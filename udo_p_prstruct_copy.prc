create or replace procedure UDO_P_PRSTRUCT_COPY
(
NIDENT in number -- идентификатор помеченных хаписей (RN Этапа договора)
) is

--- Копирование в структуры цены из проекта в договор
nOUTRN     number;
nOutCALC   number;
begin
  for ss in (
    select PST.*
          ,st.rn nStage_RN
          ,PS.NAME as sPRJ_NAME
          ,ST.DESCRIPTION as sSTG_DESCR
          ,ps.cost_sum
          ,st.sum_type
    from UDO_PRJSTG_PRSTRUCT  PST
        ,PROJECTSTAGE         PS
        ,STAGES               ST
        ,SELECTLIST           SL
    where SL.IDENT = NIDENT
      and ST.RN = SL.DOCUMENT
      and PS.Faceacccust = ST.FACEACC
      and PST.PRN = PS.RN
      and PST.SIGN_ACT = 1
  ) loop
    begin
      select cnt.rn
        into nOUTRN
        from contrprstruct cnt
       where cnt.prn      = ss.nStage_RN
         and cnt.calcschm   = ss.calcschm
         and cnt.price_kind = ss.price_kind 
         and cnt.date_from  = ss.date_from;
    exception when others then
      nOUTRN := null;
    end;
   -- P_exception(0,'!!! '||ss.nStage_RN);
    if nOUTRN is null then
      p_contrprstruct_base_insert(
        nCOMPANY        => ss.company,            -- Организация
        nPRN            => ss.nStage_RN,          -- Родитель
        nPRICE_KIND     => ss.price_kind,         -- Вид цены
        nCALCSCHM       => ss.calcschm,           -- Схема калькуляции
        dDATE_FROM      => ss.date_from,          -- Действует с
        dDATE_TO        => ss.date_to,            -- Действует по
        nSUMM           => ss.summ,               -- Сумма
        nSUMM_BASE      => ss.summ_base,          -- Сумма в базовой валюте
        nCALC_INDIR     => 0,                     -- Расчет косвенных затрат
        nRN             => nOUTRN                 -- Регистрационный номер    
      );
    else
      p_contrprstruct_base_update(
        nRN             => nOUTRN,                -- Регистрационный номер    
        nCOMPANY        => ss.company,            -- Организация
        nPRICE_KIND     => ss.price_kind,         -- Вид цены
        nCALCSCHM       => ss.calcschm,           -- Схема калькуляции
        dDATE_FROM      => ss.date_from,          -- Действует с
        dDATE_TO        => ss.date_to,            -- Действует по
        nCALC_INDIR     => 0                      -- Расчет косвенных затрат
      );
        
    end if;
    for cc in (
      select PCL.*
      from  UDO_PRJSTG_PRCLC  PCL
      where PCL.PRN = ss.rn      
    ) loop
      begin
        select cn.rn
          into nOutCALC
          from contrprclc cn
         where cn.prn = nOUTRN
           and cn.cost_article = cc.cost_article;
      exception when others then
        nOutCALC := null;
      end;
      if nOutCALC is null then
        p_contrprclc_base_insert(
          nCOMPANY        => cc.company,              -- Организация
          nPRN            => nOUTRN,                  -- Родитель
          sNUMB           => cc.numb,                 -- Номер строки калькуляции
          nCOST_ARTICLE   => cc.cost_article,         -- Статья затрат
          nSIGN_MAIN      => cc.sign_main,            -- Признак "Основная"
          nEXP_TYPE       => cc.exp_type,             -- Тип затрат
          nCOST_SUM       => cc.cost_sum,             -- Сумма затрат
          nPERCENT_PLAN   => 0,                       -- Процент план
          nPERCENT_FACT   => 0,                       -- Процент факт
          nRN             => nOutCALC                 -- Регистрационный номер
        );
      else
        p_contrprclc_base_update(
          nRN             => nOutCALC,                 -- Регистрационный номер
          nCOMPANY        => cc.company,              -- Организация
          sNUMB           => cc.numb,                 -- Номер строки калькуляции
          nCOST_ARTICLE   => cc.cost_article,         -- Статья затрат
          nEXP_TYPE       => cc.exp_type,             -- Тип затрат
          nCOST_SUM       => cc.cost_sum,             -- Сумма затрат
          nPERCENT_PLAN   => 0,                       -- Процент план
          nPERCENT_FACT   => 0                        -- Процент факт
        );
      end if;
    end loop;

  end loop;
end UDO_P_PRSTRUCT_COPY;
/

