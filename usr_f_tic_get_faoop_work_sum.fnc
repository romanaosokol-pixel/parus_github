create or replace function usr_f_tic_get_faoop_work_sum
/*
20/02/2026 Степанов М.
Раздел "Расходные накладные на отпуск потребителям"
Функция для колонки "#Отработано в графиках отпуска (сумма)"
create public synonym usr_f_tic_get_faoop_work_sum for usr_f_tic_get_faoop_work_sum;
grant execute on usr_f_tic_get_faoop_work_sum to public;
*/
(
 nRN            in number
)
return varchar2
is
  nCalc_Sum     pkg_std.tsumm;
  nSpec_Sum     pkg_std.tsumm;

  sResult   pkg_std.tstring;
begin
   select nvl( sum( a.nCalc_Sum ), 0 ), nvl( sum( a.nSpec_Sum ), 0 )
    into nCalc_Sum, nSpec_Sum
    from ( select tics.summwithnds as nSpec_Sum
                 ,( select sum( quant_plan * cost_plan ) from trinvcustclc where prn = tics.rn ) as nCalc_Sum
             from transinvcustspecs tics
            where tics.prn = nRN ) a ;

  if nCalc_Sum = 0 then
    sResult := 'Нет';
  elsif nCalc_Sum = nSpec_Sum then
    sResult := 'Полностью';
  elsif nCalc_Sum < nSpec_Sum then
    sResult := 'Не полностью';
  elsif nCalc_Sum > nSpec_Sum then
    sResult := 'С превышением';
  else
    sResult := 'Не определёно';
  end if;

  return sResult;

end;
/
