create or replace procedure UDO_P_LOAD_MASSFILES_IMXPS
(
  NCOMPANY           in number,                           -- Рег. номер организации
  SPATTERN_DIR       in varchar2 default null/*'C:\tmp\LOAD'*/,       -- Каталог размещения файлов для загрузки
  SPATTERN_DIR_ERR   in varchar2 default null/*'C:\tmp\LOAD_ERROR'*/, -- Каталог для фалов с ошибками при загрузке
  --SPATTERN_DIR_OK    in varchar2 default null/*'C:\tmp\LOAD_OK'*/,    -- Каталог для фалов с удачной загрузкой
  SPATTERN_FORMAT    in varchar2 default null/*'KZ'*/                 -- Формат загузки фалов
)
is
  NBUFFER_SIZE              constant PKG_STD.TNUMBER := 32767;                                               -- Размер буфера данных для загрузки ответа
  SSERVER                   constant PKG_STD.TSTRING := 'http://10.7.19.35:8080/ReadFiles/fileRead?';        -- Адрес тнстового сервиса для разбора PDF и поиска страниц в нём
  SSERVER_PROD              constant PKG_STD.TSTRING := 'http://10.21.136.209:8080/ReadFiles/fileRead?';   -- Адрес рабочего сервиса для разбора PDF и поиска страниц в нём
  /*SPATTERN_DIR              constant PKG_STD.TSTRING := 'C:\tmp\LOAD';
  SPATTERN_DIR_ERR          constant PKG_STD.TSTRING := 'C:\tmp\LOAD_ERROR';
  SPATTERN_DIR_OK           constant PKG_STD.TSTRING := 'C:\tmp\LOAD_OK';
  SPATTERN_FORMAT           constant PKG_STD.TSTRING := 'KZ';*/


  SPATTERN_QUERY_DIR        constant PKG_STD.TSTRING := '%DIR%';          -- Шаблон для имени файла в запросе к серверу
  SPATTERN_QUERY_DIR_ERR    constant PKG_STD.TSTRING := '%DIR_ERROR%';    -- Шаблон для имени файла в запросе к серверу
  SPATTERN_QUERY_DIR_OK     constant PKG_STD.TSTRING := '%DIR_OK%';       -- Шаблон для имени файла в запросе к серверу
  SPATTERN_QUERY_FORMAT     constant PKG_STD.TSTRING := '%FORMAT%';       -- Шаблон для имени файла в запросе к серверу
  SPATTERN_QUERY_USER       constant PKG_STD.TSTRING := '%USER%';
  SPATTERN_QUERY_OS_USER       constant PKG_STD.TSTRING := '%OS_USER%';
  SPATTERN_QUERY_FIND       constant PKG_STD.TSTRING := 'SDIR=' || SPATTERN_QUERY_DIR
                                                       || '=' || SPATTERN_QUERY_DIR_ERR
                                                       ||'='||SPATTERN_QUERY_DIR_OK
                                                       ||'='||SPATTERN_QUERY_FORMAT
                                                       ||'='||SPATTERN_QUERY_USER
                                                       ||'='||SPATTERN_QUERY_OS_USER;      -- Шаблон имени файла с данными банковской выписки
  HTTP_REQ                  UTL_HTTP.REQ;             -- HTTP-запрос
  HTTP_RESP                 UTL_HTTP.RESP;            -- HTTP-ответ
  SURL                      PKG_STD.TLSTRING;         -- URL для запроса
  BBUFFER                   raw(32767);               -- Буфер для порции данных ответа
  BRESP                     blob;                     -- Полный ответ
  SMSG                      PKG_STD.TSTRING;          -- Сообщение о статусе обработки текущего доумента
  NIDENT                    PKG_STD.tSTRING;          -- Идентификатор отмеченных записей
  sOS_USER                  PKG_STD.tSTRING;
  NEXSQUEUE                 PKG_STD.tREF;
  OPTS                      PKG_EXS.TOPTIONS;
  HDR_HEADERS               PKG_EXS.TOPTIONS;

