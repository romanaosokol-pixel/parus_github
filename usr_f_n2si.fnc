create or replace function usr_f_n2si
/*
Аналог штатной функции n2si с форматированием. Степанов М. 20/01/2021
*/
(
  N in number
)
return varchar2
as
begin
  return trim(to_char(N, NI_FORMAT));
end;
/*
grant execute on usr_f_n2si to public;
*/
/
