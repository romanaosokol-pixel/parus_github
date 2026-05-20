create or replace procedure usr_p_rep_udo_mark_upload1
/*
Процедура к отчёту "Выгрузка показтелей бюджетирования 1"
Раздел "Показатели"
Работает по отмеченным записям
27/11/2024 Степанов М.
*/
(
 nIDENT_PROCESS in number
,nIDENT         in number
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
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Префикс');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Вид движения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Статья');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Лицевой счет движения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Финансовая операция');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Значение');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Валюта');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номер договора');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Контрагент');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Наименование контрагента');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Экономист ПЭО');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Проект');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Лицевой счет затрат');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Подразделение');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Примечание');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Тип платежа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Наименование статьи движения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Статья доходов и расходов для статьи движения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Инструмент оплаты');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => '#Заказчик');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => '#Доходный договор');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Тип показателя');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Наименование раздела источника');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Описатель документа источника (на момент формирования)');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Описатель документа источника (текущий)');
  udo_pkg_excel_report_xml.p_row_end;

  /* По отмеченным показателям */
  for c in (select t.*
                  ,udo_f_mark_doccode(nrn => t.nrn)         as sContracts
                  ,udo_f_mark_economist(nrn => t.nrn)       as sRespEconomist
                  ,udo_f_mark_projcode(nrn => t.nrn)        as sProject
                  ,udo_f_mark_zakazchik(nrn => t.nrn)       as sCustomer
                  ,udo_f_mark_doccode_profit(nrn => t.nrn)  as sDoccode_Profit
              from selectlist   sl
                  ,udo_v_mark   t
             where sl.ident = nIDENT
               and t.nrn    = sl.document)
  loop
    /* Счётчик колонок */
    nCountColumn := 0;
    /* Начало строки */
    udo_pkg_excel_report_xml.p_row_begin;

    /* Колонки */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.smark_numb); /* Номер */

    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.smark_pref); /* Префикс */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sfinflowtype); /* Вид движения */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dmark_date)); /* Дата */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sfpdartcl); /* Статья */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sfaceacc); /* Лицевой счет движения */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sfinoper); /* Финансовая операция */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,pnvalue => c.nval); /* Значение */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.scurrency); /* Валюта */

    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sContracts); /* Валюта */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sagent); /* Контрагент */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sagent_name); /* Наименование контрагента */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sRespEconomist); /* Экономист ПЭО */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sproject); /* Проект */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.scost_faceacc); /* Лицевой счет затрат */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.ssubdiv); /* Подразделение */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.snote); /* Примечание */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => case c.npay_sign when 0 then 'Аванс' when 1 then 'По факту' end); /* Тип платежа */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sfpdartcl_name ); /* Наименование статьи движения */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.siearticle ); /* Статья доходов и расходов для статьи движения */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.spaytool ); /* Инструмент оплаты */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sCustomer ); /* #Заказчик */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sDoccode_Profit ); /* #Доходный договор */

    for c1 in ( select t.stype_attr_name from udo_v_mark_attrs t
                 where t.nprn = c.nrn
                   and t.ntype_attr in (137717) /* Тип показателя */  )
    loop
      nCountColumn := nCountColumn + 1;
      udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                      ,psstyle => null
                                                      ,psvalue => c1.stype_attr_name ); /* Тип показателя */
    end loop;

    for c2 in ( select t.* from udo_v_mark_src t where t.nprn = c.nrn )
    loop
      nCountColumn := nCountColumn + 1;
      udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                      ,psstyle => null
                                                      ,psvalue => c2.ssrc_unit_name ); /* Наименование раздела источника */
      nCountColumn := nCountColumn + 1;
      udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                      ,psstyle => null
                                                      ,psvalue => c2.ssrc_doc_def ); /* Описатель документа источника (на момент формирования) */
      nCountColumn := nCountColumn + 1;
      udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                      ,psstyle => null
                                                      ,psvalue => c2.ssrc_doc_def_cur ); /* Описатель документа источника (текущий) */
    end loop;

    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка показтелей бюджетирования 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end;
/
