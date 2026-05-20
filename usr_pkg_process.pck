create or replace package USR_PKG_PROCESS as
/*
Пакет для идентификации исполняемых пользовательских процессов. Степанов М. 28/12/2020

Использование в процедуре:
declare
  sProcName  constant varchar(60) := 'ИМЯ_ПРОЦЕДУРЫ';
BEGIN
  -- Открытие процесса
  USR_PKG_PROCESS.PROCESS_OPEN(sProcName);
  ...  
  Тело процедуры
  ...  
  -- Закрытие процесса
  USR_PKG_PROCESS.PROCESS_CLOSE(sProcName);
exception
  when others then
    USR_PKG_PROCESS.PROCESS_CLOSE(sProcName);
    raise;
END;

Использование для идентификации:
if NVL(USR_PKG_PROCESS.PROCESS_GET, 'null') not in ('ИМЯ_ПРОЦЕДУРЫ') then
  p_exception(0, 'Ай-ай-ай'); 
end if;
*/

  --#########################################################################################################

  function PROCESS_GET
  /*
  Чтение
  */
  return varchar2;
  --#########################################################################################################

  procedure PROCESS_OPEN
  /*
  Открытие
  */
  (
   SNAME  in varchar2
  );
  --#########################################################################################################

  procedure PROCESS_CLOSE
  /*
  Закрытие
  */
  ;
  --#########################################################################################################

  /*function GET_CURRENT_ENV
  \*
  Считывание текущего ENV
  *\
  (
   NDOCUMENT  in number
  ,NMODE      in number default 0
  ) 
  return PKG_ENV_BASE.tEnv;*/
  --#########################################################################################################

  function GET_CURRENT_ENV
  /*
  Считывание текущего ENV
  */
  (
   SUNITCODE  in varchar2
  ,NMODE      in number default 0
  ) 
  return pkg_env_base.tenv;
  --#########################################################################################################
  /*
  function GET_PARUS_PROCESS
  \*
  Получение парусного процеса
  *\
  (
   NDOCUMENT  in number
  ,NMODE      in number default 0
  ) 
  return varchar2;*/
  --#########################################################################################################

  function GET_CURRENT_ENV
  /*
  Считывание текущего ENV по бизнес-процессу
  */
  return pkg_env_base.tenv;
  --#########################################################################################################

  function GET_PARUS_PROCESS
  /*
  Получение парусного процеса
  */
  (
   SUNITCODE  in varchar2
  ,NMODE      in number default 0
  )
  return varchar2;
  --#########################################################################################################

  function GET_PARUS_PROCESS
  /*
  Получение парусного процеса
  */
  return varchar2;
  --#########################################################################################################
  /*
  function GET_ENV_IDENT
  \*
  Получение IDENT процеса
  *\
  (
   NDOCUMENT  in number
  ,NMODE      in number default 0
  ) 
  return number;*/
  --#########################################################################################################

  function GET_ENV_IDENT
  /*
  Получение IDENT процеса
  */
  (
   SUNITCODE  in varchar2
  ,NMODE      in number default 0
  ) 
  return number;
  --#########################################################################################################

  procedure GET_CURRENT_DOC_PARAMS
  /*
  Получить параметры текущего документа
  */
  (
   nDOCUMENT   out number
  ,sUNITCODE   out varchar2
  );
  --#########################################################################################################

