create or replace procedure usr_p_budget_alloc_nmb
(
  ncompany  in number
 ,nfinplan  in number
 ,ndoctypes in number
 ,ndocnumb  out number
) is

begin
  select nvl(max(br.docnumb), 0) + 1
    into ndocnumb
    from usr_t_budget_allocation br
    join udo_t_finplan fp
      on fp.rn = br.finplan
   where br.company = ncompany
     and br.doctypes = ndoctypes
     and fp.fp_period = (select fpt.fp_period from udo_t_finplan fpt where fpt.rn = nfinplan);

end;
/
