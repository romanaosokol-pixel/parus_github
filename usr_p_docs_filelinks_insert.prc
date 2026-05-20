create or replace procedure USR_P_DOCS_FILELINKS_INSERT
/*
Все разделы.
Добавить присоединённый документ
01/04/2024 Степанов М.
*/
(
 nRN          in number
,nCOMPANY     in number
,sUNITCODE    in varchar2
,sACATALOG    in varchar2
,sFILE_TYPE   in varchar2 
,sNOTE        in varchar2
,sFILE_NAME   in varchar2 /* Имя файла. Вводится вручную */
,bDOCUMENT    in blob
) 
is
  nCRN      pkg_std.tref; 

  nNumber   pkg_std.tnumber;
begin
  /* Проверки */
  /* Имя файла задано */
  if sFILE_NAME is null then
    p_exception(0, 'Не задано имя файла.'); 
  /* Расширение файла: 1) должно присутствовать (в имени есть точка); 2) длина должна быть 3 или 4 символа */
  elsif  length(sFILE_NAME) - instr(sFILE_NAME, '.', -1) not in (3, 4)
  or cmp_num(instr(sFILE_NAME, '.', -1), 0) = 1 then
    p_exception(0, 'Неверное расширение файла <%s>', sFILE_NAME); 
  end if;

  /* Каталог присоединёного документа */
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,nversion    => null
                    ,sunitcode   => 'FileLinks'
                    ,sname       => sACATALOG
                    ,nrn         => nCRN);

  /* Добавление присоединённого документа */
  p_filelinks_insert_ex(ncompany   => nCOMPANY
                       ,ncrn       => nCRN
                       ,scode      => get_filelinks_nextnumb(nCOMPANY, null)
                       ,sfile_type => sFILE_TYPE
                       ,snote      => sNOTE
                       ,sfile_path => sFILE_NAME
                       ,btemplate  => bDOCUMENT
                       ,ctemplate  => null
                       ,sunitcode  => sUNITCODE
                       ,ntable_prn => nRN
                       ,nrn        => nNumber);
end USR_P_DOCS_FILELINKS_INSERT;
/
