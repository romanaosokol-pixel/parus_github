create or replace package UDO_PKG_SYSW0006_URPT_PUBLISH as

  /*
   Публикация пользовательских отчетов в WEB-интерфейсе
  */
  --константы - поддерживаемая версия сервиса печати
  SEXPECTED_SERVICE_VERS_DEFAULT varchar2(20) := '1.0';

  --константы - тип интерфейса
  NINTERFACE_DESKTOP number(1) := 0; --настольный браузер
  NINTERFACE_MOBILE  number(1) := 1; --мобильный браузер
  --констатны - переменные окружения сессии
  SSESSION_PRINT_SESSION varchar2(40) := 'PRINT_SESSION'; --сессия подключения к сервису отложенной печати
  SSESSION_VAL_SL_IDENT  varchar2(40) := 'SL_IDENT'; --идентификатор отмеченных записей
  SSESSION_VAL_DOC_RN    varchar2(40) := 'DOC_RN'; --рег. номер текущего документа
  SSESSION_VAL_UNITCODE  varchar2(40) := 'UNITCODE'; --код текущего раздела
  --разделитель списков по-умолчанию
  SDELIM_DEF char(1) := ';';

  --проверка - является ли пользователь администратором
  function UTL_CHECK_IS_ADMIN
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
  ) return boolean;

  --считавание системной настройки - разделитель списков
  function UTL_GET_SEQSYMB
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
  ) return varchar2;

  --считавание состояния активности сервиса
  function UTL_CHECK_SERVICE_ACTIVE return boolean;

  --сохранение группы параметров отчета
  procedure UTL_PRMS_PUT
  (
    SUSER varchar2 --пользователь
   ,CPRMS clob --набор параметров в JSON ({[{NPRM:<РЕГ_НОМЕР_ПАРАМЕТРА>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА>}]})
  );

  --сохранение выбранного параметра отчета
  procedure UTL_PRM_PUT
  (
    SUSER varchar2 --пользователь
   ,NPRM  number --рег. номер параметра отчета
   ,SVAL  varchar2 --значение параметра отчета
  );

  --считывание выбранного параметра отчета
  function UTL_PRM_GET
  (
    SUSER varchar2 --пользователь
   ,NPRM  number --рег. номер параметра отчета
  ) return varchar2;

  --проверка наличия сохраненного значения параметра (0 - нет, 1 - да)
  function UTL_PRM_SAVED
  (
    SUSER varchar2 --пользователь
   ,NPRM  number --рег. номер параметра отчета
  ) return number;

  --зачистка выбранных параметров отчета
  procedure UTL_PRM_CLEAR(SUSER varchar2 --пользователь
                          );

  --подключение к сервису отложенной печати
  procedure UTL_PRINT_SERVICE_CONNECT
  (
    SUSER                     varchar2 --пользователь
   ,SPASSWORD                 varchar2 --пароль
   ,NCOMPANY                  number --рег. номер организации
   ,SSESSION_CLIENT           varchar2 := null --идентификатор сессии сформированный клиентом
   ,SEXPECTED_SERVICE_VERSION varchar2 := SEXPECTED_SERVICE_VERS_DEFAULT --ожидаемая клиентом версия сервиса
   ,SSESSION                  out varchar2 --идентификатор сессии
  );

  --отключение от сервиса отложенной печати
  procedure UTL_PRINT_SERVICE_DISCONNECT(SSESSION varchar2 := null --идентификатор сессии
                                         );

  --проверка сессии сервиса отложенной печати
  procedure UTL_PRINT_SERVICE_VERIFY(SSESSION varchar2 := null --идентификатор сессии
                                     );

  --считывание признака опубликованности отчета (0 - опубликован, 1 - не опубликован)
  function CONF_REPORT_IS_PUBLISHED(NRN number --рег. номер отчета
                                    ) return number;

  --считывание описания для публикации отчета
  function CONF_REPORT_GET_PUBL_DESC(NRN number --рег. номер отчета
                                     ) return varchar2;

  --считывание описания для публикации отчета (возврат ответа WEB-серверу)
  procedure CONF_REPORT_GET_PUBL_DESC(NRN number --рег. номер отчета
                                      );

  --считывание картинки предварительного просмотра по  регистрационному номеру
  function CONF_REPORT_GET_PICT(NRN number --рег. номер картинки
                                ) return varchar2;

  --формирование списка отчетов, подлежащих публикации
  procedure CONF_REPORT_GET_REPORTS_LIST(CPRMS clob --JSON-параметры запроса ({NCOMPANY:123,SUSER:"abc",SSEARCH:"abc",NPORTION:123,NPORTION_SIZE:123})
                                         );

  --добавление нового отчета к публикации
  procedure CONF_REPORT_ADD_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,SREPORT  varchar2 --мнемокод отчета
   ,SDESC    varchar2 --публикуемое описание отчета
  );

  --установка публикуемого описания отчета
  procedure CONF_REPORT_SET_DESC
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,SDESC    varchar2 --публикуемое описание отчета
  );

  --полное удаление параметров публикации отчета
  procedure CONF_REPORT_REMOVE_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  );

  --переключение признака публикации отчета
  procedure CONF_REPORT_TOGGLE_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  );

  --добавление картинки предварительного просмотра к отчету
  procedure CONF_REPORT_ADD_PICT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,SPICT    varchar2 --наименование картинки в буфере
  );

  --удаление картинки предварительного просмотра отчета
  procedure CONF_REPORT_REMOVE_PICT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер картинки
  );

  --удаление позиции расписания отчета
  procedure CONF_REPORT_REMOVE_SCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер расписания
  );

  --считывание признака игнорирования описания при поиске
  function CONF_CLASS_IS_NO_DESC_SEARCH(NRN number --рег. номер класса
                                        ) return number;

  --считывание атрибута кода класса
  function CONF_CLASS_GET_CODE_ATTR(NRN number --рег. номер класса
                                    ) return varchar2;

  --считывание атрибута наименования класса
  function CONF_CLASS_GET_DESC_ATTR(NRN number --рег. номер класса
                                    ) return varchar2;

  --считывание атрибутов для публикации класса (возврат ответа WEB-серверу)
  procedure CONF_CLASS_GET_PUBL_ATTRS(NRN number --рег. номер класса
                                      );

  --формирование списка классов, подлежащих публикации
  procedure CONF_CLASS_GET_CLASSES_LIST(CPRMS clob --JSON-параметры запроса ({SUSER:"abc",SSEARCH:"abc",NPORTION:123,NPORTION_SIZE:123})
                                        );

  --формирование списка атрибутов класса, подлежащих публикации
  procedure CONF_CLASS_GET_CLASSATTRS_LIST(CPRMS clob --JSON-параметры запроса ({NCLASS:123,SSEARCH:"abc",NPORTION:123,NPORTION_SIZE:123})
                                           );

  --добавление нового раздела к публикации
  procedure CONF_CLASS_ADD_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,SCLASS   varchar2 --код класса
  );

  --установка атрибутов публикации раздела
  procedure CONF_CLASS_SET_PUBL_ATTRS
  (
    SUSER      varchar2 --пользователь
   ,NCOMPANY   number --рег. номер организации
   ,NRN        varchar2 --рег. номер класса
   ,SCODE_ATTR varchar2 --наименование атрибута класса для формирования его кода
   ,SDESC_ATTR varchar2 --наименование атрибута класса для формирования его описания
  );

  --полное удаление параметров публикации класса
  procedure CONF_CLASS_REMOVE_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  );

  --переключение признака игнорирования описания класса при поиске
  procedure CONF_CLASS_TOGGLE_NODESCSEARCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  );

  --рендеринг модуля печати, для подключения к отдельным страничками
  function HTML_PRINTING_MODULE return clob;

  --считывание HTML списка организаций
  function HTML_COMPANIES_LIST return clob;

  --формирование HTML со списком разделов
  function HTML_UNITS_LIST
  (
    SSESSION     varchar2 --идентификатор сессии
   ,NCOMPANY     number --организация
   ,SUSER        varchar2 --пользователь
   ,SSEARCH      varchar2 := null --строка поиска (null - не искать)
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML со списком отчетов
  function HTML_REPORTS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
   ,NCURPAGE      number --номер текущей страницы
   ,SLIST_ID      varchar2 --идентификатор списка отчетов
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML для предпросмотра отчета
  function HTML_REPORT_PREVIEW
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORT           number --рег. номер отчета
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML с детализацией по отчету
  function HTML_REPORT_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORT           number --рег. номер отчета
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML со списком записей словаря, привязанного к параметру отчета
  function HTML_REPORT_PRM_DICT_RECS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML со списком позиций очереди
  function HTML_REPORTQS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML с детализацией по позиции очереди
  function HTML_REPORTQ_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORTQ          number --рег. номер позиции очереди
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML со списком глав справки
  function HTML_HELP_UNITS_LIST
  (
    NCOMPANY     number --организация
   ,SLIST_ID     varchar2 --идентификатор списка глав справки
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --формирование HTML с главой справки
  function HTML_HELP
  (
    NCOMPANY      number --организация
   ,NHELP         number --рег. номер главы справки
   ,SHEADER_CLASS varchar2 := null --CSS-класс для заголовка
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob;

  --выдача WEB-серверу списка организаций
  procedure HTPP_COMPANIES_LIST;

  --выдача WEB-серверу списка разделов
  procedure HTPP_UNITS_LIST
  (
    SSESSION     varchar2 --идентификатор сессии
   ,NCOMPANY     number --организация
   ,SUSER        varchar2 --пользователь
   ,SSEARCH      varchar2 := null --строка поиска (null - не искать)
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --выдача WEB-серверу списка отчетов
  procedure HTPP_REPORTS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
   ,NCURPAGE      number --номер текущей страницы
   ,SLIST_ID      varchar2 --идентификатор списка отчетов
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --выдача WEB-серверу детализации по отчету
  procedure HTPP_REPORT_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORT           number --рег. номер отчета
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --выдача WEB-серверу списка записей словаря, привязанного к параметру отчета
  procedure HTPP_REPORT_PRM_DICT_RECS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --постановка отчета в очередь (по коду отчета)
  procedure HTPP_REPORT_PUT
  (
    SSESSION varchar2 --идентификатор сессии
   ,NCOMPANY number --организация
   ,SUSER    varchar2 --пользователь
   ,SREPORT  varchar2 --мнемокод отчета
   ,SPRMS    clob --параметры в JSON ([{SNAME:<ИМЯ_ПАРАМЕТРА>,NVAL_TYPE:<ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ДД.ММ.ГГГГ, для булева 1 или 0>}])
  );

  --постановка отчета в очередь
  procedure HTPP_REPORT_PUT
  (
    SSESSION varchar2 --идентификатор сессии
   ,NCOMPANY number --организация
   ,SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,SPRMS    clob --параметры в JSON ([{SNAME:<ИМЯ_ПАРАМЕТРА>,NVAL_TYPE:<ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ДД.ММ.ГГГГ, для булева 1 или 0>}])
  );

  --добавление расписания для отчета
  procedure HTPP_REPORT_ADD_SCHEDULE
  (
    SSESSION        varchar2 --идентификатор сессии
   ,SUSER           varchar2 --пользователь
   ,NREPORT         number --рег. номер отчета
   ,NSCH_TYPE       number --тип расписания
   ,SSCH_STEP       varchar2 --шаг исполнения расписания (строковое представление)
   ,SSCH_START_DATE varchar2 --дата начала действия расписания
   ,NMAIL           number --признак доставки по e-mail (0 - нет, 1 - да)
   ,SPRMS           clob --параметры в JSON ([{SNAME:<ИМЯ_ПАРАМЕТРА>,NVAL_TYPE:<ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ДД.ММ.ГГГГ, для булева 1 или 0>}])
  );

  --удаление расписания для отчета
  procedure HTPP_REPORT_REMOVE_SCHEDULE
  (
    SSESSION  varchar2 --идентификатор сессии
   ,SUSER     varchar2 --пользователь
   ,NREPORT   number --рег. номер отчета
   ,NSCHEDULE number --рег. номер расписания
  );

  --изменение "избранности" отчета
  procedure HTPP_REPORT_FAVOR_TOGGLE
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
  );

  --выдача WEB-серверу списка позиций очереди
  procedure HTPP_REPORTQS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --выдача WEB-серверу детализации по позиции очереди
  procedure HTPP_REPORTQ_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORTQ          number --рег. номер позиции очереди
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --удаление позиции очреди
  procedure HTPP_REPORTQ_REMOVE
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  );

  --загрузка готового отчета
  procedure HTPP_REPORTQ_DOWNLOAD
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  );

  --повторная постановка отчета в очередь
  procedure HTPP_REPORTQ_REPEAT
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  );

  --выдача WEB-серверу состояния позиции очереди
  procedure HTPP_REPORTQ_GETSTATE
  (
    SSESSION varchar2 --идентификатор сессии
   ,NCOMPANY number --организация
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  );

  --выдача WEB-серверу списка разделов справки
  procedure HTPP_HELP_UNITS_LIST
  (
    NCOMPANY     number --организация
   ,SLIST_ID     varchar2 --идентификатор списка глав справки
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

  --выдача WEB-серверу раздела справки
  procedure HTPP_HELP
  (
    NCOMPANY      number --организация
   ,NHELP         number --рег. номер главы справки
   ,SHEADER_CLASS varchar2 := null --CSS-класс для заголовка
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  );

end;
/

create or replace package body UDO_PKG_SYSW0006_URPT_PUBLISH as

  --проверка - является ли пользователь администратором
  function UTL_CHECK_IS_ADMIN
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
  ) return boolean is
  begin
    if (UDO_PKG_URPT_SRV.UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                                           ,SUSER    => SUSER) = 1)
    then
      return true;
    else
      return false;
    end if;
  end;

  --считавание системной настройки - разделитель списков
  function UTL_GET_SEQSYMB
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
  ) return varchar2 is
    JRESP              JSON; --объектное представление ответа сервиса отложенной печати
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - код настройки
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_OPTION_KEY
                          ,PAIR_VALUE => 'SeqSymb');
    --параметры действия - организация
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_COMPANY_KEY
                          ,PAIR_VALUE => NCOMPANY);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_OPTION_GET_STR_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим значение
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это список значений - будем разбирать
    if (NRESP_TYPE is null)
    then
      --сформируем объектное представление списка
      JRESP := JSON(CRESP);
      --если там есть параметр и это строка
      if ((JRESP.EXIST('SSTR_VALUE')) and (JRESP.GET('SSTR_VALUE').IS_STRING))
      then
        return JRESP.GET('SSTR_VALUE').GET_STRING;
      else
        return SDELIM_DEF;
      end if;
    else
      return SDELIM_DEF;
    end if;
  exception
    when others then
      return SDELIM_DEF;
  end;

  --считавание состояния активности сервиса
  function UTL_CHECK_SERVICE_ACTIVE return boolean is
    JRESP      JSON; --объектное представление ответа сервиса отложенной печати
    JREQ       JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS  JSON; --объектное представление параметров запроса к сервису отложенной печати
    CREQ       clob; --текстовое представление запроса к сервису отложенной печати
    CRESP      clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE number(17); --разобранный код ответа сервера
    SRESP_MSG  varchar2(4000); --разобранное сообщение сервера
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ      := JSON();
    JREQ_PRMS := JSON();
    --действие - определить активность сервиса
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_OPTION_CHECK_ACTV_VAL);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим значение
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это ответ о состоянии - будем разбирать
    if (NRESP_TYPE is null)
    then
      --сформируем объектное ответа
      JRESP := JSON(CRESP);
      --если там есть параметр и это строка
      if ((JRESP.EXIST('NSTATE')) and (JRESP.GET('NSTATE').IS_NUMBER))
      then
        if (JRESP.GET('NSTATE').GET_NUMBER = UDO_PKG_URPT_SRV.NIS_ACTIVE)
        then
          return true;
        else
          return false;
        end if;
      else
        return false;
      end if;
    else
      return false;
    end if;
  exception
    when others then
      return false;
  end;

  --сохранение группы параметров отчета
  procedure UTL_PRMS_PUT
  (
    SUSER varchar2 --пользователь
   ,CPRMS clob --набор параметров в JSON ([{NPRM:<РЕГ_НОМЕР_ПАРАМЕТРА>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА>}])
  ) is
    JPRMS JSON_LIST; --JSON описание параметров отчета (объект)
    JPRM  JSON; --JSON описание парамета отчета (объект)
  begin
    --разберем параметры в коллекцию (если они есть)
    if ((CPRMS is not null) and (DBMS_LOB.GETLENGTH(CPRMS) > 0))
    then
      JPRMS := JSON_LIST(CPRMS);
      --если коллекция не пуста
      if (JPRMS.COUNT > 0)
      then
        --идем по ней
        for I in 1 .. JPRMS.COUNT
        loop
          --сформируем объектное представление параметра
          JPRM := JSON(JPRMS.GET(I));
          --если он корректен
          if ((JPRM.EXIST('NPRM')) and
             ((JPRM.GET('NPRM').IS_NUMBER) or (JPRM.GET('NPRM').IS_STRING)) and
             (JPRM.EXIST('SVAL')) and (JPRM.GET('SVAL').IS_STRING))
          then
            --сохраним его
            UTL_PRM_PUT(SUSER => SUSER
                       ,NPRM  => NVL(JPRM.GET('NPRM').GET_NUMBER
                                    ,TO_NUMBER(JPRM.GET('NPRM').GET_STRING))
                       ,SVAL  => JPRM.GET('SVAL').GET_STRING);
          end if;
        end loop;
      end if;
    end if;
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CPRMS);
  exception
    when others then
      null;
  end;

  --сохранение выбранного параметра отчета
  procedure UTL_PRM_PUT
  (
    SUSER varchar2 --пользователь
   ,NPRM  number --рег. номер параметра отчета
   ,SVAL  varchar2 --значение параметра отчета
  ) is
  begin
    update UDO_T_SYSW0006_URPT_PRM T
       set T.VAL = SVAL
     where T.USR = SUSER
       and T.PRM = NPRM;
    if (sql%notfound)
    then
      insert into UDO_T_SYSW0006_URPT_PRM
        (USR, PRM, VAL)
      values
        (SUSER, NPRM, SVAL);
    end if;
  exception
    when others then
      null;
  end;

  --считывание выбранного параметра отчета
  function UTL_PRM_GET
  (
    SUSER varchar2 --пользователь
   ,NPRM  number --рег. номер параметра отчета
  ) return varchar2 is
    SRES UDO_T_SYSW0006_URPT_PRM.VAL%type; --результат работы
  begin
    select T.VAL
      into SRES
      from UDO_T_SYSW0006_URPT_PRM T
     where T.USR = SUSER
       and T.PRM = NPRM;
    return SRES;
  exception
    when others then
      return null;
  end;

  --проверка наличия сохраненного значения параметра (0 - нет, 1 - да)
  function UTL_PRM_SAVED
  (
    SUSER varchar2 --пользователь
   ,NPRM  number --рег. номер параметра отчета
  ) return number is
    NTMP number(17); --буфер для расчетов
  begin
    --подчитаем количество этого параметра в буфере для этого пользователя
    select count(T.PRM)
      into NTMP
      from UDO_T_SYSW0006_URPT_PRM T
     where T.USR = SUSER
       and T.PRM = NPRM;
    --если они есть
    if (NTMP > 0)
    then
      return 1;
    else
      --ничего нет
      return 0;
    end if;
  exception
    when others then
      return 0;
  end;

  --зачистка выбранных параметров отчета
  procedure UTL_PRM_CLEAR(SUSER varchar2 --пользователь
                          ) is
  begin
    delete from UDO_T_SYSW0006_URPT_PRM T
     where T.USR = SUSER;
  exception
    when others then
      null;
  end;

  --подключение к сервису отложенной печати
  procedure UTL_PRINT_SERVICE_CONNECT
  (
    SUSER                     varchar2 --пользователь
   ,SPASSWORD                 varchar2 --пароль
   ,NCOMPANY                  number --рег. номер организации
   ,SSESSION_CLIENT           varchar2 := null --идентификатор сессии сформированный клиентом
   ,SEXPECTED_SERVICE_VERSION varchar2 := SEXPECTED_SERVICE_VERS_DEFAULT --ожидаемая клиентом версия сервиса
   ,SSESSION                  out varchar2 --идентификатор сессии
  ) is
    SCOMPANY           COMPANIES.NAME%type; --наименование организации
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    JRESP              JSON; --объектное представление ответа сервиса отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SERR               varchar2(4000); --буфер для ошибок
  begin
    --найдем наименование организации
    begin
      select T.NAME
        into SCOMPANY
        from COMPANIES T
       where T.RN = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NCOMPANY
                                ,SUNIT_TABLE => 'COMPANIES');
    end;
    --подключаемся к сервису
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - наименование организации
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SCOMPANY_KEY
                            ,PAIR_VALUE => SCOMPANY);
      --параметры действия - пароль
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PASSWORD_KEY
                            ,PAIR_VALUE => SPASSWORD);
      --параметры действия - идентификатор сессии клиента
      if (SSESSION_CLIENT is not null)
      then
        JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_CLIENT_KEY
                              ,PAIR_VALUE => SSESSION_CLIENT);
      end if;
      --параметры действия - ожидаемая клиентом версия сервиса
      if (SEXPECTED_SERVICE_VERSION is not null)
      then
        JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_EXPECTED_SERVICE_VERS_KEY
                              ,PAIR_VALUE => SEXPECTED_SERVICE_VERSION);
      end if;
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_LOGIN_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --пробуем аутентифицироваться
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
      --проверим ответ на наличие ошибок
      UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                          ,NRESP_TYPE => NRESP_TYPE
                                          ,SRESP_MSG  => SRESP_MSG);
      --если пришел не стандартный ответ, а просто данные - значит это сведения о номере сессии и всё успешно
      if (NRESP_TYPE is null)
      then
        --сформируем объектное представление данных ответа
        JRESP := JSON(CRESP);
        --если там есть идентификатор сессии и это строка - считаем идентификатор сессии
        if ((JRESP.EXIST('SSESSION')) and (JRESP.GET('SSESSION').IS_STRING))
        then
          SSESSION := JRESP.GET('SSESSION').GET_STRING;
          PKG_SESSION_VARS.PUT(SNAME  => SSESSION_PRINT_SESSION
                              ,SVALUE => SSESSION);
        else
          --иначе - неизвестный формат ответа
          P_EXCEPTION(0
                     ,'Неожиданный ответ сервиса отложенной печати!');
        end if;
      else
        --иначе - какая-то ошибка, выдадим её
        P_EXCEPTION(0
                   ,SRESP_MSG);
      end if;
    exception
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
  end;

  --отключение от сервиса отложенной печати
  procedure UTL_PRINT_SERVICE_DISCONNECT(SSESSION varchar2 := null --идентификатор сессии
                                         ) is
    JREQ       JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS  JSON; --объектное представление параметров запроса к сервису отложенной печати
    CREQ       clob; --текстовое представление запроса к сервису отложенной печати
    CRESP      clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE number(17); --разобранный код ответа сервера
    SRESP_MSG  varchar2(4000); --разобранное сообщение сервера
    SERR       varchar2(4000); --буфер для ошибок
  begin
    --отключаемся от сервиса
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ      := JSON();
      JREQ_PRMS := JSON();
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => NVL(SSESSION
                                     ,PKG_SESSION_VARS.GET_STR(SNAME => SSESSION_PRINT_SESSION)));
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_LOGOUT_VAL);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --пробуем выйти
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
      --проверим ответ на наличие ошибок
      UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                          ,NRESP_TYPE => NRESP_TYPE
                                          ,SRESP_MSG  => SRESP_MSG);
      --если не всё в порядке
      if (NRESP_TYPE <> UDO_PKG_URPT_SRV.NRESP_TYPE_OK)
      then
        --выдадим ошибку
        P_EXCEPTION(0
                   ,SRESP_MSG);
      end if;
    exception
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
  end;

  --считывание признака опубликованности отчета (0 - опубликован, 1 - не опубликован)
  function CONF_REPORT_IS_PUBLISHED(NRN number --рег. номер отчета
                                    ) return number is
  begin
    return UDO_PKG_URPT_SRV.CONF_GET_PRM_NUM_BASE(SUNIT   => 'UserReports'
                                                 ,NUNITRN => NRN
                                                 ,SPRM    => UDO_PKG_URPT_SRV.SCONF_USR_REPORT_PUBL);
  exception
    when others then
      return UDO_PKG_URPT_SRV.NCAN_PUBLISH_USER_NO;
  end;

  --считывание описания для публикации отчета
  function CONF_REPORT_GET_PUBL_DESC(NRN number --рег. номер отчета
                                     ) return varchar2 is
  begin
    return UDO_PKG_URPT_SRV.CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                                 ,NUNITRN => NRN
                                                 ,SPRM    => UDO_PKG_URPT_SRV.SCONF_USR_REPORT_DESC);
  exception
    when others then
      return null;
  end;

  --считывание описания для публикации отчета (возврат ответа WEB-серверу)
  procedure CONF_REPORT_GET_PUBL_DESC(NRN number --рег. номер отчета
                                      ) is
    SDESC UDO_T_URPT_SRV_CONF.STR_VAL%type; --текущее описание отчета
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --считаем описание
      SDESC := CONF_REPORT_GET_PUBL_DESC(NRN => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => SDESC);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --считывание картинки предварительного просмотра по  регистрационному номеру
  function CONF_REPORT_GET_PICT(NRN number --рег. номер картинки
                                ) return varchar2 is
  begin
    return UDO_PKG_URPT_SRV.CONF_GET_PICT_BASE(NRN => NRN);
  exception
    when others then
      return null;
  end;

  --формирование списка отчетов, подлежащих публикации
  procedure CONF_REPORT_GET_REPORTS_LIST(CPRMS clob --JSON-параметры запроса ({NCOMPANY:123,SUSER:"abc",SSEARCH:"abc",NPORTION:123,NPORTION_SIZE:123})
                                         ) is
    NCOMPANY      COMPANIES.RN%type; --рег. номер организации
    SUSER         varchar2(80); --имя пользователя
    NPORTION      number(17); --номер порции данных
    NPORTION_SIZE number(17); --размер порции данных
    NROW_FROM     number(17); --нижняя граница диапазона данных
    NROW_TO       number(17); --верхняя граница диапазона данных
    SSEARCH       varchar2(4000); --поисковый запрос
    JPRMS         JSON; --объектное представление параметров
    JRESP         JSON; --объектное представление ответа
    JRPT          JSON; --объектное представление отчета
    JRPTS         JSON_LIST; --объектное представление списка отчетов
    SERR          varchar2(4000); --буфер для ошибок
    CRESP         clob; --текстовое представление ответа
  begin
    --обработаем запрос
    begin
      --сформируем объектное представление параметров
      JPRMS := JSON(CPRMS);
      --проверим параметры
      if ((not JPRMS.EXIST('NCOMPANY')) or
         (not JPRMS.GET('NCOMPANY').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NCOMPANY"!');
      else
        NCOMPANY := JPRMS.GET('NCOMPANY').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('NPORTION')) or
         (not JPRMS.GET('NPORTION').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NPORTION"!');
      else
        NPORTION := JPRMS.GET('NPORTION').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('NPORTION_SIZE')) or
         (not JPRMS.GET('NPORTION_SIZE').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NPORTION_SIZE"!');
      else
        NPORTION_SIZE := JPRMS.GET('NPORTION_SIZE').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('SUSER')) or (not JPRMS.GET('SUSER').IS_STRING))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "SUSER"!');
      else
        SUSER := JPRMS.GET('SUSER').GET_STRING;
      end if;
      if ((not JPRMS.EXIST('SSEARCH')) or (not JPRMS.GET('SSEARCH').IS_STRING))
      then
        UDO_PKG_URPT_SRV.UTL_PREPARE_SEARCH(SSEARCH          => null
                                           ,SSEARCH_PREPARED => SSEARCH);
      else
        UDO_PKG_URPT_SRV.UTL_PREPARE_SEARCH(SSEARCH          => JPRMS.GET('SSEARCH')
                                                                .GET_STRING
                                           ,SSEARCH_PREPARED => SSEARCH);
      end if;
      --определим границы выдаваемого диапазона отчетов
      UDO_PKG_URPT_SRV.UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                                           ,NPORTION_SIZE => NPORTION_SIZE
                                           ,NROW_FROM     => NROW_FROM
                                           ,NROW_TO       => NROW_TO);
      --инициализируем список отчетов
      JRPTS := JSON_LIST();
      --идем по отчетам
      for C in (select UR.CODE SCODE
                      ,UR.NAME SNAME
                      ,UR.CODE SVALUE
                  from USERREPORTS UR
                      ,(select URL.RN NRN
                              ,ROW_NUMBER() OVER(order by ROWNUM) NROW
                          from USERREPORTS URL
                         where URL.COMPANY = NCOMPANY
                           and (STRINLIKE(UPPER(URL.CODE || ' ' || URL.NAME)
                                         ,UPPER(SSEARCH)) <> 0)
                           and UDO_PKG_URPT_SRV.UTL_REPORT_PUBLISHABLE(NREPORT => URL.RN) =
                               UDO_PKG_URPT_SRV.NIS_PUBLISHABLE
                           and not exists
                         (select CN.RN
                                  from UDO_T_URPT_SRV_CONF CN
                                      ,UNITLIST            U
                                 where CN.UNITRN = URL.RN
                                   and CN.UNIT = U.RN
                                   and U.UNITCODE = 'UserReports')
                           and UDO_PKG_URPT_SRV.UTL_CHECK_PRIVS(SUSER => SUSER
                                                               ,SUNIT => 'UserReports'
                                                               ,NCRN  => URL.CRN) =
                               UDO_PKG_URPT_SRV.NHAVE_PRIVS
                           and ROWNUM <= NROW_TO) UPLIM
                 where UPLIM.NRN = UR.RN
                   and UPLIM.NROW >= NROW_FROM)
      loop
        --соберем объект отчета
        JRPT := JSON();
        JRPT.PUT(PAIR_NAME  => 'CODE'
                ,PAIR_VALUE => C.SCODE);
        JRPT.PUT(PAIR_NAME  => 'DESC'
                ,PAIR_VALUE => C.SNAME);
        JRPT.PUT(PAIR_NAME  => 'VALUE'
                ,PAIR_VALUE => C.SVALUE);
        --добавляем отчет в ответ
        JRPTS.APPEND(ELEM => JRPT.TO_JSON_VALUE());
      end loop;
      --всё ок
      JRESP := JSON();
      JRESP.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SRESP_STATE_KEY
               ,PAIR_VALUE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK);
      JRESP.PUT(PAIR_NAME  => 'RECS'
               ,PAIR_VALUE => JRPTS);
      --вернем ответ
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                              ,CACHE   => false);
      JRESP.TO_CLOB(BUF => CRESP);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --добавление нового отчета к публикации
  procedure CONF_REPORT_ADD_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,SREPORT  varchar2 --мнемокод отчета
   ,SDESC    varchar2 --публикуемое описание отчета
  ) is
    NREPORT USERREPORTS.RN%type; --рег. номер отчета
    SERR    varchar2(4000); --буфер для ошибок
    CRESP   clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (SREPORT is null)
      then
        P_EXCEPTION(0
                   ,'Не указан мнемокод публикуемого отчета!');
      end if;
      --разыменуем отчет
      FIND_USERREP_CODE(NFLAG_SMART => 0
                       ,NCOMPANY    => NCOMPANY
                       ,SCODE       => SREPORT
                       ,NRN         => NREPORT);
      --опубликуем отчет
      UDO_PKG_URPT_SRV.CONF_SET_USR_REPORT(SUSER    => SUSER
                                          ,NCOMPANY => NCOMPANY
                                          ,NRN      => NREPORT
                                          ,NPUBL    => UDO_PKG_URPT_SRV.NCAN_PUBLISH_USER_YES
                                          ,SDESC    => SDESC);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --установка публикуемого описания отчета
  procedure CONF_REPORT_SET_DESC
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,SDESC    varchar2 --публикуемое описание отчета
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор отчета!');
      end if;
      --установим описание отчета
      UDO_PKG_URPT_SRV.CONF_SET_USR_REPORT_DESC(SUSER    => SUSER
                                               ,NCOMPANY => NCOMPANY
                                               ,NRN      => NRN
                                               ,SDESC    => SDESC);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --полное удаление параметров публикации отчета
  procedure CONF_REPORT_REMOVE_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор отчета!');
      end if;
      --удалим публикацию отчета
      UDO_PKG_URPT_SRV.CONF_UNSET_USR_REPORT(SUSER    => SUSER
                                            ,NCOMPANY => NCOMPANY
                                            ,NRN      => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --переключение признака публикации отчета
  procedure CONF_REPORT_TOGGLE_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор отчета!');
      end if;
      --переключим публикацию отчета
      UDO_PKG_URPT_SRV.CONF_TOGGLE_USR_REPORT_PUBLISH(SUSER    => SUSER
                                                     ,NCOMPANY => NCOMPANY
                                                     ,NRN      => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --добавление картинки предварительного просмотра к отчету
  procedure CONF_REPORT_ADD_PICT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,SPICT    varchar2 --наименование картинки в буфере
  ) is
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор отчета!');
      end if;
      --идем по буферу
      for C in (select *
                  from WWV_FLOW_FILES
                 where name = SPICT)
      loop
        --добавляем картинку
        UDO_PKG_URPT_SRV.CONF_SET_USR_REPORT_PREVIEW(SUSER    => SUSER
                                                    ,NCOMPANY => NCOMPANY
                                                    ,NRN      => NRN
                                                    ,BPICT    => C.BLOB_CONTENT);
      end loop;
    exception
      when others then
        rollback;
    end;
    --зачистим буфер
    begin
      delete from WWV_FLOW_FILES
       where name = SPICT;
    exception
      when others then
        null;
    end;
  exception
    when others then
      null;
  end;

  --удаление картинки предварительного просмотра отчета
  procedure CONF_REPORT_REMOVE_PICT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер картинки
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор изображения!');
      end if;
      --удалим куртинку отчета
      UDO_PKG_URPT_SRV.CONF_UNSET_USR_REPORT_PREVIEW(SUSER    => SUSER
                                                    ,NCOMPANY => NCOMPANY
                                                    ,NRN      => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --удаление позиции расписания отчета
  procedure CONF_REPORT_REMOVE_SCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер расписания
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор расписания!');
      end if;
      --удалим расписание отчета
      UDO_PKG_URPT_SRV.CONF_UNSET_USR_REPORT_SCH(SUSER    => SUSER
                                                ,NCOMPANY => NCOMPANY
                                                ,NRN      => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --считывание признака игнорирования описания при поиске
  function CONF_CLASS_IS_NO_DESC_SEARCH(NRN number --рег. номер класса
                                        ) return number is
  begin
    return NVL(UDO_PKG_URPT_SRV.CONF_GET_PRM_NUM_BASE(SUNIT   => 'DMSClasses'
                                                     ,NUNITRN => NRN
                                                     ,SPRM    => UDO_PKG_URPT_SRV.SCONF_CLASS_NO_DESC_SEARCH)
              ,UDO_PKG_URPT_SRV.NNO_DESC_SEARCH_NO);
  exception
    when others then
      return UDO_PKG_URPT_SRV.NNO_DESC_SEARCH_NO;
  end;

  --считывание атрибута кода класса
  function CONF_CLASS_GET_CODE_ATTR(NRN number --рег. номер класса
                                    ) return varchar2 is
  begin
    return UDO_PKG_URPT_SRV.CONF_GET_PRM_STR_BASE(SUNIT   => 'DMSClasses'
                                                 ,NUNITRN => NRN
                                                 ,SPRM    => UDO_PKG_URPT_SRV.SCONF_CLASS_CODE);
  exception
    when others then
      return null;
  end;

  --считывание атрибута наименования класса
  function CONF_CLASS_GET_DESC_ATTR(NRN number --рег. номер класса
                                    ) return varchar2 is
  begin
    return UDO_PKG_URPT_SRV.CONF_GET_PRM_STR_BASE(SUNIT   => 'DMSClasses'
                                                 ,NUNITRN => NRN
                                                 ,SPRM    => UDO_PKG_URPT_SRV.SCONF_CLASS_DESC);
  exception
    when others then
      return null;
  end;

  --считывание атрибутов для публикации класса (возврат ответа WEB-серверу)
  procedure CONF_CLASS_GET_PUBL_ATTRS(NRN number --рег. номер класса
                                      ) is
    SCODE_ATTR UDO_T_URPT_SRV_CONF.STR_VAL%type; --текущий атрибут кода
    SDESC_ATTR UDO_T_URPT_SRV_CONF.STR_VAL%type; --текущий атрибут описания
    SERR       varchar2(4000); --буфер для ошибок
    JRESP      JSON; --объектное представление ответа
    CRESP      clob; --текстовое представление ответа
  begin
    begin
      --считаем атрибуты
      SCODE_ATTR := CONF_CLASS_GET_CODE_ATTR(NRN => NRN);
      SDESC_ATTR := CONF_CLASS_GET_DESC_ATTR(NRN => NRN);
      --всё в ответ
      JRESP := JSON();
      JRESP.PUT(PAIR_NAME  => 'SCODE'
               ,PAIR_VALUE => SCODE_ATTR);
      JRESP.PUT(PAIR_NAME  => 'SNAME'
               ,PAIR_VALUE => SDESC_ATTR);
      JRESP.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SRESP_STATE_KEY
               ,PAIR_VALUE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK);
      --вернем ответ
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                              ,CACHE   => false);
      JRESP.TO_CLOB(BUF => CRESP);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --формирование списка классов, подлежащих публикации
  procedure CONF_CLASS_GET_CLASSES_LIST(CPRMS clob --JSON-параметры запроса ({SUSER:"abc",SSEARCH:"abc",NPORTION:123,NPORTION_SIZE:123})
                                        ) is
    SUSER         varchar2(80); --имя пользователя
    NPORTION      number(17); --номер порции данных
    NPORTION_SIZE number(17); --размер порции данных
    NROW_FROM     number(17); --нижняя граница диапазона данных
    NROW_TO       number(17); --верхняя граница диапазона данных
    SSEARCH       varchar2(4000); --поисковый запрос
    JPRMS         JSON; --объектное представление параметров
    JRESP         JSON; --объектное представление ответа
    JCLS          JSON; --объектное представление класса
    JCLSS         JSON_LIST; --объектное представление списка классов
    SERR          varchar2(4000); --буфер для ошибок
    CRESP         clob; --текстовое представление ответа
  begin
    --обработаем запрос
    begin
      --сформируем объектное представление параметров
      JPRMS := JSON(CPRMS);
      --проверим параметры
      if ((not JPRMS.EXIST('NPORTION')) or
         (not JPRMS.GET('NPORTION').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NPORTION"!');
      else
        NPORTION := JPRMS.GET('NPORTION').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('NPORTION_SIZE')) or
         (not JPRMS.GET('NPORTION_SIZE').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NPORTION_SIZE"!');
      else
        NPORTION_SIZE := JPRMS.GET('NPORTION_SIZE').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('SUSER')) or (not JPRMS.GET('SUSER').IS_STRING))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "SUSER"!');
      else
        SUSER := JPRMS.GET('SUSER').GET_STRING;
      end if;
      if ((not JPRMS.EXIST('SSEARCH')) or (not JPRMS.GET('SSEARCH').IS_STRING))
      then
        UDO_PKG_URPT_SRV.UTL_PREPARE_SEARCH(SSEARCH          => null
                                           ,SSEARCH_PREPARED => SSEARCH);
      else
        UDO_PKG_URPT_SRV.UTL_PREPARE_SEARCH(SSEARCH          => JPRMS.GET('SSEARCH')
                                                                .GET_STRING
                                           ,SSEARCH_PREPARED => SSEARCH);
      end if;
      --определим границы выдаваемого диапазона классов
      UDO_PKG_URPT_SRV.UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                                           ,NPORTION_SIZE => NPORTION_SIZE
                                           ,NROW_FROM     => NROW_FROM
                                           ,NROW_TO       => NROW_TO);
      --инициализируем список классов
      JCLSS := JSON_LIST();
      --идем по классам
      for C in (select UL.UNITCODE SCODE
                      ,(select RS.TEXT
                          from V_RESOURCES_LOCAL RS
                         where RS.TABLE_NAME = 'UNITLIST'
                           and RS.COLUMN_NAME = 'UNITNAME'
                           and RS.RN = UL.RN) SNAME
                      ,UL.UNITCODE SVALUE
                  from UNITLIST UL
                      ,(select ULL.RN NRN
                              ,ROW_NUMBER() OVER(order by ROWNUM) NROW
                          from UNITLIST ULL
                         where (STRINLIKE(UPPER(ULL.UNITCODE || ' ' ||
                                                (select RS.TEXT
                                                   from V_RESOURCES_LOCAL RS
                                                  where RS.TABLE_NAME =
                                                        'UNITLIST'
                                                    and RS.COLUMN_NAME =
                                                        'UNITNAME'
                                                    and RS.RN = ULL.RN))
                                         ,UPPER(SSEARCH)) <> 0)
                           and not exists (select CN.RN
                                  from UDO_T_URPT_SRV_CONF CN
                                      ,UNITLIST            U
                                 where CN.UNITRN = ULL.RN
                                   and CN.UNIT = U.RN
                                   and U.UNITCODE = 'DMSClasses')
                           and UDO_PKG_URPT_SRV.UTL_CHECK_PRIVS(SUSER => SUSER
                                                               ,SUNIT => 'DMSClasses'
                                                               ,NCRN  => ULL.HRN) =
                               UDO_PKG_URPT_SRV.NHAVE_PRIVS
                           and ROWNUM <= NROW_TO) UPLIM
                 where UPLIM.NRN = UL.RN
                   and UPLIM.NROW >= NROW_FROM)
      loop
        --соберем объект отчета
        JCLS := JSON();
        JCLS.PUT(PAIR_NAME  => 'CODE'
                ,PAIR_VALUE => C.SCODE);
        JCLS.PUT(PAIR_NAME  => 'DESC'
                ,PAIR_VALUE => C.SNAME);
        JCLS.PUT(PAIR_NAME  => 'VALUE'
                ,PAIR_VALUE => C.SVALUE);
        --добавляем отчет в ответ
        JCLSS.APPEND(ELEM => JCLS.TO_JSON_VALUE());
      end loop;
      --всё ок
      JRESP := JSON();
      JRESP.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SRESP_STATE_KEY
               ,PAIR_VALUE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK);
      JRESP.PUT(PAIR_NAME  => 'RECS'
               ,PAIR_VALUE => JCLSS);
      --вернем ответ
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                              ,CACHE   => false);
      JRESP.TO_CLOB(BUF => CRESP);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --формирование списка атрибутов класса, подлежащих публикации
  procedure CONF_CLASS_GET_CLASSATTRS_LIST(CPRMS clob --JSON-параметры запроса ({NCLASS:123,SSEARCH:"abc",NPORTION:123,NPORTION_SIZE:123})
                                           ) is
    NCLASS        UNITLIST.RN%type; --рег. номер класса
    NPORTION      number(17); --номер порции данных
    NPORTION_SIZE number(17); --размер порции данных
    NROW_FROM     number(17); --нижняя граница диапазона данных
    NROW_TO       number(17); --верхняя граница диапазона данных
    SSEARCH       varchar2(4000); --поисковый запрос
    JPRMS         JSON; --объектное представление параметров
    JRESP         JSON; --объектное представление ответа
    JCLA          JSON; --объектное представление атрибута
    JCLAS         JSON_LIST; --объектное представление списка атрибутов
    SERR          varchar2(4000); --буфер для ошибок
    CRESP         clob; --текстовое представление ответа
  begin
    --обработаем запрос
    begin
      --сформируем объектное представление параметров
      JPRMS := JSON(CPRMS);
      --проверим параметры
      if ((not JPRMS.EXIST('NCLASS')) or (not JPRMS.GET('NCLASS').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NCLASS"!');
      else
        NCLASS := JPRMS.GET('NCLASS').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('NPORTION')) or
         (not JPRMS.GET('NPORTION').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NPORTION"!');
      else
        NPORTION := JPRMS.GET('NPORTION').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('NPORTION_SIZE')) or
         (not JPRMS.GET('NPORTION_SIZE').IS_NUMBER))
      then
        P_EXCEPTION(0
                   ,'Некорректно указаны параметры запроса - параметр "NPORTION_SIZE"!');
      else
        NPORTION_SIZE := JPRMS.GET('NPORTION_SIZE').GET_NUMBER;
      end if;
      if ((not JPRMS.EXIST('SSEARCH')) or (not JPRMS.GET('SSEARCH').IS_STRING))
      then
        UDO_PKG_URPT_SRV.UTL_PREPARE_SEARCH(SSEARCH          => null
                                           ,SSEARCH_PREPARED => SSEARCH);
      else
        UDO_PKG_URPT_SRV.UTL_PREPARE_SEARCH(SSEARCH          => JPRMS.GET('SSEARCH')
                                                                .GET_STRING
                                           ,SSEARCH_PREPARED => SSEARCH);
      end if;
      --определим границы выдаваемого диапазона классов
      UDO_PKG_URPT_SRV.UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                                           ,NPORTION_SIZE => NPORTION_SIZE
                                           ,NROW_FROM     => NROW_FROM
                                           ,NROW_TO       => NROW_TO);
      --инициализируем список атрибутов
      JCLAS := JSON_LIST();
      --идем по атрибутам класса
      for C in (select CA.SCOLUMN_NAME SCODE
                      ,CA.SCAPTION     SNAME
                      ,CA.SCOLUMN_NAME SVALUE
                  from V_DMSCLATTRS CA
                      ,(select CAL.NRN NRN
                              ,ROW_NUMBER() OVER(order by ROWNUM) NROW
                          from V_DMSCLATTRS CAL
                         where CAL.NPRN = NCLASS
                           and (STRINLIKE(UPPER(CAL.SCOLUMN_NAME || ' ' ||
                                                CAL.SCAPTION)
                                         ,UPPER(SSEARCH)) <> 0)
                           and ROWNUM <= NROW_TO) UPLIM
                 where UPLIM.NRN = CA.NRN
                   and UPLIM.NROW >= NROW_FROM)
      loop
        --соберем объект отчета
        JCLA := JSON();
        JCLA.PUT(PAIR_NAME  => 'CODE'
                ,PAIR_VALUE => C.SCODE);
        JCLA.PUT(PAIR_NAME  => 'DESC'
                ,PAIR_VALUE => C.SNAME);
        JCLA.PUT(PAIR_NAME  => 'VALUE'
                ,PAIR_VALUE => C.SVALUE);
        --добавляем отчет в ответ
        JCLAS.APPEND(ELEM => JCLA.TO_JSON_VALUE());
      end loop;
      --всё ок
      JRESP := JSON();
      JRESP.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SRESP_STATE_KEY
               ,PAIR_VALUE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK);
      JRESP.PUT(PAIR_NAME  => 'RECS'
               ,PAIR_VALUE => JCLAS);
      --вернем ответ
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                              ,CACHE   => false);
      JRESP.TO_CLOB(BUF => CRESP);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --добавление нового раздела к публикации
  procedure CONF_CLASS_ADD_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,SCLASS   varchar2 --код класса
  ) is
    NCLASS UNITLIST.RN%type; --рег. номер класса
    SERR   varchar2(4000); --буфер для ошибок
    CRESP  clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (SCLASS is null)
      then
        P_EXCEPTION(0
                   ,'Не указан код публикуемого класса!');
      end if;
      --разыменуем класс
      FIND_UNITLIST_CODE(NFLAG_SMART  => 0
                        ,NFLAG_OPTION => 0
                        ,SCODE        => SCLASS
                        ,NRN          => NCLASS);
      --опубликуем класс
      UDO_PKG_URPT_SRV.CONF_SET_CLASS(SUSER           => SUSER
                                     ,NCOMPANY        => NCOMPANY
                                     ,NRN             => NCLASS
                                     ,SCODE_ATTR      => null
                                     ,SDESC_ATTR      => null
                                     ,NNO_DESC_SEARCH => UDO_PKG_URPT_SRV.NNO_DESC_SEARCH_NO);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --установка атрибутов публикации раздела
  procedure CONF_CLASS_SET_PUBL_ATTRS
  (
    SUSER      varchar2 --пользователь
   ,NCOMPANY   number --рег. номер организации
   ,NRN        varchar2 --рег. номер класса
   ,SCODE_ATTR varchar2 --наименование атрибута класса для формирования его кода
   ,SDESC_ATTR varchar2 --наименование атрибута класса для формирования его описания
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идинтификатор класса!');
      end if;
      --установим публикуемые атрибуты класса
      UDO_PKG_URPT_SRV.CONF_SET_CLASS_PUBL_ATTRS(SUSER      => SUSER
                                                ,NCOMPANY   => NCOMPANY
                                                ,NRN        => NRN
                                                ,SCODE_ATTR => SCODE_ATTR
                                                ,SDESC_ATTR => SDESC_ATTR);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --полное удаление параметров публикации класса
  procedure CONF_CLASS_REMOVE_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор класса!');
      end if;
      --удалим публикацию класса
      UDO_PKG_URPT_SRV.CONF_UNSET_CLASS(SUSER    => SUSER
                                       ,NCOMPANY => NCOMPANY
                                       ,NRN      => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --переключение признака игнорирования описания класса при поиске
  procedure CONF_CLASS_TOGGLE_NODESCSEARCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  ) is
    SERR  varchar2(4000); --буфер для ошибок
    CRESP clob; --текстовое представление ответа
  begin
    begin
      --проверим параметры
      if (SUSER is null)
      then
        P_EXCEPTION(0
                   ,'Не указан пользователь!');
      end if;
      if (NCOMPANY is null)
      then
        P_EXCEPTION(0
                   ,'Не указана организация!');
      end if;
      if (NRN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан идентификатор класса!');
      end if;
      --переключим публикацию отчета
      UDO_PKG_URPT_SRV.CONF_TOGGLE_CLASS_NODESCSEARCH(SUSER    => SUSER
                                                     ,NCOMPANY => NCOMPANY
                                                     ,NRN      => NRN);
      --всё ок
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => null);
    exception
      when others then
        SERR := sqlerrm;
        rollback;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдадим ответ WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --проверка сессии сервиса отложенной печати
  procedure UTL_PRINT_SERVICE_VERIFY(SSESSION varchar2 := null --идентификатор сессии
                                     ) is
    JREQ       JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS  JSON; --объектное представление параметров запроса к сервису отложенной печати
    CREQ       clob; --текстовое представление запроса к сервису отложенной печати
    CRESP      clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE number(17); --разобранный код ответа сервера
    SRESP_MSG  varchar2(4000); --разобранное сообщение сервера
    SERR       varchar2(4000); --буфер для ошибок
  begin
    --отключаемся от сервиса
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ      := JSON();
      JREQ_PRMS := JSON();
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => NVL(SSESSION
                                     ,PKG_SESSION_VARS.GET_STR(SNAME => SSESSION_PRINT_SESSION)));
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_SESSION_CHECK_VAL);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --пробуем верифицировать сессию
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
      --проверим ответ на наличие ошибок
      UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                          ,NRESP_TYPE => NRESP_TYPE
                                          ,SRESP_MSG  => SRESP_MSG);
      --если не всё в порядке
      if (NRESP_TYPE <> UDO_PKG_URPT_SRV.NRESP_TYPE_OK)
      then
        --выдадим ошибку
        P_EXCEPTION(0
                   ,SRESP_MSG);
      end if;
    exception
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,SERR);
    end;
  end;

  --рендеринг модуля печати, для подключения к отдельным страничками
  function HTML_PRINTING_MODULE return clob is
    SHTML clob; --свёрстанный HTML
  begin
    /*
    Пример вызова на странице (для печати отчета мо отмеченным записям):
    javascript:makeSelectListG($("#P1001_DOCUMENT").val() + ":" + $("#P1001_UNITCODE").val(),
                               function (nident) {
                                 putReportG(cardReportCode,
                                            [{SNAME:"SUNITCODE", NVAL_TYPE:0, SVAL:$("#P1001_UNITCODE").val()},
                                             {SNAME:"NIDENT", NVAL_TYPE:1, SVAL:nident}]);
                               });
    */
    SHTML := '
