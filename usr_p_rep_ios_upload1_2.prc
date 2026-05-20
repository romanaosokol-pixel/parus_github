create or replace procedure USR_P_REP_IOS_UPLOAD1_2
/*
Процедура к отчёту "Выгрузка по спецификациям приходных ордеров 1.2"
12/01/2024 Степанов М.
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
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Ответственный');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Инициатор');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Вид отгрузки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура_код');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура_наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Модификация_код');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Модификация_наименование');
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
            select listagg(a.dlo_sul_auth  , ';') within group (order by null) as dlo_sul_auth
                  ,listagg(a.dlo_spers_auth, ';') within group (order by null) as dlo_spers_auth
                  ,listagg(a.pai_sul_auth  , ';') within group (order by null) as pai_sul_auth  
                  ,listagg(a.pai_sce_auth  , ';') within group (order by null) as pai_sce_auth  
                  ,decode_date(a.indocdate)     as дата
                  ,a.sship_type                 as вид_отгрузки
                  ,a.nomen_code                 as номенклатура_код
                  ,a.nomen_name                 as номенклатура_наименование
                  ,a.modif_code                 as модификация_код
                  ,a.modif_name                 as модификация_наименование
                  ,sum(a.factquant)             as количество
                  ,round(a.price, 2)            as цена
                  ,round(a.nmid_price, 2)       as средняя_цена
                  ,round(a.nmid_price_supp, 2)  as средняя_цена_поставщика
                  ,a.simport                    as импорт
                  ,a.sgroup                     as группа
                  ,a.agnname                    as поставщик
                  ,a.sul_auth                   as io_sul_auth
              from (
                    select dlo.sul_auth   as dlo_sul_auth
                          ,dlo.spers_auth as dlo_spers_auth
                          ,pai.sul_auth   as pai_sul_auth
                          ,pai.sce_auth   as pai_sce_auth
                          ,io.indocdate
                          ,dnm.nomen_code
                          ,dnm.nomen_name
                          ,nm.modif_code
                          ,nm.modif_name
                          ,ios.factquant
                          ,ios.factsumtax / ios.factquant as price
                          ,(
                            select sum(s.factsumtax) / sum(s.factquant)
                              from inorderspecs s, inorders h
                             where s.prn        = h.rn
                               and h.docstatus  = 2
                               and s.nommodif   = nm.rn
                               and h.indocdate  between dPRICE_FROM and dPRICE_TO
                               and s.factsumtax != 0
                           ) as nmid_price
                          ,(
                            select sum(s.factsumtax) / sum(s.factquant)
                              from inorderspecs s, inorders h
                             where s.prn        = h.rn
                               and h.docstatus  = 2
                               and s.nommodif   = nm.rn
                               and h.indocdate  between dPRICE_FROM and dPRICE_TO
                               and h.contragent = io.contragent
                               and s.factsumtax != 0
                           ) as nmid_price_supp
                          ,usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 19579336, sunitcode => 'Nomenclator', ndocument => dnm.rn ) as simport
                          ,usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 19579777, sunitcode => 'Nomenclator', ndocument => dnm.rn ) as sgroup
                          ,al.agnname
                          ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1
                                                                         ,nrn        => io.rn
                                                                         ,soperation => 'I' ) as sul_auth
                          ,usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 193749297, sunitcode => 'IncomingOrders', ndocument => io.rn ) as sship_type /* Вид отгрузки */
                      from inorders     io
                      join inorderspecs ios on ios.prn = io.rn
                      join nommodif     nm  on nm.rn   = ios.nommodif
                      join dicnomns     dnm on dnm.rn  = nm.prn
                      join agnlist      al  on al.rn   = io.contragent
                      /* Приходная накладная */
                      left join ( select dl.out_document
                                        ,t.rn
                                        ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1
                                                                                       ,nrn        => t.rn
                                                                                       ,soperation => 'I' ) as sul_auth
                                    from ininvoices t
                                    join doclinks   dl on t.rn = f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                                                               ,sout_unitcode => 'IncomingOrders'
                                                                                               ,nout_document => dl.out_document
                                                                                               ,sin_unitcode  => 'IncomingInvoices' ) ) iiv
                        on iiv.out_document = io.rn
                      /* Вх.счёт */
                      left join ( select dl.out_document
                                        ,( select ce.init_authid from clnevents   ce where ce.linked_rn = t.rn )  as sce_auth
                                        ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1 
                                                                                       ,nrn        => t.rn
                                                                                       ,soperation => 'I' ) as sul_auth
                                    from payaccin         t
                                    join doclinks         dl on t.rn         = f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                                                                             ,sout_unitcode => 'IncomingOrders'
                                                                                                             ,nout_document => dl.out_document
                                                                                                             ,sin_unitcode  => 'PaymentAccountsIn' ) ) pai
                           on pai.out_document = io.rn
                          and pai.sul_auth not in ('SUROVEGINA_IO', 'SUROV_RS', 'KHOK','KORNEEV_OV', 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD')
                          and pai.sce_auth not in ('SUROVEGINA_IO', 'SUROV_RS', 'KHOK','KORNEEV_OV', 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD')
                      /* Заказ поставщику */
                      left join ( select dl.out_document
                                        ,t.crn
                                        ,pkg_document.make_number( ndoc_type => t.ord_doctype
                                                                  ,sdoc_pref => t.ord_pref
                                                                  ,sdoc_numb => t.ord_numb
                                                                  ,ddoc_date => t.ord_date )  as details
                                        ,coalesce( ( select al.pers_authid from agnlist al where al.rn = t.acc_agent )
                                                 , ( select cp.pers_authid 
                                                       from clnpersons cp
                                                       join agnlist    al on al.rn = cp.pers_agent
                                                      where al.rn = t.acc_agent ) ) as spers_auth
                                        ,usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1
                                                                                       ,nrn        => t.rn
                                                                                       ,soperation => 'I' ) as sul_auth
                                    from deliveryord       t
                                    join doclinks          dl on t.rn = f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                                                                      ,sout_unitcode => 'IncomingOrders'
                                                                                                      ,nout_document => dl.out_document
                                                                                                      ,sin_unitcode  => 'DeliveryOrders' ) ) dlo
                           on dlo.out_document = io.rn   
                          and dlo.sul_auth   not in ('SUROVEGINA_IO', 'SUROV_RS', 'KHOK','KORNEEV_OV', 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD')
                          and dlo.spers_auth not in ('SUROVEGINA_IO', 'SUROV_RS', 'KHOK','KORNEEV_OV', 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD')
                     /* Условие */
                     where io.docstatus   = 2
                       and io.indocdate   between dFROM and dTO
                       and ios.factsumtax != 0
                       and usr_pkg_updatelist.updatelist_get_last_authid
                           ( nflagsmart => 1
                            ,nrn        => io.rn
                            ,soperation => 'I' ) not in ('SUROVEGINA_IO', 'SUROV_RS', 'KHOK','KORNEEV_OV', 'KOSTIN_AS', 'KUZHAKOVA_VV', 'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD')
                   ) a
             group by a.indocdate
                     ,a.sship_type
                     ,a.nomen_code
                     ,a.nomen_name
                     ,a.modif_code
                     ,a.modif_name
                     ,a.price
                     ,a.nmid_price
                     ,a.nmid_price_supp
                     ,a.simport
                     ,a.sgroup
                     ,a.agnname
                     ,a.sul_auth
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
                                                    ,psvalue => usr_pkg_common.get_list_distinct(slist => c.dlo_sul_auth));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => usr_pkg_common.get_list_distinct(slist => c.dlo_spers_auth));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => usr_pkg_common.get_list_distinct(slist => c.pai_sul_auth));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => usr_pkg_common.get_list_distinct(slist => c.pai_sce_auth));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => usr_pkg_common.get_list_distinct(slist => c.io_sul_auth));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.дата);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.вид_отгрузки);
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
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по приходным ордерам 1_2.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end USR_P_REP_IOS_UPLOAD1_2;
/
