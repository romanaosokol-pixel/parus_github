create or replace procedure UDO_P_PRJSTG_PRCLCINCL_UPD
(
  NCOMPANY in number,
  NRN      in number,
  NSIGN    in number,
  NPERCENT in number
) is
  /*
    Процедура перезаписи процента вхождения
    grant execute on UDO_P_PRJSTG_PRCLCINCL_UPD to public;
  */
begin
  UDO_PKG_PRJSTG_PRSTRUCT.ART_UPDATE(NRN      => NRN
                                    ,NSIGN    => NSIGN
                                    ,NPERCENT => NPERCENT);
end UDO_P_PRJSTG_PRCLCINCL_UPD;
/

