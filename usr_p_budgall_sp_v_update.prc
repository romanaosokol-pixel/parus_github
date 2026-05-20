create or replace procedure usr_p_budgall_sp_v_update(nrn       in usr_t_alloc_arts_v.rn%type
                                                     ,nval      in usr_t_alloc_arts_v.val%type
                                                     ,nval_fact in usr_t_alloc_arts_v.val_fact%type
                                                     ,snote     in usr_t_alloc_arts_v.note%type) is
  /* Исправление строки 
    Бюджетное распределение. Статьи. Значение
   Правим только значение и описание
   
   Городецкий О.И. 2025-11-24 Исправление месячных значений уточняющей статьи в бюджетном распределении
    
  */
begin

/* Может факт им не давать править? */

  usr_p_budgall_sp_v_base_update(nrn => nrn, nval => nvl(nval,0), snote => snote, nval_fact => NVL(nval_fact,0));
end;
/
