create or replace procedure usr_p_budgall_sp_v_base_update
(
  nrn   in usr_t_alloc_arts_v.rn%type
 ,nval  in usr_t_alloc_arts_v.val%type
 ,nval_FACT  in usr_t_alloc_arts_v.val_fact%type
 ,snote in usr_t_alloc_arts_v.note%type
) is

  /* Исправление строки 
    Бюджетное распределение. Статьи. Значение
   Правим только значение и описание 
  */
begin

  update usr_t_alloc_arts_v t
     set t.val  = nval
        ,t.note = snote
        ,T.VAL_FACT = nval_FACT
   where t.rn = nrn;

end;
/
