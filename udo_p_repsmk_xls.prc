create or replace procedure UDO_P_REPSMK_XLS
(
  nCOMPANY in number, -- организация
  sYEAR    in varchar2 -- отчетный год
) as
  /*
    04/01/2024 Марков МВ.
    Отчет "Отчет СМК"
    В формате MS Excel
    Выпуск готовой продукции за отчетный год.
    
    Выпуск - это сдача продукци на склад СГП
    Готовое изделие - это отгружается по договору/проекту
    Модуль - это входящий модуль в готовое изделие
    
    Модуль определяется:
    - по загрузке из Интермеха - класс "Модули"
    - по признаку "Собственного изготовления", группе ТМЦ "Продукция", имеет входимость в другую спецификацию
    
    UDO_REPSMK_TMP - предварительные данные
  */

  nIDENT   PKG_STD.tREF;
  nTMP     PKG_STD.tREF;
  dBEGDATE date;
  dENDDATE date;

  -- описание
  cFORM constant varchar2(20) := 'Отчет_СМК';
  cYEAR constant varchar2(20) := 'год';
  cPRJ  constant varchar2(20) := 'проект';
  cTEMA constant varchar2(20) := 'тема';
  cAGN  constant varchar2(20) := 'заказчик';
  cLINE constant varchar2(20) := 'строка';
  cORD  constant varchar2(20) := 'нпп';
  cNOM  constant varchar2(20) := 'изделие';
  cQ_N  constant varchar2(20) := 'к_изд';
  cQ_M  constant varchar2(20) := 'к_мод';

  p    integer;
  n    integer;
  iORD integer;

  -- очистка данных
  procedure clear_tmp(nID in number) is
  begin
    delete from UDO_REPSMK_TMP where IDENT = nID;
  end clear_tmp;

  -- вставка
  procedure ins_tmp(rROW in out UDO_REPSMK_TMP%rowtype) is
  begin
    insert into UDO_REPSMK_TMP values rROW;
  end ins_tmp;

  -- определим тип продукции
  function get_sign_prod(nMATRES in number) return number is
    nRES PKG_STD.tREF;
    iCNT integer;
  begin
    begin
      select count(*) into iCNT from FCPRODLSTSP PLS where PLS.COMPLETE = nMATRES;
    exception
      when no_data_found then
        iCNT := 0;
    end;
    if iCNT = 0 then
      -- готовая продукция
      return 0;
    else
      -- модуль
      nRES := 1;
    end if;
    -- проверим модуль - по Виду изделия
    begin
      select count(*)
        into iCNT
        from FCMATRESOURCE MR,
             FCPRODUCTKIND PK
       where MR.RN = nMATRES
         and MR.PROD_KIND = PK.RN
         and PK.CODE = 'Модули';
    exception
      when no_data_found then
        iCNT := 0;
    end;
    if iCNT <= 0 then
      -- сборочная единица
      nRES := 99;
    end if;
    return nRES;
  end get_sign_prod;

  -- ШПЗ отгрузки
  function get_fa_out(nSUPPLY in number) return number is
    nRES PKG_STD.tREF;
  begin
    -- партия
    begin
      select GS.PRN into nRES from GOODSSUPPLY GS where GS.RN = nSUPPLY;
    exception
      when no_data_found then
        return null;
    end;
    -- проверим отгрузку
    for rtr in (select SOJ.RN,
                       SOJ.FACEACC,
                       SOJ.UNITCODE
                  from STOREOPERJOURN SOJ,
                       GOODSSUPPLY    GS
                 where SOJ.GOODSSUPPLY = GS.RN
                   and GS.PRN = nRES
                   and SOJ.UNITCODE = 'GoodsTransInvoicesToConsumers') loop
      if rtr.faceacc is null then
        begin
          select TC.FACEACC
            into rtr.faceacc
            from TRANSINVCUST TC,
                 DOCLINKS     L
           where L.OUT_DOCUMENT = rtr.rn
             and L.OUT_DOCUMENT = 'StoreOpersJournal'
             and L.IN_DOCUMENT = TC.RN
             and L.IN_UNITCODE = rtr.unitcode;
        exception
          when no_data_found then
            rtr.faceacc := null;
        end;
      end if;
      --
      if rtr.faceacc is not null then
        return rtr.faceacc;
      end if;
    end loop;
    return null;
  end get_fa_out;

  -- тема по ШПЗ выпуска
  function get_tema
  (
    nFACEACC in number,
    nAGENT   out number
  ) return varchar2 is
    sRES varchar2(2000);
  begin
    if nFACEACC is null then
      return null;
    end if;
    -- посмотрим в проектах
    begin
      select P.NAME_USL,
             P.EXT_CUST
        into sRES,
             nAGENT
        from PROJECT      P,
             PROJECTSTAGE PS
       where PS.FACEACC = nFACEACC
         and PS.PRN = P.RN
         and rownum < 2;
    exception
      when no_data_found then
        nAGENT := to_number(null);
    end;
    -- посмотрим в договорах
    if nAGENT is null then
      begin
        select C.AGENT,
               nvl((select DPV.STR_VALUE
                     from DOCS_PROPS_VALS DPV
                    where DPV.UNIT_RN = C.RN
                      and DPV.DOCS_PROP_RN = 6450726),
                   C.EXT_NUMBER)
          into nAGENT,
               sRES
          from CONTRACTS       C,
               STAGES          S,
               DOCS_PROPS_VALS DV,
               FACEACC         FA
         where DV.UNIT_RN = S.RN
           and DV.DOCS_PROP_RN = 12047550 -- ШПЗ
           and DV.STR_VALUE = FA.NUMB
           and FA.RN = nFACEACC
           and S.PRN = C.RN
           and rownum < 2;
      exception
        when no_data_found then
          nAGENT := to_number(null);
      end;
    end if;
    return sRES;
  end get_tema;

  -- тема по л/с отгрузки
  function get_tema_out
  (
    nFACEACC in number,
    nAGENT   out number
  ) return varchar2 is
    sRES varchar2(2000);
  begin
    if nFACEACC is null then
      return null;
    end if;
    -- посмотрим в проектах
    begin
      select P.NAME_USL,
             P.EXT_CUST
        into sRES,
             nAGENT
        from PROJECT      P,
             PROJECTSTAGE PS
       where PS.FACEACCCUST = nFACEACC
         and PS.PRN = P.RN
         and rownum < 2;
    exception
      when no_data_found then
        nAGENT := to_number(null);
    end;
    -- посмотрим в договорах
    if nAGENT is null then
      begin
        select C.AGENT,
               nvl((select DPV.STR_VALUE
                     from DOCS_PROPS_VALS DPV
                    where DPV.UNIT_RN = C.RN
                      and DPV.DOCS_PROP_RN = 6450726),
                   C.EXT_NUMBER)
          into nAGENT,
               sRES
          from CONTRACTS C,
               STAGES    S
         where S.FACEACC = nFACEACC
           and S.PRN = C.RN
           and rownum < 2;
      exception
        when no_data_found then
          nAGENT := to_number(null);
      end;
    end if;
    return sRES;
  end get_tema_out;

  -- нет отгрузки - корректировка по привязке заводского номера
  procedure get_tema_art
  (
    nARTICLE in number,
    nAGENT   in out number,
    sTEMA    in out varchar2
  ) is
  
  begin
    -- только при наличии заводского номера
    if nARTICLE is null then
      return;
    end if;
    -- привязка к этапу проекта
    begin
      select P.EXT_CUST,
             P.NAME_USL
        into nAGENT,
             sTEMA
        from UDO_PROJECTSTAGE_SHT_ART SHA,
             UDO_PROJECTSTAGE_SHT     SHT,
             PROJECTSTAGE             PS,
             PROJECT                  P
       where SHA.ARTICLE = nARTICLE
         and SHA.PRN = SHT.RN
         and SHT.PRN = PS.RN
         and PS.PRN = P.RN;
    exception
      when no_data_found then
        null;
    end;
  end get_tema_art;

  -- количество модулей в изделии
  function get_module_quant(nPRODCMP in number) return number is
    nRES number(17);
  begin
    nRES := 0;
    if nPRODCMP is null then
      return nRES;
    end if;
    for rmd in (select CSP.MTR_RES,
                       CSP.PROD_QUANT,
                       (select count(*)
                          from FCPRODUCTKIND PK
                         where PK.RN = MR.PROD_KIND
                           and PK.CODE = 'Модули') M_CNT
                  from FCPRODCMPSP   CSP,
                       FCMATRESOURCE MR
                 where CSP.PRN = nPRODCMP
                   and CSP.HIER_LEVEL > 1
                   and CSP.MTR_RES = MR.RN
                   and MR.RES_SIGN = 0
                   and exists (select null
                          from FCPRODCMPSP CS
                         where CS.PRN = nPRODCMP
                           and CS.HRN = CSP.RN)) loop
      if rmd.m_cnt > 0 then
        nRES := nRES + rmd.prod_quant;
      end if;
    end loop;
    return nRES;
  end get_module_quant;

  /* Формирование данных */
  procedure create_tmp
  (
    nID  in number,
    nCMP in number,
    dBEG in date,
    dEND in date
  ) is
    rTMP UDO_REPSMK_TMP%rowtype;
  begin
    rTMP.Ident  := nID;
    rTMP.Authid := utilizer;
  
    -- все сдачи на СГП за отчетный год
    for rin in (select IFS.RN,
                       IFS.PRN,
                       IFS.QUANT_FACT,
                       IFS.ARTICLE,
                       LST.RN as LST_RN,
                       LST.MATRES,
                       LST.PRODCMP,
                       LST.PRODCMPSP,
                       (select DT.DOCCODE from DOCTYPES DT where DT.RN = LST.DOCTYPE) as DOCCODE,
                       LST.FACEACC,
                       (select SOJ.GOODSSUPPLY
                          from STOREOPERJOURN SOJ,
                               DOCLINKS       LS
                         where LS.IN_DOCUMENT = IFS.RN
                           and LS.OUT_DOCUMENT = SOJ.RN) as SUPPLY,
                       (select PSP.NESTING_LEVEL
                          from FCPRODPLANSP PSP,
                               DOCLINKS     LP
                         where LP.OUT_DOCUMENT = LST.RN
                           and LP.OUT_UNITCODE = 'CostRouteLists'
                           and LP.IN_DOCUMENT = PSP.RN
                           and LP.IN_UNITCODE = 'CostProductPlansSpecs'
                           and rownum < 2) as PLAN_LVL
                  from INCOMEFROMDEPS     IFD,
                       INCOMEFROMDEPSSPEC IFS,
                       DOCLINKS           L,
                       FCROUTLST          LST
                 where IFD.COMPANY = nCMP
                   and IFD.WORK_DATE between dBEG and dEND
                   and IFS.PRN = IFD.RN
                   and L.OUT_DOCUMENT = IFD.RN
                   and L.OUT_UNITCODE = 'IncomFromDeps'
                   and L.IN_DOCUMENT = LST.RN
                   and L.IN_UNITCODE = 'CostRouteLists') loop
      --
      rTMP.Matres     := rin.matres;
      rTMP.Faceacc    := rin.faceacc;
      rTMP.Quant      := rin.quant_fact;
      rTMP.Frdepsp_Rn := rin.rn;
      rTMP.Article    := rin.article;
      rTMP.Supply     := rin.supply;
      -- тип выпуска
      if rin.doccode in ('ТП Дораб', 'ТП Ремонт') then
        -- ремонты
        rTMP.Sign_Prod := 2;
      elsif rin.doccode = 'ТехПаспорт' then
        -- готовая продукция
        if rin.plan_lvl = 0 then
          -- номенклатура выпуска - изделие
          rTMP.Sign_Prod := 0;
        else
          rTMP.Sign_Prod := get_sign_prod(nMATRES => rin.matres);
        end if;
      else
        -- непонятно - пока ремонты
        rTMP.Sign_Prod := 2;
      end if;
      -- тема
      rTMP.Tema := get_tema(nFACEACC => rTMP.Faceacc, nAGENT => rTMP.Agn_Rn);
      -- отгрузка
      if rin.supply is not null then
        rTMP.Faceacc_Out := get_fa_out(nSUPPLY => rin.supply);
      end if;
      -- тема отгрузки
      if rTMP.Faceacc_Out is null then
        -- нет отгрузки - корректировка по привязке заводского номера
        get_tema_art(nARTICLE => rTMP.Article, nAGENT => rTMP.Agn_Rn, sTEMA => rTMP.Tema);
        rTMP.Tema_Out := to_char(null);
        rTMP.Agn_Out_Rn := to_number(null);
      else
        -- отгрузка
        rTMP.Tema_Out := get_tema_out(nFACEACC => rTMP.Faceacc_Out, nAGENT => rTMP.Agn_Out_Rn);
      end if;
      -- количество модулей в изделии
      if rTMP.Sign_Prod = 0 then
        rTMP.Quant_m := get_module_quant(nPRODCMP => rin.prodcmp);
      end if;
    
      -- вставка
      if rTMP.Sign_Prod in (0, 2) then
        -- пока только основной выпуск (без ремонтов)
        ins_tmp(rROW => rTMP);
      end if;
    end loop;
  end create_tmp;

  /* корректировка данных после формирования */
  procedure corr_tmp(nID in number) is
  begin
    for rcr in (select * from UDO_REPSMK_TMP T where T.IDENT = nID) loop
      if rcr.faceacc_out is not null then
        update UDO_REPSMK_TMP TMP
           set TMP.TEMA_REP    = nvl(rcr.tema_out, rcr.tema),
               TMP.FACEACC_REP = nvl(rcr.faceacc_out, rcr.faceacc),
               TMP.AGN_REP_RN  = nvl(rcr.agn_out_rn, rcr.agn_rn)
         where TMP.FRDEPSP_RN = rcr.frdepsp_rn
           and TMP.IDENT = rcr.ident;
      else
        update UDO_REPSMK_TMP TMP
           set TMP.TEMA_REP    = rcr.tema,
               TMP.FACEACC_REP = rcr.faceacc,
               TMP.AGN_REP_RN  = rcr.agn_rn
         where TMP.FRDEPSP_RN = rcr.frdepsp_rn
           and TMP.IDENT = rcr.ident;
      end if;
    end loop;
  end corr_tmp;

