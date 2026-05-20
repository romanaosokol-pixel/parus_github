create or replace procedure UDO_P_PAYNOTES_FACEACC_UPDATE(
NCOMPANY in number,
NRN in number, 
sArticle in varchar)
is
nARTICLE  pkg_std.tref;
nFACE_RN  pkg_std.tref;
begin
  /* 
    16/11/2022 Столярский Е.
    Процедура подменяет ЛС в журнале платежей только для случая платежа без ВСО и договора
  */
  begin
  FIND_FPDARTCL_CODE
      (
        nFLAG_SMART  => 0,   -- признак генерации исключения (0 - да, 1 - нет)
        nCOMPANY     => nCOMPANY,   -- организация.
        sCODE        => sArticle, -- мнемокод
        nRN          => nARTICLE   -- регистрационный номер записи
      ); 
   exception when others then
     p_exception(0,'Не удается определить статью %s.',sArticle);
   end;     
   
   for pay in (
     select pn.*
     from PAYNOTES pn, FACEACC fc
     where pn.rn = NRN
     and pn.signplan = 0
     and fc.rn = pn.faceacc
     and fc.sign_stage = 0
     and fc.valid_doctype is null
     and fc.valid_docdate is null
     and fc.valid_doctype is null
     and not exists (select null from DOCLINKS dl 
                      where dl.out_document = pn.rn
                        and dl.out_unitcode = 'PayNotes'
                        and dl.in_unitcode  = 'PaymentAccountsIn')
                        
     and not exists (select null from PAYNOTESCLC pc
                     where pc.prn = pn.rn
                       and pc.cost_article is not null)
   ) loop
     begin
       select fc.rn
       into nFACE_RN
       from FACEACC fc
       where fc.agent = pay.payer
         and fc.ieelement = nARTICLE;
     exception when others then
       p_exception(0,'Не удается подобрать ЛС для контрагента "%s" со статьёй "%s"', pay.payer, sArticle);
     end;
     if nFACE_RN is not null then
       PKG_OBJECT_DDL.DISABLE_TRIGGER('PAYNOTES', 'T_PAYNOTES_BUPDATE');

       update PAYNOTES pp set pp.faceacc = nFACE_RN where pp.rn = pay.rn;
       PKG_OBJECT_DDL.ENABLE_TRIGGER('PAYNOTES', 'T_PAYNOTES_BUPDATE');
     end if;
   end loop;

end UDO_P_PAYNOTES_FACEACC_UPDATE;
/

