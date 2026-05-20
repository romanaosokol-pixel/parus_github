create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_JOINS
/*
   Разыменование ссылок в разделе "Планы и отчеты по статьям"
  */
(
  NCOMPANY     number --рег. номер организации
 ,SPROJECT     varchar2 --мнемокод проекта
 ,SSTAGE       varchar2 --номер этапа проекта
 ,SPERIOD      varchar2 --мнемокод расчетного периода (год)
 ,SCALC_SCHEMA varchar2 --мнемокод схемы калькуляции
 ,SLIMITART    varchar2 --контрольная статья
 ,NPROJECT     out number --рег. номер проекта
 ,NSTAGE       out number --рег. номер этапа проекта
 ,NPERIOD      out number --рег. номер расчетного периода
 ,NCALC_SCHEMA out number --рег. номер схемы калькуляции
 ,NLIMITART    out number --рег. номер контрольной статьи
) as
  NSTATE PROJECTSTAGE.STATE%type; --состояние этапа
begin
  --найлем рег. номер проекта
  begin
    select P.RN
      into NPROJECT
      from PROJECT P
     where P.COMPANY = NCOMPANY
       and trim(P.CODE) = trim(SPROJECT);
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Запись проекта "' || SPROJECT || '" не определена!');
  end;
  
  --найдем рег. номер этапа
  begin
    select PS.RN
          ,PS.STATE
      into NSTAGE
          ,NSTATE
      from PROJECTSTAGE PS
     where PS.PRN = NPROJECT
       and trim(PS.NUMB) = trim(SSTAGE);
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Запись этапа "' || SSTAGE || '" проекта "' || SPROJECT || '" не определена!');
  end;
  if (NSTATE not in (0, 1, 2, 3))
  then
    P_EXCEPTION(0, 'Этап "' || SSTAGE || '" проекта "' || SPROJECT ||'" списан или закрыт!');
  end if;
  
  --найдем рег. номер раcчетного периода
  begin
    select T.RN
      into NPERIOD
      from ENPERIOD T
     where T.COMPANY = NCOMPANY
       and T.CODE = SPERIOD;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Запись расчетного периода с мнемокодом "' || SPERIOD || '" не определена!');
  end;
  
  --найдем рег. номер схемы калькуляции
  BEGIN
    SELECT sps.rn
      INTO NCALC_SCHEMA
      FROM project p
           JOIN projectstage ps ON p.rn = ps.prn AND
                                   ps.rn = NSTAGE
                JOIN udo_prjstg_prstruct sps ON ps.rn = sps.prn
                     JOIN finstate pk ON sps.price_kind = pk.rn AND
                                         pk.code = SCALC_SCHEMA
     WHERE p.rn = NPROJECT;
  EXCEPTION
    WHEN no_data_found
      THEN p_exception(0, 'Для этапа "' || SSTAGE || '" проекта "' || SPROJECT || '" структура цены "' || SCALC_SCHEMA || '" не найдена!');
  END;
  /*FIND_PRJCALCSCHM_CODE(NFLAG_SMART  => 0
                       ,NFLAG_OPTION => 1
                       ,NCOMPANY     => NCOMPANY
                       ,SCODE        => SCALC_SCHEMA
                       ,NRN          => NCALC_SCHEMA);*/
  
  --найдем рег. номер контрольной статьи
  if (SLIMITART is not null)
  then
    /*begin
      select SA.RN
        into NLIMITART
        from UDO_T_PRJSTG_ARTCL SA
            ,FPDARTCL           A
       where SA.PRN = NSTAGE
         and SA.FPDARTCL = A.RN
         and A.CODE = SLIMITART;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0
                   ,'Для указанного  этапа "' || SSTAGE || '" проекта "' ||
                    SPROJECT || '" статья "' || SLIMITART ||
                    '" не определена!');
    end;*/
    
    BEGIN
      SELECT spsa.rn
        INTO NLIMITART
        FROM project p
             JOIN projectstage ps ON p.rn = ps.prn AND
                                     ps.rn = NSTAGE
                  JOIN udo_prjstg_prstruct sps ON ps.rn = sps.prn AND
                                                  sps.rn = NCALC_SCHEMA
                       JOIN udo_prjstg_prclc spsa ON sps.rn = spsa.prn
                            JOIN fpdartcl fpda ON spsa.cost_article = fpda.rn AND
                                                  fpda.code = SLIMITART
       WHERE p.rn = NPROJECT;
    EXCEPTION
      WHEN no_data_found
        THEN p_exception(0, 'Для этапа "' || SSTAGE || '" проекта "' || SPROJECT || '" структуры цены "' || SCALC_SCHEMA || '" статья "'||SLIMITART||'" не найдена!');
    END;
    
  else
    NLIMITART := null;
  end if;
end;
/

