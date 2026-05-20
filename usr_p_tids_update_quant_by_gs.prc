create or replace procedure USR_P_TIDS_UPDATE_QUANT_BY_GS
/*
Расходные накладные на отпуск в подразделения. Спецификация. Исправить количество по данным товарного запаса на дату документа
08/04/2022 Степанов М.
*/
(
 nRN in number
) 
is
  rRow          transinvdeptspecs%rowtype;
  rV_Row        v_transinvdeptspecs%rowtype;
  rTransInvDept transinvdept%rowtype;
  nRestFact     pkg_std.tquant;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TIDS_UPDATE_QUANT_BY_GS');

  /* Считывание спецификации и заголовка */
  rRow          := USR_PKG_TRANSINVDEPT.TRANSINVDEPTSPECS_GET(nRN);
  rTransInvDept := USR_PKG_TRANSINVDEPT.TRANSINVDEPT_GET(rRow.prn);

  /* Определение фактического остатка */
  begin
    select s.nrestfact
      into nRestFact
      from (
            select SUP.PRN     as NPRN
                  ,H.DATE_FROM as DDATE_FROM
                  ,H.DATE_TO   as DDATE_TO
                  ,H.RESTFACT  as NRESTFACT
                  ,SUP.STORE   as NSTORE
              from GOODSSUPPLY     SUP
                  ,GOODSSUPPLYHIST H
             where SUP.RN = H.PRN
           ) S
     where S.DDATE_FROM <= rTransInvDept.docdate
       and (S.DDATE_TO  >= rTransInvDept.docdate or S.DDATE_TO is null)
       and S.NPRN        = rRow.goodsparty
       and S.NSTORE      = rTransInvDept.store
       and S.NRESTFACT  != 0;
  exception
    when no_data_found then
      P_EXCEPTION(0, 'Не найден товарный запас с остатком. %s %s'
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('GoodsTransInvoicesToDeptsSpecs', rRow.rn)
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('GoodsTransInvoicesToDepts', rRow.prn)); 
    when too_many_rows then
      P_EXCEPTION(0, 'Найдено больше одного товарного запаса с остатком. %s %s'
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('GoodsTransInvoicesToDeptsSpecs', rRow.rn)
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('GoodsTransInvoicesToDepts', rRow.prn)); 
    when others then
      P_EXCEPTION(0, 'Неопределённая ситуация при поиске товарного запаса с остатком. %s %s'
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('GoodsTransInvoicesToDeptsSpecs', rRow.rn)
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('GoodsTransInvoicesToDepts', rRow.prn)); 
  end;

  /* Считывание представления текущей записи */
  select * into rV_Row from v_transinvdeptspecs where nrn = rRow.rn;

  /* Подмена количества в записи представления */
  rV_Row.NQUANT := nRestFact;

  /* Клиентское исправление */
  usr_pkg_transinvdept.transinvdeptspecs_update(rv_row => rV_Row);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_TIDS_UPDATE_QUANT_BY_GS;
/
