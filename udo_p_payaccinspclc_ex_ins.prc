create or replace procedure UDO_P_PAYACCINSPCLC_EX_INS
  (
    nCOMPANY         in number,            -- Организация
    SFACEAC          in varchar2,         -- Л/С строки калькуляции
    NPRN             in number,         -- Рег номер родителя
    NDEPARTMENTORD   in number,         -- Рег номер заказа подразделений
    NRN              out number
  )
is
    NCRN             PKG_STD.tREF;  
begin
 begin
   select C.CRN into NCRN from PAYACCINSPCLC C where C.RN = NPRN and C.COMPANY = NCOMPANY;
 exception when NO_DATA_FOUND then
   p_exception(0,'Какталог не определён.');
 end;
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   NCRN, 
                   'PaymentAccountsInSpecsCalcsEX',
                   'P_PAYACCINSPCLC_EX_INS',
                   'PAYACCINSPCLC_EX');
  /* Добавление записи расширения */
  UDO_PKG_PAYACCINSPCLC_EX.PAYACCINSPCLC_EX_INS(nCOMPANY       => nCOMPANY,
                                                SFACEAC        => SFACEAC,
                                                NPRN           => NPRN,
                                                NDEPARTMENTORD => NDEPARTMENTORD,
                                                NRN            => NRN);
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   nCRN, 
                   'PaymentAccountsInSpecsCalcsEX',
                   'P_PAYACCINSPCLC_EX_INS',
                   'PAYACCINSPCLC_EX',
                   nRN);                                              
end UDO_P_PAYACCINSPCLC_EX_INS;
-- grant execute on UDO_P_PAYACCINSPCLC_EX_INS to public;
/

