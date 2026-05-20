create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_INIT
/*
   Начальное формирование постатейного плана в разделе "Планы и отчеты по статьям (спецификация)"
  */
(
  NPRN          number --рег. номер родительской записи
 ,NPRJSTG_ARTCL varchar2 --рег. номер статьи этапа заказа
 ,NMODE         number --режим работы (1 - инициализация при добавлении, 2 - снятие инициализации)
) as
  SPLAN_CONST      CONSTLST.NAME%type := 'СОСТ_ПЛАН'; --констата с мнемокодом планового состояния
  SFACT_CONST      CONSTLST.NAME%type := 'СОСТ_ФАКТ'; --констата с мнемокодом фактического состояния
  SENPCAT_CONST    CONSTLST.NAME%type := 'КАТ_РАСЧ_ПЕРИОДОВ'; --констата с наименованием каталога расчетных периодов
  NENPCAT          ACATALOG.RN%type; --рег. номер каталога для расчетных периодов
  SPLAN            FINSTATE.CODE%type; --состояние план (мнемокод)
  NPLAN            FINSTATE.RN%type; --состояние план (рег. номер)
  SFACT            FINSTATE.CODE%type; --состояние факт (мнемокод)
  NFACT            FINSTATE.RN%type; --состояние факт (рег. номер)
  RPLAN             UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --запись плана
  --ARTREC           UDO_V_PRJSTG_ARTCL%rowtype; --запись статьи этапа
  ARTREC           UDO_V_PRJSTG_PRCLC%rowtype; --запись статьи этапа
  PRDREC           ENPERIOD%rowtype; --запись периода планирования
  PLAN_PERIOD_PREF CONSTLST.STRVALUE%type; --префикс учетного периода для плановой КПФЗ
  NTMP             number; --временная переменная
  
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

  --проверка наличия планов
  function SP_EXISTS
  (
    NPLAN   number
   ,NART    number
   ,NSTATUS number
   ,NPERIOD number
  ) return boolean is
    NTMP number;
    BRES boolean := false;
  begin
    begin
      select S.RN
        into NTMP
        from UDO_T_PRJSTG_ARTCL_PLAN_SP S
       where S.PRN = NPLAN
         and S.PRJSTG_ARTCL = NART
         and S.STATE = NSTATUS
         and S.PERIOD = NPERIOD;
      BRES := true;
    exception
      when NO_DATA_FOUND then
        BRES := false;
    end;
    return BRES;
  end;

