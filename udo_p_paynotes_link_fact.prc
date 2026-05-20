create or replace procedure UDO_P_PAYNOTES_LINK_FACT
(
  nCOMPANY          in number,          -- организация
  nIDENT            in number           -- RN отмеченных записей
)
as
nCount             number;
nPlanRN            number;

begin
  --nIDENT := gen_ident;
    nCount := 0; nPlanRN := 0;
    -- Проверяем количество выделенных записей
    select count(*) into nCount from SELECTLIST;
    if (nCount < 2) then 
      p_exception(0,'Ошибка!!! Нужно обязательно выделить один плановый платеж и хотя бы один фактический!');
    end if;

    -- Проверяем количество записей с признаком План
    select count(*) into nCount from paynotes pn 
          where rn in (select document from SELECTLIST) and pn.signplan = 1 and pn.company = nCOMPANY;
    if (nCount > 1) then 
      p_exception(0,'Ошибка!!! Плановый платеж должен быть только один!');
    end if;

    -- Получаем RN Планового платежа
    select pn.rn into nPlanRN from paynotes pn where pn.rn in (select document from SELECTLIST) and pn.signplan = 1;

    if (0 != nPlanRN) then
      begin
          update paynotes pn set pn.pay_plan = nPlanRN
              where pn.rn in (select document from SELECTLIST) and pn.signplan = 0 and pn.company = nCOMPANY;
          COMMIT;
          nCount := SQL%ROWCOUNT;
          --PKG_MSG.RAISE_ACCESS_VIOLATION(nCount || ' строки изменено.');
/*          if (1 = nCount) then p_exception(0, nCount || ' строка изменена.');
          elsif (2 = nCount or 3 = nCount or 4 = nCount) then p_exception(0, nCount || ' строки изменено.'); 
          else p_exception(0, nCount || ' строк изменено.');
          end if;*/
      end;
    end if;

end UDO_P_PAYNOTES_LINK_FACT;
/

