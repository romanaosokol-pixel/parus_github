create or replace procedure UDO_P_LST_OPER_OLAP
(
  nCOMPANY in number,
  dBEGDATE in date,
  dENDDATE in date
) as
  /*
    27/03/2024 Марков МВ.
    многомерный отчет "Операции по МЛ"
  */
begin
  delete from IDLIST;
  insert into IDLIST(ID, HID)
  select 154, LSH.RN
  from UDO_FCROUTLST_HIST LSH
  where trunc(LSH.STATE_DATE) between dBEGDATE and dENDDATE;
end;
/
