create or replace procedure UDO_P_MARK_ATTRS_DSPL_TGL
/*
    Клиентское сокрытие/отображение атрибута в разделе "Показатели (атрибуты)"
  */
(
  NPRN number --рег. номер показателя
 ,NRN  number --рег. номер атрибута показателя
) is
  PREC UDO_T_MARK%rowtype; --запись показателя
begin
  --считаем родителя
  PREC := UDO_PKG_MARK.MARK_GET(NRN    => NPRN
                               ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'MarksAttrs'
                  ,SACTION   => 'UDO_P_MARK_ATTRS_DSPL_TGL'
                  ,STABLE    => 'UDO_T_MARK_ATTRS'
                  ,NDOCUMENT => NRN);
  --изменим индикатор
  UDO_PKG_MARK.MARK_ATTRS_DSPL_TGL(NPRN => NPRN
                                  ,NRN  => NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'MarksAttrs'
                  ,SACTION   => 'UDO_P_MARK_ATTRS_DSPL_TGL'
                  ,STABLE    => 'UDO_T_MARK_ATTRS'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_ATTRS_DSPL_TGL to public;
/

