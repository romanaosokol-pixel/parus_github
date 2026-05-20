create or replace procedure UDO_P_TYPE_ATTR_IU_FORM_INIT
/*
   Инициализация формы исправления в разделе "Типовые атрибуты показателей"
  */
(
  NRN         number --рег. номер типового атрибута
 ,SUNITNAME   out varchar2 --наименование раздела
 ,SMETHOD     out varchar2 --наименование метода вызова привязки
 ,SMETHOD_PRM out varchar2 --наименование параметра метода вызова
 ,SINIT_PRM   out varchar2 --наименование родительского атрибута привязки
 ,SEX_DICT    out varchar2 --мнемокод дополнительного словаря привязки
 ,NSYNC       out number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
) is
begin
  UDO_PKG_TYPE_ATTR.TYPE_ATTR_IU_FORM_INIT(NRN         => NRN --рег. номер типового атрибута
                                          ,SUNITNAME   => SUNITNAME --наименование раздела
                                          ,SMETHOD     => SMETHOD --наименование метода вызова привязки
                                          ,SMETHOD_PRM => SMETHOD_PRM --наименование параметра метода вызова
                                          ,SINIT_PRM   => SINIT_PRM --наименование родительского атрибута привязки
                                          ,SEX_DICT    => SEX_DICT --мнемокод дополнительного словаря привязки
                                          ,NSYNC       => NSYNC --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
                                           );
end;
--grant execute on UDO_P_TYPE_ATTR_IU_FORM_INIT to public;
/

