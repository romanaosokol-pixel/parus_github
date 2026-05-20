create or replace procedure usr_p_rep_updatelist_by_note
/*
Процедура к отчёту "Выгрузка по журналу регистрации событий по примечанию"
13/05/2025 Степанов М.
*/
(
 nIDENT_PROCESS in number
,dFROM          in date
,dTO            in date
,sNOTE          in varchar2
,nTRADE_DOC_SP  in number
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
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Операция');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Раздел');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Каталог');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Примечание');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Пользователь');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Имя колонки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Значение');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям */
  for c in ( select to_char(a.modifdate, 'DD.MM.YYYY HH24:MI:SS') as modifdate, decode(a.operation, 'I', 'Добавление', 'U', 'Исправление', 'D', 'Удаление') as operation
                   ,f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => a.tablename)) as stable_name
                   ,(select name from acatalog where rn = a.catalog) as scatalog
                   ,a.note
                   ,(select name from userlist where authid = a.authid) as sauthid
                   ,coalesce(get_tabcolumns_note_name(nflag_smart => 1, stable_name => a.tablename, scolumn_name => a.column_name), a.column_name) as column_name
                   ,coalesce(a.str_value, to_char(a.num_value), to_char(a.date_value, 'dd.mm.yyyy')) as sval
               from (
                     select t.modifdate, t.operation, t.note
                           ,t.tablename
                           ,t.catalog
                           ,t.authid
                           ,s.column_name
                           ,s.str_value, s.num_value, s.date_value
                       from updatelist         t
                           ,updatelist_detail  s
                      where s.prn = t.rn
                     union
                     select t.modifdate, t.operation, t.note
                           ,t.tablename
                           ,t.catalog
                           ,t.authid
                           ,s.column_name
                           ,s.str_value, s.num_value, s.date_value
                       from updatelist_arc         t
                           ,updatelist_detail_arc  s
                      where s.prn = t.rn
                     ) a
              where a.modifdate between dFROM and dTO
                and a.str_value||a.num_value||a.date_value is not null
                and ( a.tablename in ('INORDERSPECS', 'INCOMEFROMDEPSSPEC', 'TRANSINVDEPTSPECS', 'TRANSINVCUSTSPECS', 'WROFFACTSPECS', 'RINVTOSUPSPECS')
                     or nvl(nTRADE_DOC_SP, 0) = 0 )
                and a.note like '%'||sNOTE||'%'
            order by a.modifdate )
  loop
    /* Счётчик колонок */
    nCountColumn := 0;

    /* Начало строки */
    udo_pkg_excel_report_xml.p_row_begin;

    /* Колонки */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.modifdate);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.operation);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.stable_name);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.scatalog);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.note);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sauthid);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.column_name);
   nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sval);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по журналу регистрации событий по примечанию.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end;
/
