create or replace procedure UDO_P_TYPE_ATTR_INIT
/*
   Клиентская инициализация системных атрибутов в разделе "Типовые атрибуты показателей"
  */
(
  NCRN     number --рег. номер каталога размещения
 ,NCOMPANY number --рег. номер организации
) is
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE_TEMP(NCOMPANY   => NCOMPANY
                       ,NVERSION   => null
                       ,NCATALOG   => NCRN
                       ,NJUR_PERS  => null
                       ,NHIERARCHY => null
                       ,SUNIT      => 'MarkTypeAttrs'
                       ,SACTION    => 'UDO_P_TYPE_ATTR_INIT'
                       ,STABLE     => 'UDO_T_TYPE_ATTR'
                       ,NIDENT     => null);
  --инициализируем
  UDO_PKG_TYPE_ATTR.TYPE_ATTR_INIT(NCRN     => NCRN
                                  ,NCOMPANY => NCOMPANY);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE_TEMP(NCOMPANY   => NCOMPANY
                       ,NVERSION   => null
                       ,NCATALOG   => NCRN
                       ,NJUR_PERS  => null
                       ,NHIERARCHY => null
                       ,SUNIT      => 'MarkTypeAttrs'
                       ,SACTION    => 'UDO_P_TYPE_ATTR_INIT'
                       ,STABLE     => 'UDO_T_TYPE_ATTR'
                       ,NIDENT     => null);
end;
--grant execute on UDO_P_TYPE_ATTR_INIT to public;
/

