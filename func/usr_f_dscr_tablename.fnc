create or replace function USR_F_DSCR_TABLENAME
/*
Функция для колонки "#Имя таблицы".
Раздел: Все разделы, в представлении которых есть поле.
27/11/2023 Степанов М.
grant execute on USR_F_DSCR_TABLENAME to public;
*/
(
 sUNITCODE  in varchar2
)
return varchar2
is
  sRes    pkg_std.tstring; 
begin
  find_unitlist_table(nflag_smart => 1
                     ,sunitcode   => sUNITCODE
                     ,stablename  => sRes);
  return sRes;
end USR_F_DSCR_TABLENAME;
/
