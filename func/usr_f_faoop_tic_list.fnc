create or replace function usr_f_faoop_tic_list
/*
Лицевые счета (план расхода)
Функция для колонки "#Расходные накладные потребителям"
17/02/2025 Степанов М. Переделка на калькуляции
grant execute on usr_f_faoop_tic_list to public;
*/
(
 nRN in number
)
return varchar
is
  sRes pkg_std.tstring;
begin
  begin
    select listagg( pkg_document.make_number( ndoc_type => tic.doctype, sdoc_pref => tic.pref, sdoc_numb => tic.numb, ddoc_date => tic.docdate ), ';') within group (order by t.rn)
      into sRes
      from fcacoperplans t
      join trinvcustclc       ticsc on ticsc.graphpoint = t.graphpoint
      join transinvcustspecs  tics  on tics.rn     = ticsc.prn
      join transinvcust       tic   on tic.rn      = tics.prn
                                   and tic.status  = 1
     where t.rn = nRN;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация. RN <%s> в разделе <%s>.', nRN );
  end;

  return( usr_pkg_common.get_list_distinct( sRes, ', ' ) );

end;
/
