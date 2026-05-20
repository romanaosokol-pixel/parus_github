create or replace procedure UDO_P_PRODUCTORD_MTR_REST
(
  nCOMPANY   in number,
  nIDENT     in number,
  nSIGN_ALL  in number, -- остатки по всем темам
  nSIGN_DIFF in number -- разделить потребность по заказам на производство
) as
  /*
    14/06/2024 Марков МВ.
    Заказы на производство.
    Пользовательское действие "Потребность по остаткам на складах"
    
    Оценка потребности в ТМЦ по остаткам на складах ЭРИ и ДСЕ.
    Пока только на этих складах.
    
    UDO_PRODORD_MTR_REST - потребность по ПС
    UDO_PRODORD_MTR_REST_SUPPLY - остатки
    UDO_PRODORD_MTR_REST_CMPSP - входимость по ПС
    UDO_PRODORD_MTR_REST_D28 - возможные замены (все)
    UDO_PRODORD_MTR_REST_TMP - сводная таблица по остаткам
  */

  /* очистка временной таблицы */
  procedure clear_rest is
  begin
    delete from UDO_PRODORD_MTR_REST where AUTHID = utilizer;
    delete from UDO_PRODORD_MTR_REST_TMP  where AUTHID = utilizer;
  end clear_rest;

  /* Функция определяет тему по серии из ПО */
  function get_tema_by_sernumb(sSERNUMB in varchar2) return varchar2 is
    sRES varchar2(2000);
  begin
    for rio in (select IOS.RN,
                       (select count(*)
                          from INORDERSPECSCLC CLC
                         where CLC.PRN = IOS.RN
                           and CLC.FACEACCOUNT is not null) as CLC_CNT
                  from INORDERSPECS IOS,
                       INORDERS     IO
                 where trim(IOS.SERNUMB) = sSERNUMB
                   and IOS.PRN = IO.RN
                 order by IO.INDOCDATE) loop
      --
      if rio.clc_cnt > 0 then
        -- по калькуляции
        for rcl in (select CLC.FACEACCOUNT from INORDERSPECSCLC CLC where CLC.PRN = rio.rn) loop
          sRES := UDO_F_FACEACC_GET_SHEFR(NRN => rcl.faceaccount);
        end loop;
      else
        -- по связи с заказом подразделения
        null;
      end if;
      --
    end loop;
    return sRES;
  end get_tema_by_sernumb;

  /* процедура наполнения ТМЦ по спецификации */
  procedure set_cmp
  (
    nID         in number, -- идентификатор
    nORD        in number, -- заказ на производство
    nORDS       in number, -- спецификация заказа
    nQUANT_PROD in number, -- количество изделий
    nPRODCMP    in number, -- ПС
    nDIFF       in number -- разделить потребность по заказам
  ) is
    rREST  UDO_PRODORD_MTR_REST%rowtype;
    rCMPSP UDO_PRODORD_MTR_REST_CMPSP%rowtype;
    --
    procedure ins_rest(rROW in out UDO_PRODORD_MTR_REST%rowtype) is
    begin
      rROW.Rn := gen_ident;
      insert into UDO_PRODORD_MTR_REST values rROW;
    end ins_rest;
    --
    procedure ins_cmpsp(rROW in out UDO_PRODORD_MTR_REST_CMPSP%rowtype) is
    begin
      rROW.Rn := rROW.Prodcmp_Sp;
      insert into UDO_PRODORD_MTR_REST_CMPSP values rROW;
    end ins_cmpsp;
  
  begin
    -- формируем список покупных ТМЦ по ПС
    rREST.Ident      := nID;
    rREST.Authid     := utilizer;
    rREST.Prodord    := nORD;
    rREST.Prodord_Sp := nORDS;
    rREST.Prod_Quant := nQUANT_PROD;
    rREST.Quant_Plan := 0;
    rREST.Rest_Sp    := 0;
    rREST.Rest_Dir   := 0;
    rCMPSP.Ident     := nID;
    -- тема заказа
    begin
      select UDO_F_FACEACC_GET_SHEFR(NRN => ORD.FACEACC)
        into rREST.Tema
        from PRODUCTORD ORD
       where ORD.RN = nORD
         and ORD.FACEACC is not null;
    exception
      when no_data_found then
        rREST.Tema := to_char(null);
    end;
    -- сформируем потребность
    for rcmp in (select CSP.RN,
                        CSP.MTR_RES,
                        CSP.PROD_QUANT,
                        (select HSP.MTR_RES
                           from FCPRODCMPSP HSP
                          where HSP.PRN = CSP.PRN
                            and HSP.RN = CSP.HRN) as HRN_MTR_RES
                   from FCPRODCMPSP CSP
                  where CSP.PRN = nPRODCMP
                    and CSP.HRN is not null
                    and CSP.SIGN_RES = 1
                    and CSP.PROD_QUANT > 0
                  order by CSP.HIER_LEVEL) loop
      -- найдем в списке потребности
      begin
        select R.*
          into rREST
          from UDO_PRODORD_MTR_REST R
         where R.IDENT = nID
           and R.MATRES = rcmp.mtr_res
           and ((nDIFF = 1 and R.PRODORD = nORD) or nDIFF = 0);
      exception
        when no_data_found then
          -- добавим
          rREST.Matres := rcmp.mtr_res;
          ins_rest(rROW => rREST);
      end;
      -- добавим спецификацию
      rCMPSP.Prn        := rREST.Rn;
      rCMPSP.Prodcmp_Sp := rcmp.rn;
      rCMPSP.Part_Of    := rcmp.hrn_mtr_res;
      rCMPSP.Quant_Prod := round(rcmp.prod_quant, 3);
      ins_cmpsp(rROW => rCMPSP);
    
    end loop;
  
  end set_cmp;

  /* процедура формирования возможных замен */
  procedure set_d28(nID in number) is
    rD28 UDO_PRODORD_MTR_REST_D28%rowtype;
    --
    procedure ins_d28
    (
      nMATRES in number,
      rROW    in out UDO_PRODORD_MTR_REST_D28%rowtype
    ) is
    begin
      for rd in (select R.RN
                   from UDO_PRODORD_MTR_REST R
                  where R.IDENT = nID
                    and R.MATRES = nMATRES) loop
        rROW.Rn  := rROW.Modif;
        rROW.Prn := rd.rn;
        insert into UDO_PRODORD_MTR_REST_D28 values rROW;
      end loop;
    end ins_d28;
  
  begin
    rD28.Ident  := nID;
    rD28.Authid := utilizer;
    -- по всем позициям потребности
    for rdr in (select distinct MR.NOMEN_MODIF,
                                R.MATRES
                  from UDO_PRODORD_MTR_REST R,
                       FCMATRESOURCE        MR
                 where R.IDENT = nID
                   and R.MATRES = MR.RN
                   and MR.NOMEN_MODIF is not null) loop
      -- ищем замены по распоряжению об изменении заказа подразделения
      -- новые
      for rdd in (select distinct DCH.MODIF_CHNG
                    from UDO_DEPORDDIR_SP   DSP,
                         UDO_DEPORDDIR_CHNG DCH,
                         UDO_DEPORDDIR      D
                   where DSP.MODIF = rdr.nomen_modif
                     and DCH.PRN = DSP.RN
                     and DSP.PRN = D.RN
                     and D.STATE in (1, 6) -- только отработанные
                  ) loop
        rD28.Modif := rdd.modif_chng;
        begin
          select MR.RN into rD28.Matres from FCMATRESOURCE MR where MR.NOMEN_MODIF = rD28.Modif;
        exception
          when no_data_found then
            rD28.Matres := to_number(null);
        end;
        --
        ins_d28(nMATRES => rdr.matres, rROW => rD28);
      end loop;
      -- старые
      for rdd1 in (select distinct DSP.MODIF_CHNG
                     from UDO_DEPORDDIR_SP DSP,
                          UDO_DEPORDDIR    D
                    where DSP.MODIF = rdr.nomen_modif
                      and DSP.MODIF_CHNG is not null
                      and DSP.PRN = D.RN
                      and D.STATE in (1, 6) -- только отработанные
                      and not exists (select null from UDO_DEPORDDIR_CHNG DCH where DCH.PRN = DSP.RN)
                      and not exists (select null
                             from UDO_PRODORD_MTR_REST_D28 R28
                            where R28.IDENT = nID
                              and R28.MODIF = DSP.MODIF_CHNG)) loop
        rD28.Modif := rdd1.modif_chng;
        begin
          select MR.RN into rD28.Matres from FCMATRESOURCE MR where MR.NOMEN_MODIF = rD28.Modif;
        exception
          when no_data_found then
            rD28.Matres := to_number(null);
        end;
        --
        ins_d28(nMATRES => rdr.matres, rROW => rD28);
      end loop;
    
    end loop;
  end set_d28;

  /* процедура поиска остатков по потребности */
  procedure set_supply(nID in number) is
    rSUPPLY UDO_PRODORD_MTR_REST_SUPPLY%rowtype;
    --
    procedure ins_supply(rROW in out UDO_PRODORD_MTR_REST_SUPPLY%rowtype) is
    begin
      rROW.Rn := rROW.Supply;
      insert into UDO_PRODORD_MTR_REST_SUPPLY values rROW;
    end ins_supply;
  
  begin
    rSUPPLY.Ident := nID;
    -- по всем остаткам модификации в спецификации (оригиналы)
    for rspc in (select R.RN,
                        GS.RESTFACT,
                        GS.RESERV,
                        GP.NOMMODIF,
                        GP.RN as PARTY,
                        GS.RN as SUPPLY,
                        trim(GP.SERNUMB) as SERNUMB,
                        (select UDO_F_FACEACC_GET_SHEFR(NRN => CLC.FACEACC)
                           from GOODSSUPPLYCLC CLC
                          where CLC.PRN = GS.RN
                            and CLC.QUANT_FACT > 0
                            and CLC.FACEACC is not null
                            and rownum < 2) as TEMA
                   from UDO_PRODORD_MTR_REST R,
                        FCMATRESOURCE        MR,
                        GOODSPARTIES         GP,
                        GOODSSUPPLY          GS
                  where R.IDENT = nID
                    and R.MATRES = MR.RN
                    and GP.NOMMODIF = MR.NOMEN_MODIF
                    and GS.PRN = GP.RN
                    and GS.STORE in (select ST.RN
                                       from AZSAZSLISTMT ST,
                                            STKIND       SK
                                      where ST.STKIND = SK.RN
                                        and SK.CODE in ('ДСЕ', 'ЭРИ')
                                        and ST.AZS_NUMBER not in ('ВремПеремещение'))
                    and GS.RESTFACT > 0) loop
      rSUPPLY.Prn          := rspc.rn;
      rSUPPLY.Modif        := rspc.nommodif;
      rSUPPLY.Party        := rspc.party;
      rSUPPLY.Supply       := rspc.supply;
      rSUPPLY.Quant_Rest   := rspc.restfact;
      rSUPPLY.Quant_Reserv := rspc.reserv;
      rSUPPLY.Modif_Chng   := to_number(null);
      --
      if rspc.tema is null then
        -- определим по поставке
        rSUPPLY.Tema := get_tema_by_sernumb(sSERNUMB => rspc.sernumb);
      else
        rSUPPLY.Tema := rspc.tema;
      end if;
      --
      ins_supply(rROW => rSUPPLY);
    end loop;
  
    -- по всем остаткам замен
    for rspd in (select R.RN,
                        MR.NOMEN_MODIF,
                        GS.RESTFACT,
                        GS.RESERV,
                        GP.NOMMODIF,
                        GP.RN as PARTY,
                        GS.RN as SUPPLY,
                        trim(GP.SERNUMB) as SERNUMB,
                        (select UDO_F_FACEACC_GET_SHEFR(NRN => CLC.FACEACC)
                           from GOODSSUPPLYCLC CLC
                          where CLC.PRN = GS.RN
                            and CLC.QUANT_FACT > 0
                            and CLC.FACEACC is not null
                            and rownum < 2) as TEMA
                   from UDO_PRODORD_MTR_REST_D28 R28,
                        UDO_PRODORD_MTR_REST     R,
                        GOODSPARTIES             GP,
                        GOODSSUPPLY              GS,
                        FCMATRESOURCE            MR
                  where R.IDENT = nID
                    and R28.PRN = R.RN
                    and R.MATRES = MR.RN
                    and GP.NOMMODIF = R28.MODIF
                    and GS.PRN = GP.RN
                    and GS.STORE in (select ST.RN
                                       from AZSAZSLISTMT ST,
                                            STKIND       SK
                                      where ST.STKIND = SK.RN
                                        and SK.CODE in ('ДСЕ', 'ЭРИ')
                                        and ST.AZS_NUMBER not in ('ВремПеремещение'))
                    and GS.RESTFACT > 0) loop
      rSUPPLY.Prn          := rspd.rn;
      rSUPPLY.Modif        := rspd.nomen_modif;
      rSUPPLY.Party        := rspd.party;
      rSUPPLY.Supply       := rspd.supply;
      rSUPPLY.Quant_Rest   := rspd.restfact;
      rSUPPLY.Quant_Reserv := rspd.reserv;
      rSUPPLY.Modif_Chng   := rspd.nommodif;
      --
      if rspd.tema is null then
        -- определим по поставке
        rSUPPLY.Tema := get_tema_by_sernumb(sSERNUMB => rspd.sernumb);
      else
        rSUPPLY.Tema := rspd.tema;
      end if;
      --
      ins_supply(rROW => rSUPPLY);
    end loop;
  
  end set_supply;

  /* процедура пересчета потребности */
  procedure rest_recalc
  (
    nID   in number,
    nDIFF in number
  ) is
  begin
    for rspl in (select R.RN,
                        (select nvl(sum(RSP.QUANT_PROD), 0)
                           from UDO_PRODORD_MTR_REST_CMPSP RSP
                          where RSP.PRN = R.RN
                            and RSP.IDENT = R.IDENT) as QUANT_PROD,
                        (select nvl(sum(RS.QUANT_RESERV), 0)
                           from UDO_PRODORD_MTR_REST_SUPPLY RS
                          where RS.PRN = R.RN
                            and RS.IDENT = R.IDENT
                            and RS.MODIF_CHNG is null) as RESERV,
                        (select nvl(sum(RS.QUANT_REST), 0)
                           from UDO_PRODORD_MTR_REST_SUPPLY RS
                          where RS.PRN = R.RN
                            and RS.IDENT = R.IDENT
                            and RS.MODIF_CHNG is null) as REST,
                        (select nvl(sum(RS.QUANT_RESERV), 0)
                           from UDO_PRODORD_MTR_REST_SUPPLY RS
                          where RS.PRN = R.RN
                            and RS.IDENT = R.IDENT
                            and RS.MODIF_CHNG is not null) as RESERV_DIR,
                        (select nvl(sum(RS.QUANT_REST), 0)
                           from UDO_PRODORD_MTR_REST_SUPPLY RS
                          where RS.PRN = R.RN
                            and RS.IDENT = R.IDENT
                            and RS.MODIF_CHNG is not null) as REST_DIR
                   from UDO_PRODORD_MTR_REST R
                  where R.IDENT = nID) loop
      update UDO_PRODORD_MTR_REST R
         set R.REST_SP    = rspl.rest,
             R.REST_DIR   = rspl.rest_dir,
             R.RESERV_SP  = rspl.reserv,
             R.RESERV_DIR = rspl.reserv_dir,
             R.QUANT_PLAN = rspl.quant_prod
       where IDENT = nID
         and RN = rspl.rn;
    end loop;
  end rest_recalc;

  /* процедура формирования сводных данных */
  procedure create_tmp(nID in number, nALL in number) is
    rTMP UDO_PRODORD_MTR_REST_TMP%rowtype;
    --
    procedure ins_tmp(rROW in out UDO_PRODORD_MTR_REST_TMP%rowtype) is
    begin
      insert into UDO_PRODORD_MTR_REST_TMP values rROW;
    end ins_tmp;
  begin
    --
    rTMP.Ident  := nID;
    rTMP.Authid := utilizer;
    -- по потребности
    for rmtr in (select * from UDO_PRODORD_MTR_REST R where R.IDENT = nID) loop
      rTMP.Matres            := rmtr.matres;
      rTMP.Prod_Quant        := rmtr.quant_plan;
      rTMP.Quant_Tema_Rest   := 0;
      rTMP.Quant_Tema_Reserv := 0;
      rTMP.Quant_Rest   := rmtr.rest_sp;
      rTMP.Quant_Reserv := rmtr.reserv_sp;
      rTMP.Modif_Chng   := null;
      -- если есть остатки по оригиналу
      if nvl(rmtr.rest_sp, 0) > 0 then
        -- соберем темы остатков
        rTMP.Tema_Rest := '';
        for rrsp in (select RS.TEMA,
                            nvl(sum(RS.QUANT_REST), 0) as REST,
                            nvl(sum(RS.QUANT_RESERV), 0) as RESERV
                       from UDO_PRODORD_MTR_REST_SUPPLY RS
                      where RS.PRN = rmtr.rn
                        and RS.IDENT = rmtr.ident
                        and RS.MODIF_CHNG is null
                        and rtrim(RS.TEMA) is not null
                      group by RS.TEMA) loop
          if rtrim(rTMP.Tema_Rest) is null then
            rTMP.Tema_Rest := rrsp.tema;
          else
            if length(rTMP.Tema_Rest || ';' || rrsp.tema) <= 2000 then
              rTMP.Tema_Rest := rTMP.Tema_Rest || ';' || rrsp.tema;
            end if;
          end if;
          -- количество по теме заказа
          if nALL = 1 or (rtrim(rrsp.tema) is not null and rrsp.tema = rmtr.tema) then
            rTMP.Quant_Tema_Rest   := rTMP.Quant_Tema_Rest + rrsp.rest;
            rTMP.Quant_Tema_Reserv := rTMP.Quant_Tema_Reserv + rrsp.reserv;
          end if;
        end loop;
      end if;
      -- добавим остаток оригинала
      ins_tmp(rROW => rTMP);
      -- если есть остатки по заменам
      if rmtr.rest_dir > 0 then
        -- по каждой замене
        for rrdr in (select RS.MODIF_CHNG,
                            nvl(sum(RS.QUANT_REST), 0) as REST,
                            nvl(sum(RS.QUANT_RESERV), 0) as RESERV
                       from UDO_PRODORD_MTR_REST_SUPPLY RS
                      where RS.IDENT = rmtr.ident
                        and RS.PRN = rmtr.rn
                        and RS.MODIF_CHNG is not null
                      group by RS.MODIF_CHNG) loop
          rTMP.Modif_Chng   := rrdr.modif_chng;
          rTMP.Quant_Rest   := rrdr.rest;
          rTMP.Quant_Reserv := rrdr.reserv;
          -- список тем
          rTMP.Tema_Rest         := '';
          rTMP.Quant_Tema_Rest   := 0;
          rTMP.Quant_Tema_Reserv := 0;
          for rrsp in (select RS.TEMA,
                              nvl(sum(RS.QUANT_REST), 0) as REST,
                              nvl(sum(RS.QUANT_RESERV), 0) as RESERV
                         from UDO_PRODORD_MTR_REST_SUPPLY RS
                        where RS.PRN = rmtr.rn
                          and RS.IDENT = rmtr.ident
                          and rtrim(RS.TEMA) is not null
                          and RS.MODIF_CHNG = rrdr.modif_chng
                        group by RS.TEMA) loop
            if rtrim(rTMP.Tema_Rest) is null then
              rTMP.Tema_Rest := rrsp.tema;
            else
              if length(rTMP.Tema_Rest || ';' || rrsp.tema) <= 2000 then
                rTMP.Tema_Rest := rTMP.Tema_Rest || ';' || rrsp.tema;
              end if;
            end if;
            -- количество по теме заказа
            if rrsp.tema = rmtr.tema then
              rTMP.Quant_Tema_Rest   := rTMP.Quant_Tema_Rest + rrsp.rest;
              rTMP.Quant_Tema_Reserv := rTMP.Quant_Tema_Reserv + rrsp.reserv;
            end if;
          end loop;
          -- добавим остаток по замене
          ins_tmp(rROW => rTMP);
        end loop;
      end if;
    
    end loop;
  
  end create_tmp;

