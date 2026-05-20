create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_PLAN
/*
   Изменение помесячных планов в разделе "Планы и отчеты по статьям (спецификация)"
  */
(
  NPRN          number --рег. номер плана
 ,NPRJSTG_ARTCL number --рег. номер планируемой статьи
 ,NSTATE        number --рег. номер состояния
 ,NSUMMS        UDO_TP_NUMTABLE --суммы (коллекция из 12 чисел)
 ,NCHECK_LINKS  number --проверять связи (0 - нет, 1 - да)
) as
  NCOMPANY      COMPANIES.RN%type; --рег. номер организации
  NMNRN         UDO_T_PRJSTG_ARTCL_PLAN_MN.RN%type; --рег. номер планируемой записи
  NSPRN         UDO_T_PRJSTG_ARTCL_PLAN_SP.RN%type; --рег. номер спецификации
  SPRJSTG_ARTCL FPDARTCL.CODE%type; --мнемокод статьи
  SSTATE        FINSTATE.CODE%type; --мнемокод состояния
  SPERIOD       ENPERIOD.CODE%type; --мнемокод учетного периода
  NSUMM         UDO_T_PRJSTG_ARTCL_PLAN_SP.SUMM%type; --текущая сумма по спецификации
  SCHECKUNIT    UNITLIST.UNITCODE%type; --код постатейного раздела
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
  --найдем запись помесячного плана
  begin
    select T.RN
      into NMNRN
      from UDO_T_PRJSTG_ARTCL_PLAN_MN T
     where T.PRN = NPRN
       and T.PRJSTG_ARTCL = NPRJSTG_ARTCL
       and T.STATE = NSTATE;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Неудалось определить планируемую запись!');
  end;
  --идем по массиву сумм
  for I in 1 .. 12
  loop
    --определим расчетный период, статью, состояние и исправляемую запись спецификации плана
    begin
      select P.COMPANY, T.RN, P.CODE, FDA.CODE, FS.CODE, T.SUMM
        into NCOMPANY, NSPRN, SPERIOD, SPRJSTG_ARTCL, SSTATE, NSUMM
        from UDO_T_PRJSTG_ARTCL_PLAN_SP T
            --,UDO_T_PRJSTG_ARTCL         A
            ,udo_prjstg_prclc a
            ,FPDARTCL                   FDA
            ,ENPERIOD                   P
            ,FINSTATE                   FS
       where T.PRN = NPRN
         and T.PRJSTG_ARTCL = NPRJSTG_ARTCL
         and T.STATE = NSTATE
         and T.PERIOD = P.RN
         and T.PRJSTG_ARTCL = A.RN
         and A.COST_ARTICLE = FDA.RN
         and T.STATE = FS.RN
         and (P.MAIN_SIGN = 1 or P.PER_TYPE <> 4)              --- EZST 
         and TO_NUMBER(TO_CHAR(P.STARTDATE, 'mm')) = I;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Неопределена запись спецификации с данным типом, статьей, состоянием и периодом!');
    end;
    --проверим связи по входам и выходам
    if (NCHECK_LINKS = 1)
    then
      if (SSTATE = UDO_F_GET_CONST_VAL(NCOMPANY, 'СОСТ_ПЛАН'))
      then
        SCHECKUNIT := 'PrjArtclsPlanRepsMnP';
      else
        SCHECKUNIT := 'PrjArtclsPlanRepsMnF';
      end if;
      PKG_DOCLINKS_SMART.HARD_CHECK(NCOMPANY, SCHECKUNIT, NMNRN);
    end if;
    --исправим данные плана, если они изменились
    if (NSUMMS(I) <> NSUMM)
    then
      --исправление спецификации
      UDO_P_PRJSTG_ARTCL_PL_SP_UPD(NRN           => NSPRN
                                  ,SPRJSTG_ARTCL => SPRJSTG_ARTCL
                                  ,SPERIOD       => SPERIOD
                                  ,SSTATE        => SSTATE
                                  ,NSUMM         => NSUMMS(I)
                                  ,DACT_FROM     => sysdate
                                  ,NCHECK_LINKS  => NCHECK_LINKS);
    end if;
  end loop;
end;
/

