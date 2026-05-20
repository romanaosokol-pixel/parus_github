create or replace procedure usr_p_agnlist_agnnane_is_emp(pin_agent_from in agnlist.agnname%type) is

  isemp agnlist.emp%type;

begin
  begin
    select a.emp
      into isemp
      from agnlist a
     where a.agnname = pin_agent_from
       and a.version = 91134 and a.AGNTYPE = 1 and A.Emp =1; /*физ. лицо*/
  exception
    when no_data_found then
      p_exception(0
                 ,'Контрагент, с признаком "сотрудник", наименованием %s не найден!', pin_agent_from);
                 
    when others then  p_exception(0
                 ,'Контрагент с наименованием %s вызвал ошибку!', pin_agent_from);            
  end;

/*  if isemp = 0
  then
    p_exception(0
               ,'Контрагент с наименованием %s не является сотрудником. Установите унего признак "Сотрудник"', pin_agent_from);
  end if;*/

end;
/
