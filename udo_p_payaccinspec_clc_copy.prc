create or replace procedure UDO_P_PAYACCINSPEC_CLC_COPY
(
NRN    in number, -- RN Документа
NParam in number  -- Признак: 1 -  копировать в остальные строки спецификации
)
is
 tPAYSPEC PAYACCINSPEC%rowtype;

/*Процедура корректирует колличество в калькуляции Входящего счета, на равномерное распределение  */
  procedure SET_QUANT
     (nRN_CLC     in number,
      nQUANT_CLC  in number
     )
  is
    nCount     number;   
    nRem_Quant number (15);
    nQuant     number (15);
    
  begin
    
    select count(rn)
    into nCount
    from PAYACCINSPCLC cl
    where cl.prn = NRN_CLC;
    
    if nCount > 1 then
      nRem_Quant := nQUANT_CLC;
      for ss in (
        select clc.*
        from PAYACCINSPCLC clc
        where clc.prn = NRN_CLC
        ) loop
          if nCount = 1 then
            nQuant := nRem_Quant;
          else
            nQuant := round(nRem_Quant/nCount,0);
          end if;
          if nQuant > 0 then
            update PAYACCINSPCLC cl
            set cl.quant_plan = nQuant,
                cl.quant_fact = nQuant
            where cl.rn = ss.rn;
            nRem_Quant := nRem_Quant - nQuant;
          else
            null;
            delete from PAYACCINSPCLC clc where clc.rn =  ss.rn;
          end if;  
          nCount := nCount - 1;
       end loop;
     end if;
  end; 
  
  procedure COPY_CLC
    (
     NPRN        in number,
     tPAYSP      in PAYACCINSPEC%rowtype 
    )
    is
    nlRN number;
    rPAYCLC PAYACCINSPCLC%rowtype;
    
    begin
      begin
        select *
        into rPAYCLC
        from PAYACCINSPCLC cc
        where cc.prn = NPRN
          and rownum = 1;
      exception when NO_DATA_FOUND then
        rPAYCLC.rn        := null;
        rPAYCLC.Cost_Plan := tPAYSP.Summ / tPAYSP.Quant;
      end;  
    
      for sp in (
        select * from PAYACCINSPCLC cl where cl.prn = tPAYSP.RN
      ) loop
        begin
          select rn
          into nlRN
          from PAYACCINSPCLC clc
          where clc.prn = NPRN
            and clc.faceaccount = sp.faceaccount;
        exception when NO_DATA_FOUND then
          nlRN := null;
        end;    
        if nlRN is null then
          P_PAYACCINSPCLC_BASE_INSERT
            (
              nCOMPANY          => SP.COMPANY,       -- Организация
              nPRN              => NPRN,             -- Родитель
              sNUMB             => sp.numb,          -- Номер строки
              nCOST_ARTICLE     => nvl(rPAYCLC.Cost_Article, SP.COST_ARTICLE),  -- Статья затрат
              nCOST_PLACE       => nvl(rPAYCLC.Cost_Place, SP.COST_PLACE),    -- Место возникновения затрат
              nCOST_PLAN        => rPAYCLC.Cost_Plan, -- Затраты на единицу план
              nCOST_FACT        => rPAYCLC.Cost_Plan, -- Затраты на единицу факт
              nPRIORITY         => SP.PRIORITY,      -- Приоритет
              nFACEACCOUNT      => SP.FACEACCOUNT,   -- Лицевой счёт
              nGRAPHPOINT       => SP.GRAPHPOINT,    -- Точка графика лицевого счета
              nFINOPER_TYPE     => sp.finoper_type,  -- Вид финансовой операции
              nQUANT_PLAN       => 0,                -- Количество план
              nQUANT_FACT       => 0,                -- Количество факт
              nSUBDIV           => SP.SUBDIV,        -- Подразделение
              nRN               => nlRN              -- Регистрационный номер
            );      

        end if;
      end loop;
    end;

begin  
  select c.*
  into tPAYSPEC
  from PAYACCINSPEC c 
  where c.rn = NRN;
  
  SET_QUANT (nRN_CLC => NRN, nQUANT_CLC => tPAYSPEC.Quant);
  
  if NParam = 1 then
    for sp in (
      select spp.*
      from PAYACCINSPEC spp, DICNOMNS dn
      where spp.prn = tPAYSPEC.Prn
        and spp.rn <> NRN
        and dn.rn = spp.nomen
        and dn.NOMEN_TYPE = 1
    ) loop
      COPY_CLC
          (
           NPRN        => sp.rn,
           tPAYSP      => tPAYSPEC 
          );
      SET_QUANT (nRN_CLC => sp.rn, nQUANT_CLC => sp.quant);
  
    end loop;
  end if;
  
end UDO_P_PAYACCINSPEC_CLC_COPY;
/

