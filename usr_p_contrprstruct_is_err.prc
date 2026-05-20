create or replace procedure usr_p_contrprstruct_is_err(
                                                       
                                                       nrn in number) is

  ndup_rn contrprstruct.rn%type;
  nclc    contrprclc.rn%type;

begin
  /*
  Процедура отбирает RN структур цены, у которых калькуляция структуры цены изменится полс едействия СФОРМИРОВАТЬ
  Создается копия проверяемой структуры цены и на ней выполняется действие сформировать. Если получились результаты, отличные от проверяемой RN
  записывается в таблицу USR_T_TMP_IS_ERR
  Нужно если внешней процедурой поменяли значения строк калькуляции структуры цены 
  */

  --- P_EXCEPTION(0, NRn);
  --- Скопируем структуру в 50 год и пересчитаем ее (будем эмулировать зпуск действия  "формирования" на копии структуры цены)

  for doc in (select t.prn
                    ,t.price_kind
                    ,t.calcschm
                    ,t.calc_indir
                    ,t.state /* Состояние (0 - Новая, 1 - Согласована, 2 - Утверждена, 3 - Аннулирована) */
                    ,t.sign_act
                    ,t.company
                from contrprstruct t
                join finstate fs
                  on fs.rn = t.price_kind
                join prjcalcschm pm
                  on pm.rn = t.calcschm
               where t.rn = nrn
              
              )
  loop
  
    /* копируем шапку */
  
    ---  P_EXCEPTION(0, doc.state);
    begin
      p_contrprstruct_base_insert(ncompany    => doc.company
                                 ,nprn        => doc.prn
                                 ,nprice_kind => 154332934 ---143209030--- со структурой test  doc.price_kind
                                 ,ncalcschm   => doc.calcschm
                                 ,ddate_from  => to_date('01-01.1950', 'DD.MM.YYYY')
                                 ,ddate_to    => to_date('01-01.1950', 'DD.MM.YYYY')
                                 ,nsumm       => 0
                                 ,nsumm_base  => 0
                                 ,nsumm_fact  => 0
                                 ,nsumm_fin   => 0
                                 ,ncalc_indir => doc.calc_indir
                                 ,nrn         => ndup_rn);
    exception
      when others then
        p_exception(0, doc.prn);
    end;
  
    /* Копируем спецификацию */
  
    for rclc in (select c.* from contrprclc c where c.prn = nrn)
    loop
    
      begin
        p_contrprclc_base_insert(rclc.company
                                ,ndup_rn
                                , -- Вставляем в новую структуру
                                 rclc.numb
                                ,rclc.cost_article
                                ,rclc.sign_main
                                ,rclc.exp_type
                                ,rclc.cost_sum
                                ,rclc.sum_fact
                                ,rclc.sum_fin
                                ,rclc.percent_plan
                                ,rclc.percent_fact
                                ,nclc -- nRN
                                 );
      
      end;
    
    end loop;
  
    /* пересчитываем */
    p_contrprstruct_make(ncompany => doc.company, nrn => ndup_rn);
  
    --- сравним исходную структуру и скопированную
  
    for cur in (
                
                select t.cost_article
                       ,t.cost_sum
                  from contrprclc t
                 where t.prn = nrn --- Наш исходный
                
                minus
                
                select t.cost_article
                       ,t.cost_sum
                  from contrprclc t
                 where t.prn = ndup_rn --- Пересчитанный
                )
    loop
    
      for err in (select (select t.cost_sum
                            from contrprclc t
                           where t.prn = nrn --- Наш исходный
                             and t.cost_article = cur.cost_article) sum_ish
                        ,(select t.cost_sum
                            from contrprclc t
                           where t.prn = ndup_rn --- Пересчитанный
                             and t.cost_article = cur.cost_article) sum_calc
                        ,fp.code
                    from fpdartcl fp
                   where fp.rn = cur.cost_article)
      loop
      
        insert into usr_t_tmp_is_err (nrn) values (nrn);
        exit;
      end loop;
      exit;
    end loop; --- Цикл сравнения строк калькуляции
    --- Удаляем фиктивную структуру, если ее создавали
    p_contrprstruct_base_delete(nrn => ndup_rn, ncompany => doc.company);
  end loop; --- Цикл по документу

end;
/
