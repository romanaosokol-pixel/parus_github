create or replace procedure UDO_P_TRANSINVDEPT_CRT_RSRV
(
  nDOCUMENT                   in number
) 
/*
  Процедура для автоматического создания записей журнала резервирования по заказам подразделений при перемещении с ВК.
  14/03/2025 Степанов М. исключил случаи, когда склад-получатель "Брак"; добавил перевод события в статус "Проверка отд.серт."
  14/03/2025 Степанов М. добавил перевод события в статус "Проверка отд.серт."
  14/03/2025 Степанов М. добавил запись реквизитов родительской накладной в документ-основание создаваемой накладной
*/
is
  -- 18/02/2024 Марков МВ. Формирование накладной на сертификацию
  type rec_CERT is record(
    nCLC number(17), -- калькуляция затрат
    nNM  number(17), -- номенклатура
    nMD  number(17), -- модификация
    nFA  number(17), -- тема
    sC_TP varchar2(2000), -- вид сертификации
    nC_QT number(17, 3), -- количество на сертификацию
    sC_AG varchar2(240), -- сертифицирующая организация
    nSPL  number(17), -- товарный запас в накладную
    nC_QN number(17, 3) -- количество в накладную на сертификацию
  );
  type tCERT is table of rec_CERT;
  rCERT tCERT := tCERT();
  nTD_C       pkg_std.tref; -- Запись заголовка РН на сертификацию
  nTDS_C      pkg_std.tref; -- Запись спецификации РН на сертификацию
  
  --
  mrec                        transinvdept%rowtype; -- Запись заголовка РН 
  rstore                      azsazslistmt%rowtype; -- Запись склада расхода
  rin_store                   AZSAZSLISTMT%rowtype; -- Запись склада прихода    
  sSTKIND                     STKIND.Code%type;     -- Вид склада ВК
  nSTKIND                     pkg_std.tref;         -- Рег. номер склада ВК     
  nRSRV                       pkg_std.tref;         -- Рег. номер журнала резервирования
  nQNT_TMP                    pkg_std.tQUANT;       -- Временная переменная
  nQNT_RSRV                   pkg_std.tQUANT;       -- Кол-во резерва     
  nQNT_ORD                    pkg_std.tQUANT;       -- Кол-во в заказе                      
  tINVOICES                   udo_tp_numtable := udo_tp_numtable();
  tPAYACCINSPCLC              udo_tp_numtable := udo_tp_numtable();
  nClnEvents                  pkg_std.tref;  
  
  /* добавим заголовок РН на сертификацию */
  procedure set_td_c
  (
    rROW      in transinvdept%rowtype, -- накладная выпуска из ВК
    sCERT_AGN in varchar2, -- сертфикатор
    nRN       out number -- запись заголовка
  ) is
    -- накладные формируются в каталоге "ПДО - Сертификация"
    sCRN constant varchar2(20) := 'Сертификация';
    nCRN       PKG_STD.tREF;
    nJUR_PERS  PKG_STD.tREF;
    sJUR_PERS  JURPERSONS.CODE%type;
    nDOCTYPE   constant PKG_STD.tREF := 17575789; -- Расходная накладная в подразделение (списание в производство)
    nIN_STORE  PKG_STD.tREF;
    nIN_STOPER PKG_STD.tREF := 11935240; -- ПриходВнутр;
    nIN_MOL constant PKG_STD.tREF := 8562886; -- Шилов Алексей Николаевич
    nSUBDIV PKG_STD.tREF := 7706819; -- Отдел сертификации
    sPREF  TRANSINVDEPT.PREF%type;
    sNUMB  TRANSINVDEPT.NUMB%type;
    rTRANS TRANSINVDEPT%rowtype;
  begin
    -- каталог
    find_acatalog_name(nFLAG_SMART => 0,
                       nCOMPANY    => rROW.Company,
                       nVERSION    => null,
                       sUNITCODE   => 'GoodsTransInvoicesToDepts',
                       sNAME       => sCRN,
                       nRN         => nCRN);
    -- основное юрлицо
    find_jurpersons_main(nFLAG_SMART => 0, nCOMPANY => rROW.Company, sJUR_PERS => sJUR_PERS, nJUR_PERS => nJUR_PERS);

    /* Сертификатор */
    if rtrim(sCERT_AGN) is not null then
      begin
        select ST.RN
          into nIN_STORE
          from AZSAZSLISTMT ST,
               AGNLIST      AG
         where ST.AGENT = AG.RN
           and ST.COMPANY = rROW.Company
           and AG.AGNABBR = sCERT_AGN;
        nSUBDIV    := null;
      exception
        when no_data_found then
          nIN_STORE  := null;
          /*nIN_STOPER := null; */
      end;
    end if;
    /* генерация следующего номера */
    sPREF := to_char(sysdate, 'yyyy');
    P_TRANSINVDEPT_BASE_NEXTNUMB(rROW.Company, nJUR_PERS, trunc(sysdate), nDOCTYPE, sPREF, sNUMB);
    -- базовое добавление РН
    P_TRANSINVDEPT_BASE_INSERT(nCOMPANY       => rROW.Company,
                               nCRN           => nCRN,
                               nJUR_PERS      => nJUR_PERS,
                               nDOCTYPE       => nDOCTYPE,
                               sPREF          => sPREF,
                               sNUMB          => sNUMB,
                               dDOCDATE       => trunc(sysdate),
                               nDIRDOC        => null,
                               sDIRNUMB       => null,
                               dDIRDATE       => null,
                               nSTOPER        => 12078561, -- РасходВнутр
                               nFACEACC       => null,
                               nGRAPHPOINT    => null,
                               nSTORE         => rROW.In_Store, -- куда приняли
                               nMOL           => rROW.In_Mol,
                               nSHEEPVIEW     => 12737558, -- Сертификация
                               nAGENT         => null,
                               nSUBDIV        => nSUBDIV,
                               nCURRENCY      => 91318, -- базовая
                               nCURCOURS      => 1,
                               nCURBASE       => 1,
                               nSUMMWITHNDS   => 0,
                               nRECIPDOC      => null,
                               sRECIPNUMB     => null,
                               dRECIPDATE     => null,
                               nFERRYMAN      => null,
                               sGETCONFIRM    => null,
                               sWAYBLADENUMB  => null,
                               nDRIVER        => null,
                               nCAR           => null,
                               nROUTE         => null,
                               nTRAILER1      => null,
                               nTRAILER2      => null,
                               nFA_CURCOURS   => 1,
                               nFA_CURBASE    => 1,
                               nIN_STORE      => nIN_STORE,
                               nIN_MOL        => nIN_MOL,
                               nIN_STOPER     => nIN_STOPER,
                               nIN_PARTY      => null,
                               sIN_PARTY      => null,
                               nIN_CURCOURS   => 1,
                               nIN_CURBASE    => 1,
                                /* 14/03/2025 Степанов М. добавил запись реквизитов родительской накладной в документ-основание создаваемой накладной */
                               nVALID_DOCTYPE => rROW.doctype,
                               sVALID_DOCNUMB => pkg_document.make_number(sdoc_pref => rROW.pref, sdoc_numb => rROW.numb),
                               dVALID_DOCDATE => rROW.docdate,
                               sCOMMENTS      => 'Передача на сертификацию',
                               sBARCODE       => null,
                               nRESERV_SIGN   => 0, -- необходимость резервирования
                               nORD_DOCTYPE   => null,
                               sORD_DOCNUMB   => null,
                               dORD_DOCDATE   => null,
                               nNEED_UTIL     => 0,
                               nRN            => nRN);
  end set_td_c;

  /* добавим спецификацию РН */
  procedure set_td_sp_c
  (
    nPRN    in number, -- заголовок
    nMODIF  in number, -- модификация
    nQUANT  in number, -- количество
    nSUPPLY in number, -- товарный запас
    nCLC    in number, -- калькуляция
    nRN     out number -- спецификация
  ) is
    nPARTY   PKG_STD.tREF;
    nCOMPANY PKG_STD.tREF;
    nCLC_RN  PKG_STD.tREF;
  begin
    -- приходная партия ТМЦ
    begin
      select GP.RN,
             GP.COMPANY
        into nPARTY,
             nCOMPANY
        from GOODSPARTIES GP,
             GOODSSUPPLY  GS
       where GS.RN = nSUPPLY
         and GS.PRN = GP.RN;
    exception
      when no_data_found then
        p_exception(0,
                    'Невозможно определить товарный запас для формирования накладной на сертификацию.' || chr(10) ||
                    'GOODSUPPLY: %s',
                    nSUPPLY);
    end;
    -- базовое добавление спецификации
    P_TRANSINVDEPTSP_BASE_INSERT(nCOMPANY         => nCOMPANY,
                                 nPRN             => nPRN,
                                 nAGENT           => null,
                                 nGOODSPARTY      => nPARTY,
                                 nNOMMODIF        => nMODIF,
                                 nNOMNMODIFPACK   => null,
                                 nARTICLE         => null,
                                 nCELL            => null,
                                 nTEMPERATURE     => null,
                                 nPRICE           => 0,
                                 nQUANT           => nQUANT,
                                 nQUANTALT        => 0,
                                 nCOEFF           => 0,
                                 nCOEFF_VAL_SIGN  => 0,
                                 nCOEFF_CALC_SIGN => 1,
                                 nPRICEMEAS       => 1,
                                 nSUMMWITHNDS     => 0,
                                 dBEGINDATE       => null,
                                 dENDDATE         => null,
                                 sNOTE            => null,
                                 sBCODE           => null,
                                 sCARDNUMB        => null,
                                 sSTRCODE         => null,
                                 nCONS_RATE       => null,
                                 nSERVLIFE        => null,
                                 nREVREAS         => null,
                                 sRES_COMMS       => null,
                                 nRN              => nRN);
    -- добавим калькуляцию строки
    for rclc in (select * from PAYACCINSPCLC CLC where CLC.RN = nCLC) loop
      P_TRANSINVDEPTCLC_BASE_INSERT(nCOMPANY      => nCOMPANY,
                                    nPRN          => nRN,
                                    sNUMB         => null,
                                    nCOST_ARTICLE => rclc.cost_article,
                                    nCOST_PLACE   => rclc.cost_place,
                                    nCOST_PLAN    => rclc.cost_plan,
                                    nCOST_FACT    => rclc.cost_fact,
                                    nPRIORITY     => rclc.priority,
                                    nFACEACCOUNT  => rclc.faceaccount,
                                    nGRAPHPOINT   => rclc.graphpoint,
                                    nFINOPER_TYPE => rclc.finoper_type,
                                    nQUANT_PLAN   => nQUANT,
                                    nQUANT_FACT   => nQUANT,
                                    nSUBDIV       => rclc.subdiv,
                                    nRN           => nCLC_RN);
    end loop;
  end set_td_sp_c;

