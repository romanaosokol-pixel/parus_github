create or replace procedure usr_p_payaccin_cl_val_del(nrn payaccin.rn%type) is

  /*Процедура удаления расчета бюджетных данных по ВСЕМУ счету*/
begin

  for cur in (select t.rn
                from usr_tab_payaccin_cl_val t
               where t.prn = nrn)
  
  loop
  
    usr_p_payaccin_cl_val_bdel(nrn => cur.rn);
  
  end loop;

end;
/