begin
  --считаем родительскую запись
  begin
    select T.*
      into RPLAN
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NPRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, NPRN, 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --считаем статью этапа
  begin
    select T.*
      into ARTREC
      from --UDO_V_PRJSTG_ARTCL T
           UDO_V_PRJSTG_PRCLC T
     where T.NRN = NPRJSTG_ARTCL;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, NPRJSTG_ARTCL, 'UDO_T_PRJSTG_ARTCL');
  end;
  --считаем период планирования
  begin
    select T.*
      into PRDREC
      from ENPERIOD T
     where T.RN = RPLAN.PERIOD;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, RPLAN.PERIOD, 'ENPERIOD');
  end;
  --найдем плановое состояние
  P_GET_STRING_CONSTANT(RPLAN.COMPANY,SPLAN_CONST, null, SPLAN);
  FIND_FINSTATE_CODE(0, RPLAN.COMPANY, SPLAN, NPLAN);
  --найдем фактическое состояние
  P_GET_STRING_CONSTANT(RPLAN.COMPANY, SFACT_CONST, null, SFACT);
  FIND_FINSTATE_CODE(0, RPLAN.COMPANY, SFACT, NFACT);
  --считаем префикс планового периода карточки ПФЗП
  PLAN_PERIOD_PREF := UDO_F_SYS0006_GET_CONST_VAL(RPLAN.COMPANY ,'ПЛАН_ПЕР_ПРЕФ');
  /*if (PLAN_PERIOD_PREF is null)
  then
    P_EXCEPTION(0,'Не указано значение системной константы "ПЛАН_ПЕР_ПРЕФ"!');
  end if;*/
  --определим каталог расчетных периодов
  if (UDO_F_SYS0006_GET_CONST_VAL( RPLAN.COMPANY, SENPCAT_CONST) is null)
  then
    P_EXCEPTION(0 ,'Неуказано название каталога для расчетных периодов (константа "' || SENPCAT_CONST || '")!');
  end if;
  FIND_ACATALOG_NAME(0, RPLAN.COMPANY, null, 'ENCalcPeriods', UDO_F_SYS0006_GET_CONST_VAL(RPLAN.COMPANY, SENPCAT_CONST), NENPCAT);
  --если это инициализация
  if (NMODE = 1)
  then
    --добавляем остатки (факт), если их ещё нет
    if (not (REST_EXISTS(RPLAN.RN, ARTREC.NRN, NFACT)))
    then
      UDO_P_PRJSTG_ARTCL_PL_RS_B_INS(NPRN          => RPLAN.RN
                                    ,NPRJSTG_ARTCL => ARTREC.NRN
                                    ,NSTATE        => NFACT
                                    ,NRESTB        => 0
                                    ,NRESTE        => 0
                                    ,DACT_FROM     => sysdate
                                    ,NRN           => NTMP);
    end if;
    --добавляем остатки (план), если их ещё нет и если они нужны
    if (--(ARTREC.NSIGN_PLAN = 1) and
       (not (REST_EXISTS(RPLAN.RN, ARTREC.NRN, NPLAN))))
    then
      UDO_P_PRJSTG_ARTCL_PL_RS_B_INS(NPRN          => RPLAN.RN
                                    ,NPRJSTG_ARTCL => ARTREC.NRN
                                    ,NSTATE        => NPLAN
                                    ,NRESTB        => 0
                                    ,NRESTE        => 0
                                    ,DACT_FROM     => sysdate
                                    ,NRN           => NTMP);
    end if;
    --строим список периодов, входящих в период (год) плана
    for PRD in (select P.RN, P.CODE
                  from ENPERIOD P
                 where P.COMPANY = RPLAN.COMPANY
                   and P.STARTDATE >= PRDREC.STARTDATE
                   and P.ENDDATE <= PRDREC.ENDDATE
                   and P.PERTYPE = 0
                   --and P.CODE not like PLAN_PERIOD_PREF || '%'
                   and P.CRN in (select T.RN
                                   from ACATALOG T
                                 connect by prior T.RN = T.CRN
                                  start with T.RN = NENPCAT
                                 )
                 )
    loop
      --добавляем ежемесячные планы (в состоянии факт), если их ещё нет
      if (not (SP_EXISTS( RPLAN.RN, ARTREC.NRN, NFACT, PRD.RN)))
      then
        UDO_P_PRJSTG_ARTCL_PL_SP_B_INS(NPRN          => RPLAN.RN
                                      ,NPRJSTG_ARTCL => ARTREC.NRN
                                      ,NPERIOD       => PRD.RN
                                      ,NSTATE        => NFACT
                                      ,NSUMM         => 0
                                      ,DACT_FROM     => sysdate
                                      ,NRN           => NTMP);
      end if;
      --добавляем ежемесячные планы (план), если их ещё нет и если они нужны
      if (--(ARTREC.NSIGN_PLAN = 1) and
         (not (SP_EXISTS(RPLAN.RN, ARTREC.NRN, NPLAN, PRD.RN))))
      then
        UDO_P_PRJSTG_ARTCL_PL_SP_B_INS(NPRN          => RPLAN.RN
                                      ,NPRJSTG_ARTCL => ARTREC.NRN
                                      ,NPERIOD       => PRD.RN
                                      ,NSTATE        => NPLAN
                                      ,NSUMM         => 0
                                      ,DACT_FROM     => sysdate
                                      ,NRN           => NTMP);
      end if;
    end loop;
    --установим лимитирующую статью, если она ещё не установлена и есть среди статей этапа
    if (RPLAN.LIMITART is null)
    then
      for C in (select SA.RN
                  from --UDO_T_PRJSTG_ARTCL SA
                       udo_prjstg_prclc sa
                      ,FPDARTCL           A
                 where SA.PRN = RPLAN.CALC_SCHEMA
                   and SA.COST_ARTICLE = A.RN
                   and A.CODE = UDO_F_SYS0006_GET_CONST_VAL(RPLAN.COMPANY, 'СТАТЬЯ_ЦЕНА')
               )
      loop
        update UDO_T_PRJSTG_ARTCL_PLAN T
           set T.LIMITART = C.RN
         where T.RN = RPLAN.RN;
      end loop;
    end if;
  end if;
  --если это снятие инициализации
  if (NMODE = 2)
  then
    --удалим остатки по статье
    for RS in (select T.RN
                 from UDO_T_PRJSTG_ARTCL_PLAN_RS T
                where T.PRN = RPLAN.RN
                  and T.PRJSTG_ARTCL = ARTREC.NRN)
    loop
      UDO_P_PRJSTG_ARTCL_PL_RS_DEL(RS.RN);
    end loop;
    --удалим планы по статье
    for SP in (select T.RN
                 from UDO_T_PRJSTG_ARTCL_PLAN_SP T
                where T.PRN = RPLAN.RN
                  and T.PRJSTG_ARTCL = ARTREC.NRN)
    loop
      UDO_P_PRJSTG_ARTCL_PL_SP_DEL(SP.RN);
    end loop;
  end if;
END UDO_P_PRJSTG_ARTCL_PL_SP_INIT;
/

