create or replace function USR_F_TRIM
/*
Функция обрезки. Заменяет все пробелы и переносы строк на пробелы в колчиестве, указанном в параметре nSPACES
31/01/2024 Степанов М.
grant execute on USR_F_TRIM to public;
*/
(
 sVAL       in varchar2
,nSPACES    in number default 1
)
return varchar2
as
begin
  return trim( regexp_replace( sVAL, '[[:space:]]+', rpad(' ', nSPACES) ) );
end USR_F_TRIM;
/
