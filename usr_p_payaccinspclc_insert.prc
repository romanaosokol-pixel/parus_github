create or replace procedure usr_p_payaccinspclc_insert(ncompany in number
                                                       /* ,njur           in number*/ --- Это вычисляется
                                                      ,nprn             in payaccinspec.rn%type
                                                      ,sdepord          in ins_department.code%type
                                                      ,speriod          in enperiod.code%type
                                                      ,sbudj_code       in udo_t_finplan.fp_code%type
                                                      ,sfp_type         in doctypes.doccode%type /* Тип бюджета */
                                                      ,sbudj_art_nmb    in udo_t_finplan_arts.art_numb%type
                                                      ,salloc_art_nmb   in usr_t_alloc_arts.art_numb%type
                                                      ,sfaceaccount     in varchar2
                                                      ,nquant_fact      in number
                                                      ,ncost_fact_sum   in number
                                                      ,allocation_sp_rn in number /*RN строки бюджетного распределения*/
                                                      ,finplan_arts_rn  in number /*RN строки бюджета */
                                                      ,scost_article    in varchar2 --- Стаья затрат
                                                       ) is

  ndocrn payaccin.rn%type;
  nface  payaccin.faceacc%type;
  njur   payaccin.jur_pers%type;
  ncrn   payaccin.crn%type; -- Каталог

  s_shpz   faceacc.numb%type;
  v_nrn    payaccinspclc.rn%type;
  nbudj_rn udo_t_finplan.rn%type;
  nperiod  enperiod.rn%type;
  ndepord  ins_department.rn%type;
  nfp_type udo_t_finplan.fp_type%type;

  n_shpz payaccinspclc.faceaccount%type;

  v_cost   payaccinspclc.cost_plan%type := case nquant_fact
                                             when 0 then
                                              0
                                             else
                                              ncost_fact_sum / nquant_fact
                                           end;
  v_numb   payaccinspclc.numb%type;
  v_nrn_sv number(17);

  sub_sz faceacc.numb%type; /* Номер подстатьи */

  procedure usr_p_payaccinspclc_join(ncompany in number
                                    ,nprn     in number
                                    ,speriod  in varchar2
                                    ,sdepord  in varchar2
                                    ,nperiod  out number
                                    ,ndepord  out number
                                    ,njur     out number
                                    ,snumb    out varchar2) is
  begin
    begin
      select per.rn
        into nperiod
        from enperiod per
       where per.code = speriod
         and per.company = ncompany;
    exception
      when no_data_found then
        p_exception(0, 'Расчетный период с кодом "%s" не найден.', speriod);
    end;
  
    begin
      select dep.rn
        into ndepord
        from ins_department dep
       where dep.code = sdepord
         and dep.company = ncompany;
    
    exception
      when no_data_found then
        p_exception(1, 'Подразделение с кодом "%s" не найдено.', sdepord);
    end;
    /* Вычислим номер, для уникальности записи */
    select count(*) + 1
      into snumb
      from payaccinspclc pc
     where pc.prn = nprn;
  
  end;

begin


  /* поиск записи */
  begin
    select ps.crn
          ,p.rn
          ,p.faceacc
      into ncrn
          ,ndocrn
          ,nface
      from payaccinspec ps
      join payaccin p
        on p.rn = ps.prn
     where ps.rn = nprn;
  exception
    when no_data_found then
      pkg_msg.record_not_found(v_nrn, 'PaymentAccountsInSpecs');
  end;

  /* фиксация начала выполнения действия */
  usr_p_payaccinspclc_join(ncompany => ncompany
                          ,nprn     => nprn
                          ,speriod  => speriod
                          ,sdepord  => sdepord
                          ,nperiod  => nperiod
                          ,ndepord  => ndepord
                          ,njur     => njur
                          ,snumb    => v_numb);

  if sfaceaccount is null
  then null;
    /*Найдем Л/С этапа проекта (Лицевой счет (заказ)) по алгоритму */
 --- if user = 'GOR' then p_exception(0, 114); end if;
    usr_p_shpz_get_get(ncompany          => ncompany                     
                      ,nfaceacc          => nface
                      ,salloc_art_rn     => allocation_sp_rn
                      ,out_sfaceacc_shpz => s_shpz);
  end if;

  udo_p_payaccinspclc_insert(ncompany      => ncompany
                            ,nprn          => nprn
                            ,snumb         => v_numb -- номер считаем автоматически
                            ,scost_article => scost_article /* статья затрат */
                            ,scost_place   => null /* места возникновения затрат (ссылка FPDACCNT(RN)) */
                            ,ncost_plan    => v_cost /* Затраты на единицу план */
                            ,ncost_fact    => v_cost /* Затраты на единицу факт */
                            ,npriority     => null /* Приоритет */
                            ,sfaceaccount  => nvl(sfaceaccount, s_shpz) /* Лицевой счёт (ссылка на FACEACC(RN)) */
                            ,sgraphpoint   => null /* Точка графика лицевого счета (ссылка на FCACGRAPHPOINTS(RN)) */
                            ,sfinoper_type => null /* Вид финансовой операции (ссылка на DICTOPER(RN)) */
                            ,nquant_plan   => nquant_fact /* Количество план */
                            ,nquant_fact   => nquant_fact /* Количество факт */
                            ,ssubdiv       => sdepord /* Подразделение (ссылка на INS_DEPARTMENT(RN)) */
                            ,nrn           => v_nrn);

  pkg_env.prologue(ncompany, null, ncrn, null, null, 'PaymentAccountsInSpecsCalcs', 'usr_payaccinspclc_insert', 'PAYACCINSPCLC', v_nrn);

  if allocation_sp_rn is not null
  then
  
    begin
      select f.numb
        into sub_sz
        from usr_t_alloc_arts brs
        join faceacc f
          on f.rn = brs.faceacc_cost
       where brs.rn = allocation_sp_rn;
    exception
      when no_data_found then
        p_exception(0
                   ,'Лицевой счет c rn = %s не найден в строке бюджетного распределения'
                   ,allocation_sp_rn);
    end;
  end if;

  /* Номер лицевого счета ---  подстатья бюджетного распределения*/
  pkg_docs_props_vals.modify(sproperty   => 'Подстатья'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => v_nrn
                            ,nnum_value  => null
                            ,sstr_value  => sub_sz
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /*Периода расчетного */

  pkg_docs_props_vals.modify(sproperty   => 'Рпериод'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => v_nrn
                            ,nnum_value  => null
                            ,sstr_value  => speriod
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /*RN  RN_СТР_РАСПРЕД */

  pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_РАСПРЕД'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => v_nrn
                            ,nnum_value  => allocation_sp_rn
                            ,sstr_value  => null
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);
                            
  /* Запишем в таблицу, для скорости запросов */                           
  
  USR_P_calc_detail_modif(nprn => v_nrn, sunitcode => 'PaymentAccountsInSpecsCalcs', nalloc_arts => allocation_sp_rn, nrn => v_nrn_sv, nSUM => round(nquant_fact * ncost_fact_sum,2));                            

  /*RN  RN_СТР_БЮДЖЕТ */

  pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_БЮДЖЕТ'
                            ,sunitcode   => 'PaymentAccountsInSpecsCalcs'
                            ,ndocument   => v_nrn
                            ,nnum_value  => finplan_arts_rn
                            ,sstr_value  => null
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /* фиксация окончания выполнения действия */

  pkg_env.epilogue(ncompany, null, ncrn, null, null, 'PaymentAccountsInSpecsCalcs', 'usr_payaccinspclc_insert', 'PAYACCINSPCLC', v_nrn);

end;
/
