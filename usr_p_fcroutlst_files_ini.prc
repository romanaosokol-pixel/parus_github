create or replace procedure usr_p_fcroutlst_files_ini
(
  nrn           in filelinks.rn%type
 ,out_prn       out fcroutlst.rn%type
 ,out_mr_name   out varchar2
 ,out_zav_nmb   out varchar2
 ,out_oper_numb out varchar2
 ,out_file_name out varchar2
 ,out_file_nmb  out varchar2
 ,out_file_typ  out varchar2
) is

  nmsrn          fcroutlstsp.rn%type;
  nfl            integer;
  file_name_mini varchar2(255);
  szav_nmb       varchar2(80);

begin

  ---out_notes := null;
  begin
    select ml.rn
          ,mr.name sname
          ,msp.rn
          ,substr(fl.file_path, instr(fl.file_path, '.', -1) + 1)
          ,case
             when fl.bdata is null then
              0
             else
              1
           end
          ,msp.oper_numb
      into out_prn
          ,out_mr_name
          ,nmsrn
          ,out_file_typ
          ,nfl
          ,out_oper_numb
      from filelinks fl
      join filelinksunits fll
        on fll.filelinks_prn = fl.rn
      join fcroutlstsp msp
        on msp.rn = fll.table_prn
      join fcroutlst ml
        on ml.rn = msp.prn
      join fcmatresource mr
        on mr.rn = ml.matres
     where fl.rn = nrn;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедура запускается только по присоединенному документу связанного со строкой спецификации маршрутного листа.');
    
  end;

  p_exception(nfl
             ,'Файл из данного присоединенного документа уже выгружен, повторная вынрузка не требуется.');

  begin
    begin
      select ar.code
        into out_zav_nmb
        from fcroutlstsernumb zn
        join rlarticles ar
          on ar.rn = zn.article
       where zn.prn = out_prn;
    exception
      when too_many_rows
           or no_data_found then
        out_zav_nmb := null;
    end;
  end;

  if out_zav_nmb is not null then 
    
  
   usr_p_fcroutlst_files_name(nmsrn         => nmsrn
                            ,pin_file_typ  => out_file_typ
                            ,pin_zav_nmb   => out_zav_nmb
                            ,pin_mr_name   => out_mr_name
                            ,pin_oper_nmb  => out_oper_numb
                            ,out_file_nmb  => out_file_nmb
                            ,out_file_name => out_file_name);
  
  
  else

  out_file_name := nvl(out_file_name, 'Выберите серию');
  
  
  end if;
  

end;
/
