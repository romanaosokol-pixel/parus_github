create or replace procedure UDO_P_LOADEXT_ORD_NOMEN_LINK
(
  nDOCUMENT                   in number, -- Рег. номер записи спецификации
  NMODIF                      in number, -- Рег. нмер модификации
  NNOMEN                      in number  -- Рег. нмер номенклатуры
)
is
/*
  Процедура привязки номенклатуры для пользовательского приложения "Поиск номенклатуры"
  grant execute on UDO_P_LOADEXT_ORD_NOMEN_LINK to public;
  */
begin
  /*udo_pkg_loadext_ord_base.SP_SET_NOMEN(NRN    => nDOCUMENT,
                                        nNOMEN => NMODIF,
                                        nMODIF => NNOMEN);*/
                                        null;
end UDO_P_LOADEXT_ORD_NOMEN_LINK;
/

