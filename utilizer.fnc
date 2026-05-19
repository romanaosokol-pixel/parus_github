create or replace function UTILIZER
return varchar2
as
begin
  return nvl(sys_context('PARUS'||'$'||lpad(ltrim(to_char(to_number(sys_context('USERENV','CURRENT_SCHEMAID')),'XXXXXXXX')),8,'0')||'$'||'SYSTEM','UTILIZER'),sys_context('USERENV','SESSION_USER'));
end UTILIZER;
/

