create or replace procedure UDO_P_PRJSTG_PRSTRUCT_INSERT
/*
  Клиентская процедура добавления структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTRUCT_INSERT to public;
 */
(
  nCOMPANY        in number,            -- Организация
  nPRN            in number,            -- Родитель
  sPRICE_KIND     in varchar2,          -- Мнемокод вида цены
  sCALCSCHM       in varchar2,          -- Мнемокод схемы калькуляции
  dDATE_FROM      in date,              -- Действует с
  dDATE_TO        in date,              -- Действует по
  nAUTOCALC       in number,             -- Признак автопересчета косвенных статей
  nDUP_RN         in number,            -- Регистрационный номер размножаемой записи
  nRN             out number            -- Регистрационный номер
) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_INSERT
(
  nCOMPANY        => nCOMPANY,
  nPRN            => nPRN,
  sPRICE_KIND     => sPRICE_KIND,
  sCALCSCHM       => sCALCSCHM,
  dDATE_FROM      => dDATE_FROM,
  dDATE_TO        => dDATE_TO,
  nAUTOCALC       => nAUTOCALC,
  nDUP_RN         => nDUP_RN,
  nRN             => nRN
);
end;
/

