create or replace procedure USR_P_IOS_SIGNTAX_UPDATE
/*
Приходные ордера. Спецификация. Исправить признак "Цены включают налоги" на правильные значения
25/08/2023 Степанов М.
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IOS_SIGNTAX_UPDATE');

  usr_pkg_inorders.inorderspecs_update_pcr(nflagsmart => 0, nrn => nRN, nprice_calc_rule => 1);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IOS_SIGNTAX_UPDATE;
/
