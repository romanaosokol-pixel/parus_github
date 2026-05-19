create or replace function usr_f_tic_get_faoop_status
/*
04/02/2025 Степанов М.
Раздел "Расходные накладные на отпуск потребителям (спецификации)"
Функция возвращает список графиков отпуска, к которым относится спецификация
create public synonym usr_f_tic_get_faoop_status for usr_f_tic_get_faoop_status;
grant execute on usr_f_tic_get_faoop_status to public;
*/
(
 nRN            in number
)
return varchar2
is
  nTotal    pkg_std.tnumber;
  nLinked   pkg_std.tnumber;

  sResult   pkg_std.tstring;
begin
  select (
          select count(*)
            from transinvcustspecs tics
           where tics.prn = nRN
         )
        ,(
          select count(*)
           from transinvcustspecs          tics
               ,udo_t_transinvcustspecs_ex t
          where tics.prn = nRN
            and t.prn = tics.rn
         )
    into nTotal, nLinked
    from dual;

  if nLinked = 0 then
    sResult := 'Нет';
  elsif nLinked = nTotal then
    sResult := 'Полностью';
  else
    sResult := 'Частично';
  end if;

  return sResult;

end;
/
