create or replace procedure usr_p_rep_budget_allocation(nrn in number) is

  budj_code udo_t_finplan.fp_code%type;
  otv_code  agnlist.agnabbr%type;
  en_period enperiod.code%type;
  dep_code  ins_department.code%type;
  syear     number(4);
  bj_rn     udo_t_finplan.rn%type;

  ch constant pkg_std.tstring := 'REP';

  line_l constant pkg_std.tstring := 'LINE_1';
  line_2 constant pkg_std.tstring := 'LINE_2';
  line_3 constant pkg_std.tstring := 'LINE_3';

  idx1 integer;
  idx2 integer;
  idx3 integer;

  n_fl integer;
  idx integer :=0;

  v_it1  number(15);
  v_it2  number(15);
  v_it3  number(15);
  v_it4  number(15);
  v_it5  number(15);
  v_it6  number(15);
  v_it7  number(15);
  v_it8  number(15);
  v_it9  number(15);
  v_it10 number(15);
  v_it11 number(15);
  v_it12 number(15);

  v_itf1  number(15);
  v_itf2  number(15);
  v_itf3  number(15);
  v_itf4  number(15);
  v_itf5  number(15);
  v_itf6  number(15);
  v_itf7  number(15);
  v_itf8  number(15);
  v_itf9  number(15);
  v_itf10 number(15);
  v_itf11 number(15);
  v_itf12 number(15);

  cell_budj_code constant pkg_std.tstring := 'BUDJ_CODE';
  cell_otv_code  constant pkg_std.tstring := 'OTV_CODE';
  cell_rep_date  constant pkg_std.tstring := 'REP_DATE';
  cell_dep_code  constant pkg_std.tstring := 'DEP_CODE';
  cell_en_period constant pkg_std.tstring := 'EN_PERIOD';

