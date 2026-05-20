create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_CREATE
/*
   Формирование плана по статьям в разделе "Планы и отчеты по статьям"
   для указаного этапа проекта
  */
(
  NCRN     number --рег. номер каталога
 ,NCOMPANY number --рег. номер организации
 ,SPROJECT varchar2 --код проекта
 ,SSTAGE   varchar2 --код этапа проекта
) as
  type PLANS is table of number(17); --тип для хранения рег. номеров сформированных планов
  SENPCAT_CONST CONSTLST.NAME%type := 'КАТ_РАСЧ_ПЕРИОДОВ'; --констата с наименованием каталога расчетных периодов
  NENPCAT       ACATALOG.RN%type; --рег. номер каталога для расчетных периодов
  PL            PLANS := PLANS(); --коллекция рег. номеров сформированных планов
  STREC         PROJECTSTAGE%rowtype; --запись инициализируемого этапа
  NCRN_         number := NCRN; --рег. номер каталога
  NPERIODCNT    number; --количество периодов системы, найденных для данного проекта
  NYEARCNT      number; --количество лет этапа
  
  scalcschm     VARCHAR2(20);
  
  --проверка наличия планов
  function PLAN_EXISTS
  (
    NPROJECT number
   ,NSTAGE   number
   ,NPERIOD  number
  )return BOOLEAN
  is
    NTMP number;
    BRES boolean := false;
  begin
    begin
      select P.RN
        into NTMP
        from UDO_T_PRJSTG_ARTCL_PLAN P
       where P.PROJECT = NPROJECT
         and P.STAGE = NSTAGE
         and P.PERIOD = NPERIOD;
      BRES := true;
    exception
      when NO_DATA_FOUND then
        BRES := false;
    end;
    return BRES;
  end;

begin
  --считаем запись этапа
  begin
    select PS.*
      into STREC
      from PROJECT      P
          ,PROJECTSTAGE PS
     where P.COMPANY = NCOMPANY
       and trim(P.CODE) = trim(SPROJECT)
       and P.RN = PS.PRN
       and trim(PS.NUMB) = trim(SSTAGE);
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Запись этапа "' || SSTAGE || '" проекта "' || SPROJECT ||'" не определена!');
  end;
  --определим каталог расчетных периодов
  if (UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY, SENPCAT_CONST) is null)
  then
    P_EXCEPTION(0, 'Неуказано название каталога для расчетных периодов (константа "' ||SENPCAT_CONST || '")!');
  end if;
  FIND_ACATALOG_NAME(0, NCOMPANY, null, 'ENCalcPeriods', UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY, SENPCAT_CONST), NENPCAT);
  --выставим каталог
  NCRN_ := NVL(NCRN_, UDO_F_SYSP0014_CRN_BY_PRJTYPE( NCOMPANY, 'PrjArtclsPlanReps', SUBSTR(SPROJECT, 1 ,2)));
  --проверим, что есть расчетные периоды для этого этапа
  select count(P.RN)
    into NPERIODCNT
    from ENPERIOD P
   where EXTRACT(year from P.STARTDATE) between
         EXTRACT(year from STREC.BEGPLAN) - 1 and
         EXTRACT(year from STREC.ENDPLAN)
     and P.PERTYPE = 3
     and P.COMPANY = NCOMPANY
     and P.CRN in (select T.RN
                     from ACATALOG T
                   connect by prior T.RN = T.CRN
                    start with T.RN = NENPCAT);
  NYEARCNT := (TO_NUMBER(TO_CHAR(STREC.ENDPLAN, 'yyyy'))) - TO_NUMBER(TO_CHAR(STREC.BEGPLAN ,'yyyy')) + 2;
  
  if (NPERIODCNT <> NYEARCNT)
  then
    P_EXCEPTION(0, 'В системе отсуствуют отчетные периоды для данного этапа!' || NPERIODCNT || ':' || NYEARCNT);
  end if;
  
  -- схема калькуляции
  BEGIN
    SELECT fs.code
      INTO scalcschm
      FROM udo_prjstg_prstruct prs
           JOIN finstate fs ON prs.price_kind = fs.rn
     WHERE prs.prn = strec.rn
       AND prs.sign_act = 1;
  EXCEPTION
    WHEN no_data_found
      THEN p_exception(0, 'Для этапа "%s" проекта "%s" не найдена действующая цена этапа ', SSTAGE, SPROJECT);
  END;
  
  --построим список расчетных периодов
  for PRD in (select P.*
                from ENPERIOD P
               where EXTRACT(year from P.STARTDATE) between
                     EXTRACT(year from STREC.BEGPLAN) - 1 and
                     EXTRACT(year from STREC.ENDPLAN)
                 and P.PERTYPE = 3
                 and P.COMPANY = NCOMPANY
                 and P.CRN in (select T.RN
                                 from ACATALOG T
                               connect by prior T.RN = T.CRN
                                start with T.RN = NENPCAT)
               )
  loop
    --если такого плана ещё нет, то добавим его
    if (not (PLAN_EXISTS(STREC.PRN, STREC.RN, PRD.RN)))
    then
      PL.EXTEND;
      UDO_P_PRJSTG_ARTCL_PLAN_INS(NCRN         => NCRN_
                                 ,NCOMPANY     => NCOMPANY
                                 ,SPROJECT     => SPROJECT
                                 ,SSTAGE       => SSTAGE
                                 ,SPERIOD      => PRD.CODE
                                 ,SCALC_SCHEMA => scalcschm
                                 ,NSUMM        => 0
                                 ,SLIMITART    => null
                                 ,NRN          => PL(PL.LAST));
    end if;
  end loop;
  --пройдем по созданным планам и инициализируем их
  if (PL.COUNT > 0)
  then
    for I in PL.FIRST .. PL.LAST
    loop
      --сформируем статьи
      UDO_P_PRJSTG_ARTCL_PLAN_INIT(PL(I), 1);
      --установим лимитирующую статью, если такая есть среди полученных
      for C in (select T.RN
                  from UDO_T_PRJSTG_ARTCL T
                      ,FPDARTCL           A
                 where T.PRN = STREC.RN
                   and T.FPDARTCL = A.RN
                   and A.CODE = UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY, 'СТАТЬЯ_ЦЕНА'))
      loop
        update UDO_T_PRJSTG_ARTCL_PLAN T
           set T.LIMITART = C.RN
         where T.RN = PL(I);
      end loop;
    end loop;
  end if;
end UDO_P_PRJSTG_ARTCL_PLAN_CREATE;
/*
   create public synonym UDO_P_PRJSTG_ARTCL_PLAN_CREATE for UDO_P_PRJSTG_ARTCL_PLAN_CREATE;
   grant execute on UDO_P_PRJSTG_ARTCL_PLAN_CREATE to public;
  */
/

