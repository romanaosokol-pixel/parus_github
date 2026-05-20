create or replace procedure UDO_P_RP_TRNSNVDPT_INC_XLS
(
  NCOMPANY          in number,     -- Организация
  NIDENT            in number,     -- ИД помеченных записей
  SRAZDEL           in varchar2    -- Раздел
)
is
begin
  /* Формирование отчет */
  UDO_PKG_RP_TRNSNVDPT_INC_XLS.XLS_MAKE(NCOMPANY => NCOMPANY, NIDENT => NIDENT, SRAZDEL => SRAZDEL);

end UDO_P_RP_TRNSNVDPT_INC_XLS;
-- grant execute on UDO_P_RP_TRNSNVDPT_INC_XLS to public;
/

