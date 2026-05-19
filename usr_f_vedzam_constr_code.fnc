create or replace function usr_f_vedzam_constr_code(nrn udo_deporddir.rn%type ) return varchar2 is
  v_res agnlist.agnabbr%type;

begin
  begin
    select a.agnabbr into v_res from agnlist a where a.rn = usr_f_vedzam_constr_rn(nrn);
  exception
    when no_data_found then
      return null;
  end;
  return v_res;
end;
/
