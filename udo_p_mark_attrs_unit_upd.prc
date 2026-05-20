create or replace procedure UDO_P_MARK_ATTRS_UNIT_UPD
/*
   Клиентское исправление атрибута полученного по связи с разделом в разделе "Показатели (атрибуты)"
  */
(
  NRN       number --рег. номер атрибута показателя
 ,SVAL_UNIT varchar2 --значение по ссылке из раздела
) as
  REC  UDO_T_MARK_ATTRS%rowtype; --запись атрибута показателя
  PREC UDO_T_MARK%rowtype; --запись показателя
begin
  --считаем запись
  REC := UDO_PKG_MARK.MARK_ATTRS_GET(NRN    => NRN
                                    ,NSMART => 0);
  --считаем родителя
  PREC := UDO_PKG_MARK.MARK_GET(NRN    => REC.PRN
                               ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'MarksAttrs'
                  ,SACTION   => 'UDO_P_MARK_ATTRS_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_ATTRS'
                  ,NDOCUMENT => NRN);
  --базово исправим
  UDO_PKG_MARK.MARK_ATTRS_UNIT_UPDATE(NRN       => NRN
                                     ,SVAL_UNIT => SVAL_UNIT);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'MarksAttrs'
                  ,SACTION   => 'UDO_P_MARK_ATTRS_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_ATTRS'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_ATTRS_UNIT_UPD to public;
/

