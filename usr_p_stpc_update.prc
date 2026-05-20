create or replace procedure usr_p_stpc_update
/*
Раздел: "Места хранения (ячейки)"
Процедура: Исправить.
22/05/2025 Степанов М.
*/
(
 nRN                  in number
,nIS_AVAIL            in number     /* признак доступности места для размещения чего-либо (0 - недоступно, 1 - доступно) */
)
is
  rV_Row          v_stplcells%rowtype;

  sVarchar        pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_STPC_UPDATE');

  /* Считывание текущей записи */
  begin select * into rV_Row from v_stplcells where nrn = usr_p_stpc_update.nrn; end;

  /* Проверка параметров */
  if nIS_AVAIL is null then
    p_exception(0, 'Не заполнен входной параметр "nIS_AVAIL".' );
  elsif nIS_AVAIL not in (0, 1) then
    p_exception(0, 'Неверное значение "%s" входного параметра "nIS_AVAIL".', nIS_AVAIL );
  end if;

  /* Подмена значений параметров (переворачиваем входное значение 0/1) */
  rV_Row.nis_avail := case nIS_AVAIL when 0 then 1 else 0 end;

  /* Исправление */
  p_stplcells_update(nrn           => rV_Row.nrn
                    ,ncompany      => rV_Row.ncompany
                    ,szone         => rV_Row.szone
                    ,splace        => rV_Row.splace
                    ,spref         => rV_Row.spref
                    ,snumb         => rV_Row.snumb
                    ,ntier         => rV_Row.ntier
                    ,nwidth        => rV_Row.nwidth
                    ,ndepth        => rV_Row.ndepth
                    ,nheight       => rV_Row.nheight
                    ,nmaxweight    => rV_Row.nmaxweight
                    ,nis_avail     => rV_Row.nis_avail
                    ,nmu_size      => rV_Row.nmu_size
                    ,nmu_weight    => rV_Row.nmu_weight
                    ,nhorz_offset  => rV_Row.nhorz_offset
                    ,nvert_offset  => rV_Row.nvert_offset
                    ,npart_rmv     => rV_Row.npart_rmv
                    ,nfull_fill    => rV_Row.nfull_fill
                    ,ndiff_knd     => rV_Row.ndiff_knd
                    ,ntemp_from    => rV_Row.ntemp_from
                    ,ntemp_to      => rV_Row.ntemp_to
                    ,nhumid_from   => rV_Row.nhumid_from
                    ,nhumid_to     => rV_Row.nhumid_to
                    ,sbarcode      => rV_Row.sbarcode
                    ,nunload_place => rV_Row.nunload_place
                    ,nship_place   => rV_Row.nship_place
                    ,ncur_weight   => rV_Row.ncur_weight);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
