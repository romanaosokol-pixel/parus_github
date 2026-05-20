create or replace procedure USR_P_PAI_MAKE_INORDERS
/*
Входящие счета на оплату. Заголовок. Сформировать приходные ордера
02/20/2023 Степанов М.
*/
(
 nRN              in number
,sCATALOG         in varchar2
,sDOCTYPE         in varchar2
,dDATE            in date
,sSTORE           in varchar2
,sSTOREOPER       in varchar2
)
is
  aRNList         udo_tp_numtable;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_MAKE_INORDERS');

  usr_pkg_payaccin.payaccin_make_inorders(nrn        => nRN
                                         ,scatalog   => sCATALOG
                                         ,sdoctype   => sDOCTYPE
                                         ,ddate      => dDATE
                                         ,sstore     => sSTORE
                                         ,sstoreoper => sSTOREOPER
                                         ,arnlist    => aRNLIST);
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_PAI_MAKE_INORDERS;
/
