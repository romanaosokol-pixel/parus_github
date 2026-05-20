create or replace procedure usr_p_alloc_arts_v_ispoln_br(pin_doc in USR_T_BUDGET_ALLOCATION.rn%type) is

  pin_year varchar2(4);
begin

  /* Пересчет исполнения конкретного бюджетного распределения */
  select extract(year from per.startdate)
    into pin_year
    from usr_t_budget_allocation br
    join udo_t_finplan bj
      on bj.rn = br.finplan
    join enperiod per
      on per.rn = bj.fp_period
   where br.rn = pin_doc;

  /* Обнулим фактические значения для бюджетного распределения */

  update usr_t_alloc_arts_v zv
     set zv.val_fact = 0
   where zv.prn in (select brs.rn
                      from usr_t_alloc_arts brs
                     where brs.prn = pin_doc);

  /* Рассчитаем исполнение по показателям */
  for cur in (select sum(t.val) s
                    ,zv.rn
                from udo_t_mark t
                join faceacc f
                  on f.rn = t.alloc_arts_faceacc
                join usr_t_alloc_arts brs
                  on brs.faceacc_cost = f.rn
                join usr_t_alloc_arts_v zv
                  on zv.prn = brs.rn
               where trim(t.mark_pref) = 'Факт'
                 and extract(year from t.mark_date) = pin_year
                 and t.mark_date between zv.date_from and zv.date_to
                 and brs.prn = pin_doc
              
               group by zv.rn)
  
  loop
  
    update usr_t_alloc_arts_v zv
       set zv.val_fact = cur.s
     where zv.rn = cur.rn;
  
  end loop;

end;
/
