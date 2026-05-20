create or replace procedure usr_p_payaccin_cl_val_bdel(nrn usr_tab_payaccin_cl_val.rn%type) is

  /*Базовая процедура удаления расчета бюджетных данных по счету*/
begin

  delete usr_tab_payaccin_cl_val
   where rn = nrn;

end;
/
