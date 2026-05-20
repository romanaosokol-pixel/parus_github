create or replace procedure UDO_P_PRJSTG_PRSTRUCT_DELETE
/*
  Клиентская процедура удаления структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTRUCT_DELETE to public;
 */
(
  nRN             in number,            -- Регистрационный номер
  nCOMPANY        in number            -- Организация
 ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_DELETE
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY
);
end;
/

