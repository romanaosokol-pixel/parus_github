create or replace procedure USR_P_IIV_SIGNTAX_UPDATE
/*
Приходные накладные. Заголовок. Исправить признак "Цены включают налоги" на правильные значения
08/04/2022 Степанов М.
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIV_SIGNTAX_UPDATE');

  /* Исправление заголовка */
  USR_PKG_ININVOICES.ININVOICES_UPDATE_SIGNTAX(nFLAGSMART => 0, NRN => nRN, nSIGNTAX => 1);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IIV_SIGNTAX_UPDATE;
/
