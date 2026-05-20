create or replace function USR_F_FAOOP_REST_SUM_WITH_TAX
/*
Функция для колонки - #Осталось отгрузить (сумма с налогами)
grant execute on usr_f_faoop_rest_sum_with_tax to public;
10/07/2025 Степанов М.
*/
(
 nRN            in number
,nSUMMWITHNDS   in number
)
return number
is
  nRes pkg_std.tsumm;
begin
  select sum( trs.summwithnds )
    into nRes
    from udo_t_transinvcustspecs_ex ex
    join transinvcustspecs          trs
      on trs.rn           = ex.prn
   where ex.fcacoperplans = nRN;

  return( nSUMMWITHNDS - nvl( nRes, 0 ) );

end;
/
