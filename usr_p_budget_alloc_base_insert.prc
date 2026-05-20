create or replace procedure usr_p_budget_alloc_base_insert
(
  ncompany  in number
 ,ncrn      in number
 ,ndoctypes in number
 ,ndocnumb  in number
 ,ddocdate  in date
 ,nfinplan  in number
 ,nrn       out number
  
) is

  rec usr_t_budget_allocation%rowtype; --Куда пишем

begin
  nrn          := gen_id;
  rec.rn       := nrn;
  rec.company  := ncompany;
  rec.crn      := ncrn;
  rec.doctypes := ndoctypes;
  rec.docnumb  := ndocnumb;
  rec.docdate  := ddocdate;
  rec.finplan  := nfinplan;

  insert into usr_t_budget_allocation values rec;

end;
/
