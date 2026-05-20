create or replace procedure usr_p_tid_faceacc_cntrl(nrn in transinvdept.faceacc%type) is

  /*Контроль для валидатора процедуры Формирование акта из этапа Договора */
  v_direct varchar2(20);
begin
  begin
  
    select usr_pkg_docs_props_vals.get_val_str(sprop_code => 'direction', sunitcode => 'IncomeExpenseArticles', ndocument => cl.rn)
      into v_direct
      from faceacc f
      join fpdartcl sz
        on sz.rn = f.ieelement
      join diciearts cl
        on cl.rn = sz.iearticle
     where f.rn = nrn;
  
  exception
    when no_data_found then
      v_direct := null;
    
  end;

  case
    when v_direct is null then
    
      p_exception(0
                 ,'Не найдена статья калькуляции с заданным свойством "Направление" в статье затрат лицевого счета накладной! ');
    
    when v_direct != 'Доход' then
    
      p_exception(0
                 ,'В Лицевом счете накладной,  в статье калькуляции состава затрат, заданно свойство "Направление" с признаком "' ||
                  v_direct || '", а должно быть с признаком "Приход". Выберите правильный лицевой счет.');
    
    else
    
      null;
    
  end case;

end;
/
