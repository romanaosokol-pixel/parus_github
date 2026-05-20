create or replace procedure usr_p_st_fcacpayplans_pay
/*
Раздел: Договоры (этапы)
Процедура: Пересчитать исполнение плана платежей
03/12/2025 Степанов М.
*/
(
 nRN              in number
,dPAY_DATE_FROM   in date
,dPAY_DATE_TO     in date
)
is
  rRow    stages%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_ST_FCACPAYPLANS_PAY');

  /* Считывание */
  rRow := usr_pkg_contracts.stages_get( nrn => nRN );

  /* Выполнение процедуры для лицевого счёта этапа */
  usr_pkg_faceacc.faceacc_fcacpayplans_pay(nrn            => rRow.faceacc
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
