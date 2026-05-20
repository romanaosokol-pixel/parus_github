create or replace procedure usr_p_rep_tids_upload1
/*
Процедура к отчёту "Выгрузка по спецификациям расходных накладных в подразделения 1"
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
/*  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство (номер)');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство (дата)');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения (номер)');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения (дата)');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок (тип)');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок (номер)');*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура. Мнемокод');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура. Наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'РН в подразделения из сертификации. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'РН в подразделения из сертификации. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'РН в подразделения из сертификации. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Сертификация. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Сертификация. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Сертификация. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'РН в подразделения на сертификацию. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'РН в подразделения на сертификацию. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'РН в подразделения на сертификацию. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приход из подразделений. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приход из подразделений. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приход из подразделений. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => '#Заказ на производство');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => '#Комплектуемое изделие');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => '#Заводские номера');
  udo_pkg_excel_report_xml.p_row_end;


  for c in (
            select dnm.nomen_code, dnm.nomen_name
                  ,strcombine(trim(tid.doc_pref)  , trim(tid.doc_numb)  , '-') as tid_numb  , tid.doc_date   as tid_doc_date , tid.quant   as tid_quant
                  ,strcombine(trim(pc.doc_pref)   , trim(pc.doc_numb)   , '-') as pc_numb   , pc.doc_date    as pc_doc_date , pc.quant as pc_quant
                  ,strcombine(trim(tid_2.doc_pref), trim(tid_2.doc_numb), '-') as tid_2_numb, tid_2.doc_date as tid_2_doc_date, tid_2.quant as tid_2_quant
                  ,strcombine(trim(io.doc_pref)   , trim(io.doc_numb)   , '-') as io_numb   , io.doc_date    as io_doc_date  , io.quant    as io_quant
                  --,strcombine(trim(iiv.doc_pref)  , trim(iiv.doc_numb)  , '-') as iiv_numb  , iiv.doc_date   as iiv_docdate , iiv.quant   as iiv_quant
                  ,strcombine(trim(pai.doc_pref)  , trim(pai.doc_numb)  , '-') as pai_numb  , pai.doc_date   as pai_doc_date , pai.quant   as pai_quant
                  ,strcombine(trim(ifd.doc_pref)   , trim(ifd.doc_numb)   , '-') as ifd_numb   , ifd.doc_date    as ifd_doc_date  , ifd.quant    as ifd_quant
                  ,udo_f_invdept_depord(nrn => tid.h_rn)          as spo
                  ,udo_f_transinvdept_main_prod(nrn => tid.h_rn)  as scompl_art
                  ,udo_f_transinvdept_main_numb(nrn => tid.h_rn)  as sart_numbers
              from /*(select to_date('01.01.2023', 'dd.mm.yyyy') as bg, to_date('10.01.2025', 'dd.mm.yyyy') as en from dual ) d
                  ,*/nommodif nm
                  ,dicnomns dnm
                  ,(
                    select h.rn as h_rn, h.pref as doc_pref, h.numb as doc_numb, h.docdate as doc_date, h.status, s.rn as s_rn, s.nommodif, s.quant
                      from transinvdept h
                          ,transinvdeptspecs s
                     where s.prn = h.rn
                       and h.status = 1
                   ) tid
                  ,(
                    select h.rn as h_rn, h.doc_pref, h.doc_numb, h.doc_date, s.quant as s_quant, so.rn as so_rn, so.quant as quant, gs.prn as so_goodsparty
                          ,dl.out_document
                      from udo_prod_cull     h
                          ,udo_prod_cull_sp  s
                          ,udo_prod_cull_out so
                          ,goodssupply       gs
                          ,doclinks          dl
                     where s.prn     = h.rn
                       and so.prn    = s.rn
                       and h.crn     = 16117952 /* Сертификация */
                       and so.supply = gs.rn
                       and dl.in_document = so.rn
                   ) pc
                  ,(
                    select h.rn as h_rn, h.pref as doc_pref, h.numb as doc_numb, h.docdate as doc_date, h.status, s.rn as s_rn, s.nommodif, s.quant, s.goodsparty
                          ,dl.out_document
                      from transinvdept      h
                          ,transinvdeptspecs s
                          ,doclinks         dl
                     where s.prn          = h.rn
                       and dl.in_document = h.rn
                   ) tid_2
                  ,(
                    select h.rn as h_rn, h.indocpref as doc_pref, h.indocnumb as doc_numb, h.indocdate as doc_date, h.docstatus as status, s.rn as s_rn, s.nommodif, s.factquant as quant, gs.prn as s_goodsparty
                      from inorders     h
                          ,inorderspecs s
                          ,goodssupply  gs
                     where s.prn         = h.rn
                       and s.goodssupply = gs.rn
                   ) io
                  ,(
                    select h.rn as h_rn, h.doc_pref as doc_pref, h.doc_numb as doc_numb, h.doc_date as doc_date, h.doc_state as status, s.rn as s_rn, s.nommodif, s.quant_fact as quant, gs.prn as s_goodsparty
                      from incomefromdeps     h
                          ,incomefromdepsspec s
                          ,goodssupply        gs
                     where s.prn    = h.rn
                       and s.supply = gs.rn
                   ) ifd
                  ,(
                    select h.rn as h_rn, h.pref as doc_pref, h.numb as doc_numb, h.doc_date as doc_date, h.status as status, s.rn as s_rn, s.modif as nommodif, s.quant as quant
                          ,dl.out_document
                      from ininvoices       h
                          ,ininvoicesspecs  s
                          ,doclinks     dl
                     where s.prn          = h.rn
                       and dl.in_document = h.rn
                   ) iiv
                  ,(
                    select h.rn as h_rn, h.doc_pref as doc_pref, h.doc_numb as doc_numb, h.doc_date as doc_date, h.doc_state as status, s.rn as s_rn, s.nommodif, s.quant as quant
                          --,sce.departmentordsp as sce_dos
                          ,dl.out_document
                      from payaccin         h
                          ,payaccinspec     s
                          /*,payaccinspclc    sc
                          ,payaccinspclc_ex sce*/
                          ,doclinks      dl
                     where s.prn          = h.rn
                       /*and sc.prn         = s.rn(+)
                       and sce.prn        = sc.rn(+)*/
                       and dl.in_document = h.rn
                   ) pai
             where tid.doc_date       between /*d.bg*/dFROM and /*d.en*/dTO
               and nm.rn              = tid.nommodif
               and dnm.rn             = nm.prn
               and pc.out_document    = tid.s_rn
               and tid_2.out_document = pc.h_rn
               and pc.so_goodsparty   = tid_2.goodsparty
               and tid_2.goodsparty   = io.s_goodsparty(+)
               and tid_2.goodsparty   = ifd.s_goodsparty(+)
               and io.h_rn            = iiv.out_document(+)
               and io.nommodif        = iiv.nommodif(+)
               and iiv.h_rn           = pai.out_document(+)
               and iiv.nommodif       = pai.nommodif(+)

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
                                                    ,psvalue => c.tid_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.tid_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.tid_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pc_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.pc_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.pc_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.tid_2_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.tid_2_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.tid_2_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.io_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.io_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.io_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.pai_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.pai_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.ifd_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => decode_date(c.ifd_doc_date));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.ifd_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.spo);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.scompl_art);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.sart_numbers);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по спецификациям расходных накладных в подразделения 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end USR_P_REP_TIDS_UPLOAD1;
/
