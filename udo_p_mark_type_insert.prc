create or replace procedure UDO_P_MARK_TYPE_INSERT
/*
  Клиентское добавление в разделе "Типы показателей"
   */
(
  NCRN     number --рег. номер каталога
 ,NCOMPANY number --рег. номер организации
 ,SCODE    varchar2 --мнемокод
 ,SNAME    varchar2 --наименование
 ,NDUPRN   number := null --рег. номер размножаемой записи типа показателя
 ,NRN      out number --рег. номер типа показателя
) is
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => NCOMPANY
                  ,NVERSION => null
                  ,NCATALOG => NCRN
                  ,SUNIT    => 'MarkTypes'
                  ,SACTION  => 'UDO_P_MARK_TYPE_INSERT'
                  ,STABLE   => 'UDO_T_MARK_TYPE');
  --добавим запись
  UDO_PKG_MARK_TYPE.MARK_TYPE_INSERT(NCRN     => NCRN
                                    ,NCOMPANY => NCOMPANY
                                    ,SCODE    => SCODE
                                    ,SNAME    => SNAME
                                    ,NDUPRN   => NDUPRN
                                    ,NRN      => NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SUNIT     => 'MarkTypes'
                  ,SACTION   => 'UDO_P_MARK_TYPE_INSERT'
                  ,STABLE    => 'UDO_T_MARK_TYPE'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_TYPE_INSERT to public;
/

