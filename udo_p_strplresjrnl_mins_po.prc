create or replace procedure UDO_P_STRPLRESJRNL_MINS_PO
  (
    nCOMPANY         in number,           -- Рег номер организации
    sUNITCODE        in varchar2,         -- Код раздела
    NCRN             in number,           -- каталог
    nRN              in number,           -- Рег номер
    NIDENT           in number,           -- Идент выделенных записей
    sSTORE           in varchar2,         -- склад
    SCELL            in varchar2,         -- место хранения (резервуар)
    NREPLACE         in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да)
    dRESERVINGDATE   in date,              -- дата и время резервирования.
    nOUTNOTE         out number
  )
  as
  /*
    ЦИТК Парус. Селиванов
    Приходный ордер (спецификации)
    Массовое резервирование по месту хранения.
  */
  
  --  nRN              PKG_STD.tREF;
  nCRN_                PKG_STD.tREF;
  begin

  -- запись строки
  P_INORDERS_EXISTS(nCOMPANY => nCOMPANY, nRN => nRN, nCRN => nCRN_);
  
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   nCRN_, 
                   'IncomingOrdersSpecs',
                   'P_STRPLRESJRNL_MINS_PO',
                   'INORDERSPECS',
                   nRN);

  /* Точка входа */
  UDO_PKG_STRPLRESJRNL_MASS_INS.SATRT
  (
    nCOMPANY         => nCOMPANY,
    sUNITCODE        => sUNITCODE,
    NIDENT           => NIDENT,
    sSTORE           => sSTORE,
    SCELL            => SCELL,
    NREPLACE         => NREPLACE,
    dRESERVINGDATE   => dRESERVINGDATE,
    nOUTNOTE         => nOUTNOTE
   );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   nCRN_, 
                   'IncomingOrdersSpecs',
                   'P_STRPLRESJRNL_MINS_PO',
                   'INORDERSPECS',
                   nRN);

end UDO_P_STRPLRESJRNL_MINS_PO;
-- grant execute on UDO_P_STRPLRESJRNL_MINS_PO to public;
/

