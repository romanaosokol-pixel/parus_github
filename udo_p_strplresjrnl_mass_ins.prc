create or replace procedure UDO_P_STRPLRESJRNL_MASS_INS
  (
    nCOMPANY         in number,           -- Рег номер организации
    sUNITCODE        in varchar2,         -- Код раздела
    NIDENT           in number,           -- Идент выделенных записей
    sSTORE           in varchar2,         -- склад
    SCELL            in varchar2,         -- место хранения (резервуар)
    nRES_TYPE        in number,           -- тип резервирования (0 - приход, 1 - расход)
    NREPLACE         in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да)
    dRESERVINGDATE   in date,              -- дата и время резервирования.
    nOUTNOTE         out number
  )
  is
  begin
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

end UDO_P_STRPLRESJRNL_MASS_INS;
-- grant execute on UDO_P_STRPLRESJRNL_MASS_INS to public;
/

