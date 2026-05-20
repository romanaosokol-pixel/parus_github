create or replace function usr_f_faoop_rest_sum_out_tax
/*
  Функция для колонки - #Осталось отгрузить (сумма БЕЗ налогов)
  
  28/01/2026 Городецкий
  */
(nrn   in fcacoperplans.rn%type
,nsumm in fcacoperplans.summ%type) return number is
  nres pkg_std.tnumber;
begin
  select sum(trs.summ)
    into nres
    from udo_t_transinvcustspecs_ex ex
    join transinvcustspecs trs
      on trs.rn = ex.prn
   where ex.fcacoperplans = nrn;

  return(nsumm - nvl(nres, 0));

end;
/
