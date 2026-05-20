create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_RSMOVE
/*
   Перенос остатков на следующий годовой план этапа заказа
   в разделе "Планы и отчеты по статьям"
  */
(
  NRN      number --рег. номер записи, остатки которой должны быть перенесены
 ,SSTATE   varchar2 --мнемокод состояния
 ,NUSEBASE number := 0 --признак использования базовой функции исправления остатков (0 - нет, 1 - да)
 ,sarticle VARCHAR2 DEFAULT NULL
) as
  type REST is record(NPRJSTG_ARTCL number
                      ,NSTATE        number
                      ,NSUMM         NUMBER
                     ); --тип для хранения остатков
  type RESTARR is table of REST; --тип для хранения коллекции остатков
  RESTEPREV  RESTARR := RESTARR(); --массив остатков на конец за предыдущий период
  REC        UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --запись обрабатываемого плана
  EPREC      ENPERIOD%rowtype; --запись расчетного периода обрабатываемого плана
  NSUMM_YEAR number; --сумма за год
  NTMP       number; --временная переменная
  --проверка наличия остатка в коллекции
  function RESTPREV_EXISTS
  (
    NPRJSTG_ARTCL number
   ,NSTATE        number
  ) return boolean is
  begin
    if (RESTEPREV.COUNT = 0)
    then
      return false;
    else
      for I in RESTEPREV.FIRST .. RESTEPREV.LAST
      loop
        if ((RESTEPREV(I).NPRJSTG_ARTCL = NPRJSTG_ARTCL) and
           (RESTEPREV(I).NSTATE = NSTATE))
        then
          return true;
        end if;
      end loop;
      return false;
    end if;
  end;

  --поиск остатка на конец предыдущего периода в коллекции
  function GET_RESTEPREV
  (
    NPRJSTG_ARTCL number
   ,NSTATE        number
  ) return number is
  begin
    if (RESTEPREV.COUNT = 0)
    then
      return 0;
    else
      for I in RESTEPREV.FIRST .. RESTEPREV.LAST
      loop
        if ((RESTEPREV(I).NPRJSTG_ARTCL = NPRJSTG_ARTCL) and
           (RESTEPREV(I).NSTATE = NSTATE))
        then
          return RESTEPREV(I).NSUMM;
        end if;
      end loop;
      return 0;
    end if;
  end;

  --установка остатка на конец в коллекции
  procedure SET_RESTE
  (
    NPRJSTG_ARTCL number
   ,NSTATE        number
   ,NSUMM         number
  ) is
  begin
    if (RESTEPREV.COUNT = 0)
    then
      RESTEPREV.EXTEND;
      RESTEPREV(RESTEPREV.LAST).NPRJSTG_ARTCL := NPRJSTG_ARTCL;
      RESTEPREV(RESTEPREV.LAST).NSTATE := NSTATE;
      RESTEPREV(RESTEPREV.LAST).NSUMM := NSUMM;
    else
      for I in RESTEPREV.FIRST .. RESTEPREV.LAST
      loop
        if ((RESTEPREV(I).NPRJSTG_ARTCL = NPRJSTG_ARTCL) and
           (RESTEPREV(I).NSTATE = NSTATE))
        then
          RESTEPREV(I).NSUMM := NSUMM;
          return;
        end if;
      end loop;
      RESTEPREV.EXTEND;
      RESTEPREV(RESTEPREV.LAST).NPRJSTG_ARTCL := NPRJSTG_ARTCL;
      RESTEPREV(RESTEPREV.LAST).NSTATE := NSTATE;
      RESTEPREV(RESTEPREV.LAST).NSUMM := NSUMM;
    end if;
  end;

  --проверка наличия остатков
  function REST_EXISTS
  (
    NPLAN   number
   ,NART    number
   ,NSTATUS number
  ) return boolean is
    NTMP number;
    BRES boolean := false;
  begin
    begin
      select R.RN
        into NTMP
        from UDO_T_PRJSTG_ARTCL_PLAN_RS R
       where R.PRN = NPLAN
         and R.PRJSTG_ARTCL = NART
         and R.STATE = NSTATUS;
      BRES := true;
    exception
      when NO_DATA_FOUND then
        BRES := false;
    end;
    return BRES;
  end;

