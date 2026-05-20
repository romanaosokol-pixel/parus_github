create or replace procedure UDO_P_MARK_FLT_ATTR_NUMB_UPD
/*
   Клиентское исправление атрибута типа "Число" в разделе "Фильтры показателей (атрибуты)"
  */
(
  NRN             number --рег. номер исправляемой записи
 ,STYPE_ATTR_NAME varchar2 --наименование типового атрибута
 ,NVAL_NUMB_FROM  number --значение (число, с)
 ,NVAL_NUMB_TO    number --значение (число, по)
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
  UDO_PKG_MARK_FLT.MARK_FLT_ATTR_NUMB_UPDATE(NRN             => NRN
                                            ,STYPE_ATTR_NAME => STYPE_ATTR_NAME
                                            ,NVAL_NUMB_FROM  => NVAL_NUMB_FROM
                                            ,NVAL_NUMB_TO    => NVAL_NUMB_TO);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFiltersAttrs'
                  ,SACTION   => 'UDO_P_MARK_FLT_ATTR_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_FLT_ATTR'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_FLT_ATTR_NUMB_UPD to public;
/

