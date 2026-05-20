create or replace package UDO_PKG_SYSW0003_PUBL_UTILS as

  /*
   Утилиты для рендеринга HTML и работы WEB-интерфейса
  */
  --константы - разделитель элементов списков
  SDELIM_LISTS varchar2(20) := ';';

  -- хеширование пароля
  function PASSWORD_HASH
  (
    sUTILIZER           in varchar2,
    sPASSWORD           in varchar2
  )
  return varchar2;

  --вход в систему
  function LOGIN
  (
    SUSERNAME in varchar2 -- имя пользователя
   ,SPASSWORD in varchar2 -- пароль
  ) return boolean;

  -- выход из системы
  procedure LOGOFF;

  --считывание префикса адреса картинок
  function GET_IMGPREF return varchar2;

  --транслитерация русской строки в английскую
  function STR_TRANSLATE(SSTR_RU varchar2 --строка с русскими символами (CL8MSWIN1251)
                         ) return varchar2;

  --считываение наименования пользователя по его имени
  function F_GET_USER_NAME(SUSER varchar2 --пользователь
                           ) return varchar2;

  --формирование адреса WEB-справки (для браузера)
  function F_MAKE_HELP_URL_WEB
  (
    NCOMPANY    number --рег. номер организации
   ,NMODE       number --режим (0 - настольный интерфейс, 1 - мобильный интерфейс)
   ,NINC_VIEWER number --включить в URL адрес просмотрщика (0 - нет, 1 - Google Docs)
  ) return varchar2;

  --формирование адреса WEB-справки (для WIN-клиента)
  function F_MAKE_HELP_URL
  (
    NCOMPANY  number --рег. номер организации
   ,SFUNCTION varchar2 --код функции
  ) return varchar2;

  --получение адреса WEB-справки (для WIN-клиента)
  procedure P_MAKE_HELP_URL
  (
    NCOMPANY  number --рег. номер организации
   ,SFUNCTION varchar2 --код функции
   ,SURL      out varchar2 --адрес справки
  );

  --порционная выдача CLOB с HTML WEB-серверу
  procedure PUBLISH_CLOB_BUFFER(SHTML clob --HTML-данные
                                );

  --формирование JSON ответа для AJAX запросов
  function MAKE_RESP
  (
    SSTATUS  varchar2 --состояние
   ,SMESSAGE varchar2 := null --сообщение
  ) return clob;

  --формирование JSON ответа для AJAX запросов и выдача их WEB-серверу
  procedure SEND_RESP
  (
    SSTATUS  varchar2 --состояние
   ,SMESSAGE varchar2 := null --сообщение
  );

  --HTML обрамление сообщения об ошибке
  function GET_ERR_HTML(NMODE number --режим (1 - начальные тэги, 2 - финальные тэги)
                        ) return varchar2;

  --нормализация сообщения об ошибке
  function CORRECT_ERR(SERR varchar2) return varchar2;

  --конвертирование строковых значений в числовые для целей WEB-представления
  function CONVERT_TO_NUMBER
  (
    SSTR   varchar2 --конвертируемая строка
   ,NSMART number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return number;

  --конвертирование числовых значений в строковые для целей WEB-представления
  function CONVERT_TO_STRING
  (
    NNUMB     number --конвертируемое число
   ,NSEPARATE number := 0 --разделять разряды (0 - нет, 1 - да)
   ,NSHARP    number := 2 --точность (кол-во знаков после запятой, только для NSEPARATE = 1)
  ) return varchar2;

  --конвертация строки в дату для целей WEB-представления
  function CONVERT_TO_DATE
  (
    NSMART   in number --признак выдачи сообщения об ошибке
   ,SDATE    in varchar2 --дата (строковое представление)
   ,SERR_MSG in varchar2 := null --сообщение об ошибке конвертации
  ) return date;

  --экранирование строки для HTML выдачи
  function STR_ESCAPE(SSTR varchar2 --экранируемая строка
                      ) return varchar2;

  --экранирование строковых элементов JSON-объекта
  procedure JSON_ESCAPE
  (
    SFIELDS varchar2 --список полей объекта для экранирования (должны быть строками, разделитель списка ;)
   ,OBJ     in out JSON --экранируемый объект
  );

  --формирование начала таблицы
  function START_TABLE
  (
    STABLE_CLASS varchar2 --CSS-класс для таблицы
   ,SATTRS       varchar2 := null --дополнительные атрибуты
  ) return varchar2;

  --формирование окончания таблицы
  function FINISH_TABLE return varchar2;

  --формирование начала строки таблицы
  function START_ROW
  (
    STR_CLASS varchar2 --CSS-класс для строки данных таблицы
   ,SATTRS    varchar2 := null --дополнительные атрибуты
  ) return varchar2;

  --формирование окончания строки таблицы
  function FINISH_ROW return varchar2;

  --формирование ячейки для заголовка таблицы
  function FORMAT_TH_CELL
  (
    SHDR        varchar2 --текст заголовка
   ,STH_CLASS   varchar2 --CSS-класс для ячейки заголовка таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2;

  --формирование ячейки для строковых данных
  function FORMAT_STR_CELL
  (
    SSTR        varchar2 --строка
   ,STD_CLASS   varchar2 --CSS-класс для ячейки данных таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2;

  --формирование ячейки для числовых данных
  function FORMAT_NUMB_CELL
  (
    NNUMB       number --число
   ,STD_CLASS   varchar2 --CSS-класс для ячейки данных таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,NSHARP      number := 2 --точность (количество знаков после запятой)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2;

  --формирование ячейки для даты
  function FORMAT_DATE_CELL
  (
    DDATE       date --дата
   ,STD_CLASS   varchar2 --CSS-класс для ячейки данных таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2;

  --считывание расширения файла
  function GET_FILE_EXT(SFILE_NAME varchar2 --имя файла
                        ) return varchar2;

  --формирование MIME-type описателя по имени файла
  function GET_MIME_TYPE(SFILE_NAME varchar2 --имя файла
                         ) return varchar2;

  --скачивание файла
  procedure DOWNLOAD_FILE
  (
    NFILE in number --рег. номер документа/процесса
   ,SUSER in varchar --имя пользователя
   ,NSRC  in number --источник (0 - общесистемный файловый буфер, 1 - очередь печати отчетов, 2 - картинка предпросмотра отчета)
  );

end;
/

create or replace package body UDO_PKG_SYSW0003_PUBL_UTILS as

  /*
   Утилиты для рендеринга HTML и работы WEB-интерфейса
  */
  -- хеширование пароля
  function PASSWORD_HASH
  (
    sUTILIZER           in varchar2,
    sPASSWORD           in varchar2
  )
  return varchar2
  as
    sUSRPWD             varchar2( 256 );
    rUSRPWD             raw( 256 );
    rRESULT             raw( 256 );
  begin
    /* обеспечение совместимости */
    if ( substr(sPASSWORD,1,1) = chr(0) ) then
      return to_char(sys.dbms_utility.get_hash_value(sUTILIZER||' '||substr(sPASSWORD,2),0,1024));
    end if;

    /* хеширование */
    sUSRPWD := sUTILIZER || upper(sPASSWORD);
    rUSRPWD := utl_i18n.string_to_raw(rpad(sUSRPWD,ceil(length(sUSRPWD)/4)*4,chr(0)),'AL16UTF16');
    --
    sys.dbms_obfuscation_toolkit.desencrypt
    (
      input          => rUSRPWD,
      key            => hextoraw('0123456789ABCDEF'),
      encrypted_data => rRESULT
    );
    sys.dbms_obfuscation_toolkit.desencrypt
    (
      input          => rUSRPWD,
      key            => utl_raw.substr(rRESULT,utl_raw.length(rRESULT)-7,8),
      encrypted_data => rRESULT
    );
    --
    return utl_raw.substr(rRESULT,utl_raw.length(rRESULT)-7,8);
  end PASSWORD_HASH;

  --вход в систему
  function LOGIN
  (
    SUSERNAME in varchar2 -- имя пользователя
   ,SPASSWORD in varchar2 -- пароль
  ) return boolean is
    NTMP number(1);
  begin
    -- проверим пароль WEB-пользователя в системе
    select 1
      into NTMP
      from USERLIST T
     where T.AUTHID = UPPER(SUSERNAME)
       and T.PASSWORD_WEB =
           PASSWORD_HASH(SUTILIZER => UPPER(SUSERNAME)
                        ,SPASSWORD => SPASSWORD)
           /*A.K. 28.11.2016 PKG_SESSION.PASSWORD_HASH(SUTILIZER => UPPER(SUSERNAME)
                                    ,SPASSWORD => SPASSWORD)*/
       and (T.CLIENT_WEB = 1 and T.SEC_PROFILE is null or
            exists(select null
                     from USERSECPROF SEC
                    where SEC.RN = T.SEC_PROFILE
                      and SEC.CLIENT_WEB = 1)) -- 09/10/2018 Михайлов И.А. поддержка профилей безопасности
       and ((T.LOGIN_ENABLED is null) or
           ((T.LOGIN_ENABLED is not null) and (T.LOGIN_ENABLED > 0)));
    --все успешно
    return true;
  exception
    when others then
      --ошибка
      return false;
  end;

  -- выход из системы
  procedure LOGOFF is
  begin
    --завершим сессию в системе
    PKG_SESSION.LOGOFF_WEB(SCONNECT => V('APP_SESSION'));
  end;

  --считывание префикса адреса картинок
  function GET_IMGPREF return varchar2 is
  begin
    return V('IMAGE_PREFIX');
  exception
    when others then
      return null;
  end;

  --транслитерация русской строки в английскую
  function STR_TRANSLATE(SSTR_RU varchar2 --строка с русскими символами (CL8MSWIN1251)
                         ) return varchar2 is
    SRES varchar2(4000);
  begin
    SRES := TRANSLATE(UPPER(SSTR_RU)
                     ,'АБВГДЕЗИЙКЛМНОПРСТУФЬЫЪЭ'
                     ,'ABVGDEZIJKLMNOPRSTUF''Y''E');
    SRES := replace(SRES
                   ,'Ж'
                   ,'ZH');
    SRES := replace(SRES
                   ,'Х'
                   ,'KH');
    SRES := replace(SRES
                   ,'Ц'
                   ,'TS');
    SRES := replace(SRES
                   ,'Ч'
                   ,'CH');
    SRES := replace(SRES
                   ,'Ш'
                   ,'SH');
    SRES := replace(SRES
                   ,'Щ'
                   ,'SH');
    SRES := replace(SRES
                   ,'Ю'
                   ,'YU');
    SRES := replace(SRES
                   ,'Я'
                   ,'YA');
    return SRES;
  end;

  --считываение наименования пользователя по его имени
  function F_GET_USER_NAME(SUSER varchar2 --пользователь
                           ) return varchar2 is
    SRES USERLIST.NAME%type; --результат работы
  begin
    --считаем
    select UL.NAME
      into SRES
      from USERLIST UL
     where UL.AUTHID = SUSER;
    --вернем
    return SRES;
  exception
    when others then
      return SUSER;
  end;

  --формирование адреса WEB-справки (для браузера)
  function F_MAKE_HELP_URL_WEB
  (
    NCOMPANY    number --рег. номер организации
   ,NMODE       number --режим (0 - настольный интерфейс, 1 - мобильный интерфейс)
   ,NINC_VIEWER number --включить в URL адрес просмотрщика (0 - нет, 1 - Google Docs)
  ) return varchar2 is
    SVIEWER_URL_GOOGLE_DOCS varchar2(2000) := 'http://docs.google.com/viewer?embedded=true&url='; --адрес приложения для просмотра
    SHELP_URL               varchar2(4000); --адрес файла справки
    SROOT                   varchar2(4000); --корневой каталог WEB-интерфейса системы
    SDIR                    varchar2(4000); --каталог для хранения опубликованных документов WEB-интерфейса системы
    SFILE                   varchar2(4000); --имя файла справки
  begin
    --считаем корень WEB-интерфейса
    SROOT := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                        ,SCONST   => 'WEB_ROOT');
    --определим каталог для публикации документов
    SDIR := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                       ,SCONST   => 'WEB_DOCS');
    --считаем имя файла справки
    case NVL(NMODE
        ,-1)
      when 0 then
        SFILE := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                            ,SCONST   => 'WEB_HELP_DESK');
      when 1 then
        SFILE := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                            ,SCONST   => 'WEB_HELP_MOBILE');
      else
        return null;
    end case;
    --сформируем адрес
    if ((SROOT is null) or (SDIR is null) or (SFILE is null))
    then
      return null;
    else
      SHELP_URL := UTL_URL.ESCAPE(SROOT || '/' || SDIR || '/' || SFILE
                                 ,true);
    end if;
    --добавим просмотрщика
    case NVL(NINC_VIEWER
        ,0)
      when 1 then
        SHELP_URL := SVIEWER_URL_GOOGLE_DOCS || SHELP_URL;
      else
        null;
    end case;
    --вернем результат
    return SHELP_URL;
  exception
    when others then
      return null;
  end;

  --формирование адреса WEB-справки (для WIN-клиента)
  function F_MAKE_HELP_URL
  (
    NCOMPANY  number --рег. номер организации
   ,SFUNCTION varchar2 --код функции
  ) return varchar2 is
    SROOT varchar2(4000); --корневой каталог WEB-интерфейса системы
    SDIR  varchar2(4000); --каталог для хранения опубликованных документов WEB-интерфейса системы
    SFILE varchar2(4000); --имя файла справки
  begin
    --считаем корень WEB-интерфейса
    SROOT := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                        ,SCONST   => 'WEB_ROOT');
    --определим каталог для публикации документов
    SDIR := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                       ,SCONST   => 'WEB_DOCS');
    --считаем имя файла справки
    SFILE := UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY => NCOMPANY
                                        ,SCONST   => 'WEB_HELP');
    if ((SROOT is null) or (SDIR is null) or (SFILE is null))
    then
      P_EXCEPTION(0
                 ,'Не удалось сформировать URL для WEB-справки! Проверьте конфигурацию системы!');
    end if;
    return SROOT || '/' || SDIR || '/' || SFILE || '#' || SFUNCTION;
  end;

  --получение адреса WEB-справки (для WIN-клиента)
  procedure P_MAKE_HELP_URL
  (
    NCOMPANY  number --рег. номер организации
   ,SFUNCTION varchar2 --код функции
   ,SURL      out varchar2 --адрес справки
  ) is
  begin
    SURL := F_MAKE_HELP_URL(NCOMPANY  => NCOMPANY
                           ,SFUNCTION => SFUNCTION);
  end;

  --порционная выдача CLOB с HTML WEB-серверу
  procedure PUBLISH_CLOB_BUFFER(SHTML clob --HTML-данные
                                ) is
    NTOTLEN number(17); --общее кол-во символов к передаче
    NREST   number(17); --остаток символов к передаче
    NBLEN   number(17) := 2000; --длина строкового буфера (порция)
    STMP    varchar2(2000); --строковый буфер
    NI      number(17) := 0; --счетчик передач
  begin
    --если есть данные
    if ((SHTML is not null) and (DBMS_LOB.GETLENGTH(SHTML) > 0))
    then
      --сколько всего данных
      NTOTLEN := DBMS_LOB.GETLENGTH(SHTML);
      --сколько осталось передать данных
      NREST := NTOTLEN;
      --режем буфер на строки
      while (NREST > 0)
      loop
        --отрезаем
        STMP := DBMS_LOB.SUBSTR(SHTML
                               ,NBLEN
                               ,(NBLEN * NI) + 1);
        --отмечаем, что отрезали
        NI    := NI + 1;
        NREST := NREST - LENGTH(STMP);
        --выдаем
        HTP.PRN(STMP);
      end loop;
    end if;
  end;

  --формирование JSON ответа для AJAX запросов
  function MAKE_RESP
  (
    SSTATUS  varchar2 --состояние
   ,SMESSAGE varchar2 := null --сообщение
  ) return clob is
    RESP  JSON; --объектное представление ответа
    CRESP clob; --тектовое предсттавление ответа
  begin
    --сформируем объект ответа
    RESP := JSON();
    RESP.PUT(PAIR_NAME  => 'SSTATUS'
            ,PAIR_VALUE => SSTATUS);
    RESP.PUT(PAIR_NAME  => 'SMESSAGE'
            ,PAIR_VALUE => SMESSAGE);
    --сформируем ответ в тексте
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                            ,CACHE   => false);
    RESP.TO_CLOB(BUF => CRESP);
    --вернем результат
    return CRESP;
  end;

  --формирование JSON ответа для AJAX запросов и выдача их WEB-серверу
  procedure SEND_RESP
  (
    SSTATUS  varchar2 --состояние
   ,SMESSAGE varchar2 := null --сообщение
  ) is
  begin
    --сформируем JSON ответ и отдадим его серверу
    PUBLISH_CLOB_BUFFER(SHTML => MAKE_RESP(SSTATUS  => SSTATUS
                                          ,SMESSAGE => SMESSAGE));
  end;

  --HTML обрамление сообщения об ошибке
  function GET_ERR_HTML(NMODE number --режим (1 - начальные тэги, 2 - финальные тэги)
                        ) return varchar2 is
  begin
    if (NMODE = 1)
    then
      return '<center><b><span style="color:red">';
    else
      return '</span></b></center>';
    end if;
  end;

  --нормализация сообщения об ошибке
  function CORRECT_ERR(SERR varchar2) return varchar2 is
    STMP varchar2(4000) := SERR;
    SRES varchar2(4000);
    NB   number;
    NE   number;
  begin
    begin
      while (INSTR(STMP
                  ,'ORA') <> 0)
      loop
        NB   := INSTR(STMP
                     ,'ORA');
        NE   := INSTR(STMP
                     ,':'
                     ,NB);
        STMP := trim(replace(STMP
                            ,trim(SUBSTR(STMP
                                        ,NB
                                        ,NE - NB + 1))
                            ,''));
      end loop;
      SRES := STMP;
    exception
      when others then
        SRES := SERR;
    end;
    return SRES;
  end;

  --конвертирование строковых значений в числовые для целей WEB-представления
  function CONVERT_TO_NUMBER
  (
    SSTR   varchar2 --конвертируемая строка (разрядность 17.5, допускается передавать пробелы в качестве разделителя групп разрядов (но не другие символы!), допускается передавать в качестве разделителя целой и дробной части "." или ",", отрицательные обрабатываются корректно с минусом спереди, автоматически удаляются некоторые спец-символы)
   ,NSMART number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return number is
    STMP PKG_STD.TLSTRING; --буфер для конвертации
    NTMP number; --буфер для конвертации
  begin
    --конвертируем
    begin
      if (SSTR is not null)
      then
        STMP := REGEXP_REPLACE(SSTR
                              ,'[ #&$%!@\(\)]');
        STMP := replace(STMP
                       ,','
                       ,'.');
        NTMP := TO_NUMBER(STMP
                         ,'99999999999999999D99999'
                         ,'NLS_NUMERIC_CHARACTERS = ''. ''');
      end if;
    exception
      when others then
        P_EXCEPTION(NSMART
                   ,'Переданное значение - "' || SSTR ||
                    '", не является числом!');
    end;
    return NTMP;
  end;

  --конвертирование числовых значений в строковые для целей WEB-представления
  function CONVERT_TO_STRING
  (
    NNUMB     number --конвертируемое число
   ,NSEPARATE number := 0 --разделять разряды (0 - нет, 1 - да)
   ,NSHARP    number := 2 --точность (кол-во знаков после запятой, только для NSEPARATE = 1)
  ) return varchar2 is
    SPATTERN varchar2(200); --шаблон для конвертации с разделителями
  begin
    --простой перевод в строку, без разделителей
    if (NSEPARATE = 0)
    then
      return replace(TO_CHAR(NNUMB)
                    ,','
                    ,'.');
    else
      --перевод с разделителями, с указанной точностью
      if ((NSHARP is null) or (NSHARP <= 0))
      then
        SPATTERN := '999G999G999G999G999G990';
      else
        SPATTERN := '999G999G999G999G999G990D' ||
                    RPAD('9'
                        ,TRUNC(NSHARP)
                        ,'9');
      end if;
      return trim(TO_CHAR(NNUMB
                         ,SPATTERN
                         ,'nls_numeric_characters=''. '''));
    end if;
  end;

  --конвертация строки в дату для целей WEB-представления
  function CONVERT_TO_DATE
  (
    NSMART   in number --признак выдачи сообщения об ошибке
   ,SDATE    in varchar2 --дата (строковое представление)
   ,SERR_MSG in varchar2 := null --сообщение об ошибке конвертации
  ) return date is
    DRESULT date; --результат работы
  begin
    --конвертируем в зависимости от возможных разделителей
    begin
      if SUBSTR(SDATE
               ,5
               ,1) = '-'
      then
        DRESULT := TO_DATE(SDATE
                          ,'yyyy-mm-dd');
      elsif SUBSTR(SDATE
                  ,3
                  ,1) = '.'
      then
        DRESULT := TO_DATE(SDATE
                          ,'dd.mm.yyyy');
      else
        DRESULT := TO_DATE(SDATE
                          ,'dd/mm/yyyy');
      end if;
    exception
      when others then
        --выдаем ошибку
        P_EXCEPTION(NSMART
                   ,NVL(SERR_MSG
                       ,'Дата задана некорректно.') ||
                    ' Укажите дату в формате "ДД.ММ.ГГГГ"!');
    end;
    return DRESULT;
  end;

  --экранирование строки для HTML выдачи
  function STR_ESCAPE(SSTR varchar2 --экранируемая строка
                      ) return varchar2 is
  begin
    return HTF.ESCAPE_SC(SSTR);
  end;

  --экранирование строковых элементов JSON-объекта
  procedure JSON_ESCAPE
  (
    SFIELDS varchar2 --список полей объекта для экранирования (должны быть строками, разделитель списка ;)
   ,OBJ     in out JSON --экранируемый объект
  ) is
  begin
    if (SFIELDS is null)
    then
      return;
    end if;
    --идем по элементам имени
    for I in (select ROWNUM
                    ,REGEXP_SUBSTR(T.STR
                                  ,'[^' || SDELIM_LISTS || ']+'
                                  ,1
                                  ,level) SITEM
                from (select RTRIM(SFIELDS
                                  ,SDELIM_LISTS) STR
                        from DUAL) T
              connect by INSTR(T.STR
                              ,SDELIM_LISTS
                              ,1
                              ,level - 1) > 0)
    loop
      --экранируем элемент объекта
      if ((OBJ.EXIST(I.SITEM)) and (OBJ.GET(I.SITEM).IS_STRING))
      then
        OBJ.PUT(PAIR_NAME  => I.SITEM
               ,PAIR_VALUE => STR_ESCAPE(SSTR => OBJ.GET(I.SITEM).GET_STRING));
      end if;
    end loop;
  end;

  --формирование начала таблицы
  function START_TABLE
  (
    STABLE_CLASS varchar2 --CSS-класс для таблицы
   ,SATTRS       varchar2 := null --дополнительные атрибуты
  ) return varchar2 is
    SCLASS varchar2(2000) := ''; --буфер для интерпретации CSS-класса
  begin
    --интерпретируем CSS-класс
    if (STABLE_CLASS is not null)
    then
      SCLASS := 'class="' || STABLE_CLASS || '"';
    end if;
    --вернем результат
    return '<table ' || SCLASS || ' ' || SATTRS || '>';
  end;

  --формирование окончания таблицы
  function FINISH_TABLE return varchar2 is
  begin
    return '</table>';
  end;

  --формирование начала строки таблицы
  function START_ROW
  (
    STR_CLASS varchar2 --CSS-класс для строки данных таблицы
   ,SATTRS    varchar2 := null --дополнительные атрибуты
  ) return varchar2 is
    SCLASS varchar2(2000) := ''; --буфер для интерпретации CSS-класса
  begin
    --интерпретируем CSS-класс
    if (STR_CLASS is not null)
    then
      SCLASS := 'class="' || STR_CLASS || '"';
    end if;
    --вернем результат
    return '<tr ' || SCLASS || ' ' || SATTRS || '>';
  end;

  --формирование окончания строки таблицы
  function FINISH_ROW return varchar2 is
  begin
    return '</tr>';
  end;

  --формирование ячейки для заголовка таблицы
  function FORMAT_TH_CELL
  (
    SHDR        varchar2 --текст заголовка
   ,STH_CLASS   varchar2 --CSS-класс для ячейки заголовка таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2 is
    SNOWRAP    varchar2(20) := ''; --признак непереноса по словам
    SBGCOLOR   varchar2(40) := ''; --цвет заливки
    SFONTSTYLE varchar2(200) := ''; --стиль шрифта при выдаче
    SCLASS     varchar2(2000) := ''; --буфер для интерпретации CSS-класса
    SCOLSPAN   varchar2(200) := ''; --кол-во объединяемых вертикальных ячеек
    SROWSPAN   varchar2(200) := ''; --кол-во объединяемых горизонтальных ячеек
  begin
    --выставим возможность переносов
    if (NNOWRAP = 1)
    then
      SNOWRAP := 'nowrap';
    end if;
    --выставим цвет заливки
    if (SBG_COLOR is not null)
    then
      SBGCOLOR := 'background-color:' || SBG_COLOR || ';';
    end if;
    --выставим стиль шрифта для выдачи
    if (SFONT_STYLE is not null)
    then
      SFONTSTYLE := 'font-weight:' || SFONT_STYLE || ';';
    end if;
    --интерпретируем объединиение ячеек
    if (NCOLSPAN is not null)
    then
      SCOLSPAN := 'colspan ="' || TO_CHAR(NCOLSPAN) || '"';
    end if;
    if (NROWSPAN is not null)
    then
      SROWSPAN := 'rowspan ="' || TO_CHAR(NROWSPAN) || '"';
    end if;
    --интерпретируем CSS-класс
    if (STH_CLASS is not null)
    then
      SCLASS := 'class="' || STH_CLASS || '"';
    end if;
    --сформируем HTML для ячейки таблицы и вернем результат
    return '<th ' || SNOWRAP || ' ' || SCLASS || ' ' || SCOLSPAN || ' ' || SROWSPAN || ' style="text-align: ' || NVL(SALIGN
                                                                                                                    ,'left') || ';' || SBGCOLOR || SFONTSTYLE || '" ' || SATTRS || '>' || SHDR || '</th>';
  end;

  --формирование ячейки для строковых данных
  function FORMAT_STR_CELL
  (
    SSTR        varchar2 --строка
   ,STD_CLASS   varchar2 --CSS-класс для ячейки данных таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2 is
    SNOWRAP    varchar2(20) := ''; --признак непереноса по словам
    SBGCOLOR   varchar2(40) := ''; --цвет заливки
    SFONTSTYLE varchar2(200) := ''; --стиль шрифта при выдаче
    SCLASS     varchar2(2000) := ''; --буфер для интерпретации CSS-класса
    SCOLSPAN   varchar2(200) := ''; --кол-во объединяемых вертикальных ячеек
    SROWSPAN   varchar2(200) := ''; --кол-во объединяемых горизонтальных ячеек
  begin
    --выставим возможность переносов
    if (NNOWRAP = 1)
    then
      SNOWRAP := 'nowrap';
    end if;
    --выставим цвет заливки
    if (SBG_COLOR is not null)
    then
      SBGCOLOR := 'background-color:' || SBG_COLOR || ';';
    end if;
    --выставим стиль шрифта для выдачи
    if (SFONT_STYLE is not null)
    then
      SFONTSTYLE := 'font-weight:' || SFONT_STYLE || ';';
    end if;
    --интерпретируем объединиение ячеек
    if (NCOLSPAN is not null)
    then
      SCOLSPAN := 'colspan ="' || TO_CHAR(NCOLSPAN) || '"';
    end if;
    if (NROWSPAN is not null)
    then
      SROWSPAN := 'rowspan ="' || TO_CHAR(NROWSPAN) || '"';
    end if;
    --интерпретируем CSS-класс
    if (STD_CLASS is not null)
    then
      SCLASS := 'class="' || STD_CLASS || '"';
    end if;
    --сформируем HTML для ячейки таблицы и вернем результат
    return '<td ' || SNOWRAP || ' ' || SCLASS || ' ' || SCOLSPAN || ' ' || SROWSPAN || ' style="text-align: ' || NVL(SALIGN
                                                                                                                    ,'left') || ';' || SBGCOLOR || SFONTSTYLE || '" ' || SATTRS || '>' || SSTR || '</td>';
  end;

  --формирование ячейки для числовых данных
  function FORMAT_NUMB_CELL
  (
    NNUMB       number --число
   ,STD_CLASS   varchar2 --CSS-класс для ячейки данных таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,NSHARP      number := 2 --точность (количество знаков после запятой)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2 is
    SNOWRAP    varchar2(20) := ''; --признак непереноса по словам
    SBGCOLOR   varchar2(40) := ''; --цвет заливки
    SCOLOR     varchar2(200); --цвет числа при выдаче
    SFONTSTYLE varchar2(200) := ''; --стиль шрифта при выдаче
    SCLASS     varchar2(2000) := ''; --буфер для интерпретации CSS-класса
    SCOLSPAN   varchar2(200) := ''; --кол-во объединяемых вертикальных ячеек
    SROWSPAN   varchar2(200) := ''; --кол-во объединяемых горизонтальных ячеек
    STMP       varchar2(4000); --буфер для расчетов
  begin
    --выставим возможность переносов
    if (NNOWRAP = 1)
    then
      SNOWRAP := 'nowrap';
    end if;
    --выставим цвет заливки
    if (SBG_COLOR is not null)
    then
      SBGCOLOR := 'background-color:' || SBG_COLOR || ';';
    end if;
    --выставим цвет
    if (NNUMB is not null)
    then
      if (NNUMB > 0)
      then
        SCOLOR := 'color:blue;';
      else
        if (NNUMB < 0)
        then
          SCOLOR := 'color:red;';
        else
          SCOLOR := 'color:green;';
        end if;
      end if;
      STMP := '<nobr>' || CONVERT_TO_STRING(NNUMB     => NNUMB
                                           ,NSEPARATE => 1
                                           ,NSHARP    => NSHARP) || '</nobr>';
    else
      SCOLOR := '';
      STMP   := '-';
    end if;
    --выставим стиль шрифта для выдачи
    if (SFONT_STYLE is not null)
    then
      SFONTSTYLE := 'font-weight:' || SFONT_STYLE || ';';
    end if;
    --интерпретируем объединиение ячеек
    if (NCOLSPAN is not null)
    then
      SCOLSPAN := 'colspan ="' || TO_CHAR(NCOLSPAN) || '"';
    end if;
    if (NROWSPAN is not null)
    then
      SROWSPAN := 'rowspan ="' || TO_CHAR(NROWSPAN) || '"';
    end if;
    --интерпретируем CSS-класс
    if (STD_CLASS is not null)
    then
      SCLASS := 'class="' || STD_CLASS || '"';
    end if;
    --сформируем HTML для ячейки таблицы и вернем результат
    return '<td ' || SNOWRAP || ' ' || SCLASS || ' ' || SCOLSPAN || ' ' || SROWSPAN || ' style="text-align: ' || NVL(SALIGN
                                                                                                                    ,'right') || '; ' || SCOLOR || SBGCOLOR || SFONTSTYLE || '" ' || SATTRS || '>' || STMP || '</td>';
  end;

  --формирование ячейки для даты
  function FORMAT_DATE_CELL
  (
    DDATE       date --дата
   ,STD_CLASS   varchar2 --CSS-класс для ячейки данных таблицы
   ,SALIGN      varchar2 := null --выравнивание (left, rigth, center)
   ,SBG_COLOR   varchar2 := null --цвет заливки
   ,NNOWRAP     number := 0 --возможность переноса (0 - да, 1 - нет)
   ,SFONT_STYLE varchar2 := null --стиль шрифта (bold, bolder, lighter, normal, 100, 200, 300, 400, 500, 600, 700, 800 ,900)
   ,NCOLSPAN    number := null --кол-во объединяемых вертикальных ячеек
   ,NROWSPAN    number := null --кол-во объединяемых горизонтальных ячеек
   ,SATTRS      varchar2 := null --дополнительные атрибуты
  ) return varchar2 is
    SNOWRAP    varchar2(20) := ''; --признак непереноса по словам
    SBGCOLOR   varchar2(40) := ''; --цвет заливки
    SFONTSTYLE varchar2(200) := ''; --стиль шрифта при выдаче
    SCLASS     varchar2(2000) := ''; --буфер для интерпретации CSS-класса
    SCOLSPAN   varchar2(200) := ''; --кол-во объединяемых вертикальных ячеек
    SROWSPAN   varchar2(200) := ''; --кол-во объединяемых горизонтальных ячеек
    STMP       varchar2(15); --буфер для расчетов
  begin
    --выставим возможность переносов
    if (NNOWRAP = 1)
    then
      SNOWRAP := 'nowrap';
    end if;
    --выставим цвет заливки
    if (SBG_COLOR is not null)
    then
      SBGCOLOR := 'background-color:' || SBG_COLOR || ';';
    end if;
    --конвертируем дату
    if (DDATE is not null)
    then
      STMP := TO_CHAR(DDATE
                     ,'dd.mm.yyyy');
    else
      STMP := '';
    end if;
    --выставим стиль шрифта для выдачи
    if (SFONT_STYLE is not null)
    then
      SFONTSTYLE := 'font-weight:' || SFONT_STYLE || ';';
    end if;
    --интерпретируем объединиение ячеек
    if (NCOLSPAN is not null)
    then
      SCOLSPAN := 'colspan ="' || TO_CHAR(NCOLSPAN) || '"';
    end if;
    if (NROWSPAN is not null)
    then
      SROWSPAN := 'rowspan ="' || TO_CHAR(NROWSPAN) || '"';
    end if;
    --интерпретируем CSS-класс
    if (STD_CLASS is not null)
    then
      SCLASS := 'class="' || STD_CLASS || '"';
    end if;
    --сформируем HTML для ячейки таблицы и вернем результат
    return '<td ' || SNOWRAP || ' ' || SCLASS || ' ' || SCOLSPAN || ' ' || SROWSPAN || '  style ="text-align: ' || NVL(SALIGN
                                                                                                                      ,'center') || ';' || SBGCOLOR || SFONTSTYLE || '" ' || SATTRS || '>' || STMP || '</td>';
  end;

  --считывание расширения файла
  function GET_FILE_EXT(SFILE_NAME varchar2 --имя файла
                        ) return varchar2 is
  begin
    if (INSTR(SFILE_NAME
             ,'.'
             ,-1) > 0)
    then
      return SUBSTR(SFILE_NAME
                   ,INSTR(SFILE_NAME
                         ,'.'
                         ,-1) + 1);
    else
      return null;
    end if;
  exception
    when others then
      return null;
  end;

  --формирование MIME-type описателя по имени файла
  function GET_MIME_TYPE(SFILE_NAME varchar2 --имя файла
                         ) return varchar2 is
    SRES varchar2(4000) := 'application/octet-stream'; --MIME-type по-умолчанию
  begin
    case LOWER(GET_FILE_EXT(SFILE_NAME => SFILE_NAME))
      when 'doc' then
        SRES := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      when 'docx' then
        SRES := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      when 'xls' then
        SRES := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      when 'xlsx' then
        SRES := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      when 'pdf' then
        SRES := 'application/pdf';
      when 'png' then
        SRES := 'image/png';
      else
        null;
    end case;
    --вернем результат
    return SRES;
  end;

  --скачивание файла
  procedure DOWNLOAD_FILE
  (
    NFILE in number --рег. номер документа/процесса
   ,SUSER in varchar --имя пользователя
   ,NSRC  in number --источник (0 - общесистемный файловый буфер, 1 - очередь печати отчетов, 2 - картинка предпросмотра отчета)
  ) as
    SMIME            varchar2(2000) := 'application/octet-stream'; --mime-описатель типа выгружаемого файла (по умолчанию "application/octet-stream")
    SFILE_NAME       varchar2(4000); --имя выгружаемого файла
    CBUFF            clob; --буфер для текстовых данных источника
    BBUFF            blob; --буфер для двоичных данных источника
    BDOWNLOAD_BUFFER blob; --буфер для выгрузки
    NLENGTH          number(17); --размер буфера для выгрузки
    --преобразование имени файла для использования в HTML-заголовке
    function PREPARE_FILENAME(SFILE_NAME varchar2 --имя файла
                              ) return varchar2 is
    begin
      return UTL_URL.ESCAPE(replace(replace(SUBSTR(SFILE_NAME
                                                  ,INSTR(SFILE_NAME
                                                        ,'/') + 1)
                                           ,CHR(10)
                                           ,null)
                                   ,CHR(13)
                                   ,null)
                           ,false
                           ,'UTF8');
    end;

    --конфертация CLOB в BLOB
    function CLOB_TO_BLOB(CDATA clob --преобразуемые данные
                          ) return blob is
      BDATA         blob; --буфер для конвертации
      NWARNING      number; --буфер для предупреждений конвертера
      DEST_OFFSET   number := 1; --смещение буфера назначения при конвертации
      SRC_OFFSET    number := 1; --смещение буфера источника при конвертации
      NLANG_CONTEXT number := DBMS_LOB.DEFAULT_LANG_CTX; --региональный контекст при конвертации
    begin
      if (CDATA is not null)
      then
        DBMS_LOB.CREATETEMPORARY(LOB_LOC => BDATA
                                ,CACHE   => false);
        DBMS_LOB.CONVERTTOBLOB(DEST_LOB     => BDATA
                              ,SRC_CLOB     => CDATA
                              ,AMOUNT       => DBMS_LOB.GETLENGTH(LOB_LOC => CDATA)
                              ,DEST_OFFSET  => DEST_OFFSET
                              ,SRC_OFFSET   => SRC_OFFSET
                              ,BLOB_CSID    => DBMS_LOB.DEFAULT_CSID
                              ,LANG_CONTEXT => NLANG_CONTEXT
                              ,WARNING      => NWARNING);
        return BDATA;
      else
        return null;
      end if;
    exception
      when others then
        return null;
    end;

  begin
    --инициализируем буферы выгрузки
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => BDOWNLOAD_BUFFER
                            ,CACHE   => false);
    --считаем данные из источника
    case NSRC
    --общесистемный файловый буфер
      when 0 then
        --считаем запись
        begin
          select T.DATA
                ,T.BDATA
                ,T.FILENAME
            into CBUFF
                ,BBUFF
                ,SFILE_NAME
            from FILE_BUFFER T
           where T.RN = NFILE
             and T.AUTHID = SUSER;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0
                       ,'Запись файлового буфера (RN: ' || NFILE ||
                        ', AUTHID: "' || SUSER || '") не определена!');
        end;
        --определим MIME-тип для файла
        SMIME := GET_MIME_TYPE(SFILE_NAME => SFILE_NAME);
        --определим, что будем выгружать - если нет бинарных данных, то берем тектовый буфер
        if (BBUFF is null)
        then
          BDOWNLOAD_BUFFER := CLOB_TO_BLOB(CDATA => CBUFF);
        else
          --данные в бинарном буфере есть - забираем их
          BDOWNLOAD_BUFFER := BBUFF;
        end if;
        --очередь печати отчетов
      when 1 then
        --считаем данные из очереди
        begin
          select NVL(R.REPORT_PDF
                    ,R.REPORT)
                ,UDO_PKG_URPT_SRV.UTL_REPORTQ_BUILD_FILE_NAME(NREPORTQ => R.PRN)
            into BBUFF
                ,SFILE_NAME
            from RPTPRTQUEUE_RPT R
           where R.RN = NFILE;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0
                       ,'Запись готового отчета очереди печати (RN: ' || NFILE ||
                        ') не определена!');
        end;
        --определим MIME-тип для файла
        SMIME := GET_MIME_TYPE(SFILE_NAME => SFILE_NAME);
        --зафиксируем, что будем выгружать
        BDOWNLOAD_BUFFER := BBUFF;
        --картинка предпросмотра отчета
      when 2 then
        --считаем данные из параметров настройки отчета
        begin
          select T.PICT
                ,UDO_PKG_URPT_SRV.UTL_REPORT_BUILD_PW_FILE_NAME(NRN => T.RN)
            into BBUFF
                ,SFILE_NAME
            from UDO_T_URPT_SRV_RPTPICT T
           where T.RN = NFILE;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0
                       ,'Запись изображения предварительного просмотра отчета (RN: ' ||
                        NFILE || ') не определена!');
        end;
        --определим MIME-тип для файла
        SMIME := GET_MIME_TYPE(SFILE_NAME => SFILE_NAME);
        --зафиксируем, что будем выгружать
        BDOWNLOAD_BUFFER := BBUFF;
        --такой источник не поддерживается
      else
        P_EXCEPTION(0
                   ,'Тип источника "' || NSRC || '" не поддерживается!');
    end case;
    --убедимся, что указано имя выгружаемого файла
    if (SFILE_NAME is null)
    then
      P_EXCEPTION(0
                 ,'Не указано имя выгружаемого файла!');
    end if;
    --убедимся, что в файле есть хоть что-то
    if (BDOWNLOAD_BUFFER is null)
    then
      P_EXCEPTION(0
                 ,'Нет данных для выгрузки!');
    end if;
    --определим размер выгружаемого файла
    NLENGTH := LENGTH(BDOWNLOAD_BUFFER);
    --открываем заголовок HTTP
    OWA_UTIL.MIME_HEADER(CCONTENT_TYPE => SMIME
                        ,BCLOSE_HEADER => false);
    --указываем размер скачиваемого файла и его имя
    HTP.P('Content-length: ' || NLENGTH);
    HTP.P('Content-Disposition:  attachment; filename="' ||
          PREPARE_FILENAME(SFILE_NAME => SFILE_NAME) || '"');
    --закрываем заголовок
    OWA_UTIL.HTTP_HEADER_CLOSE;
    --загрузка из BLOB
    WPG_DOCLOAD.DOWNLOAD_FILE(BDOWNLOAD_BUFFER);
  end;

end;
/

