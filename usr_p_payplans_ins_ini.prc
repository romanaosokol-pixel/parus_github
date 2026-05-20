create or replace procedure usr_p_payplans_ins_ini(ncompany         in number
                                                  ,nprn             in faceacc.rn%type
                                                  ,sdepord          out ins_department.code%type
                                                  ,speriod          out enperiod.code%type
                                                  ,sbudj_code       out udo_t_finplan.fp_code%type
                                                  ,finplan_rn       out udo_t_finplan.rn%type
                                                  ,scost_article    out fpdartcl.code%type
                                                  ,sbudj_art_nmb    out udo_t_finplan_arts.art_numb%type
                                                  ,finplan_arts_rn  out udo_t_finplan_arts.rn%type
                                                  ,salloc_art_nmb   out usr_t_alloc_arts.art_numb%type
                                                  ,allocation_sp_rn out usr_t_alloc_arts.rn%type
                                                  ,ncost_fact_sum   out paynotesclc.sum_fact%type
                                                  ,sfaceaccount     out faceacc.numb%type
                                                  ,salloc_art_code out faceacc.numb%type
                                                  ,salloc_art_rn   out faceacc.rn%type
                                                  ,serr_txt        out varchar2) is

  sper_year varchar2(4);
  ---  nfaceacc  paynotes.faceacc%type;

begin

  for cur in (
              
              select extract(year from gp.end_date) sper_year
                     ,sz.code scost_article
                     ,sz.rn sz_rn
                from fcacpayplans gp
                join faceacc f
                  on f.rn = gp.prn
                join fpdartcl sz
                  on sz.rn = f.ieelement
               where gp.rn = nprn)
  
  loop
  
    /* Находим расчетный период */
    usr_p_enperiod_code_get(ncompany => ncompany, sper_year => cur.sper_year, sper_code => speriod);
  
    /*Определяем Бюджета и статью бюджет*/
  
    usr_p_finplan_get(ncompany            => ncompany
                     ,i_speriod           => speriod
                     ,i_sost_zatr         => cur.scost_article
                     ,out_fp_code         => sbudj_code
                     ,out_fp_rn           => finplan_rn
                     ,out_dep_code        => sdepord
                     ,out_finplan_arts    => sbudj_art_nmb
                     ,out_finplan_arts_rn => finplan_arts_rn
                     ,out_err_txt         => serr_txt);
  
    /* Если подстатья у статьи единственная, то вернем ее сразу  */
  
    usr_p_calc_one_subitems_get(finplan_arts_rn    => finplan_arts_rn
                               ,o_salloc_art_nmb   => salloc_art_nmb
                               ,o_allocation_sp_rn => allocation_sp_rn
                               ,o_salloc_art_lic   => salloc_art_code
                               ,o_salloc_art_rn    => salloc_art_rn
                               ,o_err_txt          => serr_txt);
  
  end loop;

end;
/*
    \*Определяем ШПЗ*\
    usr_p_shpz_get_get(ncompany          => ncompany
                      ,nrn               => null
                      ,sunitcode         => null
                      ,speriod           => speriod
                      ,nfaceacc          => nfaceacc
                      ,SALLOC_ART_RN    => SALLOC_ART_RN
                      ,out_sfaceacc_shpz => sfaceaccount);
  
  end;*/
/
