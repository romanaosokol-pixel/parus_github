create or replace procedure UDO_P_MARK_FLT_ATTR_TGL_ACTIVE
/*
   Клиентское переключение состояния активности в разделе "Фильтры показателей (атрибуты)"
  */
(
  NCOMPANY number --рег. номер организации
 ,NIDENT   number --идентификатор отмеченных записей атрибутов фильтра
 ,NACTIVE  number := null --флаг активности (см. константы NACTIVE_*, null - измененить текущее состояние на противоположное)
) as
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE_TEMP(NCOMPANY   => NCOMPANY
                       ,NVERSION   => null
                       ,NCATALOG   => null
                       ,NJUR_PERS  => null
                       ,NHIERARCHY => null
                       ,SUNIT      => 'MarkFiltersAttrs'
                       ,SACTION    => 'UDO_P_MARK_FLT_ATTR_TGL_ACTIVE'
                       ,STABLE     => 'UDO_T_MARK_FLT_ATTR'
                       ,NIDENT     => NIDENT);
  --переключим активность атрибута фильтра
  UDO_PKG_MARK_FLT.MARK_FLT_ATTR_TGL_ACTIVE(NCOMPANY => NCOMPANY
                                           ,NIDENT   => NIDENT
                                           ,NACTIVE  => NACTIVE);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE_TEMP(NCOMPANY   => NCOMPANY
                       ,NVERSION   => null
                       ,NCATALOG   => null
                       ,NJUR_PERS  => null
                       ,NHIERARCHY => null
                       ,SUNIT      => 'MarkFiltersAttrs'
                       ,SACTION    => 'UDO_P_MARK_FLT_ATTR_TGL_ACTIVE'
                       ,STABLE     => 'UDO_T_MARK_FLT_ATTR'
                       ,NIDENT     => NIDENT);
end;
--grant execute on UDO_P_MARK_FLT_ATTR_TGL_ACTIVE to public;
/

