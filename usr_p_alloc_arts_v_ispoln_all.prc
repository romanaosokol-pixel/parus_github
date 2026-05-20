create or replace procedure usr_p_alloc_arts_v_ispoln_all(pin_year in varchar2) is

begin

  /* Обнулим фактические значения для всех подстатей указанного года */

  update usr_t_alloc_arts_v zv
     set zv.val_fact = 0
   where zv.prn in (select brs.rn
                      from usr_t_alloc_arts brs
                      join udo_t_finplan_arts bjs
                        on bjs.rn = brs.finplan_arts
                      join udo_t_finplan bj
                        on bj.rn = bjs.prn
                      join enperiod per
                        on per.rn = bj.fp_period                    
                     where extract(year from per.startdate) = pin_year);


/* Рассчитаем исполнение по покащзателям */
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
              
               group by zv.rn)
  
  loop
  
    update usr_t_alloc_arts_v zv
       set zv.val_fact = cur.s
     where zv.rn = cur.rn;
  
  end loop;

end;
/
