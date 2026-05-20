create or replace procedure UDO_P_STRPLRESJRNL_MINS_TIC
  (
    nCOMPANY         in number,           -- Рег номер организации
    sUNITCODE        in varchar2,         -- Код раздела
    NCRN             in number,           -- каталог
    NRN              in number,           -- Рег номер
    NIDENT           in number,           -- Идент выделенных записей
    sSTORE           in varchar2,         -- склад
    SCELL            in varchar2,         -- место хранения (резервуар)
    nRES_TYPE        in number default 0, -- тип резервирования (0 - приход, 1 - расход)
    NREPLACE         in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да)
    dRESERVINGDATE   in date,             -- дата и время резервирования.
    nOUTNOTE         out number
  )
  is
--    nRN              PKG_STD.tREF;
  begin

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   NCRN,
                   'GoodsTransInvoicesToConsumersSpecs',
                   'UDO_STRPLRESJRNL_MINS_TIC',
                   'TRANSINVCUSTSPECS',
                   nRN);

  /* Точка входа */
  UDO_PKG_STRPLRESJRNL_MASS_INS.SATRT
  (
    nCOMPANY         => nCOMPANY,
    sUNITCODE        => sUNITCODE,
    NIDENT           => NIDENT,
    sSTORE           => sSTORE,
    SCELL            => SCELL,
    nRES_TYPE        => nRES_TYPE,
    NREPLACE         => NREPLACE,
    dRESERVINGDATE   => dRESERVINGDATE,
    nOUTNOTE         => nOUTNOTE
   );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   nCRN,
                   'GoodsTransInvoicesToConsumersSpecs',
                   'UDO_STRPLRESJRNL_MINS_TIC',
                   'TRANSINVCUSTSPECS',
                   nRN);

end UDO_P_STRPLRESJRNL_MINS_TIC;
-- grant execute on UDO_P_STRPLRESJRNL_MINS_TIC to public;
/

