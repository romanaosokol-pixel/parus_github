create or replace procedure UDO_P_SHEETD28SP_UPDATE(
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number,   -- Организация
       sMATRES_NOMEN        in varchar2, -- Изделие (номенклатура)
       sMATRES_MODIF        in varchar2, -- Изделие (модификация номенклатуры)
       sMATRES_DIFF_NOMEN   in varchar2, -- Изделие (номенклатура)
       sMATRES_DIFF_MODIF   in varchar2, -- Изделие (модификация номенклатуры)
       sNOTE                in varchar2  -- Примечание
       ) is
/* Исправление записи спецификации ведомости Д28 */
  nPRN           PKG_STD.tREF;  -- Регистрационный номер родителя
  nCRN           PKG_STD.tREF;  -- Каталог
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
  nMATRES        PKG_STD.tREF;  -- Изделие
  nMATRES_DIFF   PKG_STD.tREF;  -- Изделие
begin

  /* Считывание записи */
  UDO_PKG_SHEETD28_BASE.SPEC_EXISTS(nRN, nCOMPANY, nPRN, nCRN, nJUR_PERS);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28Specs', 'UDO_SHEETD28SP_UPDATE', 'UDO_SHEETD28SP', nRN );

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

  /* Базовое исправление */
  UDO_PKG_SHEETD28_BASE.SPEC_UPDATE(
      nRN                  => nRN,
      nCOMPANY             => nCOMPANY,
      nMATRES              => nMATRES,
      nMATRES_DIFF         => nMATRES_DIFF,
      sNOTE                => sNOTE
      );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28Specs', 'UDO_SHEETD28SP_UPDATE', 'UDO_SHEETD28SP', nRN );

end UDO_P_SHEETD28SP_UPDATE;
/

