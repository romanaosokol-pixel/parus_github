create or replace procedure USR_P_GP_UPDATE_CERT
/*
Процедура для действия "Исправить Сертификаты"
Раздел: Приходные партии товара
create public synonym usr_p_gp_update_cert for usr_p_gp_update_cert;
grant execute on usr_p_gp_update_cert to public;
*/
(
 nRN          in number
,sCERTIFICATE in varchar2
)
as
  rGoodsParties   goodsparties%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GP_UPDATE_CERT');

  /* считывание записи */
  rGoodsParties := usr_pkg_goodsparties.goodsparties_get(nrn => nRN);

  /* проверка прав доступа */
  pkg_env.prologue(ncompany  => rGoodsParties.company
                  ,nversion  => null
                  ,ncatalog  => null
                  ,njur_pers => rGoodsParties.jur_pers
                  ,sunit     => 'GoodsParties'
                  ,saction   => 'GOODSPARTIES_UPDATE_CERT'
                  ,stable    => 'GOODSPARTIES'
                  ,ndocument => rGoodsParties.rn);

  /* подстановка значения */
  rGoodsParties.certificate := sCERTIFICATE;

  /* базовое исправление */
  usr_pkg_goodsparties.goodsparties_base_update(rrow => rGoodsParties);

  /* фиксация окончания выполнение действия */
  pkg_env.epilogue(ncompany  => rGoodsParties.company
                  ,nversion  => null
                  ,ncatalog  => null
                  ,njur_pers => rGoodsParties.jur_pers
                  ,sunit     => 'GoodsParties'
                  ,saction   => 'GOODSPARTIES_UPDATE_CERT'
                  ,stable    => 'GOODSPARTIES'
                  ,ndocument => rGoodsParties.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end;
/