begin
  -- инициализация
  if rtrim(sYEAR) is null then
    p_exception(0, 'Не указан отчетный год.');
  end if;
  if nCOMPANY is null then
    p_exception(0, 'Не указана организация.');
  end if;
  if length(sYEAR) != 4 then
    p_exception(0, 'Некорректно указан отчетный год: %s', sYEAR);
  else
    begin
      nTMP     := to_number(sYEAR);
      dBEGDATE := s2d('01.01.' || sYEAR);
      dENDDATE := s2d('31.12.' || sYEAR);
    exception
      when others then
        p_exception(0, 'Некорректно указан отчетный год: %s', sYEAR);
    end;
  end if;
  -- формирование данных
  nIDENT := gen_ident;
  create_tmp(nID => nIDENT, nCMP => nCOMPANY, dBEG => dBEGDATE, dEND => dENDDATE);
  corr_tmp(nID => nIDENT);

  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cYEAR);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cPRJ);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cPRJ, sCELL_NAME => cTEMA);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cPRJ, sCELL_NAME => cAGN);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cORD);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cNOM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_N);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_M);

  -- печать
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cYEAR, sCELL_VALUE => 'Отчетный год: ' || sYEAR);
  -- по темам
  iORD := 0;
  for rtm in (select distinct T.TEMA_REP,
                              T.AGN_REP_RN,
                              A.AGNNAME
                from UDO_REPSMK_TMP T,
                     AGNLIST        A
               where T.IDENT = nIDENT
                 and T.AGN_REP_RN = A.RN
               order by T.TEMA_REP) loop
  
    p := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cPRJ);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cTEMA,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => p,
                                sCELL_VALUE   => rtm.tema_rep);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cAGN, iCELL_INDEX_X => 0, iCELL_INDEX_Y => p, sCELL_VALUE => rtm.agnname);
  
    -- по изделиям темы
    for rnm in (select MR.NAME,
                       sum(T.QUANT) as QNT_ART,
                       sum(T.QUANT_M) as QNT_MOD
                  from UDO_REPSMK_TMP T,
                       FCMATRESOURCE  MR
                 where T.IDENT = nIDENT
                   and T.TEMA_REP = rtm.tema_rep
                   and T.AGN_REP_RN = rtm.agn_rep_rn
                   and T.MATRES = MR.RN
                   and T.SIGN_PROD in (0, 2) -- изделия и ремонты
                 group by MR.NAME
                 order by MR.NAME) loop
      iORD := iORD + 1;
      n    := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cORD,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => to_char(iORD));
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cNOM, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rnm.name);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_N,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rnm.qnt_art);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_M,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rnm.qnt_mod);
    end loop;
  
  end loop;

  -- подчистка данных
  PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cPRJ);
  PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cLINE);
  --if utilizer not in ('CITK_MARKOV') then
  clear_tmp(nID => nIDENT);
  --end if;

end;
/
