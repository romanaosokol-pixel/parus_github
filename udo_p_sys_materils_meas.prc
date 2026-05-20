create or replace procedure UDO_P_SYS_MATERILS_MEAS as
  /*
    16/03/2023 Марков МВ.
    Список материалов с неправильной ЕИ (штуки)
    разовая процедура
    UDO_SYS_MATERILS_MEAS_TMP
    UDO_SYS_MATERILS_MEAS_ART
  */
begin
  -- материалы
  for rec in (select nm.nomen_name,
                     mt.ext_id,
                     md.rn,
                     (select sp.ext_nomen
                        from udo_loadext_ord_sp sp
                       where sp.ext_id = to_char(mt.ext_id)
                         and rownum < 2) ips_name
                from udo_modif_matches mt,
                     nommodif          md,
                     dicnomns          nm
               where mt.prn = md.rn
                 and md.prn = nm.rn
                 and exists (select null
                        from udo_loadext_ord_sp        ls,
                             udo_loadext_ord_attr_spec las
                       where ls.ext_id = to_char(mt.ext_id)
                         and ls.ext_klass = 'Материалы'
                         and las.prn = ls.rn
                         and las.attribute_id = 1129
                         and las.integer_value = 2804)
               order by nm.nomen_name) loop
    insert into UDO_SYS_MATERILS_MEAS_TMP
      (EXT_ID,
       MODIF,
       NOMEN_NAME,
       IPS_NAME)
    values
      (rec.ext_id,
       rec.rn,
       rec.nomen_name,
       rec.ips_name);
  end loop;
  -- входимость
  for rmt in (select * from UDO_SYS_MATERILS_MEAS_TMP) loop
    --
    for rrt in (select distinct to_number(sp.ext_id) ext_id,
                                sp.ext_nomen,
                                sp.modif,
                                case
                                  when sp.modif is not null then
                                   (select nm.nomen_name
                                      from dicnomns nm,
                                           nommodif md
                                     where md.rn = sp.modif
                                       and md.prn = nm.rn)
                                  else
                                   ''
                                end as nomen_name,
                                (select count(*)
                                   from udo_loadext_ord_sp        spm,
                                        udo_loadext_ord_attr_spec las
                                  where spm.prn = sp.prn
                                    and spm.ext_id = to_char(rmt.ext_id)
                                    and las.prn = spm.rn
                                    and las.attribute_id = 1129
                                    and las.integer_value = 2804) meas_id
                  from udo_loadext_ord_sp sp
                 where sp.sign_head = 1
                   and exists (select null
                          from udo_loadext_ord_sp ls
                         where ls.prn = sp.prn
                           and ls.ext_id = to_char(rmt.ext_id))) loop
      insert into UDO_SYS_MATERILS_MEAS_ART
        (EXT_ID_MTR,
         EXT_ID,
         MODIF,
         NOMEN_NAME,
         IPS_NAME,
         MEAS_ID)
      values
        (rmt.ext_id,
         rrt.ext_id,
         rrt.modif,
         rrt.nomen_name,
         rrt.ext_nomen,
         rrt.meas_id);
    end loop;
  end loop;
end;
/

