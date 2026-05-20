create or replace procedure usr_p_paynotesclc_update(ncompany         in number
                                                    ,nrn              in paynotes.rn%type
                                                    ,snumb            in varchar2
                                                    ,sdepord          in ins_department.code%type
                                                    ,sfinoper_type    in varchar2
                                                    ,speriod          in out enperiod.code%type
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

begin

  udo_p_paynotesclc_update(nrn           => nrn /* Регистрационный номер */
                          ,ncompany      => ncompany /* Организация */
                          ,snumb         => snumb /* Номер строки (менять не дадим !) */
                          ,scost_article => scost_article /* Мнемокод статьи затрат */
                          ,scost_place   => null /* Мнемокод места возникновения затрат (Не используем - т.к. бюджеты завязаны на Подразделения) */
                          ,nsum_plan     => ncost_fact_sum /* Сумма затрат план */
                          ,nsum_fact     => ncost_fact_sum /* Сумма затрат факт */
                          ,npriority     => null /* Приоритет */
                          ,sfaceaccount  => sfaceaccount /* Номер лицевого счёта */
                          ,sgraphpoint   => null /* Мнемокод точки графика лицевого счета */
                          ,sfinoper_type => sfinoper_type /* Мнемокод вида финансовой операции (Не используем) */
                          ,ssubdiv       => sdepord /* Мнемокод подразделения */);

end;
/
