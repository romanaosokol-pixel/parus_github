create or replace procedure UDO_P_TI_IF_DLMAKE_FE
(
  nCOMPANY         in number,
  SATRIB           in varchar2,        -- Изменённый атрибут
  nDOC_RN_TI       in out number,
  nDOC_RN_TI_ND    in out number,          -- доступность
  nDOC_RN_IF       in out number,
  nDOC_RN_IF_ND    in out number          -- доступность
)
is
begin
  /* Обработка формы */
  UDO_PKG_TI_IF_DL_CREATE.DLMAKE_FE(nCOMPANY      => nCOMPANY,
                                    SATRIB        => SATRIB,
                                    nDOC_RN_TI    => nDOC_RN_TI,
                                    nDOC_RN_TI_ND => nDOC_RN_TI_ND,
                                    nDOC_RN_IF    => nDOC_RN_IF,
                                    nDOC_RN_IF_ND => nDOC_RN_IF_ND);
end UDO_P_TI_IF_DLMAKE_FE;
-- grant execute on UDO_P_TI_IF_DLMAKE_FE to public;
/

