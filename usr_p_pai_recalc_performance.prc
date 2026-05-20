create or replace procedure usr_p_pai_recalc_performance
/*
Раздел: Входящие счета на оплату.
Пересчитать исполнение
07/11/2024 Степанов М.
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_RECALC_PERFORMANCE');

  usr_pkg_payaccin.payaccin_recalc_performance(nrn => nRN);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end USR_P_PAI_RECALC_PERFORMANCE;
/
