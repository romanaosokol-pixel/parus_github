create or replace procedure UP_DMSSRCGEN_FILLLINK
(
  nCOMPANY     in number,
  nIDENT       in number,
  sLINKNAME    in varchar2,
  sSRCKEY      in varchar2
)
as
  sTABLE       UNITLIST.TABLE_NAME%type;
  sNAME        DMSCLATTRS.COLUMN_NAME%type;
  nCLASS       PKG_STD.tREF;
  sSTR         PKG_STD.tSTRING;
  nRN          PKG_STD.tREF;
  nMRN         PKG_STD.tREF;
  nSRCKEY      PKG_STD.tREF;
  nSRCCLASS    UNITLIST.RN%type;
  sSRCCLASS    UNITLIST.UNITCODE%type;
  sSRCATTRIB   DMSCLATTRS.COLUMN_NAME%type;

  procedure P_CHECK_LEN
  (
    sNAME      in varchar2
  )
  as
  begin
    if length(sNAME) > 30 then
      P_EXCEPTION(0, 'Длина идентификатора "' || sNAME || '" более 30 символов.');
    end if;
  end;

begin
  /* Инициализация ******************************************************************************** */
  begin
    select A.COLUMN_NAME, A.PRN, U.TABLE_NAME
      into sNAME, nCLASS, sTABLE
      from SELECTLIST L,
           DMSCLATTRS A,
           UNITLIST U
     where L.IDENT = nIDENT
       and A.RN = L.DOCUMENT
       and U.RN = A.PRN;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Атрибут не найден.');
  end;

  FIND_DMSCLCONSTRS_NAME(0, 0, sSRCKEY, nSRCKEY);

  begin
    select U.RN, U.UNITCODE
      into nSRCCLASS, sSRCCLASS
      from DMSCLCONSTRS C,
           UNITLIST U
     where C.RN = nSRCKEY
       and U.RN = C.PRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nSRCKEY, 'Units');
  end;

  sSTR := 'C_' || sTABLE || '_' || sNAME || '_FK';
  P_CHECK_LEN(sSTR);
  P_DMSCLLINKS_INSERT(sSRCCLASS, nCLASS, null, 1, sSRCKEY, sSTR, sLINKNAME, 0, null, null, null, null, null, nMRN);

  begin
    select A.COLUMN_NAME
      into sSRCATTRIB
      from DMSCLCONATTRS CA,
           DMSCLATTRS A
     where CA.PRN = nSRCKEY
       and CA.POSITION = 1
       and CA.ATTRIBUTE = A.RN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nSRCKEY, 'Units');
  end;

  P_DMSCLLINKATTRS_INSERT(nMRN, 1, nSRCCLASS, nCLASS, sSRCATTRIB, sNAME, nRN);
end;
/

