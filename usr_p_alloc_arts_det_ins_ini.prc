create or replace procedure usr_p_alloc_arts_det_ins_ini(sfaceacc out varchar2, sPeriod_code out varchar2) is
begin

  begin
    select f.numb
      into sfaceacc
      from stages st
      join faceacc f
        on f.rn = st.faceacc
     where st.rn = usr_pkg_pub_const.nnumber;
  exception
    when no_data_found then
      sfaceacc := null;
  end;
  
  sPeriod_code := usr_pkg_pub_const.svarchar;

end;
/
