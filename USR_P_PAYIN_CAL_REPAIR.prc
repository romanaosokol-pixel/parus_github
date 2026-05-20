create or replace procedure usr_p_payin_cal_repair is

  /*
  1. Находим калькуляции, которые потеряли связь сос трокою бюджетного распределения
  Берем значение свойства Подстатья и на его основе заполнить свойства RN строки бюджетного распределления и rn строки бюджета
  
  2. Находим калькуляции входящего счете у которых в поле лицевой счет (Заказ) стоит лицевой счет не используемый в этапах проектов
  и удаляем эти ЛС из калькуляции
  
  */

  v_nrn number(17);

begin
  for cur in (
              
                with repaire as
                 (select (select t.str_value
                            from docs_props_vals t
                           where t.docs_prop_rn = 260403049
                             and t.unit_rn = svz.unit_rn /* Свойство "Подстатья" */
                          ) ls
                        ,svz.unit_rn
                        ,(select t.str_value
                            from docs_props_vals t
                           where t.docs_prop_rn = 260630065
                             and t.unit_rn = svz.unit_rn /* Свойство "Период" */
                          ) period
                         
                        ,svz.company
                  
                    from docs_props_vals svz
                    left join usr_t_alloc_arts brs
                      on brs.rn = svz.num_value
                   where svz.docs_prop_rn = 260630987 /* Свойство "RN строки распределения */
                     and brs.rn is null /* Потеряна связь с распределением (рапределенеи было удалено при переформировании) */
                  
                  )
                
                select r.unit_rn        rn
                      ,brs.finplan_arts rn_str_bj
                      ,brs.rn           brs_rn
                --- ,bj.rn     bj_rn
                  from repaire r /* Калькуляции которые надо перепривязать к бюджету */
                  join faceacc f
                    on f.numb = r.ls
                   and f.company = r.company
                  join usr_t_alloc_arts brs
                    on brs.faceacc_cost = f.rn
                  join usr_t_budget_allocation br
                    on br.rn = brs.prn
                  join udo_t_finplan bj
                    on bj.rn = br.finplan
                  join enperiod per
                    on per.rn = bj.fp_period
                
                 where per.code = r.period
                   and per.company = r.company)
  loop
    /*Актуализируем связь со строкой бюджета*/
  
    pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_БЮДЖЕТ'
                              ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                              ,ndocument   => cur.rn
                              ,sstr_value  => null
                              ,nnum_value  => cur.rn_str_bj
                              ,ddate_value => null
                              ,nrn         => v_nrn);
  
    /*Актуализируем связь со строкой бюджетного распределения */
    pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_РАСПРЕД'
                              ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                              ,ndocument   => cur.rn
                              ,sstr_value  => null
                              ,nnum_value  => cur.brs_rn
                              ,ddate_value => null
                              ,nrn         => v_nrn);
  
  end loop;

  /*2. Находим калькуляции входящего счете у которых в поле лицевой счет (Заказ) стоит лицевой счет не используемый в этапах проектов
  и удаляем эти ЛС из калькуляции*/

  update payaccinspclc t
     set t.faceaccount = null
   where t.rn in (select cl.rn
                    from payaccinspclc cl
                    left join projectstage ps
                      on ps.faceacc = cl.faceaccount
                    join payaccinspec sp
                      on sp.rn = cl.prn
                    join payaccin p
                      on p.rn = sp.prn
                   where cl.faceaccount is not null
                     and ps.rn is null 
                     and p.doc_date > to_date('01-01-2026', 'DD.MM.YYYY'));

end;
/
