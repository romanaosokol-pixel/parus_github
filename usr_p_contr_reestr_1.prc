create or replace procedure usr_p_contr_reestr_1(nident                in selectlist.ident%type
                                                ,ncompany              in companies.rn%type
                                                ,pin_sz                in varchar2
                                                ,pin_rep_date          in date
                                                ,pin_close_date        in date
                                                ,pin_beg_date          in date
                                                ,pin_sz_price_with_nds in varchar2
                                                ,pin_sz_nds            in varchar2
                                                ,pin_sz_price_out_nds  in varchar2
                                                ,pin_sz_profit         in varchar2
                                                ,pin_sz_cost           in varchar2
                                                ,pin_sz_pki            in varchar2
                                                ,pin_sz_agent_sc       in varchar2
                                                ,pin_sz_salary         in varchar2
                                                ,pin_sz_soc            in varchar2
                                                ,pin_sz_nakl_rash      in varchar2
                                                ,pin_sz_nakl_rash_otp  in varchar2) is

  idx integer;
  sh  pkg_std.tstring := 'REP';

  cell_rep_date constant pkg_std.tstring := 'REP_DATE';
  line_1        constant pkg_std.tstring := 'LINE_1';

  v_sum      number(17, 2);
  v_dog_list varchar2(2000);
  v_zak_doc  varchar2(10);

