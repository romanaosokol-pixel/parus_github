create or replace function usr_f_pcuso_get_tids_incl
/*
28/06/2024 Степанов М.
Сертификация / Входной контроль (результаты сертификации/ВК)
Функция возвращает количество в накладных в подразделения
create public synonym usr_f_pcuso_get_tids_incl for usr_f_pcuso_get_tids_incl;
grant execute on usr_f_pcuso_get_tids_incl to public;
*/
(
 nRN in number
)
return number
as
  nRES        pkg_std.tquant;
begin
  begin
    select sum(tids.quant)
      into nRES
      from doclinks           dl
          ,transinvdeptspecs  tids
     where dl.in_document   = nRN
       and dl.out_document  = tids.rn
    group by dl.in_document;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске для записи с RN: %s', nRN);
  end;

  return(nRES);

end usr_f_pcuso_get_tids_incl;
/
