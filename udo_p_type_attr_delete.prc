create or replace procedure UDO_P_TYPE_ATTR_DELETE
/*
   Клиентское удаление в разделе "Типовые атрибуты показателей"
  */
(NRN number --рег. номер типового атрибута
 ) is
  REC UDO_T_TYPE_ATTR%rowtype; --запись типового атрибута
begin
  --считаем запись атрибута
  REC := UDO_PKG_TYPE_ATTR.TYPE_ATTR_GET(NRN    => NRN
                                        ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'MarkTypeAttrs'
                  ,SACTION   => 'UDO_P_TYPE_ATTR_DELETE'
                  ,STABLE    => 'UDO_T_TYPE_ATTR'
                  ,NDOCUMENT => REC.RN);
  --базово удалим
  UDO_PKG_TYPE_ATTR.TYPE_ATTR_DELETE(NRN => REC.RN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'MarkTypeAttrs'
                  ,SACTION   => 'UDO_P_TYPE_ATTR_DELETE'
                  ,STABLE    => 'UDO_T_TYPE_ATTR'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_TYPE_ATTR_DELETE to public;
/

