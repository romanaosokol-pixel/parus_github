create or replace procedure UDO_P_PRJSTG_ARTCL_BASE_INSERT
/*
  Базовая процедура добавления записи в раздел "Статьи" этапа проекта
  */
(
  NPRN       number -- рег. номомер родительского этапа
 ,NFPDARTCL  number -- рег. номер статьи
 ,NCURRENCY  number -- рег. номер валюты
 ,NSIGN      number := 0 -- признак типа (0 - общие статьи, 1 - статья структуры цены)
 ,NSIGN_PLAN number := 0 -- признак планирования (0 - не подлежит планированию, 1 - подлежит планированию)
 ,DACT_FROM  date -- дата начала действия показателей
 ,NRN        out number -- рег. номер добавленной записи
) is
begin
  NRN := GEN_ID;
  insert into UDO_T_PRJSTG_ARTCL
    (RN, PRN, FPDARTCL, CURRENCY, SIGN, SIGN_PLAN, ACT_FROM)
  values
    (NRN, NPRN, NFPDARTCL, NCURRENCY, NSIGN, NSIGN_PLAN, DACT_FROM);
end UDO_P_PRJSTG_ARTCL_BASE_INSERT;
/

