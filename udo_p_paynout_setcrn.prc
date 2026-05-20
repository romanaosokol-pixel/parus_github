create or replace procedure UDO_P_PAYNOUT_SETCRN
(
nRN in number
)
is
nPAYRN number;
nCRN   number;
sUNIT DOCLINKS.OUT_UNITCODE%type;
begin
  for cc in (
  select pp.* from PAYNOTES pp where pp.rn = nRN
  ) loop
    begin
     select dl.in_document, dl.in_unitcode
       into nPAYRN, sUNIT
       from DOCLINKS dl
      where dl.out_document = cc.rn
        and dl.out_unitcode = 'PayNotes'
        and dl.in_unitcode in ('PaymentAccountsIn', 'PaymentAccounts');
    exception when NO_DATA_FOUND then
      sUNIT := null;
    end;    

      if sUNIT = 'PaymentAccountsIn' then
        select p.crn
        into nCRN
        from PAYACCIN p
        where p.rn = nPAYRN;
      elsif sUNIT = 'PaymentAccounts' then
        select p.crn
        into nCRN
        from PAYACC p
        where p.rn = nPAYRN;
      end if;

      nCRN := UDO_F_PAYNOTES_ACALOG (
                             nCOMPANY     => 90521,
                             nInCatalog   => nCRN,
                             sOutUnitCode => 'PayNotes'
                           );
   if nCRN is not null then

         update PAYNOTES nn
         set nn.crn = nCRN
         where nn.rn = cc.rn;



    end if;
  end loop;
end UDO_P_PAYNOUT_SETCRN;
/

