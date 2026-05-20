create or replace procedure usr_p_paynotesclc_calc(nrn paynotes.rn%type) is

  /*
  
  Расчет калькуляции строки журнала платежей
  для фактических платежей
  
  Если ПЛАНОВЫЙ платеж, по которому создан фактический платеж,  создан из входящего счета, то формировать калькуляцию не надо, она уже задана в счете!
  
  эмулируется ручной вызов процедуры заведения калькуляции с валидаторами
  
  Городецкий О.И. 06-05-2026
  
  */

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
  salloc_art_rn    faceacc.rn%type;
  serr_txt         varchar2(2000);
  salloc_name      varchar2(2000);
  is_ok            number(1);

begin

  for cur in (select pn.company
                from paynotes pn
               where pn.rn = nrn)
  loop
  
    usr_p_paynotesclc_ins_ini(ncompany         => cur.company
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
                             ,salloc_art_rn    => salloc_art_rn
                             ,salloc_name      => salloc_name
                             ,serr_txt         => serr_txt
                             ,is_ok            => is_ok);
  
    --- if user = 'PARUS' then p_exception(0, '55 '||sbudj_code||' '||salloc_art_code||' '||allocation_sp_rn); end if;
  
    usr_p_paynotesclc_insert(ncompany         => cur.company
                            ,nprn             => nrn
                            ,sdepord          => sdepord
                            ,speriod          => speriod
                            ,salloc_art_code  => salloc_art_code
                            ,sfaceaccount     => sfaceaccount
                            ,ncost_fact_sum   => ncost_fact_sum
                            ,allocation_sp_rn => allocation_sp_rn
                            ,finplan_arts_rn  => finplan_arts_rn
                            ,scost_article    => scost_article);
  
  end loop;

end;
/
