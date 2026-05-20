create or replace procedure usr_p_budget_alloc_insert_ini(sdoc_type out varchar2
                                                         ,ddocdate  out date) is

begin
  sdoc_type := 'ап';
  ddocdate  := trunc(sysdate);
end;
/
