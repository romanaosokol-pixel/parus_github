create or replace procedure usr_p_prod_cull_out_ini
/*
Сертификация/Входной контроль. Результаты сертификации/ВК.
Инициализация параметров для формы
15/10/2025 Степанов М.
create public synonym usr_p_prod_cull_out_ini for usr_p_prod_cull_out_ini;
grant execute on usr_p_prod_cull_out_ini to public;
*/
(
 nRN                in number
,sCHECK_TYPES       out varchar
,sCHECK_DEFECTIVE   out varchar
,sMEAS_PARAMS       out varchar
)
is
  rProd_Cull_Out  udo_prod_cull_out%rowtype;
begin
  /* Считывание */
  rProd_Cull_Out := usr_pkg_prod_cull.prod_cull_out_get( nrn => nRN );

  /* Присвоение результатов */
  sCHECK_TYPES     := rProd_Cull_Out.check_types;
  sCHECK_DEFECTIVE := rProd_Cull_Out.check_defective;
  sMEAS_PARAMS     := rProd_Cull_Out.meas_params;
end;
/
