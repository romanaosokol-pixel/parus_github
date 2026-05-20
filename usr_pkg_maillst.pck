create or replace package USR_PKG_MAILLST is
  /*
  Степанов М. 29/11/2024
  Package предназначен для работы с разделом "Очередь рассылок". 
  MailingList                   MAILLST       ML    Очередь рассылок
  MailingListContent            MAILLSTCNT    MLC   Очередь рассылок (содержание)
  MailingListContentAddresses   MAILLSTCNTADR MLCA  Очередь рассылок (адреса)
  */
  /*#########################################################################################################*/

  function MAILLST_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return MAILLST%rowtype;
  /*#########################################################################################################*/

  procedure MAILLST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLST_BSEND
  /*
  Заголовок. Проверка перед "Отправка рассылки"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLST_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLST_EXS_EXT_SEND
  /*
  Заголовок. Отправка пакетом PKG_EXS_EXT_MAIL с регистрацией в очереди рассылок
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,nFORMAT          in number default pkg_exs_ext_mail.nformat_text /* 0 - текст, 1 - html */
  );
  /*#########################################################################################################*/

  procedure MAILLST_INSERT_EXS_EXT_SEND
  /*
  Заголовок. Добавление и отправка
     Чтобы отправить присоединённые документы, перед вызовом текущей процедуры, используем USR_PKG_DOCUMENT.INSERT_FL_TO_SELECTLIST,
     передаём в текущую процедуру идентификатор записей SELECTLIST, в результате присоединённые документы из SELECTLIST привязываются к Содержанию (MAILLSTCNT).
     Дальше добавляем присоединённые документы Содержания в FILE_BUFFER с таким же идентификатором, и передаём идентификатор в процедуру 
     непосредсвенной отправки MAILLST_EXS_EXT_SEND.
     Не забыть выполнить очистку SELECTLIST после отправки (P_SELECTLIST_CLEAR)  
  */
  (
   nCOMPANY         in number
  ,nDOCUMENT        in number   default null
  ,sUNITCODE        in varchar2 default null
  ,sDESCRIPTION     in varchar2               
  ,sFROM_ADDRESS    in varchar2 default null
  ,nDEL_AFTER_SEND  in number   default 0              
  ,sTO_LIST         in varchar2               /* Список e-mail'ов получателей (разделитель - параметр "SeqSymb") */
  ,sTITLE           in varchar2 := null       /* Тема */
  ,cTEXT            in clob     := null       /* Содержание */
  ,nFILELINKS_IDENT in number   default null  /* Идентификатор SELECTLIST, в котором хранятся RN присоединённых документов */ 
  ,nFORMAT          in number   default pkg_exs_ext_mail.nformat_text /* 0 - текст, 1 - html */
  ,nRN              out number
  );
  /*#########################################################################################################*/

  function MAILLSTCNT_GET
  /*
  Содержание. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return maillstcnt%rowtype;
  /*#########################################################################################################*/

  function MAILLSTCNT_GET_STATUS_NAME
  /*
  Содержание. Наименование статуса 
  */
  (
   nREC_STATUS    in number
  ) 
  return varchar2;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_AINSERT
  /*
  Очередь рассылок (содержание). Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BUPDATE
  /*
  Очередь рассылок (содержание). Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_AUPDATE
  /*
  Очередь рассылок (содержание). Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BSETSTATUS
  /*
  Очередь рассылок (содержание). Проверка перед "Отправка рассылки"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_ASETSTATUS
  /*
  Очередь рассылок (содержание). Проверка после "Отправка рассылки"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BDELETE
  /*
  Очередь рассылок (содержание). Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_CHECK_BASE
  /*
  Очередь рассылок (содержание). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_SETSTATUS
  /*
  Содержание. Установка статуса отправки
  */
  (
   nRN          in number 
  ,nREC_STATUS  in number 
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW       in maillstcnt%rowtype
  ,nRN        out number
  ,nMODE      in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW       in maillstcnt%rowtype
  ,nMODE      in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

end USR_PKG_MAILLST;
/
create or replace package body USR_PKG_MAILLST is

  /*#########################################################################################################*/

  function MAILLST_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return maillst%rowtype
  is
    rRow maillst%rowtype;
  begin
    begin
      select * into rRow from maillst where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'MAILLST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'MAILLST'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end MAILLST_GET;
  /*#########################################################################################################*/

  procedure MAILLST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            maillst%rowtype;
  begin
    /* Считывание */
    /*rRow := maillst_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    maillst_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end MAILLST_AINSERT;
  /*#########################################################################################################*/

  procedure MAILLST_BUPDATE
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
  end MAILLST_BUPDATE;
  /*#########################################################################################################*/

  procedure MAILLST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание*/
    /*rRow := maillst_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    maillst_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end MAILLST_AUPDATE;
  /*#########################################################################################################*/

  procedure MAILLST_BSEND
  /*
  Заголовок. Проверка перед "Отправка рассылки"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end MAILLST_BSEND;
  /*#########################################################################################################*/

  procedure MAILLST_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end MAILLST_BDELETE;
  /*#########################################################################################################*/

  procedure MAILLST_CHECK_BASE
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
    /* Заголовок */  
    /*rRow := maillst_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    
  end MAILLST_CHECK_BASE;
  /*#########################################################################################################*/

  procedure MAILLST_EXS_EXT_SEND
  /*
  Заголовок. Отправка пакетом PKG_EXS_EXT_MAIL с регистрацией в очереди рассылок
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,nFORMAT          in number default pkg_exs_ext_mail.nformat_text /* 0 - текст, 1 - html */
  ) 
  is
    rRow            maillst%rowtype;
    rMailLstCnt     maillstcnt%rowtype;
    sTo_Addresses   pkg_std.tstring; 
    sTo_FIO         pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := maillst_get(nrn => nRN); 

    /* По содержаниям */
    for c in (select * from maillstcnt where prn = rRow.rn)
    loop
      /* Сохранение в переменную */
      rMailLstCnt := c;

      /* Добавление присоединённых документов Содержания в FILE_BUFFER (эта таблица очищается потом в USR_P_JOBS_DAILY). */
      usr_pkg_document.insert_fl_to_file_buffer( nrn => c.rn, nident => c.rn );

      /* Считывание адресов содержания */
      begin
        select listagg(trim(address), ';') within group (order by null)
              ,listagg(trim(fio), cr) within group (order by null)
          into sTo_Addresses
              ,sTo_FIO
          from maillstcntadr
         where prn = rMailLstCnt.rn;
      exception
        when no_data_found then
          sTo_Addresses := null;
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске адресов очереди рассылок с RN <%s> в разделе <%s>.'
                     ,rRow.rn ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'MAILLSTCNT')));
      end;

      /* Если список адресов НЕ ПУСТОЙ */
      if sTo_Addresses is not null then

        /* Если содержание-blob пустое, копируем в него содержание */
        if rMailLstCnt.content_html is null then 
          rMailLstCnt.content_html := clob2blob( lcdata => rMailLstCnt.content );
        end if;

        /* Добавление в текст письма списка получателей */
        rMailLstCnt.content_html := clob2blob( lcdata => blob2clob( lbdata => rMailLstCnt.content_html ) ||cr||cr|| 'Сообщение отправлено: ' ||cr|| sTo_FIO );

        /* Исправление содержания */
        maillstcnt_base_update(rrow => rMailLstCnt, nmode => 0);
         /* Отправка */
        pkg_exs_ext_mail.send_by_list(sto_list            => sTo_Addresses
                                     ,stitle              => rMailLstCnt.title
                                     ,ctext               => blob2clob( rMailLstCnt.content_html )
                                     ,nfile_buffer_ident  => c.rn
                                     ,nformat             => nFORMAT );
        /* Исправление состояния содержания на "Отправлено" */
        maillstcnt_setstatus(nrn => rMailLstCnt.rn, nrec_status => 1, nmode => 1);

      /* Список адресов ПУСТОЙ */
      else
        /* исправление состояния содержания на "Ошибка" */
        maillstcnt_setstatus(nrn => rMailLstCnt.rn, nrec_status => 1, nmode => 1);

        /* Отправка администраторам */
        pkg_exs_ext_mail.send_by_list(sto_list            => 'm.stepanov@module.ru'
                                     ,stitle              => 'Ошибка отправки. '||rMailLstCnt.title
                                     ,ctext               => blob2clob( rMailLstCnt.content_html )
                                     ,nfile_buffer_ident  => c.rn
                                     ,nformat             => nFORMAT );
      end if;
    end loop;

  end MAILLST_EXS_EXT_SEND;
  /*#########################################################################################################*/

  procedure MAILLST_INSERT_EXS_EXT_SEND
  /*
  Заголовок. Добавление и отправка
     Чтобы отправить присоединённые документы, перед вызовом текущей процедуры, используем USR_PKG_DOCUMENT.INSERT_FL_TO_SELECTLIST,
     передаём в текущую процедуру идентификатор записей SELECTLIST, в результате присоединённые документы из SELECTLIST привязываются к Содержанию (MAILLSTCNT).
     Дальше добавляем присоединённые документы Содержания в FILE_BUFFER с таким же идентификатором, и передаём идентификатор в процедуру 
     непосредсвенной отправки MAILLST_EXS_EXT_SEND.
     Не забыть выполнить очистку SELECTLIST после отправки (P_SELECTLIST_CLEAR)  
  */
  (
   nCOMPANY         in number
  ,nDOCUMENT        in number   default null
  ,sUNITCODE        in varchar2 default null              
  ,sDESCRIPTION     in varchar2               
  ,sFROM_ADDRESS    in varchar2 default null
  ,nDEL_AFTER_SEND  in number   default 0              
  ,sTO_LIST         in varchar2               /* Список e-mail'ов получателей (разделитель - параметр "SeqSymb") */
  ,sTITLE           in varchar2 := null       /* Тема */
  ,cTEXT            in clob     := null       /* Содержание */
  ,nFILELINKS_IDENT in number   default null  /* Идентификатор SELECTLIST, в котором хранятся RN присоединённых документов */ 
  ,nFORMAT          in number   default pkg_exs_ext_mail.nformat_text /* 0 - текст, 1 - html */
  ,nRN              out number
  ) 
  is
    nMaiLlst        pkg_std.tref; 
    nMailLstCnt     pkg_std.tref; 
    nMailLstCntAdr  pkg_std.tref; 
    
    sVarchar      pkg_std.tlstring; 
    nNumber       pkg_std.tnumber;  
  begin
    /* Добавление заголовка */
    p_maillst_base_insert(ncrn            => 6020232
                         ,sdescription    => sDESCRIPTION
                         ,sfrom_address   => sFROM_ADDRESS
                         ,ndel_after_send => nDEL_AFTER_SEND
                         ,nrn             => nMaiLlst);
    /* Если задан документ, устанавливаем связь */
    if nDOCUMENT is not null then
      pkg_doclinks.link( nflag_smart       => 0
                        ,ncompany          => nCOMPANY
                        ,sin_unitcode      => sUNITCODE
                        ,nin_document      => nDOCUMENT
                        ,sout_unitcode     => 'MailingList'
                        ,nout_document     => nMaiLlst );
    end if;                         
    /* Добавление содержания */
    p_maillstcnt_base_insert(nprn          => nMaiLlst
                            ,stitle        => STITLE
                            ,scontent      => sys.dbms_lob.substr(lob_loc => cTEXT, amount => 4000, offset => 1)
                            ,bcontent_html => clob2blob(lcdata => cTEXT)
                            ,nrn           => nMailLstCnt);

    /* По SELECTLIST, который содержит RN присоединённых документов */
    for c in ( select document from selectlist where ident = nFILELINKS_IDENT )
    loop
      /* Добавление связи присоединённого документа с содержанием */
      p_filelinksunits_base_insert(nfilelinks_prn => c.document
                                  ,ntable_prn     => nMailLstCnt
                                  ,sunitcode      => 'MailingListContent'
                                  ,nrn            => nNumber);
    end loop;
    /* Очистка SELECTLIST */
    p_selectlist_clear( nident => nFILELINKS_IDENT );

    /* Добавление адресов */
    for c in (
              select translate(regexp_substr(t.val, '[^;]+', 1, level), '*?', '%_') as sVal
                from (select sTO_LIST as val from dual) t
              connect by regexp_substr(t.val, '[^;]+', 1, level) is not null
             )
    loop
      p_maillstcntadr_base_insert(nprn     => nMailLstCnt
                                 ,saddress => c.sval
                                 ,sfio     => c.sval
                                 ,snote    => null
                                 ,nrn      => nMailLstCntAdr);
    end loop;

    /* Отправка */
    maillst_exs_ext_send( nrn => nMaiLlst, ncompany => nCOMPANY, nformat => nFORMAT );

    /* Выходной RN */
    nRN := nMaiLlst;
    
  end MAILLST_INSERT_EXS_EXT_SEND;
  /*#########################################################################################################*/

  function MAILLSTCNT_GET
  /*
  Содержание. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return maillstcnt%rowtype
  is
    rRow maillstcnt%rowtype;
  begin
    begin
      select * into rRow from maillstcnt where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'MAILLSTCNT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'MAILLSTCNT')));
    end;
    return(rRow);
  end MAILLSTCNT_GET;
  /*#########################################################################################################*/

  function MAILLSTCNT_GET_STATUS_NAME
  /*
  Содержание. Наименование статуса 
  */
  (
   nREC_STATUS    in number
  ) 
  return varchar2
  is
    sVarchar  pkg_std.tstring; 
  begin
    sVarchar := case nREC_STATUS
                  when 0 then 'Ожидает отправки'
                  when 1 then 'Отправлено'
                  when 2 then 'Ошибка'
                  when 3 then 'Отправлено частично'
                  else null
                end;
    return(sVarchar);
  end MAILLSTCNT_GET_STATUS_NAME;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_AINSERT
  /*
  Очередь рассылок (содержание). Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            maillstcnt%rowtype;
    
    sTo_Addresses   pkg_std.tstring; 
    sTo_FIO         pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := maillstcnt_get(nrn => nRN); 

    /* ПРОВЕРКИ */
    /* Базовая */
    maillstcnt_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end MAILLSTCNT_AINSERT;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BUPDATE
  /*
  Очередь рассылок (содержание). Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end MAILLSTCNT_BUPDATE;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_AUPDATE
  /*
  Очередь рассылок (содержание). Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание*/
    /*rRow := maillst_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    maillst_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end MAILLSTCNT_AUPDATE;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BSETSTATUS
  /*
  Очередь рассылок (содержание). Проверка перед "Отправка рассылки"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end MAILLSTCNT_BSETSTATUS;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_ASETSTATUS
  /*
  Очередь рассылок (содержание). Проверка после "Отправка рассылки"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end MAILLSTCNT_ASETSTATUS;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BDELETE
  /*
  Очередь рассылок (содержание). Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end MAILLSTCNT_BDELETE;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_CHECK_BASE
  /*
  Очередь рассылок (содержание). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end MAILLSTCNT_CHECK_BASE;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_SETSTATUS
  /*
  Очередь рассылок (содержание). Установка статуса отправки
  */
  (
   nRN          in number 
  ,nREC_STATUS  in number 
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    nCRN                      PKG_STD.tREF;    -- Каталог
    nPRN                      PKG_STD.tREF;
    nDEL_AFTER_SEND           MAILLST.DEL_AFTER_SEND%type;
    iEXISTS                   integer;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_maillstcnt_setstatus(nrn => nRN, nrec_status => nREC_STATUS);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Считывание записи */
      begin
        select
          C.CRN, C.PRN, L.DEL_AFTER_SEND
        into
          nCRN, nPRN, nDEL_AFTER_SEND
        from
          MAILLSTCNT C,
          MAILLST    L
        where C.RN  = nRN
          and C.PRN = L.RN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND( nRN,'MailingListContent' );
      end;

      /* фиксация начала выполнения действия */
      /*PKG_ENV.PROLOGUE( null,null,nCRN,null,null,'MailingListContent','MAILLSTCNT_SETSTATUS','MAILLSTCNT',nRN );*/

      update MAILLSTCNT
         set REC_STATUS = nREC_STATUS
       where RN = nRN;

      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND( nRN,'MailingListContent' );
      end if;

      /* фиксация окончания выполнения действия */
      /*PKG_ENV.EPILOGUE( null,null,nCRN,null,null,'MailingListContent','MAILLSTCNT_SETSTATUS','MAILLSTCNT',nRN );*/

      if nDEL_AFTER_SEND = 1 then
        select count(*)
          into iEXISTS
          from DUAL
          where exists
                (
                  select null from MAILLSTCNT where PRN = nPRN and REC_STATUS = 0
                );
        if iEXISTS = 0 then
          P_MAILLST_BASE_DELETE( nPRN );
        end if;
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end MAILLSTCNT_SETSTATUS;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BASE_INSERT
  /*
  Очередь рассылок (содержание). Добавление базовое
  */
  (
   rROW       in maillstcnt%rowtype
  ,nRN        out number
  ,nMODE      in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_maillstcnt_base_insert(nprn          => rROW.PRN
                              ,stitle        => rROW.TITLE
                              ,scontent      => rROW.CONTENT
                              ,bcontent_html => rROW.CONTENT_HTML
                              ,nrn           => nRN);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/
      
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
  end MAILLSTCNT_BASE_INSERT;
  /*#########################################################################################################*/

  procedure MAILLSTCNT_BASE_UPDATE
  /*
  Очередь рассылок (содержание). Исправление базовое
  */
  (
   rROW       in maillstcnt%rowtype
  ,nMODE      in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_maillstcnt_base_update(nrn => rROW.RN, stitle => rROW.TITLE, scontent => rROW.CONTENT);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
  end MAILLSTCNT_BASE_UPDATE;
  /*#########################################################################################################*/
  
end USR_PKG_MAILLST;
/
