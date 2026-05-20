create or replace procedure UDO_P_REG_FOR_ACTIVATION
(
  nCOMPANY           in number,
  sUNITCODE          in varchar2,
  nDOCUMENT          in number
)
as
begin
  /* процедура предварительной регистрации документа для активации статусной модели */
  UDO_PKG_UNITSTMOD.REG_FOR_ACTIVATION
  (
    nCOMPANY  => nCOMPANY,
    sUNITCODE => sUNITCODE,
    nDOCUMENT => nDOCUMENT
  );

end;
-- grant execute on UDO_P_REG_FOR_ACTIVATION to public;
/

