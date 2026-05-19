create or replace function USR_F_TIC_GET_PA_DTAILS
/*
Раздел Расходные накладные на отпуск потребителям
Функция для колонки "#Счёт на оплату"
26/02/2025 Степанов М.
grant execute on usr_f_tic_get_pa_dtails to public;
*/
(
 nRN       in number
)
return varchar2
is
  nRef      pkg_std.tref;
  sVarchar  pkg_std.tstring; 
begin
  /* Счёт на оплату RN */
  nRef := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                               ,sout_unitcode  => 'GoodsTransInvoicesToConsumers'
                                               ,nout_document  => nRN
                                               ,sin_unitcode   => 'PaymentAccounts');
  /* Если найден */
  if nRef is not null then 
    /* Реквизиты */
    sVarchar := substr(f_docdescrs_get_description(sunitcode => 'PaymentAccounts', ndocument => nRef), 0, 4000);
  end if;

  return(sVarchar);
end;
/
