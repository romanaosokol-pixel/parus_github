create or replace procedure UDO_P_PRJSTG_PRCLC_COST_SUM
(
       nPRN          in number, 
       nCOST_ARTICLE in number,
       nKind         in number,
       nScmpRn       in number,
       nScmpPRn      in number,
       nFromPr       in number,
       nCostSum      out UDO_PRJSTG_PRCLC.COST_SUM%type--, --(17,2);
       --sNumb         out UDO_PRJSTG_PRCLC.NUMB%type      --VARCHAR2(10)
)
-- Рекурсивная процедура получения данных Схемы Калькуляции
as
  nCostPart UDO_PRJSTG_PRCLC.COST_SUM%type;
  sNumbPart UDO_PRJSTG_PRCLC.NUMB%type;
begin
    if (1 = nKind) then
      nCostSum := 0;
      for rec in (
          select scart.fpdartcl, scart.sign, scmp.kind, scmp.rn scmp_rn, scmp.prn scmp_prn, nvl(scmp.percent, 100) s_perc--, scmp.numb
          from PRJCALCSCHMART scart, PRJCALCSCHMSP scmp
          where scart.prn = nScmpRn
          and scmp.fpdartcl = scart.fpdartcl
          and scmp.prn = nScmpPRn
      ) loop

        UDO_P_PRJSTG_PRCLC_COST_SUM(nPRN, rec.fpdartcl, rec.kind, rec.scmp_rn, rec.scmp_prn, nFromPr, nCostPart/*, sNumbPart*/);
        
        if (0 = rec.sign) then
             nCostSum := nCostSum + nCostPart * rec.s_perc / 100;
        else nCostSum := nCostSum - nCostPart * rec.s_perc / 100;
        end if;
        
      end loop;
      
    else
      
      begin 
        
        if (1 = nFromPr) then
          select nvl(sta.cost_sum, 0) cost_sum--, trim(sta.NUMB) NUMB
            into nCostSum--, sNumb
          from UDO_PRJSTG_PRCLC sta 
          where sta.prn = nPRN and sta.cost_article = nCOST_ARTICLE;
             --and trim(t.numb) = trim(sNUMB);
        else
          select nvl(sta.cost_sum, 0) cost_sum--, trim(sta.NUMB) NUMB
            into nCostSum--, sNumb
          from CONTRPRCLC sta 
          where sta.prn = nPRN and sta.cost_article = nCOST_ARTICLE;
        end if;
             
      exception when NO_DATA_FOUND then     
        nCostSum := 0;
        --sNumb := '';
      end;

    end if;
end UDO_P_PRJSTG_PRCLC_COST_SUM;

/*
grant EXECUTE on UDO_P_PRJSTG_PRCLC_COST_SUM to public;
*/
/

