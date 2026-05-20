create or replace function USR_F_ESR_ADD_FACTORY_NUMB
/*
Раздел Остатки ТМЦ по сотрудникам (остатки)
Функция для колонки "#Заводской номер производителя" в
10/04/2024 Степанов М.
grant execute on USR_F_ESR_ADD_FACTORY_NUMB to public;
*/
(
 nGOODSPARTY  in number
)
return varchar2
is
begin
  return usr_pkg_goodsparties_add.get_val_str(ngoodsparties => nGOODSPARTY, stype => 'Заводской номер');
end USR_F_ESR_ADD_FACTORY_NUMB;
/
