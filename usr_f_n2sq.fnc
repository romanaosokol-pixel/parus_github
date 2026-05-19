create or replace function usr_f_n2sq
/*
Аналог штатной функции n2sq с форматированием. Степанов М. 20/01/2021
*/
(
  N in number
)
return varchar2
as
begin
  return trim(to_char(N,'999G999G999G999G999G990D999', 'NLS_NUMERIC_CHARACTERS = '', '''));
end;
/*
grant execute on usr_f_n2sq to public;
*/
/