end USR_PKG_PROCESS;
/
create or replace package body USR_PKG_PROCESS as

  --#########################################################################################################

  function PROCESS_GET
  /*
  Чтение
  */
  return varchar2
  is
  begin
    return(USR_PKG_PUB_CONST.SPROCESSNAME);
  end PROCESS_GET;
  --#########################################################################################################

  procedure PROCESS_OPEN
  /*
  Открытие
  */
  (
   SNAME  in varchar2
  ) 
  is
    sVarchar    varchar2(60); 
  begin
    -- Текущий процесс
    sVarchar := PROCESS_GET;
    -- Если есть текущий процесс
    if sVarchar is not null then
      P_EXCEPTION(0, 'В текущей сессии есть активный процесс: <'||sVarchar||'>'); 
    end if;      
    -- Присвоение
    usr_pkg_pub_const.sprocessname := SNAME;
  end PROCESS_OPEN;
  --#########################################################################################################

  procedure PROCESS_CLOSE
  /*
  Закрытие
  */
  is
    sVarchar    varchar2(60); 
  begin
    -- Текущий процесс
    sVarchar := PROCESS_GET;
    -- Если есть текущий процесс
    if sVarchar is null then
      P_EXCEPTION(0, 'В текущей сессии нет активного процесса.'); 
    end if;      
    -- Присвоение
    usr_pkg_pub_const.sprocessname := null;
  end PROCESS_CLOSE;
  --#########################################################################################################
  /*
  function GET_CURRENT_ENV
  \*
  Считывание текущего ENV
  *\
  (
   NDOCUMENT  in number
  ,NMODE      in number default 0
  ) 
  return pkg_env_base.tenv
  is
    rEnv          pkg_env_base.tenv;
    sCONNECT_EXT  pkg_std.tstring;
  begin
    \* идентификатор соединения *\
    sCONNECT_EXT := PKG_SESSION.GET_CONNECT_EXT;
    
    begin
      select el.unitcode
            ,eld.actioncode
            ,el.tablename
            ,el.document
            ,el.company
            ,eld.version
            ,eld.catalog
            ,eld.jur_pers
            ,eld.hierarchy
            ,eld.ident
            ,el.authid
            ,el.connect_ext
            --
            ,el.busproc
        into rEnv.unitcode
            ,rEnv.actioncode
            ,rEnv.table_name
            ,rEnv.document
            ,rEnv.company
            ,rEnv.version
            ,rEnv.catalog
            ,rEnv.jur_pers
            ,rEnv.hierarchy
            ,rEnv.ident
            ,rEnv.authid
            ,rEnv.connect_ext
            --
            ,rEnv.busproc_id
        from env_lock el, env_lock_det eld
       where eld.prn       = el.rn
  --       and el.unitcode   = SUNITCODE
         and el.document   = NDOCUMENT
         and el.connect_ext = sconnect_ext
         and (
              nmode = 0 and eld.ident is not null
             or
              nmode = 1 and eld.actioncode is not null
             );
    exception
      when no_data_found then
        --P_EXCEPTION(0, 'Не найдена запись ENV_LOCK');         
        null;
      when too_many_rows then
        P_EXCEPTION(0, 'Найдено больше одной записи ENV_LOCK');         
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при поиске записи ENV_LOCK');         
    end; 


  \*  for c in (
              select *
                from (select el.lock_date
                            ,el.session_id
                            ,el.authid
                            ,el.osuser
                            ,el.machine
                            ,el.terminal
                            ,el.ip_address
                            ,el.program
                            ,el.unitcode
                            ,el.tablename
                            ,el.document
                            ,el.busproc
                            ,el.connect_ext
                            ,el.company
                            ,el.connect_type
                            ,el.program$vs
                            ,el.browser
                            ,eld.actioncode
                            ,eld.version
                            ,eld.catalog
                            ,eld.jur_pers
                            ,eld.hierarchy
                            ,eld.ident
                            ,rownum
                        from env_lock el, env_lock_det eld
                       where eld.prn       = el.rn
                         and el.unitcode   = sunitcode
                         and el.connect_ext = sconnect_ext
                         AND (
                              nmode = 0 and eld.ident is not null
                             or
                              nmode = 1 and eld.actioncode is not null
                             )
                      order by eld.rn asc
                     ) a
                   where rownum = 1
                   )
    LOOP
      rEnv.unitcode         := c.unitcode;
      rEnv.actioncode       := c.actioncode;
      rEnv.table_name       := c.tablename;
      rEnv.document         := c.document;
      rEnv.company          := c.company;
      rEnv.version          := c.version;
      rEnv.catalog          := c.catalog;
      rEnv.jur_pers         := c.jur_pers;
      rEnv.hierarchy        := c.hierarchy;
      rEnv.ident            := c.ident;
      rEnv.authid           := c.authid;
      rEnv.connect_ext      := c.connect_ext;
    end loop; 
  *\

    -- Результат
    return(rEnv);
  end GET_CURRENT_ENV;*/
  --#########################################################################################################

  function GET_CURRENT_ENV
  /*
  Считывание текущего ENV
  */
  (
   SUNITCODE  in varchar2
  ,NMODE      in number default 0
  ) 
  return pkg_env_base.tenv
  is
    rEnv          pkg_env_base.tenv;
    sConnect_ext  pkg_std.tstring;
  begin
    /* Идентификатор соединения */
    sConnect_ext := pkg_session.get_connect_ext;

    begin
      select a.unitcode
            ,a.actioncode
            ,a.tablename
            ,a.document
            ,a.company
            ,a.version
            ,a.catalog
            ,a.jur_pers
            ,a.hierarchy
            ,a.ident
            ,a.authid
            ,a.connect_ext
            ,a.busproc
        into rEnv.unitcode
            ,rEnv.actioncode
            ,rEnv.table_name
            ,rEnv.document
            ,rEnv.company
            ,rEnv.version
            ,rEnv.catalog
            ,rEnv.jur_pers
            ,rEnv.hierarchy
            ,rEnv.ident
            ,rEnv.authid
            ,rEnv.connect_ext
            ,rEnv.busproc_id
        from (select el.unitcode
                    ,eld.actioncode
                    ,el.tablename
                    ,el.document
                    ,el.company
                    ,eld.version
                    ,eld.catalog
                    ,eld.jur_pers
                    ,eld.hierarchy
                    ,eld.ident
                    ,el.authid
                    ,el.connect_ext
                    ,el.busproc
                from env_lock el, env_lock_det eld
               where eld.prn        = el.rn
                 and el.unitcode    = SUNITCODE
                 and el.connect_ext = sconnect_ext
                 and ( nmode = 0 and eld.ident is not null
                      or
                       nmode = 1 and eld.actioncode is not null )
              order by eld.lock_date desc ) a
       where rownum = 1;
    exception
      when no_data_found then
        null;
      when too_many_rows then
        p_exception(0, 'Найдено больше одной записи ENV_LOCK');         
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске записи ENV_LOCK');         
    end; 

    /* Результат */
    return(rEnv);

  end GET_CURRENT_ENV;
  --#########################################################################################################

  function GET_CURRENT_ENV
  /*
  Считывание текущего ENV по бизнес-процессу
  */
  return pkg_env_base.tenv
  is
    rEnv          pkg_env_base.tenv;
    sCONNECT_EXT  pkg_std.tstring;
  begin
    /* идентификатор соединения */
    sCONNECT_EXT := PKG_SESSION.GET_CONNECT_EXT;

    begin
      select *
        into rEnv.unitcode
            ,rEnv.actioncode
            ,rEnv.table_name
            ,rEnv.document
            ,rEnv.company
            ,rEnv.version
            ,rEnv.catalog
            ,rEnv.jur_pers
            ,rEnv.hierarchy
            ,rEnv.ident
            ,rEnv.authid
            ,rEnv.connect_ext
            ,rEnv.busproc_id
        from ( select el.unitcode
                     ,eld.actioncode
                     ,el.tablename
                     ,el.document
                     ,el.company
                     ,eld.version
                     ,eld.catalog
                     ,eld.jur_pers
                     ,eld.hierarchy
                     ,eld.ident
                     ,el.authid
                     ,el.connect_ext
                     ,el.busproc
                 from env_lock el, env_lock_det eld
                where eld.prn        = el.rn
                  and el.busproc     = pkg_env_base.get_busproc
                  and el.connect_ext = sconnect_ext
               order by eld.lock_date desc )
        where rownum = 1;
    exception
      when no_data_found then
        null;
      when too_many_rows then
        P_EXCEPTION(0, 'Найдено больше одной записи ENV_LOCK');         
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при поиске записи ENV_LOCK');         
    end; 

    /* Результат */
    return(rEnv);
    
  end GET_CURRENT_ENV;
  --#########################################################################################################
  /*
  function GET_PARUS_PROCESS
  \*
  Получение парусного процеса
  *\
  (
   NDOCUMENT  in number
  ,NMODE      in number default 0
  ) 
  return varchar2
  is
    rEnv          pkg_env_base.tenv;
  begin
    rEnv := GET_CURRENT_ENV(NDOCUMENT => NDOCUMENT, NMODE => NMODE);
    return(NVL(rEnv.actioncode, 'NULL'));
  end GET_PARUS_PROCESS;*/
  --#########################################################################################################

  function GET_PARUS_PROCESS
  /*
  Получение парусного процеса
  */
  (
   SUNITCODE  in varchar2
  ,NMODE      in number default 0
  ) 
  return varchar2
  is
    rEnv          pkg_env_base.tenv;
  begin
    rEnv := GET_CURRENT_ENV(SUNITCODE => SUNITCODE, NMODE => NMODE);
    return(NVL(rEnv.actioncode, 'NULL'));
  end GET_PARUS_PROCESS;
  --#########################################################################################################

  function GET_PARUS_PROCESS
  /*
  Получение парусного процеса
  */
  return varchar2
  is
    rEnv          pkg_env_base.tenv;
  begin
    rEnv := get_current_env;
    return(NVL(rEnv.actioncode, 'NULL'));
  end GET_PARUS_PROCESS;
  --#########################################################################################################
  /*
  function GET_ENV_IDENT
  \*
  Получение IDENT процеса
  *\
  (
   NDOCUMENT  in number
  ,NMODE      in number default 0
  ) 
  return number
  is
    rEnv          pkg_env_base.tenv;
  begin
    rEnv := GET_CURRENT_ENV(NDOCUMENT => NDOCUMENT, NMODE => NMODE);
    return(rEnv.ident);
  end GET_ENV_IDENT;*/
  --#########################################################################################################

  function GET_ENV_IDENT
  /*
  Получение IDENT процеса
  */
  (
   SUNITCODE  in varchar2
  ,NMODE      in number default 0
  ) 
  return number
  is
    rEnv          pkg_env_base.tenv;
  begin
    rEnv := GET_CURRENT_ENV(SUNITCODE => SUNITCODE, NMODE => NMODE);
    return(rEnv.ident);
  end GET_ENV_IDENT;
  --#########################################################################################################

  procedure GET_CURRENT_DOC_PARAMS
  /*
  Получить параметры текущего документа
  */
  (
   nDOCUMENT   out number
  ,sUNITCODE   out varchar2
  ) 
  is
  begin
    begin
      select document , unitcode
        into nDOCUMENT, sUNITCODE
        from (select * from selectlist where connect_ext = pkg_session.get_connect_ext order by rn desc) 
       where rownum < 2;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании отмеченного документа');
    end;
  end GET_CURRENT_DOC_PARAMS;
  --#########################################################################################################

end USR_PKG_PROCESS;
/*
grant execute on USR_PKG_PROCESS to public;
*/
/
