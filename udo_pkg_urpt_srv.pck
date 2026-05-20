create or replace package UDO_PKG_URPT_SRV as

  /*
   WEB-сервис обслуживания очереди отложенной печати пользовательских отчетов
  */
  --разрешить запросы на действия с пустой сессией
  BALLOW_EMPTY_SESSION_ACTIONS constant boolean := false;

  --разрешить подключения без проверки соответствия клиентской и серверной частей
  BALLOW_NO_SERVICE_VERS_CHECK constant boolean := true;

  --сортировать данные словарей
  BORDERED_DICTS constant boolean := false;

  --наименование сервиса
  SSERVICE_NAME constant varchar2(20) := 'Парус-отчетность';

  --версия сервиса
  SSERVICE_VERSION constant varchar2(20) := '1.0';

  --схема данных по-умолчанию
  SSHEMA_DEFAULT constant varchar2(20) := 'PARUS';

  --таблица версий
  STABLE_VERSIONS constant varchar2(20) := 'VERSIONS';

  --таблица организаций
  STABLE_COMPANIES constant varchar2(20) := 'COMPANIES';

  --имя канала сообщений сервиса печати
  SPIPE_NAME constant varchar2(200) := 'PARUS$RPTPRTQUEUE$PIPE';

  --имя приложения сервиса отчетности
  SPROGRAMM_NAME varchar2(20) := 'p8application.exe';

  --имя модуля сервиса отчетности
  SMODULE_NAME varchar2(20) := 'PARUS$PrintServer';

  --наименование WEB-сервиса печати в лицензии (сервер)
  SSRV_LIC varchar2(40) := 'AdminOnline';

  --наименование WEB-сервиса печати в лицензии (клиент - имплементация)
  SCLN_LIC_IMPLEMENTATION varchar2(40) := 'Other';

  --наименование WEB-сервиса печати в лицензии (клиент - соединение)
  SCLN_LIC_APPLICATION varchar2(40) := 'Other';

  --разделитель слов в предложении
  SENT_WRD_DELIM varchar2(1) := ' ';

  --разделитель списков
  SLIST_DELIM varchar(1) := GET_OPTIONS_STR('SeqSymb');

  --максимальное время простоя сессии сервиса (мин)
  NSERVICE_IDLE_TIME number(2) := 15;

  --признаки наличия прав доступа
  NHAVE_NO_PRIVS constant number(1) := 0; --прав нет
  NHAVE_PRIVS    constant number(1) := 1; --права есть
  --признаки наличия роли у пользователя
  NHAVE_ROLE    constant number(1) := 1; --роль есть
  NHAVE_NO_ROLE constant number(1) := 0; --роли нет
  --признаки наличия роли у пользователя роли администратора
  NIS_ADMIN     constant number(1) := 1; --администратор
  NIS_NOT_ADMIN constant number(1) := 0; --не администратор
  --признаки активности сервиса
  NIS_ACTIVE     constant number(1) := 1; --не активен
  NIS_NOT_ACTIVE constant number(1) := 0; --активен
  --параметры конфигурации публикации пользовательских отчетов
  SCONF_USR_REPORT_PUBL constant varchar2(40) := 'USR_REPORT_PUBL'; --признак публикации отчета
  SCONF_USR_REPORT_DESC constant varchar2(40) := 'USR_REPORT_DESC'; --описание отчета для публикации
  --параметры конфигурации публикации классов
  SCONF_CLASS_CODE           constant varchar2(40) := 'CLASS_CODE'; --атрибут для мнемокода записи
  SCONF_CLASS_DESC           constant varchar2(40) := 'CLASS_DESC'; --атрибут для описания записи
  SCONF_CLASS_NO_DESC_SEARCH constant varchar2(40) := 'CLASS_NO_DESC_SEARCH'; --признак исключения атрибута описания записи из поиска
  --типы данных значений параметров (WEB-сервис)
  NVAL_TYPE_STR  constant number(1) := 0; --значение типа строка
  NVAL_TYPE_NUMB constant number(1) := 1; --значение типа число
  NVAL_TYPE_DATE constant number(1) := 2; --значение типа дата
  NVAL_TYPE_BOOL constant number(1) := 3; --булево значение
  NVAL_TYPE_BLOB constant number(1) := 4; --двоичные данные
  NVAL_TYPE_CLOB constant number(1) := 5; --текстовые данные
  --типы данных значений параметров (Система)
  NVAL_TYPE_STR_SYS  constant number(1) := 0; --значение типа строка
  NVAL_TYPE_NUMB_SYS constant number(1) := 1; --значение типа число
  NVAL_TYPE_CURR_SYS constant number(1) := 2; --значение типа валюта
  NVAL_TYPE_BOOL_SYS constant number(1) := 3; --булево значение
  NVAL_TYPE_DATE_SYS constant number(1) := 4; --значение типа дата
  --способы ввода значений параметров (WEB-сервис)
  NINP_TYPE_MANUAL   constant number(1) := 0; --ручной ввод
  NINP_TYPE_DICT     constant number(1) := 1; --заполнение из словаря
  NINP_TYPE_COMPANY  constant number(1) := 2; --контекст - организация
  NINP_TYPE_UNIT     constant number(1) := 3; --контекст - код раздела
  NINP_TYPE_DOC_RN   constant number(1) := 4; --контекст - рег. номер докумета
  NINP_TYPE_SL_IDENT constant number(1) := 5; --контекст - идетификатор отмеченных записей
  --способы ввода значений параметров (Система)
  NINP_TYPE_MANUAL_SYS   constant number(1) := 0; --ручной ввод
  NINP_TYPE_COMPANY_SYS  constant number(1) := 1; --контекст - организация
  NINP_TYPE_DOC_SYS      constant number(1) := 2; --заполнение из учетного регистра/словаря
  NINP_TYPE_SL_IDENT_SYS constant number(1) := 4; --контекст - идентификатор помеченных записей
  NINP_TYPE_EXDICT_SYS   constant number(1) := 5; --заполнение из дополнительного словаря
  NINP_TYPE_UNIT_SYS     constant number(1) := 6; --контекст - код раздела
  NINP_TYPE_DOC_RN_SYS   constant number(1) := 7; --контекст - рег. номер документа
  --типы отчетов (WEB-сервис)
  NRPT_TYPE_CRYSTAL constant number(1) := 0; --Crystal Reports
  NRPT_TYPE_EXCEL   constant number(1) := 1; --MS Excel
  NRPT_TYPE_OOCALC  constant number(1) := 2; --Open Office Calc
  --типы отчетов (Система)
  NRPT_TYPE_CRYSTAL_SYS constant number(1) := 0; --Crystal Reports
  NRPT_TYPE_EXCEL_SYS   constant number(1) := 1; --MS Excel
  NRPT_TYPE_OOCALC_SYS  constant number(1) := 3; --Open Office Calc
  --состояния позиции очередеди
  NQUEUE_STATE_INS constant number(1) := 0; --поставлено в очередь
  NQUEUE_STATE_RUN constant number(1) := 1; --обрабатывается
  NQUEUE_STATE_OK  constant number(1) := 2; --завершено успешно
  NQUEUE_STATE_ERR constant number(1) := 3; --завершено с ошибкой
  --способы сортировки коллекции отчетов
  NRPT_ORDER_NAME constant number(1) := 0; --по наименованию
  NRPT_ORDER_UNIT constant number(1) := 1; --по разделам привязки
  --обязательность параметра (WEB-сервис)
  NREQ_NO  constant number(1) := 0; --необязательный
  NREQ_YES constant number(1) := 1; --обязательный
  --обязательность параметра (Система)
  NREQ_NO_SYS  constant number(1) := 0; --необязательный
  NREQ_YES_SYS constant number(1) := 1; --обязательный
  --режимы загрузки отчета
  NDOWNLOAD_MODE_CHECK constant number(1) := 0; --проверить возможность загрузки
  NDOWNLOAD_MODE_GET   constant number(1) := 1; --загрузить
  --включенность отчета в список избранных
  NFAVOR_NO  constant number(1) := 0; --не включен в избранное
  NFAVOR_YES constant number(1) := 1; --включен в избранное
  --типы расписаний
  NSCHED_TYPE_MIN   constant number(1) := 0; --0 - минута
  NSCHED_TYPE_HOUR  constant number(1) := 1; --1 - час
  NSCHED_TYPE_DAY   constant number(1) := 2; --2 - день
  NSCHED_TYPE_WEEK  constant number(1) := 3; --3 - неделя
  NSCHED_TYPE_MONTH constant number(1) := 4; --4 - месяц
  NSCHED_TYPE_ONCE  constant number(1) := 5; --5 - единовременно
  --возможность отправки отчета по e-mail
  NMAIL_ENABLED_NO  constant number(1) := 0; --отправка невозможна
  NMAIL_ENABLED_YES constant number(1) := 1; --отправка возможна
  --отправка по e-mail
  NMAIL_NO  constant number(1) := 0; --отправлять
  NMAIL_YES constant number(1) := 1; --не отправлять
  --состояние отправки отчета по e-mail
  NMAIL_NOT_ORDERED constant number(1) := 0; --отправка не заказывалась
  NMAIL_WAIT        constant number(1) := 1; --ожидает отправки
  NMAIL_SEND_OK     constant number(1) := 2; --отправлен успешно
  NMAIL_SEND_ERR    constant number(1) := 3; --ошибка отправки
  --нет привязки к разделам
  NNOUNIT_RN   number(17) := 0; --рег. номер спец. раздела "Нет привязки к разделам"
  SNOUNIT_CODE varchar2(40) := 'NO_UNIT'; --код спец. раздела "Нет привязки к разделам"
  SNOUNIT_NAME varchar2(200) := ' Нет привязки к разделам'; --наименование спец. раздела "Нет привязки к разделам"
  --типы ответов сервиса
  SRESP_TYPE_KEY  constant varchar2(20) := 'RESP_TYPE'; --наименование ключа для идентификации ответа сервера
  SRESP_TYPE_VAL  constant varchar2(20) := 'PRNWS_MESSAGE'; --значение ключа для идентификации ответа сервера
  SRESP_STATE_KEY constant varchar2(20) := 'STATE'; --наименование ключа для описания в ответе состояния сервера
  SRESP_MSG_KEY   constant varchar2(20) := 'MSG'; --наименование ключа для описания в ответе сообщения сервера
  NRESP_TYPE_ERR  constant number(1) := 0; --ошибка выполнения
  NRESP_TYPE_OK   constant number(1) := 1; --успешное выполнение
  --запросы к серверу
  SREQ_TYPE_PRINT_KEY            constant varchar2(20) := 'SPRMS'; --наименование ключа для идентификации запроса к серверу печати отчетов
  SREQ_TYPE_HELP_KEY             constant varchar2(20) := 'HELP'; --наименование ключа для идентификации запроса о выдачи справочной информации
  SREQ_TYPE_HELP_VAL             constant varchar2(20) := 'YES'; --значение ключа для идентификации запроса о выдачи справочной информации
  SREQ_USER_KEY                  constant varchar2(20) := 'SUSER'; --наименование ключа для имени пользователя
  SREQ_PASSWORD_KEY              constant varchar2(20) := 'SPASSWORD'; --наименование ключа для имени пользователя
  SREQ_SESSION_CLIENT_KEY        constant varchar2(20) := 'SSESSION_CLIENT'; --наименование ключа для идентификатора сессии, сформированного клиентским приложением
  SREQ_SESSION_KEY               constant varchar2(20) := 'SSESSION'; --наименование ключа для идентификатора сессии
  SREQ_EXPECTED_SERVICE_VERS_KEY constant varchar2(40) := 'SEXPECTED_SERVICE_VERSION'; --наименование ключа для ожидаемой клиентом версии сервиса
  SREQ_ACTION_KEY                constant varchar2(20) := 'SACTION'; --наименование ключа для действия с сервером
  SREQ_ACTION_PRMS_KEY           constant varchar2(20) := 'SACTION_PRMS'; --наименование ключа для параметров действия
  SREQ_SEARCH_KEY                constant varchar2(20) := 'SSEARCH'; --наименование ключа для строки поиска
  SREQ_REPORT_KEY                constant varchar2(20) := 'NREPORT'; --наименование ключа для идентификатора отчета
  SREQ_REPORT_SCH_KEY            constant varchar2(20) := 'NREPORTSCH'; --наименование ключа для указания идентификатора расписания отчета
  SREQ_SCH_TYPE_KEY              constant varchar2(20) := 'NSCHED_TYPE'; --наименование ключа для указания типа расписания
  SREQ_SCH_STEP_KEY              constant varchar2(20) := 'NSTEP'; --наименование ключа для указания шага исполнения расписания
  SREQ_SCH_START_DATE_KEY        constant varchar2(20) := 'SSTART_DATE'; --наименование ключа для указания даты начала обработки расписания
  SREQ_SCH_MAIL_KEY              constant varchar2(20) := 'NSCHED_MAIL'; --наименование ключа для указания признака отправки подготовленного по расписанию отчета
  SREQ_PRM_KEY                   constant varchar2(20) := 'NPRM'; --наименование ключа для идентификатора параметра отчета
  SREQ_COMPANY_KEY               constant varchar2(20) := 'NCOMPANY'; --наименование ключа для идентификатора организации
  SREQ_SCOMPANY_KEY              constant varchar2(20) := 'SCOMPANY'; --наименование ключа для имени организации
  SREQ_UNIT_KEY                  constant varchar2(20) := 'NUNIT'; --наименование ключа для идентификатора раздела
  SREQ_FAVOR_KEY                 constant varchar2(20) := 'NFAVOR'; --наименование ключа для флага отображения избранных отчетов
  SREQ_PORTION_KEY               constant varchar2(20) := 'NPORTION'; --наименование ключа для указания номера порции данных (номера страницы)
  SREQ_PORTION_SIZE_KEY          constant varchar2(20) := 'NPORTION_SIZE'; --наименование ключа для указания размера порции данных (размера страницы)
  SREQ_RPT_ORDER_KEY             constant varchar2(20) := 'NRPT_ORDER'; --наименование ключа для указания порядка сортировки отчетов
  SREQ_PRMS_KEY                  constant varchar2(20) := 'PRMS'; --наименование ключа для идентификации списка параметров отчета
  SREQ_NAME_KEY                  constant varchar2(20) := 'SNAME'; --наименование ключа для указания имени
  SREQ_VAL_TYPE_KEY              constant varchar2(20) := 'NVAL_TYPE'; --наименование ключа для указания типа данных
  SREQ_VAL_KEY                   constant varchar2(20) := 'SVAL'; --наименование ключа для указания значения
  SREQ_REPORTQ_KEY               constant varchar2(20) := 'NREPORTQ'; --наименование ключа для указания идентификатора позиции очереди
  SREQ_TIME_STAMP_KEY            constant varchar2(20) := 'STIME_STAMP'; --наименование ключа для указания точной даты со временем
  SREQ_OPTION_KEY                constant varchar2(20) := 'SOPTION'; --наименование ключа для указания када считываемого параметра системы
  SREQ_ACT_LOGIN_VAL             constant varchar2(20) := 'LOGIN'; --значение ключа для действия (SREQ_ACTION_KEY) - "Аутентификация"
  SREQ_ACT_LOGOUT_VAL            constant varchar2(20) := 'LOGOUT'; --значение ключа для действия (SREQ_ACTION_KEY) - "Заверешение сеанса"
  SREQ_ACT_SESSION_CHECK_VAL     constant varchar2(20) := 'SESSION_CHECK'; --значение ключа для действия (SREQ_ACTION_KEY) - "Проверка активности сеанса"
  SREQ_ACT_OPTION_GET_STR_VAL    constant varchar2(20) := 'OPTION_GET_STR'; --значение ключа для действия (SREQ_ACTION_KEY) - "Считать значение параметра (строка)"
  SREQ_ACT_OPTION_GET_NUM_VAL    constant varchar2(20) := 'OPTION_GET_NUM'; --значение ключа для действия (SREQ_ACTION_KEY) - "Считать значение параметра (число)"
  SREQ_ACT_OPTION_GET_DATE_VAL   constant varchar2(20) := 'OPTION_GET_DATE'; --значение ключа для действия (SREQ_ACTION_KEY) - "Считать значение параметра (дата)"
  SREQ_ACT_OPTION_GET_CMPNS_VAL  constant varchar2(20) := 'OPTION_GET_COMPANIES'; --значение ключа для действия (SREQ_ACTION_KEY) - "Считать список организаций"
  SREQ_ACT_OPTION_CHECK_ACTV_VAL constant varchar2(20) := 'OPTION_CHECK_ACTIVE'; --значение ключа для действия (SREQ_ACTION_KEY) - "Определить активность сервиса"
  SREQ_ACT_UNITS_GET_VAL         constant varchar2(20) := 'UNITS_GET'; --значение ключа для действия (SREQ_ACTION_KEY) - "Получить список разделов к которым привязаны отчеты"
  SREQ_ACT_REPORT_GET_VAL        constant varchar2(20) := 'REPORT_GET'; --значение ключа для действия (SREQ_ACTION_KEY) - "Получить детальную информацию по отчету"
  SREQ_ACT_REPORTS_GET_VAL       constant varchar2(20) := 'REPORTS_GET'; --значение ключа для действия (SREQ_ACTION_KEY) - "Получить список отчетов"
  SREQ_ACT_REPORT_PUT_VAL        constant varchar2(20) := 'REPORT_PUT'; --значение ключа для действия (SREQ_ACTION_KEY) - "Поместить отчет в очередь"
  SREQ_ACT_REPORT_ADD_SCHED_VAL  constant varchar2(20) := 'REPORT_ADD_SCHED'; --значение ключа для действия (SREQ_ACTION_KEY) - "Добавить расписание для отчета"
  SREQ_ACT_REPORT_REM_SCHED_VAL  constant varchar2(20) := 'REPORT_REMOVE_SCHED'; --значение ключа для действия (SREQ_ACTION_KEY) - "Удалить расписание отчета"
  SREQ_ACT_REPORT_PREVIEW_VAL    constant varchar2(20) := 'REPORT_PREVIEW'; --значение ключа для действия (SREQ_ACTION_KEY) - "Предварительный просмотр отчета"
  SREQ_ACT_REPORT_FAVOR_TGL_VAL  constant varchar2(20) := 'REPORT_FAVOR_TOGGLE'; --значение ключа для действия (SREQ_ACTION_KEY) - "Поместить/убрать отчет в избранное"
  SREQ_ACT_REPORTQ_GET_VAL       constant varchar2(20) := 'REPORTQ_GET'; --значение ключа для действия (SREQ_ACTION_KEY) - "Получить детальную информацию о позиции очереди"
  SREQ_ACT_REPORTQS_GET_VAL      constant varchar2(20) := 'REPORTQS_GET'; --значение ключа для действия (SREQ_ACTION_KEY) - "Получить список позиций очереди"
  SREQ_ACT_REPORTQ_REMOVE_VAL    constant varchar2(20) := 'REPORTQ_REMOVE'; --значение ключа для действия (SREQ_ACTION_KEY) - "Удалить позицию очереди"
  SREQ_ACT_REPORTQ_DOWNLOAD_VAL  constant varchar2(20) := 'REPORTQ_DOWNLOAD'; --значение ключа для действия (SREQ_ACTION_KEY) - "Загрузить готовый отчет"
  SREQ_ACT_REPORTQ_REPEAT_VAL    constant varchar2(20) := 'REPORTQ_REPEAT'; --значение ключа для действия (SREQ_ACTION_KEY) - "Повторить печать"
  SREQ_ACT_REPORTQ_CHECK_NEW     constant varchar2(20) := 'REPORTQ_CHECK_NEW'; --значение ключа для действия (SREQ_ACTION_KEY) - "Проверка обновлений очереди"
  SREQ_ACT_PRM_DICT_RECS_GET_VAL constant varchar2(20) := 'PRM_DICT_RECS_GET'; --значение ключа для действия (SREQ_ACTION_KEY) - "Получить список значений параметра из связанного раздела"
  --виды ответов сервиса
  NRESP_KIND_JSON constant number(1) := 0; --ответ в JSON
  NRESP_KIND_XML  constant number(1) := 1; --ответ в XML
  --признаки формирования данных об объекте
  NINFO_BRIEF constant number(1) := 0; --краткая информация
  NINFO_FULL  constant number(1) := 1; --полная информация
  --типы словарей
  NDICT_TYPE_UNIT constant number(1) := 0; --раздел системы
  NDICT_TYPE_EXD  constant number(1) := 1; --дополнительный словарь
  NDICT_TYPE_RLU  constant number(1) := 2; --раздел привязки отчета
  --признаки возможности публикации отчета
  NIS_NOT_PUBLISHABLE constant number(1) := 0; --не подлежит публикации
  NIS_PUBLISHABLE     constant number(1) := 1; --подлежит публикации
  --признаки возможности оторажения отчета для пользователя
  NCAN_PUBLISH_USER_NO  constant number(1) := 0; --не отображается
  NCAN_PUBLISH_USER_YES constant number(1) := 1; --отображается
  --признаки исполнения отчета по расписанию
  NSCHEDULED_NO  constant number(1) := 0; --исполнен принудительно
  NSCHEDULED_YES constant number(1) := 1; --исполнен по расписанию
  --признаки игнорирования описания класса при поиске
  NNO_DESC_SEARCH_YES constant number(1) := 1; --не включать описание в поиск
  NNO_DESC_SEARCH_NO  constant number(1) := 0; --включать описание в поиск
  --наименование константы, указывающей на роль администратора
  SADMIN_ROLE_CONST_NAME constant varchar2(40) := 'ОТЧЕТНОСТЬ_АДМИНИСТРАТОР'; --константа, указывающая на роль администратора
  --организация системы
  type COMPANY is record(
     NRN        number(17) --рег. номер организации
    ,SNAME      varchar2(160) --краткое наименование
    ,SFULL_NAME varchar2(160) --полное наименование
    );

  --коллекция организаций системы
  type COMPANYS is table of COMPANY;

  --параметр конфигурации сервиса
  type CONF_PRM is record(
     SCODE varchar2(40) --код параметра
    ,SDESC varchar2(240) --описание параметра
    ,NTYPE number(1) --тип данных параметра (0 - строка, 1 - число, 2 - дата, 3 - булево значение, 4 - двоичные данные, 5 - текстовые данные)
    );

  --коллекция параметров конфигурации сервиса
  type CONF_PRMS is table of CONF_PRM;

  --набор параметров конфигурации для данной сессии
  CPS CONF_PRMS;

  --связь отчета с разделом
  type REPORT_LU is record(
     NRN        number(17) --рег. номер привязки
    ,NPRN       number(17) --рег. номер отчета
    ,SNAME      varchar2(160) --наименование привязки
    ,NUNIT      number(17) --рег. номер раздела
    ,SUNIT_CODE varchar2(40) --код раздела
    ,SUNIT_NAME varchar2(240) --наименование раздела
    );

  --коллекция связей отчета с разделами
  type REPORT_LUS is table of REPORT_LU;

  --запись расписания отчета
  type REPORT_SCH is record(
     NRN         number(17) --рег. номер расписания
    ,NPRN        number(17) --рег. номер отчета
    ,SUSR        varchar2(30) --пользователь
    ,NSCHED_TYPE number(1) --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц)
    ,NSTEP       number(17) --шаг исполнения расписания
    ,DSTART_DATE date --дата начала исполнения расписания
    ,NMAIL       number(1) --признак доставки по e-mail (0 - нет, 1 - да)
    );

  --коллекция расписаний отчета
  type REPORT_SCHS is table of REPORT_SCH;

  --параметр отчета
  type REPORT_PRM is record(
     NRN       number(17) --рег. номер параметра
    ,NPRN      number(17) --рег. номер отчета
    ,SNAME     varchar2(80) --имя параметра
    ,SPROMPT   varchar2(240) --приглашение ко вводу
    ,NREQ      number(1) --обязательный (0 - нет, 1 - да)
    ,NVAL_TYPE number(1) --тип данных (0 - строка, 1 - число, 2 - дата, 3 - булево)
    ,NINP_TYPE number(1) --способ ввода значения (0 - ручной ввод, 1 - выбор из словаря, 2 - контекст - организация, 3 - контекст - код раздела)
    ,SPREV_VAL varchar2(4000) --предыдущее указанное при заказе значение
    ,SDEF_VAL  varchar2(4000) --значение по-умолчанию
    );

  --коллекция параметров отчета
  type REPORT_PRMS is table of REPORT_PRM;

  --отчет
  type REPORT is record(
     NRN           number(17) --рег. номер отчета
    ,SCODE         varchar2(20) --код отчета
    ,SNAME         varchar2(160) --наименование отчета
    ,SDESC         varchar2(240) --описание
    ,NRPT_TYPE     number(1) --тип отчета (0 - CR, 1 - Excel, 2 - OO Calc)
    ,NFAVOR        number(1) --состояние избранности (0 - нет, 1 - да)
    ,NCNTQ         number(17) --количество отчетов в очереди
    ,NPREVIEW      number(1) --наличие предпросмотра (0 - нет, 1 - да)
    ,NSCHEDULED    number(1) --наличие расписаний (0 - нет, 1 - да)
    ,NMAIL_ENABLED number(1) --возможность доставки отчета по e-mail (0 - нет, 1 - да)
    ,SMAIL         varchar2(240) --адрес e-mail для доставки отчета
    ,LUS           REPORT_LUS --связи отчета с разделами
    ,SCHS          REPORT_SCHS --расписания формирования
    ,PRMS          REPORT_PRMS --параметры отчета
    );

  --элемент коллекции отчета
  type REPORTS_ITEM is record(
     NUNIT      number(17) --рег. номер текущего раздела (заполняется только при сортировке списка по разделам)
    ,SUNIT_CODE varchar2(40) --код текущего раздела (заполняется только при сортировке списка по разделам)
    ,SUNIT_NAME varchar2(240) --наименование текущего раздела (заполняется только при сортировке списка по разделам)
    ,RPT        REPORT --запись отчета
    );

  --коллекция отчетов
  type REPORTS is table of REPORTS_ITEM;

  --параметр позиции очереди печати
  type REPORTQ_PRM is record(
     NRN       number(17) --рег. номер параметра
    ,NPRN      number(17) --рег. номер позиции очереди
    ,SNAME     varchar2(80) --имя параметра
    ,SPROMPT   varchar2(240) --приглашение ко вводу
    ,NVAL_TYPE number(1) --тип данных (0 - строка, 1 - число, 2 - дата, 3 - булево)
    ,SVAL      varchar2(4000) --значение
    );

  --коллекция параметров позиции очереди печати
  type REPORTQ_PRMS is table of REPORTQ_PRM;

  --позиция очереди печати
  type REPORTQ is record(
     NRN          number(17) --рег. номер позиции очереди
    ,NREPORT      number(17) --рег. номер отчета
    ,SCODE        varchar2(20) --код позиции очереди
    ,SNAME        varchar2(160) --наименование позиции очереди
    ,SDESC        varchar2(240) --описание позиции очереди
    ,NTYPE        number(1) --тип позиции очереди (0 - CR, 1 - Excel, 2 - OO Calc)
    ,NQUEUE_STATE number(1) --состояние (0 - поставлено в очередь, 1 - выполнение начато, 2 - завершено успешно, 3 - завершено с ошибками)
    ,DQUEUE_TS    date --дата постановки в очередь
    ,DSTART_TS    date --дата старта формирования
    ,DFINISH_TS   date --дата окончания формирования
    ,SEXEC_TIME   varchar2(160) --срок исполнения (минут:секунд)
    ,SERR         varchar2(4000) --сообщение об ошибке исполнения
    ,NFAVOR       number(1) --состояние избранности (0 - нет, 1 - да)
    ,NSCHEDULED   number(1) --исполнен по расписанию (0 - нет, 1 - да)
    ,NMAILED      number(1) --состояние отправки по e-mail (0 - отправка не заказывалась, 1 - ожидает отправки, 2 - отправлен успешно, 3 - ошибка отправки)
    ,PRMS         REPORTQ_PRMS --параметры исполнения
    );

  --коллекция позиций очереди печати
  type REPORTQS is table of REPORTQ;

  --запись раздела-словаря
  type DICT_REC is record(
     NRN   number(17) --рег. номер записи словаря
    ,SCODE varchar2(4000) --код записи словаря
    ,SDESC varchar2(4000) --описание записи словаря
    ,SVAL  varchar2(4000) --возвращаемое значение словря
    );

  --коллекция записей словря
  type DICT_RECS is table of DICT_REC;

  --запись раздела
  type UNIT is record(
     NRN      number(17) --рег. номер записи раздела
    ,SCODE    varchar2(40) --код раздела
    ,SNAME    varchar2(160) --наименование раздела
    ,NREPORTS number(17) --количество привязанных отчетов
    );

  --коллекция разделов
  type UNITS is table of UNIT;

  --расчет диапаона выдаваемых записей
  procedure UTL_CALC_ROWS_LIMITS
  (
    NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NROW_FROM     out number --нижняя граница диапазона
   ,NROW_TO       out number --верхняя граница диапазона
  );

  --подготовка пользовательской строки поиска для вставки в запрос
  procedure UTL_PREPARE_SEARCH
  (
    SSEARCH          varchar2 --пользовательская строка поиска
   ,SSEARCH_PREPARED out varchar2 --подготовленная строка поиска
  );

  --формирование стандартного ответа сервиса
  function UTL_MAKE_RESP
  (
    NRESP_TYPE number --тип ответа (0 - ошибка, 1 - успех)
   ,NRESP_KIND number --вид ответа (0 - JSON, 1 - XML)
   ,SRESP_MSG  varchar2 --сообщение
  ) return clob;

  --проверка прав доступа пользователя на раздел/действия в разделе (0 - прав нет, 1 - права есть)
  function UTL_CHECK_PRIVS
  (
    SUSER    varchar2 --пользователь
   ,SUNIT    varchar2 --код раздела
   ,SACTION  varchar2 := null --код действия (для выборки - null, для остальных - системные коды действий)
   ,NCOMPANY number := null --рег. номер организации
   ,NVERSION number := null --рег. номер версии
   ,NJURPERS number := null --рег. номер юридического лица
   ,NCRN     number := null --рег. номер каталога
  ) return number;

  --проверка наличия роли у пользователя (0 - роль не назначена пользователю, 1 - назначена)
  function UTL_CHECK_USER_ROLE
  (
    SUSER  varchar2 --пользователь
   ,SROLE  varchar2 --роль (или список ролей с разделителем)
   ,SDELIM varchar2 := SLIST_DELIM --разделитель списков
  ) return number;

  --проверкая - является ли пользователь администратором (0 - не администратор, 1 - администратор)
  function UTL_CHECK_IS_ADMIN
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
  ) return number;

  --проверка возможности публикации отчета (0 - нет, 1 - да)
  function UTL_REPORT_PUBLISHABLE(NREPORT number --рег. номер отчета
                                  ) return number deterministic;

  --проверка возможности отображения отчета для пользователя (0 - нет, 1 - да)
  function UTL_REPORT_CAN_PUBLISH_USER
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,NUNIT    number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер раздела)
   ,NFAVOR   number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
  ) return number deterministic;

  --формирование имени файла картинки предпросмотра отчета
  function UTL_REPORT_BUILD_PW_FILE_NAME(NRN number --рег. номер картинки в таблице параметров публиккации отчета
                                         ) return varchar2;

  --формирование имени файла готового отчета
  function UTL_REPORTQ_BUILD_FILE_NAME(NREPORTQ number --рег. номер позиции очереди
                                       ) return varchar2;

  --формирование текста письма для рассылки готового отчета по E-mail
  procedure UTL_REPORTQ_BUILD_MAIL
  (
    NREPORTQ number --рег. номер позиции очереди
   ,SSUBJ    out varchar2 --тема письма
   ,STEXT    out varchar2 --текст письма
  );

  --получение наименования раздела по его рег. номеру
  function UTL_UNIT_NAME(NUNIT number --рег. номер раздела
                         ) return varchar2 deterministic;

  --подсчет количества привязанных к разделу отчетов, подлежащих публикации
  function UTL_UNIT_CNT_PUBREPORTS
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SSEARCH  varchar2 --строка поиска (null - не искать)
   ,NUNIT    number --рег. номер раздела (0 - для спец. раздела "Без привязки к разделу")
  ) return number deterministic;

  --скачивание файла
  procedure UTL_DOWNLOAD
  (
    NFILE in number --рег. номер готового файла отчета для позиции очереди печати
   ,NTYPE in number --тип файла (1 - готовый отчет, 2 - картинка предпросмотра отчета)
  );

  --конфигурация сервиса - поиск наименования параметра по его коду
  function CONF_FIND_PRM_DESC(SCODE varchar2 --код параметра
                              ) return varchar2;

  --конфигурация сервиса - базовое считывание значения параметра типа "Строка"
  function CONF_GET_PRM_STR_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
  ) return varchar2;

  --конфигурация сервиса - базовое считывание значения параметра типа "Число"
  function CONF_GET_PRM_NUM_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
  ) return number;

  --конфигурация сервиса - базовое считывание значения параметра типа "Дата"
  function CONF_GET_PRM_DATE_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
  ) return date;

  --конфигурация сервиса - базовое считывание картинки предварительного просмотра (возвращает URL)
  function CONF_GET_PICT_BASE(NRN number --рег. номер картинки
                              ) return varchar2;

  --клиентская установка значения параметров сервиса для раздела "Пользовательские отчеты"
  procedure CONF_SET_USR_REPORT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,NPUBL    number --признак публикации (0 - нет, 1 - да)
   ,SDESC    varchar2 --публикуемое описание отчета
  );

  --клиентская установка описания публикации для раздела "Пользовательские отчеты"
  procedure CONF_SET_USR_REPORT_DESC
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,SDESC    varchar2 --публикуемое описание отчета
  );

  --клиентская установка картинки предпросмотра для раздела "Пользовательские отчеты"
  procedure CONF_SET_USR_REPORT_PREVIEW
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,BPICT    blob --данные картинки
  );

  --клиентское переключение признака опубликованности для раздела "Пользовательские отчеты"
  procedure CONF_TOGGLE_USR_REPORT_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  );

  --клиентское удаление параметров сервиса для раздела "Пользовательские отчеты"
  procedure CONF_UNSET_USR_REPORT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  );

  --клиентское удаление картинки предварительного просмотра для раздела "Пользовательские отчеты"
  procedure CONF_UNSET_USR_REPORT_PREVIEW
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер картинки
  );

  --клиентское удаление расписания для раздела "Пользовательские отчеты"
  procedure CONF_UNSET_USR_REPORT_SCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер расписания
  );

  --клиентская установка значения параметров сервиса для раздела "Классы"
  procedure CONF_SET_CLASS
  (
    SUSER           varchar2 --пользователь
   ,NCOMPANY        number --рег. номер организации
   ,NRN             number --рег. номер класса
   ,SCODE_ATTR      varchar2 --наименование атрибута класса для формирования его кода
   ,SDESC_ATTR      varchar2 --наименование атрибута класса для формирования его описания
   ,NNO_DESC_SEARCH number --признак исключения атрибута описания из поиска (0 - искать по иписанию, 1 - не искать по описанию)
  );

  --клиентская установка значения параметров сервиса для раздела "Классы"
  procedure CONF_SET_CLASS_PUBL_ATTRS
  (
    SUSER      varchar2 --пользователь
   ,NCOMPANY   number --рег. номер организации
   ,NRN        number --рег. номер класса
   ,SCODE_ATTR varchar2 --наименование атрибута класса для формирования его кода
   ,SDESC_ATTR varchar2 --наименование атрибута класса для формирования его описания
  );

  --клиентское переключение признака игнорирования описания при поиске для раздела "Пользовательские отчеты"
  procedure CONF_TOGGLE_CLASS_NODESCSEARCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  );

  --клиентское удаление параметров сервиса для раздела "Классы"
  procedure CONF_UNSET_CLASS
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  );

  --проверка наличия расписания (0 - нет, 1 - есть)
  function SCHED_EXISTS
  (
    NPRN        number --рег. номер родительского отчета
   ,SUSR        varchar2 --пользователь
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц, 5 - единовременно)
   ,NSTEP       number --шаг исполнения расписания
   ,DSTART_DATE date --дата начала исполнения расписания
  ) return number;

  --базовое добавление записи расписания
  procedure SCHED_BASE_INSERT
  (
    NPRN        number --рег. номер родительского отчета
   ,SUSR        varchar2 --пользователь
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц, 5 - единовременно)
   ,NSTEP       number --шаг исполнения расписания
   ,DSTART_DATE date --дата начала исполнения расписания
   ,NMAIL       number --доставка по e-mail (0 - нет, 1 - да)
   ,CPRMS       clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
   ,NRN         out number --рег. номер добавленной записи расписания
  );

  --базовое удаление записи расписания
  procedure SCHED_BASE_DELETE(NRN number --рег. номер удаляемой записи
                              );

  --вычисление даты следующего запуска расписания
  function SCHED_CALC_NEXT_DATE(NRN number --рег. номер записи расписания
                                ) return date;

  --выяснение необходимости запуска позиции расписания
  function SCHED_CHECK_EXEC
  (
    NRN   number --рег. номер записи расписания
   ,DEXEC date := sysdate --дата, относительно которой необходимо выполнить проверку
  ) return boolean;

  --обработка зарегистрированных расписаний
  procedure SCHED_PROCESS;

  --формирование коллекции записей словаря
  procedure DICT_RECS_GET
  (
    NCOMPANY          number --рег. номер организации
   ,SUSER             varchar2 --пользователь
   ,SSEARCH           varchar2 --строка поиска (null - не искать)
   ,NPORTION          number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE     number --количество записей в порции (0 - все)
   ,NUNIT             number --рег. номер раздела системы/дополнительного словаря
   ,NSHOW_MENTHOD     number --рег. номер метода вызова раздела (игнорируется, если NUINT дополнительный словарь)
   ,NSHOW_MENTHOD_PRM number --рег. номер параметра метода вызова раздела (игнорируется, если NUINT дополнительный словарь)
   ,DCT_RECS          out DICT_RECS --сформированная коллекция записей словаря
  );

  --аутентификация в системе
  procedure SERVICE_LOGIN
  (
    SUSER                     varchar2 --пользователь
   ,SPASSWORD                 varchar2 --пароль
   ,SCOMPANY                  varchar2 --наименование организации
   ,SSESSION_CLIENT           varchar2 := null --идентификатор сессии сформированный клиентом
   ,SEXPECTED_SERVICE_VERSION varchar2 := null --ожидаемая клиентом версия сервиса
   ,SSESSION                  out varchar2 --идентификатор сессии
   ,NCOMPANY                  out number --рег. номер организации
  );

  --завершение сеанса системе
  procedure SERVICE_LOGOUT(SSESSION varchar2 --идентификатор сессии
                           );

  --проверка актуальности сессии
  procedure SERVICE_SESSION_CHECK
  (
    SUSER    varchar2 --пользователь
   ,SSESSION varchar2 --идентификатор сессии
  );

  --проверка активности сервиса (0 - неактивен, 1 - активен)
  function SERVICE_ACTIVE_CHECK return number;

  --считывание значения строкового параметра системы
  function SERVICE_OPTION_GET_STR
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return varchar2;

  --считывание значения числового параметра системы
  function SERVICE_OPTION_GET_NUM
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return number;

  --считывание значения датского параметра системы
  function SERVICE_OPTION_GET_DATE
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return date;

  --считывание организации
  procedure SERVICE_COMPANY_GET
  (
    NCOMPANY number --рег. номер записи
   ,CMPN     out COMPANY --сформированная запись организации
  );

  --считывание списка организаций
  procedure SERVICE_COMPANYS_GET
  (
    SUSER varchar2 --пользователь
   ,CMPNS out COMPANYS --коллекция организаций
  );

  --формирование записи раздела
  procedure UNIT_GET
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SSEARCH  varchar2 --строка поиска (null - не искать)
   ,NUNIT    number --рег. номер раздела (0 - для формирования спец. раздела "Без привязки к разделу")
   ,UNT      out UNIT --сформированная запись раздела
  );

  --формирование коллекции разделов, имеющих привязанные отчеты
  procedure UNITS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,UNTS          out UNITS --сформированная коллекция разделов
  );

  --формирование записи связи отчета с разделом
  procedure REPORT_LU_GET
  (
    NLU    number --рег. номер привязки
   ,RPT_LU out REPORT_LU --сформированная запись связи отчета с разделом
  );

  --формирование коллекции связей отчета с разделами
  procedure REPORT_LUS_GET
  (
    NREPORT number --рег. номер отчета
   ,RPT_LUS out REPORT_LUS --сформированная коллекция связей отчета с разделами
  );

  --формирование записи расписания отчета
  procedure REPORT_SCH_GET
  (
    NSCH    number --рег. номер расписания
   ,RPT_SCH out REPORT_SCH --сформированная запись расписания отчета
  );

  --формирование коллекции расписаний отчета
  procedure REPORT_SCHS_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,RPT_SCHS out REPORT_SCHS --сформированная коллекция расписаний отчета
  );

  --формирование записи параметра отчета
  procedure REPORT_PRM_GET
  (
    SUSER   varchar2 --пользователь
   ,NPRM    number --рег. номер параметра отчета
   ,RPT_PRM out REPORT_PRM --сформированная запись параметра отчета
  );

  --формирование коллекции параметров отчета
  procedure REPORT_PRMS_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,RPT_PRMS out REPORT_PRMS --сформированная коллекция параметров отчета
  );

  --формирование списка записей словаря параметра отчета
  procedure REPORT_PRM_DICT_RECS_GET
  (
    SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,SUNIT_CODE    out varchar2 --код раздела
   ,SUNIT_NAME    out varchar2 --наименование раздела
   ,DCT_RECS      out DICT_RECS --сформированная коллекция записей словаря
  );

  --формирование записи отчета
  procedure REPORT_GET
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
   ,RPT     out REPORT --сформированная запись отчета
  );

  --формирование коллекции отчетов
  procedure REPORTS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
   ,RPTS          out REPORTS --сформированная коллекция отчетов
  );

  --добавление отчета в очередь
  procedure REPORT_PUT
  (
    NCOMPANY   number --рег. номер организации
   ,SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NSCHEDULED number --признак исполнения по расписанию (0 - нет, 1 - да)
   ,NMAIL      number --признак отправки по e-mail (0 - нет, 1 - да)
   ,PRMS       REPORTQ_PRMS --набор параметров для формируемой позиции очереди
   ,NREPORTQ   out number --рег. номер сформированной позиции очереди
  );

  --добавление расписания для отчета
  procedure REPORT_ADD_SCHED
  (
    SUSER       varchar2 --пользователь
   ,NREPORT     number --рег. номер отчета
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц)
   ,NSTEP       number --шаг исполнения расписания
   ,DSTART_DATE date --дата начала исполнения расписания
   ,NMAIL       number --доставка по e-mail (0 - нет, 1 - да)
   ,CPRMS       clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
   ,NREPORTSCH  out number --рег. номер сформированной позиции расписания
  );

  --удаление расписания для отчета
  procedure REPORT_REMOVE_SCHED
  (
    SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NREPORTSCH number --рег. номер удаляемой позиции расписания (null - удаление всех расписаний этого пользователя для отчета)
  );

  --выгрузка картинки предпросмотра для отчета
  procedure REPORT_PREVIEW
  (
    NREPORT number --рег. номер отчета
   ,SURL    out varchar2 --URL картинки для предпросмотра
  );

  --формирование записи параметра позиции очереди
  procedure REPORTQ_PRM_GET
  (
    NPRMQ    number --рег. номер параметра позиции очереди
   ,RPTQ_PRM out REPORTQ_PRM --запись параметра позиции очереди
  );

  --формирование коллекции параметров для позиции очереди
  procedure REPORTQ_PRMS_GET
  (
    NREPORTQ  number --рег. номер позиции очереди
   ,RPTQ_PRMS out REPORTQ_PRMS --коллекция параметров позиции очереди
  );

  --формирование записи позиции очереди
  procedure REPORTQ_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
   ,RPTQ     out REPORTQ --запись позиции очереди
  );

  --формирование коллекции позиций очереди
  procedure REPORTQS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,RPTQS         out REPORTQS --сформированная коллекция позиций очереди
  );

  --удаление позиции очереди
  procedure REPORTQ_REMOVE
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  );

  --выгрузка готового отчета из позиции очереди
  procedure REPORTQ_DOWNLOAD
  (
    NREPORTQ   number --рег. номер позиции очереди
   ,SFILE_NAME out varchar2 --имя файла
   ,SURL       out varchar2 --URL файла для загрузки
  );

  --повтор заказа отчета
  procedure REPORTQ_REPEAT
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  );

  --проверка наличия обновлений очереди
  procedure REPORTQ_CHECK_NEW
  (
    NCOMPANY         number --рег. номер организации
   ,SUSER            varchar2 --пользователь
   ,STIME_STAMP      varchar2 --хронологическая точка отсчета проверки (ГГГГ-ММ-ДД ЧЧ24:МИ:СС)
   ,NREPORTQ_NEW_CNT out number --количество новых готовых позиций очереди с момента STIME_STAMP
  );

  --разбор стандартного ответа сервера (в JSON)
  procedure JSON_PARSE_RESPONSE
  (
    CJSON      clob --данные ответа
   ,NRESP_TYPE out number --тип ответа (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
   ,SRESP_MSG  out varchar2 --сообщение сервера
  );

  --аутентификация в сервисе (ответ в JSON)
  function JSON_SERVICE_LOGIN
  (
    SUSER                     varchar2 --пользователь
   ,SPASSWORD                 varchar2 --пароль
   ,SCOMPANY                  varchar2 --наименование организации
   ,SSESSION_CLIENT           varchar2 := null --идентификатор сессии сформированный клиентом
   ,SEXPECTED_SERVICE_VERSION varchar2 := null --ожидаемая клиентом версия сервиса
  ) return clob;

  --завершение сеанса работы с сервисом (ответ в JSON)
  function JSON_SERVICE_LOGOUT(SSESSION varchar2 --идентификатор сессии
                               ) return clob;

  --валидация сеанса работы с сервисом (ответ в JSON)
  function JSON_SERVICE_SESSION_CHECK(SSESSION varchar2 --идентификатор сессии
                                      ) return clob;

  --проверка активности сервиса (ответ в JSON)
  function JSON_SERVICE_ACTIVE_CHECK return clob;

  --считывание строкового параметра сиситемы (ответ в JSON)
  function JSON_SERVICE_OPTION_GET_STR
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return clob;

  --считывание числового параметра сиситемы (ответ в JSON)
  function JSON_SERVICE_OPTION_GET_NUM
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return clob;

  --считывание датского параметра сиситемы (ответ в JSON)
  function JSON_SERVICE_OPTION_GET_DATE
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return clob;

  --считывание списка организаций (ответ в JSON)
  function JSON_SERVICE_COMPANYS_GET(SUSER varchar2 --пользователь
                                     ) return clob;

  --запрос детальной информации о разделе (в JSON)
  function JSON_UNIT_GET
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SSEARCH  varchar2 --строка поиска (null - не искать)
   ,NUNIT    number --рег. номер раздела
  ) return clob;

  --запрос списка разделов, имеющих привязанные отчеты (в JSON)
  function JSON_UNITS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
  ) return clob;

  --запрос детальной информации об отчете (в JSON)
  function JSON_REPORT_GET
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
   ,NINFO   number := 0 --признак выдачи информации (0 - полная, 1 - краткая)
  ) return clob;

  --запрос списка отчетов (в JSON)
  function JSON_REPORTS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
  ) return clob;

  --постановка отчета в очередь (ответ о результате постановки в JSON)
  function JSON_REPORT_PUT
  (
    NCOMPANY   number --рег. номер организации
   ,SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NSCHEDULED number --признак исполнения по расписанию (0 - нет, 1 - да)
   ,NMAIL      number --признак отправки по e-mail (0 - нет, 1 - да)
   ,CPRMS      clob --JSON описание параметров печати
  ) return clob;

  --формирование расписания отчета (ответ о результате формирования в JSON)
  function JSON_REPORT_ADD_SCHED
  (
    SUSER       varchar2 --пользователь
   ,NREPORT     number --рег. номер отчета
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц)
   ,NSTEP       number --шаг исполнения расписания
   ,SSTART_DATE varchar2 --дата начала исполнения расписания (ГГГГ-ММ-ДД ЧЧ24:МИ:СС), строковое представлениe
   ,NMAIL       number --доставка по e-mail (0 - нет, 1 - да)
   ,CPRMS       clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
  ) return clob;

  --удаление расписания отчета (ответ о результате постановки в JSON)
  function JSON_REPORT_REMOVE_SCHED
  (
    SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NREPORTSCH number --рег. номер удаляемой позиции расписания (null - удаление всех расписаний этого пользователя для отчета)
  ) return clob;

  --выгрузка картинки предпросмотра для отчета (ответ о результате в JSON)
  function JSON_REPORT_PREVIEW(NREPORT number --рег. номер отчета
                               ) return clob;

  --формирование списка записей словаря параметра отчета
  function JSON_REPORT_PRM_DICT_RECS_GET
  (
    SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
  ) return clob;

  --запрос детальной информации о позиции очереди (в JSON)
  function JSON_REPORTQ_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
   ,NINFO    number := 0 --признак выдачи информации (0 - полная, 1 - краткая)
  ) return clob;

  --запрос списка позиций очереди (в JSON)
  function JSON_REPORTQS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
  ) return clob;

  --удаление позиции из очереди (ответ о результате удаления в JSON)
  function JSON_REPORTQ_REMOVE
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) return clob;

  --выгрузка отчета из очереди (ответ о результате в JSON)
  function JSON_REPORTQ_DOWNLOAD(NREPORTQ number --рег. номер позиции очереди
                                 ) return clob;

  --повторная постановка отчета в очередь (ответ о результате постановки в JSON)
  function JSON_REPORTQ_REPEAT
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) return clob;

  --проверка наличия обновлений очереди (ответ о результате проверки в JSON)
  function JSON_REPORTQ_CHECK_NEW
  (
    NCOMPANY    number --рег. номер организации
   ,SUSER       varchar2 --пользователь
   ,STIME_STAMP varchar2 --хронологическая точка отсчета проверки (ГГГГ-ММ-ДД ЧЧ24:МИ:СС), строковое представлениe
  ) return clob;

  --выдача справки по WEB-сервису обслуживания очереди печати отчетов
  function JSON_URPT_SRV_HELP return clob;

  --универсальная функция обработки запросов к WEB-сервису обслуживания очереди печати отчетов (ответ в CLOB)
  function JSON_URPT_SRV_PROCESS(CPRMS clob --параметры запроса (JSON)
                                 ) return clob;

  --универсальная процедура обработки запросов к WEB-сервису обслуживания очереди печати отчетов (выдача ответа вебсерверу)
  procedure JSON_URPT_SRV(CPRMS clob --параметры запроса (JSON)
                          );

