create or replace procedure UDO_P_SHEETD28_DELETE(
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number    -- Организация
       ) is
/* Удаление записи ведомости Д28 */
  nCRN           PKG_STD.tREF;  -- Каталог
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
begin
  /* считывание записи */
  UDO_PKG_SHEETD28_BASE.DOC_EXISTS(nRN, nCOMPANY, nCRN, nJUR_PERS);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', 'UDO_SHEETD28_DELETE', 'UDO_SHEETD28', nRN );

  /* Базовое удаление */
  UDO_PKG_SHEETD28_BASE.DOC_DELETE(nRN, nCOMPANY);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', 'UDO_SHEETD28_DELETE', 'UDO_SHEETD28', nRN );

end UDO_P_SHEETD28_DELETE;
/

