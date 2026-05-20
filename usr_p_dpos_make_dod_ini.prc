create or replace procedure usr_p_dpos_make_dod_ini(nrn   in departmentords.rn%type
                                                   ,snote out departmentords.note%type) is

begin

  begin
    select strcombine(zp.note
                     ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'ÊÎÌÌ_ÇÀßÂÊÈ'
                                                         ,sunitcode  => 'DepartmentsOrders'
                                                         ,ndocument  => zp.rn)
                     ,'/')
      into snote
      from departmentords zps
      join departmentord zp
        on zp.rn = zps.prn
     where zps.rn = nrn;
  
  exception
    when no_data_found then
      snote := null;
  end;
end;
/
