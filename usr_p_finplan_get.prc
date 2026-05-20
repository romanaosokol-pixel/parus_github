create or replace procedure usr_p_finplan_get(ncompany            in number
                                             ,i_speriod           in enperiod.code%type
                                             ,i_sost_zatr         in fpdartcl.code%type
                                             ,out_fp_code         out udo_t_finplan.fp_code%type
                                             ,out_fp_rn           out udo_t_finplan.rn%type
                                             ,out_dep_code        out ins_department.code%type
                                             ,out_finplan_arts    out udo_t_finplan_arts.art_numb%type
                                             ,out_finplan_arts_rn out udo_t_finplan_arts.rn%type
                                             ,out_err_txt         out varchar2) is

begin
/* Поиск бюджета и его параметров по "Периоду" и "составу затрат" */

  begin
    select t.fp_code
          ,t.rn
          ,dep.code
          ,ts.art_numb
          ,ts.rn
      into out_fp_code
          ,out_fp_rn
          ,out_dep_code
          ,out_finplan_arts
          ,out_finplan_arts_rn
      from udo_t_finplan t
      join enperiod per
        on per.rn = t.fp_period
      join doctypes dt
        on dt.rn = t.fp_type
      join dicsmrks gb
        on gb.rn = t.groupbudg
      join ins_department dep
        on dep.rn = t.depord
      join udo_t_finplan_arts ts
        on ts.prn = t.rn
      join fpdartcl sz
        on sz.rn = ts.fpdartcl
      join ins_department dep
        on dep.rn = t.depord
     where per.code = i_speriod
       and t.company = ncompany
       and dt.doccode = 'БДДСП_подр'
       and gb.smark_mnemo = 'ПЛАН'
       and sz.code = i_sost_zatr
       and sz.version = 91451;
  
  exception
    when no_data_found then
      out_err_txt := 'Бюджет не найден';
      return;
    when too_many_rows then
      out_err_txt := 'Бюджет не может быть определен однозначно';
      return;
  end;
  out_err_txt := null;
end;
/
