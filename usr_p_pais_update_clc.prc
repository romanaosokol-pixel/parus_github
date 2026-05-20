create or replace procedure usr_p_pais_update_clc
(
  pin_nrn     in number
 ,pin_nquant  in number
 ,out_vis_msg out number
 ,out_msg     out varchar2
) is

  nq number(4);

begin
  /* Если ввели количество, то выводим сообщение */
  if pin_nquant is not null then
    out_vis_msg := 1;
  
    --- Считаем количество калькуляций
    select count(*) into nq from payaccinspclc t where t.prn = pin_nrn;
  
    case nq
      when 0 then
        out_msg := 'Строки калькуляции не созданы';
      when 1 then
        out_msg := 'Будет исправлено количество в строке калькуляции';
      else
        out_msg := 'Создано несколько строк калькуляции, количество изменено не будет';
    end case;
  
    if nq = 1 then
    
      select count(*)
        into nq
        from payaccinspclc t
        join payaccinspclc_ex ex
          on t.rn = ex.prn
       where t.prn = pin_nrn;
    end if;
    
     case nq
      when 0 then
        out_msg := out_msg||CR||'Заказы подразделений не созданы';
      when 1 then
        out_msg := out_msg||CR||'Будет переформирован заказ подразделений';
      else
        out_msg := out_msg||CR||'Создано несколько заказов подразделений, количество изменено не будет';
    end case;
  
  end if;
end;
/
