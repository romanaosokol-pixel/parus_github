create or replace procedure UP_DMSSRCGEN_FILLSTD
(
  nCOMPANY     in number,
  nIDENT       in number,
  sNAME        in varchar2,
  nATTRIB      in number,
  nATTRIB_HLEV in number,
  nATTRIB_CODE in number,
  nATTRIB_NAME in number,
  nCONSTR      in number,
  nLINK        in number,
  nACTION      in number,
  nVIEW        in number,
  nFORM        in number
)
as
  sTABLE        UNITLIST.TABLE_NAME%type;
  sCLASS        UNITLIST.UNITCODE%type;
  sPARENT       UNITLIST.PARENTCODE%type;
  nPARENT       UNITLIST.HRN%type;
  nSIGN_SHARE   UNITLIST.SIGN_SHARE%type;
  nSIGN_ACCREG  UNITLIST.SIGN_ACCREG%type;
  nSIGN_HIER    UNITLIST.SIGN_HIER%type;
  nHIER         UNITLIST.HIERARCHICAL%type;
  nSIGN_JURPERS UNITLIST.SIGN_JURPERS%type;
  nCLASS        PKG_STD.tREF;
  nRN           PKG_STD.tREF;
  nMRN          PKG_STD.tREF;
  nSRN          PKG_STD.tREF;
  nPOS          PKG_STD.tNUMBER;
  lCOMPANY      boolean := false;
  lVERSION      boolean := false;
  lCATALOG      boolean := false;
  lPARENT       boolean := false;
  lHIER         boolean := false;
  lJUR_PERS     boolean := false;
  sSTR          PKG_STD.tSTRING;
  sSTR1         PKG_STD.tSTRING;
