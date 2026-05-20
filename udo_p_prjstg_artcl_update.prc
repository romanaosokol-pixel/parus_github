create or replace procedure UDO_P_PRJSTG_ARTCL_UPDATE
/*
  Клиентская процедура исправления записи в раздел "Статьи" этапа проекта
  */
(
  NRN       number -- рег. номер записи
 ,SFPDARTCL varchar2 -- код статьи затрат
 ,SCURRENCY varchar2 -- код валюты
 ,DACT_FROM date -- дата начала действия
) is
  NFPDARTCL number(17); --рег. номер статьи
  NCURRENCY number(17); --рег. номер валюты
  REC       UDO_T_PRJSTG_ARTCL%rowtype; --исправляемая запись
  PREC      PROJECTSTAGE%rowtype; --родительская запись
  PRJREC    PROJECT%rowtype; --запись проекта
begin
  -- считаем исправляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL');
  end;
  -- считаем родительскую запись
  begin
    select P.*
      into PREC
      from PROJECTSTAGE P
     where P.RN = REC.PRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => REC.PRN
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
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_UPDATE'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL'
                  ,NDOCUMENT => REC.RN);
  -- базовое добавление
  UDO_P_PRJSTG_ARTCL_BASE_UPDATE(NRN       => NRN
                                ,NFPDARTCL => NFPDARTCL
                                ,NCURRENCY => NCURRENCY
                                ,DACT_FROM => DACT_FROM);
  -- фиксация окончания выполнения действия 
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'ProjectsStagesArts'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_UPDATE'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL'
                  ,NDOCUMENT => REC.RN);
end UDO_P_PRJSTG_ARTCL_UPDATE;
/

