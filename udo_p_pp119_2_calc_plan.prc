create or replace procedure UDO_P_PP119_2_CALC_PLAN
/*
   Калькуляция этапа заказа в указанном году
   Чечнев М.С.
  */
(
  NPLAN        number --рег. номер плана
 ,SSTATE       varchar2 --мнемокод состояния пересчитываемых данных
 ,NINIT_CALC   number --режим работы (1 - начальная инициализация по данным статей заказа, 0 - расчет по даннм плана)
 ,NCHECK_LINKS number --проверять связи (0 - нет, 1 - да)
 ,NMONTH       number --номер месяца для пересчета (null для всех)
 ,SART         varchar2 --расчитываемая статья (null для всех, можно чере разделитель SeqSymb)
) as
  REC        UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --запись плана
  PRJREC     PROJECT%rowtype; --запись заказа
  STGREC     PROJECTSTAGE%rowtype; --запись этапа
  PRD        ENPERIOD%rowtype; --запись расчетного периода плана
  CALCREC    PRJCALCSCHM%rowtype; --запись схемы калькуляции
  NARTSUMM   UDO_T_PRICE_STRUCT.SUMM%type; --расчитанная сумма по статье
  STREC      PROJECTSTAGE%rowtype; --запись инициализируемого этапа
  NCNTMONTHS number(17); --количество месяцев этапа
  NSTATE     FINSTATE.RN%type; --рег. номер состояния
  NSUMMS     UDO_TP_NUMTABLE; --массив для хранения значений расчитанных сумм
  --функция считывания значения прямой статьи (для начальной калькуляции по данным структуры цены заказа)
  function GET_DIRECT_SUMM_INIT
  (
    NSTAGE number
   ,NART   number
   ,NSIGN  number
  ) return number is
    NRES UDO_T_PRICE_STRUCT.SUMM%type := 0;
  begin
    select DECODE(NSIGN
                 ,0
                 ,NVL(T.SUMM
                     ,0)
                 ,NVL(T.SUMM * (-1)
                     ,0))
      into NRES
      from UDO_T_PRICE_STRUCT T
          ,UDO_T_PRJSTG_ARTCL A
     where T.PRN = NSTAGE
       and T.PRJSTG_ARTCL = A.RN
       and A.FPDARTCL = NART;
    return NRES;
  exception
    when others then
      return NRES;
  end;

  --функция считывания значения прямой статьи (для калькуляции по данным помесячного плана)
  function GET_DIRECT_SUMM
  (
    NSTAGE    number
   ,NART      number
   ,NARTSCHRN number
   ,NSIGN     number
   ,NYEAR     number
   ,NMONTH    number
   ,SSTATE    varchar2
  ) return number is
    NRES UDO_T_PRJSTG_ARTCL_PLAN_SP.SUMM%type := 0;
  begin
    select DECODE(NSIGN
                 ,0
                 ,NVL(SP.SUMM
                     ,0)
                 ,NVL(SP.SUMM * (-1)
                     ,0)) * ROUND((TO_NUMBER(NVL(UDO_F_GET_DOC_PROP_VAL(NARTSCHRN
                                                                       ,'ПроцентВхождения')
                                                ,100)) / 100)
                                 ,2)
      into NRES
      from UDO_T_PRJSTG_ARTCL_PLAN    P
          ,UDO_T_PRJSTG_ARTCL_PLAN_SP SP
          ,UDO_T_PRJSTG_ARTCL         SA
          ,ENPERIOD                   EP
          ,ENPERIOD                   EPS
          ,FINSTATE                   FS
          ,FPDARTCL                   FA
     where P.STAGE = NSTAGE
       and P.PERIOD = EP.RN
       and EXTRACT(year from EP.STARTDATE) = NYEAR
       and SP.PRN = P.RN
       and SP.STATE = FS.RN
       and FS.CODE = SSTATE
       and SP.PERIOD = EPS.RN
       and EXTRACT(year from EPS.STARTDATE) = NYEAR
       and EXTRACT(month from EPS.STARTDATE) = NMONTH
       and SA.RN = SP.PRJSTG_ARTCL
       and SA.FPDARTCL = FA.RN
       and FA.RN = NART;
    return NRES;
  exception
    when others then
      return NRES;
  end;

  --функция проверки является ли статья схемы калькуляции прямой или косвенной
  function IS_ART_DIRECT
  (
    NSCHEMA number
   ,NART    number
  ) return boolean is
    NTMP number;
    STMP FPDARTCL.CODE%type;
    BRES boolean := true;
  begin
    select SP.KIND
          ,A.CODE
      into NTMP
          ,STMP
      from PRJCALCSCHMSP SP
          ,FPDARTCL      A
     where SP.PRN = NSCHEMA
       and SP.FPDARTCL = NART
       and SP.FPDARTCL = A.RN;
    if (NTMP = 0)
    then
      BRES := true;
    else
      BRES := false;
    end if;
    if ((SART is not null) and
       (STRINLIKE(STMP
                  ,SART
                  ,GET_OPTIONS_STR('SeqSymb')) = 0))
    then
      BRES := true;
    end if;
    return BRES;
  exception
    when others then
      return BRES;
  end;

  --функция расчета статьи согласно схеме (для начальной калькуляции по данным структуры цены заказа)
  function CALC_ART_INIT
  (
    NSTAGE    number
   ,NSCHEMA   number
   ,NSCHEMASP number
  ) return number is
    CALCSPREC     PRJCALCSCHMSP%rowtype;
    NSCHEMASP_ART number;
    NRES          UDO_T_PRICE_STRUCT.SUMM%type := 0;
  begin
    begin
      select T.*
        into CALCSPREC
        from PRJCALCSCHMSP T
       where RN = NSCHEMASP;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NSCHEMASP
                                ,SUNIT_TABLE => 'PRJCALCSCHMSP');
    end;
    for CS in (select A.*
                 from PRJCALCSCHMART A
                where A.PRN = NSCHEMASP)
    loop
      if (IS_ART_DIRECT(NSCHEMA => NSCHEMA
                       ,NART    => CS.FPDARTCL))
      then
        NRES := NRES + GET_DIRECT_SUMM_INIT(NSTAGE => NSTAGE
                                           ,NART   => CS.FPDARTCL
                                           ,NSIGN  => CS.SIGN);
      else
        begin
          select S.RN
            into NSCHEMASP_ART
            from PRJCALCSCHMSP S
           where S.PRN = NSCHEMA
             and S.FPDARTCL = CS.FPDARTCL;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0
                       ,'Неудалось определить схему калькуляции косвенной статьи затрат!');
        end;
        NRES := NRES + CALC_ART_INIT(NSTAGE    => NSTAGE
                                    ,NSCHEMA   => NSCHEMA
                                    ,NSCHEMASP => NSCHEMASP_ART);
      end if;
    end loop;
    return NRES * CALCSPREC.PERCENT / 100;
  end;

  --функция расчета статьи согласно схеме (для калькуляции по данным плана)
  function CALC_ART
  (
    NSTAGE    number
   ,NSCHEMA   number
   ,NSCHEMASP number
   ,NYEAR     number
   ,NMONTH    number
   ,SSTATE    varchar2
  ) return number is
    CALCSPREC     PRJCALCSCHMSP%rowtype;
    NSCHEMASP_ART number;
    NRES          UDO_T_PRJSTG_ARTCL_PLAN_SP.SUMM%type := 0;
  begin
    begin
      select T.*
        into CALCSPREC
        from PRJCALCSCHMSP T
       where RN = NSCHEMASP;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NSCHEMASP
                                ,SUNIT_TABLE => 'PRJCALCSCHMSP');
    end;
    for CS in (select A.*
                 from PRJCALCSCHMART A
                where A.PRN = NSCHEMASP)
    loop
      if (IS_ART_DIRECT(NSCHEMA => NSCHEMA
                       ,NART    => CS.FPDARTCL))
      then
        NRES := NRES + GET_DIRECT_SUMM(NSTAGE    => NSTAGE
                                      ,NART      => CS.FPDARTCL
                                      ,NARTSCHRN => CS.RN
                                      ,NSIGN     => CS.SIGN
                                      ,NYEAR     => NYEAR
                                      ,NMONTH    => NMONTH
                                      ,SSTATE    => SSTATE);
      else
        begin
          select S.RN
            into NSCHEMASP_ART
            from PRJCALCSCHMSP S
           where S.PRN = NSCHEMA
             and S.FPDARTCL = CS.FPDARTCL;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0
                       ,'Неудалось определить схему калькуляции косвенной статьи затрат!');
        end;
        NRES := NRES + CALC_ART(NSTAGE    => NSTAGE
                               ,NSCHEMA   => NSCHEMA
                               ,NSCHEMASP => NSCHEMASP_ART
                               ,NYEAR     => NYEAR
                               ,NMONTH    => NMONTH
                               ,SSTATE    => SSTATE);
      end if;
    end loop;
    return NRES * CALCSPREC.PERCENT / 100;
  end;

