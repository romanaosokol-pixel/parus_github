create or replace function usr_f_fcdelivsh_mr_rn(nrn fcdelivsh.rn%type) return varchar2 is
  v_nres fcroutlst.rn%type;
begin
  begin
    select dl.in_document
      into v_nres
      from doclinks dl
     where dl.out_document = nrn
       and dl.in_unitcode = 'CostRouteLists'
       and dl.out_unitcode = 'CostDeliverySheets'
       and rownum = 1;
  exception
    when no_data_found then
      return null;
  end;
  return to_char(v_nres);
end;
/
