create or replace procedure udo_p_tics_setlink_ini
/*
Инициализация параметров для формы процедуры udo_p_transinvcustsp_setlink
10/02/2026 Степанов М.
create public synonym udo_p_tics_setlink_ini for udo_p_tics_setlink_ini;
grant execute on udo_p_tics_setlink_ini to public;
*/
(
 nRN                in number
,nFACEACC           out number
)
is
  rRow              transinvcustspecs%rowtype;
  rTransInvCust     transinvcust%rowtype;
begin
  /* Считывание */
  rRow          := usr_pkg_transinvcust.transinvcustspecs_get( nrn => nRN );
  rTransInvCust := usr_pkg_transinvcust.transinvcust_get( nrn => rRow.prn );

  /* Присвоение результатов */
  nFACEACC := rTransInvCust.faceacc;

end;
/
