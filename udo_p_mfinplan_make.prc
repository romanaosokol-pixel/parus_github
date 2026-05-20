create or replace procedure UDO_P_MFINPLAN_MAKE
(
  nCOMPANY           in number,    -- Организация
  nRN                in number     -- RN Бюджета
)
is
begin
  UDO_PKG_MFINPLAN_MAKE.START_MAKE(nCOMPANY => nCOMPANY, nRN => nRN);
end;
/