begin
  /* Считывание заголовка РН */
  mrec := UDO_PKG_GET.ROW_TRANSINVDEPT(NRN => nDOCUMENT, NSMART => 0);
  
  /* Проверка отработки */
  if mrec.status != 1 and mrec.in_status != 1  /*and utilizer != 'PARUS'*/ then 
    p_exception(0, 'Накладная должна быть отработана как факт и отработана с приходом.');
  end if;
  
  /* Склады прихода и расхода */
  if mrec.store is not null then 
    rstore := UDO_PKG_GET.ROW_STORE(NRN => mrec.store , NSMART => 0);
  end if;
  if mrec.in_store is not null then 
    rin_store := UDO_PKG_GET.ROW_STORE(NRN => mrec.in_store , NSMART => 0);
  end if;
  
  /* Проверяем склад прихода (если не указан склад, то выходим) */
  if mrec.store is not null then 
    /* Вид склада для входного контроля */
    sSTKIND := UDO_F_GET_CONST_VAL_STR(nFLAG_SMART => 0,nCOMPANY => mrec.Company,sCONST_NAME => 'ВИД_СКЛАДА_ВК');
    FIND_STKIND_CODE(nFLAG_SMART  => 0,
                     nFLAG_OPTION => 0,
                     nCOMPANY     => mrec.Company,
                     sCODE        => sSTKIND,
                     nRN          => nSTKIND);
    
    /* Если вид склада расхода не равен "ВК", то выходим. Резервируем только при перемещении с ВК.*/
