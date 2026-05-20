create or replace procedure usr_p_fcroutlst_files_name
(
  nmsrn         in fcroutlstsp.rn%type /*Строка маршрутного листа*/
 ,pin_file_typ  in varchar2
 ,pin_zav_nmb   in varchar2
 ,pin_mr_name   in varchar2
 ,pin_oper_nmb  in varchar2
 ,out_file_nmb  out varchar2
 ,out_file_name out varchar2
 
) is
szav_nmb varchar2(40);
file_name_mini varchar2(2000);

begin
   -- Выделяем заводской номер
  szav_nmb := substr(pin_zav_nmb, instr(pin_zav_nmb, '_', -1) + 1);
  -- Создадим новый индекс
  file_name_mini := upper(pin_mr_name || '_Z' || szav_nmb || '_' || trim(pin_oper_nmb));

  -- Найдем максимальный индекс из уже имеющихся по префиксу file_name_mini .

  select nvl(to_char(max(to_number(substr(fl.file_path
                                         ,instr(fl.file_path, '_', -1) + 1
                                         ,instr(fl.file_path, '.', -1) -
                                          instr(fl.file_path, '_', -1) - 1))) + 1)
            ,1)
    into out_file_nmb
  
    from fcroutlstsp sp
    join filelinksunits fll
      on fll.table_prn = sp.rn
    join filelinks fl
      on fl.rn = fll.filelinks_prn
   where sp.prn = (select t.prn from fcroutlstsp t where t.rn = nmsrn)
     and upper(substr(fl.file_path, 1, instr(fl.file_path, '_', -1) - 1)) like
         file_name_mini || '%';

  out_file_name := file_name_mini || case
                     when out_file_nmb is null then
                      ''
                     else
                      '_' || out_file_nmb
                   end || '.' || pin_file_typ;
end;
/
