create or replace procedure UDO_P_TRANSINVDEPT_MAKE_INCTRL
(
  nRN                       in number, -- Рег. номер записи
  sCTLG                     in varchar2, -- каталог
  sDOC_TYPE                 in varchar2, -- тип документа
  dSERT_DATE                in date,     -- дата сертификации
  sSTORE_SPOIL              in varchar2, -- склад брака
  sSTOPER_SPOIL             in varchar2, -- складская операция брака
  SNOTE                     in varchar2  -- примечание
) is
  /*
  Клиентская процедура фораирования записи входного контроля.
  Раздел "Расходные накладные на отпуск в подраздленеия"
  
  grant execute on UDO_P_TRANSINVDEPT_MAKE_INCTRL to public;
  */ 
  REC                       TRANSINVDEPT%rowtype; -- запись РНОПодр
begin
  /* считывание записи РНОПодр*/
  rec := udo_pkg_get.ROW_TRANSINVDEPT(nRN,0);  

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rec.COMPANY,
                   null,
                   rec.CRN, 
                   'GoodsTransInvoicesToDepts',
                   'UDO_TRANSINVDEPT_MAKE_INCTRL',
                   'TRANSINVDEPT',
                   rec.RN);
                   
  /* базовое формирование записи */ 
  UDO_PKG_PROD_CULL.CULL_MAKE_BY_TID(nTID          => rec.RN,
                                     sCTLG         => sCTLG,        
                                     sDOC_TYPE     => sDOC_TYPE,    
                                     dSERT_DATE    => dSERT_DATE,   
                                     sSERT_AGENT   => null, 
                                     sSTORE_SPOIL  => sSTORE_SPOIL, 
                                     sSTOPER_SPOIL => sSTOPER_SPOIL,
                                     sFACEACC_AGN  => null,
                                     nSIGN_SERT    => 1, 
                                     SNOTE         => SNOTE,
                                     nMODE_CHECK   => 1);
                                     
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rec.COMPANY,
                   null,
                   rec.CRN, 
                   'GoodsTransInvoicesToDepts',
                   'UDO_TRANSINVDEPT_MAKE_INCTRL',
                   'TRANSINVDEPT',
                   rec.RN);
end ;
/

