create or replace procedure UDO_P_TYPE_ATTR_INSERT
/*
   Клиентское добавление в разделе "Типовые атрибуты показателей"
  */
(
  NCRN        number --рег. номер каталога размещения
 ,NCOMPANY    number --рег. номер организации
 ,SCODE       varchar2 --мнемокод
 ,SNAME       varchar2 --наименование
 ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
 ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
 ,SUNITNAME   varchar2 --наименование раздела
 ,SMETHOD     varchar2 --наименование метода вызова привязки
 ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
 ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
 ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
 ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
 ,NRN         out number --рег. номер типового атрибута
) is
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => NCOMPANY
                  ,NVERSION => null
                  ,NCATALOG => NCRN
                  ,SUNIT    => 'MarkTypeAttrs'
                  ,SACTION  => 'UDO_P_TYPE_ATTR_INSERT'
                  ,STABLE   => 'UDO_T_TYPE_ATTR');
  --базово добавим
  UDO_PKG_TYPE_ATTR.TYPE_ATTR_INSERT(NCRN        => NCRN --рег. номер каталога размещения
                                    ,NCOMPANY    => NCOMPANY --рег. номер организации
                                    ,SCODE       => SCODE --мнемокод
                                    ,SNAME       => SNAME --наименование
                                    ,NDATA_TYPE  => NDATA_TYPE --тип данных (см. константы NDATA_TYPE_*)
                                    ,NLNK_TYPE   => NLNK_TYPE --тип связи (см. константы NLNK_TYPE_*)
                                    ,SUNITNAME   => SUNITNAME --наименование раздела
                                    ,SMETHOD     => SMETHOD --наименование метода вызова привязки
                                    ,SMETHOD_PRM => SMETHOD_PRM --наименование параметра метода вызова
                                    ,SINIT_PRM   => SINIT_PRM --наименование родительского атрибута привязки
                                    ,SEX_DICT    => SEX_DICT --мнемокод дополнительного словаря привязки
                                    ,NSYNC       => NSYNC --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
                                    ,NRN         => NRN --рег. номер типового атрибута
                                     );
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SUNIT     => 'MarkTypeAttrs'
                  ,SACTION   => 'UDO_P_TYPE_ATTR_INSERT'
                  ,STABLE    => 'UDO_T_TYPE_ATTR'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_TYPE_ATTR_INSERT to public;
/

