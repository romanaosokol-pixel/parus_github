create or replace procedure UDO_P_PRODUCTORDS_REM_ONE
(
  nCOMPANY in number, -- организация
  nIDENT   in number, -- отмеченные записи
  sNOMEN   in varchar2, -- номенклатура
  sMODIF   in varchar2, -- модификация
  sSERNUMB in varchar2 -- серийный номер для выделения
) as
  /*
    03/05/2023 Марков МВ.
    Заказы на производство (спецификация)
    Выделение заводского нмоера отдельной строкой
    
    включить в пакет UDO_PKG_PRODUCTORD
  */
  rORDS        PRODUCTORDS%rowtype;
  rORDPS       PRODUCTORDPS%rowtype;
  rPLAN_SP     FCPRODPLANSP%rowtype;
  rPROG_SP     FCPRODPLANSP%rowtype;
  nORDS_RN     PKG_STD.tREF;
  nPLAN_SP_RN  PKG_STD.tREF;
  nPROG_SP_RN  PKG_STD.tREF;
  nPROG_SP_PRN PKG_STD.tREF;
  nARTICLE     PKG_STD.tREF;
  iCNT_SER     integer;
  iCNT_REM     integer;
  sLST_REM     varchar2(2000);

  -- перенос маршрутного листа
  procedure lst_relocate
  (
    nPLAN_OLD  in number, -- строка производственной программы ОТКУДА
    nPLAN_NEW  in number, -- строка производственной программы КУДА
    nSIGN_ONE  in number, -- признак проверки наличия отдельного МЛ
    nSING_MAIN in number, -- признак головного изделия
    nART_RN    in number, -- заводской номер
    nQUANT     in number, -- количество переноса
    iCNT       in out integer -- количество смещения по заводским номерам
  ) is
    iCNT_   integer;
    nQUANT_ integer;
  begin
    -- МЛ по строке производствнной программы
    if nSING_MAIN = 1 then
      iCNT := 0;
    else
      iCNT_   := iCNT * nQUANT;
      nQUANT_ := nQUANT;
    end if;
    --
    for rls in (select LST.RN as LST_RN,
                       trim(LST.DOCPREF) || '-' || trim(LST.DOCNUMB) as LST_NUMB,
                       LSR.RN as LSR_RN,
                       LSR.ARTICLE,
                       RA.CODE as SER_NUMB,
                       (select count(*) from FCROUTLSTSERNUMB SR where SR.PRN = LST.RN) as SER_CNT
                  from FCROUTLST        LST,
                       DOCLINKS         L,
                       FCROUTLSTSERNUMB LSR,
                       RLARTICLES       RA
                 where L.IN_DOCUMENT = nPLAN_OLD
                   and L.IN_UNITCODE = 'CostProductPlansSpecs'
                   and L.OUT_DOCUMENT = LST.RN
                   and L.OUT_UNITCODE = 'CostRouteLists'
                   and LSR.PRN = LST.RN
                   and LSR.ARTICLE = RA.RN
                 order by RA.CODE) loop
    
      -- контроль заводского номера
      if nART_RN is null then
        -- это не головное изделие
        -- делаем смещение по количеству заводских номеров
        iCNT_ := iCNT_ - 1;
        if iCNT_ < 0 then
          -- этот номер
          if nQUANT_ > 0 then
            -- переносим указанное количество номеров
            nQUANT_ := nQUANT_ - 1;
            if rls.ser_cnt > 1 and
               nSIGN_ONE = 1 then
              p_exception(0,
                          'Заводской номер %s входит в МЛ на несколько заводских номеров.' || chr(10) ||
                          'Выделение в отдельную строку невозможно!',
                          rls.ser_numb);
            elsif rls.ser_cnt > 1 and
                  nSIGN_ONE = 0 then
              -- не переносим
              null;
            else
              -- перенос МЛ на новую строку программы
              iCNT_REM := iCNT_REM + 1;
              sLST_REM := nvl(sLST_REM, '') || ';' || rls.lst_numb;
              -- переносим только связь со строкой программы
              for rld in (select *
                            from DOCLINKS L
                           where L.IN_DOCUMENT = nPLAN_OLD
                             and L.OUT_DOCUMENT = rls.lst_rn) loop
                -- удалим старую
                pkg_doclinks.REMOVE(sIN_UNITCODE  => rld.in_unitcode,
                                    nIN_DOCUMENT  => rld.in_document,
                                    sOUT_UNITCODE => rld.out_unitcode,
                                    nOUT_DOCUMENT => rld.out_document);
                -- создадим новую
                pkg_doclinks.LINK(nFLAG_SMART   => 0,
                                  nCOMPANY      => nCOMPANY,
                                  sIN_UNITCODE  => rld.in_unitcode,
                                  nIN_DOCUMENT  => nPLAN_NEW,
                                  sOUT_UNITCODE => rld.out_unitcode,
                                  nOUT_DOCUMENT => rld.out_document);
              end loop;
            end if;
          end if;
          --
        end if;
      
      else
        if rls.article = nART_RN then
          -- этот номер
          if rls.ser_cnt > 1 and
             nSIGN_ONE = 1 then
            p_exception(0,
                        'Заводской номер %s входит в МЛ на несколько заводских номеров.' || chr(10) ||
                        'Выделение в отдельную строку невозможно!',
                        rls.ser_numb);
          else
            -- перенос МЛ на новую строку программы
            iCNT_REM := iCNT_REM + 1;
            if rtrim(sLST_REM) is null then
              sLST_REM := rls.lst_numb;
            else
              sLST_REM := sLST_REM || ';' || rls.lst_numb;
            end if;
            -- переносим только связь со строкой программы
            for rld in (select *
                          from DOCLINKS L
                         where L.IN_DOCUMENT = nPLAN_OLD
                           and L.OUT_DOCUMENT = rls.lst_rn) loop
              -- удалим старую
              pkg_doclinks.REMOVE(sIN_UNITCODE  => rld.in_unitcode,
                                  nIN_DOCUMENT  => rld.in_document,
                                  sOUT_UNITCODE => rld.out_unitcode,
                                  nOUT_DOCUMENT => rld.out_document);
              -- создадим новую
              pkg_doclinks.LINK(nFLAG_SMART   => 0,
                                nCOMPANY      => nCOMPANY,
                                sIN_UNITCODE  => rld.in_unitcode,
                                nIN_DOCUMENT  => nPLAN_NEW,
                                sOUT_UNITCODE => rld.out_unitcode,
                                nOUT_DOCUMENT => rld.out_document);
            end loop;
          end if;
          -- нашли свой номер - выход
          exit;
        
        else
          -- посчитаем сколько перед номером
          iCNT := iCNT + 1;
        end if;
      end if;
    end loop;
  
  end lst_relocate;

  -- перенос по уровням с сохранением ссылки на верхний уровень
  procedure next_rem_one
  (
    nPRN_NODE      in number,
    nUP_LVL_OLD    in number,
    nUP_LVL_NEW    in number,
    nNESTING_LEVEL in number,
    sPARTY_NUMB    in varchar2
  ) is
  begin
  
    -- перенос подчиненной иерархии программы
    for rpls in (select PPS.*
                   from FCPRODPLANSP PPS
                  where PPS.PRN_NODE = nPRN_NODE
                    and PPS.NESTING_LEVEL = nNESTING_LEVEL
                    and PPS.UP_LEVEL = nUP_LVL_OLD) loop
      rPROG_SP := rpls;
      -- контроль количества
      rPROG_SP.Main_Quant := rPROG_SP.Main_Quant / rORDS.Main_Quant;
      if rPROG_SP.Main_Quant != rORDS.Main_Quant then
        if rPROG_SP.Main_Quant != round(rPROG_SP.Main_Quant, 0) then
          begin
            select MR.NAME into rpls.route from FCMATRESOURCE MR where MR.RN = rpls.matres;
          exception
            when no_data_found then
              p_exception(0, 'Не найден материальный ресурс. RN: %s', rpls.matres);
          end;
          p_exception(0,
                      'Количество для изделия %s не кратно запуску головного изделия.',
                      rpls.route);
        end if;
      end if;
      -- уменьшим количество
      update FCPRODPLANSP PPS
         set PPS.QUANT_REST = PPS.QUANT_REST - rPROG_SP.Main_Quant,
             PPS.MAIN_QUANT = PPS.MAIN_QUANT - rPROG_SP.Main_Quant
       where PPS.RN = rPROG_SP.Rn;
      -- создадим новую запись производственной программы
      rPROG_SP.Party_Numb := sPARTY_NUMB;
      p_fcprodplansp_base_insert(nCOMPANY        => rPROG_SP.Company,
                                 nPRN            => rPROG_SP.Prn,
                                 nMATRES         => rPROG_SP.Matres,
                                 nNOMCLASSIF     => rPROG_SP.Nomclassif,
                                 nARTICLE        => rPROG_SP.Article,
                                 nDEFECT_SIGN    => rPROG_SP.Defect_Sign,
                                 nINTERNAL_SIGN  => rPROG_SP.Internal_Sign,
                                 nPARTY          => rPROG_SP.Party,
                                 nMAIN_QUANT     => rPROG_SP.Main_Quant,
                                 nALT_QUANT      => 0,
                                 nEQUAL          => 0,
                                 nMAINNORM_QUANT => rPROG_SP.Mainnorm_Quant,
                                 nALTNORM_QUANT  => rPROG_SP.Altnorm_Quant,
                                 dEXEC_DATE      => rPROG_SP.Exec_Date,
                                 dREP_DATE       => rPROG_SP.Rep_Date,
                                 dREP_DATE_TO    => rPROG_SP.Rep_Date_To,
                                 nPR_COND        => rPROG_SP.Pr_Cond,
                                 nSUBDIV_DLVR    => rPROG_SP.Subdiv_Dlvr,
                                 nROUTSHT        => rPROG_SP.Routsht,
                                 nROUTSHTSP      => rPROG_SP.Routshtsp,
                                 nLOSTTYPE       => rPROG_SP.Losttype,
                                 nLOSTDEFL       => rPROG_SP.Lostdefl,
                                 nSUBDIV         => rPROG_SP.Subdiv,
                                 nAGENT          => rPROG_SP.Agent,
                                 nSTORE          => rPROG_SP.Store,
                                 nSTORE_OPER     => rPROG_SP.Store_Oper,
                                 nCOST_ARTICLE   => rPROG_SP.Cost_Article,
                                 nCOST_PLACE     => rPROG_SP.Cost_Place,
                                 nPROD_ORDER     => rPROG_SP.Prod_Order,
                                 nCOST_MATRES    => rPROG_SP.Cost_Matres,
                                 nPER_MATRES     => rPROG_SP.Per_Matres,
                                 nPER_ARTICLE    => rPROG_SP.Per_Article,
                                 nNESTING_LEVEL  => rPROG_SP.Nesting_Level,
                                 nPRIORITY       => rPROG_SP.Priority,
                                 nQUANT_REST     => 1,
                                 nREL_FACT       => 0,
                                 nSTART_FACT     => 0,
                                 nBASE_MTR       => rPROG_SP.Base_Mtr,
                                 nPROD_SIGN      => rPROG_SP.Prod_Sign,
                                 nRN             => nPROG_SP_RN,
                                 dCORR_DATE      => sysdate,
                                 sCORR_BASE      => rPROG_SP.Corr_Base,
                                 nPRODCMP        => rPROG_SP.Prodcmp,
                                 nPRODCMPSP      => rPROG_SP.Prodcmpsp,
                                 sPARTY_NUMB     => rPROG_SP.Party_Numb,
                                 nPRN_NODE       => nPROG_SP_PRN,
                                 nREL_IGN_REST   => 1,
                                 nUP_LEVEL       => nUP_LVL_NEW);
    
      -- перенос маршрутного листа
      lst_relocate(nPLAN_OLD  => rPROG_SP.Rn,
                   nPLAN_NEW  => nPROG_SP_RN,
                   nSIGN_ONE  => 0,
                   nSING_MAIN => 0,
                   nART_RN    => null,
                   nQUANT     => rPROG_SP.Main_Quant,
                   iCNT       => iCNT_SER);
    
      -- перенос по уровням с сохранением ссылки на верхний уровень
      next_rem_one(nPRN_NODE      => rPLAN_SP.Rn,
                   nUP_LVL_OLD    => rPROG_SP.Rn,
                   nUP_LVL_NEW    => nPROG_SP_RN,
                   nNESTING_LEVEL => nNESTING_LEVEL + 1,
                   sPARTY_NUMB    => sPARTY_NUMB);
    
    end loop;
  
  end next_rem_one;

