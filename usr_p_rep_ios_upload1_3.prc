create or replace procedure usr_p_rep_ios_upload1_3
/*
Процедура к отчёту "Выгрузка по спецификациям приходных ордеров 1.3"
31/10/2025 Степанов М.
*/
(
 nIDENT_PROCESS in number
,dFROM          in date
,dTO            in date
,dPRICE_FROM    in date
,dPRICE_TO      in date
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
begin
  /* Готовим шаблон */
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  /* Строка с наименованиями колонок */
  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура код');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Модификация код');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Модификация наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Реквизиты');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Создатель');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Каталог');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт на оплату. Каталог');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходная накладная. Каталог');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Каталог');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Реквизиты');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Вид отгрузки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Цена');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Средняя цена');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Средняя цена поставщика');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Импорт');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Группа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Поставщик');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям приходных ордеров */
  for c in (
            select decode_date( a.indocdate ) as дата
                  ,a.nomen_code             as номенклатура_код
                  ,a.nomen_name             as номенклатура_наименование
                  ,a.modif_code             as модификация_код
                  ,a.modif_name             as модификация_наименование
                  ,a.dlo_details            as Заказ_поставщику_Реквизиты
                  ,a.dlo_sauthid            as Заказ_поставщику_Создатель
                  ,a.dlo_crn                as Заказ_поставщику_Каталог
                  ,a.pai_crn                as Входящий_счёт_на_оплату_Кат
                  ,a.iiv_crn                as Приходная_накладная_Каталог
                  ,a.io_crn                 as Приходный_ордер_Каталог
                  ,a.io_details             as Приходный_ордер_Реквизиты
                  ,a.io_sheep_type          as Вид_отгрузки
                  ,sum(a.factquant)         as количество
                  ,round(a.price, 2)        as цена
                  ,round(a.nmid_price, 2)       as средняя_цена
                  ,round(a.nmid_price_supp, 2)  as средняя_цена_поставщика
                  ,a.simport                as импорт
                  ,a.sgroup                 as группа
                  ,a.agnname                as поставщик
              from (
                    select io.indocdate
                          ,dnm.nomen_code
                          ,dnm.nomen_name
                          ,nm.modif_code
                          ,nm.modif_name
                          ,dlo.details                                                      as dlo_details
                          ,dlo.sauthid                                                      as dlo_sauthid
                          ,usr_pkg_common.get_cat_higher_str( nrn => dlo.crn, nsigns => 1 ) as dlo_crn
                          ,usr_pkg_common.get_cat_higher_str( nrn => pai.crn, nsigns => 1 ) as pai_crn
                          ,usr_pkg_common.get_cat_higher_str( nrn => iiv.crn, nsigns => 1 ) as iiv_crn
                          ,usr_pkg_common.get_cat_higher_str( nrn => io.crn , nsigns => 1 ) as io_crn
                          ,pkg_document.make_number( ndoc_type => io.indoctype
                                                    ,sdoc_pref => io.indocpref
                                                    ,sdoc_numb => io.indocnumb
                                                    ,ddoc_date => io.indocdate )            as io_details
                          ,usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 193749297, ndocument => io.rn ) as io_sheep_type
                          ,ios.factquant
                          ,ios.factsumtax / ios.factquant as price
                          ,(
                            select sum(s.factsumtax) / sum(s.factquant)
                              from inorderspecs s, inorders h
                             where s.prn        = h.rn
                               and h.docstatus  = 2
                               and s.nommodif   = nm.rn
                               and h.indocdate  between dPRICE_FROM and dPRICE_TO
                               and not exists ( select null
                                                  from doclinks    dl
                                                      ,ininvoices  t
                                                 where dl.out_document = h.rn
                                                   and dl.in_document  = t.rn
                                                   and t.crn           = 129481643 ) /* Исключение ордеров, созданных из накладных в каталоге "Кооперация" 40825/19824 */
                           ) as nmid_price
                          ,(
                            select sum(s.factsumtax) / sum(s.factquant)
                              from inorderspecs s, inorders h
                             where s.prn        = h.rn
                               and h.docstatus  = 2
                               and s.nommodif   = nm.rn
                               and h.indocdate  between dPRICE_FROM and dPRICE_TO
                               and h.contragent = io.contragent
                               and not exists ( select null
                                                  from doclinks    dl
                                                      ,ininvoices  t
                                                 where dl.out_document = h.rn
                                                   and dl.in_document  = t.rn
                                                   and t.crn           = 129481643 ) /* Исключение ордеров, созданных из накладных в каталоге "Кооперация" 40825/19824 */
                           ) as nmid_price_supp
                          ,(
                            select str_value
                              from docs_props_vals
                             where docs_prop_rn = 19579336
                               and unit_rn      = dnm.rn
                           ) as simport
                          ,(
                            select str_value
                              from docs_props_vals
                             where docs_prop_rn = 19579777
                               and unit_rn      = dnm.rn
                           ) as sgroup
                          ,al.agnname
                      from inorders     io
                      left join ( select dl.out_document
                                        ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1, nrn => t.rn, soperation => 'I' ) as sauthid
                                        ,t.crn
                                        ,pkg_document.make_number( ndoc_type => t.ord_doctype
                                                                  ,sdoc_pref => t.ord_pref
                                                                  ,sdoc_numb => t.ord_numb
                                                                  ,ddoc_date => t.ord_date )  as details
                                    from deliveryord t
                                    join doclinks dl on t.rn = f_doclinks_link_in_recurs_doc(nflag_mode    => 1
                                                                                            ,sout_unitcode => 'IncomingOrders'
                                                                                            ,nout_document => dl.out_document
                                                                                            ,sin_unitcode  => 'DeliveryOrders' ) ) dlo
                        on dlo.out_document = io.rn                                                                                            
                      left join ( select dl.out_document
                                        ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1, nrn => t.rn, soperation => 'I' ) as sauthid
                                        ,t.crn
                                    from payaccin t
                                    join doclinks dl on t.rn = f_doclinks_link_in_recurs_doc(nflag_mode    => 1
                                                                                            ,sout_unitcode => 'IncomingOrders'
                                                                                            ,nout_document => dl.out_document
                                                                                            ,sin_unitcode  => 'PaymentAccountsIn' ) ) pai
                        on pai.out_document = io.rn                                                                                            
                      left join ( select dl.out_document
                                        ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1, nrn => t.rn, soperation => 'I' ) as sauthid
                                        ,t.crn
                                    from ininvoices t
                                    join doclinks dl on t.rn = f_doclinks_link_in_recurs_doc(nflag_mode    => 1
                                                                                            ,sout_unitcode => 'IncomingOrders'
                                                                                            ,nout_document => dl.out_document
                                                                                            ,sin_unitcode  => 'IncomingInvoices' ) ) iiv
                        on iiv.out_document = io.rn                                                                                            
                      join agnlist      al  on al.rn   = io.contragent
                      join inorderspecs ios on ios.prn = io.rn
                      join nommodif     nm  on nm.rn   = ios.nommodif
                      join dicnomns     dnm on dnm.rn  = nm.prn
                     where io.docstatus  = 2
                       and io.indocdate  between dFROM and dTO
                       and io.crn               not in ( 82692770, 52381262 ) /* Микроэлектроника, СГП */
                       and nvl( pai.crn, -999 ) not in ( 7615025, 12072267 ) /* Кооперация,  Микроэлектроника */
                       and nvl( iiv.crn, -999 ) not in ( 129481643, 82207905, 71679621 ) /* Кооперация, "Микроэлектроника, СГП  */
                       and usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1, nrn => io.rn, soperation => 'I' ) not in ( 'SUROVEGINA_IO', 'SUROV_RS', 'KORNEEV_OV'
                                                                , 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD' ) 
                       and nvl( pai.sauthid, 'null' ) not in ( 'SUROVEGINA_IO', 'SUROV_RS', 'KORNEEV_OV'
                                                                , 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD' ) 
                       and nvl( iiv.sauthid, 'null' ) not in ( 'SUROVEGINA_IO', 'SUROV_RS', 'KORNEEV_OV'
                                                                , 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD' ) 
                       /*and not exists ( select null
                                          from doclinks    dl
                                              ,ininvoices  t
                                         where dl.out_document = io.rn
                                           and dl.in_document  = t.rn
                                           and t.crn           in ( 129481643, 82207905, 71679621 ) ) \* Исключение ордеров, созданных из накладных 
                                                                                                       в каталоге "Кооперация", "Микроэлектроника", СГП  *\*/
                   ) a
             group by a.indocdate
                     ,a.nomen_code
                     ,a.nomen_name
                     ,a.modif_code
                     ,a.modif_name
                     ,a.dlo_details
                     ,a.dlo_sauthid  
                     ,a.dlo_crn      
                     ,a.pai_crn      
                     ,a.iiv_crn      
                     ,a.io_crn       
                     ,a.io_details   
                     ,a.io_sheep_type
                     ,a.price
                     ,a.nmid_price
                     ,a.nmid_price_supp
                     ,a.simport
                     ,a.sgroup
                     ,a.agnname
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
                                                    ,psvalue => c.дата);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.номенклатура_код);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.номенклатура_наименование);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.модификация_код);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.модификация_наименование);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Заказ_поставщику_Реквизиты);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Заказ_поставщику_Создатель);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Заказ_поставщику_Каталог);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Входящий_счёт_на_оплату_Кат);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Приходная_накладная_Каталог);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Приходный_ордер_Каталог);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Приходный_ордер_Реквизиты);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.Вид_отгрузки);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.количество);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatSum
                                                    ,pnvalue => c.цена);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatSum
                                                    ,pnvalue => c.средняя_цена);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatSum
                                                    ,pnvalue => c.средняя_цена_поставщика);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.импорт);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.группа);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.поставщик);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по приходным ордерам 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end USR_P_REP_IOS_UPLOAD1_3;
/
