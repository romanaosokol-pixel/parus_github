create or replace procedure usr_p_operplans_modify
(
  pin_doc        in fcacoperplans.rn%type
 ,pin_com        in fcacoperplans.company%type
 ,pin_nakl_date  in date
 ,pin_begin_date in fcacoperplans.begin_date%type
 ,pin_end_date   in fcacoperplans.end_date%type
) is

  nnrn  number(17);
  nprop number(17) := 7526416; ---'Реальная дата'
  
  --- Считаем текущее значение свойства 
  v_old_date date := usr_pkg_docs_props_vals.get_val_date(ndoc_prop => nprop, ndocument => pin_doc);
  v_old_d1 fcacoperplans.begin_date%type;
  v_old_d2 fcacoperplans.end_date%type;

begin
  --Лицевые счета (план расхода). Исправить значение полей

  begin
    select fp.begin_date
          ,fp.end_date
      into v_old_d1
          ,v_old_d2
      from fcacoperplans fp
     where fp.rn = pin_doc;
  exception
    when no_data_found then
      p_exception(0
                 ,'График отпуска товаров и услуг с RN = %s  не найден. Запускайте процедуру только на одном конкретном графике.');
  end;

    if cmp_dat(v_old_date , pin_nakl_date) = 0 then
  
    pkg_docs_props_vals .modify(nproperty   => nprop
                               ,sunitcode   => 'FaceAccountsOperOutPlans'
                               ,ndocument   => pin_doc
                               ,sstr_value  => null
                               ,nnum_value  => null
                               ,ddate_value => pin_nakl_date
                               ,nrn         => nnrn);
  
  end if;

  if cmp_dat(v_old_d1, pin_begin_date) = 0 then
    
    update fcacoperplans set begin_date = pin_begin_date where rn = pin_doc;
    
  end if;

  if cmp_dat(v_old_d2, pin_end_date) = 0 then
    update fcacoperplans set end_date = pin_end_date where rn = pin_doc;
  end if;



end;
/
