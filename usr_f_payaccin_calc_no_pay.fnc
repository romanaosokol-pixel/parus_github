create or replace function usr_f_payaccin_calc_no_pay(frn usr_t_alloc_arts.faceacc_cost%type) return number as

  no_pay number(17, 2);

begin

/* Неоплаченная сумма по счетам, по заданной строоке бюджетного распределения 
Городецкий 06-04-2026 */ 

  select sum(round(cl.cost_plan * cl.quant_plan, 2) * (p.summwithnds - p.factpaysumm) / p.summwithnds) s
    into no_pay
    from payaccinspclc cl
    join usr_tab_calc_detail cld
      on cl.rn = cld.prn
    join usr_t_alloc_arts brs
      on brs.rn = cld.alloc_arts
    join payaccinspec ps
      on ps.rn = cl.prn
    join payaccin p
      on p.rn = ps.prn
   where brs.faceacc_cost = frn
     and p.doc_state = 1 /*Только согласованные */
     and p.factpaysumm != p.summwithnds;

  return no_pay;

end;
/
