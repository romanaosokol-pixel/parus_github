create or replace package USR_PKG_USERPROFILES is
  /*
  Степанов М. 06/09/2024
  Пакет для "Профили пользователей"
  Делал для копирования настроек из другой базы. Не работает. Похоже из-за оракловой ошибки "global_names parameter must be set to TRU"
  Оставляю до лучших времён
  */
  /*#########################################################################################################*/

  procedure USERPROFILES_COPY
  /* 
  Копирование
  */
  (
   sSOURCE_USER     in varchar2     -- Пользователь - источник
  ,sSOURCE_COMPANY  in varchar2     -- Организация - источник
  ,sUSERS           in varchar2     -- Пользователи - приемник
  ,sCOMPANIES       in varchar2     -- Организации - приемник
  ,sAPPS            in varchar2     -- Приложения
  ,sUNITS           in varchar2     -- Разделы
  ,nUSE_PRIVS       in number      -- Учитывать права доступа 0-нет, 1-да
  ,sTYPES           in varchar2     -- Типы
  ,sKINDS           in varchar2     -- Виды
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  );
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_MODIFY
  /* 
  Исправление базовое
  */
  (
   sAUTHID      in varchar2
  ,nREC_TYPE    in number
  ,nKIND        in number
  ,nCOMPANY     in number           -- организация
  ,sAPPCODE     in varchar2         -- код приложения
  ,sUNITCODE    in varchar2         -- код раздела
  ,sSHOW_METHOD in varchar2         -- метод вызова
  ,sUNITFUNC    in varchar2         
  ,nUNITMODE    in number           
  ,sREC_KEY     in varchar2         
  ,lUSERDATA    in blob             -- настройки
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  );
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_INSERT
  /* 
  Добавление базовое
  */
  (
   sAUTHID      in varchar2         -- пользователь
  ,nREC_TYPE    in number           -- тип
  ,nKIND        in number           -- вид
  ,nCOMPANY     in number           -- организация
  ,sAPPCODE     in varchar2         -- код приложения
  ,sUNITCODE    in varchar2         -- код раздела
  ,sSHOW_METHOD in varchar2         -- метод вызова
  ,sUNITFUNC    in varchar2         -- действие раздела
  ,nUNITMODE    in number           
  ,sREC_KEY     in varchar2         -- ключ
  ,lUSERDATA    in blob             -- настройки
  ,nRN          out number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  );
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_UPDATE
  /* 
  Исправление базовое
  */
  (
   nRN          in number
  ,lUSERDATA    in blob
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  );
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_DELETE
  /* 
  Удаление базовое
  */
  (
   nRN          in number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  );
  /*#########################################################################################################*/

