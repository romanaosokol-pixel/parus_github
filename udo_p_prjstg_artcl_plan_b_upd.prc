create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_B_UPD
/*
   Ѕазовое исправление в разделе "ѕланы и отчеты по стать€м"
  */
(
  NRN          number --рег. номер исправл€емой записи
 ,NPROJECT     number --рег. номер проекта
 ,NSTAGE       number --рег. номер этапа проекта
 ,NPERIOD      number --рег. номер расчетного периода
 ,NCALC_SCHEMA number --рег. номер схемы калькул€ции
 ,NSUMM        number --сумма на период
 ,NLIMITART    number --рег. номер контрольной статьи
) as
begin
  --исправим запись
  update UDO_T_PRJSTG_ARTCL_PLAN T
     set T.PROJECT     = NPROJECT
        ,T.STAGE       = NSTAGE
        ,T.PERIOD      = NPERIOD
        ,T.CALC_SCHEMA = NCALC_SCHEMA
        ,T.SUMM        = NSUMM
        ,T.LIMITART    = NLIMITART
   where T.RN = NRN;
end;
/

