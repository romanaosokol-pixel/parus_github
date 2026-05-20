create or replace package USR_PKG_AGNLIST is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Контрагенты". 
  AGNLIST               AGNLIST         AL
  ContragentsBankAttrs  AGNACC          AAC
  BankAccountTypes      BANKACCTYPES    BAT
  AgentAddresses        AGNADDRESSES    AGA

  Концепция ведения Адресов: 
  Проверяется в триггерах:
  - значение адреса указывается либо с использованием географических понятий, либо текстом в поле Примечание. Если в примечании, то в географическом понятии 
    должна быть указана запись типа "Страна", иначе примечание должно быть пустым, а в географическом понятии запись НЕ типа "Страна".
  - если адрес заполняется с геопонятиями, то должны быть заполнены какие-то из остальных полей: дом, корпус, квартира и т.д.
  - адрес должен иметь хотя бы один из признаков: юридический, реального проживания, почтовый, регистрации
  - должен иметь дату начала действия. Изменять её запрещено.
  - исправление значения адреса запрещено.
  - удаление записи адреса запрещено.
  Проверяется в неименованных блоках:
  - недопустимо изменять адреса таким образом, чтобы возник ещё один адрес с признаком, и датой, меньшей, чем дата существующего адреса с таким же признаком 
  - недопустимо изменять адреса таким образом, чтобы возник ещё один адрес со значением адреса, и датой, меньшей, чем дата существующего адреса с таким же значением адреса
  */

  /*#########################################################################################################*/

  function AGNLIST_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnlist%rowtype;
  /*#########################################################################################################*/

  function AGNLIST_GET_ADDRESS
  /*
  Адреса. Получение текстовых значений адреса по параметрам.
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGN        in number             /* 0-legal_sign, 1-real_sign, 2-mail_sign, 3-registration_sign, 4-birth_sign */
  ,dDATE        in date default null  /* Дата определения. Если не задана, то берётся с большей датой */
  )
  return number;
  /*#########################################################################################################*/

  function AGNLIST_GET_STR_DETAILS
  /*
  Заголовок. Получение текстовых значений контрагента, реквизитов и т.д.
  */
  (
   nFLAGSMART   in number default 0
  ,rAGN         in agnlist%rowtype
  ,rAGNACC      in agnacc%rowtype
  ,dDATE        in date
  ,sPARAM_LIST  in varchar2   /* Список параметров (через ";") :
                                 1 - Наименование ИНН/КПП  
                                 2 - Адрес
                                 3 - Банковские реквизиты */
  ,nADDRES_SIGN in number default 0   /* тип адреса */
  )
  return varchar2;
  /*#########################################################################################################*/

  procedure AGNLIST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNLIST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
