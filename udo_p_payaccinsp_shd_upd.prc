create or replace procedure UDO_P_PAYACCINSP_SHD_UPD
(
  nRN      in number, -- рег.номер
  nCOMPANY in number, -- организация
  dIN_DATE in date, -- дата поставки
  nQUANT   in number, -- количество поставки
  sNOTE    in varchar2 -- примечание
) as
  /*
    19/04/2024 Марков МВ.
    Входящие счета на оплату (спецификация, графики поставки)
    Исправление
    grant execute on UDO_P_PAYACCINSP_SHD_UPD to public;
  */
  nCRN PKG_STD.tREF;
begin
  -- запись графика
  UDO_PKG_PAYACCIN_BASE.P_SHEDULE_EXISTS(nCOMPANY => nCOMPANY, nRN => nRN, nCRN => nCRN);
  -- пролог
  PKG_ENV.PROLOGUE(nCOMPANY  => nCOMPANY,
                   nVERSION  => null,
                   nCATALOG  => nCRN,
                   sUNIT     => 'PaymentAccountsInSpecShedule',
                   sACTION   => 'UDO_PAYACCINSPEC_SHEDULE_UPDATE',
                   sTABLE    => 'UDO_PAYACCINSPEC_SHEDULE',
                   nDOCUMENT => nRN);
  -- базовое добавление
  UDO_PKG_PAYACCIN_BASE.P_SPEC_SHEDULE_UPDATE(nRN      => nRN,
                                              nCOMPANY => nCOMPANY,
                                              dIN_DATE => dIN_DATE,
                                              nQUANT   => nQUANT,
                                              sNOTE    => sNOTE);
  -- эпилог
  PKG_ENV.EPILOGUE(nCOMPANY  => nCOMPANY,
                   nVERSION  => null,
                   nCATALOG  => nCRN,
                   sUNIT     => 'PaymentAccountsInSpecShedule',
                   sACTION   => 'UDO_PAYACCINSPEC_SHEDULE_UPDATE',
                   sTABLE    => 'UDO_PAYACCINSPEC_SHEDULE',
                   nDOCUMENT => nRN);
end;
/
