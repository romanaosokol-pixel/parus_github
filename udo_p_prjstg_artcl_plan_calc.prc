create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_CALC
/*
   Калькуляция этапа заказа в указанном году
   Чечнев М.С.
  */
(
  NPLAN        number    -- рег. номер плана
 ,SSTATE       varchar2  -- мнемокод состояния пересчитываемых данных
 ,NINIT_CALC   number    -- режим работы (1 - начальная инициализация по данным статей заказа, 0 - расчет по даннм плана)
 ,NCHECK_LINKS number    -- проверять связи (0 - нет, 1 - да)
 ,NMONTH       number    -- номер месяца для пересчета (null для всех)
 ,SART         varchar2  -- расчитываемая статья (null для всех, можно чере разделитель SeqSymb)
 ,nusedep      NUMBER    -- использовать зависимости статей 
)
as
  RPLAN      UDO_T_PRJSTG_ARTCL_PLAN%rowtype; -- запись плана
  RPRJ       PROJECT%rowtype;                 -- запись заказа
  RSTG       PROJECTSTAGE%rowtype;            -- запись этапа
  PRD        ENPERIOD%rowtype;                -- запись расчетного периода плана
  CALCREC    PRJCALCSCHM%rowtype;             -- запись схемы калькуляции
  NARTSUMM   UDO_T_PRICE_STRUCT.SUMM%type;    -- расчитанная сумма по статье
  STREC      PROJECTSTAGE%rowtype;            -- запись инициализируемого этапа
  NCNTMONTHS number(17);                      -- количество месяцев этапа
  NSTATE     FINSTATE.RN%type;                -- рег. номер состояния
  NSUMMS     UDO_TP_NUMTABLE;                 -- массив для хранения значений расчитанных сумм
  nint_summ  NUMBER(17,2);
  
  --функция считывания значения прямой статьи (для калькуляции по данным помесячного плана)
  function GET_DIRECT_SUMM
  (
    NSTAGE         number
   ,nprjstg_artcl  number
   ,NSIGN          number
   ,NYEAR          number
   ,NMONTH         number
   ,SSTATE         varchar2
  ) return number 
  is
    NRES UDO_T_PRJSTG_ARTCL_PLAN_SP.SUMM%type := 0;
  begin
    select DECODE(NSIGN, 0, NVL(SP.SUMM, 0), NVL(-SP.SUMM, 0) )
      into NRES
      from UDO_T_PRJSTG_ARTCL_PLAN    P
          ,ENPERIOD                   EP
          ,UDO_T_PRJSTG_ARTCL_PLAN_SP SP
          ,FINSTATE                   FS
          ,ENPERIOD                   EPS
          /*,UDO_T_PRJSTG_ARTCL         SA*/
          /*,FPDARTCL                   FA*/
     where P.STAGE = NSTAGE
       and P.PERIOD = EP.RN and EXTRACT(year from EP.STARTDATE) = NYEAR
       and SP.PRN = P.RN
       and SP.STATE = FS.RN and FS.CODE = SSTATE
       and SP.PERIOD = EPS.RN and EXTRACT(year from EPS.STARTDATE) = NYEAR and EXTRACT(month from EPS.STARTDATE) = NMONTH
       AND sp.prjstg_artcl = nprjstg_artcl
       /*and SA.RN = SP.PRJSTG_ARTCL
       and SA.FPDARTCL = FA.RN
       and FA.RN = NART*/;
    return NRES;
  exception
    when others then
      return NRES;
  end;

  --функция расчета статьи согласно схеме (для калькуляции по данным плана)
  function CALC_ART
  (
    NSTAGE    number
   ,nprjstg_artcl number
   ,NYEAR     number
   ,NMONTH    number
   ,SSTATE    VARCHAR2
   ,nuse_dep  NUMBER DEFAULT 0
  ) return number
  is
    CALCSPREC     PRJCALCSCHMSP%rowtype;
    rpsa          udo_prjstg_prclc%ROWTYPE;
    NSCHEMASP_ART number;
    NRES          NUMBER := 0;
    nsumm         NUMBER := 0;
    ncoeff        NUMBER := 0;
  begin
    
    BEGIN
      SELECT t.*
        INTO rpsa
        FROM udo_prjstg_prclc t
       WHERE t.rn = nprjstg_artcl;
    EXCEPTION
      WHEN no_data_found
        THEN pkg_msg.record_not_found( 0, nprjstg_artcl, 'UDO_PRJSTG_PRCLC');
    END;
    
    for CS in (
               SELECT psai.sign, psai.percent, psai.prn_percent, psa.rn, pss.kind
                 FROM udo_prjstg_prclc_art psai,
                      udo_prjstg_prstruct ps
                      JOIN udo_prjstg_prclc psa ON ps.rn = psa.prn
                      JOIN prjcalcschmsp pss ON ps.calcschm = pss.prn
                WHERE psai.prn = rpsa.rn /*510362*/ AND
                      ps.rn    = rpsa.prn/*510356*/ AND
                      psa.cost_article = psai.fpdartcl AND
                      psai.fpdartcl = pss.fpdartcl
                ORDER BY psa.numb
               )
    loop
      CASE nuse_dep
        WHEN 0 THEN  ncoeff := 1;
        ELSE ncoeff := cs.percent * cs.prn_percent/10000;
      END CASE;
      nsumm := GET_DIRECT_SUMM(NSTAGE        => NSTAGE
                              ,nprjstg_artcl => CS.RN
                              ,NSIGN         => CS.SIGN
                              ,NYEAR         => NYEAR
                              ,NMONTH        => NMONTH
                              ,SSTATE        => SSTATE)* ncoeff; 
      NRES  := NRES + nsumm;
      nsumm := 0;
    end loop;
    return NRES /** CALCSPREC.PERCENT / 100*/;
  end CALC_ART;

