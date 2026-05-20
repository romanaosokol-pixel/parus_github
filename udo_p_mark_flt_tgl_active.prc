create or replace procedure UDO_P_MARK_FLT_TGL_ACTIVE
/*
   Клиентское переключение состояния активности в разделе "Фильтры показателей"
  */
(
  NCOMPANY number --рег. номер организации
 ,NIDENT   number --идентификатор отмеченных записей фильтра
 ,NACTIVE  number := null --флаг активности (см. константы NACTIVE_*, null - измененить текущее состояние на противоположное)
) is
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE_TEMP(NCOMPANY   => NCOMPANY
                       ,NVERSION   => null
                       ,NCATALOG   => null
                       ,NJUR_PERS  => null
                       ,NHIERARCHY => null
                       ,SUNIT      => 'MarkFilters'
                       ,SACTION    => 'UDO_P_MARK_FLT_TGL_ACTIVE'
                       ,STABLE     => 'UDO_T_MARK_FLT'
                       ,NIDENT     => NIDENT);
  --переключим активность фильтра
  UDO_PKG_MARK_FLT.MARK_FLT_TGL_ACTIVE(NCOMPANY => NCOMPANY
                                      ,NIDENT   => NIDENT
                                      ,NACTIVE  => NACTIVE);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE_TEMP(NCOMPANY   => NCOMPANY
                       ,NVERSION   => null
                       ,NCATALOG   => null
                       ,NJUR_PERS  => null
                       ,NHIERARCHY => null
                       ,SUNIT      => 'MarkFilters'
                       ,SACTION    => 'UDO_P_MARK_FLT_TGL_ACTIVE'
                       ,STABLE     => 'UDO_T_MARK_FLT'
                       ,NIDENT     => NIDENT);
end;
--grant execute on UDO_P_MARK_FLT_TGL_ACTIVE to public;
/

