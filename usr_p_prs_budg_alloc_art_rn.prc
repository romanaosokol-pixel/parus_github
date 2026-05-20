create or replace procedure usr_p_prs_budg_alloc_art_rn(nrn           paynotes.rn%type
                                                       ,ncompany      paynotes.company%type
                                                       ,nalloc_art_rn out faceacc.rn%type
                                                       ,serr_txt      out varchar2) is

  nyear         number(4);
  speriod       enperiod.code%type;
  scost_article fpdartcl.code%type;

  sbudj_code      udo_t_finplan.fp_code%type;
  finplan_rn      udo_t_finplan.rn%type;
  sdepord         ins_department.code%type;
  sbudj_art_nmb   udo_t_finplan_arts.art_numb%type;
  finplan_arts_rn udo_t_finplan_arts.rn%type;

  salloc_art_code faceacc.numb%type; /* Лицевой счет, определяющий статью затрат */

  salloc_art_nmb   usr_t_alloc_arts.art_numb%type;
  allocation_sp_rn number(17);

begin

  begin
  
    select extract(year from per.enddate)
          ,sz.code
      into nyear
          ,scost_article
      from udo_projectstage_pbudg t
      join projectstage prs
        on prs.rn = t.prn
      join faceacc f
        on f.rn = prs.faceacccust
      join fpdartcl sz
        on sz.rn = f.ieelement
      join enperiod per
        on per.rn = t.period
     where t.rn = nrn;
  exception
    when no_data_found then
      serr_txt := 'Строка Проекты(Этапы, распределение статей бюджета не найдена для RN = ' || nrn;
    return;
    
  end;

  /* Находим расчетный период */
  usr_p_enperiod_code_get(ncompany => ncompany, sper_year => nyear, sper_code => speriod);

  if speriod is null
  then
    serr_txt := 'Учетный период для года ' || nyear || ' не найден';
    return;
  end if;

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

  if serr_txt is not null
  then
    return;
  end if;

  /* Если подстатья у статьи единственная, то вернем ее сразу  */

  usr_p_calc_one_subitems_get(finplan_arts_rn    => finplan_arts_rn
                             ,o_salloc_art_nmb   => salloc_art_nmb
                             ,o_allocation_sp_rn => allocation_sp_rn
                             ,o_salloc_art_lic   => salloc_art_code
                             ,o_salloc_art_rn    => nalloc_art_rn
                             ,o_err_txt          => serr_txt);
                             
  --- if user = 'PARUS' then P_exception(0, 81||' --> '||nalloc_art_rn||' --> '||serr_txt); end if;                          

end;
/
