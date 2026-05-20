create or replace procedure UDO_P_PRJSTG_ARTCL_BASE_DELETE
/*
  Базовая процедура удаления записи из раздела "Статьи" этапа проекта
  */
(NRN number --рег. номер удаляемой записи
 ) as
begin
  --удалим запись
  delete from UDO_T_PRJSTG_ARTCL T
   where T.RN = NRN;
end UDO_P_PRJSTG_ARTCL_BASE_DELETE;
/

