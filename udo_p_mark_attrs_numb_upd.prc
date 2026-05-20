create or replace procedure UDO_P_MARK_ATTRS_NUMB_UPD
/*
   Клиентское исправление атрибута типа число в разделе "Показатели (атрибуты)"
  */
(
  NRN       number --рег. номер атрибута показателя
 ,NVAL_NUMB number --значение (число)
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
  UDO_PKG_MARK.MARK_ATTRS_NUMB_UPDATE(NRN       => NRN
                                     ,NVAL_NUMB => NVAL_NUMB);
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
--grant execute on UDO_P_MARK_ATTRS_NUMB_UPD to public;
/

