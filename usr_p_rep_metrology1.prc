create or replace procedure USR_P_REP_METROLOGY1
/*
Процедура к отчёту "Отчёт для отдела метрологии 1"
04/04/2024 Степанов М.
create public synonym usr_p_rep_metrology1 for usr_p_rep_metrology1;
grant execute on usr_p_rep_metrology1 to public; 
*/
(
 nIDENT_PROCESS in number
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

  rMtlgDetRec             usr_pkg_pub_const.tmtlgdetrec;
begin
  /* Готовим шаблон */
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  /* Строка с наименованиями колонок */
  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Серия');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Складская карточка');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Номенклатура');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Заводской номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Инвентарный номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Дата окончания гарантии');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Комплектность');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Номер в госреестре');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Примечание');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Фактическая поверка. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Плановая поверка. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Плановая поверка. Контрагент');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Интервал поверки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Ответственный в бух.учёте');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Основные средства');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'На поверке');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Свидетельство поверки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Производитель');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Дата изготовления');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Руководство');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Характеристики');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'В перечне приборов');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'В перечне индикаторов');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'В перечне приборов длительного хранения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Приходная партия. RN');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Группа номенклатуры');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => sformatstring_head, psvalue => 'Каталог номенклатуры');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям заказов подразделений */
  for c in (
            select gp.rn, gp.sernumb, dnm.nomen_code, dnm.nomen_name, dnm.sgroup_prop, dnm.scatalog_tree
              from goodsparties gp
                  ,nommodif     nm
                  ,(select t.rn, t.crn, t.nomen_code, t.nomen_name
                          ,f_docs_props_get_str_value(nproperty => 19579777, sunitcode => 'Nomenclator', ndocument => t.rn) as sgroup_prop
                          ,usr_pkg_common.get_cat_higher_str(nrn => t.crn, nsigns => 1) as scatalog_tree
                      from dicnomns t
                    ) dnm
                      
             where nm.rn  = gp.nommodif
               and dnm.rn = nm.prn
               and (
                    dnm.crn = 12063756 /* Метрология */
                   or
                    cmp_vc2(dnm.sgroup_prop, 'Метрология') = 1
                   )
               and exists (select null from goodssupply where prn = gp.rn)
               and cmp_num((select sum(restfact) from goodssupply where prn = gp.rn), 0) != 1
             )
  loop
    /* Считывание значений */
    usr_pkg_goodsparties_add.get_vals(ngoodsparties => c.rn, rmtlgdetrec => rMtlgDetRec);

    /* Счётчик колонок */
    nCountColumn := 0;

    /* Начало строки */
    udo_pkg_excel_report_xml.p_row_begin(pnindex => null, pnheight => null, pnautofit => 1);

    /* Колонки */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => c.sernumb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sstore_card);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => c.nomen_name);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sfactory_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sinv_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => to_char(rMtlgDetRec.dexpiry_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sequipment);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sstate_reg_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.snote);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => to_char(rMtlgDetRec.dfact_check_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => to_char(rMtlgDetRec.dplan_check_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.splan_check_agn);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn, psstyle => sformatnumber_sum, pnvalue => rMtlgDetRec.ncheck_interval);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sacc_resp);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sfixed_assets);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.son_verif);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sverif_cert);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sproducer);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => to_char(rMtlgDetRec.dprod_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sSpecs);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sManual);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sListOfDevicesExist);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sListOfIndicatorsExist);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => rMtlgDetRec.sListOfDevicesLSExist);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => c.rn);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => c.sgroup_prop);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn, psstyle => sformatstring, psvalue => c.scatalog_tree);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Перечень метрологических приборов.xls', pnident => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end usr_p_rep_metrology1;
/