<style>

 .noTitleG .ui-dialog-titlebar {
   display:none
 }

 .a_button_global {
   background-color: #a4c3df;
   padding-left: 10px;
   color: black;
   text-decoration: none;
   padding-right: 10px;
   padding-top: 5px;
   padding-bottom: 5px;
   font-size: 150%;
 }

 .a_button_global:hover {
   background-color: #eaeff5
 }

 .a_button_hot_global {
   background-color: coral;
   padding-left: 10px;
   color: black;
   text-decoration: none;
   padding-right: 10px;
   padding-top: 5px;
   padding-bottom: 5px;
   font-size: 150%;
 }

 .a_button_hot_global:hover {
   background-color: #eaeff5
 }

</style>

<div id="loadingDlgGlobal" style="display:none">
 <table style="height:100%">
   <tr><td id="loadingDlgMsgGlobal"></td></tr>
   <tr><td><img src="' || V('IMAGE_PREFIX') || V('APP_IMGS_DIR') ||
             '/loading.gif"/></td></tr>
 </table>
</div>

<div style="display:none" id="errContainerGlobal">
  <table style="width:100%;height:150px">
    <tr><td>
      <center>
        <b><span id="errMsgGlobal" style="color:red"></span></b>
      </center>
    </td></tr>
    <tr><td style="vertical-align: bottom;">
      <center><br>
        <a href="javascript:;" onclick="$(''#errContainerGlobal'').dialog(''close'');" class="a_button_hot_global">Закрыть</a>
      </center>
    </td></tr>
  </table>
