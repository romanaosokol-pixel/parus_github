create or replace function USR_F_ESR_ADD_STORE_CARD
/*
Раздел Остатки ТМЦ по сотрудникам (остатки)
Функция для колонки "#Складская карточка" в
10/04/2023 Степанов М.
grant execute on USR_F_ESR_ADD_STORE_CARD to public;
*/
(
 nGOODSPARTY  in number
)
return varchar2
is
begin
  return usr_pkg_goodsparties_add.get_val_str(ngoodsparties => nGOODSPARTY, stype => 'Складская карточка');
end USR_F_ESR_ADD_STORE_CARD;
/
