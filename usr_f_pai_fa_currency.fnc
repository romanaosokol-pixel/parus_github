create or replace function usr_f_pai_fa_currency
/*
Раздел Входящие счета на оплату
Функция для колонки "#Валюта лицевого счёта"
28/02/2025 Степанов М.
grant execute on usr_f_pai_fa_currency to public;
*/
(
 sFA_CURRENCY       in varchar2
)
return varchar2
is
begin
  return(sFA_CURRENCY);
end;
/
