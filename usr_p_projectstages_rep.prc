create or replace procedure usr_p_projectstages_rep
(
  pin_idn  in number
 ,pin_date in date
) is

  idx1 integer;
  idx2 integer;
  idxd integer;
  idxp integer;

  sh  pkg_std.tstring := 'X';
  shn varchar2(30); -- новый лист

  cell_project_code constant pkg_std.tstring := 'PROJECT_CODE';
  cell_usl_name     constant pkg_std.tstring := 'USL_NAME';
  cell_project_goal constant pkg_std.tstring := 'PROJECT_GOAL';
  cell_cell_tz      constant pkg_std.tstring := 'CELL_TZ';
  cell_dogovor      constant pkg_std.tstring := 'DOGOVOR';
  cell_price        constant pkg_std.tstring := 'PRICE';

  cell_11 constant pkg_std.tstring := 'CELL_1';
  cell_12 constant pkg_std.tstring := 'CELL_2';
  cell_13 constant pkg_std.tstring := 'CELL_3';
  cell_14 constant pkg_std.tstring := 'CELL_4';
  cell_15 constant pkg_std.tstring := 'CELL_5';
  cell_16 constant pkg_std.tstring := 'CELL_6';
  cell_21 constant pkg_std.tstring := 'CELL_21';
  cell_22 constant pkg_std.tstring := 'CELL_22';
  cell_23 constant pkg_std.tstring := 'CELL_23';
  cell_24 constant pkg_std.tstring := 'CELL_24';
  cell_25 constant pkg_std.tstring := 'CELL_25';
  cell_26 constant pkg_std.tstring := 'CELL_26';

  line_1 constant pkg_std.tstring := 'LINE_1';
  line_2 constant pkg_std.tstring := 'LINE_2';
  line_d constant pkg_std.tstring := 'LINE_D';
  line_p constant pkg_std.tstring := 'LINE_P';
  
  V_DOG_SUM number(17,2):=0;

