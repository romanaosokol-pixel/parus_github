create or replace procedure usr_p_rits_make_iiv
/*
Раздел: "Расходные накладные на возврат поставщикам"
Процедура: Сформировать приходную накладную.
17/04/2025 Степанов М.
create public synonym usr_p_rits_make_iiv for usr_p_rits_make_iiv;
grant execute on usr_p_rits_make_iiv to public;
*/
(
 nRN              in number
,sCATALOG         in varchar2
,sDOC_TYPE        in varchar2
,sDOC_PREF        in varchar2
,sSTORE_OPER      in varchar2
)
is
  aRNList          udo_tp_numtable;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_RITS_MAKE_IIV');

  /* Процедура */
  usr_pkg_rinvtosup.rinvtosup_make_iiv(nrn         => nRN
                                      ,scatalog    => sCATALOG
                                      ,sdoc_type   => sDOC_TYPE
                                      ,sdoc_pref   => sDOC_PREF
                                      ,sstore_oper => sSTORE_OPER
                                      ,arnlist     => aRNList );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
