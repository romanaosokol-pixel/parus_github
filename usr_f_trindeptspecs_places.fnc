create or replace function USR_F_TRINDEPTSPECS_PLACES
/*
09/12/2025 Степанов. Переделал на связь непосредственно от спецификации, а не от заголовка
05.06.2025 FEDOREEV_RE.
Расходные накладные на отпуск в подразделения (Спецификация)
Колонка #Места хранения
grant execute on usr_f_trindeptspecs_places to public
*/
(
 nRN    in number
) 
return varchar2 
as
  v_result pkg_std.tstring;
begin
  select listagg(trim(ce.pref) || '.' || trim(ce.numb), '; ') within group(order by ce.rn)
    into v_result
    from transinvdeptspecs sp
    join doclinks          dl   on dl.in_document = sp.rn
    join strplresjrnl      sprj on sprj.rn        = dl.out_document
    join stplcells         ce   on ce.rn          = sprj.cell
   where sp.rn = nRN;

  return(v_result);

end USR_F_TRINDEPTSPECS_PLACES;
/
