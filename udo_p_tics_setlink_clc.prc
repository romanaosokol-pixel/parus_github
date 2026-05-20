create or replace procedure udo_p_tics_setlink_clc
/*
Расчёт значений параметров для формы процедуры udo_p_transinvcustsp_setlink
10/02/2026 Степанов М.
create public synonym udo_p_tics_setlink_clc for udo_p_tics_setlink_clc;
grant execute on udo_p_tics_setlink_clc to public;
*/
(
 nFAOOP           in number
,sFAOOP           out varchar2
)
is
begin
  /* Присвоение результатов */
  sFAOOP := f_docdescrs_get_description( sunitcode => 'FaceAccountsOperOutPlans', ndocument => nFAOOP);
end;
/