begin

  prsg_excel.prepare;
  prsg_excel.sheet_select(sh);
  prsg_excel.cell_describe(cell_rep_date);
  prsg_excel.line_describe(line_1);

  for i in 1 .. 44
  loop
    prsg_excel.line_cell_describe(line_1, 'CELL_' || i);
  end loop;

  prsg_excel.cell_value_write(cell_rep_date, to_char(pin_rep_date, 'DD.MM.YYYY'));

  for dog in (
              
              select dog.rn
                     ,usr_f_contract_status(nrn => dog.rn) status /*Cell_2*/
                     ,to_char(dog.close_date, 'DD.MM.YYYY') sclose_date /*Cell_3*/
                     ,max(sz.code) sz_code /*Cell_4*/
                     ,usr_f_contracts_gkcust(nrn => dog.rn) sgen_zak /*Cell_5*/
                     ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'PrProductType', sunitcode => 'Contracts', ndocument => dog.rn) sprod_type /* СELL_6 */
                     ,usr_f_contracts_vid(nrn => dog.rn, ncompany => dog.company) sdog_vid /*Cell_7*/
                     ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Заместитель ГД', sunitcode => 'Contracts', ndocument => dog.rn) szam_gd /* СELL_8 */
                     ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник', sunitcode => 'Contracts', ndocument => dog.rn) seconom /* СELL_9*/
                     ,zak.agnname szak_name /* СELL_10*/
                     ,zak.agnidnumb szak_inn /* СELL_11*/
                     ,pr.name_usl sname_usl /* СELL_12*/
                     ,coalesce(dog.subject, udo_f_contract_coperplan(nrn => dog.rn)) spredmet /* СELL_14*/
                     ,dog.ext_number sext_number /* СELL_15*/
                     ,'''' || trim(dog.doc_pref) || '-' || trim(dog.doc_numb) such_nomer /* СELL_16*/
                     ,usr_f_dscr_ct_prj_code(nrn => dog.rn) spbu /* СELL_17*/
                     ,to_char(dog.doc_date, 'DD.MM.YYYY') sdoc_date /* СELL_18*/
                     ,to_char(dog.end_date, 'DD.MM.YYYY') send_date /* СELL_19*/
                     ,dog.doc_sumtax ndog_sumtax /* СELL_20*/
                      -- ,st.stage_sumtax nst_sumtax /* СELL_45*/
                     ,dog.doc_sum ndog_sum /* СELL_21*/
                      -- ,st.stage_sum nst_sum /* СELL_46*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_price_with_nds)) clc_price_with_tax /* СELL_22*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_nds)) clc_nds /* СELL_23*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_price_out_nds)) clc_price_out_tax /* СELL_24*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_profit)) clc_profit /* СELL_25*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_cost)) clc_cost /* СELL_26*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_pki)) clc_pki /* СELL_27*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_agent_sc)) clc_agent_sc /* СELL_28*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_salary)) clc_zp /* СELL_29*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_soc)) clc_soc_all /* СELL_30*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_nakl_rash)) clc_nakl_rash /* СELL_32*/
                     ,sum(usr_f_stages_price_sz(nrn => st.rn, sz_code => pin_sz_nakl_rash_otp)) clc_nakl_rash_opr /* СELL_33*/
                     ,sum(nvl(usr_pkg_faceacc.faceacc_get_fact_summs(nrn => st.faceacc, ssum_type => 'SERV_BASE_SUM', ddate_to => pin_rep_date), 0)) otgr_usl /*cell_39 */
                     ,sum(nvl(usr_pkg_faceacc.faceacc_get_fact_summs(nrn => st.faceacc, ssum_type => 'LOAD_BASE_SUM', ddate_to => pin_rep_date), 0)) otgr_tov /*cell_40 */
                     ,sum(nvl(usr_pkg_faceacc.faceacc_get_fact_summs(nrn => st.faceacc, ssum_type => 'PAY_BASE_SUM', ddate_to => pin_rep_date), 0)) oplat /*cell_42 */
                     ,sum(usr_f_faceacc_pay_sum(nrn => st.faceacc, spay_type => 'ПредоплатаБезнал', dpay_date_to => pin_rep_date)) pay_sum_avans /*cell_43 */
                from selectlist sl
                join contracts dog
                  on dog.rn = sl.document
                join stages st
                  on st.prn = dog.rn
                join faceacc f
                  on f.rn = st.faceacc
                join fpdartcl sz
                  on sz.rn = f.ieelement
                join agnlist zak
                  on zak.rn = dog.agent
                left join project pr
                  on pr.code = usr_f_dscr_ct_prj_code(nrn => dog.rn)
                 and pr.company = dog.company
               where sl.ident = nident
                 and sl.unitcode = 'Contracts'
                 and sl.authid = utilizer
                    
                    /* Отбор по датам */
                 and (pin_close_date is null or coalesce(dog.close_date, pin_close_date - 1) < pin_close_date)
                 and (pin_beg_date is null or coalesce(dog.begin_date, pin_beg_date) >= pin_beg_date)
              
              /*Отбор по составам затрат */
               and exists(with szr as (select distinct regexp_substr(str, '[^;]+', 1, level) as scode
                                         from (select pin_sz as str
                                                 from dual)
                                       connect by regexp_substr(str, '[^;]+', 1, level) is not null)
              
                select 1
                  from stages st
                  join faceacc f
                    on f.rn = st.faceacc
                  join fpdartcl szt
                    on szt.rn = f.ieelement
                  join szr
                    on szr.scode = szt.code
                --- and szt.version = 91451
                 where st.prn = dog.rn)
                
                 group by dog.rn
                   ,usr_f_contract_status(nrn => dog.rn)
                   ,to_char(dog.close_date, 'DD.MM.YYYY')                  
                   ,usr_f_contracts_gkcust(nrn => dog.rn)
                   ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'PrProductType', sunitcode => 'Contracts', ndocument => dog.rn)
                   ,usr_f_contracts_vid(nrn => dog.rn, ncompany => dog.company)
                   ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Заместитель ГД', sunitcode => 'Contracts', ndocument => dog.rn)
                   ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник', sunitcode => 'Contracts', ndocument => dog.rn)
                   ,zak.agnname
                   ,zak.agnidnumb
                   ,pr.name_usl
                   ,coalesce(dog.subject, udo_f_contract_coperplan(nrn => dog.rn))
                   ,dog.ext_number
                   ,'''' || trim(dog.doc_pref) || '-' || trim(dog.doc_numb)
                   ,usr_f_dscr_ct_prj_code(nrn => dog.rn)
                   ,to_char(dog.doc_date, 'DD.MM.YYYY')
                   ,to_char(dog.end_date, 'DD.MM.YYYY')
                   ,dog.doc_sumtax
                   ,dog.doc_sum
                
                ---    order by dog.reg_date  ,dog.rn
                
                ---dog.rn in (263825945, 136473037, 6018349)
                
              
              )
  loop
  
    idx := prsg_excel.line_append(line_1);
    prsg_excel.cell_value_write('CELL_1', 0, idx, idx);
    prsg_excel.cell_value_write('CELL_2', 0, idx, dog.status);
    prsg_excel.cell_value_write('CELL_3', 0, idx, dog.sclose_date);
    prsg_excel.cell_value_write('CELL_4', 0, idx, dog.sz_code);
    prsg_excel.cell_value_write('CELL_5', 0, idx, dog.sgen_zak);
    prsg_excel.cell_value_write('CELL_6', 0, idx, dog.sprod_type);
    prsg_excel.cell_value_write('CELL_7', 0, idx, dog.sdog_vid);
    prsg_excel.cell_value_write('CELL_8', 0, idx, dog.szam_gd);
    prsg_excel.cell_value_write('CELL_9', 0, idx, dog.seconom);
    prsg_excel.cell_value_write('CELL_10', 0, idx, dog.szak_name);
    prsg_excel.cell_value_write('CELL_11', 0, idx, dog.szak_inn);
    prsg_excel.cell_value_write('CELL_12', 0, idx, dog.sname_usl);
  
    prsg_excel.cell_value_write('CELL_14', 0, idx, dog.spredmet);
    prsg_excel.cell_value_write('CELL_15', 0, idx, dog.sext_number);
    prsg_excel.cell_value_write('CELL_16', 0, idx, dog.such_nomer);
    prsg_excel.cell_value_write('CELL_17', 0, idx, dog.spbu);
    prsg_excel.cell_value_write('CELL_18', 0, idx, dog.sdoc_date);
    prsg_excel.cell_value_write('CELL_19', 0, idx, dog.send_date);
    prsg_excel.cell_value_write('CELL_20', 0, idx, dog.ndog_sumtax);
    prsg_excel.cell_value_write('CELL_21', 0, idx, dog.ndog_sum);
    prsg_excel.cell_value_write('CELL_22', 0, idx, dog.clc_price_with_tax);
    prsg_excel.cell_value_write('CELL_23', 0, idx, dog.clc_nds);
    prsg_excel.cell_value_write('CELL_24', 0, idx, dog.clc_price_out_tax);
    prsg_excel.cell_value_write('CELL_25', 0, idx, dog.clc_profit);
    prsg_excel.cell_value_write('CELL_26', 0, idx, dog.clc_cost);
    prsg_excel.cell_value_write('CELL_27', 0, idx, dog.clc_pki);
    prsg_excel.cell_value_write('CELL_28', 0, idx, dog.clc_agent_sc);
    prsg_excel.cell_value_write('CELL_29', 0, idx, dog.clc_zp);
    prsg_excel.cell_value_write('CELL_30', 0, idx, dog.clc_soc_all);
  
    prsg_excel.cell_value_write('CELL_32', 0, idx, dog.clc_nakl_rash);
    prsg_excel.cell_value_write('CELL_33', 0, idx, dog.clc_nakl_rash_opr);
  
    prsg_excel.cell_value_write('CELL_39', 0, idx, dog.otgr_usl);
    prsg_excel.cell_value_write('CELL_40', 0, idx, dog.otgr_tov);
  
    prsg_excel.cell_value_write('CELL_42', 0, idx, dog.oplat);
    prsg_excel.cell_value_write('CELL_43', 0, idx, dog.pay_sum_avans);
  
    /* Закрывающий жокумент */
  
    begin
    
      select 'ТН'
        into v_zak_doc
        from stages st
        join fcacoperplans gr
          on gr.prn = st.faceacc
       where st.prn = dog.rn
         and gr.price != 0
         and rownum = 1;
    exception
      when no_data_found then
        v_zak_doc := 'АКТ';
      
    end;
  
    prsg_excel.cell_value_write('CELL_13', 0, idx, v_zak_doc);
  
    /* Договоры с соисполнителями, сумма */
    v_sum      := 0;
    v_dog_list := ';';
    for soag in (select sum(st.stage_sumtax) s
                       ,ag.agnname so_agent
                   from contracts d
                   join stages st
                     on st.prn = d.rn
                   join faceacc f
                     on f.rn = st.faceacc
                   join fpdartcl sz
                     on sz.rn = f.ieelement
                   join agnlist ag
                     on ag.rn = d.agent
                   join projectstagepf pre
                     on pre.faceacc = st.faceacc
                   join projectstage prs
                     on prs.rn = pre.prn
                   join project pr
                     on pr.rn = prs.prn
                  where pr.code = dog.spbu
                    and d.rn != dog.rn
                    and sz.code like '%\_Б' escape '\'
                    and d.status != 0 /* Исключили статус "Не утвержден" */
                    and st.begin_date <= pin_rep_date
                    and st.status != 2 /* Исключили статус "Аннулирован" */
                    and st.sign_sum = 1 /* ОТражается на сумме договора */
                  group by ag.agnname
                 
                 )
    loop
      v_sum := v_sum + soag.s;
      if length(v_dog_list) < 1800
      then
        v_dog_list := v_dog_list || chr(10) || to_char(soag.s, '999G999G999G999G999D00', 'NLS_NUMERIC_CHARACTERS=''. ''') || ' ' || soag.so_agent;
      else
        v_dog_list := v_dog_list || '.';
      end if;
    end loop;
  
    prsg_excel.cell_value_write('CELL_36', 0, idx, v_sum);
    prsg_excel.cell_value_write('CELL_37', 0, idx, substr(v_dog_list, 3));
  
  end loop;

  prsg_excel.execute_macros(smacros_name => 'AUTOFIT');

  prsg_excel.line_delete(line_1);

end;
/
