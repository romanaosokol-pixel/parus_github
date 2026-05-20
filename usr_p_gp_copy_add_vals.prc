create or replace procedure USR_P_GP_COPY_ADD_VALS
/*
Приходные партии товара
Процедура "Копировать доп.данные Приходной партии из другой"
08/04/2024 Степанов М.
*/
(
 nGOODSPARTIES      in number
,nGOODSPARTIES_FROM in number
,nDELETE_FROM       in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GP_COPY_ADD_VALS');

  usr_pkg_goodsparties_add.copy_vals(ngoodsparties      => nGOODSPARTIES
                                    ,ngoodsparties_from => nGOODSPARTIES_FROM
                                    ,ndelete_from       => nDELETE_FROM);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GP_COPY_ADD_VALS;
/
