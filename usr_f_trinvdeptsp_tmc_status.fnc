create or replace function usr_f_trinvdeptsp_tmc_status(nrn in transinvdeptspecs.rn%type) return varchar2 is

  v_res varchar2(80);

begin
  /* Выводится статус партии ТМЦ. Статус устанавливается на этапе Сертификации/входной контроль */

  begin
    select usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Статус качества'
                                              ,sunitcode  => 'GoodsParties'
                                              ,ndocument  => t.goodsparty)
      into v_res
      from transinvdeptspecs t
     where t.rn = nrn;
  exception
    when no_data_found then
      return null;
  end;
  return v_res;
end;
/
