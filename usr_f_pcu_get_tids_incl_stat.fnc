create or replace function usr_f_pcu_get_tids_incl_stat
/*
28/06/2024 Степанов М.
Сертификация / Входной контроль (передано на сертификацию/ВК)
Функция возвращает сформированы накладные в подразделения
create public synonym usr_f_pcu_get_tids_incl_stat for usr_f_pcu_get_tids_incl_stat;
grant execute on usr_f_pcu_get_tids_incl_stat to public;
*/
(
 nRN in number
)
return varchar2
as
  sRES        pkg_std.tstring;
begin
  begin
    select case
             when nvl(sum(usr_f_pcus_get_tids_incl(t.rn)), 0) = 0                    then 'Нет'
             when nvl(sum(t.quant), 0) > nvl(sum(usr_f_pcus_get_tids_incl(t.rn)), 0) then 'Частично'
             when nvl(sum(t.quant), 0) = nvl(sum(usr_f_pcus_get_tids_incl(t.rn)), 0) then 'Полностью'
           else 'Не определён'
           end
      into sRES
      from udo_prod_cull_sp   t
          ,udo_prod_cull_out  o
     where t.prn  = nRN
       and o.prn  = t.rn;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске для записи с RN: %s', nRN);
  end;

  return(sRES);

end usr_f_pcu_get_tids_incl_stat;
/