/*#########################################################################################################*/

  function AGNACC_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return AGNACC %ROWTYPE;
  /*#########################################################################################################*/

  function AGNACC_GET_CODE_ID
  /* 
  Поиск кода банковских реквизитов по регистрационному номеру записи. 
  */
  (
   nFLAG_SMART       in number          /* признак генерации исключения (>0 - нет, 0(null) - да с регистрацией, <0 - да без регистрации) */
  ,nRN               in number          /* регистрационный номер записи */
  )
  return varchar2;
  /*#########################################################################################################*/

  procedure AGNACC_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNACC_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNACC_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNACC_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNACC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  function BANKACCTYPES_GET
  /*
  Типы банковских счетов. Считывание
  */
  (
   nRN      in number 
  ) 
  return bankacctypes%rowtype;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET
  /*
  Адреса. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnaddresses%rowtype;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET_TYPE_NAME
  /*
  Адреса. Нааименование признака адреса
  */
  (
   nSIGN    in number
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET_VAL
  /*
  Адреса. Получение значения адреса по параметрам.
  */
  (
   nFLAGSMART   in number default 0
  ,rROW         in agnaddresses%rowtype
  ,sFORMAT      in varchar2 default 'PRYSHLF'  
  ,sDELIMITER   in varchar2 default ', '  -- разделитель
  )
  return varchar2;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET_VAL
  /*
  Адреса. Получение значения адреса по параметрам.
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ,sFORMAT      in varchar2 default 'PRYSHLF'  
  ,sDELIMITER   in varchar2 default ', '  -- разделитель
  )
  return varchar2;
  /*#########################################################################################################*/

  procedure AGNADDRESSES_AINSERT
  /*
  Адреса. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNADDRESSES_BUPDATE
  /*
  Адреса. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNADDRESSES_AUPDATE
  /*
  Адреса. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNADDRESSES_BDELETE
  /*
  Адреса. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AGNADDRESSES_CHECK_BASE
  /*
  Адреса. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW       in v_agnaddresses%rowtype
  ,NCOMPANY     in number
  ,nRN          out number
  );
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_agnaddresses%rowtype
  ,NCOMPANY     in number
  );
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW         in agnaddresses%rowtype
  ,NCOMPANY     in number
  ,nRN          out number
  );
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW         in agnaddresses%rowtype
  ,NCOMPANY     in number
  );
  /*#########################################################################################################*/

end USR_PKG_AGNLIST;
/
create or replace package body USR_PKG_AGNLIST is

  /*#########################################################################################################*/

  function AGNLIST_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnlist%rowtype
  is
    rRow agnlist%rowtype;
  begin
    begin
      select * into rRow from agnlist where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'AGNLIST');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'AGNLIST'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end AGNLIST_GET;
  /*#########################################################################################################*/

  function AGNLIST_GET_ADDRESS
  /*
  Заголовок. Получение RN адреса контрагента по параметрам.
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGN        in number             /* Признак: 0 - legal_sign, 1 - real_sign, 2 - mail_sign, 3 - registration_sign, 4 - birth_sign */
  ,dDATE        in date default null  /* Дата определения. Если не задана, то берётся с большей датой */
  )
  return number
  as
    nRef        pkg_std.tref; 
  begin
    /* Поиск */
    begin
      select rn
        into nRef
        from ( select rn
                 from agnaddresses
                where prn = nRN
                  and (   ( nSIGN = 0 and legal_sign = 1 )
                       or ( nSIGN = 1 and real_sign  = 1 )
                       or ( nSIGN = 2 and mail_sign  = 1 )
                       or ( nSIGN = 3 and registration_sign = 1 )
                       or ( nSIGN = 4 and birth_sign = 1 ) )
                  and cmp_dat_minmax( registration_date, dDATE ) <= 0
               order by registration_date desc, rn ) a
       where rownum = 1;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найден адрес с признаком <%s> для контрагента <%s> на дату <%s>. '
                   ,agnaddresses_get_type_name( nsign => nSIGN )
                   ,get_agnlist_agnabbr_id( nflag_smart => 1, nrn => nRN )
                   ,decode_date( dDATE ) );
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного адреса с признаком <%s> для контрагента <%s> на дату <%s>. '
                   ,agnaddresses_get_type_name( nsign => nSIGN )
                   ,get_agnlist_agnabbr_id( nflag_smart => 1, nrn => nRN )
                   ,decode_date( dDATE ) );
      when others then
        p_exception( 0, 'Неопределённая ситуация при поиске адреса с признаком <%s> для контрагента <%s> на дату <%s>. '
                   ,agnaddresses_get_type_name( nsign => nSIGN )
                   ,get_agnlist_agnabbr_id( nflag_smart => 1, nrn => nRN )
                   ,decode_date( dDATE ) );
    end;
    
    /* Результат */
    return nRef;
    
  end AGNLIST_GET_ADDRESS;
  /*#########################################################################################################*/

  function AGNLIST_GET_STR_DETAILS
  /*
  Заголовок. Получение текстовых значений контрагента, реквизитов и т.д.
  */
  (
   nFLAGSMART   in number default 0
  ,rAGN         in agnlist%rowtype
  ,rAGNACC      in agnacc%rowtype
  ,dDATE        in date
  ,sPARAM_LIST  in varchar2   /* Список параметров (через ";") :
                                 1 - Наименование ИНН/КПП  
                                 2 - Адрес 
                                 3 - Банковские реквизиты */
  ,nADDRES_SIGN in number default 0   /* тип адреса */
  )
  return varchar2
  as
    sOut            pkg_std.tstring; 
    rAgnBanks       agnbanks%rowtype;
    rBankAgnList    agnlist%rowtype;
    nAgnAddresses   pkg_std.tref; 
    
    sVarchar        pkg_std.tstring; 
  begin
    /* 1 - Наименование ИНН/КПП */
    if strin(1, sPARAM_LIST) = 1 then 
      /* Контрагент задан в параметре */
      if rAGN.RN is not null then
        sOut := rAGN.AGNNAME;
        sOut := strcombine(sOut, rAGN.AGNIDNUMB || '/' || rAGN.REASON_CODE, ', ИНН/КПП ' );
      /* не задан */
      else
        if nvl(nFLAGSMART, 0) = 0 then
          p_exception(0, 'Не задан контрагент.'); 
        end if;    
      end if;    
    end if;

    /* 2 - Адрес юридический */
    if strin(2, sPARAM_LIST) = 1 then 
      /* Определение RN юридического адреса */
      nAgnAddresses := agnlist_get_address(nflagsmart => nFLAGSMART, nrn => rAGN.RN, nsign => nADDRES_SIGN, ddate => dDATE);
      /* RN адреса найден */
      if nAgnAddresses is not null then
        /* Формирование текста адреса */
        sVarchar := agnaddresses_get_val( nflagsmart => nFLAGSMART, nrn => nAgnAddresses );
        sOut := strcombine( sOut, sVarchar, ', ' );
      /* не задан */
      else
        if nvl(nFLAGSMART, 0) = 0 then
          p_exception(0, 'Не найден <%s> адрес контрагента'
                     ,agnaddresses_get_type_name( nsign => nADDRES_SIGN) ); 
        end if;    
      end if;
    end if;
    
    /* 3 - Банковские реквизиты */
    if strin(3, sPARAM_LIST) = 1 then 
      /* БанковскиЙ реквизит задан в параметре */
      if rAGNACC.RN is not null then
        /* В банковском реквизите заполнен банк */
        if rAGNACC.AGNBANKS is not null then
          rAgnBanks     := usr_pkg_agnbanks.agnbanks_get(nrn => rAGNACC.AGNBANKS);
          rBankAgnList  := agnlist_get(nrn => rAgnBanks.agnrn);
        /* не заполнен банк */
        else
          rBankAgnList.agnname    := rAGNACC.BANKNAMEACC;
          rAgnBanks.bankacc       := rAGNACC.BANKACC;
          rAgnBanks.bankfcodeacc  := rAGNACC.BANKFCODEACC;
        end if;
        /* Формирование текста банковских реквизитов */
        sOut := strcombine(sOut, rAGNACC.AGNACC, ', р/с ');
        sOut := strcombine(sOut, rBankAgnList.agnname, ', в ');
        sOut := strcombine(sOut, rAGNBanks.bankacc, ', к/с ');
        sOut := strcombine(sOut, rAGNBanks.bankfcodeacc, ', БИК ');
      else
        if nvl(nFLAGSMART, 0) = 0 then
          p_exception(0, 'Не найден банковский реквизит контрагента'); 
        end if;    
      end if;
    end if; 
    
    /* Результат */
    return sOut;
    
  end AGNLIST_GET_STR_DETAILS;
  /*#########################################################################################################*/

  procedure AGNLIST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            agnlist%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := AGNLIST_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    agnlist_check_base(nrn => nRN, ncompany => nCOMPANY);

  end AGNLIST_AINSERT;
  /*#########################################################################################################*/

  procedure AGNLIST_BUPDATE
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
  end AGNLIST_BUPDATE;
  /*#########################################################################################################*/

  procedure AGNLIST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     agnlist%rowtype;
    
  begin
    /* Считывание
     rRow := agnlist_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    agnlist_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNLIST_AUPDATE;
  /*#########################################################################################################*/

  procedure AGNLIST_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        agnlist%rowtype;
    sCatalog    acatalog.name%type;
    nNumber     pkg_std.tnumber;  
  begin
    null;
  end AGNLIST_BMOVE_IN;
  /*#########################################################################################################*/

  procedure AGNLIST_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    agnlist_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNLIST_AMOVE_IN;
  /*#########################################################################################################*/

  procedure AGNLIST_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end AGNLIST_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure AGNLIST_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end AGNLIST_AMOVE_OUT;
  /*#########################################################################################################*/

  procedure AGNLIST_BDELETE
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
  end AGNLIST_BDELETE;
  /*#########################################################################################################*/

  procedure AGNLIST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      agnlist%rowtype;
  begin
    null;
    /* Заголовок */  
    rRow := agnlist_get(nrn => nRN); 

    /* Наименование */    
    for c in (
              select t.crn
                from agnlist t
               where upper(t.agnname) = upper(rRow.agnname)
                 and t.rn != rRow.rn
                 and not exists (select null from userroles where authid = utilizer and roleid = 90519) /* нет роли Все права */
              ) 
    loop    
      p_exception(0, 'Существует контрагент с таким же значением поля "Наименование" в каталоге <%s>. %s, %s'
                 ,get_acatalog_name_id(nflag_smart => 1, nrn => c.crn)
                 ,cr||rRow.agnabbr, rRow.agnname); 
    end loop;

    /* Если каталог контрагента внутри каталога "Юридические лица" или "Банки" */    
    if (usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => 510118) or
        usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => 535603)) --and utilizer != 'KHOK'
       then
      /* ИНН */    
      if rRow.agnidnumb is null and rRow.resident_sign = 0 then
        p_exception(0, 'Не заполнен ИНН, при этом, не указан признак "Нерезидент", и находится в каталоге <%s>. %s, %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,cr||rRow.agnabbr, rRow.agnname); 
      end if;
      /* КПП */    
      if rRow.reason_code is null and rRow.resident_sign = 0 and rRow.ind_businessman = 0 then
        p_exception(0, 'Не заполнен КПП, при этом, не указан признак "Нерезидент", не указан признак "Индивидуальный предприниматель", и находится в каталоге <%s>. %s%s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,cr||rRow.agnabbr, cr||rRow.agnname); 
      end if;
    /* Если каталог контрагента внутри каталога "Сотрудники" */
    elsif usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => 116126) then
      /* Юр.лицо */
      if rRow.agntype = 0 then
        p_exception(0, 'Контрагент - юридическое лицо не должен находится в каталоге <%s>. %s, %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,cr||rRow.agnabbr, rRow.agnname); 
      end if;
    end if;

      /* НЕ Резидент */    
    if rRow.resident_sign = 1 and rRow.crn != 7558296 /* ВЭД */ then
      p_exception(0, 'Контрагент - нерезидент должен находиться в каталоге <%s>. %s, %s'
                 ,get_acatalog_name_id(nflag_smart => 1, nrn => 7558296)
                 ,cr||rRow.agnabbr, rRow.agnname); 
    end if;
    
    if rRow.resident_sign = 0 and REGEXP_LIKE(rRow.agnidnumb, '\D') then
    p_exception(0, 'ИНН Контрагента - резидента не может содержать НЕ цифровые символы.'||
    ' Если вы не видите не цифровыe символы, введите значение ИНН вручную.');     
    end if;
    
    if rRow.resident_sign = 0 and REGEXP_LIKE(rRow.reason_code, '\D') then
    p_exception(0, 'КПП Контрагента - резидента не может содержать НЕ цифровые символы.'||
    ' Если вы не видите не цифровыe символы, введите значение КПП вручную.');     
    end if;
    
    
 
  end AGNLIST_CHECK_BASE;
  /*#########################################################################################################*/

  function AGNACC_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnacc%rowtype
  is
    rRow agnacc%rowtype;
  begin
    begin
      select * into rRow from agnacc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'AGNACC');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'AGNACC'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end AGNACC_GET;
  /*#########################################################################################################*/

  function AGNACC_GET_CODE_ID
  /* 
  Поиск кода банковских реквизитов по регистрационному номеру записи. 
  */
  (
   nFLAG_SMART       in number          /* признак генерации исключения (>0 - нет, 0(null) - да с регистрацией, <0 - да без регистрации) */
  ,nRN               in number          /* регистрационный номер записи */
  )
  return varchar2
  as
    sRes             pkg_std.tstring; 
  begin
    /* считывание записи */
    begin
      select strcode
        into sRes
        from agnacc
       where rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nflag_smart, ndocument => nrn, sunit_table => 'AGNACC' );
    end;

    /* возврат результата */
    return sRes;
    
  end AGNACC_GET_CODE_ID;
  /*#########################################################################################################*/

  procedure AGNACC_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    agnacc_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNACC_AINSERT;
  /*#########################################################################################################*/

  procedure AGNACC_BUPDATE
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
  end AGNACC_BUPDATE;
  /*#########################################################################################################*/

  procedure AGNACC_AUPDATE
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
    agnacc_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNACC_AUPDATE;
  /*#########################################################################################################*/

  procedure AGNACC_BDELETE
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
  end AGNACC_BDELETE;
  /*#########################################################################################################*/

  procedure AGNACC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            agnacc%rowtype;
    rBankAccTypes   bankacctypes%rowtype;
  begin
    /* Считывание */
    rRow := agnacc_get(nrn => nRN); 
    if rRow.bankacc_type is not null then
      rBankAccTypes := bankacctypes_get(nrn => rRow.bankacc_type);
    end if;

    /* ПРОВЕРКИ */
    /* Наличие реквизитов с таким же номером расчётного счёта */
    for c in (
              select t.agnacc, t.strcode, h.agnabbr
                from agnacc t, agnlist h
               where t.agnrn = h.rn
                 and t.rn   != rRow.rn
                 and t.agnacc is not null
                 and rRow.agnacc is not null
                 and cmp_vc2(regexp_replace(t.agnacc, '[^0-9]+', ''), regexp_replace(rRow.agnacc, '[^0-9]+', '')) = 1
                 --and utilizer != 'KHOK'
             )    
    loop
      p_exception(0, 'Номер расчётного счёта <%s> уже используется в реквизитах <%s> контрагента <%s>.%s'
                 ,rRow.agnacc
                 ,c.strcode
                 ,c.agnabbr
                 ,cr||f_docdescrs_get_description(sunitcode => 'ContragentsBankAttrs', ndocument => rRow.rn)); 
    end loop;    
    
    /* Тип рассчётного счёта НЕ УФК */
    if rBankAccTypes.rn not in (6525523) then
      /* Длина */
      if REGEXP_LIKE (rRow.agnacc, '^[0-9]+$') and length(rRow.agnacc) != 20 then
        p_exception(0, 'Номер расчётного счёта <%s> должен состоять из 20 цифр.%s'
                   ,rRow.agnacc
                   ,cr||f_docdescrs_get_description(sunitcode => 'ContragentsBankAttrs', ndocument => rRow.rn) ); 
      end if;
      /* Первые числа */
      if REGEXP_LIKE (rRow.agnacc, '^[0-9]+$') and rRow.agnacc not like '40%' then
        p_exception(0, 'Номер расчётного счёта <%s> должен начинаться с 40.%s'
                   ,rRow.agnacc
                   ,cr||f_docdescrs_get_description(sunitcode => 'ContragentsBankAttrs', ndocument => rRow.rn) ); 
      end if;
    end if;

  end AGNACC_CHECK_BASE;
  /*#########################################################################################################*/

  function BANKACCTYPES_GET
  /*
  Типы банковских счетов. Считывание
  */
  (
   nRN      in number 
  ) 
  return bankacctypes%rowtype
  is
    rRow bankacctypes%rowtype;
  begin
    begin
      select T.*
        into rRow
        from bankacctypes t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'BANKACCTYPES'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BANKACCTYPES')));
    end;
    return(rRow);
  end BANKACCTYPES_GET;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET
  /*
  Адреса. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnaddresses%rowtype
  is
    rRow agnaddresses%rowtype;
  begin
    begin
      select * into rRow from agnaddresses where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'AGNADDRESSES');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'AGNADDRESSES'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end AGNADDRESSES_GET;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET_TYPE_NAME
  /*
  Адреса. Нааименование признака адреса
  */
  (
   nSIGN    in number
  ) 
  return varchar2
  is
    sVarchar  pkg_std.tstring; 
  begin
    /* Определение */
    case nSIGN 
      when 0 then
        sVarchar := 'Юридический';
      when 1 then
        sVarchar := 'Реального проживания';
      when 2 then
        sVarchar := 'Почтовый';
      when 3 then
        sVarchar := 'Регистрации';
      when 4 then
        sVarchar := 'Рождения';
    else
      null;        
    end case;

    /* Результат */
    return(sVarchar);

  end AGNADDRESSES_GET_TYPE_NAME;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET_VAL
  /*
  Адреса. Получение значения адреса по параметрам.
  */
  (
   nFLAGSMART   in number default 0
  ,rROW         in agnaddresses%rowtype
  ,sFORMAT      in varchar2 default 'PRYSHLF'  
  ,sDELIMITER   in varchar2 default ', '  -- разделитель
  )
  return varchar2
  as
    rGeografy       geografy%rowtype;
    sOut            pkg_std.tstring; 
  begin
    /* Считывание географического понятия */
    rGeografy := udo_pkg_get.row_geografy(nrn => rROW.GEOGRAFY_RN);
    
    /* Если геопонятие Страна */
    if rGeografy.geogrtype = 1 then
      /* берём текст из примечания */
      sOut := rROW.NOTE;
    else
      /* Иначе вычитываем в заданном формате */
      pkg_agnaddresses.make_address_smart(nsmart_flag => nFLAGSMART
                                         ,nrn         => rROW.RN
                                         ,sformat     => sFORMAT
                                         ,saddress    => sOut
                                         ,sdelimiter  => sDELIMITER);
    end if;

    /* Результат */
    return sOut;
    
  end AGNADDRESSES_GET_VAL;
  /*#########################################################################################################*/

  function AGNADDRESSES_GET_VAL
  /*
  Адреса. Получение значения адреса по параметрам.
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ,sFORMAT      in varchar2 default 'PRYSHLF'  
  ,sDELIMITER   in varchar2 default ', '  -- разделитель
  )
  return varchar2
  as
    rRow    agnaddresses%rowtype;
    sOut    pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := agnaddresses_get(nrn => nRN, nflagsmart => nFLAGSMART); 

    /* Если заполнено примечание */
    sOut := agnaddresses_get_val(nflagsmart => nFLAGSMART, rrow => rRow, sformat => sFORMAT, sdelimiter => sDELIMITER);

    /* Результат */
    return sOut;
    
  end AGNADDRESSES_GET_VAL;
  /*#########################################################################################################*/

  procedure AGNADDRESSES_AINSERT
  /*
  Адреса. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    agnaddresses_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNADDRESSES_AINSERT;
  /*#########################################################################################################*/

  procedure AGNADDRESSES_BUPDATE
  /*
  Адреса. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Заголовок */
    /*usr_pkg_pub_const.ragnaddresses := agnaddresses_get(nrn => nRN);*/
    
  end AGNADDRESSES_BUPDATE;
  /*#########################################################################################################*/

  procedure AGNADDRESSES_AUPDATE
  /*
  Адреса. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     agnaddresses%rowtype;
  begin
    /* Считывание */
    /* rRow := agnaddresses_get(nrn => nRN); */

    /* ПРОВЕРКИ */

    /* Базовая */
    agnaddresses_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNADDRESSES_AUPDATE;
  /*#########################################################################################################*/

  procedure AGNADDRESSES_BDELETE
  /*
  Адреса. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end AGNADDRESSES_BDELETE;
  /*#########################################################################################################*/

  procedure AGNADDRESSES_CHECK_BASE
  /*
  Адреса. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      agnaddresses%rowtype;
    
    /* Процедура проверки по признаку */
    procedure SIGN_CHECK( nSIGN in number)
    as 
      nAddress  pkg_std.tref; 
      rAddress  agnaddresses%rowtype;
    begin
      /* поиск адреса с таким же признаком на дату больше даты текущго адреса */
      nAddress := agnlist_get_address(nflagsmart => 1, nrn => rRow.prn, nsign => nSIGN, ddate => to_date('31.12.2099', 'dd.mm.yyyy'));
      /* если такой адреса найден и он не равняется текущему */
      if  nAddress is not null and nAddress != rRow.rn then
        rAddress := agnaddresses_get(nrn => nAddress); 
        p_exception(0, 'Уже существует адрес такими признаками и датой регистрации больше или равной дате текущего адреса.%s%s%s%s'
                   ,cr||agnaddresses_get_type_name(nsign => nSIGN)
                   ,cr||decode_date(rAddress.registration_date) 
                   ,cr||agnaddresses_get_val(nflagsmart => 1, rrow => rAddress)
                   ,cr||get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rAddress.prn) ); 
      end if;

      /* поиск адреса на дату меньше даты текущго адреса */
      nAddress := agnlist_get_address(nflagsmart => 1, nrn => rRow.prn, nsign => nSIGN, ddate => rRow.registration_date - 1);
      /* если такой адреса найден */
      if nAddress is not null then
        rAddress := agnaddresses_get(nrn => nAddress); 
        /* значение найденного адреса равно значению текущего */
        if cmp_vc2( usr_f_norm(sval => agnaddresses_get_val(nflagsmart => 1, rrow => rAddress ))
                  , usr_f_norm(sval => agnaddresses_get_val(nflagsmart => 1, rrow => rRow))) = 1 then
          p_exception(0, 'Уже существует адрес с таким значением и меньшей датой. %s%s%s%s'
                     ,cr||agnaddresses_get_type_name(nsign => nSIGN)
                     ,cr||decode_date(rAddress.registration_date) 
                     ,cr||agnaddresses_get_val(nflagsmart => 1, rrow => rAddress)
                     ,cr||get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rAddress.prn) ); 
        end if;
      end if;
    end SIGN_CHECK;

  begin
    /* Считывание */
    rRow := agnaddresses_get(nrn => nRN); 

    /* ПРОВЕРКИ */
    /* Признаки адреса */
    /* Юридический */
    if rRow.legal_sign = 1 then
      SIGN_CHECK(nSign => 0);
    /* Проживания */
    elsif rRow.real_sign = 1 then
      SIGN_CHECK(nSign => 1);
    /* Почтовый */
    elsif rRow.mail_sign = 1 then
      SIGN_CHECK(nSign => 2);
    /* Регистрации */
    elsif rRow.registration_sign = 1 then
      SIGN_CHECK(nSign => 3);
    /* Рождения */
    elsif rRow.birth_sign = 1 then
      SIGN_CHECK(nSign => 4);
    end if;
 
  end AGNADDRESSES_CHECK_BASE;
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW       in v_agnaddresses%rowtype
  ,NCOMPANY     in number
  ,nRN          out number
  ) 
  is
  begin
    p_agnaddresses_insert(ncompany           => NCOMPANY
                         ,nprn               => rV_ROW.NPRN
                         ,sgeografy_fullname => rV_ROW.SGEOGRAFY_FULLNAME
                         ,saddr_house        => rV_ROW.SADDR_HOUSE
                         ,saddr_block        => rV_ROW.SADDR_BLOCK
                         ,saddr_building     => rV_ROW.SADDR_BUILDING
                         ,saddr_stead        => rV_ROW.SADDR_STEAD
                         ,saddr_flat         => rV_ROW.SADDR_FLAT
                         ,sADDR_ADD          => rV_ROW.SADDR_ADD           /*Обновление 2025/11*/
                         ,saddr_post         => rV_ROW.SADDR_POST
                         ,nprimary_sign      => rV_ROW.NPRIMARY_SIGN
                         ,nlegal_sign        => rV_ROW.NLEGAL_SIGN
                         ,nreal_sign         => rV_ROW.NREAL_SIGN
                         ,nmail_sign         => rV_ROW.NMAIL_SIGN
                         ,nregistration_sign => rV_ROW.NREGISTRATION_SIGN
                         ,nbirth_sign        => rV_ROW.NBIRTH_SIGN
                         ,dregistration_date => rV_ROW.DREGISTRATION_DATE
                         ,dregistration_end  => rV_ROW.DREGISTRATION_END
                         ,snote              => rV_ROW.SNOTE
                         ,saoguid            => rV_ROW.SAOGUID
                         ,shouseguid         => rV_ROW.SHOUSEGUID
                         ,ssteadguid         => rV_ROW.SSTEADGUID
                         ,sAPARTMENTGUID     => rV_ROW.sAPARTMENTGUID   /*Обновление 2025/11*/
                         ,nrn                => nRN);
  END AGNADDRESSES_INSERT;
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_agnaddresses%rowtype
  ,NCOMPANY     in number
  ) 
  is
  begin
    p_agnaddresses_update(ncompany           => NCOMPANY
                         ,nrn                => rV_ROW.NRN
                         ,sgeografy_fullname => rV_ROW.SGEOGRAFY_FULLNAME
                         ,saddr_house        => rV_ROW.SADDR_HOUSE
                         ,saddr_block        => rV_ROW.SADDR_BLOCK
                         ,saddr_building     => rV_ROW.SADDR_BUILDING
                         ,saddr_stead        => rV_ROW.SADDR_STEAD
                         ,saddr_flat         => rV_ROW.SADDR_FLAT
                         ,sADDR_ADD          => rV_ROW.SADDR_ADD           /*Обновление 2025/11*/
                         ,saddr_post         => rV_ROW.SADDR_POST
                         ,nprimary_sign      => rV_ROW.NPRIMARY_SIGN
                         ,nlegal_sign        => rV_ROW.NLEGAL_SIGN
                         ,nreal_sign         => rV_ROW.NREAL_SIGN
                         ,nmail_sign         => rV_ROW.NMAIL_SIGN
                         ,nregistration_sign => rV_ROW.NREGISTRATION_SIGN
                         ,nbirth_sign        => rV_ROW.NBIRTH_SIGN
                         ,dregistration_date => rV_ROW.DREGISTRATION_DATE
                         ,dregistration_end  => rV_ROW.DREGISTRATION_END
                         ,snote              => rV_ROW.SNOTE
                         ,saoguid            => rV_ROW.SAOGUID
                         ,shouseguid         => rV_ROW.SHOUSEGUID
                         ,ssteadguid         => rV_ROW.SSTEADGUID
                         /*Обновление 2025/11*/
                         ,sAPARTMENTGUID     => rV_ROW.sAPARTMENTGUID);
  END AGNADDRESSES_UPDATE;
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW         in agnaddresses%rowtype
  ,NCOMPANY     in number
  ,nRN          out number
  ) 
  is
  begin
    p_agnaddresses_base_insert(ncompany           => NCOMPANY
                              ,nprn               => rROW.PRN
                              ,ngeografy_rn       => rROW.GEOGRAFY_RN
                              ,saddr_house        => rROW.ADDR_HOUSE
                              ,saddr_block        => rROW.ADDR_BLOCK
                              ,saddr_building     => rROW.ADDR_BUILDING
                              ,saddr_stead        => rROW.ADDR_STEAD
                              ,saddr_flat         => rROW.ADDR_FLAT
                              ,sADDR_ADD          => rROW.ADDR_ADD           /*Обновление 2025/11*/
                              ,saddr_post         => rROW.ADDR_POST
                              ,nprimary_sign      => rROW.PRIMARY_SIGN
                              ,nlegal_sign        => rROW.LEGAL_SIGN
                              ,nreal_sign         => rROW.REAL_SIGN
                              ,nmail_sign         => rROW.MAIL_SIGN
                              ,nregistration_sign => rROW.REGISTRATION_SIGN
                              ,nbirth_sign        => rROW.BIRTH_SIGN
                              ,dregistration_date => rROW.REGISTRATION_DATE
                              ,dregistration_end  => rROW.REGISTRATION_END
                              ,snote              => rROW.NOTE
                              ,saoguid            => rROW.AOGUID
                              ,shouseguid         => rROW.HOUSEGUID
                              ,ssteadguid         => rROW.STEADGUID
                              ,sAPARTMENTGUID     => rROW.APARTMENTGUID   ---Обновление 2025/11
                              ,nrn                => nRN);
  END AGNADDRESSES_BASE_INSERT;
  --#########################################################################################################

  PROCEDURE AGNADDRESSES_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW         in agnaddresses%rowtype
  ,NCOMPANY     in number
  ) 
  is
  begin
    p_agnaddresses_base_update(ncompany           => NCOMPANY
                              ,nrn                => rROW.RN
                              ,ngeografy_rn       => rROW.GEOGRAFY_RN
                              ,saddr_house        => rROW.ADDR_HOUSE
                              ,saddr_block        => rROW.ADDR_BLOCK
                              ,saddr_building     => rROW.ADDR_BUILDING
                              ,saddr_stead        => rROW.ADDR_STEAD
                              ,saddr_flat         => rROW.ADDR_FLAT
                              ,sADDR_ADD          => rROW.ADDR_ADD           /*Обновление 2025/11*/
                              ,saddr_post         => rROW.ADDR_POST
                              ,nprimary_sign      => rROW.PRIMARY_SIGN
                              ,nlegal_sign        => rROW.LEGAL_SIGN
                              ,nreal_sign         => rROW.REAL_SIGN
                              ,nmail_sign         => rROW.MAIL_SIGN
                              ,nregistration_sign => rROW.REGISTRATION_SIGN
                              ,nbirth_sign        => rROW.BIRTH_SIGN
                              ,dregistration_date => rROW.REGISTRATION_DATE
                              ,dregistration_end  => rROW.REGISTRATION_END
                              ,snote              => rROW.NOTE
                              ,saoguid            => rROW.AOGUID
                              ,shouseguid         => rROW.HOUSEGUID
                              ,ssteadguid         => rROW.STEADGUID
                              /*Обновление 2025/11*/
                              ,sAPARTMENTGUID     => rROW.APARTMENTGUID);
  END AGNADDRESSES_BASE_UPDATE;
  /*#########################################################################################################*/

end USR_PKG_AGNLIST;
/
