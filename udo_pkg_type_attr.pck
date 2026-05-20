create or replace package UDO_PKG_TYPE_ATTR as

  /*
   Пакет функций раздела "Типовые показатели"
  */
  --тип для записи атрибута
  type TYPE_ATTR is record(
     NRN              UDO_T_TYPE_ATTR.RN%type --рег. номер
    ,NCRN             UDO_T_TYPE_ATTR.CRN%type --рег. номер каталога
    ,NCOMPANY         UDO_T_TYPE_ATTR.COMPANY%type --рег. номер организации
    ,SCODE            UDO_T_TYPE_ATTR.CODE%type --мнемокод
    ,SNAME            UDO_T_TYPE_ATTR.NAME%type --наименование
    ,NDATA_TYPE       UDO_T_TYPE_ATTR.DATA_TYPE%type --тип данных (см. константы NDATA_TYPE_*)
    ,NLNK_TYPE        UDO_T_TYPE_ATTR.LNK_TYPE%type --тип привязки (см. константы NLNK_TYPE_*)
    ,SUNIT            UDO_T_TYPE_ATTR.UNIT%type --код раздела привязки
    ,SMETHOD_NAME     RESOURCES.RESOURCE_TEXT%type --наименование метода вызова раздела привязки
    ,SMETHOD_PRM_NAME RESOURCES.RESOURCE_TEXT%type --наименование параметра метода вызова раздела привязки
    ,SINIT_PRM_NAME   UDO_T_TYPE_ATTR.NAME%type --наименование родителького атрибута
    ,SEX_DICT         EXTRA_DICTS.CODE%type --мнемокод дополнительного словаря привязки
    ,NSYNC            UDO_T_TYPE_ATTR.SYNC%type --признак синхронизации (см. константы NSYNC_*)
    ,NSYSTEM          UDO_T_TYPE_ATTR.SYSTEM%type --признак системного атрибута (см. константы NSYSTEM_*)
    ,SVIEW_FLD_STR    varchar2(40) --имя поля представления для извлечения строковых данных
    ,SVIEW_FLD_NUMB   varchar2(40) --имя поля представления для извлечения числовых данных
    ,SVIEW_FLD_DATE   varchar2(40) --имя поля представления для извлечения данных типа дата
    ,SVIEW_FLD_SRC    varchar2(40) --имя поля представления для извлечения ссылки на источник
    );

  --тип для коллекции атрибутов
  type TYPE_ATTRS is table of TYPE_ATTR; --коллекция атрибутов
  --тип для записи системных атрибутов организации
  type SYSTEM_ATTR is record(
     NCOMPANY COMPANIES.RN%type --рег. номер организации
    ,TA       TYPE_ATTRS --коллекция системных атрибутов для данной организации
    );

  --тип для коллекции системных атрибутов
  type SYSTEM_ATTRS is table of SYSTEM_ATTR; --коллекция системных атрибутов
  --типы данных атрибутов
  NDATA_TYPE_STR  constant number(1) := 0; --тип данных атрибута - строка
  NDATA_TYPE_NUMB constant number(1) := 1; --тип данных атрибута - число
  NDATA_TYPE_DATE constant number(1) := 2; --тип данных атрибута - дата
  --типы привязок атрибутов
  NLNK_TYPE_NONE  constant number(1) := 0; --тип привязки атрибута - нет привязки
  NLNK_TYPE_UNIT  constant number(1) := 1; --тип привязки атрибута - раздел
  NLNK_TYPE_EDICT constant number(1) := 2; --тип привязки атрибута - дополнительный словарь
  --признаки синхронизации атрибутов со связанными словарям
  NSYNC_DO constant number(1) := 1; --синхронизироать/проверять значения
  NSYNC_NO constant number(1) := 0; --не синхронизироать/проверять значения
  --системность атрибутов
  NSYSTEM_RESERVED constant number(1) := 1; --зарезервированный системный атрибут
  NSYSTEM_USER     constant number(1) := 0; --пользовательский атрибут
  --коды системных атрибутов
  /*
  Сюда обязательно добавлять атрибуты, если меняется физическая структура таблицы UDO_T_MARK
  При добавлении новых полей в UDO_T_MARK не забывайте:
  1. Добавлять в этот список констант новые атрибуты
  2. Добавлять их настройки в TYPE_ATTR_SYSTEM_BUILD
  3. Добавлять их (если это внешние ключи) в запрос по системным атрибутам внутри UDO_PKG_MARK_FLT.MARK_FLT_CHECK_DISPLAY
  4. Добавлять их в представление UDO_V_MARK_SHADOW (естественно и в основное клиентское представление UDO_V_MARK)
  */
  SSYS_TATTR_JUR_PERS        constant UDO_T_TYPE_ATTR.CODE%type := 'NJUR_PERS'; --юридическое лицо
  SSYS_TATTR_MARK_VERS       constant UDO_T_TYPE_ATTR.CODE%type := 'NMARK_VERS'; --версия
  SSYS_TATTR_MARK_TYPE       constant UDO_T_TYPE_ATTR.CODE%type := 'NMARK_TYPE'; --тип
  SSYS_TATTR_MARK_PREF       constant UDO_T_TYPE_ATTR.CODE%type := 'SMARK_PREF'; --префикс
  SSYS_TATTR_MARK_NUMB       constant UDO_T_TYPE_ATTR.CODE%type := 'SMARK_NUMB'; --номер
  SSYS_TATTR_MARK_DATE       constant UDO_T_TYPE_ATTR.CODE%type := 'DMARK_DATE'; --дата показателя
  SSYS_TATTR_STATE_DATE      constant UDO_T_TYPE_ATTR.CODE%type := 'DSTATE_DATE'; --по состоянию на
  SSYS_TATTR_DO_ACT_FROM     constant UDO_T_TYPE_ATTR.CODE%type := 'DDO_ACT_FROM'; --дата начала действия
  SSYS_TATTR_DO_ACT_TO       constant UDO_T_TYPE_ATTR.CODE%type := 'DDO_ACT_TO'; --дата окончания действия
  SSYS_TATTR_DATE_FROM       constant UDO_T_TYPE_ATTR.CODE%type := 'DDATE_FROM'; --начало периода
  SSYS_TATTR_DATE_TO         constant UDO_T_TYPE_ATTR.CODE%type := 'DDATE_TO'; --окончание периода
  SSYS_TATTR_SUBDIV          constant UDO_T_TYPE_ATTR.CODE%type := 'NSUBDIV'; --подразделение
  SSYS_TATTR_AGENT           constant UDO_T_TYPE_ATTR.CODE%type := 'NAGENT'; --контрагент
  SSYS_TATTR_AGNACC          constant UDO_T_TYPE_ATTR.CODE%type := 'NAGNACC'; --реквизиты контрагента
  SSYS_TATTR_PAYTOOL         constant UDO_T_TYPE_ATTR.CODE%type := 'NPAYTOOL'; --инструмент оплаты
  SSYS_TATTR_FINFLOWTYPE     constant UDO_T_TYPE_ATTR.CODE%type := 'NFINFLOWTYPE'; --вид движения
  SSYS_TATTR_FINOPER         constant UDO_T_TYPE_ATTR.CODE%type := 'NFINOPER'; --финансовая операция
  SSYS_TATTR_FINSTATE        constant UDO_T_TYPE_ATTR.CODE%type := 'NFINSTATE'; --состояние
  SSYS_TATTR_FPDARTCL        constant UDO_T_TYPE_ATTR.CODE%type := 'NFPDARTCL'; --статья движения
  SSYS_TATTR_FACEACC         constant UDO_T_TYPE_ATTR.CODE%type := 'NFACEACC'; --лицевой счет движения
  SSYS_TATTR_GRAPHPOINT      constant UDO_T_TYPE_ATTR.CODE%type := 'NGRAPHPOINT'; --точка графика лицевого счета движения
  SSYS_TATTR_COST_PLACE      constant UDO_T_TYPE_ATTR.CODE%type := 'NCOST_PLACE'; --место возникновения затрат
  SSYS_TATTR_COST_FPDARTCL   constant UDO_T_TYPE_ATTR.CODE%type := 'NCOST_FPDARTCL'; --статья затрат
  SSYS_TATTR_COST_FACEACC    constant UDO_T_TYPE_ATTR.CODE%type := 'NCOST_FACEACC'; --лицевой счет затрат
  SSYS_TATTR_COST_GRAPHPOINT constant UDO_T_TYPE_ATTR.CODE%type := 'NCOST_GRAPHPOINT'; --точка графика лицевого счета затрат
  SSYS_TATTR_COST_GR         constant UDO_T_TYPE_ATTR.CODE%type := 'NCOST_GR'; --группа затрат
  SSYS_TATTR_VAL             constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL'; --значение
  SSYS_TATTR_VAL_MOD         constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_MOD'; --значение (измененное)
  SSYS_TATTR_VAL_DIFF        constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_DIFF'; --отклонение
  SSYS_TATTR_MEAS            constant UDO_T_TYPE_ATTR.CODE%type := 'NMEAS'; --единица измерения
  SSYS_TATTR_CURRENCY        constant UDO_T_TYPE_ATTR.CODE%type := 'NCURRENCY'; --валюта
  SSYS_TATTR_VAL_ACC         constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_ACC'; --значение показателя в валюте договора/лицевого счета (расчитанное системой)
  SSYS_TATTR_VAL_MOD_ACC     constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_MOD_ACC'; --значение показателя в валюте договора/лицевого счета (измененное пользователем)
  SSYS_TATTR_VAL_DIFF_ACC    constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_DIFF_ACC'; --отклонение в валюте договора/лицевого счета
  SSYS_TATTR_CURRENCY_ACC    constant UDO_T_TYPE_ATTR.CODE%type := 'NCURRENCY_ACC'; --валюта договора/лицевого счета
  SSYS_TATTR_CURBASE_ACC     constant UDO_T_TYPE_ATTR.CODE%type := 'NCURBASE_ACC'; --курс валюты договора/лицевого счета к курсу БВ
  SSYS_TATTR_CURCOURS_ACC    constant UDO_T_TYPE_ATTR.CODE%type := 'NCURCOURS_ACC'; --котировка валюты договора/лицевого счета к БВ
  SSYS_TATTR_VAL_DOC         constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_DOC'; --значение показателя в валюте документа/платежа/инструмента оплаты (расчитанное системой)
  SSYS_TATTR_VAL_MOD_DOC     constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_MOD_DOC'; --значение показателя в валюте документа/платежа/инструмента оплаты (измененное пользователем)
  SSYS_TATTR_VAL_DIFF_DOC    constant UDO_T_TYPE_ATTR.CODE%type := 'NVAL_DIFF_DOC'; --отклонение в валюте документа/платежа/инструмента оплаты
  SSYS_TATTR_CURRENCY_DOC    constant UDO_T_TYPE_ATTR.CODE%type := 'NCURRENCY_DOC'; --валюта документа/платежа/инструмента оплаты
  SSYS_TATTR_CURBASE_DOC     constant UDO_T_TYPE_ATTR.CODE%type := 'NCURBASE_DOC'; --курс валюты документа/платежа/инструмента оплаты к курсу БВ
  SSYS_TATTR_CURCOURS_DOC    constant UDO_T_TYPE_ATTR.CODE%type := 'NCURCOURS_DOC'; --котировка валюты документа/платежа/инструмента оплаты к БВ
  SSYS_TATTR_BALUNIT         constant UDO_T_TYPE_ATTR.CODE%type := 'NBALUNIT'; --рег. номер ПБЕ
  SSYS_TATTR_ACCOUNT         constant UDO_T_TYPE_ATTR.CODE%type := 'NACCOUNT'; --рег. номер  счета
  SSYS_TATTR_ANALYTIC1       constant UDO_T_TYPE_ATTR.CODE%type := 'NANALYTIC1'; --рег. номер аналитики 1 уровня,
  SSYS_TATTR_ANALYTIC2       constant UDO_T_TYPE_ATTR.CODE%type := 'NANALYTIC2'; -- рег. номер аналитики 2 уровня,
  SSYS_TATTR_ANALYTIC3       constant UDO_T_TYPE_ATTR.CODE%type := 'NANALYTIC3'; --ег. номер аналитики 3 уровня,
  SSYS_TATTR_ANALYTIC4       constant UDO_T_TYPE_ATTR.CODE%type := 'NANALYTIC4'; --рег. номер аналитики 4 уровня,
  SSYS_TATTR_ANALYTIC5       constant UDO_T_TYPE_ATTR.CODE%type := 'NANALYTIC5'; --рег. номер аналитики 5 уровня
  SSYS_TATTR_PAY_TYPE        constant UDO_T_TYPE_ATTR.CODE%type := 'NPAY_TYPE'; --рег. номер вида оплаты
  SSYS_TATTR_PAY_SIGN        constant UDO_T_TYPE_ATTR.CODE%type := 'NPAY_SIGN'; --тип платежа
  SSYS_TATTR_NOTE            constant UDO_T_TYPE_ATTR.CODE%type := 'SNOTE'; --примечание
  --флаг процесса инициализации системных атрибутов
  BINIT_MODE boolean := false;

  --коллекция системных атрибутов для всех организаций
  SA SYSTEM_ATTRS;

  --считывание раздела
  function UTL_UNIT_GET
  (
    NRN    number --рег. номер раздела
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UNITLIST%rowtype RESULT_CACHE;

  --считывание метода вызова раздела
  function UTL_UNIT_SHOWMETHODS_GET
  (
    NRN    number --рег. номер метода вызова раздела
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UNIT_SHOWMETHODS%rowtype;

  --считывание параметра метода вызова раздела
  function UTL_UNIT_PARAMS_GET
  (
    NRN    number --рег. номер параметра метода вызова раздела
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UNITPARAMS%rowtype RESULT_CACHE;

  --считывание записи дополнительного словаря
  function UTL_EXTRA_DICTS_GET
  (
    NRN    number --рег. номер дополнительного словаря
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return EXTRA_DICTS%rowtype RESULT_CACHE;

  --формирование списка системных атрибутов раздела "Типовые атрибуты"
  procedure TYPE_ATTR_SYSTEM_BUILD(SYSTEM_TYPE_ATTRS out TYPE_ATTRS --коллекция системных атрибутов
                                   );

  --инициализация системных атрибутов в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_SYSTEM_INIT
  (
    NCRN     number := null --рег. номер каталога размещения
   ,NCOMPANY number := null --рег. номер организации
  );

  --проверка атрибута на вхождение в список зарезервированных системных в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_SYSTEM_CHECK
  (
    SCODE varchar2 --мнемокод проверяемого атрибута
   ,SNAME varchar2 --наименование проверяемого атрибута
  );

  --считывание параметров системного атрибута по коду
  procedure TYPE_ATTR_SYSTEM_GET
  (
    NCOMPANY number --рег. номер организации
   ,SCODE    varchar2 --мнемокод искомого атрибута
   ,TA       out TYPE_ATTR --запись найденного системного атрибута
  );

  --считывание записи в разделе "Типовые атрибуты"
  function TYPE_ATTR_GET
  (
    NRN    number --рег. номер типового атрибута
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UDO_T_TYPE_ATTR%rowtype RESULT_CACHE;

  --считывание записи в разделе "Типовые атрибуты" (по мнемокоду)
  function TYPE_ATTR_GET
  (
    NCOMPANY number --рег. номер организации
   ,SCODE    varchar2 --мнемокод
   ,NSMART   number := 1 --признак выдачи сообщения об ошибке
  ) return UDO_T_TYPE_ATTR%rowtype RESULT_CACHE;

  --считывание записи в разделе "Типовые атрибуты" (по наименованию)
  function TYPE_ATTR_GET
  (
    NCOMPANY number --рег. номер организации
   ,SNAME    varchar2 --наименование
   ,NSMART   number := 1 --признак выдачи сообщения об ошибке
  ) return UDO_T_TYPE_ATTR%rowtype RESULT_CACHE;

  --инициализация форм размножения/исправления в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_IU_FORM_INIT
  (
    NRN         number --рег. номер типового атрибута
   ,SUNITNAME   out varchar2 --наименование раздела
   ,SMETHOD     out varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM out varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   out varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    out varchar2 --мнемокод дополнительного словаря привязки
   ,NSYNC       out number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
  );

  --разрешение ссылок в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_JOINS
  (
    NCOMPANY    number -- рег. номер организации
   ,SUNITNAME   varchar2 --наименование/мнемокод раздела
   ,SMETHOD     varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
   ,SUNIT       out varchar2 -- код раздела
   ,NMETHOD     out number --рег. номер метода вызова привязки
   ,NMETHOD_PRM out number --рег. номер параметра метода вызова
   ,NINIT_PRM   out number --рег. номер родительского атрибута привязки
   ,NEX_DICT    out number --рег. номер дополнительного словаря привязки
  );

  --корректировка и проверка непротиворечивости привязок в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_LNK_TYPE_CHECK
  (
    REC     in out UDO_T_TYPE_ATTR%rowtype --проверяемая запись
   ,SACTION varchar2 --код действия
  );

  --базовое добавление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_INSERT
  (
    NCRN        number --рег. номер каталога размещения
   ,NCOMPANY    number --рег. номер организации
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNIT       varchar2 --код раздела привязки
   ,NMETHOD     number --рег. номер метода вызова привязки
   ,NMETHOD_PRM number --рег. номер параметра метода вызова
   ,NINIT_PRM   number --рег. номер родительского атрибута привязки
   ,NEX_DICT    number --рег. номер дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
   ,NSYSTEM     number --признак системного атрибута (см. констатнты NSYSTEM_*)
   ,NRN         out number --рег. номер типового атрибута
  );

  --базовое исправление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_UPDATE
  (
    NRN         number --рег. номер типового атрибута
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNIT       varchar2 --код раздела привязки
   ,NMETHOD     number --рег. номер метода вызова привязки
   ,NMETHOD_PRM number --рег. номер параметра метода вызова
   ,NINIT_PRM   number --рег. номер родительского атрибута привязки
   ,NEX_DICT    number --рег. номер дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
   ,NSYSTEM     number --признак системного атрибута (см. констатнты NSYSTEM_*)
  );

  --базовое удаление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_DELETE(NRN number --рег. номер типового атрибуты
                                  );

  --базовая инициализация системных атрибутов в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_INIT
  (
    NCRN     number --рег. номер каталога размещения
   ,NCOMPANY number --рег. номер организации
  );

  --клиентское добалвение в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_INSERT
  (
    NCRN        number --рег. номер каталога размещения
   ,NCOMPANY    number --рег. номер организации
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNITNAME   varchar2 --наименование раздела
   ,SMETHOD     varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
   ,NRN         out number --рег. номер типового атрибута
  );

  --клиентское исправление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_UPDATE
  (
    NRN         number --рег. номер типового атрибута
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNITNAME   varchar2 --наименование раздела
   ,SMETHOD     varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
  );

  --клиентское удаление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_DELETE(NRN number --рег. номер типового атрибута
                             );

  --клиентская инициализация системных атрибутов в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_INIT
  (
    NCRN     number --рег. номер каталога размещения
   ,NCOMPANY number --рег. номер организации
  );

end;
/

create or replace package body UDO_PKG_TYPE_ATTR as

  --считывание раздела
  function UTL_UNIT_GET
  (
    NRN    number --рег. номер раздела
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UNITLIST%rowtype RESULT_CACHE RELIES_ON(UNITLIST) is
    REC UNITLIST%rowtype; --результат работы
  begin
    select T.*
      into REC
      from UNITLIST T
     where T.RN = NRN;
    return REC;
  exception
    when NO_DATA_FOUND then
      REC.RN := null;
      if (NSMART = 1)
      then
        return REC;
      else
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NRN
                                ,SUNIT_TABLE => 'UNITLIST');
      end if;
  end;

  --считывание метода вызова раздела
  function UTL_UNIT_SHOWMETHODS_GET
  (
    NRN    number --рег. номер метода вызова раздела
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UNIT_SHOWMETHODS%rowtype is
    REC UNIT_SHOWMETHODS%rowtype; --результат работы
  begin
    select T.*
      into REC
      from UNIT_SHOWMETHODS T
     where T.RN = NRN;
    return REC;
  exception
    when NO_DATA_FOUND then
      REC.RN := null;
      if (NSMART = 1)
      then
        return REC;
      else
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NRN
                                ,SUNIT_TABLE => 'UNIT_SHOWMETHODS');
      end if;
  end;

  --считывание параметра метода вызова раздела
  function UTL_UNIT_PARAMS_GET
  (
    NRN    number --рег. номер параметра метода вызова раздела
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UNITPARAMS%rowtype RESULT_CACHE RELIES_ON(UNITPARAMS) is
    REC UNITPARAMS%rowtype; --результат работы
  begin
    select T.*
      into REC
      from UNITPARAMS T
     where T.RN = NRN;
    return REC;
  exception
    when NO_DATA_FOUND then
      REC.RN := null;
      if (NSMART = 1)
      then
        return REC;
      else
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NRN
                                ,SUNIT_TABLE => 'UNITPARAMS');
      end if;
  end;

  --считывание записи дополнительного словаря
  function UTL_EXTRA_DICTS_GET
  (
    NRN    number --рег. номер дополнительного словаря
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return EXTRA_DICTS%rowtype RESULT_CACHE RELIES_ON(EXTRA_DICTS) is
    REC EXTRA_DICTS%rowtype; --результат работы
  begin
    select T.*
      into REC
      from EXTRA_DICTS T
     where T.RN = NRN;
    return REC;
  exception
    when NO_DATA_FOUND then
      REC.RN := null;
      if (NSMART = 1)
      then
        return REC;
      else
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NRN
                                ,SUNIT_TABLE => 'EXTRA_DICTS');
      end if;
  end;

  --формирование списка системных атрибутов раздела "Типовые атрибуты"
  procedure TYPE_ATTR_SYSTEM_BUILD(SYSTEM_TYPE_ATTRS out TYPE_ATTRS --коллекция системных атрибутов
                                   ) is
  begin
    --инициализация коллекция
    SYSTEM_TYPE_ATTRS := TYPE_ATTRS();
    --юридическая принадлежность
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_JUR_PERS;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Юридическое лицо';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'JuridicalPersons';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Юридические лица';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод юридического лица';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SJUR_PERS';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NJUR_PERS';
    --версия
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_MARK_VERS;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Версия';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'MarkVersions';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'MarkVersions';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод версии';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SMARK_VERS';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NMARK_VERS';
    --тип показателя
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_MARK_TYPE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Тип показателя';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'MarkTypes';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'MarkTypes';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SMARK_TYPE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NMARK_TYPE';
    --префикс
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_MARK_PREF;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Префикс';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SMARK_PREF';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --номер
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_MARK_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Номер';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SMARK_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --дата показателя
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_MARK_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Дата';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := 'DMARK_DATE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --по состоянию на
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_STATE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'По состоянию на';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := 'DSTATE_DATE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --дата начала действия
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_DO_ACT_FROM;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Действует с';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := 'DDO_ACT_FROM';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --дата окончания действия
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_DO_ACT_TO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Действует по';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := 'DDO_ACT_TO';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --начало периода
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_DATE_FROM;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Начало периода';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := 'DDATE_FROM';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --окончание периода
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_DATE_TO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Окончание периода';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_DATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := 'DDATE_TO';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --подразделение
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_SUBDIV;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Подразделение';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'INS_DEPARTMENT';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Штатные подразделения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод штатного подразделения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SSUBDIV';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NSUBDIV';
    --контрагент
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_AGENT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Контрагент';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AGNLIST';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Контрагенты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод контрагента';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SAGENT';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NAGENT';
    --реквизиты контрагента
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_AGNACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Реквизиты контрагента';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AGNLIST';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Контрагенты (реквизиты банковских счетов)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Код реквизитов банковских счетов контрагента';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Контрагент';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SAGNACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NAGNACC';
    --инструмент оплаты
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_PAYTOOL;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Инструмент оплаты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FinancialPayTools';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Инструменты оплаты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод инструмента оплаты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SPAYTOOL';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NPAYTOOL';
    --вид виджения
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_FINFLOWTYPE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Вид движения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FinancialFlowTypes';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Виды движения по элементу';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод вида движения по элементу';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SFINFLOWTYPE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NFINFLOWTYPE';
    --финансовая операция    
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_FINOPER;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Финансовая операция';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'TypeOpersPay';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Виды финансовых операций';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод вида финансовых операций';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SFINOPER';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NFINOPER';
    --состояние
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_FINSTATE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Состояние';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FinancialStates';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Состояния финансовых показателей';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод состояния финансовых показателей';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SFINSTATE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NFINSTATE';
    --статья движения
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_FPDARTCL;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Статья движения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FinPlanArticles';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Элементы дохода и расхода, статьи затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод элемента ДиР, статьи затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SFPDARTCL';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NFPDARTCL';
    --лицевой счет движения
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_FACEACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Лицевой счет движения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FaceAccounts';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Лицевые счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер лицевого счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SFACEACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NFACEACC';
    --точка графика лицевого счета движения
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_GRAPHPOINT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Точка графика лицевого счета движения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FaceAccounts';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Лицевые счета (точки графиков)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод точки графика лицевого счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Лицевой счет движения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SGRAPHPOINT';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NGRAPHPOINT';
    --место возникновения затрат
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_COST_PLACE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Место возникновения затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FinPlanAccountCenters';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Места возникновения затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод места возникновения затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCOST_PLACE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCOST_PLACE';
    --статья затрат
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_COST_FPDARTCL;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Статья затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FinPlanArticles';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Элементы дохода и расхода, статьи затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод элемента ДиР, статьи затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCOST_FPDARTCL';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCOST_FPDARTCL';
    --лицевой счет затрат
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_COST_FACEACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Лицевой счет затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FaceAccounts';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Лицевые счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер лицевого счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCOST_FACEACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCOST_FACEACC';
    --точка графика лицевого счета затрат
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_COST_GRAPHPOINT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Точка графика лицевого счета затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'FaceAccounts';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Лицевые счета (точки графиков)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод точки графика лицевого счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Лицевой счет затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCOST_GRAPHPOINT';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCOST_GRAPHPOINT';
    --группа затрат
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_COST_GR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Группа затрат';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'CostGroups';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'main';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCOST_GR';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCOST_GR';
    --значение
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Значение';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --значение (измененное)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_MOD;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Значение (измененное)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_MOD';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --отклонение
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_DIFF;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Отклонение';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_DIFF';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --единица измерения
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_MEAS;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Единица измерения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'MeasureUnits';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Единицы измерения';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод ЕИ';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SMEAS';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NMEAS';
    --валюта
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURRENCY;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Валюта';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'CURNAMES';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Наименования валют';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Код ИСО валюты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCURRENCY';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCURRENCY';
    --значение показателя в валюте договора/лицевого счета (расчитанное системой)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_ACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Значение в валюте договора';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_ACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --значение показателя в валюте договора/лицевого счета (измененное)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_MOD_ACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Значение в валюте договора (измененное)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_MOD_ACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --отклонение показателя в валюте договора/лицевого счета (расчитанное системой)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_DIFF_ACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Отклонение в валюте договора';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_DIFF_ACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --валюта договора/лицевого счета
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURRENCY_ACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Валюта договора';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'CURNAMES';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Наименования валют';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Код ИСО валюты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCURRENCY_ACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCURRENCY_ACC';
    --курс валюты договора/лицевого счета к курсу БВ
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURBASE_ACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Курс валюты договора';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NCURBASE_ACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --котировка валюты договора/лицевого счета к БВ
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURCOURS_ACC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Котировка валюты договора';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NCURCOURS_ACC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --значение показателя в валюте документа/платежа/инструмента оплаты (расчитанное системой)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_DOC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Значение в валюте платежа';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_DOC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --значение показателя в валюте документа/платежа/инструмента оплаты (измененное)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_MOD_DOC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Значение в валюте платежа (измененное)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_MOD_DOC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --отклонение показателя в валюте документа/платежа/инструмента оплаты (расчитанное системой)
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_VAL_DIFF_DOC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Отклонение в валюте платежа';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NVAL_DIFF_DOC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --валюта документа/платежа/инструмента оплаты
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURRENCY_DOC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Валюта платежа';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'CURNAMES';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Наименования валют';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Код ИСО валюты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SCURRENCY_DOC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NCURRENCY_DOC';
    --курс валюты документа/платежа/инструмента оплаты к курсу БВ
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURBASE_DOC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Курс валюты платежа';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NCURBASE_DOC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --котировка документа/платежа/инструмента оплаты к БВ
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_CURCOURS_DOC;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Котировка валюты платежа';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NCURCOURS_DOC';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --рег. номер ПБЕ
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_BALUNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'ПБЕ';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'BalanceUnits';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Подразделения балансовой единицы';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод ПБЕ';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SBALUNIT_CODE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NBALUNIT';
    --счет
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_ACCOUNT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AccountsPlan';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'План счетов';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SACCOUNT_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NACCOUNT';
    --рег. номер аналитики 1 уровня
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_ANALYTIC1;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Аналитика 1 уровня';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AccountsPlan';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'План счетов (аналитические счета)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер аналитического счёта';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SANALYTIC1_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NANALYTIC1';
    --рег. номер аналитики 2 уровня
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_ANALYTIC2;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Аналитика 2 уровня';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AccountsPlan';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'План счетов (аналитические счета)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер аналитического счёта';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SANALYTIC2_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NANALYTIC2';
    --рег. номер аналитики 3 уровня
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_ANALYTIC3;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Аналитика 3 уровня';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AccountsPlan';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'План счетов (аналитические счета)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер аналитического счёта';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SANALYTIC3_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NANALYTIC3';
    --рег. номер аналитики 4 уровня
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_ANALYTIC4;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Аналитика 4 уровня';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AccountsPlan';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'План счетов (аналитические счета)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер аналитического счёта';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SANALYTIC4_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NANALYTIC4';
    --рег. номер аналитики 5 уровня
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_ANALYTIC5;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Аналитика 5 уровня';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AccountsPlan';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'План счетов (аналитические счета)';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Номер аналитического счёта';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := 'Номер счета';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SANALYTIC5_NUMB';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NANALYTIC5';
    --рег. номер вида оплаты
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_PAY_TYPE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Вид оплаты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_UNIT;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SUNIT := 'AZSGSMPAYMENTSTYPES';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_NAME := 'Виды оплаты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SMETHOD_PRM_NAME := 'Мнемокод вида оплаты';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SINIT_PRM_NAME := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SEX_DICT := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_DO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SPAY_TYPE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := 'NPAY_TYPE';
    --тип платежа
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_PAY_SIGN;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Тип платежа';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_NUMB;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := 'NPAY_SIGN';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
    --примечание
    SYSTEM_TYPE_ATTRS.EXTEND();
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SCODE := SSYS_TATTR_NOTE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SNAME := 'Примечание';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NDATA_TYPE := NDATA_TYPE_STR;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NLNK_TYPE := NLNK_TYPE_NONE;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYNC := NSYNC_NO;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).NSYSTEM := NSYSTEM_RESERVED;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_STR := 'SNOTE';
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_NUMB := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_DATE := null;
    SYSTEM_TYPE_ATTRS(SYSTEM_TYPE_ATTRS.LAST).SVIEW_FLD_SRC := null;
  end;

  --инициализация системных атрибутов в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_SYSTEM_INIT
  (
    NCRN     number := null --рег. номер каталога размещения
   ,NCOMPANY number := null --рег. номер организации
  ) is
    A           TYPE_ATTRS := TYPE_ATTRS(); --коллекция системных атрибутов
    NCRN_       ACATALOG.RN%type; --каталог размещения атрибутов
    REC         UDO_T_TYPE_ATTR%rowtype; --запись типового атрибута
    SUNIT       UDO_T_TYPE_ATTR.UNIT%type; -- код раздела
    NMETHOD     UDO_T_TYPE_ATTR.METHOD%type; --рег. номер метода вызова привязки
    NMETHOD_PRM UDO_T_TYPE_ATTR.METHOD_PRM%type; --рег. номер параметра метода вызова
    NINIT_PRM   UDO_T_TYPE_ATTR.INIT_PRM%type; --рег. номер родительского атрибута привязки
    NEX_DICT    UDO_T_TYPE_ATTR.EX_DICT%type; --рег. номер дополнительного словаря привязки
    NTMP        number; --буфер для расчетов
  begin
    --инициализируем справочник во всех организациях
    for C in (select RN
                from COMPANIES T
               where ((NCOMPANY is null) or ((NCOMPANY is not null) and (T.RN = NCOMPANY))))
    loop
      --загрузим коллекцию системных атрибутов
      TYPE_ATTR_SYSTEM_BUILD(SYSTEM_TYPE_ATTRS => A);
      --найдем каталог размещения типовых показателей
      if (NCRN is null)
      then
        FIND_ROOT_CATALOG(NCOMPANY => C.RN
                         ,SCODE    => 'MarkTypeAttrs'
                         ,NCRN     => NCRN_);
      else
        NCRN_ := NCRN;
      end if;
      --удаляем атрибуты, которых уже нет среди системных
      for RA in (select T.RN
                       ,T.CODE
                   from UDO_T_TYPE_ATTR T
                  where T.COMPANY = C.RN
                    and T.SYSTEM = NSYSTEM_RESERVED)
      loop
        --обнулим счетчик найденных
        NTMP := 0;
        --обойдем коллекцию системных и найдем данный атрибут
        if (A.COUNT > 0)
        then
          for I in A.FIRST .. A.LAST
          loop
            if (A(I).SCODE = RA.CODE)
            then
              NTMP := NTMP + 1;
            end if;
          end loop;
        end if;
        --если не нашли
        if (NTMP = 0)
        then
          --в этой организации удалим данный системный атрибуты в типах показателей
          for MT in (select M.RN
                       from UDO_T_MARK_TYPE M
                      where M.COMPANY = C.RN)
          loop
            UDO_PKG_MARK_TYPE.BINIT_MODE := true;
            begin
              UDO_PKG_MARK_TYPE.MARK_TYPE_ATTRS_BASE_REMOVE(NPRN       => MT.RN
                                                           ,NTYPE_ATTR => RA.RN
                                                           ,NSYSTEM    => NSYSTEM_RESERVED);
            exception
              when others then
                UDO_PKG_MARK_TYPE.BINIT_MODE := false;
                raise;
            end;
            UDO_PKG_MARK_TYPE.BINIT_MODE := false;
          end loop;
          --удаляем сам атрибут
          begin
            BINIT_MODE := true;
            TYPE_ATTR_BASE_DELETE(NRN => RA.RN);
            BINIT_MODE := false;
          exception
            when others then
              BINIT_MODE := false;
              raise;
          end;
        end if;
      end loop;
      --обходим коллекцию и добавляем системные атрибуты, если их ещё нет
      if (A.COUNT > 0)
      then
        for I in A.FIRST .. A.LAST
        loop
          --проверим наличие атрибута с таким мнемокодом в данной организации
          REC := TYPE_ATTR_GET(NCOMPANY => C.RN
                              ,SCODE    => A(I).SCODE
                              ,NSMART   => 1);
          if (REC.RN is null)
          then
            --проверим наличие атрибута с таким наименованием в данной организации
            REC := TYPE_ATTR_GET(NCOMPANY => C.RN
                                ,SNAME    => A(I).SNAME
                                ,NSMART   => 1);
            if (REC.RN is null)
            then
              --ни по коду, ни по наименованию совпадений нет - добавляем системный атрибут
              BINIT_MODE := true;
              begin
                --разыменуем ссылки
                TYPE_ATTR_JOINS(NCOMPANY    => C.RN
                               ,SUNITNAME   => A(I).SUNIT
                               ,SMETHOD     => A(I).SMETHOD_NAME
                               ,SMETHOD_PRM => A(I).SMETHOD_PRM_NAME
                               ,SINIT_PRM   => A(I).SINIT_PRM_NAME
                               ,SEX_DICT    => A(I).SEX_DICT
                               ,SUNIT       => SUNIT
                               ,NMETHOD     => NMETHOD
                               ,NMETHOD_PRM => NMETHOD_PRM
                               ,NINIT_PRM   => NINIT_PRM
                               ,NEX_DICT    => NEX_DICT);
                --базово добавим            
                TYPE_ATTR_BASE_INSERT(NCRN        => NCRN_
                                     ,NCOMPANY    => C.RN
                                     ,SCODE       => A(I).SCODE
                                     ,SNAME       => A(I).SNAME
                                     ,NDATA_TYPE  => A(I).NDATA_TYPE
                                     ,NLNK_TYPE   => A(I).NLNK_TYPE
                                     ,SUNIT       => SUNIT
                                     ,NMETHOD     => NMETHOD
                                     ,NMETHOD_PRM => NMETHOD_PRM
                                     ,NINIT_PRM   => NINIT_PRM
                                     ,NEX_DICT    => NEX_DICT
                                     ,NSYNC       => A(I).NSYNC
                                     ,NSYSTEM     => A(I).NSYSTEM
                                     ,NRN         => A(I).NRN);
                BINIT_MODE := false;
              exception
                when others then
                  BINIT_MODE := false;
                  raise;
              end;
            else
              P_EXCEPTION(0
                         ,'Нарушение целостности набора системных типовых атрибутов показателей! Для атрибута с наименованием "%s" задан мнемокод "%s", отличный от системного "%s"!'
                         ,A                                                                                                                                                                                                                                                                                 (I)
                          .SNAME
                         ,REC.CODE
                         ,A                                                                                                                                                                                                                                                                                 (I)
                          .SCODE);
            end if;
          else
            --мнемокод встретился - будем обновлять
            BINIT_MODE := true;
            begin
              --исправим каталог размещения
              update UDO_T_TYPE_ATTR T
                 set T.CRN = NCRN_
               where T.RN = REC.RN;
              --разыменуем ссылки
              TYPE_ATTR_JOINS(NCOMPANY    => C.RN
                             ,SUNITNAME   => A(I).SUNIT
                             ,SMETHOD     => A(I).SMETHOD_NAME
                             ,SMETHOD_PRM => A(I).SMETHOD_PRM_NAME
                             ,SINIT_PRM   => A(I).SINIT_PRM_NAME
                             ,SEX_DICT    => A(I).SEX_DICT
                             ,SUNIT       => SUNIT
                             ,NMETHOD     => NMETHOD
                             ,NMETHOD_PRM => NMETHOD_PRM
                             ,NINIT_PRM   => NINIT_PRM
                             ,NEX_DICT    => NEX_DICT);
              --базово исправим
              TYPE_ATTR_BASE_UPDATE(NRN         => REC.RN
                                   ,SCODE       => A(I).SCODE
                                   ,SNAME       => A(I).SNAME
                                   ,NDATA_TYPE  => A(I).NDATA_TYPE
                                   ,NLNK_TYPE   => A(I).NLNK_TYPE
                                   ,SUNIT       => SUNIT
                                   ,NMETHOD     => NMETHOD
                                   ,NMETHOD_PRM => NMETHOD_PRM
                                   ,NINIT_PRM   => NINIT_PRM
                                   ,NEX_DICT    => NEX_DICT
                                   ,NSYNC       => A(I).NSYNC
                                   ,NSYSTEM     => A(I).NSYSTEM);
              BINIT_MODE := false;
            exception
              when others then
                BINIT_MODE := false;
                raise;
            end;
          end if;
        end loop;
      end if;
      --в этой организации инициализируем системные атрибуты в типах показателей
      for MT in (select M.RN
                   from UDO_T_MARK_TYPE M
                  where M.COMPANY = C.RN)
      loop
        UDO_PKG_MARK_TYPE.MARK_TYPE_ATTRS_INIT(NPRN => MT.RN);
      end loop;
    end loop;
  end;

  --проверка атрибута на вхождение в список зарезервированных системных в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_SYSTEM_CHECK
  (
    SCODE varchar2 --мнемокод проверяемого атрибута
   ,SNAME varchar2 --наименование проверяемого атрибута
  ) is
    A TYPE_ATTRS := TYPE_ATTRS(); --коллекция системных атрибутов
  begin
    --загрузим коллекцию системных атрибутов
    TYPE_ATTR_SYSTEM_BUILD(SYSTEM_TYPE_ATTRS => A);
    --обходим коллекцию и добавляем системные атрибуты, если их ещё нет
    if (A.COUNT > 0)
    then
      for I in A.FIRST .. A.LAST
      loop
        if (A(I).SCODE = SCODE)
        then
          P_EXCEPTION(0
                     ,'Мнемокод типового атрибута "%s" зарезервирован системой! Укажите иной мнемокод!'
                     ,SCODE);
        end if;
        if (A(I).SNAME = SNAME)
        then
          P_EXCEPTION(0
                     ,'Наименование типового атрибута "%s" зарезервировано системой! Укажите иной мнемокод!'
                     ,SNAME);
        end if;
      end loop;
    end if;
  end;

  --считывание параметров системного атрибута по коду
  procedure TYPE_ATTR_SYSTEM_GET
  (
    NCOMPANY number --рег. номер организации
   ,SCODE    varchar2 --мнемокод искомого атрибута
   ,TA       out TYPE_ATTR --запись найденного системного атрибута
  ) is
  begin
    --флаг, что ничего не нашли
    TA.SCODE := null;
    --определим параметры системного атрибута по глобальной коллекции системных атриубтов - ищем нашу организацию в коллекции
    for I in SA.FIRST .. SA.LAST
    loop
      if (SA(I).NCOMPANY = NCOMPANY)
      then
        --ищем указанный системный атрибут по коду
        for J in SA(I).TA.FIRST .. SA(I).TA.LAST
        loop
          if (SA(I).TA(J).SCODE = SCODE)
          then
            TA := SA(I).TA(J);
          end if;
        end loop;
      end if;
    end loop;
  exception
    when others then
      null;
  end;

  --считывание записи в разделе "Типовые атрибуты"
  function TYPE_ATTR_GET
  (
    NRN    number --рег. номер типового атрибута
   ,NSMART number := 1 --признак выдачи сообщения об ошибке
  ) return UDO_T_TYPE_ATTR%rowtype RESULT_CACHE RELIES_ON(UDO_T_TYPE_ATTR) is
    REC UDO_T_TYPE_ATTR%rowtype; --результат работы
  begin
    select T.*
      into REC
      from UDO_T_TYPE_ATTR T
     where T.RN = NRN;
    return REC;
  exception
    when NO_DATA_FOUND then
      REC.RN := null;
      if (NSMART = 1)
      then
        return REC;
      else
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                                ,NDOCUMENT   => NRN
                                ,SUNIT_TABLE => 'UDO_T_TYPE_ATTR');
      end if;
  end;

  --считывание записи в разделе "Типовые атрибуты" (по мнемокоду)
  function TYPE_ATTR_GET
  (
    NCOMPANY number --рег. номер организации
   ,SCODE    varchar2 --мнемокод
   ,NSMART   number := 1 --признак выдачи сообщения об ошибке
  ) return UDO_T_TYPE_ATTR%rowtype RESULT_CACHE RELIES_ON(UDO_T_TYPE_ATTR) is
    REC UDO_T_TYPE_ATTR%rowtype; --результат работы
  begin
    --найдем атрибут
    for C in (select T.RN
                from UDO_T_TYPE_ATTR T
               where T.COMPANY = NCOMPANY
                 and T.CODE = SCODE)
    loop
      return TYPE_ATTR_GET(NRN    => C.RN
                          ,NSMART => NSMART);
    end loop;
    --ничего не нашли
    if (NSMART = 1)
    then
      REC.RN := null;
      return REC;
    else
      P_EXCEPTION(0
                 ,'Типовой атрибут с мнемокодом "%s" в организации (RN: %s) не определен!'
                 ,NVL(SCODE
                     ,'<НЕ УКАЗАН>')
                 ,NVL(TO_CHAR(NCOMPANY)
                     ,'<НЕ УКАЗАН>'));
    end if;
  end;

  --считывание записи в разделе "Типовые атрибуты" (по наименованию)
  function TYPE_ATTR_GET
  (
    NCOMPANY number --рег. номер организации
   ,SNAME    varchar2 --наименование
   ,NSMART   number := 1 --признак выдачи сообщения об ошибке
  ) return UDO_T_TYPE_ATTR%rowtype RESULT_CACHE RELIES_ON(UDO_T_TYPE_ATTR) is
    REC UDO_T_TYPE_ATTR%rowtype; --результат работы
  begin
    --найдем атрибут
    for C in (select T.RN
                from UDO_T_TYPE_ATTR T
               where T.COMPANY = NCOMPANY
                 and T.NAME = SNAME)
    loop
      return TYPE_ATTR_GET(NRN    => C.RN
                          ,NSMART => NSMART);
    end loop;
    --ничего не нашли
    if (NSMART = 1)
    then
      REC.RN := null;
      return REC;
    else
      P_EXCEPTION(0
                 ,'Типовой атрибут с наименованием "%s" в организации (RN: %s) не определен!'
                 ,NVL(SNAME
                     ,'<НЕ УКАЗАНО>')
                 ,NVL(TO_CHAR(NCOMPANY)
                     ,'<НЕ УКАЗАН>'));
    end if;
  end;

  --инициализация форм размножения/исправления в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_IU_FORM_INIT
  (
    NRN         number --рег. номер типового атрибута
   ,SUNITNAME   out varchar2 --наименование раздела
   ,SMETHOD     out varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM out varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   out varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    out varchar2 --мнемокод дополнительного словаря привязки
   ,NSYNC       out number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
  ) is
  begin
    --считаем запись и инициализируем выход
    for C in (select (select RS.TEXT
                        from V_RESOURCES_LOCAL RS
                       where RS.TABLE_NAME = 'UNITLIST'
                         and RS.COLUMN_NAME = 'UNITNAME'
                         and RS.RN = U.RN) SUNITNAME
                    ,(select RS.TEXT
                        from V_RESOURCES_LOCAL RS
                       where RS.TABLE_NAME = 'UNIT_SHOWMETHODS'
                         and RS.COLUMN_NAME = 'METHOD_NAME'
                         and RS.RN = UM.RN) SMETHOD
                    ,(select RS.TEXT
                        from V_RESOURCES_LOCAL RS
                       where RS.TABLE_NAME = 'UNITPARAMS'
                         and RS.COLUMN_NAME = 'PARAMNAME'
                         and RS.RN = UP.RN) SMETHOD_PRM
                    ,IP.NAME SINIT_PRM
                    ,ED.CODE SEX_DICT
                    ,T.SYNC NSYNC
                from UDO_T_TYPE_ATTR  T
                    ,UNITLIST         U
                    ,UNIT_SHOWMETHODS UM
                    ,UNITPARAMS       UP
                    ,UDO_T_TYPE_ATTR  IP
                    ,EXTRA_DICTS      ED
               where T.RN = NRN
                 and T.UNIT = U.UNITCODE(+)
                 and T.METHOD = UM.RN(+)
                 and T.METHOD_PRM = UP.RN(+)
                 and T.INIT_PRM = IP.RN(+)
                 and T.EX_DICT = ED.RN(+))
    loop
      SUNITNAME   := C.SUNITNAME;
      SMETHOD     := C.SMETHOD;
      SMETHOD_PRM := C.SMETHOD_PRM;
      SINIT_PRM   := C.SINIT_PRM;
      SEX_DICT    := C.SEX_DICT;
      NSYNC       := C.NSYNC;
    end loop;
  end;

  --разрешение ссылок в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_JOINS
  (
    NCOMPANY    number -- рег. номер организации
   ,SUNITNAME   varchar2 --наименование/мнемокод раздела
   ,SMETHOD     varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
   ,SUNIT       out varchar2 -- код раздела
   ,NMETHOD     out number --рег. номер метода вызова привязки
   ,NMETHOD_PRM out number --рег. номер параметра метода вызова
   ,NINIT_PRM   out number --рег. номер родительского атрибута привязки
   ,NEX_DICT    out number --рег. номер дополнительного словаря привязки
  ) is
    ED    EXTRA_DICTS%rowtype; --запись дополнительного словаря привязки
    PATTR UDO_T_TYPE_ATTR%rowtype; --запись родительского атрибута привязки
    NTMP  number(17); --буфер для расчетов
  begin
    --раздел
    begin
      FIND_UNITLIST_NAME(NFLAG_SMART  => 0
                        ,NFLAG_OPTION => 1
                        ,SNAME        => SUNITNAME
                        ,SCODE        => SUNIT
                        ,NRN          => NTMP);
    exception
      when others then
        FIND_UNITLIST_CODE(NFLAG_SMART  => 0
                          ,NFLAG_OPTION => 1
                          ,SCODE        => SUNITNAME
                          ,NRN          => NTMP);
        SUNIT := SUNITNAME;
    end;
    --метод вызова    
    FIND_SHOWMETHODS_NAME(NFLAG_SMART  => 0
                         ,NFLAG_OPTION => 1
                         ,SUNITCODE    => SUNIT
                         ,SMETHODNAME  => SMETHOD
                         ,NRN          => NMETHOD);
    --параметр метода вызова
    FIND_UNITPARAMS_NAME(NFLAG_SMART  => 0
                        ,NFLAG_OPTION => 1
                        ,NMETHOD      => NMETHOD
                        ,SPARAM_NAME  => SMETHOD_PRM
                        ,NRN          => NMETHOD_PRM);
    --родительский атрибут привязки
    if (SINIT_PRM is not null)
    then
      PATTR     := TYPE_ATTR_GET(NCOMPANY => NCOMPANY
                                ,SNAME    => SINIT_PRM
                                ,NSMART   => 0);
      NINIT_PRM := PATTR.RN;
    end if;
    --доп. словарь
    if (SEX_DICT is not null)
    then
      FIND_EXTRA_DICT_BY_CODE(NFLAG_SMART    => 0
                             ,NCOMPANY       => NCOMPANY
                             ,SCODE          => SEX_DICT
                             ,NRN            => ED.RN
                             ,NFORMAT        => ED.FORMAT
                             ,NNUM_WIDTH     => ED.NUM_WIDTH
                             ,NNUM_PRECISION => ED.NUM_PRECISION
                             ,NSTR_WIDTH     => ED.STR_WIDTH
                             ,SNAME          => ED.NAME);
      NEX_DICT := ED.RN;
    end if;
  end;

  --корректировка и проверка непротиворечивости привязок в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_LNK_TYPE_CHECK
  (
    REC     in out UDO_T_TYPE_ATTR%rowtype --проверяемая запись
   ,SACTION varchar2 --код действия
  ) is
    PREC   UDO_T_TYPE_ATTR%rowtype; --запись родительского (для проверяемого) типового атрибута
    UPREC  UNITPARAMS%rowtype; --запись параметра метода вызова
    EDREC  EXTRA_DICTS%rowtype; --запись дополнительного словаря
    CURREC UDO_T_TYPE_ATTR%rowtype; --текущее состояние типового атрибута
  begin
    --проверки при добавлении
    if (SACTION = 'I')
    then
      if ((REC.SYSTEM = NSYSTEM_RESERVED) and (not BINIT_MODE))
      then
        P_EXCEPTION(0
                   ,'Добавление системного атрибута недопустимо!');
      end if;
    end if;
    --проверки при исправлении
    if (SACTION = 'U')
    then
      --считаем текущее состояние атрибута
      CURREC := TYPE_ATTR_GET(NRN    => REC.RN
                             ,NSMART => 0);
      --исправлять системные атрибуты нельзя
      if ((CURREC.SYSTEM = NSYSTEM_RESERVED) and (not BINIT_MODE))
      then
        P_EXCEPTION(0
                   ,'Исправление системного атрибута недопустимо!');
      end if;
      --превращать несистемные атрибуты в системные так же нельзя
      if ((CURREC.SYSTEM = NSYSTEM_USER) and (REC.SYSTEM = NSYSTEM_RESERVED))
      then
        P_EXCEPTION(0
                   ,'Установка признака системного атрибута для типового пользовательского атрибута недопустима!');
      end if;
      --если меняется тип данных или тип привязки или способ синхронизации - надо убедиться что ещё нет в системе показателей с этим атрибутом
      if ((CURREC.DATA_TYPE <> REC.DATA_TYPE) or (CURREC.LNK_TYPE <> REC.LNK_TYPE) or
         (CMP_VC2(V1 => CURREC.UNIT
                  ,V2 => REC.UNIT) = 0) or (CMP_NUM(V1 => CURREC.METHOD
                                                    ,V2 => REC.METHOD) = 0) or
         (CMP_NUM(V1 => CURREC.METHOD_PRM
                  ,V2 => REC.METHOD_PRM) = 0) or
         (CMP_NUM(V1 => CURREC.INIT_PRM
                  ,V2 => REC.INIT_PRM) = 0) or (CMP_NUM(V1 => CURREC.EX_DICT
                                                        ,V2 => REC.EX_DICT) = 0) or (CURREC.SYNC <> REC.SYNC))
      then
        for C in (select T.RN
                    from UDO_T_MARK_ATTRS T
                   where T.TYPE_ATTR = REC.RN
                  union all
                  select T.RN
                    from UDO_T_MARK_FLT_ATTR T
                   where T.TYPE_ATTR = REC.RN)
        loop
          P_EXCEPTION(0
                     ,'Атрибут "%s" уже задействован в разделе "Показатели" - измнение типа данных или характеристик привязки недопустимо!'
                     ,CURREC.NAME);
        end loop;
      end if;
    end if;
    --проверки при удалении
    if (SACTION = 'D')
    then
      --удалять системные атрибуты нельзя
      if ((REC.SYSTEM = NSYSTEM_RESERVED) and (not BINIT_MODE))
      then
        P_EXCEPTION(0
                   ,'Удаление системного атрибута недопустимо!');
      end if;
      --нельзя удалять атрибуты, если они задействованы в показателях
      for C in (select T.RN
                  from UDO_T_MARK_ATTRS T
                 where T.TYPE_ATTR = REC.RN
                union all
                select T.RN
                  from UDO_T_MARK_FLT_ATTR T
                 where T.TYPE_ATTR = REC.RN)
      loop
        P_EXCEPTION(0
                   ,'Атрибут "%s" уже задействован в разделе "Показатели" - удаление недопустимо!'
                   ,REC.NAME);
      end loop;
    end if;
    --привзка доступна только для строковых атрибутов
    if (REC.DATA_TYPE = NDATA_TYPE_STR)
    then
      --работаем от типа привязки
      case (REC.LNK_TYPE)
      --привязки нет
        when NLNK_TYPE_NONE then
          begin
            --зачистим в записи лишние поля
            REC.UNIT       := null;
            REC.METHOD     := null;
            REC.METHOD_PRM := null;
            REC.INIT_PRM   := null;
            REC.EX_DICT    := null;
            REC.SYNC       := NSYNC_NO;
          end;
          --раздел
        when NLNK_TYPE_UNIT then
          begin
            --проверим корректность приявязки
            if (REC.UNIT is null)
            then
              P_EXCEPTION(0
                         ,'Не указан раздел привязки!');
            end if;
            if (REC.METHOD is null)
            then
              P_EXCEPTION(0
                         ,'Не указан метод вызова раздела привязки!');
            end if;
            if (REC.METHOD_PRM is null)
            then
              P_EXCEPTION(0
                         ,'Не указан параметр метода вызова раздела привязки!');
            end if;
            UPREC := UTL_UNIT_PARAMS_GET(NRN    => REC.METHOD_PRM
                                        ,NSMART => 0);
            if (UPREC.DATA_TYPE <> NDATA_TYPE_STR)
            then
              P_EXCEPTION(0
                         ,'В качестве параметра привязки можно указывать только строковые параметры методов вызова!');
            end if;
            if ((UPREC.DEP_RN is not null) and (REC.INIT_PRM is null))
            then
              P_EXCEPTION(0
                         ,'Не указан родительский параметр метода вызова раздела привязки!');
            end if;
            if ((REC.INIT_PRM is not null) and (REC.RN is not null) and (REC.INIT_PRM = REC.RN))
            then
              P_EXCEPTION(0
                         ,'Атрибут не может быть родительским сам для себя!');
            end if;
            if (REC.INIT_PRM is not null)
            then
              PREC := TYPE_ATTR_GET(NRN    => REC.INIT_PRM
                                   ,NSMART => 0);
              if (PREC.SYNC <> NSYNC_DO)
              then
                P_EXCEPTION(0
                           ,'Родительский атрибут "%s" для атриубта "%s" должен иметь признак "Синхронизировать/проверять значения"!'
                           ,PREC.NAME
                           ,REC.NAME);
              end if;
            end if;
            --зачистим в записи лишние поля
            if (UPREC.DEP_RN is null)
            then
              REC.INIT_PRM := null;
            end if;
            REC.EX_DICT := null;
          end;
          --дополнительный словарь
        when NLNK_TYPE_EDICT then
          begin
            --проверим корректность приявязки
            if (REC.EX_DICT is null)
            then
              P_EXCEPTION(0
                         ,'Не указан дополнительный словарь привязки!');
            end if;
            EDREC := UTL_EXTRA_DICTS_GET(NRN    => REC.EX_DICT
                                        ,NSMART => 0);
            if (EDREC.FORMAT <> NDATA_TYPE_STR)
            then
              P_EXCEPTION(0
                         ,'В качестве источника привязки привязки можно указывать только дополнительные словари с типом данных "Строка"!');
            end if;
            --зачистим в записи лишние поля
            REC.UNIT       := null;
            REC.METHOD     := null;
            REC.METHOD_PRM := null;
            REC.INIT_PRM   := null;
          end;
      end case;
    else
      --для остальных - привязки нет
      REC.LNK_TYPE   := NLNK_TYPE_NONE;
      REC.UNIT       := null;
      REC.METHOD     := null;
      REC.METHOD_PRM := null;
      REC.INIT_PRM   := null;
      REC.EX_DICT    := null;
      REC.SYNC       := NSYNC_NO;
    end if;
  end;

  --базовое добавление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_INSERT
  (
    NCRN        number --рег. номер каталога размещения
   ,NCOMPANY    number --рег. номер организации
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNIT       varchar2 --код раздела привязки
   ,NMETHOD     number --рег. номер метода вызова привязки
   ,NMETHOD_PRM number --рег. номер параметра метода вызова
   ,NINIT_PRM   number --рег. номер родительского атрибута привязки
   ,NEX_DICT    number --рег. номер дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
   ,NSYSTEM     number --признак системного атрибута (см. констатнты NSYSTEM_*)
   ,NRN         out number --рег. номер типового атрибута
  ) is
    REC UDO_T_TYPE_ATTR%rowtype; --запись атрибута
  begin
    --проверим, что атрибут не является зарезервированным (только если это добавление несистемного атрибута)
    if (NSYSTEM <> NSYSTEM_RESERVED)
    then
      TYPE_ATTR_SYSTEM_CHECK(SCODE => SCODE
                            ,SNAME => SNAME);
    end if;
    --соберем запись
    REC.CRN        := NCRN;
    REC.COMPANY    := NCOMPANY;
    REC.CODE       := SCODE;
    REC.NAME       := SNAME;
    REC.DATA_TYPE  := NDATA_TYPE;
    REC.LNK_TYPE   := NLNK_TYPE;
    REC.UNIT       := SUNIT;
    REC.METHOD     := NMETHOD;
    REC.METHOD_PRM := NMETHOD_PRM;
    REC.INIT_PRM   := NINIT_PRM;
    REC.EX_DICT    := NEX_DICT;
    REC.SYNC       := NSYNC;
    REC.SYSTEM     := NSYSTEM;
    --проверим и откорректируем параметры привязки
    TYPE_ATTR_LNK_TYPE_CHECK(REC     => REC
                            ,SACTION => 'I');
    --сформируем регистрационный номер
    REC.RN := GEN_ID();
    NRN    := REC.RN;
    --добавим запись
    insert into UDO_T_TYPE_ATTR
    values REC;
  end;

  --базовое исправление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_UPDATE
  (
    NRN         number --рег. номер типового атрибута
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNIT       varchar2 --код раздела привязки
   ,NMETHOD     number --рег. номер метода вызова привязки
   ,NMETHOD_PRM number --рег. номер параметра метода вызова
   ,NINIT_PRM   number --рег. номер родительского атрибута привязки
   ,NEX_DICT    number --рег. номер дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
   ,NSYSTEM     number --признак системного атрибута (см. констатнты NSYSTEM_*)
  ) is
    REC UDO_T_TYPE_ATTR%rowtype; --запись типового атрибута
  begin
    --считаем запись атрибута
    REC := TYPE_ATTR_GET(NRN => NRN);
    --проверим, что атрибут не является зарезервированным  (только если это пользовательское исправление)
    if (NSYSTEM <> NSYSTEM_RESERVED)
    then
      TYPE_ATTR_SYSTEM_CHECK(SCODE => SCODE
                            ,SNAME => SNAME);
    end if;
    --соберем новую запись
    REC.CODE       := SCODE;
    REC.NAME       := SNAME;
    REC.DATA_TYPE  := NDATA_TYPE;
    REC.LNK_TYPE   := NLNK_TYPE;
    REC.UNIT       := SUNIT;
    REC.METHOD     := NMETHOD;
    REC.METHOD_PRM := NMETHOD_PRM;
    REC.INIT_PRM   := NINIT_PRM;
    REC.EX_DICT    := NEX_DICT;
    REC.SYNC       := NSYNC;
    REC.SYSTEM     := NSYSTEM;
    --проверим и откорректируем параметры привязки
    TYPE_ATTR_LNK_TYPE_CHECK(REC     => REC
                            ,SACTION => 'U');
    --исправим запись
    update UDO_T_TYPE_ATTR T
       set T.CODE       = REC.CODE
          ,T.NAME       = REC.NAME
          ,T.DATA_TYPE  = REC.DATA_TYPE
          ,T.LNK_TYPE   = REC.LNK_TYPE
          ,T.UNIT       = REC.UNIT
          ,T.METHOD     = REC.METHOD
          ,T.METHOD_PRM = REC.METHOD_PRM
          ,T.INIT_PRM   = REC.INIT_PRM
          ,T.EX_DICT    = REC.EX_DICT
          ,T.SYNC       = REC.SYNC
          ,T.SYSTEM     = REC.SYSTEM
     where T.RN = REC.RN;
  end;

  --базовое удаление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_DELETE(NRN number --рег. номер типового атрибуты
                                  ) is
    REC UDO_T_TYPE_ATTR%rowtype; --запись типового атрибута
  begin
    --считаем запись атрибута
    REC := TYPE_ATTR_GET(NRN => NRN);
    --проверка корректности удаления атрибута
    TYPE_ATTR_LNK_TYPE_CHECK(REC     => REC
                            ,SACTION => 'D');
    --удалим запись
    delete from UDO_T_TYPE_ATTR T
     where T.RN = REC.RN;
  end;

  --базовая инициализация системных атрибутов в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_BASE_INIT
  (
    NCRN     number --рег. номер каталога размещения
   ,NCOMPANY number --рег. номер организации
  ) is
  begin
    TYPE_ATTR_SYSTEM_INIT(NCRN     => NCRN
                         ,NCOMPANY => NCOMPANY);
  end;

  --клиентское добалвение в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_INSERT
  (
    NCRN        number --рег. номер каталога размещения
   ,NCOMPANY    number --рег. номер организации
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNITNAME   varchar2 --наименование раздела
   ,SMETHOD     varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
   ,NRN         out number --рег. номер типового атрибута
  ) is
    SUNIT       UDO_T_TYPE_ATTR.UNIT%type; --код раздела привязки
    NMETHOD     UDO_T_TYPE_ATTR.METHOD%type; --рег. номер метода вызова привязки
    NMETHOD_PRM UDO_T_TYPE_ATTR.METHOD_PRM%type; --рег. номер параметра метода вызова
    NINIT_PRM   UDO_T_TYPE_ATTR.INIT_PRM%type; --рег. номер родительского атрибута привязки
    NEX_DICT    UDO_T_TYPE_ATTR.EX_DICT%type; --рег. номер дополнительного словаря привязки
  begin
    --разыменуем ссылки
    TYPE_ATTR_JOINS(NCOMPANY    => NCOMPANY
                   ,SUNITNAME   => SUNITNAME
                   ,SMETHOD     => SMETHOD
                   ,SMETHOD_PRM => SMETHOD_PRM
                   ,SINIT_PRM   => SINIT_PRM
                   ,SEX_DICT    => SEX_DICT
                   ,SUNIT       => SUNIT
                   ,NMETHOD     => NMETHOD
                   ,NMETHOD_PRM => NMETHOD_PRM
                   ,NINIT_PRM   => NINIT_PRM
                   ,NEX_DICT    => NEX_DICT);
    /*--регистрация начала действия
    PKG_ENV.PROLOGUE(NCOMPANY => NCOMPANY
                    ,NVERSION => null
                    ,NCATALOG => NCRN
                    ,SUNIT    => 'MarkTypeAttrs'
                    ,SACTION  => 'UDO_P_TYPE_ATTR_INSERT'
                    ,STABLE   => 'UDO_T_TYPE_ATTR');
    */
    --добавим запись
    TYPE_ATTR_BASE_INSERT(NCRN        => NCRN
                         ,NCOMPANY    => NCOMPANY
                         ,SCODE       => SCODE
                         ,SNAME       => SNAME
                         ,NDATA_TYPE  => NDATA_TYPE
                         ,NLNK_TYPE   => NLNK_TYPE
                         ,SUNIT       => SUNIT
                         ,NMETHOD     => NMETHOD
                         ,NMETHOD_PRM => NMETHOD_PRM
                         ,NINIT_PRM   => NINIT_PRM
                         ,NEX_DICT    => NEX_DICT
                         ,NSYNC       => NSYNC
                         ,NSYSTEM     => NSYSTEM_USER
                         ,NRN         => NRN);
    /*--регистрация окончания дейстия
    PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                    ,NVERSION  => null
                    ,NCATALOG  => NCRN
                    ,SUNIT     => 'MarkTypeAttrs'
                    ,SACTION   => 'UDO_P_TYPE_ATTR_INSERT'
                    ,STABLE    => 'UDO_T_TYPE_ATTR'
                    ,NDOCUMENT => NRN);
    */
  end;

  --клиентское исправление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_UPDATE
  (
    NRN         number --рег. номер типового атрибута
   ,SCODE       varchar2 --мнемокод
   ,SNAME       varchar2 --наименование
   ,NDATA_TYPE  number --тип данных (см. константы NDATA_TYPE_*)
   ,NLNK_TYPE   number --тип связи (см. константы NLNK_TYPE_*)
   ,SUNITNAME   varchar2 --наименование раздела
   ,SMETHOD     varchar2 --наименование метода вызова привязки
   ,SMETHOD_PRM varchar2 --наименование параметра метода вызова
   ,SINIT_PRM   varchar2 --наименование родительского атрибута привязки
   ,SEX_DICT    varchar2 --мнемокод дополнительного словаря привязки
   ,NSYNC       number --признак синхронизации/проверки значений словаря (см. констатнты NSYNC_*)
  ) is
    REC         UDO_T_TYPE_ATTR%rowtype; --запись типового атрибута
    SUNIT       UDO_T_TYPE_ATTR.UNIT%type; --код раздела привязки
    NMETHOD     UDO_T_TYPE_ATTR.METHOD%type; --рег. номер метода вызова привязки
    NMETHOD_PRM UDO_T_TYPE_ATTR.METHOD_PRM%type; --рег. номер параметра метода вызова
    NINIT_PRM   UDO_T_TYPE_ATTR.INIT_PRM%type; --рег. номер родительского атрибута привязки
    NEX_DICT    UDO_T_TYPE_ATTR.EX_DICT%type; --рег. номер дополнительного словаря привязки
  begin
    --считаем запись атрибута
    REC := TYPE_ATTR_GET(NRN    => NRN
                        ,NSMART => 0);
    --разыменуем ссылки
    TYPE_ATTR_JOINS(NCOMPANY    => REC.COMPANY
                   ,SUNITNAME   => SUNITNAME
                   ,SMETHOD     => SMETHOD
                   ,SMETHOD_PRM => SMETHOD_PRM
                   ,SINIT_PRM   => SINIT_PRM
                   ,SEX_DICT    => SEX_DICT
                   ,SUNIT       => SUNIT
                   ,NMETHOD     => NMETHOD
                   ,NMETHOD_PRM => NMETHOD_PRM
                   ,NINIT_PRM   => NINIT_PRM
                   ,NEX_DICT    => NEX_DICT);
    /*--регистрация начала действия
    PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                    ,NVERSION  => null
                    ,NCATALOG  => REC.CRN
                    ,SUNIT     => 'MarkTypeAttrs'
                    ,SACTION   => 'UDO_P_TYPE_ATTR_UPDATE'
                    ,STABLE    => 'UDO_T_TYPE_ATTR'
                    ,NDOCUMENT => REC.RN);
    */
    --исправим запись
    TYPE_ATTR_BASE_UPDATE(NRN         => REC.RN
                         ,SCODE       => SCODE
                         ,SNAME       => SNAME
                         ,NDATA_TYPE  => NDATA_TYPE
                         ,NLNK_TYPE   => NLNK_TYPE
                         ,SUNIT       => SUNIT
                         ,NMETHOD     => NMETHOD
                         ,NMETHOD_PRM => NMETHOD_PRM
                         ,NINIT_PRM   => NINIT_PRM
                         ,NEX_DICT    => NEX_DICT
                         ,NSYNC       => NSYNC
                         ,NSYSTEM     => NSYSTEM_USER);
    /*--регистрация окончания дейстия
    PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                    ,NVERSION  => null
                    ,NCATALOG  => REC.CRN
                    ,SUNIT     => 'MarkTypeAttrs'
                    ,SACTION   => 'UDO_P_TYPE_ATTR_UPDATE'
                    ,STABLE    => 'UDO_T_TYPE_ATTR'
                    ,NDOCUMENT => REC.RN);
    */
  end;

  --клиентское удаление в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_DELETE(NRN number --рег. номер типового атрибута
                             ) is
    REC UDO_T_TYPE_ATTR%rowtype; --запись типового атрибута
  begin
    --считаем запись атрибута
    REC := TYPE_ATTR_GET(NRN    => NRN
                        ,NSMART => 0);
    /*--регистрация начала действия
    PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                    ,NVERSION  => null
                    ,NCATALOG  => REC.CRN
                    ,SUNIT     => 'MarkTypeAttrs'
                    ,SACTION   => 'UDO_P_TYPE_ATTR_DELETE'
                    ,STABLE    => 'UDO_T_TYPE_ATTR'
                    ,NDOCUMENT => REC.RN);*/
    --удалим запись
    TYPE_ATTR_BASE_DELETE(NRN => REC.RN);
    /*--регистрация окончания дейстия
    PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                    ,NVERSION  => null
                    ,NCATALOG  => REC.CRN
                    ,SUNIT     => 'MarkTypeAttrs'
                    ,SACTION   => 'UDO_P_TYPE_ATTR_DELETE'
                    ,STABLE    => 'UDO_T_TYPE_ATTR'
                    ,NDOCUMENT => REC.RN);*/
  end;

  --клиентская инициализация системных атрибутов в разделе "Типовые атрибуты"
  procedure TYPE_ATTR_INIT
  (
    NCRN     number --рег. номер каталога размещения
   ,NCOMPANY number --рег. номер организации
  ) is
  begin
    /*--регистрация начала действия
    PKG_ENV.PROLOGUE_TEMP(NCOMPANY   => NCOMPANY
                         ,NVERSION   => null
                         ,NCATALOG   => NCRN
                         ,NJUR_PERS  => null
                         ,NHIERARCHY => null
                         ,SUNIT      => 'MarkTypeAttrs'
                         ,SACTION    => 'UDO_P_TYPE_ATTR_INIT'
                         ,STABLE     => 'UDO_T_TYPE_ATTR'
                         ,NIDENT     => null);*/
    --базово инициализируем
    TYPE_ATTR_BASE_INIT(NCRN     => NCRN
                       ,NCOMPANY => NCOMPANY);
    /*--регистрация окончания дейстия
    PKG_ENV.EPILOGUE_TEMP(NCOMPANY   => NCOMPANY
                         ,NVERSION   => null
                         ,NCATALOG   => NCRN
                         ,NJUR_PERS  => null
                         ,NHIERARCHY => null
                         ,SUNIT      => 'MarkTypeAttrs'
                         ,SACTION    => 'UDO_P_TYPE_ATTR_INIT'
                         ,STABLE     => 'UDO_T_TYPE_ATTR'
                         ,NIDENT     => null);*/
  end;

begin
  --инициализируем коллекцию системных атрибутов
  SA := SYSTEM_ATTRS();
  --наполним её для всех организаций
  for C in (select T.RN
              from COMPANIES T)
  loop
    SA.EXTEND();
    SA(SA.LAST).NCOMPANY := C.RN;
    SA(SA.LAST).TA := TYPE_ATTRS();
    TYPE_ATTR_SYSTEM_BUILD(SYSTEM_TYPE_ATTRS => SA(SA.LAST).TA);
  end loop;
end;
--grant execute on UDO_PKG_TYPE_ATTR to public;
/

