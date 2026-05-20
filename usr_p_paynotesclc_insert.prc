create or replace procedure usr_p_paynotesclc_insert(ncompany         in number
                                                    ,nprn             in paynotes .rn%type
                                                    ,sdepord          in ins_department.code%type
                                                    ,speriod          in out enperiod.code%type
                                                    ,salloc_art_code  in faceacc.numb%type /* Номер подстатьи (Номер лицевого счета) */
                                                    ,sfaceaccount     in varchar2
                                                    ,ncost_fact_sum   in number
                                                    ,allocation_sp_rn in number /*RN строки бюджетного распределения*/
                                                    ,finplan_arts_rn  in number /*RN строки бюджета */
                                                    ,scost_article    in varchar2 --- Стаья затрат
                                                     ) is

  v_nrn payaccinspclc.rn%type;
  snumb paynotesclc.numb%type;

begin

  /* Вычислим номер, для уникальности записи */
  select count(*) + 1
    into snumb
    from paynotesclc pc
   where pc.prn = nprn;

  udo_p_paynotesclc_insert(ncompany      => ncompany
                          ,nprn          => nprn
                          ,snumb         => snumb
                          ,scost_article => scost_article
                          ,scost_place   => null
                          ,nsum_plan     => ncost_fact_sum
                          ,nsum_fact     => ncost_fact_sum
                          ,npriority     => null
                          ,sfaceaccount  => sfaceaccount
                          ,sgraphpoint   => null
                          ,sfinoper_type => null
                          ,ssubdiv       => sdepord
                          ,nrn           => v_nrn);

  /* Запишем доп поля калькуляции (пока пишем в свойства)*/
  usr_p_calc_set(nrn              => v_nrn
                ,sunitcode        => 'PayNotesCalcs'
                ,salloc_art_nmb   => salloc_art_code
                ,speriod          => speriod
                ,allocation_sp_rn => allocation_sp_rn
                ,finplan_arts_rn  => finplan_arts_rn);

end;
/
