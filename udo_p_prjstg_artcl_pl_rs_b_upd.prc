create or replace procedure UDO_P_PRJSTG_ARTCL_PL_RS_B_UPD
/*
   Базовое исправление в разделе "Планы и отчеты по статьям (остатки)"
  */
(
  NRN           number --рег. номер исправляемой записи
 ,NPRJSTG_ARTCL number --рег. номер статьи этапа заказа
 ,NSTATE        number --рег. номер состояния
 ,NRESTB        number --сумма остатка на начало
 ,NRESTE        number --сумма остатка на конец
 ,DACT_FROM     date --дата начала действия показателей
) as
begin
  --исправим данные в таблице
  update UDO_T_PRJSTG_ARTCL_PLAN_RS T
     set T.PRJSTG_ARTCL = NPRJSTG_ARTCL
        ,T.STATE        = NSTATE
        ,T.RESTB        = NRESTB
        ,T.RESTE        = NRESTE
        ,T.ACT_FROM     = DACT_FROM
   where T.RN = NRN;
end;
/

