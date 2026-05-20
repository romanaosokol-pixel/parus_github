create or replace procedure USR_P_DOC_STRPLRESJRNL_DELETE
/*
25/07/2023 Степанов М.
Документы. Удаление связанных записей журнала резервирования текущего документа
*/
(
 nRN        in number
)
as
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DOC_STRPLRESJRNL_DELETE');

  /* Удаление журнала резервирования по местам хранения */
  usr_pkg_document.strplresjrnl_delete(nrn => nRN);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end;
/
