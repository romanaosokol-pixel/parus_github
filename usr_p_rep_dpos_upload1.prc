create or replace procedure usr_p_rep_dpos_upload1
/*
Процедура к отчёту "Выгрузка по спецификациям заказов подразделений 1"
18/01/2024 Степанов М.
*/
(
 nIDENT_PROCESS in number
,nDATE_TYPE     in number default 0 /* Использовать для отбора: 0 - дату исполнения - 91 день, 1 - дату заказа подразделения, 2 - дату утверждения заказа на производство */
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
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата исполнения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Номер заявки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактическая дата утверждения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ на производство. Фактически утвердил');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура, мнемокод');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номенклатура, наименование');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Состояние');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Зарезервировано');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Передано в производство');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Исполнено фактически');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Получено по ПО');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Дата изменения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Дата добавления');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ подразделения. Дата аннулирования');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок. Тип');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок. Дата включения');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План закупок. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Тип');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Заказ поставщику. Контрагент');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Тип');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Количество');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Дней поставки');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Контрагент');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Входящий счёт. Дата платежа');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Номер');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Дата');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Приходный ордер. Количество');
  udo_pkg_excel_report_xml.p_row_end;

  /* По спецификациям заказов подразделений */
  for c in (
            select nvl(po.release_date, dpo.release_date)  as release_date 
                  ,po.head_numb           as po_head_numb
                  ,po.head_date           as po_head_date
                  ,po.head_1C_ord         as po_head_1C_ord
                  ,po.head_state_date     as po_head_state_date
                  ,po.head_state_spers    as po_head_state_spers
                  ,dnm.nomen_code     
                  ,dnm.nomen_name
                  ,trim(dpo.ord_pref)||'-'||trim(dpo.ord_numb)                                        as dpo_head_numb
                  ,dpo.ord_date                                                                       as dpo_head_date
                  ,usr_pkg_departmentord.departmentord_get_status_name(nord_state => dpo.ord_state)   as dpo_state
                  ,dpos.main_quant                                                                    as dpo_quant
                  ,udo_f_prodordsp_reserv(nrn => dpos.rn, ncompany => dpos.company)                                              as dpo_res_quant
                  ,udo_f_prodordsp_transinv(nrn => dpos.rn, ncompany => dpos.company)                                            as dpo_prod_quant
                  ,f_departmentordps_get_nparam(nflag_smart => 1, nprn => dpos.rn, nflag_mode => 0, sparname => 'P_FACTM_QUANT') as nexec_fact
                  ,udo_f_prodordsp_inord(nrn => dpos.rn, nnom_modif => dpos.nom_modif, ncompany => dpos.company)                 as nreciev_IO
                  ,bpd.date_0         as bpd_date_0
                  ,bpd.date_1         as bpd_date_1
                  ,bpd.date_2         as bpd_date_2
                  ,bp.head_type       as bp_head_type
                  ,bp.head_numb       as bp_head_numb 
                  ,bp.head_date       as bp_head_date 
                  ,bp.incl_date       as bp_incl_date
                  ,bp.quant           as bp_quant    
                  ,pai.head_type      as pai_head_type
                  ,pai.head_numb      as pai_head_numb
                  ,pai.head_date      as pai_head_date 
                  ,pai.quant          as pai_quant  
                  ,pai.ndelivdays     as pai_ndelivdays
                  ,pai.agnname        as pai_agnname
                  ,(
                    select min(pn.pay_date) 
                      from doclinks dl 
                          ,paynotes pn
                     where dl.in_document  = pai.h_rn
                       and dl.out_document = pn.rn
                       and pn.signplan     = 0
                   )                  as pai_pay_date 
                  ,dlo.head_type      as dlo_head_type
                  ,dlo.head_numb      as dlo_head_numb
                  ,dlo.head_date      as dlo_head_date 
                  ,dlo.agnname        as dlo_agnname
                  ,iiv.head_numb      as iiv_head_numb
                  ,iiv.head_date      as iiv_head_date 
                  ,iiv.quant          as iiv_quant       
                  ,io.head_numb       as io_head_numb 
                  ,io.head_date       as io_head_date 
                  ,io.quant           as io_quant      
              from departmentords dpos
                  ,departmentord  dpo
                  ,dicnomns       dnm
                  /* максимальные даты изменения, добавления, аннулирования строки плана */
                  ,(
                    select b.deptordsp, max(b.d0) as date_0, max(b.d1) as date_1, max(b.d2) as date_2
                      from (
                            select sr.deptordsp
                                  ,decode(sr.kind, 0, h.work_date) as d0
                                  ,decode(sr.kind, 1, h.work_date) as d1
                                  ,decode(sr.kind, 2, h.work_date) as d2
                              from (
                                    select t.*, (
                                                 case when t.quantplan_bef is null then 1
                                                      when t.quantplan_aft = 0     then 2
                                                 else 0
                                                 end
                                                ) as kind
                                      from buyplandirspref t
                                   ) sr
                                  ,buyplandirsp     s
                                  ,buyplandir       h
                             where s.rn = sr.prn
                               and h.rn = s.prn
                           ) b  
                    group by b.deptordsp
                   ) bpd
                  ,(
                    select dl_1.out_document                       as dl_1_out_document
                          ,h.rn                                    as head_rn
                          ,trim(h.ord_pref)||'-'||trim(h.ord_numb) as head_numb
                          ,h.ord_date                              as head_date
                          ,(select dpv.str_value from docs_props_vals dpv where dpv.docs_prop_rn = 8027721 and dpv.unit_rn = h.rn) as head_1C_ord
                          /* максимальная дата утверждения и сотрудник по журналу регистраций */
                          ,nvl((select clp.code from clnpersons clp where r.authid = clp.pers_authid), r.authid)  as head_state_spers
                          ,trunc(r.reg_date)                                                                      as head_state_date 
                          ,nvl(
                               (select dpv.date_value from docs_props_vals dpv where dpv.docs_prop_rn = 113738795 and dpv.unit_rn = h.rn)
                              ,h.release_date
                              ) - 91          as release_date
                      from doclinks   dl_1
                          ,doclinks   dl_2
                          ,productord h
                          ,(
                            select a.tablern, a.authid, max(a.reg_date) as reg_date
                              from (
                                    select *
                                      from (
                                            select ul.tablern, ul.authid, uls.reg_date
                                              from updatelist          ul
                                                  ,updatelist_detail   uls
                                             where uls.prn          = ul.rn
                                               and uls.column_name  = 'ORD_STATE'
                                               and uls.num_value    = 1
                                            union
                                            select ula.tablern, ula.authid, ulas.reg_date
                                              from updatelist_arc          ula
                                                  ,updatelist_detail_arc   ulas
                                             where ula.rn            = ulas.prn 
                                               and ulas.column_name  = 'ORD_STATE'
                                               and ulas.num_value    = 1
                                            order by reg_date desc
                                           ) e
                                   ) a
                             group by a.tablern, a.authid
                           ) r
                     where dl_1.in_unitcode = 'CostProductExpenseActs'
                       and dl_1.in_document = dl_2.out_document
                       and dl_2.in_unitcode = 'ProductionOrders'
                       and dl_2.in_document = h.rn
                       and h.rn             = r.tablern(+)
                   ) po
                  ,(
                    select dl.in_document                   as dl_in_document
                          ,s.nomen
                          ,substr(      get_doctypes_code_id(nflag_smart => 1, nrn => h.doctype)
                                 ,instr(get_doctypes_code_id(nflag_smart => 1, nrn => h.doctype), '_') +1
                                 )                          as head_type
                          ,trim(h.pref)||'-'||trim(h.numb)  as head_numb
                          ,h.docdate                        as head_date
                          ,s.incl_date                      as incl_date
                          ,pd.prn                           as pd_prn
                          ,sum(pd.actm_quant)               as quant
                      from doclinks         dl
                          ,buyplane         h
                          ,buyplanesp       s
                          ,buyplanespref    p
                          ,departmentordps  pd
                     where dl.out_document = s.rn
                       and s.prn           = h.rn
                       and p.prn           = s.rn
                       and p.deptordsp     = pd.prn 
                       and s.quant_plan   != 0 
                    group by dl.in_document
                            ,s.nomen
                            ,pd.prn
                            ,get_doctypes_code_id(nflag_smart => 1, nrn => h.doctype)
                            ,trim(h.pref)||'-'||trim(h.numb)
                            ,h.docdate
                            ,s.incl_date
                   ) bp
                  ,(
                    select sce.departmentordsp
                          ,h.rn                                    as h_rn
                          ,s.nomen
                          ,sc.faceaccount
                          ,get_doctypes_code_id(nflag_smart => 1, nrn => h.doc_type) as head_type
                          ,trim(h.doc_pref)||'-'||trim(h.doc_numb) as head_numb
                          ,h.doc_date                              as head_date
                          ,sum(sce.quant)                          as quant
                          ,max((select dpv.num_value from docs_props_vals dpv where dpv.docs_prop_rn = 7551156 and dpv.unit_rn = s.rn)) as nDelivDays
                          ,al.agnname                              as agnname
                      from payaccinspclc_ex  sce
                          ,payaccinspclc     sc
                          ,payaccinspec      s
                          ,payaccin          h
                          ,agnlist           al
                     where sce.prn    = sc.rn
                       and sc.prn     = s.rn
                       and s.prn      = h.rn
                       and h.supplier = al.rn
                    group by sce.departmentordsp
                            ,h.rn
                            ,s.nomen
                            ,sc.faceaccount
                            ,get_doctypes_code_id(nflag_smart => 1, nrn => h.doc_type)
                            ,trim(h.doc_pref)||'-'||trim(h.doc_numb)
                            ,h.doc_date
                            ,al.agnname
                   ) pai
                  ,(
                    select bpsp.deptordsp
                          ,h.rn                                    as h_rn
                          ,s.nomen                                 as nomen
                          ,get_doctypes_code_id(nflag_smart => 1, nrn => h.ord_doctype) as head_type
                          ,trim(h.ord_pref)||'-'||trim(h.ord_numb) as head_numb
                          ,h.ord_date                              as head_date
                          ,al.agnname                              as agnname
                      from deliveryord                    h
                          ,deliveryords                   s
                          ,udo_uzd_03_buyplanesp_cntr_doc uzd
                          ,buyplanespref                  bpsp
                          ,buyplanesp                     bps
                          ,buyplane                       bp
                          ,agnlist                        al
                     where s.prn      = h.rn
                       and uzd.doc_rn = s.rn
                       and uzd.rn_ref = bpsp.rn
                       and bpsp.prn   = bps.rn
                       and bps.prn    = bp.rn 
                       and h.agent    = al.rn
                    group by bpsp.deptordsp
                            ,h.rn
                            ,s.nomen
                            ,get_doctypes_code_id(nflag_smart => 1, nrn => h.ord_doctype)
                            ,trim(h.ord_pref)||'-'||trim(h.ord_numb)
                            ,h.ord_date
                            ,al.agnname
                   ) dlo
                  ,(
                    select dl.in_document                  as dl_in_document
                          ,h.rn                            as h_rn
                          ,s.nomen
                          ,sc.faceaccount
                          ,trim(h.pref)||'-'||trim(h.numb) as head_numb
                          ,h.doc_date                      as head_date
                          ,sum(sc.quant_plan)              as quant
                      from doclinks         dl
                          ,ininvoices       h
                          ,ininvoicesspecs  s
                          ,ininvoicesspc    sc
                     where dl.out_document = h.rn
                       and s.prn           = h.rn
                       and sc.prn          = s.rn
                    group by dl.in_document
                          ,h.rn
                          ,s.nomen
                          ,sc.faceaccount
                          ,trim(h.pref)||'-'||trim(h.numb)
                          ,h.doc_date
                   ) iiv
                  ,(
                    select dl.in_document                            as dl_in_document
                          ,nm.prn                                    as nomen
                          ,h.rn                                      as h_rn
                          ,sc.faceaccount
                          ,trim(h.indocpref)||'-'||trim(h.indocnumb) as head_numb
                          ,h.indocdate                               as head_date
                          ,sum(sc.quant_plan)                        as quant
                      from doclinks         dl
                          ,inorders         h
                          ,inorderspecs     s
                          ,inorderspecsclc  sc
                          ,nommodif         nm
                     where dl.out_document = h.rn
                       and s.prn           = h.rn
                       and sc.prn          = s.rn
                       and s.nommodif      = nm.rn
                    group by dl.in_document
                            ,nm.prn
                            ,h.rn  
                            ,sc.faceaccount
                            ,trim(h.indocpref)||'-'||trim(h.indocnumb)
                            ,h.indocdate
                   ) io
                  /*,(select to_date('01.01.2023', 'dd.mm.yyyy') as bg, to_date('01.01.2025', 'dd.mm.yyyy') as en from dual ) d*/
             where dpos.prn         = dpo.rn
               and dpos.nomen       = dnm.rn
               and dpos.rn          = bpd.deptordsp(+)
               and dpos.prn         = po.dl_1_out_document(+)
               and (
                    (nvl(po.release_date, dpo.release_date) between dFROM -- d.bg 
                                                                and dTO --  d.en
                     and nDATE_TYPE  = 0)
                    or 
                    (dpo.ord_date between dFROM -- d.bg 
                                      and dTO --  d.en
                     and nDATE_TYPE  = 1)
                    or 
                    (po.head_state_date between dFROM -- d.bg 
                                        and dTO --  d.en
                     and nDATE_TYPE  = 2)
                   )
               and dpos.rn          = pai.departmentordsp(+)
               and dpos.rn          = bp.dl_in_document(+)
               and dpos.rn          = bp.pd_prn(+)
               and bp.pd_prn        = dlo.deptordsp(+)
               and pai.h_rn         = iiv.dl_in_document(+)
               and pai.nomen        = iiv.nomen(+)
               and pai.faceaccount  = iiv.faceaccount(+)
               and iiv.h_rn         = io.dl_in_document(+)
               and iiv.nomen        = io.nomen(+)
               and iiv.faceaccount  = io.faceaccount(+)
               and dpos.main_quant != 0
               and cmp_vc2(
                           (select dpv.str_value from docs_props_vals dpv where dpv.docs_prop_rn = 22244761 and dpv.unit_rn = dpos.rn) 
                          ,'Да'
                          ) != 1
/* and (po.head_rn = 114773328 or user != 'STEPANOV_MV') */
/*and dnm.nomen_code = '00000034838'*/
/*and dpos.rn = 58384669*/
--and (po.head_rn = 116124197 or user != 'STEPANOV_MV')
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
                                                    ,psvalue => to_char(c.release_date, 'dd.mm.yyyy'));
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
                                                    ,psvalue => c.po_head_1C_ord);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.po_head_state_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.po_head_state_spers);
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
                                                    ,psvalue => c.dpo_head_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.dpo_head_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dpo_state);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.dpo_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.dpo_res_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.dpo_prod_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.nexec_fact);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.nreciev_IO);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.bpd_date_0, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.bpd_date_1, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.bpd_date_2, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.bp_head_type);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.bp_head_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.bp_head_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.bp_incl_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.bp_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_head_type);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_head_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.dlo_head_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.dlo_agnname);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_head_type);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_head_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.pai_head_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.pai_quant);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.pai_ndelivdays);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.pai_agnname);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.pai_pay_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.io_head_numb);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.io_head_date, 'dd.mm.yyyy'));
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_number(pnindex => nCountColumn
                                                    ,psstyle => sFormatQuant
                                                    ,pnvalue => c.io_quant);
    /* Конец строки */
    udo_pkg_excel_report_xml.p_row_end;
  end loop;

  /* Записываем результат формирования отчета */
  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка по спецификациям заказов подразделений 1.xls'
                                        ,pnident    => nIDENT_PROCESS);
  /* Освобождаем ресурсы отчета */
  udo_pkg_excel_report_xml.p_finalize;

end USR_P_REP_DPOS_UPLOAD1;
/
