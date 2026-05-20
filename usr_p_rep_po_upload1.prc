create or replace procedure usr_p_rep_po_upload1
/*
Процедура к отчёту "Выгрузка по заказам на производство 1"
25/03/2024 Степанов М.
*/
(
 nIDENT_PROCESS in number
,nDATE_TYPE     in number default 0 /* Использовать для отбора: 0 - дату заказа, 1 - дату добавления заказа, 2 - дату утверждения заказа */
,dFROM          in date
,dTO            in date
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
  /* Проверка параметров */
  if nDATE_TYPE not in (0, 1, 2) then
    p_exception(0, 'Неверное значение <%s> параметра <nDATE_TYPE>', nDATE_TYPE);
  end if;

  /* Готовим шаблон */
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  /* Строка с наименованиями колонок */
  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Статус');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактическая дата добавления');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактически добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактическая дата утверждения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактически утвердил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Дата поставки ОМТС');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактичесая дата установки даты поставки ОМТС');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактически установил дату поставки ОМТС');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактичесая дата формирования заказов подразделений');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План производства. Фактичесая включения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План производства. Фактически включил');
  udo_pkg_excel_report_xml.p_row_end;

  /* Запрос */
  for c in (
            select po.head_numb           as po_head_numb
                  ,po.head_date           as po_head_date
                  ,po.head_state          as po_head_state
                  ,po.head_ins_date       as po_head_ins_date
                  ,po.head_ins_pers       as po_head_ins_pers
                  ,po.head_approve_date   as po_head_approve_date
                  ,po.head_approve_pers   as po_head_approve_pers
                  ,po.head_omts_date      as po_head_omts_date
                  ,po.head_set_omts_date  as po_head_set_omts_date
                  ,po.head_set_omts_pers  as po_head_set_omts_pers
                  ,po.head_fra_exec_date  as po_head_fra_exec_date
                  ,fpp.head_ins_date      as fpp_head_ins_date
                  ,fpp.head_ins_pers      as fpp_head_ins_pers
              from (
                    select h.rn
                          ,trim(h.ord_pref)||'-'||trim(h.ord_numb) as head_numb
                          ,h.ord_date                              as head_date
                          ,b.modifdate                             as head_ins_date
                          ,nvl((select clp.code from clnpersons clp where b.authid = clp.pers_authid), b.authid) as head_ins_pers
                          ,decode(h.ord_state, 0, 'Не утвержден', 1, 'Утвержден', 2, 'Согласование', 3, 'Закрыт', 4, 'Аннулирован', 'Не определён') as head_state
                          ,r.modifdate                                                                                as head_approve_date
                          ,nvl((select clp.code from clnpersons clp where r.authid = clp.pers_authid), r.authid)      as head_approve_pers
                          ,(select date_value from docs_props_vals where docs_prop_rn = 113738795 and unit_rn = h.rn) as head_omts_date
                          ,z.modifdate                                                                                as head_set_omts_date
                          ,nvl((select clp.code from clnpersons clp where z.authid = clp.pers_authid), z.authid)      as head_set_omts_pers
                          ,(
                            select max(
                                       (select trunc(ul.modifdate) as modifdate
                                          from updatelist     ul
                                         where ul.operation = 'I'
                                           and ul.tablern   = dl_2.out_document
                                        union
                                        select trunc(ul.modifdate) as modifdate
                                          from updatelist_arc ul
                                         where ul.operation = 'I'
                                           and ul.tablern   = dl_2.out_document)
                                       ) 
                                from fcprexpact t
                                    ,doclinks   dl
                                    ,doclinks   dl_2
                               where not exists (select null from udo_v_fcprexpactmr_grp s where s.nprn = t.rn and nvl(trunc(s.nqnt_rest, 3), 0) > 0)
                                 and dl.in_document   = h.rn
                                 and dl.out_document  = t.rn
                                 and dl_2.in_document = t.rn
                             )                        as head_fra_exec_date
                      from productord h
                          ,(
                            select ul.tablern, trunc(ul.modifdate) as modifdate, ul.authid
                              from updatelist     ul
                             where ul.operation = 'I'
                            union
                            select ul.tablern, trunc(ul.modifdate) as modifdate, ul.authid
                              from updatelist_arc ul
                             where ul.operation = 'I'
                           ) b
                          ,(
                            select a.tablern, a.authid, trunc(max(a.modifdate)) as modifdate
                              from (
                                    select *
                                      from (
                                            select ul.tablern, ul.authid, ul.modifdate
                                              from updatelist          ul
                                                  ,updatelist_detail   uls
                                             where uls.prn          = ul.rn
                                               and uls.column_name  = 'ORD_STATE'
                                               and uls.num_value    = 1
                                            union
                                            select ul.tablern, ul.authid, ul.modifdate
                                              from updatelist_arc          ul
                                                  ,updatelist_detail_arc   uls
                                             where uls.prn          = ul.rn
                                               and uls.column_name  = 'ORD_STATE'
                                               and uls.num_value    = 1
                                            order by modifdate desc
                                           ) e
                                   ) a
                             group by a.tablern, a.authid
                           ) r
                          ,(
                            select a.tablern, a.authid, trunc(max(a.modifdate)) as modifdate
                              from (
                                    select *
                                      from (
                                            select ul.tablern, ul.authid, ul.modifdate
                                              from updatelist          ul
                                                  ,updatelist_detail   uls
                                             where uls.prn          = ul.rn
                                               and uls.column_name  = 'Дата_ОМТС'
                                            union
                                            select ul.tablern, ul.authid, ul.modifdate
                                              from updatelist_arc          ul
                                                  ,updatelist_detail_arc   uls
                                             where uls.prn          = ul.rn
                                               and uls.column_name  = 'Дата_ОМТС'
                                            order by modifdate desc
                                           ) e
                                   ) a
                             group by a.tablern, a.authid
                           ) z
                    where h.rn = b.tablern(+)
                      and h.rn = r.tablern(+)
                      and h.rn = z.tablern(+)
                   ) po
                  ,(
                    select pos.prn
                          ,b.modifdate                              as head_ins_date
                          ,nvl((select clp.code from clnpersons clp where b.authid = clp.pers_authid), b.authid) as head_ins_pers
                      from productords  pos
                          ,doclinks     dl
                          ,fcprodplansp s
                          ,(
                            select ul.tablern, trunc(ul.modifdate) as modifdate, ul.authid
                              from updatelist     ul
                             where ul.operation = 'I'
                            union
                            select ul.tablern, trunc(ul.modifdate) as modifdate, ul.authid
                              from updatelist_arc ul
                             where ul.operation = 'I'
                           ) b
                     where pos.rn          = dl.in_document
                       and dl.out_document = s.rn
                       and s.rn            = b.tablern(+)
                   ) fpp
                  /*,(select to_date('01.01.2023', 'dd.mm.yyyy') as bg, to_date('01.01.2025', 'dd.mm.yyyy') as en from dual ) d*/
             where (
                    (po.head_date between dFROM -- d.bg
                                      and dTO --  d.en
                     and nDATE_TYPE  = 0)
                    or
                    (nvl(po.head_ins_date, po.head_date) between dFROM -- d.bg
                                                             and dTO --  d.en
                     and nDATE_TYPE  = 1)
                    or
                    (nvl(po.head_approve_date, po.head_date) between dFROM -- d.bg
                                                                 and dTO --  d.en
                     and nDATE_TYPE  = 2)
                   )
               and po.rn = fpp.prn
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
                                                    ,psvalue => c.po_head_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.po_head_state);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_ins_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.po_head_ins_pers);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_approve_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.po_head_approve_pers);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_omts_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_set_omts_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.po_head_set_omts_pers);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_fra_exec_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.fpp_head_ins_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.fpp_head_ins_pers);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по заказам на производство 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end usr_p_rep_po_upload1;
/
