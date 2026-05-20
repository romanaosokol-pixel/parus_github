create or replace procedure usr_p_fcacoperplansclc_rec(nrn in contrprstruct.rn%type) is

  /* 
  
  Процедура формирует кальуляции графиков отпуска по калькуляции структуры цены
  распределяя сумму из структуры  пропорционально сумме графика.
  
  */

  v_nrn1 fcacoperplansclc.rn%type;
  v_sum  fcacoperplansclc.cost_plan%type;

begin

  --- Удаляем калькудяции ВСЕХ графиков отпуска данного этапа!

  delete fcacoperplansclc t
   where t.rn in (select clc.rn
                    from contrprstruct sp
                    join stages st
                      on st.rn = sp.prn
                    join fcacoperplans gr
                      on gr.prn = st.faceacc
                    join fcacoperplansclc clc
                      on clc.prn = gr.rn
                   where sp.rn = nrn);

  for cur in (select gr.rn
                    ,gr.summwithnds s_gr
                    ,gr.quant
                    ,st.faceacc
                    ,st.stage_sumtax summ_all
                    ,gr.summwithnds / st.stage_sumtax koeff
                    ,lead(gr.rn) over(order by gr.prn, gr.summwithnds) lrn
                from contrprstruct sp
                join stages st
                  on st.rn = sp.prn
                join fcacoperplans gr
                  on gr.prn = st.faceacc              
               where sp.rn = nrn
               and st.stage_sumtax !=0 -- Тут тут и разносить нечего
               )
               
  loop
   
     
    
      /* Распределяем на калькуляцию графика долю калькуляции Структуры цены пропоорционально отношению суммы калькуляции графика к сумме структуры*/
    
      for str in (select ct.company
                        ,cl.numb
                        ,cl.cost_article
                        ,cl.cost_sum
                    from contrprstruct ct
                    join contrprclc cl
                      on cl.prn = ct.rn
                   where ct.rn = nrn)
      loop
      
        if cur.lrn is not null
        then
        
          v_sum := round(str.cost_sum * cur.koeff / cur.quant, 2); -- Это цена
        
        else
          -- В последнюю пишем дельту, чтоб не было ошибок округления
          select nvl(sum(fop.cost_plan * fp.quant), 0) -- Цену переводим в сумму
            into v_sum
            from fcacoperplans fp
            join fcacoperplansclc fop
              on fop.prn = fp.rn
             and fop.cost_article = str.cost_article
           where fp.prn = cur.faceacc;
        
          v_sum := str.cost_sum - v_sum;
        
        end if;
        p_fcacoperplansclc_base_insert(ncompany      => str.company
                                      ,nprn          => cur.rn
                                      ,snumb         => str.numb
                                      ,ncost_article => str.cost_article
                                      ,ncost_place   => null
                                      ,ncost_plan    => v_sum
                                      ,ncost_fact    => null
                                      ,npriority     => null
                                      ,nfaceacc      => null
                                      ,ngraphpoint   => null
                                      ,nfinoper_type => null
                                      ,nquant_plan   => null
                                      ,nquant_fact   => null
                                      ,nsubdiv       => null
                                      ,nbal_unit     => null
                                      ,nmanager      => null
                                      ,nfin_source   => null
                                      ,npay_tool     => null
                                      ,nord_nomen    => null
                                      ,nord_modif    => null
                                      ,nrn           => v_nrn1);
      
      end loop;
    
  end loop;

update CONTRPRSTRUCT set CALC_INDIR = 1 where rn = nrn;


end;
/
