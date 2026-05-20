create or replace procedure UDO_P_PRJSTG_ARTCL_INSERT
/*
  Клиентская процедура добавления записи в раздел "Статьи" этапа проекта
  */
(
  NPRN       number -- рег. номомер родительского этапа
 ,SFPDARTCL  varchar2 -- код статьи
 ,SCURRENCY  varchar2 -- код валюты
 ,NSIGN      number := 0 -- признак типа (0 - общие статьи, 1 - статья структуры цены)
 ,NSIGN_PLAN number := 0 -- признак планирования (0 - не подлежит планированию, 1 - подлежит планированию)
 ,DACT_FROM  date -- дата начала действия
 ,NRN        out number -- рег. номер новой записи
) is
  NFPDARTCL number(17); --рег. номер статьи
  NCURRENCY number(17); --рег. номер валюты
  PREC      PROJECTSTAGE%rowtype; --родительская запись
  PRJREC    PROJECT%rowtype; --запись проекта
begin
  -- считаем родительскую запись
  begin
    select P.*
      into PREC
      from PROJECTSTAGE P
     where P.RN = NPRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NPRN
                              ,SUNIT_TABLE => 'PROJECTSTAGE');
  end;
  if (PREC.STATE not in (0
                        ,1))
  then
    P_EXCEPTION(0
               ,'Родттельский этап списан или закрыт!');
  end if;
  -- считаем запись проекта
  begin
    select P.*
      into PRJREC
      from PROJECT P
     where P.RN = PREC.PRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => PREC.PRN
                              ,SUNIT_TABLE => 'PROJECT');
  end;
  -- разрешение ссылок
  UDO_P_PRJSTG_ARTCL_JOINS(NCOMPANY  => PREC.COMPANY
                          ,SFPDARTCL => SFPDARTCL
                          ,SCURRENCY => SCURRENCY
                          ,NFPDARTCL => NFPDARTCL
                          ,NCURRENCY => NCURRENCY);
  -- проверим совпедение валют
  if (NCURRENCY != PRJREC.CURNAMES)
  then
    P_EXCEPTION(0
               ,'Валюта статьи должна совпадать с валютой проекта!');
  end if;
  -- фиксируем начало действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'ProjectsStagesArts'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_INSERT'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL');
  -- базовое добавление
  UDO_P_PRJSTG_ARTCL_BASE_INSERT(NPRN       => NPRN
                                ,NFPDARTCL  => NFPDARTCL
                                ,NCURRENCY  => NCURRENCY
                                ,NSIGN      => NVL(NSIGN
                                                  ,0)
                                ,NSIGN_PLAN => NVL(NSIGN_PLAN
                                                  ,0)
                                ,DACT_FROM  => DACT_FROM
                                ,NRN        => NRN);
  -- фиксация окончания выполнения действия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'ProjectsStagesArts'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_INSERT'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL'
                  ,NDOCUMENT => NRN);
  -- проведем инициализацию статьи
  UDO_P_PRJSTG_ARTCL_INIT(NRN   => NRN
                         ,NMODE => 1);
end UDO_P_PRJSTG_ARTCL_INSERT;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_INSERT for UDO_P_PRJSTG_ARTCL_INSERT;
  grant execute on UDO_P_PRJSTG_ARTCL_INSERT to public;
  */
/

