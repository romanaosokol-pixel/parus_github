create or replace procedure UDO_P_STAGE_KARTZATR (
       nIDENT     in number, --идентификатор помеченных записей -- Ётапы проекта или договора
       sAgn_main  in varchar,
       nFact      in integer /* 0 - по фактическим данным, 1 - по формулам —хемы калькул€ции */
) 
---- ¬ызовы отчетов " алькул€ци€ затрат"
is
  begin

  if (1 = nFact) then -- по формулам —хемы калькул€ции
    UDO_P_REP_STAGE_KARTZATR_NEW(nIDENT => nIDENT, sAgn_main => sAgn_main);
  else
    UDO_P_REP_STAGE_KARTZATR(nIDENT => nIDENT, sAgn_main => sAgn_main);
  end if;
   
end UDO_P_STAGE_KARTZATR;

/*
grant EXECUTE on UDO_P_STAGE_KARTZATR to public;
*/
/