begin
  /* Инициализация ******************************************************************************** */
  begin
    select U.RN, U.SIGN_SHARE, U.SIGN_ACCREG, U.SIGN_HIER, U.TABLE_NAME, U.UNITCODE, U.PARENTCODE, U.HRN, U.HIERARCHICAL,
           U.SIGN_JURPERS
      into nCLASS, nSIGN_SHARE, nSIGN_ACCREG, nSIGN_HIER, sTABLE, sCLASS, sPARENT, nPARENT, nHIER,
           nSIGN_JURPERS
      from SELECTLIST L,
           UNITLIST U
     where L.IDENT = nIDENT
       and U.RN = L.DOCUMENT;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Раздел не найден.');
  end;

  if nSIGN_SHARE = 1 then
    if nSIGN_ACCREG = 0 then
      lVERSION := true;
    else
      lCOMPANY := true;
    end if;
  end if;

  if nSIGN_HIER = 1 then
    lCATALOG := true;
  end if;

  if nHIER = 1 then
    lHIER := true;
  end if;

  if nSIGN_JURPERS = 1 then
    lJUR_PERS := true;
  end if;

  if sPARENT is not null then
    lPARENT := true;
  end if;

  nPOS := 0;

  if nATTRIB = 1 then
    /* Добавляем атрибуты *************************************************************************** */
    nPOS := nPOS + 1;
    P_DMSCLATTRS_INSERT(nCLASS, 'RN', 'Регистрационный номер', 0, nPOS, 'TRN', null, null, nRN);

    if lVERSION then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'VERSION', 'Версия', 0, nPOS, 'TVERSION', null, null, nRN);
    end if;

    if lCOMPANY then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'COMPANY', 'Организация', 0, nPOS, 'TCOMPANY', null, null, nRN);
    end if;

    if lCATALOG then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'CRN', 'Каталог', 0, nPOS, 'TCRN', null, null, nRN);
    end if;

    if lHIER then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'HRN', 'Родитель в иерархии', 0, nPOS, 'TRN', null, null, nRN);
      if nATTRIB_HLEV = 1 then
        nPOS := nPOS + 1;
        P_DMSCLATTRS_INSERT(nCLASS, 'HIER_LEVEL', 'Уровень иерархии', 0, nPOS, 'THIERLEVEL', null, null, nRN);
      end if;
    end if;

    if lPARENT then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'PRN', 'Родитель', 0, nPOS, 'TRN', null, null, nRN);
    end if;

    if lJUR_PERS then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'JUR_PERS', 'Юридическое лицо', 0, nPOS, 'TRN', null, null, nRN);
    end if;

    if nATTRIB_CODE = 1 then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'CODE', 'Мнемокод', 0, nPOS, 'TCODE', null, null, nRN);
    end if;

    if nATTRIB_NAME = 1 then
      nPOS := nPOS + 1;
      P_DMSCLATTRS_INSERT(nCLASS, 'NAME', 'Наименование', 0, nPOS, 'TNAME', null, null, nRN);
    end if;
  end if;

  if nCONSTR = 1 then
    /* Добавляем ограничения ************************************************************************ */
    sSTR := 'C_' || sTABLE || '_PK';
    P_DMSMESSAGES_INSERT
    (
      sCODE => sSTR,
      nKIND => 0,
      sTEXT => 'Дублирование регистрационного номера '||sNAME||'.',
      nRN   => nRN
    );
    P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Первичный ключ', sSTR, 1, null, sSTR, null, null, 0, nMRN);
    P_DMSCLCONATTRS_INSERT(nMRN, 1, 'RN', nRN);

    P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Регистрационный номер обязателен', sSTR || '_SNN', 5, null, 'C_SYSTEM_NOTNULL', null, null, 0, nMRN);
    P_DMSCLCONATTRS_INSERT(nMRN, 1, 'RN', nRN);

    if lVERSION then
      sSTR := F_GEN_CONSTRAINT_NAME('C_', sTABLE, 'VERSION', '_SNN');
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Версия обязательна', sSTR, 5, null, 'C_SYSTEM_VERSION', null, null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'VERSION', nRN);
    end if;

    if lCOMPANY then
      sSTR := F_GEN_CONSTRAINT_NAME('C_', sTABLE, 'COMPANY', '_SNN');
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Организация обязательна', sSTR, 5, null, 'C_SYSTEM_COMPANY', null, null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'COMPANY', nRN);
    end if;

    if lCATALOG then
      sSTR := F_GEN_CONSTRAINT_NAME('C_', sTABLE, 'CRN', '_SNN');
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Каталог обязателен', sSTR, 5, null, 'C_SYSTEM_CATALOG', null, null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'CRN', nRN);
    end if;

    if lHIER and nATTRIB_HLEV = 1 then
      sSTR := F_GEN_CONSTRAINT_NAME('C_', sTABLE, 'HIER_LEVEL', '_SNN');
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Уровень иерархии', sSTR, 5, null, 'C_SYSTEM_NOTNULL', null, null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'HIER_LEVEL', nRN);
      sSTR := 'C_' || sTABLE || '_HIER_LEVEL_VAL';
      P_DMSMESSAGES_INSERT
      (
        sCODE => sSTR,
        nKIND => 0,
        sTEXT => 'Недопустимое значение уровня иерархии.',
        nRN   => nRN
      );
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Уровень иерархии >= 1', sSTR, 2, null, sSTR, 'HIER_LEVEL >= 1', null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'HIER_LEVEL', nRN);
    end if;

    if lPARENT then
      sSTR := F_GEN_CONSTRAINT_NAME('C_', sTABLE, 'PRN', '_SNN');
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Родитель обязателен', sSTR, 5, null, 'C_SYSTEM_PRN', null, null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'PRN', nRN);
    end if;

    if lJUR_PERS then
      sSTR := F_GEN_CONSTRAINT_NAME('C_', sTABLE, 'JURPERS', '_SNN');
      P_DMSCLCONSTRS_INSERT_ADV(nCLASS, 'Юридическое лицо обязателено', sSTR, 5, null, 'C_SYSTEM_NOTNULL', null, null, 0, nMRN);
      P_DMSCLCONATTRS_INSERT(nMRN, 1, 'JUR_PERS', nRN);
    end if;
  end if;

  if nLINK = 1 then
    /* Добавляем связи ****************************************************************************** */
    if lVERSION then
      sSTR := 'C_' || sTABLE || '_VERSION_FK';
      P_DMSCLLINKS_INSERT('VersionsUnits', nCLASS, 'Связь с версиями', 1, 'C_VERSIONS_PK', sSTR, 'Ссылка на версии', 0, null, null, null, null, null, nMRN);
      FIND_UNITLIST_CODE(0, 0, 'VersionsUnits', nSRN);
      P_DMSCLLINKATTRS_INSERT(nMRN, 1, nSRN, nCLASS, 'RN', 'VERSION', nRN);
    end if;

    if lCOMPANY then
      sSTR := 'C_' || sTABLE || '_COMPANY_FK';
      P_DMSCLLINKS_INSERT('Companies', nCLASS, 'Связь с организациями', 1, 'C_COMPANIES_PK', sSTR, 'Ссылка на организации', 0, null, null, null, null, null, nMRN);
      FIND_UNITLIST_CODE(0, 0, 'Companies', nSRN);
      P_DMSCLLINKATTRS_INSERT(nMRN, 1, nSRN, nCLASS, 'RN', 'COMPANY', nRN);
    end if;

    if lCATALOG then
      sSTR := 'C_' || sTABLE || '_CRN_FK';
      P_DMSCLLINKS_INSERT('CatalogTree', nCLASS, 'Связь с каталогами', 1, 'C_ACATALOG_PK', sSTR, 'Ссылка на каталоги', 0, null, null, null, null, null, nMRN);
      FIND_UNITLIST_CODE(0, 0, 'CatalogTree', nSRN);
      P_DMSCLLINKATTRS_INSERT(nMRN, 1, nSRN, nCLASS, 'RN', 'CRN', nRN);
    end if;

    if lHIER then
      sSTR := 'C_' || sTABLE || '_HRN_FK';
      P_DMSCLLINKS_INSERT(sCLASS, nCLASS, 'Связь с родителем в иерархии', 1, 'C_' || sTABLE || '_PK', sSTR, 'Ссылка на родителя в иерархии', 1, null, null, PKG_EXT.IIF(nATTRIB_HLEV = 1, 'HIER_LEVEL', null), null, null, nMRN);
      P_DMSCLLINKATTRS_INSERT(nMRN, 1, nCLASS, nCLASS, 'RN', 'HRN', nRN);
    end if;

    if lPARENT then
      sSTR := 'C_' || sTABLE || '_PRN_FK';
      -- Поиск первичного ключа родителя
      begin
        select CONSTRAINT_NAME
          into sSTR1
          from DMSCLCONSTRS
         where PRN = nPARENT
           and CONSTRAINT_TYPE = 1;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION( 0, 'Для раздела "%s" не определён первичный ключ.', sPARENT );
      end;

      P_DMSCLLINKS_INSERT(sPARENT, nCLASS, 'Master-Detail', 1, sSTR1, sSTR, 'Ссылка на родителя', 1, null, null, null, null, null, nMRN);
      FIND_UNITLIST_CODE(0, 0, sPARENT, nSRN);
      P_DMSCLLINKATTRS_INSERT(nMRN, 1, nSRN, nCLASS, 'RN', 'PRN', nRN);
    end if;

    if lJUR_PERS then
      sSTR := 'C_' || sTABLE || '_JURPERS_FK';
      P_DMSCLLINKS_INSERT('JuridicalPersons', nCLASS, 'Связь с юридическими лицами', 1, 'C_JURPERSONS_PK', sSTR, 'Ссылка на юридическое лицо', 0, null, null, null, null, null, nMRN);
      FIND_UNITLIST_CODE(0, 0, 'JuridicalPersons', nSRN);
      P_DMSCLLINKATTRS_INSERT(nMRN, 1, nSRN, nCLASS, 'RN', 'JUR_PERS', nRN);
    end if;
  end if;

  if nACTION = 1 then
    /* Добавляем действия *************************************************************************** */
    sSTR := sTABLE || '_INSERT';
    P_DMSCLACTIONS_INSERT_ADV
    (
      nCLASS, -- nPRN
      null, -- sDETAILCODE
      sSTR, -- sCODE
      'Добавление/размножение '||sNAME, -- sNAME
      10, -- nNUMB
      1, -- nSTANDARD
      null, -- nOVERRIDE
      0, -- nUNCOND_ACCESS
      null, -- sMETHOD
      0, -- nPROCESS_MODE
      1, -- nTRANSACT_MODE
      0, -- nREFRESH_MODE
      0, -- nSHOW_DIALOG
      null, -- sSYSIMAGE
      0, -- nONLY_CUSTOM_MODE
      nRN -- nRN
    );
    sSTR := sTABLE || '_UPDATE';
    P_DMSCLACTIONS_INSERT_ADV
    (
      nCLASS, -- nPRN
      null, -- sDETAILCODE
      sSTR, -- sCODE
      'Исправление '||sNAME, -- sNAME
      20, -- nNUMB
      2, -- nSTANDARD
      null, -- nOVERRIDE
      0, -- nUNCOND_ACCESS
      null, -- sMETHOD
      1, -- nPROCESS_MODE
      1, -- nTRANSACT_MODE
      1, -- nREFRESH_MODE
      0, -- nSHOW_DIALOG
      null, -- sSYSIMAGE
      0, -- nONLY_CUSTOM_MODE
      nRN -- nRN
    );
    sSTR := sTABLE || '_DELETE';
    P_DMSCLACTIONS_INSERT_ADV
    (
      nCLASS, -- nPRN
      null, -- sDETAILCODE
      sSTR, -- sCODE
      'Удаление '||sNAME, -- sNAME
      30, -- nNUMB
      3, -- nSTANDARD
      null, -- nOVERRIDE
      0, -- nUNCOND_ACCESS
      null, -- sMETHOD
      2, -- nPROCESS_MODE
      1, -- nTRANSACT_MODE
      2, -- nREFRESH_MODE
      0, -- nSHOW_DIALOG
      null, -- sSYSIMAGE
      0, -- nONLY_CUSTOM_MODE
      nRN -- nRN
    );

    if lCATALOG and not lPARENT then
      sSTR := sTABLE || '_MOVE_IN';
      P_DMSCLACTIONS_INSERT_ADV
      (
        nCLASS, -- nPRN
        null, -- sDETAILCODE
        sSTR, -- sCODE
        'Перемещение '||sNAME||' (в каталог)', -- sNAME
        40, -- nNUMB
        4, -- nSTANDARD
        null, -- nOVERRIDE
        0, -- nUNCOND_ACCESS
        null, -- sMETHOD
        2, -- nPROCESS_MODE
        1, -- nTRANSACT_MODE
        2, -- nREFRESH_MODE
        0, -- nSHOW_DIALOG
        null, -- sSYSIMAGE
        0, -- nONLY_CUSTOM_MODE
        nRN -- nRN
      );
      sSTR := sTABLE || '_MOVE_OUT';
      P_DMSCLACTIONS_INSERT_ADV
      (
        nCLASS, -- nPRN
        null, -- sDETAILCODE
        sSTR, -- sCODE
        'Перемещение '||sNAME||' (из каталога)', -- sNAME
        50, -- nNUMB
        5, -- nSTANDARD
        null, -- nOVERRIDE
        0, -- nUNCOND_ACCESS
        null, -- sMETHOD
        2, -- nPROCESS_MODE
        1, -- nTRANSACT_MODE
        2, -- nREFRESH_MODE
        0, -- nSHOW_DIALOG
        null, -- sSYSIMAGE
        0, -- nONLY_CUSTOM_MODE
        nRN -- nRN
      );
    end if;

    if lHIER then
      sSTR := sTABLE || '_MOVE';
      P_DMSCLACTIONS_INSERT_ADV
      (
        nCLASS, -- nPRN
        null, -- sDETAILCODE
        sSTR, -- sCODE
        'Перемещение '||sNAME||' (в иерархии)', -- sNAME
        60, -- nNUMB
        6, -- nSTANDARD
        null, -- nOVERRIDE
        0, -- nUNCOND_ACCESS
        null, -- sMETHOD
        2, -- nPROCESS_MODE
        1, -- nTRANSACT_MODE
        2, -- nREFRESH_MODE
        0, -- nSHOW_DIALOG
        null, -- sSYSIMAGE
        0, -- nONLY_CUSTOM_MODE
        nRN -- nRN
      );
    end if;
  end if;

  begin
    select UNITNAME
      into sSTR
      from UNITLIST
     where RN = nCLASS;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Раздел не найден.');
  end;

  if nVIEW = 1 then
    /* Добавляем представление ********************************************************************** */
    P_DMSCLVIEWS_INSERT(nCLASS, 'V_' || sTABLE, sSTR, null, 1, 0, null, null, nRN);
  end if;

  if nFORM = 1 then
    /* Добавляем форму ****************************************************************************** */
    P_USERFORMS_INSERT
    (
      nFORM_KIND       => 5,
      sFORM_UNITCODE   => sCLASS,
      sSHOW_METHOD     => null,
      nFORM_ID         => 0,
      sFORM_CLASS      => sSTR,
      sFORM_NAME       => sSTR,
      nLINK_APPS       => 0,
      nLINK_PRIVS      => 0,
      nFORM_ACTIVE     => 1,
      nEVENTS_LANGUAGE => null,
      nDUP_RN          => null,
      nRN              => nRN
    );
  end if;
end UP_DMSSRCGEN_FILLSTD;
/

