create or replace procedure usr_paynotes_alloc_art_rn(nrn           paynotes.rn%type
                                                     ,ncompany      paynotes.company%type
                                                     ,nalloc_art_rn out faceacc.rn%type) is

  sdepord          ins_department.code%type;
  speriod          enperiod.code%type;
  sbudj_code       udo_t_finplan.fp_code%type;
  finplan_rn       udo_t_finplan.rn%type;
  scost_article    fpdartcl.code%type;
  sbudj_art_nmb    udo_t_finplan_arts.art_numb%type;
  finplan_arts_rn  udo_t_finplan_arts.rn%type;
  salloc_art_nmb   usr_t_alloc_arts.art_numb%type;
  allocation_sp_rn usr_t_alloc_arts.rn%type;
  ncost_fact_sum   paynotesclc.sum_fact%type;
  sfaceaccount     faceacc.numb%type;
  salloc_art_code  faceacc.numb%type;
  salloc_name      usr_t_alloc_arts.Name%type;
  serr_txt         varchar2(2000);
  is_ok number(1);

begin

  usr_p_paynotesclc_ins_ini(ncompany         => ncompany
                           ,nprn             => nrn
                           ,sdepord          => sdepord
                           ,speriod          => speriod
                           ,sbudj_code       => sbudj_code
                           ,finplan_rn       => finplan_rn
                           ,scost_article    => scost_article
                           ,sbudj_art_nmb    => sbudj_art_nmb
                           ,finplan_arts_rn  => finplan_arts_rn
                           ,salloc_art_nmb   => salloc_art_nmb
                           ,allocation_sp_rn => allocation_sp_rn
                           ,ncost_fact_sum   => ncost_fact_sum
                           ,sfaceaccount     => sfaceaccount
                           ,salloc_art_code  => salloc_art_code
                           ,salloc_art_rn    => nalloc_art_rn
                           ,salloc_name => salloc_name
                           ,serr_txt         => serr_txt
                           ,is_ok =>is_ok);

end;
/
