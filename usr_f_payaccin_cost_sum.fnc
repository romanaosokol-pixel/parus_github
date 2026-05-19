create or replace function usr_f_payaccin_cost_sum(alloc_rn usr_t_alloc_arts.rn%type ) return number is

res_nSum number(15,2); -- Сумма по калькуляциям УТВЕРЖДЕННЫХ счетов, по заданной подстатье бюджетного распределения


begin


select nvl(sum(L.nval), 0)
  into res_nsum
  from USR_T_ALLOC_ARTS BRS
  join USR_V_LIMIT_CONTROL L on L.nalloc_arts_faceacc = BRS.FACEACC_COST
 where BRS.rn = alloc_rn;

return res_nsum;

end;
/
