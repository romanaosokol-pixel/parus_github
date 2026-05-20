create or replace procedure UDO_P_SHEETD28SP_DELETE(
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number    -- Организация
       ) is
/* Удаление записи спецификации ведомости Д28 */
  nPRN           PKG_STD.tREF;  -- Регистрационный номер родителя
  nCRN           PKG_STD.tREF;  -- Каталог
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
begin

  /* Считывание записи */
  UDO_PKG_SHEETD28_BASE.SPEC_EXISTS(nRN, nCOMPANY, nPRN, nCRN, nJUR_PERS);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28Specs', 'UDO_SHEETD28SP_DELETE', 'UDO_SHEETD28SP', nRN );

  /* Базовое удаление */
  UDO_PKG_SHEETD28_BASE.SPEC_DELETE(nRN, nCOMPANY);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28Specs', 'UDO_SHEETD28SP_DELETE', 'UDO_SHEETD28SP', nRN );

end UDO_P_SHEETD28SP_DELETE;
/

