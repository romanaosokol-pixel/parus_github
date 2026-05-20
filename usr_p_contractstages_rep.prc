create or replace procedure usr_p_contractstages_rep
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

  v_dog_sum number(17, 2) := 0;

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
                    ,dog.rn dog_rn
                    ,dog.ext_number
                from selectlist sl
                join contracts dog
                  on dog.rn = sl.document
                left join doclinks dl
                  on dl.out_document = dog.rn
                 and dl.in_unitcode = 'Projects'
                 and dl.out_unitcode = sl.unitcode
                left join project pr
                  on pr.rn = dl.in_document
               where sl.ident = pin_idn
                 and sl.authid = utilizer
                 and sl.unitcode = 'Contracts')
  loop
    shn := substr(regexp_replace(prj.ext_number || '-' || prj.dog_rn, '[?:*/\\[\\]', ''), 1, 30);
    prsg_excel.sheet_copy(sh, shn);
    prsg_excel.sheet_select(shn);
    prsg_excel.cell_value_write(scell_name => cell_project_code, scell_value => prj.txt1);
    prsg_excel.cell_value_write(scell_name => cell_usl_name, scell_value => prj.name);
    prsg_excel.cell_value_write(scell_name => cell_project_goal, scell_value => prj.goal);
    
    
  
    idxd      := null;
    v_dog_sum := 0;
    for dog in (select dt.doccode || ' №' || trim(dog.ext_number) || ' от ' ||
                       to_char(dog.doc_date, 'DD.MM.YYYY') || ' c ' || ag.agnname || cr ||
                       'Сроки с ' || to_char(dog.begin_date, 'DD.MM.YYYY') || ' по ' ||
                       to_char(dog.end_date, 'DD.MM.YYYY') dog_txt
                      ,dog.doc_sumtax s
                  from contracts dog
                  join doctypes dt
                    on dt.rn = dog.doc_type
                  join agnlist ag
                    on ag.rn = dog.agent
                 where dog.rn = prj.dog_rn)
    loop
      v_dog_sum := v_dog_sum + dog.s;
    
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
                                trim(to_char(v_dog_sum
                                            ,'999G999G999G999G999G999D99'
                                            ,'NLS_NUMERIC_CHARACTERS = '', ''')));
  
    prsg_excel.line_delete(line_p);
  
    --- Цикл по этапам проекта в которых есть НЕ просроченные этапы
    idx1 := null;
    idx2 := null;
  
   
    
      for et1 in (select st.rn
                      ,case st.status
                         when 0 then
                          'Закрыт'
                         when 1 then
                          'Открыт'
                         when 2 then
                          'Аннулирован'
                         when 3 then
                          'Согласован'
                         else
                          '---'
                       end status
                      ,'''' || trim(st.numb) numb
                      ,case
                         when st.description is not null then
                          st.description || ' ' || st.comments
                         else
                          st.comments
                       end name
                      ,'с ' || to_char(st.begin_date, 'DD.MM.YYYY') || ' по ' ||
                       to_char(st.end_date, 'DD.MM.YYYY') period
                      ,st.comments note
                  from stages st
                 where st.prn = prj.dog_rn
                 and ((st.status = 0 and nvl(usr_pkg_docs_props_vals.get_val_date(nDOC_PROP => 7526416, nDOCUMENT => st.rn), st.end_date) <= st.end_date)
                       or 
                     (st.status in (1,3) and  nvl(usr_pkg_docs_props_vals.get_val_date(nDOC_PROP => 7526416, nDOCUMENT => st.rn), st.end_date) >= pin_date))
                      
                 
                 order by st.numb)
      loop
        if idx1 is null then 
          idx1 := prsg_excel.line_append(line_1);
          else
          idx1 := prsg_excel.line_continue(line_1);
        end if;  
          
          
          prsg_excel.cell_value_write(cell_11, 0, idx1, et1.numb); --- Этап следующего уровня
          prsg_excel.cell_value_write(cell_12, 0, idx1, et1.name);
          prsg_excel.cell_value_write(cell_13, 0, idx1, et1.period);
          prsg_excel.cell_value_write(cell_14, 0, idx1, et1.status);
          prsg_excel.cell_value_write(cell_16, 0, idx1, et1.note);
        
        
     
    
    end loop;
  
    --- Цикл по этапам проекта в которых есть НЕ просроченные этапы
  
    for et2 in (select st.rn
                      ,case st.status
                         when 0 then
                          'Закрыт'
                         when 1 then
                          'Открыт'
                         when 2 then
                          'Аннулирован'
                         when 3 then
                          'Согласован'
                         else
                          '---'
                       end status
                      ,'''' || trim(st.numb) numb
                      ,case
                         when st.description is not null then
                          st.description || ' ' || st.comments
                         else
                          st.comments
                       end name
                      ,'с ' || to_char(st.begin_date, 'DD.MM.YYYY') || ' по ' ||
                       to_char(st.end_date, 'DD.MM.YYYY') period
                      ,st.comments note
                  from stages st
                 where st.prn = prj.dog_rn
                 and not (((st.status = 0 and nvl(usr_pkg_docs_props_vals.get_val_date(nDOC_PROP => 7526416, nDOCUMENT => st.rn), st.end_date) <= st.end_date)
                       or 
                     (st.status in (1,3) and  nvl(usr_pkg_docs_props_vals.get_val_date(nDOC_PROP => 7526416, nDOCUMENT => st.rn), st.end_date) >= pin_date))
                     )
                      
                 
                 order by st.numb)
    loop
    
     if idx2 is null then 
          idx2 := prsg_excel.line_append(line_2);
          else
          idx2 := prsg_excel.line_continue(line_2);
        end if;  
    
      prsg_excel.cell_value_write(cell_21, 0, idx2, et2.numb);
      prsg_excel.cell_value_write(cell_22, 0, idx2, et2.name);
      prsg_excel.cell_value_write(cell_23, 0, idx2, et2.period);
      prsg_excel.cell_value_write(cell_24, 0, idx2, et2.status);
      prsg_excel.cell_value_write(cell_26, 0, idx2, et2.note);
    
         
    end loop;
  
    --- 
  
    prsg_excel.line_delete(line_1);
    prsg_excel.line_delete(line_2);
  
  end loop;

  prsg_excel.sheet_delete(sh);

end;
/
