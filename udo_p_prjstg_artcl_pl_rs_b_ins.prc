create or replace procedure UDO_P_PRJSTG_ARTCL_PL_RS_B_INS
/*
   Базовое добавление в раздел "Планы и отчеты по статьям (остатки)"
  */
(
  NPRN          number --рег. номер родительской записи
 ,NPRJSTG_ARTCL number --рег. номер статьи этапа заказа
 ,NSTATE        number --рег. номер состояния
 ,NRESTB        number --сумма остатка на начало
 ,NRESTE        number --сумма остатка на конец
 ,DACT_FROM     date --дата начала действия показателей
 ,NRN           out number --рег. номер добавленной записи
) as
begin
  --сформируем рег. номер
  NRN := GEN_ID;
  --добавим запись в раздел
  insert into UDO_T_PRJSTG_ARTCL_PLAN_RS
    (RN, PRN, PRJSTG_ARTCL, STATE, RESTB, RESTE, ACT_FROM)
  values
    (NRN, NPRN, NPRJSTG_ARTCL, NSTATE, NRESTB, NRESTE, DACT_FROM);
end;
/

