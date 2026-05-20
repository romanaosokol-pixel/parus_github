create or replace procedure usr_p_rep_stpc_barcode2
/*
24/09/2022 Степанов М.
Процедура для отчёта "Места хранения со штрих-кодами (формат для склада ДСЕ)".
*/
(
 nIDENT             in number
)
as
  sline01     constant varchar2(40) := '_sline01';
  scell       constant varchar2(40) := '_s';
  nCount      pkg_std.tnumber := 0;

  n           pkg_std.tnumber;
begin
  /* Подготовка, добавления листа, строки, описание ячеек */
  prsg_excel.prepare;
  prsg_excel.sheet_select('Sheet1');
  prsg_excel.line_describe(sline01);
  for Idx in 11 .. 26 loop
    prsg_excel.line_cell_describe(sline01, scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* По отмеченным записям */
  for c in ( select t.rn, trim(t.numb) as sname
               from selectlist  sl
                   ,stplcells   t
              where sl.ident = nIdent
                and t.rn     = sl.document )
  loop
    nCount := nCount + 1;
    /* Счётчик колонок */
    case nCount
      /* Первая колонка */
      when 1 then
        /* добавление строки */
        n := prsg_excel.line_append(sline01);
        /* заполнение ячеек */
        prsg_excel.cell_value_write(scell||'011', 0, n, c.sname);
        prsg_excel.cell_value_write(scell||'024', 0, n, c.rn);
      /* Вторая колонка */
      when 2 then
        /* заполнение ячеек */
        prsg_excel.cell_value_write(scell||'012', 0, n, c.sname);
        prsg_excel.cell_value_write(scell||'025', 0, n, c.rn);
      /* Третья колонка */
      when 3 then
        /* заполнение ячеек */
        prsg_excel.cell_value_write(scell||'013', 0, n, c.sname);
        prsg_excel.cell_value_write(scell||'026', 0, n, c.rn);
        /* сброс счётчика */
        nCount := 0;
    else
      p_exception(0, 'Неверное значение <%s> счётчика.', nCount);
    end case;
  end loop;

  /* Очистка */
  prsg_excel.line_delete(sline01);

end;
/
