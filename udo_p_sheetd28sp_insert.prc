create or replace procedure UDO_P_SHEETD28SP_INSERT(
       nCOMPANY             in number,   -- Организация
       nPRN                 in number,   -- Регистрационный номер родителя
       sMATRES_NOMEN        in varchar2, -- Изделие (номенклатура)
       sMATRES_MODIF        in varchar2, -- Изделие (модификация номенклатуры)
       sMATRES_DIFF_NOMEN   in varchar2, -- Изделие (номенклатура)
       sMATRES_DIFF_MODIF   in varchar2, -- Изделие (модификация номенклатуры)
       sNOTE                in varchar2, -- Примечание
       nDUP_RN              in number,   -- Регистрационный номер размножаемой записи
       nRN                  out number   -- Регистрационный номер
       ) is
/* Добавление записи спецификации ведомости Д28 */
  nCRN           PKG_STD.tREF;  -- Каталог
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
  nMATRES        PKG_STD.tREF;  -- Изделие
  nMATRES_DIFF   PKG_STD.tREF;  -- Изделие
begin

  /* Считывание записи */
  UDO_PKG_SHEETD28_BASE.DOC_EXISTS(nPRN, nCOMPANY, nCRN, nJUR_PERS);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28Specs', 'UDO_SHEETD28SP_INSERT', 'UDO_SHEETD28SP' );

  /* Разрешение ссылок */
  UDO_P_SHEETD28SP_JOINS(
      nCOMPANY             => nCOMPANY,
      sMATRES_NOMEN        => sMATRES_NOMEN,
      sMATRES_MODIF        => sMATRES_MODIF,
      sMATRES_DIFF_NOMEN   => sMATRES_DIFF_NOMEN,
      sMATRES_DIFF_MODIF   => sMATRES_DIFF_MODIF,
      nMATRES              => nMATRES,
      nMATRES_DIFF         => nMATRES_DIFF
      );

  /* Базовое добавление */
  UDO_PKG_SHEETD28_BASE.SPEC_INSERT(
      nCOMPANY             => nCOMPANY,
      nPRN                 => nPRN,
      nMATRES              => nMATRES,
      nMATRES_DIFF         => nMATRES_DIFF,
      sNOTE                => sNOTE,
      nRN                  => nRN
      );

  /* Если размножение */
  if nDUP_RN is not null then
    null;
  end if;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28Specs', 'UDO_SHEETD28SP_INSERT', 'UDO_SHEETD28SP', nRN );

end UDO_P_SHEETD28SP_INSERT;
/