end USR_PKG_USERPROFILES;
/
create or replace package body USR_PKG_USERPROFILES is

  /*#########################################################################################################*/

  procedure USERPROFILES_COPY
  /* 
  Копирование
  */
  (
   sSOURCE_USER     in varchar2     -- Пользователь - источник
  ,sSOURCE_COMPANY  in varchar2     -- Организация - источник
  ,sUSERS           in varchar2     -- Пользователи - приемник
  ,sCOMPANIES       in varchar2     -- Организации - приемник
  ,sAPPS            in varchar2     -- Приложения
  ,sUNITS           in varchar2     -- Разделы
  ,nUSE_PRIVS       in number      -- Учитывать права доступа 0-нет, 1-да
  ,sTYPES           in varchar2     -- Типы
  ,sKINDS           in varchar2     -- Виды
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  ) 
  as
    sSOURCE_AUTHID    USERLIST.AUTHID%type;
    nSOURCE_COMPANY   PKG_STD.tREF;

    MAIN_IDENT_       constant number( 1 ) := 5;
    USERS_IDENT_      constant number( 1 ) := 1;
    COMPANIES_IDENT_  constant number( 1 ) := 2;
    APPS_IDENT_       constant number( 1 ) := 3;
    UNITS_IDENT_      constant number( 1 ) := 4;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userprofiles_copy(ssource_user    => sSOURCE_USER
                         ,ssource_company => sSOURCE_COMPANY
                         ,susers          => sUSERS
                         ,scompanies      => sCOMPANIES
                         ,sapps           => sAPPS
                         ,sunits          => sUNITS
                         ,nuse_privs      => nUSE_PRIVS
                         ,stypes          => sTYPES
                         ,skinds          => sKINDS);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
    
      /* предварительная проверка прав доступа */
      PKG_ENV.ACCESS(null, null, null, 'UserProfiles', 'USERPROFILES_COPY');

      FIND_USERLIST_BY_NAME_EX(0, 0, sSOURCE_USER, sSOURCE_AUTHID);
      FIND_COMPANY_NAME_EX(0, 0, sSOURCE_COMPANY, nSOURCE_COMPANY);

      /* список настроек */
      PKG_COND_BROKER.PROLOGUE(PKG_COND_BROKER.MODE_MULTI_, MAIN_IDENT_);
      PKG_COND_BROKER.SET_TABLE('USERPROFILES');
      PKG_COND_BROKER.ADD_CODE('AUTHID', sSOURCE_AUTHID);
      PKG_COND_BROKER.ADD_ENUM('COMPANY', nSOURCE_COMPANY);
      PKG_COND_BROKER.ADD_ENUM('REC_TYPE', sTYPES);
      PKG_COND_BROKER.ADD_ENUM('KIND', sKINDS);
      PKG_COND_BROKER.EPILOGUE;

      /* список пользователей */
      PKG_COND_BROKER.PROLOGUE(PKG_COND_BROKER.MODE_MULTI_, USERS_IDENT_);
      PKG_COND_BROKER.SET_TABLE('USERLIST');
      PKG_COND_BROKER.ADD_CODE('NAME', sUSERS);
      PKG_COND_BROKER.EPILOGUE;

      /* список организаций */
      PKG_COND_BROKER.PROLOGUE(PKG_COND_BROKER.MODE_MULTI_, COMPANIES_IDENT_);
      PKG_COND_BROKER.SET_TABLE('COMPANIES');
      PKG_COND_BROKER.ADD_CODE('NAME', sCOMPANIES);
      PKG_COND_BROKER.EPILOGUE;

      /* список приложений */
      PKG_COND_BROKER.PROLOGUE(PKG_COND_BROKER.MODE_MULTI_, APPS_IDENT_);
      PKG_COND_BROKER.SET_TABLE('APPLIST');
      PKG_COND_BROKER.ADD_CODE('APPNAME', sAPPS);
      PKG_COND_BROKER.EPILOGUE;

      /* список разделов */
      PKG_COND_BROKER.PROLOGUE(PKG_COND_BROKER.MODE_MULTI_, UNITS_IDENT_);
      PKG_COND_BROKER.SET_TABLE('UNITLIST');
      PKG_COND_BROKER.ADD_CODE('UNITNAME', sUNITS);
      PKG_COND_BROKER.EPILOGUE;

      /* профили источника */
      for rec in
      (
        select UP.AUTHID,
               UP.REC_TYPE,
               UP.KIND,
               UP.COMPANY,
               UP.APPCODE,
               UP.UNITCODE,
               MU.MASTERCODE,
               MU.SHARING, -- 0 - нет деления, 1 - по версиям, 2 - по организациям
               UP.SHOW_METHOD,
               UP.UNITFUNC,
               UP.UNITMODE,
               UP.REC_KEY,
               UP.USERDATA
          from (
                 select *
                   from USERPROFILES
                   where RN in(select ID from COND_BROKER_IDMULTI where IDENT = MAIN_IDENT_)
               ) UP,
               (
                 select UL1.UNITCODE,
                        nvl(UL1.MASTERCODE,UL1.UNITCODE)  as MASTERCODE,
                        case
                          when ( UL1.MASTERCODE is null ) then
                            UL1.SIGN_SHARE*(UL1.SIGN_ACCREG+1)
                          else
                            (select UL2.SIGN_SHARE*(UL2.SIGN_ACCREG+1) from UNITLIST UL2 where UL2.UNITCODE = UL1.MASTERCODE)
                        end as SHARING
                 from UNITLIST UL1
               ) MU
        where     UP.APPCODE in(select APPCODE from APPLIST where RN in(select ID from COND_BROKER_IDMULTI where IDENT = APPS_IDENT_))
              and UP.UNITCODE = MU.UNITCODE(+)
              and (   UP.UNITCODE is null
                   or MU.MASTERCODE in(select UNITCODE from UNITLIST where RN in(select ID from COND_BROKER_IDMULTI where IDENT = UNITS_IDENT_)))
      )
      loop
        /* пользователи/организации-приёмники */
        for users in
        (
          select US.AUTHID,
                 CO.COMPANY
            from (
                   select US.AUTHID
                     from USERLIST US
                     where     US.RN in(select ID from COND_BROKER_IDMULTI where IDENT = USERS_IDENT_)
                           and not exists(select null from USERSDELETED UD where UD.USERID = US.RN) -- не удалённый пользователь

                 ) US,
                 (
                   select RN as COMPANY
                     from COMPANIES
                     where RN in(select ID from COND_BROKER_IDMULTI where IDENT = COMPANIES_IDENT_)
                 ) CO
            where    -- не проверять права
                     nUSE_PRIVS = 0
                     -- права на приложение
                  or     exists
                         (
                           select null
                             from USERAPPS UP
                             where     UP.APPCODE = rec.APPCODE
                                   and UP.ROLEID  in(select UR.ROLEID from USERROLES UR where UR.AUTHID = US.AUTHID)
                           union all
                           select null
                             from USERAPPS UP
                             where     UP.APPCODE = rec.APPCODE
                                   and UP.AUTHID  = US.AUTHID
                         )
                     -- права на организацию
                     and exists
                         (
                           select null
                             from USERPRIV UP
                             where     UP.COMPANY = CO.COMPANY
                                   and UP.ROLEID  in(select UR.ROLEID from USERROLES UR where UR.AUTHID = US.AUTHID)
                           union all
                           select null
                             from USERPRIV UP
                             where     UP.COMPANY = CO.COMPANY
                                   and UP.AUTHID  = US.AUTHID
                         )
                     -- права на раздел
                     and (
                              -- не проверять права
                              rec.UNITCODE is null
                              -- раздел без деления
                           or rec.SHARING = 0
                              and exists
                                  (
                                    select null
                                      from USERPRIV UP
                                      where     UP.UNITCODE = rec.MASTERCODE
                                            and UP.ROLEID   in(select UR.ROLEID from USERROLES UR where UR.AUTHID = US.AUTHID)
                                    union all
                                    select null
                                      from USERPRIV UP
                                      where     UP.UNITCODE = rec.MASTERCODE
                                            and UP.AUTHID   = US.AUTHID
                                  )
                              -- раздел с делением по организациям
                           or rec.SHARING = 2
                              and exists
                                  (
                                    select null
                                      from USERPRIV UP
                                      where     UP.UNITCODE = rec.MASTERCODE
                                            and UP.COMPANY  = CO.COMPANY
                                            and UP.ROLEID   in(select UR.ROLEID from USERROLES UR where UR.AUTHID = US.AUTHID)
                                    union all
                                    select null
                                      from USERPRIV UP
                                      where     UP.UNITCODE = rec.MASTERCODE
                                            and UP.COMPANY  = CO.COMPANY
                                            and UP.AUTHID   = US.AUTHID
                                  )
                              -- раздел с делением по версиям
                           or rec.SHARING = 1
                              and exists
                                  (
                                    select null
                                      from USERPRIV UP
                                      where     UP.UNITCODE = rec.MASTERCODE
                                            and UP.VERSION  = (select CV.VERSION from COMPVERLIST CV where CV.COMPANY = CO.COMPANY and CV.UNITCODE = rec.MASTERCODE)
                                            and UP.ROLEID   in(select UR.ROLEID from USERROLES UR where UR.AUTHID = US.AUTHID)
                                    union all
                                    select null
                                      from USERPRIV UP
                                      where     UP.UNITCODE = rec.MASTERCODE
                                            and UP.VERSION  = (select CV.VERSION from COMPVERLIST CV where CV.COMPANY = CO.COMPANY and CV.UNITCODE = rec.MASTERCODE)
                                            and UP.AUTHID   = US.AUTHID
                                  )
                         )
        )
        loop

          /* это не профиль источника */
          if ( not(users.AUTHID = rec.AUTHID and users.COMPANY = rec.COMPANY) ) then

            /* базовая модификация */
            /*P_USERPROFILES_BASE_MODIFY*/
            USERPROFILES_BASE_MODIFY
            (
              sAUTHID      => users.AUTHID,
              nREC_TYPE    => rec.REC_TYPE,
              nKIND        => rec.KIND,
              nCOMPANY     => users.COMPANY,
              sAPPCODE     => rec.APPCODE,
              sUNITCODE    => rec.UNITCODE,
              sSHOW_METHOD => rec.SHOW_METHOD,
              sUNITFUNC    => rec.UNITFUNC,
              nUNITMODE    => rec.UNITMODE,
              sREC_KEY     => rec.REC_KEY,
              lUSERDATA    => rec.USERDATA
             ,nMODE        => nMODE
            );
          end if;
        end loop;
      end loop;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end USERPROFILES_COPY;
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_MODIFY
  /* 
  Исправление базовое
  */
  (
   sAUTHID      in varchar2
  ,nREC_TYPE    in number
  ,nKIND        in number
  ,nCOMPANY     in number           -- организация
  ,sAPPCODE     in varchar2         -- код приложения
  ,sUNITCODE    in varchar2         -- код раздела
  ,sSHOW_METHOD in varchar2         -- метод вызова
  ,sUNITFUNC    in varchar2         
  ,nUNITMODE    in number           
  ,sREC_KEY     in varchar2         
  ,lUSERDATA    in blob             -- настройки
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  ) 
  as
    /* Параметры из штатной процедуры */
    nRN     PKG_STD.tREF;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userprofiles_base_modify(sauthid      => sAUTHID     
                                ,nrec_type    => nREC_TYPE   
                                ,nkind        => nKIND       
                                ,ncompany     => nCOMPANY    
                                ,sappcode     => sAPPCODE       
                                ,sunitcode    => sUNITCODE      
                                ,sshow_method => sSHOW_METHOD   
                                ,sunitfunc    => sUNITFUNC      
                                ,nunitmode    => nUNITMODE      
                                ,srec_key     => sREC_KEY       
                                ,luserdata    => lUSERDATA    );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* считывание записи настроек */
      begin
        select RN
          into nRN
          from USERPROFILES
          where AUTHID = sAUTHID
            and REC_TYPE = nREC_TYPE
            and KIND = nKIND
            and ((COMPANY is null and nCOMPANY is null) or (COMPANY is not null and nCOMPANY is not null and COMPANY = nCOMPANY))
            and ((APPCODE is null and sAPPCODE is null) or (APPCODE is not null and sAPPCODE is not null and APPCODE = sAPPCODE))
            and ((UNITCODE is null and sUNITCODE is null) or (UNITCODE is not null and sUNITCODE is not null and UNITCODE = sUNITCODE))
            and ((SHOW_METHOD is null and sSHOW_METHOD is null) or (SHOW_METHOD is not null and sSHOW_METHOD is not null and SHOW_METHOD = sSHOW_METHOD))
            and ((UNITFUNC is null and sUNITFUNC is null) or (UNITFUNC is not null and sUNITFUNC is not null and UNITFUNC = sUNITFUNC))
            and ((UNITMODE is null and nUNITMODE is null) or (UNITMODE = nUNITMODE))
            and ((REC_KEY is null and sREC_KEY is null) or (REC_KEY is not null and sREC_KEY is not null and REC_KEY = sREC_KEY));
      exception
        when NO_DATA_FOUND then
          nRN := null;
      end;

      if lUSERDATA is null then
        if nRN is not null then
          /*P_USERPROFILES_BASE_DELETE*/USERPROFILES_BASE_DELETE(nrn => nRN, nmode => nMODE);
        end if;
      elsif nRN is null then
        /*P_USERPROFILES_BASE_INSERT*/userprofiles_base_insert(sAUTHID, nREC_TYPE, nKIND, nCOMPANY, sAPPCODE, sUNITCODE, sSHOW_METHOD, sUNITFUNC, nUNITMODE, sREC_KEY, lUSERDATA, nRN, nmode => nMODE);
      else
        /*P_USERPROFILES_BASE_UPDATE*/userprofiles_base_update(nRN, lUSERDATA, nmode => nMODE);
      end if;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end USERPROFILES_BASE_MODIFY;
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_INSERT
  /* 
  Добавление базовое
  */
  (
   sAUTHID      in varchar2         -- пользователь
  ,nREC_TYPE    in number           -- тип
  ,nKIND        in number           -- вид
  ,nCOMPANY     in number           -- организация
  ,sAPPCODE     in varchar2         -- код приложения
  ,sUNITCODE    in varchar2         -- код раздела
  ,sSHOW_METHOD in varchar2         -- метод вызова
  ,sUNITFUNC    in varchar2         -- действие раздела
  ,nUNITMODE    in number           
  ,sREC_KEY     in varchar2         -- ключ
  ,lUSERDATA    in blob             -- настройки
  ,nRN          out number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  ) 
  as
    cClob   clob;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userprofiles_base_insert(sauthid      => sAUTHID     
                                ,nrec_type    => nREC_TYPE   
                                ,nkind        => nKIND       
                                ,ncompany     => nCOMPANY    
                                ,sappcode     => sAPPCODE    
                                ,sunitcode    => sUNITCODE   
                                ,sshow_method => sSHOW_METHOD
                                ,sunitfunc    => sUNITFUNC   
                                ,nunitmode    => nUNITMODE   
                                ,srec_key     => sREC_KEY    
                                ,luserdata    => lUSERDATA   
                                ,nrn          => nRN);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* Конвертация в Clob */
      cClob := BLOB2CLOB(lbdata => lUSERDATA);

      /* генерация регистрационного номера записи */
      nRN := GEN_ID;

      /* добавление записи в таблицу */
      insert into USERPROFILES@module
      (
        RN,
        AUTHID,
        REC_TYPE,
        KIND,
        COMPANY,
        APPCODE,
        UNITCODE,
        SHOW_METHOD,
        UNITFUNC,
        UNITMODE,
        REC_KEY,
        USERDATA
      )
      values
      (
       nRN,
       sAUTHID,
       nREC_TYPE,
       nKIND,
       nCOMPANY,
       sAPPCODE,
       sUNITCODE,
       sSHOW_METHOD,
       sUNITFUNC,
       nUNITMODE,
       sREC_KEY,
       /*lUSERDATA*/  CLOB2BLOB(lcdata => cclob)
      );
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end USERPROFILES_BASE_INSERT;
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_UPDATE
  /* 
  Исправление базовое
  */
  (
   nRN          in number
  ,lUSERDATA    in blob
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  ) 
  as
    cClob   clob;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userprofiles_base_update(nrn => nRN, luserdata => lUSERDATA);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* Конвертация в Clob */
      cClob := BLOB2CLOB(lbdata => lUSERDATA);

      /* исправление записи в таблице */
      update USERPROFILES@module
        set USERDATA = /*CLOB2BLOB(lcdata => cclob)*/ lUSERDATA
        where RN= nRN;

      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(nRN , 'UserProfiles');
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end USERPROFILES_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure USERPROFILES_BASE_DELETE
  /* 
  Удаление базовое
  */
  (
   nRN          in number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский: копирование в базу MODULE */
  ) 
  as
    cClob   clob;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userprofiles_base_delete(nrn => nRN);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* удаление записи из таблицы */
      delete
        from USERPROFILES@module
       where RN = nRN;

      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(nRN ,'UserProfiles');
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end USERPROFILES_BASE_DELETE;
  /*#########################################################################################################*/

end USR_PKG_USERPROFILES;
/
