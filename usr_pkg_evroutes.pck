create or replace package USR_PKG_EVROUTES is
  /*
  Package предназначен для работы с разделом "Маршруты событий".
  EventRoutes                   EVROUTES      ER    Маршруты событий
  EventRoutesPoints             EVRTPOINTS    ERP   Маршруты событий (точки)
  EventRoutesPointExecuters     EVRTPTEXEC    ERPE  Маршруты событий (исполнители в точках)
  EventRoutesPointsPasses       EVRTPTPASS    ERPP  Маршруты событий (точки перехода)
  EventRoutesPointsNotifs       EVRTPTNOT     ERPN  Маршруты событий (уведомления в точках) 
  EventRoutesPointsNotifsAddrs  EVRTPTNTADDR  ERPNA Маршруты событий (адресаты уведомлений в точках)
  */
  --#########################################################################################################

  function EVROUTES_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN       in number
  ) 
  return EVROUTES%ROWTYPE;
  --#########################################################################################################

  function EVROUTES_GET_BY_CET
  /*
  Заголовок. Поиск RN маршрута по RN типового события
  */
  (
   nRN    in number
  ) 
  return number;
  --#########################################################################################################

  procedure EVROUTES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVROUTES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVROUTES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVROUTES_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVROUTES_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVROUTES_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVROUTES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function EVRTPOINTS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN       in number
  ) 
  return EVRTPOINTS%ROWTYPE;
  --#########################################################################################################

  function EVRTPOINTS_GET_BY_CETS
  /*
  Заголовок. Поиск RN точки маршрута по RN статуса типового события
  */
  (
   nRN    in number
  ) 
  return number;
  --#########################################################################################################

  function EVRTPOINTS_GET_CES_NAME
  /*
  Спецификация. Определение наименования типового статуса по RN точки маршрута
  */
  (
   nRN      in number
  ) 
  return varchar2;
  --#########################################################################################################

  function EVRTPOINTS_GET_ERPE_MAIL_LIST
  /*
  Исполнители. Считывание записи
  */
  (
   nRN                in number
  ,nSEND_PERSON       in number default null
  ,sSEND_USER_AUTHID  in varchar2 default null
  ) 
  return varchar2;
  --#########################################################################################################

  function EVRTPOINTS_GET_NEXT_POINT
  /*
  Точки. Получить следующую точку
  Выбирается либо единственная точка перехода, либо та, у которой заполнено свойство "По умолчанию"
  */
  (
   nRN                in number   /* текущая точка */
  ,nFLAGSMART         in number default 0
  ,sPASS_COND_PROC    in varchar2 default null
  ,sCOMMENTARY        in varchar2 default null
  ) 
  return number;
  --#########################################################################################################

  function EVRTPOINTS_GET_NO_RIGHTS
  /*
  Функция проверки наличия в точке маршрута записи в Исполнители в точке маршрута, к которой относится пользователь, у которой нет никаких прав.
  Запрет: 0-нет, 1-есть
  */
  (
   nFLAGSMART       in number default 0 
  ,nRN              in number
  ,sAUTHID          in varchar2   
  )
  return number;
  --#########################################################################################################

  procedure EVRTPOINTS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPOINTS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPOINTS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPOINTS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPOINTS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function EVRTPTEXEC_GET
  /*
  Исполнители. Считывание
  */
  (
   nRN       in number
  ) 
  return EVRTPTEXEC%ROWTYPE;
  --#########################################################################################################

  procedure EVRTPTEXEC_GET_LIST
  /*
  Маршруты событий (адресаты уведомлений в точках). Назначение ответственного экономиста
  */
  (
   nFLAGSMART   in number default 0
  ,rROW         in clnevents%rowtype
  ,sPARAM_LIST  in varchar2 /* список через ";" */
  ,aEVRTPTEXEC  out usr_pkg_pub_const.tEvrtPtExec
  );
  --#########################################################################################################

  procedure EVRTPTEXEC_AINSERT
  /*
  Исполнители. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPTEXEC_BUPDATE
  /*
  Исполнители. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPTEXEC_AUPDATE
  /*
  Исполнители. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPTEXEC_BDELETE
  /*
  Исполнители. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPTEXEC_CHECK_BASE
  /*
  Исполнители. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EVRTPTEXEC_SET
  /*
  Маршруты событий (исполнители в точках). Назначение исполнителей в событии
  */
  (
   nCLNEVENTS   in number
  ,nFLAGSMART   in number
  ,sPARAM_LIST  in varchar2 /* список через ";" */
  );
  --#########################################################################################################

  function EVRTPTPASS_GET
  /*
  Точки переходов из точки маршрута
  */
  (
   nRN      in number
  ) 
  return evrtptpass%rowtype;
  --#########################################################################################################

  function EVRTPTPASS_GET_BY_ERP
  /*
  Поиск точки перехода по точкам маршрута
  */
  (
   nPRN           in number
  ,nNEXT_POINT    in number
  ,nFLAGSMART     in number default 0
  )
  return number;
  --#########################################################################################################

  function EVRTPTNOT_GET
  /*
  Уведомления в точках
  */
  (
   nRN      in number
  ) 
  return evrtptnot%rowtype;
  /*#########################################################################################################*/

  PROCEDURE EVRTPTNOT_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rROW         in evrtptnot%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure EVRTPTNOT_CREATE_WARNMSG_TEXT
  /*
  Уведомления в точках. Формирование текста заголовка и тела сообщения
  */
  (
   nFLAGSMART   in number
  ,nCLNEVENTS   in number
  ,nACT_TYPE    in number /* тип активизации (после какого действия) */
                          /* 0 - после выполнения действия в точке маршрута (не используется) */
                          /* 1 - после выполнения отката действия в точке маршрута (не используется) */
                          /* 2 - после выполнения переадресации в точке маршрута */
                          /* 3 - после перехода в следующую точку маршрута */
                          /* 4 - после выполнения возврата в предыдущую точку маршрута */
                          /* 5 - после истечения времени пребывания в точке маршрута */
                          /* 6 - после истечения времени исполнения у исполнителя */
                          /* 7 - после добавления примечания к событию в точке маршрута */
  ,STITLE       out varchar2
  ,STEXT        out varchar2
  );
  --#########################################################################################################

  procedure EVRTPTNTADDR_SET
  /*
  Маршруты событий (адресаты уведомлений в точках). Назначение получателей уведомления
  */
  (
   nFLAGSMART   in number default 0
  ,nEVENT       in number
  ,sPARAM_LIST  in varchar2 /* список через ";" */
  );
  --#########################################################################################################

