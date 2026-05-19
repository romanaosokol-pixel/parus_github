create or replace function usr_f_pn_get_ct_rn
/*
02/03/2026 Степанов М.
Раздел "Журнал платежей".
Функция для колонки "#Договор (RN)"
grant execute on usr_f_pn_get_ct_rn to public;
*/
(
 nFACEACC   in number
)
return varchar2
as
  nRef    pkg_std.tref;
begin
  begin
    select prn
      into nRef
      from stages
     where faceacc = nFACEACC;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,nFACEACC ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'PAYNOTES' ) ) );
  end;

  return nRef;

end;
/