</div>

<script>

function showLoadingG(msg) {
   var message="Подождите...";
   if((msg != null)&&(msg != "")) message = msg;
   $("#loadingDlgMsgGlobal").html("<center><b>" + message + "</b></center>");
   $("#loadingDlgGlobal").dialog({dialogClass:''noTitleG'',modal:true,width:250,height:100,resizable:false});
}

function hideLoadingG() {
   $("#loadingDlgGlobal").dialog("close");
}

function showExecErrG(msg) {
   $("#errMsgGlobal").html(msg);
   $("#errContainerGlobal").dialog({dialogClass:''noTitleG'',modal:true,width:350,resizable:false});
}

function hideExecErrG() {
   $("#errContainerGlobal").dialog("close");
}

function putReportG(report_code, prms) {
   hideExecErrG();
   showLoadingG("Заказываю отчет...");
   $.post(''wwv_flow.show'',
          {''p_request''      : ''APPLICATION_PROCESS=HTPP_REPORT_PUT_GLOBAL'',
           ''p_flow_id''      : $v(''pFlowId''),
           ''p_flow_step_id'' : $v(''pFlowStepId''),
           ''p_instance''     : $v(''pInstance''),
           ''x01''            : report_code,
           ''x02''            : JSON.stringify(prms)},
          function(pData){
                 hideLoadingG();
                 var res = eval("(" + pData + ")");
                 if(res.STATE == 0) {
                   showExecErrG("Ошибка печати: " + res.MSG);
                 } else {
                    checkReportQStateG(res.MSG, 1);
                 }
      }
   );
}

function checkReportQStateG(reportQ, cntTry) {
   if(cntTry == 1) showLoadingG("Формирую отчет...");
   $.post(''wwv_flow.show'',
          {''p_request''      : ''APPLICATION_PROCESS=HTPP_REPORTQ_GETSTATE_GLOBAL'',
           ''p_flow_id''      : $v(''pFlowId''),
           ''p_flow_step_id'' : $v(''pFlowStepId''),
           ''p_instance''     : $v(''pInstance''),
           ''x01''            : reportQ},
          function(pData){
                 if((pData != null)&&(pData != "")) {
                   var res = eval("(" + pData + ")");
                   if(res.STATE == 0) {
                     hideLoadingG();
                     showExecErrG("Ошибка проверки статуса готовности отчета: " + res.MSG);
                   } else {
                     if((res.MSG == ''0'')||(res.MSG == ''1'')) {
                       checkReportQStateG(reportQ, ++cntTry)
                     } else {
                       hideLoadingG();
                       if(res.MSG == ''2'') {
                         hideLoadingG();
                         downloadReportG(reportQ);
                       } else {
                         showExecErrG(res.MSG);
                       }
                     }
                   }
                 } else {
                   hideLoadingG();
                   showExecErrG("Сервер не вернул результата, попробуйте позже...");
                 }
      }
   );
}

function downloadReportG(reportq) {
   hideExecErrG();
   showLoadingG("Загружаю отчет...");
   $.post(''wwv_flow.show'',
          {''p_request''      : ''APPLICATION_PROCESS=HTPP_REPORTQ_DOWNLOAD_GLOBAL'',
           ''p_flow_id''      : $v(''pFlowId''),
           ''p_flow_step_id'' : $v(''pFlowStepId''),
           ''p_instance''     : $v(''pInstance''),
           ''x01''            : reportq},
          function(pData){
                 hideLoadingG();
                 var res = eval("(" + pData + ")");
                 if(res.STATE == 0) {
                   showExecErrG("Ошибка загрузки: " + res.MSG);
                 } else {
                   window.location.href = res.URL;
                 }
      }
   );
}

function makeSelectListG(docsList, callBack) {
   if((docsList == "")||(docsList == null)) {
     showExecErrG("Необходимо указать как минимум один документ!");
     return;
   }
   showLoadingG("Группирую документы...");
   $.post(''wwv_flow.show'',
          {''p_request''      : ''APPLICATION_PROCESS=CREATE_SELECTLIST_GLOBAL'',
           ''p_flow_id''      : $v(''pFlowId''),
           ''p_flow_step_id'' : $v(''pFlowStepId''),
           ''p_instance''     : $v(''pInstance''),
           ''x01''            : docsList},
          function(data){
                  hideLoadingG();
                  if((data == "")||(data == null)) {
                    showExecErrG("Сервер не вернул ответ! Попробуйте позже!");
                  } else {
                    try {
                      var res = eval("(" + data + ")");
                      if(res.status != "OK") {
                        showExecErrG("Ошибка группировки документов: " + res.msg);
                      } else {
                        callBack(res.ident);
                      }
                    } catch (e) {
                      showExecErrG("Неожиданный ответ сервера: " + e.message);
                    }
                  }
      }
   );
}

