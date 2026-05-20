create or replace procedure USR_P_GS_RECALC
/*
Товарные запасы.
Пересчитать данные
Степанов М.В. 20/09/2024
*/
(
 nRN                in number    /* Товарный запас. RN */
,nCOMPANY           in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GS_RECALC');

  usr_pkg_goodsparties.goodssupply_recalc(nrn => f_goodssupply_by_rownum(nrownum => nRN), ncompany => nCOMPANY);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GS_RECALC;
/
