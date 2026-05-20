create or replace procedure usr_p_alloc_arts_det_upd_i(nrn               in number
                                                      ,speriod_code      out varchar2
                                                      ,dep_code          out varchar2
                                                      ,sbudg_rn          out number
                                                      ,sbudj_code        out varchar2
                                                      ,finplan_arts      out number
                                                      ,sbudg_art_code    out varchar2
                                                      ,proj_rn           out number
                                                      ,sproject_stage_fc out varchar2) is

begin
/*
Валидатор на открытие
для формы исправления детализации  бюджетного распределения
Городецкий

*/
  begin
  
    select per.code
          ,dep.code
          ,bj.rn
          ,bj.fp_code
          ,bjs.rn
          ,bjs.code
          ,prs.prn
          ,pf.numb
      into speriod_code
          ,dep_code
          ,sbudg_rn
          ,sbudj_code
          ,finplan_arts
          ,sbudg_art_code
          ,proj_rn
          ,sproject_stage_fc
      from usr_t_alloc_arts_det det
      join udo_t_finplan_arts bjs
        on bjs.rn = det.finplan_arts
      join udo_t_finplan bj
        on bj.rn = bjs.prn
      join enperiod per
        on per.rn = bj.fp_period
      join ins_department dep
        on dep.rn = bj.depord
      left join projectstage prs
        on prs.rn = det.projectstage
      left join faceacc pf
        on pf.rn = prs.faceacc
     where det.rn = nrn;
  
  exception
    when no_data_found then
      null;
    
  end;

end;
/