end USR_PKG_EVROUTES;
/
create or replace package body USR_PKG_EVROUTES is

  --#########################################################################################################

  function EVROUTES_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number
  ) 
  return evroutes%rowtype
  is
    rRow evroutes%rowtype;
  begin
    begin
      select * into rRow from evroutes where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVROUTES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVROUTES')));
    end;
    return(rRow);
  end EVROUTES_GET;
  --#########################################################################################################

  function EVROUTES_GET_BY_CET
  /*
  Заголовок. Поиск RN маршрута по RN типового события
  */
  (
   nRN    in number
  ) 
  return number
  is
    nRes    pkg_std.tref; 
  begin
    begin
      select rn into nRes from evroutes where event_type = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVROUTES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVROUTES')));
    end;
    return(nRes);
  end EVROUTES_GET_BY_CET;
  --#########################################################################################################

  procedure EVROUTES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    evroutes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end EVROUTES_AINSERT;
  --#########################################################################################################

  procedure EVROUTES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVROUTES_BUPDATE;
  --#########################################################################################################

  procedure EVROUTES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    evroutes_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end EVROUTES_AUPDATE;
  --#########################################################################################################

  procedure EVROUTES_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVROUTES_BDELETE;
  --#########################################################################################################

  procedure EVROUTES_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVROUTES_BMOVE_IN;
  --#########################################################################################################

  procedure EVROUTES_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end EVROUTES_BMOVE_OUT;
  --#########################################################################################################

  procedure EVROUTES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVROUTES_CHECK_BASE;
  --#########################################################################################################

  function EVRTPOINTS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN      in number
  ) 
  return evrtpoints%rowtype
  is
    rRow evrtpoints%rowtype;
  begin
    begin
      select * into rRow from evrtpoints where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVRTPOINTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPOINTS')));
    end;
    return(rRow);
  end EVRTPOINTS_GET;
  --#########################################################################################################

  function EVRTPOINTS_GET_BY_CETS
  /*
  Заголовок. Поиск RN точки маршрута по RN статуса типового события
  */
  (
   nRN    in number
  ) 
  return number
  is
    nRes    pkg_std.tref; 
  begin
    begin
      select rn into nRes from evrtpoints where event_status = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNTYPSTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNTYPSTS')));
    end;
    return(nRes);
  end EVRTPOINTS_GET_BY_CETS;
  --#########################################################################################################

  function EVRTPOINTS_GET_CES_NAME
  /*
  Спецификация. Определение наименования типового статуса по RN точки маршрута
  */
  (
   nRN      in number
  ) 
  return varchar2
  is
    sRes  clnevnstats.evnstat_name%type; 
  begin
    begin
      select ces.evnstat_name
        into sRes
        from evrtpoints   erp
            ,clnevntypsts cets
            ,clnevnstats  ces
       where erp.rn  = nRN
         and cets.rn = erp.event_status
         and ces.rn  = cets.event_status;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVRTPOINTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPOINTS')));
    end;
    return(sRes);
  end EVRTPOINTS_GET_CES_NAME;
  --#########################################################################################################

  function EVRTPOINTS_GET_ERPE_MAIL_LIST
  /*
  Исполнители. Считывание записи
  */
  (
   nRN                in number
  ,nSEND_PERSON       in number default null
  ,sSEND_USER_AUTHID  in varchar2 default null
  ) 
  return varchar2
  is
    sOut    pkg_std.tstring; 
  begin
    for c in (
              /* Группы */
              select al.mail
                from evrtptexec t
                    ,usergrp    ugp
                    ,usergrpsp  ugps
                    ,clnpersons cp
                    ,agnlist    al
               where t.prn          = nRN
                 and t.default_exec = 1
                 and ugp.rn         = t.user_group
                 and ugps.prn       = ugp.rn
                 and cp.pers_authid = ugps.authid
                 and al.rn          = cp.pers_agent
              union 
              /* Сотрудник */
              select al.mail
                from evrtptexec t
                    ,clnpersons cp
                    ,agnlist    al
               where t.prn          = nRN
                 and t.default_exec = 1
                 and cp.rn          = t.person
                 and al.rn          = cp.pers_agent
              union 
              /* Инициатор */
              select al.mail
                from clnpersons cp
                    ,agnlist    al
               where cp.rn  = nSEND_PERSON
                 and al.rn  = cp.pers_agent
              union 
              /* Инициатор */
              select al.mail
                from clnpersons cp
                    ,agnlist    al
               where cp.pers_authid = sSEND_USER_AUTHID
                 and al.rn          = cp.pers_agent
             )
      loop
        sOut := strcombine(sOut, c.mail, ';');
      end loop;

    return(sOut);

  end EVRTPOINTS_GET_ERPE_MAIL_LIST;
  --#########################################################################################################

  function EVRTPOINTS_GET_NEXT_POINT
  /*
  Точки. Получить следующую точку.
  Выбирается либо единственная точка перехода, либо та, у которой заполнено свойство "По умолчанию"
  */
  (
   nRN                in number   /* текущая точка */
  ,nFLAGSMART         in number default 0
  ,sPASS_COND_PROC    in varchar2 default null
  ,sCOMMENTARY        in varchar2 default null
  ) 
  return number
  is
    nOut    pkg_std.tref; 
  begin
    begin
      select t.next_point
        into nOut
        from (select a.*, count(*) over() as ncount 
                from evrtptpass a 
               where a.prn = nRN) t
       where (cmp_vc2(t.pass_cond_proc, sPass_Cond_Proc) = 1 or sPass_Cond_Proc is null)
         and (cmp_vc2(t.commentary, sCommentary) = 1 or sCommentary is null )
         and (cmp_vc2( upper(usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 157879269 /*160125665*/, ndocument => t.rn)), 'ДА' ) = 1 /* По умолчанию */
              or 
              t.ncount = 1) ;
    exception
      when no_data_found then
        p_exception(0, 'Не найдено следуюшей точки перехода для точки маршрута с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTPASS')));
      when too_many_rows then
        p_exception(0, 'Найдено больше одной следуюшей точки перехода для точки маршрута с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTPASS')));
      when others then
        p_exception(0, 'Неопределённая ситуация при определении точки перехода для точки маршрута с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTPASS')));
    end;

    return(nOut);

  end EVRTPOINTS_GET_NEXT_POINT;
  --#########################################################################################################

  function EVRTPOINTS_GET_NO_RIGHTS
  /*
  Функция проверки наличия в точке маршрута записи в Исполнители в точке маршрута, к которой относится пользователь, у которой нет никаких прав.
  Запрет: 0-нет, 1-есть
  */
  (
   nFLAGSMART       in number default 0 
  ,nRN              in number
  ,sAUTHID          in varchar2   
  )
  return number 
  is
    nCHECK_RESULT       pkg_std.tnumber := 0;
    nPERSON             PKG_STD.tREF;
    sPERSON             CLNPERSONS.CODE%type;
    sAGENT              AGNLIST.AGNABBR%type;
    nINIT_PERSON        CLNEVENTS.INIT_PERSON%type;
    sINIT_AUTHID        CLNEVENTS.INIT_AUTHID%type;
    nCLIENT_CLIENT      CLNEVENTS.CLIENT_CLIENT%type;
    nCLIENT_PERSON      CLNEVENTS.CLIENT_PERSON%type;
  begin
    nCHECK_RESULT := 0;

    select count(*)
      into nCHECK_RESULT
      from DUAL
     where exists ( select null
                      from EVRTPTEXEC t
                     where t.PRN = /*nPOINT*/nRN
                       and (( DO_ENABLED     = /*1*/ 0 /*and nACTION_CODE = 0*/ ) /*or */and 
                            ( UNDO_ENABLED   = /*1*/ 0 /*and nACTION_CODE = 1*/ ) /*or */and 
                            ( GO_ENABLED     = /*1*/ 0 /*and nACTION_CODE = 2*/ ) /*or */and 
                            ( SEND_ENABLED   = /*1*/ 0 /*and nACTION_CODE = 3*/ ) /*or */and 
                            ( RETURN_ENABLED = /*1*/ 0 /*and nACTION_CODE = 4*/ ) /*or */and 
                            ( CLOSE_ENABLED  = /*1*/ 0 /*and nACTION_CODE = 5*/ ) /*or */and 
                            ( OPEN_ENABLED   = /*1*/ 0 /*and nACTION_CODE = 6*/ ))
                       and F_EVRTPTEXEC_CHECK_AUTHID
                           (
                             COMPANY,
                             /*UTILIZER*/sAUTHID,
                             /*nPERSON*/null,
                             /*nEVENT*/null,
                             nINIT_PERSON,
                             sINIT_AUTHID,
                             nCLIENT_CLIENT,
                             nCLIENT_PERSON,
                             /*nPOINT*/nRN,
                             PREDEFINED_EXEC,
                             PREDEFINED_PROC,
                             CLIENT,
                             DIVISION,
                             POST,
                             POST_IN_DIV,
                             PERSON,
                             STAFFGRP,
                             USER_GROUP,
                             USER_AUTHID
                           ) > 0 );

    if nCHECK_RESULT > 0 then
      nCHECK_RESULT := 1;
    end if;

    if nFLAGSMART = 0 and nCHECK_RESULT = 1 then
      p_exception(0, 'Недостаточно полномочий для выполнения действий в точке маршрута "%s".', evrtpoints_get_ces_name( nrn => nRN ) ); 
    end if;
    
    return nCHECK_RESULT;

  end EVRTPOINTS_GET_NO_RIGHTS;
  --#########################################################################################################

  procedure EVRTPOINTS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */    
    /* Проверка базовая */
    evrtpoints_check_base(nrn => nRN, ncompany => nCOMPANY);

  end EVRTPOINTS_AINSERT;
  --#########################################################################################################

  procedure EVRTPOINTS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVRTPOINTS_BUPDATE;
  --#########################################################################################################

  procedure EVRTPOINTS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    evrtpoints_check_base(nrn => nRN, ncompany => nCOMPANY);

  end EVRTPOINTS_AUPDATE;
  --#########################################################################################################

  procedure EVRTPOINTS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVRTPOINTS_BDELETE;
  --#########################################################################################################

  procedure EVRTPOINTS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVRTPOINTS_CHECK_BASE;
  --#########################################################################################################

  function EVRTPTEXEC_GET
  /*
  Исполнители. Считывание записи
  */
  (
   nRN      in number
  ) 
  return evrtptexec%rowtype
  is
    rRow evrtptexec%rowtype;
  begin
    begin
      select * into rRow from evrtptexec where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVRTPTEXEC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTEXEC')));
    end;
    return(rRow);
  end EVRTPTEXEC_GET;
  --#########################################################################################################

  procedure EVRTPTEXEC_GET_LIST
  /*
  Маршруты событий (адресаты уведомлений в точках). Назначение ответственного экономиста
  */
  (
   nFLAGSMART   in number default 0
  ,rROW         in clnevents%rowtype
  ,sPARAM_LIST  in varchar2 /* список через ";" */
  ,aEVRTPTEXEC  out usr_pkg_pub_const.tEvrtPtExec
  ) 
  is
    rDocument         usr_pkg_pub_const.tdoc_base_values_rec;
    nContracts        pkg_std.tref;
    sResp_Economist   pkg_std.tstring;
    nResp_Economist   pkg_std.tref;
    nClnPersons       pkg_std.tref;
    nProject          pkg_std.tref;
    aRNList           udo_tp_numtable := udo_tp_numtable();
    nIndex            pkg_std.tnumber := 0; 
    rClnevnHist       clnevnhist%rowtype;
    rClnevnHistPrev   clnevnhist%rowtype;
    rEvRoutes         evroutes%rowtype;
    rEvRtPoints       evrtpoints%rowtype;
    rEvRtPointsPrev   evrtpoints%rowtype;

    sVarchar          pkg_std.tstring;
    nNumber           pkg_std.tnumber;
  begin
    /* Документ статусной модели */
    rDocument := usr_pkg_document.get_base_values(nflagsmart => 1
                                                 ,nrn        => rROW.LINKED_RN
                                                 ,ncompany   => rROW.COMPANY
                                                 ,sunitcode  => rROW.LINKED_UNIT);

    /* С признаком "Ответственный исполнитель" кроме тех, кто определяется процедурой */
    if strin(0, sPARAM_LIST) = 1 then 
      /* Считывание доп.данных события */
      usr_pkg_clnevents.clnevents_get_additional_data(rrow             => rROW
                                                     ,rclnevnhist      => rClnevnHist
                                                     ,rclnevnhist_prev => rClnevnHistPrev
                                                     ,revroutes        => rEvRoutes
                                                     ,revrtpoints      => rEvRtPoints
                                                     ,revrtpoints_prev => rEvRtPointsPrev);
      /* Добавление в массив всех исполнителей по-умолчанию, которые назначаются не процедурой */
      select t.* bulk collect
        into aEVRTPTEXEC
        from evrtptexec t
       where t.prn              = rEvRtPoints.rn
         and t.responsible      = 1
         and t.predefined_proc  is null;
    end if;

    /* Для события "ВходСчетаОплат", статус "СогласСчетаОМТС" */
    if strin(1, sPARAM_LIST) = 1 then 

      /* Если пользователи в списке */
      if utilizer in ('MUKHORTIN_VA', 'NOVIKOV_VA') then
        nClnPersons := 7621203;  -- OSTAPENKO_ES
      else 
        if sysdate < '22-FEB-2025' then --between '11-JUN-2025' and '07-JUL-2025'
