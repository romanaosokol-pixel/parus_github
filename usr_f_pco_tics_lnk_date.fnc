create or replace function usr_f_pco_tics_lnk_date
/*
Раздел: Сертификация / Входной контроль ( Результаты сертификации / ВК )
Колонка #Дата создания накладной
30/10/2025 Степанов М.
create public synonym usr_f_pco_tics_lnk_date for usr_f_pco_tics_lnk_date;
grant execute on usr_f_pco_tics_lnk_date to public;
*/
(
 nRN in number
)
return date
as
begin
  return( f_doclinks_link_out( sin_unitcode => 'UdoProdCullSpOut', nin_document => nRN, sout_unitcode => 'GoodsTransInvoicesToDeptsSpecs' ) );
end;
/
