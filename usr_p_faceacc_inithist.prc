create or replace procedure usr_p_faceacc_inithist
/*
Раздел: Лицевые счета
Процедур: Корректировка истории исполнения
07/07/2025 Степанов М.
*/
(
 nCOMPANY   in number
,nIDENT     in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'usr_p_faceacc_inithist');

  /* Корректировка */
  usr_pkg_faceacc.faceacc_inithist(ncompany => nCOMPANY, nident => nIDENT);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end;
/
