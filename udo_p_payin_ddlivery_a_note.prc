create or replace procedure UDO_P_PAYIN_DDLIVERY_A_NOTE
(
  NCOMPANY         in number,         -- Рег. номер организации
  NRN              in number,         -- Рег номер записи
  DDELIVERY        in date,           -- Дата поставки
  SNOTE            in varchar2        -- Примечание
)
is

begin
  /* Точка старта */
  UDO_PKG_PAYIN_DDLIVERY_A_NOTE.START_MAKE
  (
    NCOMPANY         => NCOMPANY,
    NRN              => NRN,
    DDELIVERY        => DDELIVERY,
    SNOTE            => SNOTE
  );

end UDO_P_PAYIN_DDLIVERY_A_NOTE;
-- grant execute on UDO_P_PAYIN_DDLIVERY_A_NOTE to public;
/

