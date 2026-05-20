create or replace procedure usr_f_cull_out_status_tmc(nsupply       in goodssupply.rn%type
                                                     ,nsign_out_def in number default 0
                                                     ,nsign_out     out number) is

  /*
    Возвращаем примечание значения доп словаря УМТС_ТМЦСтатус, которое хранится в свойстве приходной партии товара
    Приходную партию определяем по RN товарного запаса!
  */

begin
  with z as
   (select usr_pkg_docs_props_vals.get_val_str(sprop_code => 'УМТС_ТМЦСтатус', sunitcode => 'GoodsParties', ndocument => gy.prn) zn_sv
      from goodssupply gy
     where gy.rn = nsupply),
  dicv as
   (select dv.str_value
          ,dv.note
      from extra_dicts d
      join extra_dicts_values dv
        on dv.prn = d.rn
     where d.code = 'УМТС_ТМЦСтатус'
       and d.version = 91432) /*Вычислять не будем, версия у нас одна */
  select dicv.note
    into nsign_out
    from z
    join dicv
      on z.zn_sv = dicv.str_value;
exception
  when no_data_found then
    nsign_out := nsign_out_def; /* Значение по умолчанию */
end;
/
