create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_UPD
/*
   Клиентское исправление в разделе "Планы и отчеты по статьям"
  */
(
  NRN          number --рег. номер исправляемой записи
 ,NCRN         number --рег. номер каталога
 ,NCOMPANY     number --рег. номер организации
 ,SPROJECT     varchar2 --мнемокод проекта
 ,SSTAGE       varchar2 --номер этапа проекта
 ,SPERIOD      varchar2 --мнемокод расчетного периода (год)
 ,SCALC_SCHEMA varchar2 --мнемокод схемы калькуляции
 ,SLIMITART    varchar2 --контрольная статья
 ,NSUMM        number --сумма на период
) as
  NPROJECT     number(17); --рег. номер проекта
  NSTAGE       number(17); --рег. номер этапа проекта
  NPERIOD      number(17); --рег. номер расчетного периода
  NCALC_SCHEMA number(17); --рег. номер схемы калькуляции
  NLIMITART    number(17); --рег. номер контрольной статьи
  REC          UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --исправляемая запись
begin
  --разыменуем ссылки
  UDO_P_PRJSTG_ARTCL_PLAN_JOINS(NCOMPANY     => NCOMPANY
                               ,SPROJECT     => SPROJECT
                               ,SSTAGE       => SSTAGE
                               ,SPERIOD      => SPERIOD
                               ,SCALC_SCHEMA => SCALC_SCHEMA
                               ,SLIMITART    => SLIMITART
                               ,NPROJECT     => NPROJECT
                               ,NSTAGE       => NSTAGE
                               ,NPERIOD      => NPERIOD
                               ,NCALC_SCHEMA => NCALC_SCHEMA
                               ,NLIMITART    => NLIMITART);
  --считаем исправляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --проверим её состояние
  if (REC.STATE <> 0)
  then
    P_EXCEPTION(0
               ,'Исправление невозможно - документ утвержден!');
  end if;
  --проверим неизменяемость полей
  if (REC.PROJECT <> NPROJECT)
  then
    P_EXCEPTION(0
               ,'Изменение проекта запрещено!');
  end if;
  if (REC.STAGE <> NSTAGE)
  then
    P_EXCEPTION(0
               ,'Изменение этапа проекта запрещено!');
  end if;
  if (REC.PERIOD <> NPERIOD)
  then
    P_EXCEPTION(0
               ,'Изменение периода запрещено!');
  end if;
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_UPD'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => NRN);
  --исправим данные в таблице
  UDO_P_PRJSTG_ARTCL_PLAN_B_UPD(NRN          => NRN
                               ,NPROJECT     => NPROJECT
                               ,NSTAGE       => NSTAGE
                               ,NPERIOD      => NPERIOD
                               ,NCALC_SCHEMA => NCALC_SCHEMA
                               ,NSUMM        => NSUMM
                               ,NLIMITART    => NLIMITART);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_UPD'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => NRN);
end;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PLAN_UPD for UDO_P_PRJSTG_ARTCL_PLAN_UPD;
  grant execute on UDO_P_PRJSTG_ARTCL_PLAN_UPD to public;
  */
/

