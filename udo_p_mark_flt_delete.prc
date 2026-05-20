create or replace procedure UDO_P_MARK_FLT_DELETE
/*
   Клиентское удаление в разделе "Фильтры показателей"
  */
(NRN number --рег. номер записи
 ) as
  REC UDO_T_MARK_FLT%rowtype; --запись фильтра
begin
  --считаем запись
  REC := UDO_PKG_MARK_FLT.MARK_FLT_GET(NRN    => NRN
                                      ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFilters'
                  ,SACTION   => 'UDO_P_MARK_FLT_DELETE'
                  ,STABLE    => 'UDO_T_MARK_FLT'
                  ,NDOCUMENT => REC.RN);
  --базово удалим
  UDO_PKG_MARK_FLT.MARK_FLT_DELETE(NRN => REC.RN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFilters'
                  ,SACTION   => 'UDO_P_MARK_FLT_DELETE'
                  ,STABLE    => 'UDO_T_MARK_FLT'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_FLT_DELETE to public;
/

