create or replace procedure UP_DMSSRCGEN_FILLCONSTR
(
  nCOMPANY     in number,
  nIDENT       in number,
  nMAKE_NN     in number,
  nMAKE_NB     in number,
  sNB_TEXT     in varchar2,
  nMAKE_UK     in number,
  sUK_TEXT     in varchar2,
  nMAKE_VL     in number,
  sVL_TEXT     in varchar2
)
as
  sTABLE        UNITLIST.TABLE_NAME%type;
  nSIGN_SHARE   UNITLIST.SIGN_SHARE%type;
  nSIGN_ACCREG  UNITLIST.SIGN_ACCREG%type;
  sPARENT       UNITLIST.PARENTCODE%type;
  sNAME         DMSCLATTRS.COLUMN_NAME%type;
  nDATA_TYPE    DMSDOMAINS.DATA_TYPE%type;
  nDATA_SUBTYPE DMSDOMAINS.DATA_SUBTYPE%type;
  nCLASS        PKG_STD.tREF;
  nDOMAIN       PKG_STD.tREF;
  sSTR          PKG_STD.tSTRING;
  sTEXT         PKG_STD.tSTRING;
  nRN           PKG_STD.tREF;
  nMRN          PKG_STD.tREF;
  lCOMPANY      boolean := false;
  lVERSION      boolean := false;
  lPARENT       boolean := false;
  I             integer;

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
    select A.COLUMN_NAME, A.PRN, A.DOMAIN, U.TABLE_NAME, U.SIGN_SHARE, U.SIGN_ACCREG, U.PARENTCODE, D.DATA_TYPE, D.DATA_SUBTYPE
      into sNAME, nCLASS, nDOMAIN, sTABLE, nSIGN_SHARE, nSIGN_ACCREG, sPARENT, nDATA_TYPE, nDATA_SUBTYPE
      from SELECTLIST L,
           DMSCLATTRS A,
           UNITLIST U,
           DMSDOMAINS D
     where L.IDENT = nIDENT
       and A.RN = L.DOCUMENT
       and U.RN = A.PRN
       and A.DOMAIN = D.RN;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Атрибут не найден.');
  end;

  if nSIGN_SHARE = 1 then
    if nSIGN_ACCREG = 0 then
      lVERSION := true;
    else
      lCOMPANY := true;
    end if;
  end if;

  if sPARENT is not null then
    lPARENT := true;
  end if;

  if nMAKE_NN = 1 then
    sSTR  := F_GEN_CONSTRAINT_NAME('C_', sTABLE, sNAME, '_SNN');
    sTEXT := 'C_' || sTABLE || '_' || sNAME || '_SNN';
    P_CHECK_LEN(sSTR);
    P_DMSCLCONSTRS_INSERT_ADV(nCLASS, sTEXT, sSTR, 5, null, 'C_SYSTEM_NOTNULL', null, null, 0, nMRN);
    P_DMSCLCONATTRS_INSERT(nMRN, 1, sNAME, nRN);
  end if;

  if nMAKE_NB = 1 then
    sSTR := 'C_' || sTABLE || '_' || sNAME || '_NB';
    P_CHECK_LEN(sSTR);
    if nMAKE_NN = 1 then
      sTEXT := 'rtrim(' || sNAME || ') is not null';
    else
      sTEXT := sNAME || ' is null or rtrim(' || sNAME || ') is not null';
    end if;
    P_DMSMESSAGES_INSERT
    (
      sCODE => sSTR,
      nKIND => 0,
      sTEXT => sNB_TEXT,
      nRN   => nRN
    );
    P_DMSCLCONSTRS_INSERT_ADV(nCLASS, sSTR, sSTR, 2, null, sSTR, sTEXT, null, 0, nMRN);
    P_DMSCLCONATTRS_INSERT(nMRN, 1, sNAME, nRN);
  end if;

  if nMAKE_UK = 1 then
    sSTR := 'C_' || sTABLE || '_' || sNAME || '_UK';
    P_CHECK_LEN(sSTR);
    P_DMSMESSAGES_INSERT
    (
      sCODE => sSTR,
      nKIND => 0,
      sTEXT => sUK_TEXT,
      nRN   => nRN
    );
    P_DMSCLCONSTRS_INSERT_ADV(nCLASS, sSTR, sSTR, 0, null, sSTR, null, null, 0, nMRN);

    if lPARENT then
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'PRN', nRN);
    else
      if lVERSION then
        P_DMSCLCONATTRS_INSERT(nMRN, 1, 'VERSION', nRN);
      end if;
      if lCOMPANY then
        P_DMSCLCONATTRS_INSERT(nMRN, 1, 'COMPANY', nRN);
      end if;
    end if;

    P_DMSCLCONATTRS_INSERT(nMRN, 2, sNAME, nRN);
  end if;

  if nMAKE_VL = 1 then
    sSTR := 'C_' || sTABLE || '_' || sNAME || '_VAL';
    P_CHECK_LEN(sSTR);
    P_DMSMESSAGES_INSERT
    (
      sCODE => sSTR,
      nKIND => 0,
      sTEXT => sVL_TEXT,
      nRN   => nRN
    );
    sTEXT := sNAME || ' in (';

    if nDATA_TYPE = 1 and nDATA_SUBTYPE = 1 then
      -- Это логический тип
      sTEXT := sTEXT || '0,1';
    else
      I := 0;
      for cREC in (
        select VALUE_NUM
          from DMSENUMVALUES
         where PRN = nDOMAIN
         order by POSITION
      ) loop
        if I > 0 then
          sTEXT := sTEXT || ',';
        end if;
        I := I + 1;
        sTEXT := sTEXT || to_char(cREC.VALUE_NUM);
      end loop;
    end if;

    sTEXT := sTEXT || ')';
    P_DMSCLCONSTRS_INSERT_ADV(nCLASS, sSTR, sSTR, 2, null, sSTR, sTEXT, null, 0, nMRN);
    P_DMSCLCONATTRS_INSERT(nMRN, 1, sNAME, nRN);
  end if;
end UP_DMSSRCGEN_FILLCONSTR;
/

