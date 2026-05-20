create or replace procedure USR_P_REP_TID_UPLOAD1
/*
Процедура к отчёту "Выгрузка по расходным накладным на отпуск в подразделения 1"
18/01/2024 Степанов М.
*/
(
 nIDENT_PROCESS   in number
,sSTORE_FROM_LIST in varchar2
,sSTORE_TO_LIST   in varchar2
,dFROM            in date
,dTO              in date
,nDATE_TYPE       in number default 0 /* Использовать для отбора дату: 0-документа, 1-отработки, 2-перехода в "Скомплектовано", 3-перехода в "ВыданоПроизводство" */
,nPRINT_SPEC      in number default 0 /* Печатать спецификацию */
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

  aStoreFromRNList        udo_tp_numtable := udo_tp_numtable();
  aStoreToRNList          udo_tp_numtable := udo_tp_numtable();
begin
  /* Проверка параметров */
  if nDATE_TYPE not in (0, 1, 2, 3) then
    p_exception(0, 'Неверное значение <%s> параметра <nDATE_TYPE>', nDATE_TYPE);
  end if;

  /* Заполнение списков RN входных параметров */
  if sSTORE_FROM_LIST is not null then
    aStoreFromRNList := usr_pkg_common.get_rn_list_by_code(sSTORE_FROM_LIST, 'AZSAZSLISTMT', 'AZS_NUMBER');
  end if;

  if sSTORE_TO_LIST is not null then
    aStoreToRNList := usr_pkg_common.get_rn_list_by_code(sSTORE_TO_LIST, 'AZSAZSLISTMT', 'AZS_NUMBER');
  end if;

  /* Готовим шаблон */
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  /* Строка с наименованиями колонок */
  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Документ. Тип');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Документ. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Документ. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Автор');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Склад-отправитель');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Склад-получатель');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Состояние');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Состояние. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Статус');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Переведён в "Скомплектовано"');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Переведён в "ВыданоПроизводство"');
  /* если печатать спецификацию, добавляем колонки */
  if nPRINT_SPEC != 0 then
    udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура. Мнемокод"');
    udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура. Наименование"');
  end if;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => '#Комплектуемое изделие');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям заказов подразделений */
  for c in (
            select tid.rn
                  ,dt.doccode, trim(tid.pref)||'-'||trim(tid.numb) as spref_numb, tid.docdate
                  ,ce.sinit_pers
                  ,ds.azs_number    as sstore
                  ,ds_in.azs_number as sin_store
                  ,decode(tid.status, 0, 'Не отработан', 'Отработан') as sstatus
                  ,tid.work_date
                  ,ce.evnstat_code
                  ,ce.dcompl
                  ,ce.dprod
                  ,tids.nomen_code
                  ,tids.nomen_name
                  ,udo_f_transinvdept_main_prod(nrn => tid.rn) as skompl_izd
              from transinvdept tid
                  ,doctypes     dt
                  ,azsazslistmt ds
                  ,azsazslistmt ds_in
                  ,(
                    select (select cast(max(change_date) as date) from clnevnhist where prn = a.rn and event_stat = 40677676) as dCompl
                          ,(select cast(max(change_date) as date) from clnevnhist where prn = a.rn and event_stat = 40677679) as dProd
                          ,nvl(al.agnabbr, a.init_authid) as sinit_pers
                          ,ces.evnstat_code
                          ,a.linked_rn
                      from clnevents    a
                          ,clnpersons   cp
                          ,agnlist      al
                          ,clnevntypsts cets
                          ,clnevnstats  ces
                     where a.init_authid     = cp.pers_authid(+)
                       and cp.pers_agent     = al.rn(+)
                       and a.event_stat      = cets.rn
                       and cets.event_status = ces.rn
                   ) ce
               ,(
                 select b.prn, dnm.nomen_code, dnm.nomen_name
                   from transinvdeptspecs b
                       ,nommodif          nm
                       ,dicnomns          dnm
                  where b.nommodif   = nm.rn
                    and nm.prn       = dnm.rn
                    and nPRINT_SPEC != 0
                ) tids           
             where tid.doctype  = dt.rn
               and tid.store    = ds.rn
               and (ds.rn       in (select column_value from table(cast(aStoreFromRNList as udo_tp_numtable))) or sSTORE_FROM_LIST is null)
               and tid.in_store = ds_in.rn(+)
               and (ds_in.rn    in (select column_value from table(cast(aStoreToRNList   as udo_tp_numtable))) or sSTORE_TO_LIST   is null)
               and (
                    (tid.docdate between dFROM and dTO and nDATE_TYPE = 0)
                   or 
                    (tid.status != 0        and tid.work_date between dFROM and dTO and nDATE_TYPE = 1)
                   or 
                    (ce.dcompl  is not null and ce.dcompl     between dFROM and dTO and nDATE_TYPE = 2)
                   or 
                    (ce.dprod   is not null and ce.dprod      between dFROM and dTO and nDATE_TYPE = 3)
                   )
               and ce.linked_rn = tid.rn
               and tid.rn       = tids.prn(+)
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
                                                    ,psvalue => c.doccode);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.spref_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.docdate, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sinit_pers);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sstore);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sin_store);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sstatus);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.work_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.evnstat_code);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.dcompl, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.dprod, 'dd.mm.yyyy'));
    /* если печатать спецификацию, заполняем колонки */
    if nPRINT_SPEC != 0 then
      nCountColumn := nCountColumn + 1;
      udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                      ,psstyle => null
                                                      ,psvalue => c.nomen_code);
      nCountColumn := nCountColumn + 1;
      udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                      ,psstyle => null
                                                      ,psvalue => c.nomen_name);
    end if;
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.skompl_izd);

    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по расходным накладным на отпуск в подразделения 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end usr_p_rep_tid_upload1;
/
