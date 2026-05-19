create or replace function usr_f_mark_unitname(nrn udo_t_mark.rn%type) return varchar2 is

  sres varchar2(2000) := ';';
begin
  /* Колонка в раздел Бюджетирование.Показатели  Выводит все наименования разделов источника из соотв. спецификации */

  for cur in (select ul.unitname
                from udo_t_mark t
                join udo_t_mark_src ts
                  on ts.prn = t.rn
                join unitlist ul
                  on ul.unitcode = ts.src_unit
               where t.rn = nrn)
  loop
  
    if length(sres) < 1700 then
      sres := ';' || cur.unitname;
    end if;
  
  end loop;

  return substr(sres, 2);

end;

  ----grant execute on usr_f_mark_unitname to public;
/
