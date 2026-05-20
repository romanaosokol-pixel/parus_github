create or replace procedure usr_p_payaccin_cl_val_clc(nrn payaccin.rn%type) is

  v_nrn number(17);

begin

  /* Очистить текущий расчет показателей */

  usr_p_payaccin_cl_val_del(nrn => nrn);

  /*Расситаем бюджет для счета (Лимит, остаток, дельту)*/

  for cur in (
              
                with cl as
                 (select distinct p.rn
                                 ,usr_f_payincl_alloc_rn(psc.rn) alloc_rn
                    from payaccin p
                    join payaccinspec ps
                      on ps.prn = p.rn
                    join payaccinspclc psc
                      on psc.prn = ps.rn
                   where p.rn = nrn)
                
                select p.company
                      ,cl.alloc_rn
                      ,usr_f_alloc_art_limit(cl.alloc_rn, 0) limit
                      ,usr_f_payaccin_cost_sum(alloc_rn => cl.alloc_rn) cost
                  from cl
                  join payaccin p
                    on cl.rn = p.rn
                  join usr_t_alloc_arts brs
                    on brs.rn = cl.alloc_rn)
  
  loop
  ---p_exception(0, cur.cost);
    usr_p_payaccin_cl_val_bins(ncompany  => cur.company
                              ,nprn      => nrn
                              ,nalloc_rn => cur.alloc_rn
                              ,nlimit    => cur.limit
                              ,ncost     => cur.cost
                              ,nrn       => v_nrn);
  
  end loop;

end;
/
