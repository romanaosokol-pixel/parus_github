create or replace procedure UDO_P_PAIN_UNITSTMOD_SED_MAIL
(
  NCOMPANY           in number,         -- Рег. номер организации
  NDOCUMENT          in number,         -- Рег номер События
  nRESULT            out number         -- Результат
)
is
  NREZ              PKG_STD.tNUMBER;
  NLINKED_RN         PKG_STD.tREF;       -- Рег. номер ВСО
begin
  begin
    select t.linked_rn into NLINKED_RN from clnevents t where t.linked_unit = 'PaymentAccountsIn' and t.rn = nDOCUMENT and t.company = nCOMPANY;
  exception when NO_DATA_FOUND then
    nRESULT := 1;
    when TOO_MANY_ROWS then
    nRESULT := 2;
  end;

  begin
    -- переделал процедуру формирования сообщения
    --UDO_P_SPAYACCIN_MAKE_SED_MAIL(NCOMPANY      => nCOMPANY,
    --                              NRN           => NLINKED_RN);
    UDO_P_PACCIN_MAKE_SEND_MAIL_2(nCOMPANY      => nCOMPANY,
                                  sUNITCODE     => 'PaymentAccountsIn',
                                  nDOCUMENT     => NLINKED_RN,
                                  sUNITFUNC     => '' -- указать код контекстной функции "Утвердить" 
                                  );
  exception when Others then
    nRESULT := 3;
  end;
 nRESULT := 0;

end UDO_P_PAIN_UNITSTMOD_SED_MAIL;
-- grant execute on UDO_P_PAIN_UNITSTMOD_SED_MAIL to public;
/

