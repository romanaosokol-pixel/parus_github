create or replace procedure UDO_P_SHEETD28_MAKESPEC(
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number    -- Организация
       ) is
/* Формирование спецификации ведомости Д28 по спецификации изделия */
  nCRN           PKG_STD.tREF;  -- Каталог
  nJUR_PERS      PKG_STD.tREF;  -- Принадлежность
  nMATRES        PKG_STD.tREF;  -- Изделие
begin
  /* считывание записи */
  UDO_PKG_SHEETD28_BASE.DOC_EXISTS(nRN, nCOMPANY, nCRN, nJUR_PERS);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', 'UDO_SHEETD28_MAKESPEC', 'UDO_SHEETD28', nRN );


  /* Формирование спецификации */
  UDO_PKG_SHEETD28_BASE.SPEC_MAKE(
      nCOMPANY             => nCOMPANY,
      nPRN                 => nRN
      );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', 'UDO_SHEETD28_MAKESPEC', 'UDO_SHEETD28', nRN );

end UDO_P_SHEETD28_MAKESPEC;
/

