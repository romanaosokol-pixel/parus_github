create or replace procedure USR_P_REP_IOS_UPLOAD1
/*
Процедура к отчёту "Выгрузка по спецификациям приходных ордеров 1"
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
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'номенклатура_код');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'номенклатура_наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'модификация_код');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'модификация_наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'цена');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'средняя цена');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'средняя цена поставщика');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'импорт');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'группа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'поставщик');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'вид_отгрузки');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям приходных ордеров */
  for c in (
            select decode_date( a.indocdate ) as дата
                  ,a.nomen_code             as номенклатура_код
                  ,a.nomen_name             as номенклатура_наименование
                  ,a.modif_code             as модификация_код
                  ,a.modif_name             as модификация_наименование
                  ,sum(a.factquant)         as количество
                  ,round(a.price, 2)        as цена
                  ,round(a.nmid_price, 2)       as средняя_цена
                  ,round(a.nmid_price_supp, 2)  as средняя_цена_поставщика
                  ,a.simport                as импорт
                  ,a.sgroup                 as группа
                  ,a.agnname                as поставщик
                  ,a.sship_type             as вид_отгрузки
              from (
                    select io.indocdate
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
                          ,usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 193749297, sunitcode => 'IncomingOrders', ndocument => io.rn ) as sship_type /* Вид отгрузки */
                      from inorders     io
                          ,inorderspecs ios
                          ,nommodif     nm
                          ,dicnomns     dnm
                          ,agnlist      al
                     where ios.prn         = io.rn
                       and io.docstatus    = 2
                       and io.indocdate    between dFROM and dTO
                       and ios.nommodif    = nm.rn
                       and nm.prn          = dnm.rn
                       and io.contragent   = al.rn
                       and ios.factsumtax != 0
                       and usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1, nrn => io.rn, soperation => 'I') not in ('SUROVEGINA_IO', 'SUROV_RS', 'KHOK'
                                                                                                                                    ,'KORNEEV_OV', 'KOSTIN_AS', 'KUZHAKOVA_VV'
                                                                                                                                    ,'KARCHEVSKAYA_MV', 'SOLODCHENKO_UD')
                   ) a
             group by a.indocdate
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
                     ,a.sship_type
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
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.вид_отгрузки);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по приходным ордерам 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end USR_P_REP_IOS_UPLOAD1;
/
