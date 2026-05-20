create or replace procedure UDO_P_PRJSTG_ARTCL_BASE_UPDATE
/*
  Ѕазова€ процедура исправлени€ записи в разделе "—татьи" этапа проекта
  */
(
  NRN       number -- рег. номер исправл€емой записи
 ,NFPDARTCL number -- рег. номер статьи
 ,NCURRENCY number -- рег. номер валюты
 ,DACT_FROM date -- дата начала действи€ характеристик
) is
begin
  -- исправим данные в таблице
  update UDO_T_PRJSTG_ARTCL T
     set T.FPDARTCL = NFPDARTCL
        ,T.CURRENCY = NCURRENCY
        ,T.ACT_FROM = DACT_FROM
   where T.RN = NRN;
end UDO_P_PRJSTG_ARTCL_BASE_UPDATE;
/

