create or replace function usr_f_stages_get_fa_status
/*
Раздел Договоры (этапы)
Функция для колонки "#Лицевой счёт. Состояние"
create public synonym usr_f_stages_get_fa_status for usr_f_stages_get_fa_status;
grant execute on usr_f_stages_get_fa_status to public;
*/
(
 nFACEACC   in number
)
return varchar2
is
  rFaceAcc  faceacc%rowtype;
  sRes      pkg_std.tstring;
begin
  rFaceAcc := usr_pkg_faceacc.faceacc_get( nrn => nFACEACC );
  sRes     := usr_pkg_faceacc.faceacc_get_status_name( dfact_open_date => rFaceAcc.fact_open_date, dfact_close_date => rFaceAcc.fact_close_date );
  return sRes;
end;
/