begin
  sOS_USER := SYS_CONTEXT( 'userenv', 'OS_USER' );
  /*if UPPER(sOS_USER) = 'СИСТЕМА' then
     sOS_USER := 'SYSTEM';
  end if;*/
  case
    when SPATTERN_DIR is null then
      p_exception(0,'Не задан "Каталог размещения файлов для загрузки".');
    when SPATTERN_DIR_ERR is null then
      p_exception(0,'Не задан "Каталог для файлов с ошибками при загрузке".');
    /*when SPATTERN_DIR_OK is null then
      p_exception(0,'Не задан "Каталог для файлов с удачной загрузкой".');*/
    when SPATTERN_FORMAT is null then
      p_exception(0,'Не задан Формат загрузки файлов!');
    else null;
  end case;
   begin
      /* Формирование дополнительных параметров отправки */
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'SDIR',
                        SVALUE  => SPATTERN_DIR);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'SDIR_ERR',
                        SVALUE  => SPATTERN_DIR_ERR);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'SDIR_OK',
                        SVALUE  => null);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'SFORMAT',
                        SVALUE  => SPATTERN_FORMAT);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'USER',
                        SVALUE  => user);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'OS_USER',
                        SVALUE  => sOS_USER);
    PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                        SCODE   => 'NLNK_COMPANY',
                        SVALUE  => NCOMPANY);

    /* Кладем сообщение в очередь */
    PKG_EXS.QUEUE_PUT(SEXSSERVICE   => 'SendLoadFile',
                      SEXSSERVICEFN => 'fileReadImxProdSpec',
                      BMSG          => null,
                      NLNK_COMPANY  => NCOMPANY,
                      SOPTIONS      => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => OPTS),
                      NNEW_EXSQUEUE => NEXSQUEUE);
   end;


/*  begin
      \* Сформируем адрес для запроса *\
      SURL := \*SSERVER*\SSERVER_PROD ||UTL_URL.ESCAPE(replace(replace(replace(replace(replace(replace(SPATTERN_QUERY_FIND,
                                             SPATTERN_QUERY_DIR,
                                             SPATTERN_DIR),SPATTERN_QUERY_DIR_ERR,SPATTERN_DIR_ERR),SPATTERN_QUERY_DIR_OK,SPATTERN_DIR_OK),SPATTERN_QUERY_FORMAT,SPATTERN_FORMAT),
                                             SPATTERN_QUERY_USER,user), SPATTERN_QUERY_OS_USER,sOS_USER),
                             false,
                             PKG_CHARSET.CHARSET_UTF_);
      \* Выполняем запрос *\
      HTTP_REQ  := UTL_HTTP.BEGIN_REQUEST(URL => SURL, METHOD => 'POST');
      HTTP_RESP := UTL_HTTP.GET_RESPONSE(R => HTTP_REQ);
      \* Создаем буфер для ответа *\
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => BRESP, CACHE => false);
      DBMS_LOB.OPEN(LOB_LOC => BRESP, OPEN_MODE => DBMS_LOB.LOB_READWRITE);
      \* Читаем данные ответа *\
      begin
        loop
          UTL_HTTP.READ_RAW(R    => HTTP_RESP,
                            DATA => BBUFFER,
                            LEN  => NBUFFER_SIZE);
          DBMS_LOB.WRITEAPPEND(LOB_LOC => BRESP,
                               AMOUNT  => UTL_RAW.LENGTH(BBUFFER),
                               BUFFER  => BBUFFER);
        end loop;
      exception
        when others then
          if (sqlcode <> -29266) then
            raise;
          end if;
      end;
      \* Если ответ сервера с ошибкой *\
      if (HTTP_RESP.STATUS_CODE <> 200) then
        \* Вернём её *\
        if (DBMS_LOB.GETLENGTH(BRESP) <> 0) then
          SMSG := BLOB2CLOB(BRESP, PKG_CHARSET.CHARSET_UTF_);
        else
          SMSG := 'Ошибка выполнения запроса к серверу: ' ||
                  HTTP_RESP.REASON_PHRASE;
        end if;
      else
        \* Если данных в ответе нет *\
        if (DBMS_LOB.GETLENGTH(BRESP) = 0) then
          \* Скажем про это *\
          SMSG := 'Данных не найдено';
        else
          nIDENT := BLOB2CLOB(BRESP, PKG_CHARSET.CHARSET_UTF_);
        end if;
       end if;
        UTL_HTTP.END_RESPONSE(R => HTTP_RESP);
        DBMS_LOB.FREETEMPORARY(LOB_LOC => BRESP);
    exception
      when others then
        SMSG := 'Ошибка получения данных: ' || sqlerrm;
        if (HTTP_RESP.PRIVATE_HNDL is not null) then
          UTL_HTTP.END_RESPONSE(R => HTTP_RESP);
        end if;
        if (DBMS_LOB.ISTEMPORARY(LOB_LOC => BRESP) = 1) then
          DBMS_LOB.FREETEMPORARY(LOB_LOC => BRESP);
        end if;
    end;*/

end UDO_P_LOAD_MASSFILES_IMXPS;
-- grant execute on UDO_P_LOAD_MASSFILES_IMXPS to public;
/

