create or replace function USR_F_FCROUTLST_SERNUMB
/*
Функция возвращает заводские номера маршрутного листа с периодами
14/05/2024 Степанов М.
grant execute on usr_f_fcroutlst_sernumb to public;
*/
(
 nRN    in number
)
return varchar2
is
  sRes    pkg_std.tstring; 
begin
  /* Формирование списка */
  select listagg(usr_pkg_rlarticles.rlarticles_get_short_numb(snumb => rla.code), ';') within group (order by rla.code)
    into sRes
    from fcroutlstsernumb  fls
        ,rlarticles        rla 
   where fls.prn     = nRN
     and fls.article = rla.rn;

  /* Список не пустой */
  if sRes is not null then
    /* Преобразование в список с последовательностями */
    sRes := usr_pkg_common.make_period_from_list(slist => sRes);
  end if;

  return(sRes);

end USR_F_FCROUTLST_SERNUMB;
/
