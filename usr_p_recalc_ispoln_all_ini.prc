create or replace procedure usr_p_recalc_ispoln_all_ini(nrn      in number
                                                       ,out_year out varchar2) is

  v_nrn number(17) := nrn;

begin

  begin
    select extract(year from t.dper_datebeg)
      into out_year
      from usr_v_budget_allocation t    
     where t.nrn = v_nrn;
  
  exception
    when no_data_found then
      out_year := extract(year from sysdate);
  end;

end;
/
