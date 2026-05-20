create or replace procedure UDO_P_MARK_FLT_UPDATE
/*
   Клиентское исправление в разделе "Фильтры показателей"
  */
(
  NRN   number --рег. номер исправляемой записи
 ,SNAME varchar2 --наименование фильтра
) is
  REC UDO_T_MARK_FLT%rowtype; --запись фильтра
begin
  --считаем запись
  REC := UDO_PKG_MARK_FLT.MARK_FLT_GET(NRN    => NRN
                                      ,NSMART => 0);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFilters'
                  ,SACTION   => 'UDO_P_MARK_FLT_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_FLT'
                  ,NDOCUMENT => REC.RN);
  --базово исправим
  UDO_PKG_MARK_FLT.MARK_FLT_UPDATE(NRN   => NRN
                                  ,SNAME => SNAME);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => null
                  ,SUNIT     => 'MarkFilters'
                  ,SACTION   => 'UDO_P_MARK_FLT_UPDATE'
                  ,STABLE    => 'UDO_T_MARK_FLT'
                  ,NDOCUMENT => REC.RN);
end;
--grant execute on UDO_P_MARK_FLT_UPDATE to public;
/