begin

  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);

  prsg_excel.cell_describe(scell_name => cell_budj_code);
  prsg_excel.cell_describe(scell_name => cell_otv_code);
  prsg_excel.cell_describe(scell_name => cell_rep_date);
  prsg_excel.cell_describe(scell_name => cell_dep_code);
  prsg_excel.cell_describe(scell_name => cell_en_period);

  prsg_excel.line_describe(line_l);
  prsg_excel.line_describe(line_2);

  for i in 1 .. 33
  loop
    prsg_excel.line_cell_describe(line_l, 'COL_' || i);
    prsg_excel.line_cell_describe(line_2, 'COL_I_' || i);
  end loop;

  select bj.fp_code
        ,per.code
        ,otv.agnabbr
        ,dep.code
        ,bj.rn
        ,extract(year from per.enddate)
    into budj_code
        ,en_period
        ,otv_code
        ,dep_code
        ,bj_rn
        ,syear
    from usr_t_budget_allocation br
    join udo_t_finplan bj
      on bj.rn = br.finplan
    join enperiod per
      on per.rn = bj.fp_period
    left join agnlist otv
      on otv.rn = bj.budj_otv
    left join ins_department dep
      on dep.rn = bj.depord
   where br.rn = nrn;

  prsg_excel.cell_value_write(scell_name => cell_budj_code, scell_value => budj_code);
  prsg_excel.cell_value_write(scell_name => cell_otv_code, scell_value => otv_code);
  prsg_excel.cell_value_write(scell_name => cell_rep_date, scell_value => to_char(sysdate, 'DD.MM.YYYY'));
  prsg_excel.cell_value_write(scell_name => cell_dep_code, scell_value => 'Îòäåë: ' || dep_code);
  prsg_excel.cell_value_write(scell_name => cell_en_period, scell_value => 'Ïåğèîä: ' || en_period);

  for cur1 in (select level      nlv
                     ,t.rn       brs_rn
                     ,t.art_numb
                     ,t.code
                     ,t.name
                 from udo_t_finplan_arts t
                where t.prn = bj_rn
               connect by prior t.rn = t.parent_art
                start with t.parent_art is null
                order by t.art_numb)
  loop
  
   /* if idx1 is null
    then
      idx1 := prsg_excel.line_append(line_l);
    else
      idx1 := prsg_excel.line_continue(line_l);
    end if;
  
    prsg_excel.cell_value_write('COL_1', 0, idx1, cur1.name);
    prsg_excel.cell_value_write('COL_2', 0, idx1, cur1.art_numb);
    prsg_excel.cell_value_write('COL_3', 0, idx1, cur1.code);*/
  
    n_fl   := 0;
    v_it1  := 0;
    v_it2  := 0;
    v_it3  := 0;
    v_it4  := 0;
    v_it5  := 0;
    v_it6  := 0;
    v_it7  := 0;
    v_it8  := 0;
    v_it9  := 0;
    v_it10 := 0;
    v_it11 := 0;
    v_it12 := 0;
  
    v_itf1  := 0;
    v_itf2  := 0;
    v_itf3  := 0;
    v_itf4  := 0;
    v_itf5  := 0;
    v_itf6  := 0;
    v_itf7  := 0;
    v_itf8  := 0;
    v_itf9  := 0;
    v_itf10 := 0;
    v_itf11 := 0;
    v_itf12 := 0;
  
    for cur2 in ( select  brs.rn brs_rn
                        ,brs.art_numb
                        ,f.numb
                        ,brs.name
                        ,sum(case v.numb
                               when 1 then
                                v.val
                               else
                                0
                             end) v1
                        ,sum(case v.numb
                               when 2 then
                                v.val
                               else
                                0
                             end) v2
                        ,sum(case v.numb
                               when 3 then
                                v.val
                               else
                                0
                             end) v3
                        ,sum(case v.numb
                               when 4 then
                                v.val
                               else
                                0
                             end) v4
                        ,sum(case v.numb
                               when 5 then
                                v.val
                               else
                                0
                             end) v5
                        ,sum(case v.numb
                               when 6 then
                                v.val
                               else
                                0
                             end) v6
                        ,sum(case v.numb
                               when 7 then
                                v.val
                               else
                                0
                             end) v7
                        ,sum(case v.numb
                               when 8 then
                                v.val
                               else
                                0
                             end) v8
                        ,sum(case v.numb
                               when 9 then
                                v.val
                               else
                                0
                             end) v9
                        ,sum(case v.numb
                               when 10 then
                                v.val
                               else
                                0
                             end) v10
                        ,sum(case v.numb
                               when 11 then
                                v.val
                               else
                                0
                             end) v11
                        ,sum(case v.numb
                               when 12 then
                                v.val
                               else
                                0
                             end) v12
                        ,sum(case v.numb
                               when 1 then
                                v.val_fact
                               else
                                0
                             end) vf1
                        ,sum(case v.numb
                               when 2 then
                                v.val_fact
                               else
                                0
                             end) vf2
                        ,sum(case v.numb
                               when 3 then
                                v.val_fact
                               else
                                0
                             end) vf3
                        ,sum(case v.numb
                               when 4 then
                                v.val_fact
                               else
                                0
                             end) vf4
                        ,sum(case v.numb
                               when 5 then
                                v.val_fact
                               else
                                0
                             end) vf5
                        ,sum(case v.numb
                               when 6 then
                                v.val_fact
                               else
                                0
                             end) vf6
                        ,sum(case v.numb
                               when 7 then
                                v.val_fact
                               else
                                0
                             end) vf7
                        ,sum(case v.numb
                               when 8 then
                                v.val_fact
                               else
                                0
                             end) vf8
                        ,sum(case v.numb
                               when 9 then
                                v.val_fact
                               else
                                0
                             end) vf9
                        ,sum(case v.numb
                               when 10 then
                                v.val_fact
                               else
                                0
                             end) vf10
                        ,sum(case v.numb
                               when 11 then
                                v.val_fact
                               else
                                0
                             end) vf11
                        ,sum(case v.numb
                               when 12 then
                                v.val_fact
                               else
                                0
                             end) vf12
                 
                   from usr_t_alloc_arts brs
                   join faceacc f
                     on f.rn = brs.faceacc_cost
                   left join usr_t_alloc_arts_v v
                     on v.prn = brs.rn
                  where brs.prn = nrn
                   and brs.finplan_arts = cur1.brs_rn
                  group by brs.art_numb
                           ,f.numb
                           ,brs.name
                           ,brs.rn
                  order by brs.art_numb 
                  )
    loop
      n_fl := 1;
    
       if idx1 is null
    then
      idx1 := prsg_excel.line_append(line_l);
    else
      idx1 := prsg_excel.line_continue(line_l);
    end if;
    
    idx:=idx +1;
    
      prsg_excel.cell_value_write('COL_1', 0, idx1, cur1.name);
      prsg_excel.cell_value_write('COL_2', 0, idx1, cur1.art_numb);
      prsg_excel.cell_value_write('COL_3', 0, idx1, cur2.art_numb);
      prsg_excel.cell_value_write('COL_4', 0, idx1, cur2.name);
    
      if cur2.v1 != 0
      then
        prsg_excel.cell_value_write('COL_5', 0, idx1, cur2.v1);
        v_it1 := v_it1 + cur2.v1;
      end if;
    
      if cur2.v2 != 0
      then
        prsg_excel.cell_value_write('COL_6', 0, idx1, cur2.v2);
        v_it2 := v_it2 + cur2.v2;
      end if;
    
      if cur2.v3 != 0
      then
        prsg_excel.cell_value_write('COL_7', 0, idx1, cur2.v3);
        v_it3 := v_it3 + cur2.v3;
      end if;
    
      if cur2.v4 != 0
      then
        prsg_excel.cell_value_write('COL_8', 0, idx1, cur2.v4);
        v_it4 := v_it4 + cur2.v4;
      end if;
    
      if cur2.v5 != 0
      then
        prsg_excel.cell_value_write('COL_9', 0, idx1, cur2.v5);
        v_it5 := v_it5 + cur2.v5;
      end if;
    
      if cur2.v6 != 0
      then
        prsg_excel.cell_value_write('COL_10', 0, idx1, cur2.v6);
        v_it6 := v_it6 + cur2.v6;
      end if;
    
      if cur2.v7 != 0
      then
        prsg_excel.cell_value_write('COL_11', 0, idx1, cur2.v7);
        v_it7 := v_it7 + cur2.v7;
      end if;
    
      if cur2.v8 != 0
      then
        prsg_excel.cell_value_write('COL_12', 0, idx1, cur2.v8);
        v_it8 := v_it8 + cur2.v8;
      end if;
    
      if cur2.v9 != 0
      then
        prsg_excel.cell_value_write('COL_13', 0, idx1, cur2.v9);
        v_it9 := v_it9 + cur2.v9;
      end if;
    
      if cur2.v10 != 0
      then
        prsg_excel.cell_value_write('COL_17', 0, idx1, cur2.v10);
        v_it10 := v_it10 + cur2.v10;
      end if;
    
      if cur2.v11 != 0
      then
        prsg_excel.cell_value_write('COL_15', 0, idx1, cur2.v11);
        v_it11 := v_it11 + cur2.v11;
      end if;
    
      if cur2.v12 != 0
      then
        prsg_excel.cell_value_write('COL_16', 0, idx1, cur2.v12);
        v_it12 := v_it12 + cur2.v12;
      end if;
    
      if cur2.vf1 != 0
      then
        prsg_excel.cell_value_write('COL_18', 0, idx1, cur2.vf1);
        v_itf1 := v_itf1 + cur2.vf1;
      end if;
    
      if cur2.vf2 != 0
      then
        prsg_excel.cell_value_write('COL_19', 0, idx1, cur2.vf2);
        v_itf2 := v_itf2 + cur2.vf2;
      end if;
    
      if cur2.vf3 != 0
      then
        prsg_excel.cell_value_write('COL_20', 0, idx1, cur2.vf3);
        v_itf3 := v_itf3 + cur2.vf3;
      end if;
    
      if cur2.vf4 != 0
      then
        prsg_excel.cell_value_write('COL_21', 0, idx1, cur2.vf4);
        v_itf4 := v_itf4 + cur2.vf4;
      end if;
    
      if cur2.vf5 != 0
      then
        prsg_excel.cell_value_write('COL_22', 0, idx1, cur2.vf5);
        v_itf5 := v_itf5 + cur2.vf5;
      end if;
    
      if cur2.vf6 != 0
      then
        prsg_excel.cell_value_write('COL_23', 0, idx1, cur2.vf6);
        v_itf6 := v_itf6 + cur2.vf6;
      end if;
    
      if cur2.vf7 != 0
      then
        prsg_excel.cell_value_write('COL_24', 0, idx1, cur2.vf7);
        v_itf7 := v_itf7 + cur2.vf7;
      end if;
    
      if cur2.vf8 != 0
      then
        prsg_excel.cell_value_write('COL_25', 0, idx1, cur2.vf8);
        v_itf8 := v_itf8 + cur2.vf8;
      end if;
    
      if cur2.vf9 != 0
      then
        prsg_excel.cell_value_write('COL_26', 0, idx1, cur2.vf9);
        v_itf9 := v_itf9 + cur2.vf9;
      end if;
    
      if cur2.vf10 != 0
      then
        prsg_excel.cell_value_write('COL_27', 0, idx1, cur2.vf10);
        v_itf10 := v_itf10 + cur2.vf10;
      end if;
    
      if cur2.vf11 != 0
      then
        prsg_excel.cell_value_write('COL_28', 0, idx1, cur2.vf11);
        v_itf11 := v_itf11 + cur2.vf11;
      end if;
    
      if cur2.vf12 != 0
      then
        prsg_excel.cell_value_write('COL_29', 0, idx1, cur2.vf12);
        v_itf12 := v_itf12 + cur2.vf12;
      end if;
    
    end loop;
  
    if n_fl = 1
    then
    
      idx2 := prsg_excel.line_continue(line_2);
      /* Âûâîäèì èòîãè ïî ñòàòüå */
      prsg_excel.cell_value_write('COL_I_1', 0, idx2, cur1.name || ' Èòîã');
      prsg_excel.cell_value_write('COL_I_2', 0, idx2, cur1.art_numb);
      prsg_excel.cell_value_write('COL_I_5', 0, idx2, v_it1);
      prsg_excel.cell_value_write('COL_I_6', 0, idx2, v_it2);
      prsg_excel.cell_value_write('COL_I_7', 0, idx2, v_it3);
      prsg_excel.cell_value_write('COL_I_8', 0, idx2, v_it4);
      prsg_excel.cell_value_write('COL_I_9', 0, idx2, v_it5);
      prsg_excel.cell_value_write('COL_I_10', 0, idx2, v_it6);
      prsg_excel.cell_value_write('COL_I_11', 0, idx2, v_it7);
      prsg_excel.cell_value_write('COL_I_12', 0, idx2, v_it8);
      prsg_excel.cell_value_write('COL_I_13', 0, idx2, v_it9);
      prsg_excel.cell_value_write('COL_I_14', 0, idx2, v_it10);
      prsg_excel.cell_value_write('COL_I_15', 0, idx2, v_it11);
      prsg_excel.cell_value_write('COL_I_16', 0, idx2, v_it12);
    
      prsg_excel.cell_value_write('COL_I_18', 0, idx2, v_itf1);
      prsg_excel.cell_value_write('COL_I_19', 0, idx2, v_itf2);
      prsg_excel.cell_value_write('COL_I_20', 0, idx2, v_itf3);
      prsg_excel.cell_value_write('COL_I_21', 0, idx2, v_itf4);
      prsg_excel.cell_value_write('COL_I_22', 0, idx2, v_itf5);
      prsg_excel.cell_value_write('COL_I_23', 0, idx2, v_itf6);
      prsg_excel.cell_value_write('COL_I_24', 0, idx2, v_itf7);
      prsg_excel.cell_value_write('COL_I_25', 0, idx2, v_itf8);
      prsg_excel.cell_value_write('COL_I_26', 0, idx2, v_itf9);
      prsg_excel.cell_value_write('COL_I_27', 0, idx2, v_itf10);
      prsg_excel.cell_value_write('COL_I_28', 0, idx2, v_itf11);
      prsg_excel.cell_value_write('COL_I_29', 0, idx2, v_itf12);
    
    end if;
  
  end loop;

  prsg_excel.line_delete(sline_name => line_l);
  prsg_excel.line_delete(sline_name => line_2);

end;
/
