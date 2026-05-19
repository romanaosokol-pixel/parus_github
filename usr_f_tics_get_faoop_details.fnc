create or replace function usr_f_tics_get_faoop_details
/*
04/02/2025 Степанов М.
Раздел "Расходные накладные на отпуск потребителям (спецификации)"
Функция возвращает список графиков отпуска, к которым относится спецификация
create public synonym usr_f_tics_get_faoop_details for usr_f_tics_get_faoop_details;
grant execute on usr_f_tics_get_faoop_details to public;
*/
(
 nRN            in number
)
return varchar2
is
  sResult   pkg_std.tstring;
begin
  for c in ( select fcacoperplans from udo_t_transinvcustspecs_ex where prn = nRN )
  loop
    sResult := strcombine(sleft => sResult, sright => f_docdescrs_get_description(sunitcode => 'FaceAccountsOperOutPlans', ndocument => c.fcacoperplans), sdelimeter => ', ');
  end loop;

  return sResult;

end;
/
