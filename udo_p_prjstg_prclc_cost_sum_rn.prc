create or replace procedure UDO_P_PRJSTG_PRCLC_COST_SUM_RN
(
       nIdent     in number -- RN из UDO_PRJSTG_PRCLC или CONTRPRCLC 
)
-- Рекурсивная процедура получения данных Схемы Калькуляции
as
   nKind       number(8,0);
   nStRn       number(17,0);
   nCalcScm    number(17,0);
   nCostPart   FCCOSTNOTES.COST_BSUM%type;
   nCostSum    FCCOSTNOTES.COST_BSUM%type;

  procedure UDO_P_COMPUTE_COST
  (
    nIdent      in number,  --RN строки схемы калькуляции
    nCostCalc   out FCCOSTNOTES.COST_BSUM%type
  )
  as
      begin 
        
          select nvl(sum(cst.COST_BSUM), 0) into nCostCalc
          from PROJECTSTAGE  pjs,
               STAGES        stg,
               CONTRPRSTRUCT str,
               CONTRPRCLC    clc,
               FCCOSTNOTES   cst,
               FINSTATE      fst
          where pjs.FACEACCCUST = stg.FACEACC
                and stg.RN = str.PRN
                and str.RN = clc.PRN
                and pjs.FACEACC = cst.PROD_ORDER
                and pjs.FACEACCCUST = cst.FACEACC
                and clc.COST_ARTICLE = cst.COST_ARTICLE
                and cst.COST_TYPE = fst.RN
                and upper(fst.CODE) = 'ФАКТ'
                and clc.rn = nIdent --6282154
                and stg.RN = nStRn --6282145   
          group by clc.RN;
            
          exception when NO_DATA_FOUND then
            nCostCalc := 0;

  end UDO_P_COMPUTE_COST;
      
begin

   select clc.exp_type, str.prn, str.calcschm into nKind, nStRn, nCalcScm
   from CONTRPRCLC clc, CONTRPRSTRUCT str
   where str.rn = clc.prn and str.RN = nIdent; --6282154  
   
    if (1 = nKind) then
      nCostPart := 0;
      for rec in (
          select scart.fpdartcl, /*scart.sign,*/ case scart.SIGN when 0 then 1 else -1 end  as nSIGN,
                 scmp.kind, scmp.rn scmp_rn, scmp.prn scmp_prn, nvl(scmp.percent, 100) s_perc--, scmp.numb
          from PRJCALCSCHMART scart, PRJCALCSCHMSP scmp
          where scmp.fpdartcl = scart.fpdartcl
          and scart.prn = nStRn --nScmpRn
          and scmp.prn = nCalcScm --nScmpPRn
      ) loop
--,case scart.SIGN when 0 then 1 else -1 end  as nSIGN
        UDO_P_COMPUTE_COST(nIdent, nCostPart);
        --UDO_P_PRJSTG_PRCLC_COST_SUM_RN(nPRN, rec.fpdartcl, rec.kind, rec.scmp_rn, rec.scmp_prn, nFromPr, nCostPart/*, sNumbPart*/);

        nCostSum := nCostSum + nCostPart*rec.nSIGN; --* rec.s_perc / 100;

      end loop;
            
    end if;

end UDO_P_PRJSTG_PRCLC_COST_SUM_RN;

/*
grant EXECUTE on UDO_P_PRJSTG_PRCLC_COST_SUM_RN to public;
*/
/

