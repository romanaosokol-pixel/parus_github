create or replace procedure UDO_P_LOADEXT_ORD_GET_NOMEN
(
  NDOCUMENT                   in number,   -- Рег. номер спецификации
  SNOMEN                      out varchar2 -- Наименование номенклатуры
)
is
/*
  Процедура инициализации поля поиска номенклатуры для пользоватлеьского приложения "Поиск номенклатуры"
  grant execute on UDO_P_LOADEXT_ORD_GET_NOMEN to public;
  */
  rec                         udo_loadext_ord_sp%rowtype; -- Запись спецификации
begin
  rec := udo_pkg_loadext_ord_base.SP_GET_ID(NFLAG_SMART => 1, NRN => NDOCUMENT);

  SNOMEN := rec.ext_nomen;

end UDO_P_LOADEXT_ORD_GET_NOMEN;
/

