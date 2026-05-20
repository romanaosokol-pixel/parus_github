create or replace procedure UDO_P_MARK_TYPE_DELETE
/*
  Клиентское удаление в разделе "Типы показателей"
   */
(NRN number --рег. номер типа показателя
 ) is
  REC UDO_T_MARK_TYPE%rowtype; --запись типа показателя
begin
  --считаем запись
  REC := UDO_PKG_MARK_TYPE.MARK_TYPE_GET(NRN    => NRN
                                        ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'MarkTypes'
                  ,SACTION   => 'UDO_P_MARK_TYPE_DELETE'
                  ,STABLE    => 'UDO_T_MARK_TYPE'
                  ,NDOCUMENT => REC.RN);
  --удалим запись
  UDO_PKG_MARK_TYPE.MARK_TYPE_DELETE(NRN => NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'MarkTypes'
                  ,SACTION   => 'UDO_P_MARK_TYPE_DELETE'
                  ,STABLE    => 'UDO_T_MARK_TYPE'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_TYPE_DELETE to public;
/

