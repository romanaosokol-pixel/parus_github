create or replace package UDO_PKG_SYS0015_MAIL
/*
 Пакет для работы с E-Mail
*/
 as

  --разделитель элементов заголовка письма
  SBOUNDARY varchar2(50) := '----=*#abc1234321cba#*=';

  --элемент приложения к письму
  type ATTACH is record(
     SFILE_MIME varchar2(4000) --MIME-type дескриптор приложения
    ,SFILE_NAME varchar2(4000) --наименование файла приложения
    ,BFILE_DATA blob --данные файла приложения
    );

  --коллекция приложений к письму
  type ATTACHES is table of ATTACH;

  --считывание основного строкового значения указанной константы
  function GET_CONST_VAL_STR
  (
    NCOMPANY number --рег. номер организации
   ,SCONST   varchar2 --наименование константы
  ) return varchar2;

  --получение адреса E-Mail по имени пользователя БД
  function GET_MAIL_BY_AUTHID
  (
    NCOMPANY  number --рег. номер организации
   ,SAUTHID   varchar2 --имя пользователя Oracle
   ,NGET_MODE number := 3 --режим определения почты (1 - через д/с раздела "Контрагенты", 2 - через аутентификацию сотрудников, 3 - попробовать оба способа)
  ) return varchar2;

  --помещение письма в очередь
  procedure MAIL_INSERT
  (
    NCOMPANY number --рег. номер оргаизации
   ,SSNDR    varchar2 --от кого (null - отправитель по-умолчанию)
   ,SRCVR    varchar2 --кому
   ,SSUBJ    varchar2 --тема (null - тема по-умолчанию)
   ,STEXT    varchar2 --текст
   ,NRN      out number --рег. номер записи очереди
  );

  --клиентское удаление письма из очереди
  procedure MAIL_DELETE(NRN number --рег. номер удаляемой записи
                        );

  --клиентское добавления аттача к письму
  procedure MAIL_ATT_INSERT
  (
    NPRN       number --рег. номер родительского письма
   ,SFILE_MIME varchar2 --описатель содержимого - MIME-type
   ,SFILE_NAME varchar2 --наименование файла
   ,BFILE_DATA blob --данные файла
   ,NRN        out number --рег. номер добавленной записи
  );

  --клиентское удаление аттача к письму
  procedure MAIL_ATT_DELETE(NRN number --рег. номер удаляемой записи
                            );

  --обработка очереди сообщений
  procedure MAIL_PROCESS;

  --отправка сообщения
  procedure SMTP_SEND_MAIL
  (
    NSMART   number --признак генерации исключения (0 - да, 1 - нет)
   ,NCOMPANY number --рег. номер организации
   ,SFROM    varchar2 --от кого (null - отправитель по-умолчанию)
   ,STO      varchar2 --кому
   ,SSUBJ    varchar2 --тема (null - тема по-умолчанию)
   ,STEXT    varchar2 --текст
   ,ATTS     ATTACHES --приложения
  );

end;
/

