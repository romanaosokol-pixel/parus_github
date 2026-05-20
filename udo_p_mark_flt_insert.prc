create or replace procedure UDO_P_MARK_FLT_INSERT
/*
   Клиентское добавление в разделе "Фильтры показателей"
  */
(
  NCOMPANY number --рег. номер организации
 ,SNAME    varchar2 --наименование фильтра
 ,NDUPRN   number := null --рег. номер размножаемой записи показателя
 ,NRN      out number --рег. номер добвленной записи
) is
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => NCOMPANY
                  ,NVERSION => null
                  ,NCATALOG => null
                  ,SUNIT    => 'MarkFilters'
                  ,SACTION  => 'UDO_P_MARK_FLT_INSERT'
                  ,STABLE   => 'UDO_T_MARK_FLT');
  --базово добавим
  UDO_PKG_MARK_FLT.MARK_FLT_INSERT(NCOMPANY => NCOMPANY
                                  ,SNAME    => SNAME
                                  ,NDUPRN   => NDUPRN
                                  ,NRN      => NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFilters'
                  ,SACTION   => 'UDO_P_MARK_FLT_INSERT'
                  ,STABLE    => 'UDO_T_MARK_FLT'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_FLT_INSERT to public;
/

