create or replace procedure UDO_P_MARK_FLT_ATTR_DEL
/*
   Клиентское удаление в разделе "Фильтры показателей (атрибуты)"
  */
(NRN number --рег. номер удаляемой записи
 ) as
  REC  UDO_T_MARK_FLT_ATTR%rowtype; --запись атрибута фильтра
  PREC UDO_T_MARK_FLT%rowtype; --запись фильтра
begin
  --считаем запись
  REC := UDO_PKG_MARK_FLT.MARK_FLT_ATTR_GET(NRN    => NRN
                                           ,NSMART => 0);
  --считаем родительскую запись
  PREC := UDO_PKG_MARK_FLT.MARK_FLT_GET(NRN    => REC.PRN
                                       ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFiltersAttrs'
                  ,SACTION   => 'UDO_P_MARK_FLT_ATTR_DELETE'
                  ,STABLE    => 'UDO_T_MARK_FLT_ATTR'
                  ,NDOCUMENT => NRN);
  --базово удалим
  UDO_PKG_MARK_FLT.MARK_FLT_ATTR_DELETE(NRN => NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFiltersAttrs'
                  ,SACTION   => 'UDO_P_MARK_FLT_ATTR_DELETE'
                  ,STABLE    => 'UDO_T_MARK_FLT_ATTR'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_FLT_ATTR_DEL to public;
/

