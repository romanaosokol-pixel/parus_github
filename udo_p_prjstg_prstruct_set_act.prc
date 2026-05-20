create or replace procedure UDO_P_PRJSTG_PRSTRUCT_SET_ACT
/*
  Клиентская процедура установки признака "Действующая" для структуры цены

  grant execute on UDO_P_PRJSTG_PRSTRUCT_SET_ACT to public;
 */
(
   nCOMPANY        in number,
  nRN             in number,
  nSIGN_ACT       in number,            -- Признак "Действующая" (0 - нет, 1 - да)
  dDATE           in date               -- Действует с/по
 ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_SET_ACT
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY   ,
  nSIGN_ACT       => nSIGN_ACT,
  dDATE           => dDATE
);
end;
/

