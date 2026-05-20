create or replace procedure usr_p_paynotes_update
/*
Журнал платежей. Исправить
02/12/2025 Степанов М.
*/
(
 nRN              in number
,dPAY_DATE        in date
,sFINOPER_MNEMO   in varchar2
,sGRAPHPOINT      in varchar2
)
is
  rV_Row          v_paynotes%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'usr_p_paynotes_update');

  /* Считывание */
  select * into rV_Row from v_paynotes where nrn = usr_p_paynotes_update.nrn;

  /* Подмена значений */
  if sFINOPER_MNEMO is not null then  
    p_exception(0, 'Изменять параметр %s пока запрещено.', 'sFINOPER_MNEMO'); 
  end if;

  rV_Row.sfinoper_mnemo := nvl( sFINOPER_MNEMO, rV_Row.sfinoper_mnemo ) ;
  rV_Row.dpay_date      := nvl( dPAY_DATE, rV_Row.sgraphpoint ) ;
  rV_Row.sgraphpoint    := nvl( sGRAPHPOINT, rV_Row.sgraphpoint ) ;

  /* Исправление в пользовательском режиме */
  usr_pkg_paynotes.paynotes_update( rv_row => rV_Row, nmode => 1 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
