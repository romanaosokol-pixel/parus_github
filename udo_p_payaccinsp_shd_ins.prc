create or replace procedure UDO_P_PAYACCINSP_SHD_INS
(
  nPRN     in number, -- родитель
  nCOMPANY in number, -- организация
  dIN_DATE in date, -- дата поставки
  nQUANT   in number, -- количество поставки
  sNOTE    in varchar2, -- примечание
  nRN      out number -- рег.номер
) as
  /*
    19/04/2024 Марков МВ.
    Входящие счета на оплату (спецификация, графики поставки)
    Добавление
    grant execute on UDO_P_PAYACCINSP_SHD_INS to public;
  */
  nCRN PKG_STD.tREF;
begin
  -- спецификация
  UDO_PKG_PAYACCIN_BASE.P_SPEC_EXISTS(nCOMPANY => nCOMPANY, nRN => nPRN, nCRN => nCRN);
  -- пролог
  PKG_ENV.PROLOGUE(nCOMPANY => nCOMPANY,
                   nVERSION => null,
                   nCATALOG => nCRN,
                   sUNIT    => 'PaymentAccountsInSpecShedule',
                   sACTION  => 'UDO_PAYACCINSPEC_SHEDULE_INSERT',
                   sTABLE   => 'UDO_PAYACCINSPEC_SHEDULE');
  -- базовое добавление
  UDO_PKG_PAYACCIN_BASE.P_SPEC_SHEDULE_INSERT(nPRN     => nPRN,
                                              nCRN     => nCRN,
                                              nCOMPANY => nCOMPANY,
                                              dIN_DATE => dIN_DATE,
                                              nQUANT   => nQUANT,
                                              sNOTE    => sNOTE,
                                              nRN      => nRN);
  -- эпилог
  PKG_ENV.EPILOGUE(nCOMPANY  => nCOMPANY,
                   nVERSION  => null,
                   nCATALOG  => nCRN,
                   sUNIT     => 'PaymentAccountsInSpecShedule',
                   sACTION   => 'UDO_PAYACCINSPEC_SHEDULE_INSERT',
                   sTABLE    => 'UDO_PAYACCINSPEC_SHEDULE',
                   nDOCUMENT => nRN);
end;
/
