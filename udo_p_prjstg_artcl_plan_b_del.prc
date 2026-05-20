create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_B_DEL
/*
   Базовое удаление в разделе "Планы и отчеты по статьям"
  */
(NRN number --рег. номер удаляемой записи
 ) as
begin
  --удалим запись
  delete from UDO_T_PRJSTG_ARTCL_PLAN T
   where T.RN = NRN;
end UDO_P_PRJSTG_ARTCL_PLAN_B_DEL;
/

