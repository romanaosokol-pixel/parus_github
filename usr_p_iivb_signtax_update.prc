create or replace procedure USR_P_IIVB_SIGNTAX_UPDATE
/*
Приходные накладные. Заголовок (буфер).
Исправить признак "Цены включают налоги" на правильные значения
25/09/2023 Степанов М.
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIVB_SIGNTAX_UPDATE');

  /* Исправление */
  usr_pkg_ininvoices.ininvoicesbuff_update_signtax(nflagsmart => 0, nrn => nRN, nsigntax => 1);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IIVB_SIGNTAX_UPDATE;
/
