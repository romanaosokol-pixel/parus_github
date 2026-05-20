create or replace function USR_F_FA_STATUS_NAME
/*
03/09/2024 Степанов М.
Раздел "Лицевые счета".
Функция для колонки "#Состояние"
grant execute on USR_F_FA_STATUS_NAME to public;
*/
(
 dFACT_OPEN_DATE    in date
,dFACT_CLOSE_DATE   in date
)
return varchar2
as
begin
  return usr_pkg_faceacc.faceacc_get_status_name(dfact_open_date => dFACT_OPEN_DATE, dfact_close_date => dFACT_CLOSE_DATE);
end USR_F_FA_STATUS_NAME;
/
