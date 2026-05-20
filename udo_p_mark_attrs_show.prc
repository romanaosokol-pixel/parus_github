create or replace procedure UDO_P_MARK_ATTRS_SHOW
/*
  Клиентское отображение атрибута в разделе "Показатели (атрибуты)"
   */
(
  NPRN            number --рег. номер показателя
 ,STYPE_ATTR_NAME varchar2 --наименование атрибута
) is
  PREC UDO_T_MARK%rowtype; --запись показателя
begin
  --считаем запись показателя
  PREC := UDO_PKG_MARK.MARK_GET(NRN    => NPRN
                               ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'MarksAttrs'
                  ,SACTION   => 'UDO_P_MARK_ATTRS_SHOW'
                  ,STABLE    => 'UDO_T_MARK_ATTRS'
                  ,NDOCUMENT => PREC.RN);
  --отобразим атрибут
  UDO_PKG_MARK.MARK_ATTRS_SHOW(NPRN            => PREC.RN
                              ,STYPE_ATTR_NAME => STYPE_ATTR_NAME);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'MarksAttrs'
                  ,SACTION   => 'UDO_P_MARK_ATTRS_SHOW'
                  ,STABLE    => 'UDO_T_MARK_ATTRS'
                  ,NDOCUMENT => PREC.RN);
end;
--grant execute on UDO_P_MARK_ATTRS_SHOW to public;
/

