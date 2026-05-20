create or replace procedure UDO_P_MARK_COPY_YEAR
/*
   Клиентское размножение на год в разделе "Показатели"
  */
(
  NRN        number --рег. номер показателя
 ,NYEAR      number --год размножения
 ,NVAL_RESET number --признак сброса значений в целевых показателях (1-сбросить, 0-не сбрасывать)
) as
  REC UDO_T_MARK%rowtype; --запись размножаемого показателя
begin
  --считаем размножаемый показатель
  REC := UDO_PKG_MARK.MARK_GET(NRN    => NRN
                              ,NSMART => 0);
  --регистрация начала дейстия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,NJUR_PERS => REC.JUR_PERS
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_COPY_YEAR'
                  ,STABLE    => 'UDO_T_MARK'
                  ,NDOCUMENT => REC.RN);
  --выполним копирование
  UDO_PKG_MARK.MARK_COPY_YEAR(NRN        => REC.RN
                             ,NYEAR      => NYEAR
                             ,NVAL_RESET => NVAL_RESET);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,NJUR_PERS => REC.JUR_PERS
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_COPY_YEAR'
                  ,STABLE    => 'UDO_T_MARK'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_COPY_YEAR to public;
/

