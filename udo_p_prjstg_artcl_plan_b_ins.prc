create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_B_INS
/*
   Ѕазовое добавление в раздел "ѕланы и отчеты по стать€м"
  */
(
  NCRN         number --рег. номер каталога
 ,NCOMPANY     number --рег. номер организации
 ,NPROJECT     number --рег. номер проекта
 ,NSTAGE       number --рег. номер этапа проекта
 ,NPERIOD      number --рег. номер расчетного периода
 ,NCALC_SCHEMA number --рег. номер схемы калькул€ции
 ,NSUMM        number --сумма на период
 ,NLIMITART    number --рег. номер контрольной статьи
 ,NRN          out number --рег. номер добавленной записи
) as
begin
  --сформируем рег. номер
  NRN := GEN_ID;
  --добавим данные в таблицу
  insert into UDO_T_PRJSTG_ARTCL_PLAN
    (RN
    ,CRN
    ,COMPANY
    ,PROJECT
    ,STAGE
    ,PERIOD
    ,CALC_SCHEMA
    ,STATE
    ,STATE_DATE
    ,SUMM
    ,LIMITART)
  values
    (NRN
    ,NCRN
    ,NCOMPANY
    ,NPROJECT
    ,NSTAGE
    ,NPERIOD
    ,NCALC_SCHEMA
    ,0
    ,sysdate
    ,NSUMM
    ,NLIMITART);
end UDO_P_PRJSTG_ARTCL_PLAN_B_INS;
/

