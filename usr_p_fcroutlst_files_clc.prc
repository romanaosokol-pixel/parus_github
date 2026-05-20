create or replace procedure usr_p_fcroutlst_files_clc
(
  nrn           in filelinks.rn%type
 ,pin_zav_nmb   in varchar2
 ,pin_mr_name   in varchar2
 ,pin_file_typ  in varchar2
 ,pin_oper_nmb  in varchar2
 ,out_file_nmb  out varchar2
 ,out_file_name out varchar2
) is
  nfl            integer;
  file_name_mini varchar2(2000);
  nmsrn          fcroutlstsp.rn%type;
  szav_nmb       varchar2(80);

begin
  -- Проверим, что такой заводской номер существует
  begin
    select 1
      into nfl
      from filelinksunits fll
      join fcroutlstsp sp
        on sp.rn = fll.table_prn
      join fcroutlstsernumb zn
        on zn.prn = sp.prn
      join rlarticles art
        on art.rn = zn.article
     where fll.filelinks_prn = nrn
       and art.code = pin_zav_nmb
       and art.version = 92063;
  exception
    when no_data_found then
      p_exception(0
                 ,'Серийного номера %s не существует в данном маршрутном листе. Введите корректное значение через словарь.'
                 ,pin_zav_nmb);
    
  end;

  select fll.table_prn into nmsrn from filelinks fl join filelinksunits fll on fll.filelinks_prn = fl.rn where fl.rn = nrn;

  usr_p_fcroutlst_files_name(nmsrn         => nmsrn
                            ,pin_file_typ  => pin_file_typ
                            ,pin_zav_nmb   => pin_zav_nmb
                            ,pin_mr_name   => pin_mr_name
                            ,pin_oper_nmb  => pin_oper_nmb
                            ,out_file_nmb  => out_file_nmb
                            ,out_file_name => out_file_name);

         
end;
/
