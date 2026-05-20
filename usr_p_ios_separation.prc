create or replace procedure USR_P_IOS_SEPARATION
/*
Приходные ордера. Спецификация. Разделить спецификацию на несколько с количеством 1
02/20/2023 Степанов М.
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IOS_SEPARATION');

  usr_pkg_inorders.inorderspecs_separation(nrn => nRN);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IOS_SEPARATION;
/
