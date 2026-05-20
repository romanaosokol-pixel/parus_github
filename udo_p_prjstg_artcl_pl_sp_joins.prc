create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_JOINS
/*
   Разыменование ссылок в разделе "Планы и отчеты по статьям (спецификация)"
  */
(
  NCOMPANY      number   --рег. номер организации
 ,NPRN           number   --рег. номер этапа проекта
 ,SPRJSTG_ARTCL varchar2 --мнемокод статьи этапа заказа
 ,SPERIOD       varchar2 --мнемокод расчетного периода
 ,SSTATE        varchar2 --мнемокод состояния
 ,NPRJSTG_ARTCL out number --рег. номер статьи этапа заказа
 ,NPERIOD       out number --рег. номер расчетного периода
 ,NSTATE        out number --рег. номер состояния
) as
  SSTAGE varchar2(200); --код заказа/этапа
begin
  
  --считаем код проекта/этапа
  begin
    select trim(P.CODE) || '/' || trim(PS.NUMB)
      into SSTAGE
      from udo_t_prjstg_artcl_plan ppa
          ,PROJECT      P
          ,PROJECTSTAGE PS
     where ppa.rn = nprn
       AND ppa.project = p.rn
       and ppa.stage = PS.RN
       and Ppa.COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, NPRN, 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --найдем рег. номер статьи этапа проекта
  begin
    select pc.RN
      into NPRJSTG_ARTCL
      FROM udo_t_prjstg_artcl_plan ppa 
          --,UDO_T_PRJSTG_ARTCL T
          ,udo_prjstg_prstruct t
          ,udo_prjstg_prclc   pc
          ,FPDARTCL           A
     where ppa.rn = nprn
       AND ppa.calc_schema = t.rn
       AND t.rn = pc.prn
       and pc.cost_article = A.RN
       and A.CODE = SPRJSTG_ARTCL;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Статья этапа проекта "' || SSTAGE || '" с мнемокодом "' || SPRJSTG_ARTCL || '" не определена!');
  end;
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
  --найдем рег. номер состояния
  FIND_FINSTATE_CODE(NFLAG_SMART => 0
                    ,NCOMPANY    => NCOMPANY
                    ,SCODE       => SSTATE
                    ,NRN         => NSTATE);
end;
/