--if utilizer in ('CITK_MARKOV') then p_exception(0, 'mrec.stoper = %s', mrec.stoper); end if;
    if rSTORE.STKIND != nSTKIND or rSTORE.STKIND is null or rSTORE.STKIND = rIN_STORE.STKIND
      or mrec.stoper in (50233858) -- 30/01/2023 Марков МВ. Кроме возвратных накладных
      /* 14/03/2025 Степанов М. исключил случаи, когда склад-получатель "Брак"; добавил перевод события в статус "Проверка отд.серт." */
      or rIN_STORE.STKIND = 58790915 /* Вид склада-получателя "Брак" */
       then  
      return;      
    end if;    
  else 
    return;
  end if;  
  
  /* Считывание приходных накладных для ТЗ расходной накладной */
  select distinct dl.in_document
    bulk collect into tINVOICES 
    from INORDERSPECS      sp,
         goodssupply       gs,
         TRANSINVDEPTSPECS td,
         goodsparties      gp,
         doclinks          dl
   where td.prn         = mrec.rn
     and sp.goodssupply = gs.rn
     and gs.prn         = td.goodsparty
     and td.goodsparty  = gp.rn
     and sp.Nommodif    = td.nommodif 
     and cmp_num(sp.Nomnmodifpack,td.nomnmodifpack) = 1 
     and cmp_num(sp.ARTICLE, td.article)   = 1 
     and cmp_vc2(sp.SERNUMB, gp.sernumb)   = 1 
     and cmp_num(sp.COUNTRY, gp.country)   = 1 
     and cmp_vc2(sp.GTD, gp.gtd)           = 1
     and dl.in_unitcode  = 'IncomingInvoices'
     and dl.out_unitcode = 'IncomingOrders'
     and dl.out_document = sp.prn;
     	 
  if tINVOICES.Count = 0 then 
    null;
    -- 02/03/2023 есть Выход с ВК после возврата с производства
    -- p_exception(0 , 'Не удалось подобрать приходные накладные для автоматического формирования резервов по заказам подразделений.');
  end if;
  
  
  /* 2023.06.02 Переделано резервирование с подбора заказов подразделения по плану закупок на подбор по калькуляции ВСО    
     Считывание калькуляции входящего счета на оплату (с отбором по калькуляции РН) */
  select distinct pc.rn
    bulk collect into tPAYACCINSPCLC
    from payaccinspclc     pc,
         payaccinspec      ps,
         doclinks          dl,
         TRANSINVDEPTSPECS td,
         TRANSINVDEPTCLC   tc,
         table(tINVOICES) iv
   where -- заголовки ВСО - ПН
         dl.in_document  = ps.prn 
     and dl.in_unitcode  = 'PaymentAccountsIn'
     and dl.out_unitcode = 'IncomingInvoices'
     and dl.out_document = iv.column_value
         -- спецификация РН - ВСО
     and td.prn      = mrec.rn
     and ps.Nommodif = td.nommodif 
     and cmp_num(ps.Nommodifpack,td.nomnmodifpack) = 1 
         -- калькуляция РН - ВСО
     and td.rn = tc.prn 
     and ps.rn = pc.prn        
     and tc.faceaccount = pc.faceaccount;
  
  
  if tPAYACCINSPCLC.Count > 0 then 
    
    /* Параметры сертификации */
    rCERT := tCERT();
    -- 18/02/2025 Марков МВ. 
    for rct in(select PEX.PRN CLC_RN,
                      ORDS.NOMEN, 
                      ORDS.NOM_MODIF,
                      (select ORD.FACEACC from DEPARTMENTORD ORD where ORD.RN = ORDS.PRN) as FACEACC,
                      (select DV.STR_VALUE
                         from DOCS_PROPS_VALS DV
                        where DV.UNIT_RN = ORDS.RN
                          and DV.DOCS_PROP_RN = 106408702) as CERT_K, -- Вид сертификации
                      (select DV.STR_VALUE
                         from DOCS_PROPS_VALS DV
                        where DV.UNIT_RN = ORDS.RN
                          and DV.DOCS_PROP_RN = 165891904) as CERT_A, -- Сертифицирующая организация
                      (select DV.NUM_VALUE
                         from DOCS_PROPS_VALS DV
                        where DV.UNIT_RN = ORDS.RN
                          and DV.DOCS_PROP_RN = 55996499) as CERT_Q -- Количество для сертификации
                 from table(tPAYACCINSPCLC) TC,
                      PAYACCINSPCLC_EX      PEX,
                      DEPARTMENTORDS        ORDS
                where PEX.PRN = TC.COLUMN_VALUE
                  and PEX.DEPARTMENTORDSP = ORDS.RN) loop
      --
      if rCERT.Count > 0 then
        for Idx in rCERT.First..rCERT.Last loop
          if rCERT(Idx).nNM = rct.nomen and rCERT(Idx).nMD = rct.nom_modif then
            rCERT(Idx).sC_AG := nvl(rCERT(Idx).sC_AG, rct.cert_a);
            if rCERT(Idx).nC_QT < rct.cert_q then
              rCERT(Idx).nC_QT := rct.cert_q;
            end if;
            rct.cert_q := 0;
          end if;
        end loop;
      end if;
      --
      if nvl(rct.cert_q, 0) > 0 then
        rCERT.Extend;
        rCERT(rCERT.Last).nCLC  := rct.clc_rn;
        rCERT(rCERT.Last).nNM   := rct.nomen;
        rCERT(rCERT.Last).nMD   := rct.nom_modif;
        rCERT(rCERT.Last).sC_TP := rct.cert_k;
        rCERT(rCERT.Last).nC_QT := nvl(rct.cert_q, 0);
        rCERT(rCERT.Last).sC_AG := rct.cert_a;
        rCERT(rCERT.Last).nC_QN := 0;
        rCERT(rCERT.Last).nSPL  := to_number(null);
        rCERT(rCERT.Last).nFA   := rct.faceacc;
      end if;
    end loop;
    
