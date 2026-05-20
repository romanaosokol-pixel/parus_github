create or replace procedure UDO_P_PRJSTG_PRSTR_CLC_MAIN
/*
  Клиентская процедура установки признака "Основная" статьи структуры цены

  grant execute on UDO_P_PRJSTG_PRSTR_CLC_MAIN to public;
 */
(
  nRN             in number,            -- Регистрационный номер
  nCOMPANY        in number            -- Организация
  ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.CLC_SET_MAIN
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY      ,
  nSIGN_MAIN       => 1  -- Признак "Основная" (0 - нет, 1 - да)
);

end;
/

