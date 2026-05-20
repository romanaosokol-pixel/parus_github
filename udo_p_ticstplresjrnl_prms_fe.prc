create or replace procedure UDO_P_TICSTPLRESJRNL_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада
    SCELL            in out varchar2,   -- Мнемокод ячейки
    SCELL_ND         in out number,     -- Доступность ячейки
    SCELL_NN         in out number,     -- Обязательность ячейки
    nRES_TYPE        in out number          -- тип резервирования (0 - приход, 1 - расход)
  )
  is
  begin
  /* Пользовательская форма для Расхода потребителям */
  UDO_PKG_STRPLRESJRNL_MASS_INS.TRANSINVCUST_PRMS_FE
  (
    NCOMPANY         => NCOMPANY,
    NRN              => NRN,
    SATRIB           => SATRIB,
    SSTORE           => SSTORE,
    SSTORE_ND        => SSTORE_ND,
    SCELL            => SCELL,
    SCELL_ND         => SCELL_ND,
    SCELL_NN         => SCELL_NN,
    nRES_TYPE        => nRES_TYPE
  );

end UDO_P_TICSTPLRESJRNL_PRMS_FE;
-- grant execute on UDO_P_TICSTPLRESJRNL_PRMS_FE to public;
/