--          nClnPersons := 138810795; -- Коваль (KOVAL_OA)
          --nClnPersons := 265586494; -- Солошенков (SOLOSHENKOV_DV)
          nClnPersons := 7621203;  -- OSTAPENKO_ES
        else 
          nClnPersons := 61833393; -- Канаев (KANAEV_IY) по-умолчанию
        end if;
      end if;

      /* Добавление в массив */
      if nClnPersons is not null then                                
        nIndex := aEVRTPTEXEC.count + 1;
        aEVRTPTEXEC(nIndex).person := nClnPersons;
      end if;

    end if;

      /* Для события "Переносы между тем.", статус "Согласование разр." */
    if strin(3, sPARAM_LIST) = 1 then 

      /* Получение списка контрагентов, ответственных за проекты  документа */
      usr_pkg_faceacc_replace.faceacc_replace_get_resp_list(nflagsmart => 1
                                                           ,nrn        => rROW.LINKED_RN
                                                           ,arnlist    => aRNList);
      /* По контрагентам ответственным за проекты */
      for c in ( select column_value from table(cast(aRNList as udo_tp_numtable)) ) 
      loop
        /* Ответственный за проект. Сотрудник. RN */
        find_clnpersons_by_agent(nflag_smart => nFLAGSMART
                                ,ncompany    => rROW.COMPANY
                                ,nagent      => c.column_value
                                ,ddate       => sysdate
                                ,nclnpersons => nClnPersons);
        /* Добавление в массив */
        if nClnPersons is not null then                                
          nIndex := aEVRTPTEXEC.count + 1;
          aEVRTPTEXEC(nIndex).person := nClnPersons;
        end if;

      end loop;

    end if;

    /* Ответсвенный экономист */
    if strin(4, sPARAM_LIST) = 1 then 

      /* Если найден ЛС */
      if rDocument.nfaceacc is not null then                                                  
        /* Поиск договора по ЛС */
        find_contracts_faceacc(nflag_smart  => 1
                              ,ncompany     => rROW.COMPANY
                              ,nfaceacc     => rDocument.nfaceacc
                              ,sfaceacc     => null
                              ,ncontract    => null
                              ,ncontractout => nContracts
                              ,sdoc_type    => sVarchar
                              ,sdoc_pref    => sVarchar
                              ,sdoc_numb    => sVarchar
                              ,ddoc_date    => sVarchar
                              ,nstage       => nNumber
                              ,sstagenumb   => sVarchar
                              ,sfaceaccout  => sVarchar);
        /* Если договор НЕ найден */
        if nContracts is null then                                                  

          /* Поиск проекта по ЛС */
          nProject := usr_pkg_project.project_get_rn_by_faceacc(nflagsmart => 1, nfaceacc => rDocument.nfaceacc);

          /* Если проект найден */
          if nProject is not null then        
            /* Поиск договора по проекту */
            nContracts := usr_pkg_doclinks.doclinks_link_out_doc(sin_unitcode   => 'Projects'
                                                                ,nin_document   => nProject
                                                                ,sout_unitcode  => 'Contracts');
          end if;                                                            
        end if;
        
        /* Если договор найден */
        if nContracts is not null then 

          /* Ответственный экономист. Контрагент. Мнемокод */
          sResp_Economist := usr_pkg_contracts.contracts_get_resp_economist(nrn => nContracts, ncompany => rROW.COMPANY);

          /* Ответственный экономист. Контрагент. RN */
          find_agnlist_code(nflag_smart  => 0
                           ,nflag_option => 0
                           ,ncompany     => rROW.COMPANY
                           ,scode        => sResp_Economist
                           ,nrn          => nResp_Economist);
          /* Ответственный экономист. Сотрудник. RN */
          find_clnpersons_by_agent(nflag_smart => 0
                                  ,ncompany    => rROW.COMPANY
                                  ,nagent      => nResp_Economist
                                  ,ddate       => current_date
                                  ,nclnpersons => nClnPersons);
        /* Если договор НЕ найден */
        else
          p_exception(nFLAGSMART, 'Невозможно определить договор по документу с RN "%s" в разделе "%s".'
                     ,rROW.LINKED_RN
                     ,f_unitlist_getname(sunitcode => rROW.LINKED_UNIT));
        end if;

        /* Добавление в массив */
        if nClnPersons is not null then                                
          nIndex := aEVRTPTEXEC.count + 1;
          aEVRTPTEXEC(nIndex).person := nClnPersons;
        end if;
      end if;                          
    end if;                          

    /* "ВходСчетаОплат", статус "ИнформЗаказчика". Если документ в каталоге "ОТД", то Аскеров. */
    if strin(5, sPARAM_LIST) = 1 then 

      /* Если связано с разделом Входящие счета на оплату и каталог документа "ОТД" */
      if rROW.LINKED_UNIT = 'PaymentAccountsIn' and rDocument.ncrn in ( 50190777 ) then
        /* Аскеров */
        nClnPersons := 50190751;
      /* Иначе, чтобы получатель был определён, и не создавалось рассылки с ошибкой по причине отсутствия получателя */
      else        
        /* Степанов М. */
        nClnPersons := 82414787; 
      end if;

      /* Добавление в массив */
      if nClnPersons is not null then                                
        nIndex := aEVRTPTEXEC.count + 1;
        aEVRTPTEXEC(nIndex).person := nClnPersons;
      end if;
    end if;                          

    /* Инициатор события */
    if strin(6, sPARAM_LIST) = 1 then 

      /* Если задан RN сотрудника */
      if rROW.INIT_PERSON is not null then                                
        nClnPersons := rRoW.INIT_PERSON;
      /* Если задан AAUTHID сотрудника */
      elsif rROW.INIT_AUTHID is not null then                                
        find_clnpersons_authid_ex( ncompany     => rRow.COMPANY
                                  ,ddate        => rRow.REG_DATE
                                  ,spers_authid => rRow.INIT_AUTHID
                                  ,npers_agent  => nClnPersons );
      end if;

      /* Если сотрудник найден */
      if nClnPersons is not null then
        /* Добавление в массив */
        nIndex := aEVRTPTEXEC.count + 1;
        aEVRTPTEXEC(nIndex).person := nClnPersons;
      end if;

    end if;                          

  end EVRTPTEXEC_GET_LIST;
  --#########################################################################################################

  procedure EVRTPTEXEC_AINSERT
  /*
  Исполнители. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    evrtptexec_check_base(nrn => nRN, ncompany => nCOMPANY);

  end EVRTPTEXEC_AINSERT;
  --#########################################################################################################

  procedure EVRTPTEXEC_BUPDATE
  /*
  Исполнители. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVRTPTEXEC_BUPDATE;
  --#########################################################################################################

  procedure EVRTPTEXEC_AUPDATE
  /*
  Исполнители. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    evrtptexec_check_base(nrn => nRN, ncompany => nCOMPANY);

  end EVRTPTEXEC_AUPDATE;
  --#########################################################################################################

  procedure EVRTPTEXEC_BDELETE
  /*
  Исполнители. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVRTPTEXEC_BDELETE;
  --#########################################################################################################

  procedure EVRTPTEXEC_CHECK_BASE
  /*
  Исполнители. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EVRTPTEXEC_CHECK_BASE;
  --#########################################################################################################

  procedure EVRTPTEXEC_SET
  /*
  Маршруты событий (исполнители в точках). Назначение исполнителей в событии
  */
  (
   nCLNEVENTS   in number
  ,nFLAGSMART   in number
  ,sPARAM_LIST  in varchar2 /* список через ";" */
  ) 
  is
    rRow              clnevents%rowtype;

    aEvrTptExec       usr_pkg_pub_const.tEvrTptExec;
  begin
    /* Событие */
    rRow := usr_pkg_clnevents.clnevents_get(nrn => nCLNEVENTS);

    /* Поиск исполнителей по параметрам */
    evrtptexec_get_list(nflagsmart  => nFLAGSMART
                       ,rrow        => rRow
                       ,sparam_list => sPARAM_LIST
                       ,aevrtptexec => aEvrTptExec);

    /* Назначение */
    if aEvrTptExec.count != 0 then

      for i in aEvrTptExec.first .. aEvrTptExec.last 
      loop
        if aEvrTptExec(i).client is not null and aEvrTptExec(i).post is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, nclient => aEvrTptExec(i).client, npost => aEvrTptExec(i).post);
        elsif aEvrTptExec(i).client is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, nclient => aEvrTptExec(i).client);
        elsif aEvrTptExec(i).division is not null and aEvrTptExec(i).post is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, ndivision => aEvrTptExec(i).division, npost => aEvrTptExec(i).post);
        elsif aEvrTptExec(i).division is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, ndivision => aEvrTptExec(i).division);
        elsif aEvrTptExec(i).post is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, npost => aEvrTptExec(i).post);
        elsif aEvrTptExec(i).post_in_div is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, npost_in_div => aEvrTptExec(i).post_in_div);
        elsif aEvrTptExec(i).person is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, nperson => aEvrTptExec(i).person);
        elsif aEvrTptExec(i).staffgrp is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, nstaffgrp => aEvrTptExec(i).staffgrp);
        elsif aEvrTptExec(i).user_group is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, nuser_group  => aEvrTptExec(i).user_group);
        elsif aEvrTptExec(i).user_authid is not null then
          p_evrtptexec_predefined_assign(ncompany => rRow.company, suser_authid => aEvrTptExec(i).user_authid);
        end if;
      end loop;
    end if;

  end EVRTPTEXEC_SET;
  --#########################################################################################################

  function EVRTPTPASS_GET
  /*
  Точки переходов из точки маршрута
  */
  (
   nRN      in number
  ) 
  return evrtptpass%rowtype
  is
    rRow evrtptpass%rowtype;
  begin
    begin
      select * into rRow from evrtptpass where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVRTPTPASS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTPASS')));
    end;
    return(rRow);
  end EVRTPTPASS_GET;
  --#########################################################################################################

  function EVRTPTPASS_GET_BY_ERP
  /*
  Поиск точки перехода по точкам маршрута
  */
  (
   nPRN           in number
  ,nNEXT_POINT    in number
  ,nFLAGSMART     in number default 0
  ) 
  return number
  is
    nRef    pkg_std.tref; 
  begin
    begin
      select rn 
        into nRef 
        from evrtptpass 
       where prn = nPRN
         and next_point = nNEXT_POINT;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nPRN, sunit_table => 'EVRTPTPASS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nPRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTPASS')));
    end;

    return(nRef);

  end EVRTPTPASS_GET_BY_ERP;
  --#########################################################################################################

  function EVRTPTNOT_GET
  /*
  Уведомления в точках
  */
  (
   nRN      in number
  ) 
  return evrtptnot%rowtype
  is
    rRow evrtptnot%rowtype;
  begin
    begin
      select * into rRow from evrtptnot where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'EVRTPTNOT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EVRTPTNOT')));
    end;
    return(rRow);
  end EVRTPTNOT_GET;
  /*#########################################################################################################*/

  PROCEDURE EVRTPTNOT_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rROW         in evrtptnot%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_evrtptnot_base_update(ncompany           => rROW.COMPANY
                             ,nrn                => rROW.RN
                             ,nmsg_catalog       => rROW.MSG_CATALOG
                             ,nmsg_type          => rROW.MSG_TYPE
                             ,stitle             => rROW.TITLE
                             ,smessage           => rROW.MESSAGE
                             ,nprovider          => rROW.PROVIDER
                             ,nact_type          => rROW.ACT_TYPE
                             ,nsend_type         => rROW.SEND_TYPE
                             ,ndelete_after_send => rROW.DELETE_AFTER_SEND
                             ,nadd_event_info    => rROW.ADD_EVENT_INFO);

    /* Режим выполнения: 1 - пользовательский */
    /* elsif nMODE = 1 then*/
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  END EVRTPTNOT_UPDATE;
  --#########################################################################################################

  procedure EVRTPTNOT_CREATE_WARNMSG_TEXT
  /*
  Уведомления в точках. Формирование текста заголовка и тела сообщения
  */
  (
   nFLAGSMART   in number
  ,nCLNEVENTS   in number
  ,nACT_TYPE    in number /* тип активизации (после какого действия) */
                          /* 0 - после выполнения действия в точке маршрута (не используется) */
                          /* 1 - после выполнения отката действия в точке маршрута (не используется) */
                          /* 2 - после выполнения переадресации в точке маршрута */
                          /* 3 - после перехода в следующую точку маршрута */
                          /* 4 - после выполнения возврата в предыдущую точку маршрута */
                          /* 5 - после истечения времени пребывания в точке маршрута */
                          /* 6 - после истечения времени исполнения у исполнителя */
                          /* 7 - после добавления примечания к событию в точке маршрута */
  ,STITLE       out varchar2
  ,STEXT        out varchar2
  ) 
  is
    rRow              clnevents%rowtype;
    rClnevnHist       clnevnhist%rowtype;
    rClnevnHistPrev   clnevnhist%rowtype;
    rEvRoutes         evroutes%rowtype;
    rEvRtPoints       evrtpoints%rowtype;
    rEvRtPointsPrev   evrtpoints%rowtype;
    sPers_Agent       pkg_std.tstring; 
    nPers_Agent       pkg_std.tref; 
    nClnEvNotes       pkg_std.tref; 
    
    sVarchar  pkg_std.tstring; 
    nNumber   pkg_std.tnumber; 
  begin
    /* Проверка параметров */
    if nvl(nACT_TYPE, -1) not in (0,1,2,3,4,5,6,7) then
      p_exception(nFLAGSMART, 'Неверное значение <%s> параметра <nACT_TYPE>', nACT_TYPE); 
      return;
    end if;

    /* Считывание */
    rRow := usr_pkg_clnevents.clnevents_get(nrn => nCLNEVENTS);
    usr_pkg_clnevents.clnevents_get_additional_data(rrow             => rRow
                                                   ,rclnevnhist      => rClnevnHist
                                                   ,rclnevnhist_prev => rClnevnHistPrev
                                                   ,revroutes        => rEvRoutes
                                                   ,revrtpoints      => rEvRtPoints
                                                   ,revrtpoints_prev => rEvRtPointsPrev);
    /* Заголовок */
    STITLE  := 'Уведомление статусной модели.';

    /* Содержание */
    STEXT := strcombine(STEXT, f_unitlist_getname(sunitcode => rRow.linked_unit), cr||'Раздел: ');
    STEXT := strcombine(STEXT, f_docdescrs_get_description(sunitcode => rRow.linked_unit, ndocument => rRow.linked_rn), cr||'Документ: ');
    STEXT := strcombine(STEXT, get_unitfunc_name_code(nflag_smart => nFLAGSMART, scode => rClnevnHist.action_code), cr||'Действие: ');
    /* Действие выполнил */
    sPers_Agent := null;
    nPers_Agent := null;
    find_clnpersons_authid_ex(ncompany     => rRow.company
                             ,ddate        => rRow.reg_date
                             ,spers_authid => rRow.authid
                             ,npers_agent  => nPers_Agent);
    sPers_Agent := get_agnlist_agnabbr_id(nflag_smart => nFLAGSMART, nrn => nPers_Agent);
    STEXT := strcombine(STEXT, sPers_Agent, cr||'Действие выполнил: ');
    STEXT := strcombine(STEXT, usr_pkg_evroutes.evrtpoints_get_ces_name(nrn => rEvRtPoints.rn), cr||'Текущий статус: ');


    /* тип активизации (после какого действия) */
    case nACT_TYPE 

      /* 2 - после выполнения переадресации в точке маршрута */
      when 2 then
        sPers_Agent := null;
        find_clnpersons_agent(nflag_smart  => nFLAGSMART
                             ,ncompany     => rRow.company
                             ,sperson_code => get_clnpersons_code_id(nflag_smart => nFLAGSMART, nrn => rClnevnHist.send_person)
                             ,nrn          => nNumber
                             ,sagnabbr     => sPers_Agent);
        STEXT := strcombine(STEXT, sPers_Agent, cr||'Направлено: ');

      /* 3 - после перехода в следующую точку маршрута */
      when 3 then

        /* Предыдущий статус */
        if rEvRtPointsPrev.rn is not null then
          STEXT := strcombine(STEXT, usr_pkg_evroutes.evrtpoints_get_ces_name(nrn => rEvRtPointsPrev.rn), cr||'Предыдущий статус: ');
        end if;
        /* 28/07/2025 KHOK. Добавлено примечание изменения Статуса */
        /* Находим примечание к событию */
        if rClnevnHistPrev.Note is not null then
          p_clnevnotes_get_attrib(nrn => rClnevnHistPrev.Note, note => sVarchar);
          STEXT := strcombine(STEXT, TRIM(sVarchar), cr||'Примечание: ');
        end if;
        if rClnevnHist.Note is not null then
          p_clnevnotes_get_attrib(nrn => rClnevnHist.Note, note => sVarchar);
          STEXT := strcombine(STEXT, TRIM(rClnevnHist.Note), cr||' ');
        end if;

        /* Направлено */
        sPers_Agent := null;
        sVarchar    := null;
        /* по сотрудникам направлено, и сотрудникам группы направлено */
        for c in (
                  select t.send_person as person
                    from clnevnhist t
                   where t.prn         = rRow.rn
                     and t.change_date > rClnevnHistPrev.change_date
                     and t.send_person is not null
                  union                 
                  select cp.rn  as person
                    from clnevnhist t
                        ,usergrp    ug
                        ,usergrpsp  ugs
                        ,clnpersons cp
                   where t.prn              = rRow.rn
                     and t.change_date      > rClnevnHistPrev.change_date
                     and t.send_user_group  is not null
                     and ug.rn              = t.send_user_group 
                     and ugs.prn            = ug.rn
                     and cp.pers_authid     = ugs.authid
                 )
        loop
          find_clnpersons_agent(nflag_smart  => nFLAGSMART
                               ,ncompany     => rRow.company
                               ,sperson_code => get_clnpersons_code_id(nflag_smart => nFLAGSMART, nrn => c.person)
                               ,nrn          => nNumber
                               ,sagnabbr     => sVarchar);
          sPers_Agent := strcombine(sPers_Agent, sVarchar, ', ');
        end loop;                
        STEXT := strcombine(STEXT, sPers_Agent, cr||'Направлено: ');

      /* 7 - после добавления примечания к событию в точке маршрута */
      when 7 then
        /* Находим последнее примечание к событию */
        sVarchar := null;
        select max(t.rn)
          into nClnEvNotes
          from clnevnotes t
         where t.prn = rRow.rn;
        if nClnEvNotes is not null then
          p_clnevnotes_get_attrib(nrn => nClnEvNotes, note => sVarchar);
        end if;
        STEXT := strcombine(STEXT, sVarchar, cr||'Примечание: ');

        /* если текущая история "Установка отметки об исполнении" */
        sVarchar := null;
        if rClnevnHist.action_code = 'CLNEVENTS_PERF_MARK_SET' then
          sVarchar := get_clnevnpfmrk_code_id(nflag_smart => nFLAGSMART, nrn => rClnevnHist.perf_mark);
        end if;
        STEXT := strcombine(STEXT, sVarchar, cr||'Отметка об исполнении: ');
    else 
      null;
    end case;

    /* Добавляем перенос строки */
    STEXT := STEXT ||cr;

    /* Инициатор */
    sPers_Agent := null;
    find_clnpersons_agent(nflag_smart  => nFLAGSMART
                         ,ncompany     => rRow.company
                         ,sperson_code => get_clnpersons_code_id(nflag_smart => nFLAGSMART, nrn => rRow.init_person)
                         ,nrn          => nNumber
                         ,sagnabbr     => sPers_Agent);
    STEXT := strcombine(STEXT, sPers_Agent, cr||'Инициатор: ');

  end EVRTPTNOT_CREATE_WARNMSG_TEXT;
  --#########################################################################################################

  procedure EVRTPTNTADDR_SET
  /*
  Маршруты событий (адресаты уведомлений в точках). Назначение получателей уведомления
  */
  (
   nFLAGSMART   in number default 0
  ,nEVENT       in number
  ,sPARAM_LIST  in varchar2 /* список через ";" */
  ) 
  is
    rRow              clnevents%rowtype;
    aEvrTptExec       usr_pkg_pub_const.tEvrTptExec;
  begin
    /* Считывание */
    rRow := usr_pkg_clnevents.clnevents_get(nrn => nEVENT);

    /* Поиск получателей по параметрам */
    evrtptexec_get_list(nflagsmart  => nFLAGSMART
                       ,rrow        => rRow
                       ,sparam_list => sPARAM_LIST
                       ,aevrtptexec => aEvrTptExec);

    /* Назначение */
    if aEvrTptExec.count != 0 then
      for i in aEvrTptExec.first .. aEvrTptExec.last 
      loop
        if aEvrTptExec(i).client is not null and aEvrTptExec(i).post is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, nclient => aEvrTptExec(i).client, npost => aEvrTptExec(i).post);
        elsif aEvrTptExec(i).client is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, nclient => aEvrTptExec(i).client);
        elsif aEvrTptExec(i).division is not null and aEvrTptExec(i).post is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, ndivision => aEvrTptExec(i).division, npost => aEvrTptExec(i).post);
        elsif aEvrTptExec(i).division is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, ndivision => aEvrTptExec(i).division);
        elsif aEvrTptExec(i).post is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, npost => aEvrTptExec(i).post);
        elsif aEvrTptExec(i).post_in_div is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, npost_in_div => aEvrTptExec(i).post_in_div);
        elsif aEvrTptExec(i).person is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, nperson => aEvrTptExec(i).person);
        elsif aEvrTptExec(i).staffgrp is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, nstaffgrp => aEvrTptExec(i).staffgrp);
        elsif aEvrTptExec(i).user_group is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, nuser_group  => aEvrTptExec(i).user_group);
        elsif aEvrTptExec(i).user_authid is not null then
          p_evrtptntaddr_predef_assign(ncompany => rRow.company, suser_authid => aEvrTptExec(i).user_authid);
        end if;
      end loop;
    end if;

  end EVRTPTNTADDR_SET;
  --#########################################################################################################

end USR_PKG_EVROUTES;
/
