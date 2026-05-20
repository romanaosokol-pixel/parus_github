create or replace procedure udo_p_transinvdept_sp_remove
(
  nCOMPANY in number,
  nIDENT   in number,
  sUNIT    in varchar2
) as
  /*
    18/05/2023 Марков МВ.
    Удаление спецификации отработанного документа (Расходной накладной, Приход из подразделения)
    
    !!!! Удаление возможно только на конечной точке складского движения !!!!!
    
  */
  nOLD_STATUS    PKG_STD.tNUMBER; -- старое состояние (0 - не отработан; 1 - отработан как план; 2 - отработан как факт)
  nOLD_IN_STATUS PKG_STD.tNUMBER;
  --nSET_STATE_SCHEMA PKG_STD.tNUMBER := 0;     -- схема смены состояния (0 - УЗСР, 1 - ОТНП, 2 - УС)
  --nIN_SET_STATE_SCHEMA PKG_STD.tNUMBER := 0;  -- схема смены состояния для прихода (0 - УЗСР, 1 - ОТНП, 2 - УС)
  nDOCTYPE     PKG_STD.tREF;
  sPREF        TRANSINVDEPT.PREF%TYPE;
  sNUMB        TRANSINVDEPT.NUMB%TYPE;
  dDOCDATE     PKG_STD.tLDATE;
  nFACEACC     PKG_STD.tREF;
  sFACEACC     FACEACC.NUMB%TYPE;
  nFA_CURRENCY PKG_STD.tREF;
  nGRAPHPOINT  PKG_STD.tREF;
  nCURRENCY    PKG_STD.tREF;
  nCURCOURS    PKG_STD.tLNUMBER;
  nCURBASE     PKG_STD.tLNUMBER;
  --nBASECURRENCY     PKG_STD.tREF; -- базовая валюта
  nSUMMWITHNDS PKG_STD.tSUMM;
  --nSUMMWITHNDS_BASE PKG_STD.tSUMM;
  --nSUMMWITHNDS_ACC  PKG_STD.tSUMM;
  nSERV_SUM_NDS PKG_STD.tSUMM;
  --nSERV_SUM_NDS_BASE PKG_STD.tSUMM;
  --nSERV_SUM_ACC     PKG_STD.tSUMM;
  nSTOPER PKG_STD.tREF;
  --nSHEEP_RN         PKG_STD.tREF;
  nST_RN PKG_STD.tREF;
  --vREMNS            PKG_FACEACCTRADE.TFACEACC_REMNS;
  nIN_STORE      PKG_STD.tREF;
  nIN_STORE_TYPE PKG_STD.tNUMBER;
  nIN_STOPER     PKG_STD.tREF;
  --nIN_GOODSUPPLY    PKG_STD.tREF;
  --sIN_CARDNUMB      GOODSSUPPLY.CARDNUMB%type;
  --nPRICE_RN         PKG_STD.tREF;
  --nPRICE            PKG_STD.tLNUMBER;
  --nPRICEMEAS        PKG_STD.tNUMBER;
  --nART_PRICE_CUR    PKG_STD.tREF; -- валюта цены изделия
  nIN_CURRENCY    PKG_STD.tREF;
  nIN_CURCOURS    PKG_STD.tLNUMBER;
  nIN_CURBASE     PKG_STD.tLNUMBER;
  nPARTY_RN       PKG_STD.tREF;
  nMOL            PKG_STD.tREF;
  nSUBDIV         PKG_STD.tREF;
  nIN_PARTY       PKG_STD.tREF;
  sIN_PARTY_CODE  PKG_STD.tSTRING;
  nIN_KEEP_SIGN   PKG_STD.tNUMBER;
  nIN_COMMIS_SIGN PKG_STD.tNUMBER;
  --rINDOC            INCOMDOC%ROWTYPE;
  --rPARTY            GOODSPARTIES%ROWTYPE;
  --sBARCODE          PKG_STD.tSTRING;

  nGSMWAYS_TYPE    PKG_STD.tNUMBER; -- тип складской операции (0 - расход, 1 - приход)
  nIN_GSMWAYS_TYPE PKG_STD.tNUMBER; -- тип складской операции прихода (0 - расход, 1 - приход)
  nFACTRET_SIGN    PKG_STD.tNUMBER; -- признак возврата (0 - прямая (операция, факт), 1 - возврат)
  nKEEP_SIGN       PKG_STD.tNUMBER; -- признак ответственного хранения (0 - нет, 1 - да)
  nINEXP_SIGN      PKG_STD.tNUMBER; -- тип складской операции (1 - Расход, 3 - Приход)
  nIN_INEXP_SIGN   PKG_STD.tNUMBER; -- тип складской операции прихода (1 - Расход, 3 - Приход)
  --nFACT_SIGN        PKG_STD.tNUMBER;
  --nPLAN_SIGN        PKG_STD.tNUMBER;
  --nROLLBACK         PKG_STD.tNUMBER;

  --nPLAN_QUANT       PKG_STD.tLNUMBER;
  --nPLAN_QUANT_ALT   PKG_STD.tLNUMBER;
  --nFACT_QUANT       PKG_STD.tLNUMBER;
  --nFACT_QUANT_ALT   PKG_STD.tLNUMBER;
  --nPLAN_SUM         PKG_STD.tLNUMBER;
  --nFACT_SUM         PKG_STD.tLNUMBER;
  nFA_COURS     PKG_STD.tLNUMBER;
  nFA_BASECOURS PKG_STD.tLNUMBER;
  --nSP_NEG_SIGN      PKG_STD.tNUMBER;  -- признак списания в минус по МХ (0 - нет, 1 - да)
  nSTORE          PKG_STD.tREF;
  nSTORE_TYPE     PKG_STD.tNUMBER;
  nSTORE_CURRENCY PKG_STD.tREF;
  sSTORE          AZSAZSLISTMT.AZS_NUMBER%TYPE;
  --sEXEPT            PKG_STD.tLSTRING;
  --sPACK             NOMNPACK.CODE%TYPE;
  nPROCESS_SIGN         PKG_STD.tNUMBER;
  nIN_PROCESS_SIGN      PKG_STD.tNUMBER;
  nDISTRIBUTION_SIGN    PKG_STD.tNUMBER;
  nIN_DISTRIBUTION_SIGN PKG_STD.tNUMBER;
  --nDISTR_QUANT      PKG_STD.tQUANT;
  --nDISTR_QUANTALT   PKG_STD.tQUANT;
  --nMODIFY_REGPRICE  PKG_STD.tLNUMBER;

  nUSE_STORE_KOEFF PKG_STD.tNUMBER;
  --nQUANT_ALT        PKG_STD.tLNUMBER;
  nCOUNT    PKG_STD.tNUMBER;
  nVDOCTYPE PKG_STD.tLNUMBER;
  sVDOCNUMB TRANSINVDEPT.VALID_DOCNUMB%TYPE;
  dVDOCDATE PKG_STD.tLDATE;

  dRESERVDATE PKG_STD.tLDATE; -- дата резервирования накладной
  --nDO_RN            PKG_STD.tREF;     -- RN родительского заказа подразделения.
  --nDOP_RN           PKG_STD.tREF;     -- RN родительского периода исполнения заказа подразделения
  --dDO_RES_DATE      PKG_STD.tLDATE;   -- дата резервирования заказа подразделения
  --dDO_RES_DATE_TO   PKG_STD.tLDATE;   -- дата резервирования до заказа подразделения
  --nDO_LINK_WAY      PKG_STD.tNUMBER;  -- связь с заказом (0-через распоряжение, 1-не через распоряжение)

  dOLD_WORK_DATE    PKG_STD.tLDATE;
  dOLD_IN_WORK_DATE PKG_STD.tLDATE;
  nJUR_PERS         PKG_STD.tREF;
  nQUANT_S          PKG_STD.tLNUMBER;
  nQUANT_ALT_S      PKG_STD.tLNUMBER;
  nCLC_GOODSSUPPLY  PKG_STD.tREF;

  nOLD_RESTPLAN number(17);
  nOLD_RESTFACT number(17);
  nFORM_SPL_CLC PKG_STD.tNUMBER := GET_OPTIONS_NUM('Realiz_InvDept_FormSupplyCalc', nCOMPANY);
  sMSG          varchar2(2000);
  nWARNING      number(17);
  nTMP          number(17);
  nCMPL         number(17);
  --
  nPRN  number(17);
  rDOC  INCOMEFROMDEPS%rowtype;
  rSPEC INCOMEFROMDEPSSPEC%rowtype;

  /* считывание остатков ТЗ */
  procedure GET_GOODSSUPPLY_RESTS
  (
    nRN       in number,
    nRESTPLAN out number,
    nRESTFACT out number
  ) is
  begin
    select RESTPLAN,
           RESTFACT
      into nRESTPLAN,
           nRESTFACT
      from GOODSSUPPLY
     where RN = nRN
       and COMPANY = nCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nRN, 'GoodsSupply');
  end GET_GOODSSUPPLY_RESTS;

  /* отражение на калькуляции затрат товарного запаса */
  procedure REFLECTION_CLC
  (
    nSIGN_PLAN    in number, -- Плановые затраты (-1 - вычесть, 0 - без изменений, 1 - добавить)
    nSIGN_FACT    in number, -- Фактические затраты (-1 - вычесть, 0 - без изменений, 1 - добавить)
    nPRN          in number, -- Строка накладной
    nQUANT        in number, -- Количество в основной ЕИ родительской строки накладной
    nSUPPLY       in number, -- Товарный запас
    nOLD_RESTPLAN in number, -- Старый плановый остаток в основной ЕИ товарного запаса
    nOLD_RESTFACT in number, -- Старый фактический остаток в основной ЕИ товарного запаса
    nSIGN_OUT     in number -- По расходу (0 - нет, 1 - да)
  ) is
  begin
    if (PROCEDURE_EXISTS('P_TRANSINVDEPTCLC_BSET_STATUS') = 0) then
      return;
    end if;
  
    execute immediate 'begin
         P_TRANSINVDEPTCLC_BSET_STATUS
         (
           :nCOMPANY,
           :nSIGN_PLAN,
           :nSIGN_FACT,
           :nPRN,
           :nQUANT,
           :nSUPPLY,
           :nOLD_RESTPLAN,
           :nOLD_RESTFACT,
           :nSIGN_OUT
         );
       end;'
      using in nCOMPANY, in nSIGN_PLAN, in nSIGN_FACT, in nPRN, in nQUANT, in nSUPPLY, in nOLD_RESTPLAN, in nOLD_RESTFACT, in nSIGN_OUT;
  end REFLECTION_CLC;

  /* процедура DO_CLEAR */
  procedure DO_CLEAR
  (
    ARN          in number,
    AQUANT       in number,
    AGOODSSUPPLY in number,
    APARTY       in number,
    ASTATUS      in number
  ) is
    nCOUNT         PKG_STD.tNUMBER := 0;
    nQUANT_S       PKG_STD.tQUANT;
    nQUANT_ALT_S   PKG_STD.tQUANT;
    nQUANT_JOUR    PKG_STD.tLNUMBER;
    nQUANTALT_JOUR PKG_STD.tLNUMBER;
    aMSG           PKG_STD.tSTRING;
    nNOMEN_JOUR    PKG_STD.tREF;
    nSUMMNDS_JOUR  INCOMEFROMDEPSSPEC.SUMM_FACT%type;
    nSIGNPLAN      PKG_STD.tNUMBER;
  
    nOLD_RESTPLAN   GOODSSUPPLY.RESTPLAN%type;
    nNEW_RESTPLAN   GOODSSUPPLY.RESTPLAN%type;
    nOLD_RESTFACT   GOODSSUPPLY.RESTFACT%type;
    nNEW_RESTFACT   GOODSSUPPLY.RESTFACT%type;
    rSPL_CLC        GOODSSUPPLYCLC%rowtype;
    nQUANT_PLAN     GOODSSUPPLYCLC.QUANT_PLAN%type;
    nQUANT_FACT     GOODSSUPPLYCLC.QUANT_FACT%type;
    nCOST_PLAN      GOODSSUPPLYCLC.COST_PLAN%type;
    nCOST_FACT      GOODSSUPPLYCLC.COST_FACT%type;
    bSupplyIsDroped boolean := false;
  begin
    if (nFORM_SPL_CLC = 1) then
      /* старый плановый/фактический остаток в основной ЕИ товарного запаса - снятие отработки */
      if (AGOODSSUPPLY is not null) then
        begin
          select RESTPLAN,
                 RESTFACT
            into nOLD_RESTPLAN,
                 nOLD_RESTFACT
            from GOODSSUPPLY
           where RN = AGOODSSUPPLY
             and COMPANY = nCOMPANY;
        exception
          when NO_DATA_FOUND then
            PKG_MSG.RECORD_NOT_FOUND(AGOODSSUPPLY, 'GoodsSupply');
        end;
      end if;
    end if;
  
    /* получение связи по DOCLINKS */
    for C in (select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */
               L.OUT_DOCUMENT
                from DOCLINKS L
               where L.IN_DOCUMENT = ARN
                 and L.IN_UNITCODE = 'IncomFromDepsSpecs'
                 and L.OUT_UNITCODE = 'StoreOpersJournal') loop
      P_GOODSSUPPLYCOR_BASE_DELETE(0, nCOMPANY, rSpec.Prn, C.OUT_DOCUMENT, sMSG, nWARNING, nSIGNPLAN);
      /* убираем связи по DOCLINKS */
      P_LINKSALL_REMOVE(nCOMPANY, 'IncomFromDeps', rSpec.Rn, 'StoreOpersJournal', C.OUT_DOCUMENT);
      P_LINKSALL_REMOVE(nCOMPANY, 'IncomFromDepsSpecs', ARN, 'StoreOpersJournal', C.OUT_DOCUMENT);

      PKG_GOODS_CHECK.P_SET_ON;
    end loop;
    /* для реализационных записей, очищаем товарный запас в журнале резервирования по местам хранения */
    P_STRPLRESJRNL_SET_GOODSSUPPLY(nCOMPANY,
                                   ARN,
                                   'IncomFromDepsSpecs',
                                   0 /*nRES_TYPE*(приход)*/,
                                   null /*nGOODSSUPPLY*/);
  
    if (AGOODSSUPPLY is not null) then
    
      /* проверка на наличие в истории ТЗ c датой равной или больше даты отработки ПП отрицательных остатков */
      select count(*)
        into nCOUNT
        from DUAL
       where exists (select null
                from GOODSSUPPLYHIST
               where PRN = AGOODSSUPPLY
                 and DATE_FROM >= rDOC.WORK_DATE
                 and (RESTPLAN < 0 or RESTPLANALT < 0 or RESTFACT < 0 or RESTFACTALT < 0));
    
      /* проверяем на отрицательные остатки */
      if (nCOUNT > 0) then
        P_EXCEPTION(0, 'Зарегистрированы отгрузки из товарного запаса, сформированного данным приходом из подразделений. Изменение состояния документа недопустимо.');
      end if;
    end if;
  
    if (AGOODSSUPPLY is not null) then
      if rDOC.PARTY is not null or
         rDOC.PARTY_RN is not null then
        update INCOMEFROMDEPSSPEC set SUPPLY = null where RN = ARN;
        if SQL%NOTFOUND then
          PKG_MSG.RECORD_NOT_FOUND(ARN, 'IncomFromDepsSpecs');
        end if;
      end if;
    
      /* удаление товарного запаса и партии товара */
      select count(*)
        into nCOUNT
        from dual
       where exists (select null
                from STOREOPERJOURN
               where COMPANY = nCOMPANY
                 and GOODSSUPPLY = AGOODSSUPPLY);
    
      /* при наличии записи в журнале резервирования обнуляем запись товарных запасов, но не удаляем */
      if (nCOUNT = 0) then
        select count(*) into nCOUNT from dual where exists (select null from RESJOURNAL where SUPPLY = AGOODSSUPPLY);
      end if;
    
      /* при наличии ссылки из другой строки прихода на ТЗ не удаляем */
      if (nCOUNT = 0) then
        select count(*)
          into nCOUNT
          from dual
         where exists (select null from INCOMEFROMDEPSSPEC where SUPPLY = AGOODSSUPPLY);
      end if;
    
      if (nCOUNT = 0) then
        /* удаляется только при наличии партии в заголовке
        либо при непосредственном удалении из спецификации  */
        if (rDOC.PARTY is not null) or
           (rDOC.PARTY_RN is not null) then
          -->> 31/01/2023 Марков МВ. Очистим места хранения для ТЗ
          for rpl in (select STP.RN from STPLGOODSSUPPLY STP where STP.GOODSSUPPLY = AGOODSSUPPLY) loop
            P_STPLGOODSSUPPLY_BASE_DELETE(nCOMPANY => nCOMPANY, nRN => rpl.rn);
          end loop;
          /*-- подчищаем остатки операций (не должно быть, но есть!!!!)
          for rjpl in(select STJ.RN,
                             (select LP.IN_DOCUMENT from DOCLINKS LP
                               where LP.OUT_UNITCODE = 'StoragePlacesOperJournal'
                                 and LP.OUT_DOCUMENT = STJ.RN
                                 and LP.IN_UNITCODE = 'StoragePlacesResJournal') as RES_RN
                        from STRPLOPRJRNL STJ where STJ.GOODSSUPPLY = AGOODSSUPPLY) loop
            if rjpl.res_rn is null then
              delete from STRPLOPRJRNL where RN = rjpl.rn;
            else
              P_STRPLRESJRNL_ROLLBACK(nCOMPANY => nCOMPANY, nRN => rjpl.res_rn);
            end if;
          end loop;*/
          --<<
          P_GOODSSUPPLY_BASE_DELETE(nCOMPANY, AGOODSSUPPLY);
          bSupplyIsDroped := true;
        end if;
      
        select count(*)
          into nCOUNT
          from dual
         where exists (select null
                  from GOODSSUPPLY
                 where COMPANY = nCOMPANY
                   and PRN = APARTY);
      
        if (nCOUNT = 0) then
          P_GOODSPARTIES_BASE_DELETE(nCOMPANY, APARTY);
        end if;
      end if;
    
      select nvl(sum(QUANT), 0),
             nvl(sum(QUANTALT), 0)
        into nQUANT_S,
             nQUANT_ALT_S
        from STOREOPERJOURN
       where COMPANY = nCOMPANY
         and GOODSSUPPLY = AGOODSSUPPLY
         and OPERDATE = rDOC.WORK_DATE;
    
      if (nQUANT_S = 0) and
         (nQUANT_ALT_S = 0) then
        P_REGPRICE_DELETE_BY_DATE(nCOMPANY, AGOODSSUPPLY, rDOC.WORK_DATE);
      end if;
    
      if (nFORM_SPL_CLC = 1) then
        if (not bSupplyIsDroped) then
          /* новый плановый/фактический остаток в основной ЕИ товарного запаса */
          begin
            select RESTPLAN,
                   RESTFACT
              into nNEW_RESTPLAN,
                   nNEW_RESTFACT
              from GOODSSUPPLY
             where RN = AGOODSSUPPLY
               and COMPANY = nCOMPANY;
          exception
            when NO_DATA_FOUND then
              PKG_MSG.RECORD_NOT_FOUND(AGOODSSUPPLY, 'GoodsSupply');
          end;
        
        end if; -- ( not bSupplyIsDroped )
      end if; -- ( nFORM_SPL_CLC = 1 )
    
    end if; -- ( AGOODSSUPPLY is not null ) and ( nSTATUS = 0 )
  end DO_CLEAR; -- процедура DO_CLEAR

  -- удаление спецификации расходной накладной в подразделение
  procedure invdept_del is
  begin
    /* считывание текущих параметров записи */
    begin
      select /*+ ORDERED */
       decode(T.STATUS, 0, 0, 1, 2, 2, 1) STATUS,
       T.IN_STATUS,
       T.DOCTYPE,
       T.PREF,
       T.NUMB,
       T.DOCDATE,
       T.FACEACC,
       T.GRAPHPOINT,
       T.CURRENCY,
       T.SUMMWITHNDS,
       T.SERV_SUMM_NDS,
       T.STOPER,
       T.IN_STORE,
       T.IN_STOPER,
       T.IN_PARTY,
       T.IN_PARTY_CODE,
       T.CURCOURS,
       T.CURBASE,
       T.FA_CURCOURS,
       T.FA_CURBASE,
       T.IN_CURCOURS,
       T.IN_CURBASE,
       T.MOL,
       T.SUBDIV,
       T.STORE,
       S.AZS_NUMBER,
       S.CURRENCY,
       T.VALID_DOCTYPE,
       T.VALID_DOCNUMB,
       T.VALID_DOCDATE,
       T.RESERVDATE,
       T.IN_WORK_DATE,
       T.WORK_DATE,
       T.JUR_PERS,
       S.STORE_TYPE,
       S.CALC_TYPE,
       S.PROCESS_SIGN,
       S.DISTRIBUTION_SIGN,
       SO.GSMWAYS_TYPE,
       SO.KEEP_SIGN,
       decode(SO.GSMWAYS_TYPE, 0, 1, 1, 3),
       SO.FACTRET_SIGN,
       ISO.GSMWAYS_TYPE,
       ISO.KEEP_SIGN,
       ISO.COMMIS_SIGN,
       decode(ISO.GSMWAYS_TYPE, 0, 1, 1, 3),
       INS.STORE_TYPE,
       INS.PROCESS_SIGN,
       INS.DISTRIBUTION_SIGN,
       INS.CURRENCY,
       F.NUMB,
       F.CURRENCY
        into nOLD_STATUS,
             nOLD_IN_STATUS,
             nDOCTYPE,
             sPREF,
             sNUMB,
             dDOCDATE,
             nFACEACC,
             nGRAPHPOINT,
             nCURRENCY,
             nSUMMWITHNDS,
             nSERV_SUM_NDS,
             nSTOPER,
             nIN_STORE,
             nIN_STOPER,
             nIN_PARTY,
             sIN_PARTY_CODE,
             nCURCOURS,
             nCURBASE,
             nFA_COURS,
             nFA_BASECOURS,
             nIN_CURCOURS,
             nIN_CURBASE,
             nMOL,
             nSUBDIV,
             nSTORE,
             sSTORE,
             nSTORE_CURRENCY,
             nVDOCTYPE,
             sVDOCNUMB,
             dVDOCDATE,
             dRESERVDATE,
             dOLD_IN_WORK_DATE,
             dOLD_WORK_DATE,
             nJUR_PERS,
             nSTORE_TYPE,
             nUSE_STORE_KOEFF,
             nPROCESS_SIGN,
             nDISTRIBUTION_SIGN,
             nGSMWAYS_TYPE,
             nKEEP_SIGN,
             nINEXP_SIGN,
             nFACTRET_SIGN,
             nIN_GSMWAYS_TYPE,
             nIN_KEEP_SIGN,
             nIN_COMMIS_SIGN,
             nIN_INEXP_SIGN,
             nIN_STORE_TYPE,
             nIN_PROCESS_SIGN,
             nIN_DISTRIBUTION_SIGN,
             nIN_CURRENCY,
             sFACEACC,
             nFA_CURRENCY
        from TRANSINVDEPT      T,
             TRANSINVDEPTSPECS SP,
             AZSAZSLISTMT      S,
             AZSGSMWAYSTYPES   SO,
             FACEACC           F,
             AZSAZSLISTMT      INS,
             AZSGSMWAYSTYPES   ISO
       where SP.PRN = T.RN
         and SP.RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIDENT)
         and T.COMPANY = nCOMPANY
         and T.STORE = S.RN
         and T.STOPER = SO.RN
         and T.FACEACC = F.RN(+)
         and T.IN_STORE = INS.RN(+)
         and T.IN_STOPER = ISO.RN(+);
    exception
      when NO_DATA_FOUND then
        p_exception(0,
                    'Запись расходной накладной для отмеченных записей спецификации не найдена.');
    end;
  
    -- отменить распределение по местам хранения
    for CUR in (select RN, PRN
                  from TRANSINVDEPTSPECS
                 where RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIDENT)
    ) loop
      /* КВ */
      nCMPL := f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                                      nOUT_DOCUMENT => cur.prn,
                                      sIN_UNITCODE  => 'CostDeliverySheets');
      if nCMPL is not null then
        -- удалим в КВ
        for rtrn in(select SHTR.RN from FCDELIVSHSPTRN SHTR, FCDELIVSHSP SSP, FCDELIVSH SH where SH.RN = nCMPL
          and SSP.PRN = SH.RN and SHTR.PRN = SSP.RN and SHTR.TRNSDPTSP = CUR.RN) loop
          p_fcdelivshsptrn_base_delete(nRN => rtrn.rn, nCOMPANY => nCOMPANY);
        end loop;
        -- удалим линки
        for rlnk in(select L.*
          from DOCLINKS L where L.OUT_DOCUMENT = cur.rn and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs') loop
          PKG_DOCLINKS.REMOVE(sIN_UNITCODE  => rlnk.in_unitcode,
                              nIN_DOCUMENT  => rlnk.in_document, 
                              sOUT_UNITCODE => rlnk.out_unitcode, 
                              nOUT_DOCUMENT => rlnk.out_document);
        end loop;
        /*p_exception(0, 'Расходная накладная связана с комплектовочной ведомостью.' || chr(10) ||
                       'Для удаления необходимо использовать процедуру "Удаление спецификации накладной, связанной с КВ"');*/
      end if;
      /* очистка товарного запаса в журнале резервирования по местам хранения */
      P_STRPLRESJRNL_SET_GOODSSUPPLY(nCOMPANY,
                                     CUR.RN,
                                     'GoodsTransInvoicesToDeptsSpecs',
                                     0 /*RES_TYPE*(приход)*/,
                                     null /*GOODSSUPPLY*/);
    end loop;
    /* удаляем связь с приходом и обновляем записи ЖСО для расходов */
    for Rec in (select /*+ ORDERED */
                 S.RN SP_RN,
                 S.PRN as SP_PRN,
                 S.QUANT SP_QUANT,
                 L.OUT_DOCUMENT SOJ_RN,
                 SOJ.*,
                 lead(SOJ.RN) over(order by S.RN) as OUT_RN -- RN записи расхода ЖСО
                  from TRANSINVDEPTSPECS S,
                       DOCLINKS          L,
                       STOREOPERJOURN    SOJ
                 where S.RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIDENT)
                   and S.COMPANY = nCOMPANY
                   and S.RN = L.IN_DOCUMENT
                   and L.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                   and L.OUT_UNITCODE = 'StoreOpersJournal'
                   and L.OUT_DOCUMENT = SOJ.RN
                 order by S.RN,
                          SOJ.OPER_TYPE desc -- сначала отрабатывается приход!!!
                ) loop
      if (Rec.OPER_TYPE = 1) and
         (nFORM_SPL_CLC = 1) then
        /* считывание остатков ТЗ прихода */
        GET_GOODSSUPPLY_RESTS(Rec.GOODSSUPPLY, nOLD_RESTPLAN, nOLD_RESTFACT);
      end if;
    
      /* снимаем предыдущую отработку как с прихода, так и с расхода */
      P_GOODSSUPPLYCOR_BASE_DELETE(0, nCOMPANY, rec.sp_prn, Rec.SOJ_RN, sMSG, nWARNING, nTMP);
      P_LINKSALL_REMOVE(nCOMPANY, 'GoodsTransInvoicesToDepts', rec.sp_prn, 'StoreOpersJournal', Rec.SOJ_RN);
      P_LINKSALL_REMOVE(nCOMPANY, 'GoodsTransInvoicesToDeptsSpecs', Rec.SP_RN, 'StoreOpersJournal', Rec.SOJ_RN);
    
      /* приходы */
      if (Rec.OPER_TYPE = 1) then
        begin
          select /*+ORDERED*/
           GS.PRN,
           GP.INDOC
            into nPARTY_RN,
                 nIN_PARTY
            from GOODSSUPPLY  GS,
                 GOODSPARTIES GP
           where GS.RN = Rec.GOODSSUPPLY
             and GS.PRN = GP.RN;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0, 'Товарный запас не найден.');
        end;
      
        /* проверка наличия товарных запасов в записях ЖСО и в журнале резервирования */
        select count(*)
          into nCOUNT
          from (select 1
                  from STOREOPERJOURN S
                 where S.COMPANY = nCOMPANY
                   and S.GOODSSUPPLY = Rec.GOODSSUPPLY
                union all
                select 1
                  from RESJOURNAL J
                 where J.COMPANY = nCOMPANY
                   and J.SUPPLY = Rec.GOODSSUPPLY);
      
        /* удаление товарного запаса, партии товара, партии получателя */
        if (nCOUNT = 0) then
          /* удаление товарного запаса */
          for rsj in(select SJ.RN from STRPLOPRJRNL SJ where SJ.GOODSSUPPLY = Rec.GOODSSUPPLY) loop
            -- удалим линки
            for rsjl in(select * from doclinks l where l.out_document = rsj.rn) loop
              pkg_doclinks.REMOVE(sIN_UNITCODE  => rsjl.in_unitcode,
                                  nIN_DOCUMENT  => rsjl.in_document,
                                  sOUT_UNITCODE => rsjl.out_unitcode,
                                  nOUT_DOCUMENT => rsjl.out_document);
            end loop;
          end loop;
          for rjr in(select SR.RN from STRPLRESJRNL SR where SR.GOODSSUPPLY = Rec.GOODSSUPPLY) loop
            -- удалим линки
            for rsjl in(select * from doclinks l where l.out_document = rjr.rn) loop
              pkg_doclinks.REMOVE(sIN_UNITCODE  => rsjl.in_unitcode,
                                  nIN_DOCUMENT  => rsjl.in_document,
                                  sOUT_UNITCODE => rsjl.out_unitcode,
                                  nOUT_DOCUMENT => rsjl.out_document);
            end loop;
          end loop;
          delete from STRPLOPRJRNL SJ where SJ.GOODSSUPPLY = Rec.GOODSSUPPLY;
          delete from STPLGOODSSUPPLY ST where ST.GOODSSUPPLY = Rec.GOODSSUPPLY;
          delete from STRPLRESJRNL SR where SR.GOODSSUPPLY = Rec.GOODSSUPPLY;
          
          --select count(*) into nCOUNT from STPLGOODSSUPPLY ST where ST.GOODSSUPPLY = Rec.GOODSSUPPLY;
          --select count(*) into nPARTY_RN from STRPLOPRJRNL SJ where SJ.GOODSSUPPLY = Rec.GOODSSUPPLY;
          --p_exception(0, 'nSTPL = %s, nSTRPL = %s', nCOUNT, nPARTY_RN);
          
          P_GOODSSUPPLY_BASE_DELETE(nCOMPANY, Rec.GOODSSUPPLY);
          Rec.GOODSSUPPLY := null;
          /* проверка наличия товарных запасов для партии товара */
          select count(*)
            into nCOUNT
            from GOODSSUPPLY
           where COMPANY = nCOMPANY
             and PRN = nPARTY_RN;
          /* удаление партии товара, если у нее нет товарных запасов */
          if (nCOUNT = 0) then
            P_GOODSPARTIES_BASE_DELETE(nCOMPANY, nPARTY_RN);
          end if;
          /* проверка наличия партии товара для партии получателя */
          select count(*)
            into nCOUNT
            from GOODSPARTIES
           where COMPANY = nCOMPANY
             and INDOC = nIN_PARTY;
          /* удаление партии, если у нее нет партий товара */
          if (nCOUNT = 0) then
            begin
              P_INCOMDOC_BASE_DELETE(nCOMPANY, nIN_PARTY);
            exception
              when OTHERS then
                null;
            end;
          end if;
        else
          select sum(QUANT),
                 sum(QUANTALT)
            into nQUANT_S,
                 nQUANT_ALT_S
            from STOREOPERJOURN
           where COMPANY = nCOMPANY
             and GOODSSUPPLY = Rec.GOODSSUPPLY
             and OPERDATE = dOLD_IN_WORK_DATE
             and RN <> Rec.OUT_RN; -- исключая "парную" запись расхода
        
          if (nvl(nQUANT_S, 0) = 0) and
             (nvl(nQUANT_ALT_S, 0) = 0) then
            P_REGPRICE_DELETE_BY_DATE(nCOMPANY, Rec.GOODSSUPPLY, dOLD_IN_WORK_DATE);
          end if;
        end if;
      
        if (nFORM_SPL_CLC = 1) and
           (Rec.GOODSSUPPLY is not null) then
          /* отражение на калькуляции затрат товарного запаса прихода */
          REFLECTION_CLC(-1, -- nSIGN_PLAN
                         -1, -- nSIGN_FACT
                         Rec.SP_RN, -- nPRN
                         Rec.SP_QUANT, -- nQUANT
                         Rec.GOODSSUPPLY, -- nSUPPLY
                         nOLD_RESTPLAN,
                         nOLD_RESTFACT,
                         0 -- nSIGN_OUT
                         );
        end if;
      
        /* расходы */
      elsif (Rec.OPER_TYPE = 0) then
        /* отработка расхода */
        P_GOODSSUPPLYCOR_BASE_INSERT(nCOMPANY,
                                     0,
                                     rec.sp_prn,
                                     'GoodsTransInvoicesToDepts',
                                     Rec.GOODSSUPPLY,
                                     Rec.ARTICLE,
                                     Rec.DOCTYPE,
                                     Rec.STOPER,
                                     Rec.DOCPREF,
                                     Rec.DOCNUMB,
                                     Rec.DOCDATE,
                                     dOLD_WORK_DATE,
                                     Rec.SIGNPLAN,
                                     Rec.FACEACC,
                                     nFA_BASECOURS,
                                     nFA_COURS,
                                     nJUR_PERS,
                                     Rec.CURRENCY,
                                     nCURCOURS,
                                     nCURBASE,
                                     Rec.QUANT,
                                     Rec.QUANTALT,
                                     Rec.DOC_QUANT,
                                     Rec.DOC_QUANTALT,
                                     Rec.REGPRICE,
                                     Rec.REGPRICEMEAS,
                                     Rec.REGSUMM,
                                     Rec.PRICE,
                                     Rec.PRICEMEAS,
                                     Rec.SUMMTAX,
                                     Rec.SUMM,
                                     0 /*nSUMM_NDS*/,
                                     nWARNING,
                                     sMSG,
                                     nST_RN);
        P_LINKSALL_LINK_DIRECT(nCOMPANY,
                               'GoodsTransInvoicesToDepts',
                               rec.sp_prn,
                               null,
                               sysdate,
                               0,
                               'StoreOpersJournal',
                               nST_RN,
                               nST_RN,
                               sysdate,
                               0);
        P_LINKSALL_LINK_DIRECT(nCOMPANY,
                               'GoodsTransInvoicesToDeptsSpecs',
                               Rec.SP_RN,
                               rec.sp_prn,
                               sysdate,
                               0,
                               'StoreOpersJournal',
                               nST_RN,
                               nST_RN,
                               sysdate,
                               0);
      end if;
    end loop; -- Rec
  
    /* отражение на калькуляции затрат ТЗ (до обнуления суммы с НДС в спецификации, которая используется в отражении на калькуляцию) */
    /* снятие отработки факт */
    if (nFORM_SPL_CLC = 1) and
       (nOLD_STATUS = 2) then
      /* только расходные документы */
      for C in (select RN,
                       PRN,
                       QUANT
                  from TRANSINVDEPTSPECS
                 where RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIDENT)) loop
        nCLC_GOODSSUPPLY := null;
        nPRN             := C.PRN;
      
        for Rec in (select J.GOODSSUPPLY
                      from DOCLINKS       L,
                           STOREOPERJOURN J
                     where L.IN_DOCUMENT = C.RN
                       and L.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                       and L.OUT_UNITCODE = 'StoreOpersJournal'
                       and L.OUT_DOCUMENT = J.RN) loop
          nCLC_GOODSSUPPLY := Rec.GOODSSUPPLY;
        
          /* считывание остатков ТЗ */
          GET_GOODSSUPPLY_RESTS(nCLC_GOODSSUPPLY, nOLD_RESTPLAN, nOLD_RESTFACT);
        
          exit;
        end loop; -- Rec
      
        if (nCLC_GOODSSUPPLY is not null) then
          REFLECTION_CLC(case
                           when (F_DOCLINKS_LINK_IN('GoodsTransInvoicesToDepts', C.PRN, 'SheepDirectToDepts') is not null) then
                            0
                           else
                            1
                         end, -- nSIGN_PLAN
                         1, -- nSIGN_FACT
                         C.RN, -- nPRN
                         C.QUANT, -- nQUANT
                         nCLC_GOODSSUPPLY, -- nSUPPLY
                         nOLD_RESTPLAN,
                         nOLD_RESTFACT,
                         1 -- nSIGN_OUT
                         );
        end if;
      end loop; -- C
    end if; -- ( nFORM_SPL_CLC = 1 ) and ( nOLD_STATUS = 2 )
  
    /* корректировка товарных запасов */
  
    /* только расходные документы */
    for Rec in (select /*+ ORDERED */
                 L.IN_DOCUMENT  as S_RN,
                 L.OUT_DOCUMENT SOJ_RN,
                 J.GOODSSUPPLY,
                 J.QUANT
                  from DOCLINKS       L,
                       STOREOPERJOURN J
                 where L.IN_DOCUMENT in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIDENT)
                   and L.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                   and L.OUT_UNITCODE = 'StoreOpersJournal'
                   and L.OUT_DOCUMENT = J.RN) loop
      P_GOODSSUPPLYCOR_BASE_DELETE(0, nCOMPANY, nPRN, Rec.SOJ_RN, sMSG, nWARNING, nTMP);
      P_LINKSALL_REMOVE(nCOMPANY, 'GoodsTransInvoicesToDepts', nPRN, 'StoreOpersJournal', Rec.SOJ_RN);
      P_LINKSALL_REMOVE(nCOMPANY, 'GoodsTransInvoicesToDeptsSpecs', rec.s_rn, 'StoreOpersJournal', Rec.SOJ_RN);
    end loop; -- Rec
  
    -- удалить отмеченные строки
    PKG_FLAG.SET_FLAG;
    for rrc in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) loop
      p_transinvdeptsp_base_delete(nCOMPANY => nCOMPANY, nRN => rrc.document);
    end loop;
    PKG_FLAG.RESET_FLAG;
  end invdept_del;

  -- удаление спецификации прихода из подразделения
  procedure incomefrdep_del is
    nFND_REC          number(17);
    nSET_STATE_SCHEMA number(17);
    nINEXP_SIGN       number(17);
  begin
    for rsp in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) loop
      begin
        select IFS.* into rSPEC from INCOMEFROMDEPSSPEC IFS where IFS.RN = rsp.document;
      exception
        when no_data_found then
          PKG_MSG.RECORD_NOT_FOUND(rsp.document, 'IncomFromDepsSpecs');
      end;
      /* считывание накладной */
      begin
        select *
          into rDOC
          from INCOMEFROMDEPS
         where RN = rSPEC.Prn
           and COMPANY = nCOMPANY;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(rSPEC.Prn, 'IncomFromDeps');
      end;
      -- инициализация
      nSET_STATE_SCHEMA := 0; -- отработка документа по схеме УЗСР
      nINEXP_SIGN       := 0;
    
      /* проверка на распределение по местам хранения */
      if (F_STRPLRESJRNL_CHECK_PROCESSED(nCOMPANY, rSPEC.Prn, 'IncomFromDeps', 1) > 0) then
        /* снать отработку записей журнала резервирования */
        for ResJrnl in (select /*+ ORDERED*/
                         JRNL.*
                          from INCOMEFROMDEPSSPEC SP,
                               DOCLINKS           L,
                               STRPLRESJRNL       JRNL
                         where SP.RN = rSPEC.Rn
                           and L.IN_DOCUMENT = SP.RN
                           and L.IN_UNITCODE = 'IncomFromDepsSpecs'
                           and L.OUT_UNITCODE = 'StoragePlacesResJournal'
                           and L.OUT_DOCUMENT = JRNL.RN
                           and JRNL.FREE_DATE is not null) loop
          P_STRPLRESJRNL_ROLLBACK(nCOMPANY, ResJrnl.RN);
        end loop;
        /* проверяем наличие резервуаров в спецификации прихода */
        select count(*)
          into nFND_REC
          from dual
         where exists (select null
                  from INCOMEFROMDEPSSPEC S,
                       DICNOMNS           DN,
                       NOMMODIF           NM
                 where S.RN = rSPEC.Rn
                   and S.COMPANY = nCOMPANY
                   and S.CELL is not null
                   and S.NOMMODIF = NM.RN
                   and NM.PRN = DN.RN
                   and DN.NOMEN_TYPE = 1);
        /* если среди спецификаций есть с указанным резервуаром - удаляем распределение с мест хранения */
        if (nFND_REC > 0) then
          for rec in (select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */
                       L.OUT_DOCUMENT
                        from INCOMEFROMDEPSSPEC S,
                             DOCLINKS           L
                       where S.RN = rSPEC.Rn
                         and L.IN_DOCUMENT = S.RN
                         and L.IN_UNITCODE = 'IncomFromDepsSpecs'
                         and L.OUT_UNITCODE = 'StoragePlacesResJournal') loop
            P_STRPLRESJRNL_BASE_DELETE(nCOMPANY, rec.OUT_DOCUMENT);
          end loop;
        end if;
      end if; -- МХ
    
      /* отмена отработки */
      if rSpec.Supply is not null then
        for spl in (select * from GOODSSUPPLY GS where GS.RN = rSpec.Supply) loop
          DO_CLEAR(rSPEC.RN, rSPEC.QUANT_FACT, rSPEC.SUPPLY, spl.prn, 0);
        end loop;
      end if;
    
      -- удалим строку спецификации
      PKG_FLAG.SET_FLAG;
      P_INCOMEFROMDPSPEC_BASE_DELETE(nCOMPANY => nCOMPANY, nRN => rSpec.Rn);
      PKG_FLAG.RESET_FLAG;
    end loop;
  
  end incomefrdep_del;

begin

  --
  if utilizer not in ('CITK_MARKOV', 'KHOK') then
    p_exception(0, 'У вас нет прав на выполнение процедуры. Обратитесь к Администратору!');
  end if;

  --
  if sUNIT = 'GoodsTransInvoicesToDeptsSpecs' then
    invdept_del;
  elsif sUNIT = 'IncomFromDepsSpecs' then
    incomefrdep_del;
  else
    null;
  end if;

end;
/
