create or replace procedure UDO_P_MARK_DELETE
/*
   Клиентское удаление в разделе "Показатели"
  */
(NRN number --рег. номер показателя
 ) as
  REC UDO_T_MARK%rowtype; --запись показателя
begin
  --считаем показатель
  REC := UDO_PKG_MARK.MARK_GET(NRN    => NRN
                              ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,NJUR_PERS => REC.JUR_PERS
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_DELETE'
                  ,STABLE    => 'UDO_T_MARK'
                  ,NDOCUMENT => REC.RN);
  --базово удалим
  UDO_PKG_MARK.MARK_DELETE(NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,NJUR_PERS => REC.JUR_PERS
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_DELETE'
                  ,STABLE    => 'UDO_T_MARK'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_DELETE to public;
/

