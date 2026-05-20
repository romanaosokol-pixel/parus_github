create or replace procedure UDO_P_PLROUTNOT_NEXTNUMB
(
  nCOMPANY in number, -- организация
  sPREF    in varchar2, -- префикс
  sNUMB    out varchar2 -- следующий номер
) as
/*
  12/09/2022 Марков МВ.
  Извещение об оперативном изменении.
  Генерация следующего номера
*/
begin
  UDO_PKG_PLROUTNOT.P_PLROUTNOT_NEXTNUMB(nCOMPANY => nCOMPANY, sPREF => sPREF, sNUMB => sNUMB);
end;
/

