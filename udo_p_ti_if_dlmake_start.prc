create or replace procedure UDO_P_TI_IF_DLMAKE_START
(
  nCOMPANY         in number,
  NRN              in number,
  SUNITCODE        in varchar2,
  nDOC_RN_TI       in number,
  nDOC_RN_IF       in number,
  NTYPE_DL         in number           -- тип Связи (0 - по выходу; 1 - по входу)
)
is
begin
  /* Точка старта */
  UDO_PKG_TI_IF_DL_CREATE.DLMAKE_START(nCOMPANY   => nCOMPANY,
                                       NRN        => NRN,
                                       SUNITCODE  => SUNITCODE,
                                       nDOC_RN_TI => nDOC_RN_TI,
                                       nDOC_RN_IF => nDOC_RN_IF,
                                       NTYPE_DL   => NTYPE_DL);
end UDO_P_TI_IF_DLMAKE_START;
-- grant execute on UDO_P_TI_IF_DLMAKE_START to public;
/

