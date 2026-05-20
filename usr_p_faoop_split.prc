create or replace procedure usr_p_faoop_split
/*
Лицевые счета (план расхода)/ Отделить от текущей записи с заданным количеством
24/03/2026 Степанов М.
create public synonym usr_p_faoop_split for usr_p_faoop_split;
grant execute on usr_p_faoop_split to public;
*/
(
 nRN                in number
,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
,dBEGIN_DATE        in date
,dEND_DATE          in date
)
is
begin
  /* Открытие процесса */
  usr_pkg_process.process_open(sname => 'USR_P_FAOOP_SPLIT');

  /* Выполнение процедуры */
  usr_pkg_faceacc.fcacoperoutplans_split( nrn         => nRN
                                         ,nquant_new  => nQUANT_NEW
                                         ,dbegin_date => dBEGIN_DATE
                                         ,dend_date   => dEND_DATE );

  /* Закрытие процесса */
  usr_pkg_process.process_close;

/* Обработка исключений */
exception when others then
  /* Закрытие процесса */
  usr_pkg_process.process_close;
  raise;

end;
/
