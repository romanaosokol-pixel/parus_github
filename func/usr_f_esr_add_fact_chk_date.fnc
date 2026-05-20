create or replace function USR_F_ESR_ADD_FACT_CHK_DATE
/*
Раздел Остатки ТМЦ по сотрудникам (остатки)
Функция для колонки "#Фактическая поверка. Дата" в
10/04/2024 Степанов М.
grant execute on USR_F_ESR_ADD_FACT_CHK_DATE to public;
*/
(
 nGOODSPARTY  in number
)
return date
is
begin
  return usr_pkg_goodsparties_add.get_val_date(ngoodsparties => nGOODSPARTY, stype => 'Фактическая поверка. Дата');
end USR_F_ESR_ADD_FACT_CHK_DATE;
/