--if utilizer in ('CITK_MARKOV') then p_exception(0, '1. rCERT.Count = %s', rCERT.Count); end if;
    /* Цикл по строкам расходной накладной */
    for cur in (select T.Goodssupply, gp.country,gp.gtd, gp.sernumb, ts.*,
                       0 as cert_quant
                  from transinvdeptspecs ts,
                       STOREOPERJOURN    T,
                       goodssupply       gs,
                       goodsparties      gp,
                       doclinks          dl
                 where t.goodssupply   = gs.rn
                   and gs.prn          = gp.rn
                   and t.oper_type     = 1 -- приход
                   and ts.prn          = mrec.rn
                   and dl.in_unitcode  = 'GoodsTransInvoicesToDeptsSpecs'
                   and dl.in_document  = ts.rn 
                   and dl.out_unitcode = 'StoreOpersJournal'
                   and dl.out_document = t.rn)
    loop  
      -- 18/02/2025 Марков МВ сертификация
      if rCERT.Count > 0 then
        for Idx in rCERT.First..rCERT.Last loop
          if nvl(rCERT(Idx).nMD, 0) = cur.nommodif then
            if rCERT(Idx).nC_QT > cur.quant then
              rCERT(Idx).nC_QN := cur.quant;
            else
              rCERT(Idx).nC_QN := rCERT(Idx).nC_QT;
            end if;
            rCERT(Idx).nSPL := cur.goodssupply;
            cur.cert_quant := rCERT(Idx).nC_QN;
