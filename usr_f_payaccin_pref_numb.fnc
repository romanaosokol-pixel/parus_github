create or replace function USR_F_PAYACCIN_PREF_NUMB
/*
18/08/2023 Степанов М.
Раздел "Входящие счета на оплату".
Функция для колонки "Префикс-номер"
grant execute on USR_F_PAYACCIN_PREF_NUMB to public;
*/
(
 SDOC_PREF  in varchar2
,SDOC_NUMB  in varchar2
)
return varchar2
as
begin
  return trim(SDOC_PREF)||'-'||trim(SDOC_NUMB);
end USR_F_PAYACCIN_PREF_NUMB;
/
