create or replace function usr_f_pais_price
/*
Раздел "Входящие счета на оплату (спецификация)".
Функция для колонки "#Цена (округлённая)"
05/03/2026 Степанов М.
grant execute on USR_F_PAIS_PRICE to public;
*/
(
 nPRICE in number
)
return number
as
begin

  return nPRICE;

end USR_F_PAIS_PRICE;
/