begin
  -- предварительная очистка
  clear_rest;
  -- по всем отмеченным заказам на производство
  for rpo in (select ORD.RN as PRN,
                     ORD.CRN,
                     ORDS.RN as RN,
                     ORDS.PRODCMP,
                     ORDS.MAIN_QUANT,
                     trim(ORD.ORD_PREF) || '-' || trim(ORD.ORD_NUMB) as ORD_NUMB
                from PRODUCTORD  ORD,
                     PRODUCTORDS ORDS,
                     SELECTLIST  SL
               where SL.IDENT = nIDENT
                 and SL.DOCUMENT = ORD.RN
                 and ORDS.PRN = ORD.RN) loop
    if rpo.crn not in (131671756) then
      p_exception(0, 'Оценка потребности доступна только для заказов на производство в каталоге "Прогноз"!!!');
    end if;
    if rpo.prodcmp is null then
      p_exception(0, 'Для заказа на производство %s не указана ПС.', rpo.ord_numb);
    else
      -- потребность по спецификации
      set_cmp(nID         => nIDENT,
              nORD        => rpo.prn,
              nORDS       => rpo.rn,
              nQUANT_PROD => 1,
              nPRODCMP    => rpo.prodcmp,
              nDIFF       => nvl(nSIGN_DIFF, 0));
    end if;
  end loop;
  -- формирование возможных замен
  set_d28(nID => nIDENT);
  -- остатки на складах
  set_supply(nID => nIDENT);
  -- пересчет потребности
  rest_recalc(nID => nIDENT, nDIFF => nvl(nSIGN_DIFF, 0));

  -- формирование сводных данных
  create_tmp(nID => nIDENT, nALL => nvl(nSIGN_ALL, 0));
  
end;
/
