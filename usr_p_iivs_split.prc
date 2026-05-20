create or replace procedure USR_P_IIVS_SPLIT
/*
Приходные накладные. Спецификация. Отделить от текущей записи с заданным количеством
03/07/2023 Степанов М.
*/
(
 nRN          in number
,nQUANT_NEW   in number  /* Количество отделямое в новую спецификацию */
)
is
begin
  /* Открытие процесса */
  usr_pkg_process.process_open(sname => 'USR_P_IIVS_SPLIT');

  /* Выполнение процедуры */
  usr_pkg_ininvoices.ininvoicesspecs_split(nrn => nRN, nquant_new => nQUANT_NEW);

  /* Закрытие процесса */
  usr_pkg_process.process_close;

/* Обработка исключений */
exception when others then
  /* Закрытие процесса */
  usr_pkg_process.process_close;
  raise;

end USR_P_IIVS_SPLIT;
/
