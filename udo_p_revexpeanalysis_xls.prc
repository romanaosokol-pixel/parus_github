create or replace procedure UDO_P_REVEXPEANALYSIS_XLS
(
  NCOMPANY          in number,   -- Организация
  SFPDARTCL         in Varchar2, -- Статья движения
  SPERIOD           in varchar2  -- Мнемокод расчетного периода
)
is
begin
  /* Формирование отчет */
  UDO_PKG_REVEXPEANALYSIS_XLS.XLS_MAKE(NCOMPANY  => NCOMPANY,
                                     SFPDARTCL => SFPDARTCL,
                                     SPERIOD   => SPERIOD);
end;
/

