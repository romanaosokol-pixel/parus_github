create or replace function usr_f_mark_base_sprn
(
  nfaceacc      number
 ,ncost_faceacc number
) return varchar2 is

  v_res varchar2(17);
/* RN Этапа договора или этапа проекта, если договора нет */
begin
  begin
    select to_char(st.rn) into v_res from stages st where st.faceacc = nfaceacc;
  exception
    when no_data_found then
      begin
        select to_char(st.rn) into v_res from projectstage st where st.faceacc = ncost_faceacc;
      exception
        when no_data_found then
          return '-';
      end;
    
  end;

  return v_res;

end;
/
