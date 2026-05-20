create or replace procedure usr_p_paynotesclc_ins_ini(ncompany         in number
                                                     ,nprn             in paynotes .rn%type
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
                                                     ,sfaceaccount     out faceacc.numb%type /*Привязка к проекту */
                                                     ,salloc_art_code  out faceacc.numb%type
                                                     ,salloc_art_rn    out faceacc.rn%type
                                                     ,salloc_name      out usr_t_alloc_arts.name%type /* Наименование подстатьи */
                                                     ,serr_txt         out varchar2
                                                     ,is_ok            out number ) is

  sper_year varchar2(4);
  nfaceacc  paynotes.faceacc%type;

begin

  begin
  
    select extract(year from pn.pay_date)
          ,sz.code
          ,pn.pay_sum - nvl((select sum(cl.sum_fact)
                              from paynotesclc cl
                             where cl.prn = pn.rn)
                           ,0)
          ,pn.faceacc
      into sper_year
          ,scost_article
          ,ncost_fact_sum /*Общая сумма по платежке - сумма ранее заведенных калькуляций*/
          ,nfaceacc
      from paynotes pn
      join faceacc f
        on f.rn = pn.faceacc
      left join fpdartcl sz
        on sz.rn = f.ieelement
     where pn.rn = nprn;
  exception
    when no_data_found then
      serr_txt := 'Не нашли запись журнала платежей.';
      return;
    
  end;

  /* Определяем подстатью бюджета, если она привязана к лицевому счету */

  usr_p_alloc_arts_det_faceacc(nfaceacc         => nfaceacc
                              ,sper_year        => sper_year
                              ,speriod          => speriod
                              ,scost_article    => scost_article
                              ,sbudj_code       => sbudj_code
                              ,finplan_rn       => finplan_rn
                              ,sdepord          => sdepord
                              ,sbudj_art_nmb    => sbudj_art_nmb
                              ,finplan_arts_rn  => finplan_arts_rn
                              ,allocation_sp_rn => allocation_sp_rn
                              ,salloc_art_rn    => salloc_art_rn
                              ,salloc_art_code  => salloc_art_code
                              ,salloc_art_nmb   => salloc_art_nmb
                              ,salloc_name      => salloc_name
                              ,out_err_txt      => serr_txt);

  --- if user = 'GOR' then p_exception(0, '64 '||sbudj_code||' '||salloc_art_code||' '||allocation_sp_rn); end if;                       
  if allocation_sp_rn is null
  then
  
    /*Если лицевой счет жестко не привязан к бюджету, то */
    /* Находим расчетный период */
    usr_p_enperiod_code_get(ncompany => ncompany, sper_year => sper_year, sper_code => speriod);
  
    /* Поиск бюджета и его параметров по "Периоду" и "составу затрат" */
  
    usr_p_finplan_get(ncompany            => ncompany
                     ,i_speriod           => speriod
                     ,i_sost_zatr         => scost_article
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
  
  end if;

  /*Определяем ШПЗ если этап проекта  привязан к подстатье бюджета */
  usr_p_shpz_get_get(ncompany => ncompany, nfaceacc => nfaceacc, nalloc_art_rn => salloc_art_rn, out_sfaceacc_shpz => sfaceaccount);
  ---  , nrn => null, sunitcode => null, speriod => speriod, nfaceacc => nfaceacc, salloc_art_rn => salloc_art_rn, out_sfaceacc_shpz => sfaceaccount);
  ---if user = 'GOR' then p_exception(0, '64 '||sbudj_code||' '||salloc_art_code||' '||allocation_sp_rn); end if;    
  
  is_ok :=0; /*Кнопка ОК недоступна, т.к. надо внести или лицевой счет или ШПЗ */
  
  
end;
/