</script>';
    --веренем результат
    return SHTML;
  end;

  --считывание HTML списка организаций
  function HTML_COMPANIES_LIST return clob is
    JRESP      JSON; --объектное представление ответа сервиса отложенной печати
    JREQ       JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS  JSON; --объектное представление параметров запроса к сервису отложенной печати
    JCMPNS     JSON_LIST;
    JCMPN      JSON;
    CREQ       clob; --текстовое представление запроса к сервису отложенной печати
    CRESP      clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE number(17); --разобранный код ответа сервера
    SRESP_MSG  varchar2(4000); --разобранное сообщение сервера
    SHTML      clob; --свёрстанный HTML
  begin
    --инициализируем ответ
    SHTML := '<option value="-1">Нет доступных организаций</option><script>showExecErr("В системе нет доступных для сервиса организаций...");</script>';
    --сформируем запрос к сервису - инициализация объекта
    JREQ      := JSON();
    JREQ_PRMS := JSON();
    --действие - считать список организаций
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_OPTION_GET_CMPNS_VAL);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим значение
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это список отчетов - будем разбирать
    if (NRESP_TYPE is null)
    then
      --сформируем объектное представление списка
      JRESP := JSON(CRESP);
      --если там есть организации и это действительно список
      if ((JRESP.EXIST('COMPANIES')) and (JRESP.GET('COMPANIES').IS_ARRAY))
      then
        --то разбираем его
        JCMPNS := JSON_LIST(JRESP.GET('COMPANIES'));
        --если он не пустой
        if (JCMPNS.COUNT > 0)
        then
          SHTML := '';
          --идем по элементам списка
          for I in 1 .. JCMPNS.COUNT
          loop
            --считаем очередной элемент
            JCMPN := JSON(JCMPNS.GET(I));
            --экранируем строки
            UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SFULL_NAME'
                                                   ,OBJ     => JCMPN);
            --добавим организацию в ответ
            SHTML := SHTML || '<option value="' ||
                     TO_CHAR(JCMPN.GET('NRN').GET_NUMBER) || '">' || JCMPN.GET(PAIR_NAME =>'SNAME')
                    .GET_STRING || '</option>';
          end loop;
        end if;
      else
        null;
      end if;
    else
      null;
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      return SHTML;
  end;

  --формирование HTML со списком разделов
  function HTML_UNITS_LIST
  (
    SSESSION     varchar2 --идентификатор сессии
   ,NCOMPANY     number --организация
   ,SUSER        varchar2 --пользователь
   ,SSEARCH      varchar2 := null --строка поиска (null - не искать)
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    JRESP              JSON; --объектное представление ответа сервиса отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JUNTS              JSON_LIST; --объектное представление списка разделов из ответа
    JUNT               JSON; --объектное представлеие раздела из списка разделов из ответа
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - организация
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_COMPANY_KEY
                          ,PAIR_VALUE => NCOMPANY);
    --параметры действия - строка поиска
    if (SSEARCH is not null)
    then
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SEARCH_KEY
                            ,PAIR_VALUE => SSEARCH);
    end if;
    --параметры действия - номер порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_KEY
                          ,PAIR_VALUE => 0);
    --параметры действия - кол-во записей в порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_SIZE_KEY
                          ,PAIR_VALUE => 0);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_UNITS_GET_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим список отчетов
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это список отчетов - будем разбирать
    if (NRESP_TYPE is null)
    then
      --разбираем список отчетов и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          declare
            --формирование элемента списка
            function BUILD_ITEM
            (
              NUNIT      number --рег. номер раздела
             ,SUNIT_NAME varchar2 --наименование раздела
             ,NREPORTS   number --количество отчетов
            ) return varchar2 is
              SRES   varchar2(4000); --результат работы
              SCOUNT varchar2(200); --счетчик отчетов
            begin
              --сформируем занчение счетчика
              if (NREPORTS is not null)
              then
                SCOUNT := '(' || TO_CHAR(NREPORTS) || ')';
              else
                SCOUNT := '';
              end if;
              --сверстаем элемент
              SRES := '<tr onclick="loadReportsList($(this), '''');" unit="' ||
                      TO_CHAR(NUNIT) || '" class="' || STR_CLASS ||
                      '"><td class="' || STD_CLASS || '"><b>' || SUNIT_NAME ||
                      '</b></td><td class="' || STD_CLASS ||
                      '"><span style="color:blue;font-weight:bold;display:none">' ||
                      SCOUNT || '</span></td></tr>';
              --вернем результат
              return SRES;
            end;

          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть разделы и это действительно список
            if ((JRESP.EXIST('UNITS')) and (JRESP.GET('UNITS').IS_ARRAY))
            then
              --то разбираем его
              JUNTS := JSON_LIST(JRESP.GET('UNITS'));
              --если он не пустой
              if (JUNTS.COUNT > 0)
              then
                --начинаем вёрстку
                SHTML := '';
                --идем по разделам списка
                for I in 1 .. JUNTS.COUNT
                loop
                  --считаем очередной отчет
                  JUNT := JSON(JUNTS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME'
                                                         ,OBJ     => JUNT);
                  --сверстаем элемент
                  SHTML := SHTML ||
                           BUILD_ITEM(NUNIT      => JUNT.GET('NRN').GET_NUMBER
                                     ,SUNIT_NAME => JUNT.GET('SNAME').GET_STRING
                                     ,NREPORTS   => JUNT.GET('NREPORTS')
                                                    .GET_NUMBER);
                end loop;
                --добавим спец-раздел "Все"
                SHTML := BUILD_ITEM(NUNIT      => -1
                                   ,SUNIT_NAME => '<span style="color:green">ПОКАЗАТЬ ВСЕ</span>'
                                   ,NREPORTS   => null) || SHTML;
                --добавим спец-раздел "Избранное"
                SHTML := BUILD_ITEM(NUNIT      => -2
                                   ,SUNIT_NAME => '<span style="color:coral">ИЗБРАННЫЕ</span>'
                                   ,NREPORTS   => null) || SHTML;
                --добавим спец-раздел "Заказанные"
                SHTML := BUILD_ITEM(NUNIT      => -3
                                   ,SUNIT_NAME => 'ЗАКАЗАННЫЕ'
                                   ,NREPORTS   => null) || SHTML;
                --завершаем вёрстку
                SHTML := '<table cellspacing="0" cellpadding="0" class="' ||
                         STABLE_CLASS || '">' || SHTML || '</table>';
                --позиционируемся на избранном или на полном списке (если был поиск)
                if (SSEARCH is null)
                then
                  SHTML := SHTML || '<script>loadReportsList($("tr.' ||
                           STR_CLASS || '[unit=-2]"), '''')</script>';
                else
                  SHTML := SHTML || '<script>loadReportsList($("tr.' ||
                           STR_CLASS || '[unit=-1]"), '''')</script>';
                end if;
              else
                --если он пустой - нет разделов
                if (SSEARCH is null)
                then
                  P_EXCEPTION(0
                             ,'Сервер не вернул данных!');
                else
                  SHTML := null;
                end if;
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            null;
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML со списком отчетов
  function HTML_REPORTS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
   ,NCURPAGE      number --номер текущей страницы
   ,SLIST_ID      varchar2 --идентификатор списка отчетов
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    JRESP              JSON; --объектное представление ответа сервиса отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JRPTS              JSON_LIST; --объектное представление списка отчетов из ответа
    JRPT               JSON; --объектное представлеие отчета из списка отчетов из ответа
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
    SIMG               varchar2(200); --картинка для отчета
    SGRP               varchar2(200); --наименование группы для отчета
  begin
    --зачистим текущие выборы параметров отчетов
    UTL_PRM_CLEAR(SUSER => SUSER);
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - организация
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_COMPANY_KEY
                          ,PAIR_VALUE => NCOMPANY);
    --параметры действия - раздел отчета
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_UNIT_KEY
                          ,PAIR_VALUE => NUNIT);
    --параметры действия - избранность
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_FAVOR_KEY
                          ,PAIR_VALUE => NFAVOR);
    --параметры действия - строка поиска
    if (SSEARCH is not null)
    then
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SEARCH_KEY
                            ,PAIR_VALUE => SSEARCH);
    end if;
    --параметры действия - номер порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_KEY
                          ,PAIR_VALUE => NPORTION);
    --параметры действия - кол-во записей в порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_SIZE_KEY
                          ,PAIR_VALUE => NPORTION_SIZE);
    --параметры действия - порядок сортировки
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_RPT_ORDER_KEY
                          ,PAIR_VALUE => NRPT_ORDER);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTS_GET_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим список отчетов
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это список отчетов - будем разбирать
    if (NRESP_TYPE is null)
    then
      --разбираем список отчетов и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          declare
            NFIRST number(17); --рег. номер первого отчета
            --формирование элемента списка
            function BUILD_ITEM
            (
              NREPORT      number --рег. номер отчета
             ,SREPORT_NAME varchar2 --наименование отчета
             ,SREPORT_DESC varchar2 --описание отчета
             ,SIMG         varchar2 --иконка
             ,NFAVOR_SHOW  number --признак отображения "избранности" (0 - не показывать, 1 - покзывать)
             ,NFAVOR       number --признак "избранности" (0 - нет, 1 - да)
             ,NSCHEDULED   number --признак наличия расписания (0 - нет, 1 - да)
            ) return varchar2 is
              SRES     varchar2(4000); --результат работы
              SREFRESH varchar2(10); --признак обновления списка избранного (true/fasle)
            begin
              --сверстаем элемент
              SRES := '<tr onclick="loadReport($(this));" report="' ||
                      TO_CHAR(NREPORT) || '" class="' || STR_CLASS ||
                      '"><td class="' || STD_CLASS ||
                      '"><table><tr><td rowspan="2" style="padding-right:5px;vertical-align:middle;"><img style="height:48px;width:48px" src="' ||
                      V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' || SIMG ||
                      '"></td><td style="margin-right:5px; text-align:left; width:100%;"><b>' ||
                      SREPORT_NAME || '</b></td>';
              if (NFAVOR_SHOW = 1)
              then
                if (HTML_REPORTS_LIST.NFAVOR = 1)
                then
                  SREFRESH := 'true';
                else
                  SREFRESH := 'false';
                end if;
                SRES := SRES ||
                        '<td rowspan="2" style="vertical-align:middle; padding-left:3px; text-align:right;"><a href="javascript:;" onclick="toggleFavor(' ||
                        TO_CHAR(NREPORT) || ', ' || SREFRESH || ');" title="' ||
                        IIF_STR(TO_CHAR(NFAVOR)
                               ,'='
                               ,TO_CHAR(UDO_PKG_URPT_SRV.NFAVOR_YES)
                               ,'Удалить из избранных'
                               ,'Добавить в избранные') || '"><img id="favor' ||
                        TO_CHAR(NREPORT) || '" src="' ||
                        IIF_STR(TO_CHAR(NFAVOR)
                               ,'='
                               ,TO_CHAR(UDO_PKG_URPT_SRV.NFAVOR_YES)
                               ,V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' ||
                                'favor_yes.png'
                               ,V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' ||
                                'favor_no.png') || '"></a></td>';
              end if;
              SRES := SRES ||
                      '</tr><tr><td style="font-size:80%; margin-right:5px; text-align:left;">' ||
                      SREPORT_DESC ||
                      IIF_STR(TO_CHAR(NSCHEDULED)
                             ,'='
                             ,TO_CHAR(0)
                             ,''
                             ,'<p style="width:100%; text-align:right; font-size:80%; font-weight:bold; color:green;">ЗАДАНО РАСПИСАНИЕ</p>') ||
                      '</td></tr></table></td><td class="rptl_list_item_selector" style="width:5px"></td></tr>';
              --вернем результат
              return SRES;
            end;

          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть отчеты и это действительно список
            if ((JRESP.EXIST('REPORTS')) and (JRESP.GET('REPORTS').IS_ARRAY))
            then
              --то разбираем его
              JRPTS := JSON_LIST(JRESP.GET('REPORTS'));
              --если он не пустой
              if (JRPTS.COUNT > 0)
              then
                SHTML := '';
                --идем по отчетам списка
                for I in 1 .. JRPTS.COUNT
                loop
                  --считаем очередной отчет
                  JRPT := JSON(JRPTS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC'
                                                         ,OBJ     => JRPT);
                  --определим картинку элемента
                  case JRPT.GET('NRPT_TYPE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                      SIMG := 'icon_cr.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                      SIMG := 'icon_excel.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                      SIMG := 'icon_ooc.png';
                    else
                      SIMG := 'menu\menu-page-128.png';
                  end case;
                  --сверстаем его
                  SHTML := SHTML ||
                           BUILD_ITEM(NREPORT      => JRPT.GET('NRN').GET_NUMBER
                                     ,SREPORT_NAME => JRPT.GET('SNAME')
                                                      .GET_STRING
                                     ,SREPORT_DESC => JRPT.GET('SDESC')
                                                      .GET_STRING
                                     ,SIMG         => SIMG
                                     ,NFAVOR_SHOW  => 1
                                     ,NFAVOR       => JRPT.GET('NFAVOR')
                                                      .GET_NUMBER
                                     ,NSCHEDULED   => JRPT.GET('NSCHEDULED')
                                                      .GET_NUMBER);
                  --запомним первый
                  if (I = 1)
                  then
                    NFIRST := JRPT.GET('NRN').GET_NUMBER;
                  end if;
                end loop;
                --завершаем вёрстку
                SHTML := '<table cellspacing="0" cellpadding="0" class="' ||
                         STABLE_CLASS || '">' || SHTML || '</table>';
                --позиционируемся на первом отчете в списке
                if (NFIRST is not null)
                then
                  SHTML := SHTML || '<script>loadReport($("tr.' || STR_CLASS ||
                           '[report=' || TO_CHAR(NFIRST) || ']"))</script>';
                end if;
              else
                --если он пустой - нет отчетов
                if (SSEARCH is null)
                then
                  SHTML := '<center><div style="padding:15px"><b>Для данного раздела нет доступных отчетов!</b></div></center><script>setReport("none");</script>';
                else
                  SHTML := '<center><div style="padding:15px"><b>В данном разделе нет отчетов, удовлетворяющих критериям поиска!</b></div></center><script>setReport("none");</script>';
                end if;
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть отчеты и это действительно список
            if ((JRESP.EXIST('REPORTS')) and (JRESP.GET('REPORTS').IS_ARRAY))
            then
              --то разбираем его
              JRPTS := JSON_LIST(JRESP.GET('REPORTS'));
              --если он не пустой
              if (JRPTS.COUNT > 0)
              then
                SHTML := '';
                --идем по отчетам списка
                for I in 1 .. JRPTS.COUNT
                loop
                  --считаем очередной отчет
                  JRPT := JSON(JRPTS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC'
                                                         ,OBJ     => JRPT);
                  --определим для него группу
                  if (NRPT_ORDER = UDO_PKG_URPT_SRV.NRPT_ORDER_UNIT)
                  then
                    SGRP := JRPT.GET('SUNIT_NAME').GET_STRING;
                  else
                    SGRP := 'Список по алфавиту';
                  end if;
                  --определим картинку элемента
                  case JRPT.GET('NRPT_TYPE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                      SIMG := 'icon_cr.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                      SIMG := 'icon_excel.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                      SIMG := 'icon_ooc.png';
                    else
                      SIMG := 'menu\menu-page-128.png';
                  end case;
                  --сверстаем элемент
                  SHTML := SHTML || '<li group-name="' || SGRP || '">';
                  SHTML := SHTML || '<a href="f?p=' || V('APP_ID') || ':12:' ||
                           V('APP_SESSION') || '::' || V('DEBUG') ||
                           '::P12_REPORT:' ||
                           TO_CHAR(JRPT.GET('NRN').GET_NUMBER) || '">';
                  SHTML := SHTML || '<table style="width:100%">';
                  SHTML := SHTML || '<tr>';
                  SHTML := SHTML || '<td>';
                  SHTML := SHTML || '<img style="height:64px;width:64px" src="' ||
                           V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' || SIMG || '">';
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '<td style="padding-left:10px;width:100%">';
                  SHTML := SHTML ||
                           '<h3 style="white-space:normal;text-align:left;">' || JRPT.GET('SNAME')
                          .GET_STRING || '</h3>';
                  SHTML := SHTML ||
                           '<p style="white-space:normal;text-align:left;">' || JRPT.GET('SDESC')
                          .GET_STRING || '</p>' ||
                           IIF_STR(TO_CHAR(JRPT.GET('NSCHEDULED').GET_NUMBER)
                                  ,'='
                                  ,TO_CHAR(0)
                                  ,''
                                  ,'<p style="width:100%; text-align:right; font-size:60%; font-weight:bold; color:green;">ЗАДАНО РАСПИСАНИЕ</p>');
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '</tr>';
                  SHTML := SHTML || '</table>';
                  SHTML := SHTML || '</a>';
                  if (NVL(NFAVOR
                         ,UDO_PKG_URPT_SRV.NFAVOR_NO) <>
                     UDO_PKG_URPT_SRV.NFAVOR_YES)
                  then
                    SHTML := SHTML || '<a href="f?p=' || V('APP_ID') || ':13:' ||
                             V('APP_SESSION') || '::' || V('DEBUG') || ':::' ||
                             '" data-icon="' ||
                             IIF_STR(TO_CHAR(JRPT.GET('NFAVOR').GET_NUMBER)
                                    ,'='
                                    ,TO_CHAR(UDO_PKG_URPT_SRV.NFAVOR_YES)
                                    ,'favor-yes'
                                    ,'favor-no') || '" data-theme="c"></a>';
                  end if;
                  SHTML := SHTML || '</li>';
                end loop;
                SHTML := SHTML || '<script>$("#' || SLIST_ID ||
                         '").listview({autodividers:true,autodividersSelector:function(li){return li.attr("group-name");}});</script>';
              else
                --если он пустой - прячем кнопку "Ещё" - нет больше отчетов
                SHTML := SHTML || '<script>$("#P' || TO_CHAR(NCURPAGE) ||
                         '_GET_MORE").button("disable");</script>';
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML для предпросмотра отчета
  function HTML_REPORT_PREVIEW
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORT           number --рег. номер отчета
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    JURLS              JSON_LIST := JSON_LIST(); --коллекция ссылок (JSON-представление)
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - рег. номер отчета
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                          ,PAIR_VALUE => NREPORT);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORT_PREVIEW_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим детали отчета
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел стандартный ответ, без ошибок - значит нам прислали URL-картинки
    if (NRESP_TYPE = UDO_PKG_URPT_SRV.NRESP_TYPE_OK)
    then
      --разбираем ответ и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          begin
            JURLS := JSON_LIST(SRESP_MSG);
            if (JURLS.COUNT > 0)
            then
              SHTML := SHTML || '<table><tr>';
              SHTML := SHTML || '<td class="' || SBUTTON_HOT_CLASS ||
                       '" style="height:210px; vertical-align:middle; cursor:pointer;" onclick="$(''#preview_cont'').scrollLeft($(''#preview_cont'').scrollLeft()-200);"><div><img src="' ||
                       V('IMAGE_PREFIX') || V('APP_IMGS_DIR') ||
                       '/prev_tumb.png"></div></td>';
              SHTML := SHTML ||
                       '<td style="height:210px; vertical-align:middle;"><div id="preview_cont" style="height:100%; max-width:550px; vertical-align:middle; overflow:hidden; display:inline-block; border:1px solid #3A5A87; margin-left:2px; margin-right:2px;">';
              SHTML := SHTML || '<table style="height:100%;"><tr>';
              for I in 1 .. JURLS.COUNT
              loop
                SHTML := SHTML ||
                         '<td style="height:100%; vertical-align:middle;"><a style="padding-right:' ||
                         TO_CHAR(IIF_NUM(I
                                        ,'='
                                        ,JURLS.COUNT
                                        ,0
                                        ,5)) ||
                         'px; vertical-align:middle; display:inline-block;" class="report_glr" href="' || JURLS.GET(I)
                        .GET_STRING || '" title="Предварительный просмотр">';
                SHTML := SHTML ||
                         '<img style="padding:5px;" class="img-galery-tumb" src="' || JURLS.GET(I)
                        .GET_STRING || '" height="200px" alt="">';
                SHTML := SHTML || '</a></td>';
              end loop;
              SHTML := SHTML || '</tr></table>';
              SHTML := SHTML || '</div></td>';
              SHTML := SHTML || '<td class="' || SBUTTON_HOT_CLASS ||
                       '" style="height:210px; vertical-align:middle; cursor:pointer;" onclick="$(''#preview_cont'').scrollLeft($(''#preview_cont'').scrollLeft()+200);"><div><img src="' ||
                       V('IMAGE_PREFIX') || V('APP_IMGS_DIR') ||
                       '/next_tumb.png"></div></td>';
              SHTML := SHTML || '</tr></table>';
              SHTML := SHTML || '<script type="text/javascript">';
              SHTML := SHTML || ' jQuery(function(){ ';
              SHTML := SHTML || ' jQuery(".report_glr").lightBox({';
              SHTML := SHTML || ' overlayOpacity: 0.6,';
              SHTML := SHTML || ' imageLoading: "' || V('IMAGE_PREFIX') ||
                       V('APP_IMGS_DIR') || '/lb/loading.gif",';
              SHTML := SHTML || ' imageBtnClose: "' || V('IMAGE_PREFIX') ||
                       V('APP_IMGS_DIR') || '/lb/navi-close.png",';
              SHTML := SHTML || ' imageBtnPrev: "' || V('IMAGE_PREFIX') ||
                       V('APP_IMGS_DIR') || '/lb/navi-left.png",';
              SHTML := SHTML || ' imageBtnNext: "' || V('IMAGE_PREFIX') ||
                       V('APP_IMGS_DIR') || '/lb/navi-right.png",';
              SHTML := SHTML || ' containerResizeSpeed: 350,';
              SHTML := SHTML || ' txtImage: "Изображение",';
              SHTML := SHTML || ' txtOf: "из"';
              SHTML := SHTML || ' })';
              SHTML := SHTML || ' });';
              SHTML := SHTML || ' </script>';
            else
              SHTML := '';
            end if;
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            null;
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML с детализацией по отчету
  function HTML_REPORT_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORT           number --рег. номер отчета
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JRPT               JSON; --объектное представлеие отчета из ответа
    JRPT_ULS           JSON_LIST; --объектное представление списка разделов подключения отчета
    JRPT_UL            JSON; --объектное представление раздела подключения отчета
    JRPT_PRMS          JSON_LIST; --объектное представление списка параметров отчета
    JRPT_PRM           JSON; --объектное представление параметра отчета
    JRPT_SCHS          JSON_LIST; --объектное представление списка расписаний отчета
    JRPT_SCH           JSON; --объектное представление расписания отчета
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
    STYPE              varchar2(200); --текстовое описание типа отчета
    SHTML_INPUT_TYPE   varchar2(40); --HTML тип поля для ввода параметра
    SHTML_INPUT_CLASS  varchar2(40); --класс для идентификации виджета и инициализации его плагина
    SPRMS              clob; --буфер для верстки параметров
    SPRINT_BTN         clob; --кнопка "печать"
    SPRM_DEF_ATTRS     varchar2(4000); --описание атрибутов тэга для идентификации параметра
    SPRM_SHOW_ATTRS    varchar2(4000); --описание атрибутов тэга для отображения параметра
    SPRM_VAL           varchar2(4000); --значение аттарибута
    BPRMS_SHOW         boolean; --признак наличия визуализируемых параметров
    SDICT_BTN          varchar2(4000); --HTML для кнопки выбора из словаря
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - рег. номер отчета
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                          ,PAIR_VALUE => NREPORT);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORT_GET_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим детали отчета
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это отчет - будем разбирать
    if (NRESP_TYPE is null)
    then
      --разбираем ответ и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          begin
            --сформируем объектное представление отчета
            JRPT := JSON(CRESP);
            --экранируем строковые поля
            UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC;SMAIL'
                                                   ,OBJ     => JRPT);
            --определим текстовку для типа
            case JRPT.GET('NRPT_TYPE').GET_NUMBER
              when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                STYPE := 'Crystal Reports';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                STYPE := 'MS Excel';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                STYPE := 'Open Office Calc';
              else
                STYPE := 'Неизвестный тип';
            end case;
            --заголовок
            SHTML := '<h1 class="' || SHEADER_CLASS || '">' || JRPT.GET('SNAME')
                    .GET_STRING || '</h1>';
            --предпросмотр
            if (JRPT.GET('NPREVIEW').GET_NUMBER > 0)
            then
              --предпросмотр - начало
              SHTML := SHTML ||
                       '<table cellpadding="0" cellspacing="0" class="' ||
                       STABLE_CLASS || '" style="max-width:700px;"><tr class="' ||
                       STR_CLASS || '"><th class="' || STH_CLASS ||
                       '">Предварительный просмотр</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">';
              --картинка
              SHTML := SHTML || '<span>' ||
                       HTML_REPORT_PREVIEW(SSESSION          => SSESSION
                                          ,NCOMPANY          => NCOMPANY
                                          ,SUSER             => SUSER
                                          ,NREPORT           => JRPT.GET('NRN')
                                                                .GET_NUMBER
                                          ,SBUTTON_HOT_CLASS => SBUTTON_HOT_CLASS
                                          ,NINTERFACE        => NINTERFACE) ||
                       '</span>';
              --предпросмотр - завершение
              SHTML := SHTML || '</td></tr></table>';
            end if;
            --детали описания - начало
            SHTML := SHTML || '<table cellpadding="0" cellspacing="0" class="' ||
                     STABLE_CLASS || '" style="max-width:700px;"><tr class="' ||
                     STR_CLASS || '"><th class="' || STH_CLASS ||
                     '">Детали</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">';
            SHTML := SHTML || '<table cellpadding="0" cellspacing="0">';
            --код отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Код:</b></td><td class="' || STD_CLASS || '">' || JRPT.GET('SCODE')
                    .GET_STRING || '</td></tr>';
            --наименование отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Наименование:</b></td><td class="' || STD_CLASS || '">' || JRPT.GET('SNAME')
                    .GET_STRING || '</td></tr>';
            --описание отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Описание:</b></td><td class="' || STD_CLASS || '">' || JRPT.GET('SDESC')
                    .GET_STRING || '</td></tr>';
            --тип отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Тип:</b></td><td class="' || STD_CLASS || '">' ||
                     STYPE || '</td></tr>';
            --привязка отчета к разделам
            SHTML    := SHTML || '<tr><td class="' || STD_CLASS ||
                        '"><b>Привязка к разделам:</b></td><td class="' ||
                        STD_CLASS || '">';
            JRPT_ULS := JSON_LIST(JRPT.GET('LUS'));
            if (JRPT_ULS.COUNT > 0)
            then
              for I in 1 .. JRPT_ULS.COUNT
              loop
                --считаем привязку
                JRPT_UL := JSON(JRPT_ULS.GET(I));
                --экранируем строковые поля
                UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SUNIT_CODE;SUNIT_NAME'
                                                       ,OBJ     => JRPT_UL);
                --форматируем
                SHTML := SHTML || JRPT_UL.GET('SUNIT_NAME').GET_STRING;
                if (I < JRPT_ULS.COUNT)
                then
                  SHTML := SHTML || ', ';
                end if;
              end loop;
            else
              SHTML := SHTML || 'Нет привязки к разделам';
            end if;
            SHTML := SHTML || '</td></tr>';
            --история печати отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>История печати:</b></td><td class="' || STD_CLASS || '">';
            SHTML := SHTML || IIF_STR(TO_CHAR(JRPT.GET('NCNTQ').GET_NUMBER)
                                     ,'<='
                                     ,'0'
                                     ,'Отчет ранее не печатался'
                                     ,'<a href="javascript:;" onclick="loadReportsList($(''tr.ul_list_item[unit=-3]''), ' ||
                                      TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                                      ')">Печатался ' ||
                                      TO_CHAR(JRPT.GET('NCNTQ').GET_NUMBER) ||
                                      ' раз(а)</a>') || '</td></tr>';
            --детали описания - окончание
            SHTML := SHTML || '</table></td></tr></table>';
            --расписание
            if (JRPT.GET('NSCHEDULED').GET_NUMBER > 0)
            then
              JRPT_SCHS := JSON_LIST(JRPT.GET('SCHS'));
              if (JRPT_SCHS.COUNT > 0)
              then
                --расписание - начало
                SHTML := SHTML ||
                         '<table cellpadding="0" cellspacing="0" class="' ||
                         STABLE_CLASS ||
                         '" style="max-width:700px;"><tr class="' || STR_CLASS ||
                         '"><th class="' || STH_CLASS ||
                         '">Расписание</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">';
                SHTML := SHTML || '<table cellpadding="0" cellspacing="0">';
                --идем по расписаниям
                for I in 1 .. JRPT_SCHS.COUNT
                loop
                  JRPT_SCH := JSON(JRPT_SCHS.GET(I));
                  --верстаем позицию расписания
                  declare
                    SSCH_TYPE varchar2(200); --тип расписания (строковое представление)
                  begin
                    --определим тип расписания (строковое представление)
                    case JRPT_SCH.GET('NSCHED_TYPE').GET_NUMBER
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_MIN then
                        SSCH_TYPE := 'Ежеминутно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_HOUR then
                        SSCH_TYPE := 'Каждый час';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_DAY then
                        SSCH_TYPE := 'Ежедневно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_WEEK then
                        SSCH_TYPE := 'Еженедельно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_MONTH then
                        SSCH_TYPE := 'Ежемесячно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_ONCE then
                        SSCH_TYPE := 'Единовременно';
                      else
                        SSCH_TYPE := 'Неизвестный тип расписания';
                    end case;
                    --сформируем HTML
                    SHTML := SHTML || '<tr><td class="' || STD_CLASS || '"><b>' ||
                             SSCH_TYPE || '</b></td><td class="' || STD_CLASS || '">' ||
                             IIF_STR(JRPT_SCH.GET('NSCHED_TYPE').GET_NUMBER
                                    ,'='
                                    ,UDO_PKG_URPT_SRV.NSCHED_TYPE_ONCE
                                    , 'Исполнить ' || JRPT_SCH.GET('DSTART_DATE')
                                     .GET_STRING
                                    , 'Начать ' || JRPT_SCH.GET('DSTART_DATE')
                                     .GET_STRING || ' с шагом ' ||
                                      TO_CHAR(JRPT_SCH.GET('NSTEP').GET_NUMBER)) ||
                             IIF_STR(JRPT_SCH.GET('NMAIL').GET_NUMBER
                                    ,'='
                                    ,UDO_PKG_URPT_SRV.NMAIL_YES
                                    ,', доставить по e-mail'
                                    ,'') || '</td><td class="' || STD_CLASS ||
                             '" style="vertical-align:middle;"><img src="' ||
                             V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' ||
                             'remove.png" class="aBtn ' || SBUTTON_CLASS ||
                             '" onclick="removeSchedule(''' ||
                             TO_CHAR(JRPT.GET('NRN').GET_NUMBER) || ''', ''' ||
                             TO_CHAR(JRPT_SCH.GET('NRN').GET_NUMBER) ||
                             ''')" style="width:28px; padding:0px; vertical-align:middle;"></td></tr>';
                  end;
                end loop;
                --расписание - окончание
                SHTML := SHTML || '</table></td></tr></table>';
              end if;
            end if;
            --возможность доставки по e-mail
            SHTML := SHTML || '<input type="hidden" id="canMail" value="' ||
                     TO_CHAR(JRPT.GET('NMAIL_ENABLED').GET_NUMBER) || '">';
            --адрес доставки по e-mail
            SHTML := SHTML || '<input type="hidden" id="addrMail" value="' || JRPT.GET('SMAIL')
                    .GET_STRING || '">';
            --параметры - начало
            JRPT_PRMS := JSON_LIST(JRPT.GET('PRMS'));
            --фалг - визуализируемых нет
            BPRMS_SHOW := false;
            --открываем список параметров
            SPRMS := '<table cellpadding="0" cellspacing="0">';
            --если параметры есть
            if (JRPT_PRMS.COUNT > 0)
            then
              --идем по параметрам
              for I in 1 .. JRPT_PRMS.COUNT
              loop
                JRPT_PRM := JSON(JRPT_PRMS.GET(I));
                --экранируем строковые поля
                UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SPROMPT;SPREV_VAL;SDEF_VAL'
                                                       ,OBJ     => JRPT_PRM);
                --разберем тип параметра и выставим правильный элемент формы ввода для него
                case JRPT_PRM.GET('NVAL_TYPE').GET_NUMBER
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_STR then
                    SHTML_INPUT_TYPE  := 'text';
                    SHTML_INPUT_CLASS := 'txtInput';
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_NUMB then
                    SHTML_INPUT_TYPE  := 'number';
                    SHTML_INPUT_CLASS := 'txtInput';
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_DATE then
                    SHTML_INPUT_TYPE  := 'text';
                    SHTML_INPUT_CLASS := 'dateInput';
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_BOOL then
                    SHTML_INPUT_TYPE  := 'checkbox';
                    SHTML_INPUT_CLASS := 'checkInput';
                  else
                    SHTML_INPUT_TYPE := '';
                end case;
                --определим атрибут отображения параметра и его значение по умолчанию
                case JRPT_PRM.GET('NINP_TYPE').GET_NUMBER
                --если инициализация организацией - не показываем
                  when UDO_PKG_URPT_SRV.NINP_TYPE_COMPANY then
                    SPRM_SHOW_ATTRS := 'style="display:none"';
                    SPRM_VAL        := TO_CHAR(NCOMPANY);
                    --если инициализация идентификатором отмеченных записей - не показываем
                  when UDO_PKG_URPT_SRV.NINP_TYPE_SL_IDENT then
                    SPRM_SHOW_ATTRS := 'style="display:none"';
                    SPRM_VAL        := TO_CHAR(PKG_SESSION_VARS.GET_NUM(SNAME => SSESSION_VAL_SL_IDENT));
                    --если инициализация идентификатором текущего документа  - не показываем
                  when UDO_PKG_URPT_SRV.NINP_TYPE_DOC_RN then
                    SPRM_SHOW_ATTRS := 'style="display:none"';
                    SPRM_VAL        := TO_CHAR(PKG_SESSION_VARS.GET_NUM(SNAME => SSESSION_VAL_DOC_RN));
                    --если инициализация кодом текущего раздела
                  when UDO_PKG_URPT_SRV.NINP_TYPE_UNIT then
                    --если код текущего раздела установлен в контексте - не показываем
                    if (PKG_SESSION_VARS.GET_STR(SNAME   => SSESSION_VAL_UNITCODE
                                                --,SDEFVAL => null -- релиз 20/06/2018 Бухвин
                                                ) is not null)
                    then
                      SPRM_SHOW_ATTRS := 'style="display:none"';
                      SPRM_VAL        := PKG_SESSION_VARS.GET_STR(SNAME => SSESSION_VAL_UNITCODE);
                    else
                      --иначе - показываем и даем выбрать из разделов, к которым привязан отчет
                      SPRM_SHOW_ATTRS := '';
                      if (UTL_PRM_SAVED(SUSER => SUSER
                                       ,NPRM  => JRPT_PRM.GET('NRN').GET_NUMBER) = 1)
                      then
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => UTL_PRM_GET(SUSER => SUSER
                                                                                              ,NPRM  => JRPT_PRM.GET('NRN')
                                                                                                        .GET_NUMBER));
                      else
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => NVL(JRPT_PRM.GET('SPREV_VAL')
                                                                                       .GET_STRING
                                                                                      ,JRPT_PRM.GET('SDEF_VAL')
                                                                                       .GET_STRING));
                      end if;
                      BPRMS_SHOW := true;
                    end if;
                  else
                    begin
                      --инчае - показываем и выставляем флаг наличия визуализируемых, а так же определим значение параметра, демонстрируемое пользователю
                      SPRM_SHOW_ATTRS := '';
                      if (UTL_PRM_SAVED(SUSER => SUSER
                                       ,NPRM  => JRPT_PRM.GET('NRN').GET_NUMBER) = 1)
                      then
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => UTL_PRM_GET(SUSER => SUSER
                                                                                              ,NPRM  => JRPT_PRM.GET('NRN')
                                                                                                        .GET_NUMBER));
                      else
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => NVL(JRPT_PRM.GET('SPREV_VAL')
                                                                                       .GET_STRING
                                                                                      ,JRPT_PRM.GET('SDEF_VAL')
                                                                                       .GET_STRING));
                      end if;
                      BPRMS_SHOW := true;
                    end;
                end case;
                --сформируем атрибуты для дальнейшей идентификации параметра в форме
                SPRM_DEF_ATTRS := 'class="PRM ' || SHTML_INPUT_CLASS ||
                                  '" id="' || JRPT_PRM.GET('SNAME').GET_STRING ||
                                  '" val_type="' ||
                                  TO_CHAR(JRPT_PRM.GET('NVAL_TYPE').GET_NUMBER) ||
                                  '" nprm = "' ||
                                  TO_CHAR(JRPT_PRM.GET('NRN').GET_NUMBER) || '"';
                --сформируем атрибуты для выбора из справочника
                if (JRPT_PRM.GET('NINP_TYPE')
                   .GET_NUMBER in
                    (UDO_PKG_URPT_SRV.NINP_TYPE_UNIT
                    ,UDO_PKG_URPT_SRV.NINP_TYPE_DICT))
                then
                  SDICT_BTN := '<td class="' || STD_CLASS ||
                               '" style="vertical-align:middle;"><img src="' ||
                               V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' ||
                               'dict.png" class="aBtn ' || SBUTTON_CLASS ||
                               '" onclick="showDictionary(''' || JRPT_PRM.GET('SPROMPT')
                              .GET_STRING || ''', ' ||
                               TO_CHAR(JRPT_PRM.GET('NRN').GET_NUMBER) ||
                               ')" style="width:28px; padding:0px; vertical-align:middle;"></td>';
                else
                  SDICT_BTN := ' ';
                end if;
                --сверстаем параметр
                if (SHTML_INPUT_TYPE <> 'checkbox')
                then
                  SPRMS := SPRMS || '<tr ' || SPRM_SHOW_ATTRS || '><td class="' ||
                           STD_CLASS || '"><b>' ||
                           IIF_STR(JRPT_PRM.GET('NREQ').GET_NUMBER
                                  ,'='
                                  ,1
                                  ,'<span style="color:red">*</span>'
                                  ,'') || JRPT_PRM.GET('SPROMPT').GET_STRING ||
                           ':</b></td>';
                  SPRMS := SPRMS || '<td colspan="' ||
                           IIF_STR(SDICT_BTN
                                  ,'<>'
                                  ,' '
                                  ,'1'
                                  ,'2') || '"  class="' || STD_CLASS ||
                           '"><input ' || SPRM_DEF_ATTRS || ' type="' ||
                           SHTML_INPUT_TYPE ||
                           '" style="border:1px solid #3A5A87; padding:5px; margin:0!important;"></td>' ||
                           SDICT_BTN || '</tr><script>$("#' || JRPT_PRM.GET('SNAME')
                          .GET_STRING || '").val(htmlDecode("' || SPRM_VAL ||
                           '"));
                                  </script>';
                else
                  SPRMS := SPRMS || '<tr ' || SPRM_SHOW_ATTRS ||
                           '><td  colspan="3" class="' || STD_CLASS ||
                           '"><label><input ' || SPRM_DEF_ATTRS || ' type="' ||
                           SHTML_INPUT_TYPE || '" ' ||
                           IIF_STR(SPRM_VAL
                                  ,'='
                                  ,'1'
                                  ,'checked'
                                  ,'') || ' />' ||
                           IIF_STR(JRPT_PRM.GET('NREQ').GET_NUMBER
                                  ,'='
                                  ,1
                                  ,'<span style="color:red">*</span>'
                                  ,'') || '<b>' || JRPT_PRM.GET('SPROMPT')
                          .GET_STRING || '</b></label></td></tr>';
                end if;
              end loop;
            end if;
            --закрываем список параметров
            SPRMS := SPRMS || '</table>';
            --кнопка "Печать"
            SPRINT_BTN := '<br>';
            if (UTL_CHECK_SERVICE_ACTIVE)
            then
              SPRINT_BTN := SPRINT_BTN || '<a href="javascript:putReport(' ||
                            TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                            ', 0);" class="' || SBUTTON_HOT_CLASS ||
                            '">Печать</a>&nbsp;';
            end if;
            SPRINT_BTN := SPRINT_BTN || '<a href="javascript:putReport(' ||
                          TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                          ', 1);" class="' || SBUTTON_CLASS ||
                          '">В очередь</a>&nbsp;<a href="javascript:showScheduleAddDialog(' ||
                          TO_CHAR(JRPT.GET('NRN').GET_NUMBER) || ');" class="' ||
                          SBUTTON_CLASS || '">В расписание</a>';
            if (BPRMS_SHOW)
            then
              SPRMS := '<table cellpadding="0" cellspacing="0" class="' ||
                       STABLE_CLASS || '" style="max-width:700px;"><tr class="' ||
                       STR_CLASS || '"><th class="' || STH_CLASS ||
                       '">Параметры</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">' ||
                       SPRMS || SPRINT_BTN || '</td></tr></table>';
            else
              SPRMS := '<table cellpadding="0" cellspacing="0" class="' ||
                       STABLE_CLASS || '" style="max-width:700px;"><tr class="' ||
                       STR_CLASS || '"><th class="' || STH_CLASS ||
                       '">Заказ</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">' ||
                       SPRMS || SPRINT_BTN || '</td></tr></table>';
            end if;
            --пристыкуем параметры к общему HTMLю
            SHTML := SHTML || SPRMS;
            --пропишем функции возврата значений и инициализации виджетов
            SHTML := SHTML || '<script>';
            SHTML := SHTML || 'jQuery(function($){';
            SHTML := SHTML || ' $.datepicker.regional[''ru''] = {';
            SHTML := SHTML || '   closeText: ''Закрыть'',';
            SHTML := SHTML || '   prevText: ''&#x3c;Пред'',';
            SHTML := SHTML || '   nextText: ''След&#x3e;'',';
            SHTML := SHTML || '   currentText: ''Сегодня'',';
            SHTML := SHTML ||
                     '   monthNames: [''Январь'',''Февраль'',''Март'',''Апрель'',''Май'',''Июнь'',';
            SHTML := SHTML ||
                     '''Июль'',''Август'',''Сентябрь'',''Октябрь'',''Ноябрь'',''Декабрь''],';
            SHTML := SHTML ||
                     '   monthNamesShort: [''Янв'', ''Фев'',''Мар'',''Апр'',''Май'',''Июн'',';
            SHTML := SHTML ||
                     '''Июл'',''Авг'',''Сен'',''Окт'',''Ноя'',''Дек''],';
            SHTML := SHTML ||
                     '   dayNames: [''воскресенье'',''понедельник'',''вторник'',''среда'',''четверг'',''пятница'',''суббота''],';
            SHTML := SHTML ||
                     '   dayNamesShort: [''вск'',''пнд'',''втр'',''срд'',''чтв'',''птн'',''сбт''],';
            SHTML := SHTML ||
                     '   dayNamesMin: [''Вс'',''Пн'',''Вт'',''Ср'',''Чт'',''Пт'',''Сб''],';
            SHTML := SHTML || '   weekHeader: ''Не'',';
            SHTML := SHTML || '   dateFormat: ''dd.mm.yy'',';
            SHTML := SHTML || '   firstDay: 1,';
            SHTML := SHTML || '   isRTL: false,';
            SHTML := SHTML || '   showMonthAfterYear: false,';
            SHTML := SHTML || '   yearSuffix: ''''};';
            SHTML := SHTML ||
                     ' $.datepicker.setDefaults($.datepicker.regional[''ru'']);';
            SHTML := SHTML || '});';
            SHTML := SHTML || '$("input.dateInput").datepicker();';
            SHTML := SHTML ||
                     '$("input.dateInput").each(function(){$(this).datepicker("setDate", $.datepicker.parseDate("yy-mm-dd", $(this).val()))});';
            SHTML := SHTML || 'jQuery.fn.get_prm_value = function() {';
            SHTML := SHTML || ' var o = $(this[0]);';
            SHTML := SHTML || ' var val = "";';
            SHTML := SHTML || ' if(o.hasClass("txtInput")) {';
            SHTML := SHTML || '  val = o.val();';
            SHTML := SHTML || ' }';
            SHTML := SHTML || ' if(o.hasClass("dateInput")) {';
            SHTML := SHTML || '  try { ';
            SHTML := SHTML || '   var d = $.datepicker.parseDate("dd.mm.yy", ';
            SHTML := SHTML || '           o.val());';
            SHTML := SHTML ||
                     '   val = $.datepicker.formatDate("yy-mm-dd", d);';
            SHTML := SHTML || '  } catch(e) {';
            SHTML := SHTML ||
                     '   showExecErr("Некорректно указано значение даты ''" + o.val() + "''!");';
            SHTML := SHTML || '   val = "";';
            SHTML := SHTML || '   throw(e);';
            SHTML := SHTML || '  };';
            SHTML := SHTML || ' }';
            SHTML := SHTML || ' if(o.hasClass("checkInput")) {';
            SHTML := SHTML || '  if(o.prop("checked"))';
            SHTML := SHTML || '   val = "1";';
            SHTML := SHTML || '  else';
            SHTML := SHTML || '   val = "0";';
            SHTML := SHTML || ' }';
            SHTML := SHTML || ' return val;';
            SHTML := SHTML || '}';
            SHTML := SHTML || '</script>';
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            --сформируем объектное представление отчета
            JRPT := JSON(CRESP);
            --экранируем строковые поля
            UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC'
                                                   ,OBJ     => JRPT);
            --определим текстовку для типа
            case JRPT.GET('NRPT_TYPE').GET_NUMBER
              when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                STYPE := 'Crystal Reports';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                STYPE := 'MS Excel';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                STYPE := 'Open Office Calc';
              else
                STYPE := 'Неизвестный тип';
            end case;
            --заголовок
            SHTML := '<center><h3>' || JRPT.GET('SNAME').GET_STRING ||
                     '</h3></center>';
            SHTML := SHTML || '<table style="width:100%">';
            --код отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Код:</b></td></tr><tr><td style="padding:4px;">' || JRPT.GET('SCODE')
                    .GET_STRING || '</td></tr>';
            --наименование отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Наименование:</b></td></tr><tr><td style="padding:4px;">' || JRPT.GET('SNAME')
                    .GET_STRING || '</td></tr>';
            --описание отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Описание:</b></td></tr><tr><td style="padding:4px;">' || JRPT.GET('SDESC')
                    .GET_STRING || '</td></tr>';
            --тип отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Тип:</b></td></tr><tr><td style="padding:4px;">' ||
                     STYPE || '</td></tr>';
            --привязка отчета к разделам
            SHTML    := SHTML ||
                        '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Привязка к разделам:</b></td></tr><tr><td style="padding:4px;">';
            JRPT_ULS := JSON_LIST(JRPT.GET('LUS'));
            if (JRPT_ULS.COUNT > 0)
            then
              for I in 1 .. JRPT_ULS.COUNT
              loop
                --считаем привязку
                JRPT_UL := JSON(JRPT_ULS.GET(I));
                --экранируем строковые поля
                UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SUNIT_CODE;SUNIT_NAME'
                                                       ,OBJ     => JRPT_UL);
                --форматируем
                SHTML := SHTML || JRPT_UL.GET('SUNIT_NAME').GET_STRING;
                if (I < JRPT_ULS.COUNT)
                then
                  SHTML := SHTML || ', ';
                end if;
              end loop;
            else
              SHTML := SHTML || 'Нет привязки к разделам';
            end if;
            SHTML := SHTML || '</td></tr>';
            --история печати отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;">' ||
                     IIF_STR(TO_CHAR(JRPT.GET('NCNTQ').GET_NUMBER)
                            ,'<='
                            ,'0'
                            ,''
                            ,'<a href="f?p=' || V('APP_ID') || ':14:' ||
                             V('APP_SESSION') || '::' || V('DEBUG') ||
                             '::P14_NREPORT:' ||
                             TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                             '" data-role="button" data-corners="false" class="aBtn">Печатался ' ||
                             TO_CHAR(JRPT.GET('NCNTQ').GET_NUMBER) ||
                             ' раз(а)</a>') || '</td></tr>';
            --избранность отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;">' ||
                     '<label data-corners="false" ><input onclick="ToggleFavor(' ||
                     TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                     ');" class="checkInput" type="checkbox" ' ||
                     IIF_STR(TO_CHAR(JRPT.GET('NFAVOR').GET_NUMBER)
                            ,'='
                            ,TO_CHAR(UDO_PKG_URPT_SRV.NFAVOR_YES)
                            ,'checked'
                            ,'') || ' />Избранное</label>' || '</td></tr>';
            SHTML := SHTML || '</table>';
            --расписание
            if (JRPT.GET('NSCHEDULED').GET_NUMBER > 0)
            then
              JRPT_SCHS := JSON_LIST(JRPT.GET('SCHS'));
              if (JRPT_SCHS.COUNT > 0)
              then
                --расписание - начало
                SHTML := SHTML ||
                         '<center><h3>Расписание</h3></center><table style="width:100%">';
                --идем по расписаниям
                for I in 1 .. JRPT_SCHS.COUNT
                loop
                  JRPT_SCH := JSON(JRPT_SCHS.GET(I));
                  --верстаем позицию расписания
                  declare
                    SSCH_TYPE varchar2(200); --тип расписания (строковое представление)
                  begin
                    --определим тип расписания (строковое представление)
                    case JRPT_SCH.GET('NSCHED_TYPE').GET_NUMBER
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_MIN then
                        SSCH_TYPE := 'Ежеминутно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_HOUR then
                        SSCH_TYPE := 'Каждый час';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_DAY then
                        SSCH_TYPE := 'Ежедневно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_WEEK then
                        SSCH_TYPE := 'Еженедельно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_MONTH then
                        SSCH_TYPE := 'Ежемесячно';
                      when UDO_PKG_URPT_SRV.NSCHED_TYPE_ONCE then
                        SSCH_TYPE := 'Единовременно';
                      else
                        SSCH_TYPE := 'Неизвестный тип расписания';
                    end case;
                    --сформируем HTML
                    SHTML := SHTML ||
                             '<tr style="background-color:#CFE0F1;"><td style="padding:4px;width:100%"><b>' ||
                             SSCH_TYPE || '</b><br>' ||
                             IIF_STR(JRPT_SCH.GET('NSCHED_TYPE').GET_NUMBER
                                    ,'='
                                    ,UDO_PKG_URPT_SRV.NSCHED_TYPE_ONCE
                                    , 'Исполнить ' || JRPT_SCH.GET('DSTART_DATE')
                                     .GET_STRING
                                    , 'Начать ' || JRPT_SCH.GET('DSTART_DATE')
                                     .GET_STRING || ' с шагом ' ||
                                      TO_CHAR(JRPT_SCH.GET('NSTEP').GET_NUMBER)) ||
                             IIF_STR(JRPT_SCH.GET('NMAIL').GET_NUMBER
                                    ,'='
                                    ,UDO_PKG_URPT_SRV.NMAIL_YES
                                    ,', доставить по e-mail'
                                    ,'') ||
                             '</td><td style="vertical-align:middle;"><a href="javascript:removeSchedule(''' ||
                             TO_CHAR(JRPT.GET('NRN').GET_NUMBER) || ''', ''' ||
                             TO_CHAR(JRPT_SCH.GET('NRN').GET_NUMBER) ||
                             ''')" style="width:44px" class="aBtn" data-corners="false" data-mini="true" data-inline="true" data-theme="b"><img src="' ||
                             V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' ||
                             'remove.png" style="width:24px; padding:0px; vertical-align:middle;"></a></td></tr>';
                  end;
                end loop;
                --расписание - окончание
                SHTML := SHTML || '</table>';
              end if;
            end if;
            --возможность доставки по e-mail
            SHTML := SHTML || '<input type="hidden" id="canMail" value="' ||
                     TO_CHAR(JRPT.GET('NMAIL_ENABLED').GET_NUMBER) || '">';
            --адрес доставки по e-mail
            SHTML := SHTML || '<input type="hidden" id="addrMail" value="' || JRPT.GET('SMAIL')
                    .GET_STRING || '">';
            --параметры отчета
            JRPT_PRMS := JSON_LIST(JRPT.GET('PRMS'));
            if (JRPT_PRMS.COUNT > 0)
            then
              --фалг - визуализируемых нет
              BPRMS_SHOW := false;
              --открываем список параметров
              SPRMS := '<table style="width:100%">';
              --идем по параметрам
              for I in 1 .. JRPT_PRMS.COUNT
              loop
                JRPT_PRM := JSON(JRPT_PRMS.GET(I));
                --экранируем строковые поля
                UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SPROMPT;SPREV_VAL;SDEF_VAL'
                                                       ,OBJ     => JRPT_PRM);
                --разберем тип параметра и выставим правильный элемент формы ввода для него
                case JRPT_PRM.GET('NVAL_TYPE').GET_NUMBER
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_STR then
                    SHTML_INPUT_TYPE  := 'text';
                    SHTML_INPUT_CLASS := 'txtInput';
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_NUMB then
                    SHTML_INPUT_TYPE  := 'number';
                    SHTML_INPUT_CLASS := 'txtInput';
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_DATE then
                    SHTML_INPUT_TYPE  := 'date';
                    SHTML_INPUT_CLASS := 'txtInput';
                  when UDO_PKG_URPT_SRV.NVAL_TYPE_BOOL then
                    SHTML_INPUT_TYPE  := 'checkbox';
                    SHTML_INPUT_CLASS := 'checkInput';
                  else
                    SHTML_INPUT_TYPE := '';
                end case;
                --определим атрибут отображения параметра и его значение по умолчанию
                case JRPT_PRM.GET('NINP_TYPE').GET_NUMBER
                --если инициализация организацией - не показываем
                  when UDO_PKG_URPT_SRV.NINP_TYPE_COMPANY then
                    SPRM_SHOW_ATTRS := 'style="display:none"';
                    SPRM_VAL        := TO_CHAR(NCOMPANY);
                    --если инициализация идентификатором отмеченных записей - не показываем
                  when UDO_PKG_URPT_SRV.NINP_TYPE_SL_IDENT then
                    SPRM_SHOW_ATTRS := 'style="display:none"';
                    SPRM_VAL        := TO_CHAR(PKG_SESSION_VARS.GET_NUM(SNAME => SSESSION_VAL_SL_IDENT));
                    --если инициализация идентификатором текущего документа  - не показываем
                  when UDO_PKG_URPT_SRV.NINP_TYPE_DOC_RN then
                    SPRM_SHOW_ATTRS := 'style="display:none"';
                    SPRM_VAL        := TO_CHAR(PKG_SESSION_VARS.GET_NUM(SNAME => SSESSION_VAL_DOC_RN));
                    --если инициализация кодом текущего раздела
                  when UDO_PKG_URPT_SRV.NINP_TYPE_UNIT then
                    --если код текущего раздела установлен в контексте - не показываем
                    if (PKG_SESSION_VARS.GET_STR(SNAME   => SSESSION_VAL_UNITCODE
                                                --,SDEFVAL => null -- релиз 20/06/2018 Бухвин
                                                ) is not null)
                    then
                      SPRM_SHOW_ATTRS := 'style="display:none"';
                      SPRM_VAL        := PKG_SESSION_VARS.GET_STR(SNAME => SSESSION_VAL_UNITCODE);
                    else
                      --иначе - показываем и даем выбрать из разделов, к которым привязан отчет
                      SPRM_SHOW_ATTRS := '';
                      if (UTL_PRM_SAVED(SUSER => SUSER
                                       ,NPRM  => JRPT_PRM.GET('NRN').GET_NUMBER) = 1)
                      then
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => UTL_PRM_GET(SUSER => SUSER
                                                                                              ,NPRM  => JRPT_PRM.GET('NRN')
                                                                                                        .GET_NUMBER));
                      else
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => NVL(JRPT_PRM.GET('SPREV_VAL')
                                                                                       .GET_STRING
                                                                                      ,JRPT_PRM.GET('SDEF_VAL')
                                                                                       .GET_STRING));
                      end if;
                      BPRMS_SHOW := true;
                    end if;
                  else
                    begin
                      --инчае - показываем и выставляем флаг наличия визуализируемых, а так же определим значение параметра, демонстрируемое пользователю
                      SPRM_SHOW_ATTRS := '';
                      if (UTL_PRM_SAVED(SUSER => SUSER
                                       ,NPRM  => JRPT_PRM.GET('NRN').GET_NUMBER) = 1)
                      then
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => UTL_PRM_GET(SUSER => SUSER
                                                                                              ,NPRM  => JRPT_PRM.GET('NRN')
                                                                                                        .GET_NUMBER));
                      else
                        SPRM_VAL := UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => NVL(JRPT_PRM.GET('SPREV_VAL')
                                                                                       .GET_STRING
                                                                                      ,JRPT_PRM.GET('SDEF_VAL')
                                                                                       .GET_STRING));
                      end if;
                      BPRMS_SHOW := true;
                    end;
                end case;
                --сформируем атрибуты для дальнейшей идентификации параметра в форме
                SPRM_DEF_ATTRS := 'class="PRM ' || SHTML_INPUT_CLASS ||
                                  '" id="' || JRPT_PRM.GET('SNAME').GET_STRING ||
                                  '" val_type="' ||
                                  TO_CHAR(JRPT_PRM.GET('NVAL_TYPE').GET_NUMBER) ||
                                  '" nprm = "' ||
                                  TO_CHAR(JRPT_PRM.GET('NRN').GET_NUMBER) || '"';
                --сформируем атрибуты для выбора из справочника
                if (JRPT_PRM.GET('NINP_TYPE')
                   .GET_NUMBER in
                    (UDO_PKG_URPT_SRV.NINP_TYPE_UNIT
                    ,UDO_PKG_URPT_SRV.NINP_TYPE_DICT))
                then
                  SDICT_BTN := '<td style="width:48px"><a href="javascript:OpenDictionary(''f?p=' ||
                               V('APP_ID') || ':17:' || V('APP_SESSION') || '::' ||
                               V('DEBUG') || '::P17_NPRM:' ||
                               TO_CHAR(JRPT_PRM.GET('NRN').GET_NUMBER) ||
                               ''')" style="width:44px" class="aBtn" data-corners="false" data-mini="true" data-inline="true" data-theme="b"><img src="' ||
                               V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' ||
                               'dict.png" style="width:24px"></a></td>';
                else
                  SDICT_BTN := ' ';
                end if;
                --сверстаем параметр
                if (SHTML_INPUT_TYPE <> 'checkbox')
                then
                  SPRMS := SPRMS || '<tr ' || SPRM_SHOW_ATTRS ||
                           '><td colspan="2"><b>' ||
                           IIF_STR(JRPT_PRM.GET('NREQ').GET_NUMBER
                                  ,'='
                                  ,1
                                  ,'<span style="color:red">*</span>'
                                  ,'') || JRPT_PRM.GET('SPROMPT').GET_STRING ||
                           '</b></td></tr>';
                  SPRMS := SPRMS || '<tr ' || SPRM_SHOW_ATTRS ||
                           '><td colspan="' || IIF_STR(SDICT_BTN
                                                      ,'<>'
                                                      ,' '
                                                      ,'1'
                                                      ,'2') || '"><input ' ||
                           SPRM_DEF_ATTRS || ' type="' || SHTML_INPUT_TYPE ||
                           '" ></td>' || SDICT_BTN || '</tr><script>$("#' || JRPT_PRM.GET('SNAME')
                          .GET_STRING || '").val(htmlDecode("' || SPRM_VAL ||
                           '"));</script>';
                else
                  SPRMS := SPRMS || '<tr ' || SPRM_SHOW_ATTRS ||
                           '><td colspan="2"><label data-corners="false"><input ' ||
                           SPRM_DEF_ATTRS || ' type="' || SHTML_INPUT_TYPE || '" ' ||
                           IIF_STR(SPRM_VAL
                                  ,'='
                                  ,'1'
                                  ,'checked'
                                  ,'') || ' />' ||
                           IIF_STR(JRPT_PRM.GET('NREQ').GET_NUMBER
                                  ,'='
                                  ,1
                                  ,'<span style="color:red">*</span>'
                                  ,'') || JRPT_PRM.GET('SPROMPT').GET_STRING ||
                           '</label></td></tr>';
                end if;
              end loop;
              SPRMS := SPRMS || '</table>';
            else
              BPRMS_SHOW := false;
            end if;
            if (BPRMS_SHOW)
            then
              SPRMS := '<center><h3>Параметры</h3></center>' || SPRMS;
            end if;
            --пристыкуем параметры к общему HTMLю
            SHTML := SHTML || SPRMS;
            --кнопка "Печать"
            if (UTL_CHECK_SERVICE_ACTIVE)
            then
              SHTML := SHTML || '<a href="javascript:PutReport(' ||
                       TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                       ', 0);" data-role="button" data-corners="false" data-theme="' ||
                       SBUTTON_HOT_CLASS || '" class="aBtn">Печать</a>';
            end if;
            --кнопка "В очередь"
            SHTML := SHTML || '<a href="javascript:PutReport(' ||
                     TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                     ', 1);" data-role="button" data-corners="false" data-theme="' ||
                     SBUTTON_CLASS || '" class="aBtn">В очередь</a>';
            --кнопка "В расписание"
            SHTML := SHTML || '<a href="javascript:showShceduleAdd(' ||
                     TO_CHAR(JRPT.GET('NRN').GET_NUMBER) ||
                     ');" data-role="button" data-corners="false" data-theme="' ||
                     SBUTTON_CLASS || '" class="aBtn">В расписание</a>';
            --инициализируем виджеты
            SHTML := SHTML ||
                     '<script>$(".aBtn").button();$(".txtInput").textinput();$(".checkInput").checkboxradio();</script>';
            --пропишем функцию возврата значения
            SHTML := SHTML || '<script>';
            SHTML := SHTML || 'jQuery.fn.get_prm_value = function() {';
            SHTML := SHTML || ' var o = $(this[0]);';
            SHTML := SHTML || ' var val = "";';
            SHTML := SHTML || ' if(o.hasClass("txtInput")) {';
            SHTML := SHTML || '  val = o.val();';
            SHTML := SHTML || ' }';
            SHTML := SHTML || ' if(o.hasClass("checkInput")) {';
            SHTML := SHTML || '  if(o.prop("checked"))';
            SHTML := SHTML || '   val = "1";';
            SHTML := SHTML || '  else';
            SHTML := SHTML || '   val = "0";';
            SHTML := SHTML || ' }';
            SHTML := SHTML || ' return val;';
            SHTML := SHTML || '}';
            SHTML := SHTML || '</script>';
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML со списком записей словаря, привязанного к параметру отчета
  function HTML_REPORT_PRM_DICT_RECS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    JRESP              JSON; --объектное представление ответа сервиса отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JRECS              JSON_LIST; --объектное представление списка записей раздела
    JREC               JSON; --объектное представлеие записи раздела
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
    SGRP               varchar2(200); --наименование группы для записей (наименование раздела)
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - рег. номер параметра отчета
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PRM_KEY
                          ,PAIR_VALUE => NPRM);
    --параметры действия - строка поиска
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SEARCH_KEY
                          ,PAIR_VALUE => SSEARCH);
    --параметры действия - номер порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_KEY
                          ,PAIR_VALUE => NPORTION);
    --параметры действия - кол-во записей в порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_SIZE_KEY
                          ,PAIR_VALUE => NPORTION_SIZE);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_PRM_DICT_RECS_GET_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим список записей словаря, привязанного к параметру
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это список записей - будем разбирать
    if (NRESP_TYPE is null)
    then
      --разбираем ответ и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть записи словаря и это действительно список
            if ((JRESP.EXIST('DICT_RECS')) and
               (JRESP.GET('DICT_RECS').IS_ARRAY) and
               (JRESP.EXIST('SUNIT_NAME')) and
               (JRESP.GET('SUNIT_NAME').IS_STRING))
            then
              --то разбираем его
              JRECS := JSON_LIST(JRESP.GET('DICT_RECS'));
              --если он не пустой
              if (JRECS.COUNT > 0)
              then
                SHTML := '';
                --идем по списку записей раздела
                for I in 1 .. JRECS.COUNT
                loop
                  --считаем элемент из списка
                  JREC := JSON(JRECS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SVAL;SCODE;SDESC'
                                                         ,OBJ     => JREC);
                  --сверстаем элемент
                  SHTML := SHTML || '<tr class="' || STR_CLASS ||
                           '"><td style="vertical-align:middle; width:5%; padding-right:5px;"><input  class="DICT_CHECK" valueID="' ||
                           TO_CHAR(JREC.GET('NRN').GET_NUMBER) ||
                           '" type="checkbox" onclick="addPrmSelection(' ||
                           TO_CHAR(NPRM) || ', ' ||
                           TO_CHAR(JREC.GET('NRN').GET_NUMBER) || ', ''' ||
                           replace(JREC.GET('SVAL').GET_STRING
                                  ,CHR(13)
                                  ,'<br>') || ''', ''' ||
                           replace(JREC.GET('SDESC').GET_STRING
                                  ,CHR(13)
                                  ,'<br>') ||
                           ''', this.checked);"></td><td class="' || STD_CLASS ||
                           ' DICT_VAL" valueID="' ||
                           TO_CHAR(JREC.GET('NRN').GET_NUMBER) || '">';
                  SHTML := SHTML || '<a href="javascript:;" onclick="setPrm(' ||
                           TO_CHAR(NPRM) || ',''' || JREC.GET('SVAL')
                          .GET_STRING || ''');">';
                  SHTML := SHTML || '<table style="width:100%">';
                  SHTML := SHTML || '<tr><td><b>' || JREC.GET('SCODE')
                          .GET_STRING || '</b></td></tr>';
                  SHTML := SHTML || '<tr><td>' ||
                           replace(JREC.GET('SDESC').GET_STRING
                                  ,CHR(13)
                                  ,'<br>') || '</td></tr>';
                  SHTML := SHTML || '</table>';
                  SHTML := SHTML || '</a>';
                  SHTML := SHTML || '</td></tr>';
                end loop;
                SHTML := SHTML ||
                         '<tr id="loadMore"><td colspan="2" style="padding-top:10px;"><center><a href="javascript:$(''#loadMore'').remove();loadDictionaryData(' ||
                         TO_CHAR(NPRM) || ', ' || TO_CHAR(NPORTION + 1) ||
                         ', true)"><b>ЕЩЁ</b></a></center></td></tr>';
              else
                --если он пустой - прячем кнопку "Ещё" - нет больше записей
                SHTML := SHTML || '<script>$("#loadMore").remove();</script>';
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть записи словаря и это действительно список
            if ((JRESP.EXIST('DICT_RECS')) and
               (JRESP.GET('DICT_RECS').IS_ARRAY) and
               (JRESP.EXIST('SUNIT_NAME')) and
               (JRESP.GET('SUNIT_NAME').IS_STRING))
            then
              --считаем из ответа код раздела
              SGRP := JRESP.GET('SUNIT_NAME').GET_STRING;
              --то разбираем его
              JRECS := JSON_LIST(JRESP.GET('DICT_RECS'));
              --если он не пустой
              if (JRECS.COUNT > 0)
              then
                SHTML := '';
                --идем по списку записей раздела
                for I in 1 .. JRECS.COUNT
                loop
                  --считаем элемент из списка
                  JREC := JSON(JRECS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SVAL;SCODE;SDESC'
                                                         ,OBJ     => JREC);
                  --сверстаем элемент
                  SHTML := SHTML || '<li group-name="' || SGRP || '">';
                  SHTML := SHTML || '<table style="width:100%">';
                  SHTML := SHTML || '<tr>';
                  SHTML := SHTML ||
                           '<td style="vertical-align:middle;width:3%;">';
                  SHTML := SHTML ||
                           '<a class="aBtn DICT_CHECK" data-corners="false" data-inline="true" data-icon="check" data-iconpos="notext" valueID="' ||
                           TO_CHAR(JREC.GET('NRN').GET_NUMBER) ||
                           '" href="javascript:addPrmSelection(' ||
                           TO_CHAR(NPRM) || ', ' ||
                           TO_CHAR(JREC.GET('NRN').GET_NUMBER) || ', ''' ||
                           replace(JREC.GET('SVAL').GET_STRING
                                  ,CHR(13)
                                  ,'<br>') || ''', ''' ||
                           replace(JREC.GET('SDESC').GET_STRING
                                  ,CHR(13)
                                  ,'<br>') || ''');">Check';
                  SHTML := SHTML || '</a>';
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML ||
                           '<td style="padding-left:10px;cursor:pointer;width:100%" class="DICT_VAL" valueID="' ||
                           TO_CHAR(JREC.GET('NRN').GET_NUMBER) ||
                           '" onclick="SetPrm(' || TO_CHAR(NPRM) || ',''' || JREC.GET('SVAL')
                          .GET_STRING || ''');">';
                  SHTML := SHTML || '<h3 style="white-space:normal;">' || JREC.GET('SCODE')
                          .GET_STRING || '</h3>';
                  SHTML := SHTML || '<p style="white-space:normal;">' ||
                           replace(JREC.GET('SDESC').GET_STRING
                                  ,CHR(13)
                                  ,'<br>') || '</p>';
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '</tr>';
                  SHTML := SHTML || '</table>';
                  SHTML := SHTML || '</li>';
                end loop;
                SHTML := SHTML ||
                         '<script>$("#Recs").listview({autodividers:true,autodividersSelector:function(li){return li.attr("group-name");}});</script>';
                SHTML := SHTML || '<script>$(".aBtn").button();</script>';
              else
                --если он пустой - прячем кнопку "Ещё" - нет больше записей
                SHTML := SHTML ||
                         '<script>$("#P17_GET_MORE").button("disable");</script>';
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML со списком позиций очереди
  function HTML_REPORTQS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    JRESP              JSON; --объектное представление ответа сервиса отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JRPTQS             JSON_LIST; --объектное представление списка позиций очереди из ответа
    JRPTQ              JSON; --объектное представлеие позиции очереди из списка позиций из ответа
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
    SIMG               varchar2(200); --картинка для позиции очереди
    SGRP               varchar2(200); --наименование группы для позиции очереди
    SSTATE             varchar2(200); --текстовое представление состояния позиции очереди
    SORDERED           varchar2(200); --текстовое представление даты заказа позиции очереди
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - организация
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_COMPANY_KEY
                          ,PAIR_VALUE => NCOMPANY);
    --параметры действия - рег. номер пользовательского отчета
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                          ,PAIR_VALUE => NREPORT);
    --параметры действия - строка поиска
    if (SSEARCH is not null)
    then
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SEARCH_KEY
                            ,PAIR_VALUE => SSEARCH);
    end if;
    --параметры действия - номер порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_KEY
                          ,PAIR_VALUE => NPORTION);
    --параметры действия - кол-во записей в порции
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PORTION_SIZE_KEY
                          ,PAIR_VALUE => NPORTION_SIZE);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTQS_GET_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим список позиций очереди
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это список отчетов - будем разбирать
    if (NRESP_TYPE is null)
    then
      --разбираем ответ и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          declare
            NFIRST number(17); --рег. номер первого отчета
            --формирование элемента списка
            function BUILD_ITEM
            (
              NREPORTQ      number --рег. номер позиции очереди
             ,SREPORTQ_NAME varchar2 --наименование позиции очереди
             ,SREPORTQ_DESC varchar2 --описание позиции очереди
             ,SSTATE        varchar2 --состояние позиции очереди
             ,NSCHEDULED    number --признак наличия расписания (0 - нет, 1 - да)
             ,SIMG          varchar2 --иконка
            ) return varchar2 is
              SRES varchar2(4000); --результат работы
            begin
              --сверстаем элемент
              SRES := '<tr onclick="loadReportQ($(this));" reportq="' ||
                      TO_CHAR(NREPORTQ) || '" class="' || STR_CLASS ||
                      '"><td class="' || STD_CLASS ||
                      '"><table><tr><td rowspan="2" style="padding-right:5px;vertical-align:middle;"><img style="height:48px;width:48px" src="' ||
                      V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' || SIMG ||
                      '"></td><td style="margin-right:5px"><div style="padding-bottom:4px"><b>' ||
                      SREPORTQ_NAME || '</b></div>' || SSTATE ||
                      '</td></tr><tr><td style="font-size:80%;margin-right:5px">' ||
                      SREPORTQ_DESC ||
                      IIF_STR(TO_CHAR(NSCHEDULED)
                             ,'='
                             ,TO_CHAR(0)
                             ,''
                             ,'<p style="width:100%; text-align:right; font-size:80%; font-weight:bold; color:green;">ИСПОЛНЕН ПО РАСПИСАНИЮ</p>') ||
                      '</td></tr></table></td><td class="rptl_list_item_selector" style="width:5px"></td></tr>';
              --вернем результат
              return SRES;
            end;

          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть отчеты и это действительно список
            if ((JRESP.EXIST('REPORTQS')) and (JRESP.GET('REPORTQS').IS_ARRAY))
            then
              --то разбираем его
              JRPTQS := JSON_LIST(JRESP.GET('REPORTQS'));
              --если он не пустой
              if (JRPTQS.COUNT > 0)
              then
                SHTML := '';
                --идем по элементам списка
                for I in 1 .. JRPTQS.COUNT
                loop
                  --считаем очередной элемент
                  JRPTQ := JSON(JRPTQS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC'
                                                         ,OBJ     => JRPTQ);
                  --определим текст для даты заказа
                  if (NREPORT is not null)
                  then
                    SORDERED := ', заказан ' || JRPTQ.GET('DQUEUE_TS')
                               .GET_STRING;
                  else
                    SORDERED := '';
                  end if;
                  --определим текст для состояния элемента
                  case JRPTQ.GET('NQUEUE_STATE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_INS then
                      SSTATE := '<span style="background-color:orange;text-shadow:none;color:black;padding-right:3px;padding-left:3px;font-size:80%;">Выполняется' ||
                                SORDERED || '</span>';
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_RUN then
                      SSTATE := '<span style="background-color:orange;text-shadow:none;color:black;padding-right:3px;padding-left:3px;font-size:80%;">Выполняется' ||
                                SORDERED || '</span>';
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_OK then
                      SSTATE := '<span style="background-color:green;text-shadow:none;color:white;padding-right:3px;padding-left:3px;font-size:80%;">Выполнен успешно' ||
                                SORDERED || '</span>';
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR then
                      SSTATE := '<span style="background-color:red;text-shadow:none;color:white;padding-right:3px;padding-left:3px;font-size:80%;">Выполнен с ошибками' ||
                                SORDERED || '</span>';
                    else
                      SSTATE := '';
                  end case;
                  --определим картинку элемента
                  case JRPTQ.GET('NTYPE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                      SIMG := 'icon_cr.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                      SIMG := 'icon_excel.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                      SIMG := 'icon_ooc.png';
                    else
                      SIMG := 'menu\menu-page-128.png';
                  end case;
                  --сверстаем его
                  SHTML := SHTML || BUILD_ITEM(NREPORTQ      => JRPTQ.GET('NRN')
                                                                .GET_NUMBER
                                              ,SREPORTQ_NAME => JRPTQ.GET('SNAME')
                                                                .GET_STRING
                                              ,SREPORTQ_DESC => JRPTQ.GET('SDESC')
                                                                .GET_STRING
                                              ,SSTATE        => SSTATE
                                              ,NSCHEDULED    => JRPTQ.GET('NSCHEDULED')
                                                                .GET_NUMBER
                                              ,SIMG          => SIMG);
                  --запомним первый
                  if (I = 1)
                  then
                    NFIRST := JRPTQ.GET('NRN').GET_NUMBER;
                  end if;
                end loop;
                --завершаем вёрстку
                SHTML := '<table cellspacing="0" cellpadding="0" class="' ||
                         STABLE_CLASS || '">' || SHTML || '</table>';
                --позиционируемся на первом отчете в списке
                if (NFIRST is not null)
                then
                  SHTML := SHTML || '<script>loadReportQ($("tr.' || STR_CLASS ||
                           '[reportq=' || TO_CHAR(NFIRST) || ']"))</script>';
                end if;
              else
                --если он пустой - нет отчетов
                SHTML := '';
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть отчеты и это действительно список
            if ((JRESP.EXIST('REPORTQS')) and (JRESP.GET('REPORTQS').IS_ARRAY))
            then
              --то разбираем его
              JRPTQS := JSON_LIST(JRESP.GET('REPORTQS'));
              --если он не пустой
              if (JRPTQS.COUNT > 0)
              then
                SHTML := '';
                --идем по списку элементов очереди
                for I in 1 .. JRPTQS.COUNT
                loop
                  --считаем элемент из списка
                  JRPTQ := JSON(JRPTQS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC'
                                                         ,OBJ     => JRPTQ);
                  --сформируем заголовок группы
                  SGRP := 'По дате заказа';
                  if (TRUNC(TO_DATE(JRPTQ.GET('DQUEUE_TS').GET_STRING
                                   ,'yyyy-mm-dd hh24:mi:ss')) = TRUNC(sysdate))
                  then
                    SGRP := 'Сегодня';
                  end if;
                  if (TRUNC(TO_DATE(JRPTQ.GET('DQUEUE_TS').GET_STRING
                                   ,'yyyy-mm-dd hh24:mi:ss')) =
                     TRUNC(sysdate - 1))
                  then
                    SGRP := 'Вчера';
                  end if;
                  if (TRUNC(TO_DATE(JRPTQ.GET('DQUEUE_TS').GET_STRING
                                   ,'yyyy-mm-dd hh24:mi:ss')) <=
                     TRUNC(sysdate - 2))
                  then
                    SGRP := 'Ранее';
                  end if;
                  --определим текст для состояния элемента
                  case JRPTQ.GET('NQUEUE_STATE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_INS then
                      SSTATE := '<span style="background-color:orange;text-shadow:none;color:black;padding:3px;font-weight:bold;">Выполняется</span>';
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_RUN then
                      SSTATE := '<span style="background-color:orange;text-shadow:none;color:black;padding:3px;font-weight:bold;">Выполняется</span>';
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_OK then
                      SSTATE := '<span style="background-color:green;text-shadow:none;color:white;padding:3px;font-weight:bold;">Выполнен успешно</span>';
                    when UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR then
                      SSTATE := '<span style="background-color:red;text-shadow:none;color:white;padding:3px;font-weight:bold;">Выполнен с ошибками</span>';
                    else
                      SSTATE := '';
                  end case;
                  --определим картинку элемента
                  case JRPTQ.GET('NTYPE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                      SIMG := 'icon_cr.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                      SIMG := 'icon_excel.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                      SIMG := 'icon_ooc.png';
                    else
                      SIMG := 'menu\menu-page-128.png';
                  end case;
                  --сверстаем элемент
                  SHTML := SHTML || '<li group-name="' || SGRP || '">';
                  SHTML := SHTML || '<a href="f?p=' || V('APP_ID') || ':16:' ||
                           V('APP_SESSION') || '::' || V('DEBUG') ||
                           '::P16_REPORTQ:' ||
                           TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) || '">';
                  SHTML := SHTML || '<table style="width:100%">';
                  SHTML := SHTML || '<tr>';
                  SHTML := SHTML || '<td>';
                  SHTML := SHTML || '<img style="height:64px;width:64px" src="' ||
                           V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' || SIMG || '">';
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '<td style="padding-left:10px;width:100%">';
                  SHTML := SHTML || '<h3 style="white-space:normal;">' || JRPTQ.GET('SNAME')
                          .GET_STRING || '</h3>';
                  SHTML := SHTML ||
                           '<p style="white-space:normal;text-align:left;">' ||
                           SSTATE || '</p>';
                  SHTML := SHTML ||
                           '<p style="white-space:normal;text-align:left;">Заказан: ' || JRPTQ.GET('DQUEUE_TS')
                          .GET_STRING || '</p>' ||
                           IIF_STR(TO_CHAR(JRPTQ.GET('NSCHEDULED').GET_NUMBER)
                                  ,'='
                                  ,TO_CHAR(0)
                                  ,''
                                  ,'<p style="width:100%; text-align:right; font-size:60%; font-weight:bold; color:green;">ИСПОЛНЕН ПО РАСПИСАНИЮ</p>');
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '</tr>';
                  SHTML := SHTML || '</table>';
                  SHTML := SHTML || '</a>';
                  SHTML := SHTML || '<a href="javascript:downloadReport(' ||
                           TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) ||
                           ');" data-icon="download" data-theme="c"></a>';
                  SHTML := SHTML || '</li>';
                end loop;
                SHTML := SHTML ||
                         '<script>$("#UsrRptQs").listview({autodividers:true,autodividersSelector:function(li){return li.attr("group-name");}});</script>';
              else
                --если он пустой - прячем кнопку "Ещё" - нет больше отчетов
                SHTML := SHTML ||
                         '<script>$("#P14_GET_MORE").button("disable");</script>';
              end if;
            else
              P_EXCEPTION(0
                         ,'Неожиданный ответ сервера!');
            end if;
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML с детализацией по позиции очереди
  function HTML_REPORTQ_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORTQ          number --рег. номер позиции очереди
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JRPTQ              JSON; --объектное представлеие позиции очереди из ответа
    JRPTQ_PRMS         JSON_LIST; --объектное представление списка параметров позиции очереди
    JRPTQ_PRM          JSON; --объектное представление параметра позиции очереди
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SHTML              clob; --свёрстанный HTML
    SERR               varchar2(4000); --буфер для ошибок
    STYPE              varchar2(200); --текстовое описание типа позиции очереди
    SSTATE             varchar2(200); --текстовое описание состояния позиции очереди
    SSTATE_COLOR       varchar2(200); --текстовое описание цвета состояния позиции очереди
    SSCH               varchar2(200); --текстовое описание способа добавления отчета в очередь
    SSCH_COLOR         varchar2(200); --текстовое описание цвета способа добавления отчета в очередь
    SMAIL              varchar2(200); --текстовое описание состояния отправки отчета по e-mail
    SMAIL_COLOR        varchar2(200); --текстовое описание цвета состояния отправки отчета по e-mail
    SDESC_WIDTH        varchar2(20) := '150px'; --ширина колонки полей описания
    SPRMS              clob; --буфер для верстки параметров
    SPRM_ROW_STYLE     varchar2(2000); --стиль строки параметра
    BPRMS_SHOW         boolean := false; --признак наличия параметров
    SVAL               varchar2(4000); --преобразованное для публикации значение параметра позиции очереди
  begin
    --сформируем запрос к сервису - инициализация объекта
    JREQ               := JSON();
    JREQ_PRMS          := JSON();
    JREQ_PRMS_ACT_PRMS := JSON();
    --параметры действия - рег. номер позиции очереди
    JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORTQ_KEY
                          ,PAIR_VALUE => NREPORTQ);
    --пользователь
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                 ,PAIR_VALUE => SUSER);
    --сессия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                 ,PAIR_VALUE => SSESSION);
    --действие
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                 ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTQ_GET_VAL);
    --параеметры действия
    JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                 ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
    --теперь всё в запрос
    JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
            ,PAIR_VALUE => JREQ_PRMS);
    --конвертируем объектное представление в текст
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                            ,CACHE   => false);
    JREQ.TO_CLOB(BUF => CREQ);
    --запросим детали позиции очереди
    CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    --проверим ответ на наличие ошибок
    UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                        ,NRESP_TYPE => NRESP_TYPE
                                        ,SRESP_MSG  => SRESP_MSG);
    --если пришел не стандартный ответ, а просто данные - значит это позиция очереди - будем разбирать
    if (NRESP_TYPE is null)
    then
      --разбираем ответ и формируем HTML
      case NINTERFACE
      --для десктопа
        when NINTERFACE_DESKTOP then
          begin
            --сформируем объектное представление отчета
            JRPTQ := JSON(CRESP);
            --экранируем строковые поля
            UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC;SEXEC_TIME;SERR'
                                                   ,OBJ     => JRPTQ);
            --определим текстовку для типа
            case JRPTQ.GET('NTYPE').GET_NUMBER
              when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                STYPE := 'Crystal Reports';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                STYPE := 'MS Excel';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                STYPE := 'Open Office Calc';
              else
                STYPE := 'Неизвестный тип';
            end case;
            --опредлим текстовку и цвет для состояния
            case JRPTQ.GET('NQUEUE_STATE').GET_NUMBER
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_INS then
                SSTATE       := 'Выполняется';
                SSTATE_COLOR := 'orange';
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_RUN then
                SSTATE       := 'Выполняется';
                SSTATE_COLOR := 'orange';
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_OK then
                SSTATE       := 'Выполнен успешно';
                SSTATE_COLOR := 'green';
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR then
                SSTATE       := 'Выполнен с ошибками';
                SSTATE_COLOR := 'red';
              else
                SSTATE       := 'Неопределенное состояние';
                SSTATE_COLOR := 'black';
            end case;
            --определим текстовку и цвет для способа постановки в очередь
            case JRPTQ.GET('NSCHEDULED').GET_NUMBER
              when UDO_PKG_URPT_SRV.NSCHEDULED_NO then
                SSCH       := 'Заказан вручную';
                SSCH_COLOR := 'black';
              when UDO_PKG_URPT_SRV.NSCHEDULED_YES then
                SSCH       := 'Заказан автоматически, по заданному расписанию';
                SSCH_COLOR := 'green';
              else
                SSCH       := 'Неопределенный способ заказа отчета';
                SSCH_COLOR := 'red';
            end case;
            --определим текстовку и цвет для статуса отправки по e-mail
            case JRPTQ.GET('NMAILED').GET_NUMBER
              when UDO_PKG_URPT_SRV.NMAIL_NOT_ORDERED then
                SMAIL       := 'Доставка не заказана';
                SMAIL_COLOR := 'black';
              when UDO_PKG_URPT_SRV.NMAIL_WAIT then
                SMAIL       := 'Ожидает отправки';
                SMAIL_COLOR := 'orange';
              when UDO_PKG_URPT_SRV.NMAIL_SEND_OK then
                SMAIL       := 'Успешно отправлен';
                SMAIL_COLOR := 'green';
              when UDO_PKG_URPT_SRV.NMAIL_SEND_ERR then
                SMAIL       := 'Ошибка доставки';
                SMAIL_COLOR := 'red';
              else
                SMAIL       := 'Неопределенное состояние отправки';
                SMAIL_COLOR := 'red';
            end case;
            --заголовок
            SHTML := '<h1 class="' || SHEADER_CLASS || '">' || JRPTQ.GET('SNAME')
                    .GET_STRING || '</h1>';
            --детали описания - начало
            SHTML := SHTML || '<table cellpadding="0" cellspacing="0" class="' ||
                     STABLE_CLASS || '"><tr class="' || STR_CLASS ||
                     '"><th class="' || STH_CLASS ||
                     '">Детали</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">';
            SHTML := SHTML || '<table cellpadding="0" cellspacing="0">';
            --код отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Код:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('SCODE')
                    .GET_STRING || '</td></tr>';
            --наименование отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Наименование:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('SNAME')
                    .GET_STRING || '</td></tr>';
            --описание отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Описание:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('SDESC')
                    .GET_STRING || '</td></tr>';
            --тип отчета
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Тип:</b></td><td class="' || STD_CLASS || '">' ||
                     STYPE || '</td></tr>';
            --состояние
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Состояние:</b></td><td class="' || STD_CLASS ||
                     '"><span style="color:' || SSTATE_COLOR || '"><b>' ||
                     SSTATE || '</b></span></td></tr>';
            --дата постановки в очередь
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Время заказа:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('DQUEUE_TS')
                    .GET_STRING || '</td></tr>';
            --время начала обработки
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Начало обработки:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('DSTART_TS')
                    .GET_STRING || '</td></tr>';
            --вермя завершения обработки
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Завершение обработки:</b></td><td class="' ||
                     STD_CLASS || '">' || JRPTQ.GET('DFINISH_TS').GET_STRING ||
                     '</td></tr>';
            --длительность обработки
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Длительность обработки:</b></td><td class="' ||
                     STD_CLASS || '">' || JRPTQ.GET('SEXEC_TIME').GET_STRING ||
                     '</td></tr>';
            --способ постановки в очередь
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Способ заказа:</b></td><td class="' || STD_CLASS ||
                     '"><span style="color:' || SSCH_COLOR || '"><b>' || SSCH ||
                     '</b></span></td></tr>';
            --состояние доставки по e-mail
            SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                     '"><b>Доставка по e-mail:</b></td><td class="' ||
                     STD_CLASS || '"><span style="color:' || SMAIL_COLOR ||
                     '"><b>' || SMAIL || '</b></span></td></tr>';
            --сообщение об ошибке обработки
            if (JRPTQ.GET('NQUEUE_STATE')
               .GET_NUMBER = UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR)
            then
              SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                       '"><b>Ошибка обработки:</b></td><td class="' ||
                       STD_CLASS || '">' || JRPTQ.GET('SERR').GET_STRING ||
                       '</td></tr>';
            end if;
            --детали описания - окончание
            SHTML := SHTML || '</table></td></tr></table>';
            --параметры - начало
            JRPTQ_PRMS := JSON_LIST(JRPTQ.GET('PRMS'));
            if (JRPTQ_PRMS.COUNT > 0)
            then
              --фалг - параметры есть
              BPRMS_SHOW := true;
              --открываем список параметров
              SPRMS := '<table cellpadding="0" cellspacing="0">';
              --идем по параметрам
              for I in 1 .. JRPTQ_PRMS.COUNT
              loop
                JRPTQ_PRM := JSON(JRPTQ_PRMS.GET(I));
                --экранируем строковые поля
                UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SPROMPT;SVAL'
                                                       ,OBJ     => JRPTQ_PRM);
                --определим значение для публикации
                begin
                  --если тип данных
                  case JRPTQ_PRM.GET('NVAL_TYPE').GET_NUMBER
                  --число
                    when UDO_PKG_URPT_SRV.NVAL_TYPE_NUMB then
                      declare
                        NSHARP number(17);
                      begin
                        if (TO_NUMBER(JRPTQ_PRM.GET('SVAL').GET_STRING) =
                           TRUNC(TO_NUMBER(JRPTQ_PRM.GET('SVAL').GET_STRING)))
                        then
                          NSHARP := 0;
                        else
                          NSHARP := 2;
                        end if;
                        SVAL := UDO_PKG_SYSW0003_PUBL_UTILS.CONVERT_TO_STRING(NNUMB     => JRPTQ_PRM.GET('SVAL')
                                                                                           .GET_STRING
                                                                             ,NSEPARATE => 1
                                                                             ,NSHARP    => NSHARP);
                      end;
                      --дата
                    when UDO_PKG_URPT_SRV.NVAL_TYPE_DATE then
                      SVAL := TO_CHAR(TO_DATE(JRPTQ_PRM.GET('SVAL').GET_STRING
                                             ,'yyyy-mm-dd')
                                     ,'dd.mm.yyyy');
                      --логическое выражение
                    when UDO_PKG_URPT_SRV.NVAL_TYPE_BOOL then
                      if (JRPTQ_PRM.GET('SVAL').GET_STRING = '1')
                      then
                        SVAL := 'Да';
                      else
                        SVAL := 'Нет';
                      end if;
                      --прочие типы
                    else
                      SVAL := JRPTQ_PRM.GET('SVAL').GET_STRING;
                  end case;
                exception
                  --если при попытке форматирования что-то пошло не так - прочто отобразим значение как есть
                  when others then
                    SVAL := JRPTQ_PRM.GET('SVAL').GET_STRING;
                end;
                --теперь верстаем
                SPRMS := SPRMS || '<tr><td class="' || STD_CLASS || '"><b>' ||
                         NVL(JRPTQ_PRM.GET('SPROMPT').GET_STRING
                            ,JRPTQ_PRM.GET('SNAME').GET_STRING) ||
                         ':</b></td><td class="' || STD_CLASS || '">' || SVAL ||
                         '</td></tr>';
              end loop;
              --закрываем список параметров
              SPRMS := SPRMS || '</table>';
            else
              BPRMS_SHOW := false;
            end if;
            --если параметры были - подготовим для них заголовок
            if (BPRMS_SHOW)
            then
              SPRMS := '<table cellpadding="0" cellspacing="0" class="' ||
                       STABLE_CLASS || '"><tr class="' || STR_CLASS ||
                       '"><th class="' || STH_CLASS ||
                       '">Параметры формирования</th></tr><tr><td style="padding-top:10px;padding-bottom:10px">' ||
                       SPRMS || '</td></tr></table>';
            end if;
            --пристыкуем параметры к общему HTMLю
            SHTML := SHTML || SPRMS;
            --действия - открываем список
            SHTML := SHTML || '<table cellpadding="0" cellspacing="0" class="' ||
                     STABLE_CLASS || '"><tr class="' || STR_CLASS ||
                     '"><th class="' || STH_CLASS ||
                     '"></th></tr><tr><td style="padding-top:10px;padding-bottom:10px">';
            --загрузить
            SHTML := SHTML || '<a href="javascript:downloadReport(' ||
                     TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) || ');" class="' ||
                     SBUTTON_HOT_CLASS || '">Загрузить</a>&nbsp;';
            --удалить
            SHTML := SHTML || '<a href="javascript:removeReport(' ||
                     TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) || ');" class="' ||
                     SBUTTON_CLASS || '">Удалить</a>&nbsp;';
            --повторить
            SHTML := SHTML || '<a href="javascript:repeatReport(' ||
                     TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) || ');" class="' ||
                     SBUTTON_CLASS || '">Повторить</a>';
            --действия - закрываем список
            SHTML := SHTML || '</td></tr></table>';
          end;
          --для мобильного устройства
        when NINTERFACE_MOBILE then
          begin
            --сформируем объектное представление позиции очереди
            JRPTQ := JSON(CRESP);
            --экранируем строковые поля
            UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC;SEXEC_TIME;SERR'
                                                   ,OBJ     => JRPTQ);
            --определим текстовку для типа
            case JRPTQ.GET('NTYPE').GET_NUMBER
              when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                STYPE := 'Crystal Reports';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                STYPE := 'MS Excel';
              when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                STYPE := 'Open Office Calc';
              else
                STYPE := 'Неизвестный тип';
            end case;
            --опредлим текстовку и цвет для состояния
            case JRPTQ.GET('NQUEUE_STATE').GET_NUMBER
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_INS then
                SSTATE       := 'Выполняется';
                SSTATE_COLOR := 'orange';
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_RUN then
                SSTATE       := 'Выполняется';
                SSTATE_COLOR := 'orange';
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_OK then
                SSTATE       := 'Выполнен успешно';
                SSTATE_COLOR := 'green';
              when UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR then
                SSTATE       := 'Выполнен с ошибками';
                SSTATE_COLOR := 'red';
              else
                SSTATE       := 'Неопределенное состояние';
                SSTATE_COLOR := 'black';
            end case;
            --определим текстовку и цвет для способа постановки в очередь
            case JRPTQ.GET('NSCHEDULED').GET_NUMBER
              when UDO_PKG_URPT_SRV.NSCHEDULED_NO then
                SSCH       := 'Заказан вручную';
                SSCH_COLOR := 'black';
              when UDO_PKG_URPT_SRV.NSCHEDULED_YES then
                SSCH       := 'Заказан автоматически, по заданному расписанию';
                SSCH_COLOR := 'green';
              else
                SSCH       := 'Неопределенный способ заказа отчета';
                SSCH_COLOR := 'red';
            end case;
            --определим текстовку и цвет для статуса отправки по e-mail
            case JRPTQ.GET('NMAILED').GET_NUMBER
              when UDO_PKG_URPT_SRV.NMAIL_NOT_ORDERED then
                SMAIL       := 'Доставка не заказана';
                SMAIL_COLOR := 'black';
              when UDO_PKG_URPT_SRV.NMAIL_WAIT then
                SMAIL       := 'Ожидает отправки';
                SMAIL_COLOR := 'orange';
              when UDO_PKG_URPT_SRV.NMAIL_SEND_OK then
                SMAIL       := 'Успешно отправлен';
                SMAIL_COLOR := 'green';
              when UDO_PKG_URPT_SRV.NMAIL_SEND_ERR then
                SMAIL       := 'Ошибка доставки';
                SMAIL_COLOR := 'red';
              else
                SMAIL       := 'Неопределенное состояние отправки';
                SMAIL_COLOR := 'red';
            end case;
            --заголовок
            SHTML := '<center><h3 class="' || SHEADER_CLASS || '">' || JRPTQ.GET('SNAME')
                    .GET_STRING || '</h3></center>';
            SHTML := SHTML || '<table style="width:100%">';
            --код отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Код:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('SCODE')
                    .GET_STRING || '</td></tr>';
            --наименование отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Наименование:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('SNAME')
                    .GET_STRING || '</td></tr>';
            --описание отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Описание:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('SDESC')
                    .GET_STRING || '</td></tr>';
            --тип отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Тип:</b></td></tr><tr><td style="padding:4px;">' ||
                     STYPE || '</td></tr>';
            --состояние
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Состояние:</b></td></tr><tr><td style="padding:4px;"><span style="color:' ||
                     SSTATE_COLOR || '">' || SSTATE || '</span></td></tr>';
            --дата постановки в очередь
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Время заказа:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('DQUEUE_TS')
                    .GET_STRING || '</td></tr>';
            --время начала обработки
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Начало обработки:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('DSTART_TS')
                    .GET_STRING || '</td></tr>';
            --вермя завершения обработки
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Завершение обработки:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('DFINISH_TS')
                    .GET_STRING || '</td></tr>';
            --длительность обработки
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Длительность обработки:</b></td></tr><tr><td style="padding:4px;">' || JRPTQ.GET('SEXEC_TIME')
                    .GET_STRING || '</td></tr>';
            --способ постановки в очередь
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Способ заказа:</b></td></tr><tr><td style="padding:4px;"><span style="color:' ||
                     SSCH_COLOR || '">' || SSCH || '</span></td></tr>';
            --состояние доставки по e-mail
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Доставка по e-mail:</b></td></tr><tr><td style="padding:4px;"><span style="color:' ||
                     SMAIL_COLOR || '">' || SMAIL || '</span></td></tr>';
            --сообщение об ошибке обработки
            if (JRPTQ.GET('NQUEUE_STATE')
               .GET_NUMBER = UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR)
            then
              SHTML := SHTML ||
                       '<tr style="background-color:#CFE0F1;"><td style="padding:4px;"><b>Ошибка обработки:</b></td></tr><tr><td style="padding:4px;"><span style="color:red"><b>' || JRPTQ.GET('SERR')
                      .GET_STRING || '</b></span></td></tr>';
            end if;
            --избранность отчета
            SHTML := SHTML ||
                     '<tr style="background-color:#CFE0F1;"><td style="padding:4px;">' ||
                     '<label data-corners="false" ><input onclick="ToggleFavor(' ||
                     TO_CHAR(JRPTQ.GET('NREPORT').GET_NUMBER) ||
                     ');" class="checkInput" type="checkbox" ' ||
                     IIF_STR(TO_CHAR(JRPTQ.GET('NFAVOR').GET_NUMBER)
                            ,'='
                            ,TO_CHAR(UDO_PKG_URPT_SRV.NFAVOR_YES)
                            ,'checked'
                            ,'') || ' />Избранное</label>' || '</td></tr>';
            SHTML := SHTML || '</table>';
            --параметры отчета
            JRPTQ_PRMS := JSON_LIST(JRPTQ.GET('PRMS'));
            if (JRPTQ_PRMS.COUNT > 0)
            then
              --фалг - параметры есть
              BPRMS_SHOW := true;
              --открываем список параметров
              SPRMS := '<table style="width:100%">';
              --идем по параметрам
              for I in 1 .. JRPTQ_PRMS.COUNT
              loop
                JRPTQ_PRM := JSON(JRPTQ_PRMS.GET(I));
                --экранируем строковые поля
                UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SNAME;SPROMPT;SVAL'
                                                       ,OBJ     => JRPTQ_PRM);
                --сверстаем параметр - определим цвет заливки
                if (TRUNC(I / 2) = (I / 2))
                then
                  SPRM_ROW_STYLE := '';
                else
                  SPRM_ROW_STYLE := 'style="background-color:#CFE0F1;"';
                end if;
                --определим значение для публикации
                begin
                  --если тип данных
                  case JRPTQ_PRM.GET('NVAL_TYPE').GET_NUMBER
                  --число
                    when UDO_PKG_URPT_SRV.NVAL_TYPE_NUMB then
                      declare
                        NSHARP number(17);
                      begin
                        if (TO_NUMBER(JRPTQ_PRM.GET('SVAL').GET_STRING) =
                           TRUNC(TO_NUMBER(JRPTQ_PRM.GET('SVAL').GET_STRING)))
                        then
                          NSHARP := 0;
                        else
                          NSHARP := 2;
                        end if;
                        SVAL := UDO_PKG_SYSW0003_PUBL_UTILS.CONVERT_TO_STRING(NNUMB     => JRPTQ_PRM.GET('SVAL')
                                                                                           .GET_STRING
                                                                             ,NSEPARATE => 1
                                                                             ,NSHARP    => NSHARP);
                      end;
                      --дата
                    when UDO_PKG_URPT_SRV.NVAL_TYPE_DATE then
                      SVAL := TO_CHAR(TO_DATE(JRPTQ_PRM.GET('SVAL').GET_STRING
                                             ,'yyyy-mm-dd')
                                     ,'dd.mm.yyyy');
                      --логическое выражение
                    when UDO_PKG_URPT_SRV.NVAL_TYPE_BOOL then
                      if (JRPTQ_PRM.GET('SVAL').GET_STRING = '1')
                      then
                        SVAL := 'Да';
                      else
                        SVAL := 'Нет';
                      end if;
                      --прочие типы
                    else
                      SVAL := JRPTQ_PRM.GET('SVAL').GET_STRING;
                  end case;
                exception
                  --если при попытке форматирования что-то пошло не так - прочто отобразим значение как есть
                  when others then
                    SVAL := JRPTQ_PRM.GET('SVAL').GET_STRING;
                end;
                --теперь верстаем
                SPRMS := SPRMS || '<tr ' || SPRM_ROW_STYLE ||
                         '><td style="padding:4px;width:' || SDESC_WIDTH ||
                         '"><b>' ||
                         NVL(JRPTQ_PRM.GET('SPROMPT').GET_STRING
                            ,JRPTQ_PRM.GET('SNAME').GET_STRING) ||
                         ':</b></td><td style="padding:4px;">' || SVAL ||
                         '</td></tr>';
              end loop;
              SPRMS := SPRMS || '</table>';
            else
              BPRMS_SHOW := false;
            end if;
            if (BPRMS_SHOW)
            then
              SPRMS := '<center><h3>Параметры</h3></center>' || SPRMS;
            end if;
            --пристыкуем параметры к общему HTMLю
            SHTML := SHTML || SPRMS;
            --кнопка "Загрузить"
            if (JRPTQ.GET('NQUEUE_STATE')
               .GET_NUMBER <> UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR)
            then
              SHTML := SHTML || '<a href="javascript:downloadReport(' ||
                       TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) ||
                       ');" data-role="button" data-corners="false" data-theme="' ||
                       SBUTTON_HOT_CLASS || '" class="aBtn">Загрузить</a>';
            end if;
            --кнопка повторить
            SHTML := SHTML || '<a href="javascript:RepeatReport(' ||
                     TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) ||
                     ');" data-role="button" data-corners="false" data-theme="' ||
                     SBUTTON_CLASS || '" class="aBtn">Повторить</a>';
            --кнопка удалить
            SHTML := SHTML || '<a href="javascript:RemoveReport(' ||
                     TO_CHAR(JRPTQ.GET('NRN').GET_NUMBER) ||
                     ');" data-role="button" data-corners="false" data-theme="' ||
                     SBUTTON_CLASS || '" class="aBtn">Удалить</a>';
            --инициализируем виджеты
            SHTML := SHTML ||
                     '<script>$(".aBtn").button();$(".checkInput").checkboxradio();</script>';
          end;
          --для неизвестного устройства
        else
          P_EXCEPTION(0
                     ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                      '" не поддерживается!');
      end case;
    else
      --иначе показываем сообщение сервера
      SHTML := UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SRESP_MSG) ||
               UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
    end if;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML со списком глав справки
  function HTML_HELP_UNITS_LIST
  (
    NCOMPANY     number --организация
   ,SLIST_ID     varchar2 --идентификатор списка глав справки
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    I     number := 0; --счетчик элементов
    SHTML clob; --свёрстанный HTML
    SERR  varchar2(4000); --буфер для ошибок
  begin
    --отрисуем главы справки в зависимости от типа интерфейса
    case NINTERFACE
    --для десктопа
      when NINTERFACE_DESKTOP then
        declare
          NFIRST number(17); --рег. номер первого элемента списка
          --формирование элемента списка
          function BUILD_ITEM
          (
            NITEM number --рег. номер элемента списка
           ,SNAME varchar2 --наименование элемента
           ,SDESC varchar2 --описание элемента
          ) return varchar2 is
            SRES varchar2(4000); --результат работы
          begin
            --сверстаем элемент
            SRES := '<tr onclick="loadHelp($(this));" help="' || TO_CHAR(NITEM) ||
                    '" class="' || STR_CLASS || '"><td class="' || STD_CLASS ||
                    '"><table><tr><td style="margin-right:5px"><b>' || SNAME ||
                    '</b></td>';
            SRES := SRES ||
                    '</tr><tr><td style="font-size:80%;margin-right:5px">' ||
                    SDESC ||
                    '</td></tr></table></td><td class="helpl_list_item_selector" style="width:5px"></td></tr>';
            --вернем результат
            return SRES;
          end;

        begin
          --идем по главам справочного раздела
          for C in (select *
                      from UDO_T_SYSW0006_URPT_HELPU T
                     where T.INTERFACE = NINTERFACE
                     order by T.ORD)
          loop
            --инкрементируем количество элементов
            I := I + 1;
            --сверстаем элемент списка
            SHTML := SHTML || BUILD_ITEM(NITEM => C.RN
                                        ,SNAME => C.HEAD
                                        ,SDESC => C.DESCR);
            --запомним первый
            if (I = 1)
            then
              NFIRST := C.RN;
            end if;
          end loop;
          --завершаем вёрстку
          SHTML := '<table style="width:100%" cellspacing="0" cellpadding="0" class="' ||
                   STABLE_CLASS || '">' || SHTML || '</table>';
          --позиционируемся на первом отчете в списке
          if (NFIRST is not null)
          then
            SHTML := SHTML || '<script>loadHelp($("tr.' || STR_CLASS ||
                     '[help=' || TO_CHAR(NFIRST) || ']"))</script>';
          end if;
        end;
        --для мобильного устройства
      when NINTERFACE_MOBILE then
        declare
          --формирование элемента списка
          function BUILD_ITEM
          (
            NITEM number --рег. номер элемента списка
           ,NNUMB number --номер главы
           ,SNAME varchar2 --наименование элемента
           ,SDESC varchar2 --описание элемента
          ) return varchar2 is
            SRES varchar2(4000); --результат работы
          begin
            --сверстаем элемент
            SHTML := SHTML || '<li>';
            SHTML := SHTML || '<a href="f?p=' || V('APP_ID') || ':3:' ||
                     V('APP_SESSION') || '::' || V('DEBUG') ||
                     '::P3_HELP_UNIT:' || TO_CHAR(NITEM) || '">';
            SHTML := SHTML || '<table>';
            SHTML := SHTML || '<tr>';
            SHTML := SHTML || '<td style="padding-left:10px">';
            SHTML := SHTML || '<h3 style="white-space:normal;">' || SNAME ||
                     '</h3>';
            SHTML := SHTML ||
                     '<p style="white-space:normal;text-align:justify;">' ||
                     SDESC || '</p>';
            SHTML := SHTML || '</td>';
            SHTML := SHTML || '</tr>';
            SHTML := SHTML || '</table>';
            SHTML := SHTML || '</a>';
            SHTML := SHTML || '</li>';
            --вернем результат
            return SRES;
          end;

        begin
          --идем по главам справочного раздела
          for C in (select *
                      from UDO_T_SYSW0006_URPT_HELPU T
                     where T.INTERFACE = NINTERFACE
                     order by T.ORD)
          loop
            --инкрементируем количество элементов
            I := I + 1;
            --сверстаем элемент списка
            SHTML := SHTML || BUILD_ITEM(NITEM => C.RN
                                        ,NNUMB => I
                                        ,SNAME => C.HEAD
                                        ,SDESC => C.DESCR);
          end loop;
          --завершаем вёрстку
          SHTML := '<ul data-role="listview" data-autodividers="false" id="HelpUnits">' ||
                   SHTML || '</ul>';
          /*
          begin
            null;

            --сформируем объектное представление списка
            JRESP := JSON(CRESP);
            --если там есть отчеты и это действительно список
            if ((JRESP.EXIST('REPORTS')) and (JRESP.GET('REPORTS').IS_ARRAY))
            then
              --то разбираем его
              JRPTS := JSON_LIST(JRESP.GET('REPORTS'));
              --если он не пустой
              if (JRPTS.COUNT > 0)
              then
                SHTML := '';
                --идем по отчетам списка
                for I in 1 .. JRPTS.COUNT
                loop
                  --считаем очередной отчет
                  JRPT := JSON(JRPTS.GET(I));
                  --экранируем строковые поля
                  UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC'
                                                         ,OBJ     => JRPT);
                  --определим для него группу
                  if (NRPT_ORDER = UDO_PKG_URPT_SRV.NRPT_ORDER_UNIT)
                  then
                    SGRP := JRPT.GET('SUNIT_NAME').GET_STRING;
                  else
                    SGRP := 'Список по алфавиту';
                  end if;
                  --определим картинку элемента
                  case JRPT.GET('NRPT_TYPE').GET_NUMBER
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_CRYSTAL then
                      SIMG := 'icon_cr.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_EXCEL then
                      SIMG := 'icon_excel.png';
                    when UDO_PKG_URPT_SRV.NRPT_TYPE_OOCALC then
                      SIMG := 'icon_ooc.png';
                    else
                      SIMG := 'menu\menu-page-128.png';
                  end case;
                  --сверстаем элемент
                  SHTML := SHTML || '<li group-name="' || SGRP || '">';
                  SHTML := SHTML || '<a href="f?p=' || V('APP_ID') || ':12:' ||
                           V('APP_SESSION') || '::' || V('DEBUG') ||
                           '::P12_REPORT:' ||
                           TO_CHAR(JRPT.GET('NRN').GET_NUMBER) || '">';
                  SHTML := SHTML || '<table>';
                  SHTML := SHTML || '<tr>';
                  SHTML := SHTML || '<td>';
                  SHTML := SHTML || '<img style="height:64px;width:64px" src="' ||
                           V('IMAGE_PREFIX') || V('APP_IMGS_DIR') || '/' || SIMG || '">';
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '<td style="padding-left:10px">';
                  SHTML := SHTML || '<h3 style="white-space:normal;">' || JRPT.GET('SNAME')
                          .GET_STRING || '</h3>';
                  SHTML := SHTML ||
                           '<p style="white-space:normal;text-align:justify;">' || JRPT.GET('SDESC')
                          .GET_STRING || '</p>';
                  SHTML := SHTML || '</td>';
                  SHTML := SHTML || '</tr>';
                  SHTML := SHTML || '</table>';
                  SHTML := SHTML || '</a>';
                  if (NVL(NFAVOR
                         ,UDO_PKG_URPT_SRV.NFAVOR_NO) <>
                     UDO_PKG_URPT_SRV.NFAVOR_YES)
                  then
                    SHTML := SHTML || '<a href="f?p=' || V('APP_ID') || ':13:' ||
                             V('APP_SESSION') || '::' || V('DEBUG') || ':::' ||
                             '" data-icon="' ||
                             IIF_STR(TO_CHAR(JRPT.GET('NFAVOR').GET_NUMBER)
                                    ,'='
                                    ,TO_CHAR(UDO_PKG_URPT_SRV.NFAVOR_YES)
                                    ,'favor-yes'
                                    ,'favor-no') || '" data-theme="c"></a>';
                  end if;
                  SHTML := SHTML || '</li>';
                end loop;
                SHTML := SHTML || '<script>$("#' || SLIST_ID ||
                         '").listview({autodividers:true,autodividersSelector:function(li){return li.attr("group-name");}});</script>';
            */
        end;
        --для неизвестного устройства
      else
        P_EXCEPTION(0
                   ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                    '" не поддерживается!');
    end case;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --формирование HTML с главой справки
  function HTML_HELP
  (
    NCOMPANY      number --организация
   ,NHELP         number --рег. номер главы справки
   ,SHEADER_CLASS varchar2 := null --CSS-класс для заголовка
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) return clob is
    SHTML clob; --свёрстанный HTML
    SERR  varchar2(4000); --буфер для ошибок
    HREC  UDO_T_SYSW0006_URPT_HELPU%rowtype; --запись главы справки
    HCREC UDO_T_SYSW0006_URPT_HELPC%rowtype; --запись контента главы справки
  begin
    --отрисуем главы справки в зависимости от типа интерфейса
    case NINTERFACE
    --для десктопа
      when NINTERFACE_DESKTOP then
        begin
          --считаем главу
          begin
            select T.*
              into HREC
              from UDO_T_SYSW0006_URPT_HELPU T
             where T.RN = NHELP;
          exception
            when NO_DATA_FOUND then
              PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                      ,NDOCUMENT   => NHELP
                                      ,SUNIT_TABLE => 'UDO_T_SYSW0006_URPT_HELPU');
          end;
          --считаем данные главы
          begin
            select T.*
              into HCREC
              from UDO_T_SYSW0006_URPT_HELPC T
             where T.PRN = HREC.RN
               and T.INTERFACE = NINTERFACE;
          exception
            when NO_DATA_FOUND then
              HCREC.RN := null;
          end;
          --заголовок
          SHTML := '<h1 class="' || SHEADER_CLASS || '">' || HREC.HEAD ||
                   '</h1>';
          --если данные есть - показываем
          if (HCREC.RN is not null)
          then
            --проведем макроподстановки
            HCREC.HELPC := replace(replace(HCREC.HELPC
                                          ,'#IMAGE_PREFIX#'
                                          ,V('IMAGE_PREFIX'))
                                  ,'#APP_IMGS_DIR#'
                                  ,V('APP_IMGS_DIR'));
            --добавим контент к вёрстке
            SHTML := SHTML || HCREC.HELPC;
          end if;
        end;
        --для мобильного устройства
      when NINTERFACE_MOBILE then
        begin
          --считаем главу
          begin
            select T.*
              into HREC
              from UDO_T_SYSW0006_URPT_HELPU T
             where T.RN = NHELP;
          exception
            when NO_DATA_FOUND then
              PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                      ,NDOCUMENT   => NHELP
                                      ,SUNIT_TABLE => 'UDO_T_SYSW0006_URPT_HELPU');
          end;
          --считаем данные главы
          begin
            select T.*
              into HCREC
              from UDO_T_SYSW0006_URPT_HELPC T
             where T.PRN = HREC.RN
               and T.INTERFACE = NINTERFACE;
          exception
            when NO_DATA_FOUND then
              HCREC.RN := null;
          end;
          --заголовок
          SHTML := '<h3 class="' || SHEADER_CLASS || '">' || HREC.HEAD ||
                   '</h3>';
          --если данные есть - показываем
          if (HCREC.RN is not null)
          then
            --проведем макроподстановки
            HCREC.HELPC := replace(replace(HCREC.HELPC
                                          ,'#IMAGE_PREFIX#'
                                          ,V('IMAGE_PREFIX'))
                                  ,'#APP_IMGS_DIR#'
                                  ,V('APP_IMGS_DIR'));
            --добавим контент к вёрстке
            SHTML := SHTML || HCREC.HELPC;
          end if;
        end;
        --для неизвестного устройства
      else
        P_EXCEPTION(0
                   ,'Код интерфейса "' || TO_CHAR(NINTERFACE) ||
                    '" не поддерживается!');
    end case;
    --вернем результат
    return SHTML;
  exception
    when others then
      SERR := sqlerrm;
      return UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 1) || UDO_PKG_SYSW0003_PUBL_UTILS.STR_ESCAPE(SSTR => SERR) || UDO_PKG_SYSW0003_PUBL_UTILS.GET_ERR_HTML(NMODE => 2);
  end;

  --выдача WEB-серверу списка организаций
  procedure HTPP_COMPANIES_LIST is
    CDATA clob; --данные списка
  begin
    --соберем список
    CDATA := HTML_COMPANIES_LIST();
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --выдача WEB-серверу списка разделов
  procedure HTPP_UNITS_LIST
  (
    SSESSION     varchar2 --идентификатор сессии
   ,NCOMPANY     number --организация
   ,SUSER        varchar2 --пользователь
   ,SSEARCH      varchar2 := null --строка поиска (null - не искать)
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_UNITS_LIST(SSESSION     => SSESSION
                            ,NCOMPANY     => NCOMPANY
                            ,SUSER        => SUSER
                            ,SSEARCH      => SSEARCH
                            ,STABLE_CLASS => NVL(STABLE_CLASS
                                                ,V('DEF_TABLE_CLASS'))
                            ,STR_CLASS    => NVL(STR_CLASS
                                                ,V('DEF_TR_CLASS'))
                            ,STH_CLASS    => NVL(STH_CLASS
                                                ,V('DEF_TH_CLASS'))
                            ,STD_CLASS    => NVL(STD_CLASS
                                                ,V('DEF_TD_CLASS'))
                            ,NINTERFACE   => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --выдача WEB-серверу списка отчетов
  procedure HTPP_REPORTS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
   ,NCURPAGE      number --номер текущей страницы
   ,SLIST_ID      varchar2 --идентификатор списка отчетов
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_REPORTS_LIST(SSESSION      => SSESSION
                              ,NCOMPANY      => NCOMPANY
                              ,SUSER         => SUSER
                              ,NUNIT         => NUNIT
                              ,NFAVOR        => NFAVOR
                              ,SSEARCH       => SSEARCH
                              ,NPORTION      => NPORTION
                              ,NPORTION_SIZE => NPORTION_SIZE
                              ,NRPT_ORDER    => NRPT_ORDER
                              ,NCURPAGE      => NCURPAGE
                              ,SLIST_ID      => SLIST_ID
                              ,STABLE_CLASS  => STABLE_CLASS
                              ,STR_CLASS     => STR_CLASS
                              ,STH_CLASS     => STH_CLASS
                              ,STD_CLASS     => STD_CLASS
                              ,NINTERFACE    => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --выдача WEB-серверу детализации по отчету
  procedure HTPP_REPORT_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORT           number --рег. номер отчета
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_REPORT_DETAIL(SSESSION          => SSESSION
                               ,NCOMPANY          => NCOMPANY
                               ,SUSER             => SUSER
                               ,NREPORT           => NREPORT
                               ,SHEADER_CLASS     => SHEADER_CLASS
                               ,SBUTTON_CLASS     => SBUTTON_CLASS
                               ,SBUTTON_HOT_CLASS => SBUTTON_HOT_CLASS
                               ,STABLE_CLASS      => STABLE_CLASS
                               ,STR_CLASS         => STR_CLASS
                               ,STH_CLASS         => STH_CLASS
                               ,STD_CLASS         => STD_CLASS
                               ,NINTERFACE        => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --выдача WEB-серверу списка записей словаря, привязанного к параметру отчета
  procedure HTPP_REPORT_PRM_DICT_RECS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_REPORT_PRM_DICT_RECS_LIST(SSESSION      => SSESSION
                                           ,SUSER         => SUSER
                                           ,NPRM          => NPRM
                                           ,SSEARCH       => SSEARCH
                                           ,NPORTION      => NPORTION
                                           ,NPORTION_SIZE => NPORTION_SIZE
                                           ,STABLE_CLASS  => STABLE_CLASS
                                           ,STR_CLASS     => STR_CLASS
                                           ,STH_CLASS     => STH_CLASS
                                           ,STD_CLASS     => STD_CLASS
                                           ,NINTERFACE    => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --постановка отчета в очередь (по коду отчета)
  procedure HTPP_REPORT_PUT
  (
    SSESSION varchar2 --идентификатор сессии
   ,NCOMPANY number --организация
   ,SUSER    varchar2 --пользователь
   ,SREPORT  varchar2 --мнемокод отчета
   ,SPRMS    clob --параметры в JSON ([{SNAME:<ИМЯ_ПАРАМЕТРА>,NVAL_TYPE:<ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ДД.ММ.ГГГГ, для булева 1 или 0>}])
  ) is
    NREPORT USERREPORTS.RN%type; --рег. номер отчета
    CRESP   clob; --текстовое представление ответа сервиса отложенной печати
    SERR    varchar2(4000); --буфер для ошибок
  begin
    FIND_USERREP_CODE(NFLAG_SMART => 0
                     ,NCOMPANY    => NCOMPANY
                     ,SCODE       => SREPORT
                     ,NRN         => NREPORT);
    HTPP_REPORT_PUT(SSESSION => SSESSION
                   ,NCOMPANY => NCOMPANY
                   ,SUSER    => SUSER
                   ,NREPORT  => NREPORT
                   ,SPRMS    => SPRMS);
  exception
    when others then
      SERR  := sqlerrm;
      CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                             ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                             ,SRESP_MSG  => SERR);
      UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --постановка отчета в очередь
  procedure HTPP_REPORT_PUT
  (
    SSESSION varchar2 --идентификатор сессии
   ,NCOMPANY number --организация
   ,SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,SPRMS    clob --параметры в JSON ([{SNAME:<ИМЯ_ПАРАМЕТРА>,NVAL_TYPE:<ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ДД.ММ.ГГГГ, для булева 1 или 0>}])
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер организации
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_COMPANY_KEY
                            ,PAIR_VALUE => NCOMPANY);
      --параметры действия - рег. номер отчета
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                            ,PAIR_VALUE => NREPORT);
      --параметры действия - параметры печати отчета
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PRMS_KEY
                            ,PAIR_VALUE => JSON_LIST(SPRMS));
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORT_PUT_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --поместим отчет в очередь
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --добавление расписания для отчета
  procedure HTPP_REPORT_ADD_SCHEDULE
  (
    SSESSION        varchar2 --идентификатор сессии
   ,SUSER           varchar2 --пользователь
   ,NREPORT         number --рег. номер отчета
   ,NSCH_TYPE       number --тип расписания
   ,SSCH_STEP       varchar2 --шаг исполнения расписания (строковое представление)
   ,SSCH_START_DATE varchar2 --дата начала действия расписания
   ,NMAIL           number --признак доставки по e-mail (0 - нет, 1 - да)
   ,SPRMS           clob --параметры в JSON ([{SNAME:<ИМЯ_ПАРАМЕТРА>,NVAL_TYPE:<ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL:<ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ДД.ММ.ГГГГ, для булева 1 или 0>}])
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
    NSCH_STEP          number(17); --шаг исполнения расписания (числовое представление)
  begin
    begin
      --конвертируем строковое представление шага расписания в числовое представление
      begin
        NSCH_STEP := UDO_PKG_SYSW0003_PUBL_UTILS.CONVERT_TO_NUMBER(SSTR   => SSCH_STEP
                                                                  ,NSMART => 0);
      exception
        when others then
          P_EXCEPTION(0
                     ,'Значение "' || SSCH_STEP ||
                      '" поля "Шаг" не является числовым!');
      end;
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер отчета
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                            ,PAIR_VALUE => NREPORT);
      --параметры действия - тип расписания
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SCH_TYPE_KEY
                            ,PAIR_VALUE => NSCH_TYPE);
      --параметры действия - шаг
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SCH_STEP_KEY
                            ,PAIR_VALUE => NSCH_STEP);
      --параметры действия - дата начала
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SCH_START_DATE_KEY
                            ,PAIR_VALUE => SSCH_START_DATE);
      --параметры действия - доставка по e-mail
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SCH_MAIL_KEY
                            ,PAIR_VALUE => NMAIL);
      --параметры действия - параметры печати отчета
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_PRMS_KEY
                            ,PAIR_VALUE => JSON_LIST(SPRMS));
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORT_ADD_SCHED_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --добавим расписание для отчета
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --удаление расписания для отчета
  procedure HTPP_REPORT_REMOVE_SCHEDULE
  (
    SSESSION  varchar2 --идентификатор сессии
   ,SUSER     varchar2 --пользователь
   ,NREPORT   number --рег. номер отчета
   ,NSCHEDULE number --рег. номер расписания
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер отчета
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                            ,PAIR_VALUE => NREPORT);
      --параметры действия - рег. номер расписания
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_SCH_KEY
                            ,PAIR_VALUE => NSCHEDULE);
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORT_REM_SCHED_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --удалим расписание у отчета
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --изменение "избранности" отчета
  procedure HTPP_REPORT_FAVOR_TOGGLE
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер отчета
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORT_KEY
                            ,PAIR_VALUE => NREPORT);
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORT_FAVOR_TGL_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --изменим избранность
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --выдача WEB-серверу списка позиций очереди
  procedure HTPP_REPORTQS_LIST
  (
    SSESSION      varchar2 --идентификатор сессии
   ,NCOMPANY      number --организация
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 := null --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,STABLE_CLASS  varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS     varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS     varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS     varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_REPORTQS_LIST(SSESSION      => SSESSION
                               ,NCOMPANY      => NCOMPANY
                               ,SUSER         => SUSER
                               ,NREPORT       => NREPORT
                               ,SSEARCH       => SSEARCH
                               ,NPORTION      => NPORTION
                               ,NPORTION_SIZE => NPORTION_SIZE
                               ,STABLE_CLASS  => STABLE_CLASS
                               ,STR_CLASS     => STR_CLASS
                               ,STH_CLASS     => STH_CLASS
                               ,STD_CLASS     => STD_CLASS
                               ,NINTERFACE    => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --выдача WEB-серверу детализации по позиции очереди
  procedure HTPP_REPORTQ_DETAIL
  (
    SSESSION          varchar2 --идентификатор сессии
   ,NCOMPANY          number --организация
   ,SUSER             varchar2 --пользователь
   ,NREPORTQ          number --рег. номер позиции очереди
   ,SHEADER_CLASS     varchar2 := null --CSS-класс для заголовка
   ,SBUTTON_CLASS     varchar2 := null --CSS-класс для кнопок (обычных)
   ,SBUTTON_HOT_CLASS varchar2 := null --CSS-класс для кнопок (горячих)
   ,STABLE_CLASS      varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS         varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS         varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS         varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE        number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_REPORTQ_DETAIL(SSESSION          => SSESSION
                                ,NCOMPANY          => NCOMPANY
                                ,SUSER             => SUSER
                                ,NREPORTQ          => NREPORTQ
                                ,SHEADER_CLASS     => SHEADER_CLASS
                                ,SBUTTON_CLASS     => SBUTTON_CLASS
                                ,SBUTTON_HOT_CLASS => SBUTTON_HOT_CLASS
                                ,STABLE_CLASS      => STABLE_CLASS
                                ,STR_CLASS         => STR_CLASS
                                ,STH_CLASS         => STH_CLASS
                                ,STD_CLASS         => STD_CLASS
                                ,NINTERFACE        => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --удаление позиции очреди
  procedure HTPP_REPORTQ_REMOVE
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер позиции очереди
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORTQ_KEY
                            ,PAIR_VALUE => NREPORTQ);
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTQ_REMOVE_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --удалим позицию очереди
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --загрузка готового отчета
  procedure HTPP_REPORTQ_DOWNLOAD
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер позиции очереди
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORTQ_KEY
                            ,PAIR_VALUE => NREPORTQ);
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTQ_DOWNLOAD_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --отправим отчет на загрузку
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --повторная постановка отчета в очередь
  procedure HTPP_REPORTQ_REPEAT
  (
    SSESSION varchar2 --идентификатор сессии
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер позиции очереди
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORTQ_KEY
                            ,PAIR_VALUE => NREPORTQ);
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTQ_REPEAT_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --поместим отчет в очередь повторно
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --выдача WEB-серверу состояния позиции очереди
  procedure HTPP_REPORTQ_GETSTATE
  (
    SSESSION varchar2 --идентификатор сессии
   ,NCOMPANY number --организация
   ,SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) is
    JREQ               JSON; --объектное представление запроса к сервису отложенной печати
    JREQ_PRMS          JSON; --объектное представление параметров запроса к сервису отложенной печати
    JREQ_PRMS_ACT_PRMS JSON; --объектное представление параметров действия в запросе к сервису отложенной печати
    CREQ               clob; --текстовое представление запроса к сервису отложенной печати
    CRESP              clob; --текстовое представление ответа сервиса отложенной печати
    JRPTQ              JSON; --объектное представлеие позиции очереди из ответа
    NRESP_TYPE         number(17); --разобранный код ответа сервера
    SRESP_MSG          varchar2(4000); --разобранное сообщение сервера
    SERR               varchar2(4000); --буфер для ошибок
  begin
    begin
      --сформируем запрос к сервису - инициализация объекта
      JREQ               := JSON();
      JREQ_PRMS          := JSON();
      JREQ_PRMS_ACT_PRMS := JSON();
      --параметры действия - рег. номер позиции очереди
      JREQ_PRMS_ACT_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_REPORTQ_KEY
                            ,PAIR_VALUE => NREPORTQ);
      --пользователь
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_USER_KEY
                   ,PAIR_VALUE => SUSER);
      --сессия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_SESSION_KEY
                   ,PAIR_VALUE => SSESSION);
      --действие
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_KEY
                   ,PAIR_VALUE => UDO_PKG_URPT_SRV.SREQ_ACT_REPORTQ_GET_VAL);
      --параеметры действия
      JREQ_PRMS.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_ACTION_PRMS_KEY
                   ,PAIR_VALUE => JREQ_PRMS_ACT_PRMS);
      --теперь всё в запрос
      JREQ.PUT(PAIR_NAME  => UDO_PKG_URPT_SRV.SREQ_TYPE_PRINT_KEY
              ,PAIR_VALUE => JREQ_PRMS);
      --конвертируем объектное представление в текст
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CREQ
                              ,CACHE   => false);
      JREQ.TO_CLOB(BUF => CREQ);
      --запросим детали позиции очереди
      CRESP := UDO_PKG_URPT_SRV.JSON_URPT_SRV_PROCESS(CPRMS => CREQ);
      --проверим ответ на наличие ошибок
      UDO_PKG_URPT_SRV.JSON_PARSE_RESPONSE(CJSON      => CRESP
                                          ,NRESP_TYPE => NRESP_TYPE
                                          ,SRESP_MSG  => SRESP_MSG);
      --если пришел не стандартный ответ, а просто данные - значит это позиция очереди - будем разбирать
      if (NRESP_TYPE is null)
      then
        --сформируем объектное представление отчета
        JRPTQ := JSON(CRESP);
        --сформируем ответ с состоянием позиции очереди
        if (JRPTQ.GET('NQUEUE_STATE')
           .GET_NUMBER = UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR)
        then
          SRESP_MSG := JRPTQ.GET('SERR').GET_STRING;
        else
          SRESP_MSG := TO_CHAR(JRPTQ.GET('NQUEUE_STATE').GET_NUMBER);
        end if;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_OK
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SRESP_MSG);
      else
        --сформируем ответ с ошибкой, пришедшей от сервера
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SRESP_MSG);
      end if;
    exception
      when others then
        SERR  := sqlerrm;
        CRESP := UDO_PKG_URPT_SRV.UTL_MAKE_RESP(NRESP_TYPE => UDO_PKG_URPT_SRV.NRESP_TYPE_ERR
                                               ,NRESP_KIND => UDO_PKG_URPT_SRV.NRESP_KIND_JSON
                                               ,SRESP_MSG  => SERR);
    end;
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CRESP);
  end;

  --выдача WEB-серверу списка разделов справки
  procedure HTPP_HELP_UNITS_LIST
  (
    NCOMPANY     number --организация
   ,SLIST_ID     varchar2 --идентификатор списка глав справки
   ,STABLE_CLASS varchar2 := null --CSS-класс для таблицы
   ,STR_CLASS    varchar2 := null --CSS-класс для строки данных таблицы
   ,STH_CLASS    varchar2 := null --CSS-класс для ячейки заголовка таблицы
   ,STD_CLASS    varchar2 := null --CSS-класс для ячейки данных таблицы
   ,NINTERFACE   number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_HELP_UNITS_LIST(NCOMPANY     => NCOMPANY
                                 ,SLIST_ID     => SLIST_ID
                                 ,STABLE_CLASS => STABLE_CLASS
                                 ,STR_CLASS    => STR_CLASS
                                 ,STH_CLASS    => STH_CLASS
                                 ,STD_CLASS    => STD_CLASS
                                 ,NINTERFACE   => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

  --выдача WEB-серверу раздела справки
  procedure HTPP_HELP
  (
    NCOMPANY      number --организация
   ,NHELP         number --рег. номер главы справки
   ,SHEADER_CLASS varchar2 := null --CSS-класс для заголовка
   ,NINTERFACE    number := 0 --интерфейс (0 - настольный, 1 - мобильный)
  ) is
    CDATA clob; --данные отчета
  begin
    --соберем список
    CDATA := HTML_HELP(NCOMPANY      => NCOMPANY
                      ,NHELP         => NHELP
                      ,SHEADER_CLASS => SHEADER_CLASS
                      ,NINTERFACE    => NINTERFACE);
    --отдаим WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CDATA);
  end;

end;
/

