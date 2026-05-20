create or replace procedure UDO_RP_PRODUCTORD_MAT_REQW (
nCOMPANY  in number,
sUNITCODE in varchar,
--nDOCUMENT in number,
nIDENT in number) is


  ---- Процедура отчета ""
  -- Использовать UDO_V_FINPLAN_ARTS ???
    ---- Переменные отчета
 
  C_SLIST   constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  L_GROUP   constant PKG_STD.TSTRING := 'Line'; -- Наименование бюджета

--
  C_nPP            constant PKG_STD.TSTRING := 'nPP';     
  C_Nomen_Name     constant PKG_STD.TSTRING := 'Nomen_Name';        
  C_QUANT_Treb     constant PKG_STD.TSTRING := 'QUANT_Treb';    
  C_QUANT_Reserv   constant PKG_STD.TSTRING := 'QUANT_Reserv';      
  C_QUANT_work     constant PKG_STD.TSTRING := 'QUANT_work';   
  C_QUANT_Rem      constant PKG_STD.TSTRING := 'QUANT_Rem';   
  C_QUANT_CMPL     constant PKG_STD.TSTRING := 'QUANT_CMPL';   
  C_Sernumb        constant PKG_STD.TSTRING := 'Sernumb';   

  C_Nomen_cod      constant PKG_STD.TSTRING := 'Nomen_cod';   
  C_Prise          constant PKG_STD.TSTRING := 'Prise';   
  C_Summ           constant PKG_STD.TSTRING := 'Summ';   
  C_AGENT_doc      constant PKG_STD.TSTRING := 'AGENT_doc';   
  C_Agent          constant PKG_STD.TSTRING := 'Agent';  
  C_Agent_INN      constant PKG_STD.TSTRING := 'Agent_INN';  
  
  C_Header         constant PKG_STD.TSTRING := 'Header';

  nSTR_GROUP       PKG_STD.tREF;
  nPP_count        PKG_STD.tREF;
  sProduct         PKG_STD.tSTRING;
  slProd           PKG_STD.tSTRING;
  nCount           PKG_STD.tREF;
  nDOC_RN          PKG_STD.tREF;
  tPRODORD         PRODUCTORD%rowtype;
  sMomen_MAIN      PKG_STD.tSTRING;
  nSel_out         PKG_STD.tREF;
  nrn_tmp          PKG_STD.tREF;
  nident_doc       PKG_STD.tREF;
  nQUANT_NEED      PKG_STD.tQUANT;
  nNew_line        number(2);

  procedure Print_agent (
      GOODSparty in PKG_STD.tREF
     ,Print_Line in PKG_STD.tREF
     ,Quant      in PKG_STD.tQUANT
      )
    as
    
    begin

--P_exception(0,'!!! print'||GOODSparty);

      for prn in (
        select nvl(ag.fullname,ag.agnname) as agentname
              ,ag.AGNIDNUMB
              ,trim(ivs.ext_numb)||' от '||to_char(ivs.doc_date,'dd.mm.yyyy') as ext_numb
              ,inor.factsum / inor.factquant as prise_WO
              ,inor.factsumtax / inor.factquant as prise_WITH
              ,gp.sernumb 
        from  GOODSPARTIES      gp,
              GOODSSUPPLY       gs,
              INORDERSPECS      inor,
              DOCLINKS          dl,
              AGNLIST           ag, 
              ININVOICES        ivs
        where gp.rn = GOODSparty
          and gs.prn = gp.rn
          and inor.goodssupply = gs.rn
          and dl.out_document = inor.prn
          and dl.out_unitcode = 'IncomingOrders'
          and dl.in_unitcode = 'IncomingInvoices'
          and dl.in_document = ivs.rn
          and ag.rn = ivs.AGENT
     union 
     /* Для перенесенных остатков */
      select nvl(ag.fullname,ag.agnname) as agentname
            ,ag.AGNIDNUMB
            ,trim(inh.INVDOCNUMB)||' от '||to_char(inh.INVDOCDATE,'dd.mm.yyyy') as ext_numb
            ,inor.factsum / inor.factquant as prise_WO
            ,inor.factsumtax / inor.factquant as prise_WITH
            ,gp.sernumb 
      from  GOODSPARTIES      gp,
           -- GOODSSUPPLY       gs,
            INORDERSPECS      inor,
            AGNLIST           ag, 
            INORDERS          inh
      where gp.rn = GOODSparty
       -- and
        and trim(inor.sernumb) = trim(gp.sernumb)
        and not exists (select null 
                          from DOCLINKS dl 
                         where dl.out_document = inor.prn
                           and dl.out_unitcode = 'IncomingOrders'
                           and dl.in_unitcode = 'IncomingInvoices')
        and inor.prn = inh.rn
        and ag.rn = inh.CONTRAGENT                          
      )loop
