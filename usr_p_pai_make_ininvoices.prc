create or replace procedure usr_p_pai_make_ininvoices
/*
Входящие счета на оплату. Заголовок. Сформировать приходные накладные
08/04/2025 Степанов М.
*/
(
 nRN              in number
,sCATALOG         in varchar2
,sDOCTYPE         in varchar2
,sDOCPREF         in varchar2
,dDATE            in date
,sEXT_NUMB        in varchar2
,dEXT_DATE        in date
,sCURRENCY        in varchar2
,sSTOREOPER       in varchar2
)
is
  aRNList         udo_tp_numtable;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_MAKE_ININVOICES');

  /* Формирование */
  usr_pkg_payaccin.payaccin_make_ininvoices(nrn        => nRN
                                           ,scatalog   => sCATALOG
                                           ,sdoctype   => sDOCTYPE
                                           ,sdocpref   => sDOCPREF
                                           ,ddate      => dDATE
                                           ,sext_numb  => sEXT_NUMB   
                                           ,dext_date  => dEXT_DATE   
                                           ,scurrency  => sCURRENCY   
                                           ,sstoreoper => sSTOREOPER
                                           ,arnlist    => aRNList);
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
