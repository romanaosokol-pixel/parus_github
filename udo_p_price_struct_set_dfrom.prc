create or replace procedure UDO_P_PRICE_STRUCT_SET_DFROM
(
  NPRN  in number,
  DDATE out date
) is
  NRN number;
begin
  begin
    select T.RN
      into NRN
      from UDO_PRJSTG_PRSTRUCT T
     where T.PRN = NPRN
       and ROWNUM = 1;
  exception
    when NO_DATA_FOUND then
      begin
        select PS.BEGPLAN
          into DDATE
          from PROJECTSTAGE PS
         where PS.RN = NPRN;
      exception
        when NO_DATA_FOUND then
          DDATE := null;
      end;
  end;
end UDO_P_PRICE_STRUCT_SET_DFROM;
/

