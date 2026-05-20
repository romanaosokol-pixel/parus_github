create or replace procedure usr_p_fa_fcacpayplans_pay
/*
Раздел: Лицевые счета
Процедура:   Пересчитать исполнение плана платежей
02/12/2025 Степанов М.
*/
(
 nRN              in number
,dPAY_DATE_FROM   in date
,dPAY_DATE_TO     in date
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'usr_p_fa_fcacpayplans_pay');

  /* Выполнение процедуры */
  usr_pkg_faceacc.faceacc_fcacpayplans_pay(nrn            => nRN
                                          ,dpay_date_from => dPAY_DATE_FROM
                                          ,dpay_date_to   => dPAY_DATE_TO);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
