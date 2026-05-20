create or replace procedure UDO_P_STPLCELLS_RENAME(
  nCOMPANY   in number,
  nRN        in number,  -- Идентификатор строки Места хранения
  sNewNum    in varchar2 -- Новый номер
  ) is

  nPRN       PKG_STD.tREF;
  sPREFvar   STPLCELLS.NUMB%type;

begin

  sPREFvar := STRRIGHT( STRTRIM(sNewNum), 10 );
--p_exception(0, nRN || ': "' || sPREFvar || '"');
  /* поиск записи */
  begin
    select PRN
      into nPRN
      from STPLCELLS
     where RN = nRN;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION( 0,'Запись места хранения, ячейки (RN: '||nvl(to_char(nRN),'<null>')||') не найдена.' );
  end;
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, null, null, nPRN, 'StoragePlacesCells', 'STPLCELLS_UPDATE', 'STPLCELLS', nRN );
  /* разрешение ссылок */
  --P_STPLCELLS_JOINS( nCOMPANY, sZONE, sPLACE, nZONE, nPLACE );

  /* исправление */
  update STPLCELLS stp
     set stp.numb = sPREFvar
   where stp.RN = nRN
     and COMPANY = nCOMPANY;
  if ( SQL%NOTFOUND ) then
    PKG_MSG.RECORD_NOT_FOUND( nRN, 'StoragePlacesCells' );
  end if;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, null, null, nPRN, 'StoragePlacesCells', 'STPLCELLS_UPDATE', 'STPLCELLS', nRN );


end UDO_P_STPLCELLS_RENAME;
/