begin
  -- пролог
  if utilizer not in ('CITK_MARKOV') then
    p_exception(0, ' У Вас нет прав на выполнение процедуры.');
  end if;
  -- выполнение
  iCNT_REM := 0;
  -- может быть отмечена только 1 запись спецификации
  for rdp in (select PS.*
                from SELECTLIST  SL,
                     PRODUCTORDS PS
               where SL.IDENT = nIDENT
                 and SL.DOCUMENT = PS.RN) loop
    if rORDS.Rn is not null then
      p_exception(0, 'Необходимо отметить только одну запись!!!');
    end if;
    -- параметры строки заказа на производство
    rORDS := rdp;
    begin
      select PPS.* into rORDPS from PRODUCTORDPS PPS where PPS.PRN = rORDS.Rn;
    exception
      when no_data_found then
        p_exception(0,
                    'Ошибка определения исполнения по строке спецификации!!!');
    end;
    -- заводской номер (серийное изделие)
    begin
      select RA.RN
        into nARTICLE
        from RLARTICLES RA
       where RA.NOMMODIF = rORDS.Nom_Modif
         and RA.CODE = sSERNUMB;
    exception
      when no_data_found then
        p_exception(0,
                    'Заводской номер %s для изделия %s не найден.',
                    sSERNUMB,
                    sNOMEN);
    end;
  end loop;
  --
  if rORDS.Main_Quant < 2 then
    p_exception(0,
                'КОличество по строке спецификации должно быть больше единицы!!!');
  end if;
  -- добавим новую
  PKG_FLAG.SET_FLAG;
  p_productords_base_insert(nCOMPANY     => rORDS.Company,
                            nPRN         => rORDS.Prn,
                            nNOMEN       => rORDS.Nomen,
                            nNOM_PACK    => rORDS.Nom_Pack,
                            nNOM_MODIF   => rORDS.Nom_Modif,
                            nNOMMOD_PACK => rORDS.Nommod_Pack,
                            nPRODUCT     => rORDS.Product,
                            nEXP_PRICE   => rORDS.Exp_Price,
                            nPR_MEAS     => rORDS.Pr_Meas,
                            nSTORE       => rORDS.Store,
                            sNOTE        => rORDS.Note,
                            nCOST_PLAN   => rORDS.Cost_Plan,
                            nCOST_FACT   => rORDS.Cost_Fact,
                            nCOST_NPZ    => rORDS.Cost_Npz,
                            nPRODCMP     => rORDS.Prodcmp,
                            dACTPF_DATE  => rORDPS.Actpf_Date,
                            nACTM_QUANT  => 1,
                            nACTA_QUANT  => 0,
                            nACTSUMM     => 0,
                            nIGNOREPERF  => 0,
                            nRN          => nORDS_RN);
  -- изменим количество в старой строке заказа
  p_productords_base_update(nCOMPANY     => rORDS.Company,
                            nRN          => rORDS.Rn,
                            nNOMEN       => rORDS.Nomen,
                            nNOM_PACK    => rORDS.Nom_Pack,
                            nNOM_MODIF   => rORDS.Nom_Modif,
                            nNOMMOD_PACK => rORDS.Nommod_Pack,
                            nPRODUCT     => rORDS.Product,
                            nEXP_PRICE   => rORDS.Exp_Price,
                            nPR_MEAS     => rORDS.Pr_Meas,
                            nSTORE       => rORDS.Store,
                            sNOTE        => rORDS.Note,
                            nCOST_PLAN   => rORDS.Cost_Plan,
                            nCOST_FACT   => rORDS.Cost_Fact,
                            nCOST_NPZ    => rORDS.Cost_Npz,
                            nPRODCMP     => rORDS.Prodcmp,
                            nPERFS_STATE => rORDPS.Perfs_State, -- для исполнения.
                            dCS_DATE     => rORDPS.Cs_Date,
                            dACTPF_DATE  => rORDPS.Actpf_Date,
                            dCUST_DATE   => rORDPS.Cust_Date,
                            dEXEC_DATE   => rORDPS.Exec_Date,
                            nACTM_QUANT  => rORDPS.Actm_Quant - 1,
                            nACTA_QUANT  => rORDPS.Acta_Quant,
                            nCUSTM_QUANT => rORDPS.Custm_Quant - 1,
                            nCUSTA_QUANT => rORDPS.Custa_Quant,
                            nEXECM_QUANT => rORDPS.Execm_Quant - 1,
                            nEXECA_QUANT => rORDPS.Execa_Quant,
                            nACTSUMM     => rORDPS.Actsumm,
                            nCUSTSUMM    => rORDPS.Custsumm,
                            nEXECSUMM    => rORDPS.Execsumm);

  PKG_FLAG.RESET_FLAG;
  --
  rPLAN_SP.Rn := f_doclinks_link_out_doc(sIN_UNITCODE  => 'ProductionOrdersSpecs',
                                         nIN_DOCUMENT  => rORDS.Rn,
                                         sOUT_UNITCODE => 'CostProductPlansSpecs');
  if rPLAN_SP.Rn is null then
    -- Строка заказа на производство не включена в план выпуска.
    -- Достаточно выделить только по заказу
    return; -- все
  end if;

  -- строка включена в план выпуска
  begin
    select PPS.* into rPLAN_SP from FCPRODPLANSP PPS where PPS.RN = rPLAN_SP.Rn;
  exception
    when no_data_found then
      p_exception(0, 'Строка плана выпуска для строки заказа не найдена.');
  end;
  -- уменьшим выпуск по старой строке
  update FCPRODPLANSP PPS
     set PPS.QUANT_REST = PPS.QUANT_REST - 1,
         PPS.MAIN_QUANT = PPS.MAIN_QUANT - 1
   where PPS.RN = rPLAN_SP.Rn;
  -- инициализация новой строки
  rPLAN_SP.Main_Quant     := 1;
  rPLAN_SP.Quant_Rest     := 1;
  rPLAN_SP.Quant_Woff     := 0;
  rPLAN_SP.Quant_Shopplan := 0;
  select max(lpad(PARTY_NUMB, 20, ' ')) into rPLAN_SP.Party_Numb from FCPRODPLANSP where PRN = rPLAN_SP.Prn;
  rPLAN_SP.Party_Numb := PKG_INCREMENT.DOCUMENT_(rPLAN_SP.Party_Numb, 20);
  -- добавим новую строку плана выпуска
  p_fcprodplansp_base_insert(nCOMPANY        => rPLAN_SP.Company,
                             nPRN            => rPLAN_SP.Prn,
                             nMATRES         => rPLAN_SP.Matres,
                             nNOMCLASSIF     => rPLAN_SP.Nomclassif,
                             nARTICLE        => rPLAN_SP.Article,
                             nDEFECT_SIGN    => rPLAN_SP.Defect_Sign,
                             nINTERNAL_SIGN  => rPLAN_SP.Internal_Sign,
                             nPARTY          => rPLAN_SP.Party,
                             nMAIN_QUANT     => 1,
                             nALT_QUANT      => 0,
                             nEQUAL          => 0,
                             nMAINNORM_QUANT => rPLAN_SP.Mainnorm_Quant,
                             nALTNORM_QUANT  => rPLAN_SP.Altnorm_Quant,
                             dEXEC_DATE      => rPLAN_SP.Exec_Date,
                             dREP_DATE       => rPLAN_SP.Rep_Date,
                             dREP_DATE_TO    => rPLAN_SP.Rep_Date_To,
                             nPR_COND        => rPLAN_SP.Pr_Cond,
                             nSUBDIV_DLVR    => rPLAN_SP.Subdiv_Dlvr,
                             nROUTSHT        => rPLAN_SP.Routsht,
                             nROUTSHTSP      => rPLAN_SP.Routshtsp,
                             nLOSTTYPE       => rPLAN_SP.Losttype,
                             nLOSTDEFL       => rPLAN_SP.Lostdefl,
                             nSUBDIV         => rPLAN_SP.Subdiv,
                             nAGENT          => rPLAN_SP.Agent,
                             nSTORE          => rPLAN_SP.Store,
                             nSTORE_OPER     => rPLAN_SP.Store_Oper,
                             nCOST_ARTICLE   => rPLAN_SP.Cost_Article,
                             nCOST_PLACE     => rPLAN_SP.Cost_Place,
                             nPROD_ORDER     => rPLAN_SP.Prod_Order,
                             nCOST_MATRES    => rPLAN_SP.Cost_Matres,
                             nPER_MATRES     => rPLAN_SP.Per_Matres,
                             nPER_ARTICLE    => rPLAN_SP.Per_Article,
                             nNESTING_LEVEL  => rPLAN_SP.Nesting_Level,
                             nPRIORITY       => rPLAN_SP.Priority,
                             nQUANT_REST     => 1,
                             nREL_FACT       => 0,
                             nSTART_FACT     => 0,
                             nBASE_MTR       => rPLAN_SP.Base_Mtr,
                             nPROD_SIGN      => rPLAN_SP.Prod_Sign,
                             nRN             => nPLAN_SP_RN,
                             dCORR_DATE      => sysdate,
                             sCORR_BASE      => rPLAN_SP.Corr_Base,
                             nPRODCMP        => rPLAN_SP.Prodcmp,
                             nPRODCMPSP      => rPROG_SP.Prodcmpsp,
                             sPARTY_NUMB     => rPLAN_SP.Party_Numb);
  nPROG_SP_PRN := nPLAN_SP_RN;
  -- добавим линк
  PKG_DOCLINKS.LINK(nFLAG_SMART   => 0,
                    nCOMPANY      => nCOMPANY,
                    sIN_UNITCODE  => 'ProductionOrdersSpecs',
                    nIN_DOCUMENT  => nORDS_RN,
                    sOUT_UNITCODE => 'CostProductPlansSpecs',
                    nOUT_DOCUMENT => nPLAN_SP_RN);

  -- производственная программа
  -- сначала определимся с головным изделием (нужено определить параметры переноса серий модулей)
  for rpla in (select PPS.*
                 from FCPRODPLANSP PPS
                where PPS.PRN_NODE = rPLAN_SP.Rn
                  and PPS.MATRES = rPLAN_SP.Matres
                  and PPS.NESTING_LEVEL = 0) loop
    rPROG_SP := rpla;
    if rPROG_SP.Main_Quant != rORDS.Main_Quant then
      p_exception(0,
                  'Количество в спецификации заказа не равно количеству запуска!!!');
    end if;
    -- уменьшим количество
    update FCPRODPLANSP PPS
       set PPS.QUANT_REST = PPS.QUANT_REST - 1,
           PPS.MAIN_QUANT = PPS.MAIN_QUANT - 1
     where PPS.RN = rPROG_SP.Rn;
    -- создадим новую запись производственной программы
    rPROG_SP.Party_Numb := rPLAN_SP.Party_Numb;
    p_fcprodplansp_base_insert(nCOMPANY        => rPROG_SP.Company,
                               nPRN            => rPROG_SP.Prn,
                               nMATRES         => rPROG_SP.Matres,
                               nNOMCLASSIF     => rPROG_SP.Nomclassif,
                               nARTICLE        => rPROG_SP.Article,
                               nDEFECT_SIGN    => rPROG_SP.Defect_Sign,
                               nINTERNAL_SIGN  => rPROG_SP.Internal_Sign,
                               nPARTY          => rPROG_SP.Party,
                               nMAIN_QUANT     => 1,
                               nALT_QUANT      => 0,
                               nEQUAL          => 0,
                               nMAINNORM_QUANT => rPROG_SP.Mainnorm_Quant,
                               nALTNORM_QUANT  => rPROG_SP.Altnorm_Quant,
                               dEXEC_DATE      => rPROG_SP.Exec_Date,
                               dREP_DATE       => rPROG_SP.Rep_Date,
                               dREP_DATE_TO    => rPROG_SP.Rep_Date_To,
                               nPR_COND        => rPROG_SP.Pr_Cond,
                               nSUBDIV_DLVR    => rPROG_SP.Subdiv_Dlvr,
                               nROUTSHT        => rPROG_SP.Routsht,
                               nROUTSHTSP      => rPROG_SP.Routshtsp,
                               nLOSTTYPE       => rPROG_SP.Losttype,
                               nLOSTDEFL       => rPROG_SP.Lostdefl,
                               nSUBDIV         => rPROG_SP.Subdiv,
                               nAGENT          => rPROG_SP.Agent,
                               nSTORE          => rPROG_SP.Store,
                               nSTORE_OPER     => rPROG_SP.Store_Oper,
                               nCOST_ARTICLE   => rPROG_SP.Cost_Article,
                               nCOST_PLACE     => rPROG_SP.Cost_Place,
                               nPROD_ORDER     => rPROG_SP.Prod_Order,
                               nCOST_MATRES    => rPROG_SP.Cost_Matres,
                               nPER_MATRES     => rPROG_SP.Per_Matres,
                               nPER_ARTICLE    => rPROG_SP.Per_Article,
                               nNESTING_LEVEL  => rPROG_SP.Nesting_Level,
                               nPRIORITY       => rPROG_SP.Priority,
                               nQUANT_REST     => 1,
                               nREL_FACT       => 0,
                               nSTART_FACT     => 0,
                               nBASE_MTR       => rPROG_SP.Base_Mtr,
                               nPROD_SIGN      => rPROG_SP.Prod_Sign,
                               nRN             => nPROG_SP_RN,
                               dCORR_DATE      => sysdate,
                               sCORR_BASE      => rPROG_SP.Corr_Base,
                               nPRODCMP        => rPROG_SP.Prodcmp,
                               nPRODCMPSP      => rPROG_SP.Prodcmpsp,
                               sPARTY_NUMB     => rPROG_SP.Party_Numb,
                               nPRN_NODE       => nPROG_SP_PRN,
                               nREL_IGN_REST   => 1);
  
    -- перенос маршрутного листа
    lst_relocate(nPLAN_OLD  => rPROG_SP.Rn,
                 nPLAN_NEW  => nPROG_SP_RN,
                 nSIGN_ONE  => 1,
                 nSING_MAIN => 1,
                 nART_RN    => nARTICLE,
                 nQUANT     => 1,
                 iCNT       => iCNT_SER);
  
    -- перенос по уровням с сохранением ссылки на верхний уровень
    next_rem_one(nPRN_NODE => rPLAN_SP.Rn, nUP_LVL_OLD => rPROG_SP.Rn, nUP_LVL_NEW => nPROG_SP_RN, nNESTING_LEVEL => 1, sPARTY_NUMB => rPROG_SP.Party_Numb);
  
  end loop;

  -- эпилог
  if nPROG_SP_RN is not null and
     iCNT_SER >= 0 then
    null;
    /*p_exception(0, 'Пока все норм!'||chr(10)||
    'Перенесено: %s МЛ'||chr(10)||
    'МЛ: %s', iCNT_REM, sLST_REM);*/
  else
    p_exception(0,
                'Косяк!' || chr(10) || 'Перенесено: %s МЛ' || chr(10) || 'МЛ: %s',
                iCNT_REM,
                sLST_REM);
  end if;
end;
/
