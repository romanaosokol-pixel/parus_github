create or replace procedure UDO_P_STRPLRESJRNL_COPY_INORD
(
  nCOMPANY           in number,         -- Рег номер организации
  NRN                in number          -- Рег номер РН а подразделения
)
is
nrn_STRPLRESJRNL     PKG_STD.tREF;
begin

FOR DOC in (select T.* from TRANSINVDEPT  T where T.RN =NRN and T.COMPANY = nCOMPANY)loop

for STR in (select TS.RN TS_RN, 
                   TS.QUANT TS_QUANT, 
                   TS.QUANTALT TS_QUANTALT, 
                   decode(NP.QUANT,null,to_number(null),0,0,round(TS.QUANT/NP.QUANT,3))TS_QUANTPACK, 
                   ST.* 
                   from TRANSINVDEPTSPECS TS, NOMNMODIFPACK MP, NOMNPACK NP, STRPLRESJRNL ST, GOODSSUPPLY G, DOCLINKS DL_PO, DOCLINKS DL_RN
where DL_RN.OUT_DOCUMENT = DOC.RN
  and DL_RN.IN_UNITCODE = 'IncomingOrders'
  and DL_PO.IN_DOCUMENT = DL_RN.IN_DOCUMENT
  and DL_PO.OUT_UNITCODE = 'StoragePlacesResJournal'
  and ST.RN = DL_PO.OUT_DOCUMENT
  and TS.PRN = DL_RN.OUT_DOCUMENT
  and ST.GOODSSUPPLY = G.RN
  and G.PRN =  TS.GOODSPARTY
  and TS.NOMMODIF = ST.NOMMODIF
  and TS.NOMNMODIFPACK = MP.RN (+)
  and MP.NOMENPACK    = NP.RN (+)
  )loop


           P_STRPLRESJRNL_BASE_INSERT(nCOMPANY       => nCOMPANY, -- организация.
                                     sAUTHID         => UTILIZER , -- пользователь
                                     sMASTERUNITCODE => 'GoodsTransInvoicesToDepts', -- код master-раздела
                                     sSLAVEUNITCODE  => 'GoodsTransInvoicesToDeptsSpecs', -- код slave-раздела
                                     nMASTERRN       => DOC.RN, -- регистрационный номер master-записи
                                     nSLAVERN        => STR.TS_RN, -- регистрационный номер slave-записи
                                     nRACK           => null, -- не используется (по возможности убрать)
                                     nCELL           => STR.CELL, -- место хранения (резервуар)
                                     nGOODSSUPPLY    => STR.GOODSSUPPLY, -- товарный запас
                                     nRES_TYPE       => 1, -- тип резервирования (0 - приход, 1 - расход)
                                     nNOMMODIF       => STR.NOMMODIF, -- модификация.
                                     nNOMNMODIFPACK  => null, -- упаковка модификации
                                     nARTICLE        => str.article, -- изделие на складе
                                     nGOODSUNIT      => null, -- грузовая единица
                                     nDOCTYPE        => DOC.DOCTYPE, -- тип документа
                                     dDOCDATE        => DOC.DOCDATE, -- дата документа
                                     sDOCNUMB        => DOC.NUMB, -- номер документа
                                     sDOCPREF        => DOC.PREF, -- префикс номера документа
                                     dRESERVING_DATE => DOC.DOCDATE, -- дата и время резервирования.
                                     dFREE_DATE      => null, -- дата и время снятия резервирования.
                                     nQUANT          => STR.TS_QUANT, -- количество в основной ЕИ
                                     nQUANTALT       => STR.TS_QUANTALT, -- количество в дополнительной ЕИ
                                     nQUANTPACK      => STR.TS_QUANTPACK, -- не используется (рассчитывается из ОЕИ)
                                     nCHECK_PARTY    => 0, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
                                     --nLINK_TYPE      => 1,
                                     nRN             => nrn_STRPLRESJRNL);
end loop;

end loop;
end;
-- grant execute on UDO_P_STRPLRESJRNL_COPY_INORD to public;
/

