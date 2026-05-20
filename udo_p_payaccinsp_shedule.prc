create or replace procedure UDO_P_PAYACCINSP_SHEDULE
/*
19/04/2024 Марков МВ.
Входящие счета на оплату (спецификация, график поставки)
Даты начала и окончания графика поставки
*/

(
 nRN    in number
,dBEG   out date
,dEND   out date
)
as
begin
  for rec in (select shd.in_date
                from udo_payaccinspec_shedule shd
               where shd.prn = nRN
              order by shd.in_date)
  loop
    if dBEG is null then
      dBEG := rec.in_date;
    end if;

    if dEND is null
    or rec.in_date > dEND then
      dEND := rec.in_date;
    end if;

  end loop;

end;
/
