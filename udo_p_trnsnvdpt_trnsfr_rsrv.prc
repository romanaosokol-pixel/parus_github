create or replace procedure UDO_P_TRNSNVDPT_TRNSFR_RSRV
(
  NCOMPANY                    in number,   -- Рег. номер организации
  NRN                         in number,   -- Рег. номер РН
  sACTION                     in varchar2, -- код действия
  sMODE                       in varchar2  -- код режима (BEFORE - до действия, AFTER - после действия)
)
is
  /* Процедура разработана для снятия и восстановления резервов для целей перемещения ТМЦ при помощи РНОПодр*/
  
  /*
    22/10/2024 Степанов М. за исключением резервов по комплектовочным ведомостям документов на склад Временного преремещения
    28/02/2023 Марков МВ.
    Добавил склады Сертификации для перемещения резервов
    26/09/2023 Марков МВ.
    Доработал перенос резервов при прохождении сертификации, так как создается новая партия ТМЦ с сертификатом
  */
  
  RTID                        TRANSINVDEPT%rowtype; -- Запись РН
  NTYPE                       PKG_STD.tREF;         -- тип запуска (0 - снять резерв 1 - восстановить резерв)
  nWORK                       PKG_STD.tREF;         -- тип работы (0 - снять отработку, 1-отработать)
  nQNT_REST                   pkg_std.tQUANT;       -- Кол-во к резервированию  
  nQNT_RSRV                   pkg_std.tQUANT;       -- Кол-во резерва             
  NRSRV_NEW                   PKG_STD.tref;         -- Рег. номер резрва
  ntmp                        PKG_STD.tREF;         -- Временная переменная

  rSTORE                      azsazslistmt%rowtype; -- Запись склада расхода
  rIN_STORE                   azsazslistmt%rowtype; -- Запись склада прихода
  SDEF_STKIND_DSE             PKG_STD.tSTRING := 'ДСЕ';  -- вид склада для контроля
  SDEF_STKIND_ERI             PKG_STD.tSTRING := 'ЭРИ';  -- вид склада для контроля
  SDEF_STKIND_CERT            PKG_STD.tSTRING := 'Сертификация';  -- вид склада для контроля
  SDEF_STKIND_BRAK            PKG_STD.tSTRING := 'Изолятор брака';  -- вид склада для контроля (исключить)!!!!
  --
  SDEF_STKIND_VK              PKG_STD.tSTRING := 'ВК';   -- вид склада для контроля
  nDEF_STKIND_VK              PKG_STD.tREF;
  nDEF_STKIND_DSE             PKG_STD.tREF;
  nDEF_STKIND_ERI             PKG_STD.tREF;
  nDEF_STKIND_CERT            PKG_STD.tREF;
  nDEF_STKIND_BRAK            PKG_STD.tREF;
  
  /* Считывание атрибутов РН и режима работы */         
  procedure GET_ATTR
  (
    NRN                         in number,   -- Рег. номер РН
    sACTION                     in varchar2, -- код действия
    sMODE                       in varchar2, -- код режима (BEFORE - до действия, AFTER - после действия)
    NTYPE                       out number,  -- тип запуска (0 - снять резерв 1 - восстановить резерв)
    nWORK                       out number,  -- тип работы (0 - снять отработку, 1-отработать)  
    RTID                        out TRANSINVDEPT%rowtype -- Запись РН
  )
  is
  begin     
     /* Отработка */
    if sACTION in ('TRANSINVDEPT_ASPLAN','TRANSINVDEPT_PROCESS') then    
      /* Режим работы */
      if sMODE = 'BEFORE' then 
        NTYPE := 0;
        nWORK := 1;
      else 
        NTYPE := 1;
        nWORK := 1;
      end if;
    /* Снятие отработки */
    elsif sACTION = 'TRANSINVDEPT_CANCEL' then   
      /* Режим работы */
      if sMODE = 'BEFORE' then 
        NTYPE := 0;
        nWORK := 0;
      else 
        NTYPE := 1;
        nWORK := 0;
      end if;
    else 
      NTYPE := null;  
      nWORK := null;
    end if;

    if NTYPE is not null then 
      /* Проверка наличия связи (закрытие резервов связнанных с КВ выполняется в отдельной процедуре) */
      if f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                                nOUT_DOCUMENT => NRN,
                                sIN_UNITCODE  => 'CostDeliverySheets') is not null then 
         NTYPE := null;  
         nWORK := null;
      end if;
      
      /* Считывание РН */
      RTID := udo_pkg_get.ROW_TRANSINVDEPT(NRN => NRN, NSMART => 0);
      
      /* Считывание складов */
      rSTORE    := udo_pkg_get.ROW_STORE(NRN => RTID.STORE, NSMART => 1);
      rIN_STORE := udo_pkg_get.ROW_STORE(NRN => RTID.In_Store, NSMART => 1); 
    
    
      /* виды складов для проверки */
      if rSTORE.Rn is not null and rIN_STORE.Rn is not null then 
        find_stkind_code(nFLAG_SMART  => 0,
                         nFLAG_OPTION => 0,
                         nCOMPANY     => nCOMPANY,
                         sCODE        => SDEF_STKIND_DSE,
                         nRN          => nDEF_STKIND_DSE);
        find_stkind_code(nFLAG_SMART  => 0,
                         nFLAG_OPTION => 0,
                         nCOMPANY     => nCOMPANY,
                         sCODE        => sDEF_STKIND_ERI,
                         nRN          => nDEF_STKIND_ERI);
        find_stkind_code(nFLAG_SMART  => 0,
                         nFLAG_OPTION => 0,
                         nCOMPANY     => nCOMPANY,
                         sCODE        => sDEF_STKIND_CERT,
                         nRN          => nDEF_STKIND_CERT);
        find_stkind_code(nFLAG_SMART  => 0,
                         nFLAG_OPTION => 0,
                         nCOMPANY     => nCOMPANY,
                         sCODE        => sDEF_STKIND_VK,
                         nRN          => nDEF_STKIND_VK);
      end if;                 
      
      /* Проверка заполнен складов (если не заполнен, то не выполненяем НБ) и 
         вида складов расхода и прихода (если виды складов не "ЭРИ" и "ДСЕ", то не выполненяем НБ)*/
      if RTID.Store is null or 
         RTID.In_Store is null or 
         (rSTORE.Stkind not in (nDEF_STKIND_DSE, nDEF_STKIND_ERI, nDEF_STKIND_CERT)
         and f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts', nOUT_DOCUMENT => NRN,sIN_UNITCODE => 'UdoProdCull') is null) or 
         (rIN_STORE.Stkind not in (nDEF_STKIND_DSE, nDEF_STKIND_ERI, nDEF_STKIND_CERT)
          and f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts', nOUT_DOCUMENT => NRN,sIN_UNITCODE => 'UdoProdCull') is null)
          then
         
         NTYPE := null;  
         nWORK := null;
--if utilizer in('CITK_MARKOV') then p_exception(0, 'No result.'); end if;
         return; -- 24/10/2022 Марков МВ. не выполняем, значит возврат
         
      end if;
      
      /* Проверка отрабтки с приходом (при перемещении ТМЦ обязательна отработка  с приходом) */
      if sACTION in ('TRANSINVDEPT_ASPLAN','TRANSINVDEPT_PROCESS')
        and sMODE = 'AFTER' 
        and rTID.In_Status = 0 /*and utilizer not in ('PAY', 'PARUS')*/ then
        
        p_exception(0, 'При перемещении ТМЦ между складами обязательно необходимо выполнять действие "Отработать с приходом".');
      
      /*else 
        if sMODE = 'AFTER' then 
        p_exception(0,sACTION ||'-'||sMODE|| '    '||NTYPE||'-'||nWORK);
        end if;*/
      end if;
      
    end if;
    
  end GET_ATTR;
    
  /* Закрываем резерв и его исполнение */
  procedure RSRV_CLOSE
  (
    nPRN       in number,
    nRSRV      in number,
    nDORDSP    in number,
    ninvdptsp  in number,
    ncmpl      in number 
  )
  is
  begin   
    /* Считываем связи перед закрытием (регистрируем их во временной таблице) */
    for cur in (select dl.in_unitcode, dl.in_document, dl.out_unitcode, dl.out_document 
                  from DOCLINKS dl 
                 where dl.in_document = nRSRV
                   and dl.in_unitcode = 'ReservationJournal'
                 union all 
                select dl.in_unitcode, dl.in_document, dl.out_unitcode, dl.out_document  
                  from DOCLINKS dl 
                 where dl.out_document = nRSRV 
                   and dl.out_unitcode = 'ReservationJournal')  
    loop
      /* Сохраним данные для последующго восстановления */
      insert into UDO_TRNSFR_RSRV_LNK_TMP
        (RN,
         PRN,
         RSRV,
         IN_UNITCODE,
         IN_DOCUMENT,
         OUT_UNITCODE,
         OUT_DOCUMENT)
      values
        (gen_id(),
         nPRN,
         nRSRV,
         cur.in_unitcode,
         cur.in_document,
         cur.out_unitcode,
         cur.out_document); 
    end loop cur;
    
    /* Закрываем резерв */ 
    udo_pkg_resjournal_ctrl.take(ndocument      => nRSRV,
                                 snote          => 'Резерв закрыт из расходной накладной.',
                                 nlink_drop     => 1,
                                 ndords_setnull => 1);
    /* Обнуляем исполнение */
    if nDORDSP is not null then                               
      udo_pkg_depords_prf.SET_INVDPTSP(nDORDSP   => nDORDSP,
                                       nRSRV     => nRSRV,
                                       nINVDPTSP => null); 
      udo_pkg_depords_prf.SET_CMPL(nDORDSP => nDORDSP,
                                   nRSRV   => nRSRV,
                                   nCMPL   => null);                  
    end if;
    
    /* Сохраним данные резерва во временную таблицу для последующго восстановления */
    insert into UDO_TRNSFR_RSRV_TMP
      (RN, PRN,  DORDSP, RSRV, INVDPTSP ,CMPL)
    values
      (gen_id(),
       nPRN,
       nDORDSP,
       nRSRV,
       ninvdptsp,
       ncmpl); 
  end RSRV_CLOSE; 
  
            
  /* создание нового резерва */
  procedure RSRV_OPEN
  (
    nCOMPANY  in number,
    nPRN      in number,
    nRSRV_OLD in number,
    nSUPPLY   in number,
    nQUANT    in number,
    nDORDSP   in number,
    nINVDPTSP in number,
    nCMPL     in number,
    NRSRV_NEW out number
  )
  is
    RRESJRN     RESJOURNAL%rowtype;
  begin
    /* Если резерв связана с ЗП, то создаем резерв и восстанавливаем привязку */
    if nDORDSP is not null then 
      udo_pkg_resjournal_ctrl.make_by_dords_ex(nsupply  => NSUPPLY,
                                               nquant   => nQUANT,
                                               ndepords => nDORDSP,
                                               nrsrv    => NRSRV_NEW);
                                           
      if nINVDPTSP is not null then
        udo_pkg_depords_prf.SET_INVDPTSP(nDORDSP   => nDORDSP,
                                         nRSRV     => NRSRV_NEW,
                                         nINVDPTSP => nINVDPTSP);  
      end if;
      if nCMPL is not null then 
        udo_pkg_depords_prf.SET_CMPL(nDORDSP => nDORDSP,
                                     nRSRV   => NRSRV_NEW,
                                     nCMPL   => nCMPL);  
      end if; 
    /*Если резерв не связан с ЗП, то просто создаем резерв */     
    else 
      /* считываем закрытый резерв */
      RRESJRN := udo_pkg_get.ROW_RESJOURNAL(NRN => nRSRV_OLD, NSMART => 0);
      
      /*создание резерва без привязка к ЗП */
      P_RESJOURNAL_BASE_INSERT(NCOMPANY        => RRESJRN.COMPANY
                              ,SAUTHID         => RRESJRN.AUTHID
                              ,NSUPPLY         => nSUPPLY
                              ,DRES_START_DATE => RRESJRN.RES_START_DATE
                              ,DRES_END_DATE   => null
                              ,NQUANT          => nQUANT
                              ,NQUANT_ALT      => NVL(RRESJRN.QUANT_ALT ,0)
                              ,NDOCTYPE        => RRESJRN.DOCTYPE
                              ,DDOCDATE        => RRESJRN.DOCDATE
                              ,SDOCPREF        => RRESJRN.DOCPREF
                              ,SDOCNUMB        => RRESJRN.DOCNUMB
                              ,NAGENT          => RRESJRN.AGENT
                              ,NSUBDIV         => RRESJRN.SUBDIV
                              ,NSELL_TUBE      => RRESJRN.SELL_TUBE
                              ,NACC_AGENT      => RRESJRN.ACC_AGENT
                              ,SNOTES          => RRESJRN.NOTES
                              ,NRN             => NRSRV_NEW);
    end if;
    
    /* Восстанавливаем связи резерва */     
    for cur in (select t.* 
                  from udo_trnsfr_rsrv_lnk_tmp t
                 where t.prn  = nPRN  
                   and t.rsrv = nRSRV_OLD)
    loop
      p_linksall_link_direct(nCOMPANY          => nCOMPANY,
                             sIN_UNITCODE      => cur.in_unitcode,
                             nIN_DOCUMENT      => case when cur.in_unitcode = 'ReservationJournal' then NRSRV_NEW else cur.in_document end,
                             nIN_PRN_DOCUMENT  => null,
                             dIN_IN_DATE       => sysdate,
                             nIN_STATUS        => 0,
                             sOUT_UNITCODE     => cur.out_unitcode,
                             nOUT_DOCUMENT     => case when cur.out_unitcode = 'ReservationJournal' then NRSRV_NEW else cur.out_document end,
                             nOUT_PRN_DOCUMENT => null,
                             dOUT_IN_DATE      => sysdate,
                             nOUT_STATUS       => 0);
    end loop;                   
  end RSRV_OPEN;    
  
  /* Подчистка временных таблиц */
  procedure RSRV_TMP_DELETE
  (
   nPRN in number
  )
  is 
  begin 
    delete from UDO_TRNSFR_RSRV_TMP TD where td.prn = nPRN; 
    delete from UDO_TRNSFR_RSRV_LNK_TMP TD where td.prn = nPRN;
  end RSRV_TMP_DELETE;  
  
begin
  --if utilizer not in ('PAY', 'PARUS') then return; end if;
  /* Считывание атрибутов РН и режима работы */
  GET_ATTR(NRN       => NRN,    
           sACTION   => sACTION,
           sMODE     => sMODE,  
           NTYPE     => NTYPE,    
           nWORK     => nWORK,    
           RTID      => RTID); 
           
  /* Если не определили режим работы, то выходим */
  if NTYPE is null then 
    return; 
  end if; 
  
  /* Цик по спецификации РН */
  for SP in (select Gs.RESTFACT,
                    gs.restplan, 
                    Gs.RESERV, 
                    TS.RN,
                    TS.QUANT,
                    TS.GOODSPARTY, -- старая партия ТМЦ
                    (select PC.RN
                       from TRANSINVDEPT  TD,
                            DOCLINKS      L,
                            UDO_PROD_CULL PC
                      where TD.RN = nRN
                        and L.OUT_DOCUMENT = TD.RN
                        and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                        and L.IN_DOCUMENT = PC.RN
                        and L.IN_UNITCODE = 'UdoProdCull'
                        and PC.MODE_CHECK = 0) as PROD_CULL_CERT, -- журнал сертификации
                    (select GS.RN
                       from STOREOPERJOURN SOJ,
                            DOCLINKS       LS,
                            GOODSSUPPLY    GS
                      where LS.IN_DOCUMENT = TS.RN
                        and LS.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                        and LS.OUT_DOCUMENT = SOJ.RN
                        and LS.OUT_UNITCODE = 'StoreOpersJournal'
                        and SOJ.OPER_TYPE = 1
                        and SOJ.GOODSSUPPLY = GS.RN) as SUPPLY_NEW, -- новая партия
                    (select GS.PRN
                       from STOREOPERJOURN SOJ,
                            DOCLINKS       LS,
                            GOODSSUPPLY    GS
                      where LS.IN_DOCUMENT = TS.RN
                        and LS.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                        and LS.OUT_DOCUMENT = SOJ.RN
                        and LS.OUT_UNITCODE = 'StoreOpersJournal'
                        and SOJ.OPER_TYPE = 1
                        and SOJ.GOODSSUPPLY = GS.RN) as PARTY_NEW -- новая партия
               from TRANSINVDEPTSPECS TS, 
                    GOODSSUPPLY gs
              where TS.PRN = RTID.RN
                and TS.Goodsparty = Gs.PRN
                and case when nWORK = 1 and gs.store = RTID.Store then 1 
                         when nWORK = 0 and gs.store = RTID.In_Store then 1 
                    else 0 end = 1) 
  loop 

      /* Снятие резерва */
      if NTYPE = 0 then 
        /* кол-во к перемещению */
        nQNT_REST := sp.Quant - ( least(SP.RESTFACT,sp.restplan) - SP.RESERV );   
        /* если ТЗ зарезерирован, то закрываем/открываем резерв на оставшееся количество */
        if nQNT_REST > 0 then
          /* Цикл по резервам */
          for rsrv in (select UR.DORDSP,ur.invdptsp, ur.cmpl, r.*
                         from RESJOURNAL      R,
                              goodssupply     gs,
                              udo_depords_prf UR
                        where gs.prn = SP.GOODSPARTY
                          and r.supply = gs.rn
                          and R.RN = UR.RSRV(+)
                          and r.res_end_date is null
                          and case when nWORK = 1 and gs.store = RTID.Store then 1  
                                   when nWORK = 0 and gs.store = RTID.In_Store then 1 
                              else 0 end = 1
                          /* 22/10/2024 Степанов М. за исключением резервов по комплектовочным ведомостям документов на склад Временного преремещения */
                          and not ( rSTORE.Stkind in (nDEF_STKIND_DSE, nDEF_STKIND_ERI)
                                    and rIN_STORE.rn = 20300310
                                    and ( f_doclinks_link_in(sout_unitcode => 'ReservationJournal', nout_document => r.rn, sin_unitcode  => 'CostDeliverySheetsSpecCompletion') is not null 
                                        or exists ( select null from UDO_DEPORDS_PRF where rsrv = r.rn ) ) )
                         order by ur.rn NULLS FIRST)  
          loop
             /* кол-во доступное для перемещения (кол-во резерва) */
             if nQNT_REST >= rsrv.quant then
               nQNT_RSRV := rsrv.quant;
             else  
               /* Разбиваем резерв только если перемещение между разными складами (меняется ссылка на goodssupply). 
                  Если в рамках одного склада, то просто закрываем/открываем резерв */ 
               if RTID.Store != RTID.In_Store then 
                 nQNT_RSRV := nQNT_REST;
               else 
                 nQNT_RSRV := rsrv.quant;
               end if;  
             end if;
                
             /* разбиение резерва на 2 части, если кол-вов резерва превышает необходимое для перемещение */
             if nQNT_RSRV != rsrv.quant then 
               UDO_PKG_RESJOURNAL_CTRL.DIVISION(NRESJOURNAL_SRC  => rsrv.rn,
                                                NQUANT_IN        => nQNT_RSRV,-- кол-во для выделения
                                                NRESJOURNAL_IN   => rsrv.rn,   -- рег. номер записи резерва с выделенным количеством (nQNT_RSRV)
                                                NRESJOURNAL_REST => ntmp      -- рег. номер записи резерва с остатком количества
                                                );
             end if;
              
             /* Закрываем резерв и его исполнение */
             RSRV_CLOSE(nPRN      => sp.rn,
                        nRSRV     => rsrv.rn,
                        nDORDSP   => rsrv.DORDSP,
                        nINVDPTSP => rsrv.invdptsp,
                        nCMPL     => rsrv.cmpl);    
                             
            /* Остаток к перемещению */                 
            nQNT_REST := nQNT_REST - nQNT_RSRV;
            
            exit when nQNT_REST <= 0;  
          end loop rsrv;
      
        end if;    

      /* Восстановление резерва */
      elsif NTYPE = 1 then
        for GSP in (select T.RN     TMP_RN,
                           T.DORDSP,
                           T.CMPL, 
                           T.INVDPTSP,
                           t.rsrv,
                           r.quant, 
                           GS.RN       NSUPPLY
                      from UDO_TRNSFR_RSRV_TMP T,
                           RESJOURNAL          r,
                           GOODSSUPPLY         GS
                     where t.prn  = sp.rn 
                       and gs.prn = sp.Goodsparty
                       and t.rsrv = r.rn  
                       and case when nWORK = 1 and gs.store = RTID.In_Store  then 1  
                                when nWORK = 0 and gs.store = RTID.Store then 1 
                           else 0 end = 1) 
        loop
          --p_exception(0,'GS.RN-'||GSP.NSUPPLY);
          /* создание нового резерва */
          if sp.prod_cull_cert is null or sACTION = 'TRANSINVDEPT_CANCEL' then
            RSRV_OPEN(nCOMPANY  => NCOMPANY,
                      NPRN      => SP.RN,
                      nRSRV_OLD => GSP.RSRV,	
                      nsupply   => GSP.NSUPPLY,
                      nquant    => GSP.QUANT,
                      nDORDSP   => GSP.DORDSP,
                      nINVDPTSP => GSP.INVDPTSP,
                      nCMPL     => GSP.CMPL,
                      NRSRV_NEW => NRSRV_NEW);
          else
            -- 26/09/2023 марков МВ. сертифицированные ТМЦ
            RSRV_OPEN(nCOMPANY  => NCOMPANY,
                      NPRN      => SP.RN,
                      nRSRV_OLD => GSP.RSRV,	
                      nsupply   => SP.SUPPLY_NEW,
                      nquant    => GSP.QUANT,
                      nDORDSP   => GSP.DORDSP,
                      nINVDPTSP => GSP.INVDPTSP,
                      nCMPL     => GSP.CMPL,
                      NRSRV_NEW => NRSRV_NEW);
          end if;
        end loop; 
         
        /* Подчистка временных таблиц */
        RSRV_TMP_DELETE(NPRN => SP.RN);
      end if;
      
  end loop sp; 
end UDO_P_TRNSNVDPT_TRNSFR_RSRV;
/
