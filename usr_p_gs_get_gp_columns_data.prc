create or replace procedure USR_P_GS_GET_GP_COLUMNS_DATA
/*
Товарные запасы
Процедура Показать значения колонок приходной партии
20/12/2023 Степанов М.
*/
(
 nRN       in number
,sCOLUMN1  out varchar2  /* #Примечание Входного Контроля */
,sCOLUMN2  out varchar2  /* #ПримечаниеПО */
,sCOLUMN3  out varchar2  /* #Группа ТМЦ */
,sCOLUMN4  out varchar2  /* #Серийные номера */
,sCOLUMN5  out varchar2  /* #Кол-во по серии (Фактическое) */
)
is
  rRow  goodssupply%rowtype;
begin
  /* Считывание записи */
  rRow := usr_pkg_goodsparties.goodssupply_get(nrn => f_goodssupply_by_rownum(nrownum => nRN), nFLAGSMART => 1);
  /* Если найдена */
  if rRow.rn is not null then
    sCOLUMN1 := udo_f_goods_cull_out_note(nrn => rRow.prn); 
    sCOLUMN2 := udo_f_goodsparties_ponote(ncompany => rRow.company, nrn => rRow.prn); 
    sCOLUMN3 := udo_f_goodsparties_group_code(nrn => rRow.prn); 
    sCOLUMN4 := udo_f_goodsparties_mnf_numb(nrn => rRow.prn); 
    sCOLUMN5 := udo_f_goodssuplay_sernum_sum(nrn => rRow.prn); 
  end if;
end USR_P_GS_GET_GP_COLUMNS_DATA;
/
