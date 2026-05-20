create or replace procedure usr_p_tid_base_update
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Исправить базовая. 
10/04/2026 Степанов М.
create public synonym usr_p_tid_base_update for usr_p_tid_base_update;
grant execute on usr_p_tid_base_update to public;
*/
(
 nRN                  in number
/*,nSTATUS_IGNORE       in number*/
,sCOMMENTS            in varchar2
)
is
  rRow          transinvdept%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_BASE_UPDATE');

  /* Проверка параметров */
  if sCOMMENTS is null then
    p_exception(0, 'Не заполнены входные параметры. %s'
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => nRN) );
  end if;

  /* Считывание текущей записи */
  rRow := usr_pkg_transinvdept.transinvdept_get( nrn => nRN );

  /* Примечание */
   rRow.comments := nvl( sCOMMENTS, rRow.comments );

  /* Исправление */
  usr_pkg_transinvdept.transinvdept_base_update( rRow => rRow, nstatus_ignore => 1 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
    usr_pkg_process.process_close;
  raise;
end;
/
