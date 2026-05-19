create or replace function usr_f_n2sc
/*
Аналог штатной функции n2sc с форматированием. Степанов М. 20/01/2021
*/
(
  N in number
)
return varchar2
as
begin
  return trim(to_char(N,'999G999G999G999G999G990D99999', 'NLS_NUMERIC_CHARACTERS = '', '''));
end;
/*
grant execute on usr_f_n2sc to public;
*/
/
