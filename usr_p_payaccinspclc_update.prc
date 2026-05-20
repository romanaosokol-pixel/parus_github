create or replace procedure usr_p_payaccinspclc_update(nrn              in payaccinspclc.rn%type
                                                      ,ncompany         in payaccinspclc.company%type
                                                      ,sdepord          in ins_department.code%type
                                                      ,speriod          in enperiod.code%type
                                                      ,sfp_type         in doctypes.doccode%type /* Тип бюджета Всегда ПЛАН (пока)*/
                                                      ,sbudj_code       in udo_t_finplan.fp_code%type
                                                      ,scost_article    in varchar2 -- Мнемокод статьи затрат 
                                                      ,sbudj_art_nmb    in udo_t_finplan_arts.art_numb%type
                                                      ,salloc_art_nmb   in usr_t_alloc_arts.art_numb%type
                                                      ,allocation_sp_rn in number
                                                      ,finplan_arts_rn  in number
                                                      ,sfaceaccount     in varchar2 -- Номер лицевого счёта ШПЗ в нашем случае
                                                      ,nquant_plan      in number -- Количество план               
                                                      ,nsum_plan        in number -- Сумма план
                                                       ) is

  v_nrn_sv           number(17);
  v_numb             payaccinspclc.numb%type;
  v_cost_article     fpdartcl.code%type;
  v_cost_place       fpdaccnt.code%type;
  v_cost             payaccinspclc.cost_plan%type := case nquant_plan
                                                       when 0 then
                                                        0
                                                       else
                                                        nsum_plan / nquant_plan
                                                     end;
  v_priority         payaccinspclc.priority%type;
  v_graphpoint       fcacgraphpoints.code%type;
  v_finoper_type     dictoper.typoper_mnemo%type;
  sub_sz             faceacc.numb%type; /* Номер подстатьи */
  ncrn               number(17);
  v_allocation_sp_rn number(17);

begin

  /* считывание записи */
  p_payaccinspclc_exists(nrn, ncompany, ncrn);

  /* фиксация начала выполнения действия */
  pkg_env.prologue(ncompany, null, ncrn, null, null, 'PaymentAccountsInSpecsCalcs', 'usr_p_payaccinspclc_update', 'PAYACCINSPCLC', nrn);

  /* Номер строки править не даем! */

  select pc.numb
        ,nvl(scost_article, sz.code)
        ,pl.code
        ,pc.priority
        ,gp.code
        ,fin.typoper_mnemo
    into v_numb
        ,v_cost_article
        ,v_cost_place
        ,v_priority
        ,v_graphpoint
        ,v_finoper_type
    from payaccinspclc pc
    left join fpdartcl sz
      on sz.rn = pc.cost_article
    left join fpdaccnt pl
      on pl.rn = pc.cost_place
    left join fcacgraphpoints gp
      on gp.rn = pc.graphpoint
    left join dictoper fin
      on fin.rn = pc.finoper_type
  
   where pc.rn = nrn;

  udo_p_payaccinspclc_update(nrn           => nrn /*Регистрационный номер*/
                            ,ncompany      => ncompany /* Организация */
                            ,snumb         => v_numb /* Номер строки */
                            ,scost_article => nvl(v_cost_article, scost_article) /* Мнемокод статьи затрат */
                            ,scost_place   => v_cost_place /* Мнемокод места возникновения затрат */
                            ,ncost_plan    => v_cost /* Затраты на единицу план */
                            ,ncost_fact    => v_cost /* Затраты на единицу факт */
                            ,npriority     => v_priority /* Приоритет */
                            ,sfaceaccount  => sfaceaccount /* Номер лицевого счёта */
                            ,sgraphpoint   => v_graphpoint /* Мнемокод точки графика лицевого счета */
                            ,sfinoper_type => v_finoper_type /* Мнемокод вида финансовой операции */
                            ,nquant_plan   => nquant_plan /* Количество план */
                            ,nquant_fact   => nquant_plan /* Количество факт */
                            ,ssubdiv       => sdepord /* Мнемокод подразделения */);

  pkg_docs_props_vals.modify(sproperty   => 'Рпериод'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => nrn
                            ,nnum_value  => null
                            ,sstr_value  => speriod
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  if allocation_sp_rn is not null
  then
    v_allocation_sp_rn := allocation_sp_rn;
    begin
      select f.numb
        into sub_sz
        from usr_t_alloc_arts brs
        join faceacc f
          on f.rn = brs.faceacc_cost
       where brs.rn = allocation_sp_rn;
    exception
      when no_data_found then
        /*Если в свойстве стоит RN подстатьи, а самой подстатьи уже нет (ее удалили при переформировании распределения), то надо 
            1. Обнулить эту подстатью, как неправильную
            2. Проверить, что подстатья у статьи единственная и если это так, то подставить ее.
        */
        /*1*/
        v_allocation_sp_rn := null;
      
        /*2*/
      
        begin
        
          select f.numb
                ,brs.rn
            into sub_sz
                ,v_allocation_sp_rn
            from usr_t_alloc_arts brs
            join faceacc f
              on f.rn = brs.faceacc_cost
           where brs.finplan_arts = finplan_arts_rn;
        
        exception
          when others then
            sub_sz             := null;
            v_allocation_sp_rn := null;
          
        end;
      
    end;
    ---if user = 'GOR' then P_exception(0, sub_sz); end if;
    pkg_docs_props_vals.modify(sproperty   => 'Подстатья'
                              ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                              ,ndocument   => nrn
                              ,nnum_value  => null
                              ,sstr_value  => sub_sz
                              ,ddate_value => null
                              ,nrn         => v_nrn_sv);
  end if;

  pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_БЮДЖЕТ'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => nrn
                            ,nnum_value  => finplan_arts_rn
                            ,sstr_value  => null
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_РАСПРЕД'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => nrn
                            ,nnum_value  => v_allocation_sp_rn
                            ,sstr_value  => null
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /* Запишем в таблицу, для скорости запросов */

  usr_p_calc_detail_modif(nprn        => nrn
                         ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                         ,nalloc_arts => allocation_sp_rn
                         ,nrn         => v_nrn_sv
                         ,nsum        => round(nquant_plan * nsum_plan, 2)
                          
                          );

  /* фиксация окончания выполнения действия */
  pkg_env.epilogue(ncompany, null, ncrn, null, null, 'PaymentAccountsInSpecsCalcs', 'usr_p_payaccinspclc_update', 'PAYACCINSPCLC', nrn);

end;
/
