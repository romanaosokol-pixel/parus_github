create or replace procedure usr_p_rep_ios_upload2_2
/*
Процедура к отчёту "Выгрузка по спецификациям приходных ордеров 2.2"
22/01/2024 Степанов М.
*/
(
 nIDENT_PROCESS in number
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
  /* Готовим шаблон */
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  /* Строка с наименованиями колонок */
  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Ответственный');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Инициатор');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Придный ордер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Придный ордер. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Придный ордер. Добавил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Склад');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура, мнемокод');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура, наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Импорт');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Группа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Партия');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Серия');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата документа передачи на склад');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата отработки передачи на склад');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Примечания входного контроля');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям */
  for c in (
            select dlo.snumb        as dlo_snumb
                  ,dlo.sul_auth     as dlo_sul_auth
                  ,dlo.spers_auth   as dlo_spers_auth
                  ,pai.snumb        as pai_snumb
                  ,pai.sul_auth     as pai_sul_auth
                  ,pai.sce_auth     as pai_sce_auth
                  ,pkg_document.make_number(io.indoctype, io.indocpref, io.indocnumb, io.indocdate) as io
                  ,io.indocdate
                  ,usr_pkg_updatelist.updatelist_get_last_authid(nflagsmart => 1, nrn => io.rn, soperation => 'I') as sio_ul_auth
                  ,ds.azs_number
                  ,dnm.nomen_code
                  ,dnm.nomen_name
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
                  ,party.icd_code
                  ,party.sernumb
                  ,ios.factquant
                  ,(
                    select min(t.docdate)
                      from storeoperjourn t
                          ,goodssupply    gs
                          ,azsazslistmt   ds
                     where t.goodssupply = gs.rn
                       and gs.prn        = party.prn
                       and gs.rn        != party.rn
                       and t.oper_type   = 1
                       and gs.store      = ds.rn
                       and (
                            ds.crn in (
                                       12152556 /* ДСЕ */
                                      ,12047487 /* СГП */
                                      ,12374862 /* СГП */
                                      ,11924895 /* ЭРИ */
                                      ,69976211 /* СЗ */
                                      )
                           or ds.rn in (
                                        89531489 /* Склад средств измер. */
                                       ,20300310 /* ВремПеремещение */
                                       ,32814621 /* Микроэлектроника */
                                       )
                           )
                   ) as dout
                  ,(
                    select min(t.operdate)
                      from storeoperjourn t
                          ,goodssupply    gs
                          ,azsazslistmt   ds
                     where t.goodssupply = gs.rn
                       and gs.prn        = party.prn
                       and gs.rn        != party.rn
                       and t.oper_type   = 1
                       and gs.store      = ds.rn
                       and (
                            ds.crn in (
                                       12152556 /* ДСЕ */
                                      ,12047487 /* СГП */
                                      ,12374862 /* СГП */
                                      ,11924895 /* ЭРИ */
                                      ,69976211 /* СЗ */
                                      )
                           or ds.rn in (
                                        89531489 /* Склад средств измер. */
                                       ,20300310 /* ВремПеремещение */
                                       ,32814621 /* Микроэлектроника */
                                       )
                           )
                   ) as dwork
                  ,party.pco_note
              from inorderspecs ios
                  ,inorders     io
                  ,azsazslistmt ds
                  ,nommodif     nm
                  ,dicnomns     dnm
                  ,(
                    select s.rn, s.prn, h.sernumb, icd.code as icd_code
                          ,(
                            select listagg(a.note, ',') within group (order by a.note)
                              from (
                                    select distinct cot.supply, cot.note
                                      from udo_prod_cull_out cot
                                   ) a
                             where a.supply = s.rn
                           ) as pco_note
                      from goodssupply  s
                          ,goodsparties h
                          ,incomdoc     icd
                     where s.prn    = h.rn
                       and h.indoc  = icd.rn
                   ) party
                  ,( select dl.out_document, t.rn
                       from doclinks   dl
                           ,ininvoices t
                      where dl.in_document = t.rn ) iiv
                  ,( select dl.out_document, t.*
                           ,pkg_document.make_number(t.doc_type, t.doc_pref, t.doc_numb, t.doc_date) as snumb
                           ,usr_pkg_updatelist.updatelist_get_last_authid(nflagsmart => 1, nrn => t.rn, soperation => 'I') as sul_auth
                           ,ce.init_authid as sce_auth
                       from doclinks   dl
                           ,payaccin   t
                           ,clnevents  ce
                      where dl.in_document = t.rn
                        and t.rn           = ce.linked_rn(+) ) pai
                  ,( select dl.out_document
                           ,pkg_document.make_number(t.ord_doctype, t.ord_pref, t.ord_numb, t.ord_date)                    as snumb
                           ,usr_pkg_updatelist.updatelist_get_last_authid(nflagsmart => 1, nrn => t.rn, soperation => 'I') as sul_auth
                           ,cp.pers_authid                                                                                 as spers_auth
                       from doclinks     dl
                           ,deliveryord  t
                           ,agnlist      al
                           ,clnpersons   cp
                      where dl.in_document = t.rn
                        and t.acc_agent    = al.rn(+)
                        and al.rn          = cp.pers_agent(+) ) dlo
             where io.rn  = ios.prn
               and io.indocdate between dFROM and dTO
               and io.docstatus = 2
               and io.store     = ds.rn
               and ds.crn not in (
                                  12152556 /* ДСЕ */
                                 ,12047487 /* СГП */
                                 ,12374862 /* СГП */
                                 ,11924895 /* ЭРИ */
                                 ,69976211 /* СЗ */
                                 )
               and ds.rn not in (
                                 89531489 /* Склад средств измер. */
                                ,20300310 /* ВремПеремещение */
                                ,32814621 /* Микроэлектроника */
                                )

               and ios.nommodif = nm.rn
               and nm.prn       = dnm.rn
               and ios.goodssupply  = party.rn(+)
               and io.rn            = iiv.out_document(+)
               and iiv.rn           = pai.out_document(+)
               and pai.rn           = dlo.out_document(+)
--and ios.rn = 82090274
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
                                                    ,psvalue => c.dlo_snumb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_sul_auth);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_spers_auth);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_snumb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_sul_auth);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_sce_auth);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.io);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.indocdate));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sio_ul_auth);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.azs_number);
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
                                                    ,psvalue => c.simport);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sgroup);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.icd_code);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sernumb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.factquant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dout));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.dwork));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pco_note);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по спецификациям приходных ордеров 2_2.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end usr_p_rep_ios_upload2_2;
/