end;
/

create or replace package body UDO_PKG_URPT_SRV as

  --считывание основного строкового значения указанной константы
  function UTL_GET_CONST_VAL_STR
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

  --расчет диапаона выдаваемых записей
  procedure UTL_CALC_ROWS_LIMITS
  (
    NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NROW_FROM     out number --нижняя граница диапазона
   ,NROW_TO       out number --верхняя граница диапазона
  ) is
  begin
    if (NPORTION_SIZE <= 0)
    then
      NROW_FROM := 1;
      NROW_TO   := 1000000000;
    else
      NROW_FROM := NPORTION * NPORTION_SIZE - NPORTION_SIZE + 1;
      NROW_TO   := NPORTION * NPORTION_SIZE;
    end if;
  end;

  --подготовка пользовательской строки поиска для вставки в запрос
  procedure UTL_PREPARE_SEARCH
  (
    SSEARCH          varchar2 --пользовательская строка поиска
   ,SSEARCH_PREPARED out varchar2 --подготовленная строка поиска
  ) is
    SANY_SYS char(1) := '%'; --маска "любое количество любых символов" Oracle
    SONE_SYS char(1) := '_'; --маска "любой один символ" Oracle
    SANY_PRS varchar2(240) := PKG_OPTIONS.STARSYMB; --маска "любое количество любых символов" Парус
    SONE_PRS varchar2(240) := PKG_OPTIONS.QUESTSYMB; --маска "любой один символ" Парус
  begin
    --если пользовательская строка пустая - то это всё что угодно
    if (SSEARCH is null)
    then
      SSEARCH_PREPARED := SANY_SYS;
    else
      --подменим пользовательские маски на системные и соберем подготовленную строку поиска
      SSEARCH_PREPARED := '%' || replace(replace(replace(SSEARCH
                                                        ,SANY_PRS
                                                        ,SANY_SYS)
                                                ,SONE_PRS
                                                ,SONE_SYS)
                                        ,SENT_WRD_DELIM
                                        ,SANY_SYS) || '%';
    end if;
  end;

  --формирование стандартного ответа сервиса
  function UTL_MAKE_RESP
  (
    NRESP_TYPE number --тип ответа (0 - ошибка, 1 - успех)
   ,NRESP_KIND number --вид ответа (0 - JSON, 1 - XML)
   ,SRESP_MSG  varchar2 --сообщение
  ) return clob is
    CRESP clob; --текст ответа
  begin
    --откроем буфер
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                            ,CACHE   => false);
    --собираем ответ
    case NRESP_KIND
      when NRESP_KIND_JSON then
        declare
          JRESP JSON;
        begin
          JRESP := JSON();
          JRESP.PUT(PAIR_NAME  => SRESP_TYPE_KEY
                   ,PAIR_VALUE => SRESP_TYPE_VAL);
          JRESP.PUT(PAIR_NAME  => SRESP_STATE_KEY
                   ,PAIR_VALUE => NRESP_TYPE);
          JRESP.PUT(PAIR_NAME  => SRESP_MSG_KEY
                   ,PAIR_VALUE => SRESP_MSG);
          JRESP.TO_CLOB(BUF => CRESP);
        end;
      when NRESP_KIND_XML then
        begin
          null;
        end;
      else
        null;
    end case;
    --вернем результат
    return CRESP;
  end;

  --считывание записи организации
  function UTL_COMPANY_REC
  (
    NCOMPANY number --рег. номер организации
   ,NSMART   number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return COMPANIES%rowtype is
    RES COMPANIES%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from COMPANIES T
       where T.RN = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NCOMPANY
                                ,SUNIT_TABLE => 'COMPANIES');
    end;
    --вернем результат
    return RES;
  end;

  --считывание записи связи отчета с разделом
  function UTL_REPORT_LU_REC
  (
    NLU    number --рег. номер привязки
   ,NSMART number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return USERREPORTSLINKS%rowtype is
    RES USERREPORTSLINKS%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from USERREPORTSLINKS T
       where T.RN = NLU;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NLU
                                ,SUNIT_TABLE => 'USERREPORTSLINKS');
    end;
    --вернем результат
    return RES;
  end;

  --считывание записи расписания отчета
  function UTL_REPORT_SCH_REC
  (
    NSCH   number --рег. номер расписания
   ,NSMART number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return UDO_T_URPT_SRV_SCHED%rowtype is
    RES UDO_T_URPT_SRV_SCHED%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from UDO_T_URPT_SRV_SCHED T
       where T.RN = NSCH;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NSCH
                                ,SUNIT_TABLE => 'UDO_T_URPT_SRV_SCHED');
    end;
    --вернем результат
    return RES;
  end;

  --считывание записи парамера отчета
  function UTL_REPORT_PRM_REC
  (
    NPRM   number --рег. номер параметра отчета
   ,NSMART number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return USERREPORTS_PARAMS%rowtype is
    RES USERREPORTS_PARAMS%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from USERREPORTS_PARAMS T
       where T.RN = NPRM;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NPRM
                                ,SUNIT_TABLE => 'USERREPORTS_PARAMS');
    end;
    --вернем результат
    return RES;
  end;

  --считывание записи парамера отчета по имени параметра
  function UTL_REPORT_PRM_REC_BY_NAME
  (
    NREPORT   number --рег. номер отчета
   ,SPRM_NAME varchar2 --имя параметра отчета
   ,NSMART    number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return USERREPORTS_PARAMS%rowtype is
    RES USERREPORTS_PARAMS%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from USERREPORTS_PARAMS T
       where T.PRN = NREPORT
         and T.NAME = SPRM_NAME;
    exception
      when others then
        RES.RN := null;
        P_EXCEPTION(NSMART
                   ,'Ошибка поиска параметра "' || SPRM_NAME ||
                    '" для отчета с идентификатором "' || NREPORT || '"!');
    end;
    --вернем результат
    return RES;
  end;

  --считывание записи отчета
  function UTL_REPORT_REC
  (
    NREPORT number --рег. номер отчета
   ,NSMART  number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return USERREPORTS%rowtype is
    RES USERREPORTS%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from USERREPORTS T
       where T.RN = NREPORT;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NREPORT
                                ,SUNIT_TABLE => 'USERREPORTS');
    end;
    --вернем результат
    return RES;
  end;

  --проверка возможности публикации отчета (0 - нет, 1 - да)
  function UTL_REPORT_PUBLISHABLE(NREPORT number --рег. номер отчета
                                  ) return number deterministic is
  begin
    for C in (select /*+ RULE*/
               UR.RN NRN
                from USERREPORTS UR
               where UR.RN = UTL_REPORT_PUBLISHABLE.NREPORT
                    --есть хранимая процедура
                 and UR.STORED_PROC is not null
                    --тип отчета - только CR, Excel, OOCalc
                 and UR.REPORT_TYPE in (NRPT_TYPE_CRYSTAL_SYS
                                       ,NRPT_TYPE_EXCEL_SYS
                                       ,NRPT_TYPE_OOCALC_SYS)
                    --есть только параметры привязанные к организации, разделу, дополнительному словарю, учетному регистру или непривязанные
                 and (select count(P.RN)
                        from USERREPORTS_PARAMS P
                       where P.PRN = UR.RN
                         and P.LINKING not in
                             (NINP_TYPE_MANUAL_SYS
                             ,NINP_TYPE_COMPANY_SYS
                             ,NINP_TYPE_DOC_SYS
                             ,NINP_TYPE_EXDICT_SYS
                             ,NINP_TYPE_UNIT_SYS)) = 0
                    --есть только параметры типа строка, число, валюта, логический, дата
                 and (select count(P.RN)
                        from USERREPORTS_PARAMS P
                       where P.PRN = UR.RN
                         and P.DATA_TYPE not in
                             (NVAL_TYPE_STR_SYS
                             ,NVAL_TYPE_NUMB_SYS
                             ,NVAL_TYPE_CURR_SYS
                             ,NVAL_TYPE_BOOL_SYS
                             ,NVAL_TYPE_DATE_SYS)) = 0
                    --брать только если нет параметров, привязанных друг к другу (номенклатура - модицифкаиця, например)
                 and (select count(P.RN)
                        from USERREPORTS_PARAMS P
                       where P.PRN = UR.RN
                         and P.INIT_RN is not null) = 0
                    --не брать, если есть параметр привязанный к коду раздела и нет привязки к разделам
                 and (((select count(P.RN)
                          from USERREPORTS_PARAMS P
                         where P.PRN = UR.RN
                           and P.LINKING = NINP_TYPE_UNIT_SYS) = 0) or
                     (((select count(P.RN)
                           from USERREPORTS_PARAMS P
                          where P.PRN = UR.RN
                            and P.LINKING = NINP_TYPE_UNIT_SYS) > 0) and
                     (exists (select null
                                  from USERREPORTSLINKS URL2
                                 where URL2.PRN = UR.RN)))))
    loop
      --если такой есть - значит выходим
      return NIS_PUBLISHABLE;
    end loop;
    --в курсор не вошли - отчет не отвечает условиям публикации
    return NIS_NOT_PUBLISHABLE;
  exception
    when others then
      return NIS_NOT_PUBLISHABLE;
  end;

  --проверка возможности отображения отчета для пользователя (0 - нет, 1 - да)
  function UTL_REPORT_CAN_PUBLISH_USER
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,NUNIT    number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер раздела)
   ,NFAVOR   number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
  ) return number deterministic is
  begin
    for C in (select /*+ RULE*/
               UR.RN NRN
                from USERREPORTS      UR
                    ,USERREPORTSLINKS URL
                    ,UNITLIST         UL
               where UR.COMPANY = UTL_REPORT_CAN_PUBLISH_USER.NCOMPANY
                 and UR.RN = UTL_REPORT_CAN_PUBLISH_USER.NREPORT
                 and UR.RN = URL.PRN(+)
                 and URL.UNITCODE = UL.UNITCODE(+)
                    --только публикуемые
                 and UTL_REPORT_PUBLISHABLE(NREPORT => UR.RN) = NIS_PUBLISHABLE
                    --установлен признак публикации
                 and CONF_GET_PRM_NUM_BASE(SUNIT   => 'UserReports'
                                          ,NUNITRN => UR.RN
                                          ,SPRM    => SCONF_USR_REPORT_PUBL) = 1
                    --только относящиеся к указанному разделу
                 and ((UTL_REPORT_CAN_PUBLISH_USER.NUNIT is null) or
                     ((UTL_REPORT_CAN_PUBLISH_USER.NUNIT is not null) and
                     (UTL_REPORT_CAN_PUBLISH_USER.NUNIT =
                     NVL(UL.RN
                           ,NNOUNIT_RN))))
                    --только имеющие указанный признак избранности
                 and ((UTL_REPORT_CAN_PUBLISH_USER.NFAVOR is null) or
                     ((UTL_REPORT_CAN_PUBLISH_USER.NFAVOR is not null) and
                     (((UTL_REPORT_CAN_PUBLISH_USER.NFAVOR = NFAVOR_NO) and
                     (not exists (select null
                                        from UDO_T_URPT_SRV_FAVOR T
                                       where T.RPT = UR.RN
                                         and T.USR = SUSER))) or
                     ((UTL_REPORT_CAN_PUBLISH_USER.NFAVOR = NFAVOR_YES) and
                     (exists (select null
                                    from UDO_T_URPT_SRV_FAVOR T
                                   where T.RPT = UR.RN
                                     and T.USR = SUSER))))))
                    --есть права доступа к каталогу хранения
                 and UTL_CHECK_PRIVS(SUSER => SUSER
                                    ,SUNIT => 'UserReports'
                                    ,NCRN  => UR.CRN) = NHAVE_PRIVS)
    loop
      --если такой есть - значит выходим
      return NCAN_PUBLISH_USER_YES;
    end loop;
    --в курсор не вошли - отчет не отвечает условиям публикации
    return NCAN_PUBLISH_USER_NO;
  exception
    when others then
      return NCAN_PUBLISH_USER_NO;
  end;

  --формирование имени файла картинки предпросмотра отчета
  function UTL_REPORT_BUILD_PW_FILE_NAME(NRN number --рег. номер картинки в таблице параметров публиккации отчета
                                         ) return varchar2 is
    SEXT       varchar2(200); --расширение файла
    SFILE_NAME varchar2(2000); --имя файла картинки
  begin
    --определимся с расширением
    SEXT := 'png';
    --сформируем имя файла
    SFILE_NAME := 'PREVIEW_' || TO_CHAR(NRN) || '.' || SEXT;
    --вернем результат
    return SFILE_NAME;
  exception
    when others then
      return null;
  end;

  --считывание записи параметра позиции очереди
  function UTL_REPORTQ_PRM_REC
  (
    NPRMQ  number --рег. номер параметра позиции очереди
   ,NSMART number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return RPTPRTQUEUE_PRM%rowtype is
    RES RPTPRTQUEUE_PRM%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from RPTPRTQUEUE_PRM T
       where T.RN = NPRMQ;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NPRMQ
                                ,SUNIT_TABLE => 'RPTPRTQUEUE_PRM');
    end;
    --вернем результат
    return RES;
  end;

  --считывание записи позиции очереди
  function UTL_REPORTQ_REC
  (
    NREPORTQ number --рег. номер позиции очереди
   ,NSMART   number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return RPTPRTQUEUE%rowtype is
    RES RPTPRTQUEUE%rowtype; --результат работы
  begin
    --считаем данные
    begin
      select T.*
        into RES
        from RPTPRTQUEUE T
       where T.RN = NREPORTQ;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART
                                ,NDOCUMENT   => NREPORTQ
                                ,SUNIT_TABLE => 'RPTPRTQUEUE');
    end;
    --вернем результат
    return RES;
  end;

  --добавление документа в буфер отмеченных записей позиции очереди
  procedure UTL_REPORTQ_LST_BASE_INSERT
  (
    NPRN         number --регистрационный номер записи родителя
   ,NTYPE        number --тип: 0 - из списка отмеченных записей
   ,NIDENT       number --идентификатор помеченных записей
   ,NDOCUMENT    number --документ 0
   ,SUNITCODE    varchar2 --код раздела документа 0
   ,SACTIONCODE  varchar2 --код действия документа 0
   ,NCATALOG     number --каталог документа 0
   ,NDOCUMENT1   number --документ 1
   ,SUNITCODE1   varchar2 --код раздела документа 1
   ,SACTIONCODE1 varchar2 --код действия документа 1
   ,NRN          out number --регистрационный номер записи
  ) as
  begin
    /* генерация регистрационного номера записи */
    NRN := GEN_RPTQ();
    /* добавление записи в таблицу */
    insert into RPTPRTQUEUE_LST
      (RN
      ,PRN
      ,type
      ,IDENT
      ,DOCUMENT
      ,UNITCODE
      ,ACTIONCODE
      ,CATALOG
      ,DOCUMENT1
      ,UNITCODE1
      ,ACTIONCODE1)
    values
      (NRN
      ,NPRN
      ,NTYPE
      ,NIDENT
      ,NDOCUMENT
      ,SUNITCODE
      ,SACTIONCODE
      ,NCATALOG
      ,NDOCUMENT1
      ,SUNITCODE1
      ,SACTIONCODE1);
  end;

  --добавление параметра позиции очереди
  procedure UTL_REPORTQ_PRM_BASE_INSERT
  (
    NPRN        number --регистрационный номер записи родителя
   ,SNAME       varchar2 --имя параметра
   ,NDATA_TYPE  number --тип данных
   ,SSTR_VALUE  varchar2 --значение (строка)
   ,NNUM_VALUE  number --значение (число, валюта, логический)
   ,DDATE_VALUE date --значение (дата)
   ,NRN         out number --регистрационный номер записи
  ) as
  begin
    --генерация регистрационного номера записи
    NRN := GEN_RPTQ;
    --добавление записи в таблицу
    insert into RPTPRTQUEUE_PRM
      (RN, PRN, name, DATA_TYPE, STR_VALUE, NUM_VALUE, DATE_VALUE)
    values
      (NRN, NPRN, SNAME, NDATA_TYPE, SSTR_VALUE, NNUM_VALUE, DDATE_VALUE);
  end;

  --добавление позиции очереди
  procedure UTL_REPORTQ_BASE_INSERT
  (
    SUSER        varchar2 --пользователь
   ,NREPORT_TYPE number --тип отчёта
   ,NCOMPANY     number --организация
   ,NIDENT       number --идентификатор процесса
   ,NUSER_REPORT number --пользовательский отчёт
   ,NRN          out number --регистрационный номер записи
  ) as
  begin
    --генерация регистрационного номера записи
    NRN := GEN_RPTQ;
    --добавление записи в таблицу
    insert into RPTPRTQUEUE
      (RN
      ,authid
      ,STATUS
      ,QUEUE_TIME_STAMP
      ,BEGIN_TIME_STAMP
      ,END_TIME_STAMP
      ,ERROR_TEXT
      ,ERROR_TRACE
      ,REPORT_TYPE
      ,COMPANY
      ,IDENT
      ,USER_REPORT)
    values
      (NRN
      ,SUSER
      ,PKG_RPTPRTQUEUE.STATUS_QUEUE
      ,sysdate
      ,null
      ,null
      ,null
      ,null
      ,NREPORT_TYPE
      ,NCOMPANY
      ,NIDENT
      ,NUSER_REPORT);
  end;

  --формирование имени файла готового отчета
  function UTL_REPORTQ_BUILD_FILE_NAME(NREPORTQ number --рег. номер позиции очереди
                                       ) return varchar2 is
    RPTQ_REC   RPTPRTQUEUE%rowtype; --запись позиции очереди
    RPT_REC    USERREPORTS%rowtype; --запись отчета
    SEXT       varchar2(200); --расширение файла
    SFILE_NAME varchar2(2000); --имя файла отчета
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => RPTQ_REC.USER_REPORT);
    --определимся с расширением и дескриптором типа
    case RPT_REC.REPORT_TYPE
      when NRPT_TYPE_CRYSTAL_SYS then
        SEXT := 'pdf';
      when NRPT_TYPE_EXCEL_SYS then
        SEXT := 'xls';
      when NRPT_TYPE_OOCALC_SYS then
        SEXT := 'ods';
      else
        SEXT := 'dat';
    end case;
    --сформируем имя файла
    SFILE_NAME := RPTQ_REC.AUTHID || '_' || TO_CHAR(RPTQ_REC.RN) || '.' || SEXT;
    --вернем результат
    return SFILE_NAME;
  exception
    when others then
      return null;
  end;

  --формирование текста письма для рассылки готового отчета по E-mail
  procedure UTL_REPORTQ_BUILD_MAIL
  (
    NREPORTQ number --рег. номер позиции очереди
   ,SSUBJ    out varchar2 --тема письма
   ,STEXT    out varchar2 --текст письма
  ) is
    RPTQ_REC      RPTPRTQUEUE%rowtype; --запись позиции очереди
    JRPTQ         JSON; --объектное представлеие позиции очереди из ответа
    JRPTQ_PRMS    JSON_LIST; --объектное представление списка параметров позиции очереди
    JRPTQ_PRM     JSON; --объектное представление параметра позиции очереди
    STYPE         varchar2(200); --текстовое описание типа позиции очереди
    SSTATE        varchar2(200); --текстовое описание состояния позиции очереди
    SSTATE_COLOR  varchar2(200); --текстовое описание цвета состояния позиции очереди
    SSCH          varchar2(200); --текстовое описание способа добавления отчета в очередь
    SSCH_COLOR    varchar2(200); --текстовое описание цвета способа добавления отчета в очередь
    SPRMS         clob; --буфер для верстки параметров
    BPRMS_SHOW    boolean := false; --признак наличия параметров
    SVAL          varchar2(4000); --преобразованное для публикации значение параметра позиции очереди
    SHTML         varchar2(32000);
    SHEADER_CLASS varchar2(40) := '';
    STABLE_CLASS  varchar2(40) := '';
    STR_CLASS     varchar2(40) := '';
    STH_CLASS     varchar2(40) := '';
    STD_CLASS     varchar2(40) := '';
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --сформируем объектное представление отчета
    JRPTQ := JSON(JSON_REPORTQ_GET(SUSER    => RPTQ_REC.AUTHID
                                  ,NREPORTQ => RPTQ_REC.RN
                                  ,NINFO    => NINFO_FULL));
    --экранируем строковые поля
    UDO_PKG_SYSW0003_PUBL_UTILS.JSON_ESCAPE(SFIELDS => 'SCODE;SNAME;SDESC;SEXEC_TIME;SERR'
                                           ,OBJ     => JRPTQ);
    --строим тему сообщения в зависимости от статуса позиции очереди
    case RPTQ_REC.STATUS
    --отчет сформирован успешно
      when NQUEUE_STATE_OK then
        begin
          SSUBJ := SSERVICE_NAME || ' - подготовлен отчет "' || JRPTQ.GET('SNAME')
                  .GET_STRING || '"';
        end;
        --отчет сформирован с ошибками
      when NQUEUE_STATE_ERR then
        begin
          SSUBJ := SSERVICE_NAME || ' - ошибка подготовки отчета "' || JRPTQ.GET('SNAME')
                  .GET_STRING || '"';
        end;
      else
        SSUBJ := null;
    end case;
    --если с темой определились - строим тело
    if (SSUBJ is not null)
    then
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
      --заголовок
      SHTML := '<h1 class="' || SHEADER_CLASS || '">' || JRPTQ.GET('SNAME')
              .GET_STRING || '</h1>';
      --детали описания - начало
      SHTML := SHTML || '<table cellpadding="0" cellspacing="0" class="' ||
               STABLE_CLASS || '"><tr class="' || STR_CLASS || '"><td class="' ||
               STH_CLASS ||
               '"><h2>Детали</h2></td></tr><tr><td style="padding-top:10px;padding-bottom:10px">';
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
               '"><b>Тип:</b></td><td class="' || STD_CLASS || '">' || STYPE ||
               '</td></tr>';
      --состояние
      SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
               '"><b>Состояние:</b></td><td class="' || STD_CLASS ||
               '"><span style="color:' || SSTATE_COLOR || '"><b>' || SSTATE ||
               '</b></span></td></tr>';
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
               '"><b>Завершение обработки:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('DFINISH_TS')
              .GET_STRING || '</td></tr>';
      --длительность обработки
      SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
               '"><b>Длительность обработки:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('SEXEC_TIME')
              .GET_STRING || '</td></tr>';
      --способ постановки в очередь
      SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
               '"><b>Способ заказа:</b></td><td class="' || STD_CLASS ||
               '"><span style="color:' || SSCH_COLOR || '"><b>' || SSCH ||
               '</b></span></td></tr>';
      --сообщение об ошибке обработки
      if (JRPTQ.GET('NQUEUE_STATE')
         .GET_NUMBER = UDO_PKG_URPT_SRV.NQUEUE_STATE_ERR)
      then
        SHTML := SHTML || '<tr><td class="' || STD_CLASS ||
                 '"><b>Ошибка обработки:</b></td><td class="' || STD_CLASS || '">' || JRPTQ.GET('SERR')
                .GET_STRING || '</td></tr>';
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
                 '"><td class="' || STH_CLASS ||
                 '"><h2>Параметры формирования</h2></td></tr><tr><td style="padding-top:10px;padding-bottom:10px">' ||
                 SPRMS || '</td></tr></table>';
      end if;
      --пристыкуем параметры к общему HTMLю
      SHTML := SHTML || SPRMS;
      --вернем сформированное
      STEXT := '<html><style>td{padding:3px}</style><body>' || SHTML ||
               '</body></html>';
    else
      STEXT := null;
    end if;
  exception
    when others then
      SSUBJ := null;
      STEXT := null;
  end;

  --проверка прав доступа пользователя на раздел/действия в разделе (0 - прав нет, 1 - права есть)
  function UTL_CHECK_PRIVS
  (
    SUSER    varchar2 --пользователь
   ,SUNIT    varchar2 --код раздела
   ,SACTION  varchar2 := null --код действия (для выборки - null, для остальных - системные коды действий)
   ,NCOMPANY number := null --рег. номер организации
   ,NVERSION number := null --рег. номер версии
   ,NJURPERS number := null --рег. номер юридического лица
   ,NCRN     number := null --рег. номер каталога
  ) return number is
    NRES number(17) := 0; --результат проверки
  begin
    --если это не действие на выборку данных, а действие над данными
    if (SACTION is not null)
    then
      begin
        select null
          into NRES
          from (select null
                  from V_USERPRIV2FUNC T
                 where T.SUNITCODE = UTL_CHECK_PRIVS.SUNIT
                   and T.SAUTHID = SUSER
                   and T.SFUNCCODE = UTL_CHECK_PRIVS.SACTION
                   and T.NACCESS = 1
                   and ((UTL_CHECK_PRIVS.NCRN is null) or
                       ((UTL_CHECK_PRIVS.NCRN is not null) and
                       ((T.NCATALOG = UTL_CHECK_PRIVS.NCRN) or
                       (T.NHIERARCHY = UTL_CHECK_PRIVS.NCRN))))
                   and ((UTL_CHECK_PRIVS.NCOMPANY is null) or
                       ((UTL_CHECK_PRIVS.NCOMPANY is not null) and
                       (T.NCOMPANY = UTL_CHECK_PRIVS.NCOMPANY)))
                   and ((UTL_CHECK_PRIVS.NJURPERS is null) or
                       ((UTL_CHECK_PRIVS.NJURPERS is not null) and
                       (T.NJUR_PERS = UTL_CHECK_PRIVS.NJURPERS)))
                union
                select null
                  from V_ROLEPRIV2FUNC R
                 where R.SUNITCODE = UTL_CHECK_PRIVS.SUNIT
                   and R.NROLEID in (select RL.ROLEID
                                       from USERROLES RL
                                      where RL.AUTHID = SUSER)
                   and R.SFUNCCODE = UTL_CHECK_PRIVS.SACTION
                   and R.NACCESS = 1
                   and ((UTL_CHECK_PRIVS.NCRN is null) or
                       ((UTL_CHECK_PRIVS.NCRN is not null) and
                       ((R.NCATALOG = UTL_CHECK_PRIVS.NCRN) or
                       (R.NHIERARCHY = UTL_CHECK_PRIVS.NCRN))))
                   and ((UTL_CHECK_PRIVS.NCOMPANY is null) or
                       ((UTL_CHECK_PRIVS.NCOMPANY is not null) and
                       (R.NCOMPANY = UTL_CHECK_PRIVS.NCOMPANY)))
                   and ((UTL_CHECK_PRIVS.NJURPERS is null) or
                       ((UTL_CHECK_PRIVS.NJURPERS is not null) and
                       (R.NJUR_PERS = UTL_CHECK_PRIVS.NJURPERS))))
         where ROWNUM <= 1;
        return NHAVE_PRIVS;
      exception
        --не нашли - прав доступа нет
        when NO_DATA_FOUND then
          return NHAVE_NO_PRIVS;
      end;
    else
      begin
        select null
          into NRES
          from USERPRIV UP
         where UP.UNITCODE = UTL_CHECK_PRIVS.SUNIT
           and ((UTL_CHECK_PRIVS.NCRN is null) or
               ((UTL_CHECK_PRIVS.NCRN is not null) and
               ((UP.CATALOG = UTL_CHECK_PRIVS.NCRN) or
               (UP.HIERARCHY = UTL_CHECK_PRIVS.NCRN))))
           and ((UTL_CHECK_PRIVS.NCOMPANY is null) or
               ((UTL_CHECK_PRIVS.NCOMPANY is not null) and
               (UP.COMPANY = UTL_CHECK_PRIVS.NCOMPANY)))
           and ((UTL_CHECK_PRIVS.NVERSION is null) or
               ((UTL_CHECK_PRIVS.NVERSION is not null) and
               (UP.VERSION = UTL_CHECK_PRIVS.NVERSION)))
           and ((UTL_CHECK_PRIVS.NJURPERS is null) or
               ((UTL_CHECK_PRIVS.NJURPERS is not null) and
               (UP.JUR_PERS = UTL_CHECK_PRIVS.NJURPERS)))
           and ((UP.AUTHID = SUSER) or
               (UP.ROLEID in (select UR.ROLEID
                                 from USERROLES UR
                                where UR.AUTHID = SUSER)))
           and ROWNUM <= 1;
        --права доступа есть
        return NHAVE_PRIVS;
      exception
        --не нашли - прав доступа нет
        when NO_DATA_FOUND then
          return NHAVE_NO_PRIVS;
      end;
    end if;
    --прав доступа нет
    return NHAVE_NO_PRIVS;
  exception
    when others then
      return NHAVE_NO_PRIVS;
  end;

  --проверка наличия роли у пользователя (0 - роль не назначена пользователю, 1 - назначена)
  function UTL_CHECK_USER_ROLE
  (
    SUSER  varchar2 --пользователь
   ,SROLE  varchar2 --роль (или список ролей с разделителем)
   ,SDELIM varchar2 := SLIST_DELIM --разделитель списков
  ) return number is
  begin
    --убедимся, что у пользователя есть нужная системная роль
    for C in (select UR.RN
                from USERROLES UR
                    ,ROLES     R
               where UR.ROLEID = R.RN
                 and UR.AUTHID = SUSER
                 and (exists (select 1
                                from (select REGEXP_SUBSTR(T.STR
                                                          ,'[^' || SDELIM || ']+'
                                                          ,1
                                                          ,level) MBR
                                        from (select NVL(replace(replace(LTRIM(RTRIM(SROLE
                                                                                    ,SDELIM)
                                                                              ,SDELIM)
                                                                        ,'*'
                                                                        ,'%')
                                                                ,'?'
                                                                ,'_')
                                                        ,'%') STR
                                                from DUAL) T
                                      connect by INSTR(T.STR
                                                      ,SDELIM
                                                      ,1
                                                      ,level - 1) > 0) LST
                               where R.ROLENAME like LST.MBR)))
    loop
      --роль назначена
      return NHAVE_ROLE;
    end loop;
    --роль не назначена
    return NHAVE_NO_ROLE;
  exception
    when others then
      return NHAVE_NO_ROLE;
  end;

  --проверкая - является ли пользователь администратором (0 - не администратор, 1 - администратор)
  function UTL_CHECK_IS_ADMIN
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
  ) return number is
    SADMIN_ROLE CONSTLST.STRVALUE%type; --роль администратора
  begin
    --считаем роль администратора
    SADMIN_ROLE := UTL_GET_CONST_VAL_STR(NCOMPANY => NCOMPANY
                                        ,SCONST   => SADMIN_ROLE_CONST_NAME);
    --проверим наличие роли у пользователя
    if (SADMIN_ROLE is not null)
    then
      if (UTL_CHECK_USER_ROLE(SUSER => SUSER
                             ,SROLE => SADMIN_ROLE) = NHAVE_ROLE)
      then
        return NIS_ADMIN;
      else
        return NIS_NOT_ADMIN;
      end if;
    else
      return NIS_NOT_ADMIN;
    end if;
  exception
    when others then
      return NIS_NOT_ADMIN;
  end;

  --форомирование запроса к данным раздела на основании его настроек в КОРе
  function UTL_BUILD_CONSTR_QUERY
  (
    NCOMPANY          number --рег. номер организации
   ,NUNIT             number --рег. номер раздела системы
   ,NSHOW_MENTHOD     number --рег. номер метода вызова раздела
   ,NSHOW_MENTHOD_PRM number --рег. номер параметра метода вызова раздела
   ,NEXCLUDE_SEARCH   number --не добавлять условия поиска в запрос (0 - добавлять, 1 - не добавлять)
  ) return varchar2 is
    UNT          UNITLIST%rowtype; --запись раздела
    MPRM         UNITPARAMS%rowtype; --запись параметра метода вызова
    SALIAS       char(1) := 'T'; --псевдоним представления в запросе
    SSQL         varchar2(4000); --собранный запрос
    SVIEW        DMSCLVIEWS.VIEW_NAME%type; --наименование представления раздела
    NVIEW        DMSCLVIEWS.RN%type; --рег. номер представления раздела
    SPK_ATR      DMSCLATTRS.COLUMN_NAME%type; --наименование атрибута представления раздела для первичного ключа
    SCODE_ATR    DMSCLATTRS.COLUMN_NAME%type; --наименование атрибута представления раздела для мнемокода записи
    SDESC_ATR    varchar2(4000); --наименование атрибута раздела для описания записи
    SVAL_ATR     DMSCLATTRS.COLUMN_NAME%type; --наименование атрибута представления раздела для значения записи
    SDIV_ATR     DMSCLATTRS.COLUMN_NAME%type; --наименование атрибута представления для деления по организациям
    SDIV_ATR_VAL varchar2(4000); --значение атрибута деления
    NVERSION     VERSIONS.RN%type; --рег. номер версии раздела
  begin
    --считаем запись раздела системы
    begin
      select U.*
        into UNT
        from UNITLIST U
       where U.RN = NUNIT;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    --считаем запись параметра метода вызова
    begin
      select P.*
        into MPRM
        from UNITPARAMS P
       where P.RN = NSHOW_MENTHOD_PRM;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    --проверим, что в параметре метода вызова есть ссылка на атрибут класса - если нет, то дальше можно не строить
    if (MPRM.ATTRIBUTE is null)
    then
      return null;
    end if;
    --считаем представление для переданного метода вызова - сначала корневое из метода вызова
    begin
      select EXTRACTVALUE(XMLTYPE(T.SETTINGS)
                         ,'/ShowMethod/Group/DataSource/@ViewName')
        into SVIEW
        from UNIT_SHOWMETHODS T
       where T.RN = NSHOW_MENTHOD
         and T.SETTINGS is not null;
    exception
      when others then
        SVIEW := null;
    end;
    --если нет в методе вызова - пробуем из списка представлений
    if (SVIEW is null)
    then
      begin
        select T.VIEW_NAME
          into SVIEW
          from DMSCLVIEWS T
         where T.PRN = NUNIT
           and T.ACCESSIBILITY = 1
           and T.CUSTOM_QUERY = 0;
      exception
        when NO_DATA_FOUND then
          SVIEW := null;
        when TOO_MANY_ROWS then
          SVIEW := null;
      end;
    end if;
    --если представление так и не нашли - дальше не работаем
    if (SVIEW is null)
    then
      return null;
    else
      --если представление нашли - считаем его рег. номер
      begin
        select T.RN
          into NVIEW
          from DMSCLVIEWS T
         where T.PRN = NUNIT
           and T.VIEW_NAME = SVIEW;
      exception
        when others then
          return null;
      end;
    end if;
    --найдем атрибут представления для первичного ключа раздела
    begin
      SPK_ATR := F_DMSCLASSES_KEY_FIELD(SUNITCODE  => UNT.UNITCODE
                                       ,SVIEW_NAME => SVIEW);
      SPK_ATR := SALIAS || '.' || SPK_ATR;
    exception
      when others then
        return null;
    end;
    --найдем атрибут для мнемокода записи
    if (CONF_GET_PRM_STR_BASE(SUNIT   => 'DMSClasses'
                             ,NUNITRN => NUNIT
                             ,SPRM    => SCONF_CLASS_CODE) is not null)
    then
      begin
        select VA.COLUMN_NAME
          into SCODE_ATR
          from DMSCLVIEWSATTRS VA
              ,DMSCLATTRS      UA
         where VA.PRN = NVIEW
           and VA.ATTR = UA.RN
           and UA.COLUMN_NAME =
               CONF_GET_PRM_STR_BASE(SUNIT   => 'DMSClasses'
                                    ,NUNITRN => NUNIT
                                    ,SPRM    => SCONF_CLASS_CODE);
        SCODE_ATR := SALIAS || '.' || SCODE_ATR;
      exception
        when others then
          SCODE_ATR := null;
      end;
    else
      begin
        select VA.COLUMN_NAME
          into SCODE_ATR
          from DMSCLVIEWSATTRS VA
         where VA.PRN = NVIEW
           and VA.ATTR = MPRM.ATTRIBUTE;
        SCODE_ATR := SALIAS || '.' || SCODE_ATR;
      exception
        when others then
          SCODE_ATR := null;
      end;
    end if;
    --если не нашли атрибут для мнемокода записи, то выходим
    if (SCODE_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для описания записи
    if (CONF_GET_PRM_STR_BASE(SUNIT   => 'DMSClasses'
                             ,NUNITRN => NUNIT
                             ,SPRM    => SCONF_CLASS_DESC) is not null)
    then
      begin
        select VA.COLUMN_NAME
          into SDESC_ATR
          from DMSCLVIEWSATTRS VA
              ,DMSCLATTRS      UA
         where VA.PRN = NVIEW
           and VA.ATTR = UA.RN
           and UA.COLUMN_NAME =
               CONF_GET_PRM_STR_BASE(SUNIT   => 'DMSClasses'
                                    ,NUNITRN => NUNIT
                                    ,SPRM    => SCONF_CLASS_DESC);
        SDESC_ATR := SALIAS || '.' || SDESC_ATR;
      exception
        when others then
          SDESC_ATR := 'null';
      end;
    else
      --если есть описатель - то он будет задействован
      begin
        select 'F_DOCDESCRS_GET_DESCRIPTION(''' || UNT.UNITCODE || ''', ' ||
               SPK_ATR || ')'
          into SDESC_ATR
          from DOCDESCRS D
         where D.UNITCODE = UNT.UNITCODE
           and D.USERPROC is not null;
      exception
        when others then
          SDESC_ATR := 'null';
      end;
    end if;
    --если не нашли атрибут для описания записи, то выходим
    if (SDESC_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для значения записи
    begin
      select VA.COLUMN_NAME
        into SVAL_ATR
        from DMSCLVIEWSATTRS VA
       where VA.PRN = NVIEW
         and VA.ATTR = MPRM.ATTRIBUTE;
      SVAL_ATR := SALIAS || '.' || SVAL_ATR;
    exception
      when others then
        SVAL_ATR := null;
    end;
    --если не нашли атрибут для значения записи, то выходим
    if (SVAL_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для деления
    if (UNT.SIGN_SHARE = 1)
    then
      begin
        --деление по организациям
        if (UNT.SIGN_ACCREG = 1)
        then
          P_DMSCLVIEWS_GET_LINKS_KIND(SVIEW_NAME => SVIEW
                                     ,NKIND      => 2
                                     ,SATTR_NAME => SDIV_ATR);
          SDIV_ATR     := SALIAS || '.' || SDIV_ATR;
          SDIV_ATR_VAL := TO_CHAR(NCOMPANY);
        else
          --деление по версиям
          P_DMSCLVIEWS_GET_LINKS_KIND(SVIEW_NAME => SVIEW
                                     ,NKIND      => 3
                                     ,SATTR_NAME => SDIV_ATR);
          FIND_VERSION_BY_COMPANY(NCOMPANY  => NCOMPANY
                                 ,SUNITCODE => UNT.UNITCODE
                                 ,NVERSION  => NVERSION);
          SDIV_ATR     := SALIAS || '.' || SDIV_ATR;
          SDIV_ATR_VAL := TO_CHAR(NVERSION);
        end if;
      exception
        when others then
          SDIV_ATR := null;
      end;
    else
      --деления нет
      SDIV_ATR := null;
    end if;
    --дополним представление псевдонимом
    SVIEW := SVIEW || ' ' || SALIAS;
    --соберем запрос - основная значимая часть
    SSQL := 'SELECT ' || SPK_ATR || ' NRN, ' || SCODE_ATR || ' SCODE, ' ||
            SDESC_ATR || ' SDESC, ' || SVAL_ATR || ' SVAL FROM ' || SVIEW;
    --соберем запрос - добавим в запрос отбор по верхней границе
    SSQL := SSQL || ', (SELECT ' || SPK_ATR ||
            ' NRN, ROW_NUMBER() OVER(ORDER BY ROWNUM) NROW FROM ' || SVIEW ||
            ' WHERE ROWNUM <= :NROW_TO';
    --соберем запрос - если просили включить поиск, добавим и его
    if (NEXCLUDE_SEARCH = 0)
    then
      --соберем запрос - условия поиска
      SSQL := SSQL || ' AND (STRINLIKE(UPPER(' || SCODE_ATR ||
              IIF_STR(SVALUE1    => TO_CHAR(NVL(CONF_GET_PRM_NUM_BASE(SUNIT   => 'DMSClasses'
                                                                     ,NUNITRN => NUNIT
                                                                     ,SPRM    => SCONF_CLASS_NO_DESC_SEARCH)
                                               ,NNO_DESC_SEARCH_NO))
                     ,SCONDITION => '='
                     ,SVALUE2    => TO_CHAR(NNO_DESC_SEARCH_YES)
                     ,STRUE      => ''
                     ,SFALSE     => '||'' ''|| ' || SDESC_ATR) ||
              '), UPPER(:SSEARCH)) <> 0)';
    end if;
    SSQL := SSQL || ') UPLIM';
    --соберем запрос - добавим в запрос отбор по нижней границе
    SSQL := SSQL || ' WHERE UPLIM.NRN = ' || SPK_ATR ||
            ' AND UPLIM.NROW >= :NROW_FROM';
    --соберем запрос - добавим отбор по признаку деления
    if ((SDIV_ATR is not null) and (SDIV_ATR_VAL is not null))
    then
      SSQL := SSQL || ' AND ' || SDIV_ATR || ' = ' || SDIV_ATR_VAL;
    end if;
    --если словарь с ортировкой
    if (BORDERED_DICTS)
    then
      --соберем запрос - сортировка
      SSQL := SSQL || ' ORDER BY ' || SCODE_ATR;
    end if;
    --вернем результат
    return SSQL;
  end;

  --форомирование запроса к данным раздела на основании его настроек в системе по-умолчанию
  function UTL_BUILD_SYSDEF_QUERY
  (
    NCOMPANY          number --рег. номер организации
   ,NUNIT             number --рег. номер раздела системы
   ,NSHOW_MENTHOD_PRM number --рег. номер параметра метода вызова раздела
   ,SSHEMA            varchar2 := SSHEMA_DEFAULT --схема данных Oracle для анализа
   ,NEXCLUDE_SEARCH   number --не добавлять условия поиска в запрос (0 - добавлять, 1 - не добавлять)
  ) return varchar2 is
    UNT          UNITLIST%rowtype; --запись раздела
    MPRM         UNITPARAMS%rowtype; --запись параметра метода вызова
    SALIAS       char(1) := 'T'; --псевдоним представления в запросе
    SSQL         varchar2(4000); --собранный запрос
    STABLE       DMSCLVIEWS.VIEW_NAME%type; --наименование представления раздела
    SPK_ATR      DMSCLATTRS.COLUMN_NAME%type; --наименование атрибута представления раздела для первичного ключа
    SCODE_ATR    varchar2(4000); --наименование атрибута представления раздела для мнемокода записи
    SDESC_ATR    varchar2(4000); --наименование атрибута раздела для описания записи
    SVAL_ATR     varchar2(4000); --наименование атрибута представления раздела для значения записи
    SDIV_ATR     DMSCLATTRS.COLUMN_NAME%type; --наименование атрибута представления для деления по организациям
    SDIV_ATR_VAL varchar2(200); --значение атрибута деления
    NVERSION     VERSIONS.RN%type; --рег. номер версии раздела
    --поиск атрибута первичного ключа
    function FIND_PK_ATR
    (
      SSHEMA varchar2 --схема данных Oracle для анализа
     ,STABLE varchar2 --таблица раздела
    ) return varchar2 is
      SRES varchar2(4000); --результат работы
    begin
      select CC.COLUMN_NAME
        into SRES
        from ALL_CONSTRAINTS  C
            ,ALL_CONS_COLUMNS CC
       where C.TABLE_NAME = STABLE
         and C.OWNER = SSHEMA
         and C.CONSTRAINT_TYPE = 'P'
         and CC.OWNER = C.OWNER
         and CC.CONSTRAINT_NAME = C.CONSTRAINT_NAME
         and CC.TABLE_NAME = C.TABLE_NAME;
      return SRES;
    exception
      when others then
        return null;
    end;

    --поиск атрибута деления
    function FIND_DIV_ATR
    (
      SSHEMA varchar2 --схема данных Oracle для анализа
     ,STABLE varchar2 --таблица раздела
     ,NDIV   number --признака деления (1 - организации, 2 - версии)
    ) return varchar2 is
      SRES varchar2(4000); --результат работы
    begin
      select CC.COLUMN_NAME
        into SRES
        from ALL_CONSTRAINTS  C
            ,ALL_CONS_COLUMNS CC
            ,ALL_CONSTRAINTS  CR
       where C.TABLE_NAME = STABLE
         and C.OWNER = SSHEMA
         and C.CONSTRAINT_TYPE = 'R'
         and CC.OWNER = C.OWNER
         and CC.CONSTRAINT_NAME = C.CONSTRAINT_NAME
         and CC.TABLE_NAME = C.TABLE_NAME
         and C.R_OWNER = CR.OWNER
         and C.R_CONSTRAINT_NAME = CR.CONSTRAINT_NAME
         and CR.TABLE_NAME = DECODE(NDIV
                                   ,1
                                   ,STABLE_COMPANIES
                                   ,2
                                   ,STABLE_VERSIONS
                                   ,null);
      return SRES;
    exception
      when others then
        return null;
    end;

  begin
    --считаем запись раздела системы
    begin
      select U.*
        into UNT
        from UNITLIST U
       where U.RN = NUNIT;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    --считаем запись параметра метода вызова
    begin
      select P.*
        into MPRM
        from UNITPARAMS P
       where P.RN = NSHOW_MENTHOD_PRM;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    --проверим, что в параметре метода вызова есть прямой запрос - если нет, то дальше можно не строить
    if (MPRM.DIRECT_SQL is null)
    then
      return null;
    end if;
    --считаем основную таблицу раздела
    STABLE := UNT.TABLE_NAME;
    --если таблицу так и не нашли - дальше не работаем
    if (STABLE is null)
    then
      return null;
    end if;
    --найдем атрибут таблицы для первичного ключа раздела
    SPK_ATR := FIND_PK_ATR(SSHEMA => SSHEMA
                          ,STABLE => STABLE);
    --если атрибут таблицы для первичного ключа так и не нашли - дальше не работаем
    if (SPK_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для мнемокода записи
    begin
      /*PKG_UNITPARAMS.BUILD_DIRECT(NPARAMETER => MPRM.RN
                                 ,NCOMPANY   => NCOMPANY
                                 ,NVERSION   => null
                                 ,NM_RN      => null
                                 ,SQUERY     => SCODE_ATR
                                 ,BBIND_VAR  => true);*/
      -- релиз 20/06/2018 Бухвин
      SCODE_ATR:=PKG_UNITPARAMS.BUILD_DIRECT(NPARAMETER => MPRM.RN
                                 ,NCOMPANY   => NCOMPANY
                                 ,NVERSION   => null
                                 ,NM_RN      => null
                                 ,BBIND_VAR  => true);
      SCODE_ATR := '(' || SCODE_ATR || ' and (' || SPK_ATR || ' = ' || SALIAS || '.' ||
                   SPK_ATR || '))';
    exception
      when others then
        SCODE_ATR := null;
    end;
    --если не нашли атрибут для мнемокода записи, то выходим
    if (SCODE_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для описания записи (вызов описателя документа или пустое значение)
    begin
      select 'F_DOCDESCRS_GET_DESCRIPTION(''' || UNT.UNITCODE || ''', ' ||
             SPK_ATR || ')'
        into SDESC_ATR
        from DOCDESCRS D
       where D.UNITCODE = UNT.UNITCODE
         and D.USERPROC is not null;
    exception
      when others then
        SDESC_ATR := 'null';
    end;
    --если не нашли атрибут для описания записи, то выходим
    if (SDESC_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для значения записи
    SVAL_ATR := SCODE_ATR;
    --если не нашли атрибут для значения записи, то выходим
    if (SVAL_ATR is null)
    then
      return null;
    end if;
    --найдем атрибут для деления
    if (UNT.SIGN_SHARE = 1)
    then
      begin
        --деление по организациям
        if (UNT.SIGN_ACCREG = 1)
        then
          SDIV_ATR     := FIND_DIV_ATR(SSHEMA => SSHEMA
                                      ,STABLE => STABLE
                                      ,NDIV   => 1);
          SDIV_ATR_VAL := TO_CHAR(NCOMPANY);
        else
          --деление по версиям
          SDIV_ATR := FIND_DIV_ATR(SSHEMA => SSHEMA
                                  ,STABLE => STABLE
                                  ,NDIV   => 2);
          FIND_VERSION_BY_COMPANY(NCOMPANY  => NCOMPANY
                                 ,SUNITCODE => UNT.UNITCODE
                                 ,NVERSION  => NVERSION);
          SDIV_ATR_VAL := TO_CHAR(NVERSION);
        end if;
      exception
        when others then
          SDIV_ATR := null;
      end;
    else
      --деления нет
      SDIV_ATR := null;
    end if;
    --дополним таблицу псевдонимом
    STABLE := STABLE || ' ' || SALIAS;
    --дополним колонки псевдонимами
    SDIV_ATR := SALIAS || '.' || SDIV_ATR;
    SPK_ATR  := SALIAS || '.' || SPK_ATR;
    --соберем запрос - основная значимая часть
    SSQL := 'SELECT ' || SPK_ATR || ' NRN, ' || SCODE_ATR || ' SCODE, ' ||
            SDESC_ATR || ' SDESC, ' || SVAL_ATR || ' SVAL FROM ' || STABLE;
    --соберем запрос - добавим в запрос отбор по верхней границе
    SSQL := SSQL || ', (SELECT ' || SPK_ATR ||
            ' NRN, ROW_NUMBER() OVER(ORDER BY ROWNUM) NROW FROM ' || STABLE ||
            ' WHERE ROWNUM <= :NROW_TO';
    --соберем запрос - если просили включить поиск, добавим и его
    if (NEXCLUDE_SEARCH = 0)
    then
      --соберем запрос - условия поиска
      SSQL := SSQL || ' AND (STRINLIKE(UPPER(' || SCODE_ATR ||
              IIF_STR(SVALUE1    => TO_CHAR(NVL(CONF_GET_PRM_NUM_BASE(SUNIT   => 'DMSClasses'
                                                                     ,NUNITRN => NUNIT
                                                                     ,SPRM    => SCONF_CLASS_NO_DESC_SEARCH)
                                               ,NNO_DESC_SEARCH_NO))
                     ,SCONDITION => '='
                     ,SVALUE2    => TO_CHAR(NNO_DESC_SEARCH_YES)
                     ,STRUE      => ''
                     ,SFALSE     => '||'' ''|| ' || SDESC_ATR) ||
              '), UPPER(:SSEARCH)) <> 0)';
    end if;
    SSQL := SSQL || ') UPLIM';
    --соберем запрос - добавим в запрос отбор по нижней границе
    SSQL := SSQL || ' WHERE UPLIM.NRN = ' || SPK_ATR ||
            ' AND UPLIM.NROW >= :NROW_FROM';
    --соберем запрос - добавим отбор по признаку деления
    if ((SDIV_ATR is not null) and (SDIV_ATR_VAL is not null))
    then
      SSQL := SSQL || ' AND ' || SDIV_ATR || ' = ' || SDIV_ATR_VAL;
    end if;
    --если словарь с ортировкой
    if (BORDERED_DICTS)
    then
      --соберем запрос - сортировка
      SSQL := SSQL || ' ORDER BY 2';
    end if;
    --вернем результат
    return SSQL;
  end;

  --получение наименования раздела по его рег. номеру
  function UTL_UNIT_NAME(NUNIT number --рег. номер раздела
                         ) return varchar2 deterministic is
    SRES V_RESOURCES_LOCAL.TEXT%type; --результат работы
  begin
    --считаем наименование раздела
    select NVL(UL_NM.TEXT
              ,UL.UNITCODE)
      into SRES
      from UNITLIST UL
          ,(select RN
                  ,TEXT
              from V_RESOURCES_LOCAL
             where TABLE_NAME = 'UNITLIST'
               and COLUMN_NAME = 'UNITNAME') UL_NM
     where UL.RN = NUNIT
       and UL.RN = UL_NM.RN(+);
    --вернем результат
    return SRES;
  exception
    when others then
      return null;
  end;

  --подсчет количества привязанных к разделу отчетов, подлежащих публикации
  function UTL_UNIT_CNT_PUBREPORTS
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SSEARCH  varchar2 --строка поиска (null - не искать)
   ,NUNIT    number --рег. номер раздела (0 - для спец. раздела "Без привязки к разделу")
  ) return number is
    NRES     number(17); --результат работы
    SSEARCH_ varchar2(4000); --строка поиска подготовленная для добавления в запрос
  begin
    --подготовим строку поиска для использования в запросах
    UTL_PREPARE_SEARCH(SSEARCH          => SSEARCH
                      ,SSEARCH_PREPARED => SSEARCH_);
    --считаем в зависимости от типа раздела
    if (NUNIT = NNOUNIT_RN)
    then
      select count(UR.RN)
        into NRES
        from USERREPORTS UR
       where not exists (select URL.RN
                from USERREPORTSLINKS URL
               where URL.PRN = UR.RN)
         and UDO_PKG_URPT_SRV.UTL_REPORT_CAN_PUBLISH_USER(NCOMPANY => NCOMPANY
                                                         ,SUSER    => SUSER
                                                         ,NREPORT  => UR.RN
                                                         ,NUNIT    => null
                                                         ,NFAVOR   => null) =
             NCAN_PUBLISH_USER_YES
         and ((STRINLIKE(UPPER(UR.CODE)
                        ,UPPER(SSEARCH_)) <> 0) or
             (STRINLIKE(UPPER(UR.NAME)
                        ,UPPER(SSEARCH_)) <> 0) or
             (STRINLIKE(UPPER(CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                                    ,NUNITRN => UR.RN
                                                    ,SPRM    => SCONF_USR_REPORT_DESC))
                        ,UPPER(SSEARCH_)) <> 0));
    else
      select count(URL.RN)
        into NRES
        from USERREPORTSLINKS URL
            ,UNITLIST         UL
            ,USERREPORTS      UR
       where UL.RN = NUNIT
         and URL.UNITCODE = UL.UNITCODE
         and UR.RN = URL.PRN
         and UDO_PKG_URPT_SRV.UTL_REPORT_CAN_PUBLISH_USER(NCOMPANY => NCOMPANY
                                                         ,SUSER    => SUSER
                                                         ,NREPORT  => URL.PRN
                                                         ,NUNIT    => null
                                                         ,NFAVOR   => null) =
             NCAN_PUBLISH_USER_YES
         and ((STRINLIKE(UPPER(UR.CODE)
                        ,UPPER(SSEARCH_)) <> 0) or
             (STRINLIKE(UPPER(UR.NAME)
                        ,UPPER(SSEARCH_)) <> 0) or
             (STRINLIKE(UPPER(CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                                    ,NUNITRN => UR.RN
                                                    ,SPRM    => SCONF_USR_REPORT_DESC))
                        ,UPPER(SSEARCH_)) <> 0));
    end if;
    --вернем результат
    return NRES;
  exception
    when others then
      return 0;
  end;

  --считывание адреса E-mail по пользоателю
  function UTL_GET_USER_MAIL
  (
    NCOMPANY  number --рег. номер организации
   ,SUSER     varchar2 --пользователь
   ,NGET_MODE number := 3 --режим определения почты (1 - через д/с раздела "Контрагенты", 2 - через аутентификацию сотрудников, 3 - попробовать оба способа)
  ) return varchar2 is
  begin
    --вернем результат
    return UDO_PKG_SYS0015_MAIL.GET_MAIL_BY_AUTHID(NCOMPANY  => NCOMPANY
                                                  ,SAUTHID   => SUSER
                                                  ,NGET_MODE => NGET_MODE);
  exception
    when others then
      return null;
  end;

  --скачивание файла
  procedure UTL_DOWNLOAD
  (
    NFILE in number --рег. номер готового файла отчета для позиции очереди печати
   ,NTYPE in number --тип файла (1 - готовый отчет, 2 - картинка предпросмотра отчета)
  ) is
  begin
    UDO_PKG_SYSW0003_PUBL_UTILS.DOWNLOAD_FILE(NFILE => NFILE
                                             ,SUSER => null
                                             ,NSRC  => NTYPE);
  end;

  --проверка активности сервиса
  function UTL_SERVICE_IS_ACTIVE return boolean is
  begin
    --проверим наличие активного сервиса в сессиях
    for C in (select S.SID
                from V$SESSION S
               where S.MODULE = SMODULE_NAME
                 and S.STATUS = 'ACTIVE'
                 and S.PROGRAM = SPROGRAMM_NAME)
    loop
      return true;
    end loop;
    --нет активного сервиса
    return false;
  exception
    when others then
      return false;
  end;

  --конфигурация сервиса - инициализация параметров
  procedure CONF_INIT is
  begin
    CPS := CONF_PRMS();
    --пользовательские отчеты - признак публикации
    CPS.EXTEND;
    CPS(CPS.LAST).SCODE := SCONF_USR_REPORT_PUBL;
    CPS(CPS.LAST).SDESC := 'Публиковать отчет';
    CPS(CPS.LAST).NTYPE := NVAL_TYPE_BOOL;
    --пользовательские отчеты - описание отчета для публикации
    CPS.EXTEND;
    CPS(CPS.LAST).SCODE := SCONF_USR_REPORT_DESC;
    CPS(CPS.LAST).SDESC := 'Публикуемое описание отчета';
    CPS(CPS.LAST).NTYPE := NVAL_TYPE_STR;
    --классы - атрибут для мнемокода записи
    CPS.EXTEND;
    CPS(CPS.LAST).SCODE := SCONF_CLASS_CODE;
    CPS(CPS.LAST).SDESC := 'Атрибут для мнемокода записи';
    CPS(CPS.LAST).NTYPE := NVAL_TYPE_STR;
    --классы - атрибут для описания записи
    CPS.EXTEND;
    CPS(CPS.LAST).SCODE := SCONF_CLASS_DESC;
    CPS(CPS.LAST).SDESC := 'Атрибут для описания записи';
    CPS(CPS.LAST).NTYPE := NVAL_TYPE_STR;
    --классы - признак исключения описания из поиска
    CPS.EXTEND;
    CPS(CPS.LAST).SCODE := SCONF_CLASS_NO_DESC_SEARCH;
    CPS(CPS.LAST).SDESC := 'Не искать по описанию';
    CPS(CPS.LAST).NTYPE := NVAL_TYPE_BOOL;
  end;

  --конфигурация сервиса - поиск наименования параметра по его коду
  function CONF_FIND_PRM_DESC(SCODE varchar2 --код параметра
                              ) return varchar2 is
    SRES varchar2(240);
  begin
    --если коллекция инициализирована
    if (CPS is not null) and (CPS.COUNT > 0)
    then
      --идем по ней
      for I in CPS.FIRST .. CPS.LAST
      loop
        if (CPS(I).SCODE = SCODE)
        then
          SRES := CPS(I).SDESC;
        end if;
      end loop;
    end if;
    --вернем результат
    return SRES;
  exception
    when others then
      return null;
  end;

  --конфигурация сервиса - поиск рег. номера параметра по его характеристикам
  function CONF_FIND_PRM
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
   ,NSMART  number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return number is
    NRES UDO_T_URPT_SRV_CONF.RN%type; --результат
  begin
    --найдем параметр
    select T.RN
      into NRES
      from UDO_T_URPT_SRV_CONF T
          ,UNITLIST            UL
     where T.UNIT = UL.RN
       and UL.UNITCODE = SUNIT
       and T.UNITRN = NUNITRN
       and T.PRM = SPRM;
    --вернем результат
    return NRES;
  exception
    when others then
      P_EXCEPTION(NSMART
                 ,'Параметр "' || SPRM ||
                  '" WEB-сервиса обслуживания очереди отложенной печати пользовательских отчетов, для документа "' ||
                  NUNITRN || '" раздела "' || SUNIT || '" не найден!');
      return null;
  end;

  --конфигурация сервиса - поиск записи  параметра по его характеристикам
  function CONF_FIND_PRM_REC
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
   ,NSMART  number := 0 --признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return UDO_T_URPT_SRV_CONF%rowtype is
    NRN UDO_T_URPT_SRV_CONF.RN%type; --рег. номер параметра
    RES UDO_T_URPT_SRV_CONF%rowtype; --результат
  begin
    --найдем рег. номер параметра
    NRN := CONF_FIND_PRM(SUNIT   => SUNIT
                        ,NUNITRN => NUNITRN
                        ,SPRM    => SPRM
                        ,NSMART  => NSMART);
    --если нашли
    if (NRN is not null)
    then
      --считаем запись
      select T.*
        into RES
        from UDO_T_URPT_SRV_CONF T
       where T.RN = NRN;
      --вернем её
      return RES;
    else
      --если не нашли
      P_EXCEPTION(NSMART
                 ,'Запись параметра "' || SPRM ||
                  '" WEB-сервиса обслуживания очереди отложенной печати пользовательских отчетов, для документа "' ||
                  NUNITRN || '" раздела "' || SUNIT || '" не найден!');
      return null;
    end if;
  exception
    when others then
      P_EXCEPTION(NSMART
                 ,'Запись параметра "' || SPRM ||
                  '" WEB-сервиса обслуживания очереди отложенной печати пользовательских отчетов, для документа "' ||
                  NUNITRN || '" раздела "' || SUNIT || '" не найден!');
      return null;
  end;

  --разрешение ссылок параметра
  procedure CONF_JOINS
  (
    SUNIT varchar2 --код родительского раздела параметра
   ,NUNIT out number --рег. номер родительского раздела параметра
  ) is
  begin
    --разыменуем код раздела
    FIND_UNITLIST_CODE(NFLAG_SMART  => 0
                      ,NFLAG_OPTION => 0
                      ,SCODE        => SUNIT
                      ,NRN          => NUNIT);
  end;

  --конфигурация сервиса - базовая установка значения параметра типа "Строка"
  procedure CONF_SET_PRM_BASE
  (
    SUNIT    varchar2 --код родительского раздела параметра
   ,NUNITRN  number --рег. номер документа в разделе
   ,SPRM     varchar2 --код параметра
   ,SSTR_VAL varchar2 --значение типа "Строка"
  ) is
    NRN   UDO_T_URPT_SRV_CONF.RN%type; --рег. номер параметра
    NUNIT UNITLIST.RN%type; --рег. номер родительского раздела параметра
  begin
    --разыменуем ссылки
    CONF_JOINS(SUNIT => SUNIT
              ,NUNIT => NUNIT);
    --найдем рег. номер параметра
    NRN := CONF_FIND_PRM(SUNIT   => SUNIT
                        ,NUNITRN => NUNITRN
                        ,SPRM    => SPRM
                        ,NSMART  => 1);
    --если нашли
    if (NRN is not null)
    then
      update UDO_T_URPT_SRV_CONF T
         set T.STR_VAL = SSTR_VAL
       where T.RN = NRN;
    else
      insert into UDO_T_URPT_SRV_CONF
        (RN, UNIT, UNITRN, PRM, STR_VAL)
      values
        (GEN_ID, NUNIT, NUNITRN, SPRM, SSTR_VAL);
    end if;
  end;

  --конфигурация сервиса - базовая установка значения параметра типа "Число"
  procedure CONF_SET_PRM_BASE
  (
    SUNIT    varchar2 --код родительского раздела параметра
   ,NUNITRN  number --рег. номер документа в разделе
   ,SPRM     varchar2 --код параметра
   ,NNUM_VAL number --значение типа "Число"
  ) is
    NRN   UDO_T_URPT_SRV_CONF.RN%type; --рег. номер параметра
    NUNIT UNITLIST.RN%type; --рег. номер родительского раздела параметра
  begin
    --разыменуем ссылки
    CONF_JOINS(SUNIT => SUNIT
              ,NUNIT => NUNIT);
    --найдем рег. номер параметра
    NRN := CONF_FIND_PRM(SUNIT   => SUNIT
                        ,NUNITRN => NUNITRN
                        ,SPRM    => SPRM
                        ,NSMART  => 1);
    --если нашли
    if (NRN is not null)
    then
      update UDO_T_URPT_SRV_CONF T
         set T.NUM_VAL = NNUM_VAL
       where T.RN = NRN;
    else
      insert into UDO_T_URPT_SRV_CONF
        (RN, UNIT, UNITRN, PRM, NUM_VAL)
      values
        (GEN_ID, NUNIT, NUNITRN, SPRM, NNUM_VAL);
    end if;
  end;

  --конфигурация сервиса - базовая установка значения параметра типа "Дата"
  procedure CONF_SET_PRM_BASE
  (
    SUNIT     varchar2 --код родительского раздела параметра
   ,NUNITRN   number --рег. номер документа в разделе
   ,SPRM      varchar2 --код параметра
   ,DDATE_VAL date --значение типа "Дата"
  ) is
    NRN   UDO_T_URPT_SRV_CONF.RN%type; --рег. номер параметра
    NUNIT UNITLIST.RN%type; --рег. номер родительского раздела параметра
  begin
    --разыменуем ссылки
    CONF_JOINS(SUNIT => SUNIT
              ,NUNIT => NUNIT);
    --найдем рег. номер параметра
    NRN := CONF_FIND_PRM(SUNIT   => SUNIT
                        ,NUNITRN => NUNITRN
                        ,SPRM    => SPRM
                        ,NSMART  => 1);
    --если нашли
    if (NRN is not null)
    then
      update UDO_T_URPT_SRV_CONF T
         set T.DATE_VAL = DDATE_VAL
       where T.RN = NRN;
    else
      insert into UDO_T_URPT_SRV_CONF
        (RN, UNIT, UNITRN, PRM, DATE_VAL)
      values
        (GEN_ID, NUNIT, NUNITRN, SPRM, DDATE_VAL);
    end if;
  end;

  --конфигурация сервиса - базовое считывание значения параметра типа "Строка"
  function CONF_GET_PRM_STR_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
  ) return varchar2 is
    SRES UDO_T_URPT_SRV_CONF.STR_VAL%type; --результат
  begin
    --считаем значение
    select T.STR_VAL
      into SRES
      from UDO_T_URPT_SRV_CONF T
          ,UNITLIST            UL
     where T.UNIT = UL.RN
       and UL.UNITCODE = SUNIT
       and T.UNITRN = NUNITRN
       and T.PRM = SPRM;
    --вернем результат
    return SRES;
  exception
    when others then
      return null;
  end;

  --конфигурация сервиса - базовое считывание значения параметра типа "Число"
  function CONF_GET_PRM_NUM_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
  ) return number is
    NRES UDO_T_URPT_SRV_CONF.NUM_VAL%type; --результат
  begin
    --считаем значение
    select T.NUM_VAL
      into NRES
      from UDO_T_URPT_SRV_CONF T
          ,UNITLIST            UL
     where T.UNIT = UL.RN
       and UL.UNITCODE = SUNIT
       and T.UNITRN = NUNITRN
       and T.PRM = SPRM;
    --вернем результат
    return NRES;
  exception
    when others then
      return null;
  end;

  --конфигурация сервиса - базовое считывание значения параметра типа "Дата"
  function CONF_GET_PRM_DATE_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
   ,SPRM    varchar2 --код параметра
  ) return date is
    DRES UDO_T_URPT_SRV_CONF.DATE_VAL%type; --результат
  begin
    --считаем значение
    select T.DATE_VAL
      into DRES
      from UDO_T_URPT_SRV_CONF T
          ,UNITLIST            UL
     where T.UNIT = UL.RN
       and UL.UNITCODE = SUNIT
       and T.UNITRN = NUNITRN
       and T.PRM = SPRM;
    --вернем результат
    return DRES;
  exception
    when others then
      return null;
  end;

  --конфигурация сервиса - базовое удаление параметра
  procedure CONF_REMOVE_PRM_BASE(NRN number --рег. номер параметра
                                 ) is
  begin
    --удалим параметр объекта
    delete from UDO_T_URPT_SRV_CONF T
     where T.RN = NRN;
  exception
    when others then
      null;
  end;

  --конфигурация сервиса - базовое удаление всех параметров объекта
  procedure CONF_REMOVE_PRMS_BASE
  (
    SUNIT   varchar2 --код родительского раздела параметра
   ,NUNITRN number --рег. номер документа в разделе
  ) is
  begin
    --идем по параметрам объекта
    for C in (select T.RN
                from UDO_T_URPT_SRV_CONF T
                    ,UNITLIST            U
               where T.UNIT = U.RN
                 and T.UNITRN = NUNITRN
                 and U.UNITCODE = SUNIT)
    loop
      --удаляем параметр
      CONF_REMOVE_PRM_BASE(NRN => C.RN);
    end loop;
  end;

  --конфигарция сервиса - базовая установка картинки предварительного просмотра
  procedure CONF_SET_PICT_BASE
  (
    NREPORT number --рег. номер отчета
   ,BPICT   blob --данные картинки
  ) is
  begin
    --добавим картинку
    insert into UDO_T_URPT_SRV_RPTPICT
      (RN, PRN, PICT)
    values
      (GEN_ID, NREPORT, BPICT);
  end;

  --конфигурация сервиса - базовое считывание картинки предварительного просмотра (возвращает URL)
  function CONF_GET_PICT_BASE(NRN number --рег. номер картинки
                              ) return varchar2 is
  begin
    --идем по картинкам предпросмотра
    for IMG in (select T.RN
                  from UDO_T_URPT_SRV_RPTPICT T
                 where T.RN = NRN
                   and T.PICT is not null
                   and NVL(DBMS_LOB.GETLENGTH(T.PICT)
                          ,0) > 0)
    loop
      --сформируем URL и вернем ответ
      return 'PARUS.UDO_PKG_URPT_SRV.UTL_DOWNLOAD?NFILE=' || IMG.RN || '&NTYPE=2';
    end loop;
    --нет такой картинки
    return null;
  exception
    when others then
      return null;
  end;

  --конфигарция сервиса - базовое удаление картинки предварительного просмотра
  procedure CONF_REMOVE_PICT_BASE(NRN number --рег. номер картинки
                                  ) is
  begin
    --удалим картинку
    delete from UDO_T_URPT_SRV_RPTPICT T
     where T.RN = NRN;
  end;

  --конфигарция сервиса - базовое удаление всех картинок предварительного просмотра
  procedure CONF_REMOVE_PICTS_BASE(NREPORT number --рег. номер отчета
                                   ) is
  begin
    --идем по картинкам
    for P in (select T.RN
                from UDO_T_URPT_SRV_RPTPICT T
               where T.PRN = NREPORT)
    loop
      --удаляем картинку
      CONF_REMOVE_PICT_BASE(NRN => P.RN);
    end loop;
  end;

  --клиентская установка значения параметров сервиса для раздела "Пользовательские отчеты"
  procedure CONF_SET_USR_REPORT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,NPUBL    number --признак публикации (0 - нет, 1 - да)
   ,SDESC    varchar2 --публикуемое описание отчета
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --установка признака публикации
    CONF_SET_PRM_BASE(SUNIT    => 'UserReports'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_USR_REPORT_PUBL
                     ,NNUM_VAL => NPUBL);
    --установка публикуемого описания
    CONF_SET_PRM_BASE(SUNIT    => 'UserReports'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_USR_REPORT_DESC
                     ,SSTR_VAL => SDESC);
  end;

  --клиентская установка описания публикации для раздела "Пользовательские отчеты"
  procedure CONF_SET_USR_REPORT_DESC
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,SDESC    varchar2 --публикуемое описание отчета
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --установка публикуемого описания
    CONF_SET_PRM_BASE(SUNIT    => 'UserReports'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_USR_REPORT_DESC
                     ,SSTR_VAL => SDESC);
  end;

  --клиентская установка картинки предпросмотра для раздела "Пользовательские отчеты"
  procedure CONF_SET_USR_REPORT_PREVIEW
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
   ,BPICT    blob --данные картинки
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --установка картинки публикации
    CONF_SET_PICT_BASE(NREPORT => NRN
                      ,BPICT   => BPICT);
  end;

  --клиентское переключение признака опубликованности для раздела "Пользовательские отчеты"
  procedure CONF_TOGGLE_USR_REPORT_PUBLISH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  ) is
    NPUBLISH number(17); --текущее значение признака опубликованности
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --считаем признак опубликованности
    NPUBLISH := CONF_GET_PRM_NUM_BASE(SUNIT   => 'UserReports'
                                     ,NUNITRN => NRN
                                     ,SPRM    => SCONF_USR_REPORT_PUBL);
    --переключим его
    if (NPUBLISH = NCAN_PUBLISH_USER_YES)
    then
      CONF_SET_PRM_BASE(SUNIT    => 'UserReports'
                       ,NUNITRN  => NRN
                       ,SPRM     => SCONF_USR_REPORT_PUBL
                       ,NNUM_VAL => NCAN_PUBLISH_USER_NO);
    else
      CONF_SET_PRM_BASE(SUNIT    => 'UserReports'
                       ,NUNITRN  => NRN
                       ,SPRM     => SCONF_USR_REPORT_PUBL
                       ,NNUM_VAL => NCAN_PUBLISH_USER_YES);
    end if;
  end;

  --клиентское удаление параметров сервиса для раздела "Пользовательские отчеты"
  procedure CONF_UNSET_USR_REPORT
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер отчета
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --удалим все картинки предпросмотра
    CONF_REMOVE_PICTS_BASE(NREPORT => NRN);
    --удалим все параметры публикации
    CONF_REMOVE_PRMS_BASE(SUNIT   => 'UserReports'
                         ,NUNITRN => NRN);
  end;

  --клиентское удаление картинки предварительного просмотра для раздела "Пользовательские отчеты"
  procedure CONF_UNSET_USR_REPORT_PREVIEW
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер картинки
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --удалим картинку предпросмотра
    CONF_REMOVE_PICT_BASE(NRN => NRN);
  end;

  --клиентское удаление расписания для раздела "Пользовательские отчеты"
  procedure CONF_UNSET_USR_REPORT_SCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер расписания
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации отчета!');
    end if;
    --удалим расписание
    SCHED_BASE_DELETE(NRN => NRN);
  end;

  --клиентская установка значения параметров сервиса для раздела "Классы"
  procedure CONF_SET_CLASS
  (
    SUSER           varchar2 --пользователь
   ,NCOMPANY        number --рег. номер организации
   ,NRN             number --рег. номер класса
   ,SCODE_ATTR      varchar2 --наименование атрибута класса для формирования его кода
   ,SDESC_ATTR      varchar2 --наименование атрибута класса для формирования его описания
   ,NNO_DESC_SEARCH number --признак исключения атрибута описания из поиска (0 - искать по иписанию, 1 - не искать по описанию)
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации класса!');
    end if;
    --установка атрибута кода
    CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_CLASS_CODE
                     ,SSTR_VAL => SCODE_ATTR);
    --установка атрибута наименования
    CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_CLASS_DESC
                     ,SSTR_VAL => SDESC_ATTR);
    --установка признака использования описания при поиске
    CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_CLASS_NO_DESC_SEARCH
                     ,NNUM_VAL => NNO_DESC_SEARCH);
  end;

  --клиентская установка значения параметров сервиса для раздела "Классы"
  procedure CONF_SET_CLASS_PUBL_ATTRS
  (
    SUSER      varchar2 --пользователь
   ,NCOMPANY   number --рег. номер организации
   ,NRN        number --рег. номер класса
   ,SCODE_ATTR varchar2 --наименование атрибута класса для формирования его кода
   ,SDESC_ATTR varchar2 --наименование атрибута класса для формирования его описания
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации класса!');
    end if;
    --установка атрибута кода
    CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_CLASS_CODE
                     ,SSTR_VAL => SCODE_ATTR);
    --установка атрибута наименования
    CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                     ,NUNITRN  => NRN
                     ,SPRM     => SCONF_CLASS_DESC
                     ,SSTR_VAL => SDESC_ATTR);
  end;

  --клиентское переключение признака игнорирования описания при поиске для раздела "Пользовательские отчеты"
  procedure CONF_TOGGLE_CLASS_NODESCSEARCH
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  ) is
    NNO_DESC_SEARCH number(17); --текущее значение признака игнорирования описания при поиске
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации класса!');
    end if;
    --считаем признак игнорирования описания при поиске
    NNO_DESC_SEARCH := CONF_GET_PRM_NUM_BASE(SUNIT   => 'DMSClasses'
                                            ,NUNITRN => NRN
                                            ,SPRM    => SCONF_CLASS_NO_DESC_SEARCH);
    --переключим его
    if (NNO_DESC_SEARCH = NNO_DESC_SEARCH_YES)
    then
      CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                       ,NUNITRN  => NRN
                       ,SPRM     => SCONF_CLASS_NO_DESC_SEARCH
                       ,NNUM_VAL => NNO_DESC_SEARCH_NO);
    else
      CONF_SET_PRM_BASE(SUNIT    => 'DMSClasses'
                       ,NUNITRN  => NRN
                       ,SPRM     => SCONF_CLASS_NO_DESC_SEARCH
                       ,NNUM_VAL => NNO_DESC_SEARCH_YES);
    end if;
  end;

  --клиентское удаление параметров сервиса для раздела "Классы"
  procedure CONF_UNSET_CLASS
  (
    SUSER    varchar2 --пользователь
   ,NCOMPANY number --рег. номер организации
   ,NRN      number --рег. номер класса
  ) is
  begin
    --проверим права доступа
    if (UTL_CHECK_IS_ADMIN(NCOMPANY => NCOMPANY
                          ,SUSER    => SUSER) = NIS_NOT_ADMIN)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для установки параметров публикации класса!');
    end if;
    --удалим все параметры класса
    CONF_REMOVE_PRMS_BASE(SUNIT   => 'DMSClasses'
                         ,NUNITRN => NRN);
  end;

  --проверка наличия расписания (0 - нет, 1 - есть)
  function SCHED_EXISTS
  (
    NPRN        number --рег. номер родительского отчета
   ,SUSR        varchar2 --пользователь
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц, 5 - единовременно)
   ,NSTEP       number --шаг исполнения расписания
   ,DSTART_DATE date --дата начала исполнения расписания
  ) return number is
    NTMP number(17); --буфер для расчетов
  begin
    --проверим наличие
    select T.RN
      into NTMP
      from UDO_T_URPT_SRV_SCHED T
     where T.PRN = NPRN
       and T.USR = SUSR
       and T.SCHED_TYPE = NSCHED_TYPE
       and T.STEP = NSTEP
       and T.START_DATE = DSTART_DATE;
    --вернем признак существования
    return 1;
  exception
    when NO_DATA_FOUND then
      return 0;
    when others then
      P_EXCEPTION(0
                 ,'Ошибка проверки уникальности расписания!');
  end;

  --базовое добавление записи расписания
  procedure SCHED_BASE_INSERT
  (
    NPRN        number --рег. номер родительского отчета
   ,SUSR        varchar2 --пользователь
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц, 5 - единовременно)
   ,NSTEP       number --шаг исполнения расписания
   ,DSTART_DATE date --дата начала исполнения расписания
   ,NMAIL       number --доставка по e-mail (0 - нет, 1 - да)
   ,CPRMS       clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
   ,NRN         out number --рег. номер добавленной записи расписания
  ) is
  begin
    --проверим параметры
    if ((NPRN is null) or (SUSR is null) or (NSCHED_TYPE is null) or
       (NSTEP is null) or (DSTART_DATE is null))
    then
      P_EXCEPTION(0
                 ,'Не указаны обязательные праметры!');
    end if;
    if (NSCHED_TYPE not in (NSCHED_TYPE_MIN
                           ,NSCHED_TYPE_HOUR
                           ,NSCHED_TYPE_DAY
                           ,NSCHED_TYPE_WEEK
                           ,NSCHED_TYPE_MONTH
                           ,NSCHED_TYPE_ONCE))
    then
      P_EXCEPTION(0
                 ,'Указанный тип расписания "' || NSCHED_TYPE ||
                  '" не поддерживается!');
    end if;
    if ((NSCHED_TYPE <> NSCHED_TYPE_ONCE) and
       ((NSTEP <> TRUNC(NSTEP)) or (NSTEP <= 0)))
    then
      P_EXCEPTION(0
                 ,'Шаг расписания должен быть целым положительным числом!');
    end if;
    if ((NSCHED_TYPE = NSCHED_TYPE_ONCE) and (NSTEP <> 0))
    then
      P_EXCEPTION(0
                 ,'Для единовременного исполнения шаг должен быть равен нулю!');
    end if;
    if (NMAIL is null)
    then
      P_EXCEPTION(0
                 ,'Не указан признак доставки по E-Mail!');
    end if;
    if (NMAIL not in (NMAIL_NO
                     ,NMAIL_YES))
    then
      P_EXCEPTION(0
                 ,'Признак доставки по E-Mail указан неверно!');
    end if;
    if (SCHED_EXISTS(NPRN        => NPRN
                    ,SUSR        => SUSR
                    ,NSCHED_TYPE => NSCHED_TYPE
                    ,NSTEP       => NSTEP
                    ,DSTART_DATE => DSTART_DATE) = 1)
    then
      P_EXCEPTION(0
                 ,'Такое расписание уже существует!');
    end if;
    --сформируем рег. номер записи
    NRN := GEN_ID;
    --добавим запись
    insert into UDO_T_URPT_SRV_SCHED
      (RN
      ,PRN
      ,USR
      ,SCHED_TYPE
      ,STEP
      ,START_DATE
      ,PRMS
      ,PREV_EXEC
      ,CNT_EXEC
      ,ERR_EXEC
      ,MAIL)
    values
      (NRN
      ,NPRN
      ,UPPER(SUSR)
      ,NSCHED_TYPE
      ,NSTEP
      ,DSTART_DATE
      ,CPRMS
      ,null
      ,0
      ,null
      ,NMAIL);
  end;

  --базовое удаление записи расписания
  procedure SCHED_BASE_DELETE(NRN number --рег. номер удаляемой записи
                              ) is
  begin
    --удалим запись расписания
    delete from UDO_T_URPT_SRV_SCHED T
     where T.RN = NRN;
    if (sql%notfound)
    then
      P_EXCEPTION(0
                 ,'Заись расписания (RN: ' || NRN || ') не найдена!');
    end if;
  end;

  --вычисление даты следующего запуска расписания
  function SCHED_CALC_NEXT_DATE(NRN number --рег. номер записи расписания
                                ) return date is
    SCH UDO_T_URPT_SRV_SCHED%rowtype; --запись расписания
  begin
    --считаем запись расписания
    select T.*
      into SCH
      from UDO_T_URPT_SRV_SCHED T
     where T.RN = NRN;
    --если нет даты предыдущего запуска, то дата очередного запуска - это дата старта
    if (SCH.PREV_EXEC is null)
    then
      return SCH.START_DATE;
    else
      --расчитаем в зависимости от типа расписания
      case SCH.SCHED_TYPE
      --ежеминутно
        when NSCHED_TYPE_MIN then
          begin
            return SCH.START_DATE +(1 / (24 * 60)) * SCH.STEP * SCH.CNT_EXEC;
          end;
          --ежечасно
        when NSCHED_TYPE_HOUR then
          begin
            return SCH.START_DATE +(1 / 24) * SCH.STEP * SCH.CNT_EXEC;
          end;
          --ежедневно
        when NSCHED_TYPE_DAY then
          begin
            return SCH.START_DATE + 1 * SCH.STEP * SCH.CNT_EXEC;
          end;
          --еженедельно
        when NSCHED_TYPE_WEEK then
          begin
            return SCH.START_DATE +(1 * 7) * SCH.STEP * SCH.CNT_EXEC;
          end;
          --ежемесячно
        when NSCHED_TYPE_MONTH then
          begin
            return ADD_MONTHS(SCH.START_DATE
                             ,SCH.STEP * SCH.CNT_EXEC);
          end;
          --единовременно
        when NSCHED_TYPE_ONCE then
          begin
            return SCH.START_DATE;
          end;
        else
          return null;
      end case;
    end if;
    return null;
  exception
    when others then
      return null;
  end;

  --выяснение необходимости запуска позиции расписания
  function SCHED_CHECK_EXEC
  (
    NRN   number --рег. номер записи расписания
   ,DEXEC date := sysdate --дата, относительно которой необходимо выполнить проверку
  ) return boolean is
    DEXEC_NEXT date; --расчетная дата следующего запуска
  begin
    --расчитаем дату следующего запуска
    DEXEC_NEXT := SCHED_CALC_NEXT_DATE(NRN => NRN);
    --если не расчиталась - то запускать не можем
    if (DEXEC_NEXT is null)
    then
      return false;
    end if;
    --если она раньше указанной - надо исполнять
    if (DEXEC_NEXT <= DEXEC)
    then
      return true;
    end if;
    --исполять не надо
    return false;
  exception
    when others then
      return false;
  end;

  --обработка зарегистрированных расписаний
  procedure SCHED_PROCESS is
    CRES       clob; --результат постановки в очередь (текстовое представление)
    DEXEC      date; --дата исполнения расписания
    NRESP_TYPE number(17); --тип ответа о постановке в очередь (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
    SRESP_MSG  varchar2(4000); --сообщение сервера о постановке в очередь
    NMAIL      UDO_T_SYS0015_MAIL.RN%type; --рег. номер сформировонной позиции очереди E-Mail рассылки
    NMAIL_ATT  UDO_T_SYS0015_MAIL_ATT.RN%type; --рег. номер приложения к письму, помещенному в очередь E-Mail рассылки
    SRCVR      UDO_T_SYS0015_MAIL.RCVR%type; --получатель E-mail рассылки
    SSUBJ      UDO_T_SYS0015_MAIL.SUBJ%type; --тема письма
    STEXT      UDO_T_SYS0015_MAIL.TEXT%type; --тело письма
    SFILE_NAME UDO_T_SYS0015_MAIL_ATT.FILE_NAME%type; --наименование файла-приложения к письму с данными отчета
  begin
    --идем по расписаниям
    for C in (select T.*
                    ,R.COMPANY
                from UDO_T_URPT_SRV_SCHED T
                    ,USERREPORTS          R
               where T.PRN = R.RN)
    loop
      --зафиксируем дату исполнения
      DEXEC := sysdate;
      --проверим, надо ли исполнять позицию
      if (SCHED_CHECK_EXEC(NRN   => C.RN
                          ,DEXEC => DEXEC))
      then
        --поместим в очередь
        CRES := JSON_REPORT_PUT(NCOMPANY   => C.COMPANY
                               ,SUSER      => C.USR
                               ,NREPORT    => C.PRN
                               ,NSCHEDULED => NSCHEDULED_YES
                               ,NMAIL      => C.MAIL
                               ,CPRMS      => C.PRMS);
        --разберем ответ
        JSON_PARSE_RESPONSE(CJSON      => CRES
                           ,NRESP_TYPE => NRESP_TYPE
                           ,SRESP_MSG  => SRESP_MSG);
        --обработаем ответ для записи в расписание
        if (NRESP_TYPE is null)
        then
          SRESP_MSG := 'Неожиданный ответ сервера!';
        else
          if (NRESP_TYPE = NRESP_TYPE_OK)
          then
            SRESP_MSG := null;
          end if;
        end if;
        --отметим в расписании его исполнение
        update UDO_T_URPT_SRV_SCHED T
           set T.PREV_EXEC = DEXEC
              ,T.CNT_EXEC  = NVL(T.CNT_EXEC
                                ,0) + 1
              ,T.ERR_EXEC  = SRESP_MSG
         where T.RN = C.RN;
        --удалим позицию расписания, если исполнили единовременную запись
        if (C.SCHED_TYPE = NSCHED_TYPE_ONCE)
        then
          SCHED_BASE_DELETE(NRN => C.RN);
        end if;
      end if;
    end loop;
    --теперь идем по позициям очереди, которые следует рассылать по почте и которые ещё не отправлены
    for C in (select T.RN
                    ,UR.COMPANY NCOMPANY
                    ,Q.RN NREPORTQ
                    ,Q.STATUS NREPORTQ_STATUS
                    ,Q.AUTHID SUSER
                    ,R.REPORT BFILE_DATA
                    ,NVL(DBMS_LOB.GETLENGTH(R.REPORT)
                        ,0) NFILE_LENGTH
                from UDO_T_URPT_SRV_RPTPQ T
                    ,RPTPRTQUEUE          Q
                    ,RPTPRTQUEUE_RPT      R
                    ,USERREPORTS          UR
               where T.MAILED = NMAIL_WAIT
                 and T.MAIL is null
                 and T.PQ = Q.RN
                 and Q.USER_REPORT = UR.RN
                 and Q.STATUS in (NQUEUE_STATE_OK
                                 ,NQUEUE_STATE_ERR)
                 and Q.RN = R.PRN(+))
    loop
      --определимся с получателем
      SRCVR := UTL_GET_USER_MAIL(NCOMPANY => C.NCOMPANY
                                ,SUSER    => C.SUSER);
      --сформируем тему и тело письма
      UTL_REPORTQ_BUILD_MAIL(NREPORTQ => C.NREPORTQ
                            ,SSUBJ    => SSUBJ
                            ,STEXT    => STEXT);
      --если успешно сформированы атрибуты письма
      if ((SRCVR is not null) and (SSUBJ is not null) and (STEXT is not null))
      then
        --ставим письмо в очередь
        UDO_PKG_SYS0015_MAIL.MAIL_INSERT(NCOMPANY => C.NCOMPANY
                                        ,SSNDR    => UDO_F_GET_CONST_VAL_STR(NFLAG_SMART => 1
                                                                            ,NCOMPANY    => C.NCOMPANY
                                                                            ,SCONST_NAME => 'SMTP_ОТПРАВИТЕЛЬ_ОТЧЕТНОСТЬ')
                                        ,SRCVR    => SRCVR
                                        ,SSUBJ    => SSUBJ
                                        ,STEXT    => STEXT
                                        ,NRN      => NMAIL);
        --если это успешный отчет - добавим к письму приложение
        if ((C.NREPORTQ_STATUS = NQUEUE_STATE_OK) and (C.NFILE_LENGTH > 0))
        then
          --сформируем имя файла для приложения отчета
          SFILE_NAME := UTL_REPORTQ_BUILD_FILE_NAME(NREPORTQ => C.NREPORTQ);
          --если успешно сформировали имя файла - делаем приложение к письму
          if (SFILE_NAME is not null)
          then
            UDO_PKG_SYS0015_MAIL.MAIL_ATT_INSERT(NPRN       => NMAIL
                                                ,SFILE_MIME => UDO_PKG_SYSW0003_PUBL_UTILS.GET_MIME_TYPE(SFILE_NAME => SFILE_NAME)
                                                ,SFILE_NAME => SFILE_NAME
                                                ,BFILE_DATA => C.BFILE_DATA
                                                ,NRN        => NMAIL_ATT);
          end if;
        end if;
        --отмечаем в отчете рег. номер сформированного письма
        update UDO_T_URPT_SRV_RPTPQ T
           set T.MAIL = NMAIL
         where T.RN = C.RN;
      end if;
    end loop;
    --проставим статусы отправки в позициях очереди печати, поставленных в очередь рассылки
    for C in (select T.RN
                    ,DECODE(NVL(M.STATUS
                               ,-1)
                           ,0
                           ,NMAIL_WAIT
                           ,1
                           ,NMAIL_WAIT
                           ,2
                           ,NMAIL_SEND_OK
                           ,-1
                           ,NMAIL_SEND_ERR) STATUS
                from UDO_T_URPT_SRV_RPTPQ T
                    ,UDO_T_SYS0015_MAIL   M
               where T.MAILED = NMAIL_WAIT
                 and T.MAIL is not null
                 and T.MAIL = M.RN(+))
    loop
      update UDO_T_URPT_SRV_RPTPQ T
         set T.MAILED = C.STATUS
       where T.RN = C.RN;
    end loop;
  exception
    when others then
      null;
  end;

  --формирование коллекции записей словаря
  procedure DICT_RECS_GET
  (
    NCOMPANY          number --рег. номер организации
   ,SUSER             varchar2 --пользователь
   ,SSEARCH           varchar2 --строка поиска (null - не искать)
   ,NPORTION          number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE     number --количество записей в порции (0 - все)
   ,NUNIT             number --рег. номер раздела системы/дополнительного словаря/рег. номер отчета
   ,NSHOW_MENTHOD     number --рег. номер метода вызова раздела (игнорируется, если NUINT дополнительный словарь)
   ,NSHOW_MENTHOD_PRM number --рег. номер параметра метода вызова раздела (игнорируется, если NUINT дополнительный словарь)
   ,DCT_RECS          out DICT_RECS --сформированная коллекция записей словаря
  ) is
    SSEARCH_        varchar2(4000); --строка поиска подготовленная для добавления в запрос
    NROW_FROM       number(17); --нижняя граница диапазона записей
    NROW_TO         number(17); --верхняя граница диапазона записей
    NDICT_TYPE      number(1); --тип анализируемого словаря (0 - раздел, 1 - дополнительный словарь, 2 - список разделов привязки отчета)
    NVERSION        VERSIONS.RN%type; --рег. номер версии данных словаря
    NEXCLUDE_SEARCH number(1) := 0; --признак включения поисковых условий в запрос (0 - включить, 1 - исключить)
  begin
    --определим тип переданного словаря
    begin
      select NDICT_TYPE_UNIT
        into NDICT_TYPE
        from UNITLIST UL
       where UL.RN = NUNIT;
    exception
      when NO_DATA_FOUND then
        begin
          select NDICT_TYPE_EXD
            into NDICT_TYPE
            from EXTRA_DICTS ED
           where ED.RN = NUNIT;
        exception
          when NO_DATA_FOUND then
            begin
              select NDICT_TYPE_RLU
                into NDICT_TYPE
                from USERREPORTS UR
               where UR.RN = NUNIT;
            exception
              when NO_DATA_FOUND then
                NDICT_TYPE := null;
            end;
        end;
    end;
    --если тип словаря успешно определили - будем наполнять коллекцию значениями в зависимости от типа
    if (NDICT_TYPE is not null)
    then
      --инициализируем выходную коллекцию записей раздела
      DCT_RECS := DICT_RECS();
      --подготовим строку поиска для использования в запросах
      UTL_PREPARE_SEARCH(SSEARCH          => SSEARCH
                        ,SSEARCH_PREPARED => SSEARCH_);
      --выставим флаг необходимости поиска
      if (SSEARCH is null)
      then
        NEXCLUDE_SEARCH := 1;
      end if;
      --вычисляем границы диапазона записей
      UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                          ,NPORTION_SIZE => NPORTION_SIZE
                          ,NROW_FROM     => NROW_FROM
                          ,NROW_TO       => NROW_TO);
      --разбераемся от типа словаря
      case NDICT_TYPE
      --словарь - это раздел системы
        when NDICT_TYPE_UNIT then
          declare
            SSQL varchar2(4000); --собранный запрос
          begin
            --попробуем собрать запрос на основе настроек в КОР
            SSQL := UTL_BUILD_CONSTR_QUERY(NCOMPANY          => NCOMPANY
                                          ,NUNIT             => NUNIT
                                          ,NSHOW_MENTHOD     => NSHOW_MENTHOD
                                          ,NSHOW_MENTHOD_PRM => NSHOW_MENTHOD_PRM
                                          ,NEXCLUDE_SEARCH   => NEXCLUDE_SEARCH);
            --если не получилось через КОР настройки - то попробуем по словарю данных и базовым системным настройкам
            if (SSQL is null)
            then
              SSQL := UTL_BUILD_SYSDEF_QUERY(NCOMPANY          => NCOMPANY
                                            ,NUNIT             => NUNIT
                                            ,NSHOW_MENTHOD_PRM => NSHOW_MENTHOD_PRM
                                            ,NEXCLUDE_SEARCH   => NEXCLUDE_SEARCH);
            end if;
            --если запрос успешно построен - исполним его в коллекцию
            if (SSQL is not null)
            then
              begin
                if (NEXCLUDE_SEARCH = 0)
                then
                  execute immediate SSQL bulk collect
                    into DCT_RECS
                    using NROW_TO, SSEARCH_, NROW_FROM;
                else
                  execute immediate SSQL bulk collect
                    into DCT_RECS
                    using NROW_TO, NROW_FROM;
                end if;
              exception
                when others then
                  DCT_RECS := DICT_RECS();
              end;
            end if;
          end;
          --словарь - это один из дополнительных словарей системы
        when NDICT_TYPE_EXD then
          begin
            --определим версию дополнительных словарей
            FIND_VERSION_BY_COMPANY(NCOMPANY  => NCOMPANY
                                   ,SUNITCODE => 'ExtraDictionaries'
                                   ,NVERSION  => NVERSION);
            --идем по значениям дополнительного словаря
            for C in (select ORD.NRN
                            ,ORD.SVAL
                            ,ORD.SDESC
                        from (select ROWNUM NROW
                                    ,NRN
                                    ,SVAL
                                    ,SDESC
                                from (select EDV.RN NRN
                                            ,NVL(NVL(EDV.STR_VALUE
                                                    ,TO_CHAR(EDV.NUM_VALUE))
                                                ,TO_CHAR(EDV.DATE_VALUE
                                                        ,'yyyy-mm-dd')) SVAL
                                            ,EDV.NOTE SDESC
                                        from EXTRA_DICTS        ED
                                            ,EXTRA_DICTS_VALUES EDV
                                       where ED.RN = NUNIT
                                         and ED.VERSION = NVERSION
                                         and EDV.PRN = ED.RN
                                         and ((STRINLIKE(UPPER(NVL(NVL(EDV.STR_VALUE
                                                                      ,TO_CHAR(EDV.NUM_VALUE))
                                                                  ,TO_CHAR(EDV.DATE_VALUE
                                                                          ,'dd.mm.yyyy')))
                                                        ,UPPER(SSEARCH_)) <> 0) or
                                             (STRINLIKE(UPPER(EDV.NOTE)
                                                        ,UPPER(SSEARCH_)) <> 0))
                                         and exists
                                       (select null
                                                from USERPRIV UP
                                               where UP.CATALOG = ED.CRN
                                                 and ((UP.AUTHID = SUSER) or
                                                     (UP.ROLEID in
                                                     (select UR.ROLEID
                                                          from USERROLES UR
                                                         where UR.AUTHID = SUSER))))
                                       order by 2)) ORD
                       where ORD.NROW between NROW_FROM and NROW_TO)
            loop
              DCT_RECS.EXTEND();
              DCT_RECS(DCT_RECS.LAST).NRN := C.NRN;
              DCT_RECS(DCT_RECS.LAST).SCODE := C.SVAL;
              DCT_RECS(DCT_RECS.LAST).SDESC := C.SDESC;
              DCT_RECS(DCT_RECS.LAST).SVAL := C.SVAL;
            end loop;
          end;
          --словарь - это один из разделов к которым привязан отчет
        when NDICT_TYPE_RLU then
          begin
            --идем по списку разделов к которым привязан параметр
            for C in (select ORD.NRN
                            ,ORD.SVAL
                            ,ORD.SDESC
                        from (select ROWNUM NROW
                                    ,NRN
                                    ,SVAL
                                    ,SDESC
                                from (select UL.RN NRN
                                            ,UL.UNITCODE SVAL
                                            ,UTL_UNIT_NAME(UL.RN) SDESC
                                        from USERREPORTSLINKS URL
                                            ,UNITLIST         UL
                                       where URL.PRN = NUNIT
                                         and UL.UNITCODE = URL.UNITCODE
                                       order by UL.UNITCODE)) ORD
                       where ORD.NROW between NROW_FROM and NROW_TO)
            loop
              DCT_RECS.EXTEND();
              DCT_RECS(DCT_RECS.LAST).NRN := C.NRN;
              DCT_RECS(DCT_RECS.LAST).SCODE := C.SVAL;
              DCT_RECS(DCT_RECS.LAST).SDESC := C.SDESC;
              DCT_RECS(DCT_RECS.LAST).SVAL := C.SVAL;
            end loop;
          end;
        else
          P_EXCEPTION(0
                     ,'Тип словаря "' || NDICT_TYPE || '" не поддерживается!');
      end case;
    else
      --если тип словаря не определился
      P_EXCEPTION(0
                 ,'Неудалось определить тип для словаря (RN:' || NUNIT || ')!');
    end if;
  end;

  --аутентификация в системе
  procedure SERVICE_LOGIN
  (
    SUSER                     varchar2 --пользователь
   ,SPASSWORD                 varchar2 --пароль
   ,SCOMPANY                  varchar2 --наименование организации
   ,SSESSION_CLIENT           varchar2 := null --идентификатор сессии сформированный клиентом
   ,SEXPECTED_SERVICE_VERSION varchar2 := null --ожидаемая клиентом версия сервиса
   ,SSESSION                  out varchar2 --идентификатор сессии
   ,NCOMPANY                  out number --рег. номер организации
  ) is
    SPASSWORD_SYS USERLIST.PASSWORD_WEB%type; --пароль, хранимый в системе
    NTMP          number(17); --буфер для расчетов
  begin
    --проверяем параметры
    if (SUSER is null)
    then
      P_EXCEPTION(0
                 ,'Не указано имя пользователя!');
    end if;
    if (SPASSWORD is null)
    then
      P_EXCEPTION(0
                 ,'Не указан пароль!');
    end if;
    if (SCOMPANY is null)
    then
      P_EXCEPTION(0
                 ,'Не указана организация!');
    end if;
    if (not BALLOW_NO_SERVICE_VERS_CHECK)
    then
      if (NVL(SEXPECTED_SERVICE_VERSION
             ,'0') <> SSERVICE_VERSION)
      then
        P_EXCEPTION(0
                   ,'Несоответствие клиентской и серверной части! Обновите приложение!');
      end if;
    end if;
    --считываем хранимый пароль пользователя и проверям наличие пользователя, а так же наличие у него признака работы через WEB
    begin
      select UL.PASSWORD_WEB
        into SPASSWORD_SYS
        from USERLIST UL
       where UPPER(UL.AUTHID) = UPPER(SUSER)
         and (UL.CLIENT_WEB = 1 and UL.SEC_PROFILE is null or
              exists(select null
                       from USERSECPROF SEC
                      where SEC.RN = UL.SEC_PROFILE
                        and SEC.CLIENT_WEB = 1)); -- 09/10/2018 Михайлов И.А. поддержка профилей безопасности
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0
                   ,'Пользователь "' || SUSER ||
                    '" не зарегистрирован в системе или не имеет признака доступа через WEB-клиента!');
    end;
    if (SPASSWORD_SYS is null)
    then
      P_EXCEPTION(0
                 ,'Для пользователя "' || SUSER ||
                  '" не установлен пароль доступа через WEB-клиента!');
    end if;
    --проверим наличие в личензии серверной части
    /*begin
      select count(*)
        into NTMP
        from table(XMLSEQUENCE(EXTRACT(XMLTYPE(GET_LICENSE)
                                      ,'/LICENSE/CONTENT/ROW/APPLICATION'))) P
       where EXTRACTVALUE(value(P)
                         ,'APPLICATION') = SSRV_LIC;
    exception
      when others then
        P_EXCEPTION(0
                   ,'Не удалось проверить корректность лицензионного файла!');
    end;
    if (NTMP = 0)
    then
      P_EXCEPTION(0
                 ,'В системе не зарегистрировано приложение "%s"!'
                 ,SSRV_LIC);
    end if;*/
    --разыменовываем организацию
    FIND_COMPANY_NAME(NFLAG_SMART => 0
                     ,SCOMPNAME   => SCOMPANY
                     ,NRN         => NCOMPANY);
    --формируем идентификатор сессии
    SSESSION := NVL(SSESSION_CLIENT
                   ,RAWTOHEX(SYS_GUID()));
    --добавим сессию
    PKG_SESSION.LOGON_WEB(SCONNECT        => SSESSION
                         ,SUTILIZER       => SUSER
                         ,SPASSWORD       => SPASSWORD
                         ,SIMPLEMENTATION => SCLN_LIC_IMPLEMENTATION
                         ,SAPPLICATION    => SCLN_LIC_APPLICATION
                         ,SCOMPANY        => SCOMPANY);
    PKG_SESSION.TIMEOUT_WEB(SCONNECT => SSESSION
                           ,NTIMEOUT => NSERVICE_IDLE_TIME);
  end;

  --завершение сеанса системе
  procedure SERVICE_LOGOUT(SSESSION varchar2 --идентификатор сессии
                           ) is
  begin
    --завершим сессию в системе
    PKG_SESSION.LOGOFF_WEB(SCONNECT => SSESSION);
  end;

  --проверка актуальности сессии
  procedure SERVICE_SESSION_CHECK
  (
    SUSER    varchar2 --пользователь
   ,SSESSION varchar2 --идентификатор сессии
  ) is
  begin
    --валидируем сессию
    PKG_SESSION.VALIDATE_WEB(SCONNECT => SSESSION);
  exception
    when others then
      if (SUSER is not null)
      then
        P_EXCEPTION(0
                   ,'Сессия пользователя "' || SUSER || '" истекла!');
      else
        P_EXCEPTION(0
                   ,'Сессия истекла!');
      end if;
  end;

  --проверка активности сервиса (0 - неактивен, 1 - активен)
  function SERVICE_ACTIVE_CHECK return number is
  begin
    --вернем состояние сервиса
    if (UTL_SERVICE_IS_ACTIVE())
    then
      return NIS_ACTIVE;
    else
      return NIS_NOT_ACTIVE;
    end if;
  end;

  --считывание значения строкового параметра системы
  function SERVICE_OPTION_GET_STR
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return varchar2 is
  begin
    if (SUSER is null)
    then
      return null;
    end if;
    return GET_OPTIONS_STR(SCODE      => SOPTION
                          ,NCOMP_VERS => NCOMPANY);
  exception
    when others then
      return null;
  end;

  --считывание значения числового параметра системы
  function SERVICE_OPTION_GET_NUM
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return number is
  begin
    if (SUSER is null)
    then
      return null;
    end if;
    return GET_OPTIONS_NUM(SCODE      => SOPTION
                          ,NCOMP_VERS => NCOMPANY);
  exception
    when others then
      return null;
  end;

  --считывание значения датского параметра системы
  function SERVICE_OPTION_GET_DATE
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return date is
  begin
    if (SUSER is null)
    then
      return null;
    end if;
    return GET_OPTIONS_DATE(SCODE      => SOPTION
                           ,NCOMP_VERS => NCOMPANY);
  exception
    when others then
      return null;
  end;

  --считывание организации
  procedure SERVICE_COMPANY_GET
  (
    NCOMPANY number --рег. номер записи
   ,CMPN     out COMPANY --сформированная запись организации
  ) is
    CMPN_REC COMPANIES%rowtype; --запись организации
  begin
    --считаем запись организации
    CMPN_REC := UTL_COMPANY_REC(NCOMPANY => NCOMPANY);
    --сформируем запись организации - рег. номер
    CMPN.NRN := CMPN_REC.RN;
    --наименование
    CMPN.SNAME := CMPN_REC.NAME;
    --полное наименование
    CMPN.SFULL_NAME := CMPN_REC.FULLNAME;
  end;

  --считывание списка организаций
  procedure SERVICE_COMPANYS_GET
  (
    SUSER varchar2 --пользователь
   ,CMPNS out COMPANYS --коллекция организаций
  ) is
  begin
    --инициализируем коллекцию
    CMPNS := COMPANYS();
    --идем по списку отчетов данной организации, доступных данному пользователю и отвечающих условиям публикации
    for C in (select CMP.RN NRN
                from COMPANIES CMP
               where ((SUSER is null) or
                     ((SUSER is not null) and
                     (CMP.RN in
                     (select CO.RN
                           from COMPANIES CO
                          where exists (select /*+ INDEX(UP I_USERPRIV_UNITCODE_ROLEID) */
                                  null
                                   from USERPRIV UP
                                  where UP.UNITCODE is null
                                    and UP.COMPANY = CO.RN
                                    and UP.ROLEID in
                                        (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                          UR.ROLEID
                                           from USERROLES UR
                                          where UR.AUTHID = SUSER)
                                 union all
                                 select /*+ INDEX(UP I_USERPRIV_UNITCODE_AUTHID) */
                                  null
                                   from USERPRIV UP
                                  where UP.UNITCODE is null
                                    and UP.COMPANY = CO.RN
                                    and UP.AUTHID = SUSER))))))
    loop
      --инкремент коллекции
      CMPNS.EXTEND;
      --проинициализируем запись отчета
      SERVICE_COMPANY_GET(NCOMPANY => C.NRN
                         ,CMPN     => CMPNS(CMPNS.LAST));
    end loop;
  end;

  --формирование записи раздела
  procedure UNIT_GET
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SSEARCH  varchar2 --строка поиска
   ,NUNIT    number --рег. номер раздела (0 - для формирования спец. раздела "Без привязки к разделу")
   ,UNT      out UNIT --сформированная запись раздела
  ) is
  begin
    if (NUNIT = NNOUNIT_RN)
    then
      UNT.NRN      := NNOUNIT_RN;
      UNT.SCODE    := SNOUNIT_CODE;
      UNT.SNAME    := SNOUNIT_NAME;
      UNT.NREPORTS := UTL_UNIT_CNT_PUBREPORTS(NCOMPANY => NCOMPANY
                                             ,SUSER    => SUSER
                                             ,SSEARCH  => SSEARCH
                                             ,NUNIT    => NUNIT);
    else
      begin
        select UL.RN
              ,UL.UNITCODE
              ,UTL_UNIT_NAME(UL.RN)
              ,UTL_UNIT_CNT_PUBREPORTS(NCOMPANY
                                      ,SUSER
                                      ,SSEARCH
                                      ,NUNIT)
          into UNT.NRN
              ,UNT.SCODE
              ,UNT.SNAME
              ,UNT.NREPORTS
          from UNITLIST UL
         where UL.RN = NUNIT;
      exception
        when others then
          PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                  ,NDOCUMENT   => NUNIT
                                  ,SUNIT_TABLE => 'UNITLIST');
      end;
    end if;
  end;

  --формирование коллекции разделов, имеющих привязанные отчеты
  procedure UNITS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,UNTS          out UNITS --сформированная коллекция разделов
  ) is
    NROW_FROM number(17); --нижняя граница диапазона записей
    NROW_TO   number(17); --верхняя граница диапазона записей
  begin
    --вычисляем границы диапазона записей
    UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                        ,NPORTION_SIZE => NPORTION_SIZE
                        ,NROW_FROM     => NROW_FROM
                        ,NROW_TO       => NROW_TO);
    --инициализируем коллекцию
    UNTS := UNITS();
    --идем по списку отчетов данной организации, доступных данному пользователю и отвечающих условиям публикации
    for C in (select ORD.NUNIT
                    ,ORD.SUNIT
                    ,ORD.SUNIT_NAME
                from (select ROWNUM NROW
                            ,D.NUNIT
                            ,D.SUNIT
                            ,D.SUNIT_NAME
                        from (select ULRPTS.NUNIT
                                    ,ULRPTS.SUNIT
                                    ,ULRPTS.SUNIT_NAME
                                from (select UL.RN NUNIT
                                            ,UL.UNITCODE SUNIT
                                            ,UTL_UNIT_NAME(UL.RN) SUNIT_NAME
                                        from (select ULST.*
                                                from UNITLIST ULST
                                               where exists
                                               (select URL.RN
                                                        from USERREPORTSLINKS URL
                                                       where URL.UNITCODE =
                                                             ULST.UNITCODE
                                                         and CONF_GET_PRM_NUM_BASE(SUNIT   => 'UserReports'
                                                                                  ,NUNITRN => URL.PRN
                                                                                  ,SPRM    => SCONF_USR_REPORT_PUBL) = 1)) UL
                                       where exists
                                       (select URL.RN
                                                from USERREPORTSLINKS URL
                                               where URL.UNITCODE = UL.UNITCODE)
                                         and UTL_UNIT_CNT_PUBREPORTS(NCOMPANY => UNITS_GET.NCOMPANY
                                                                    ,SUSER    => UNITS_GET.SUSER
                                                                    ,SSEARCH  => SSEARCH
                                                                    ,NUNIT    => UL.RN) > 0
                                      union all
                                      select NNOUNIT_RN   NUNIT
                                            ,SNOUNIT_CODE SUNIT
                                            ,SNOUNIT_NAME SUNIT_NAME
                                        from DUAL
                                       where UTL_UNIT_CNT_PUBREPORTS(NCOMPANY => UNITS_GET.NCOMPANY
                                                                    ,SUSER    => UNITS_GET.SUSER
                                                                    ,SSEARCH  => SSEARCH
                                                                    ,NUNIT    => NNOUNIT_RN) > 0) ULRPTS
                               order by ULRPTS.SUNIT_NAME) D) ORD
               where ORD.NROW between NROW_FROM and NROW_TO)
    loop
      --инкремент коллекции
      UNTS.EXTEND;
      --проинициализируем запись раздела
      UNIT_GET(NCOMPANY => NCOMPANY
              ,SUSER    => SUSER
              ,SSEARCH  => SSEARCH
              ,NUNIT    => C.NUNIT
              ,UNT      => UNTS(UNTS.LAST));
    end loop;
  end;

  --формирование записи связи отчета с разделом
  procedure REPORT_LU_GET
  (
    NLU    number --рег. номер привязки
   ,RPT_LU out REPORT_LU --сформированная запись связи отчета с разделом
  ) is
    LU_REC  USERREPORTSLINKS%rowtype; --запись таблицы связей отчетов с разделами
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --считаем данные из таблицы
    LU_REC := UTL_REPORT_LU_REC(NLU => NLU);
    --считаем данные отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => LU_REC.PRN);
    --сформируем запись связим отчета с разделом - рег. номер связи
    RPT_LU.NRN := LU_REC.RN;
    --рег. номер отчета
    RPT_LU.NPRN := LU_REC.PRN;
    --имя связи
    RPT_LU.SNAME := LU_REC.NAME;
    --рег. номер раздела, код раздела, наименование раздела
    begin
      select UL.RN
            ,UL.UNITCODE
            ,UTL_UNIT_NAME(UL.RN)
        into RPT_LU.NUNIT
            ,RPT_LU.SUNIT_CODE
            ,RPT_LU.SUNIT_NAME
        from UNITLIST UL
       where UL.UNITCODE = LU_REC.UNITCODE;
    exception
      when others then
        P_EXCEPTION(0
                   ,'Не удалось считать данные раздела привязки "' ||
                    LU_REC.UNITCODE || '" отчета "' || RPT_REC.CODE || '"!');
    end;
  end;

  --формирование коллекции связей отчета с разделами
  procedure REPORT_LUS_GET
  (
    NREPORT number --рег. номер отчета
   ,RPT_LUS out REPORT_LUS --сформированная коллекция связей отчета с разделами
  ) is
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --инициализируем коллекцию
    RPT_LUS := REPORT_LUS();
    --идем по связям отчета
    for C in (select T.RN
                from USERREPORTSLINKS T
               where T.PRN = RPT_REC.RN)
    loop
      RPT_LUS.EXTEND;
      REPORT_LU_GET(NLU    => C.RN
                   ,RPT_LU => RPT_LUS(RPT_LUS.LAST));
    end loop;
  end;

  --формирование записи расписания отчета
  procedure REPORT_SCH_GET
  (
    NSCH    number --рег. номер расписания
   ,RPT_SCH out REPORT_SCH --сформированная запись расписания отчета
  ) is
    SCH_REC UDO_T_URPT_SRV_SCHED%rowtype; --запись таблицы расписаний отчета
  begin
    --считаем данные из таблицы
    SCH_REC := UTL_REPORT_SCH_REC(NSCH => NSCH);
    --сформируем запись расписания отчета - рег. номер расписания
    RPT_SCH.NRN := SCH_REC.RN;
    --рег. номер отчета
    RPT_SCH.NPRN := SCH_REC.PRN;
    --пользователь
    RPT_SCH.SUSR := SCH_REC.USR;
    --тип расписания
    RPT_SCH.NSCHED_TYPE := SCH_REC.SCHED_TYPE;
    --шаг расписания
    RPT_SCH.NSTEP := SCH_REC.STEP;
    --дата начала исполнения расписания
    RPT_SCH.DSTART_DATE := SCH_REC.START_DATE;
    --признак доставки по e-mail
    RPT_SCH.NMAIL := SCH_REC.MAIL;
  end;

  --формирование коллекции расписаний отчета
  procedure REPORT_SCHS_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,RPT_SCHS out REPORT_SCHS --сформированная коллекция расписаний отчета
  ) is
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --инициализируем коллекцию
    RPT_SCHS := REPORT_SCHS();
    --идем по расписаниям отчета
    for C in (select T.RN
                from UDO_T_URPT_SRV_SCHED T
               where T.PRN = RPT_REC.RN
                 and T.USR = SUSER)
    loop
      RPT_SCHS.EXTEND;
      REPORT_SCH_GET(NSCH    => C.RN
                    ,RPT_SCH => RPT_SCHS(RPT_SCHS.LAST));
    end loop;
  end;

  --получение состояния отчета в избранном (0 - нет, 1 - да)
  function REPORT_FAVOR_GET
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
  ) return number is
    NRES number; --результат работы
    SERR varchar2(4000); --буфер для ошибок
  begin
    --найдем в избранном
    begin
      select NFAVOR_YES
        into NRES
        from UDO_T_URPT_SRV_FAVOR T
       where T.RPT = NREPORT
         and T.USR = SUSER;
    exception
      when NO_DATA_FOUND then
        NRES := NFAVOR_NO;
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,'Не удалось определить состояние "избранности" отчета (RN:' ||
                    NREPORT || ') для пользователя "' || SUSER || '": ' || SERR);
    end;
    --вернем результат
    return NRES;
  end;

  --добавление/удаление отчета в/из списка избранных
  procedure REPORT_FAVOR_TOGGLE
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
   ,NFAVOR  out number --текущий статус отчета в избранном
  ) is
    SERR varchar2(4000); --буфер для ошибок
  begin
    --если отчет в избранном
    if (REPORT_FAVOR_GET(SUSER   => SUSER
                        ,NREPORT => NREPORT) = NFAVOR_YES)
    then
      --удалим
      delete from UDO_T_URPT_SRV_FAVOR T
       where T.RPT = NREPORT
         and T.USR = SUSER;
      --покажем что убран из избранного
      NFAVOR := NFAVOR_NO;
    else
      --если его в избранном нет - добавим
      insert into UDO_T_URPT_SRV_FAVOR
        (RN, RPT, USR)
      values
        (GEN_ID, NREPORT, SUSER);
      --покажем что в избранном
      NFAVOR := NFAVOR_YES;
    end if;
  exception
    when others then
      SERR := sqlerrm;
      P_EXCEPTION(0
                 ,'Не удалось изменить состояние "избранности" отчета (RN:' ||
                  NREPORT || ') для пользователя "' || SUSER || '": ' || SERR);
  end;

  --формирование записи параметра отчета
  procedure REPORT_PRM_GET
  (
    SUSER   varchar2 --пользователь
   ,NPRM    number --рег. номер параметра отчета
   ,RPT_PRM out REPORT_PRM --сформированная запись параметра отчета
  ) is
    PRM_REC USERREPORTS_PARAMS%rowtype; --запись таблицы параметров пользовательских отчетов
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --считаем данные из таблицы
    PRM_REC := UTL_REPORT_PRM_REC(NPRM => NPRM);
    --считаем данные отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => PRM_REC.PRN);
    --сформируем запись параметра - рег. номер параметра
    RPT_PRM.NRN := PRM_REC.RN;
    --рег. номер отчета
    RPT_PRM.NPRN := PRM_REC.PRN;
    --имя параметра
    RPT_PRM.SNAME := PRM_REC.NAME;
    --приглашение ко вводу
    RPT_PRM.SPROMPT := PRM_REC.PROMPT;
    --обязательность
    case PRM_REC.MANDATORY
      when NREQ_NO_SYS then
        RPT_PRM.NREQ := NREQ_NO;
      when NREQ_YES_SYS then
        RPT_PRM.NREQ := NREQ_YES;
      else
        P_EXCEPTION(0
                   ,'Значение признака обязательности "' || PRM_REC.MANDATORY ||
                    '" параметра "' || PRM_REC.NAME || '" отчета "' ||
                    RPT_REC.CODE || '" не поддерживается!');
    end case;
    --тип данных (0 - строка, 1 - число, 2 - дата, 3 - булево)
    case PRM_REC.DATA_TYPE
      when NVAL_TYPE_STR_SYS then
        RPT_PRM.NVAL_TYPE := NVAL_TYPE_STR;
      when NVAL_TYPE_NUMB_SYS then
        RPT_PRM.NVAL_TYPE := NVAL_TYPE_NUMB;
      when NVAL_TYPE_CURR_SYS then
        RPT_PRM.NVAL_TYPE := NVAL_TYPE_NUMB;
      when NVAL_TYPE_BOOL_SYS then
        RPT_PRM.NVAL_TYPE := NVAL_TYPE_BOOL;
      when NVAL_TYPE_DATE_SYS then
        RPT_PRM.NVAL_TYPE := NVAL_TYPE_DATE;
      else
        P_EXCEPTION(0
                   ,'Тип данных "' || PRM_REC.DATA_TYPE || '" параметра "' ||
                    PRM_REC.NAME || '" отчета "' || RPT_REC.CODE ||
                    '" не поддерживается!');
    end case;
    --способ ввода значения (0 - ручной ввод, 1 - выбор из словаря, 2 - контекст - организация, 3 - контекст - код раздела, 4 - контекст - рег. номер докумета, 5 - контекст - идетификатор отмеченных записей)
    case PRM_REC.LINKING
      when NINP_TYPE_MANUAL_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_MANUAL;
      when NINP_TYPE_COMPANY_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_COMPANY;
      when NINP_TYPE_DOC_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_DICT;
      when NINP_TYPE_EXDICT_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_DICT;
      when NINP_TYPE_UNIT_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_UNIT;
      when NINP_TYPE_DOC_RN_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_DOC_RN;
      when NINP_TYPE_SL_IDENT_SYS then
        RPT_PRM.NINP_TYPE := NINP_TYPE_SL_IDENT;
      else
        P_EXCEPTION(0
                   ,'Тип привязки "' || PRM_REC.LINKING || '" параметра "' ||
                    PRM_REC.NAME || '" отчета "' || RPT_REC.CODE ||
                    '" не поддерживается!');
    end case;
    --предыдущее значение
    begin
      select NVL(PQP.STR_VALUE
                ,NVL(TO_CHAR(PQP.NUM_VALUE)
                    ,TO_CHAR(PQP.DATE_VALUE
                            ,'yyyy-mm-dd')))
        into RPT_PRM.SPREV_VAL
        from RPTPRTQUEUE_PRM PQP
            ,RPTPRTQUEUE     PQ
       where PQ.USER_REPORT = RPT_REC.RN
         and PQ.AUTHID = SUSER
         and PQ.QUEUE_TIME_STAMP =
             (select max(PQ2.QUEUE_TIME_STAMP)
                from RPTPRTQUEUE PQ2
               where PQ2.USER_REPORT = RPT_REC.RN
                 and PQ2.AUTHID = SUSER)
         and PQP.PRN = PQ.RN
         and PQP.NAME = PRM_REC.NAME;
    exception
      when others then
        RPT_PRM.SPREV_VAL := null;
    end;
    --значение по-умолчанию
    RPT_PRM.SDEF_VAL := NVL(PRM_REC.DEFAULT_STR
                           ,NVL(TO_CHAR(PRM_REC.DEFAULT_NUM)
                               ,TO_CHAR(PRM_REC.DEFAULT_DATE
                                       ,'yyyy-mm-dd')));
  end;

  --формирование коллекции параметров отчета
  procedure REPORT_PRMS_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORT  number --рег. номер отчета
   ,RPT_PRMS out REPORT_PRMS --сформированная коллекция параметров отчета
  ) is
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --инициализируем коллекцию
    RPT_PRMS := REPORT_PRMS();
    --идем по параметрам отчета
    for C in (select T.RN
                from USERREPORTS_PARAMS T
               where T.PRN = RPT_REC.RN
               order by T.SORT_NUMB)
    loop
      RPT_PRMS.EXTEND;
      REPORT_PRM_GET(SUSER   => SUSER
                    ,NPRM    => C.RN
                    ,RPT_PRM => RPT_PRMS(RPT_PRMS.LAST));
    end loop;
  end;

  --формирование списка записей словаря параметра отчета
  procedure REPORT_PRM_DICT_RECS_GET
  (
    SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,SUNIT_CODE    out varchar2 --код раздела
   ,SUNIT_NAME    out varchar2 --наименование раздела
   ,DCT_RECS      out DICT_RECS --сформированная коллекция записей словаря
  ) is
    PRM_REC USERREPORTS_PARAMS%rowtype; --запись таблицы параметров пользовательских отчетов
    RPT_REC USERREPORTS%rowtype; --запись отчета
    NUNIT   UNITLIST.RN%type; --рег. номер раздела привязки параметра
  begin
    --считаем данные из таблицы
    PRM_REC := UTL_REPORT_PRM_REC(NPRM => NPRM);
    --считаем данные отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => PRM_REC.PRN);
    --проверим, что параметр привязан к разделу,  доп. словарю или коду раздела
    if (PRM_REC.LINKING not in (NINP_TYPE_DOC_SYS
                               ,NINP_TYPE_EXDICT_SYS
                               ,NINP_TYPE_UNIT_SYS))
    then
      P_EXCEPTION(0
                 ,'Параметр "' || PRM_REC.PROMPT ||
                  '" не привязан к источникам данных!');
    end if;
    --если параметр привязан к разделу отчета
    if (PRM_REC.LINKING = NINP_TYPE_UNIT_SYS)
    then
      NUNIT      := RPT_REC.RN;
      SUNIT_CODE := 'UNITLIST';
      SUNIT_NAME := 'Разделы системы';
    end if;
    --если параметр привязан к разделу - найдем рег. номер этого раздела, его код и наименование
    if (PRM_REC.LINKING = NINP_TYPE_DOC_SYS)
    then
      if (PRM_REC.UNITCODE is null)
      then
        P_EXCEPTION(0
                   ,'Не указан раздел привязки параметра "' || PRM_REC.PROMPT || '"!');
      end if;
      begin
        select UL.RN
              ,UL.UNITCODE
              ,UTL_UNIT_NAME(UL.RN)
          into NUNIT
              ,SUNIT_CODE
              ,SUNIT_NAME
          from UNITLIST UL
         where UL.UNITCODE = PRM_REC.UNITCODE;
      exception
        when others then
          P_EXCEPTION(0
                     ,'Раздел привязки "' || PRM_REC.UNITCODE ||
                      '" параметра "' || PRM_REC.PROMPT || '" не определен!');
      end;
    end if;
    --если параметр привязан к доп. словарю - найдем рег. номер этого словаря, его код и наименование
    if (PRM_REC.LINKING = NINP_TYPE_EXDICT_SYS)
    then
      if (PRM_REC.ED_RN is null)
      then
        P_EXCEPTION(0
                   ,'Не указан дополнительный словарь привязки параметра "' ||
                    PRM_REC.PROMPT || '"!');
      end if;
      begin
        select ED.CODE
              ,ED.NAME
          into SUNIT_CODE
              ,SUNIT_NAME
          from EXTRA_DICTS ED
         where ED.RN = PRM_REC.ED_RN;
      exception
        when others then
          P_EXCEPTION(0
                     ,'Дополнительный словарь привязки "' ||
                      TO_CHAR(PRM_REC.ED_RN) || '" параметра "' ||
                      PRM_REC.PROMPT || '" не определен!');
      end;
      NUNIT := PRM_REC.ED_RN;
    end if;
    --формирование коллекции записей словаря
    DICT_RECS_GET(NCOMPANY          => RPT_REC.COMPANY
                 ,SUSER             => SUSER
                 ,NPORTION          => NPORTION
                 ,NPORTION_SIZE     => NPORTION_SIZE
                 ,NUNIT             => NUNIT
                 ,NSHOW_MENTHOD     => PRM_REC.SHOW_METHOD_RN
                 ,NSHOW_MENTHOD_PRM => PRM_REC.PARAM_RN
                 ,SSEARCH           => SSEARCH
                 ,DCT_RECS          => DCT_RECS);
  end;

  --формирование записи отчета
  procedure REPORT_GET
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
   ,RPT     out REPORT --сформированная запись отчета
  ) is
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --сформируем запись параметра - рег. номер
    RPT.NRN := RPT_REC.RN;
    --код
    RPT.SCODE := RPT_REC.CODE;
    --наименование
    RPT.SNAME := RPT_REC.NAME;
    --описание
    RPT.SDESC := CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                      ,NUNITRN => RPT_REC.RN
                                      ,SPRM    => SCONF_USR_REPORT_DESC);
    --тип отчета (0 - CR, 1 - Excel, 2 - OO Calc)
    case RPT_REC.REPORT_TYPE
      when NRPT_TYPE_CRYSTAL_SYS then
        RPT.NRPT_TYPE := NRPT_TYPE_CRYSTAL;
      when NRPT_TYPE_EXCEL_SYS then
        RPT.NRPT_TYPE := NRPT_TYPE_EXCEL;
      when NRPT_TYPE_OOCALC_SYS then
        RPT.NRPT_TYPE := NRPT_TYPE_OOCALC;
      else
        P_EXCEPTION(0
                   ,'Тип "' || F_USERREPORTS_TYPE(RPT_REC.REPORT_TYPE) ||
                    '" отчета "' || RPT_REC.CODE || '" не поддерживается!');
    end case;
    --признак "избранности" отчета
    RPT.NFAVOR := REPORT_FAVOR_GET(SUSER   => SUSER
                                  ,NREPORT => RPT_REC.RN);
    --количество отчетов в очереди
    begin
      select count(PQ.RN)
        into RPT.NCNTQ
        from RPTPRTQUEUE PQ
       where PQ.USER_REPORT = RPT_REC.RN
         and PQ.AUTHID = SUSER;
    exception
      when others then
        RPT.NCNTQ := 0;
    end;
    --наличие предпросмотра
    begin
      select count(T.RN)
        into RPT.NPREVIEW
        from UDO_T_URPT_SRV_RPTPICT T
       where T.PRN = RPT_REC.RN
         and T.PICT is not null
         and NVL(DBMS_LOB.GETLENGTH(T.PICT)
                ,0) > 0;
    exception
      when others then
        RPT.NPREVIEW := 0;
    end;
    --наличие расписаний
    begin
      select count(T.RN)
        into RPT.NSCHEDULED
        from UDO_T_URPT_SRV_SCHED T
       where T.PRN = RPT_REC.RN
         and T.USR = SUSER;
    exception
      when others then
        RPT.NSCHEDULED := 0;
    end;
    --адрес e-mail для доставки отчета
    RPT.SMAIL := UTL_GET_USER_MAIL(NCOMPANY => RPT_REC.COMPANY
                                  ,SUSER    => SUSER);
    --возможность доставки отчета по e-mail (0 - нет, 1 - да)
    if (RPT.SMAIL is not null)
    then
      RPT.NMAIL_ENABLED := NMAIL_ENABLED_YES;
    else
      RPT.NMAIL_ENABLED := NMAIL_ENABLED_NO;
    end if;
    --связи отчета с разделами
    REPORT_LUS_GET(NREPORT => RPT_REC.RN
                  ,RPT_LUS => RPT.LUS);
    --расписания отчета
    REPORT_SCHS_GET(SUSER    => SUSER
                   ,NREPORT  => RPT_REC.RN
                   ,RPT_SCHS => RPT.SCHS);
    --параметры отчета
    REPORT_PRMS_GET(SUSER    => SUSER
                   ,NREPORT  => RPT_REC.RN
                   ,RPT_PRMS => RPT.PRMS);
  end;

  --формирование коллекции отчетов
  procedure REPORTS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
   ,RPTS          out REPORTS --сформированная коллекция отчетов
  ) is
    NROW_FROM number(17); --нижняя граница диапазона записей
    NROW_TO   number(17); --верхняя граница диапазона записей
    SSEARCH_  varchar2(4000); --строка поиска подготовленная для добавления в запрос
  begin
    --вычисляем границы диапазона записей
    UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                        ,NPORTION_SIZE => NPORTION_SIZE
                        ,NROW_FROM     => NROW_FROM
                        ,NROW_TO       => NROW_TO);
    --подготовим строку поиска для использования в запросах
    UTL_PREPARE_SEARCH(SSEARCH          => SSEARCH
                      ,SSEARCH_PREPARED => SSEARCH_);
    --инициализируем коллекцию
    RPTS := REPORTS();
    --идем по списку отчетов данной организации, доступных данному пользователю и отвечающих условиям публикации
    for C in (select ORD.NRN
                    ,ORD.NUNIT
                    ,ORD.SUNIT
                    ,ORD.SUNIT_NAME
                from (select ROWNUM NROW
                            ,D.NRN
                            ,D.NUNIT
                            ,D.SUNIT
                            ,D.SUNIT_NAME
                        from (select NRN
                                    ,NUNIT
                                    ,SUNIT
                                    ,SUNIT_NAME
                                from (select UR.RN NRN
                                            ,NVL(UL.RN
                                                ,NNOUNIT_RN) NUNIT
                                            ,NVL(UL.UNITCODE
                                                ,SNOUNIT_CODE) SUNIT
                                            ,NVL(UTL_UNIT_NAME(UL.RN)
                                                ,SNOUNIT_NAME) SUNIT_NAME
                                        from USERREPORTS      UR
                                            ,USERREPORTSLINKS URL
                                            ,UNITLIST         UL
                                       where UTL_REPORT_CAN_PUBLISH_USER(NCOMPANY => REPORTS_GET.NCOMPANY
                                                                        ,SUSER    => REPORTS_GET.SUSER
                                                                        ,NREPORT  => UR.RN
                                                                        ,NUNIT    => REPORTS_GET.NUNIT
                                                                        ,NFAVOR   => REPORTS_GET.NFAVOR) =
                                             NCAN_PUBLISH_USER_YES
                                         and UR.RN = URL.PRN(+)
                                         and URL.UNITCODE = UL.UNITCODE(+)
                                         and ((STRINLIKE(UPPER(UR.CODE)
                                                        ,UPPER(SSEARCH_)) <> 0) or
                                              (STRINLIKE(UPPER(UR.NAME)
                                                        ,UPPER(SSEARCH_)) <> 0) or
                                              (STRINLIKE(UPPER(CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                                                                    ,NUNITRN => UR.RN
                                                                                    ,SPRM    => SCONF_USR_REPORT_DESC))
                                                        ,UPPER(SSEARCH_)) <> 0))
                                       order by NVL(UTL_UNIT_NAME(UL.RN)
                                                   ,SNOUNIT_NAME)
                                               ,UR.NAME)) D) ORD
               where ORD.NROW between NROW_FROM and NROW_TO
                 and NRPT_ORDER = NRPT_ORDER_UNIT
              union all
              select ORD.NRN
                    ,ORD.NUNIT
                    ,ORD.SUNIT
                    ,ORD.SUNIT_NAME
                from (select ROWNUM NROW
                            ,D.NRN
                            ,D.NUNIT
                            ,D.SUNIT
                            ,D.SUNIT_NAME
                        from (select NRN
                                    ,NUNIT
                                    ,SUNIT
                                    ,SUNIT_NAME
                                from (select distinct UR.RN NRN
                                                     ,null  NUNIT
                                                     ,null  SUNIT
                                                     ,null  SUNIT_NAME
                                        from USERREPORTS UR
                                       where UTL_REPORT_CAN_PUBLISH_USER(NCOMPANY => REPORTS_GET.NCOMPANY
                                                                        ,SUSER    => REPORTS_GET.SUSER
                                                                        ,NREPORT  => UR.RN
                                                                        ,NUNIT    => REPORTS_GET.NUNIT
                                                                        ,NFAVOR   => REPORTS_GET.NFAVOR) =
                                             NCAN_PUBLISH_USER_YES
                                         and ((STRINLIKE(UPPER(UR.CODE)
                                                        ,UPPER(SSEARCH_)) <> 0) or
                                              (STRINLIKE(UPPER(UR.NAME)
                                                        ,UPPER(SSEARCH_)) <> 0) or
                                              (STRINLIKE(UPPER(CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                                                                    ,NUNITRN => UR.RN
                                                                                    ,SPRM    => SCONF_USR_REPORT_DESC))
                                                        ,UPPER(SSEARCH_)) <> 0))
                                       order by UR.NAME)) D) ORD
               where ORD.NROW between NROW_FROM and NROW_TO
                 and NRPT_ORDER = NRPT_ORDER_NAME)
    loop
      --инкремент коллекции
      RPTS.EXTEND;
      --проинициализируем запись отчета
      REPORT_GET(SUSER   => SUSER
                ,NREPORT => C.NRN
                ,RPT     => RPTS(RPTS.LAST).RPT);
      --если сортировка по разделам - укажем раздел
      if (NRPT_ORDER = NRPT_ORDER_UNIT)
      then
        RPTS(RPTS.LAST).NUNIT := C.NUNIT;
        RPTS(RPTS.LAST).SUNIT_CODE := C.SUNIT;
        RPTS(RPTS.LAST).SUNIT_NAME := C.SUNIT_NAME;
      end if;
    end loop;
  end;

  --добавление отчета в очередь
  procedure REPORT_PUT
  (
    NCOMPANY   number --рег. номер организации
   ,SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NSCHEDULED number --признак исполнения по расписанию (0 - нет, 1 - да)
   ,NMAIL      number --признак отправки по e-mail (0 - нет, 1 - да)
   ,PRMS       REPORTQ_PRMS --набор параметров для формируемой позиции очереди
   ,NREPORTQ   out number --рег. номер сформированной позиции очереди
  ) is
    RPT_REC      USERREPORTS%rowtype; --запись отчета
    PRM_REC      USERREPORTS_PARAMS%rowtype; --запись таблицы параметров пользовательских отчетов
    NREPORTQ_PRM RPTPRTQUEUE_PRM.RN%type; --рег. номер параметра позиции очереди
    NDATA_TYPE   RPTPRTQUEUE_PRM.DATA_TYPE%type; --типа данных параметра позиции очереди
    NTMP         RPTPRTQUEUE_PRM.NUM_VALUE%type; --буфер для числового значеня параметра позиции очереди
    STMP         RPTPRTQUEUE_PRM.STR_VALUE%type; --буфер для строкового значеня параметра позиции очереди
    DTMP         RPTPRTQUEUE_PRM.DATE_VALUE%type; --буфер для значеня типа дата параметра позиции очереди
    NPIPE_RC     binary_integer; --идентификатор сообщения фонового процесса
    pragma autonomous_transaction;
  begin
    --проверим, что есть данные отчета
    if (NREPORT is null)
    then
      P_EXCEPTION(0
                 ,'Не указан отчет для добавления в очередь!');
    end if;
    --считывание записи отчёта
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --проверим права доступа
    if ((UTL_CHECK_PRIVS(SUSER    => SUSER
                        ,SUNIT    => 'UserReports'
                        ,SACTION  => 'UREP_PRINT_SERV'
                        ,NCOMPANY => RPT_REC.COMPANY
                        ,NCRN     => RPT_REC.CRN) = NHAVE_NO_PRIVS) or
       ((UTL_CHECK_PRIVS(SUSER    => SUSER
                         ,SUNIT    => 'UserReports'
                         ,SACTION  => 'UREP_PRINT'
                         ,NCOMPANY => RPT_REC.COMPANY
                         ,NCRN     => RPT_REC.CRN) = NHAVE_NO_PRIVS)))
    then
      P_EXCEPTION(0
                 ,'У вас нет прав доступа для заказа данного отчета на сервере печати!');
    end if;
    --проверка пользовательского отчёта - тип отчёта
    if (RPT_REC.REPORT_TYPE not in
       (NRPT_TYPE_CRYSTAL_SYS
        ,NRPT_TYPE_EXCEL_SYS
        ,NRPT_TYPE_OOCALC_SYS))
    then
      P_EXCEPTION(0
                 ,'Для пользовательского отчёта "%s" (тип "%s") печать сервером печати не поддерживается!'
                 ,RPT_REC.CODE
                 ,F_USERREPORTS_TYPE(RPT_REC.REPORT_TYPE));
    end if;
    --проверка пользовательского отчёта - хранимая процедура формирования
    if (RPT_REC.STORED_PROC is null)
    then
      P_EXCEPTION(0
                 ,'Для пользовательского отчёта "%s" (без хранимой процедуры формирования) печать сервером печати не поддерживается!'
                 ,RPT_REC.CODE);
    end if;
    --проверка наличия параметров в отчете и того что они были переданы
    for C in (select P.RN
                from USERREPORTS_PARAMS P
               where P.PRN = RPT_REC.RN
                 and ROWNUM <= 1)
    loop
      --сюда мы зайдем если в отчете есть хоть один объявленный параметр
      if ((PRMS is null) or (PRMS.COUNT <= 0))
      then
        --если параметры объявлены но не переданы
        P_EXCEPTION(0
                   ,'Для отчета не заданы параметры!');
      end if;
    end loop;
    --базовое добавление записи очереди печати отчётов
    UTL_REPORTQ_BASE_INSERT(SUSER        => SUSER
                           ,NREPORT_TYPE => PKG_RPTPRTQUEUE.TYPE_USER_REPORT
                           ,NCOMPANY     => NCOMPANY
                           ,NIDENT       => null
                           ,NUSER_REPORT => RPT_REC.RN
                           ,NRN          => NREPORTQ);
    --отметим, в доп. сведениях очереди, что отчет выполнен по расписанию и надо ли его отправлять по почте
    insert into UDO_T_URPT_SRV_RPTPQ
      (RN, PQ, SCHEDULED, MAILED)
    values
      (GEN_ID()
      ,NREPORTQ
      ,NSCHEDULED
      ,DECODE(NMAIL
             ,NMAIL_NO
             ,NMAIL_NOT_ORDERED
             ,NMAIL_WAIT));
    --добавление параметров
    if ((PRMS is not null) and (PRMS.COUNT > 0))
    then
      -- цикл по параметрам
      for I in PRMS.FIRST .. PRMS.LAST
      loop
        --считаем запись параметра из пользовательского отчета
        PRM_REC := UTL_REPORT_PRM_REC_BY_NAME(NREPORT   => RPT_REC.RN
                                             ,SPRM_NAME => PRMS(I).SNAME);
        --проверим заполненность обязательного параметра
        if ((PRMS(I).SVAL is null) and (PRM_REC.MANDATORY = NREQ_YES_SYS))
        then
          P_EXCEPTION(0
                     ,'Не указано значение обязательного параметра "' ||
                      PRM_REC.PROMPT || '" отчета "' || RPT_REC.CODE || '"!');
        end if;
        --интерпретируем типы данных и приводим значения
        case PRMS(I).NVAL_TYPE
          when NVAL_TYPE_STR then
            begin
              NDATA_TYPE := NVAL_TYPE_STR_SYS;
              STMP       := PRMS(I).SVAL;
              NTMP       := null;
              DTMP       := null;
            end;
          when NVAL_TYPE_NUMB then
            declare
              NLIST_IDENT number(17); --идентификатор собственного буфера для хранения отмеченных записей
              NLIST_DOC   number(17); --рег. номер документа в собственном буфере
            begin
              NDATA_TYPE := NVAL_TYPE_NUMB_SYS;
              STMP       := null;
              NTMP       := UDO_PKG_SYSW0003_PUBL_UTILS.CONVERT_TO_NUMBER(SSTR   => PRMS(I).SVAL
                                                                         ,NSMART => 1);
              if ((PRMS(I).SVAL is not null) and (NTMP is null))
              then
                P_EXCEPTION(0
                           ,'Переданное значение "' || PRMS(I).SVAL ||
                            '", для параметра "' || PRM_REC.PROMPT ||
                            '" отчета "' || RPT_REC.CODE ||
                            '", не является числом!');
              end if;
              DTMP := null;
              --если числовой параметр привязан к идентификатору отмеченных записей, то заберем эти записи в свой буфер (клиентское приложение должно их там оставить)
              if (PRM_REC.LINKING = NINP_TYPE_SL_IDENT_SYS)
              then
                --сформируем новый идентификатор для собственного буфера
                NLIST_IDENT := GEN_IDENT();
                --добавление списка отмеченных документов в собственный буфер
                for DOC in (select *
                              from SELECTLIST
                             where IDENT = NTMP
                               and authid = SUSER)
                loop
                  --базовое добавление записи списка документов очереди печати отчётов
                  UTL_REPORTQ_LST_BASE_INSERT(NPRN         => NREPORTQ
                                             ,NTYPE        => 0
                                             ,NIDENT       => NLIST_IDENT
                                             ,NDOCUMENT    => DOC.DOCUMENT
                                             ,SUNITCODE    => DOC.UNITCODE
                                             ,SACTIONCODE  => DOC.ACTIONCODE
                                             ,NCATALOG     => DOC.CRN
                                             ,NDOCUMENT1   => DOC.DOCUMENT1
                                             ,SUNITCODE1   => DOC.UNITCODE1
                                             ,SACTIONCODE1 => DOC.ACTIONCODE1
                                             ,NRN          => NLIST_DOC);
                end loop;
                --очистка списка документов отмеченных пользователем
                P_SELECTLIST_CLEAR(NIDENT => NTMP);
                --корректировка параметра
                NTMP := NLIST_IDENT;
              end if;
            end;
          when NVAL_TYPE_BOOL then
            begin
              NDATA_TYPE := NVAL_TYPE_NUMB_SYS;
              STMP       := null;
              NTMP       := UDO_PKG_SYSW0003_PUBL_UTILS.CONVERT_TO_NUMBER(SSTR   => PRMS(I).SVAL
                                                                         ,NSMART => 1);
              if ((NTMP is null) or (NTMP not in (0
                                                 ,1)))
              then
                P_EXCEPTION(0
                           ,'Переданное значение "' || PRMS(I).SVAL ||
                            '", для параметра "' || PRM_REC.PROMPT ||
                            '" отчета "' || RPT_REC.CODE ||
                            '", не является логическим!');
              end if;
              DTMP := null;
            end;
          when NVAL_TYPE_DATE then
            begin
              NDATA_TYPE := NVAL_TYPE_DATE_SYS;
              STMP       := null;
              NTMP       := null;
              DTMP       := JSON_EXT.GET_DATE(JSON('{d:"' || PRMS(I).SVAL || '"}')
                                             ,'d');
            exception
              when others then
                P_EXCEPTION(0
                           ,'Переданное значение - "' || PRMS(I).SVAL ||
                            '", для параметра "' || PRM_REC.PROMPT ||
                            '" отчета "' || RPT_REC.CODE ||
                            '", не является датой!');
            end;
          else
            P_EXCEPTION(0
                       ,'Тип данных "' || PRMS(I).NVAL_TYPE || '" параметра "' ||
                        PRM_REC.PROMPT || '" отчета "' || RPT_REC.CODE ||
                        '" не поддерживается!');
        end case;
        --базовое добавление записи параметра очереди печати отчётов
        UTL_REPORTQ_PRM_BASE_INSERT(NPRN        => NREPORTQ
                                   ,SNAME       => PRMS(I).SNAME
                                   ,NDATA_TYPE  => NDATA_TYPE
                                   ,SSTR_VALUE  => STMP
                                   ,NNUM_VALUE  => NTMP
                                   ,DDATE_VALUE => DTMP
                                   ,NRN         => NREPORTQ_PRM);
      end loop;
    end if;
    --подтверждение автономной транзакции
    commit;
    --отправка сообщения сервису печати
    NPIPE_RC := SYS.DBMS_PIPE.SEND_MESSAGE(SPIPE_NAME
                                          ,0);
    --ошибка
    if (NPIPE_RC not in (0
                        ,1))
    then
      P_EXCEPTION(0
                 ,'Внутренняя ошибка (код %s) отправки собщения серверу печати по каналу "%s"!'
                 ,TO_CHAR(NPIPE_RC)
                 ,SPIPE_NAME);
    end if;
  end;

  --добавление расписания для отчета
  procedure REPORT_ADD_SCHED
  (
    SUSER       varchar2 --пользователь
   ,NREPORT     number --рег. номер отчета
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц)
   ,NSTEP       number --шаг исполнения расписания
   ,DSTART_DATE date --дата начала исполнения расписания
   ,NMAIL       number --доставка по e-mail (0 - нет, 1 - да)
   ,CPRMS       clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
   ,NREPORTSCH  out number --рег. номер сформированной позиции расписания
  ) is
    RPT_REC USERREPORTS%rowtype; --запись отчета
  begin
    --проверим, что есть данные отчета
    if (NREPORT is null)
    then
      P_EXCEPTION(0
                 ,'Не указан отчет для печати!');
    end if;
    --считывание записи отчёта
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --проверим права доступа
    if ((UTL_CHECK_PRIVS(SUSER    => SUSER
                        ,SUNIT    => 'UserReports'
                        ,SACTION  => 'UREP_PRINT_SERV'
                        ,NCOMPANY => RPT_REC.COMPANY
                        ,NCRN     => RPT_REC.CRN) = NHAVE_NO_PRIVS) or
       ((UTL_CHECK_PRIVS(SUSER    => SUSER
                         ,SUNIT    => 'UserReports'
                         ,SACTION  => 'UREP_PRINT'
                         ,NCOMPANY => RPT_REC.COMPANY
                         ,NCRN     => RPT_REC.CRN) = NHAVE_NO_PRIVS)))
    then
      P_EXCEPTION(0
                 ,'У вас нет прав доступа для заказа данного отчета на сервере печати!');
    end if;
    --добавим позицию расписания к отчету
    SCHED_BASE_INSERT(NPRN        => NREPORT
                     ,SUSR        => SUSER
                     ,NSCHED_TYPE => NSCHED_TYPE
                     ,NSTEP       => NSTEP
                     ,DSTART_DATE => DSTART_DATE
                     ,NMAIL       => NMAIL
                     ,CPRMS       => CPRMS
                     ,NRN         => NREPORTSCH);
  end;

  --удаление расписания для отчета
  procedure REPORT_REMOVE_SCHED
  (
    SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NREPORTSCH number --рег. номер удаляемой позиции расписания (null - удаление всех расписаний этого пользователя для отчета)
  ) is
  begin
    --идем по позициям расписаний отчета, относящихся к данному пользователю
    for C in (select T.RN
                from UDO_T_URPT_SRV_SCHED T
               where T.PRN = NREPORT
                 and T.USR = SUSER
                 and ((NREPORTSCH is null) or
                     ((NREPORTSCH is not null) and (T.RN = NREPORTSCH))))
    loop
      SCHED_BASE_DELETE(NRN => C.RN);
    end loop;
  end;

  --выгрузка картинки предпросмотра для отчета
  procedure REPORT_PREVIEW
  (
    NREPORT number --рег. номер отчета
   ,SURL    out varchar2 --URL картинки для предпросмотра
  ) is
    RPT_REC  USERREPORTS%rowtype; --запись отчета
    SURL_CUR varchar2(4000); --URL текущей картинки
    JURLS    JSON_LIST := JSON_LIST(); --коллекция ссылок (JSON-представление)
    SERR     varchar2(4000); --буфер для ошибок
  begin
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => NREPORT);
    --идем по картинкам предпросмотра
    for IMGS in (select T.RN
                   from UDO_T_URPT_SRV_RPTPICT T
                  where T.PRN = RPT_REC.RN
                    and T.PICT is not null
                    and NVL(DBMS_LOB.GETLENGTH(T.PICT)
                           ,0) > 0)
    loop
      --сформируем URL
      SURL_CUR := CONF_GET_PICT_BASE(NRN => IMGS.RN);
      --добавим его в JSON-массив
      if (SURL_CUR is not null)
      then
        JURLS.APPEND(ELEM => SURL_CUR);
      end if;
    end loop;
    --если в коллекции есть URLи - то преобразуем с троку и вернем
    if ((JURLS is not null) and (JURLS.COUNT > 0))
    then
      SURL := JURLS.TO_CHAR;
    else
      --если нет - ошибка
      P_EXCEPTION(0
                 ,'Для отчета не заданы параметры предварительного просмотра!');
    end if;
  exception
    when others then
      SERR := sqlerrm;
      P_EXCEPTION(0
                 ,'Ошибка выгрузки изображения: ' || SERR);
  end;

  --формирование записи параметра позиции очереди
  procedure REPORTQ_PRM_GET
  (
    NPRMQ    number --рег. номер параметра позиции очереди
   ,RPTQ_PRM out REPORTQ_PRM --запись параметра позиции очереди
  ) is
    PRMQ_REC RPTPRTQUEUE_PRM%rowtype; --запись таблицы параметров позиции очереди
    PRM_REC  USERREPORTS_PARAMS%rowtype; --запись таблицы параметров отчета
    RPTQ_REC RPTPRTQUEUE%rowtype; --запись позиции очереди
    RPT_REC  USERREPORTS%rowtype; --запись отчета
  begin
    --параметр записи очереди - считаем из таблицы
    PRMQ_REC := UTL_REPORTQ_PRM_REC(NPRMQ => NPRMQ);
    --запись очереди - считаем из таблицы
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => PRMQ_REC.PRN);
    --параметр отчета - считаем данные из таблицы
    PRM_REC := UTL_REPORT_PRM_REC_BY_NAME(NREPORT   => RPTQ_REC.USER_REPORT
                                         ,SPRM_NAME => PRMQ_REC.NAME
                                         ,NSMART    => 1);
    --считаем данные отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => RPTQ_REC.USER_REPORT
                             ,NSMART  => 1);
    --сформируем запись параметра позиции очереди - рег. номер параметра
    RPTQ_PRM.NRN := PRMQ_REC.RN;
    --рег. номер позиции очереди
    RPTQ_PRM.NPRN := PRMQ_REC.PRN;
    --имя параметра
    RPTQ_PRM.SNAME := PRMQ_REC.NAME;
    --приглашение ко вводу
    RPTQ_PRM.SPROMPT := NVL(PRM_REC.PROMPT
                           ,PRMQ_REC.NAME);
    --тип данных (0 - строка, 1 - число, 2 - дата, 3 - булево)
    case NVL(PRM_REC.DATA_TYPE
        ,NVAL_TYPE_STR_SYS)
      when NVAL_TYPE_STR_SYS then
        RPTQ_PRM.NVAL_TYPE := NVAL_TYPE_STR;
      when NVAL_TYPE_NUMB_SYS then
        RPTQ_PRM.NVAL_TYPE := NVAL_TYPE_NUMB;
      when NVAL_TYPE_CURR_SYS then
        RPTQ_PRM.NVAL_TYPE := NVAL_TYPE_NUMB;
      when NVAL_TYPE_BOOL_SYS then
        RPTQ_PRM.NVAL_TYPE := NVAL_TYPE_BOOL;
      when NVAL_TYPE_DATE_SYS then
        RPTQ_PRM.NVAL_TYPE := NVAL_TYPE_DATE;
      else
        P_EXCEPTION(0
                   ,'Тип данных "' || NVL(PRM_REC.DATA_TYPE
                                         ,NVAL_TYPE_STR_SYS) ||
                    '" параметра "' || NVL(PRM_REC.PROMPT
                                          ,PRMQ_REC.NAME) || '" отчета "' ||
                    NVL(RPT_REC.CODE
                       ,'<НЕ ОПРЕДЕЛЕН>') || '" не поддерживается!');
    end case;
    --значение
    RPTQ_PRM.SVAL := NVL(PRMQ_REC.STR_VALUE
                        ,NVL(TO_CHAR(PRMQ_REC.NUM_VALUE)
                            ,TO_CHAR(PRMQ_REC.DATE_VALUE
                                    ,'yyyy-mm-dd')));
  end;

  --формирование коллекции параметров для позиции очереди
  procedure REPORTQ_PRMS_GET
  (
    NREPORTQ  number --рег. номер позиции очереди
   ,RPTQ_PRMS out REPORTQ_PRMS --коллекция параметров позиции очереди
  ) is
    RPTQ_REC RPTPRTQUEUE%rowtype; --запись позиции очереди
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --инициализируем коллекцию
    RPTQ_PRMS := REPORTQ_PRMS();
    --идем по параметрам позиции очереди
    for C in (select T.RN
                from RPTPRTQUEUE_PRM T
               where T.PRN = RPTQ_REC.RN)
    loop
      RPTQ_PRMS.EXTEND;
      REPORTQ_PRM_GET(NPRMQ    => C.RN
                     ,RPTQ_PRM => RPTQ_PRMS(RPTQ_PRMS.LAST));
    end loop;
  end;

  --формирование записи позиции очереди
  procedure REPORTQ_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
   ,RPTQ     out REPORTQ --запись позиции очереди
  ) is
    RPTQ_REC RPTPRTQUEUE%rowtype; --запись позиции очереди
    RPT_REC  USERREPORTS%rowtype; --запись отчета
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --считаем запись отчета
    RPT_REC := UTL_REPORT_REC(NREPORT => RPTQ_REC.USER_REPORT);
    --сформируем запись позиции очереди - рег. номер позиции очереди
    RPTQ.NRN := RPTQ_REC.RN;
    --рег. номер отчета
    RPTQ.NREPORT := RPT_REC.RN;
    --код позиции очереди
    RPTQ.SCODE := RPT_REC.CODE;
    --наименование позиции очереди
    RPTQ.SNAME := RPT_REC.NAME;
    --описание позиции очереди
    RPTQ.SDESC := CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                       ,NUNITRN => RPT_REC.RN
                                       ,SPRM    => SCONF_USR_REPORT_DESC);
    --тип позиции очереди (0 - CR, 1 - Excel, 2 - OO Calc)
    case RPT_REC.REPORT_TYPE
      when NRPT_TYPE_CRYSTAL_SYS then
        RPTQ.NTYPE := NRPT_TYPE_CRYSTAL;
      when NRPT_TYPE_EXCEL_SYS then
        RPTQ.NTYPE := NRPT_TYPE_EXCEL;
      when NRPT_TYPE_OOCALC_SYS then
        RPTQ.NTYPE := NRPT_TYPE_OOCALC;
      else
        P_EXCEPTION(0
                   ,'Тип "' || F_USERREPORTS_TYPE(RPT_REC.REPORT_TYPE) ||
                    '" отчета "' || RPT_REC.CODE || '" не поддерживается!');
    end case;
    --состояние (0 - поставлено в очередь, 1 - выполнение начато, 2 - завершено успешно, 3 - завершено с ошибками)
    RPTQ.NQUEUE_STATE := RPTQ_REC.STATUS;
    --дата постановки в очередь
    RPTQ.DQUEUE_TS := RPTQ_REC.QUEUE_TIME_STAMP;
    --дата старта формирования
    RPTQ.DSTART_TS := RPTQ_REC.BEGIN_TIME_STAMP;
    --дата окончания формирования
    RPTQ.DFINISH_TS := RPTQ_REC.END_TIME_STAMP;
    --срок исполнения (минут:секунд)
    RPTQ.SEXEC_TIME := LPAD(TRUNC((RPTQ_REC.END_TIME_STAMP -
                                  RPTQ_REC.BEGIN_TIME_STAMP) * (24 * 60))
                           ,2
                           ,'0') || ':' ||
                       LPAD(TRUNC((RPTQ_REC.END_TIME_STAMP -
                                  RPTQ_REC.BEGIN_TIME_STAMP) * (24 * 60 * 60))
                           ,2
                           ,'0');
    --сообщение об ошибке исполнения
    RPTQ.SERR := RPTQ_REC.ERROR_TEXT;
    --состояние избранности
    RPTQ.NFAVOR := REPORT_FAVOR_GET(SUSER   => SUSER
                                   ,NREPORT => RPT_REC.RN);
    --исполнен по расписанию (0 - нет, 1 - да)
    begin
      select T.SCHEDULED
        into RPTQ.NSCHEDULED
        from UDO_T_URPT_SRV_RPTPQ T
       where T.PQ = RPTQ_REC.RN;
    exception
      when NO_DATA_FOUND then
        RPTQ.NSCHEDULED := NSCHEDULED_NO;
    end;
    --состояние отправки по e-mail (0 - отправка не заказывалась, 1 - ожидает отправки, 2 - отправлен успешно, 3 - ошибка отправки)
    begin
      select T.MAILED
        into RPTQ.NMAILED
        from UDO_T_URPT_SRV_RPTPQ T
       where T.PQ = RPTQ_REC.RN;
    exception
      when NO_DATA_FOUND then
        RPTQ.NMAILED := NMAIL_NOT_ORDERED;
    end;
    --параметры исполнения
    REPORTQ_PRMS_GET(NREPORTQ  => RPTQ_REC.RN
                    ,RPTQ_PRMS => RPTQ.PRMS);
  end;

  --формирование коллекции позиций очереди
  procedure REPORTQS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,RPTQS         out REPORTQS --сформированная коллекция позиций очереди
  ) is
    NROW_FROM number(17); --нижняя граница диапазона записей
    NROW_TO   number(17); --верхняя граница диапазона записей
    SSEARCH_  varchar2(4000); --строка поиска подготовленная для добавления в запрос
  begin
    --вычисляем границы диапазона записей
    UTL_CALC_ROWS_LIMITS(NPORTION      => NPORTION
                        ,NPORTION_SIZE => NPORTION_SIZE
                        ,NROW_FROM     => NROW_FROM
                        ,NROW_TO       => NROW_TO);
    --подготовим строку поиска для использования в запросах
    UTL_PREPARE_SEARCH(SSEARCH          => SSEARCH
                      ,SSEARCH_PREPARED => SSEARCH_);
    --инициализируем коллекцию
    RPTQS := REPORTQS();
    --идем по списку позиций очереди печати данной организации, заказнных данным пользователем
    for C in (select ORD.NRN
                from (select ROWNUM NROW
                            ,NRN
                        from (select T.RN NRN
                                from RPTPRTQUEUE T
                                    ,USERREPORTS UR
                               where T.COMPANY = NCOMPANY
                                 and T.AUTHID = SUSER
                                 and T.USER_REPORT = UR.RN(+)
                                 and ((NREPORT is null) or
                                     ((NREPORT is not null) and
                                     (T.USER_REPORT = NREPORT)))
                                 and ((STRINLIKE(UPPER(UR.CODE)
                                                ,UPPER(SSEARCH_)) <> 0) or
                                     (STRINLIKE(UPPER(UR.NAME)
                                                ,UPPER(SSEARCH_)) <> 0) or
                                     (STRINLIKE(UPPER(CONF_GET_PRM_STR_BASE(SUNIT   => 'UserReports'
                                                                            ,NUNITRN => UR.RN
                                                                            ,SPRM    => SCONF_USR_REPORT_DESC))
                                                ,UPPER(SSEARCH_)) <> 0))
                               order by T.QUEUE_TIME_STAMP desc)) ORD
               where ORD.NROW between NROW_FROM and NROW_TO)
    loop
      --инкремент коллекции
      RPTQS.EXTEND;
      --добавим в коллекцию сведения по позиции очереди
      REPORTQ_GET(SUSER    => SUSER
                 ,NREPORTQ => C.NRN
                 ,RPTQ     => RPTQS(RPTQS.LAST));
    end loop;
  end;

  --удаление позиции очереди
  procedure REPORTQ_REMOVE
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) is
    RPTQ_REC RPTPRTQUEUE%rowtype; --запись позиции очереди
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --проверим права доступа на удаление позиции очереди
    if (UTL_CHECK_PRIVS(SUSER   => SUSER
                       ,SUNIT   => 'ReportsPrintQueue'
                       ,SACTION => 'RPTPRTQUEUE_DELETE') = NHAVE_NO_PRIVS)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для удаления позиции очереди!');
    end if;
    --проверка состояния
    if (RPTQ_REC.STATUS not in
       (PKG_RPTPRTQUEUE.STATUS_BEGIN
        ,PKG_RPTPRTQUEUE.STATUS_END_OK
        ,PKG_RPTPRTQUEUE.STATUS_END_ERR))
    then
      P_EXCEPTION(0
                 ,'Не отработанное задание удалять из очереди нельзя!');
    end if;
    --удаление записи из таблицы
    delete from UDO_T_URPT_SRV_RPTPQ T
     where T.PQ = RPTQ_REC.RN;
    delete from RPTPRTQUEUE T
     where T.RN = RPTQ_REC.RN;
    --если что-то не так
    if (sql%notfound)
    then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => RPTQ_REC.RN
                              ,SUNIT_TABLE => 'ReportsPrintQueue');
    end if;
  end;

  --выгрузка готового отчета из позиции очереди
  procedure REPORTQ_DOWNLOAD
  (
    NREPORTQ   number --рег. номер позиции очереди
   ,SFILE_NAME out varchar2 --имя файла
   ,SURL       out varchar2 --URL файла для загрузки
  ) is
    RPTQ_REC   RPTPRTQUEUE%rowtype; --запись позиции очереди
    NRPTQ_FILE RPTPRTQUEUE_RPT.RN%type; --рег. номер готового отчета
    SERR       varchar2(4000); --буфер для ошибок
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --если состояние - не успешное завершение - то не выгружаем
    if (RPTQ_REC.STATUS <> NQUEUE_STATE_OK)
    then
      P_EXCEPTION(0
                 ,'Отчет не может быть выгружен - он не готов или исполнен с ошибками!');
    end if;
    --считаем рег. номер готового отчета
    begin
      select R.RN
        into NRPTQ_FILE
        from RPTPRTQUEUE_RPT R
       where R.PRN = RPTQ_REC.RN;
    exception
      when others then
        P_EXCEPTION(0
                   ,'Не удалось считать данные готового отчета!');
    end;
    --сформируем имя файла
    SFILE_NAME := UTL_REPORTQ_BUILD_FILE_NAME(NREPORTQ => RPTQ_REC.RN);
    --сформируем URL
    SURL := 'PARUS.UDO_PKG_URPT_SRV.UTL_DOWNLOAD?NFILE=' || NRPTQ_FILE ||
            '&NTYPE=1';
  exception
    when others then
      SERR := sqlerrm;
      P_EXCEPTION(0
                 ,'Ошибка выгрузки файла: ' || SERR);
  end;

  --повтор заказа отчета
  procedure REPORTQ_REPEAT
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) is
    RPTQ_REC RPTPRTQUEUE%rowtype; --запись позиции очереди
  begin
    --считаем запись позиции очереди
    RPTQ_REC := UTL_REPORTQ_REC(NREPORTQ => NREPORTQ);
    --проверим, что повторяется отчет, заказанный самим пользователем
    if (RPTQ_REC.AUTHID <> SUSER)
    then
      P_EXCEPTION(0
                 ,'Повторно печатать можно только свой отчёт.');
    end if;
    --проверим права доступа на повтор печати
    if (UTL_CHECK_PRIVS(SUSER   => SUSER
                       ,SUNIT   => 'ReportsPrintQueue'
                       ,SACTION => 'RPTPRTQUEUE_REPEAT') = NHAVE_NO_PRIVS)
    then
      P_EXCEPTION(0
                 ,'У Вас нет прав доступа для повторного заказа отчетности!');
    end if;
    --проверка текущего статуса
    if (RPTQ_REC.STATUS not in
       (PKG_RPTPRTQUEUE.STATUS_QUEUE
        ,PKG_RPTPRTQUEUE.STATUS_END_OK
        ,PKG_RPTPRTQUEUE.STATUS_END_ERR))
    then
      P_EXCEPTION(0
                 ,'Состояние "%s" записи очереди печати отчётов не м.б. установлено, т.к. запись находится в состоянии "%s".'
                 ,F_RPTPRTQUEUE_STATUS(PKG_RPTPRTQUEUE.STATUS_QUEUE)
                 ,F_RPTPRTQUEUE_STATUS(RPTQ_REC.STATUS));
    end if;
    --зачистим предыдущие сформированные данные отчета
    delete from RPTPRTQUEUE_RPT T
     where T.PRN = RPTQ_REC.RN;
    --установим способ заказа и зачистим признак того, что отчет доставлен по E-Mail
    update UDO_T_URPT_SRV_RPTPQ T
       set T.SCHEDULED = NSCHEDULED_NO
          ,T.MAILED    = DECODE(T.MAILED
                               ,NMAIL_NOT_ORDERED
                               ,NMAIL_NOT_ORDERED
                               ,NMAIL_WAIT)
     where T.PQ = RPTQ_REC.RN;
    --перевыставим статус - снова в очередь
    update RPTPRTQUEUE
       set STATUS           = PKG_RPTPRTQUEUE.STATUS_QUEUE
          ,QUEUE_TIME_STAMP = sysdate
          ,BEGIN_TIME_STAMP = null
          ,END_TIME_STAMP   = null
          ,ERROR_TEXT       = null
          ,ERROR_TRACE      = null
          ,SERV_SESSION_ID  = null
     where RN = RPTQ_REC.RN;
    --если повтор не удался
    if (sql%notfound)
    then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => RPTQ_REC.RN
                              ,SUNIT_TABLE => 'ReportsPrintQueue');
    end if;
  end;

  --проверка наличия обновлений очереди
  procedure REPORTQ_CHECK_NEW
  (
    NCOMPANY         number --рег. номер организации
   ,SUSER            varchar2 --пользователь
   ,STIME_STAMP      varchar2 --хронологическая точка отсчета проверки (ГГГГ-ММ-ДД ЧЧ24:МИ:СС), строковое представлениe
   ,NREPORTQ_NEW_CNT out number --количество новых готовых позиций очереди с момента STIME_STAMP
  ) is
    DTIME_STAMP date; --хронологическая точка отсчета проверки (ГГГГ-ММ-ДД ЧЧ24:МИ:СС)
    SERR        varchar2(4000); --буфер для ошибок
  begin
    --конвертируем строковое представление даты в дату
    begin
      DTIME_STAMP := TO_DATE(STIME_STAMP
                            ,'yyyy-mm-dd hh24:mi:ss');
    exception
      when others then
        P_EXCEPTION(0
                   ,'Некорректно указана точка проверки! Укажите дату в формате "ГГГГ-ММ-ДД ЧЧ24:МИ:СС"!');
    end;
    --подсчитаем сколько готовых отчетов (вне зависимости от состояния)
    begin
      select count(T.RN)
        into NREPORTQ_NEW_CNT
        from RPTPRTQUEUE T
       where T.AUTHID = SUSER
         and T.COMPANY = NCOMPANY
         and T.END_TIME_STAMP is not null
         and T.END_TIME_STAMP >= DTIME_STAMP;
    exception
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(0
                   ,'Ошибка проверки обновлений очереди: ' || SERR);
    end;
  end;

  --разбор стандартного ответа сервера (в JSON)
  procedure JSON_PARSE_RESPONSE
  (
    CJSON      clob --данные ответа
   ,NRESP_TYPE out number --тип ответа (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
   ,SRESP_MSG  out varchar2 --сообщение сервера
  ) is
    JRESP JSON;
  begin
    JRESP := JSON(CJSON);
    if (JRESP.EXIST(SRESP_TYPE_KEY))
    then
      if (JRESP.GET(SRESP_TYPE_KEY).GET_STRING = SRESP_TYPE_VAL)
      then
        if ((JRESP.EXIST(SRESP_STATE_KEY)) and (JRESP.EXIST(SRESP_MSG_KEY)))
        then
          NRESP_TYPE := JRESP.GET(SRESP_STATE_KEY).GET_NUMBER;
          SRESP_MSG  := JRESP.GET(SRESP_MSG_KEY).GET_STRING;
        else
          NRESP_TYPE := null;
          SRESP_MSG  := null;
        end if;
      else
        NRESP_TYPE := null;
        SRESP_MSG  := null;
      end if;
    else
      NRESP_TYPE := null;
      SRESP_MSG  := null;
    end if;
  exception
    when others then
      NRESP_TYPE := null;
      SRESP_MSG  := null;
  end;

  --аутентификация в сервисе (ответ в JSON)
  function JSON_SERVICE_LOGIN
  (
    SUSER                     varchar2 --пользователь
   ,SPASSWORD                 varchar2 --пароль
   ,SCOMPANY                  varchar2 --наименование организации
   ,SSESSION_CLIENT           varchar2 := null --идентификатор сессии сформированный клиентом
   ,SEXPECTED_SERVICE_VERSION varchar2 := null --ожидаемая клиентом версия сервиса
  ) return clob is
    SSESSION varchar2(80); --идентификатор сессии
    NCOMPANY COMPANIES.RN%type; --рег. номер организации
    J        JSON; --JSON ответ (объект)
    CJSON    clob; --JSON ответ (текст)
    SERR     varchar2(4000); --буфер для ошибок
  begin
    --создаем сессию
    SERVICE_LOGIN(SUSER                     => SUSER
                 ,SPASSWORD                 => SPASSWORD
                 ,SCOMPANY                  => SCOMPANY
                 ,SSESSION_CLIENT           => SSESSION_CLIENT
                 ,SEXPECTED_SERVICE_VERSION => SEXPECTED_SERVICE_VERSION
                 ,SSESSION                  => SSESSION
                 ,NCOMPANY                  => NCOMPANY);
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --идентификатор сессии
    J.PUT(PAIR_NAME  => 'SSESSION'
         ,PAIR_VALUE => SSESSION);
    --рег. номер организации
    J.PUT(PAIR_NAME  => 'NCOMPANY'
         ,PAIR_VALUE => NCOMPANY);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --завершение сеанса работы с сервисом (ответ в JSON)
  function JSON_SERVICE_LOGOUT(SSESSION varchar2 --идентификатор сессии
                               ) return clob is
    SERR varchar2(4000); --буфер для ошибок
  begin
    --завершаем сессию
    SERVICE_LOGOUT(SSESSION => SSESSION);
    --вернем ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => SSESSION);
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --валидация сеанса работы с сервисом (ответ в JSON)
  function JSON_SERVICE_SESSION_CHECK(SSESSION varchar2 --идентификатор сессии
                                      ) return clob is
    SERR varchar2(4000); --буфер для ошибок
  begin
    --проверим сессию
    SERVICE_SESSION_CHECK(SUSER    => null
                         ,SSESSION => SSESSION);
    --вернем ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => SSESSION);
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --проверка активности сервиса (ответ в JSON)
  function JSON_SERVICE_ACTIVE_CHECK return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    SERR  varchar2(4000); --буфер для ошибок
  begin
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --признак активности
    J.PUT(PAIR_NAME  => 'NSTATE'
         ,PAIR_VALUE => SERVICE_ACTIVE_CHECK());
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --считывание строкового параметра сиситемы (ответ в JSON)
  function JSON_SERVICE_OPTION_GET_STR
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    SERR  varchar2(4000); --буфер для ошибок
  begin
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --код параметра
    J.PUT(PAIR_NAME  => 'SOPTION'
         ,PAIR_VALUE => SOPTION);
    --строковое значение
    J.PUT(PAIR_NAME  => 'SSTR_VALUE'
         ,PAIR_VALUE => SERVICE_OPTION_GET_STR(NCOMPANY => NCOMPANY
                                              ,SUSER    => SUSER
                                              ,SOPTION  => SOPTION));
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --считывание числового параметра сиситемы (ответ в JSON)
  function JSON_SERVICE_OPTION_GET_NUM
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    SERR  varchar2(4000); --буфер для ошибок
  begin
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --код параметра
    J.PUT(PAIR_NAME  => 'SOPTION'
         ,PAIR_VALUE => SOPTION);
    --строковое значение
    J.PUT(PAIR_NAME  => 'NNUM_VALUE'
         ,PAIR_VALUE => SERVICE_OPTION_GET_NUM(NCOMPANY => NCOMPANY
                                              ,SUSER    => SUSER
                                              ,SOPTION  => SOPTION));
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --считывание датского параметра сиситемы (ответ в JSON)
  function JSON_SERVICE_OPTION_GET_DATE
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SOPTION  varchar2 --код параметра
  ) return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    SERR  varchar2(4000); --буфер для ошибок
  begin
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --код параметра
    J.PUT(PAIR_NAME  => 'SOPTION'
         ,PAIR_VALUE => SOPTION);
    --строковое значение
    J.PUT(PAIR_NAME  => 'DDATE_VALUE'
         ,PAIR_VALUE => SERVICE_OPTION_GET_DATE(NCOMPANY => NCOMPANY
                                               ,SUSER    => SUSER
                                               ,SOPTION  => SOPTION));
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --считывание списка организаций (ответ в JSON)
  function JSON_SERVICE_COMPANYS_GET(SUSER varchar2 --пользователь
                                     ) return clob is
    CMPNS  COMPANYS; --коллекция организаций
    J      JSON; --JSON ответ (объект)
    CJSON  clob; --JSON ответ (текст)
    JCMPN  JSON; --JSON представление организации (объект)
    JCMPNS JSON_LIST; --JSON список организаций (объект)
    SERR   varchar2(4000); --буфер для ошибок
  begin
    --считаем список организаций
    SERVICE_COMPANYS_GET(SUSER => SUSER
                        ,CMPNS => CMPNS);
    --инициализируем ответ
    J      := JSON();
    JCMPNS := JSON_LIST();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --пройдем по списку и сформируем ответ
    if ((CMPNS is not null) and (CMPNS.COUNT > 0))
    then
      for I in CMPNS.FIRST .. CMPNS.LAST
      loop
        --сформируем JSON-представление организации
        JCMPN := JSON();
        JCMPN.PUT(PAIR_NAME  => 'NRN'
                 ,PAIR_VALUE => CMPNS(I).NRN);
        JCMPN.PUT(PAIR_NAME  => 'SNAME'
                 ,PAIR_VALUE => CMPNS(I).SNAME);
        JCMPN.PUT(PAIR_NAME  => 'SFULL_NAME'
                 ,PAIR_VALUE => CMPNS(I).SFULL_NAME);
        --добавим в массив
        JCMPNS.APPEND(ELEM => JCMPN.TO_JSON_VALUE());
      end loop;
    end if;
    --добавим список организаций в ответ
    J.PUT(PAIR_NAME  => 'COMPANIES'
         ,PAIR_VALUE => JCMPNS);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --запрос детальной информации о разделе (в JSON)
  function JSON_UNIT_GET
  (
    NCOMPANY number --рег. номер организации
   ,SUSER    varchar2 --пользователь
   ,SSEARCH  varchar2 --строка поиска (null - не искать)
   ,NUNIT    number --рег. номер раздела
  ) return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    SERR  varchar2(4000); --буфер для ошибок
    UNT   UNIT; --запись раздела
  begin
    --сформируем запись раздела
    UNIT_GET(NCOMPANY => NCOMPANY
            ,SUSER    => SUSER
            ,SSEARCH  => SSEARCH
            ,NUNIT    => NUNIT
            ,UNT      => UNT);
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --рег. номер
    J.PUT(PAIR_NAME  => 'NRN'
         ,PAIR_VALUE => UNT.NRN);
    --мнемокод
    J.PUT(PAIR_NAME  => 'SCODE'
         ,PAIR_VALUE => UNT.SCODE);
    --наименование
    J.PUT(PAIR_NAME  => 'SNAME'
         ,PAIR_VALUE => UNT.SNAME);
    --количество привязанных отчетов
    J.PUT(PAIR_NAME  => 'NREPORTS'
         ,PAIR_VALUE => UNT.NREPORTS);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --запрос списка разделов, имеющих привязанные отчеты (в JSON)
  function JSON_UNITS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
  ) return clob is
    J          JSON; --JSON ответ (объект)
    JUNTS      JSON_LIST; --JSON список разделов (объект)
    JUNT       JSON; --JSON раздел (объект)
    CUNT       clob; --JSON раздел (текст)
    CJSON      clob; --JSON ответ (текст)
    SERR       varchar2(4000); --буфер для ошибок
    UNTS       UNITS; --коллекция разделов
    NRESP_TYPE number(1); --тип ответа сервера
    SRESP_MSG  varchar2(4000); --буфер для ответа сервера
  begin
    --сформируем список разделов
    UNITS_GET(NCOMPANY      => NCOMPANY
             ,SUSER         => SUSER
             ,SSEARCH       => SSEARCH
             ,NPORTION      => NPORTION
             ,NPORTION_SIZE => NPORTION_SIZE
             ,UNTS          => UNTS);
    --инициализируем объекты
    J     := JSON();
    JUNTS := JSON_LIST();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --пройдем по списку и сформируем ответ
    if ((UNTS is not null) and (UNTS.COUNT > 0))
    then
      for I in UNTS.FIRST .. UNTS.LAST
      loop
        --соберем данные по текущему разделу в буфер (в JSON формате)
        DBMS_LOB.CREATETEMPORARY(LOB_LOC => CUNT
                                ,CACHE   => false);
        CUNT := JSON_UNIT_GET(NCOMPANY => NCOMPANY
                             ,SUSER    => SUSER
                             ,SSEARCH  => SSEARCH
                             ,NUNIT    => UNTS(I).NRN);
        --проверим буфер на наличие ошибок
        JSON_PARSE_RESPONSE(CJSON      => CUNT
                           ,NRESP_TYPE => NRESP_TYPE
                           ,SRESP_MSG  => SRESP_MSG);
        --если ошибок нет - добавляем раздел в объект списка для ответа
        if (NRESP_TYPE is null)
        then
          --транслируем полученное текстовое JSON представление в объект
          JUNT := JSON(CUNT);
          --добавляем раздел в результирующий список
          JUNTS.APPEND(ELEM => JUNT.TO_JSON_VALUE());
        else
          --иначе выдаем ошибку
          P_EXCEPTION(0
                     ,SRESP_MSG);
        end if;
      end loop;
    end if;
    --сформируем в ответе список разделов
    J.PUT(PAIR_NAME  => 'UNITS'
         ,PAIR_VALUE => JUNTS);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --запрос детальной информации об отчете (в JSON)
  function JSON_REPORT_GET
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
   ,NINFO   number := 0 --признак выдачи информации (0 - полная, 1 - краткая)
  ) return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    LU    JSON; --JSON представление записи привязки отчета к разделу
    LUS   JSON_LIST := JSON_LIST(); --JSON представление коллекции привязок отчета к разделам
    SERR  varchar2(4000); --буфер для ошибок
    RPT   REPORT; --запись отчета
  begin
    --сформируем запись отчета
    REPORT_GET(SUSER   => SUSER
              ,NREPORT => NREPORT
              ,RPT     => RPT);
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --сначала краткая общая информация - рег. номер
    J.PUT(PAIR_NAME  => 'NRN'
         ,PAIR_VALUE => RPT.NRN);
    --мнемокод
    J.PUT(PAIR_NAME  => 'SCODE'
         ,PAIR_VALUE => RPT.SCODE);
    --наименование
    J.PUT(PAIR_NAME  => 'SNAME'
         ,PAIR_VALUE => RPT.SNAME);
    --описание
    J.PUT(PAIR_NAME  => 'SDESC'
         ,PAIR_VALUE => RPT.SDESC);
    --тип отчета
    J.PUT(PAIR_NAME  => 'NRPT_TYPE'
         ,PAIR_VALUE => RPT.NRPT_TYPE);
    --"избранность" отчета
    J.PUT(PAIR_NAME  => 'NFAVOR'
         ,PAIR_VALUE => RPT.NFAVOR);
    --количество отчетов в очереди
    J.PUT(PAIR_NAME  => 'NCNTQ'
         ,PAIR_VALUE => RPT.NCNTQ);
    --наличие предпросмотра
    J.PUT(PAIR_NAME  => 'NPREVIEW'
         ,PAIR_VALUE => RPT.NPREVIEW);
    --наличие расписания
    J.PUT(PAIR_NAME  => 'NSCHEDULED'
         ,PAIR_VALUE => RPT.NSCHEDULED);
    --возможность доставки отчета по e-mail
    J.PUT(PAIR_NAME  => 'NMAIL_ENABLED'
         ,PAIR_VALUE => RPT.NMAIL_ENABLED);
    --адрес e-mail для доставки отчета
    J.PUT(PAIR_NAME  => 'SMAIL'
         ,PAIR_VALUE => RPT.SMAIL);
    --список привязок к разделам
    if ((RPT.LUS is not null) and (RPT.LUS.COUNT > 0))
    then
      for I in RPT.LUS.FIRST .. RPT.LUS.LAST
      loop
        LU := JSON();
        LU.PUT(PAIR_NAME  => 'NRN'
              ,PAIR_VALUE => RPT.LUS(I).NRN);
        LU.PUT(PAIR_NAME  => 'NPRN'
              ,PAIR_VALUE => RPT.LUS(I).NPRN);
        LU.PUT(PAIR_NAME  => 'SNAME'
              ,PAIR_VALUE => RPT.LUS(I).SNAME);
        LU.PUT(PAIR_NAME  => 'NUNIT'
              ,PAIR_VALUE => RPT.LUS(I).NUNIT);
        LU.PUT(PAIR_NAME  => 'SUNIT_CODE'
              ,PAIR_VALUE => RPT.LUS(I).SUNIT_CODE);
        LU.PUT(PAIR_NAME  => 'SUNIT_NAME'
              ,PAIR_VALUE => RPT.LUS(I).SUNIT_NAME);
        LUS.APPEND(ELEM => LU.TO_JSON_VALUE());
      end loop;
    end if;
    J.PUT(PAIR_NAME  => 'LUS'
         ,PAIR_VALUE => LUS);
    --сверстаем ответ в зависимости от режима работы
    case NINFO
    --краткая информация
      when NINFO_BRIEF then
        begin
          null; --в ответе уже достаточно данных
        end;
        --полная информация
      when NINFO_FULL then
        declare
          PRM  JSON; --JSON представление параметра отчета
          PRMS JSON_LIST := JSON_LIST(); --JSON представление коллекции параметров отчета
          SCH  JSON; --JSON представление расписания отчета
          SCHS JSON_LIST := JSON_LIST(); --JSON представление коллекции расписаний отчета
        begin
          --соберем сведения о расписаниях отчета
          if ((RPT.SCHS is not null) and (RPT.SCHS.COUNT > 0))
          then
            for I in RPT.SCHS.FIRST .. RPT.SCHS.LAST
            loop
              SCH := JSON();
              SCH.PUT(PAIR_NAME  => 'NRN'
                     ,PAIR_VALUE => RPT.SCHS(I).NRN);
              SCH.PUT(PAIR_NAME  => 'NPRN'
                     ,PAIR_VALUE => RPT.SCHS(I).NPRN);
              SCH.PUT(PAIR_NAME  => 'NSCHED_TYPE'
                     ,PAIR_VALUE => RPT.SCHS(I).NSCHED_TYPE);
              SCH.PUT(PAIR_NAME  => 'NSTEP'
                     ,PAIR_VALUE => RPT.SCHS(I).NSTEP);
              SCH.PUT(PAIR_NAME  => 'DSTART_DATE'
                     ,PAIR_VALUE => TO_CHAR(RPT.SCHS(I).DSTART_DATE
                                           ,'yyyy-mm-dd hh24:mi:ss'));
              SCH.PUT(PAIR_NAME  => 'NMAIL'
                     ,PAIR_VALUE => RPT.SCHS(I).NMAIL);
              SCHS.APPEND(ELEM => SCH.TO_JSON_VALUE());
            end loop;
          end if;
          --добавим в ответ сведения о расписаниях отчета
          J.PUT(PAIR_NAME  => 'SCHS'
               ,PAIR_VALUE => SCHS);
          --соберем сведения о параметрах отчета
          if ((RPT.PRMS is not null) and (RPT.PRMS.COUNT > 0))
          then
            for I in RPT.PRMS.FIRST .. RPT.PRMS.LAST
            loop
              PRM := JSON();
              PRM.PUT(PAIR_NAME  => 'NRN'
                     ,PAIR_VALUE => RPT.PRMS(I).NRN);
              PRM.PUT(PAIR_NAME  => 'NPRN'
                     ,PAIR_VALUE => RPT.PRMS(I).NPRN);
              PRM.PUT(PAIR_NAME  => 'SNAME'
                     ,PAIR_VALUE => RPT.PRMS(I).SNAME);
              PRM.PUT(PAIR_NAME  => 'SPROMPT'
                     ,PAIR_VALUE => RPT.PRMS(I).SPROMPT);
              PRM.PUT(PAIR_NAME  => 'NREQ'
                     ,PAIR_VALUE => RPT.PRMS(I).NREQ);
              PRM.PUT(PAIR_NAME  => 'NVAL_TYPE'
                     ,PAIR_VALUE => RPT.PRMS(I).NVAL_TYPE);
              PRM.PUT(PAIR_NAME  => 'NINP_TYPE'
                     ,PAIR_VALUE => RPT.PRMS(I).NINP_TYPE);
              PRM.PUT(PAIR_NAME  => 'SPREV_VAL'
                     ,PAIR_VALUE => RPT.PRMS(I).SPREV_VAL);
              PRM.PUT(PAIR_NAME  => 'SDEF_VAL'
                     ,PAIR_VALUE => RPT.PRMS(I).SDEF_VAL);
              PRMS.APPEND(ELEM => PRM.TO_JSON_VALUE());
            end loop;
          end if;
          --добавим в ответ сведения о параметрах отчета
          J.PUT(PAIR_NAME  => 'PRMS'
               ,PAIR_VALUE => PRMS);
        end;
      else
        P_EXCEPTION(0
                   ,'Значение признака выдачи информации "' || NINFO ||
                    '" не поддерживается процедурой сбора данных об отчетах!');
    end case;
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --запрос списка отчетов (в JSON)
  function JSON_REPORTS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NUNIT         number --раздел привязки (null - по всем, 0 - не имеющие привязки, рег. номер отчета)
   ,NFAVOR        number --признак выдачи избранных отчетов (null - все, 0 - не входящие в избранное, 1 - входящие в избранное)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
   ,NRPT_ORDER    number --порядок сортировки (0 - по наименованию, 1 - по разделам)
  ) return clob is
    J          JSON; --JSON ответ (объект)
    JRPTS      JSON_LIST; --JSON список отчетов (объект)
    JRPT       JSON; --JSON отчет (объект)
    CRPT       clob; --JSON отчет (текст)
    CJSON      clob; --JSON ответ (текст)
    SERR       varchar2(4000); --буфер для ошибок
    RPTS       REPORTS; --коллекция отчетов
    NRESP_TYPE number(1); --тип ответа сервера
    SRESP_MSG  varchar2(4000); --буфер для ответа сервера
  begin
    --сформируем список отчетов
    REPORTS_GET(NCOMPANY      => NCOMPANY
               ,SUSER         => SUSER
               ,NUNIT         => NUNIT
               ,NFAVOR        => NFAVOR
               ,SSEARCH       => SSEARCH
               ,NPORTION      => NPORTION
               ,NPORTION_SIZE => NPORTION_SIZE
               ,NRPT_ORDER    => NRPT_ORDER
               ,RPTS          => RPTS);
    --инициализируем объекты
    J     := JSON();
    JRPTS := JSON_LIST();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --пройдем по списку и сформируем ответ
    if ((RPTS is not null) and (RPTS.COUNT > 0))
    then
      for I in RPTS.FIRST .. RPTS.LAST
      loop
        --соберем данные по текущему отчету в буфер (в JSON формате)
        DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRPT
                                ,CACHE   => false);
        CRPT := JSON_REPORT_GET(SUSER   => SUSER
                               ,NREPORT => RPTS(I).RPT.NRN
                               ,NINFO   => NINFO_BRIEF);
        --проверим буфер на наличие ошибок
        JSON_PARSE_RESPONSE(CJSON      => CRPT
                           ,NRESP_TYPE => NRESP_TYPE
                           ,SRESP_MSG  => SRESP_MSG);
        --если ошибок нет - добавляем отчет в объект списка для ответа
        if (NRESP_TYPE is null)
        then
          --транслируем полученное текстовое JSON представление в объект
          JRPT := JSON(CRPT);
          --если сортировка по разделам, то дополним объект отчета данными о разделе
          if (NRPT_ORDER = NRPT_ORDER_UNIT)
          then
            JRPT.PUT(PAIR_NAME  => 'NUNIT'
                    ,PAIR_VALUE => RPTS(I).NUNIT);
            JRPT.PUT(PAIR_NAME  => 'SUNIT_CODE'
                    ,PAIR_VALUE => RPTS(I).SUNIT_CODE);
            JRPT.PUT(PAIR_NAME  => 'SUNIT_NAME'
                    ,PAIR_VALUE => RPTS(I).SUNIT_NAME);
          end if;
          --добавляем отчет в результирующий список
          JRPTS.APPEND(ELEM => JRPT.TO_JSON_VALUE());
        else
          --иначе выдаем ошибку
          P_EXCEPTION(0
                     ,SRESP_MSG);
        end if;
      end loop;
    end if;
    --сформируем в ответе список отчетов
    J.PUT(PAIR_NAME  => 'REPORTS'
         ,PAIR_VALUE => JRPTS);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --постановка отчета в очередь (ответ о результате постановки в JSON)
  function JSON_REPORT_PUT
  (
    NCOMPANY   number --рег. номер организации
   ,SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NSCHEDULED number --признак исполнения по расписанию (0 - нет, 1 - да)
   ,NMAIL      number --признак отправки по e-mail (0 - нет, 1 - да)
   ,CPRMS      clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
  ) return clob is
    NREPORTQ RPTPRTQUEUE.RN%type; --рег. номер сформированной позиции очереди
    PRMS     REPORTQ_PRMS; --разобранные параметры отчета
    JPRMS    JSON_LIST; --JSON описание параметров отчета (объект)
    JPRM     JSON; --JSON описание парамета отчета (объект)
    SERR     varchar2(4000); --буфер для ошибок
  begin
    --инициализируем коллекцию параметров
    PRMS := REPORTQ_PRMS();
    --разберем параметры в коллекцию (если они есть)
    if ((CPRMS is not null) and (DBMS_LOB.GETLENGTH(CPRMS) > 0))
    then
      JPRMS := JSON_LIST(CPRMS);
      if (JPRMS.COUNT > 0)
      then
        for I in 1 .. JPRMS.COUNT
        loop
          JPRM := JSON(JPRMS.GET(I));
          if ((JPRM.EXIST(SREQ_NAME_KEY)) and
             (JPRM.GET(SREQ_NAME_KEY).IS_STRING) and
             (JPRM.EXIST(SREQ_VAL_TYPE_KEY)) and
             ((JPRM.GET(SREQ_VAL_TYPE_KEY).IS_NUMBER) or
             (JPRM.GET(SREQ_VAL_TYPE_KEY).IS_STRING)) and
             (JPRM.EXIST(SREQ_VAL_KEY)) and
             ((JPRM.GET(SREQ_VAL_KEY).IS_STRING) or
             (JPRM.GET(SREQ_VAL_KEY).IS_NUMBER)))
          then
            PRMS.EXTEND();
            PRMS(PRMS.LAST).SNAME := JPRM.GET(SREQ_NAME_KEY).GET_STRING;
            PRMS(PRMS.LAST).NVAL_TYPE := NVL(JPRM.GET(SREQ_VAL_TYPE_KEY)
                                             .GET_NUMBER
                                            ,TO_NUMBER(JPRM.GET(SREQ_VAL_TYPE_KEY)
                                                       .GET_STRING));
            PRMS(PRMS.LAST).SVAL := JPRM.GET(SREQ_VAL_KEY).GET_STRING;
          else
            P_EXCEPTION(0
                       ,'Параметр #' || TO_CHAR(I) || ' отчета (RN:' ||
                        TO_CHAR(NREPORT) || ') имеет некорректный формат!');
          end if;
        end loop;
      end if;
    end if;
    --поместим отчет в очередь
    REPORT_PUT(NCOMPANY   => NCOMPANY
              ,SUSER      => SUSER
              ,NREPORT    => NREPORT
              ,NSCHEDULED => NSCHEDULED
              ,NMAIL      => NMAIL
              ,PRMS       => PRMS
              ,NREPORTQ   => NREPORTQ);
    --вернем ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => TO_CHAR(NREPORTQ));
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --формирование расписания отчета (ответ о результате формирования в JSON)
  function JSON_REPORT_ADD_SCHED
  (
    SUSER       varchar2 --пользователь
   ,NREPORT     number --рег. номер отчета
   ,NSCHED_TYPE number --тип расписания (0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц)
   ,NSTEP       number --шаг исполнения расписания
   ,SSTART_DATE varchar2 --дата начала исполнения расписания (ГГГГ-ММ-ДД ЧЧ24:МИ:СС), строковое представлениe
   ,NMAIL       number --доставка по e-mail (0 - нет, 1 - да)
   ,CPRMS       clob --JSON описание параметров печати ([{SNAME: <ИМЯ_ПАРАМЕТРА>, NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА - 0 - строка, 1 - число, 2 - дата, 3 - булево>,SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0>}])
  ) return clob is
    NREPORTSCH  UDO_T_URPT_SRV_SCHED.RN%type; --рег. номер сформированной позиции расписания
    DSTART_DATE date; --дата начала исполнения расписания
    SERR        varchar2(4000); --буфер для ошибок
  begin
    --конвертируем строковое представление даты в дату
    begin
      DSTART_DATE := TO_DATE(SSTART_DATE
                            ,'yyyy-mm-dd hh24:mi:ss');
    exception
      when others then
        P_EXCEPTION(0
                   ,'Некорректно указана дата начала исполнения расписания! Укажите дату в формате "ГГГГ-ММ-ДД ЧЧ24:МИ:СС"!');
    end;
    --поместим отчет в очередь
    REPORT_ADD_SCHED(SUSER       => SUSER
                    ,NREPORT     => NREPORT
                    ,NSCHED_TYPE => NSCHED_TYPE
                    ,NSTEP       => NSTEP
                    ,DSTART_DATE => DSTART_DATE
                    ,NMAIL       => NMAIL
                    ,CPRMS       => CPRMS
                    ,NREPORTSCH  => NREPORTSCH);
    --вернем ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => TO_CHAR(NREPORTSCH));
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --удаление расписания отчета (ответ о результате постановки в JSON)
  function JSON_REPORT_REMOVE_SCHED
  (
    SUSER      varchar2 --пользователь
   ,NREPORT    number --рег. номер отчета
   ,NREPORTSCH number --рег. номер удаляемой позиции расписания (null - удаление всех расписаний этого пользователя для отчета)
  ) return clob is
    SERR varchar2(4000); --буфер для ошибок
  begin
    --удалим запись расписания
    REPORT_REMOVE_SCHED(SUSER      => SUSER
                       ,NREPORT    => NREPORT
                       ,NREPORTSCH => NREPORTSCH);
    --вернем ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => '');
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --выгрузка картинки предпросмотра для отчета (ответ о результате в JSON)
  function JSON_REPORT_PREVIEW(NREPORT number --рег. номер отчета
                               ) return clob is
    SURL varchar2(4000); --URL готового отчета для скачивания
    SERR varchar2(4000); --буфер для ошибок
  begin
    begin
      --выгрузим картинку предпросмотра
      REPORT_PREVIEW(NREPORT => NREPORT
                    ,SURL    => SURL);
    exception
      --если не удалось - вернем ответ об ошибке
      when others then
        SERR := sqlerrm;
        return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                            ,NRESP_KIND => NRESP_KIND_JSON
                            ,SRESP_MSG  => SERR);
    end;
    --если удалось и пришел не пустой URL - вернем его
    if (SURL is not null)
    then
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SURL);
    else
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => 'Не удалось определить URL для предварительного просмотра отчета!');
    end if;
  end;

  --изменение состосния "избранности" отчета (ответ о результате постановки в JSON)
  function JSON_REPORT_FAVOR_TOGGLE
  (
    SUSER   varchar2 --пользователь
   ,NREPORT number --рег. номер отчета
  ) return clob is
    NFAVOR number(1); --состояние "избранности" после выполнения действия
    SERR   varchar2(4000); --буфер для ошибок
  begin
    --поместим отчет в очередь
    REPORT_FAVOR_TOGGLE(SUSER   => SUSER
                       ,NREPORT => NREPORT
                       ,NFAVOR  => NFAVOR);
    --вернем ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => TO_CHAR(NFAVOR));
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --формирование списка записей словаря параметра отчета
  function JSON_REPORT_PRM_DICT_RECS_GET
  (
    SUSER         varchar2 --пользователь
   ,NPRM          number --рег. номер параметра отчета
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
  ) return clob is
    J          JSON; --JSON ответ (объект)
    CJSON      clob; --JSON ответ (текст)
    JRECS      JSON_LIST; --JSON список записей словаря (объект)
    JREC       JSON; --JSON запись словаря (объект)
    SERR       varchar2(4000); --буфер для ошибок
    SUNIT_CODE varchar2(1000); --код раздела
    SUNIT_NAME varchar2(4000); --наименование раздела
    DCT_RECS   DICT_RECS; --сформированная коллекция записей словаря
  begin
    --сформируем данные
    REPORT_PRM_DICT_RECS_GET(SUSER         => SUSER
                            ,NPRM          => NPRM
                            ,SSEARCH       => SSEARCH
                            ,NPORTION      => NPORTION
                            ,NPORTION_SIZE => NPORTION_SIZE
                            ,SUNIT_CODE    => SUNIT_CODE
                            ,SUNIT_NAME    => SUNIT_NAME
                            ,DCT_RECS      => DCT_RECS);
    --инициализируем объекты
    J     := JSON();
    JRECS := JSON_LIST();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --пройдем по списку записей и сформируем ответ
    if ((DCT_RECS is not null) and (DCT_RECS.COUNT > 0))
    then
      for I in DCT_RECS.FIRST .. DCT_RECS.LAST
      loop
        --соберем представление записи в JSON-объект
        JREC := JSON();
        --рег. номер
        JREC.PUT(PAIR_NAME  => 'NRN'
                ,PAIR_VALUE => DCT_RECS(I).NRN);
        --код
        JREC.PUT(PAIR_NAME  => 'SCODE'
                ,PAIR_VALUE => DCT_RECS(I).SCODE);
        --описание
        JREC.PUT(PAIR_NAME  => 'SDESC'
                ,PAIR_VALUE => DCT_RECS(I).SDESC);
        --возвращаемое значение
        JREC.PUT(PAIR_NAME  => 'SVAL'
                ,PAIR_VALUE => DCT_RECS(I).SVAL);
        --добавляем отчет в результирующий список
        JRECS.APPEND(ELEM => JREC.TO_JSON_VALUE());
      end loop;
    end if;
    --сформируем в ответе код раздела
    J.PUT(PAIR_NAME  => 'SUNIT_CODE'
         ,PAIR_VALUE => SUNIT_CODE);
    --сформируем в ответе наименование раздела
    J.PUT(PAIR_NAME  => 'SUNIT_NAME'
         ,PAIR_VALUE => SUNIT_NAME);
    --сформируем в ответе список отчетов
    J.PUT(PAIR_NAME  => 'DICT_RECS'
         ,PAIR_VALUE => JRECS);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --запрос детальной информации о позиции очереди (в JSON)
  function JSON_REPORTQ_GET
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
   ,NINFO    number := 0 --признак выдачи информации (0 - полная, 1 - краткая)
  ) return clob is
    J     JSON; --JSON ответ (объект)
    CJSON clob; --JSON ответ (текст)
    SERR  varchar2(4000); --буфер для ошибок
    RPTQ  REPORTQ; --запись позиции очереди
  begin
    --сформируем запись позиции очереди
    REPORTQ_GET(SUSER    => SUSER
               ,NREPORTQ => NREPORTQ
               ,RPTQ     => RPTQ);
    --инициализируем ответ
    J := JSON();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --сначала краткая общая информация - рег. номер
    J.PUT(PAIR_NAME  => 'NRN'
         ,PAIR_VALUE => RPTQ.NRN);
    --рег. номер отчета
    J.PUT(PAIR_NAME  => 'NREPORT'
         ,PAIR_VALUE => RPTQ.NREPORT);
    --мнемокод
    J.PUT(PAIR_NAME  => 'SCODE'
         ,PAIR_VALUE => RPTQ.SCODE);
    --наименование
    J.PUT(PAIR_NAME  => 'SNAME'
         ,PAIR_VALUE => RPTQ.SNAME);
    --описание
    J.PUT(PAIR_NAME  => 'SDESC'
         ,PAIR_VALUE => RPTQ.SDESC);
    --тип отчета
    J.PUT(PAIR_NAME  => 'NTYPE'
         ,PAIR_VALUE => RPTQ.NTYPE);
    --статус
    J.PUT(PAIR_NAME  => 'NQUEUE_STATE'
         ,PAIR_VALUE => RPTQ.NQUEUE_STATE);
    --дата постановки в очередь
    J.PUT(PAIR_NAME  => 'DQUEUE_TS'
         ,PAIR_VALUE => TO_CHAR(RPTQ.DQUEUE_TS
                               ,'yyyy-mm-dd hh24:mi:ss'));
    --признак "избранности"
    J.PUT(PAIR_NAME  => 'NFAVOR'
         ,PAIR_VALUE => RPTQ.NFAVOR);
    --признак исполнения по расписнию
    J.PUT(PAIR_NAME  => 'NSCHEDULED'
         ,PAIR_VALUE => RPTQ.NSCHEDULED);
    --состояние отправки по e-mail
    J.PUT(PAIR_NAME  => 'NMAILED'
         ,PAIR_VALUE => RPTQ.NMAILED);
    --сверстаем ответ в зависимости от режима работы
    case NINFO
    --краткая информация
      when NINFO_BRIEF then
        begin
          null; --в ответе уже достаточно данных
        end;
        --полная информация
      when NINFO_FULL then
        declare
          PRMQ  JSON; --JSON представление параметра позиции очереди
          PRMQS JSON_LIST := JSON_LIST(); --JSON представление коллекции параметров позиции очереди
        begin
          --время начала обработки
          J.PUT(PAIR_NAME  => 'DSTART_TS'
               ,PAIR_VALUE => TO_CHAR(RPTQ.DSTART_TS
                                     ,'yyyy-mm-dd hh24:mi:ss'));
          --вермя завершения обработки
          J.PUT(PAIR_NAME  => 'DFINISH_TS'
               ,PAIR_VALUE => TO_CHAR(RPTQ.DFINISH_TS
                                     ,'yyyy-mm-dd hh24:mi:ss'));
          --длительность обработки
          J.PUT(PAIR_NAME  => 'SEXEC_TIME'
               ,PAIR_VALUE => RPTQ.SEXEC_TIME);
          --сообщение об ошибке обработки
          J.PUT(PAIR_NAME  => 'SERR'
               ,PAIR_VALUE => RPTQ.SERR);
          --соберем сведения о параметрах позиции очереди
          if ((RPTQ.PRMS is not null) and (RPTQ.PRMS.COUNT > 0))
          then
            for I in RPTQ.PRMS.FIRST .. RPTQ.PRMS.LAST
            loop
              PRMQ := JSON();
              PRMQ.PUT(PAIR_NAME  => 'NRN'
                      ,PAIR_VALUE => RPTQ.PRMS(I).NRN);
              PRMQ.PUT(PAIR_NAME  => 'NPRN'
                      ,PAIR_VALUE => RPTQ.PRMS(I).NPRN);
              PRMQ.PUT(PAIR_NAME  => 'SNAME'
                      ,PAIR_VALUE => RPTQ.PRMS(I).SNAME);
              PRMQ.PUT(PAIR_NAME  => 'SPROMPT'
                      ,PAIR_VALUE => RPTQ.PRMS(I).SPROMPT);
              PRMQ.PUT(PAIR_NAME  => 'NVAL_TYPE'
                      ,PAIR_VALUE => RPTQ.PRMS(I).NVAL_TYPE);
              PRMQ.PUT(PAIR_NAME  => 'SVAL'
                      ,PAIR_VALUE => RPTQ.PRMS(I).SVAL);
              PRMQS.APPEND(ELEM => PRMQ.TO_JSON_VALUE());
            end loop;
          end if;
          --добавим в ответ сведения о параметрах позиции очереди
          J.PUT(PAIR_NAME  => 'PRMS'
               ,PAIR_VALUE => PRMQS);
        end;
      else
        P_EXCEPTION(0
                   ,'Значение признака выдачи информации "' || NINFO ||
                    '" не поддерживается процедурой сбора данных о позиции очереди!');
    end case;
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --запрос списка позиций очереди (в JSON)
  function JSON_REPORTQS_GET
  (
    NCOMPANY      number --рег. номер организации
   ,SUSER         varchar2 --пользователь
   ,NREPORT       number --рег. номер пользовательского отчета (null - по всем)
   ,SSEARCH       varchar2 --строка поиска (null - не искать)
   ,NPORTION      number --номер порции записей (игнорируется при NPORTION_SIZE=0)
   ,NPORTION_SIZE number --количество записей в порции (0 - все)
  ) return clob is
    J          JSON; --JSON ответ (объект)
    JRPTQS     JSON_LIST; --JSON список позиций очереди (объект)
    JRPTQ      JSON; --JSON позиция очереди (объект)
    CRPTQ      clob; --JSON позиция очереди (текст)
    CJSON      clob; --JSON ответ (текст)
    SERR       varchar2(4000); --буфер для ошибок
    RPTQS      REPORTQS; --коллекция позиций очереди
    NRESP_TYPE number(1); --тип ответа сервера
    SRESP_MSG  varchar2(4000); --буфер для ответа сервера
  begin
    --сформируем список позиций очереди
    REPORTQS_GET(NCOMPANY      => NCOMPANY
                ,SUSER         => SUSER
                ,NREPORT       => NREPORT
                ,SSEARCH       => SSEARCH
                ,NPORTION      => NPORTION
                ,NPORTION_SIZE => NPORTION_SIZE
                ,RPTQS         => RPTQS);
    --инициализируем объекты
    J      := JSON();
    JRPTQS := JSON_LIST();
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --пройдем по списку и сформируем ответ
    if ((RPTQS is not null) and (RPTQS.COUNT > 0))
    then
      for I in RPTQS.FIRST .. RPTQS.LAST
      loop
        --соберем данные по текущей позиции в буфер (в JSON формате)
        DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRPTQ
                                ,CACHE   => false);
        CRPTQ := JSON_REPORTQ_GET(SUSER    => SUSER
                                 ,NREPORTQ => RPTQS(I).NRN
                                 ,NINFO    => NINFO_BRIEF);
        --проверим буфер на наличие ошибок
        JSON_PARSE_RESPONSE(CJSON      => CRPTQ
                           ,NRESP_TYPE => NRESP_TYPE
                           ,SRESP_MSG  => SRESP_MSG);
        --если ошибок нет - добавляем отчет в объект списка для ответа
        if (NRESP_TYPE is null)
        then
          --транслируем полученное текстовое JSON представление в объект
          JRPTQ := JSON(CRPTQ);
          --добавляем позицию очереди в результирующий список
          JRPTQS.APPEND(ELEM => JRPTQ.TO_JSON_VALUE());
        else
          --иначе выдаем ошибку
          P_EXCEPTION(0
                     ,SRESP_MSG);
        end if;
      end loop;
    end if;
    --сформируем в ответе список отчетов
    J.PUT(PAIR_NAME  => 'REPORTQS'
         ,PAIR_VALUE => JRPTQS);
    --вернем ответ
    J.TO_CLOB(BUF => CJSON);
    return CJSON;
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --удаление позиции из очереди (ответ о результате удаления в JSON)
  function JSON_REPORTQ_REMOVE
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) return clob is
    SERR varchar2(4000); --буфер для ошибок
  begin
    --повторим печать отчета
    REPORTQ_REMOVE(SUSER    => SUSER
                  ,NREPORTQ => NREPORTQ);
    --вернем положительный ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => null);
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --выгрузка отчета из очереди (ответ о результате в JSON)
  function JSON_REPORTQ_DOWNLOAD(NREPORTQ number --рег. номер позиции очереди
                                 ) return clob is
    SFILE_NAME varchar2(4000); --имя файла готового отчета
    SURL       varchar2(4000); --URL готового отчета для скачивания
    SERR       varchar2(4000); --буфер для ошибок
    JRESP      JSON; --объектное представление ответа
    CRESP      clob; --текст ответа
  begin
    --выгрузим готовый отчет
    REPORTQ_DOWNLOAD(NREPORTQ   => NREPORTQ
                    ,SFILE_NAME => SFILE_NAME
                    ,SURL       => SURL);
    --если удалось и пришел не пустой URL и имя файла - вернем их
    if ((SURL is not null) and (SFILE_NAME is not null))
    then
      --откроем буфер
      DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP
                              ,CACHE   => false);
      --собираем ответ
      JRESP := JSON();
      JRESP.PUT(PAIR_NAME  => SRESP_TYPE_KEY
               ,PAIR_VALUE => SRESP_TYPE_VAL);
      JRESP.PUT(PAIR_NAME  => SRESP_STATE_KEY
               ,PAIR_VALUE => NRESP_TYPE_OK);
      JRESP.PUT(PAIR_NAME  => 'FILE_NAME'
               ,PAIR_VALUE => SFILE_NAME);
      JRESP.PUT(PAIR_NAME  => 'URL'
               ,PAIR_VALUE => SURL);
      JRESP.TO_CLOB(BUF => CRESP);
      return CRESP;
    else
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => 'Не удалось определить URL для загрузки данных отчета!');
    end if;
  exception
    --если не удалось - вернем ответ об ошибке
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --повторная постановка отчета в очередь (ответ о результате повтора в JSON)
  function JSON_REPORTQ_REPEAT
  (
    SUSER    varchar2 --пользователь
   ,NREPORTQ number --рег. номер позиции очереди
  ) return clob is
    SERR varchar2(4000); --буфер для ошибок
  begin
    --повторим печать отчета
    REPORTQ_REPEAT(SUSER    => SUSER
                  ,NREPORTQ => NREPORTQ);
    --вернем положительный ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => null);
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --проверка наличия обновлений очереди (ответ о результате проверки в JSON)
  function JSON_REPORTQ_CHECK_NEW
  (
    NCOMPANY    number --рег. номер организации
   ,SUSER       varchar2 --пользователь
   ,STIME_STAMP varchar2 --хронологическая точка отсчета проверки (ГГГГ-ММ-ДД ЧЧ24:МИ:СС), строковое представлениe
  ) return clob is
    NREPORTQ_NEW_CNT number(17); --количество новых позиций очереди
    SERR             varchar2(4000); --буфер для ошибок
  begin
    --проверим наличие обновлений
    REPORTQ_CHECK_NEW(NCOMPANY         => NCOMPANY
                     ,SUSER            => SUSER
                     ,STIME_STAMP      => STIME_STAMP
                     ,NREPORTQ_NEW_CNT => NREPORTQ_NEW_CNT);
    --вернем положительный ответ
    return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_OK
                        ,NRESP_KIND => NRESP_KIND_JSON
                        ,SRESP_MSG  => NREPORTQ_NEW_CNT);
  exception
    when others then
      SERR := sqlerrm;
      return UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                          ,NRESP_KIND => NRESP_KIND_JSON
                          ,SRESP_MSG  => SERR);
  end;

  --выдача справки по WEB-сервису обслуживания очереди печати отчетов
  function JSON_URPT_SRV_HELP return clob is
    CRES clob; --свёрстанная справка в HTML
  begin
    --сформируем ответ
    CRES := '<html><body>';
    CRES := CRES || '<center><b><h2>WEB-сервис "' || SSERVICE_NAME ||
            '" (версия ' || SSERVICE_VERSION ||
            ')</h2>Краткое руководство</center></b><br>';
    CRES := CRES || '<b>-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-<br>
  ФОРМАТ ПЕРЕДАЧИ ПАРАМЕТРОВ<br>
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-</b><br>
  {SPRMS: {<br>
  &nbsp;&nbsp;&nbsp;SUSER: <ПОЛЬЗОВАТЕЛЬ - передается для всех действий, кроме получения списка организаций, определения активности сервиса, завершения сеанса, валидации сеанса и получения данной справки><br>
  &nbsp;&nbsp;&nbsp;SSESSION: <ИДЕНТИФИКАТОР_СЕССИИ - передается для всех действий, кроме аутентификации, считывания параметров системы, получения списка организаций, определения активности сервиса, запроса списка новых подготовленных очетов и получения данной справки><br>
  &nbsp;&nbsp;&nbsp;SACTION: <ДЕЙСТВИЕ><br>
  &nbsp;&nbsp;&nbsp;SACTION_PRMS: {<ПАРАМЕТР_ДЕЙСТВИЯ_1>: <ЗНАЧЕНИЕ_ПАРАМЕТРА_ДЕЙСТВИЯ_1>,..<ПАРАМЕТР_ДЕЙСТВИЯ_N>: <ЗНАЧЕНИЕ_ПАРАМЕТРА_ДЕЙСТВИЯ_N>} - передается для всех действий, кроме получения списка организаций, определения активности сервиса, завершения сеанса, валидации сеанса и получения данной справки<br>
  }}<br><br>
  <b>-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-<br>
  ОПИСАНИЕ ДОСТУПНЫХ ДЕЙСТВИЙ И ИХ ПАРАМЕТРОВ<br>
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-</b><br>
  <b>0. Получение данной справки о работе сервиса</b><br>
   {SPRMS: {<br>
   &nbsp;&nbsp;&nbsp;HELP: YES<br>
   }}<br><br>
  <b>1. Аутентификация</b><br>
   SACTION: LOGIN<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;SPASSWORD: <ПАРОЛЬ_ПОЛЬЗОВАТЕЛЯ><br>
   &nbsp;&nbsp;&nbsp;SCOMPANY: <НАИМЕНОВАНИЕ_ОРГАНИЗАЦИИ><br>
   &nbsp;&nbsp;&nbsp;SSESSION_CLIENT: <ИДЕНТИФИКАТОР СЕССИ СФОРМИРОВАННЫЙ КЛИЕНТОМ - не обязательно, елси не передан - будет сформирован на сервере><br>
   }<br><br>
  <b>2. Получение деталей по отчету</b><br>
   SACTION: REPORT_GET<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА><br>
   }<br><br>
  <b>3. Просмотр списка отчетов:</b><br>
   SACTION: REPORTS_GET<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ>, <br>
   &nbsp;&nbsp;&nbsp;NUNIT: <РЕГ_НОМЕР_РАЗДЕЛА_ПРИВЯЗКИ - null - по всем, 0 - без привязки, иначе - рег. номер раздела>, <br>
   &nbsp;&nbsp;&nbsp;NFAVOR: <ПРИЗНАК_ОТОБРАЖЕНИЯ_ИЗБРАННЫХ - null - все, 0 - не изранные, 1 - избранные>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION: <НОМЕР_ПОРЦИИ - игнорируется при PORTION_SIZE=0>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION_SIZE: <КОЛ_ВО_ЗАПСИЕЙ_В_ПОРЦИИ - 0 - все>, <br>
   &nbsp;&nbsp;&nbsp;NRPT_ORDER: <СПОСОБ_СОРТИРОВКИ - 0 - по наименованию, 1 - по разделам><br>
   }<br><br>
  <b>4. Добавление отчета в очередь</b><br>
   SACTION: REPORT_PUT<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ>, <br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА>,<br>
   &nbsp;&nbsp;&nbsp;PRMS: [<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SNAME: <ИМЯ_ПАРАМЕТРА_1>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА_1 - 0 - строка, 1 - число, 2 - дата, 3 - булево>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА_1 - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0><br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SNAME: <ИМЯ_ПАРАМЕТРА_N>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА_N - 0 - строка, 1 - число, 2 - дата, 3 - булево>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА_N - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0><br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>
   &nbsp;&nbsp;&nbsp;]<br>
   }<br><br>
  <b>5. Получение деталей по позиции очереди</b><br>
   SACTION: REPORTQ_GET<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORTQ: <РЕГ_НОМЕР_ПОЗИЦИИ_ОЧЕРЕДИ><br>
   }<br><br>
  <b>6. Просмотр очереди</b><br>
   SACTION: REPORTQS_GET<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ>, <br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА - null - по всем>,<br>
   &nbsp;&nbsp;&nbsp;NPORTION: <НОМЕР_ПОРЦИИ - игнорируется при PORTION_SIZE=0>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION_SIZE: <КОЛ_ВО_ЗАПСИЕЙ_В_ПОРЦИИ - 0 - все><br>
   }<br><br>
  <b>7. Выгрузка готового отчета из очереди</b><br>
   SACTION: REPORTQ_DOWNLOAD<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORTQ: <РЕГ_НОМЕР_ПОЗИЦИИ_ОЧЕРЕДИ><br>
   }<br><br>
  <b>8. Повторная постановка отчета в очередь</b><br>
   SACTION: REPORTQ_REPEAT<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORTQ: <РЕГ_НОМЕР_ПОЗИЦИИ_ОЧЕРЕДИ><br>
   }<br><br>
  <b>9. Удаление позиции очереди</b><br>
   SACTION: REPORTQ_REMOVE<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORTQ: <РЕГ_НОМЕР_ПОЗИЦИИ_ОЧЕРЕДИ><br>
   }<br><br>
  <b>10. Список значений параметра отчета из связанного раздела</b><br>
   SACTION: PRM_DICT_RECS_GET<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NPRM: <РЕГ_НОМЕР_ПАРАМЕТРА_ОТЧЕТА>, <br>
   &nbsp;&nbsp;&nbsp;SSEARCH: <СТРОКА_ПОИСКА>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION: <НОМЕР_ПОРЦИИ - игнорируется при PORTION_SIZE=0>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION_SIZE: <КОЛ_ВО_ЗАПСИЕЙ_В_ПОРЦИИ - 0 - все><br>
   }<br><br>
  <b>11. Список разделов, имеющих привязанные отчеты</b><br>
   SACTION: UNITS_GET<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION: <НОМЕР_ПОРЦИИ - игнорируется при PORTION_SIZE=0>, <br>
   &nbsp;&nbsp;&nbsp;NPORTION_SIZE: <КОЛ_ВО_ЗАПСИЕЙ_В_ПОРЦИИ - 0 - все><br>
   }<br><br>
  <b>12. Переключение состояния "избранности"</b><br>
   SACTION: REPORT_FAVOR_TOGGLE<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА><br>
   }<br><br>
  <b>13. Добавить расписание для отчета</b><br>
   SACTION: REPORT_ADD_SCHED<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА><br>
   &nbsp;&nbsp;&nbsp;NSCHED_TYPE: <ТИП_ИНТЕРВАЛА - 0 - минута, 1 - час, 2 - день, 3 - неделя, 4 - месяц><br>
   &nbsp;&nbsp;&nbsp;NSTEP: <ШАГ_ИНТЕРВАЛА><br>
   &nbsp;&nbsp;&nbsp;SSTART_DATE: <ДАТА_НАЧАЛА_ДЕЙСТВИЯ_РАСПИСАНИЯ - строка, в формате ГГГГ-ММ-ДД ЧЧ24:МИ:СС><br>
   &nbsp;&nbsp;&nbsp;PRMS: [<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SNAME: <ИМЯ_ПАРАМЕТРА_1>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА_1 - 0 - строка, 1 - число, 2 - дата, 3 - булево>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА_1 - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0><br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SNAME: <ИМЯ_ПАРАМЕТРА_N>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NVAL_TYPE: <ТИП_ДАННЫХ_ПАРАМЕТРА_N - 0 - строка, 1 - число, 2 - дата, 3 - булево>,<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SVAL: <ЗНАЧЕНИЕ_ПАРАМЕТРА_N - для даты формат ГГГГ-ММ-ДД, для булева 1 или 0><br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>
   &nbsp;&nbsp;&nbsp;]<br>
   }<br><br>
  <b>14. Удалить расписание для отчета</b><br>
   SACTION: REPORT_REMOVE_SCHED<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА><br>
   &nbsp;&nbsp;&nbsp;NREPORTSCH: <РЕГ_НОМЕР_ПОЗИЦИИ_РАСПИСАНИЯ - null - зачистка всех расписаний данного пользователя в отчете><br>
   }<br><br>
  <b>15. Предпросмотр отчета</b><br>
   SACTION: REPORT_PREVIEW<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NREPORT: <РЕГ_НОМЕР_ПОЛЬЗОВАТЕЛЬСКОГО_ОТЧЕТА><br>
   }<br><br>
  <b>16. Проверка наличия новых готовых отчетов</b><br>
   SACTION: REPORTQ_CHECK_NEW<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ><br>
   &nbsp;&nbsp;&nbsp;STIME_STAMP: <ДАТА_ПО_СОСТОЯНИЮ_НА - строка, в формате ГГГГ-ММ-ДД ЧЧ24:МИ:СС><br>
   }<br><br>
  <b>17. Считывание параметра системы (строка)</b><br>
   SACTION: OPTION_GET_STR<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ><br>
   &nbsp;&nbsp;&nbsp;SOPTION: <КОД_ПАРАМЕТРА_СИСТЕМЫ><br>
   }<br><br>
  <b>18. Считывание параметра системы (число)</b><br>
   SACTION: OPTION_GET_NUM<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ><br>
   &nbsp;&nbsp;&nbsp;SOPTION: <КОД_ПАРАМЕТРА_СИСТЕМЫ><br>
   }<br><br>
  <b>19. Считывание параметра системы (дата)</b><br>
   SACTION: OPTION_GET_DATE<br>
   SACTION_PRMS: {<br>
   &nbsp;&nbsp;&nbsp;NCOMPANY: <РЕГ_НОМЕР_ОРГАНИЗАЦИИ><br>
   &nbsp;&nbsp;&nbsp;SOPTION: <КОД_ПАРАМЕТРА_СИСТЕМЫ><br>
   }<br><br>
  <b>20. Считывание списка организаций системы</b><br>
   SUSER: <ПОЛЬЗОВАТЕЛЬ - опционально, если не указан - все, если указан - только привязанные к пользователю><br>
   SACTION: OPTION_GET_COMPANIES<br><br>
  <b>21. Считывание состояния активности сервиса</b><br>
   SACTION: OPTION_CHECK_ACTIVE<br><br>
  <b>22. Завершение сеанса</b><br>
   SACTION: LOGOUT<br><br>
  <b>22. Валидация сеанса</b><br>
   SACTION: SESSION_CHECK<br><br>
   ';
    CRES := CRES || '</body></html>';
    --вернем результат
    return CRES;
  end;

  --универсальная функция обработки запросов к WEB-сервису обслуживания очереди печати отчетов (ответ в CLOB)
  function JSON_URPT_SRV_PROCESS(CPRMS clob --параметры запроса (JSON)
                                 ) return clob is
    SCANNER_EXCEPTION exception; --ошибка JSON-сканера
    pragma exception_init(SCANNER_EXCEPTION
                         ,-20100); --инициализация ошибки JSON-сканера
    PARSER_EXCEPTION exception; --ошибка JSON-парсера
    pragma exception_init(PARSER_EXCEPTION
                         ,-20101); --инициализация ошибки JSON-парсера
    JEXT_EXCEPTION exception; --ошибка JSON-расширений
    pragma exception_init(JEXT_EXCEPTION
                         ,-20110); --инициализация ошибки JSON-расширений
    JPRMS  JSON; --объектное представление запроса
    JRQ    JSON; --объектное представление полей запроса
    JRQ_AP JSON; --объектное представление параметров запроса (параметры запроса - одно из полей запроса - SREQ_ACTION_PRMS_KEY)
    CJSON  clob; --JSON ответ (текст)
    SERR   varchar2(4000); --буфер для ошибок
  begin
    --инициализация ответа
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CJSON
                            ,CACHE   => false);
    --разбор параметров запроса
    begin
      JPRMS := JSON(CPRMS);
      --если это запрос к сервису печати отчетов
      if ((JPRMS.EXIST(SREQ_TYPE_PRINT_KEY)) and
         (JPRMS.GET(SREQ_TYPE_PRINT_KEY).IS_OBJECT))
      then
        --считаем объект запроса
        JRQ := JSON(JPRMS.GET(SREQ_TYPE_PRINT_KEY));
        --если попросили помощь - ответим HTMLем со справкой
        if ((JRQ.EXIST(SREQ_TYPE_HELP_KEY)) and
           (UPPER(JRQ.GET(SREQ_TYPE_HELP_KEY).GET_STRING) = SREQ_TYPE_HELP_VAL))
        then
          CJSON := JSON_URPT_SRV_HELP;
        else
          --иначе работаем с сервисом перчати - проверим наличие кода действия
          if ((not JRQ.EXIST(SREQ_ACTION_KEY)) or
             (not JRQ.GET(SREQ_ACTION_KEY).IS_STRING) or
             (JRQ.GET(SREQ_ACTION_KEY).GET_STRING is null))
          then
            P_EXCEPTION(0
                       ,'В запросе к серверу не указан код действия!');
          end if;
          --проверим наличие обязательных параметров (если это не запрос списка организаций, не завершение сеанаса, не проверка активности сервиса и не валидация сессии)
          if (JRQ.GET(SREQ_ACTION_KEY)
             .GET_STRING not in (SREQ_ACT_OPTION_GET_CMPNS_VAL
                                ,SREQ_ACT_OPTION_CHECK_ACTV_VAL
                                ,SREQ_ACT_LOGOUT_VAL
                                ,SREQ_ACT_SESSION_CHECK_VAL))
          then
            if ((not JRQ.EXIST(SREQ_USER_KEY)) or
               (not JRQ.GET(SREQ_USER_KEY).IS_STRING) or
               (JRQ.GET(SREQ_USER_KEY).GET_STRING is null) or
               (not JRQ.EXIST(SREQ_ACTION_PRMS_KEY)) or
               (not JRQ.GET(SREQ_ACTION_PRMS_KEY).IS_OBJECT))
            then
              P_EXCEPTION(0
                         ,'Некорректный запрос к серверу!');
            end if;
          else
            --проверка параметров для "особых случаев"
            case JRQ.GET(SREQ_ACTION_KEY).GET_STRING
            --запрос списка организаций
              when SREQ_ACT_OPTION_GET_CMPNS_VAL then
                begin
                  --для запроса списка организаций нет обязательных параметров
                  null;
                end;
                --запрос активности сервиса
              when SREQ_ACT_OPTION_CHECK_ACTV_VAL then
                begin
                  --для запроса активности сервиса нет обязательных параметров
                  null;
                end;
                --запрос на завершение сеанса
              when SREQ_ACT_LOGOUT_VAL then
                begin
                  --для запроса на завершение сеанса только один обязательный параметр - идентификатор сессии
                  if ((not JRQ.EXIST(SREQ_SESSION_KEY)) or
                     (not JRQ.GET(SREQ_SESSION_KEY).IS_STRING))
                  then
                    P_EXCEPTION(0
                               ,'Не указан идентификатор сессии для завершения сеанса!');
                  end if;
                end;
                --запрос на валидацию сессии
              when SREQ_ACT_SESSION_CHECK_VAL then
                begin
                  --для запроса на валидацию сессии только один обязательный параметр - идентификатор сессии
                  if ((not JRQ.EXIST(SREQ_SESSION_KEY)) or
                     (not JRQ.GET(SREQ_SESSION_KEY).IS_STRING))
                  then
                    P_EXCEPTION(0
                               ,'Не указан идентификатор сессии для валидации сеанса!');
                  end if;
                end;
              else
                P_EXCEPTION(0
                           ,'Некорректный запрос к серверу!');
            end case;
          end if;
          --если это не аутентификация, не считывание параметров системы, не запрос списка организаций, не проверка обновлений, не выход, не валидация сессии и не проверка активности - проверяем сессию
          if (JRQ.GET(SREQ_ACTION_KEY)
             .GET_STRING not in (SREQ_ACT_LOGIN_VAL
                                ,SREQ_ACT_OPTION_GET_STR_VAL
                                ,SREQ_ACT_OPTION_GET_NUM_VAL
                                ,SREQ_ACT_OPTION_GET_DATE_VAL
                                ,SREQ_ACT_OPTION_GET_CMPNS_VAL
                                ,SREQ_ACT_OPTION_CHECK_ACTV_VAL
                                ,SREQ_ACT_REPORTQ_CHECK_NEW
                                ,SREQ_ACT_LOGOUT_VAL
                                ,SREQ_ACT_SESSION_CHECK_VAL))
          then
            --проверяем только если задан режим проверки
            if (not BALLOW_EMPTY_SESSION_ACTIONS)
            then
              if ((not JRQ.EXIST(SREQ_SESSION_KEY)) or
                 (not JRQ.GET(SREQ_SESSION_KEY).IS_STRING))
              then
                P_EXCEPTION(0
                           ,'Не указан идентификатор сессии!');
              else
                SERVICE_SESSION_CHECK(SUSER    => JRQ.GET(SREQ_USER_KEY)
                                                  .GET_STRING
                                     ,SSESSION => JRQ.GET(SREQ_SESSION_KEY)
                                                  .GET_STRING);
              end if;
            end if;
          end if;
          --сформируем объектное представление параметров - для удобства обращения к ним в дальнейшем
          if (JRQ.EXIST(SREQ_ACTION_PRMS_KEY))
          then
            JRQ_AP := JSON(JRQ.GET(SREQ_ACTION_PRMS_KEY));
          else
            JRQ_AP := null;
          end if;
          --в зависимости от запрошенного действия выполним обработку запроса
          case JRQ.GET(SREQ_ACTION_KEY).GET_STRING
          --аутентифицироваться
            when SREQ_ACT_LOGIN_VAL then
              declare
                SSESSION_CLIENT           varchar2(4000);
                SEXPECTED_SERVICE_VERSION varchar2(200);
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_PASSWORD_KEY)) and
                   (JRQ_AP.GET(SREQ_PASSWORD_KEY).IS_STRING) and
                   (JRQ_AP.EXIST(SREQ_SCOMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_SCOMPANY_KEY).IS_STRING))
                then
                  if ((JRQ_AP.EXIST(SREQ_SESSION_CLIENT_KEY)) and
                     (JRQ_AP.GET(SREQ_SESSION_CLIENT_KEY).IS_STRING))
                  then
                    SSESSION_CLIENT := JRQ_AP.GET(SREQ_SESSION_CLIENT_KEY)
                                       .GET_STRING;
                  else
                    SSESSION_CLIENT := null;
                  end if;
                  if ((JRQ_AP.EXIST(SREQ_EXPECTED_SERVICE_VERS_KEY)) and
                     (JRQ_AP.GET(SREQ_EXPECTED_SERVICE_VERS_KEY).IS_STRING))
                  then
                    SEXPECTED_SERVICE_VERSION := JRQ_AP.GET(SREQ_EXPECTED_SERVICE_VERS_KEY)
                                                 .GET_STRING;
                  else
                    SEXPECTED_SERVICE_VERSION := null;
                  end if;
                  CJSON := JSON_SERVICE_LOGIN(SUSER                     => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                                 .GET_STRING)
                                             ,SPASSWORD                 => JRQ_AP.GET(SREQ_PASSWORD_KEY)
                                                                           .GET_STRING
                                             ,SCOMPANY                  => JRQ_AP.GET(SREQ_SCOMPANY_KEY)
                                                                           .GET_STRING
                                             ,SSESSION_CLIENT           => SSESSION_CLIENT
                                             ,SEXPECTED_SERVICE_VERSION => SEXPECTED_SERVICE_VERSION);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --завершить сеанс
            when SREQ_ACT_LOGOUT_VAL then
              begin
                CJSON := JSON_SERVICE_LOGOUT(SSESSION => JRQ.GET(SREQ_SESSION_KEY)
                                                         .GET_STRING);
              end;
              --валидировать сеанс
            when SREQ_ACT_SESSION_CHECK_VAL then
              begin
                CJSON := JSON_SERVICE_SESSION_CHECK(SSESSION => JRQ.GET(SREQ_SESSION_KEY)
                                                                .GET_STRING);
              end;
              --получить детальную информацию об отчете
            when SREQ_ACT_REPORT_GET_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORT_GET(SUSER   => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                            .GET_STRING)
                                          ,NREPORT => JRQ_AP.GET(SREQ_REPORT_KEY)
                                                      .GET_NUMBER
                                          ,NINFO   => NINFO_FULL);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --получить список доступных отчетов
            when SREQ_ACT_REPORTS_GET_VAL then
              declare
                NUNIT   UNITLIST.RN%type; --рег. номер раздела
                NFAVOR  number(1); --флаг отображения избранных отчетов
                SSEARCH varchar2(4000); --строка поиска
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_SIZE_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_SIZE_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_RPT_ORDER_KEY)) and
                   (JRQ_AP.GET(SREQ_RPT_ORDER_KEY).IS_NUMBER))
                then
                  if ((JRQ_AP.EXIST(SREQ_UNIT_KEY)) and
                     (JRQ_AP.GET(SREQ_UNIT_KEY).IS_NUMBER))
                  then
                    NUNIT := JRQ_AP.GET(SREQ_UNIT_KEY).GET_NUMBER;
                  else
                    NUNIT := null;
                  end if;
                  if ((JRQ_AP.EXIST(SREQ_FAVOR_KEY)) and
                     (JRQ_AP.GET(SREQ_FAVOR_KEY).IS_NUMBER))
                  then
                    NFAVOR := JRQ_AP.GET(SREQ_FAVOR_KEY).GET_NUMBER;
                  else
                    NFAVOR := null;
                  end if;
                  if ((JRQ_AP.EXIST(SREQ_SEARCH_KEY)) and
                     (JRQ_AP.GET(SREQ_SEARCH_KEY).IS_STRING))
                  then
                    SSEARCH := JRQ_AP.GET(SREQ_SEARCH_KEY).GET_STRING;
                  else
                    SSEARCH := null;
                  end if;
                  CJSON := JSON_REPORTS_GET(NCOMPANY      => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                             .GET_NUMBER
                                           ,SUSER         => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                   .GET_STRING)
                                           ,NUNIT         => NUNIT
                                           ,NFAVOR        => NFAVOR
                                           ,SSEARCH       => SSEARCH
                                           ,NPORTION      => JRQ_AP.GET(SREQ_PORTION_KEY)
                                                             .GET_NUMBER
                                           ,NPORTION_SIZE => JRQ_AP.GET(SREQ_PORTION_SIZE_KEY)
                                                             .GET_NUMBER
                                           ,NRPT_ORDER    => JRQ_AP.GET(SREQ_RPT_ORDER_KEY)
                                                             .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --поместить отчет в очередь
            when SREQ_ACT_REPORT_PUT_VAL then
              declare
                CRPTPRMS clob; --буфер для параметров
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PRMS_KEY)) and
                   (JRQ_AP.GET(SREQ_PRMS_KEY).IS_ARRAY))
                then
                  DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRPTPRMS
                                          ,CACHE   => false);
                  JRQ_AP.GET(SREQ_PRMS_KEY).TO_CLOB(BUF => CRPTPRMS);
                  CJSON := JSON_REPORT_PUT(NCOMPANY   => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                         .GET_NUMBER
                                          ,SUSER      => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                               .GET_STRING)
                                          ,NREPORT    => JRQ_AP.GET(SREQ_REPORT_KEY)
                                                         .GET_NUMBER
                                          ,NSCHEDULED => NSCHEDULED_NO
                                          ,NMAIL      => NMAIL_NO
                                          ,CPRMS      => CRPTPRMS);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --добавить расписание для отчета
            when SREQ_ACT_REPORT_ADD_SCHED_VAL then
              declare
                CRPTPRMS clob; --буфер для параметров
                NMAIL    number(1); --флаг доставки по e-mail
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_SCH_TYPE_KEY)) and
                   (JRQ_AP.GET(SREQ_SCH_TYPE_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_SCH_STEP_KEY)) and
                   (JRQ_AP.GET(SREQ_SCH_STEP_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_SCH_START_DATE_KEY)) and
                   (JRQ_AP.GET(SREQ_SCH_START_DATE_KEY).IS_STRING) and
                   (JRQ_AP.EXIST(SREQ_PRMS_KEY)) and
                   (JRQ_AP.GET(SREQ_PRMS_KEY).IS_ARRAY))
                then
                  if ((JRQ_AP.EXIST(SREQ_SCH_MAIL_KEY)) and
                     (JRQ_AP.GET(SREQ_SCH_MAIL_KEY).IS_NUMBER))
                  then
                    NMAIL := JRQ_AP.GET(SREQ_SCH_MAIL_KEY).GET_NUMBER;
                  else
                    NMAIL := NMAIL_NO;
                  end if;
                  DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRPTPRMS
                                          ,CACHE   => false);
                  JRQ_AP.GET(SREQ_PRMS_KEY).TO_CLOB(BUF => CRPTPRMS);
                  CJSON := JSON_REPORT_ADD_SCHED(SUSER       => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                      .GET_STRING)
                                                ,NREPORT     => JRQ_AP.GET(SREQ_REPORT_KEY)
                                                                .GET_NUMBER
                                                ,NSCHED_TYPE => JRQ_AP.GET(SREQ_SCH_TYPE_KEY)
                                                                .GET_NUMBER
                                                ,NSTEP       => JRQ_AP.GET(SREQ_SCH_STEP_KEY)
                                                                .GET_NUMBER
                                                ,SSTART_DATE => JRQ_AP.GET(SREQ_SCH_START_DATE_KEY)
                                                                .GET_STRING
                                                ,NMAIL       => NMAIL
                                                ,CPRMS       => CRPTPRMS);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --удалить расписание отчета
            when SREQ_ACT_REPORT_REM_SCHED_VAL then
              declare
                NREPORTSCH UDO_T_URPT_SRV_SCHED.RN%type; --рег. номер удаляемого расписания
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER))
                then
                  if ((JRQ_AP.EXIST(SREQ_REPORT_SCH_KEY)) and
                     (JRQ_AP.GET(SREQ_REPORT_SCH_KEY).IS_NUMBER))
                  then
                    NREPORTSCH := JRQ_AP.GET(SREQ_REPORT_SCH_KEY).GET_NUMBER;
                  else
                    NREPORTSCH := null;
                  end if;
                  CJSON := JSON_REPORT_REMOVE_SCHED(SUSER      => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                        .GET_STRING)
                                                   ,NREPORT    => JRQ_AP.GET(SREQ_REPORT_KEY)
                                                                  .GET_NUMBER
                                                   ,NREPORTSCH => NREPORTSCH);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --предварительный просмотр отчета
            when SREQ_ACT_REPORT_PREVIEW_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORT_PREVIEW(NREPORT => JRQ_AP.GET(SREQ_REPORT_KEY)
                                                          .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --переключить состояние "избранности" отчета
            when SREQ_ACT_REPORT_FAVOR_TGL_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORT_FAVOR_TOGGLE(SUSER   => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                     .GET_STRING)
                                                   ,NREPORT => JRQ_AP.GET(SREQ_REPORT_KEY)
                                                               .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --получить детальную информацию о позиии очереди
            when SREQ_ACT_REPORTQ_GET_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORTQ_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORTQ_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORTQ_GET(SUSER    => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                              .GET_STRING)
                                           ,NREPORTQ => JRQ_AP.GET(SREQ_REPORTQ_KEY)
                                                        .GET_NUMBER
                                           ,NINFO    => NINFO_FULL);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --получить список позиций очереди
            when SREQ_ACT_REPORTQS_GET_VAL then
              declare
                NREPORT USERREPORTS.RN%type; --рег. номер пользовательского отчета для фильтрации очереди
                SSEARCH varchar2(4000); --строка поиска
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_SIZE_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_SIZE_KEY).IS_NUMBER))
                then
                  if ((JRQ_AP.EXIST(SREQ_REPORT_KEY)) and
                     (JRQ_AP.GET(SREQ_REPORT_KEY).IS_NUMBER))
                  then
                    NREPORT := JRQ_AP.GET(SREQ_REPORT_KEY).GET_NUMBER;
                  else
                    NREPORT := null;
                  end if;
                  if ((JRQ_AP.EXIST(SREQ_SEARCH_KEY)) and
                     (JRQ_AP.GET(SREQ_SEARCH_KEY).IS_STRING))
                  then
                    SSEARCH := JRQ_AP.GET(SREQ_SEARCH_KEY).GET_STRING;
                  else
                    SSEARCH := null;
                  end if;
                  CJSON := JSON_REPORTQS_GET(NCOMPANY      => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                              .GET_NUMBER
                                            ,SUSER         => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                    .GET_STRING)
                                            ,NREPORT       => NREPORT
                                            ,SSEARCH       => SSEARCH
                                            ,NPORTION      => JRQ_AP.GET(SREQ_PORTION_KEY)
                                                              .GET_NUMBER
                                            ,NPORTION_SIZE => JRQ_AP.GET(SREQ_PORTION_SIZE_KEY)
                                                              .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --удалить позицию очереди
            when SREQ_ACT_REPORTQ_REMOVE_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORTQ_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORTQ_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORTQ_REMOVE(SUSER    => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                 .GET_STRING)
                                              ,NREPORTQ => JRQ_AP.GET(SREQ_REPORTQ_KEY)
                                                           .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --загрузить готовый отчет
            when SREQ_ACT_REPORTQ_DOWNLOAD_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORTQ_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORTQ_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORTQ_DOWNLOAD(NREPORTQ => JRQ_AP.GET(SREQ_REPORTQ_KEY)
                                                             .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --повторить заказ отчета
            when SREQ_ACT_REPORTQ_REPEAT_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_REPORTQ_KEY)) and
                   (JRQ_AP.GET(SREQ_REPORTQ_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORTQ_REPEAT(SUSER    => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                 .GET_STRING)
                                              ,NREPORTQ => JRQ_AP.GET(SREQ_REPORTQ_KEY)
                                                           .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --проверить наличие обновлений в очереди
            when SREQ_ACT_REPORTQ_CHECK_NEW then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_TIME_STAMP_KEY)) and
                   (JRQ_AP.GET(SREQ_TIME_STAMP_KEY).IS_STRING))
                then
                  CJSON := JSON_REPORTQ_CHECK_NEW(NCOMPANY    => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                                 .GET_NUMBER
                                                 ,SUSER       => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                       .GET_STRING)
                                                 ,STIME_STAMP => JRQ_AP.GET(SREQ_TIME_STAMP_KEY)
                                                                 .GET_STRING);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --получить список значений для параметра
            when SREQ_ACT_PRM_DICT_RECS_GET_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_PRM_KEY)) and
                   (JRQ_AP.GET(SREQ_PRM_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_SEARCH_KEY)) and
                   (JRQ_AP.GET(SREQ_SEARCH_KEY).IS_STRING) and
                   (JRQ_AP.EXIST(SREQ_PORTION_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_SIZE_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_SIZE_KEY).IS_NUMBER))
                then
                  CJSON := JSON_REPORT_PRM_DICT_RECS_GET(SUSER         => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                                .GET_STRING)
                                                        ,NPRM          => JRQ_AP.GET(SREQ_PRM_KEY)
                                                                          .GET_NUMBER
                                                        ,SSEARCH       => JRQ_AP.GET(SREQ_SEARCH_KEY)
                                                                          .GET_STRING
                                                        ,NPORTION      => JRQ_AP.GET(SREQ_PORTION_KEY)
                                                                          .GET_NUMBER
                                                        ,NPORTION_SIZE => JRQ_AP.GET(SREQ_PORTION_SIZE_KEY)
                                                                          .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --получить список разделов, к которым привязаны отчеты
            when SREQ_ACT_UNITS_GET_VAL then
              declare
                SSEARCH varchar2(4000); --строка поиска
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_PORTION_SIZE_KEY)) and
                   (JRQ_AP.GET(SREQ_PORTION_SIZE_KEY).IS_NUMBER))
                then
                  if ((JRQ_AP.EXIST(SREQ_SEARCH_KEY)) and
                     (JRQ_AP.GET(SREQ_SEARCH_KEY).IS_STRING))
                  then
                    SSEARCH := JRQ_AP.GET(SREQ_SEARCH_KEY).GET_STRING;
                  else
                    SSEARCH := null;
                  end if;
                  CJSON := JSON_UNITS_GET(NCOMPANY      => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                           .GET_NUMBER
                                         ,SUSER         => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                 .GET_STRING)
                                         ,SSEARCH       => SSEARCH
                                         ,NPORTION      => JRQ_AP.GET(SREQ_PORTION_KEY)
                                                           .GET_NUMBER
                                         ,NPORTION_SIZE => JRQ_AP.GET(SREQ_PORTION_SIZE_KEY)
                                                           .GET_NUMBER);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --считать параметр системы (строка)
            when SREQ_ACT_OPTION_GET_STR_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_OPTION_KEY)) and
                   (JRQ_AP.GET(SREQ_OPTION_KEY).IS_STRING))
                then
                  CJSON := JSON_SERVICE_OPTION_GET_STR(NCOMPANY => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                                   .GET_NUMBER
                                                      ,SUSER    => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                         .GET_STRING)
                                                      ,SOPTION  => JRQ_AP.GET(SREQ_OPTION_KEY)
                                                                   .GET_STRING);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --считать параметр системы (число)
            when SREQ_ACT_OPTION_GET_NUM_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_OPTION_KEY)) and
                   (JRQ_AP.GET(SREQ_OPTION_KEY).IS_STRING))
                then
                  CJSON := JSON_SERVICE_OPTION_GET_NUM(NCOMPANY => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                                   .GET_NUMBER
                                                      ,SUSER    => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                         .GET_STRING)
                                                      ,SOPTION  => JRQ_AP.GET(SREQ_OPTION_KEY)
                                                                   .GET_STRING);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --считать параметр системы (дата)
            when SREQ_ACT_OPTION_GET_DATE_VAL then
              begin
                if ((JRQ_AP is not null) and (JRQ_AP.EXIST(SREQ_COMPANY_KEY)) and
                   (JRQ_AP.GET(SREQ_COMPANY_KEY).IS_NUMBER) and
                   (JRQ_AP.EXIST(SREQ_OPTION_KEY)) and
                   (JRQ_AP.GET(SREQ_OPTION_KEY).IS_STRING))
                then
                  CJSON := JSON_SERVICE_OPTION_GET_DATE(NCOMPANY => JRQ_AP.GET(SREQ_COMPANY_KEY)
                                                                    .GET_NUMBER
                                                       ,SUSER    => UPPER(JRQ.GET(SREQ_USER_KEY)
                                                                          .GET_STRING)
                                                       ,SOPTION  => JRQ_AP.GET(SREQ_OPTION_KEY)
                                                                    .GET_STRING);
                else
                  P_EXCEPTION(0
                             , 'Некорректно указаны параметры действия "' || JRQ.GET(SREQ_ACTION_KEY)
                              .GET_STRING || '"!');
                end if;
              end;
              --считать список организаций
            when SREQ_ACT_OPTION_GET_CMPNS_VAL then
              declare
                SUSER varchar2(80); --пользователь
              begin
                if ((JRQ.EXIST(SREQ_USER_KEY)) and
                   (JRQ.GET(SREQ_USER_KEY).IS_STRING))
                then
                  SUSER := UPPER(JRQ.GET(SREQ_USER_KEY).GET_STRING);
                else
                  SUSER := null;
                end if;
                CJSON := JSON_SERVICE_COMPANYS_GET(SUSER => SUSER);
              end;
              --проверка активности сервиса
            when SREQ_ACT_OPTION_CHECK_ACTV_VAL then
              begin
                CJSON := JSON_SERVICE_ACTIVE_CHECK();
              end;
            else
              P_EXCEPTION(0
                         ,'Действие "' || JRQ.GET(SREQ_ACTION_KEY).GET_STRING ||
                          '" не поддерживается сервисом!');
          end case;
        end if;
      else
        P_EXCEPTION(0
                   ,'Переданный запрос не является корректным для сервиса печати отчетов!');
      end if;
    exception
      when SCANNER_EXCEPTION then
        CJSON := UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                              ,NRESP_KIND => NRESP_KIND_JSON
                              ,SRESP_MSG  => 'Ошибка проверки запроса - убедитесь что зыпрос является валидным JSON-выражением!');
      when PARSER_EXCEPTION then
        CJSON := UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                              ,NRESP_KIND => NRESP_KIND_JSON
                              ,SRESP_MSG  => 'Ошибка разбора запроса - убедитесь что зыпрос является валидным JSON-выражением!');
      when JEXT_EXCEPTION then
        CJSON := UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                              ,NRESP_KIND => NRESP_KIND_JSON
                              ,SRESP_MSG  => 'Ошибка обработки запроса - убедитесь что зыпрос является валидным JSON-выражением!');
      when others then
        SERR  := sqlerrm;
        CJSON := UTL_MAKE_RESP(NRESP_TYPE => NRESP_TYPE_ERR
                              ,NRESP_KIND => NRESP_KIND_JSON
                              ,SRESP_MSG  => SERR);
    end;
    --вернем результат
    return CJSON;
  end;

  --универсальная процедура обработки запросов к WEB-сервису обслуживания очереди печати отчетов (выдача ответа вебсерверу)
  procedure JSON_URPT_SRV(CPRMS clob --параметры запроса (JSON)
                          ) is
    CJSON clob;
  begin
    --обработка запроса
    CJSON := JSON_URPT_SRV_PROCESS(CPRMS => CPRMS);
    --выдача ответа WEB-серверу
    UDO_PKG_SYSW0003_PUBL_UTILS.PUBLISH_CLOB_BUFFER(SHTML => CJSON);
  end;

--инициализация пакета
begin
  CONF_INIT();
end;
/

