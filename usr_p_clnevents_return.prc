create or replace procedure USR_P_CLNEVENTS_RETURN
/*
Раздел: Все разделы
Процедура: Возврат события в предыдущий статус.
26/12/2023 Степанов М.
*/
(
 nRN            in number
,nCOMPANY       in number
)
is
  nClnEvents  pkg_std.tref;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_CLNEVENTS_RETURN');

  /* RN события статусной модели */
  nClnEvents := usr_pkg_document.get_clnevents(nflagsmart => 0, nrn => nRN);

  /* Возврат */
  p_clnevents_return(ncompany => nCOMPANY, nrn => nClnEvents, naddnote_need => nClnEvents);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_CLNEVENTS_RETURN;
/