begin
  --убедимся, что корректно указаны месяцы
  if (NMONTH is not null)
  then
    if (NMONTH not between 1 and 12)
    then
      P_EXCEPTION(0 ,'Некорректно указан месяц расчета (' || NMONTH || ')!');
    end if;
  end if;
  --указывать месяц можно только для пересчета по данным плана, но не для начального расчета
  if ((NINIT_CALC = 1) and (NMONTH is not null))
  then
    P_EXCEPTION(0 ,'Нельзя указывать месяц для расчета по данным структуры цены!');
  end if;
  --считаем калькулируемую запись
  begin
    select T.*
      into RPLAN
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NPLAN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( 0, NPLAN, 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --считаем запись заказа
  begin
    select T.*
      into RPRJ
      from PROJECT T
     where T.RN = RPLAN.PROJECT;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( 0, NPLAN, 'PROJECT');
  end;
  --считаем запись этапа
  begin
    select T.*
      into RSTG
      from PROJECTSTAGE T
     where T.RN = RPLAN.STAGE;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( 0, NPLAN, 'PROJECTSTAGE');
  end;
  --считаем запись её периода
  begin
    select T.*
      into PRD
      from ENPERIOD T
     where T.RN = RPLAN.PERIOD;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( 0, RPLAN.PERIOD, 'ENPERIOD' );
  end;
  --если нет схемы калькуляции - выходим
  if (RPLAN.CALC_SCHEMA is null)
  then
    P_EXCEPTION(0, 'Для заказа/этапа "' || trim(RPRJ.CODE) || '/' || trim(RSTG.NUMB) ||
                   '" не указана схема калькуляции в разделе "Планы и отчеты по статьям" на ' ||
                   EXTRACT(year from PRD.STARTDATE) || ' год!');
  end if;
  --считаем рег. номер состояния
  FIND_FINSTATE_CODE( 0, RPLAN.COMPANY, SSTATE, NSTATE);

  --считаем запись этапа
  begin
    select PS.*
      into STREC
      from PROJECTSTAGE PS
     where PS.RN = RPLAN.STAGE;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, RPLAN.STAGE, 'PROJECTSTAGE');
  end;
  --подсчитаем количество месяцев этапа
  if ((STREC.BEGPLAN is not null) and (STREC.ENDPLAN is not null))
  then
    NCNTMONTHS := ROUND( MONTHS_BETWEEN(LAST_DAY(STREC.ENDPLAN), TO_DATE('01.' || TO_CHAR(STREC.BEGPLAN, 'mm.yyyy'), 'dd.mm.yyyy')) );
  else
    P_EXCEPTION(0, 'Для этапа не указаны даты начала/окончания действия!');
  end if;
  --считаем суммы для первоначального прогона
  if (NINIT_CALC = 1)
  then
    --идем по статьям плана
    for A in (select CSP.RN              NSCHEMASP
                    ,PSMN.PRJSTG_ARTCL   NPRJSTG_ARTCL
                    ,ART.RN NART
                    ,ART.CODE SART
                    ,CSP.KIND NKIND
                    ,NVL(Pa.Cost_Sum, 0) NPSSUMM
                from UDO_T_PRJSTG_ARTCL_PLAN_MN PSMN
                    --,UDO_T_PRJSTG_ARTCL         PA
                    ,udo_prjstg_prclc           pa
                    --,UDO_T_PRICE_STRUCT         PS
                    ,udo_prjstg_prstruct        ps
                    ,FPDARTCL                   ART
                    ,PRJCALCSCHMSP              CSP
               where PSMN.PRN          = RPLAN.RN
                 and PSMN.STATE        = NSTATE
                 and PSMN.PRJSTG_ARTCL = PA.RN
                 and PA.COST_ARTICLE   = ART.RN
                 AND pa.prn            = ps.rn
                 and CSP.PRN           = ps.calcschm/*CALCREC.RN*/
                 and CSP.FPDARTCL      = PA.COST_ARTICLE
                 --and PA.RN = PS.PRJSTG_ARTCL(+)
                 and ( (SART is null) or
                       ( (SART is not null) and (STRINLIKE(ART.CODE, SART, GET_OPTIONS_STR('SeqSymb')) > 0) ) 
                     )
               order by pa.NUMB asc)
    loop
      NARTSUMM := A.NPSSUMM;
      --распределим сумму равномерно
      NSUMMS := UDO_TP_NUMTABLE();
      for i in 1 .. 12
      loop
        NSUMMS.EXTEND;
        --если месяц попадает в даты этапа - то даем ему часть суммы
        if (LAST_DAY(TO_DATE('01.' || LPAD(TO_CHAR(I), 2, '0') || '.' || TO_CHAR(EXTRACT(year from PRD.STARTDATE)), 'dd.mm.yyyy'))
            between STREC.BEGPLAN and LAST_DAY(STREC.ENDPLAN))
        then
          NSUMMS(i) := round(NVL(NARTSUMM / NCNTMONTHS, 0), 2);
          nint_summ := nvl(nint_summ, 0) +  NSUMMS(i);
          if (i = EXTRACT(month from STREC.ENDPLAN))
          then
            NSUMMS(i) := NSUMMS(i) + (NARTSUMM - nint_summ);
          end if;
          
        else
          --если не попадает - не даем
          NSUMMS(i) := 0;
        end if;              
      end loop;
      nint_summ := 0;
      --сформируем план
      UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN          => RPLAN.RN
                                   ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                   ,NSTATE        => NSTATE
                                   ,NSUMMS        => NSUMMS
                                   ,NCHECK_LINKS  => NCHECK_LINKS);
      --если не указана контролирующая статья - укажем её
      if (RPLAN.LIMITART is null)
      then
        begin
          select SA.RN
            into RPLAN.LIMITART
            from --UDO_T_PRJSTG_ARTCL SA
                 udo_prjstg_prclc sa
                ,FPDARTCL           A
           where SA.PRN = RPLAN.CALC_SCHEMA
             and SA.COST_ARTICLE = A.RN
             and A.CODE = UDO_F_SYS0006_GET_CONST_VAL(RPLAN.COMPANY, 'СТАТЬЯ_ЦЕНА');
        exception
          when NO_DATA_FOUND then
            RPLAN.LIMITART := null;
        end;
      end if;
      --если не указана сумма на год в плане - укажем то что получилось
      if (RPLAN.SUMM = 0)
      then
        RPLAN.SUMM := UDO_F_PRJSTG_ARTCL_PLAN_GET(NSTAGE        => RPLAN.STAGE
                                               ,NPRJSTG_ARTCL => RPLAN.LIMITART
                                               ,NMONTH        => null
                                               ,NYEAR         => EXTRACT(year FROM PRD.STARTDATE)
                                               ,SSTATE        => SSTATE);
      end if;
      --поместим изменения в таблицу
      UDO_P_PRJSTG_ARTCL_PLAN_B_UPD(NRN          => RPLAN.RN
                                   ,NPROJECT     => RPLAN.PROJECT
                                   ,NSTAGE       => RPLAN.STAGE
                                   ,NPERIOD      => RPLAN.PERIOD
                                   ,NCALC_SCHEMA => RPLAN.CALC_SCHEMA
                                   ,NSUMM        => RPLAN.SUMM
                                   ,NLIMITART    => RPLAN.LIMITART);
    end loop;
    --перенесем остатки
    UDO_P_PRJSTG_ARTCL_PLAN_RSMOVE(RPLAN.RN, SSTATE, NULL, NULL);
    --если это план за последний год этапа - спишем на последний месяц все копейки, оставшиеся от планирования
    if (EXTRACT(year from PRD.STARTDATE) = EXTRACT(year from STREC.ENDPLAN))
    then
      --идем по статьям
      for ARTS in (select PL.*, pa.cost_sum NSUMM_STG
                     from UDO_T_PRJSTG_ARTCL_PLAN_MN PL
                         --,UDO_T_PRJSTG_ARTCL         PA
                         ,udo_prjstg_prclc           pa
                         ,FPDARTCL                   ART
                    where PL.PRN = RPLAN.RN
                      and PL.STATE = NSTATE
                      and PL.PRJSTG_ARTCL = PA.RN
                      and PA.COST_ARTICLE = ART.RN
                      and ( (SART is null) or
                            ((SART is not null) AND (STRINLIKE(ART.CODE, SART, GET_OPTIONS_STR('SeqSymb')) > 0)))
                          )
      loop
        declare
          NSUMM_STG  UDO_T_PRICE_STRUCT.SUMM%type;
          NSUMM_REST UDO_T_PRJSTG_ARTCL_PLAN_RS.RESTE%type;
        begin
          --считываем сумму структуры цены по этой статье
          /*select NVL(PR.SUMM, 0)
            into NSUMM_STG
            from UDO_T_PRICE_STRUCT PR
           where PR.PRN = RPLAN.STAGE
             and PR.PRJSTG_ARTCL = ARTS.PRJSTG_ARTCL;*/
          NSUMM_STG := arts.nsumm_stg;
          --считываем остаток на конец по этой статье
          select NVL(R.RESTE, 0)
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
            UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN          => RPLAN.RN
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
                    --,ART.RN NART
                    ,ART.CODE SART
                    ,CSP.KIND NKIND
                    ,TO_NUMBER(TO_CHAR(EP.STARTDATE, 'yyyy')) NYEAR
                from UDO_T_PRJSTG_ARTCL_PLAN    P
                    ,ENPERIOD                   EP
                    ,UDO_T_PRJSTG_ARTCL_PLAN_MN PSMN
                    --,UDO_T_PRJSTG_ARTCL         PA
                    ,udo_prjstg_prclc           pa
                    ,udo_prjstg_prstruct        ps
                    ,FPDARTCL                   ART
                    ,PRJCALCSCHMSP              CSP
               where P.RN              = RPLAN.RN
                 and P.PERIOD          = EP.RN
                 and PSMN.PRN          = P.RN
                 and PSMN.STATE        = NSTATE
                 and PSMN.PRJSTG_ARTCL = PA.RN
                 and PA.COST_ARTICLE   = ART.RN
                 AND pa.prn            = ps.rn
                 and CSP.PRN           = ps.calcschm/*CALCREC.RN*/
                 and CSP.FPDARTCL      = PA.COST_ARTICLE 
                 and ( (SART is null) or
                       ((SART is not null) AND (STRINLIKE(ART.CODE, SART, GET_OPTIONS_STR('SeqSymb')) > 0)) )
               order by CSP.NUMB asc )
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
            NARTSUMM := CALC_ART(NSTAGE    => RPLAN.STAGE
                                --,NSCHEMA   => CALCREC.RN
                                ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                ,NYEAR     => A.NYEAR
                                ,NMONTH    => I
                                ,SSTATE    => SSTATE
                                ,nuse_dep  => nusedep);
          else
            --или возьмем напрямую, если нет
            NARTSUMM := GET_DIRECT_SUMM(NSTAGE    => RPLAN.STAGE
                                       ,NPRJSTG_ARTCL      => A.NPRJSTG_ARTCL
                                       ,NSIGN     => 0
                                       ,SSTATE    => SSTATE
                                       ,NYEAR     => A.NYEAR
                                       ,NMONTH    => I);
          end if;
        else
          --для остальных месяцев - просто считаем что уже и так было в разделе
          NARTSUMM := UDO_F_PRJSTG_ARTCL_PLAN_GET(NSTAGE        => RPLAN.STAGE
                                                 ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                                 ,NMONTH        => I
                                                 ,NYEAR         => A.NYEAR
                                                 ,SSTATE        => SSTATE);
        end if;
        NSUMMS.EXTEND;
        NSUMMS(NSUMMS.LAST) := NVL(NARTSUMM, 0);
      end loop;
      --сформируем план
      UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN          => RPLAN.RN
                                   ,NPRJSTG_ARTCL => A.NPRJSTG_ARTCL
                                   ,NSTATE        => NSTATE
                                   ,NSUMMS        => NSUMMS
                                   ,NCHECK_LINKS  => NCHECK_LINKS);
      --перенесем остатки
      UDO_P_PRJSTG_ARTCL_PLAN_RSMOVE(NRN      => RPLAN.RN
                                    ,SSTATE   => SSTATE
                                    ,NUSEBASE => 1);
    end loop;
  end if;
end UDO_P_PRJSTG_ARTCL_PLAN_CALC;
/*
   create public synonym UDO_P_PP119_2_CALC_PLAN for UDO_P_PP119_2_CALC_PLAN;
   grant execute on UDO_P_PP119_2_CALC_PLAN to public;
  */
/

