create or replace package usr_pkg_files is

  /*
  Городецкий О.И.  22/02/2025
  Package предназначен для работы с файлами в операционной системы и загрузки/выгрузки их в базу данных
  
  Используются Java Source
  DirList  --- Список файлов директории во временной таблице USR_TAB_DIR_LIST
  
  get_dir_list  --- Процедура вызова DirList
  
  l_location  -- Директория созданная в Oracle Имя директории задается в строго ВЕРХНЕМ регистре. Пример
  l_filename  -- Имя файла
  
  */

  /*#########################################################################################################*/

  /*Запись текста в файла, вместо уже существующего. Если файла нет, то он создается */

  procedure add_text
  (
    l_location in varchar2
   ,l_filename in varchar2
   ,l_text     in varchar2
   ,smsg       out varchar2
  );

  /*#########################################################################################################*/

  /* Формирование списка файлов директории в таблице USR_TAB_DIR_LIST*/
  procedure get_dir_list(l_location in varchar2);

  /*#########################################################################################################*/

  /*Записываем файл из BLOB поля на диск */
  procedure blob2file
  (
    l_location in varchar2
   ,l_filename in varchar2
   ,l_blob     in blob
  );

  /*#########################################################################################################*/

  /* Помещает указанный файл в Blob */
  function file2blob
  (
    l_location in varchar2
   ,l_filename in varchar2
  ) return blob;

  /*#########################################################################################################*/

  procedure rename
  (
    l_location_old in varchar2
   ,l_filename_old in varchar2
   ,l_location_new in varchar2 default null
   ,l_filename_new in varchar2
   ,l_overwrite    in boolean default false
   ,smsg           out varchar2
  );
  /*#########################################################################################################*/

  procedure delete
  (
    l_location in varchar2
   ,l_filename in varchar2
   ,smsg       out varchar2
  );

end usr_pkg_files;
/
create or replace package body usr_pkg_files is

  /*
    Городецкий О.И.  22/02/2025
    Package предназначен для работы с файлами в операционной системы и загрузки/выгрузки их в базу данных
  */

  /*#########################################################################################################*/

  /*Запись текста в файла, вместо уже существующего. Если файла нет, то он создается */

  procedure add_text
  (
    l_location in varchar2
   ,l_filename in varchar2
   ,l_text     in varchar2
   ,smsg       out varchar2
  ) is
  
    file_handle utl_file.file_type;
  
  begin
    begin
      file_handle := utl_file.fopen(l_location, l_filename, 'w');
      utl_file.putf(file_handle, l_text);
      --- utl_file.PUT_LINE( 
      utl_file.fclose(file_handle);
    
    exception
      when others then
        smsg := 'Exception: SQLCODE=' || sqlcode || chr(10) || 'SQLERRM=' || sqlerrm;
        ---raise;
    end;
    smsg := nvl(smsg, 'OK');
  end add_text;

  /*#########################################################################################################*/

  /* Формирование списка файлов директории в таблице USR_TAB_DIR_LIST*/
  procedure get_dir_list(l_location in varchar2) as
    language java name 'DirList.getList(java.lang.String)';

  /*#########################################################################################################*/

  /*Записываем файл из BLOB поля на диск */
  procedure blob2file
  (
    l_location in varchar2
   ,l_filename in varchar2
   ,l_blob     in blob
  ) is
  
    l_file     utl_file.file_type;
    l_buffer   raw(32767);
    l_amount   binary_integer := 32767;
    l_pos      integer;
    l_blob_len integer;
  
  begin
  
    begin
      l_pos      := 1;
      l_blob_len := dbms_lob.getlength(l_blob);
      l_file     := utl_file.fopen(l_location, l_filename, 'wb', 32767);
      while l_pos <= l_blob_len
      loop
        dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
        utl_file.put_raw(l_file, l_buffer, true);
        l_pos := l_pos + l_amount;
      end loop;
    
      -- Close the file.
      utl_file.fclose(l_file);
    end;
  exception
    when others then
      -- Close the file if something goes wrong.
      if utl_file.is_open(l_file) then
        utl_file.fclose(l_file);
      end if;
      raise;
    
  end;

  /*#########################################################################################################*/

  /* Помещает указанный файл в Blob */

  function file2blob
  (
    l_location in varchar2
   ,l_filename in varchar2
  ) return blob as
  
    mblob    blob := empty_blob();
    mbinfile bfile := bfilename(l_location, l_filename);
  
  begin
  
    dbms_lob.open(mbinfile, dbms_lob.lob_readonly); -- Open BFILE
    dbms_lob.createtemporary(mblob, true, dbms_lob.session); -- BLOB locator initialization
    dbms_lob.open(mblob, dbms_lob.lob_readwrite); -- Open BLOB locator for writing
    dbms_lob.loadfromfile(mblob, mbinfile, dbms_lob.getlength(mbinfile)); -- Reading BFILE into BLOB
    dbms_lob.close(mblob); -- Close BLOB locator
    dbms_lob.close(mbinfile); -- Close BFILE
  
    return mblob;
  
  end;

  /*#########################################################################################################*/

  procedure rename
  (
    l_location_old in varchar2
   ,l_filename_old in varchar2
   ,l_location_new in varchar2 default null
   ,l_filename_new in varchar2
   ,l_overwrite    in boolean default false
   ,smsg           out varchar2
  ) is
  
  begin
    begin
      utl_file.frename(src_location  => l_location_old
                      ,src_filename  => l_filename_old
                      ,dest_location => nvl(l_location_new, l_location_old)
                      ,dest_filename => l_filename_new
                      ,overwrite     => l_overwrite);
    
    exception
      when others then
      
        smsg := 'Exception: SQLCODE=' || sqlcode || chr(10) || 'SQLERRM=' || sqlerrm;
        ---raise;
    end;
    smsg := nvl(smsg, 'OK');
  end;

  /*#########################################################################################################*/

  procedure delete
  (
    l_location in varchar2
   ,l_filename in varchar2
   ,smsg       out varchar2
  ) is
  
  begin
    begin
      utl_file.fremove(l_location, filename => l_filename);
    exception
      when others then
      
        smsg := 'Exception: SQLCODE=' || sqlcode || chr(10) || 'SQLERRM=' || sqlerrm;
        ---raise;
    end;
    smsg := nvl(smsg, 'OK');
  end;

/*#########################################################################################################*/

end usr_pkg_files;
/
