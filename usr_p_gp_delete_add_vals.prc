create or replace procedure USR_P_GP_DELETE_ADD_VALS
/*
Приходные партии товара
Процедура "Удалить доп.данные Приходной партии"
09/04/2024 Степанов М.
*/
(
 nGOODSPARTIES in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GP_DELETE_ADD_VALS');

  usr_pkg_goodsparties_add.delete_vals(ngoodsparties => nGOODSPARTIES);
  

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GP_DELETE_ADD_VALS;
/
