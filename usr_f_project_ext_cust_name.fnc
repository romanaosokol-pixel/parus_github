create or replace function usr_f_project_ext_cust_name(next_cust in project.ext_cust%type) return agnlist.agnname%type is

  v_res agnlist.agnname%type;
begin
/*Доп колонка в "Проект" -  "Наименование внешнего заказыика" */
  case
    when next_cust is null then
      return null;
    
    else
    
      select a.agnname
        into v_res
        from agnlist a
       where a.rn = next_cust;
    
  end case;

  return v_res;

end;
/