begin
  prsg_excel.prepare;
  prsg_excel.sheet_select(sh);
  prsg_excel.cell_describe(cell_project_code);
  prsg_excel.cell_describe(cell_usl_name);
  prsg_excel.cell_describe(cell_project_goal);
  prsg_excel.cell_describe(cell_cell_tz);

  prsg_excel.line_describe(line_d);
  prsg_excel.line_cell_describe(line_d, cell_dogovor);

  prsg_excel.line_describe(line_p);
  prsg_excel.line_cell_describe(line_p, cell_price);

  prsg_excel.line_describe(line_1);
  prsg_excel.line_cell_describe(line_1, cell_11);
  prsg_excel.line_cell_describe(line_1, cell_12);
  prsg_excel.line_cell_describe(line_1, cell_13);
  prsg_excel.line_cell_describe(line_1, cell_14);
  prsg_excel.line_cell_describe(line_1, cell_15);
  prsg_excel.line_cell_describe(line_1, cell_16);

  prsg_excel.line_describe(line_2);

  prsg_excel.line_cell_describe(line_2, cell_21);
  prsg_excel.line_cell_describe(line_2, cell_22);
  prsg_excel.line_cell_describe(line_2, cell_23);
  prsg_excel.line_cell_describe(line_2, cell_24);
  prsg_excel.line_cell_describe(line_2, cell_25);
  prsg_excel.line_cell_describe(line_2, cell_26);

  for prj in (select pr.code
                    ,pr.name_usl
                    ,'Справка по ' || pr.name_usl txt1
                    ,pr.name
                    ,pr.expected_res goal
                    ,pr.rn
                    ,pr.cost_sum_basecurr s
                from selectlist sl
                join project pr
                  on pr.rn = sl.document
               where sl.ident = pin_idn
                 and sl.authid = utilizer
                 and sl.unitcode = 'Projects')
  loop
    shn := substr(regexp_replace(prj.code || '-' || prj.name_usl, '[?:*/\\[\\]', ''), 1, 30);

    prsg_excel.sheet_copy(sh, shn);
    prsg_excel.sheet_select(shn);
    prsg_excel.cell_value_write(scell_name => cell_project_code, scell_value => prj.txt1);
    prsg_excel.cell_value_write(scell_name => cell_usl_name, scell_value => prj.name);
    prsg_excel.cell_value_write(scell_name => cell_project_goal, scell_value => prj.goal);
  
    idxd := null;
    V_DOG_SUM :=0;
    for dog in (select dt.doccode || ' №' || trim(dog.ext_number) || ' от ' ||
                       to_char(dog.doc_date, 'DD.MM.YYYY') || ' c ' || ag.agnname || cr ||
                       'Сроки с ' || to_char(dog.begin_date, 'DD.MM.YYYY') || ' по ' ||
                       to_char(dog.end_date, 'DD.MM.YYYY') dog_txt
                       ,dog.DOC_SUMTAX S
                  from doclinks dl
                  join CONTRACTS dog
                    on dog.rn = dl.out_document
                  join doctypes dt
                    on dt.rn = dog.doc_type
                  join agnlist ag
                    on ag.rn = dog.agent
                 where dl.in_document = prj.rn
                   and dl.out_unitcode = 'Contracts'
                   and dl.in_unitcode = 'Projects')
    loop
      V_DOG_SUM:=V_DOG_SUM+dog.S;
    
      idxd := prsg_excel.line_append(line_d);
      prsg_excel.cell_value_write(cell_dogovor, 0, idxd, dog.dog_txt);
    end loop;
  
    prsg_excel.line_delete(line_d);
  
    idxp := null; --- Пока одна стоимость, но их может быть несколько
  
    idxp := prsg_excel.line_append(line_p);
    prsg_excel.cell_value_write(cell_price
                               ,0
                               ,idxp
                               ,'Стоимость по контракту: ' ||
                                trim(to_char(V_DOG_SUM
                                            ,'999G999G999G999G999G999D99'
                                            ,'NLS_NUMERIC_CHARACTERS = '', ''')));
  
    prsg_excel.line_delete(line_p);
  
    --- Цикл по этапам проекта в которых есть НЕ просроченные этапы
  idx1 :=null;
  idx2 :=null;
  
    for et1 in (with pst as
                   (select dv.value_num n
                         ,dv.name      status
                     from dmsenumvalues dv
                    where dv.prn = 480982) --- Статус этапа проекта из домена
                  select ps.rn
                        ,pst.status
                        ,''''||trim(ps.numb) numb
                        ,ps.name
                        ,case when ps.begplan is null then '' else to_char(ps.begplan,'DD.MM.YYYY') end||cr||
                         case when ps.endplan is null then '' else to_char(ps.endplan,'DD.MM.YYYY') end PERIOD
                        ,ps.note   
                    from projectstage ps
                    join pst
                      on pst.n = ps.state
                   where ps.prn = prj.rn
                     and ps.hrn is null
                     and exists
                   (select null
                            from projectstage t
                           where (nvl(t.endplan, pin_date) <= nvl(t.endfact, pin_date) and t.state != 1) --- Все не открытые, но с плановой датой закрытия больше фактической даты закрытия
                              or (t.state = 1 and coalesce(t.endplan, pin_date) >= pin_date) -- Открытые, но с плановой датой закрытия после даты отчета 
                          connect by prior t.rn = t.hrn
                           start with t.rn = ps.rn)
                   order by ps.numb)
    loop
    
      if idx1 is null then
        idx1 := prsg_excel.line_append(line_1);
      else
        idx1 := prsg_excel.line_continue(line_1);
      end if;
    
      prsg_excel.cell_value_write(cell_11, 0, idx1, et1.numb);
      prsg_excel.cell_value_write(cell_12, 0, idx1, et1.name);
      prsg_excel.cell_value_write(cell_13, 0, idx1, et1.PERIOD);
      prsg_excel.cell_value_write(cell_14, 0, idx1, et1.STATUS);
      prsg_excel.cell_value_write(cell_16, 0, idx1, et1.NOTE);
    
      for l21 in (with pst as
                   (select dv.value_num n
                         ,dv.name      status
                     from dmsenumvalues dv
                    where dv.prn = 480982) --- Статус этапа проекта из домена
        select level
                        ,''''||trim(t.numb) numb
                        ,pst.status
                        ,T.Name
                        ,T.NOTE
                        ,t.rn
                        ,t.state
                        ,case when t.begplan is null then '' else to_char(t.begplan,'DD.MM.YYYY') end||cr||
                         case when t.endplan is null then '' else to_char(t.endplan,'DD.MM.YYYY') end PERIOD
                        
                    from projectstage t
                    join pst on T.State = PST.n
                   where  (nvl(t.endplan, pin_date) <= nvl(t.endfact, pin_date) and t.state != 1) --- Все не открытые, но с плановой датой закрытия больше фактической даты закрытия
                      or (t.state = 1 and coalesce(t.endplan, pin_date) >= pin_date) -- Открытые, но с плановой датой закрытия после даты отчета 
                  
                  connect by prior t.rn = t.hrn
                   start with t.rn = et1.rn)
      loop
        if l21.level > 1 then
          idx1 := prsg_excel.line_continue(line_1);
           prsg_excel.cell_value_write(cell_11, 0, idx1, L21.numb); --- Этап следующего уровня
          prsg_excel.cell_value_write(cell_12, 0, idx1, l21.name);
          prsg_excel.cell_value_write(cell_13, 0, idx1, l21.PERIOD);
          prsg_excel.cell_value_write(cell_14, 0, idx1, l21.STATUS);
          prsg_excel.cell_value_write(cell_16, 0, idx1, l21.NOTE);
        
        end if;
      end loop;
    
    end loop;
  
    --- Цикл по этапам проекта в которых есть НЕ просроченные этапы
  
    for et2 in (with pst as
                   (select dv.value_num n
                         ,dv.name      status
                     from dmsenumvalues dv
                    where dv.prn = 480982) --- Статус этапа проекта из домена
                  select ps.rn
                        ,pst.status
                        ,''''||trim(ps.numb) numb
                        ,ps.name
                        ,case when ps.begplan is null then '' else to_char(ps.begplan,'DD.MM.YYYY') end||cr||
                         case when ps.endplan is null then '' else to_char(ps.endplan,'DD.MM.YYYY') end PERIOD
                        ,ps.note
                    from projectstage ps
                    join pst
                      on pst.n = ps.state
                   where ps.prn = prj.rn
                     and ps.hrn is null
                     and exists
                   (select null
                            from projectstage t
                           where not ((nvl(t.endplan, pin_date) <= nvl(t.endfact, pin_date) and
                                  t.state != 1) --- Все не открытые, но с плановой датой закрытия больше фактической даты закрытия
                                  or (t.state = 1 and coalesce(t.endplan, pin_date) >= pin_date)) -- Открытые, но с плановой датой закрытия после даты отчета 
                          connect by prior t.rn = t.hrn
                           start with t.rn = ps.rn)
                   order by ps.numb)
    loop
    
      if idx2 is null then
        idx2 := prsg_excel.line_append(line_2);
      else
        idx2 := prsg_excel.line_continue(line_2);
      end if;
    
      prsg_excel.cell_value_write(cell_21, 0, idx2, et2.numb);
      prsg_excel.cell_value_write(cell_22, 0, idx2, et2.name);
      prsg_excel.cell_value_write(cell_23, 0, idx2, et2.PERIOD);
      prsg_excel.cell_value_write(cell_24, 0, idx2, et2.STATUS);
      prsg_excel.cell_value_write(cell_26, 0, idx2, et2.NOTE);
      
    
      for l22 in (with pst as
                   (select dv.value_num n
                         ,dv.name      status
                     from dmsenumvalues dv
                    where dv.prn = 480982) --- Статус этапа проекта из домена
        select level
                        ,''''||trim(t.numb) numb
                        ,pst.status
                        ,T.Name
                        ,T.NOTE
                        ,t.rn
                        ,t.state
                        ,case when t.begplan is null then '' else to_char(t.begplan,'DD.MM.YYYY') end||cr||
                         case when t.endplan is null then '' else to_char(t.endplan,'DD.MM.YYYY') end PERIOD
                        
                    from projectstage t
                    join pst on T.State = PST.n
                   where not (nvl(t.endplan, pin_date) <= nvl(t.endfact, pin_date) and t.state != 1) --- Все не открытые, но с плановой датой закрытия больше фактической даты закрытия
                      or (t.state = 1 and coalesce(t.endplan, pin_date) >= pin_date) -- Открытые, но с плановой датой закрытия после даты отчета 
                  
                  connect by prior t.rn = t.hrn
                   start with t.rn = et2.rn)
      loop
        if l22.level > 1 then
          idx2 := prsg_excel.line_continue(line_2);
          prsg_excel.cell_value_write(cell_21, 0, idx2, l22.numb); --- Этап следующего уровня
          prsg_excel.cell_value_write(cell_22, 0, idx2, l22.name);
          prsg_excel.cell_value_write(cell_23, 0, idx2, l22.PERIOD);
          prsg_excel.cell_value_write(cell_24, 0, idx2, l22.STATUS);
          prsg_excel.cell_value_write(cell_26, 0, idx2, l22.NOTE);
        
        end if;
      end loop;
    
    end loop;
  
    --- 
  
    prsg_excel.line_delete(line_1);
    prsg_excel.line_delete(line_2);
  
  end loop;

  prsg_excel.sheet_delete(sh);

end;
/
