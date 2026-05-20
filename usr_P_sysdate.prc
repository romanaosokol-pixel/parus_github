create or replace procedure usr_P_sysdate(out_sysdate out date) is
begin
  out_sysdate := sysdate;
end;
/
