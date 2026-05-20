create or replace procedure UDO_P_MARK_FLT_ATTR_DATE_UPD
/*
   Клиентское исправление атрибута типа "Дата" в разделе "Фильтры показателей (атрибуты)"
  */
(
  NRN             number --рег. номер исправляемой записи
 ,STYPE_ATTR_NAME varchar2 --наименование типового атрибута
 ,DVAL_DATE_FROM  date --значение (дата, с)
 ,DVAL_DATE_TO    date --значение (дата, по)
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
                  ,SACTION   => 'UDO_P_MARK_FLT_ATTR_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_FLT_ATTR'
                  ,NDOCUMENT => REC.RN);
  --базово исправим
  UDO_PKG_MARK_FLT.MARK_FLT_ATTR_DATE_UPDATE(NRN             => NRN
                                            ,STYPE_ATTR_NAME => STYPE_ATTR_NAME
                                            ,DVAL_DATE_FROM  => DVAL_DATE_FROM
                                            ,DVAL_DATE_TO    => DVAL_DATE_TO);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFiltersAttrs'
                  ,SACTION   => 'UDO_P_MARK_FLT_ATTR_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_FLT_ATTR'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_FLT_ATTR_DATE_UPD to public;
/

