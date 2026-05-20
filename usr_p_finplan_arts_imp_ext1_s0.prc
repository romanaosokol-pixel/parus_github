create or replace procedure usr_p_finplan_arts_imp_ext1_s0 is

begin
/* Шаг записи в таблицу */
  delete usr_t_finplan_arts_imp_ext1 t
   where  t.sauthid = utilizer;
end;
/
