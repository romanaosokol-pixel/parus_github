create or replace procedure USR_P_IO_SIGNTAX_UPDATE
/*
Приходные ордера. Заголовок. Исправить признак "Цены включают налоги" на правильные значения
08/04/2022 Степанов М.
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IO_SIGNTAX_UPDATE');

  /* Исправление заголовка */
  USR_PKG_INORDERS.INORDERS_UPDATE_SIGNTAX(nFLAGSMART => 0, NRN => nRN, nSIGNTAX => 1);

  /* Исправление спецификации */
  for c in (select * from INORDERSPECS where prn = nRN)
  loop
    USR_PKG_INORDERS.INORDERSPECS_UPDATE_PCR(nFLAGSMART => 0, NRN => c.rn, nPRICE_CALC_RULE => 1);
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IO_SIGNTAX_UPDATE;
/