--if utilizer in ('CITK_MARKOV') then p_exception(0, '6. rCERT(Idx).nC_QN = %s; rCERT(Idx).nC_QT = %s', rCERT(Idx).nC_QN, rCERT(Idx).nC_QT); end if;
          end if;
        end loop;
      end if;
      --
      
      /* Цикл по калькуляциии РН */
      for clc in (select tc.prn, tc.faceaccount, sum(tc.quant_fact) as nQUANT
                    from transinvdeptclc tc
                   where tc.prn = cur.rn
                   group by tc.prn, tc.faceaccount)
      loop
        /* Кол-во строки РН к распределению по плановому заказу */   
        nQNT_TMP := clc.nQUANT;
        
        /* Цикл по заказам подразделений связанным со строками калькуляции ВСО */
        for ord in (select pd.departmentordsp as nORDSP, pd.quant 
                      from PAYACCINSPCLC_EX      pd,
                           table(tPAYACCINSPCLC) tc,
                           payaccinspclc         pc,
                           payaccinspec          ps,
                           DEPARTMENTORDS        ds,
                           DEPARTMENTORD         d
                     where pc.rn              = pd.prn 
                       and pc.rn              = tc.column_value
                       and pc.faceaccount     = clc.faceaccount
                       and pd.departmentordsp = ds.rn
                       and ds.prn             = d.rn 
                           -- спецификации ВСО - РН 
                       and ps.rn              = pc.prn    
                       and ps.Nommodif        = cur.nommodif 
                       and cmp_num(ps.Nommodifpack,cur.nomnmodifpack) = 1 
                     order by d.RELEASE_DATE)
        loop   
          /* Кол-во доступное для резерва по заказу (наименьшее из количества доступного по заказу и количества из расшифровки калькуляции ВСО) */
          nQNT_ORD := least(UDO_PKG_RESJOURNAL_CTRL.GET_QUANTERST_BY_ORDER(nDEPORDS => ord.nORDSP), ord.quant); 
          
          if nQNT_ORD <= 0 then 
            continue;
          end if;  
          
          /* контроль количества для резервирования по заказу */
          if nQNT_TMP >= nQNT_ORD then 
            nQNT_RSRV :=  nQNT_ORD;
          else 
            nQNT_RSRV := nQNT_TMP;
          end if;  
          
          /* Добаление резерва*/
          UDO_PKG_RESJOURNAL_CTRL.MAKE_BY_DORDS_EX(NSUPPLY  => cur.goodssupply,
                                                   NQUANT   => nQNT_RSRV,
                                                   nDEPORDS => ord.nORDSP,
                                                   nRSRV    => nRSRV);
          nQNT_TMP := nQNT_TMP - nQNT_RSRV;
          
          exit when nQNT_TMP <= 0;            
        end loop ord;
        
      end loop clc;                                             
    end loop cur; 
     
  end if;
  
  /* 25/02/2025 Марков МВ.
     Формирование накладной на сертификацию */
  if rCERT.Count > 0 then
    nTD_C      := null;
    nTDS_C     := null;
    nClnEvents := null;
    for Idx in rCERT.First..rCERT.Last loop
      -- только для заполненных позиций
      if rCERT(Idx).nSPL is not null and rCERT(Idx).nC_QN > 0 then
        -- заголовок РН
        if nTD_C is null then
          -- добавим заголовок
          set_td_c(rROW      => mrec,
                   sCERT_AGN => rCERT(Idx).sC_AG, 
                   nRN       => nTD_C);
        end if;
        -- спецификация РН
        set_td_sp_c(nPRN    => nTD_C,
                    nMODIF  => rCERT(Idx).nMD, 
                    nQUANT  => rCERT(Idx).nC_QN, 
                    nSUPPLY => rCERT(Idx).nSPL, 
                    nCLC    => rCERT(Idx).nCLC,
                    nRN     => nTDS_C);
      end if;
    end loop;

    /* 14/03/2025 Степанов М. добавил перевод события в статус "Проверка отд.серт." */
    /* Событие статусной модели. RN */
    nClnEvents := usr_pkg_document.get_clnevents(nflagsmart => 1, nrn => nTD_C);
    /* Если событие найдено */
    if nClnEvents is not null then 
      /* Перевод на статус "Проверка отд.серт." */
      p_clnevents_change_state(ncompany         => mrec.company
                              ,nrn              => nClnEvents
                              ,sevent_stat      => 'Проверка отд.серт.'
                              ,ssend_client     => null
                              ,ssend_division   => null
                              ,ssend_post       => null
                              ,ssend_perform    => null
                              ,ssend_person     => null
                              ,ssend_staffgrp   => null
                              ,ssend_user_group => null
                              ,ssend_user_name  => null);
    end if;
  end if;
  
  /*        
  \* Считывание заказов поставщиков, связанных с приходной накладной*\
  for cur in (select dl.in_document as nDLVRYORD 
                from DOCLINKS dl, 
                     table(tINVOICES) t
               where dl.in_unitcode  = 'DeliveryOrders' 
                 and dl.out_document = t.column_value
                 and dl.out_unitcode = 'IncomingInvoices'
               union  
              select dl2.in_document as nDLVRYORD 
                from DOCLINKS         dl, 
                     DOCLINKS         dl2, 
                     table(tINVOICES) t
               where dl.in_unitcode   = 'PaymentAccountsIn' 
                 and dl.out_document  = t.column_value
                 and dl.out_unitcode  = 'IncomingInvoices'
                 and dl2.in_unitcode  = 'DeliveryOrders' 
                 and dl2.out_unitcode = dl.in_unitcode
                 and dl2.out_document = dl.in_document)
  loop
    tDLVRYORD.EXTEND;
    tDLVRYORD(tDLVRYORD.Last) := cur.nDLVRYORD;
  end loop cur;
  
  \* Считывание спецификации заказов поставщиков, связанных с приходной накладной *\
  select distinct ds.rn
    bulk collect into tDLVRYORDS 
    from DELIVERYORDS ds,
         TRANSINVDEPTSPECS td,
         table(tDLVRYORD) t 
   where ds.prn       = t.column_value
     and td.prn       = mrec.rn
     and ds.NOM_MODIF = td.nommodif 
     and cmp_num(ds.NOMMOD_PACK,td.nomnmodifpack) = 1 
     and cmp_num(ds.PRODUCT, td.article)   = 1; 
  
  if tDLVRYORDS.Count = 0 then 
    --p_exception(0 , 'Не удалось подобрать заказы поставщиков для автоматического формирования резервов по заказам подразделений.');
    return;
  end if;   
  
  \* Считывание строк заказов пдразделений включенных в план закупок *\
  select bp.rn
   bulk collect into tBPLNPREF
    from table(tDLVRYORDS)              ds,
         BUYPLANESPREF                  bp,
         UDO_UZD_03_BUYPLANESP_CNTR_DOC b
   where ds.column_value = b.doc_rn
     and b.doc_unitcode  = 'DeliveryOrdersSpec' 
     and b.rn_ref        = bp.rn;     
  
  if tBPLNPREF.Count = 0 then 
    --p_exception(0 , 'Не удалось подобрать строки плана закупок для автоматического формирования резервов по заказам подразделений.');
   return;
  end if;   
    

  if tBPLNPREF.Count > 0 then 
    
    \* Цикл по строкам расходной накладной *\
    for cur in (select T.*, gp.nommodif , gp.nomnmodifpack 
                  from STOREOPERJOURN T,
                       goodssupply    gs,
                       goodsparties   gp,
                       doclinks       dl
                 where t.goodssupply   = gs.rn
                   and gs.prn          = gp.rn
                   and t.oper_type     = 1 -- приход
                   and dl.in_unitcode  = 'GoodsTransInvoicesToDepts'
                   and dl.in_document  = mrec.rn
                   and dl.out_unitcode = 'StoreOpersJournal'
                   and dl.out_document = t.rn)
    loop  
      nQNT_TMP := cur.QUANT;
      
      \* Цикл по заказам подразделений (для резервирования используем остток п строке ЗП)*\
      for ord in (select distinct ds.rn             as nORDSP,
                                  d.RELEASE_DATE
                    from BUYPLANESPREF                  b,
                         DEPARTMENTORDS                 ds,
                         DEPARTMENTORD                  d,
                         UDO_UZD_03_BUYPLANESP_CNTR_DOC bp,
                         table(tBPLNPREF)               tb
                   where b.rn        = tb.column_value
                     and b.deptordsp = ds.rn
                     and ds.prn      = d.rn
                     and bp.rn_ref   = b.rn
                     and ds.nom_modif = cur.nommodif
                     and cmp_num(ds.nommod_pack, cur.nomnmodifpack)  = 1
                   order by d.RELEASE_DATE)
      loop   
        nQNT_ORD := UDO_PKG_RESJOURNAL_CTRL.GET_QUANTERST_BY_ORDER(nDEPORDS => ord.nORDSP); 
        
        if nQNT_ORD <= 0 then 
          continue;
        end if;  
        
        \* контроль количества для резервирования по заказу *\
        if nQNT_TMP >= nQNT_ORD then 
          nQNT_RSRV :=  nQNT_ORD;
        else 
          nQNT_RSRV := nQNT_TMP;
        end if;  
        
        \* Добаление резерва*\
        UDO_PKG_RESJOURNAL_CTRL.MAKE_BY_DORDS_EX(NSUPPLY  => cur.goodssupply,
                                                 NQUANT   => nQNT_RSRV,
                                                 nDEPORDS => ord.nORDSP,
                                                 nRSRV    => nRSRV);
        nQNT_TMP := nQNT_TMP - nQNT_RSRV;
        
        exit when nQNT_TMP <= 0;  
      end loop ord;                                           
    end loop cur;
  end if;*/
end;
/
