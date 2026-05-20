create or replace procedure USR_P_IIVS_INSERT_IIVSC
/*
Приходные накладные (спецификация)
Добавить калькуляцию
Степанов М. 18/09/2023
*/
(
 nRN            in number
,sFACEACCOUNT   in varchar2 /* Лицевой счёт (если пусто, то из накладной) */
,nQUANT         in number   /* Количество (если пусто, то из спецификации) */
)
is
  nRN2            pkg_std.tref := nRN;
  rV_Row          v_ininvoicesspecs%rowtype;
  rV_InInvoices   V_ininvoices%rowtype;
  
  nNumber         pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIVS_INSERT_IIVSC');

  /* Считывание */
  select * into rV_Row from v_ininvoicesspecs where nrn = nRN2;
  select * into rV_InInvoices from v_ininvoices where nrn = rV_Row.nprn;
  /* Добавление */
  p_ininvoicesspc_insert(ncompany      => rV_Row.ncompany
                        ,nprn          => rV_Row.nrn
                        ,snumb         => null
                        ,scost_article => null
                        ,scost_place   => null
                        ,ncost_plan    => null
                        ,ncost_fact    => null
                        ,npriority     => null
                        ,sfaceaccount  => nvl(sFACEACCOUNT, rV_InInvoices.sfaceacc)
                        ,sgraphpoint   => null
                        ,sfinoper_type => null
                        ,nquant_plan   => nvl(nQUANT, rV_Row.nquant)
                        ,nquant_fact   => nvl(nQUANT, rV_Row.nquant)
                        ,ssubdiv       => null
                        ,nrn           => nNumber);
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IIVS_INSERT_IIVSC;
/
