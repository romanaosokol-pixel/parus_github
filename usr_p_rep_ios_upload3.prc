create or replace procedure usr_p_rep_ios_upload3
/*
Процедура к отчёту "Выгрузка по спецификациям приходных ордеров 3"
24/04/2025 Степанов М.
*/
(
 nIDENT_PROCESS in number
,dFROM          in date
,dTO            in date
,dCOMPARE_FROM  in date
,dCOMPARE_TO    in date
)
as
  nCountColumn number;

  sformatstring_title     varchar2(20) := 's69';
  sformatstring_title_val varchar2(20) := 's72';
  sformatnumber_title_val varchar2(20) := 's71';
  sformatstring           varchar2(20) := 's65';

  sformatstring_head      varchar2(20) := 's62';
  sformatnumber_quant     varchar2(20) := 's66';
  sformatnumber_sum       varchar2(20) := 's67';

  sFormatQuant            varchar2(20) := 'nQuant';
  sFormatSum              varchar2(20) := 'nSum';
  
  function IOS_GET_SHIP_DAYS
  (
   nMODE        in number
  ,nMODIF       in number
  ,nAGENT       in number
  )
  return number
  as
    nDays_Mid   pkg_std.tquant; 
    nDays_Min   pkg_std.tquant;
  begin
    begin
      select sum(a.ndays) / max(a.ncount), min(a.ndays)
        into nDays_Mid                   , nDays_Min
        from ( select io.indocdate - coalesce(q.pai_Pay_Date, q.doc_date) as ndays, count(*) over() as ncount
                 from inorderspecs ios
                     ,inorders     io
                     ,( select dl_1.out_document, pais.nommodif, pai.doc_date
                              ,( select min(b.pay_date)
                                   from doclinks a
                                       ,paynotes b
                                  where a.in_document  = pais.prn
                                    and a.out_document = b.rn 
                                    and b.signplan     = 0 ) as pai_Pay_Date
                          from doclinks     dl_1
                              ,doclinks     dl_2
                              ,payaccinspec pais
                              ,payaccin     pai
                         where dl_1.in_unitcode  = 'IncomingInvoices'
                           and dl_2.out_document = dl_1.in_document
                           and dl_2.in_unitcode  = 'PaymentAccountsIn'
                           and dl_2.in_document  = pais.prn
                           and pais.prn          = pai.rn
                      ) q
                where io.rn           = ios.prn
                  and io.indocdate    between dCOMPARE_FROM and dCOMPARE_TO
                  and io.docstatus    != 0 
                  and (io.contragent  = nAGENT or nAGENT is null ) 
                  and ios.nommodif    = nMODIF
                  and q.out_document  = io.rn(+)
                  and q.nommodif      = ios.nommodif(+)
                  ) a
      ;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nMODIF
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1,stable_name => 'TRANSINVDEPT')));
    end;
    
    return case nMODE
             when 0 then nDays_Mid
             else nDays_Min
           end; 
  end;

