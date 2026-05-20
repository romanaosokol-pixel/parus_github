create or replace procedure UDO_P_PAYNOTES_GEN_PLAN
(
  nCOMPANY          in number,          -- организация
  NRN               in number           -- RN счета на оплату
--  nIDENT            in number
)
as

/* Добавление планового платежа к счету*/
nPAY_RN             number;
--nPAY_CRN            number;
nIDENT              PKG_STD.tREF;
begin
 -- nIDENT := gen_ident;
  UDO_P_PAYNOTES_MAKEPAY(
       nCOMPANY    => nCOMPANY      -- организация.
      ,nRN         => NRN           -- RN товарного документа
      ,sUNITCODE   => 'PaymentAccountsIn'    -- раздел товарного документа
      ,nSIGNPLAN   => 1             -- признак плановой записи: 0 - факт, 1 - план
      ,nBDoc_RN    => null
      ,nPAY_RN     => nPAY_RN       -- RN платежа
      ,nBDoc_CRN    => null      -- RN каталога платежа  
  );


end UDO_P_PAYNOTES_GEN_PLAN;
/

