create or replace procedure UDO_P_PAYNOTES_UNLINK_FACT
(
  nCOMPANY          in number,          -- организация
  nIDENT            in number           -- RN отмеченных записей
)
as
nCount             number;

begin
  
  begin
    -- Проверяем количество выделенных записей
/*    select count(*) into nCount from SELECTLIST;
    if (nCount < 2) then 
      p_exception(0,'Ошибка!!! Нужно обязательно выделить один плановый платеж и хотя бы один фактический!');
    end if;*/
    
    update paynotes pn set pn.pay_plan = NULL
        where pn.rn in (select document from SELECTLIST) and pn.signplan = 0 and pn.company = nCOMPANY;
    COMMIT;
    nCount := SQL%ROWCOUNT;
    --PKG_MSG.RAISE_ACCESS_VIOLATION(nCount || ' строки изменено.');
/*    if (1 = nCount) then p_exception(0, nCount || ' строка изменена.');
    elsif (2 = nCount or 3 = nCount or 4 = nCount) then p_exception(0, nCount || ' строки изменено.'); 
    else p_exception(0, nCount || ' строк изменено.');
    end if;*/
  end;

end UDO_P_PAYNOTES_UNLINK_FACT;
/