create or replace package body UDO_PKG_SYS0015_MAIL
/*
 Пакет для работы с E-Mail (тело)
*/
 as

  --считывание основного строкового значения указанной константы
  function GET_CONST_VAL_STR
  (
    NCOMPANY number --рег. номер организации
   ,SCONST   varchar2 --наименование константы
  ) return varchar2 is
    SRES CONSTLST.STRVALUE%type; --результат работы
  begin
    select T.STRVALUE
      into SRES
      from CONSTLST T
     where T.NAME = SCONST
       and T.COMPANY = NCOMPANY;
    return SRES;
  exception
    when others then
      return null;
  end;

  --получение адреса E-Mail по имени пользователя БД
  function GET_MAIL_BY_AUTHID
  (
    NCOMPANY  number --рег. номер организации
   ,SAUTHID   varchar2 --имя пользователя Oracle
   ,NGET_MODE number := 3 --режим определения почты (1 - через д/с раздела "Контрагенты", 2 - через аутентификацию сотрудников, 3 - попробовать оба способа)
  ) return varchar2 is
    SRES        AGNLIST.MAIL%type; --результат работы
    NAG_VERSION AGNLIST.VERSION%type; --рег. номер версии словаря "Контрагенты"
  begin
    --если просили искать обоими способами или через д/с раздела "Контрагенты"
    if (NGET_MODE in (1
                     ,3))
    then
      --найдем версию раздела "Контрагенты"
      FIND_VERSION_BY_COMPANY(NCOMPANY  => NCOMPANY
                             ,SUNITCODE => 'AGNLIST'
                             ,NVERSION  => NAG_VERSION);
      --найдем адрес E-mail
      begin
        select AG.MAIL
          into SRES
          from AGNLIST         AG
              ,DOCS_PROPS_VALS DPV
              ,DOCS_PROPS      DP
         where DPV.STR_VALUE = SAUTHID
           and DPV.DOCS_PROP_RN = DP.RN
           and DP.CODE = 'Пользователь'
           and DPV.UNITCODE = 'AGNLIST'
           and DPV.UNIT_RN = AG.RN
           and AG.MAIL is not null
           and AG.VERSION = NAG_VERSION;
      exception
        --если что-то не так
        when others then
          SRES := null;
      end;
      --если интересовал только данный способ или уже что-то нашлось
      if ((NGET_MODE = 1) or (SRES is not null))
      then
        --веренем что нашли
        return SRES;
      end if;
    end if;
    --если просили искать обоими способами (и первым способом ничего не нашлось) или через аутентификацию сотрудников
    if (NGET_MODE in (2
                     ,3))
    then
      begin
        select AG.MAIL
          into SRES
          from AGNLIST    AG
              ,CLNPERSONS P
              ,COMPANIES  C
         where C.RN = NCOMPANY
           and P.COMPANY = C.RN
           and P.PERS_AUTHID = SAUTHID
           and P.PERS_AGENT = AG.RN
           and P.OWNER_AGENT = C.AGENT;
      exception
        --если что-то не так
        when others then
          SRES := null;
      end;
    end if;
    --веренем результат
    return SRES;
  exception
    when others then
      return null;
  end;

  --базовое помещение письма в очередь
  procedure MAIL_BASE_INSERT
  (
    NCOMPANY number --рег. номер оргаизации
   ,SSNDR    varchar2 --от кого (null - отправитель по-умолчанию)
   ,SRCVR    varchar2 --кому
   ,SSUBJ    varchar2 --тема (null - тема по-умолчанию)
   ,STEXT    varchar2 --текст
   ,NRN      out number --рег. номер записи очереди
  ) is
    SERR varchar2(2000);
  begin
    --генерируем рег. номер
    NRN := GEN_ID;
    --добавим
    begin
      insert into UDO_T_SYS0015_MAIL
        (RN
        ,COMPANY
        ,DATEIN
        ,DATECHSTATE
        ,STATUS
        ,CNTTRYS
        ,SENDERR
        ,SNDR
        ,RCVR
        ,SUBJ
        ,TEXT)
      values
        (NRN, NCOMPANY, sysdate, null, 0, 0, null, SSNDR, SRCVR, SSUBJ, STEXT);
    exception
      when DUP_VAL_ON_INDEX then
        P_EXCEPTION(0
                   ,'Такое письмо уже существует!');
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
  end;

  --клиентское помещение письма в очередь
  procedure MAIL_INSERT
  (
    NCOMPANY number --рег. номер оргаизации
   ,SSNDR    varchar2 --от кого (null - отправитель по-умолчанию)
   ,SRCVR    varchar2 --кому
   ,SSUBJ    varchar2 --тема (null - тема по-умолчанию)
   ,STEXT    varchar2 --текст
   ,NRN      out number --рег. номер записи очереди
  ) is
  begin
    --проверим параметры
    if (SRCVR is null)
    then
      P_EXCEPTION(0
                 ,'Не указан получатель письма!');
    end if;
    if (SSUBJ is null)
    then
      P_EXCEPTION(0
                 ,'Не указана тема письма!');
    end if;
    --добавим
    MAIL_BASE_INSERT(NCOMPANY => NCOMPANY
                    ,SSNDR    => SSNDR
                    ,SRCVR    => SRCVR
                    ,SSUBJ    => SSUBJ
                    ,STEXT    => STEXT
                    ,NRN      => NRN);
  end;

  --базовое удаление письма из очереди
  procedure MAIL_BASE_DELETE(NRN number --рег. номер удаляемой записи
                             ) is
    SERR varchar2(2000);
  begin
    --удалим вложения
    for C in (select T.RN
                from UDO_T_SYS0015_MAIL_ATT T
               where T.PRN = NRN)
    loop
      MAIL_ATT_DELETE(NRN => C.RN);
    end loop;
    --удалим письмо
    begin
      delete from UDO_T_SYS0015_MAIL T
       where T.RN = NRN;
    exception
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
    if (sql%notfound)
    then
      P_EXCEPTION(0
                 ,'Письмо с идентификатором ' || NRN || ' не найдено!');
    end if;
  end;

  --клиентское удаление письма из очереди
  procedure MAIL_DELETE(NRN number --рег. номер удаляемой записи
                        ) is
  begin
    --проверим параметры
    if (NRN is null)
    then
      P_EXCEPTION(0
                 ,'Не указан идентификатор удаляемой записи!');
    end if;
    --удалим письмо
    MAIL_BASE_DELETE(NRN => NRN);
  end;

  --установка статуса отправки письма
  procedure MAIL_SETSTATUS
  (
    NRN      number --рег. номер письма
   ,NSTATUS  number --состояние (-1 - не отправлено из-за ошибки, 0 - не отправлено, 1 - отправляется, 2 - отправлено)
   ,SSENDERR varchar2 --ошибка отправки сообщения
  ) is
  begin
    --проверим параметры
    if (NRN is null)
    then
      P_EXCEPTION(0
                 ,'Не указан идентификатор письма!');
    end if;
    if (NSTATUS is null)
    then
      P_EXCEPTION(0
                 ,'Не указана устанавливаемый статус!');
    end if;
    if (NSTATUS not in (-1
                       ,0
                       ,1
                       ,2))
    then
      P_EXCEPTION(0
                 ,'Указан некорректный статус!');
    end if;
    --установим значения
    update UDO_T_SYS0015_MAIL T
       set T.DATECHSTATE = sysdate
          ,T.STATUS      = NSTATUS
          ,T.SENDERR     = SSENDERR
     where T.RN = NRN;
  end;

  --фиксация очередной попытки отправки письма
  procedure MAIL_APPENDNEWTRY(NRN number --рег. номер письма
                              ) is
  begin
    --проверим параметры
    if (NRN is null)
    then
      P_EXCEPTION(0
                 ,'Не указан идентификатор письма!');
    end if;
    --установим значения
    update UDO_T_SYS0015_MAIL T
       set T.DATECHSTATE = sysdate
          ,T.STATUS      = 1
          ,T.CNTTRYS     = T.CNTTRYS + 1
          ,T.SENDERR     = null
     where T.RN = NRN;
  end;

  --базовое добавления аттача к письму
  procedure MAIL_ATT_BASE_INSERT
  (
    NPRN       number --рег. номер родительского письма
   ,SFILE_MIME varchar2 --описатель содержимого - MIME-type
   ,SFILE_NAME varchar2 --наименование файла
   ,BFILE_DATA blob --данные файла
   ,NRN        out number --рег. номер добавленной записи
  ) is
    SERR varchar2(2000);
  begin
    --генерируем рег. номер
    NRN := GEN_ID;
    --добавим
    begin
      insert into UDO_T_SYS0015_MAIL_ATT
        (RN, PRN, FILE_MIME, FILE_NAME, FILE_DATA)
      values
        (NRN, NPRN, SFILE_MIME, SFILE_NAME, BFILE_DATA);
    exception
      when DUP_VAL_ON_INDEX then
        P_EXCEPTION(0
                   ,'Вложение "' || SFILE_NAME || '" для письма (RN: "' || NPRN ||
                    '") уже существует!');
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
  end;

  --клиентское добавления аттача к письму
  procedure MAIL_ATT_INSERT
  (
    NPRN       number --рег. номер родительского письма
   ,SFILE_MIME varchar2 --описатель содержимого - MIME-type
   ,SFILE_NAME varchar2 --наименование файла
   ,BFILE_DATA blob --данные файла
   ,NRN        out number --рег. номер добавленной записи
  ) is
  begin
    --проверим параметры
    if (NPRN is null)
    then
      P_EXCEPTION(0
                 ,'Для вложения не указано родительское письмо!');
    end if;
    if (SFILE_NAME is null)
    then
      P_EXCEPTION(0
                 ,'Для вложения не указано имя файла!');
    end if;
    if (NVL(DBMS_LOB.GETLENGTH(LOB_LOC => BFILE_DATA)
           ,0) = 0)
    then
      P_EXCEPTION(0
                 ,'Для вложения не указаны данные файла!');
    end if;
    --добавим
    MAIL_ATT_BASE_INSERT(NPRN       => NPRN
                        ,SFILE_MIME => NVL(SFILE_MIME
                                          ,UDO_PKG_SYSW0003_PUBL_UTILS.GET_MIME_TYPE(SFILE_NAME => SFILE_NAME))
                        ,SFILE_NAME => SFILE_NAME
                        ,BFILE_DATA => BFILE_DATA
                        ,NRN        => NRN);
  end;

  --базовое удаление аттача к письму
  procedure MAIL_ATT_BASE_DELETE(NRN number --рег. номер удаляемой записи
                                 ) is
    SERR varchar2(2000);
  begin
    --удалим
    begin
      delete from UDO_T_SYS0015_MAIL_ATT T
       where T.RN = NRN;
    exception
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
    if (sql%notfound)
    then
      P_EXCEPTION(0
                 ,'Вложение с идентификатором ' || NRN || ' не найдено!');
    end if;
  end;

  --клиентское удаление аттача к письму
  procedure MAIL_ATT_DELETE(NRN number --рег. номер удаляемой записи
                            ) is
  begin
    --проверим параметры
    if (NRN is null)
    then
      P_EXCEPTION(0
                 ,'Не указан идентификатор удаляемой записи!');
    end if;
    --удалим
    MAIL_ATT_BASE_DELETE(NRN => NRN);
  end;

  --возвращает очередной почтовый дрес из списка, разделенного "," или ";". Формат адреса: someone@some-domain, "Someone at some domain" <someone@some-domain>, Someone at some domain <someone@some-domain>
  function GET_ADDRESS(SADDRLIST in out varchar2 --список адресатов в разделителями
                       ) return varchar2 is
    SADDR varchar2(256);
    NI    pls_integer;
    function LOOKUP_UNQUOTED_CHAR
    (
      SSTR  in varchar2
     ,SCHRS in varchar2
    ) return pls_integer is
      SC           varchar2(5);
      NI           pls_integer;
      NLEN         pls_integer;
      BINSIDEQUOTE boolean;
    begin
      BINSIDEQUOTE := false;
      NI           := 1;
      NLEN         := LENGTH(SSTR);
      while (NI <= NLEN)
      loop
        SC := SUBSTR(SSTR
                    ,NI
                    ,1);
        if (BINSIDEQUOTE)
        then
          if (SC = '"')
          then
            BINSIDEQUOTE := false;
          else
            if (SC = '\')
            then
              NI := NI + 1;
            end if;
          end if;
          goto NEXT_CHAR;
        end if;
        if (SC = '"')
        then
          BINSIDEQUOTE := true;
          goto NEXT_CHAR;
        end if;
        if (INSTR(SCHRS
                 ,SC) >= 1)
        then
          return NI;
        end if;
        <<NEXT_CHAR>>
        NI := NI + 1;
      end loop;
      return 0;
    end;

  begin
    SADDRLIST := LTRIM(SADDRLIST);
    NI        := LOOKUP_UNQUOTED_CHAR(SSTR  => SADDRLIST
                                     ,SCHRS => ',;');
    if (NI >= 1)
    then
      SADDR     := SUBSTR(SADDRLIST
                         ,1
                         ,NI - 1);
      SADDRLIST := SUBSTR(SADDRLIST
                         ,NI + 1);
    else
      SADDR     := SADDRLIST;
      SADDRLIST := '';
    end if;
    NI := LOOKUP_UNQUOTED_CHAR(SSTR  => SADDR
                              ,SCHRS => '<');
    if (NI >= 1)
    then
      SADDR := SUBSTR(SADDR
                     ,NI + 1);
      NI    := INSTR(SADDR
                    ,'>');
      if (NI >= 1)
      then
        SADDR := SUBSTR(SADDR
                       ,1
                       ,NI - 1);
      end if;
    end if;
    return SADDR;
  end;

  --авторизация на почтовом сервере
  procedure AUTH_MAIL
  (
    CONN      in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
   ,SUSER     in varchar2 --логин
   ,SPASSWORD in varchar2 --пароль
  ) is
  begin
    UTL_SMTP.COMMAND(C   => CONN
                    ,CMD => 'AUTH LOGIN');
    UTL_SMTP.COMMAND(C   => CONN
                    ,CMD => UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(SUSER))));
    UTL_SMTP.COMMAND(C   => CONN
                    ,CMD => UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(SPASSWORD))));
  end;

  --запись MIME-заголовка письма
  procedure WRITE_MIME_HEADER
  (
    CONN   in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
   ,SNAME  in varchar2 --имя типа
   ,SVALUE in varchar2 --значение типа
  ) is
    SSUBJECT varchar2(4000);
  begin
    if (SNAME <> 'Subject')
    then
      UTL_SMTP.WRITE_RAW_DATA(C    => CONN
                             ,DATA => UTL_RAW.CAST_TO_RAW(CONVERT(SNAME || ': ' ||
                                                                  SVALUE ||
                                                                  UTL_TCP.CRLF
                                                                 ,'UTF8')));
    else
      SSUBJECT := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(CONVERT(SVALUE
                                                                                                         ,'UTF8'))));
      SSUBJECT := replace(SSUBJECT
                         ,'=' || CHR(13) || CHR(10)
                         ,'');
      SSUBJECT := replace(SSUBJECT
                         ,'?'
                         ,'=3f');
      SSUBJECT := replace(SSUBJECT
                         ,' '
                         ,'=20');
      SSUBJECT := '=?UTF-8?Q?' || SSUBJECT || '?=';
      UTL_SMTP.WRITE_DATA(C    => CONN
                         ,DATA => SNAME || ': ' || SSUBJECT || UTL_TCP.CRLF);
    end if;
  end;

  --запись текста в письмо (побайтово)
  procedure WRITE_MSG_BBODY
  (
    CONN      in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
   ,SMESSAGE  in varchar2 --текст
   ,SMIMETYPE in varchar2 := 'text/html' --тип данных
  ) is
  begin
    UTL_SMTP.WRITE_DATA(CONN
                       ,'--' || SBOUNDARY || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(CONN
                       ,'Content-Type: ' || SMIMETYPE || ';charset=UTF8' ||
                        UTL_TCP.CRLF || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_RAW_DATA(C    => CONN
                           ,DATA => UTL_RAW.CAST_TO_RAW(CONVERT(SMESSAGE
                                                               ,'UTF8')));
    UTL_SMTP.WRITE_DATA(CONN
                       ,UTL_TCP.CRLF || UTL_TCP.CRLF);
  end;

  --запись приложения в письмо
  procedure WRITE_ATTACH
  (
    CONN       in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
   ,SFILE_NAME in varchar2 --наименование файла
   ,SFILE_MIME in varchar2 --классификатор MIME-Type
   ,BFILE_DATA in blob --данные файла
   ,BFINISH    in boolean --финишировать список приложений
  ) is
    NSTEP integer := 12000;
  begin
    if SFILE_NAME is not null
    then
      UTL_SMTP.WRITE_DATA(CONN
                         ,'--' || SBOUNDARY || UTL_TCP.CRLF);
      UTL_SMTP.WRITE_DATA(CONN
                         ,'Content-Type: ' || SFILE_MIME || ';name="' ||
                          SFILE_NAME || '"' || UTL_TCP.CRLF);
      UTL_SMTP.WRITE_DATA(CONN
                         ,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
      UTL_SMTP.WRITE_DATA(CONN
                         ,'Content-Disposition: attachment;filename="' ||
                          SFILE_NAME || '"' || UTL_TCP.CRLF || UTL_TCP.CRLF);
      for I in 0 .. TRUNC((DBMS_LOB.GETLENGTH(BFILE_DATA) - 1) / NSTEP)
      loop
        UTL_SMTP.WRITE_DATA(CONN
                           ,UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(DBMS_LOB.SUBSTR(BFILE_DATA
                                                                                             ,NSTEP
                                                                                             ,I *
                                                                                              NSTEP + 1))));
      end loop;
      UTL_SMTP.WRITE_DATA(CONN
                         ,UTL_TCP.CRLF || UTL_TCP.CRLF);
    end if;
    if (BFINISH)
    then
      UTL_SMTP.WRITE_DATA(CONN
                         ,'--' || SBOUNDARY || '--' || UTL_TCP.CRLF);
    end if;
  end;

  --запись приложений в письмо
  procedure WRITE_ATTACHES
  (
    CONN in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
   ,ATTS in ATTACHES --приложения
  ) is
    BFINISH boolean := false; --признак финиширования списка приложений
  begin
    if ((ATTS is not null) and (ATTS.COUNT > 0))
    then
      for I in ATTS.FIRST .. ATTS.LAST
      loop
        if (I = ATTS.LAST)
        then
          BFINISH := true;
        else
          BFINISH := false;
        end if;
        WRITE_ATTACH(CONN       => CONN
                    ,SFILE_NAME => ATTS(I).SFILE_NAME
                    ,SFILE_MIME => ATTS(I).SFILE_MIME
                    ,BFILE_DATA => ATTS(I).BFILE_DATA
                    ,BFINISH    => BFINISH);
      end loop;
    end if;
  end;

  --открытие сессии отправки сообщения
  function BEGIN_SESSION
  (
    SDOMAIN varchar2 --домен сервера
   ,SHOST   varchar2 --имя сервера
   ,NPORT   number --номер порта сервера
  ) return UTL_SMTP.CONNECTION --подключение к серверу
   is
    CONN UTL_SMTP.CONNECTION;
  begin
    CONN := UTL_SMTP.OPEN_CONNECTION(HOST => SHOST
                                    ,PORT => NPORT);
    UTL_SMTP.EHLO(C      => CONN
                 ,DOMAIN => SDOMAIN);
    return CONN;
  end;

  --формирование заголовка сообщения
  procedure BEGIN_MAIL_IN_SESSION
  (
    CONN        in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
   ,SSENDER     in varchar2 --отправитель
   ,SRECIPIENTS in varchar2 --получатели
   ,SSUBJECT    in varchar2 --тема
   ,SONBEHALFOF in varchar2 := null --от имени кого
  ) is
    SMYRECIPIENTS varchar2(32767) := SRECIPIENTS;
    SMYSENDER     varchar2(32767) := SSENDER;
  begin
    UTL_SMTP.MAIL(C      => CONN
                 ,SENDER => GET_ADDRESS(SMYSENDER));
    while (SMYRECIPIENTS is not null)
    loop
      UTL_SMTP.RCPT(C         => CONN
                   ,RECIPIENT => GET_ADDRESS(SMYRECIPIENTS));
    end loop;
    UTL_SMTP.OPEN_DATA(C => CONN);
    WRITE_MIME_HEADER(CONN   => CONN
                     ,SNAME  => 'To'
                     ,SVALUE => SRECIPIENTS);
    WRITE_MIME_HEADER(CONN   => CONN
                     ,SNAME  => 'Subject'
                     ,SVALUE => SSUBJECT);
    if (SONBEHALFOF is not null)
    then
      WRITE_MIME_HEADER(CONN   => CONN
                       ,SNAME  => 'From'
                       ,SVALUE => SONBEHALFOF);
      WRITE_MIME_HEADER(CONN   => CONN
                       ,SNAME  => 'Sender'
                       ,SVALUE => SSENDER);
    else
      WRITE_MIME_HEADER(CONN   => CONN
                       ,SNAME  => 'From'
                       ,SVALUE => SSENDER);
      WRITE_MIME_HEADER(CONN   => CONN
                       ,SNAME  => 'Sender'
                       ,SVALUE => SSENDER);
    end if;
    WRITE_MIME_HEADER(CONN   => CONN
                     ,SNAME  => 'Content-Language'
                     ,SVALUE => 'ru');
    WRITE_MIME_HEADER(CONN   => CONN
                     ,SNAME  => 'Content-Type'
                     ,SVALUE => 'multipart/mixed; boundary="' || SBOUNDARY ||
                                '";charset=UTF8');
    WRITE_MIME_HEADER(CONN   => CONN
                     ,SNAME  => 'Content-Transfer-Encoding'
                     ,SVALUE => 'quoted-printable');
    UTL_SMTP.WRITE_DATA(C    => CONN
                       ,DATA => UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(C    => CONN
                       ,DATA => 'This is a multi-part message in MIME format.' ||
                                UTL_TCP.CRLF);
  end;

  --старт отправки сообщения
  function BEGIN_MAIL
  (
    SDOMAIN     in varchar2 --домен сервера
   ,SHOST       in varchar2 --имя сервера
   ,NPORT       in number --номер порта сервера
   ,SSENDER     in varchar2 --отправитель
   ,SRECIPIENTS in varchar2 --получатели
   ,SSUBJECT    in varchar2 --тема
   ,SUSER       in varchar2 := null --логин
   ,SPASSWORD   in varchar2 := null --пароль
   ,SONBEHALFOF in varchar2 := null --от имени кого
  ) return UTL_SMTP.CONNECTION --подключение к серверу
   is
    CONN UTL_SMTP.CONNECTION;
  begin
    CONN := BEGIN_SESSION(SDOMAIN => SDOMAIN
                         ,SHOST   => SHOST
                         ,NPORT   => NPORT);
    if (SUSER is not null)
    then
      AUTH_MAIL(CONN      => CONN
               ,SUSER     => SUSER
               ,SPASSWORD => SPASSWORD);
    end if;
    BEGIN_MAIL_IN_SESSION(CONN        => CONN
                         ,SSENDER     => SSENDER
                         ,SRECIPIENTS => SRECIPIENTS
                         ,SSUBJECT    => SSUBJECT
                         ,SONBEHALFOF => SONBEHALFOF);
    return CONN;
  end;

  --завершение отправки сообщения
  procedure END_SESSION(CONN in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
                        ) is
  begin
    UTL_SMTP.QUIT(CONN);
  end;

  --финализация сообщения
  procedure END_MAIL_IN_SESSION(CONN in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
                                ) is
  begin
    UTL_SMTP.CLOSE_DATA(C => CONN);
  end;

  --закрытие сесси отправки сообщения
  procedure END_MAIL(CONN in out nocopy UTL_SMTP.CONNECTION --подключение к серверу
                     ) is
  begin
    END_MAIL_IN_SESSION(CONN => CONN);
    END_SESSION(CONN => CONN);
  end;

  --отправка сообщения
  procedure MAIL
  (
    SDOMAIN     in varchar2 --домен сервера
   ,SHOST       in varchar2 --имя сервера
   ,NPORT       in number --номер порта сервера
   ,SSENDER     in varchar2 --отправитель
   ,SRECIPIENTS in varchar2 --получатели
   ,SSUBJECT    in varchar2 --тема
   ,SMESSAGE    in varchar2 --сообщение
   ,SMIMETYPE   in varchar2 := 'text/html' --тип данных
   ,SUSER       in varchar2 := null --логин
   ,SPASSWORD   in varchar2 := null --пароль
   ,ATTS        in ATTACHES --приложения
  ) is
    CONN UTL_SMTP.CONNECTION;
  begin
    CONN := BEGIN_MAIL(SDOMAIN     => SDOMAIN
                      ,SHOST       => SHOST
                      ,NPORT       => NPORT
                      ,SSENDER     => SSENDER
                      ,SRECIPIENTS => SRECIPIENTS
                      ,SSUBJECT    => SSUBJECT
                      ,SUSER       => SUSER
                      ,SPASSWORD   => SPASSWORD
                      ,SONBEHALFOF => null);
    WRITE_MSG_BBODY(CONN      => CONN
                   ,SMESSAGE  => SMESSAGE
                   ,SMIMETYPE => SMIMETYPE);
    WRITE_ATTACHES(CONN => CONN
                  ,ATTS => ATTS);
    END_MAIL(CONN => CONN);
  end;

  --базовая отправка письма по SMTP
  function SMTP_SEND_MAIL_BASE
  (
    SDOMAIN varchar2 --домен
   ,SSERVER varchar2 --сервер
   ,NPORT   number --порт
   ,SUSER   varchar2 --пользователь
   ,SPASS   varchar2 --пароль
   ,SFROM   varchar2 --от кого
   ,STO     varchar2 --кому
   ,SSUBJ   varchar2 --тема
   ,STEXT   varchar2 --текст
   ,ATTS    ATTACHES --приложения
  ) return number --1 - отправлено, 0 - нет
   is
    NRES number;
  begin
    begin
      MAIL(SDOMAIN     => SDOMAIN
          ,SHOST       => SSERVER
          ,NPORT       => NPORT
          ,SSENDER     => SFROM
          ,SRECIPIENTS => STO
          ,SSUBJECT    => SSUBJ
          ,SMESSAGE    => STEXT
          ,SMIMETYPE   => 'text/html'
          ,SUSER       => SUSER
          ,SPASSWORD   => SPASS
          ,ATTS        => ATTS);
      NRES := 1;
    exception
      when others then
        NRES := 0;
        raise;
    end;
    return NRES;
  end;

  --клиентская отправка письма по SMTP
  procedure SMTP_SEND_MAIL
  (
    NSMART   number --признак генерации исключения (0 - да, 1 - нет)
   ,NCOMPANY number --рег. номер организации
   ,SFROM    varchar2 --от кого (null - отправитель по-умолчанию)
   ,STO      varchar2 --кому
   ,SSUBJ    varchar2 --тема (null - тема по-умолчанию)
   ,STEXT    varchar2 --текст
   ,ATTS     ATTACHES --приложения
  ) is
    NRES    number;
    SDOMAIN varchar2(200);
    SSERVER varchar2(200);
    NPORT   number;
    SUSER   varchar2(4000);
    SPASS   varchar2(4000);
    SFROM_  varchar2(4000);
    SSUBJ_  varchar2(4000);
    SERR    varchar2(4000);
  begin
    --проверим переданные параметры
    if (STO is null)
    then
      P_EXCEPTION(NSMART
                 ,'Хотя бы один получатель должен быть указан');
    end if;
    if (SSUBJ is null)
    then
      P_EXCEPTION(NSMART
                 ,'Тема сообщения должна быть указана');
    end if;
    --считаем настройки системы и отправим письмо
    begin
      --домен сервера почтовой рассылки
      SDOMAIN := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                  ,SCONST   => 'SMTP_ДОМЕН');
      if (SDOMAIN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан домен SMTP-сервера (проверьте константу "SMTP_ДОМЕН")!');
      end if;
      --сервер почтовой рассылки (SMTP)
      SSERVER := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                  ,SCONST   => 'SMTP_СЕРВЕР');
      if (SSERVER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан адрес SMTP-сервера (проверьте константу "SMTP_СЕРВЕР")!');
      end if;
      --порт сервера почтовой рассылки (SMTP)
      NPORT := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                ,SCONST   => 'SMTP_ПОРТ');
      if (NPORT is null)
      then
        P_EXCEPTION(0
                   ,'Не указан порт SMTP-сервера (проверьте константу "SMTP_ПОРТ")!');
      end if;
      --отправитель
      if (SFROM is null)
      then
        SFROM_ := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                   ,SCONST   => 'SMTP_ОТПРАВИТЕЛЬ');
        if (SFROM_ is null)
        then
          P_EXCEPTION(0
                     ,'Не указан отправитель по-умолчанию (проверьте константу "SMTP_ОТПРАВИТЕЛЬ")!');
        end if;
      else
        SFROM_ := SFROM;
      end if;
      --тема
      if (SSUBJ is null)
      then
        SSUBJ_ := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                   ,SCONST   => 'SMTP_ТЕМА');
        if (SSUBJ_ is null)
        then
          P_EXCEPTION(0
                     ,'Не указана тема письма по-умолчанию (проверьте константу "SMTP_ТЕМА")!');
        end if;
      else
        SSUBJ_ := SSUBJ;
      end if;
      --пользователь SMTP
      SUSER := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                ,SCONST   => 'SMTP_ПОЛЬЗОВАТЕЛЬ');
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь SMTP-сервера (проверьте константу "SMTP_ПОЛЬЗОВАТЕЛЬ")!');
      end if;
      --пароль SMTP
      SPASS := GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                ,SCONST   => 'SMTP_ПАРОЛЬ');
      if (SPASS is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пароль пользователя SMTP-сервера (проверьте константу "SMTP_ПАРОЛЬ")!');
      end if;
      --отправляем
      NRES := SMTP_SEND_MAIL_BASE(SDOMAIN => SDOMAIN
                                 ,SSERVER => SSERVER
                                 ,NPORT   => NPORT
                                 ,SUSER   => SUSER
                                 ,SPASS   => SPASS
                                 ,SFROM   => SFROM_
                                 ,STO     => STO
                                 ,SSUBJ   => SSUBJ_
                                 ,STEXT   => STEXT
                                 ,ATTS    => ATTS);
    exception
      when others then
        NRES := 0;
        SERR := sqlerrm;
    end;
    if (NRES = 0)
    then
      P_EXCEPTION(NSMART
                 ,'Ошибка отправки сообщения: ' || SERR);
    end if;
  end;

  --обработка очереди сообщений
  procedure MAIL_PROCESS is
    SERR varchar2(2000); --буфер для ошибок
    ATTS ATTACHES; --коллекция приложений к письму
  begin
    --идем по очереди сообщений, FIFO
    for CUR in (select T.*
                  from UDO_T_SYS0015_MAIL T
                 where (T.STATUS = 0)
                    or ((T.STATUS = -1) and (T.CNTTRYS <= 5))
                 order by T.DATEIN asc)
    loop
      begin
        --покажем в очереди попытку отправки
        MAIL_APPENDNEWTRY(NRN => CUR.RN);
        commit;
        --инициализируем приложения к письму
        ATTS := ATTACHES();
        for C in (select T.*
                    from UDO_T_SYS0015_MAIL_ATT T
                   where T.PRN = CUR.RN
                     and T.FILE_MIME is not null
                     and T.FILE_NAME is not null
                     and NVL(DBMS_LOB.GETLENGTH(T.FILE_DATA)
                            ,0) > 0)
        loop
          ATTS.EXTEND();
          ATTS(ATTS.LAST).SFILE_MIME := C.FILE_MIME;
          ATTS(ATTS.LAST).SFILE_NAME := C.FILE_NAME;
          ATTS(ATTS.LAST).BFILE_DATA := C.FILE_DATA;
        end loop;
        --отправим письмо
        SMTP_SEND_MAIL(NSMART   => 0
                      ,NCOMPANY => CUR.COMPANY
                      ,SFROM    => CUR.SNDR
                      ,STO      => CUR.RCVR
                      ,SSUBJ    => CUR.SUBJ
                      ,STEXT    => CUR.TEXT
                      ,ATTS     => ATTS);
        --выставим в очереди статус отправки
        MAIL_SETSTATUS(NRN      => CUR.RN
                      ,NSTATUS  => 2
                      ,SSENDERR => SERR);
      exception
        when others then
          SERR := sqlerrm;
          MAIL_SETSTATUS(NRN      => CUR.RN
                        ,NSTATUS  => -1
                        ,SSENDERR => SERR);
      end;
      commit;
    end loop;
  end;

end;
/

