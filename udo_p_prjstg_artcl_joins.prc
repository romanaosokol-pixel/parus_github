create or replace procedure UDO_P_PRJSTG_ARTCL_JOINS
/*
  Процедура разрешения ссылок раздела "Статьи" этапа проекта
  */
(
  NCOMPANY  in number -- организации
 ,SFPDARTCL in varchar2 -- код статьи затрат
 ,SCURRENCY in varchar2 -- код валюты
 ,NFPDARTCL out number -- рег. номер статьи затрат
 ,NCURRENCY out number -- рег. номер валюты
) is
begin
  -- определим рег. номер статьи затрат
  FIND_FPDARTCL_CODE(NFLAG_SMART => 0
                    ,NCOMPANY    => NCOMPANY
                    ,SCODE       => SFPDARTCL
                    ,NRN         => NFPDARTCL);
  -- определим рег. номер валюты
  FIND_CURRENCY_BY_CODE(COMPANY => NCOMPANY
                       ,CODE    => SCURRENCY
                       ,RN      => NCURRENCY);
end UDO_P_PRJSTG_ARTCL_JOINS;
/

