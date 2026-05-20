create or replace procedure UDO_P_PRJSTG_PRSTRUCT_MAKE
/*
  Клиентская процедура переформирования структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTRUCT_MAKE to public;
 */
(
  nRN             in number,            -- Регистрационный номер
  nCOMPANY        in number            -- Организация
 ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_MAKE
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY
);
end;
/

