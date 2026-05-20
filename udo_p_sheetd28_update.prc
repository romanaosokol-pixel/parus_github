create or replace procedure UDO_P_SHEETD28_UPDATE(
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number,   -- Организация
       sJUR_PERS            in varchar2, -- Принадлежность
       sDOCTYPE             in varchar2, -- Тип документа
       sDOCPREF             in varchar2, -- Префикс документа
       sDOCNUMB             in varchar2, -- Номер документа
       dDOCDATE             in date,     -- Дата документа
       sEXT_NUMBER          in varchar2, -- Внешний номер
       sSUBDIV              in varchar2, -- Подразделение
       sRESPONSIBLE         in varchar2, -- Ответственный
       sMATRES_NOMEN        in varchar2, -- Изделие (номенклатура)
       sMATRES_MODIF        in varchar2, -- Изделие (модификация номенклатуры)
       sNOTE                in varchar2, -- Примечание
       sBARCODE             in varchar2  -- Штрих-код документа
       ) is
/* Исправление записи ведомости Д28 */
  nCRN           PKG_STD.tREF;  -- Каталог
  nJUR_PERS_OLD  PKG_STD.tREF;  -- Принадлежность (текущий)
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
  nDOCTYPE       PKG_STD.tREF;  -- Тип документа
  nSUBDIV        PKG_STD.tREF;  -- Подразделение
  nRESPONSIBLE   PKG_STD.tREF;  -- Ответственный
  nMATRES        PKG_STD.tREF;  -- Изделие
begin
  /* считывание записи */
  UDO_PKG_SHEETD28_BASE.DOC_EXISTS(nRN, nCOMPANY, nCRN, nJUR_PERS_OLD);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS_OLD, 'UdoSheetD28', 'UDO_SHEETD28_UPDATE', 'UDO_SHEETD28', nRN );

  /* Разрешение ссылок */
  UDO_P_SHEETD28_JOINS(
      nCOMPANY             => nCOMPANY,
      sJUR_PERS            => sJUR_PERS,
      sDOCTYPE             => sDOCTYPE,
      sSUBDIV              => sSUBDIV,
      sRESPONSIBLE         => sRESPONSIBLE,
      sMATRES_NOMEN        => sMATRES_NOMEN,
      sMATRES_MODIF        => sMATRES_MODIF,
      nJUR_PERS            => nJUR_PERS,
      nDOCTYPE             => nDOCTYPE,
      nSUBDIV              => nSUBDIV,
      nRESPONSIBLE         => nRESPONSIBLE,
      nMATRES              => nMATRES
      );

  if ( CMP_NUM(nJUR_PERS, nJUR_PERS_OLD) = 0 ) then
    /* проверка прав доступа к новому юридическому лицу */
    PKG_ENV.ACCESS_JURPERS(nJUR_PERS);
  end if;

  /* Базовое исправление */
  UDO_PKG_SHEETD28_BASE.DOC_UPDATE(
      nRN                  => nRN,
      nCOMPANY             => nCOMPANY,
      nJUR_PERS            => nJUR_PERS,
      nDOCTYPE             => nDOCTYPE,
      sDOCPREF             => sDOCPREF,
      sDOCNUMB             => sDOCNUMB,
      dDOCDATE             => dDOCDATE,
      sEXT_NUMBER          => sEXT_NUMBER,
      nSUBDIV              => nSUBDIV,
      nRESPONSIBLE         => nRESPONSIBLE,
      nMATRES              => nMATRES,
      sNOTE                => sNOTE,
      sBARCODE             => sBARCODE
      );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS_OLD, 'UdoSheetD28', 'UDO_SHEETD28_UPDATE', 'UDO_SHEETD28', nRN );

end UDO_P_SHEETD28_UPDATE;
/