begin
  --считаем обрабатываемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( 0, NRN, 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --считаем запись расчетного периода обрабатываемого плана
  begin
    select T.*
      into EPREC
      from ENPERIOD T
     where T.RN = REC.PERIOD;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( 0, NRN,   'ENPERIOD');
  end;
  --строим список планов по этому этапу проекта, начиная с текущего, в будущее
  for P in (select PL.*
                  ,TO_NUMBER(TO_CHAR(EP.STARTDATE, 'yyyy')) NYEAR
              from UDO_T_PRJSTG_ARTCL_PLAN PL
                  ,ENPERIOD                EP
             where PL.COMPANY = REC.COMPANY
               and PL.PROJECT = REC.PROJECT
               and PL.STAGE = REC.STAGE
               and PL.PERIOD = EP.RN
               and EP.STARTDATE >= EPREC.STARTDATE
               and EP.PERTYPE = 3
             order by EP.STARTDATE asc)
  loop
    --идем по остаткам данного плана
    for R in (select RS.*
                    ,F.CODE   SSTATE
                    ,FDA.CODE SPRJSTG_ARTCL
                from UDO_T_PRJSTG_ARTCL_PLAN_RS RS
                    --,UDO_T_PRJSTG_ARTCL         A
                    ,udo_prjstg_prclc           a
                    ,FINSTATE                   F
                    ,FPDARTCL                   FDA
               where RS.PRN = P.RN
                 and RS.STATE = F.RN
                 and RS.PRJSTG_ARTCL = A.rn
                 and A.Cost_Article = FDA.RN
                 and F.CODE = UDO_P_PRJSTG_ARTCL_PLAN_RSMOVE.SSTATE
                 and ( (sarticle is null) or
                       ( (sarticle is not null) and (STRINLIKE(FDA.CODE, sarticle, GET_OPTIONS_STR('SeqSymb')) > 0) ) 
                      )
                ORDER BY a.numb
              )
    loop
      --если в коллекции ещё нет остатка по этой статье - проинициализируем, т.е. скажем, что остаток на конец предыдущего года есть остток на начало текущего
      if (not RESTPREV_EXISTS(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE))
      then
        SET_RESTE(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE, NSUMM => R.RESTB);
      end if;
      --подсчитаем обороты за этот год
      NSUMM_YEAR := UDO_F_PRJSTG_ARTCL_PLAN_GET(NSTAGE        => P.STAGE
                                               ,NPRJSTG_ARTCL => R.PRJSTG_ARTCL
                                               ,NMONTH        => null
                                               ,NYEAR         => P.NYEAR
                                               ,SSTATE        => R.SSTATE);
      --установим остатки за этот год
      if (REST_EXISTS(NPLAN   => P.RN
                     ,NART    => R.PRJSTG_ARTCL
                     ,NSTATUS => R.STATE))
      then
        if (NUSEBASE = 0)
        then
          UDO_P_PRJSTG_ARTCL_PL_RS_UPD(NRN           => R.RN
                                      ,SPRJSTG_ARTCL => R.SPRJSTG_ARTCL
                                      ,SSTATE        => R.SSTATE
                                      ,NRESTB        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE)
                                      ,NRESTE        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE) + NSUMM_YEAR
                                      ,DACT_FROM     => sysdate);
        else
          UDO_P_PRJSTG_ARTCL_PL_RS_B_UPD(NRN           => R.RN
                                        ,NPRJSTG_ARTCL => R.PRJSTG_ARTCL
                                        ,NSTATE        => R.STATE
                                        ,NRESTB        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE)
                                        ,NRESTE        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE) + NSUMM_YEAR
                                        ,DACT_FROM     => sysdate);
        end if;
      else
        if (NUSEBASE = 0)
        then
          UDO_P_PRJSTG_ARTCL_PL_RS_INS(NPRN          => P.RN
                                      ,SPRJSTG_ARTCL => R.SPRJSTG_ARTCL
                                      ,SSTATE        => R.SSTATE
                                      ,NRESTB        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE)
                                      ,NRESTE        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE) + NSUMM_YEAR
                                      ,DACT_FROM     => sysdate
                                      ,NRN           => NTMP);
        else
          UDO_P_PRJSTG_ARTCL_PL_RS_B_INS(NPRN          => P.RN
                                        ,NPRJSTG_ARTCL => R.PRJSTG_ARTCL
                                        ,NSTATE        => R.STATE
                                        ,NRESTB        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE)
                                        ,NRESTE        => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE) + NSUMM_YEAR
                                        ,DACT_FROM     => sysdate
                                        ,NRN           => NTMP);
        end if;
      end if;
      --сохраним остаток, как остаток на начало для следующего периода
      SET_RESTE(NPRJSTG_ARTCL => R.PRJSTG_ARTCL
               ,NSTATE        => R.STATE
               ,NSUMM         => GET_RESTEPREV(NPRJSTG_ARTCL => R.PRJSTG_ARTCL, NSTATE => R.STATE) + NSUMM_YEAR);
    end loop;
  end loop;
end;
/

