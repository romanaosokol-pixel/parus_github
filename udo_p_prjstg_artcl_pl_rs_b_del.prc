create or replace procedure UDO_P_PRJSTG_ARTCL_PL_RS_B_DEL
/*
   Базовое удаление в разделе "Планы и отчеты по статьям (остатки)"
  */
(NRN number --рег. номер удаляемой записи
 ) as
begin
  --удалим данные из таблицы
  delete from UDO_T_PRJSTG_ARTCL_PLAN_RS T
   where T.RN = NRN;
end UDO_P_PRJSTG_ARTCL_PL_RS_B_DEL;
/

