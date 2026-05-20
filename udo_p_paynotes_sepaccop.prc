create or replace procedure UDO_P_PAYNOTES_SEPACCOP(
       nCOMPANY   in number,   -- Организация
       sContr     in varchar2, -- Контрагент
       dStart     in date,     -- Дата начала 
       dEnd       in date,     -- Дата окончания
       bFromFact  in number    -- Из Факта в План
) is
-- Корректировка значения Операция по отдельному счету
-- Из Факта в План или из Плана в Факт
-- KHOK 14.04.2023
   nContr number := 0;
   nCount number := 0;
begin
  --GET_AGNLIST_AGNABBR_ID(nFLAG_SMART => 0, nRN => nContr);
  FIND_AGENT_BY_MNEMO(COMPANY => nCOMPANY,
                      MNEMO   => sContr,
                      RN      => nContr);
--p_exception(0, sContr || ': ' || nContr);

  if 1 = bFromFact then
    for rec in (
      select t.pay_plan, t.sepaccop 
        from PAYNOTES t 
       where t.company = nCOMPANY
         and t.payer = nContr 
         and ((dStart is not null and dEnd is not null and t.pay_date between dStart and dEnd)
          or  (dStart is not null and dEnd is null   and t.pay_date >= dStart)
          or  (dEnd   is not null and dStart is null and t.pay_date < dEnd+1)
          or  (dStart is null and dEnd is null)
         )
         and t.sepaccop is not null 
         and t.pay_plan is not null 
         and t.signplan = 0
    ) loop
--p_exception(0, rec.pay_plan);
      nCount := nCount + 1;
      begin
        update PAYNOTES v 
           SET v.sepaccop = rec.sepaccop
         where v.rn = rec.pay_plan
           and v.signplan = 1;
      end;
     end loop;
   else
    for rec in (
      select t.pay_plan, t.sepaccop
        from PAYNOTES t 
              where t.company = nCOMPANY
         and t.payer = nContr 
         and ((dStart is not null and dEnd is not null and t.pay_date between dStart and dEnd)
          or  (dStart is not null and dEnd is null   and t.pay_date >= dStart)
          or  (dEnd   is not null and dStart is null and t.pay_date < dEnd+1)
          or  (dStart is null and dEnd is null)
         )
         and t.sepaccop is not null 
         and t.pay_plan is not null 
         and t.signplan = 1
    ) loop
      nCount := nCount + 1;
      begin
        update PAYNOTES v 
           SET v.sepaccop = rec.sepaccop
         where v.rn = rec.pay_plan
           and v.signplan = 0;
      end;
     end loop;
   end if;

end UDO_P_PAYNOTES_SEPACCOP;
/

