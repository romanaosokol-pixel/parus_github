create or replace procedure udo_p_strplresjrnl_mins_wrac
(
  nCOMPANY       in number, -- Рег номер организации
  sUNITCODE      in varchar2, -- Код раздела
  --nCRN           in number, -- каталог
  nRN            in number, -- Рег номер
  nIDENT         in number, -- Идент выделенных записей
  sSTORE         in varchar2, -- склад
  sCELL          in varchar2, -- место хранения (резервуар)
  nREPLACE       in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да)
  dRESERVINGDATE in date -- дата и время резервирования.
  --nOUTNOTE       out number
) as
  /*
    01/11/2024 Марков МВ.
    Акты списания недостач/оприходования излишков (спецификация)
    Действие "Массовое резервирование по местам хранения"
    grant execute on UDO_P_STRPLRESJRNL_MINS_WRAC to public;
  */
  nRES_TYPE PKG_STD.tREF; -- тип резервирования (0 - приход, 1 - расход)
  nCRN      PKG_STD.tREF; -- 
  nOUTNOTE  PKG_STD.tREF; --

begin

  -- запись
  P_WROFFACTSPECS_EXISTS(nCOMPANY => nCOMPANY, nRN => nRN, nCRN => nCRN);
  
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY  => nCOMPANY,
                   nVERSION  => null,
                   nCATALOG  => nCRN,
                   sUNIT     => 'WriteOffActsSpecs',
                   sACTION   => 'P_STRPLRESJRNL_MINS_WRAC',
                   sTABLE    => 'WROFFACTSPECS',
                   nDOCUMENT => nRN);

  -- инициализация параметров документа
  begin
    select decode(W.ACTTYPE, 0, 1, 0)
      into nRES_TYPE
      from WROFFACTS W
     where W.RN in (select WS.PRN from WROFFACTSPECS WS where WS.RN = nRN);
  exception
    when no_data_found then
      p_exception(0, 'Запись спецификации не найдена.');
  end;

  /* Точка входа */
  UDO_PKG_STRPLRESJRNL_MASS_INS.SATRT(nCOMPANY       => nCOMPANY,
                                      sUNITCODE      => sUNITCODE,
                                      NIDENT         => nIDENT,
                                      sSTORE         => sSTORE,
                                      SCELL          => sCELL,
                                      nRES_TYPE      => nRES_TYPE,
                                      NREPLACE       => nREPLACE,
                                      dRESERVINGDATE => dRESERVINGDATE,
                                      nRETURN        => 0, -- признак возвратной накладной (0 - нет, 1 - да)
                                      nOUTNOTE       => nOUTNOTE);
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY  => nCOMPANY,
                   nVERSION  => null,
                   nCATALOG  => nCRN,
                   sUNIT     => 'WriteOffActsSpecs',
                   sACTION   => 'P_STRPLRESJRNL_MINS_WRAC',
                   sTABLE    => 'WROFFACTSPECS',
                   nDOCUMENT => nRN);

end;
/
