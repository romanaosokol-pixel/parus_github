create or replace procedure usr_p_export_contracts_1
(
  pin_com in number
 ,pin_cat in varchar2
) is

  ch     constant pkg_std.tstring := 'X';
  line_1 constant pkg_std.tstring := 'LINE_1';
  cell_1 constant pkg_std.tstring := 'CELL_1';
  cell_2 constant pkg_std.tstring := 'CELL_2';
  cell_3 constant pkg_std.tstring := 'CELL_3';
  cell_4 constant pkg_std.tstring := 'CELL_4';
  cell_5 constant pkg_std.tstring := 'CELL_5';
  cell_8 constant pkg_std.tstring := 'CELL_8';
  cell_9 constant pkg_std.tstring := 'CELL_9';

  idx integer;

begin

  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);
  prsg_excel.line_describe(line_1);
  prsg_excel.line_cell_describe(line_1, cell_1);
  prsg_excel.line_cell_describe(line_1, cell_2);
  prsg_excel.line_cell_describe(line_1, cell_3);
  prsg_excel.line_cell_describe(line_1, cell_4);
  prsg_excel.line_cell_describe(line_1, cell_5);
  prsg_excel.line_cell_describe(line_1, cell_8);
  prsg_excel.line_cell_describe(line_1, cell_9);

  for cur in (with cat as
                 (select a.rn
                   from acatalog a
                  where a.docname = 'Contracts'
                    and a.company = pin_com
                 connect by prior a.rn = a.crn
                  start with a.name = pin_cat)
                select dog.subject
                      ,my.agnname my
                      ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 6454955
                                                          ,ndocument => dog.rn) customer
                      ,cu.agnname
                      ,dt.doccode || ' ' || trim(dog.doc_pref) || '-' || trim(dog.doc_numb) ||
                       ' от  ' || to_char(dog.doc_date) dog_nmb
                      ,dog.ext_number
                
                  from cat
                  join contracts dog
                    on dog.crn = cat.rn
                  join jurpersons j
                    on j.rn = dog.jur_pers
                  join agnlist my
                    on my.rn = j.agent
                  join agnlist cu
                    on cu.rn = dog.agent
                  join doctypes dt
                    on dt.rn = dog.doc_type
                 where dog.status != 2 -- Все незакрытые
              )
  loop
  
    idx := prsg_excel.line_continue(line_1);
    prsg_excel.cell_value_write(cell_1, 0, idx, idx);
    prsg_excel.cell_value_write(cell_2, 0, idx, cur.subject);
    prsg_excel.cell_value_write(cell_3, 0, idx, cur.my);
    prsg_excel.cell_value_write(cell_4, 0, idx, cur.customer);
    prsg_excel.cell_value_write(cell_5, 0, idx, cur.agnname);
    prsg_excel.cell_value_write(cell_8, 0, idx, cur.dog_nmb);
    prsg_excel.cell_value_write(cell_9, 0, idx, cur.ext_number);
  
  end loop;

  prsg_excel.line_delete(line_1);

end;
/
