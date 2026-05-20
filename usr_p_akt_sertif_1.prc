create or replace procedure usr_p_akt_sertif_1
(
  pin_idn in selectlist.ident%type
 ,pin_uni in varchar2
) is

  cell_1 constant pkg_std.tstring := 'CELL_1';
  cell_2 constant pkg_std.tstring := 'CELL_2';
  cell_3 constant pkg_std.tstring := 'CELL_3';
  cell_4 constant pkg_std.tstring := 'CELL_4';
  cell_5 constant pkg_std.tstring := 'CELL_5';
  cell_6 constant pkg_std.tstring := 'CELL_6';

  -- Строка
  line_1 constant pkg_std.tstring := 'line_1';
  idx integer;

  sh constant pkg_std.tstring := 'X';

begin
  prsg_excel.prepare;
  prsg_excel.sheet_select(sh);
  prsg_excel.line_describe(sline_name => line_1);

  prsg_excel.line_cell_describe(sline_name => line_1, scell_name => cell_1);
  prsg_excel.line_cell_describe(sline_name => line_1, scell_name => cell_2);
  prsg_excel.line_cell_describe(sline_name => line_1, scell_name => cell_3);
  prsg_excel.line_cell_describe(sline_name => line_1, scell_name => cell_4);
  prsg_excel.line_cell_describe(sline_name => line_1, scell_name => cell_5);
  prsg_excel.line_cell_describe(sline_name => line_1, scell_name => cell_6);

  for spe in (
              
              select gp.sernumb
                     ,dn.nomen_name
                     ,coalesce((select name
                                 from fcmatresource fc
                                where fc.nomen_modif = sp.nommodif
                                  and rownum = 1)
                              ,dn.nomen_name) mr_name
                     ,usr_pkg_common.frac_part_number(sp.quant, 0, 3) || ' ' || ei.meas_mnemo q_oei
                     ,dt.doccode || ' №' || trim(t.pref) || '-' || trim(t.numb) || ' от ' ||
                      to_char(t.docdate, 'DD.MM.YYYY') nakl
              , atr.f_value
                from selectlist sl
                join transinvdept t
                  on t.rn = sl.document
                join transinvdeptspecs sp
                  on t.rn = sp.prn
                join goodsparties gp
                  on gp.rn = sp.goodsparty
                join nommodif nm
                  on nm.rn = gp.nommodif
                join dicnomns dn
                  on dn.rn = nm.prn
                join dicmunts ei
                  on ei.rn = dn.umeas_main
                left join doctypes dt
                  on dt.rn = t.doctype
                 left join UDO_MODIF_ATTR ATR on atr.prn = nm.rn and atr.attribute_code = 'Класс' 
              
               where sl.ident = pin_idn
                 and sl.unitcode = pin_uni
                 and sl.authid = utilizer)
  
  loop
    idx := prsg_excel.line_append(sline_name => line_1);
  
    prsg_excel.cell_value_write(scell_name    => cell_1
                               ,icell_index_x => 0
                               ,icell_index_y => idx
                               ,ncell_value   => idx);
  
    prsg_excel.cell_value_write(scell_name    => cell_2
                               ,icell_index_x => 0
                               ,icell_index_y => idx
                               ,scell_value   => spe.f_value);
  
    prsg_excel.cell_value_write(scell_name    => cell_3
                               ,icell_index_x => 0
                               ,icell_index_y => idx
                               ,scell_value   => replace(spe.mr_name,spe.f_value,''));
  
    prsg_excel.cell_value_write(cell_4, 0, idx, spe.sernumb);
    prsg_excel.cell_value_write(cell_5, 0, idx, spe.q_oei);
    prsg_excel.cell_value_write(cell_6, 0, idx, spe.nakl);
  
  end loop;

  prsg_excel.line_delete(line_1);

end;
/