begin
  --убедимся, что корректно указаны месяцы
  if (NMONTH is not null)
  then
    if (NMONTH not between 1 and 12)
    then
      P_EXCEPTION(0
                 ,'Некорректно указан месяц расчета (' || NMONTH || ')!');
    end if;
  end if;
  --указывать месяц можно только для пересчета по данным плана, но не для начального расчета
  if ((NINIT_CALC = 1) and (NMONTH is not null))
  then
    P_EXCEPTION(0
               ,'Нельзя указывать месяц для расчета по данным структуры цены!');
  end if;
  --считаем калькулируемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NPLAN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NPLAN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --считаем запись заказа
  begin
    select T.*
      into PRJREC
      from PROJECT T
     where T.RN = REC.PROJECT;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NPLAN
                              ,SUNIT_TABLE => 'PROJECT');
  end;
  --считаем запись этапа
  begin
    select T.*
      into STGREC
      from PROJECTSTAGE T
     where T.RN = REC.STAGE;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NPLAN
                              ,SUNIT_TABLE => 'PROJECTSTAGE');
  end;
  --считаем запись её периода
  begin
    select T.*
      into PRD
      from ENPERIOD T
     where T.RN = REC.PERIOD;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => REC.PERIOD
                              ,SUNIT_TABLE => 'ENPERIOD');
  end;
  --если нет схемы калькуляции - выходим
  if (REC.CALC_SCHEMA is null)
  then
    P_EXCEPTION(0
               ,'Для заказа/этапа "' || trim(PRJREC.CODE) || '/' ||
                trim(STGREC.NUMB) ||
                '" не указана схема калькуляции в разделе "Планы и отчеты по статьям" на ' ||
                EXTRACT(year from PRD.STARTDATE) || ' год!');
  end if;
  --считаем рег. номер состояния
  FIND_FINSTATE_CODE(NFLAG_SMART => 0
                    ,NCOMPANY    => REC.COMPANY
                    ,SCODE       => SSTATE
                    ,NRN         => NSTATE);
  --считаем схему калькуляции
  begin
    select T.*
      into CALCREC
      from PRJCALCSCHM T
     where T.RN = REC.CALC_SCHEMA;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => REC.CALC_SCHEMA
                              ,SUNIT_TABLE => 'PRJCALCSCHM');
  end;
  --считаем запись этапа
  begin
    select PS.*
      into STREC
      from PROJECTSTAGE PS
     where PS.RN = REC.STAGE;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => REC.STAGE
                              ,SUNIT_TABLE => 'PROJECTSTAGE');
  end;
  --подсчитаем количество месяцев этапа
  if ((STREC.BEGPLAN is not null) and (STREC.ENDPLAN is not null))
  then
    NCNTMONTHS := ROUND(MONTHS_BETWEEN(LAST_DAY(STREC.ENDPLAN)
                                      ,TO_DATE('01.' ||
                                               TO_CHAR(STREC.BEGPLAN
                                                      ,'mm.yyyy')
                                              ,'dd.mm.yyyy')));
  else
    P_EXCEPTION(0
               ,'Для этапа не указаны даты начала/окончания действия!');
  end if;
  --считаем суммы для первоначального прогона
  if (NINIT_CALC = 1)
  then
    --идем по статьям плана
    for A in (select CSP.RN NSCHEMASP
                    ,PSMN.PRJSTG_ARTCL NPRJSTG_ARTCL
                    ,ART.RN NART
                    ,ART.CODE SART
                    ,CSP.KIND NKIND
                    ,NVL(PS.SUMM
                        ,0) NPSSUMM
                from UDO_T_PRJSTG_ARTCL_PLAN_MN PSMN
                    ,UDO_T_PRJSTG_ARTCL         PA
                    ,UDO_T_PRICE_STRUCT         PS
                    ,FPDARTCL                   ART
                    ,PRJCALCSCHMSP              CSP
               where PSMN.PRN = REC.RN
                 and PSMN.PRJSTG_ARTCL = PA.RN
                 and PSMN.STATE = NSTATE
                 and PA.FPDARTCL = ART.RN
                 and CSP.PRN = CALCREC.RN
                 and CSP.FPDARTCL = ART.RN
                 and PA.RN = PS.PRJSTG_ARTCL(+)
                 and ((SART is null) or
                     ((SART is not null) and
                     (STRINLIKE(ART.CODE
                                 ,SART
                                 ,GET_OPTIONS_STR('SeqSymb')) > 0)))
               order by CSP.NUMB asc)
    loop
      --попробуем считать сумму из структуры цены
      if (A.NPSSUMM <> 0)
      then
        NARTSUMM := A.NPSSUMM;
      else
        --если её там нет, то расчитываем
        if (A.NKIND = 1)
        then
          --расчитаем сумму по статье, согласно схеме калькуляции
          NARTSUMM := CALC_ART_INIT(NSTAGE    => REC.STAGE
                                   ,NSCHEMA   => CALCREC.RN
                                   ,NSCHEMASP => A.NSCHEMASP);
        else
          --или возьмем напрямую, если нет
          NARTSUMM := GET_DIRECT_SUMM_INIT(NSTAGE => REC.STAGE
                                          ,NART   => A.NART
                                          ,NSIGN  => 0);
        end if;
      end if;
      --распределим сумму равномерно
      NSUMMS := UDO_TP_NUMTABLE();
      for I in 1 .. 12
      loop
        NSUMMS.EXTEND;
        --если месяц попадает в даты этапа - то даем ему часть суммы
        if (LAST_DAY(TO_DATE('01.' || LPAD(TO_CHAR(I)
                                          ,2
                                          ,'0') || '.' ||
                             TO_CHAR(EXTRACT(year from PRD.STARTDATE))
                            ,'dd.mm.yyyy')) between STREC.BEGPLAN and
           LAST_DAY(STREC.ENDPLAN))
        then
          NSUMMS(NSUMMS.LAST) := NVL(NARTSUMM / NCNTMONTHS
                                    ,0);
        else
          --если не попадает - не даем
          NSUMMS(NSUMMS.LAST) := 0;
        end if;
      end loop;
      --сформируем план
      UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN          => REC.RN
                                   ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                   ,NSTATE        => NSTATE
                                   ,NSUMMS        => NSUMMS
                                   ,NCHECK_LINKS  => NCHECK_LINKS);
      --если не указана контролирующая статья - укажем её
      if (REC.LIMITART is null)
      then
        begin
          select SA.RN
            into REC.LIMITART
            from UDO_T_PRJSTG_ARTCL SA
                ,FPDARTCL           A
           where SA.PRN = REC.STAGE
             and SA.FPDARTCL = A.RN
             and A.CODE = UDO_F_GET_CONST_VAL(REC.COMPANY
                                                     ,'СТАТЬЯ_ЦЕНА');
        exception
          when NO_DATA_FOUND then
            REC.LIMITART := null;
        end;
      end if;
      --если не указана сумма на год в плане - укажем то что получилось
      if (REC.SUMM = 0)
      then
        REC.SUMM := UDO_F_PRJSTG_ARTCL_PLAN_GET(NSTAGE        => REC.STAGE
                                               ,NPRJSTG_ARTCL => REC.LIMITART
                                               ,NMONTH        => null
                                               ,NYEAR         => EXTRACT(year from
                                                                         PRD.STARTDATE)
                                               ,SSTATE        => SSTATE);
      end if;
      --поместим изменения в таблицу
      UDO_P_PRJSTG_ARTCL_PLAN_B_UPD(NRN          => REC.RN
                                   ,NPROJECT     => REC.PROJECT
                                   ,NSTAGE       => REC.STAGE
                                   ,NPERIOD      => REC.PERIOD
                                   ,NCALC_SCHEMA => REC.CALC_SCHEMA
                                   ,NSUMM        => REC.SUMM
                                   ,NLIMITART    => REC.LIMITART);
    end loop;
    --перенесем остатки
    UDO_P_PRJSTG_ARTCL_PLAN_RSMOVE(NRN    => REC.RN
                                  ,SSTATE => SSTATE);
    --если это план за последний год этапа - спишем на последний месяц все копейки, оставшиеся от планирования
    if (EXTRACT(year from PRD.STARTDATE) = EXTRACT(year from STREC.ENDPLAN))
    then
      --идем по статьям
      for ARTS in (select PL.*
                     from UDO_T_PRJSTG_ARTCL_PLAN_MN PL
                         ,UDO_T_PRJSTG_ARTCL         PA
                         ,FPDARTCL                   ART
                    where PL.STATE = NSTATE
                      and PL.PRN = REC.RN
                      and PL.PRJSTG_ARTCL = PA.RN
                      and PA.FPDARTCL = ART.RN
                      and ((SART is null) or
                          ((SART is not null) and
                          (STRINLIKE(ART.CODE
                                      ,SART
                                      ,GET_OPTIONS_STR('SeqSymb')) > 0))))
      loop
        declare
          NSUMM_STG  UDO_T_PRICE_STRUCT.SUMM%type;
          NSUMM_REST UDO_T_PRJSTG_ARTCL_PLAN_RS.RESTE%type;
        begin
          --считываем сумму структуры цены по этой статье
          select NVL(PR.SUMM
                    ,0)
            into NSUMM_STG
            from UDO_T_PRICE_STRUCT PR
           where PR.PRN = REC.STAGE
             and PR.PRJSTG_ARTCL = ARTS.PRJSTG_ARTCL;
          --считываем остаток на конец по этой статье
          select NVL(R.RESTE
                    ,0)
            into NSUMM_REST
            from UDO_T_PRJSTG_ARTCL_PLAN_RS R
           where R.PRN = ARTS.PRN
             and R.PRJSTG_ARTCL = ARTS.PRJSTG_ARTCL
             and R.STATE = ARTS.STATE;
          --если не равны - выравниваем
          if (NSUMM_STG <> NSUMM_REST)
          then
            --выставим суммы (с изменениями в декабре)
            NSUMMS := UDO_TP_NUMTABLE();
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_1;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_2;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_3;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_4;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_5;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_6;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_7;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_8;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_9;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_10;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_11;
            NSUMMS.EXTEND;
            NSUMMS(NSUMMS.LAST) := ARTS.SUMM_12;
            for I in 1 .. 12
            loop
              if (I = EXTRACT(month from STREC.ENDPLAN))
              then
                NSUMMS(I) := NSUMMS(I) + (NSUMM_STG - NSUMM_REST);
              end if;
            end loop;
            --откорректируем план
            UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN          => REC.RN
                                         ,NPRJSTG_ARTCL => ARTS.PRJSTG_ARTCL
                                         ,NSTATE        => NSTATE
                                         ,NSUMMS        => NSUMMS
                                         ,NCHECK_LINKS  => NCHECK_LINKS);
          end if;
        exception
          when others then
            null;
        end;
      end loop;
    end if;
  end if;
  --считаем суммы для калькуляции по данным плана
  if (NINIT_CALC = 0)
  then
    --идем по статьям плана
    for A in (select CSP.RN NSCHEMASP
                    ,PSMN.PRJSTG_ARTCL NPRJSTG_ARTCL
                    ,ART.RN NART
                    ,ART.CODE SART
                    ,CSP.KIND NKIND
                    ,TO_NUMBER(TO_CHAR(EP.STARTDATE
                                      ,'yyyy')) NYEAR
                from UDO_T_PRJSTG_ARTCL_PLAN    P
                    ,UDO_T_PRJSTG_ARTCL_PLAN_MN PSMN
                    ,UDO_T_PRJSTG_ARTCL         PA
                    ,FPDARTCL                   ART
                    ,PRJCALCSCHMSP              CSP
                    ,ENPERIOD                   EP
               where P.RN = REC.RN
                 and PSMN.PRN = P.RN
                 and PSMN.PRJSTG_ARTCL = PA.RN
                 and PSMN.STATE = NSTATE
                 and PA.FPDARTCL = ART.RN
                 and CSP.PRN = CALCREC.RN
                 and CSP.FPDARTCL = ART.RN
                 and P.PERIOD = EP.RN
                 and ((SART is null) or
                     ((SART is not null) and
                     (STRINLIKE(ART.CODE
                                 ,SART
                                 ,GET_OPTIONS_STR('SeqSymb')) > 0)))
               order by CSP.NUMB asc)
    loop
      --подсчитаем суммы для каждого из месяцев
      NSUMMS := UDO_TP_NUMTABLE();
      for I in 1 .. 12
      loop
        --если месяц указан то считаем сумму только для него, если не указан - для всех
        if ((NMONTH is null) or ((NMONTH is not null) and (NMONTH = I)))
        then
          if (A.NKIND = 1)
          then
            --расчитаем сумму по статье, согласно схеме калькуляции
            NARTSUMM := CALC_ART(NSTAGE    => REC.STAGE
                                ,NSCHEMA   => CALCREC.RN
                                ,NSCHEMASP => A.NSCHEMASP
                                ,NYEAR     => A.NYEAR
                                ,NMONTH    => I
                                ,SSTATE    => SSTATE);
          else
            --или возьмем напрямую, если нет
            NARTSUMM := GET_DIRECT_SUMM(NSTAGE    => REC.STAGE
                                       ,NART      => A.NART
                                       ,NARTSCHRN => null
                                       ,NSIGN     => 0
                                       ,SSTATE    => SSTATE
                                       ,NYEAR     => A.NYEAR
                                       ,NMONTH    => I);
          end if;
        else
          --для остальных месяцев - просто считаем что уже и так было в разделе
          NARTSUMM := UDO_F_PRJSTG_ARTCL_PLAN_GET(NSTAGE        => REC.STAGE
                                                 ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                                 ,NMONTH        => I
                                                 ,NYEAR         => A.NYEAR
                                                 ,SSTATE        => SSTATE);
        end if;
        NSUMMS.EXTEND;
        NSUMMS(NSUMMS.LAST) := NVL(NARTSUMM
                                  ,0);
      end loop;
      --сформируем план
      UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN          => REC.RN
                                   ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                   ,NSTATE        => NSTATE
                                   ,NSUMMS        => NSUMMS
                                   ,NCHECK_LINKS  => NCHECK_LINKS);
      --перенесем остатки
      UDO_P_PRJSTG_ARTCL_PLAN_RSMOVE(NRN      => REC.RN
                                    ,SSTATE   => SSTATE
                                    ,NUSEBASE => 1);
    end loop;
  end if;
end;
/

