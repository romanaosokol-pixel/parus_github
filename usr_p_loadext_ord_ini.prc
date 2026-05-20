create or replace procedure usr_p_loadext_ord_ini
(
  sprdord_docnumb in out varchar2
 , /* Значение атрибута "Заказ на производство. Номер" */sfaceacc        in varchar2
 , /* Значение атрибута "Лицевой счет" */sattrib         in varchar2
 ,is_ok           out number
 ,out_txt1        out varchar2
) is

begin

  if sprdord_docnumb is null
     and sfaceacc is null
  then
    is_ok    := 0;
    out_txt1 := 'Обязательно выберите Заказ на производство или Лицевой счет.';
  else
    is_ok    := 1;
    out_txt1 := null;
  end if;

end;
/
