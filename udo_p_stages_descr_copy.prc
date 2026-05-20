create or replace procedure UDO_P_STAGES_DESCR_COPY
(
NIDENT in number, -- идентификатор помеченных хаписей (RN Ётапа договора)
nSumSign in number,  -- 1 ѕереносить суммы в договор
nSign_DATE in number -- 1 копирование сроков проекта в договор
) is

--- «аполнение описани€ этапа договора из этапа проекта
begin
  for ss in (
    select st.rn nStage_RN
          ,PS.NAME as sPRJ_NAME
          ,ST.DESCRIPTION as sSTG_DESCR
          ,ps.cost_sum
          ,st.sum_type
          ,st.stage_sum
          ,dt.p_value
          ,ps.begplan
          ,ps.endplan
    from PROJECTSTAGE         PS
        ,STAGES               ST
        ,SELECTLIST           SL
        ,DICTAXIS             dt
    where SL.IDENT = NIDENT
      and ST.RN = SL.DOCUMENT
      and PS.Faceacccust = ST.FACEACC
      and dt.tax_group (+) = st.taxgr


  ) loop

    ---«аполнение описани€ этапа договора из этапа проекта.
    if ss.sstg_descr is null then
      update STAGES stt
         set stt.description = ss.sprj_name
       where stt.rn = ss.nstage_rn;
    end if;
--p_exception(0,'!! '||ss.begplan);
    if nSign_DATE = 1 then
      update STAGES stt
         set stt.begin_date  = ss.begplan,
             stt.end_date    = ss.endplan
       where stt.rn = ss.nstage_rn;
     end if; 
    
    ss.p_value := nvl(ss.p_value, 0);
    if nSumSign = 1 and ss.stage_sum = 0 then
      update STAGES stt
      set  stt.stage_sum = round(ss.cost_sum /(1+ss.p_value/100),2),
           stt.stage_sumtax = ss.cost_sum,
           stt.stage_sum_nds = ss.cost_sum - round(ss.cost_sum /(1+ss.p_value/100),2), 
           stt.sum_type = 0
      where stt.rn = ss.nstage_rn;      
    end if;
  end loop;
end UDO_P_STAGES_DESCR_COPY;
/

