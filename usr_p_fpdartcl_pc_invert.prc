create or replace procedure usr_p_fpdartcl_pc_invert(nident in number) is

  n_sv     number(1);
  v_nrn_sv number(17);
begin
  /*
  13/01/2025 Городецкий
  Процедура инвертирует значение свойства 'СМЕТА' в Статьях затрат
  Это признак того, что входящий счет, с данной статьей в лицевом счете, нужно в калькуляции привязать к бюджету
  */
  for cur in (select sl.document
                from selectlist sl
               where sl.ident = nident
                 and sl.unitcode = 'FinPlanArticles'
                 and sl.authid = utilizer)
  
  loop
  
    n_sv := nvl(usr_pkg_docs_props_vals.get_val_num(sprop_code => 'СМЕТА', sunitcode => 'FinPlanArticles', ndocument => cur.document), 0);
  
    pkg_docs_props_vals.modify(sproperty   => 'СМЕТА'
                              ,sunitcode   => 'FinPlanArticles'
                              ,ndocument   => cur.document
                              ,nnum_value  => 1 - n_sv
                              ,sstr_value  => null
                              ,ddate_value => null
                              ,nrn         => v_nrn_sv);
  
  end loop;

end;
/
