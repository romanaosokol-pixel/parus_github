create or replace procedure UDO_P_PRJSTG_PRSTRUCT_UPDATE
/*
  Клиентская процедура исправления структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTRUCT_UPDATE to public;
 */
(
  nRN             in number,            -- Регистрационный номер
  nCOMPANY        in number,            -- Организация
  sPRICE_KIND     in varchar2,          -- Мнемокод вида цены
  sCALCSCHM       in varchar2,          -- Мнемокод схемы калькуляции
  dDATE_FROM      in date,              -- Действует с
  dDATE_TO        in date,              -- Действует по
  nAUTOCALC       in number             -- Признак автопересчета косвенных статей
) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_UPDATE
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY,
  sPRICE_KIND     => sPRICE_KIND,
  sCALCSCHM       => sCALCSCHM,
  dDATE_FROM      => dDATE_FROM,
  dDATE_TO        => dDATE_TO,
  nAUTOCALC       => nAUTOCALC
);
end;
/

