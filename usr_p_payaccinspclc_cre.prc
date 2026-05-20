create or replace procedure usr_p_payaccinspclc_cre(nrn in payaccin.rn%type) is

  sdepord            ins_department.code%type;
  speriod            enperiod.code%type;
  sfp_type           doctypes.doccode%type; /* “ип бюджета */
  sbudj_code         udo_t_finplan.fp_code%type;
  scost_article      fpdartcl.code%type;
  sbudj_art_nmb      udo_t_finplan_arts.code%type;
  sfaceaccount       faceacc.numb%type;
  salloc_art_nmb     usr_t_alloc_arts.art_numb%type;
  salloc_name        usr_t_alloc_arts.name%type;
  nquant_plan        payaccinspclc.quant_plan%type;
  nsum_plan          payaccinspclc.cost_plan%type;
  finplan_rn         udo_t_finplan.rn%type;
  finplan_arts_rn    udo_t_finplan_arts.rn%type;
  allocation_sp_rn   usr_t_alloc_arts.rn%type;
  sbudj_code_enb     number(1);
  sbudj_art_nmb_enb  number(1);
  scost_article_enb  number(1);
  salloc_art_nmb_enb number(1);
  limit_year         usr_t_alloc_arts_v.val%type;
  salloc_art_nmb_clr varchar2(40); /*÷вет €чейки*/
  is_allc_art_nmb    number(1);
  is_ok              number(1);
  err_txt            varchar2(2000);

  n_fl number(1); /*ѕризнак наличи€ еалькул€ции у спецификации счета*/

begin

  /*»справление/ƒобавление калькул€ции вход€щего счета, значени€ми по умолчанию */

  /*—татью затрат берем из лицевого счета */
  scost_article := udo_f_payaccin_faceacc_article(nrn => nrn);

  /*1 ќтберем все строки спецификации вход€щего счета */

  for spe in (select ps.rn
                    ,ps.company com
                from payaccinspec ps
               where ps.prn = nrn)
  
  loop
    /* ќтбираем все калькул€ции, которые созданы по лицевому счету */
  
    n_fl := 0;
  
    for cl in (select clс.rn
                     ,clс.company com
                     ,clс.prn
                 from payaccinspclc clс
                where clс.prn = spe.rn)
    
    loop
    
      n_fl := 1;
      /* ќбновим калькул€цию (»митаци€ вызова действи€ "»справить калькул€цию" */
    
      usr_p_payaccinspclc_update_ini(nrn                => cl.rn                        
                                    ,ncompany           => cl.com
                                    ,nprn               => cl.prn
                                    ,sdepord            => sdepord
                                    ,speriod            => speriod
                                    ,sfp_type           => sfp_type
                                    ,sbudj_code         => sbudj_code
                                    ,scost_article      => scost_article
                                    ,sbudj_art_nmb      => sbudj_art_nmb
                                    ,sfaceaccount       => sfaceaccount
                                    ,salloc_art_nmb     => salloc_art_nmb
                                    ,salloc_name        => salloc_name
                                    ,nquant_plan        => nquant_plan
                                    ,nsum_plan          => nsum_plan
                                    ,finplan_rn         => finplan_rn
                                    ,finplan_arts_rn    => finplan_arts_rn
                                    ,allocation_sp_rn   => allocation_sp_rn
                                    ,sbudj_code_enb     => sbudj_code_enb
                                    ,sbudj_art_nmb_enb  => sbudj_art_nmb_enb
                                    ,scost_article_enb  => scost_article_enb
                                    ,salloc_art_nmb_enb => salloc_art_nmb_enb
                                    ,limit_year         => limit_year
                                    ,cost_year          => limit_year
                                    ,balance_year       => limit_year
                                    ,salloc_art_nmb_clr => salloc_art_nmb_clr
                                    ,is_allc_art_nmb    => is_allc_art_nmb
                                    ,is_OK => is_ok
                                    ,err_txt => ERR_TXT
                                    
                                    );
                                    
/*if user = 'GOR' 
then P_exception(0,salloc_art_nmb||' allocation_sp_rn '||allocation_sp_rn); 
end if; */                                    
    
      usr_p_payaccinspclc_update(nrn              => cl.rn
                                ,ncompany         => spe.com
                                ,sdepord          => sdepord
                                ,speriod          => speriod
                                ,sfp_type         => sfp_type
                                ,sbudj_code       => sbudj_code
                                ,scost_article    => scost_article
                                ,sbudj_art_nmb    => sbudj_art_nmb
                                ,salloc_art_nmb   => salloc_art_nmb
                                ,allocation_sp_rn => allocation_sp_rn
                                ,finplan_arts_rn  => finplan_arts_rn
                                ,sfaceaccount     => sfaceaccount
                                ,nquant_plan      => nquant_plan
                                ,nsum_plan        => nsum_plan);
    
    end loop; /*кнц калькул€ции*/
  
    if n_fl = 0
    then
      /* алькул€ци€ в спецификации счета не найдена и ее заводим */
    
      ---- «аводим калькул€цию
      usr_p_payaccinspclc_insert_ini(nrn                => null                          
                                    ,nprn               => spe.rn
                                    ,ncompany           => spe.com
                                    ,speriod            => speriod
                                    ,sdepord            => sdepord
                                    ,sbudj_code         => sbudj_code
                                    ,finplan_rn         => finplan_rn
                                    ,finplan_arts_rn    => finplan_arts_rn
                                    ,sfaceaccount       => sfaceaccount
                                    ,nquant_fact        => nquant_plan
                                    ,ncost_fact_sum     => nsum_plan
                                    ,sbudj_art_nmb      => sbudj_art_nmb
                                    ,salloc_art_nmb     => salloc_art_nmb
                                    ,allocation_sp_rn   => allocation_sp_rn
                                    ,sbudj_code_enb     => sbudj_code_enb
                                    ,sbudj_art_nmb_enb  => sbudj_art_nmb_enb
                                    ,scost_article_enb  => scost_article_enb
                                    ,salloc_art_nmb_enb => salloc_art_nmb_enb
                                    ,limit_year         => limit_year
                                    ,cost_year          => limit_year
                                    ,balance_year       => limit_year
                                    ,salloc_art_nmb_clr => salloc_art_nmb_clr
                                    ,is_allc_art_nmb    => is_allc_art_nmb
                                    ,is_ok              => is_ok
                                    ,err_txt            => err_txt);
    
      usr_p_payaccinspclc_insert(ncompany         => spe.com
                                ,nprn             => spe.rn
                                ,sdepord          => sdepord
                                ,speriod          => speriod
                                ,sbudj_code       => sbudj_code
                                ,sfp_type         => sfp_type
                                ,sbudj_art_nmb    => sbudj_art_nmb
                                ,salloc_art_nmb   => salloc_art_nmb
                                ,sfaceaccount     => sfaceaccount
                                ,nquant_fact      => nquant_plan
                                ,ncost_fact_sum   => nsum_plan
                                ,allocation_sp_rn => allocation_sp_rn
                                ,finplan_arts_rn  => finplan_arts_rn
                                ,scost_article    => scost_article);
    
    end if;
  
  end loop; /*кнц спецификации*/

end;
/
