create or replace procedure usr_p_mail_table123(pin_list_email in varchar2) is
  ---:= 'o.gorodetskiy@module.ru';

begin
  for cur in (with cnt as
                 (select gr.summwithnds gr_sum
                       ,(select sum(cl.cost_plan * gr.quant * (1 - gr.discount / 100))
                           from fcacoperplansclc cl
                           join fpdartcl fp
                             on fp.rn = cl.cost_article
                          where cl.prn = gr.rn
                            and fp.code = 'Цена с НДС'
                            and fp.version = 91451) calc_sum
                       ,trim(gr.numb) gr_nmb
                       ,trim(st.numb) stage_nmb
                       ,dog.rn dog_rn
                       ,trim(dog.doc_pref) dog_prf
                       ,trim(dog.doc_numb) dog_nmb
                       ,st.faceacc
                   from contracts dog
                   join stages st
                     on st.prn = dog.rn
                   join faceacc f
                     on f.rn = st.faceacc
                   join acatalog cat
                     on cat.rn = dog.crn
                   join fpdartcl sz
                     on sz.rn = f.ieelement
                   left join fcacoperplans gr
                     on gr.prn = f.rn
                    and gr.inexp_sign = 1
                 
                  where dog.status = 1 --- Утвержденные
                    and dog.crn != 58774176 --- Исключили каталог "Исполненные"
                       /*По всем или одному МОЛ*/
                       
                    and gr.discount = 0 --- Временно исключили договора со скидкой (от такой 1 => Договор, 1/23-32, 27.12.2023)
                    and not (st.status = 0 and st.end_date is not null)
                    
                    and trim(ST.NUMB) not in ('77','99','100')  -- НЕ контролируемые нмера этапов
                    
                    and sz.code in ('Темат. доходы_Б'
                                   ,'Продажа товаров вСНГ'
                                   ,'Расходы на КА_Б'
                                   ,'Прочие тем.расходы_Б'
                                   ,'Расходы на иниц._Б'
                                   ,'Субсидии на разработки_Б'))
                select
                
                distinct usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник'
                                                            ,sunitcode  => 'Contracts'
                                                            ,ndocument  => cnt.dog_rn) otv
                  from cnt
                 where nvl(cnt.calc_sum
                          ,0) != 0
                   and cnt.calc_sum is not null
                   and abs(cnt.gr_sum - cnt.calc_sum) > 99)
  
  loop
    usr_p_mail_table1(pin_list_mail => pin_list_email || ';' || cur.otv
                     ,pin_mol       => cur.otv
                     ,pin_tema      => 'По экономисту ' || cur.otv || ' ');
  end loop;

  for cur2 in (with cnt2 as
                  (select (select sp.summ
                            from contrprstruct sp
                           where sp.prn = st.rn
                             and sp.sign_act = 1 -- Действующая
                             and sp.state = 2 -- Утверждена)
                          ) calc_sum
                        ,st.stage_sum
                        ,trim(st.numb) stage_nmb
                        ,dog.rn dog_rn
                        ,trim(dog.doc_pref) dog_prf
                        ,trim(dog.doc_numb) dog_nmb
                        ,to_char(dog.doc_date
                                ,'DD.MM.YYYY') dog_date
                    from contracts dog
                    join stages st
                      on st.prn = dog.rn
                    join faceacc f
                      on f.rn = st.faceacc
                    join fpdartcl fo
                      on fo.rn = f.ieelement
                    join diciearts cl
                      on cl.rn = fo.iearticle
                    left join fcacoperplans gr
                      on gr.prn = st.faceacc
                    join acatalog cat
                      on cat.rn = dog.crn
                    join fpdartcl sz
                      on sz.rn = f.ieelement
                   where dog.status = 1 --- Утвержденные
                     and cl.code = 'Доход' -- Договора поставки
                     and gr.rn is null
                     and not (st.status = 0 and st.end_date is not null)
                      and trim(ST.NUMB) not in ('77','99','100')  -- НЕ контролируемые нмера этапов
                     and sz.code in ('Темат. доходы_Б'
                                    ,'Продажа товаров вСНГ'
                                    ,'Расходы на КА_Б'
                                    ,'Прочие тем.расходы_Б'
                                    ,'Расходы на иниц._Б'
                                    ,'Субсидии на разработки_Б'))
                 select distinct usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник'
                                                                    ,sunitcode  => 'Contracts'
                                                                    ,ndocument  => cnt2.dog_rn) otv
                   from cnt2
                  where cnt2.calc_sum is not null
                    and abs(cnt2.calc_sum - cnt2.stage_sum) > 99)
  
  loop
    usr_p_mail_table2(pin_list_mail => pin_list_email || ';' || cur2.otv
                     ,pin_mol       => cur2.otv
                     ,pin_tema      => 'По экономисту ' || cur2.otv || ' ');
  
  end loop;

  for cur3 in (with cnt3 as
                  (select (select nvl(sum(gr.pay_sum * (1 - 2 * gr.inexp_sign))
                                    ,0)
                            from fcacpayplans gr
                           where gr.prn = st.faceacc) calc_sum
                        ,st.stage_sumtax stage_sum --- т.к. в графике сумма с НДС
                        ,trim(st.numb) stage_nmb
                        ,dog.rn dog_rn
                        ,trim(dog.doc_pref) dog_prf
                        ,trim(dog.doc_numb) dog_nmb
                        ,to_char(dog.doc_date
                                ,'DD.MM.YYYY') dog_date
                        ,cat.name catalog
                        ,(select nvl(sum(gr.pay_sum * (1 - 2 * gr.inexp_sign))
                                    ,0)
                            from fcacpayplans gr
                            join stages stf
                              on stf.faceacc = gr.prn
                           where stf.prn = dog.rn) sum_gr_dog
                        ,(select sum(stage_sumtax) from stages sts where sts.prn = dog.rn) sum_st_dog
                    from contracts dog
                    join stages st
                      on st.prn = dog.rn
                    join faceacc f
                      on f.rn = st.faceacc
                    join fpdartcl fo
                      on fo.rn = f.ieelement
                    join diciearts cl
                      on cl.rn = fo.iearticle
                    join acatalog cat
                      on cat.rn = dog.crn
                    join fpdartcl sz
                      on sz.rn = f.ieelement
                  
                   where dog.status = 1 --- Утвержденные
                     and cl.code = 'Доход' -- Договора поставки
                     and not (st.status = 0 and st.end_date is not null)
                     and st.sign_sum = 1 -- Отражается на сумме Договора
                     and trim(ST.NUMB) not in ('77','99','100')  -- НЕ контролируемые нмера этапов
                     and sz.code in ('Темат. доходы_Б'
                                    ,'Продажа товаров вСНГ'
                                    ,'Расходы на КА_Б'
                                    ,'Прочие тем.расходы_Б'
                                    ,'Расходы на иниц._Б'
                                    ,'Субсидии на разработки_Б'))
                 
                 select distinct nvl(usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник'
                                                                        ,sunitcode  => 'Contracts'
                                                                        ,ndocument  => cnt3.dog_rn)
                                    ,cnt3.catalog) otv
                   from cnt3
                  where abs(cnt3.calc_sum - cnt3.stage_sum) > 99
                    and abs(cnt3.sum_gr_dog - cnt3.sum_st_dog) > 99)
  
  loop
  
    usr_p_mail_table2(pin_list_mail => pin_list_email || ';' || cur3.otv
                     ,pin_mol       => cur3.otv
                     ,pin_tema      => 'По экономисту ' || cur3.otv || ' ');
  end loop;

end;
/
