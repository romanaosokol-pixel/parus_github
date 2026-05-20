create or replace procedure UDO_P_MARK_TYPE_ATTRS_DELETE
/*
  Клиентское удаление в разделе "Типы показателей (атрибуты)"
   */
(NRN number --рег. номер атрибута типа показателя
 ) is
  REC  UDO_T_MARK_TYPE_ATTRS%rowtype; --запись атрибута типа показателя
  PREC UDO_T_MARK_TYPE%rowtype; --запись типа показателя
begin
  --считаем запись
  REC := UDO_PKG_MARK_TYPE.MARK_TYPE_ATTRS_GET(NRN    => NRN
                                              ,NSMART => 0);
  --считаем родителя
  PREC := UDO_PKG_MARK_TYPE.MARK_TYPE_GET(NRN    => REC.PRN
                                         ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'MarkTypesAttrs'
                  ,SACTION   => 'UDO_P_MARK_TYPE_ATTRS_DELETE'
                  ,STABLE    => 'UDO_T_MARK_TYPE_ATTRS'
                  ,NDOCUMENT => REC.RN);
  --удалим запись
  UDO_PKG_MARK_TYPE.MARK_TYPE_ATTRS_DELETE(NRN => REC.RN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'MarkTypesAttrs'
                  ,SACTION   => 'UDO_P_MARK_TYPE_ATTRS_DELETE'
                  ,STABLE    => 'UDO_T_MARK_TYPE_ATTRS'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_TYPE_ATTRS_DELETE to public;
/

