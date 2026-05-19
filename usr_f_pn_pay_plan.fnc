create or replace function USR_F_PN_PAY_PLAN
/*
03/09/2024 Степанов М.
Раздел "Журнал платежей".
Функция для колонки "#Плановый платёж"
grant execute on USR_F_PN_PAY_PLAN to public;
*/
(
 sPAY_PLAN_PREFIX   in varchar2
,sPAY_PLAN_NUMBER   in varchar2
)
return varchar2
as
begin
  return pkg_document.make_number(sdoc_pref => sPAY_PLAN_PREFIX, sdoc_numb => sPAY_PLAN_NUMBER);
end USR_F_PN_PAY_PLAN;
/
