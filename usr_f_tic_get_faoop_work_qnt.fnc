create or replace function usr_f_tic_get_faoop_work_qnt
/*
20/02/2026 Степанов М.
Раздел "Расходные накладные на отпуск потребителям"
Функция для колонки "#Отработано в графиках отпуска (количество)"
create public synonym usr_f_tic_get_faoop_work_qnt for usr_f_tic_get_faoop_work_qnt;
grant execute on usr_f_tic_get_faoop_work_qnt to public;
*/
(
 nRN            in number
)
return varchar2
is
  nCalc_Quant     pkg_std.tquant;
  nSpec_Quant     pkg_std.tquant;

  sResult   pkg_std.tstring;
begin
   select nvl( sum( a.nCalc_Quant ), 0 ), nvl( sum( a.nSpec_Quant ), 0 )
    into nCalc_Quant, nSpec_Quant
    from ( select tics.quant as nSpec_Quant
                 ,( select sum( quant_plan ) from trinvcustclc where prn = tics.rn ) as nCalc_Quant
             from transinvcustspecs tics
            where tics.prn = nRN ) a ;

  if nCalc_Quant = 0 then
    sResult := 'Нет';
  elsif nCalc_Quant = nSpec_Quant then
    sResult := 'Полностью';
  elsif nCalc_Quant < nSpec_Quant then
    sResult := 'Не полностью';
  elsif nCalc_Quant > nSpec_Quant then
    sResult := 'С превышением';
  else
    sResult := 'Не определёно';
  end if;

  return sResult;

end;
/
