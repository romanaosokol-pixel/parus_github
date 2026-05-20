create or replace procedure UDO_P_PRJSTG_PRCLCINCL_PRN_UPD
(
  NRN      in number,
  NPERCENT in number
) is
  /*
    Процедура перезаписи процента вхождения родительской статьи
    grant execute on UDO_P_PRJSTG_PRCLCINCL_UPD to public;
  */
begin
  UDO_PKG_PRJSTG_PRSTRUCT.CLC_SET_PRNPERCENT(NRN          => NRN
                                            ,NPRN_PERCENT => NPERCENT);
end UDO_P_PRJSTG_PRCLCINCL_PRN_UPD;
/

