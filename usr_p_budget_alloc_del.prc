create or replace procedure usr_p_budget_alloc_del(nrn in number) is

  nstatus usr_t_budget_allocation.status%type;

begin
  /*Проверка состочния распределения, кдаляем только из состояния "НОВОЕ"*/

  select t.status into nstatus from usr_t_budget_allocation t where t.rn = nrn;

  if nstatus != 0
  then
    p_exception(0
               ,'Удалять бюджетное распределение можно только в состоянии "Новое"');
  end if;

  usr_p_budget_alloc_base_del(nrn);

end;
/
