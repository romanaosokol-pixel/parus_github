create or replace package USR_PKG_RIGHTS is
  /*
  Степанов М. 17/09/2024
  Пакет для работы с правами
  */
  /*#########################################################################################################*/

  function USERGRP_USER_IS_ADMIN
  /*
  Проверка наличия в Группе пользователей "Админы"
  */
  (
   sAUTHID    in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  function USERPRIV_CHECK_CRN
  /*
  Проверка наличия прав доступа пользователя на каталог 
  */
  (
   nCRN       in number 
  ,sAUTHID    in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  procedure UNITFUNC_RIGHT_INSERT
  /* 
  Добавление действия в разделе типа "право"
  Проверять право вызовом пролога:
  pkg_env.prologue(ncompany   => nCOMPANY
                  ,nversion   => null
                  ,ncatalog   => nCRN
                  ,njur_pers  => nJUR_PERS
                  ,nhierarchy => null
                  ,sunit      => 'CostRouteListsSerialNumbers'
                  ,saction    => 'USR_FCROUTLSTSERNUMB_REPRINT'
                  ,stable     => 'FCROUTLSTSERNUMB'
                  ,ndocument  => nRN);
  */
  (
   sUNITCODE    in varchar2               /* Код раздела */
  ,sCODE        in varchar2               /* Код действия, например: USR_FCROUTLSTSERNUMB_REPRINT */
  ,sNAME        in varchar2               /* Наименование действия, например: "Повторная печать маршрутного листа" */
  ,sNUMB        in varchar2 default null  /* Номер действия в разделе. Если не задан, то будет расчитан следующий */
  );
  /*#########################################################################################################*/

  procedure USERROLES_LINK
  (
   nROLEID       in number               /* регистрационный номер записи роли */
  ,sAUTHID       in varchar2             /* идентификатор пользователя */
  ,nMODE         in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure USERROLES_UNLINK
  (
   nROLEID       in number              /* регистрационный номер записи роли */
  ,sAUTHID       in varchar2            /* идентификатор пользователя */
  ,nMODE         in number default 0    /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

end USR_PKG_RIGHTS;
/
create or replace package body USR_PKG_RIGHTS is

  /*#########################################################################################################*/

  function USERGRP_USER_IS_ADMIN
  /*
  Проверка наличия в Группе пользователей "Админы"
  */
  (
   sAUTHID    in varchar2
  ) 
  return number
  is
    nNumber   pkg_std.tnumber; 
  begin
    select sign( count(*) )
      into nNumber
      from usergrp    t
      join usergrpsp  sp  on sp.prn = t.rn
                         and sp.authid = sAUTHID
     where t.rn      = 78712877 /* Админы */ ;

    return( nNumber );

  end USERGRP_USER_IS_ADMIN;
  /*#########################################################################################################*/

  function USERPRIV_CHECK_CRN
  /*
  Проверка наличия прав доступа пользователя на каталог 
  */
  (
   nCRN       in number 
  ,sAUTHID    in varchar2
  ) 
  return number
  is
    nNumber   pkg_std.tnumber; 
  begin
    select count(*) 
      into nNumber
      from dual
     where exists ( select /*+ index(up i_userpriv_catalog_roleid) */ null
                      from userpriv   up
                     where up.catalog = nCRN
                       and up.roleid  in (select /*+ index(ur i_userroles_authid_fk) */ ur.roleid from userroles ur where ur.authid = sAUTHID)
                    union all
                    select /*+ index(up i_userpriv_catalog_authid) */ null
                      from userpriv   up
                     where up.catalog = nCRN
                       and up.authid  = sAUTHID );
    return(nNumber);
  end USERPRIV_CHECK_CRN;
  /*#########################################################################################################*/

  procedure UNITFUNC_RIGHT_INSERT
  /* 
  Добавление действия в разделе типа "право"
  Проверять право вызовом пролога:
  pkg_env.prologue(ncompany   => nCOMPANY
                  ,nversion   => null
                  ,ncatalog   => nCRN
                  ,njur_pers  => nJUR_PERS
                  ,nhierarchy => null
                  ,sunit      => 'CostRouteListsSerialNumbers'
                  ,saction    => 'USR_FCROUTLSTSERNUMB_REPRINT'
                  ,stable     => 'FCROUTLSTSERNUMB'
                  ,ndocument  => nRN);

  Если при выпролнении добавления действия ругается на T_UNITFUNC_BUPDATE, 
  то закомментировать в нём регистрацию событий "if ( PKG_IUD.PROLOGUE('UNITFUNC','U') ) then"
  */
  (
   sUNITCODE    in varchar2               /* Код раздела */
  ,sCODE        in varchar2               /* Код действия, например: USR_FCROUTLSTSERNUMB_REPRINT */
  ,sNAME        in varchar2               /* Наименование действия, например: "Повторная печать маршрутного листа" */
  ,sNUMB        in varchar2 default null  /* Номер действия в разделе. Если не задан, то будет расчитан следующий */
  )
   as
    rUnitFunc unitfunc%rowtype;
  begin
    /* Заполнение значений в переменную */
    find_unitlist_code(nflag_smart  => 0
                      ,nflag_option => 0
                      ,scode        => sUNITCODE
                      ,nrn          => rUnitFunc.prn);
    rUnitFunc.code := sCODE;
    rUnitFunc.name := sNAME;
    
    /* номер */
    if sNUMB is not null then
      rUnitFunc.numb := sNUMB;
    else
      select max(t.numb) + 1
        into rUnitFunc.numb
        from unitfunc t
       where t.unitcode = sUNITCODE;
    end if;
  
    rUnitFunc.standard       := 0;
    rUnitFunc.uncond_access  := 0;
    rUnitFunc.process_mode   := 2;
    rUnitFunc.transact_mode  := 1;
    rUnitFunc.refresh_mode   := 0;
    rUnitFunc.show_dialog    := 0;
    rUnitFunc.technology     := 0;
    rUnitFunc.asynchron_exec := 0;
  
    /* Добавление */
    p_unitfunc_base_insert(nprn              => rUnitFunc.prn
                          ,sdetailcode       => rUnitFunc.detailcode
                          ,scode             => rUnitFunc.code
                          ,sname             => rUnitFunc.name
                          ,nnumb             => rUnitFunc.numb
                          ,nsysimage         => rUnitFunc.sysimage
                          ,nstandard         => rUnitFunc.standard
                          ,noverride         => rUnitFunc.override
                          ,nuncond_access    => rUnitFunc.uncond_access
                          ,nmethod           => rUnitFunc.method
                          ,nprocess_mode     => rUnitFunc.process_mode
                          ,ntransact_mode    => rUnitFunc.transact_mode
                          ,nrefresh_mode     => rUnitFunc.refresh_mode
                          ,nshow_dialog      => rUnitFunc.show_dialog
                          ,nonly_custom_mode => rUnitFunc.only_custom_mode
                          ,ntechnology       => rUnitFunc.technology
                          ,sproducer         => rUnitFunc.producer
                          ,nasynchron_exec   => rUnitFunc.asynchron_exec
                          ,iswap_standard    => null
                          ,nrn               => rUnitFunc.rn);
  end UNITFUNC_RIGHT_INSERT;
  /*#########################################################################################################*/

  procedure USERROLES_LINK
  (
   nROLEID       in number              /* регистрационный номер записи роли */
  ,sAUTHID       in varchar2            /* идентификатор пользователя */
  ,nMODE         in number default 0    /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  as
    nRN           PKG_STD.tREF;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userroles_link(nroleid => nROLEID, sauthid => sAUTHID);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* дискретизация записей назначения */
      for C in
      (
        select NUR.ROLEID,NUR.AUTHID
          from (
                 /* одному пользователю одну роль */
                 select nROLEID as ROLEID,sAUTHID as AUTHID
                   from DUAL
                   where     nROLEID is not null
                         and sAUTHID is not null
                 /* всем пользователям одну роль */
                 union all
                 select nROLEID as ROLEID,US.AUTHID as AUTHID
                   from USERLIST US
                   where     nROLEID is not null
                         and sAUTHID is     null
                         and not exists(select null from USERSDELETED UD where UD.USERID = US.RN) /* не удалённый пользователь */
                 /* одному пользователю все роли */
                 union all
                 select RL.RN as ROLEID,sAUTHID as AUTHID
                   from ROLES RL
                   where     nROLEID is     null
                         and sAUTHID is not null
                 /* всем пользователям все роли */
                 union all
                 select RL.RN as ROLEID,US.AUTHID as AUTHID
                   from USERLIST US,
                        ROLES    RL
                   where     nROLEID is null
                         and sAUTHID is null
                         and not exists(select null from USERSDELETED UD where UD.USERID = US.RN) /* не удалённый пользователь */
               ) NUR
          where not exists(select null
                             from USERROLES UR
                              where     UR.AUTHID = NUR.AUTHID
                                    and UR.ROLEID = NUR.ROLEID)
      )
      loop
        /* фиксация начала выполнения действия */
        /*PKG_ENV.PROLOGUE( null,null,null,'UserRoles','USERROLES_INSERT','USERROLES' );*/

        /* базовое добавление записи назначения роли пользователю */
        P_USERROLES_BASE_INSERT( C.ROLEID,C.AUTHID,nRN );

        /* фиксация окончания выполнения действия */
        /*PKG_ENV.EPILOGUE( null,null,null,'UserRoles','USERROLES_INSERT','USERROLES',nRN );*/
      end loop;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end USERROLES_LINK;
  /*#########################################################################################################*/

  procedure USERROLES_UNLINK
  (
   nROLEID       in number              /* регистрационный номер записи роли */
  ,sAUTHID       in varchar2            /* идентификатор пользователя */
  ,nMODE         in number default 0    /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  as
    nRN           PKG_STD.tREF;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_userroles_unlink(nroleid => nROLEID, sauthid => sAUTHID);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* дискретизация записей назначения */
      for C in
      (
        select UR.RN
          from (
                 /* одному пользователю одну роль */
                 select nROLEID as ROLEID,sAUTHID as AUTHID
                   from DUAL
                   where     nROLEID is not null
                         and sAUTHID is not null
                 /* всем пользователям одну роль */
                 union all
                 select nROLEID as ROLEID,US.AUTHID as AUTHID
                   from USERLIST US
                   where     nROLEID is not null
                         and sAUTHID is     null
                         and not exists(select null from USERSDELETED UD where UD.USERID = US.RN) /* не удалённый пользователь */
                 /* одному пользователю все роли */
                 union all
                 select RL.RN as ROLEID,sAUTHID as AUTHID
                   from ROLES RL
                   where     nROLEID is     null
                         and sAUTHID is not null
                 /* всем пользователям все роли */
                 union all
                 select RL.RN as ROLEID,US.AUTHID as AUTHID
                   from USERLIST US,
                        ROLES    RL
                   where     nROLEID is null
                         and sAUTHID is null
                        and not exists(select null from USERSDELETED UD where UD.USERID = US.RN) /* не удалённый пользователь */
               ) NUR,
               USERROLES UR
          where     UR.AUTHID = NUR.AUTHID
                and UR.ROLEID = NUR.ROLEID
      )
      loop
        /* фиксация начала выполнения действия */
        /*PKG_ENV.PROLOGUE( null,null,null,'UserRoles','USERROLES_DELETE','USERROLES',C.RN );*/

        /* базовое удаление записи назначения роли пользователю */
        P_USERROLES_BASE_DELETE( C.RN );

        /* фиксация окончания выполнения действия */
        /*PKG_ENV.EPILOGUE( null,null,null,'UserRoles','USERROLES_DELETE','USERROLES',C.RN );*/
      end loop;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end USERROLES_UNLINK;
  /*#########################################################################################################*/

end USR_PKG_RIGHTS;
/