--P_exception(0,'!!! print');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Sernumb,   0, Print_Line, prn.sernumb);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_AGENT_doc, 0, Print_Line, prn.ext_numb);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Agent,     0, Print_Line, prn.agentname);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Agent_INN, 0, Print_Line, prn.AGNIDNUMB);      
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Prise,     0, Print_Line, round(prn.prise_WO,2));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Summ,      0, Print_Line, round(Quant * prn.prise_WITH,2));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_work, 0, Print_Line, Quant );

      end loop;    
  end  Print_agent;

begin
 ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_Header); 
  -- Описываем добавляемые строки
  PRSG_EXCEL.LINE_DESCRIBE(L_GROUP);
 

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Nomen_Name);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_QUANT_Treb);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_QUANT_Reserv);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_QUANT_work);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_QUANT_Rem);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_QUANT_CMPL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Nomen_cod);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Sernumb);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Prise);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Summ);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_AGENT_doc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Agent);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_Agent_INN);

  nPP_count := 1;
  for cc in (select * from SELECTLIST sl where sl.ident = nIDENT and rownum = 1 ) loop
    UDO_PKG_MONITOR_SUPPLY.p_recreate(ncompany  => nCOMPANY,
                                      sunitcode => sUNITCODE,
                                      nIDENT=>nIDENT/*Анненко И.С. 29.03.2023*/ --nrn       => cc.document 
                                      ,nsign_plan_src => 1/*Анненко И.С. 28.03.2023*/);
    tPRODORD.rn := cc.document;                                    
  end loop;
  
  select * 
    into tPRODORD
   from PRODUCTORD pr
  where pr.rn = tPRODORD.rn;
  
  select dn.nomen_name
    into sMomen_MAIN
    from PRODUCTORDS prs, DICNOMNS dn
  where prs.prn = tPRODORD.rn
    and dn.rn = prs.nomen;
  sMomen_MAIN := 'Детализация по статье ПКИ для '||sMomen_MAIN;
  
  PRSG_EXCEL.CELL_VALUE_WRITE(C_Header,   sMomen_MAIN);         

  
   for dog in (
     select mn.snomen_name
           ,mn.nquant                                          as QUANT
           ,nvl(mn.nQUANT_RES,0)  + nvl(mn.nQUANT_REST_RES,0)  as QUANT_RES  -- Зарезервированно
           ,nvl(mn.nQUANT_INV,0)  + nvl(mn.nQUANT_REST_INV,0)  as QUANT_INV  -- Выдано
           ,nvl(mn.nQUANT_CMPL,0) + nvl(mn.nQUANT_REST_CMPL,0) as QUANT_CMPL -- Скомплектовано
           ,mn.sei
           ,mn.nrn  
           ,mn.nmodif              
     from UDO_V_MONITOR_SUPPLY      mn
     where  mn.ntype in (0, 1)
   order by mn.snomen_name
        
     ) loop
       nQUANT_NEED := dog.QUANT_INV;
       if dog.QUANT_CMPL > nQUANT_NEED then
         nQUANT_NEED := dog.QUANT_CMPL;
       end if;
       if dog.QUANT_RES > nQUANT_NEED then
         nQUANT_NEED := dog.QUANT_RES;
       end if;
       
       nQUANT_NEED := dog.QUANT - nQUANT_NEED;
       if nQUANT_NEED < 0 then nQUANT_NEED := 0; end if;
     
          nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
          nNew_line:=0;
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,          0, nSTR_GROUP, nPP_count);         
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Nomen_Name,   0, nSTR_GROUP, dog.snomen_name);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_Treb,   0, nSTR_GROUP, dog.QUANT);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_Reserv, 0, nSTR_GROUP, dog.QUANT_RES);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_work,   0, nSTR_GROUP, dog.QUANT_INV);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_CMPL,   0, nSTR_GROUP, dog.QUANT_CMPL);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_Rem,    0, nSTR_GROUP, nQUANT_NEED);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Nomen_cod,    0, nSTR_GROUP, dog.sei );
        
          sProduct := null;
       
   
          PRSG_EXCEL.CELL_VALUE_WRITE(C_Sernumb,    0, nSTR_GROUP, nDOC_RN );
          /* Если есть расходы */
        if dog.QUANT_INV > 0 then
          p_selectlist_genident(nIDENT => nident_doc);
          p_selectlist_insert(nident    => nident_doc,
                              ndocument => dog.nrn,
                              sunitcode => 'GoodsTransInvoicesToDepts', /*Расходные в подразделения */
                              nrn       => nrn_tmp);
          UDO_PKG_MONITOR_SUPPLY.p_calc_doc_list
                           (nident     => nident_doc,                  /*Идентификатор помеченных записей*/
                            sunitcode  => 'GoodsTransInvoicesToDepts', /*Код раздела*/
                            nident_doc => nSel_out);                   /*Идентификатор документов*/
          for doc in (select gp.sernumb
                            ,sum(trs.quant)                        as nQuant
                            ,max(trs.goodsparty)                   as goodsparty
                        from TRANSINVDEPTSPECS trs, 
                             GOODSPARTIES      gp,
                             TRANSINVDEPT      tr,
                             SELECTLIST        sl
                       where trs.prn = sl.document 
                         and sl.ident = nSel_out 
                         and trs.nommodif = dog.nmodif                        
                         and tr.rn = trs.prn
                         and gp.rn = trs.goodsparty
                         group by gp.sernumb 
                      
                         ) loop
            /* Печать новой строки */                         
            if nNew_line = 1 then         
              nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
            end if;
            nNew_line := 1;
            Print_agent(GOODSparty => doc.goodsparty
                       ,Print_Line => nSTR_GROUP
                       ,Quant      => doc.nQuant);
     
        --    PRSG_EXCEL.CELL_VALUE_WRITE(C_Nomen_Name, 0, nSTR_GROUP, doc.sDoc);
          end loop;
          /* Если есть резервы */
        elsif dog.QUANT_CMPL > 0 or dog.quant_res > 0 then
          p_selectlist_genident(nIDENT => nident_doc);
          p_selectlist_insert(nident    => nident_doc,
                              ndocument => dog.nrn,
                              sunitcode => 'DepartmentsOrders',  /*Резервы от Заказа подразделения*/
                              nrn       => nrn_tmp);
          UDO_PKG_MONITOR_SUPPLY.p_calc_doc_list
                           (nident     => nident_doc,                  /*Идентификатор помеченных записей*/
                            sunitcode  => 'DepartmentsOrders',         /*Код раздела*/
                            nident_doc => nSel_out);                   /*Идентификатор документов*/
          for doc in (select gg.sernumb
                            ,sum(trs.main_quant)              as nQuant
                            ,max(gg.goodsparty)               as goodsparty
                        from DEPARTMENTORD   tr,
                             DEPARTMENTORDS  trs, 
                             (select distinct gp.sernumb
                                    ,res.dordsp
                                    ,gp.rn as goodsparty
                                from udo_depords_prf  res,
                                     RESJOURNAL       rsj,
                                     GOODSSUPPLY       gs,
                                     GOODSPARTIES      gp
                               where rsj.rn = res.rsrv
                                 and gs.rn = rsj.supply
                                 and gp.rn = gs.prn
                                 and rsj.res_end_date is null
                                 ) gg,
                             SELECTLIST        sl
                       where tr.rn = trs.prn 
                         and tr.rn = sl.document 
                         and sl.ident = nSel_out 
                         and trs.rn = gg.dordsp
                         and trs.nom_modif = dog.nmodif                       
                         group by gg.sernumb 
                      
                         ) loop
                  if nNew_line = 1 then        
                    nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
                  end if;
                  nNew_line := 1;
                  Print_agent(GOODSparty => doc.goodsparty
                             ,Print_Line => nSTR_GROUP
                             ,Quant      => dog.Quant);
     
           end loop;  
        else    
          /* Подбор Входящего счета*/    
          p_selectlist_genident(nIDENT => nident_doc);
          p_selectlist_insert(nident    => nident_doc,
                              ndocument => dog.nrn,
                              sunitcode => 'PaymentAccountsIn',
                              nrn       => nrn_tmp);
          UDO_PKG_MONITOR_SUPPLY.p_calc_doc_list
                           (nident     => nident_doc,                  /*Идентификатор помеченных записей*/
                            sunitcode  => 'PaymentAccountsIn',         /*Код раздела*/
                            nident_doc => nSel_out);                   /*Идентификатор документов*/
          for doc in (select trim(tr.ext_numb)||' от '||to_char(tr.doc_date,'dd.mm.yyyy')      as ext_numb
                            ,nvl(ag.fullname, ag.agnname)                                      as agentname
                            ,ag.agnidnumb                                                      as AGNIDNUMB
                            ,trs.summ/trs.quant                                                as prise_WO
                            ,trs.summwithnds/trs.quant                                         as prise_WITH
                  
                        from PAYACCIN       tr,
                             PAYACCINSPEC   trs, 
                             AGNLIST           ag, 
                             SELECTLIST        sl
                       where tr.rn = trs.prn 
                         and tr.rn = sl.document 
                         and sl.ident = nSel_out  
                         and ag.rn = tr.supplier                      
                         and trs.nommodif = dog.nmodif                       
                      
                               ) loop
                 if nNew_line = 1 then              
                  nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
                 end if;
                 nNew_line := 1; 
                PRSG_EXCEL.CELL_VALUE_WRITE(C_AGENT_doc, 0, nSTR_GROUP, doc.ext_numb);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_Agent,     0, nSTR_GROUP, doc.agentname);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_Agent_INN, 0, nSTR_GROUP, doc.AGNIDNUMB);      
                PRSG_EXCEL.CELL_VALUE_WRITE(C_Prise,     0, nSTR_GROUP, round(doc.prise_WO,2));
                PRSG_EXCEL.CELL_VALUE_WRITE(C_Summ,      0, nSTR_GROUP, round(dog.Quant * doc.prise_WITH,2));
               -- PRSG_EXCEL.CELL_VALUE_WRITE(C_QUANT_work, 0, nSTR_GROUP, dog.Quant );
               
 
             end loop;          
     
          null;
        end if;
                                                 

          nPP_count := nPP_count +1;

     end loop;
end UDO_RP_PRODUCTORD_MAT_REQW;
/

