create or replace procedure usr_p_tid_make_rits
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Сформировать расходную накладную на возврат поставщикам.
28/03/2025 Степанов М.
create public synonym usr_p_tid_make_rits for usr_p_tid_make_rits;
grant execute on usr_p_tid_make_rits to public;
*/
(
 nRN              in number
,sCATALOG         in varchar2
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_MAKE_RITS');

  /* Процедура */
  usr_pkg_transinvdept.transinvdept_make_rits(nrn         => nRN
                                             ,scatalog    => sCATALOG
                                             ,sdoc_type   => 'ТОРГ-12'
                                             ,sdoc_pref   => d_year(sysdate)
                                             ,sstore_oper => 'ВозврПост'
                                             ,spay_type   => 'ОкончатРасчет');

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end;
/
