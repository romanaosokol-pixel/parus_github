create or replace procedure UDO_P_SHEETD28_INSERT(
       nCOMPANY             in number,   -- Организация
       nCRN                 in number,   -- Каталог
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
       sBARCODE             in varchar2, -- Штрих-код документа
       nDUP_RN              in number,   -- Регистрационный номер размножаемой записи
       nRN                  out number   -- Регистрационный номер
       ) is
/* Добавление записи ведомости Д28 */
  nDOCTYPE       PKG_STD.tREF;  -- Тип документа
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
  nSUBDIV        PKG_STD.tREF;  -- Подразделение
  nRESPONSIBLE   PKG_STD.tREF;  -- Ответственный
  nMATRES        PKG_STD.tREF;  -- Изделие
begin

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, sJUR_PERS, 'UdoSheetD28', 'UDO_SHEETD28_INSERT', 'UDO_SHEETD28' );

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

  /* Базовое добавление */
  UDO_PKG_SHEETD28_BASE.DOC_INSERT(
      nCOMPANY             => nCOMPANY,
      nCRN                 => nCRN,
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
      sBARCODE             => sBARCODE,
      nRN                  => nRN
      );

  /* Если размножение */
  if nDUP_RN is not null then
    null;
  end if;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', 'UDO_SHEETD28_INSERT', 'UDO_SHEETD28', nRN );

end UDO_P_SHEETD28_INSERT;
/

