create or replace procedure USR_P_IIV_RECREATE_IIVSC
/*
Приходные накладные
Пересоздать калькуляции
Степанов М. 25/09/2023
*/
(
 nRN            in number
)
is
  rRow          ininvoicesspecs%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIV_RECREATE_IIVSC');

  /* Пересоздание */
  usr_pkg_ininvoices.ininvoices_recreate_iivsc(nrn => nRN);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IIV_RECREATE_IIVSC;
/
