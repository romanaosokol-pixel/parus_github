create or replace procedure usr_p_fcroutlst_files
(
  nrn           in filelinks.rn%type
 ,prn           in fcroutlst.rn%type -- Определяется в валидаторе 
 ,pin_mr_name   in varchar2
 ,pin_zav_nmb   in varchar2 -- Код номенклатуры + заводской номер
 ,pin_file_nmb  in varchar2 -- Номер файла для уникальности (если такое имя уже существует)
 ,pin_oper_numb in varchar2 -- Номер операции маршрутного листа
 ,pin_file_typ  in varchar2 -- Расширение файла
 ,pin_file_name in varchar2 -- Имя файла
) is

  b_bdata        blob;
  l_location     varchar2(100) := 'TEST_FILES'; --CAPITAL
  l_filelinktype flinktypes.rn%type := 160840124; --"_ФВД"
  s_unit         unitlist.unitcode%type; -- К какому разделу присоединен документ

  -- Перекодируем имя файла в кодировку UTF8
  s_file_name varchar2(2000) := convert(pin_file_name, 'utf8', 'CL8MSWIN1251');

begin
  -- Проверим, что у присоединенного документа ненулевой Blob

  begin
  
    select fl.bdata
          ,flu.unitcode
      into b_bdata
          ,s_unit
      from filelinks fl
      left join filelinksunits flu
        on flu.table_prn = fl.rn
     where fl.rn = nrn
       and fl.bdata is not null;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'У данного присоединённого документа нет вложенного файла. Выгрузка в хранилище невозможна.');
    
  end;

  case
    when s_unit is null then
      p_exception(0
                 ,'Документ не имеет связи с разделом, перед отправкой его нужно присоединить к разделу "Маршрутные листы. Строки"');
    when s_unit != '' then
      p_exception(0
                 ,'Отправлять в хранилище данной процедурой можно только только документы присоединенные к разделу "Маршрутные листы. Строки"');
    else
      null;
  end case;

  --- Скопируем файл в хранидище

  usr_pkg_files.blob2file(l_location => l_location, l_filename => s_file_name, l_blob => b_bdata);

  --- Изменим имя файла и тип присоединенного ждокумента

  update filelinks fl
     set fl.file_path = pin_file_name
        ,fl.file_type = l_filelinktype
        ,fl.bdata     = null
   where fl.rn = nrn;

  --

end;
/
