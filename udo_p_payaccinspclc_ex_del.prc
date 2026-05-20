create or replace procedure UDO_P_PAYACCINSPCLC_EX_DEL
  (
    nCOMPANY         in number,         -- Организация
    NRN              in number          -- Рег номер родителя
  )
is
    NCRN             PKG_STD.tREF;         --
begin
 begin
   select C.CRN into NCRN from PAYACCINSPCLC C, PAYACCINSPCLC_EX E where E.RN = NRN and E.PRN =C.RN and C.COMPANY = NCOMPANY;
 exception when NO_DATA_FOUND then
   p_exception(0,'Какталог не определён.');
 end;
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   NCRN, 
                   'PaymentAccountsInSpecsCalcsEX',
                   'PAYACCINSPCLC_EX_DELETE',
                   'PAYACCINSPCLC_EX',
                   NRN);

  /* Удаление записи расширения */
  UDO_PKG_PAYACCINSPCLC_EX.PAYACCINSPCLC_EX_DEL
  (
    NRN              => NRN        -- Рег номер родителя
  );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   nCRN, 
                   'PaymentAccountsInSpecsCalcsEX',
                   'PAYACCINSPCLC_EX_DELETE',
                   'PAYACCINSPCLC_EX',
                   nRN); 
end UDO_P_PAYACCINSPCLC_EX_DEL;
-- grant execute on UDO_P_PAYACCINSPCLC_EX_DEL to public;
/

