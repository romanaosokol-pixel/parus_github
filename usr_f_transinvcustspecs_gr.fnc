create or replace function usr_f_transinvcustspecs_gr(nrn transinvcustspecs.rn%type) return varchar2 is
  v_res fcacoperplans.numb%type;
begin
  begin
    select trim(gr.numb)
      into v_res
      from transinvcustspecs t
      join udo_t_transinvcustspecs_ex ex
        on ex.prn = t.rn
      join fcacoperplans gr
        on gr.rn = ex.fcacoperplans
     where t.rn = nrn;
  exception
    when no_data_found then
      return null;
  end;
  return v_res;
end;
/
