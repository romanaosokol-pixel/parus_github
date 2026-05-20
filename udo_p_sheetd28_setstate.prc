create or replace procedure UDO_P_SHEETD28_SETSTATE(
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number,   -- Организация
       nSTATE               in number,   -- Состояние (0-Не утвержден; 1-Утвержден)
       dSTATE_DATE          in date,     -- Дата смены состояния
       nSIGN_USEDOCDATE     in number    -- Использовать дату документа
       ) is
/* Смена состояния ведомости Д28 */
  nCRN           PKG_STD.tREF;    -- Каталог
  nJUR_PERS      PKG_STD.tREF;    -- Принадлежность
  sACTION        PKG_STD.tSTRING; -- Код действия
begin

  /* считывание записи */
  UDO_PKG_SHEETD28_BASE.DOC_EXISTS(nRN, nCOMPANY, nCRN, nJUR_PERS);

  /* код действия */
  case nSTATE
    when 0 then sACTION := 'UDO_SHEETD28_CANCEL';
    when 1 then sACTION := 'UDO_SHEETD28_PROCESS';
    when 2 then sACTION := 'UDO_SHEETD28_ANNUL';
  else
    p_exception(0, 'Действие для "%s" не определено.', nSTATE);
  end case;

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', sACTION, 'UDO_SHEETD28', nRN );

  /* Смена состояния */
  UDO_PKG_SHEETD28_BASE.DOC_SETSTATE(
      nRN                 => nRN,
      nSTATE              => nSTATE,
      dSTATE_DATE         => dSTATE_DATE,
      nSIGN_USEDOCDATE    => nSIGN_USEDOCDATE
      );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'UdoSheetD28', sACTION, 'UDO_SHEETD28', nRN );

end UDO_P_SHEETD28_SETSTATE;
/

