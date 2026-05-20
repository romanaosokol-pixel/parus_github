create or replace procedure USR_P_IMPORT_USERPROFILES 
(
  pin_idn    in number /* Идентификатор ведомости */
  ,pin_com    in number 
 ,PIN_USER  in varchar2 -- Кому переносим
) is
  v_apps        applist.appcode%type;
  v_apps_rn     applist.rn%type;
  v_unitcode    unitlist.unitcode%type;
  v_unitcode_rn unitlist.rn%type;
  v_filename    file_buffer.filename%type;
  blobdata      blob;
  sname_to      pkg_std.tstring;
  nrn number(17);

  /*ВСегда 0*/
  nREc_type userprofiles.rec_type%type:=0; /* Тип 0 -Win  1- WEB */
  /* Вид
  0 - Настройки раздела
  1 - Параметры пользовательских отчетов, процедур, приложений
  2 - Формы просмотра раздела (WEB-ONLY)
  3 - Параметры отбора раздела
  4 - Параметры действий раздела
  5 - Настройки инициализируемые по ключу (WEB-ONLY). Например, формы выбора ПО/ПП, форма добавления/исправления каталогов
*/
  
  nKIND userprofiles.kind%type;
  
  sSHOW_METHOD userprofiles.show_method%type; /* Метод вызова */   
  
  /* UNITFUNC, UNITMODE, REC_KEY  -- Всегда Null */
  
  
  

begin
  select fb.filename
        ,fb.bdata
    into v_filename
        ,blobdata
    from file_buffer fb
   where fb.ident = pin_idn;

  /*отрежем путь к файлу*/
  v_filename := substr(v_filename, instr(v_filename, '\', -1) + 1);

  /* Определим приложение и раздел */
  v_apps     := substr(v_filename, 1, instr(v_filename, '_', 1) - 1);
  v_unitcode := substr(substr(v_filename, instr(v_filename, '_', -1) + 1), 1,
                       instr(substr(v_filename, instr(v_filename, '_', -1) + 1), '.', -1) - 1);

  /* Проверим, что определили верно */
  begin
    select ap.rn into v_apps_rn from applist ap where ap.appcode = v_apps;
  exception
    when no_data_found then
      p_exception(0, 'Приложение с кодом %s не найдено.', v_apps);
  end;

  begin
    select u.rn into v_unitcode_rn from unitlist u where u.unitcode = v_unitcode;
  exception
    when no_data_found then
      p_exception(0, 'Раздел с кодом %s не найден.', v_unitcode);
    
  end;

  /* Имя текущего пользователя */
  ---sname_to := get_userlist_name_id(nflag_smart => 0, sauthid => get_userlist_authid_id(nflag_smart => 0, nrn => nrn));

/*select UP.RN
into nrn
  from USERPROFILES  UP
where UP.AUTHID = PIN_USER and UP.APPCODE = v_apps and UP.UNITCODE = v_unitcode*/

---P_USERPROFILES_BASE_MODIFY(PKG_SESSION.GET_UTILIZER, nREC_TYPE, nKIND, nCOMPANY, sAPPCODE, sUNITCODE, sSHOW_METHOD, sUNITFUNC, nUNITMODE, sREC_KEY, lUSERDATA);


end;
/
