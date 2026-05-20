create or replace procedure usr_p_fcacpayplans_update
/*
Лицевые счета (план платежей). Исправить
02/12/2025 Степанов М.
*/
(
 nRN              in number
,sGRAPHPOINT      in varchar2
,sPAY_TYPE        in varchar2
)
is
  rV_Row          v_fcacpayplans%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_FCACPAYPLANS_UPDATE');

  /* Считывание */
  select * into rV_Row from v_fcacpayplans where nrn = usr_p_fcacpayplans_update.nrn;

  /* Подмена значений */
  rv_row.spay_type    := nvl( sPAY_TYPE, rv_row.sgraphpoint ) ;
  rv_row.sgraphpoint  := nvl( sGRAPHPOINT, rv_row.sgraphpoint ) ;

  /* Исправление */
  usr_pkg_faceacc.fcacpayplans_update( rv_row => rv_row, nmode => 0 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
