create or replace procedure usr_p_payaccinspclc_insert_all(ncompany         in number
                                                          ,nrn              in payaccin.rn%type
                                                          ,sdepord          in ins_department.code%type
                                                          ,speriod          in enperiod.code%type
                                                          ,sbudj_code       in udo_t_finplan.fp_code%type
                                                          ,sfp_type         in doctypes.doccode%type /* Тип бюджета */
                                                          ,sbudj_art_nmb    in udo_t_finplan_arts.art_numb%type
                                                          ,salloc_art_nmb   in usr_t_alloc_arts.art_numb%type
                                                          ,sfaceaccount     in varchar2
                                                          ,ncost_fact_sum   in payaccin.summwithnds%type /* Сумма счета */
                                                          ,allocation_sp_rn in number /*RN строки бюджетного распределения*/
                                                          ,finplan_arts_rn  in number /*RN строки бюджета */
                                                          ,finplan_rn       in number /*RN бюджета */
                                                          ,scost_article    in varchar2 /* Стаья затрат*/
                                                          ,salloc_name      in varchar2 /* Наименование подстатьи */
                                                          ,limit_year       in number
                                                          ,cost_year        in number
                                                          ,balance_year     in number) is

  nfl_upd integer; /*Признак что была исправлена калькуляция */
  /* Задаем калькуляцию по всем строкам входящего счета на оплату, ту калькуляцию что там была удаляем */
begin

  /*В утвержденных счетах масово менять не даем , т.к. контроль на этапе утверждения */

  for cur0 in (select 1
                 from payaccin p
                where p.rn = nrn
                  and p.doc_state != 0)
  loop
    p_exception(0
               ,'Массово менять калькуляцию можно только в счетах в состоянии "Не утвержден"');
  end loop;

  /*Заводим калькуляцию (все строкам одинаковую)*/

  for cur2 in (select ps.rn          nprn
                     ,ps.quant       q
                     ,ps.summwithnds s
                 from payaccin p
                 join payaccinspec ps
                   on ps.prn = p.rn
                where p.rn = nrn)
  loop
  
    nfl_upd := 0;
    /*Если калькуляция существует, то обновим ее */
  
    for cur3 in (select cl.rn
                       ,cl.quant_plan q
                       ,cl.cost_plan * cl.quant_plan s
                   from payaccinspclc cl
                  where cl.prn = cur2.nprn)
    
    loop
    
      nfl_upd := 1;
      usr_p_payaccinspclc_update(nrn              => cur3.rn
                                ,ncompany         => ncompany
                                ,sdepord          => sdepord
                                ,speriod          => speriod
                                ,sfp_type         => sfp_type /* Тип бюджета */
                                ,sbudj_code       => sbudj_code
                                ,scost_article    => scost_article /* Стаья затрат */
                                ,sbudj_art_nmb    => sbudj_art_nmb
                                ,salloc_art_nmb   => salloc_art_nmb
                                ,allocation_sp_rn => allocation_sp_rn
                                ,finplan_arts_rn  => finplan_arts_rn
                                ,sfaceaccount     => sfaceaccount
                                ,nquant_plan      => cur3.q
                                ,nsum_plan        => case cur3.s when 0 then cur2.S else cur3.s end ); /* Если в калькуляции не задана сумма, то берем ее из спецификации*/
    
    end loop;
  
    if nfl_upd = 0
    then
      /*Калькуляция не найдена */
      usr_p_payaccinspclc_insert(ncompany         => ncompany
                                ,nprn             => cur2.nprn
                                ,sdepord          => sdepord
                                ,speriod          => speriod
                                ,sbudj_code       => sbudj_code
                                ,sfp_type         => sfp_type /* Тип бюджета */
                                ,sbudj_art_nmb    => sbudj_art_nmb
                                ,salloc_art_nmb   => salloc_art_nmb
                                ,sfaceaccount     => sfaceaccount
                                ,nquant_fact      => nvl(cur2.q, 1)
                                ,ncost_fact_sum   => cur2.s
                                ,allocation_sp_rn => allocation_sp_rn /*RN строки бюджетного распределения*/
                                ,finplan_arts_rn  => finplan_arts_rn /*RN строки бюджета */
                                ,scost_article    => scost_article /* Стаья затрат */);
    end if;
  end loop;

end;
/
