create or replace procedure UDO_P_REG_FOR_ACTIVATION_INIT(
  nCOMPANY           in number,  -- Организация
  nIDENT             in number   -- Выбранные записи
) is
begin

  For rec in (
    select pac.rn from PAYACCIN pac, selectlist  sl
     where sl.ident = nIDENT and pac.RN = sl.document 
       and pac.CRN in (select RN from ACATALOG connect by prior RN = CRN start with RN = '6868349') -- 1С
     order by pac.doc_date 
   ) loop
--p_exception(0,'NCOMPANY ' || NCOMPANY || '; nIDENT ' || nIDENT || '; rec.rn ' || rec.rn);
   
   begin
     UDO_P_REG_FOR_ACTIVATION(nCOMPANY  => nCOMPANY,
                         sUNITCODE => 'PaymentAccountsIn',
                         nDOCUMENT => rec.rn);
   exception
     when NO_DATA_FOUND then 
       --PKG_MSG.RECORD_NOT_FOUND(rec.rn, 'PayAccin');
       p_exception(0,'Ошибка активации статусной модели для записи '||rec.rn);
   end;
                         
  end loop;

end UDO_P_REG_FOR_ACTIVATION_INIT;
/

