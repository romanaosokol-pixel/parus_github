create or replace procedure usr_p_budgall_sp_v_base_insert(nprn in usr_t_alloc_arts.rn%type) is

  rec usr_t_alloc_arts_v%rowtype; --Куда пишем

  /* Всегда создаем 12 пустых записей
    Бюджетное распределение. Статьи. Значение
  , в дальннейшем только правим значения */
begin

  rec.prn := nprn;
  


  for cur in (select nn.n
                    ,add_months(per.startdate, nn.n - 1) d1
                    ,last_day(add_months(per.startdate, nn.n - 1)) d2
              
                from usr_t_alloc_arts tt
                full outer join (select level as n from dual connect by level <= 12) nn
                  on 1 = 1
                join udo_t_finplan_arts art
                  on art.rn = tt.finplan_arts
                join usr_t_budget_allocation ba
                  on ba.rn = tt.prn
                join udo_t_finplan fp
                  on fp.rn = ba.finplan
                join enperiod per
                  on per.rn = fp.fp_period
               where tt.rn = nprn)
  loop
  
    rec.rn        := gen_id;
    rec.date_from := cur.d1;
    rec.date_to   := cur.d2;
    rec.val       := 0;
    rec.val_mod   := 0;
    rec.val_fact  := 0;
    rec.numb      := cur.n;
  
    insert into usr_t_alloc_arts_v values rec;
  
  end loop;

end;
/