begin
  /* Готовим шаблон */
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  /* Строка с наименованиями колонок */
  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура, мнемокод');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура, наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Модификация, мнемокод');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Модификация, наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Импорт');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Группа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Контрагент');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Дата добавления');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Дата утверждения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику (спецификация). Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Дата платежа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Контрагент');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Контрагент. Анализ');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт (спецификация). Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт (спецификация). Дата поставки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт (спецификация). Дней поставки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходная накладная. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходная накладная. Дата документа поставщика');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата поставки. План');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер (спецификация). Поставлено');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Средний срок поставки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Минимальный срок поставки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Средний срок поставки по поставщику');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Минимальный срок поставки по поставщику');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям */
  for c in ( with wquery as ( select dnm.nomen_code
                                    ,dnm.nomen_name
                                    ,nm.modif_code
                                    ,nm.modif_name
                                    ,( select str_value from docs_props_vals where docs_prop_rn = 19579336 and unit_rn = dnm.rn ) as sImport
                                    ,( select str_value from docs_props_vals where docs_prop_rn = 19579777 and unit_rn = dnm.rn ) as sGroup
                                    ,dlo.snumb        as dlo_snumb
                                    ,dlo.ddate        as dlo_ddate
                                    ,dlo.sAgent       as dlo_sAgent
                                    ,dlo.sUL_Date     as dlo_sUL_Date
                                    ,dlo.dState_Date  as dlo_dState_Date
                                    ,dlo.sul_auth     as dlo_sul_auth
                                    ,dlo.spers_auth   as dlo_spers_auth
                                    ,( select sum(t.main_quant)
                                         from deliveryords t
                                        where t.prn       = dlo.rn
                                          and t.nomen     = dnm.rn
                                          and t.nom_modif = nm.rn ) as dlo_Quant
                                    ,pai.snumb        as pai_snumb
                                    ,pai.ddate        as pai_ddate
                                    ,pai.dPay_Date    as pai_dPay_Date
                                    ,pai.sAgent       as pai_sAgent
                                    ,pai.sul_auth     as pai_sUL_Auth
                                    ,pai.sce_auth     as pai_sCE_Auth
                                    ,( select sum( t.quant)
                                         from payaccinspec t
                                        where t.prn       = pai.rn
                                          and t.nomen     = dnm.rn
                                          and t.nommodif  = nm.rn 
                                          and rownum      = 1) as pai_quant
                                    ,( select ( select date_value from docs_props_vals where docs_prop_rn = 20817235 and unit_rn = t.rn )
                                         from payaccinspec t
                                        where t.prn       = pai.rn
                                          and t.nomen     = dnm.rn
                                          and t.nommodif  = nm.rn 
                                          and rownum      = 1) as pai_dShipDate
                                    ,( select ( select num_value from docs_props_vals where docs_prop_rn = 7551156  and unit_rn = t.rn )
                                         from payaccinspec t
                                        where t.prn       = pai.rn
                                          and t.nomen     = dnm.rn
                                          and t.nommodif  = nm.rn 
                                          and rownum      = 1) as pai_nShipDays
                                    ,pkg_document.make_number(sdoc_pref => io.indocpref, sdoc_numb => io.indocnumb)   as sNumb
                                    ,io.indocdate
                                    ,io.work_date
                                    ,iiv.doc_date as iiv_doc_date
                                    ,iiv.ext_date as iiv_ext_date
                                    ,ios.factquant
                                    ,nm.rn as nm_rn
                                    ,io.contragent
                                from inorderspecs ios
                                    ,inorders     io
                                    ,azsazslistmt ds
                                    ,nommodif     nm
                                    ,dicnomns     dnm
                                    ,( select dl.out_document, t.rn, t.doc_date, t.ext_date
                                         from doclinks   dl
                                             ,ininvoices t
                                        where dl.in_document = t.rn ) iiv
                                    ,( select t.rn
                                             ,dl.out_document
                                             ,pkg_document.make_number(sdoc_pref => t.doc_pref, sdoc_numb => t.doc_numb)                      as sNumb
                                             ,t.doc_date                                                                                      as dDate
                                             ,usr_pkg_updatelist.updatelist_get_last_authid(nflagsmart => 1, nrn => t.rn, soperation => 'I')  as sUL_Auth
                                             ,ce.init_authid                                                                                  as sCE_Auth
                                             ,( select min(b.pay_date)
                                                  from doclinks a
                                                      ,paynotes b
                                                 where a.in_document  = t.rn
                                                   and a.out_document = b.rn 
                                                   and b.signplan     = 0 )                                                                   as dPay_Date
                                             ,al.agnabbr                                                                                      as sAgent
                                         from doclinks   dl
                                             ,payaccin   t
                                             ,clnevents  ce
                                             ,agnlist    al
                                        where dl.in_document = t.rn
                                          and t.rn           = ce.linked_rn(+)
                                          and al.rn          = t.supplier(+) 
                                     ) pai
                                    ,( select t.rn
                                             ,dl.out_document
                                             ,pkg_document.make_number(sdoc_pref => t.ord_pref, sdoc_numb => t.ord_numb)                     as sNumb
                                             ,t.ord_date                                                                                     as dDate
                                             ,usr_pkg_updatelist.updatelist_get_last_authid(nflagsmart => 1, nrn => t.rn, soperation => 'I') as sUL_Auth
                                             ,cp.pers_authid                                                                                 as sPers_Auth
                                             ,al2.agnabbr                                                                                    as sAgent
                                             ,usr_pkg_updatelist.updatelist_get_last_date(nflagsmart => 1, nrn => t.rn, soperation => 'I')   as sUL_Date
                                             ,t.state_date                                                                                   as dState_Date
                                         from doclinks     dl
                                             ,deliveryord  t
                                             ,agnlist      al
                                             ,clnpersons   cp
                                             ,agnlist      al2
                                        where dl.in_document = t.rn
                                          and t.acc_agent    = al.rn(+)
                                          and al.rn          = cp.pers_agent(+)
                                          and al2.rn         = t.agent(+) ) dlo
                               where io.rn        = ios.prn
                                 and io.docstatus = 2
                                 and io.store     = ds.rn
                                 and ios.nommodif = nm.rn
                                 and nm.prn       = dnm.rn
                                 and io.rn        = iiv.out_document(+)
                                 and iiv.rn       = pai.out_document(+)
                                 and pai.rn       = dlo.out_document(+) )
           select w.*
                 ,coalesce(w.pai_dShipDate, w.pai_dPay_Date + w.pai_nShipDays)  as dPlanShipDate
             from wquery w
            where w.indocdate between dFROM and dTO 
--and w.modif_code = '00000000989'
          )
  loop
    /* Счётчик колонок */
    nCountColumn := 0;

    /* Начало строки */
    udo_pkg_excel_report_xml.p_row_begin;

    /* Колонки */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.nomen_code);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.nomen_name);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.modif_code);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.modif_name);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sImport);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sGroup);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_snumb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dlo_ddate));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_sAgent);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dlo_sUL_Date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dlo_dState_Date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_sul_auth);
/*    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_spers_auth);*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => c.dlo_Quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_snumb);                   /* 'Входящий счёт. Номер' */
    nCountColumn := nCountColumn + 1;                                                                 
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn                          
                                                    ,psstyle => null                                  
                                                    ,psvalue => decode_date(c.pai_ddate));      /* 'Входящий счёт. Дата' */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.pai_dPay_Date));  /* 'Входящий счёт. Дата платежа' */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_sAgent);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_sUL_Auth);
/*    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_sCE_Auth);*/
    /* Контрагент. Анализ */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => coalesce(c.pai_sAgent, c.dlo_sAgent));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => c.pai_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.pai_dShipDate));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => c.pai_nShipDays);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sNumb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.indocdate));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.iiv_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.iiv_ext_date));
    /* Дата поставки. План */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dPlanShipDate));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => c.factquant);

/*    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dPlanShipDate));*/
/*    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dFactShipDate));*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => ios_get_ship_days( nmode => 0, nmodif => c.nm_rn, nagent  => null ));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => ios_get_ship_days( nmode => 1, nmodif => c.nm_rn, nagent  => null ));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => ios_get_ship_days( nmode => 0, nmodif => c.nm_rn, nagent  => c.contragent ));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => ios_get_ship_days( nmode => 1, nmodif => c.nm_rn, nagent  => c.contragent ));

    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по спецификациям приходных ордеров 3.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end;
/
