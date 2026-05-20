create or replace procedure USR_P_TIC_LINK_TO_PA
/*
Раздел: "Расходные накладные на отпуск потребителям "
Процедура: Установить связь со счётом на оплату.
13/03/2025 Степанов М.
*/
(
 nRN                  in number
,nCOMPANY             in number
,nPAYACC              in number
)
is
  rTransInvCust   transinvcust%rowtype;
  rPayAcc         payacc%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TIC_LINK_TO_PA');

  /* Считываем записи накладной и счёта */
  rTransInvCust := usr_pkg_transinvcust.transinvcust_get(nrn => nRN);
  rPayAcc       := usr_pkg_PayAcc.payacc_get(nrn => nPAYACC);

  /* Проверка соответствия контрагентов */
  if rTransInvCust.agent != rPayAcc.agent then
    p_exception(0, 'Контрагент накладной <%s>, не равен контрагенту счёта на оплату <%s>. %s'
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rTransInvCust.agent)
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rPayAcc.agent)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rTransInvCust.rn) ); 
  end if;
  /* Проверка соответствия лциевых счетов */
  if rTransInvCust.faceacc != rPayAcc.faceacc then
    p_exception(0, 'Лицевой счёт накладной <%s>, не равен лицевому счёту счёта на оплату <%s>. %s' 
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => rTransInvCust.faceacc)
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => rPayAcc.faceacc)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rTransInvCust.rn) ); 
  end if;

  /* Установка связи */
  pkg_doclinks.link(nflag_smart       => 0
                   ,ncompany          => rTransInvCust.company
                   ,sin_unitcode      => 'PaymentAccounts'
                   ,nin_document      => rPayAcc.rn
                   ,sout_unitcode     => 'GoodsTransInvoicesToConsumers'
                   ,nout_document     => rTransInvCust.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
