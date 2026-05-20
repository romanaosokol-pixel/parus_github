create or replace procedure USR_P_SPGS_GET_ADD_DATA
/*
Места хранения товарного запаса
Процедура Показать дополнительные данные
14/10/2024 Степанов М.
*/
(
 nRN            in number
,sCOLUMN1       out varchar2  /* #Примечание Входного Контроля */
,sCOLUMN2       out varchar2  /* #ПримечаниеПО */
,sCOLUMN3       out varchar2  /* #Группа ТМЦ */
,sCOLUMN4       out varchar2  /* #Серийные номера */
,sCOLUMN5       out varchar2  /* #Кол-во по серии (Фактическое) */
,sCOLUMN6       out varchar2  /* #Тема */
)
is
  nGoodsSupply    pkg_std.tref;
  rRow            goodssupply%rowtype;
begin
  /* RN товарного запаса */
  select goodssupply 
    into nGoodsSupply 
    from stplgoodssupply  h
        ,stplgssupplyhist s 
   where s.rn = nRN
     and h.rn = s.prn;

  /* Считывание товарного запаса */
  rRow := usr_pkg_goodsparties.goodssupply_get(nrn => nGoodsSupply, nFLAGSMART => 1);
  /* Если найден */
  if rRow.rn is not null then
    sCOLUMN1 := udo_f_goods_cull_out_note(nrn => rRow.prn);
    sCOLUMN2 := udo_f_goodsparties_ponote(ncompany => rRow.company, nrn => rRow.prn);
    sCOLUMN3 := udo_f_goodsparties_group_code(nrn => rRow.prn);
    sCOLUMN4 := udo_f_goodsparties_mnf_numb(nrn => rRow.prn);
    sCOLUMN5 := udo_f_goodssuplay_sernum_sum(nrn => rRow.prn);
    sCOLUMN6 := udo_f_goodssplclc_shefr(nrn => rRow.rn);
  end if;
end;
/
