create or replace procedure usr_p_paynotesclc_upd_ini(ncompany         in number
                                                     ,nrn              in paynotesclc.rn%type
                                                     ,sdepord          out ins_department.code%type --
                                                     ,speriod          out enperiod.code%type --
                                                     ,sbudj_code       out udo_t_finplan.fp_code%type ---
                                                     ,finplan_rn       out udo_t_finplan.rn%type --
                                                     ,scost_article    out fpdartcl.code%type --
                                                     ,sbudj_art_nmb    out udo_t_finplan_arts.art_numb%type --
                                                     ,finplan_arts_rn  out udo_t_finplan_arts.rn%type --
                                                     ,salloc_art_nmb   out usr_t_alloc_arts.art_numb%type --
                                                     ,allocation_sp_rn out usr_t_alloc_arts.rn%type --
                                                     ,ncost_fact_sum   out paynotesclc.sum_fact%type --
                                                     ,sfaceaccount     out faceacc.numb%type --
                                                     ,salloc_art_code  out faceacc.numb%type
                                                     ,salloc_art_rn    out faceacc.rn%type
                                                     ,salloc_name      out usr_t_alloc_arts.name%type
                                                     ,nquant           out number
                                                     ,limit_year       out number
                                                     ,cost_year        out number
                                                     ,balance_year     out number                                                      
                                                     ,serr_txt out varchar2) is

  sper_year varchar2(4);
  nfaceacc  paynotes.faceacc%type;

  v_sdepord ins_department.code%type;
  v_speriod enperiod.code%type;

begin

  nquant := 1;

  begin
  
    select clc.sum_fact
          ,f.numb
          ,sz.code
          ,usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 260664294, sunitcode => 'PayNotesCalcs', ndocument => clc.rn)
          ,usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 260630987, sunitcode => 'PayNotesCalcs', ndocument => clc.rn)
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 260630065, sunitcode => 'PayNotesCalcs', ndocument => clc.rn)
          ,dep.code
      into ncost_fact_sum
          ,sfaceaccount
          ,scost_article
          ,finplan_arts_rn
          ,allocation_sp_rn
          ,speriod
          ,sdepord
      from paynotesclc clc
      left join faceacc f
        on f.rn = clc.faceaccount
      left join fpdartcl sz
        on sz.rn = clc.cost_article
      left join ins_department dep
        on dep.rn = clc.subdiv
     where clc.rn = nrn;
  exception
    when no_data_found then
      serr_txt := 'Не нашли запись калькуляции журнала платежей.';
      return;
    
  end;

  /* Поиск бюджета и его параметров по строке бюджета */
  begin
    select bj.rn
          ,bj.fp_code
          ,bjs.art_numb
      into finplan_rn
          ,sbudj_code
          ,sbudj_art_nmb
      from udo_t_finplan_arts bjs
      join udo_t_finplan bj
        on bj.rn = bjs.prn
     where bjs.rn = finplan_arts_rn;
  exception
    when no_data_found then
    
      /* Поиск бюджета и его параметров по "Периоду" и "составу затрат" */
    
      usr_p_finplan_get(ncompany            => ncompany
                       ,i_speriod           => speriod
                       ,i_sost_zatr         => scost_article
                       ,out_fp_code         => sbudj_code
                       ,out_fp_rn           => finplan_rn
                       ,out_dep_code        => v_sdepord
                       ,out_finplan_arts    => sbudj_art_nmb
                       ,out_finplan_arts_rn => finplan_arts_rn
                       ,out_err_txt         => serr_txt);
    
      /* Если подстатья не задана в свойстве и она заданной  статьи единственная, то вернем ее сразу  */
      if allocation_sp_rn is null
      then
        usr_p_calc_one_subitems_get(finplan_arts_rn    => finplan_arts_rn
                                   ,o_salloc_art_nmb   => salloc_art_nmb
                                   ,o_allocation_sp_rn => allocation_sp_rn
                                   ,o_salloc_art_lic   => salloc_art_code
                                   ,o_salloc_art_rn    => salloc_art_rn
                                   ,o_err_txt          => serr_txt);
      end if;
    
  end;

  if salloc_art_nmb is null
  then
    begin
      select brs.art_numb
            ,brs.name
        into salloc_art_nmb
            ,salloc_name
        from usr_t_alloc_arts brs
       where brs.rn = allocation_sp_rn;
    exception
      when no_data_found then
        null;
    end;
  
  end if;

  if sfaceaccount is null
  then
    /*Определяем ШПЗ*/
    usr_p_shpz_get_get(ncompany          => ncompany                     
                      ,nfaceacc          => nfaceacc
                      ,salloc_art_rn     => salloc_art_rn
                      ,out_sfaceacc_shpz => sfaceaccount);
  end if;

limit_year:= usr_f_finplan_art_limit(finplan_arts_rn, 0);

end;
/
