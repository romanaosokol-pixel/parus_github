create or replace procedure usr_p_faoop_recalc
/*
Лицевые счета (план расхода). Пересчитать исполнение
18/02/2026 Степанов М.
*/
(
 nRN              in number
)
is
  rRow  fcacoperplans%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_FAOOP_RECALC');

  usr_pkg_faceacc.fcacoperoutplans_recalc( nrn => nRN );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
