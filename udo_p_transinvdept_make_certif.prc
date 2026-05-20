create or replace procedure UDO_P_TRANSINVDEPT_MAKE_CERTIF
(
  nRN                       in number, -- Рег. номер записи
  sCTLG                     in varchar2, -- каталог
  sDOC_TYPE                 in varchar2, -- тип документа
  dSERT_DATE                in date,     -- дата сертификации
  sSERT_AGENT               in varchar2, -- Орган сертификации
  sSTORE_SPOIL              in varchar2, -- склад брака
  sSTOPER_SPOIL             in varchar2, -- складская операция брака
  sFACEACC_AGN              in varchar2, -- лицевой счет контрагента
  nSIGN_SERT                in number,   -- Признак сертификации (0-выборочная, 1-полная) 
  SNOTE                     in varchar2  -- примечание
) is
  /*
  Клиентская процедура фораирования записи сертификации.
  Раздел "Расходные накладные на отпуск в подраздленеия"
  
  grant execute on UDO_P_TRANSINVDEPT_MAKE_CERTIF to public;
  */
  
  REC                       TRANSINVDEPT%rowtype; --результат работы
begin
  /* считывание записи РНОПодр*/
  rec := udo_pkg_get.ROW_TRANSINVDEPT(nRN,0);  

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rec.COMPANY,
                   null,
                   rec.CRN, 
                   'GoodsTransInvoicesToDepts',
                   'UDO_TRANSINVDEPT_MAKE_CERTIF',
                   'TRANSINVDEPT',
                   rec.RN);
                   
  /* базовое формирование записи */ 
  UDO_PKG_PROD_CULL.CULL_MAKE_BY_TID(nTID          => rec.RN,
                                     sCTLG         => sCTLG,        
                                     sDOC_TYPE     => sDOC_TYPE,    
                                     dSERT_DATE    => dSERT_DATE,   
                                     sSERT_AGENT   => sSERT_AGENT, 
                                     sSTORE_SPOIL  => sSTORE_SPOIL, 
                                     sSTOPER_SPOIL => sSTOPER_SPOIL,
                                     sFACEACC_AGN  => sFACEACC_AGN,
                                     SNOTE         => SNOTE,
                                     nSIGN_SERT    => nvl(nSIGN_SERT,1),
                                     nMODE_CHECK   => 0);
                                     
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rec.COMPANY,
                   null,
                   rec.CRN, 
                   'GoodsTransInvoicesToDepts',
                   'UDO_TRANSINVDEPT_MAKE_CERTIF',
                   'TRANSINVDEPT',
                   rec.RN);
end ;
/

