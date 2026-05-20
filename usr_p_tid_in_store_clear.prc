create or replace procedure USR_P_TID_IN_STORE_CLEAR
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Очистить склад-получатель
23/01/2026 Степанов М.
*/
(
 nFLAGSMART           in number 
,nRN                  in number
)
is
  rV_Row          v_transinvdept%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_IN_STORE_CLEAR');

  /* Считывание текущей записи */
  begin select * into rV_Row from v_transinvdept where nrn = USR_P_TID_IN_STORE_CLEAR.NRN; end;

  /* Проверка параметров */
  if rV_Row.nstoper not in (50233858) then
    p_exception(nFLAGSMART, 'Процедура предназначена для выполнения только в документах со складской операцией "ПриходВозвр". %s'
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rV_Row.nrn ) );
  end if;
  if rV_Row.nin_store is null then
    p_exception(nFLAGSMART, 'Склад-получатель не заполнен. %s'
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rV_Row.nrn ) );
  end if;

  /* Склад-получатель */
  rV_Row.sin_store  := null;

  /* Исправление */
  usr_pkg_transinvdept.transinvdept_update( rv_row => rV_Row );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
