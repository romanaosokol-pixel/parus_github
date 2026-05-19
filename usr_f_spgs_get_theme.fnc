create or replace function usr_f_spgs_get_theme
/*
Места хранения товарного запаса
Функция для колонки "#Тема"
14/10/2024 Степанов М.
grant execute on usr_f_spgs_get_theme to public;
*/
(
 nGOODSSUPPLY   in number
)
return varchar2
as
begin
  return udo_f_goodssplclc_shefr(nrn => nGOODSSUPPLY);
end;
/
