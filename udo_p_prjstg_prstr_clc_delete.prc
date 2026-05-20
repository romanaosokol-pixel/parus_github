create or replace procedure UDO_P_PRJSTG_PRSTR_CLC_DELETE
/*
  Клиентская процедура удаления статьи структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTR_CLC_DELETE to public;
 */
(
  nRN             in number,            -- Регистрационный номер
  nCOMPANY        in number            -- Организация
 ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.CLC_DELETE
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY
);
end;
/

