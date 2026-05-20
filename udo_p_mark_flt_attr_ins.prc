create or replace procedure UDO_P_MARK_FLT_ATTR_INS
/*
    лиентское добавление в разделе "‘ильтры показателей (атрибуты)"
  */
(
  NPRN            number --рег. номер фильтра
 ,STYPE_ATTR_NAME varchar2 --наименование типового атрибута
 ,NRN             out number --рег. номер добвленной записи
) as
  PREC UDO_T_MARK_FLT%rowtype; --запись фильтра
begin
  --считаем родительскую запись
  PREC := UDO_PKG_MARK_FLT.MARK_FLT_GET(NRN    => NPRN
                                       ,NSMART => 0);
  --регистраци€ начала действи€
  PKG_ENV.PROLOGUE(NCOMPANY => PREC.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => null
                  ,SUNIT    => 'MarkFiltersAttrs'
                  ,SACTION  => 'UDO_P_MARK_FLT_ATTR_INSERT'
                  ,STABLE   => 'UDO_T_MARK_FLT_ATTR');
  --базово добавим
  UDO_PKG_MARK_FLT.MARK_FLT_ATTR_INSERT(NPRN            => NPRN
                                       ,STYPE_ATTR_NAME => STYPE_ATTR_NAME
                                       ,NRN             => NRN);
  --регистраци€ окончани€ дейсти€
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFiltersAttrs'
                  ,SACTION   => 'UDO_P_MARK_FLT_ATTR_INSERT'
                  ,STABLE    => 'UDO_T_MARK_FLT_ATTR'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_FLT_ATTR_INS to public;
/

