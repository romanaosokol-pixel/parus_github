create or replace procedure usr_p_alloc_arts_det_faceacc(nfaceacc        in usr_t_alloc_arts_det.faceacc%type
                                                        ,sper_year       in varchar2
                                                        ,speriod         out enperiod.code%type
                                                        ,scost_article   out fpdartcl.code%type
                                                        ,sbudj_code      out udo_t_finplan.fp_code%type
                                                        ,finplan_rn      out udo_t_finplan.rn%type
                                                        ,sdepord         out ins_department.code%type
                                                        ,sbudj_art_nmb   out udo_t_finplan_arts.art_numb%type
                                                        ,finplan_arts_rn out udo_t_finplan_arts.rn%type
                                                        ,allocation_sp_rn out USR_T_ALLOC_ARTS.RN%type
                                                        ,salloc_art_rn    out faceacc.rn%type   
                                                        ,salloc_art_code  out faceacc.numb%type             
                                                        ,salloc_art_nmb   out usr_t_alloc_arts.art_numb%type 
                                                        ,salloc_name      out usr_t_alloc_arts.name%type /* Наименование подстатьи */
                                                        ,out_err_txt     out varchar2) is

  /*
  Нахождение параметров калькуляции если подстатья бюджета привязана к лицевому счету.
  Городецкий О.И. 06-05-2026
  */

begin
  begin
    select per.code
          ,sz.code
          ,bj.fp_code
          ,bj.rn
          ,dep.code
          ,bjs.art_numb
          ,bjs.rn
          ,brs.rn         
          ,F.rn
          ,F.numb
          ,brs.art_numb
          ,BRS.NAME
      into speriod                    
          ,scost_article
          ,sbudj_code
          ,finplan_rn
          ,sdepord
          ,sbudj_art_nmb
          ,finplan_arts_rn
          ,allocation_sp_rn
          ,salloc_art_rn  
          ,salloc_art_code
          ,SALLOC_ART_NMB
          ,salloc_name
      from usr_t_alloc_arts_det brsd
      join usr_t_alloc_arts brs
        on brs.rn = brsd.prn
      join udo_t_finplan_arts bjs
        on bjs.rn = brs.finplan_arts
      join udo_t_finplan bj
        on bj.rn = bjs.prn
      join enperiod per
        on per.rn = bj.fp_period
      join fpdartcl sz
        on sz.rn = bjs.fpdartcl
      join ins_department dep
        on dep.rn = bj.depord
      join faceacc f
        on f.rn = brs.faceacc_cost  
     where brsd.faceacc = nfaceacc
       and extract(year from per.startdate) = sper_year;
  exception
    when no_data_found then
      return; /*Это лицевой счет не привязан к подстатье бюджета*/
  
    when too_many_rows then
      out_err_txt := 'Лицевой счет привязан к нескольким статьям бюджета в ' || sper_year || ' году. Это недопустимо, привязка доолжна быть только к одной статье.';
    
  end;

end;
/
