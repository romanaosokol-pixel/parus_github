create or replace function usr_f_esr_add_acc_resp
/*
Раздел Остатки ТМЦ по сотрудникам (остатки)
Функция для колонки "#Ответственный в бух.учёте" в
10/04/2024 Степанов М.
grant execute on USR_F_ESR_ADD_ACC_RESP to public;
*/
(
 nGOODSPARTY  in number
)
return varchar2
is
begin
  return usr_pkg_goodsparties_add.get_val_str(ngoodsparties => nGOODSPARTY, stype => 'Ответственный в бух.учёте');
end USR_F_ESR_ADD_ACC_RESP;
/
