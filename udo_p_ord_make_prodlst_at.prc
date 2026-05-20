create or replace procedure udo_p_ord_make_prodlst_at
(
  nRN        in number, -- рег.номер
  nCOMPANY   in number, -- организация
  dDATE_FROM in date, -- Действует с 
  sNOTE      in varchar2 -- Примечание
) as
  /*
    04/09/2025 Марков МВ.
    Загрузка из внешних источников
    Сформировать спецификацию изделия/извещение об изменении спецификации
    Автономная транзакция при массовом формировании
  */
  PRAGMA AUTONOMOUS_TRANSACTION;

  rHEAD UDO_LOADEXT_ORD%rowtype; -- Запись заголовка
begin
  /* Запись загрузки */
  rHEAD := UDO_PKG_LOADEXT_ORD_BASE.ORD_GET_ID(NFLAG_SMART => 0, NRN => nRN);
  /* Фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY  => rHEAD.Company,
                   nVERSION  => null,
                   nCATALOG  => rHEAD.Crn,
                   nJUR_PERS => null,
                   sUNIT     => 'UdoLoadextOrd',
                   sACTION   => 'UDO_ORD_MAKE_PRODLST_ALL',
                   sTABLE    => 'UDO_LOADEXT_ORD',
                   nDOCUMENT => rHEAD.Rn);
  /* Базовое формирование спецификации */
  UDO_PKG_LOADEXT_ORD_BASE.ORD_MAKE_PRODLST(NRN => rHEAD.Rn, dDATE_FROM => dDATE_FROM, sNOTE => sNOTE);
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY  => rHEAD.Company,
                   nVERSION  => null,
                   nCATALOG  => rHEAD.Crn,
                   nJUR_PERS => null,
                   sUNIT     => 'UdoLoadextOrd',
                   sACTION   => 'UDO_ORD_MAKE_PRODLST_ALL',
                   sTABLE    => 'UDO_LOADEXT_ORD',
                   nDOCUMENT => rHEAD.Rn);
  commit;
end;
/
