create or replace function USR_F_DSCR_UNITCODE
/*
Функция для колонки "#Код раздела".
Раздел: Все разделы, в представлении которых есть поле.
27/11/2023 Степанов М.
grant execute on USR_F_DSCR_UNITCODE to public;
*/
(
 sUNITCODE  in varchar2
)
return varchar2
is
begin
  return sUNITCODE;
end USR_F_DSCR_UNITCODE;
/
