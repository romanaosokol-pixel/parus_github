create or replace function ust_f_art_is_allocation(nrn in number) return number is

  nres number(1);

begin
/* Функция показывает - разбивается ли статья бюджета на подстатьи */
  begin
  
    select 1
      into nres
      from usr_t_alloc_arts t
     where t.FINPLAN_ARTS = nrn
       and rownum = 1;
         
  exception
    when no_data_found then
      nres := 0;
    
  end;

  return nres;

end;
/
