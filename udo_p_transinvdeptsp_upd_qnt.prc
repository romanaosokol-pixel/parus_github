create or replace procedure UDO_P_TRANSINVDEPTSP_UPD_QNT
(
  nDOCUMENT                 in number, -- Рег. номер спецификации РН
  nQUANT                    in number, -- Количество
  nSIGN_DLVR                in number, -- Удалить из комплектования КВ
  nSIDN_DROP                in number  -- Признак удаления резерва
) 
is
  /*
    Процедура корректировки количества для спецификации РН (связанной с КВ)
    
    grant execute on UDO_P_TRANSINVDEPTSP_UPD_QNT to public;
  */
  rSP                       transinvdeptspecs%rowtype;
begin
  /* Считывание записи спецификации */
  rSP := udo_pkg_get.ROW_TRANSINVDEPTSPECS(NRN => nDOCUMENT,NSMART => 0);  
   
  /* проверка прав доступа */
  PKG_ENV.PROLOGUE(nCOMPANY  => rSP.COMPANY,
                   nVERSION  => null,
                   nCATALOG  => rSP.CRN,
                   sUNIT     => 'GoodsTransInvoicesToDeptsSpecs',
                   sACTION   => 'UDO_TRANSINVDEPTSP_UPD_QNT',
                   sTABLE    => 'TRANSINVDEPTSPECS',
                   nDOCUMENT => rSP.RN);
  
  /* Базовая корректировка специифкации */
  UDO_PKG_TRANSINVDEP_BASE_UTL.SP_UPDATE_QNT(nDOCUMENT  => nDOCUMENT,
                                             nQUANT     => nQUANT,
                                             nSIGN_DLVR => nSIGN_DLVR,
                                             nSIGN_DROP => nSIDN_DROP); 
  
  /* фиксация окончания выполнение действия */
  PKG_ENV.EPILOGUE(nCOMPANY  => rSP.COMPANY,
                   nVERSION  => null,
                   nCATALOG  => rSP.CRN,
                   sUNIT     => 'GoodsTransInvoicesToDeptsSpecs',
                   sACTION   => 'UDO_TRANSINVDEPTSP_UPD_QNT',
                   sTABLE    => 'TRANSINVDEPTSPECS',
                   nDOCUMENT => rSP.RN);
    
end UDO_P_TRANSINVDEPTSP_UPD_QNT;
/
