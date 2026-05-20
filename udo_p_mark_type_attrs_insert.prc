create or replace procedure UDO_P_MARK_TYPE_ATTRS_INSERT
/*
  Клиентское добавление в разделе "Типы показателей (атрибуты)"
   */
(
  NPRN       number --рег. номер типа показателя
 ,NNUMB      number --порядковый номер
 ,STYPE_ATTR varchar2 --мнемокод типового атрибута
 ,NRN        out number --рег. номер атрибута типа показателя
) is
  PREC UDO_T_MARK_TYPE%rowtype; --запись типа показателя
begin
  --считаем родителя
  PREC := UDO_PKG_MARK_TYPE.MARK_TYPE_GET(NRN    => NPRN
                                         ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => PREC.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => PREC.CRN
                  ,SUNIT    => 'MarkTypesAttrs'
                  ,SACTION  => 'UDO_P_MARK_TYPE_ATTRS_INSERT'
                  ,STABLE   => 'UDO_T_MARK_TYPE_ATTRS');
  --добавим запись
  UDO_PKG_MARK_TYPE.MARK_TYPE_ATTRS_INSERT(NPRN       => NPRN --рег. номер типа показателя
                                          ,NNUMB      => NNUMB --порядковый номер
                                          ,STYPE_ATTR => STYPE_ATTR --мнемокод типового атрибута
                                          ,NRN        => NRN --рег. номер атрибута типа показателя
                                           );
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'MarkTypesAttrs'
                  ,SACTION   => 'UDO_P_MARK_TYPE_ATTRS_INSERT'
                  ,STABLE    => 'UDO_T_MARK_TYPE_ATTRS'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_TYPE_ATTRS_INSERT to public;
/

