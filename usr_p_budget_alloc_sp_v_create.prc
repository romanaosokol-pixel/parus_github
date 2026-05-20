create or replace procedure usr_p_budget_alloc_sp_v_create(nprn in number
                                                          ,nmes in number
                                                          ,nsum in number) is

begin
  ---Обновим суммы по периода

  update udo_t_finplan_arts_v t
     set t.val = nsum
   where t.prn = nprn
     and t.numb = nmes;

end;
/
