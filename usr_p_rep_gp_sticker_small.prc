create or replace procedure usr_p_rep_gp_sticker_small
/*
03/10/2024 Степанов М.
Процедура для отчёта "Этикетки маленькие".
*/
(
 nIDENT             in number
,sUNITCODE          in varchar2
)
as
  sline01     constant varchar2(40) := '_sline01';
  scell       constant varchar2(40) := '_s';

  n           pkg_std.tnumber;
begin
  /* Подготовка, добавления листа, строки, описание ячеек */
  prsg_excel.prepare;
  prsg_excel.sheet_select('Sheet1');
  prsg_excel.line_describe(sline01);
  for Idx in 11 .. 14 loop
    prsg_excel.line_cell_describe(sline01, scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* Приходные партии товара */
  if sUNITCODE in ('GoodsParties', 'GoodsSupply') then
    /* По отмеченным записям */
    for c in ( select t.nrn, t.snomenname, t.snommodifname, t.ssernumb
                 from selectlist sl, v_goodsparties t
                where sl.ident  = nIdent
                  and (
                       ( t.nrn = sl.document and sl.unitcode = 'GoodsParties' ) /* Приходные партии товара */
                    or ( t.nrn in ( select gs.prn
                                      from goodssupply     gs
                                          ,goodssupplyhist gsh 
                                     where gsh.rn  = sl.document
                                       and gs.rn   = gsh.prn
                                    /* для вызова из нестандартных разделов (комплектовочные ведомостт и т.д.) */   
                                    union
                                    select gs.prn
                                      from goodssupply gs
                                     where gs.rn = sl.document )
                         and sl.unitcode = 'GoodsSupply' )     /* Товарные запасы */
                      )  
             ) 
    loop
      n := prsg_excel.line_append(sline01);
      prsg_excel.cell_value_write(scell||'011', 0, n, c.nrn);
      prsg_excel.cell_value_write(scell||'012', 0, n, c.snomenname);
      prsg_excel.cell_value_write(scell||'013', 0, n, c.snommodifname);
      prsg_excel.cell_value_write(scell||'014', 0, n, c.ssernumb);
    end loop;

  /* Товарные запасы по местам хранения (товарные запасы) */
  elsif sUNITCODE in ('StoragePlacesGoodsSupply') then
    /* По отмеченным записям */
    for c in ( select t.ngoodsparty, t.snomenname, t.snommodifname, t.ssernumb
                 from selectlist  sl
                 inner join v_stplgoodssupply_rackcells t on t.nhs  = sl.document
                where sl.ident = nIdent )
    loop
      n := prsg_excel.line_append(sline01);
      prsg_excel.cell_value_write(scell||'011', 0, n, c.ngoodsparty);
      prsg_excel.cell_value_write(scell||'012', 0, n, c.snomenname);
      prsg_excel.cell_value_write(scell||'013', 0, n, c.snommodifname);
      prsg_excel.cell_value_write(scell||'014', 0, n, c.ssernumb);
    end loop;
  end if;

  /* Очистка */
  prsg_excel.line_delete(sline01);

end;
/
