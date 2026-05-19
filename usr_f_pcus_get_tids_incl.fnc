create or replace function usr_f_pcus_get_tids_incl
/*
28/06/2024 Степанов М.
Сертификация / Входной контроль (передано на сертификацию/ВК)
Функция возвращает количество в накладных в подразделения
create public synonym usr_f_pcus_get_tids_incl for usr_f_pcus_get_tids_incl;
grant execute on usr_f_pcus_get_tids_incl to public;
*/
(
 nRN in number
)
return number
as
  nRES        pkg_std.tquant;
begin
  begin
    select sum(usr_f_pcuso_get_tids_incl(nRN => t.rn))
      into nRES
      from udo_prod_cull_out  t
     where t.prn = nRN;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске для записи с RN: %s', nRN);
  end;

  return(nRES);

end usr_f_pcus_get_tids_incl;
/
