create or replace package USR_PKG_FACEACC as
  -- Степанов М. 01/12/2020
  /*
    FaceAccounts                    Лицевые счета                                     FACEACC           FA
    FaceAccountsPayPlans            Лицевые счета (план платежей)                     FCACPAYPLANS      FAPP
    FaceAccountsOperPlans           Лицевые счета (план прихода)                      FCACOPERPLANS     FAOP
    FaceAccountsOperOutPlans        Лицевые счета (план расхода)                      FCACOPERPLANS     FAOOP
    FaceAccountsGraphPoints         Лицевые счета (точки графиков)                    FCACGRAPHPOINTS   FGP
    FaceAccountsOperOutPlansCalcs   Лицевые счета (план расхода, строки калькуляции)  FCACOPERPLANSCLC  FAOOPC
  */

  --#########################################################################################################

  function FACEACC_GET
  /*
    Лицевой счёт. Считывание
    */
  (nrn in number) return faceacc%rowtype;
  --#########################################################################################################

  function FACEACC_GET_STATUS_NAME
  /*
    Функция возвращает "Состояние"
    */
  (
    dfact_open_date  in date
   ,dfact_close_date in date
  ) return varchar2;
  --#########################################################################################################

  function FACEACC_GET_THEME_BY_NUMB
  /*
    Функция возвращает номер темы по номеру ЛС
    */
  (snumb in varchar2) return varchar2;
  /*#########################################################################################################*/

  function FACEACC_GET_PERF_SUM
  /*
    Функция возвращает сумму исполнения заданного вида на дату
    */
  (
    nFLAGSMART in number default 0
   ,nRN        in number
   ,dDATE      in date default null
   ,sSUM_TYPE  in varchar2
  ) return number;
  /*#########################################################################################################*/

  function FACEACC_IS_PRODUCT_COST_CODE
  /*
    Функция определяет является ли лицевой счёт ШПЗ
    */
  (
    nFLAGSMART in number default 0
   ,nRN        in number
  ) return number;
  --#########################################################################################################

  function FACEACC_GET_FACT_SUMMS
  /*
    Процедура получения фактических сумм исполнения ЛС
    */
  (
    nRN        in number
   ,nFLAGSMART in number default 1
   ,nACC_KIND  in number default null
   ,sSUM_TYPE  in varchar2
   ,dDATE_FROM in date default null
   ,dDATE_TO   in date default null
  ) return pkg_std.tsumm;
  --#########################################################################################################

  procedure FACEACC_GET_FACT_SUMMS
  /*
    Процедура получения фактических сумм исполнения ЛС
    */
  (
    nRN                  in number
   ,nFLAGSMART           in number default 1
   ,nACC_KIND            in number default null
   ,dDATE_FROM           in date default null
   ,dDATE_TO             in date default null
   ,nLOAD_SUM_ACC        out number -- сумма отгрузки по ЖО в валюте ЛС
   ,nLOAD_BASE_SUM       out number -- сумма отгрузки по ЖО в базовой валюте
   ,nLOAD_BASE_SUM_NOTAX out number -- сумма отгрузки по ЖО в базовой валюте без НДС
   ,nSERV_SUM_ACC        out number -- сумма услуг по ЖО в валюте ЛС
   ,nSERV_BASE_SUM       out number -- сумма услуг по ЖО в базовой валюте
   ,nSERV_BASE_SUM_NOTAX out number -- сумма услуг по ЖО в базовой валюте без НДС
   ,nPAY_SUM_ACC         out number -- сумма оплат по ЖП в валюте ЛС
   ,nPAY_BASE_SUM        out number -- сумма оплат по ЖП в базовой валюте
   ,nPAY_BASE_SUM_NOTAX  out number -- сумма оплат по ЖП в базовой валюте без НДС
  );
  --#########################################################################################################

  procedure FACEACC_AINSERT
  /*
    Лицевой счёт. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BUPDATE
  /*
    Лицевой счёт. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AUPDATE
  /*
    Лицевой счёт. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BOPEN
  /*
    Лицевой счёт. Проверка до открытия
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AOPEN
  /*
    Лицевой счёт. Проверка после открытия
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BCLOSE
  /*
    Лицевой счёт. Проверка до закрытия
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_ACLOSE
  /*
    Лицевой счёт. Проверка после закрытия
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BMAKECONSORD
  /*
    Лицевой счёт. Проверка перед формированием заказа потребителям
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AMAKECONSORD
  /*
    Лицевой счёт. Проверка после формирования заказа потребителям
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BMAKEDELIVERYORD
  /*
    Лицевой счёт. Проверка перед формированием заказа поставщикам
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AMAKEDELIVERYORD
  /*
    Лицевой счёт. Проверка после формирования заказа поставщикам
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BMAKEPAYACCIN
  /*
    Лицевой счёт. Проверка перед формированием входящего счёта на оплату
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AMAKEPAYACCIN
  /*
    Лицевой счёт. Проверка после формирования входящего счёта на оплату
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BMAKESHEEPDIRSCUST
  /*
    Лицевой счёт. Формирование распоряжения на отгрузку потребителям. До
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AMAKESHEEPDIRSCUST
  /*
    Лицевой счёт. Формирование распоряжения на отгрузку потребителям. После
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_BMAKEPAYNOTES
  /*
    Лицевой счёт. Проверка перед формированием платежа
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_AMAKEPAYNOTES
  /*
    Лицевой счёт. Проверка после формирования платежа
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_CHECK_BASE
  /*
    Лицевой счёт. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FACEACC_CHECK_OVER_SHIP
  /*
    Заголовок. Проверка превышения суммы отгрузки (товаров и услуг) над суммой этапа договора
    */
  (
    nFLAGSMART in number
   ,nRN        in number
   ,dDATE      in date
   ,nDIFF      out number
  );
  --#########################################################################################################

  procedure FACEACC_CHECK_OVER_SHIP
  /*
    Заголовок. Проверка превышения суммы отгрузки (товаров и услуг) над суммой этапа договора
    */
  (
    nFLAGSMART in number
   ,rROW       in faceacc%rowtype
   ,dDATE      in date
   ,nDIFF      out number
  );
  /*#########################################################################################################*/

  function FACEACC_CHECK_SUMM_CORRECT
  /* 
    Функция проверки корректности сумм ЛС по отношению к истории исполнения. Суммы корректны: 0 - да, 1 - нет
    */
  (nRN in number) return number;
  /*#########################################################################################################*/

  function FACEACC_CHECK_SUMM_CORRECT
  /* 
    Функция проверки корректности сумм ЛС по отношению к истории исполнения. Суммы корректны: 0 - да, 1 - нет
    */
  (rROW in faceacc%rowtype) return number;
  --#########################################################################################################

  procedure FACEACC_OPEN
  /*
    Заголовок. Открыть
    */
  (
    rrow       in faceacc%rowtype
   ,dopen_date in date
   ,nmode      in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure FACEACC_CLOSE
  /*
    Заголовок. Закрыть
    */
  (
    rrow        in faceacc%rowtype
   ,dclose_date in date
   ,nmode       in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure FACEACC_FIN_DETAILS_UPDATE
  /*
    Заголовок. Исправить финансовые параметры в лицевом счёте и документах
    */
  (
    rrow       in faceacc%rowtype
   ,nflagsmart in number
   ,nfpdartcl  in number
  );
  --#########################################################################################################

  procedure FACEACC_BASE_INSERT
  /*
    Заголовок. Добавление базовое
    */
  (
    rrow in faceacc%rowtype
   ,nrn  out number
  );
  --#########################################################################################################

  procedure FACEACC_BASE_UPDATE
  /*
    Заголовок. Исправление базовое
    */
  (
    rrow       in faceacc%rowtype
   ,nedit_sign in number /* признак откуда происходит редактирование (0 - из лицевых счетов, 1 - из договоров) */
   ,nsign_dir  in number default 0 /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  );
  /*#########################################################################################################*/

  procedure FACEACC_CORRPERF
  (
    nCOMPANY  in number -- Организация
   ,nIDENT    in number -- Идентификатор отмеченных записей
   ,nTRUE_REC out number -- Количество обработанных записей
   ,nMODE     in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FACEACC_INITHIST
  /* 
    Корректировка истории исполнения 
    Если вызывается не из клиента, то добавить документы в selectlist, а после процедуры очистить
    */
  (
    nCOMPANY in number
   ,nIDENT   in number
  );
  /*#########################################################################################################*/

  procedure FACEACC_FCACPAYPLANS_PAY
  /*
    Пересчитать исполнение плана платежей
    */
  (
    nRN            in number
   ,dPAY_DATE_FROM in date
   ,dPAY_DATE_TO   in date
  );
  --#########################################################################################################

  function FCACOPERPLANS_GET
  /*
    План операций. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacoperplans%rowtype;
  --#########################################################################################################

  procedure FCACOPERPLANS_GET_BY_PARAMS
  /*
    Спецификация. Получение записи по параметрам
    */
  (
    nFLAGSMART     in number    default 0
   ,nFLAG_OPTION   in number    default 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
   ,nTOO_MANY_ROWS in number    default 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
   ,nPRN           in number    default null
   ,nINEXP_SIGN    in number    default 1 /* признак приход(0) расход(1) */
   ,nGRAPHPOINT    in number    default null
   ,nNOMEN         in number    default null
   ,nNOMPACK       in number    default null
   ,nNOMMODIF      in number    default null
   ,nNOMMODIFPACK  in number    default null
   ,nTAXGR         in number    default null
   ,nQUANT         in number    default null
   ,nPRICE         in number    default null
   ,nARTICLE       in number    default null
   ,sSERNUMB       in varchar2  default null
   ,nCOUNTRY       in number    default null
   ,sGTD           in varchar2  default null
   ,dBEGINDATE     in date      default null
   ,dENDDATE       in date      default null
   ,dDATE          in date      default null /* Дата определения. Проверяется попадает ли в период даты с... и по... */
   ,rROW           out fcacoperplans%rowtype
  );
  --#########################################################################################################

  procedure FCACOPERPLANS_AINSERT
  /*
    План операций. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPERPLANS_BUPDATE
  /*
    План операций. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPERPLANS_AUPDATE
  /*
    План операций. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPERPLANS_CHECK_BASE
  /*
    План операций. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  );
  /*#########################################################################################################*/

  procedure FCACPAYPLANS_INSERT
  /*
    Лицевые счета (графики платежей). Добавление клиентское
    */
  (
    rV_ROW in v_fcacpayplans%rowtype
   ,nRN    out number /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  );
  /*#########################################################################################################*/

  procedure FCACPAYPLANS_UPDATE
  /*
    Лицевые счета (графики платежей). Добавление клиентское
    */
  (
    rV_ROW in v_fcacpayplans%rowtype
   ,nMODE  in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FCACPAYPLANS_BASE_INSERT
  /*
    Лицевые счета (графики платежей). Добавление базовое
    */
  (
    rROW      in fcacpayplans%rowtype
   ,nSIGN_DIR in number
   ,nRN       out number /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  );
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_BASE_INSERT
  /*
  План операций. Добавление базовое
  */
  (
   rROW         in fcacoperplans%rowtype
  ,nRN          out number 
  ,nSIGN_DIR    in number default 0
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_BASE_UPDATE
  /*
  План операций. Исправление базовое
    */
  (
   rROW         in fcacoperplans%rowtype
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_INSERT
  /*
  План операций. Добавление
  */
  (
   rV_ROW       in v_fcacoperplans%rowtype
  ,nDUP_RN      in number default 0 
  ,nRN          out number
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_UPDATE
  /*
  План операций. Исправление 
    */
  (
   rV_ROW       in v_fcacoperplans%rowtype
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_UPDATE_EXEC
  /*
  План операций. Исправление исполнения
  */
  (
   nRN                in number
  ,nQUANT_FACT        in number default null
  ,nSUM_FACT          in number default null
  ,nSUMWITHNDS_FACT   in number default null
  ,nSUMNDS_FACT       in number default null
  );
  --#########################################################################################################

  function FCACOPEROUTPLANS_GET
  /*
    План операций. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacoperplans%rowtype;
  /*#########################################################################################################*/

  function FCACOPEROUTPLANS_GET_EXEC
  /*
  План расхода. Получить количества и суммы исполнения и остатка
  */
  (
   nRN      in number
  ,sTYPE    in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_GET_EXEC
  /*
  План расхода. Получить количества и суммы исполнения и остатка
  */
  (
    nRN              in number
   ,nQUANT_FACT      out number
   ,nSUM_FACT        out number
   ,nSUMWITHNDS_FACT out number
   ,nSUMNDS_FACT     out number
   ,nQUANT_REST      out number
   ,nSUM_REST        out number
   ,nSUMWITHNDS_REST out number
   ,nSUMNDS_REST     out number
  );
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_AINSERT
  /*
    План операций. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_BUPDATE
  /*
    План операций. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_AUPDATE
  /*
    План операций. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_BDELETE
  /*
    План платежей. Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_ADELETE
  /*
    План расхода. Проверка после удаления
    */
  (
    nRN      in number
   ,nCOMPANY in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_CHECK_BASE
  /*
    План операций. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  );
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_RECALC
  /*
  План расхода. Пересчать исполнение
  */
  (   
   nRN            in number
  );
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_SPLIT
  /*
  План расхода. Отделить от текущей записи с заданным количеством
  */
  (
   nRN                in number
  ,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
  ,dBEGIN_DATE        in date
  ,dEND_DATE          in date
  );
  --#########################################################################################################

  function FCACPAYPLANS_GET
  /*
    План платежей. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacpayplans%rowtype;
  --#########################################################################################################

  procedure FCACPAYPLANS_AINSERT
  /*
    План платежей. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACPAYPLANS_BUPDATE
  /*
    План платежей. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACPAYPLANS_AUPDATE
  /*
    План платежей. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACPAYPLANS_BDELETE
  /*
    План платежей. Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACPAYPLANS_CHECK_BASE
  /*
    Лицевые счета (графики платежей). Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACPAYPLANS_BASE_UPDATE
  /*
    План платежей. Исправление базовое
    */
  (rfcacpayplans in fcacpayplans%rowtype);
  --#########################################################################################################

  function FCACGRAPHPOINTS_GET
  /*
    Точки графиков. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacgraphpoints%rowtype;
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_AINSERT
  /*
    Точки графиков. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_BUPDATE
  /*
    Точки графиков. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_AUPDATE
  /*
    Точки графиков. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_BDELETE
  /*
    Точки графиков. Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_CHECK_BASE
  /*
    Точки графиков. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  );
  /*#########################################################################################################*/

  procedure FCACGRAPHPOINTS_BASE_INSERT
  /*
    Лицевые счета (точки графиков). Добавление базовое
    */
  (
    rROW  in fcacgraphpoints%rowtype
   ,nRN   out number
   ,nMODE in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FCACGRAPHPOINTS_BASE_UPDATE
  /*
    Лицевые счета (точки графиков). Исправление базовое
    */
  (rROW in fcacgraphpoints%rowtype);
  --#########################################################################################################

  function FCACOPEROUTPLANSCLC_GET
  /*
    Лицевые счета (план расхода, строки калькуляции). Считывание
    */
  (nrn in number -- RN записи
   ) return fcacoperplansclc%rowtype;
  --#########################################################################################################
  procedure FCACOPEROUTPLANSCLC_CNT_INDIR
  /*
    Лицевые счета (план расхода, строки калькуляции). Считывание
    */
  (nrn in fcacoperplansclc.rn%type -- RN записи
   );
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_AINSERT
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_BUPDATE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_AUPDATE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_BDELETE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_CHECK_BASE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_AMAKE_CLC
  /*
    Лицевые счета (план расхода, строки калькуляции). Переформирование строк калькуляции по учётным ценам. После
    */
  (
    nrn      in fcacoperplans.rn%type
   ,ncompany in number
  );
  --#########################################################################################################
end USR_PKG_FACEACC;
/
create or replace package body USR_PKG_FACEACC as

  --#########################################################################################################

  function FACEACC_GET
  /*
    Лицевой счёт. Считывание
    */
  (nrn in number -- RN записи
   ) return faceacc%rowtype is
    rrow faceacc%rowtype;
  begin
    begin
      select t.* into rrow from faceacc t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nrn, sunit_table => 'FACEACC');
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <' ||
                    nvl(to_char(nrn), 'Не задан') || '> ' || 'в разделе <' ||
                    f_unitlist_getname(get_unitlist_code_table(1, 'FACEACC')) || '>.');
    end;
    return(rrow);
  end FACEACC_GET;
  --#########################################################################################################

  function FACEACC_GET_STATUS_NAME
  /*
    Функция возвращает "Состояние"
    */
  (
    dfact_open_date  in date
   ,dfact_close_date in date
  ) return varchar2 as
    sresult pkg_std.tstring;
  begin
  
    /* Если дата закрытия установлена */
    if dfact_close_date is not null then
      sresult := 'Закрыт';
      /* Если дата открытия установлена */
    elsif dfact_open_date is not null then
      sresult := 'Открыт';
      /* Иначе */
    else
      sresult := 'Не открыт';
    end if;
  
    return sresult;
  
  end FACEACC_GET_STATUS_NAME;
  --#########################################################################################################

  function FACEACC_GET_THEME_BY_NUMB
  /*
    Функция возвращает номер темы по номеру ЛС
    */
  (snumb in varchar2) return varchar2 as
  begin
    return substr(snumb, 1, instr(snumb, '/') - 1);
  end FACEACC_GET_THEME_BY_NUMB;
  /*#########################################################################################################*/

  function FACEACC_GET_PERF_SUM
  /*
  Функция возвращает сумму исполнения заданного вида на дату
  */
  (
   nFLAGSMART   in number   default 0
  ,nRN          in number
  ,dDATE        in date     default null 
  ,sSUM_TYPE    in varchar2
  ) 
  return number
  as
    dDate2    date := nvl( dDATE, sysdate );
    nResult   pkg_std.tsumm;  
  begin
    begin
      select decode( sSUM_TYPE, 'DOC_INCOME'  , doc_income
                              , 'PLAN_INCOME' , plan_income
                              , 'FACT_INCOME' , fact_income
                              , 'FACT_DEFICIT', fact_deficit
                              , 'DOC_SHIP'    , doc_ship
                              , 'PLAN_SHIP'   , plan_ship
                              , 'FACT_SHIP'   , fact_ship
                              , 'DOC_SERV'    , doc_serv
                              , 'PLAN_SERV'   , plan_serv
                              , 'FACT_SERV'   , fact_serv
                              , 'DOC_POSTED'  , doc_posted
                              , 'PLAN_POSTED' , plan_posted
                              , 'FACT_POSTED' , fact_posted
                              , 'DOC_PAYED'   , doc_payed
                              , 'PLAN_PAYED'  , plan_payed
                              , 'FACT_PAYED'  , fact_payed
                              , 'DOC_COUNT '  , doc_count )
        into nResult
        from ( select *
                 from fcacperfhist
                where prn = nRN
               order by date_hist desc ) t
       where date_hist <= dDate2 
         and rownum     = 1;
    exception
      when no_data_found then
        nResult := 0;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске суммы лицевого счёта с типом "%s".%s%s'
                   ,sSUM_TYPE, nRN, cr||cr||f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FACEACC' ) ) );
    end;

    /* Если неверный параметр */
    if nResult is null then
      /* сообщение об ошибке, если задано в параметре */
      p_exception( nFLAGSMART, 'Неверное значение "%s" параметра "sSUM_TYPE". RN: %s.%s'
                 ,sSUM_TYPE, nRN, cr||f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FACEACC' ) ) );
    end if;

    return( nResult );

  end FACEACC_GET_PERF_SUM;
  /*#########################################################################################################*/

  function FACEACC_IS_PRODUCT_COST_CODE
  /*
  Функция определяет является ли лицевой счёт ШПЗ
  */
  (
   nFLAGSMART in number default 0
  ,nRN        in number
  ) 
  return number
  as
    nRes    pkg_std.tnumber := 0; 
  begin
    begin
      select 1
        into nRes
        from projectstage
       where faceacc = nRN;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Лицевой счёт с RN <%s> не является шифром производственных затрат.', nRN);
      when too_many_rows then
        p_exception(nFLAGSMART, 'Лицевой счёт с RN <%s> используется в нескольких проектах.', nRN);
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске этапов проектов с лицевым счётом с RN <%s>.', nRN);
    end;
    
    return nRes;
    
  end FACEACC_IS_PRODUCT_COST_CODE;
  --#########################################################################################################

  function FACEACC_GET_FACT_SUMMS
  /*
  Процедура получения фактических сумм исполнения ЛС
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 1
  ,nACC_KIND  in number default null
  ,sSUM_TYPE  in varchar2
  ,dDATE_FROM in date default null
  ,dDATE_TO   in date default null
  ) 
  return pkg_std.tsumm 
  is
    nLoad_Sum_Acc        pkg_std.tsumm; -- сумма отгрузки по ЖО в валюте ЛС
    nLoad_Base_Sum       pkg_std.tsumm; -- сумма отгрузки по ЖО в базовой валюте
    nLoad_Base_Sum_Notax pkg_std.tsumm; -- сумма отгрузки по ЖО в базовой валюте без НД
    nServ_Sum_Acc        pkg_std.tsumm; -- сумма услуг по ЖО в валюте ЛС
    nServ_Base_Sum       pkg_std.tsumm; -- сумма услуг по ЖО в базовой валюте
    nServ_Base_Sum_Notax pkg_std.tsumm; -- сумма услуг по ЖО в базовой валюте без НДС
    nPay_Sum_Acc         pkg_std.tsumm; -- сумма оплат по ЖП в валюте ЛС
    nPay_Base_Sum        pkg_std.tsumm; -- сумма оплат по ЖП в базовой валюте
    nPay_Base_Sum_Notax  pkg_std.tsumm; -- сумма оплат по ЖП в базовой валюте без НДС
  
    nResult              pkg_std.tsumm;
  begin
    faceacc_get_fact_summs(nRN                  => nRN
                          ,nFLAGSMART           => nFLAGSMART
                          ,nACC_KIND            => nACC_KIND
                          ,dDATE_FROM           => dDATE_FROM
                          ,dDATE_TO             => dDATE_TO
                          ,nLOAD_SUM_ACC        => nLoad_Sum_Acc
                          ,nLOAD_BASE_SUM       => nLoad_Base_Sum
                          ,nLOAD_BASE_SUM_NOTAX => nLoad_Base_Sum_Notax
                          ,nSERV_SUM_ACC        => nServ_Sum_Acc
                          ,nSERV_BASE_SUM       => nServ_Base_Sum
                          ,nSERV_BASE_SUM_NOTAX => nServ_Base_Sum_notax
                          ,nPAY_SUM_ACC         => nPay_Sum_Acc
                          ,nPAY_BASE_SUM        => nPay_Base_Sum
                          ,nPAY_BASE_SUM_NOTAX  => nPay_Base_Sum_Notax);
    nresult := case ssum_type
                 when 'LOAD_SUM_ACC' then
                  nLoad_Sum_Acc
                 when 'LOAD_BASE_SUM' then
                  nLoad_Base_Sum
                 when 'LOAD_BASE_SUM_NOTAX' then
                  nLoad_Base_Sum_Notax
                 when 'SERV_SUM_ACC' then
                  nServ_Sum_Acc
                 when 'SERV_BASE_SUM' then
                  nServ_Base_Sum
                 when 'SERV_BASE_SUM_NOTAX' then
                  nServ_Base_Sum_notax
                 when 'PAY_SUM_ACC' then
                  nPay_Sum_Acc
                 when 'PAY_BASE_SUM' then
                  nPay_Base_Sum
                 when 'PAY_BASE_SUM_NOTAX' then
                  nPay_Base_Sum_Notax
                 when 'REST_SUM_ACC' then
                  nLoad_Sum_Acc + nServ_Sum_Acc + nPay_Sum_Acc
                 when 'REST_BASE_SUM' then
                  nLoad_Base_Sum + nServ_Base_Sum + nPay_Base_Sum
                 when 'REST_BASE_SUM_NOTAX' then
                  nLoad_Base_Sum_Notax + nServ_Base_Sum_Notax + nPay_Base_Sum_Notax
                 when 'FULL_LOAD_SUM' then
                  nLoad_Base_Sum + nServ_Base_Sum 
                 when 'FULL_LOAD_SUM_NOTAX' then
                  nLoad_Base_Sum_Notax + nServ_Base_Sum_Notax 
                  
                 else
                  0
               end;
    return(nResult);
    
  end FACEACC_GET_FACT_SUMMS;
  --#########################################################################################################

  procedure FACEACC_GET_FACT_SUMMS
  /*
    Процедура получения фактических сумм исполнения ЛС
    */
  (
   nRN                  in number
  ,nFLAGSMART in number default 1
  ,nACC_KIND            in number default null
  ,dDATE_FROM           in date   default null
  ,dDATE_TO             in date   default null
  ,nLOAD_SUM_ACC        out number /* сумма отгрузки по ЖО в валюте ЛС */
  ,nLOAD_BASE_SUM       out number /* сумма отгрузки по ЖО в базовой валюте */
  ,nLOAD_BASE_SUM_NOTAX out number /* сумма отгрузки по ЖО в базовой валюте без НДС */
  ,nSERV_SUM_ACC        out number /* сумма услуг по ЖО в валюте ЛС */
  ,nSERV_BASE_SUM       out number /* сумма услуг по ЖО в базовой валюте */
  ,nSERV_BASE_SUM_NOTAX out number /* сумма услуг по ЖО в базовой валюте без НДС*/
  ,nPAY_SUM_ACC         out number /* сумма оплат по ЖП в валюте ЛС */
  ,nPAY_BASE_SUM        out number /* сумма оплат по ЖП в базовой валюте */
  ,nPAY_BASE_SUM_NOTAX  out number /* сумма оплат по ЖП в базовой валюте без НДС */
  ) 
  is
  begin
    begin
      select ( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * lpn.load_sum_acc
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * lpn.load_base_sum
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * lpn.load_base_sum_notax
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * lpn.serv_sum_acc
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * lpn.serv_base_sum
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * lpn.serv_base_sum_notax
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * pn.pay_sum_acc
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * pn.pay_base_sum
            ,( decode( nACC_KIND, null, fa.acc_kind, nACC_KIND ) *2 -1 ) * pn.pay_base_sum_notax
        into nLOAD_SUM_ACC
            ,nLOAD_BASE_SUM
            ,nLOAD_BASE_SUM_NOTAX
            ,nSERV_SUM_ACC
            ,nSERV_BASE_SUM
            ,nSERV_BASE_SUM_NOTAX
            ,nPAY_SUM_ACC
            ,nPAY_BASE_SUM
            ,nPAY_BASE_SUM_NOTAX
        from faceacc fa
            ,( select t.faceacc
                     ,sum((ot.gsmways_type * -2 + 1 ) * t.load_sum_acc)    as load_sum_acc
                     ,sum((ot.gsmways_type * -2 + 1 ) * t.base_sum)        as load_base_sum
                     ,sum((ot.gsmways_type * -2 + 1 ) * t.base_sum_notax)  as load_base_sum_notax
                     ,sum((ot.gsmways_type * -2 + 1 ) * t.serv_sum_acc)    as serv_sum_acc
                     ,sum((ot.gsmways_type * -2 + 1 ) * t.serv_base_sum)   as serv_base_sum
                     ,sum((ot.gsmways_type * -2 + 1 ) * t.serv_bsum_notax) as serv_base_sum_notax
                 from liabilitynotes  t
                     ,azsgsmwaystypes ot
                where t.storeoper = ot.rn
                  and ( t.load_date >= dDATE_FROM or dDATE_FROM is null )
                  and ( t.load_date <= dDATE_TO   or dDATE_TO   is null )
                group by t.faceacc ) lpn
            ,( select t.faceacc
                     ,sum( ( ot.typoper_direct * -2 + 1 ) *   t.pay_sum_acc )                                            as pay_sum_acc
                     ,sum( ( ot.typoper_direct * -2 + 1 ) *   t.pay_sum / t.curr_rate * t.curr_rate_base )               as pay_base_sum
                     ,sum( ( ot.typoper_direct * -2 + 1 ) * ( t.pay_sum - t.tax_sum ) / t.curr_rate * t.curr_rate_base ) as pay_base_sum_notax
                 from paynotes t
                     ,dictoper ot
                where t.finoper     = ot.rn
                  and t.signplan    = 0
                  and ( t.pay_date >= dDATE_FROM or dDATE_FROM is null )
                  and ( t.pay_date <= dDATE_TO   or dDATE_TO   is null )
                group by t.faceacc ) pn
       where fa.rn = lpn.faceacc
         and fa.rn = pn.faceacc
         and fa.rn = nrn;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найден документ с RN: <%s> в разделе <%s>'
                   ,nRN, f_unitlist_getname( get_unitlist_code_table( nflag_smart =>  1, stable_name => 'FACEACC' ) ) );
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одного документа с RN: <%s> в разделе <%s>'
                   ,nRN, f_unitlist_getname( get_unitlist_code_table( nflag_smart =>  1, stable_name => 'FACEACC' ) ) );
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске документа с RN: <%s> в разделе <%s>'
                   ,nRN, f_unitlist_getname( get_unitlist_code_table( nflag_smart =>  1, stable_name => 'FACEACC' ) ) );
    end;
  end FACEACC_GET_FACT_SUMMS;
  /* ######################################################################################################### */

  procedure FACEACC_AINSERT
  /*
    Заголовок. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow          faceacc%rowtype;
    suserperson   pkg_std.tstring;
    suseragent    pkg_std.tstring;
    nuseragent    pkg_std.tref;
    nuseragentcrn pkg_std.tref;
  
    svarchar pkg_std.tstring;
    nnumber  pkg_std.tnumber;
  begin
    /* Считывание */
    rrow := faceacc_get(nrn => nrn);
    /* Текущий сотрудник */
    find_person_authid(sperson      => suserperson
                      ,sowner_agent => svarchar
                      ,stab_pref    => svarchar
                      ,stab_numb    => svarchar);
    /* Контрагент сотрудника. Мнемокод */
    find_clnpersons_agent(nflag_smart  => 0
                         ,ncompany     => rrow.company
                         ,sperson_code => suserperson
                         ,nrn          => nnumber
                         ,sagnabbr     => suseragent);
    /* Контрагент сотрудника. RN */
    find_agnlist_code(nflag_smart  => 0
                     ,nflag_option => 0
                     ,ncompany     => rrow.company
                     ,scode        => suseragent
                     ,nrn          => nuseragent);
    /* Контрагент сотрудника. Каталог */
    p_agnlist_exists(ncompany => rrow.company, nrn => nuseragent, ncrn => nuseragentcrn);
  
    /* ИСПРАВЛЕНИЯ */
    /* Если катлог контрагента сотрудника "ОМТС" */
    if usr_pkg_common.is_crn_in_hiercrn(ncrn => nuseragentcrn, shier_crn_list => 7597055) then
    
      /* Если лицевой счёт внутренний */
      if rrow.acc_class = 3 then
        p_exception(0
                   ,'Запрещено добавлять внутренний лицевой счёт сотруднику из каталога <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => nuseragentcrn)
                   ,cr ||
                    f_docdescrs_get_description(sunitcode => 'FaceAccounts', ndocument => rrow.rn));
      else
      
        /* Если лицевой счёт Покупка */
        if rrow.acc_kind = 0 and rrow.ieelement is null then
          /* подставляем статью затрат "Расходы на ПКИ_Б" */
          rrow.ieelement :=  6172151;
          /* исправляем ЛС */
          faceacc_base_update(rrow => rrow, nedit_sign => rrow.sign_stage);
        end if;
      
      end if;
    end if;
  
    /* ПРОВЕРКИ */
    /* Базовая */
    faceacc_check_base(nrn => nrn, ncompany => ncompany);
  
  end FACEACC_AINSERT;
  --#########################################################################################################

  procedure FACEACC_BUPDATE
  /*
    Заголовок. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
    -- Считывание
    --USR_PKG_PUB_CONST.RFACEACC := FACEACC_GET(NRN);
  end FACEACC_BUPDATE;
  --#########################################################################################################

  procedure FACEACC_AUPDATE
  /*
    Заголовок. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    -- Проверка базовая
    faceacc_check_base(nrn, ncompany);
  end FACEACC_AUPDATE;
  --#########################################################################################################

  procedure FACEACC_BOPEN
  /*
    Лицевой счёт. Проверка до открытия
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_BOPEN;
  --#########################################################################################################

  procedure FACEACC_AOPEN
  /*
    лицевой счёт. Проверка после открытия
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_AOPEN;
  --#########################################################################################################

  procedure FACEACC_BCLOSE
  /*
    лицевой счёт. Проверка до закрытия
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_BCLOSE;
  --#########################################################################################################

  procedure FACEACC_ACLOSE
  /*
    лицевой счёт. Проверка после закрытия
    */
  (
    nrn      in number
   ,ncompany in number
  ) 
  is
    rRow      faceacc%rowtype;
    rStages   stages%rowtype;
  begin
    /* Считывание */
    rRow := faceacc_get(nrn => nrn);
    /* Этап договора */
    if rRow.sign_contract = 1 then
      rStages := usr_pkg_contracts.stages_get_by_faceacc( nfaceacc => rRow.rn );
    end if;
  
    /* ПРОВЕРКИ */
    /* По графикам платежей */
    for c in (select * from fcacpayplans where prn = nrn)
    loop
      /* если график не исполнен */
      /* 17-10-2025 по согласованию с А.Б. Куроедовой  допускаются остатки в графике платежей не более 100 рублей, чтоб
      давало закрывать такие этапы 
      18/11/2025 Степанов. Если у лицевого счёта есть фактические суммы или его этап отражается на сумме договора */
      if abs(nvl(c.pay_sum, 0) - nvl(c.fact_pays, 0)) > 100 
      and (  faceacc_get_perf_sum( nrn => rRow.rn, ssum_type => 'FACT_INCOME' )
           + faceacc_get_perf_sum( nrn => rRow.rn, ssum_type => 'FACT_DEFICIT' )
           + faceacc_get_perf_sum( nrn => rRow.rn, ssum_type => 'FACT_SHIP' )
           + faceacc_get_perf_sum( nrn => rRow.rn, ssum_type => 'FACT_SERV' )
           + faceacc_get_perf_sum( nrn => rRow.rn, ssum_type => 'FACT_POSTED' )
           + faceacc_get_perf_sum( nrn => rRow.rn, ssum_type => 'FACT_PAYED' ) != 0
           or
           ( rRow.sign_contract = 1 and rStages.sign_sum = 1 ) ) then
        p_exception(0, 'Сумма по колонке "#Остаток платежа" <%s> больше 100 рублей. '||cr||
                       'При этом по лицевому счёту имеются фактические операции, или его этап отражается на сумме договора. %s%s'
                   ,c.pay_sum - c.fact_pays
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'FaceAccountsPayPlans', ndocument => c.rn )
                   ,cr||cr|| 'Лицевой счёт: '|| rRow.numb );
      end if;
    end loop;
  
    /* По графикам отпуска */
    for c in (select *
                from fcacoperplans
               where prn = nrn
                 and inexp_sign = 1)
    loop
      /* если график не исполнен */
      if nvl(udo_f_fcacoperplans_transremn(nrn => c.rn, nquant => c.quant), 0) != 0 ----and c.crn != 1073309 --"Каталог !Исполнено" Договоров исключили из контроля 
       then
        ---  До тех пор, пока не вводят все документы на отгрзку контроль не работает
        p_exception(1
                   ,'Количество по колонке "#Осталось отгрузить" <%s> не равно нулю.%s%s'
                   ,udo_f_fcacoperplans_transremn(nrn => c.rn, nquant => c.quant)
                   ,cr || f_docdescrs_get_description(sunitcode => 'FaceAccountsOperOutPlans'
                                                     ,ndocument => c.rn)
                   ,cr || 'Лицевой счёт: ' || rrow.numb);
      end if;
    end loop;
  
  end FACEACC_ACLOSE;
  --#########################################################################################################

  procedure FACEACC_BMAKECONSORD
  /*
    Лицевой счёт. Проверка перед формированием заказа потребителям
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_BMAKECONSORD;
  --#########################################################################################################

  procedure FACEACC_AMAKECONSORD
  /*
    Лицевой счёт. Проверка после формирования заказа потребителям
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    -- Проверка базовая
    null;
  end FACEACC_AMAKECONSORD;
  --#########################################################################################################

  procedure FACEACC_BMAKEDELIVERYORD
  /*
    Лицевой счёт. Проверка перед формированием заказа поставщикам
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_BMAKEDELIVERYORD;
  --#########################################################################################################

  procedure FACEACC_AMAKEDELIVERYORD
  /*
    Лицевой счёт. Проверка после формирования заказа поставщикам
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_AMAKEDELIVERYORD;
  --#########################################################################################################

  procedure FACEACC_BMAKEPAYACCIN
  /*
    Лицевой счёт. Проверка перед формированием входящего счёта на оплату
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    /* Сохранение RN в константу для инициализации в триггере сохранения данных о сформированных документах */
    usr_pkg_pub_const.nidentbefore := nrn;
  
  end FACEACC_BMAKEPAYACCIN;
  --#########################################################################################################

  procedure FACEACC_AMAKEPAYACCIN
  /*
    Лицевой счёт. Проверка после формирования входящего счёта на оплату
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    sconnect_ext pkg_std.tstring := pkg_session.get_connect_ext;
  begin
  
    /* По сформированным документам */
    for c in (select t.out_document0
                from usr_t_inhierbuff t
                    ,payaccin         pai
               where t.identbefore = usr_pkg_pub_const.nidentbefore
                 and connect_ext = sconnect_ext
                 and t.out_document0 = pai.rn)
    loop
      /* проверка заголовка */
      usr_pkg_payaccin.payaccin_ainsert(nrn => c.out_document0, ncompany => ncompany);

      /*Пересчитаем калькуляцию, для привязки к бюджету*/
      usr_p_payaccinspclc_cre( c.out_document0);   
      
    end loop;
  
    /* Очистка записей временной таблицы взаимосвязей */
    delete from usr_t_inhierbuff
     where identbefore = usr_pkg_pub_const.nidentbefore
       and connect_ext = sconnect_ext;
    usr_pkg_pub_const.nidentbefore := null;
  
  end FACEACC_AMAKEPAYACCIN;
  --#########################################################################################################

  procedure FACEACC_BMAKESHEEPDIRSCUST
  /*
    Лицевой счёт. Формирование распоряжения на отгрузку потребителям. До
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    nsheepdirscustbuf pkg_std.tref;
  
    nnumber pkg_std.tnumber;
  begin
    /* RN заголовка  буфера */
    begin
      select rn
        into nsheepdirscustbuf
        from sheepdirscustbuf
       where connect_ext = pkg_session.get_connect_ext;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0
                                ,ndocument   => nrn
                                ,sunit_table => 'SHEEPDIRSCUSTBUF');
      when too_many_rows then
        p_exception(0
                   ,'Найдено больше одной записи в буферной таблице для сессии <%s> в разделе <%s>.'
                   ,pkg_session.get_connect_ext
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1
                                                                           ,stable_name => 'SHEEPDIRSCUSTBUF')));
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа в буферной таблице для сессии <%s> в разделе <%s>.'
                   ,pkg_session.get_connect_ext
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1
                                                                           ,stable_name => 'SHEEPDIRSCUSTBUF')));
    end;
  
    /* Удаление спецификаций в буфере */
    for c in (select company
                    ,prn
                    ,rn
                from sheepdirscustspbuf
               where prn = nsheepdirscustbuf)
    loop
      p_shdirscustspbuf_base_delete(ncompany => c.company, nprn => c.prn, nrn => c.rn);
    end loop;
  
    /* Добавление спецификаций на неотпущенное количество */
    for c in (select company
                    ,taxgr
                    ,nomen
                    ,nomenpack
                    ,nommodif
                    ,nommodifpack
                    ,sum(quant - plan_quant) as rest_quant
                    ,sum(summwithnds - plan_sum) as rest_summwithnds
                from fcacoperplans
               where prn = nrn
                 and 1 = inexp_sign /* расход */
                 and 0 != quant - plan_quant
               group by company
                       ,taxgr
                       ,nomen
                       ,nomenpack
                       ,nommodif
                       ,nommodifpack)
    loop
      pkg_dictaxis_calc.p_calculate_base(nflag_smart => 0
                                        ,ncompany    => c.company
                                        ,ddate       => current_date
                                        ,nsumm_sign  => 1
                                        ,ninsumm     => c.rest_summwithnds
                                        ,ntaxgr      => c.taxgr
                                        ,nquant      => 1
                                        ,nncp_sign   => 1);
      p_shdirscustspbuf_base_insert(ncompany         => c.company
                                   ,nprn             => nsheepdirscustbuf
                                   ,ntaxgr           => c.taxgr
                                   ,ngoodsparty      => null
                                   ,nnomen           => c.nomen
                                   ,nnomnpack        => c.nomenpack
                                   ,nnommodif        => c.nommodif
                                   ,nnomnmodifpack   => c.nommodifpack
                                   ,narticle         => null
                                   ,ncell            => null
                                   ,nprice           => pkg_dictaxis_calc.f_get_value(nident => 0) /
                                                        c.rest_quant /* без НДС*/
                                   ,ndiscount        => 0
                                   ,nquant           => c.rest_quant
                                   ,nquantalt        => 0
                                   ,ncoeff           => 0
                                   ,ncoeff_val_sign  => 0
                                   ,ncoeff_calc_sign => 0
                                   ,npricemeas       => 1
                                   ,nsumm            => pkg_dictaxis_calc.f_get_value(nident => 0)
                                   ,nsummwithnds     => pkg_dictaxis_calc.f_get_value(nident => 2)
                                   ,nsumm_nds        => pkg_dictaxis_calc.f_get_value(nident => 8)
                                   ,nautocalc_sign   => 1
                                   ,dbegindate       => null
                                   ,denddate         => null
                                   ,snote            => null
                                   ,nrn              => nnumber);
    end loop;
  
  end FACEACC_BMAKESHEEPDIRSCUST;
  --#########################################################################################################

  procedure FACEACC_AMAKESHEEPDIRSCUST
  /*
    Лицевой счёт. Формирование распоряжения на отгрузку потребителям. После
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;
  
    /* По сформированным документам */
    for c in (select column_value
                    ,count(*) over() as ncount
                from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable)))
    loop
      /* проверка заголовка */
      usr_pkg_sheepdirscust.sheepdirscust_ainsert(nrn => c.column_value, ncompany => ncompany);
    end loop;
  
  end FACEACC_AMAKESHEEPDIRSCUST;
  --#########################################################################################################

  procedure FACEACC_BMAKEPAYNOTES
  /*
    Лицевой счёт. Проверка перед формированием платежа
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    /* Запрет формирования  платежей */
    p_exception(0
               ,'Запрещено добавление платежа НЕ из раздела "Банковские документы". %s'
               ,cr || f_docdescrs_get_description(sunitcode => 'FaceAccounts', ndocument => nrn));
    --end if;
  end FACEACC_BMAKEPAYNOTES;
  --#########################################################################################################

  procedure FACEACC_AMAKEPAYNOTES
  /*
    Лицевой счёт. Проверка после формирования платежа
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end FACEACC_AMAKEPAYNOTES;
  --#########################################################################################################

  procedure FACEACC_CHECK_BASE
  /*
    Заголовок. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow      faceacc%rowtype;
    rfpdartcl fpdartcl%rowtype;
  begin
    /* Считывание */
    rrow := faceacc_get(nrn => nrn);

    /* Запрет использования подразделение Модуль */
    if rrow.subdiv = 1026748 then 
      P_Exception(0, 'Подразделение "Модуль" использовать в заказах запрещено. Выберите реальное подразделение.');
    end if ;
  
    /* ПРОВЕРКИ */
    /* Статья затрат НЕ УКАЗАНА */
    if rrow.ieelement is null then
      /* Статья затрат для НЕвнутренних лицевых счетов */
      if rrow.acc_class != 3 then
        p_exception(0
                   ,'Не заполнено поле "Статья затрат". %s'
                   ,cr || rrow.numb
                   ,cr || get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rrow.agent));
      end if;
      /* Статья затрат УКАЗАНА */
    elsif utilizer not in ('KUROEDOVA_AB') then
      /* Считывание статьи затрат */
      rfpdartcl := udo_pkg_get.row_fpdartcl(nrn => rrow.ieelement, nsmart => 0);
      /* Если статья затрат НЕ В КАТАЛОГЕ "Статьи БДДС" */
      if not usr_pkg_common.is_crn_in_hiercrn(ncrn => rfpdartcl.crn, shier_crn_list => 6171728) then
        p_exception(0
                   ,'В "Статья затрат" указана статья <%s> из каталога <%s>. Статьи из этого каталога запрещено использовать в данном разделе.%s'
                   ,rfpdartcl.code
                   ,usr_pkg_common.get_cat_higher_str(nrn => rfpdartcl.crn, nsigns => 1)
                   ,cr ||
                    f_docdescrs_get_description(sunitcode => 'FaceAccounts', ndocument => rrow.rn));
      end if;
    end if;
  
    /* Наличие символа "\" в номере */
    if rrow.acc_class = 3
       and instr(rrow.numb, '\') != 0 then
      p_exception(0
                 ,'Недопостимо использовать символ "\" в номере лицевого счёта с типом "Внутренний". %s%s'
                 ,cr || rrow.numb
                 ,cr || get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rrow.agent));
    end if;
  
  end FACEACC_CHECK_BASE;
  --#########################################################################################################

  procedure FACEACC_CHECK_OVER_SHIP
  /*
  Заголовок. Проверка превышения суммы отгрузки (товаров и услуг) над суммой этапа договора
  */
  (
   nFLAGSMART in number
  ,nRN        in number
  ,dDATE      in date
  ,nDIFF      out number
  ) 
  is
    rRow      faceacc%rowtype;
  begin
    /* Считывание */
    rRow := faceacc_get( nrn => nRN );

    /* Вызов основной процедуры */
    faceacc_check_over_ship( nflagsmart => nFLAGSMART
                            ,rrow       => rRow
                            ,ddate      => dDATE
                            ,ndiff      => nDIFF ) ;
  end FACEACC_CHECK_OVER_SHIP;
  --#########################################################################################################

  procedure FACEACC_CHECK_OVER_SHIP
  /*
  Заголовок. Проверка превышения суммы отгрузки (товаров и услуг) над суммой этапа договора
  */
  (
   nFLAGSMART in number
  ,rROW       in faceacc%rowtype
  ,dDATE      in date
  ,nDIFF      out number
  ) 
  is
    rStages   stages%rowtype;
    nShipSum  pkg_std.tsumm; 
  begin
    /* Если лицевой счёт связан с договором */
    if rROW.SIGN_CONTRACT = 1 then

      /* Считываем этап по RN лицевого счёта */
      rStages := usr_pkg_contracts.stages_get_by_faceacc( nfaceacc => rROW.RN );

      /* Сумма отгрузки (товаров + услуг) */
      nShipSum :=   faceacc_get_perf_sum( nrn => rROW.RN, ssum_type => 'FACT_SHIP' )
                  + faceacc_get_perf_sum( nrn => rROW.RN, ssum_type => 'FACT_SERV' );

      /* Разница между суммой этапа и суммой отгрузки по лицевому счёту, округлённая до 10 */
      nDIFF := round( rStages.stage_sumtax, -1 ) - round( nShipSum, -1 );

      /* Если разница меньше нуля и договор отражается на сумме договора */
      if nDIFF < 0 and rStages.sign_sum = 1  then
        p_exception(nFLAGSMART, 'Сумма отгрузки по лицевому счёту (товаров и услуг) %s больше суммы этапа договора %s. '||
                   'Разница: %s. Лицевой счёт: %s'
                   ,usr_f_n2ss( nShipSum ), usr_f_n2ss( rStages.stage_sumtax ), usr_f_n2ss( nDIFF ), rROW.NUMB );
      end if;

    end if;

  end FACEACC_CHECK_OVER_SHIP;
  /*#########################################################################################################*/
  
  function FACEACC_CHECK_SUMM_CORRECT
  /* 
  Функция проверки корректности сумм ЛС по отношению к истории исполнения. Суммы корректны: 0 - да, 1 - нет
  */
  (
   nRN       in number
  ) 
  return number 
  as
    rRow    faceacc%rowtype;
    nRes    pkg_std.tnumber := 0; 
  begin
    /* Считывание лицевого счёта */
    rRow := usr_pkg_faceacc.faceacc_get( nrn => nRN );

    /* Процедура проверки */    
    return usr_pkg_faceacc.faceacc_check_summ_correct( rrow => rRow ); 

  end FACEACC_CHECK_SUMM_CORRECT;
  /*#########################################################################################################*/
  
  function FACEACC_CHECK_SUMM_CORRECT
  /* 
  Функция проверки корректности сумм ЛС по отношению к истории исполнения. Суммы корректны: 0 - да, 1 - нет
  */
  (
   rROW       in faceacc%rowtype
  ) 
  return number 
  as
    rHist   fcacperfhist%rowtype;
    nRes    pkg_std.tnumber := 0; 
  begin
    /* Считывание истории исполнения лицевого счета на максимальную дату */
    begin
      select *
        into rHist
        from fcacperfhist
       where prn = rROW.RN
         and date_hist = (select max(date_hist)
                            from fcacperfhist
                           where prn = rROW.RN);
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске истории исполнения ЛС <%s>.', rROW.numb );
    end;

    /* Проверка сумм */
    if nvl( rROW.CURRENT_SUM, 0 )   != nvl( rROW.BEGIN_SUM, 0 )  + nvl( rHist.fact_income, 0 ) - nvl( rHist.fact_ship, 0 ) 
                                     - nvl( rHist.fact_serv, 0 ) + nvl( rHist.fact_payed, 0 )  - nvl( rHist.fact_posted, 0 ) 
    or nvl( rROW.PLAN_SUM, 0 )      != nvl( rROW.BEGIN_SUM, 0 )  + nvl( rHist.plan_income, 0 ) - nvl( rHist.plan_ship, 0 ) 
                                     - nvl( rHist.plan_serv, 0 ) + nvl( rHist.plan_payed, 0 )  - nvl( rHist.plan_posted, 0 ) 
    or nvl( rROW.DOC_INCOME, 0 )    != nvl( rHist.doc_income, 0 ) 
    or nvl( rROW.PLAN_INCOME, 0 )   != nvl( rHist.plan_income, 0 ) 
    or nvl( rROW.FACT_INCOME, 0 )   != nvl( rHist.fact_income, 0 ) 
    or nvl( rROW.FACT_DEFICIT, 0 )  != nvl( rHist.fact_deficit, 0 ) 
    or nvl( rROW.DOC_SHIP, 0 )      != nvl( rHist.doc_ship, 0 ) 
    or nvl( rROW.PLAN_SHIP, 0 )     != nvl( rHist.plan_ship, 0 ) 
    or nvl( rROW.FACT_SHIP, 0 )     != nvl( rHist.fact_ship, 0 ) 
    or nvl( rROW.DOC_SERV, 0 )      != nvl( rHist.doc_serv, 0 ) 
    or nvl( rROW.PLAN_SERV, 0 )     != nvl( rHist.plan_serv, 0 ) 
    or nvl( rROW.FACT_SERV, 0 )     != nvl( rHist.fact_serv, 0 ) 
    or nvl( rROW.DOC_POSTED, 0 )    != nvl( rHist.doc_posted, 0 ) 
    or nvl( rROW.PLAN_POSTED, 0 )   != nvl( rHist.plan_posted, 0 ) 
    or nvl( rROW.FACT_POSTED, 0 )   != nvl( rHist.fact_posted, 0 ) 
    or nvl( rROW.DOC_PAYED, 0 )     != nvl( rHist.doc_payed, 0 ) 
    or nvl( rROW.PLAN_PAYED, 0 )    != nvl( rHist.plan_payed, 0 ) 
    or nvl( rROW.FACT_PAYED, 0 )    != nvl( rHist.fact_payed, 0 ) then
      nRes := 1;
    end if;

    /* Результат */
    return nRes;
    
  end FACEACC_CHECK_SUMM_CORRECT;
  --#########################################################################################################

  procedure FACEACC_OPEN
  /*
    Заголовок. Открыть
    */
  (
    rrow       in faceacc%rowtype
   ,dopen_date in date
   ,nmode      in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) is
    rrowtmp faceacc%rowtype; /* откуда происходит редактирование (0 - из лицевых счетов, 1 - из договоров) */
  begin
    /* Режим выполнения: 0 - штатный */
    if nmode = 0 then
      p_faceacc_open(ncompany => rrow.company, snumber => rrow.numb, dopen_date => dopen_date);
    
      /* Режим выполнения: 1 - пользовательский
      - игнорируется связь с договором */
    elsif nmode = 1 then
      /* Копируем во временную переменную */
      rrowtmp := rrow;
    
      /* Подменяем значения */
      rrowtmp.fact_open_date  := dopen_date;
      rrowtmp.fact_close_date := null;
    
      /* Исправление */
      faceacc_base_update(rrow => rrowtmp, nedit_sign => rrow.sign_contract);
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nmode);
    end if;
  
  end FACEACC_OPEN;
  --#########################################################################################################

  procedure FACEACC_CLOSE
  /*
    Заголовок. Закрыть
    */
  (
    rrow        in faceacc%rowtype
   ,dclose_date in date
   ,nmode       in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) is
    rrowtmp faceacc%rowtype;
  begin
    /* Режим выполнения: 0 - штатный */
    if nmode = 0 then
      p_faceacc_close(ncompany => rrow.company, snumber => rrow.numb, dclose_date => dclose_date);
    
      /* Режим выполнения: 1 - пользовательский
      - игнорируется связь с договором */
    elsif nmode = 1 then
      /* Копируем во временную переменную */
      rrowtmp := rrow;
    
      /* Подменяем значения */
      rrowtmp.fact_close_date := dclose_date;
    
      /* Исправление */
      faceacc_base_update(rrow => rrowtmp, nedit_sign => rrow.sign_contract);
    
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nmode);
    end if;
  
  end FACEACC_CLOSE;
  --#########################################################################################################

  procedure FACEACC_FIN_DETAILS_UPDATE
  /*
    Заголовок. Исправить финансовые параметры в лицевом счёте и документах
    */
  (
    rrow       in faceacc%rowtype
   ,nflagsmart in number
   ,nfpdartcl  in number
  ) is
    rrowtmp         faceacc%rowtype := rrow;
    rpaynotes       paynotes%rowtype;
    rfinpaynotes    finpaynotes%rowtype;
    rfinpaycalendar finpaycalendar%rowtype;
    rpaynotesclc    paynotesclc%rowtype;
    rfpdartcl       fpdartcl%rowtype;
    rpayaccinspclc  payaccinspclc%rowtype;
  
    svarchar pkg_std.tstring;
  begin
    /* Считывание статьи лицевого счёта */
    rfpdartcl := usr_pkg_fpdartcl.fpdartcl_get(nrn => nfpdartcl);
  
    /* Если статья в счёте не равна статье из параметра */
    if nvl(rrow.ieelement, 0) != nvl(nfpdartcl, 0) then
      /* Подменяем во временной переменной */
      rrowtmp.ieelement := nfpdartcl;
      /* Исправляем лицевой счёт */
      faceacc_bupdate(nrn => rrowtmp.rn, ncompany => rrowtmp.company);
      faceacc_base_update(rrow => rrowtmp, nedit_sign => 0);
      faceacc_aupdate(nrn => rrowtmp.rn, ncompany => rrowtmp.company);
    else
      /* мнемокод статьи лицевого счёта */
      svarchar := usr_pkg_fpdartcl.fpdartcl_get_code(nrn => rrow.ieelement);
      /* сообщение об ошибке */
      p_exception(nflagsmart
                 ,'Статья затрат в лицевом счёте равна статье затрат, заданной в параметре <%s>.%s'
                 ,svarchar
                 ,cr ||
                  f_docdescrs_get_description(sunitcode => 'FaceAccounts', ndocument => rrow.rn));
    end if;
  
    /* По платежам лицевого счёта */
    for c in (select * from paynotes where faceacc = rrow.rn)
    loop
      /* Сохранение в переменную */
      rpaynotes := c;
      /* Считывание расширений платежа */
      usr_pkg_paynotes.paynotes_get_fin_extensions(nrn             => rpaynotes.rn
                                                  ,nflagsmart      => 0
                                                  ,rfinpaynotes    => rfinpaynotes
                                                  ,rfinpaycalendar => rfinpaycalendar);
      /* Если текущая статья затрат в платеже не равна НОВОЙ СТАТЬЕ ИЗ ПАРАМЕТРА */
      if nvl(rfinpaynotes.ieelement, 0) != nvl(nfpdartcl, 0) then
        /* Подмена значения в переменной */
        rfinpaynotes.ieelement := nfpdartcl;
        /* Исправление фин.расширения платежа */
        usr_pkg_paynotes.finpaynotes_base_update(rrow            => rfinpaynotes
                                                ,rpaynotes       => rpaynotes
                                                ,rfinpaycalendar => rfinpaycalendar
                                                ,nmode           => 1);
      end if;
    
      /* По калькуляциям платежа, у которых статья затрат равна ИСХОДНОЙ СТАТЬЕ ЛЦИЦЕВОГО СЧЁТА */
      for c1 in (select *
                   from paynotesclc
                  where prn = rpaynotes.rn
                    and nvl(cost_article, 0) = nvl(rrow.ieelement, 0))
      loop
        /* Сохранение в переменную */
        rpaynotesclc := c1;
        /* Подмена значения в переменной */
        rpaynotesclc.cost_article := nfpdartcl;
        /* Исправление калькуляции  */
        begin
          usr_pkg_paynotes.paynotesclc_base_update(rrow => rpaynotesclc, nmode => 0);
        exception
          when others then
            /* если у платежа есть калькуляция с такой же статьёй */
            if sqlerrm like '%unique constraint (PARUS.C_PAYNOTESCLC_UK) violated%' then
              p_exception(0
                         ,'В платеже уже присутствует калькуляция со статьёй <%s>.%s'
                         ,rfpdartcl.code
                         ,cr || f_docdescrs_get_description(sunitcode => 'PayNotes'
                                                           ,ndocument => rpaynotesclc.prn));
            else
              raise;
            end if;
        end;
      end loop;
    end loop;
  
    /* По калькуляциям входящих счетов, у которых статья затрат равна ИСХОДНОЙ СТАТЬЕ ЛЦИЦЕВОГО СЧЁТА */
    for c in (select c.*
                from payaccin      h
                    ,payaccinspec  s
                    ,payaccinspclc c
               where h.faceacc = rrow.rn
                 and s.prn = h.rn
                 and c.prn = s.rn
                 and nvl(c.cost_article, 0) = nvl(rrow.ieelement, 0))
    loop
      /* Сохранение в переменную */
      rpayaccinspclc := c;
      /* Подмена значения в переменной */
      rpayaccinspclc.cost_article := nfpdartcl;
      /* Исправление калькуляции */
      begin
        usr_pkg_payaccin.payaccinspclc_base_update(rrow => rpayaccinspclc);
      exception
        when others then
          /* если у платежа есть калькуляция с такой же статьёй */
          if sqlerrm like '%unique constraint (PARUS.C_PAYACCINSPCLC_UK) violated%' then
            p_exception(0
                       ,'В спецификации уже присутствует калькуляция со статьёй <%s>.%s'
                       ,rfpdartcl.code
                       ,cr || f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs'
                                                         ,ndocument => rpayaccinspclc.prn));
            /* другая ошибка */
          else
            raise;
          end if;
      end;
    end loop;
  
    /* По показателям (Бюджетирование -- Показатели) 
    2024-12-19 Городецкий  (Надо выяснить, зачем в показателях состав затрат, если там есть лицевой счет и состав затрат задается там!
    */
  
    for cur in (select p.rn
                  from udo_t_mark p
                 where p.faceacc = rrow.rn
                   and p.fpdartcl != rrow.ieelement)
    loop
    
      update udo_t_mark tm set tm.fpdartcl = nfpdartcl where tm.rn = cur.rn;
    
    end loop;
  
  end FACEACC_FIN_DETAILS_UPDATE;
  --#########################################################################################################

  procedure FACEACC_BASE_INSERT
  /*
    Заголовок. Добавление базовое
    */
  (
    rrow in faceacc%rowtype
   ,nrn  out number
  ) is
  begin
    p_faceacc_base_insert(ncompany         => rrow.company
                         ,ncrn             => rrow.crn
                         ,njur_pers        => rrow.jur_pers
                         ,nprn             => rrow.prn
                         ,nagent           => rrow.agent
                         ,nfinerule        => rrow.finerule
                         ,snumber          => rrow.numb
                         ,nacc_kind        => rrow.acc_kind
                         ,nacc_class       => rrow.acc_class
                         ,noper_flag       => rrow.oper_flag
                         ,nsign_contract   => rrow.sign_contract
                         ,nsign_stage      => rrow.sign_stage
                         ,norder_sign      => rrow.order_sign
                         ,nvalid_doctype   => rrow.valid_doctype
                         ,svalid_docnumb   => rrow.valid_docnumb
                         ,dvalid_docdate   => rrow.valid_docdate
                         ,dplan_open_date  => rrow.plan_open_date
                         ,dfact_open_date  => rrow.fact_open_date
                         ,dplan_close_date => rrow.plan_close_date
                         ,dfact_close_date => rrow.fact_close_date
                         ,nexecutive       => rrow.executive
                         ,ncurrency        => rrow.currency
                         ,ncredit_sum      => rrow.credit_sum
                         ,nbegin_sum       => rrow.begin_sum
                         ,ncurrent_sum     => rrow.current_sum
                         ,nplan_sum        => rrow.plan_sum
                         ,nfcacgr          => rrow.fcacgr
                         ,nagnacc          => rrow.agnacc
                         ,nagnfi           => rrow.agnfi
                         ,nagnfo           => rrow.agnfo
                         ,nagn_trans       => rrow.agn_trans
                         ,nsubdiv          => rrow.subdiv
                         ,ntarif           => rrow.tarif
                         ,ndiscount        => rrow.discount
                         ,npay_type        => rrow.pay_type
                         ,nship_type       => rrow.ship_type
                         ,nprice_type      => rrow.price_type
                         ,dprice_date      => rrow.price_date
                         ,nsigntax         => rrow.signtax
                         ,nsame_nomn       => rrow.same_nomn
                         ,ndoc_serv        => rrow.doc_serv
                         ,nplan_serv       => rrow.plan_serv
                         ,nfact_serv       => rrow.fact_serv
                         ,ndoc_ship        => rrow.doc_ship
                         ,nplan_ship       => rrow.plan_ship
                         ,nfact_ship       => rrow.fact_ship
                         ,ndoc_income      => rrow.doc_income
                         ,nplan_income     => rrow.plan_income
                         ,nfact_income     => rrow.fact_income
                         ,nfact_deficit    => rrow.fact_deficit
                         ,ndoc_posted      => rrow.doc_posted
                         ,nplan_posted     => rrow.plan_posted
                         ,nfact_posted     => rrow.fact_posted
                         ,ndoc_payed       => rrow.doc_payed
                         ,nplan_payed      => rrow.plan_payed
                         ,nfact_payed      => rrow.fact_payed
                         ,nfinaccnt        => rrow.finaccnt
                         ,nrespmanager     => rrow.respmanager
                         ,nieelement       => rrow.ieelement
                         ,nfinsource       => rrow.finsource
                         ,npaytool         => rrow.paytool
                         ,npayprior        => rrow.payprior
                         ,npayrule         => rrow.payrule
                         ,ncheck_bal_sign  => rrow.check_bal_sign
                         ,nspec_mark       => rrow.spec_mark
                         ,nbudgexpend_sp   => rrow.budgexpend_sp
                         ,nserv_sum        => rrow.serv_sum
                         ,nserv_percent    => rrow.serv_percent
                         ,nfinplanrest     => rrow.finplanrest
                         ,snote            => rrow.note
                         ,nexpstruct       => rrow.expstruct
                         ,nincomeclass     => rrow.incomeclass
                         ,neconclass       => rrow.econclass
                         ,ndicbunts        => rrow.dicbunts
                         ,naccfndsrc       => rrow.accfndsrc
                         ,ngovcntrid       => rrow.govcntrid
                         ,naddr_agent      => rrow.addr_agent
                         ,naddr_agnacc     => rrow.addr_agnacc
                         ,nrn              => nrn);
  end FACEACC_BASE_INSERT;
  --#########################################################################################################

  procedure FACEACC_BASE_UPDATE
  /*
    Заголовок. Исправление базовое
    */
  (
    rrow       in faceacc%rowtype
   ,nedit_sign in number /* признак откуда происходит редактирование (0 - из лицевых счетов, 1 - из договоров) */
   ,nsign_dir  in number default 0 /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ) is
  begin
    p_faceacc_base_update(nedit_sign       => nedit_sign
                         ,ncompany         => rrow.company
                         ,nrn              => rrow.rn
                         ,nagent           => rrow.agent
                         ,nfinerule        => rrow.finerule
                         ,snumber          => rrow.numb
                         ,nacc_kind        => rrow.acc_kind
                         ,nacc_class       => rrow.acc_class
                         ,nvalid_doctype   => rrow.valid_doctype
                         ,svalid_docnumb   => rrow.valid_docnumb
                         ,dvalid_docdate   => rrow.valid_docdate
                         ,dplan_open_date  => rrow.plan_open_date
                         ,dfact_open_date  => rrow.fact_open_date
                         ,dplan_close_date => rrow.plan_close_date
                         ,dfact_close_date => rrow.fact_close_date
                         ,nexecutive       => rrow.executive
                         ,ncurrency        => rrow.currency
                         ,ncredit_sum      => rrow.credit_sum
                         ,nbegin_sum       => rrow.begin_sum
                         ,ncurrent_sum     => rrow.current_sum
                         ,nplan_sum        => rrow.plan_sum
                         ,nfcacgr          => rrow.fcacgr
                         ,nagnacc          => rrow.agnacc
                         ,nagnfi           => rrow.agnfi
                         ,nagnfo           => rrow.agnfo
                         ,nagn_trans       => rrow.agn_trans
                         ,nsubdiv          => rrow.subdiv
                         ,ntarif           => rrow.tarif
                         ,ndiscount        => rrow.discount
                         ,npay_type        => rrow.pay_type
                         ,nship_type       => rrow.ship_type
                         ,nprice_type      => rrow.price_type
                         ,dprice_date      => rrow.price_date
                         ,nsigntax         => rrow.signtax
                         ,nsame_nomn       => rrow.same_nomn
                         ,ndoc_serv        => rrow.doc_serv
                         ,nplan_serv       => rrow.plan_serv
                         ,nfact_serv       => rrow.fact_serv
                         ,ndoc_ship        => rrow.doc_ship
                         ,nplan_ship       => rrow.plan_ship
                         ,nfact_ship       => rrow.fact_ship
                         ,ndoc_income      => rrow.doc_income
                         ,nplan_income     => rrow.plan_income
                         ,nfact_income     => rrow.fact_income
                         ,nfact_deficit    => rrow.fact_deficit
                         ,ndoc_posted      => rrow.doc_posted
                         ,nplan_posted     => rrow.plan_posted
                         ,nfact_posted     => rrow.fact_posted
                         ,ndoc_payed       => rrow.doc_payed
                         ,nplan_payed      => rrow.plan_payed
                         ,nfact_payed      => rrow.fact_payed
                         ,nfinaccnt        => rrow.finaccnt
                         ,nrespmanager     => rrow.respmanager
                         ,nieelement       => rrow.ieelement
                         ,nfinsource       => rrow.finsource
                         ,npaytool         => rrow.paytool
                         ,npayprior        => rrow.payprior
                         ,npayrule         => rrow.payrule
                         ,ncheck_bal_sign  => rrow.check_bal_sign
                         ,nspec_mark       => rrow.spec_mark
                         ,nbudgexpend_sp   => rrow.budgexpend_sp
                         ,nserv_sum        => rrow.serv_sum
                         ,nserv_percent    => rrow.serv_percent
                         ,snote            => rrow.note
                         ,nexpstruct       => rrow.expstruct
                         ,nincomeclass     => rrow.incomeclass
                         ,neconclass       => rrow.econclass
                         ,ndicbunts        => rrow.dicbunts
                         ,naccfndsrc       => rrow.accfndsrc
                         ,ngovcntrid       => rrow.govcntrid
                         ,naddr_agent      => rrow.addr_agent
                         ,naddr_agnacc     => rrow.addr_agnacc
                         ,nsign_dir        => nsign_dir);
  end FACEACC_BASE_UPDATE;
  /*#########################################################################################################*/
  
  procedure FACEACC_CORRPERF
  (
   nCOMPANY   in number -- Организация
  ,nIDENT     in number -- Идентификатор отмеченных записей
  ,nTRUE_REC  out number -- Количество обработанных записей
  ,nMODE      in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  as
    rHIST FCACPERFHIST%rowtype;
  begin
    /* Режим выполнения: 0 - штатный */
    if nmode = 0 then
      p_faceacc_corrperf( ncompany  => nCOMPANY
                       ,nident      => nIDENT
                       ,ntrue_rec   => nTRUE_REC );
    
      /* Режим выполнения: 1 - пользовательский */
    elsif nmode = 1 then
      /* лицевые счета */
      for rFA in (select F.RN
                        ,F.CRN
                        ,F.JUR_PERS
                    from SELECTLIST L
                        ,FACEACC    F
                   where L.IDENT = nIDENT
                     and L.UNITCODE = 'FaceAccounts'
                     and L.DOCUMENT = F.RN)
      loop
        /* фиксация начала выполнения действия */
        PKG_ENV.PROLOGUE(nCOMPANY, null, rFA.CRN, rFA.JUR_PERS, 'FaceAccounts', 'FACEACC_CORRPERF', 'FACEACC', rFA.RN);
      
        /* запись истории исполнения лицевого счета на максимальную дату */
        begin
          select *
            into rHIST
            from FCACPERFHIST
           where PRN = rFA.RN
             and DATE_HIST = (select max(DATE_HIST)
                                from FCACPERFHIST
                               where PRN = rFA.RN);
        exception
          when NO_DATA_FOUND then
            null;
            rHIST := null; /* 18/07/2025 Столярский Е. */
        end;
      
        /* исправление сумм исполнения */
        if (rHIST.RN is not null) then
          update FACEACC
             set CURRENT_SUM  = BEGIN_SUM + rHIST.FACT_INCOME - rHIST.FACT_SHIP - rHIST.FACT_SERV +
                                rHIST.FACT_PAYED - rHIST.FACT_POSTED
                ,PLAN_SUM     = BEGIN_SUM + rHIST.PLAN_INCOME - rHIST.PLAN_SHIP - rHIST.PLAN_SERV +
                                rHIST.PLAN_PAYED - rHIST.PLAN_POSTED
                ,DOC_INCOME   = rHIST.DOC_INCOME
                ,PLAN_INCOME  = rHIST.PLAN_INCOME
                ,FACT_INCOME  = rHIST.FACT_INCOME
                ,FACT_DEFICIT = rHIST.FACT_DEFICIT
                ,DOC_SHIP     = rHIST.DOC_SHIP
                ,PLAN_SHIP    = rHIST.PLAN_SHIP
                ,FACT_SHIP    = rHIST.FACT_SHIP
                ,DOC_SERV     = rHIST.DOC_SERV
                ,PLAN_SERV    = rHIST.PLAN_SERV
                ,FACT_SERV    = rHIST.FACT_SERV
                ,DOC_POSTED   = rHIST.DOC_POSTED
                ,PLAN_POSTED  = rHIST.PLAN_POSTED
                ,FACT_POSTED  = rHIST.FACT_POSTED
                ,DOC_PAYED    = rHIST.DOC_PAYED
                ,PLAN_PAYED   = rHIST.PLAN_PAYED
                ,FACT_PAYED   = rHIST.FACT_PAYED
           where RN = rFA.RN
             and COMPANY = nCOMPANY;
        
          if (sql%notfound) then
            PKG_MSG.RECORD_NOT_FOUND(rFA.RN, 'FaceAccounts');
          end if;
        
          nTRUE_REC := nvl(nTRUE_REC, 0) + 1;
        /* Моя вставка. Обнуляем исполнения */
        else          
          update faceacc
             set current_sum  = 0
                ,plan_sum     = 0
                ,doc_income   = 0
                ,plan_income  = 0
                ,fact_income  = 0
                ,fact_deficit = 0
                ,doc_ship     = 0
                ,plan_ship    = 0
                ,fact_ship    = 0
                ,doc_serv     = 0
                ,plan_serv    = 0
                ,fact_serv    = 0
                ,doc_posted   = 0
                ,plan_posted  = 0
                ,fact_posted  = 0
                ,doc_payed    = 0
                ,plan_payed   = 0
                ,fact_payed   = 0
           where rn       = rfa.rn
             and company  = nCOMPANY;
        end if;
      
        /* фиксация окончания выполнения действия */
        PKG_ENV.EPILOGUE(nCOMPANY, null, rFA.CRN, rFA.JUR_PERS, 'FaceAccounts', 'FACEACC_CORRPERF', 'FACEACC', rFA.RN);
      end loop;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nmode);
    end if;

  end FACEACC_CORRPERF;
  /*#########################################################################################################*/

  procedure FACEACC_INITHIST
  /* 
  Корректировка истории исполнения 
  Если вызывается не из клиента, то добавить документы в selectlist, а после процедуры очистить
  */
  (
   nCOMPANY       in number
  ,nIDENT         in number
  ) 
  as
    nNumber     pkg_std.tnumber; 
  begin
    /* Инициализация истории исполнения */
    p_faceacc_inithist( ncompany  => nCOMPANY
                       ,nident    => nIDENT
                       ,nsign_del => 1
                       ,ntrue_rec => nNumber );
    /* Коррекция по истории исполнения */
    faceacc_corrperf( ncompany  => nCOMPANY
                     ,nident    => nIDENT
                     ,ntrue_rec => nNumber 
                     ,nmode     => 1 );
  end FACEACC_INITHIST;
  /*#########################################################################################################*/

  procedure FACEACC_FCACPAYPLANS_PAY
  /*
  Пересчитать исполнение плана платежей
  */
  (
   nRN              in number
  ,dPAY_DATE_FROM   in date
  ,dPAY_DATE_TO     in date
  )
  is
    rRow            faceacc%rowtype;
    rPayNotes       paynotes%rowtype;
    nOper_Direct    pkg_std.tnumber;
    nRollBack       pkg_std.tnumber;

    nNumber   pkg_std.tnumber;
  begin
    /* Считывание */
    rRow := usr_pkg_faceacc.faceacc_get( nrn => nRN );

    /* Очистка полей "Исполнено по плану" и "Исполнено фактически" во всех графиках лицевого счёта */
    update fcacpayplans
       set plan_pays = 0
          ,fact_pays = 0
     where prn = rRow.rn;

    /* По платежам лицевого счёта с сортировкой по дате платежа */
    for c in ( select * 
                 from paynotes
                where faceacc = rRow.rn 
                  and ( pay_date >= dPAY_DATE_FROM or dPAY_DATE_FROM is null )
                  and ( pay_date <= dPAY_DATE_TO   or dPAY_DATE_FROM is null )
               order by pay_date )
    loop
      /* Сохранение записи платежа в переменную */
      rPayNotes := c;

      /* Определение типа финансовой операции */
      begin
        select decode( factret_sign, 1, decode( typoper_direct, 1, 0, 1), typoper_direct ),
               decode( factret_sign, 1, 1, 0)
          into nOper_Direct
              ,nRollBack
          from dictoper
         where rn = rPayNotes.finoper;
      exception
        when no_data_found then
          p_exception(0,'Не найдена финансовая операция "%s". %s'
                     ,cr || rPayNotes.finoper
                     ,cr || cr ||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rPayNotes.rn ) ); 
        when others then
          p_exception(0,'Неопределённая ситуация при поиске финансовой операции "%s". %s'
                     ,cr || rPayNotes.finoper
                     ,cr || cr ||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rPayNotes.rn ) ); 
      end;

      /* Разнесение платежа на графики */
      p_fcacpayplans_pay( ncompany    => rPayNotes.company
                         ,nfaceacc    => rPayNotes.faceacc
                         ,ngraphpoint => rPayNotes.graphpoint
                         ,ninexp_sign => nOper_Direct
                         ,nplan_sign  => case rPayNotes.signplan when 1 then 1 else 0 end
                         ,nfact_sign  => case rPayNotes.signplan when 0 then 1 else 0 end
                         ,nrollback   => nRollBack
                         ,nsum        => rPayNotes.pay_sum );
    end loop;

    /* Добавление ЛС в selectlist */
    p_selectlist_insert( nident => rRow.rn, ndocument => rRow.rn, sunitcode => 'FaceAccounts', nrn => nNumber );

    /* Корректировка истории ЛС */
    usr_pkg_faceacc.faceacc_inithist( ncompany => rRow.company, nident => rRow.rn );

    /* Очистка selectlist */
    p_selectlist_clear( nident => rRow.rn );

  end FACEACC_FCACPAYPLANS_PAY;
  /*#########################################################################################################*/

  function FCACOPERPLANS_GET
  /*
    План операций. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacoperplans%rowtype is
    rrow fcacoperplans%rowtype;
  begin
    begin
      select t.* into rrow from fcacoperplans t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0
                                ,ndocument   => nrn
                                ,sunit_table => 'FCACOPERPLANS');
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <' ||
                    nvl(to_char(nrn), 'Не задан') || '> ' || 'в разделе <' ||
                    f_unitlist_getname(get_unitlist_code_table(1, 'FCACOPERPLANS')) || '>.');
    end;
    return(rrow);
  end FCACOPERPLANS_GET;
  --#########################################################################################################

  procedure FCACOPERPLANS_GET_BY_PARAMS
  /*
    Спецификация. Получение записи по параметрам
    */
  (
    nFLAGSMART     in number    default 0
   ,nFLAG_OPTION   in number    default 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
   ,nTOO_MANY_ROWS in number    default 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
   ,nPRN           in number    default null
   ,nINEXP_SIGN    in number    default 1 /* признак приход(0) расход(1) */
   ,nGRAPHPOINT    in number    default null
   ,nNOMEN         in number    default null
   ,nNOMPACK       in number    default null
   ,nNOMMODIF      in number    default null
   ,nNOMMODIFPACK  in number    default null
   ,nTAXGR         in number    default null
   ,nQUANT         in number    default null
   ,nPRICE         in number    default null
   ,nARTICLE       in number    default null
   ,sSERNUMB       in varchar2  default null
   ,nCOUNTRY       in number    default null
   ,sGTD           in varchar2  default null
   ,dBEGINDATE     in date      default null
   ,dENDDATE       in date      default null
   ,dDATE          in date      default null /* Дата определения. Проверяется попадает ли в период даты с... и по... */
   ,rROW           out fcacoperplans%rowtype
  ) 
  is
  begin
    begin
      select *
        into rrow
        from fcacoperplans t
       where ( nvl( t.prn         , -999   )  = nvl( nPRN         , -999   )  or ( nPRN           is null and nFLAG_OPTION = 1 ) )
         and t.inexp_sign = nINEXP_SIGN
         and ( nvl( t.graphpoint  , -999   )  = nvl( nGRAPHPOINT  , -999   )  or ( nGRAPHPOINT    is null and nFLAG_OPTION = 1 ) )
         and ( t.nomen                        = nvl( nNOMEN       , -999   )  or ( nNOMEN         is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.nomenpack   , -999 )    = nvl( nNOMPACK     , -999   )  or ( nNOMPACK       is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.nommodif    , -999 )    = nvl( nNOMMODIF    , -999   )  or ( nNOMMODIF      is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.nommodifpack, -999 )    = nvl( nNOMMODIFPACK, -999   )  or ( nNOMMODIFPACK  is null and nFLAG_OPTION = 1 ) )
         and ( t.taxgr                        = nvl( nTAXGR       , -999   )  or ( nTAXGR         is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.quant       , -999   )  = nvl( nQUANT       , -999   )  or ( nQUANT         is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.price       , -999   )  = nvl( nPRICE       , -999   )  or ( nPRICE         is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.sernumb     , 'null' )  = nvl( sSERNUMB     , 'null' )  or ( sSERNUMB       is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.country     , -999   )  = nvl( nCOUNTRY     , -999   )  or ( nCOUNTRY       is null and nFLAG_OPTION = 1 ) )
         and ( nvl( t.gtd         , 'null' )  = nvl( sGTD         , 'null' )  or ( sGTD           is null and nFLAG_OPTION = 1 ) )
         and ( t.begin_date = dBEGINDATE  or ( dBEGINDATE is null and nFLAG_OPTION = 1 ) )
         and ( t.end_date   = dENDDATE    or ( dENDDATE   is null and nFLAG_OPTION = 1 ) )
         and ( dDATE between t.begin_date and t.end_date  or ( dDATE is null and nFLAG_OPTION = 1 ) );
    exception
      when no_data_found then
        if nFLAGSMART = 0 then
          p_exception(nFLAGSMART, 'Не найдено спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,nPRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCACOPERPLANS' ) ) );
        end if;
      when too_many_rows then
          p_exception( sign( nTOO_MANY_ROWS + nFLAGSMART ), 'Найдено больше одной спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,nPRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCACOPERPLANS' ) ) );
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при поиске спецификации для заголовка с RN <%s> записи в разделе <%s>.%s'
                   ,nprn
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1
                                                                           ,stable_name => 'FCACOPERPLANS'))
                   ,sqlerrm);
    end;
  end FCACOPERPLANS_GET_BY_PARAMS;
  --#########################################################################################################

  procedure FCACOPERPLANS_AINSERT
  /*
    План операций. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow     fcacoperplans%rowtype;
    nstages  pkg_std.tref;
    rstages  stages%rowtype;
    svarchar pkg_std.tstring;
    nnumber  pkg_std.tnumber;
  begin
    -- Заголовок
    rrow := fcacoperplans_get(nrn);
  
    -- ПРОВЕРКИ
   
    -- Базовая
    fcacoperplans_check_base(rrow.rn, rrow.company);
  
  end FCACOPERPLANS_AINSERT;
  --#########################################################################################################

  procedure FCACOPERPLANS_BUPDATE
  /*
    План операций. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    usr_pkg_pub_const.rfcacoperplans := fcacoperplans_get(nrn);
  end FCACOPERPLANS_BUPDATE;
  --#########################################################################################################

  procedure FCACOPERPLANS_AUPDATE
  /*
    План операций. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    -- Проверка базовая
    fcacoperplans_check_base(nrn, ncompany);
  end FCACOPERPLANS_AUPDATE;
  --#########################################################################################################

  procedure FCACOPERPLANS_CHECK_BASE
  /*
    План операций. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    sres varchar2(2000);
  begin
  
   null;
  
  end fcacoperplans_check_base;
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_BASE_INSERT
  /*
  План операций. Добавление базовое
  */
  (
   rROW         in fcacoperplans%rowtype
  ,nRN          out number 
  ,nSIGN_DIR    in number default 0
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin 
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_fcacoperplans_base_insert( ncompany       => rROW.COMPANY
                                  ,nprn           => rROW.PRN
                                  ,ngraphpoint    => rROW.GRAPHPOINT
                                  ,ninexp_sign    => rROW.INEXP_SIGN
                                  ,nnomen         => rROW.NOMEN
                                  ,nnommodif      => rROW.NOMMODIF
                                  ,nnomenpack     => rROW.NOMENPACK
                                  ,nnommodifpack  => rROW.NOMMODIFPACK
                                  ,narticle       => rROW.ARTICLE
                                  ,ntaxgr         => rROW.TAXGR
                                  ,dbegin_date    => rROW.BEGIN_DATE
                                  ,dend_date      => rROW.END_DATE
                                  ,nprice         => rROW.PRICE
                                  ,npricemeas     => rROW.PRICEMEAS
                                  ,ndiscount      => rROW.DISCOUNT
                                  ,nquant         => rROW.QUANT
                                  ,nquant_meas    => rROW.QUANT_MEAS
                                  ,nsumm          => rROW.SUMM
                                  ,nsummwithnds   => rROW.SUMMWITHNDS
                                  ,nsumm_nds      => rROW.SUMM_NDS
                                  ,nautocalc_sign => rROW.AUTOCALC_SIGN
                                  ,nquant_main    => rROW.QUANT_MAIN
                                  ,nquant_alt     => rROW.QUANT_ALT
                                  ,ssernumb       => rROW.SERNUMB
                                  ,ncountry       => rROW.COUNTRY
                                  ,sgtd           => rROW.GTD
                                  ,soriginal_name => rROW.ORIGINAL_NAME
                                  ,snumb          => rROW.NUMB
                                  ,nnomprice      => rROW.NOMPRICE
                                  ,nrn            => nRN
                                  ,nsign_dir      => nSIGN_DIR );
     /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then
      \* Исправление *\
      fcacoperplans_base_update( rrow => rRow2, nmode => 0 );*/
    else
      p_exception( 0, 'Неизвестный режим выполнения <%s>', nmode );
    end if;

  end FCACOPERPLANS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_BASE_UPDATE
  /*
  План операций. Исправление базовое
  */
  (
   rROW         in fcacoperplans%rowtype
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin 
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_fcacoperplans_base_update(ncompany       => rROW.COMPANY
                                 ,nrn            => rROW.RN
                                 ,nprn           => rROW.PRN
                                 ,ngraphpoint    => rROW.GRAPHPOINT
                                 ,ninexp_sign    => rROW.INEXP_SIGN
                                 ,nnomen         => rROW.NOMEN
                                 ,nnommodif      => rROW.NOMMODIF
                                 ,nnomenpack     => rROW.NOMENPACK
                                 ,nnommodifpack  => rROW.NOMMODIFPACK
                                 ,narticle       => rROW.ARTICLE
                                 ,ntaxgr         => rROW.TAXGR
                                 ,dbegin_date    => rROW.BEGIN_DATE
                                 ,dend_date      => rROW.END_DATE
                                 ,nprice         => rROW.PRICE
                                 ,npricemeas     => rROW.PRICEMEAS
                                 ,ndiscount      => rROW.DISCOUNT
                                 ,nquant         => rROW.QUANT
                                 ,nquant_meas    => rROW.QUANT_MEAS
                                 ,nsumm          => rROW.SUMM
                                 ,nsummwithnds   => rROW.SUMMWITHNDS
                                 ,nsumm_nds      => rROW.SUMM_NDS
                                 ,nautocalc_sign => rROW.AUTOCALC_SIGN
                                 ,nquant_main    => rROW.QUANT_MAIN
                                 ,nquant_alt     => rROW.QUANT_ALT
                                 ,ssernumb       => rROW.SERNUMB
                                 ,ncountry       => rROW.COUNTRY
                                 ,sgtd           => rROW.GTD
                                 ,soriginal_name => rROW.ORIGINAL_NAME
                                 ,snumb          => rROW.NUMB
                                 ,nnomprice      => rROW.NOMPRICE);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then
      \* Исправление *\
      fcacoperplans_base_update( rrow => rRow2, nmode => 0 );*/
    else
      p_exception( 0, 'Неизвестный режим выполнения <%s>', nmode );
    end if;

  end FCACOPERPLANS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_INSERT
  /*
  План операций. Добавление
  */
  (
   rV_ROW       in v_fcacoperplans%rowtype
  ,nDUP_RN      in number default 0 
  ,nRN          out number
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_fcacoperplans_insert( ncompany       => rv_ROW.NCOMPANY
                             ,nprn           => rv_ROW.NPRN
                             ,sgraphpoint    => rv_ROW.SGRAPHPOINT
                             ,ninexp_sign    => rv_ROW.NINEXP_SIGN
                             ,snomen         => rv_ROW.SNOMEN
                             ,snommodif      => rv_ROW.SNOMMODIF
                             ,snomenpack     => rv_ROW.SNOMENPACK
                             ,snommodifpack  => rv_ROW.SNOMMODIFPACK
                             ,sarticle       => rv_ROW.SARTICLE
                             ,staxgr         => rv_ROW.STAXGR
                             ,dbegin_date    => rv_ROW.DBEGIN_DATE
                             ,dend_date      => rv_ROW.DEND_DATE
                             ,nprice         => rv_ROW.NPRICE
                             ,npricemeas     => rv_ROW.NPRICEMEAS
                             ,ndiscount      => rv_ROW.NDISCOUNT
                             ,nquant         => rv_ROW.NQUANT
                             ,nquant_meas    => rv_ROW.NQUANT_MEAS
                             ,nsumm          => rv_ROW.NSUMM
                             ,nsummwithnds   => rv_ROW.NSUMMWITHNDS
                             ,nsumm_nds      => rv_ROW.NSUMM_NDS
                             ,nautocalc_sign => rv_ROW.NAUTOCALC_SIGN
                             ,nactm_quant    => rv_ROW.NACTM_QUANT
                             ,nacta_quant    => rv_ROW.NACTA_QUANT
                             ,ssernumb       => rv_ROW.SSERNUMB
                             ,scountry       => rv_ROW.SCOUNTRY
                             ,sgtd           => rv_ROW.SGTD
                             ,soriginal_name => rv_ROW.SORIGINAL_NAME
                             ,snumb          => rv_ROW.SNUMB
                             ,nnomprice      => rv_ROW.NNOMPRICE
                             ,ndup_rn        => nDUP_RN
                             ,nrn            => nRN );
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then
      \* Исправление *\
      fcacoperplans_update( rv_row => rV_Row2, nmode => 0 );*/
    else
      p_exception( 0, 'Неизвестный режим выполнения <%s>', nmode );
    end if;
    
  end FCACOPERPLANS_INSERT;
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_UPDATE
  /*
  План операций. Исправление 
  */
  (
   rV_ROW       in v_fcacoperplans%rowtype
  ,nMODE        in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_fcacoperplans_update( ncompany       => rV_ROW.NCOMPANY
                             ,nrn            => rV_ROW.NRN
                             ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                             ,snomen         => rV_ROW.SNOMEN
                             ,snommodif      => rV_ROW.SNOMMODIF
                             ,snomenpack     => rV_ROW.SNOMENPACK
                             ,snommodifpack  => rV_ROW.SNOMMODIFPACK
                             ,sarticle       => rV_ROW.SARTICLE
                             ,staxgr         => rV_ROW.STAXGR
                             ,dbegin_date    => rV_ROW.DBEGIN_DATE
                             ,dend_date      => rV_ROW.DEND_DATE
                             ,nprice         => rV_ROW.NPRICE
                             ,npricemeas     => rV_ROW.NPRICEMEAS
                             ,ndiscount      => rV_ROW.NDISCOUNT
                             ,nquant         => rV_ROW.NQUANT
                             ,nquant_meas    => rV_ROW.NQUANT_MEAS
                             ,nsumm          => rV_ROW.NSUMM
                             ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                             ,nsumm_nds      => rV_ROW.NSUMM_NDS
                             ,nautocalc_sign => rV_ROW.NAUTOCALC_SIGN
                             ,nactm_quant    => rV_ROW.NACTM_QUANT
                             ,nacta_quant    => rV_ROW.NACTA_QUANT
                             ,ssernumb       => rV_ROW.SSERNUMB
                             ,scountry       => rV_ROW.SCOUNTRY
                             ,sgtd           => rV_ROW.SGTD
                             ,soriginal_name => rV_ROW.SORIGINAL_NAME
                             ,snumb          => rV_ROW.SNUMB
                             ,nnomprice      => rV_ROW.NNOMPRICE );
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then
      \* Исправление *\
      fcacoperplans_update( rv_row => rV_Row2, nmode => 0 );*/
    else
      p_exception( 0, 'Неизвестный режим выполнения <%s>', nmode );
    end if;
    
  end FCACOPERPLANS_UPDATE;
  /*#########################################################################################################*/

  procedure FCACOPERPLANS_UPDATE_EXEC
  /*
  План операций. Исправление исполнения
  */
  (
   nRN                in number
  ,nQUANT_FACT        in number default null
  ,nSUM_FACT          in number default null
  ,nSUMWITHNDS_FACT   in number default null
  ,nSUMNDS_FACT       in number default null
  ) 
  is
   nNumber    pkg_std.tnumber; 
  begin 
    /* Исправление исполнений */
    update fcacoperplans
       set plan_quant = nQUANT_FACT
          ,plan_sum   = nSUMWITHNDS_FACT
          ,fact_quant = nQUANT_FACT
          ,fact_sum   = nSUMWITHNDS_FACT
     where rn = nRN;
    /* Исполненная сумма без НДС */
    pkg_docs_props_vals.modify(nproperty   => 148554177
                              ,sunitcode   => 'FaceAccountsOperOutPlans'
                              ,ndocument   => nRN
                              ,sstr_value  => null
                              ,nnum_value  => nSUM_FACT
                              ,ddate_value => null
                              ,nrn         => nNumber);
    /* Исполненная сумма НДС */
    pkg_docs_props_vals.modify(nproperty   => 267211601
                              ,sunitcode   => 'FaceAccountsOperOutPlans'
                              ,ndocument   => nRN
                              ,sstr_value  => null
                              ,nnum_value  => nSUMNDS_FACT
                              ,ddate_value => null
                              ,nrn         => nNumber);

  end FCACOPERPLANS_UPDATE_EXEC;
  /*#########################################################################################################*/

  function FCACOPEROUTPLANS_GET
  /*
  План расхода. Считывание
  */
  (nrn in number -- RN записи
   ) return fcacoperplans%rowtype is
    rrow fcacoperplans%rowtype;
  begin
    begin
      select t.* into rrow from fcacoperplans t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0
                                ,ndocument   => nrn
                                ,sunit_table => 'FCACOPERPLANS');
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <' ||
                    nvl(to_char(nrn), 'Не задан') || '> ' || 'в разделе <' ||
                    f_unitlist_getname(get_unitlist_code_table(1, 'FCACOPERPLANS')) || '>.');
    end;
    return(rrow);
  end FCACOPEROUTPLANS_GET;
  /*#########################################################################################################*/

  function FCACOPEROUTPLANS_GET_EXEC
  /*
  План расхода. Получить количества и суммы исполнения и остатка
  */
  (
   nRN      in number
  ,sTYPE    in varchar2
  ) 
  return number
  as
    rTmp  transinvcustspecs%rowtype;
    rTmp2 transinvcustspecs%rowtype;
  begin
    usr_pkg_faceacc.fcacoperoutplans_get_exec( nrn              => nRN
                                              ,nquant_fact      => rTmp.quant
                                              ,nsum_fact        => rTmp.summ
                                              ,nsumwithnds_fact => rTmp.summwithnds
                                              ,nsumnds_fact     => rTmp.summ_nds
                                              ,nquant_rest      => rTmp2.quant
                                              ,nsum_rest        => rTmp2.summ
                                              ,nsumwithnds_rest => rTmp2.summwithnds
                                              ,nsumnds_rest     => rTmp2.summ_nds 
                                              );
    return case upper(sTYPE)
             when 'NQUANT_FACT'       then rTmp.quant
             when 'NSUM_FACT'         then rTmp.summ
             when 'NSUMWITHNDS_FACT'  then rTmp.summwithnds
             when 'NSUMNDS_FACT'      then rTmp.summ_nds
             when 'NQUANT_REST'       then rTmp2.quant
             when 'NSUM_REST'         then rTmp2.summ
             when 'NSUMWITHNDS_REST'  then rTmp2.summwithnds
             when 'NSUMNDS_REST'      then rTmp2.summ_nds 
           else null
           end;
  end FCACOPEROUTPLANS_GET_EXEC;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_GET_EXEC
  /*
  План расхода. Получить количества и суммы исполнения и остатка
  */
  (
   nRN                in number
  ,nQUANT_FACT        out number
  ,nSUM_FACT          out number
  ,nSUMWITHNDS_FACT   out number
  ,nSUMNDS_FACT       out number
  ,nQUANT_REST        out number
  ,nSUM_REST          out number
  ,nSUMWITHNDS_REST   out number
  ,nSUMNDS_REST       out number
  ) 
  is
  begin
    /* Получение данных по спецификациям РН потребителям */
    begin
      select a.nquant_fact
            ,a.nsum_fact
            ,a.nsumwithnds_fact
            ,a.nsumnds_fact
            ,nvl( a.quant      , 0) - nvl( a.nquant_fact     , 0 ) as nQuant_rest
            ,nvl( a.summ       , 0) - nvl( a.nsum_fact       , 0 ) as nSum_rest
            ,nvl( a.summwithnds, 0) - nvl( a.nsumwithnds_fact, 0 ) as nSumWithNDS_rest
            ,nvl( a.summ_nds   , 0) - nvl( a.nsumnds_fact    , 0 ) as nSumNDS_rest
        into nQUANT_FACT     
            ,nSUM_FACT       
            ,nSUMWITHNDS_FACT
            ,nSUMNDS_FACT    
            ,nQUANT_REST     
            ,nSUM_REST       
            ,nSUMWITHNDS_REST
            ,nSUMNDS_REST    
        from ( select t.rn
                     ,t.quant      
                     ,t.summ       
                     ,t.summwithnds
                     ,t.summ_nds   
                     ,t.fact_quant                                                                                as nquant_fact
                     ,( select num_value from docs_props_vals where docs_prop_rn = 148554177 and unit_rn = t.rn ) as nsum_fact
                     ,t.fact_sum                                                                                  as nsumwithnds_fact
                     ,( select num_value from docs_props_vals where docs_prop_rn = 267211601 and unit_rn = t.rn ) as nsumnds_fact
                 from fcacoperplans t ) a
        where a.rn = nRN;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'FCACOPERPLANS' ) ) );
    end;

  end FCACOPEROUTPLANS_GET_EXEC;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_AINSERT
  /*
  План расхода. Проверка после добавления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
    rRow              fcacoperplans%rowtype;
    rFaceAcc          faceacc%rowtype;
    nStages           pkg_std.tref;
    rFcAcGraphPoints  fcacgraphpoints%rowtype;

    sVarchar pkg_std.tstring;
    nNumber  pkg_std.tnumber;
  begin
    /* Счиытвание */
    rRow     := fcacoperoutplans_get( nrn => nrn );
    rFaceAcc := faceacc_get( nrn => rRow.prn );
  
    /* ИСПРАВЛЕНИЯ */
    /* Отключение регистрации */
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

    /* Добавление точки графика */
    rFcAcGraphPoints.prn        := rFaceAcc.rn;
    rFcAcGraphPoints.company    := rFaceAcc.company;
    rFcAcGraphPoints.crn        := rFaceAcc.crn;
    rFcAcGraphPoints.sign_hist  := 0;
    rFcAcGraphPoints.jur_pers   := rFaceAcc.jur_pers;
    rFcAcGraphPoints.sheeptype  := 6169967; /* ОтгрПродукции */
    rFcAcGraphPoints.note       := substr( f_docdescrs_get_description( sunitcode => 'FaceAccountsOperOutPlans', ndocument => rRow.rn ), 0, 240 );
    rFcAcGraphPoints.code       := rRow.rn;
    fcacgraphpoints_base_insert( rrow => rFcAcGraphPoints, nrn => rFcAcGraphPoints.rn );
    /* Запись точки графика в текущий график */
    rRow.graphpoint := rFcAcGraphPoints.rn;
    fcacoperplans_base_update( rrow => rRow );

    /* Включение регистрации */
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
  
    /* ПРОВЕРКИ */
    /* RN этапа договора */
    find_contracts_faceacc(nflag_smart  => 1
                          ,ncompany     => rrow.company
                          ,nfaceacc     => rrow.prn
                          ,sfaceacc     => null
                          ,ncontract    => null
                          ,ncontractout => nnumber
                          ,sdoc_type    => svarchar
                          ,sdoc_pref    => svarchar
                          ,sdoc_numb    => svarchar
                          ,ddoc_date    => svarchar
                          ,nstage       => nstages
                          ,sstagenumb   => svarchar
                          ,sfaceaccout  => svarchar);
  
    /* Если ЛС связан с этапом */
    if nstages is not null then
      /* проверка этапа */
      usr_pkg_contracts.stages_check_base(nrn => nstages, ncompany => rrow.company);
    end if;

    /* Соответствие типа номенклатуры и признака разнесения косвенных затрат в структуре цены */
    usr_p_contrprstruct_is_err3(nrn => nrn, out_res => svarchar);
    if svarchar is not null then
      p_exception(0, svarchar);
    end if;

    /* Базовая */
    fcacoperoutplans_check_base(nrn => rrow.rn, ncompany => rrow.company);
  
  end FCACOPEROUTPLANS_AINSERT;
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_BUPDATE
  /*
  План расхода. Проверка перед исправлением
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    usr_pkg_pub_const.rfcacoperoutplans := fcacoperoutplans_get( nrn => nrn );
  end FCACOPEROUTPLANS_BUPDATE;
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_AUPDATE
  /*
  План расхода. Проверка после исправления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
    rRow              fcacoperplans%rowtype;
    rFcAcGraphPoints  fcacgraphpoints%rowtype;
    
    sRes              varchar2(2000);
  begin
    /* Заголовок */
    rRow := fcacoperoutplans_get( nrn => nrn );
  
    /* ИСПРАВЛЕНИЯ */
    /* Если задана точка графика */
    if rRow.graphpoint is not null then
      /* Считывание точки */
      rFcAcGraphPoints := fcacgraphpoints_get( nrn => rRow.graphpoint );
      /* Если примечание точки не равно описанию графика */
      if cmp_vc2( rFcAcGraphPoints.note, f_docdescrs_get_description( sunitcode => 'FaceAccountsOperOutPlans', ndocument => rRow.rn) ) != 1 then
        /* Записываем описание графика в примечание точки */
        rFcAcGraphPoints.note := f_docdescrs_get_description( sunitcode => 'FaceAccountsOperOutPlans', ndocument => rRow.rn);
        fcacgraphpoints_base_update( rrow => rFcAcGraphPoints );
      end if;                
    end if;

    /* ПРОВЕРКИ */
    /* Базовая */
    fcacoperoutplans_check_base( nrn => nrn, ncompany => ncompany );
    /* Соответствие типа номенклатуры и признака разнесения косвенных затрат в структуре цены */
    usr_p_contrprstruct_is_err3(nrn => nrn, out_res => sres);
    if sres is not null then
      p_exception(0, sres);
    end if;
    /* Исправление Точки графика */
    if cmp_num( rRow.graphpoint, usr_pkg_pub_const.rfcacoperoutplans.graphpoint ) != 1 then
      p_exception(0, 'Запрещено исправлять поле "Точка графика". %s'
                 ,cr || f_docdescrs_get_description(sunitcode => 'FaceAccountsOperOutPlans', ndocument => rRow.prn ) );
    end if;
  
  end FCACOPEROUTPLANS_AUPDATE;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_BDELETE
  /*
  План расхода. Проверка перед удалением
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    /* Заголовок */
    usr_pkg_pub_const.rFcAcOperOutPlans := fcacoperoutplans_get( nRN => nRN );
  
  end FCACOPEROUTPLANS_BDELETE;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_ADELETE
  /*
  План расхода. Проверка после удаления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    /* ИСПРАВЛЕНИЯ */
    /* Если была заполнена точка графика */
    if usr_pkg_pub_const.rFcAcOperOutPlans.graphpoint is not null then
      /* Удаляем точку графика */
      p_fcacgraphpoints_base_delete( ncompany => usr_pkg_pub_const.rFcAcOperOutPlans.company, nrn => usr_pkg_pub_const.rFcAcOperOutPlans.graphpoint );
    end if;
  
  end FCACOPEROUTPLANS_ADELETE;
  --#########################################################################################################

  procedure FCACOPEROUTPLANS_CHECK_BASE
  /*
    План расхода. Проверка общая
    */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
    rRow      fcacoperplans%rowtype;
    rDicNomns dicnomns%rowtype;
    rFaceAcc  faceacc%rowtype;
    rStages   stages%rowtype;
    nProject  pkg_std.tref; 
    rProject  project%rowtype;
    rPrjType  prjtype%rowtype;
    
  begin
    /* Считывание */
    rRow      := fcacoperoutplans_get(nrn => nrn);
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rRow.nomen, nflagsmart => 0 );
    rFaceAcc  := faceacc_get(nrn => rRow.prn);
  
    /* Если лицевой счёт создан из договора */
    if rFaceAcc.sign_contract = 1 then
      /* Считывание этапа договора */
      begin
        select * into rStages from stages t where t.faceacc = rFaceAcc.rn;
      exception
        when no_data_found then
          p_exception(0, 'Не найден этап договора для лицевого счёта. %s'
                     ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn));
        when too_many_rows then
          p_exception(0, 'Найдено больше одного этапа договора для лицевого счёта. %s'
                     ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn));
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске этапа договора для лицевого счёта. %s%s'
                     ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn)
                     ,sqlerrm);
      end;
      
    
      if rRow.inexp_sign = 1
         and usr_f_dnm_get_ips_id_list(rRow.Nomen)  is null /*Нет IPS ID*/
      then
        p_exception(0
                   ,'В графиках отпуска товаров и услуг запрещено использовать номенклатуры без заданного признака "Интремех ID"');
      end if;
      
      
      /* Считывание проекта, связанного с договором */
      nProject := usr_pkg_doclinks.doclinks_link_in_doc( ntoo_many_rows => 0
                                                        ,sout_unitcode  => 'Contracts'
                                                        ,nout_document  => rStages.prn
                                                        ,sin_unitcode   => 'Projects' );
      if nProject is not null then
        rProject := usr_pkg_project.project_get(nrn => nProject);
      end if;
      /* Тип проекта */
      if rProject.prjtype is not null then
        rPrjType := udo_pkg_get.row_prjtype(nrn => rProject.prjtype);
      end if;

      /* Заполненность налоговой группы */
      if rRow.taxgr is null then
        p_exception(0, 'Налоговая группа графика не заполнена. %s%s'
                   ,cr || f_docdescrs_get_description('FaceAccountsOperOutPlans', rRow.rn)
                   ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn));
      end if;
      /* Проверка налоговой группы графика и этапа */
      if  nvl(rRow.taxgr, 0) != nvl(rStages.taxgr, 0)
      and rStages.taxgr is not null then
        p_exception(0, 'Налоговая группа графика не равна налоговой группе этапа. %s%s'
                   ,cr || f_docdescrs_get_description('FaceAccountsOperOutPlans', rRow.rn)
                   ,cr || f_docdescrs_get_description('ContractsStages', rStages.rn));
      end if;

      /* 
      Быкова Ксения Валерьевна № 19564 от 17.07.2025 10:35
      По этапам договоров со статьями затрат: Тематические доходы (Бюджет) и Субсидии на разработки, 
      а также типами  проекта, которые не являются поставочными ( все проекты кроме: 16, 17, 18, 19) 
      сумма графика отпуска товаров и услуг ( с налогами и без) должна быть равна нулю для всех вновь создаваемых строк графиков отпуска. 
      Кроме услуг.
      */
      if  nvl( rFaceAcc.ieelement, -1 ) in     ( 6172140, 110949068 )                 /* Статья затрат ЛС: Темат. доходы_Б, СубсидииРазработки_Б */
      and nvl( rProject.prjtype  , -1 ) not in ( 1082776, 1082784, 1082785, 1082786 ) /* Тип проекта НЕ : 16, 17, 18, 19 */
      and nvl( rRow.summ, 0 ) + nvl( rRow.summwithnds, 0 ) + nvl( rRow.summ_nds, 0 ) != 0 
      and rDicNomns.nomen_type != 2 then 
        p_exception(0, 'Поля "Сумма без налогов", "Сумма с налогами", "Сумма НДС" должны быть равны "0", т.к. статья затрат этапа <%s>, и тип проекта <%s>. %s%s%s'
                   ,usr_pkg_fpdartcl.fpdartcl_get_code( nrn => rFaceAcc.ieelement, nflagsmart => 1 )
                   ,rPrjType.name ||' ('||  rPrjType.code ||')' 
                   ,cr||cr|| f_docdescrs_get_description('FaceAccountsOperOutPlans', rRow.rn)
                   ,cr||cr|| f_docdescrs_get_description('ContractsStages', rStages.rn)
                   ,cr||cr|| f_docdescrs_get_description('Contracts', rStages.prn) ) ;
      end if;
    end if;
  
    /* Проверка дат графика относительно плановых дат лицевого счёта */
    if rRow.begin_date not between rFaceAcc.plan_open_date and rFaceAcc.plan_close_date then
      p_exception(0, 'Дата начала в графике <%s> находится вне периода действия лицевого счёта с <%s> по <%s>. %s%s'
                 ,decode_date(rRow.begin_date)
                 ,decode_date(rFaceAcc.plan_open_date)
                 ,decode_date(rFaceAcc.plan_close_date)
                 ,cr || f_docdescrs_get_description('FaceAccountsOperOutPlans', rRow.rn)
                 ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn));
    end if;
    if rRow.end_date not between rFaceAcc.plan_open_date and rFaceAcc.plan_close_date then
      p_exception(0, 'Дата окончания в графике <%s> находится вне периода действия лицевого счёта с <%s> по <%s>. %s%s'
                 ,decode_date(rRow.end_date)
                 ,decode_date(rFaceAcc.plan_open_date)
                 ,decode_date(rFaceAcc.plan_close_date)
                 ,cr || f_docdescrs_get_description('FaceAccountsOperOutPlans', rRow.rn)
                 ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn));
    end if;
  
    /* Запрещённые для заполнения поля */
    if rRow.country is not null
    or rRow.sernumb is not null
    or rRow.gtd is not null then
      p_exception(0, 'Запрещено заполнение полей: Страна производителя, Реквизиты ГТД, Серия. %s%s'
                 ,cr || f_docdescrs_get_description('FaceAccountsOperPlans', rRow.rn)
                 ,cr || f_docdescrs_get_description('FaceAccounts', rRow.prn));
    end if;
  
  end FCACOPEROUTPLANS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_RECALC
  /*
  План расхода. Пересчать исполнение
  */
  (
   nRN            in number
  ) 
  is
    rTmp          transinvcustspecs%rowtype;
  begin
    /* Получение данных по спецификациям РН потребителям */
    select nvl( sum( e.nquant_fact      ), 0 )                          as nQuant_fact
          ,nvl( sum( e.nSum_fact        ), 0 )                          as nSum_fact
          ,nvl( sum( e.nSumWithNDS_fact ), 0 )                          as nSumWithNDS_fact
          ,nvl( sum( e.nSumNDS_fact     ), 0 )                          as nSumNDS_fact
      into rTmp.quant
          ,rTmp.summ
          ,rTmp.summwithnds
          ,rTmp.summ_nds
      from fcacoperplans t
      left join ( select ticsc.graphpoint
                        ,ticsc.quant_fact * ( sot.gsmways_type * -2 + 1 ) as nQuant_Fact
                        ,usr_pkg_dictaxgr.dictaxis_calc_base( nflagsmart   => 1
                                                             ,ncompany     => tic.company
                                                             ,ntaxgr       => tics.taxgr
                                                             ,ninsumm      => ticsc.cost_fact * ticsc.quant_fact * ( sot.gsmways_type * -2 + 1 )
                                                             ,nparam       => 0 )  as nSum_fact
                        ,usr_pkg_dictaxgr.dictaxis_calc_base( nflagsmart   => 1
                                                             ,ncompany     => tic.company
                                                             ,ntaxgr       => tics.taxgr
                                                             ,ninsumm      => ticsc.cost_fact * ticsc.quant_fact * ( sot.gsmways_type * -2 + 1 )
                                                             ,nparam       => 2 )  as nSumWithNDS_fact
                        ,usr_pkg_dictaxgr.dictaxis_calc_base( nflagsmart   => 1
                                                             ,ncompany     => tic.company
                                                             ,ntaxgr       => tics.taxgr
                                                             ,ninsumm      => ticsc.cost_fact * ticsc.quant_fact * ( sot.gsmways_type * -2 + 1 )
                                                             ,nparam       => 8 )   as nSumNDS_fact
                    from trinvcustclc       ticsc 
                    join transinvcustspecs  tics  on tics.rn     = ticsc.prn
                    join transinvcust       tic   on tic.rn      = tics.prn
                                                 and tic.status  = 1
                    join azsgsmwaystypes    sot   on sot.rn      = tic.stoper ) e on e.graphpoint = t.graphpoint
         where t.rn = nRN
    group by t.rn, t.quant, t.summ, t.summwithnds, t.summ_nds;

    /* Исправление исполнения */
    fcacoperplans_update_exec(nrn              => nRN
                             ,nquant_fact      => rTmp.quant
                             ,nsum_fact        => rTmp.summ
                             ,nsumwithnds_fact => rTmp.summwithnds
                             ,nsumnds_fact     => rTmp.summ_nds);
  
  end FCACOPEROUTPLANS_RECALC;
  /*#########################################################################################################*/

  procedure FCACOPEROUTPLANS_SPLIT
  /*
  План расхода. Отделить от текущей записи с заданным количеством
  */
  (
   nRN                in number
  ,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
  ,dBEGIN_DATE        in date
  ,dEND_DATE          in date
  ) 
  is
    rV_Row            v_fcacoperplans%rowtype;
    rV_RowNew         v_fcacoperplans%rowtype;
    nQuant            pkg_std.tnumber := 0; 
    nQuantOld         pkg_std.tnumber := 0; 
    rDicNomns         dicnomns%rowtype;
    rDicMUnts         dicmunts%rowtype;
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Считывание */
    select * into rV_Row from v_fcacoperplans where nrn = fcacoperoutplans_split.nrn;

    /* Считывание номенклатуры и единицы измерения */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rV_Row.nnomen );
    rDicMUnts := udo_pkg_get.row_dicmunts( nrn => rDicNomns.umeas_main );

    /* Новая запись */
    rV_RowNew := rV_Row;

    /* Проверки */
    if nvl(nQUANT_NEW, 0) = 0 then
      p_exception(0, 'Отделяемо количество <%s> не задано или равно нулю.%s%s'
                 ,nQUANT_NEW
                 ,cr||cr||f_docdescrs_get_description( 'FaceAccountsOperOutPlans', rV_Row.nrn )
                 ,cr||cr||f_docdescrs_get_description( 'FaceAccounts', rV_Row.nprn ) ); 
    elsif rV_Row.nquant < nQUANT_NEW then
      p_exception(0, 'Отделяемо количество <%s> больше исходного <%s>. %s%s'
                 ,nQUANT_NEW
                 ,rV_Row.nquant
                 ,cr||cr||f_docdescrs_get_description( 'FaceAccountsOperOutPlans', rV_Row.nrn )
                 ,cr||cr||f_docdescrs_get_description( 'FaceAccounts', rV_Row.nprn ) ); 
    end if;

    /* Заполнение полей */
    rV_RowNew.ngraphpoint := null;
    p_fcacoperplans_getnextnumb( ncompany    => rV_RowNew.ncompany
                                ,nprn        => rV_RowNew.nprn
                                ,ninexp_sign => rV_RowNew.ninexp_sign
                                ,snumb       => rV_RowNew.snumb );
    rV_RowNew.dbegin_date := dBEGIN_DATE;
    rV_RowNew.dend_date   := dEND_DATE;
   
    /* Количество до отделения */
    nQuant := rV_Row.nquant; 

    /* Количество после отделения в старой спецификации */
    nQuantOld := nQuant - nQUANT_NEW;

    /* Заполнение переменных для новой записи */
    rV_RowNew.nsumm        := rV_Row.nsumm        / nQuant * nQUANT_NEW;
    rV_RowNew.nsummwithnds := rV_Row.nsummwithnds / nQuant * nQUANT_NEW;
    rV_RowNew.nsumm_nds    := rV_Row.nsumm_nds    / nQuant * nQUANT_NEW;

    /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
    if rDicMUnts.meas_type = 1 then
      rV_RowNew.nquant := round( nQUANT_NEW );
    else
      rV_RowNew.nquant := nQUANT_NEW;
    end if;
    rV_RowNew.nactm_quant := rV_RowNew.nquant;

    /* Заполнение для текущей записи */
    rV_Row.nsumm        := rV_Row.nsumm        / nQuant * nQuantOld;
    rV_Row.nsummwithnds := rV_Row.nsummwithnds / nQuant * nQuantOld;
    rV_Row.nsumm_nds    := rV_Row.nsumm_nds    / nQuant * nQuantOld;

    /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
    if rDicMUnts.meas_type = 1 then
      rV_Row.nquant := round( nQuantOld );
    else
      rV_Row.nquant := nQuantOld;
    end if;
    rV_Row.nactm_quant := rV_Row.nquant;

    /* Исправление текущей записи */
    fcacoperplans_update( rv_row => rV_Row, nmode => 0 );

    /* Добавление новой записи */
    fcacoperplans_insert( rv_row => rV_RowNew, nrn => rV_RowNew.nrn, nmode => 0 );

    /* Копирование свойств */
    pkg_docs_props_vals.copy( sunitcode_from => 'FaceAccountsOperOutPlans'
                             ,ndocument_from => rV_Row.nrn
                             ,sunitcode_to   => 'FaceAccountsOperOutPlans'
                             ,ndocument_to   => rV_RowNew.nrn );

    /* Копирование калькуляций */
    p_fcacoperplansclc_duplicate( ndup_prn => rV_Row.nrn, nprn => rV_RowNew.nrn );

    /* Пересчёт исполнений  */
    /*fcacoperoutplans_recalc( nrn => rV_Row.nrn );
    fcacoperoutplans_recalc( nrn => rV_RowNew.nrn );*/

  end FCACOPEROUTPLANS_SPLIT;
  /*#########################################################################################################*/

  function FCACPAYPLANS_GET
  /*
    План платежей. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacpayplans%rowtype is
    rrow fcacpayplans%rowtype;
  begin
    begin
      select t.* into rrow from fcacpayplans t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nrn, sunit_table => 'FCACPAYPLANS');
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <' ||
                    nvl(to_char(nrn), 'Не задан') || '> ' || 'в разделе <' ||
                    f_unitlist_getname(get_unitlist_code_table(1, 'FCACPAYPLANS')) || '>.');
    end;
    return(rrow);
  end FCACPAYPLANS_GET;
  --#########################################################################################################

  procedure FCACPAYPLANS_AINSERT
  /*
    План платежей. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow fcacpayplans%rowtype;
    nfgp pkg_std.tnumber;
  begin
    -- Заголовок
    rrow := fcacpayplans_get(nrn);
  
    -- ИСПРАВЛЕНИЯ
  
    -- ПРОВЕРКИ
    -- Проверка базовая
    fcacpayplans_check_base(nrn, ncompany);
  
  end FCACPAYPLANS_AINSERT;
  --#########################################################################################################

  procedure FCACPAYPLANS_BUPDATE
  /*
    План платежей. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    --- Пересчет оплачено фактически и по плану
   usr_P_fcacpayplans_recalc(nrn);
    -- usr_pkg_pub_const.rfcacpayplans := fcacpayplans_get(NRN);
  end FCACPAYPLANS_BUPDATE;
  --#########################################################################################################

  procedure FCACPAYPLANS_AUPDATE
  /*
    План платежей. Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    -- rRow      fcacpayplans%rowtype;
  begin
    -- Заголовок
    -- rRow := fcacpayplans_get(NRN);
  
    -- ПРОВЕРКИ
    -- Базовая
    fcacpayplans_check_base(nrn, ncompany);
  
  end FCACPAYPLANS_AUPDATE;
  --#########################################################################################################

  procedure FCACPAYPLANS_BDELETE
  /*
    План платежей. Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow fcacpayplans%rowtype;
  begin
    null;
    -- Заголовок
    -- rRow := fcacpayplans_get(NRN);
  
    -- ИСПРАВЛЕНИЯ
  
  end FCACPAYPLANS_BDELETE;
  --#########################################################################################################

  procedure FCACPAYPLANS_CHECK_BASE
  /*
    Лицевые счета (графики платежей). Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow fcacpayplans%rowtype;
  begin
    /* Заголовок */
    rrow := fcacpayplans_get(nrn => nrn);
  
    /* ПРОВЕРКИ */
    /* Сумма платежа */
    if rrow.pay_sum = 0 then
      p_exception(0
                 ,'Не задана сумма платежа.%s'
                 ,cr || cr || f_docdescrs_get_description(sunitcode => 'FaceAccountsPayPlans'
                                                         ,ndocument => rrow.rn));
    end if;
  
    /* Контроль за соответствием Направления платежа и Статьи калькуляции статьи затрат Этапа договора
    для статей калькуляции "Доход" и "Расход"
    */
  
    for cur in (
                
                select case
                          when fop.typoper_direct = 0
                               and fop.factret_sign = 1 then
                           'Расход'
                          when fop.typoper_direct = 1
                               and fop.factret_sign = 1 then
                           'Доход'
                          when fop.typoper_direct = 0
                               and fop.factret_sign = 0 then
                           'Доход'
                          when fop.typoper_direct = 1
                               and fop.factret_sign = 0 then
                           'Расход'
                          when fc.inexp_sign = 0 then --- Финансовая операция не задана
                           'Доход'
                          else
                           'Расход'
                        
                        end grp ---Вид платежа Графика платежей договора
                       ,sc.code -- Статья калькуляции статьи затрат этапа (Доход / Расход)
                       ,fc.inexp_sign /* признак Приход(0) расход (1) */
                       ,fop.typoper_direct /* Направление средств операции  0 - приход, 1-расход */
                       ,case fop.factret_sign
                          when 0 then
                           'Прямая'
                          when 1 then
                           'Возврат'
                          else
                           'Списание долга'
                        end napr /* Признак возврата 0 - прямая (операция, факт), 1 - возврат, 2 - списание долга   */
                  from fcacpayplans fc
                  left join dictoper fop
                    on fop.rn = fc.finoper
                  join faceacc f
                    on f.rn = fc.prn
                  join stages st
                    on st.faceacc = f.rn
                  left join fpdartcl fpa
                    on fpa.rn = f.ieelement
                  left join diciearts sc
                    on sc.rn = fpa.iearticle
                
                 where fc.rn = nrn)
    loop
      if cur.grp != cur.code then
      
        p_exception(0
                   ,'Вид платежа, в графике платежей, задан как %s,с признаком %s, а в этапе договора, на закладке "Правила формирования" задана статья затрат с признаком %s. Должно совпадать!'
                   ,cur.grp
                   ,cur.napr
                   ,cur.code);
      end if;
    
    end loop;
  
  end FCACPAYPLANS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure FCACPAYPLANS_INSERT
  /*
  Лицевые счета (графики платежей). Добавление клиентское
  */
  (
   rV_ROW     in v_fcacpayplans%rowtype
  ,nRN        out number  /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ) 
  is
  begin
    p_fcacpayplans_insert( ncompany      => rV_ROW.NCOMPANY
                          ,nprn          => rV_ROW.NPRN
                          ,snumb         => rV_ROW.SNUMB
                          ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                          ,dbegin_date   => rV_ROW.DBEGIN_DATE
                          ,dend_date     => rV_ROW.DEND_DATE
                          ,ninexp_sign   => rV_ROW.NINEXP_SIGN
                          ,nfact_sign    => rV_ROW.NFACT_SIGN
                          ,spay_type     => rV_ROW.SPAY_TYPE
                          ,npercent      => rV_ROW.NPERCENT
                          ,npay_sum      => rV_ROW.NPAY_SUM
                          ,ngr_calc_sign => rV_ROW.NGR_CALC_SIGN
                          ,sfinoper      => rV_ROW.SFINOPER
                          ,nrn           => nRN );
  end FCACPAYPLANS_INSERT;
  /*#########################################################################################################*/

  procedure FCACPAYPLANS_UPDATE
  /*
  Лицевые счета (графики платежей). Добавление клиентское
  */
  (
   rV_ROW     in v_fcacpayplans%rowtype
  ,nMODE      in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    aRN_Unit_List   usr_pkg_pub_const.trn_unit_list;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_fcacpayplans_update( ncompany      => rV_ROW.NCOMPANY
                            ,nrn           => rV_ROW.NRN
                            ,snumb         => rV_ROW.SNUMB
                            ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                            ,dbegin_date   => rV_ROW.DBEGIN_DATE
                            ,dend_date     => rV_ROW.DEND_DATE
                            ,ninexp_sign   => rV_ROW.NINEXP_SIGN
                            ,nfact_sign    => rV_ROW.NFACT_SIGN
                            ,spay_type     => rV_ROW.SPAY_TYPE
                            ,npercent      => rV_ROW.NPERCENT
                            ,npay_sum      => rV_ROW.NPAY_SUM
                            ,ngr_calc_sign => rV_ROW.NGR_CALC_SIGN
                            ,sfinoper      => rV_ROW.SFINOPER );
      /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then
      \* Исправление *\
      fcacpayplans_update( rv_row => rV_ROW, nmode => 0 );*/
    else
      p_exception( 0, 'Неизвестный режим выполнения <%s>', nmode );
    end if;

  end FCACPAYPLANS_UPDATE;
  /*#########################################################################################################*/

  procedure FCACPAYPLANS_BASE_INSERT
  /*
  Лицевые счета (графики платежей). Добавление базовое
  */
  (
   rROW       in fcacpayplans%rowtype
  ,nSIGN_DIR  in number 
  ,nRN        out number  /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ) 
  is
  begin
    p_fcacpayplans_base_insert( ncompany      => rROW.COMPANY
                               ,nprn          => rROW.PRN
                               ,snumb         => rROW.NUMB
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,dbegin_date   => rROW.BEGIN_DATE
                               ,dend_date     => rROW.END_DATE
                               ,ninexp_sign   => rROW.INEXP_SIGN
                               ,nfact_sign    => rROW.FACT_SIGN
                               ,npay_type     => rROW.PAY_TYPE
                               ,npercent      => rROW.PERCENT
                               ,npay_sum      => rROW.PAY_SUM
                               ,ngr_calc_sign => rROW.GR_CALC_SIGN
                               ,nfinoper      => rROW.FINOPER
                               ,nrn           => nRN
                               ,nsign_dir     => nSIGN_DIR );
  end FCACPAYPLANS_BASE_INSERT;
  --#########################################################################################################

  procedure FCACPAYPLANS_BASE_UPDATE
  /*
    Лицевые счета (графики платежей). Исправление базовое
    */
  (rfcacpayplans in fcacpayplans%rowtype) is
  begin
    p_fcacpayplans_base_update(ncompany      => rfcacpayplans.company
                              ,nrn           => rfcacpayplans.rn
                              ,nprn          => rfcacpayplans.prn
                              ,snumb         => rfcacpayplans.numb
                              ,ngraphpoint   => rfcacpayplans.graphpoint
                              ,dbegin_date   => rfcacpayplans.begin_date
                              ,dend_date     => rfcacpayplans.end_date
                              ,ninexp_sign   => rfcacpayplans.inexp_sign
                              ,nfact_sign    => rfcacpayplans.fact_sign
                              ,npay_type     => rfcacpayplans.pay_type
                              ,npercent      => rfcacpayplans.percent
                              ,npay_sum      => rfcacpayplans.pay_sum
                              ,ngr_calc_sign => rfcacpayplans.gr_calc_sign
                              ,nfinoper      => rfcacpayplans.finoper
                              ,nsign_dir     => rfcacpayplans.sign_hist);
  end FCACPAYPLANS_BASE_UPDATE;
  --#########################################################################################################

  function FCACGRAPHPOINTS_GET
  /*
    Точки графиков. Считывание
    */
  (nrn in number -- RN записи
   ) return fcacgraphpoints%rowtype is
    rrow fcacgraphpoints%rowtype;
  begin
    begin
      select t.* into rrow from fcacgraphpoints t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0
                                ,ndocument   => nrn
                                ,sunit_table => 'FCACGRAPHPOINTS');
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <' ||
                    nvl(to_char(nrn), 'Не задан') || '> ' || 'в разделе <' ||
                    f_unitlist_getname(get_unitlist_code_table(1, 'FCACGRAPHPOINTS')) || '>.');
    end;
    return(rrow);
  end FCACGRAPHPOINTS_GET;
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_AINSERT
  /*
    Точки графиков. Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow fcacgraphpoints%rowtype;
  begin
    -- rRow := fcacgraphpoints_get(NRN);
  
    -- ПРОВЕРКИ
    -- Базовая
    fcacgraphpoints_check_base(nrn, ncompany);
  
  end FCACGRAPHPOINTS_AINSERT;
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_BUPDATE
  /*
  Точки графиков. Проверка перед исправлением
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    usr_pkg_pub_const.rfcacgraphpoints := fcacgraphpoints_get( nrn => nrn );
  end FCACGRAPHPOINTS_BUPDATE;
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_AUPDATE
  /*
  Точки графиков. Проверка после исправления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
    rRow  fcacgraphpoints%rowtype;
  begin
    /* Считывание */
    rRow := fcacgraphpoints_get( nrn => nrn );

    /* ПРОВЕРКИ */
    /* Базовая */
    fcacgraphpoints_check_base( nrn => nrn, ncompany => ncompany );
    /* Исправление Мнемокода */
    if cmp_vc2( rRow.code, usr_pkg_pub_const.rfcacgraphpoints.code ) != 1 then
      p_exception(0, 'Запрещено исправлять поле "Мнемокод". %s'
                 ,cr || f_docdescrs_get_description(sunitcode => 'FaceAccountsGraphPoints', ndocument => rRow.prn ) );
    end if;

  end FCACGRAPHPOINTS_AUPDATE;
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_BDELETE
  /*
    Точки графиков. Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
    --USR_PKG_PUB_CONST.RFCACGRAPHPOINTS := FCACGRAPHPOINTS_GET(NRN);
  end FCACGRAPHPOINTS_BDELETE;
  --#########################################################################################################

  procedure FCACGRAPHPOINTS_CHECK_BASE
  /*
    Точки графиков. Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
    rrow fcacgraphpoints%rowtype;
    -- aProps    USR_PKG_PUB_CONST.TDOCS_PROPS_VALS;
    nfaoop_count pkg_std.tnumber;
    nfapp_count  pkg_std.tnumber;
  begin
    null;
    -- Заголовок
    -- rRow := FCACGRAPHPOINTS_GET(NRN);
    -- USR_PKG_DOCS_PROPS_VALS.GET_VALS_DOCUMENT_TYPE(RROW.RN, aProps);
  
  end FCACGRAPHPOINTS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure FCACGRAPHPOINTS_BASE_INSERT
  /*
  Лицевые счета (точки графиков). Добавление базовое
  */
  (
   rROW       in fcacgraphpoints%rowtype
  ,nRN        out number 
  ,nMODE      in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rRow2     fcacgraphpoints%rowtype := rRow;
    rFaceAcc  faceacc%rowtype; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nmode = 0 then
      p_fcacgraphpoints_base_insert( ncompany       => rROW.COMPANY
                                    ,nprn           => rROW.PRN
                                    ,scode          => rROW.CODE
                                    ,snote          => rROW.NOTE
                                    ,nins_dep       => rROW.INS_DEP
                                    ,dbdate         => rROW.BDATE
                                    ,dedate         => rROW.EDATE
                                    ,nbudgexpend_sp => rROW.BUDGEXPEND_SP
                                    ,nagnacc        => rROW.AGNACC
                                    ,nagnfi         => rROW.AGNFI
                                    ,nagnfo         => rROW.AGNFO
                                    ,nrespagent     => rROW.RESPAGENT
                                    ,npaytype       => rROW.PAYTYPE
                                    ,nsheeptype     => rROW.SHEEPTYPE
                                    ,dpricedate     => rROW.PRICEDATE
                                    ,ntarif         => rROW.TARIF
                                    ,nrn            => nRN );
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nmode = 1 then
      \* Добавление штатное *\
      fcacgraphpoints_base_insert( rrow => rRow2, nrn => nRN, nmode => 0 );*/
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE );
    end if;

  end FCACGRAPHPOINTS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure FCACGRAPHPOINTS_BASE_UPDATE
  /*
  Лицевые счета (точки графиков). Исправление базовое
  */
  (
   rROW       in fcacgraphpoints%rowtype
  ) 
  is
  begin
    p_fcacgraphpoints_base_update( nrn            => rROW.RN
                                  ,ncompany       => rROW.COMPANY
                                  ,scode          => rROW.CODE
                                  ,snote          => rROW.NOTE
                                  ,nins_dep       => rROW.INS_DEP
                                  ,dbdate         => rROW.BDATE
                                  ,dedate         => rROW.EDATE
                                  ,nbudgexpend_sp => rROW.BUDGEXPEND_SP
                                  ,nagnacc        => rROW.AGNACC
                                  ,nagnfi         => rROW.AGNFI
                                  ,nagnfo         => rROW.AGNFO
                                  ,nrespagent     => rROW.RESPAGENT
                                  ,npaytype       => rROW.PAYTYPE
                                  ,nsheeptype     => rROW.SHEEPTYPE
                                  ,dpricedate     => rROW.PRICEDATE
                                  ,ntarif         => rROW.TARIF );
  end FCACGRAPHPOINTS_BASE_UPDATE;
  --#########################################################################################################
  function FCACOPEROUTPLANSCLC_GET
  /*
    Лицевые счета (план расхода, строки калькуляции). Считывание
    */
  (nrn in number -- RN записи
   ) return fcacoperplansclc%rowtype is
    rrow fcacoperplansclc%rowtype;
  begin
    begin
      select t.* into rrow from fcacoperplansclc t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0
                                ,ndocument   => nrn
                                ,sunit_table => 'FCACOPEROUTPLANSCLC');
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <' ||
                    nvl(to_char(nrn), 'Не задан') || '> ' || 'в разделе <' ||
                    f_unitlist_getname(get_unitlist_code_table(1, 'FCACOPERPLANSCLC')) || '>.');
    end;
    return(rrow);
  end;
  --#########################################################################################################
  procedure FCACOPEROUTPLANSCLC_CNT_INDIR
  /*
    Лицевые счета (план расхода, строки калькуляции). Контроль
    
    Если строка калькуляции создана в рамках договора, то контрлируется наличие строки структуры цен со
     способом отнесения косвенных расходов "По калькуляции"
    */
  (nrn in fcacoperplansclc.rn%type -- RN записи
   ) is
    ifl  integer;
    sres varchar2(2000);
  begin
    begin
      select case
               when st.rn is null /*Калькуляции вне этапа договора*/
                    or sp.rn is not null then /*Нужная структура цены существует*/
                1
               else
                0
             end
        into ifl
        from fcacoperplansclc fc
        join fcacoperplans fop
          on fop.rn = fc.prn
        left join faceacc f
          on f.rn = fop.prn
        left join stages st
          on st.faceacc = f.rn
        left join contrprstruct sp
          on sp.prn = st.rn
         and sp.calc_indir = 1 /*Структура цены по калькуляции*/
       where fc.rn = nrn
         and rownum = 1; /*Достаточно одной структуры*/
    
    exception
      when no_data_found then
        ifl := 0;
    end;
  
    begin
      /* Выведем для справки реквизиты договора и номер этапа */
      select 'Этап: ' || trim(st.numb) || ' Договор: ' || trim(dog.doc_pref) || '-' ||
             trim(dog.doc_numb) || ' от ' || to_char(dog.doc_date, 'DD.MM.YYYY')
        into sres
        from fcacoperplansclc fpc
        join fcacoperplans fp
          on fp.rn = fpc.prn
        join faceacc f
          on f.rn = fp.prn
        join stages st
          on st.faceacc = f.rn
        join contracts dog
          on dog.rn = st.prn
       where fpc.rn = nrn;
    exception
      when no_data_found then
        sres := '.';
      
    end;
  
    p_exception(ifl
               ,'Перед заведением/исправлением строк калькуляции требуется создать хотя бы одну запись структуры цены, ' ||
                'для данного этапа, c типом распределения косвенных затрат "По калькуляции". ' ||
                'Калькуляцию структуры цены задавать не нужно, она будет рассчитана автоматически! ' || cr || sres);
  end;

  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_AINSERT
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    p_exception(0
               ,'Нельзя добавлять строки калькуляции вручную. Для обновления сумм и структуры калькуляции воспользуйтесь ' ||
                'действием "Переформирование строк калькуляции по учетным ценам" на графике отпуска товаров и услуг.');
  end;
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_BUPDATE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end;
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_AUPDATE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка после исправления
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    p_exception(0
               ,'Нельзя править строки калькуляции вручную. Для обновления сумм воспользуйтесь действием ' ||
                '"Переформирование строк калькуляции по учетным ценам" на графике отпуска товаров и услуг.');
  end;
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_BDELETE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка перед удалением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
  
    p_exception(0
               ,'Нельзя удалять строки калькуляции вручную. Для обновления сумм и структуры калькуляции воспользуйтесь действием ' ||
                '"Переформирование строк калькуляции по учетным ценам" на графике отпуска товаров и услуг.');
  
  end;
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_CHECK_BASE
  /*
    Лицевые счета (план расхода, строки калькуляции). Проверка общая
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    null;
  end;
  --#########################################################################################################

  procedure FCACOPEROUTPLANSCLC_AMAKE_CLC
  /*
    Лицевые счета (план расхода, строки калькуляции). Переформирование строк калькуляции по учётным ценам. После
    */
  (
    nrn      in fcacoperplans.rn%type
   ,ncompany in number
  ) is
    nfl integer := 0;
  begin
    /* Пересчет калькуляции структуры цены при загрузке калькуляции графика отпуска товаров и услуг */
    for cur in (select str.rn
                      ,str.company
                      ,coalesce(str.date_to, str.date_from, sysdate) date_sign
                  from fcacoperplans t
                  join stages st
                    on st.faceacc = t.prn
                  join contrprstruct str
                    on str.prn = st.rn
                   and str.calc_indir = 1 /*по калькуляции*/
                   and str.sign_act = 1 /* действующая */
                 where t.rn = nrn)
    loop
      nfl := 1; /*Нашли что пересчитывать*/
      /*снять признак "Действующая"*/
      p_contrprstruct_set_act(ncompany  => cur.company
                             ,nrn       => cur.rn
                             ,nsign_act => 0
                             ,ddate     => cur.date_sign);
      /* пересчитать */
      p_contrprstruct_make(ncompany => cur.company, nrn => cur.rn);
    
      /*установить признак "Действующая"*/
      p_contrprstruct_set_act(ncompany  => cur.company
                             ,nrn       => cur.rn
                             ,nsign_act => 1
                             ,ddate     => cur.date_sign);
    end loop;
  /*  \* Если пеерсчитывать нечего было, выдадим ошибку *\
    p_exception(0
               ,'В структуре цены данного этапа не найдено строки в статусе "Действующая" и признаком расчета косвенных затрат "По калькуляции".' || cr ||
                'Требуется завести такую структуру цены перед загрузкой калькуляции графика отпуска товаров и услуг.');*/
  end;
  --#########################################################################################################

end USR_PKG_FACEACC;
/
