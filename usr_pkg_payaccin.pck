create or replace package USR_PKG_PAYACCIN is
  /*
  Package предназначен для работы с разделом "Входящие счета на оплату". Степанов М. 01/12/2020
  PaymentAccountsIn             PAYACCIN          PAI
  PaymentAccountsInSpecs        PAYACCINSPEC      PAIS
  PaymentAccountsInSpecsCalcs   PAYACCINSPCLC     PAISC
  PaymentAccountsInSpecsCalcsEX PAYACCINSPCLC_EX  PAISCE   
  */
  /*#########################################################################################################*/

  function PAYACCIN_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return PAYACCIN%ROWTYPE;
  /*#########################################################################################################*/

  FUNCTION PAYACCIN_GET_STATE_NAME
  /*
  Наименование статусов
  */
  (
   NDOC_STATE      IN NUMBER
  ) 
  RETURN VARCHAR2;
  /*#########################################################################################################*/

  function PAYACCIN_GET_NOMEN_TYPE
  /*
  Заголовок. Получение типа номенклатур (1 - товар, 2 - услуга, 3 - тара, 9 - смешанный, 0 - нет спецификаций)
  */
  (
   nRN        in number -- RN записи
  ,nCOMPANY   in number
  ) 
  return number;  
   /*#########################################################################################################*/

  procedure PAYACCIN_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BNOTCONFIRM
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Не увержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_ANOTCONFIRM
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Не увержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BCONFIRM
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Утвержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_ACONFIRM
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Утвержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BCLOSED
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_ACLOSED
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BDECLINE
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_ADECLINE
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEININVOICE
  /*
  Заголовок. Проверка перед Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEININVOICE
  /*
  Заголовок. Проверка после Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEINORDERS
  /*
  Заголовок. Проверка перед Формирование приходных ордеров
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEINORDERS
  /*
  Заголовок. Проверка после Формирование приходных ордеров
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка перед Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка после Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка перед Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка после Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW       in v_payaccin%rowtype
  ,nDUP_RN      in number
  ,nRN          out number
  );
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   RV_ROW       in v_payaccin%rowtype  -- RN сформированного документа
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in payaccin%rowtype  -- RN сформированного документа
  ,nSTATUS_IGNORE   in number default 0  -- Исправлять в утверждёный документ 0-нет, 1-да
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_MAKE_BY_MODEL
  /*
  Добавить по образцу товарного документа
  */
  (
   nMODEL           in number
  ,dDATE            in date default null
  ,nRN              out number
  );
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_MAKE_INORDERS
  /*
  Формирование приходных ордеров
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2 default null
  ,sDOCTYPE         in varchar2 default null
  ,dDATE            in date
  ,sSTORE           in varchar2 
  ,sSTOREOPER       in varchar2 default null
  ,aRNLIST          out udo_tp_numtable
  );
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_MAKE_ININVOICES
  /*
  Формирование приходных накладных
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2 default null
  ,sDOCTYPE         in varchar2 default null
  ,sDOCPREF         in varchar2 default null
  ,dDATE            in date     default null
  ,sEXT_NUMB        in varchar2 default null
  ,dEXT_DATE        in date     default null
  ,sCURRENCY        in varchar2 default null  
  ,sSTOREOPER       in varchar2 default null
  ,aRNLIST          out udo_tp_numtable
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_UPDATE_PRICEWITHTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART     in number default 0
  ,nRN            in number
  ,nPRICEWITHTAX  in number /* 0 - не включают, 1 - включают */
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_RECREATE_PAISC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_RECALC_PERFORMANCE
  /*
  Заголовок. Пересчитать исполнение
  */
  (
   nRN      in number
  );
  /*#########################################################################################################*/

  procedure PAYACCIN_CLEAR_FOR_UPDATE
  /*
  Заголовок. Очистка перед исправлением и восстановление после очистки
  При очистке удаляются связи, снимается отработка. При восстановлении отрабатывается, восстанавливаются связи 
  Обязательно выполнять в обоих режимах, иначе документ останется неотработанным и без связей
  */
  (
   nRN          in number       
  ,nMODE        in number       /* Режим выполнения: 0 - освободить, 1 - восстановить */
  );
  /*#########################################################################################################*/

  PROCEDURE PAYACCINBUFF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW       in payaccinbuff%rowtype  -- RN сформированного документа
  );
  /*#########################################################################################################*/

  function PAYACCINSPEC_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN       in number
  ) 
  return PAYACCINSPEC%ROWTYPE;
  /*#########################################################################################################*/
  
  PROCEDURE PAYACCINSPEC_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMEN             IN NUMBER DEFAULT NULL
  ,NNOMPACK           IN NUMBER DEFAULT NULL
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,SSERNUMB           IN VARCHAR2 DEFAULT NULL
  ,NCOUNTRY           IN NUMBER   DEFAULT NULL
  ,SGTD               IN VARCHAR2 DEFAULT NULL
  ,NSTORE             IN NUMBER   DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT PAYACCINSPEC%ROWTYPE 
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_PAISC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in payaccinspec%rowtype
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации заказа поставщикам
  */
  (
   rROW   in payaccinspec%rowtype
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_OUT_DOCS
  /*
  Спецификация. Проверка выходных документов
  */
  (
   rROW             payaccinspec%rowtype
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_INSERT
  /*
  Спецификация. Добавление
  */
  (
   rV_ROW       in v_payaccinspec%rowtype  -- RN сформированного документа
  ,nRN          out number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_UPDATE
  /*
  Спецификация. Исправление
  */
  (
   rV_ROW           in v_payaccinspec%rowtype
  ,nFLAG_DEL_CALC   in number default 0     /* Не удалять калькуляцию: 0 - нет, 1 - да */
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW             in payaccinspec%rowtype
  ,nRN              out number
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nDUP_RN          in number default null  /* Для Режима 1. Размножаемая запись */
  ,nFLAG_DEL_CALC   in number default 0     /* Для Режима 1. Удалять калькуляцию: 0 - нет, 1 - да */
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in payaccinspec%rowtype
  ,nFLAG_DEL_CALC   in number default 0     /* Удалять калькуляцию: 0 - нет, 1 - да */
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_GET_INDOC_QUANT
  /*
  Спецификация. Получить количество по приходным документам
  */
  (
   nRN          in number
  ,nQUANT       out number
  ,nQUANTALT    out number
  );
  /*#########################################################################################################*/
  
  procedure PAYACCINSPEC_GET_INDOC_REMAIN
  /*
  Спецификация. Получить остаток исполнения по приходным ордерам
  */
  (
   RROW         in payaccinspec%rowtype
  ,NCALC_WAY    in number -- возвращать оставшееся: 0 - количество, 1 - сумму
  ,NMOD_SIGN    out number -- спецификация включена во входящие счёта: 0 - нет, 1 - да
  ,NRESULT      out number -- результат: количество или сумма по которым не сформированы входящие счета на оплату
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_SPLIT
  /*
  Спецификация. Отделить от текущей записи с заданным количеством
  */
  (
   nRN                in number
  ,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
  ,nUSE_REST_QUANT    in number  /* Использовать недопоставленный остаток в качестве отделямого */
  );
  /*#########################################################################################################*/  

  function PAYACCINSPCLC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return payaccinspclc%rowtype;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_AINSERT
  /*
  Спецификация (калькуляция). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BUPDATE
  /*
  Спецификация (калькуляция). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BDELETE
  /*
  Спецификация (калькуляция). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  );
 /*#########################################################################################################*/

  procedure PAYACCINSPCLC_CHECK_PAISCE
  /*
  Калькуляция. Проверка привязки заказов подразделений
  */
  (
   rROW       in payaccinspclc%rowtype
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_INSERT
  /*
  Спецификация (калькуляция). Добавление
  */
  (
   rV_ROW   in v_payaccinspclc%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_UPDATE
  /*
  Спецификация (калькуляция). Исправление
  */
  (
   rV_ROW   in v_payaccinspclc%rowtype
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое
  */
  (
   rROW   in payaccinspclc%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое
  */
  (
   rROW   in payaccinspclc%rowtype
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_GET_IIVSC_QUANT
  /*
  Спецификация (калькуляция). Получить количество по калькуляциям приходных накладных
  */
  (
   nRN          in number
  ,nQUANT_PLAN  out number
  ,nQUANT_FACT  out number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_EX_AINSERT
  /*
  Спецификация (спецификация, калькуляция, заказ подразделений). Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_EX_CHECK_BASE
  /*
  Спецификация (спецификация, калькуляция, заказ подразделений). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

end USR_PKG_PAYACCIN;
/
create or replace package body USR_PKG_PAYACCIN is

  /*#########################################################################################################*/

  function PAYACCIN_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number -- RN записи
  ) 
  return payaccin%rowtype
  is
    rRow payaccin%rowtype;
  begin
    begin
      select * into rRow from payaccin where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PAYACCIN');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCIN'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end PAYACCIN_GET;
  /*#########################################################################################################*/

  function PAYACCIN_GET_STATE_NAME
  /*
  Наименование статусов
  */
  (
   nDOC_STATE      in number
  ) 
  return varchar2
  is
    sResult pkg_std.tstring; 
  begin
    sResult := case nDOC_STATE
                 when 0 then 'Не утвержден'
                 when 1 then 'Утвержден'
                 when 2 then 'Анулирован'
                 when 3 then 'Закрыт'
               else 'Не определён'
               end;

    return(sResult);

  end PAYACCIN_GET_STATE_NAME;
  /*#########################################################################################################*/

  function PAYACCIN_GET_NOMEN_TYPE
  /*
  Заголовок. Получение типа номенклатур (1 - товар, 2 - услуга, 3 - тара, 9 - смешанный, 0 - нет спецификаций)
  */
  (
   nRN        in number -- RN записи
  ,nCOMPANY   in number
  ) 
  return number
  is
    nResult   pkg_std.tnumber;   
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Проверка наличия документа */
    p_payaccin_exists(ncompany => nCOMPANY, nrn => nrn, ncrn => nNumber);
    
    /* Определение типа */
    begin
      select decode(listagg(nomen_type) within group (order by nomen_type) 
                   ,1 ,1
                   ,2 ,2
                   ,3 ,3
                   ,null, 0 /* нет спецификаций */
                   ,9)
       into nResult
       from (select distinct dnm.nomen_type
               from payaccinspec t, dicnomns dnm
              where t.prn   = nRN
                and t.nomen = dnm.rn);
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'PAYACCIN')), sqlerrm);
    end;

    return(nResult);

  end PAYACCIN_GET_NOMEN_TYPE;
  /*#########################################################################################################*/
  
  procedure PAYACCIN_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payaccin%rowtype;
    sNumbMax        pkg_std.tstring; 
  begin
    -- Заголовок  
    rRow := payaccin_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКА */
    /* Базовая */
    payaccin_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Префикс-номер */
    /* считывание максимального номера */
    begin
      select trim(max(t.doc_numb))
        into sNumbMax
        from payaccin t
       where t.doc_type = rRow.doc_type
         and trim( t.doc_pref ) = trim( rRow.doc_pref )
         and t.rn              != rRow.rn;
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при определении максимального номера входящего счёта. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end;
    /* прибавляем единицу к максимальному номеру */
    sNumbMax := nvl(s2n(sNumbMax), 0) + 1;
    /* проверка реквизитов */
    usr_pkg_document.check_pref_numb(spref    => rRow.doc_pref
                                    ,snumb    => rRow.doc_numb
                                    ,ddate    => rRow.doc_date
                                    ,snumbmax => sNumbMax);
    
    /* Параметр "Цены включают налоги" */  
    if rRow.pricewithtax = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" должен быть заполнен. Для исправления выполните процедуру <Исправить признак "Цены включают налоги">. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;

    /* По спецификациям */
    for c in (select * from payaccinspec where prn = rRow.rn) 
    loop
      /* проверка спецификации */
      payaccinspec_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;
    
  end PAYACCIN_AINSERT;
  /*#########################################################################################################*/

  procedure PAYACCIN_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    -- Считывание
    usr_pkg_pub_const.rpayaccin := payaccin_get(nrn => nRN); 

  end PAYACCIN_BUPDATE;
  /*#########################################################################################################*/

  procedure PAYACCIN_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow            payaccin%rowtype;*/
  begin
    /* Заголовок */
    /*rRow := Payaccin_get(nrn => nRN);*/
  
    /* ИСПРАВЛЕНИЯ */


    /* ПРОВЕРКИ */
    /* Базовая */
    payaccin_check_base(nRN => nRN, ncompany => nCOMPANY);

  end PAYACCIN_AUPDATE;
  /*#########################################################################################################*/

  procedure PAYACCIN_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      payaccin%rowtype;
  begin
    /* Заголовок */
    rRow := payaccin_get(nrn => nRN);
    
    /* Снятие утверждения */
    if rRow.doc_state != 0 then
      p_payaccin_bset_status(ncompany   => rRow.company
                            ,nrn        => rRow.rn
                            ,nstatus    => 0
                            ,dwork_date => rRow.state_date);
    end if;

  end PAYACCIN_BDELETE;
  /*#########################################################################################################*/

  procedure PAYACCIN_BNOTCONFIRM
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Не увержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
  /*Привяжем калькуляцию к бюджету, в том числе по всем счетам, где ранее не привязано  */
   null;
   --usr_p_payaccinspclc_AUTO;
  end PAYACCIN_BNOTCONFIRM;
  /*#########################################################################################################*/

  procedure PAYACCIN_ANOTCONFIRM
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Не увержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end PAYACCIN_ANOTCONFIRM;
  /*#########################################################################################################*/

  procedure PAYACCIN_BCONFIRM
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Утвержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in NUMBER
  )
  is
    rRow        payaccin%rowtype;
    rFaceAcc    faceacc%rowtype;
    nStageSum   pkg_std.tnumber;
    nSumPayed   pkg_std.tnumber;

    sVarchar    pkg_std.tstring; 
  begin
    /* Заголовок */
    rRow := payaccin_get(nrn => nRN);
    usr_pkg_pub_const.rpayaccin := rRow;
    
    /* Лицевой счёт */
    rFaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rRow.faceacc);

    /* ПРОВЕРКИ */
    /* Внешний номер не заполнен */
    if rRow.ext_numb is null then
      p_exception(0, 'Не заполнен внешний номер. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;
    /* Дата регистрации */
    if rRow.reg_date is null then
      p_exception(0, 'Не заполнено поле "Дата регистрации". %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;
    /* Сумма равна нулю */
    if rRow.summwithnds = 0 then
      p_exception(0, 'Сумма счёта с НДС равна нулю. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;
    /* Примечание меньше 10 символов */
    if nvl(length(trim(rRow.comments)), 0) < 10 then
      p_exception(0, 'Не заполнено примечание или его длинна меньше 10 символов. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;
    /* Контрагент не равен контрагенту ЛС */
    if cmp_num(rRow.supplier, rFaceAcc.agent) != 1 then
      p_exception(0, 'Контрагент документа <%s> не равен контрагенту лицевого счёта <%s>.%s'
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.supplier)
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rFaceAcc.agent)
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;

    /* Перенесено из P_PAYACCIN_BSET_STATUS */
    /* Проверка типа лицевого счета */
    if cmp_num( rFaceAcc.acc_kind, 1 ) = 1 then
      p_exception(0, 'Лицевой счёт <%s> имеет тип "Продажа". Покупка по нему запрещена.%s'
                 ,rFaceAcc.numb
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn ) ); 
    end if;
   
  end PAYACCIN_BCONFIRM;
  /*#########################################################################################################*/

  procedure PAYACCIN_ACONFIRM
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Утвержден"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
    rRow            payaccin%rowtype;
    rFaceAcc        faceacc%rowtype;
    nQuant_plan     pkg_std.tquant; 
    nQuant_fact     pkg_std.tquant; 
    sz              fpdartcl.code%type;
    v_fl1           integer;
    bCalcExists     boolean := false;
    
   /*Переменные для дубля*/
    nDuplicateCount number := 0;
    rDup            payaccin%rowtype;
    l_to_list       varchar2(4000);
    l_rn            number;

    sVarchar        pkg_std.tstring;     
    
  begin
    /* Заголовок */
    rRow := payaccin_get(nrn => nRN);
    rFaceAcc := usr_pkg_faceacc.faceacc_get( nrn => rRow.faceacc );

    /* Пересчитаем калькуляцию */
    usr_p_payaccinspclc_cre(nrn => nrn);
    
    /* Пересчитаем Бюджетирование по счету */
   usr_p_payaccin_cl_val_clc(nrn => nrn);
  
    /* ПРОВЕРКИ */
    
    /*    
   Городецкий О.И. 16-01-2026 Заявка 150126/22868 от 15-01-2026
    */
    
    usr_P_PAYACCINSPCLC_chk1(nrn);
    
 

    /* Базовая*/
    payaccin_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* По спецификациям */
    for c in (select * from payaccinspec where prn = rRow.rn) 
    loop
      /* проверка базовая спецификации */
      payaccinspec_check_base(nrn => c.rn, ncompany => c.company);
      /* проверка калькуляций спецификации */
      payaccinspec_check_paisc(rrow => c);
      /* проверка превышения исполнения родительской спецификации заказа поставщикам */
      payaccinspec_check_indoc(rrow => c);
      
      /* По калькуляциям спецификации */
      for c1 in (select * from payaccinspclc where prn = c.rn) 
      loop
        /* проверка калькуляции базовая */
        payaccinspclc_check_base(nrn => c1.rn, ncompany => c1.company);
        /* проверка связей с заказами подразделений калькуляции */
        payaccinspclc_check_paisce(rrow => c1);

        /* По ссылкам на заказы подразделений калькуляции (возможно потом убрать, когда какое-то время поработает проверка payaccinspclc_ex_check_base ) */
        for c2 in (select * from payaccinspclc_ex where prn = c1.rn)
        loop
          /* проверка базовая ссылки на заказы подразделений */
          payaccinspclc_ex_check_base(nrn => c2.rn, ncompany => rRow.company);
        end loop;

        /* Признак существования калькуляции для спецификации */
        bCalcExists := true;

      end loop;

      /* Если калькуляции для спецификации отсутствует, и в лицевом счёте поставщика указана одна из статей: 
        - Расходы на ПКИ_Б, 
        - Расходы на КА_Б, 
        - Прочие тем.расходы_Б, 
        - Расходы на иниц._Б */
      if not bCalcExists and nvl( rFaceAcc.ieelement, -9 ) in ( 6172151, 6172154, 6172204, 6172301 ) then
        p_exception(0, 'В спецификации отсуствуют калькуляции. При этом в лицевом счёте поставщика указана статья <%s>. Добавьте калькуляции. %s%s'
                   ,usr_pkg_fpdartcl.fpdartcl_get_code( nrn => rFaceAcc.ieelement, nflagsmart => 1 )
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => c.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => c.prn) ); 
      end if; 
      
      /* Признак существования калькуляции для спецификации */
      bCalcExists := false;

    end loop;
    
    /*Проверка на аналогичный счет (дубль за ±7 дней)*/
    begin
      select count(*)
            ,max(p.rn) keep(dense_rank first order by p.REG_DATE desc, p.rn desc) as dup_rn
        into nDuplicateCount
            ,rDup.rn
        from payaccin p
       where p.rn != nRN
         and p.company = nCOMPANY
         and p.SUPPLIER = rRow.SUPPLIER 
         and p.SUMMWITHNDS = rRow.SUMMWITHNDS 
         and upper(trim(p.EXT_NUMB)) = upper(trim(rRow.EXT_NUMB)) 
         and p.REG_DATE between rRow.REG_DATE - 7 and rRow.REG_DATE + 7 
         and rownum = 1;
    
      if nDuplicateCount > 0 then
        rDup := USR_PKG_PAYACCIN.PAYACCIN_GET(nrn => rDup.rn);
        /*Формируем список получателей*/
        begin
          select listagg(email, ';') within group (order by email)
            into l_to_list
            from (
              select distinct lower(trim(mail)) as email
                from (
                   /*1. Инициатор текущего счёта*/
                  select mail from agnlist where agnabbr = UDO_F_PAYACCIN_EXECUTER(nRN)
                  union all
                   /*2. Инициатор дублирующего счёта*/
                  select mail from agnlist where agnabbr = UDO_F_PAYACCIN_EXECUTER(rDup.rn)
                  union all
                   /*3. Сотрудники ФЭО*/
                  select mail from agnlist where upper(agnabbr) in (
                    'ТЮМЕНЦЕВА Ю.Ю.',
                    'ТАЙМАСОВ С.В.',
                    'СУРОВ Р.С.',
                    'ШИШКИНА М.В.',
                    'СОЛОВЬЁВА Н.А.'
                  )
                  union all
                   /*4. Фиксированный email*/
                  select 'r.fedoreev@module.ru' as mail from dual
                )
               where mail is not null
                 and trim(mail) is not null
            );
        end;
        begin
        USR_PKG_MAILLST.MAILLST_INSERT_EXS_EXT_SEND(
                nCOMPANY         => 1,                                          /*ID компании*/
                sDESCRIPTION     => 'Пурус. Дубль входящего счета',             /*Описание рассылки*/
                sFROM_ADDRESS    => NULL,                                       /*Использовать дефолтный email*/
                nDEL_AFTER_SEND  => 0,                                          /*Не удалять после отправки*/
                sTO_LIST         => l_to_list,                                  /*Получатели*/
                sTITLE           => 'Парус. Дубль входящего счета',             /*Тема письма*/
                cTEXT            => 'При утверждении обнаружен аналогичный входящий счёт: '||rDup.DOC_PREF||'-'||rDup.DOC_NUMB
                ||' с внешним номером: '||rDup.EXT_NUMB||' от '||to_char(rDup.DOC_DATE, 'dd.mm.yyyy')||
                ' на сумму с НДС: '||to_char(rDup.SUMMWITHNDS)||' RUB. '||
                'Контрагент: '||get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rDup.SUPPLIER)||'<br><br>',
                nFILELINKS_IDENT => null,                                       /*Без вложений*/
                nFORMAT          => 1,                                          /*1 = HTML*/
                nRN              => l_rn                                        /*OUT: RN рассылки*/
            );
          end;
      
        /*p_exception(0
                   ,'Обнаружен аналогичный счёт с номером <%s> от <%s> на сумму %s RUB у контрагента <%s>.' ||
                    chr(10) || 'Возможно, это дубликат. Проверьте корректность документа.' ||
                    chr(10) || 'RN дублирующего счёта: %s'
                   ,rDup.EXT_NUMB
                   ,to_char(rDup.DOC_DATE, 'dd.mm.yyyy')
                   ,to_char(rDup.SUMMWITHNDS)
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rDup.SUPPLIER)
                   ,rDup.rn);*/
      end if;
    end;
  end PAYACCIN_ACONFIRM;
  /*#########################################################################################################*/

  procedure PAYACCIN_BCLOSED
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in NUMBER
  )
  is
    rRow            payaccin%rowtype;
  begin
    /* Заголовок */
    rRow := payaccin_get(nrn => nRN);
    usr_pkg_pub_const.rpayaccin := rRow;
    
    /* ПРОВЕРКИ */
    /* По выходным приходным документам, не отработанным как факт */
    for c in (select l.out_document as rn, o.docstatus
                 from doclinks l, inorders o
                where l.in_document  = rRow.rn
                  and l.in_unitcode  = 'PaymentAccountsIn'
                  and l.out_unitcode = 'IncomingOrders'
                  and l.out_document = o.rn
                  and o.docstatus    <> 2
               union all
               select l1.out_document as rn, o.docstatus
                 from doclinks l, doclinks l1, inorders o
                where l.in_document   = rRow.rn
                  and l.in_unitcode   = 'PaymentAccountsIn'
                  and l.out_unitcode  = 'IncomingInvoices'
                  and l1.in_document  = l.out_document
                  and l1.in_unitcode  = 'IncomingInvoices'
                  and l1.out_unitcode = 'IncomingOrders'
                  and l1.out_document = o.rn
                  and o.docstatus     <> 2)
     loop
        p_exception(0, 'У счета есть неотработанные приходные документы. Закрытие счета невозможно. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end loop;
    /* Сумма документа не равна сумме прихода и процесс не "Закрыть недопоставленный счёт" */
    if rRow.summwithnds != rRow.inordsumm 
    and nvl(usr_pkg_process.process_get, 'null') not in ('USR_P_PAI_CLOSE_UNDERSUPPLY') then
      p_exception(0, 'Сумма документа <%s> не равна сумме "Оприходовано фактически" <%s>. %s'
                 ,usr_f_n2ss( rRow.summwithnds )
                 ,usr_f_n2ss( rRow.inordsumm )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn) ); 
    end if;
    /* Сумма документа не равна сумме оплат и процесс не "Закрыть недопоставленный счёт" */
    if rRow.summwithnds != rRow.factpaysumm 
    and nvl(usr_pkg_process.process_get, 'null') not in ('USR_P_PAI_CLOSE_UNDERSUPPLY') then
      p_exception(0, 'Сумма документа <%s> не равна сумме "Фактических платежей" <%s>. %s'
                 ,usr_f_n2ss( rRow.summwithnds )
                 ,usr_f_n2ss( rRow.factpaysumm )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn) ); 
    end if;
    
  end PAYACCIN_BCLOSED;
  /*#########################################################################################################*/

  procedure PAYACCIN_ACLOSED
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACCIN_ACLOSED;
  /*#########################################################################################################*/

  procedure PAYACCIN_BDECLINE
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACCIN_BDECLINE;
  /*#########################################################################################################*/

  procedure PAYACCIN_ADECLINE
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACCIN_ADECLINE;
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEININVOICE
  /*
  Заголовок. Проверка перед Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
    rRow            payaccin%rowtype;
  begin
    /* Сохраняем RN в константу */
    usr_pkg_pub_const.nident := nRN;
    /* Заголовок */
    rRow := payaccin_get(nrn => nRN);
    
    /* Если валюта счёта не базовая, то формирование выполнять процедурой */
    if f_curnames_is_base( nversion => null, ncurrency_rn => rRow.currency ) != 1
    and nvl( usr_pkg_process.process_get, 'null' ) != 'USR_P_PAI_MAKE_ININVOICES' then
      p_exception(0, 'Валюта счёта "%s" не является базовой. Для формирования накладной используйте пользовательскую процедуру "Сформировать приходные накладные". %s'
                 ,f_currency_get_iso( ncurrency => rRow.currency )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn) ); 
    end if;

  END PAYACCIN_BMAKEININVOICE; 
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEININVOICE
  /*
  Заголовок. Проверка после Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select column_value from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable))) 
    loop
      /* проверка заголовка */
      usr_pkg_ininvoices.ininvoices_ainsert(nrn => c.column_value, ncompany => nCOMPANY);
      /*Переносим свойство "вид приемки" в спецификацию сформирванной накданой, если во всех
      заказах подразделений значение свойства одинаковое */
      usr_p_ininvsp_vidprm_set(nrn => c.column_value);
      
    end loop;

    /* Очищаем константу */
    usr_pkg_pub_const.nident := null;

  end PAYACCIN_AMAKEININVOICE;
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEINORDERS
  /*
  Заголовок. Проверка перед Формирование приходных ордеров
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Считывание */
    usr_pkg_pub_const.rpayaccin := payaccin_get(nrn => nRN);

    /* Если документ в каталоге Метрология */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => usr_pkg_pub_const.rpayaccin.crn, shier_crn_list => 12043905) then
      p_exception(0, 'Из документов в каталоге  <%s> запрещено формирование в раздел "Приходные ордера". %s'
                 ,get_acatalog_name_id(nflag_smart => 0, nrn => usr_pkg_pub_const.rpayaccin.crn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => usr_pkg_pub_const.rpayaccin.rn)); 
    end if;    
  end PAYACCIN_BMAKEINORDERS;
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEINORDERS
  /*
  Заголовок. Проверка после Формирование приходных ордеров
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select column_value from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable))) 
    loop
      /* проверка заголовка */
      usr_pkg_inorders.inorders_ainsert(nrn => c.column_value, ncompany => nCOMPANY);
    end loop;

  end PAYACCIN_AMAKEINORDERS;
/*#########################################################################################################*/

  procedure PAYACCIN_BMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка перед Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Запрет формирования плановых платежей штатной процедурой */
    p_exception(0, 'Для добавление планового платежа из раздела "Входящие счета на оплату" используйте пользовательские процедуры или действия. %s'
               ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => nRN)); 
  end PAYACCIN_BMAKEPLANPAYNOTE;
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка после Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACCIN_AMAKEPLANPAYNOTE;
  /*#########################################################################################################*/

  procedure PAYACCIN_BMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка перед Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Запрет формирования фактических платежей */
    p_exception(0, 'Запрещено добавление фактического платежа не из раздела "Банковские документы". %s'
               ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => nRN)); 

  end PAYACCIN_BMAKEFACTPAYNOTE;
  /*#########################################################################################################*/

  procedure PAYACCIN_AMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка после Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACCIN_AMAKEFACTPAYNOTE;
  /*#########################################################################################################*/

  procedure PAYACCIN_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payaccin%rowtype;
    nDeliveryOrd    pkg_std.tref; 
    rDeliveryOrd    deliveryord%rowtype;
    sDeliveryOrdCat acatalog.name%type;
    rFaceAcc        faceacc%rowtype;
    nCount          pkg_std.tnumber := 0; 
    nNomen          pkg_std.tref; 
  begin
    /* Заголовок */
    rRow := payaccin_get(nrn => nRN);
    
    if rRow.Doc_Date> sysdate +10  or rRow.Reg_Date > sysdate +10 then 
       p_exception(0,'Нельзя регистрировать входящие счета далее 10 дней от сегодняшней даты!'); 
    end if;
    
    /* Лицевой счёт */
    rFaceAcc  := usr_pkg_faceacc.faceacc_get(nrn => rRow.faceacc);
    /* Связанный заказ поставщикам. Любой */
    nDeliveryOrd := f_doclinks_link_in_doc(sout_unitcode => 'PaymentAccountsIn', nout_document => rRow.rn, sin_unitcode  => 'DeliveryOrders'); 
    if nDeliveryOrd is not null then
      rDeliveryOrd := usr_pkg_deliveryord.deliveryord_get(nrn => nDeliveryOrd);
    end if;
        
    /* ПРОВЕРКИ */
    /* Проверка соответствия ИГК реквизитов плательщика и получателя */
    usr_p_payaccin_igk_cnt(nrn);
    
    /* Контрагент лицевого счёта не равен контрагенту документа */
    if nvl(rRow.supplier, 0) != nvl(rFaceAcc.agent, 0) then
      p_exception(0, 'Контрагент документа <%s> не равен контрагенту лицевого счёта <%s>. %s'
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.supplier)
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rFaceAcc.agent)
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;

    /* Связанный заказ поставщикам существует */
    if rDeliveryOrd.rn is not null then
      /* Лицевой счёт не равен лицевому счёту входного документа */
      if nvl(rRow.faceacc, 0) != nvl(rDeliveryOrd.faceacc, 0) 
      and nvl(usr_pkg_process.process_get, 'null') not in ( 'USR_P_DOCS_REPLACE_FACEACC' ) then
        p_exception(0, 'Лицевой счёт документа <%s> не равен лицевому счёту входного документа <%s>. %s'
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => rDeliveryOrd.faceacc)
                   ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
      end if;

      /* Каталог текущего документа 'Отдел метрологии' */
      if cmp_num(rRow.crn, 12043905) = 1 then
        /* каталог входного документа НЕ 'Отдел метрологии' */
        if cmp_num(rDeliveryOrd.crn, 88804043) != 1 then
          p_exception(0, 'Каталог документа <%s> не равен каталогу входного документа <%s>. %s'
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rDeliveryOrd.crn)
                     ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
        end if;
      /* Каталог текущего документа НЕ 'Отдел метрологии' */
      else      
        /* каталог входного документа 'Отдел метрологии' */
        if cmp_num(rDeliveryOrd.crn, 88804043) = 1 then
          p_exception(0, 'Каталог документа <%s> не равен каталогу входного документа <%s>. %s'
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rDeliveryOrd.crn)
                     ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
        end if;
      end if;
    /* Связанный заказ поставщикам НЕ существует */
    else 
      /* Считываем RN номенклатуры из любой одной спецификаци текущего документа, и определяем общее количество спецификаций */
      begin
        select t.nomen, (select count(*) from payaccinspec t where t.prn = rRow.rn) as ncount
          into nNomen, nCount
          from payaccinspec t
         where t.prn  = rRow.rn
           and rownum = 1;
      exception
        when no_data_found then
          nNomen := 0;
          nCount := 0;
        when too_many_rows then
          nNomen := 0;
          nCount := 0;
        when others then
          p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                     ,nrn, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCIN')));
      end;

      /* Каталог текущего документа 'Отдел метрологии', 'IT', "ВЭД" 
         и спецификация НЕ "услуги; нет спецификаций" 
         и НЕ одна спецификация с номенклатурой "Расходные материалы" */
      if  usr_pkg_common.is_crn_in_hiercrn( ncrn => rRow.crn, shier_crn_list => '12043905;7609964;7553720' )
      and payaccin_get_nomen_type( nrn => rRow.rn, ncompany => rRow.company ) not in (2, 0) 
      --and utilizer != 'KHOK'
      and not ( nCount = 1 and nNomen = 7169788 ) then
        p_exception(1, 'Документ находится в каталоге <%s>, при этом не связан с заказом поставщику. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn) 
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
      end if;
    end if;

  end PAYACCIN_CHECK_BASE;
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW       in v_payaccin%rowtype
  ,nDUP_RN      in number
  ,nRN          out number
  ) 
  is
  begin
    p_payaccin_insert(ncompany       => rV_ROW.NCOMPANY
                     ,ncrn           => rV_ROW.NCRN
                     ,sdoc_type      => rV_ROW.SDOC_TYPE
                     ,sdoc_pref      => rV_ROW.SDOC_PREF
                     ,sdoc_numb      => rV_ROW.SDOC_NUMB
                     ,sext_numb      => rV_ROW.SEXT_NUMB
                     ,dreg_date      => rV_ROW.DREG_DATE
                     ,ddoc_date      => rV_ROW.DDOC_DATE
                     ,ndoc_state     => rV_ROW.NDOC_STATE
                     ,dstate_date    => rV_ROW.DSTATE_DATE
                     ,dpay_date      => rV_ROW.DPAY_DATE
                     ,spayer         => rV_ROW.SPAYER
                     ,spayeracc      => rV_ROW.SPAYERACC
                     ,ssupplier      => rV_ROW.SSUPPLIER
                     ,ssupplacc      => rV_ROW.SSUPPLACC
                     ,sfaceacc       => rV_ROW.SFACEACC
                     ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                     ,scurrency      => rV_ROW.SCURRENCY
                     ,ncurcours      => rV_ROW.NCURCOURS
                     ,ncurbase       => rV_ROW.NCURBASE
                     ,sagnfi         => rV_ROW.SAGNFI
                     ,sagnfo         => rV_ROW.SAGNFO
                     ,sstore         => rV_ROW.SSTORE
                     ,svdoc_type     => rV_ROW.SVDOC_TYPE
                     ,svdoc_num      => rV_ROW.SVDOC_NUM
                     ,dvdoc_date     => rV_ROW.DVDOC_DATE
                     ,npricewithtax  => rV_ROW.NPRICEWITHTAX
                     ,nfa_basecourse => rV_ROW.NFA_BASECOURSE
                     ,nfa_course     => rV_ROW.NFA_COURSE
                     ,nplanpaysumm   => rV_ROW.NPLANPAYSUMM
                     ,nfactpaysumm   => rV_ROW.NFACTPAYSUMM
                     ,nininvsumm     => rV_ROW.NININVSUMM
                     ,ninordsumm     => rV_ROW.NINORDSUMM
                     ,scomments      => rV_ROW.SCOMMENTS
                     ,spaytype       => rV_ROW.SPAYTYPE
                     ,ndiscount      => rV_ROW.NDISCOUNT
                     ,ndup_rn        => nDUP_RN
                     ,nrn            => nRN);
  END PAYACCIN_INSERT;
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_payaccin%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_PayAccIn       v_payaccin%rowtype;
    aRN_Unit_List     usr_pkg_pub_const.tRN_Unit_List;

    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_payaccin_update(nrn            => rV_ROW.NRN
                       ,ncompany       => rV_ROW.NCOMPANY
                       ,sdoc_type      => rV_ROW.SDOC_TYPE
                       ,sdoc_pref      => rV_ROW.SDOC_PREF
                       ,sout_numb      => null
                       ,sdoc_numb      => rV_ROW.SDOC_NUMB
                       ,sext_numb      => rV_ROW.SEXT_NUMB
                       ,dreg_date      => rV_ROW.DREG_DATE
                       ,ddoc_date      => rV_ROW.DDOC_DATE
                       ,ndoc_state     => rV_ROW.NDOC_STATE
                       ,dstate_date    => rV_ROW.DSTATE_DATE
                       ,dpay_date      => rV_ROW.DPAY_DATE
                       ,spayer         => rV_ROW.SPAYER
                       ,spayeracc      => rV_ROW.SPAYERACC
                       ,ssupplier      => rV_ROW.SSUPPLIER
                       ,ssupplacc      => rV_ROW.SSUPPLACC
                       ,sfaceacc       => rV_ROW.SFACEACC
                       ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                       ,scurrency      => rV_ROW.SCURRENCY
                       ,ncurcours      => rV_ROW.NCURCOURS
                       ,ncurbase       => rV_ROW.NCURBASE
                       ,sagnfi         => rV_ROW.SAGNFI
                       ,sagnfo         => rV_ROW.SAGNFO
                       ,sstore         => rV_ROW.SSTORE
                       ,svdoc_type     => rV_ROW.SVDOC_TYPE
                       ,svdoc_num      => rV_ROW.SVDOC_NUM
                       ,dvdoc_date     => rV_ROW.DVDOC_DATE
                       ,npricewithtax  => rV_ROW.NPRICEWITHTAX
                       ,nfa_basecourse => rV_ROW.NFA_BASECOURSE
                       ,nfa_course     => rV_ROW.NFA_COURSE
                       ,nplanpaysumm   => rV_ROW.NPLANPAYSUMM
                       ,nfactpaysumm   => rV_ROW.NFACTPAYSUMM
                       ,nininvsumm     => rV_ROW.NININVSUMM
                       ,ninordsumm     => rV_ROW.NINORDSUMM
                       ,scomments      => rV_ROW.SCOMMENTS
                       ,spaytype       => rV_ROW.SPAYTYPE
                       ,ndiscount      => rV_ROW.NDISCOUNT);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Сохранение значений в переменную */
      rV_PayAccIn := rV_ROW;
      
      /* Если статус документа НЕ "Не утверждён" */
      if rV_PayAccIn.ndoc_state != 0 then

        /* Очистка перед исправлением */
        payaccin_clear_for_update( nrn => rV_PayAccIn.nrn, nmode => 0 );

        /* Исправление */
        payaccin_update(rv_row => rV_PayAccIn, nmode => 0);

        /* Восстановление после очистки */
        payaccin_clear_for_update( nrn => rV_PayAccIn.nrn, nmode => 1 );

      /* Если статус документа "Не утверждён" */
      else
        /* Исправление */
        payaccin_update( rv_row => rV_PayAccIn, nmode => 0 );
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  END PAYACCIN_UPDATE;
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in payaccin%rowtype  -- RN сформированного документа
  ,nSTATUS_IGNORE   in number default 0  -- Исправлять в утверждёный документ 0-нет, 1-да
  ) 
  is
  begin
    /* Если договор утверждён, то снимаем утверждение */
    if nSTATUS_IGNORE = 1 and rROW.DOC_STATE != 0 then
      update payaccin set doc_state = 0 where rn = rROW.RN;
    end if;
    p_payaccin_base_update(nrn            => rROW.RN
                          ,ncompany       => rROW.COMPANY
                          ,ndoc_type      => rROW.DOC_TYPE
                          ,sdoc_pref      => rROW.DOC_PREF
                          ,sdoc_numb      => rROW.DOC_NUMB
                          ,sext_numb      => rROW.EXT_NUMB
                          ,dreg_date      => rROW.REG_DATE
                          ,ddoc_date      => rROW.DOC_DATE
                          ,ndoc_state     => rROW.DOC_STATE
                          ,dstate_date    => rROW.STATE_DATE
                          ,dpay_date      => rROW.PAY_DATE
                          ,npayer         => rROW.JUR_PERS /*nPAYER*/
                          ,npayeracc      => rROW.PAYERACC
                          ,nsupplier      => rROW.SUPPLIER
                          ,nsupplacc      => rROW.SUPPLACC
                          ,nfaceacc       => rROW.FACEACC
                          ,ngraphpoint    => rROW.GRAPHPOINT
                          ,ncurrency      => rROW.CURRENCY
                          ,ncurcours      => rROW.CURCOURS
                          ,ncurbase       => rROW.CURBASE
                          ,nagnfi         => rROW.AGNFI
                          ,nagnfo         => rROW.AGNFO
                          ,nstore         => rROW.STORE
                          ,nvdoc_type     => rROW.VDOC_TYPE
                          ,svdoc_num      => rROW.VDOC_NUM
                          ,dvdocdate      => rROW.VDOC_DATE
                          ,npricewithtax  => rROW.PRICEWITHTAX
                          ,nfa_basecourse => rROW.FA_BASECOURS
                          ,nfa_course     => rROW.FA_COURS
                          ,nplanpaysumm   => rROW.PLANPAYSUMM
                          ,nfactpaysumm   => rROW.FACTPAYSUMM
                          ,nininvsumm     => rROW.ININVSUMM
                          ,ninordsumm     => rROW.INORDSUMM
                          ,scomments      => rROW.COMMENTS
                          ,npaytype       => rROW.PAYTYPE
                          ,ndiscount      => rROW.DISCOUNT);
    /* Если договор утверждён, то восстанавливаем утверждение */
    if nSTATUS_IGNORE = 1 and rROW.DOC_STATE in (1, 2) then
      update payaccin set doc_state = rROW.DOC_STATE where rn = rROW.RN;
    end if;
  END PAYACCIN_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure PAYACCIN_MAKE_BY_MODEL
  /*
  Добавить по образцу товарного документа
  */
  (
   nMODEL           in number
  ,dDATE            in date default null
  ,nRN              out number
  )
  is
    rV_ModelHead    v_transinvcust_mdl%rowtype;
    rV_PayAccIn     v_payaccin%rowtype;
    rV_PayAccInSpec v_payaccinspec%rowtype;
    rV_FaceAcc      v_FaceAcc%rowtype;
    rAgnlist        agnlist%rowtype;
    nClnEvents      pkg_std.tref; 
    rV_ClnEvents    v_clnevents%rowtype;
    nClnPersons     pkg_std.tref; 
    rClnPersons     clnpersons%rowtype;

    nNumber         pkg_std.tnumber;
  begin
    /* Заголовок образца */
    begin
      select * into rV_ModelHead from v_transinvcust_mdl where nrn = nMODEL;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nMODEL, sunit_table => 'TRANSINVCUST_MDL');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nMODEL, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVCUST_MDL')));
    end;

    /* Наполнение переменных для заголовка */
    rV_PayAccIn.ncompany  :=  rV_ModelHead.ncompany;
    rV_PayAccIn.njur_pers :=  rV_ModelHead.njur_pers;

    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => rV_PayAccIn.ncompany
                      ,nversion    => null
                      ,sunitcode   => 'PaymentAccountsIn'
                      ,sname       => usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 134513999, ndocument => rV_ModelHead.nrn)
                      ,nrn         => rV_PayAccIn.ncrn);

    rV_PayAccIn.sdoc_type := rV_ModelHead.sdoctype;
    rV_PayAccIn.ddoc_date := nvl( dDATE, sysdate );
    rV_PayAccIn.sdoc_pref := to_number( to_char( rV_PayAccIn.ddoc_date, 'YYYY' ) );

    p_payaccin_getnextnumb(ncompany  => rV_PayAccIn.ncompany
                          ,sjur_pers => rV_ModelHead.sjur_pers
                          ,ddoc_date => rV_PayAccIn.ddoc_date
                          ,sdoc_type => rV_PayAccIn.sdoc_type
                          ,sdoc_pref => rV_PayAccIn.sdoc_pref
                          ,sdoc_numb => rV_PayAccIn.sdoc_numb);

    rV_PayAccIn.ndoc_state  :=  0;
    rV_PayAccIn.dstate_date :=  rV_PayAccIn.ddoc_date;
    rV_PayAccIn.dpay_date   :=  null;
    rV_PayAccIn.spayer      :=  rV_ModelHead.sjur_pers;
    rV_PayAccIn.spayeracc   :=  rV_ModelHead.sself_agnacc;
    rV_PayAccIn.ssupplier   :=  rV_ModelHead.sagent;
    rV_PayAccIn.ssupplacc   :=  rV_ModelHead.sagnacc;

    if rV_ModelHead.sfaceacc is not null then
      select * into rV_FaceAcc from v_faceacc where snumber = rV_ModelHead.sfaceacc;
    end if;
    rV_PayAccIn.sfaceacc       :=  rV_FaceAcc.snumber;

    rV_PayAccIn.scurrency      :=  rV_ModelHead.scurrency;
    rV_PayAccIn.ncurcours      :=  1;
    rV_PayAccIn.ncurbase       :=  1;
    rV_PayAccIn.sagnfi         :=  null;
    rV_PayAccIn.sagnfo         :=  null;
    rV_PayAccIn.sstore         :=  rV_ModelHead.sstore;
    rV_PayAccIn.svdoc_type     :=  rV_FaceAcc.svalid_doctype;
    rV_PayAccIn.svdoc_num      :=  rV_FaceAcc.svalid_docnumb;
    rV_PayAccIn.dvdoc_date     :=  rV_FaceAcc.dvalid_docdate;
    rV_PayAccIn.npricewithtax  :=  rV_ModelHead.nsigntax;
    rV_PayAccIn.nfa_basecourse :=  1;
    rV_PayAccIn.nfa_course     :=  1;
    rV_PayAccIn.nplanpaysumm   :=  0;
    rV_PayAccIn.nfactpaysumm   :=  0;
    rV_PayAccIn.nininvsumm     :=  0;
    rV_PayAccIn.ninordsumm     :=  0;
    rV_PayAccIn.scomments      :=  usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 121124504, ndocument => rV_ModelHead.nrn);
    rV_PayAccIn.spaytype       :=  null;
    rV_PayAccIn.ndiscount      :=  rV_ModelHead.ndiscount;

    /* Добавление заголовка */
    payaccin_insert(rv_row => rV_PayAccIn, ndup_rn => null, nrn => rV_PayAccIn.nrn);
    
    /* По спецификациям образца */
    for c in (select * from v_transinvcust_mdlspecs where nprn = rV_ModelHead.nrn)
    loop  
      /* Наполнение переменных для спецификации */
      rV_PayAccInSpec.nprn           := rV_PayAccIn.nrn;
      rV_PayAccInSpec.ncompany       := c.ncompany;
      rV_PayAccInSpec.snomen         := c.snomen;
      rV_PayAccInSpec.snommodif      := c.snommodif;
      rV_PayAccInSpec.snompack       := null;
      rV_PayAccInSpec.snommodifpack  := c.snomnmodifpack ;
      rV_PayAccInSpec.sseria         := null;
      rV_PayAccInSpec.scountry       := c.scountry;
      rV_PayAccInSpec.sgtd           := null;
      rV_PayAccInSpec.staxgr         := c.staxgr;
      rV_PayAccInSpec.nquant         := c.nquant;
      rV_PayAccInSpec.nquantalt      := c.nquantalt;
      rV_PayAccInSpec.dbegindate     := rV_PayAccIn.ddoc_date;
      rV_PayAccInSpec.denddate       := rV_PayAccIn.ddoc_date;
      rV_PayAccInSpec.nprice         := c.nprice;
      rV_PayAccInSpec.npricemeas     := c.npricemeas;

      pkg_dictaxis_calc.p_calculate(nflag_smart => 0
                                   ,ncompany    => rV_PayAccInSpec.ncompany
                                   ,ddate       => rV_PayAccIn.ddoc_date
                                   ,nsumm_sign  => 1 /* всегда с налогами */
                                   ,ninsumm     => c.nprice * c.nquant
                                   ,staxgr      => c.staxgr
                                   ,nquant      => 1
                                   ,nncp_sign   => 1);
      rV_PayAccInSpec.nsumm        := pkg_dictaxis_calc.f_get_value(nident => 0); /* Сумма без налогов       (0) */
      rV_PayAccInSpec.nsummwithnds := pkg_dictaxis_calc.f_get_value(nident => 2); /* Сумма со всеми налогами (2) */
      rV_PayAccInSpec.nsumm_nds    := pkg_dictaxis_calc.f_get_value(nident => 8); /* НДС                     (8) */
      rV_PayAccInSpec.nprice       := case rV_ModelHead.nsigntax when 0 then rV_PayAccInSpec.nsumm else rV_PayAccInSpec.nsummwithnds end / rV_PayAccInSpec.nquant;

      rV_PayAccInSpec.nautocalc_sign := c.nautocalc_sign;
      rV_PayAccInSpec.nplanquant     := null;
      rV_PayAccInSpec.nfactquant     := null;
      rV_PayAccInSpec.nplansumm      := null;
      rV_PayAccInSpec.nfactsumm      := null;
      rV_PayAccInSpec.sstore         := c.sstore;
      rV_PayAccInSpec.scomments      := null;
      rV_PayAccInSpec.ndiscount      := c.ndiscount;
      rV_PayAccInSpec.soriginal_name := null;
      /* Добавление спецификации */
      payaccinspec_insert(rv_row => rV_PayAccInSpec, nrn => rV_PayAccInSpec.nrn);
    end loop;

    /* Если в образце задан ответственный */
    if rV_ModelHead.nacc_agent is not null then
      /* считываем его запись */
      select * into rAgnlist from agnlist where rn = rV_ModelHead.nacc_agent;

      /* RN события документа */
      nClnEvents := usr_pkg_document.get_clnevents(nflagsmart => 0, nrn => rV_PayAccIn.nrn);

      /* считывание представление события документа */
      select * into rV_ClnEvents from v_clnevents where nrn = nClnEvents;

      /* определяем сотрудника по контрагенту - ответственному в шаблоне */
      find_clnpersons_by_agent(nflag_smart => 0
                              ,ncompany    => rV_ModelHead.ncompany
                              ,nagent      => rAgnlist.rn
                              ,ddate       => sysdate
                              ,nclnpersons => nClnPersons);

      /* считывание записи сотрудника */
      rClnPersons := udo_pkg_get.row_clnpersons(nrn => nClnPersons, nsmart => 0);

      /* RN события документа */
      if cmp_vc2(rClnPersons.pers_authid, utilizer) != 1 then

        /* определяем наименование пользователя по AUTH_ID сотрудника */
        find_userlist_by_authid(nflag_smart => 0, sauthid => rClnPersons.pers_authid, sname => rV_ClnEvents.ssend_user_name);

        /* направляем событие сотруднику - ответственному в шаблоне */
        p_clnevents_send(ncompany         => rV_ClnEvents.ncompany
                        ,nrn              => rV_ClnEvents.nrn
                        ,ssend_client     => null
                        ,ssend_division   => null
                        ,ssend_post       => null
                        ,ssend_perform    => null
                        ,ssend_person     => null
                        ,ssend_staffgrp   => null
                        ,ssend_user_group => null
                        ,ssend_user_name  => rV_ClnEvents.ssend_user_name);
      end if;
    end if;

    /* Если у контрагента ответственного заполнен e-mail */
    if rAgnlist.mail is not null then
      /* отправляем сообщение */
      pkg_exs_ext_mail.send_by_list(sto_list => rAgnlist.mail
                                   ,stitle   => 'Парус. Выполнено атоматическое формирование документа по образцу'
                                   ,ctext    => 'Образец: '||rV_ModelHead.smodel_name||
                                                cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_PayAccIn.nrn)
                                   ,nformat  => pkg_exs_ext_mail.nformat_text);
    end if;                                         

    /* RN добавленного заголовка */
    nRN := rV_PayAccIn.nrn;

  end PAYACCIN_MAKE_BY_MODEL;
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_MAKE_INORDERS
  /*
  Формирование приходных ордеров
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2 default null
  ,sDOCTYPE         in varchar2 default null
  ,dDATE            in date
  ,sSTORE           in varchar2 
  ,sSTOREOPER       in varchar2 default null
  ,aRNLIST          out udo_tp_numtable
  ) 
  is
    rRow              payaccin%rowtype;
    nCatalog          pkg_std.tref; 
    nStoreOper        pkg_std.tref; 
    nIdent            pkg_std.tref; 
    nCount            pkg_std.tnumber; 
    rInOrdersBuff     inordersbuff%rowtype; 
  begin
    /* Считывание */
    rRow := payaccin_get(nrn => nRN);
    /* Каталог Приходных ордеров */
    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => rRow.company
                      ,nversion    => null
                      ,sunitcode   => 'IncomingOrders'
                      ,sname       => sCATALOG
                      ,nrn         => nCatalog);
    /* Складская операция */
    find_dicstopr_code(nsmart_flag => 0
                      ,ncompany    => rRow.company
                      ,scode       => sSTOREOPER
                      ,nrn         => nStoreOper);

    /* Проверка утверждённости */
    if rRow.doc_state != 1 then
      p_exception(0, 'Документ не утверждён. Формирование не выполненно. %s'
                 ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.rn)); 
    end if;

    /* Формирование буфера */
    p_selectlist_genident(nident => nIdent);
    p_payaccin_makeinorder(ncompany     => rRow.company
                          ,nident       => nIdent
                          ,nrn          => rRow.rn
                          ,ddate        => dDate
                          ,sstore_title => sSTORE
                          ,nspec_empty  => 0
                          ,nORDER_TYPE  => 0       -- тип ордера (0 - Приходный ордер, 1 - Акт приёмки товаров, работ, услуг)  --Обновление 2024/03/28
                          ,nres         => nCount);
    /* если буфер не сформировался */
    if nCount = 0  then
      p_exception(0, 'Формирование не выполненно. %s'
                 ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.rn)); 
    end if;

    /* По заголовкам буфера */
    for c in (select * from inordersbuff where ident = nIdent)
    loop
      /* считывание текущей записи в переменную */
      rInOrdersBuff := c;
      /* подмена значений в переменной */
      rInOrdersBuff.crn := nCatalog;
      rInOrdersBuff.stopertype := nStoreOper;
      /* исправление записи буфера */
      usr_pkg_inorders.inordersbuff_base_update(rrow => rInOrdersBuff);

      /* Исправление Парусовой ошибки */
      for c1 in (select * from inordspbuff where prn = c.rn)
      loop
        /* пересчёт учётных цен */
        usr_pkg_inorders.inordspbuff_update_pcr(nflagsmart => 1,nrn => c1.rn, nprice_calc_rule => 1);
      end loop;
    end loop;

    /* Перенос из буфера */  
    p_inordersbuff_makedoc(ncompany => rRow.company, nident => nIdent);

    /* Очистка */  
    p_inordersbuff_pack(nident => nIdent);
    
    /* Список сформированных документов */
    aRNLIST := usr_pkg_pub_const.arnlist;

  END PAYACCIN_MAKE_INORDERS;
  /*#########################################################################################################*/

  PROCEDURE PAYACCIN_MAKE_ININVOICES
  /*
  Формирование приходных накладных
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2 default null
  ,sDOCTYPE         in varchar2 default null
  ,sDOCPREF         in varchar2 default null
  ,dDATE            in date     default null
  ,sEXT_NUMB        in varchar2 default null
  ,dEXT_DATE        in date     default null
  ,sCURRENCY        in varchar2 default null  
  ,sSTOREOPER       in varchar2 default null
  ,aRNLIST          out udo_tp_numtable
  ) 
  is
    rRow                payaccin%rowtype;
    rV_InInvoicesBuff   v_ininvoicesbuff%rowtype;
    rV_InInvoicesSpBuff v_ininvoicesspbuff%rowtype;
    nCount              pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := payaccin_get(nrn => nRN);
    
    /* Проверка утверждённости */
    if rRow.doc_state != 1 then
      p_exception(0, 'Документ не утверждён. Формирование не выполненно. %s'
                 ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.rn)); 
    /* Если цены НЕ ВКЛЮЧАЮТ налоги */
    elsif rRow.pricewithtax != 1 then
      /* изменяем на ВКЛЮЧАЮТ налоги */
      rRow.pricewithtax := 1;
      payaccin_base_update(rrow => rRow, nstatus_ignore => 1);
    end if;

    /* Сохранение настроек пользователя раздела Приходные накладные */
    usr_pkg_common.options_save_unit_params( sunitcode => 'IncomingInvoices' );

    /* Исправление настроек пользователя раздела Расходные накладные на возврат поставщикам */
    if sCATALOG is not null then
      usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_IncInv_Catalog'  , sstr_val => sCATALOG);
    end if;
    if sDOCTYPE is not null then
      usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_IncInv_DocType'  , sstr_val => sDOCTYPE);
    end if;
    if sDOCPREF is not null then
      usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_IncInv_Pref'  , sstr_val => sDOCPREF);
    end if;
    if sSTOREOPER is not null then
      usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_IncInv_StoreOper', sstr_val => sSTOREOPER);
    end if;

    /* Формирование буфера */
    p_payaccin_makeininvoice(ncompany     => rRow.company
                            ,nident       => rRow.rn
                            ,nrn          => rRow.rn
                            ,nsource_crn  => null
                            ,ddate        => trunc(dDATE)
                            ,sstore_title => null
                            ,nspec_empty  => 0
                            ,nres         => nCount);

    /* Восстановление настроек пользователя */
    usr_pkg_common.options_restore_unit_params;

    /* если буфер не сформировался */
    if nCount = 0  then
      p_exception(0, 'Формирование приходной накладной не выполненно. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.rn)); 
    end if;

    
    /* По заголовкам буфера */
    for c in ( select * from v_ininvoicesbuff where nident = rrow.rn )
    loop
      /* Копирование заголовка в переменную */
      rV_InInvoicesBuff := c;

      /* Подмена значений */
      rV_InInvoicesBuff.sext_numb     := sEXT_NUMB;
      rV_InInvoicesBuff.dext_date     := dEXT_DATE;
      rV_InInvoicesBuff.scurrency     := nvl( sCURRENCY, rV_InInvoicesBuff.scurrency );
      rV_InInvoicesBuff.ncurbasecours := rRow.curbase;
      rV_InInvoicesBuff.ncurcours     := rRow.curcours;  

      /* Исправляем заголовок */
      usr_pkg_ininvoices.ininvoicesbuff_update( rv_row => rV_InInvoicesBuff );

      /* Если валюта заголовка не равна валюте параметра */
      if cmp_vc2( rV_InInvoicesBuff.scurrency, sCURRENCY ) != 1 then

        /* По спецификациям буфера */
        for c1 in ( select * from v_ininvoicesspbuff where nprn = rV_InInvoicesBuff.nrn )
        loop
          /* Копирование спецификации в переменную */
          rV_InInvoicesSpBuff := c1;
          /* Пересчёт сумм по курсу заголовка */
          pkg_dictaxis_calc.p_calculate( nflag_smart => 0
                                        ,ncompany    => rV_InInvoicesSpBuff.ncompany
                                        ,ddate       => rV_InInvoicesBuff.ddoc_date
                                        ,nsumm_sign  => 1 /* всегда с налогами */
                                        ,ninsumm     => rV_InInvoicesSpBuff.nsummtax * rV_InInvoicesBuff.ncurbasecours / rV_InInvoicesBuff.ncurcours 
                                        ,staxgr      => rV_InInvoicesSpBuff.staxgr
                                        ,nquant      => 1
                                        ,nncp_sign   => 1 );
          rV_InInvoicesSpBuff.nsumm     := pkg_dictaxis_calc.f_get_value(nident => 0); /* Сумма без налогов       (0) */
          rV_InInvoicesSpBuff.nsummtax  := pkg_dictaxis_calc.f_get_value(nident => 2); /* Сумма со всеми налогами (2) */
          rV_InInvoicesSpBuff.nsumm_nds := pkg_dictaxis_calc.f_get_value(nident => 8); /* НДС                     (8) */
          rV_InInvoicesSpBuff.nprice    := rV_InInvoicesSpBuff.nsummtax / rV_InInvoicesSpBuff.nquant;
          /* Исправляем спецификацию */
          usr_pkg_ininvoices.ininvoicesspbuff_update( rv_row => rV_InInvoicesSpBuff );
        end loop;
      end if;
    end loop;

    /* Перенос из буфера */  
    p_ininvoicesbuff_makedoc(ncompany => rRow.company, nident => rRow.rn);

    /* Очистка */  
    p_ininvoicesbuff_clean(nident => rRow.rn, ncompany => rRow.company);    
    
    /* Список сформированных документов */
    aRNLIST := usr_pkg_pub_const.arnlist;

  END PAYACCIN_MAKE_ININVOICES;
  /*#########################################################################################################*/

  procedure PAYACCIN_UPDATE_PRICEWITHTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART     in number default 0
  ,nRN            in number
  ,nPRICEWITHTAX  in number /* 0 - не включают, 1 - включают */
  ) 
  is
    rRow        payaccin%rowtype;
    rSpec       payaccinspec%rowtype;

    nNumber     pkg_std.tnumber; 
  begin
    /* Заголовок  */
    rRow := PAYACCIN_GET(nRN);
    
    /* Проверка параметров*/    
    /* Не задан */
    if nPRICEWITHTAX is null then
      P_EXCEPTION(0, 'Не задан параметр процедуры "Цены включают налоги". %s'
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('PaymentAccountsIn', rRow.rn)); 
    elsif nPRICEWITHTAX not in (0, 1) then
      P_EXCEPTION(0, 'Неверное значение: "%s" параметра процедуры "Цены включают налоги". %s'
                 ,nPRICEWITHTAX
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('PaymentAccountsIn', rRow.rn)); 
    end if;
    /* Имеет такое же значение, как в документе */
    if  CMP_NUM(rRow.pricewithtax, nPRICEWITHTAX) = 1 
    and nFLAGSMART = 0 then
      P_EXCEPTION(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.pricewithtax when 0 then 'Нет' else 'Да' end
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('PaymentAccountsIn', rRow.rn)); 
    end if;
      
    /* Исправление заголовка */
    rRow.pricewithtax := nPRICEWITHTAX;
    payaccin_base_update(rrow => rRow, nSTATUS_IGNORE => 1);

    /* По спецификациям */
    for c in (select * from PAYACCINSPEC where prn = rRow.rn)
    loop
      /* Сохранение записи в переменную */
      rSpec := c;
      /* Расчёт сумм */
      PKG_DICTAXIS_CALC.P_CALCULATE_BASE
      (
       nFLAG_SMART => 0
      ,nCOMPANY    => rRow.company
      ,dDATE       => rRow.doc_date
      ,nSUMM_SIGN  => nPRICEWITHTAX
      ,nINSUMM     => case nPRICEWITHTAX when 0 then rSpec.summ else rSpec.summwithnds end 
      ,nTAXGR      => rSpec.taxgr
      ,nQUANT      => rSpec.quant
      ,nNCP_SIGN   => 1
      );
      /* Сохранение сумм в переменную */
      rSpec.summ        := PKG_DICTAXIS_CALC.F_GET_VALUE(0); /* Сумма без налогов (0) */
      rSpec.summwithnds := PKG_DICTAXIS_CALC.F_GET_VALUE(2); /* Сумма со всеми налогами (2) */
      rSpec.summ_nds    := PKG_DICTAXIS_CALC.F_GET_VALUE(8); /* НДС (8) */
      rSpec.price       := case nPRICEWITHTAX when 0 then rSpec.summ else rSpec.summwithnds end / rSpec.quant; /* Цена */
      /* Исправление спецификации */
      PAYACCINSPEC_BASE_UPDATE(RROW => rSpec);
    end loop;

  end PAYACCIN_UPDATE_PRICEWITHTAX;
  /*#########################################################################################################*/

  procedure PAYACCIN_RECREATE_PAISC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  ) 
  is
    rRow                  payaccin%rowtype;
    nINDH                 pkg_std.tref;          /* входной документ. Заголовок. RN */
    rINDS                 deliveryords%rowtype;  /* входной документ. Спецификация. Запись */
    nINDC_CURC_Quant      pkg_std.tquant;       /* распределённое количество калькуляции входного документа */
    nINDC_CURC_QuantRest  pkg_std.tquant;       /* нераспределённое количество калькуляции входного документа */
    nCURS_QuantRest       pkg_std.tquant;       /* нераспределённое количество калькуляции текущего документа */
    nQuant                pkg_std.tquant;       /* количество для распределения */
    rCURC                 payaccinspclc%rowtype; /* калькуляция текущего документа. Запись */
    
    nNumber           pkg_std.tnumber; 
  begin
    /* Заголовок  */
    rRow := payaccin_get(nrn => nRN);

    /* Удаление калькуляций во всех спецификациях текущего документа */
    for c in (select rn, company from payaccinspclc where prn in (select rn from payaccinspec where prn =  nRN))
    loop
      p_payaccinspclc_base_delete(nrn => c.rn, ncompany => c.company);
    end loop;
    
    /* По спецификациям текущего документа */
    for sp in (select * from payaccinspec where prn =  nRN)
    loop
      /* Поиск заголовка входного документа */
      nINDH := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                    ,sout_unitcode  => 'PaymentAccountsIn'
                                                    ,nout_document  => sp.prn
                                                    ,sin_unitcode   => 'DeliveryOrders');
      /* поиск аналогичной спецификации входного документа */
      usr_pkg_deliveryord.deliveryords_get_by_params(nprn         => nINDH
                                                    ,nnom_modif   => sp.nommodif
                                                    ,nnommod_pack => sp.nommodifpack
                                                    ,ntax_group   => sp.taxgr
                                                    ,rrow         => rINDS);
      /* Нераспределённое количество калькуляции текущего документа = количество по спецификации текущего документа */
      nCURS_QuantRest := sp.quant;

      /* По калькуляциям спецификации входного документа с сортировкой по номеру ЛС */
      for c in (select t.*
                  from deliveryordcs t, faceacc fa
                 where t.prn         = rINDS.rn
                   and t.faceaccount = fa.rn
                order by fa.numb)
      loop
        /* распределённое количество калькуляции входного документа */
        usr_pkg_deliveryord.deliveryordcs_get_paisc_quant(nrn         => c.rn
                                                         ,nquant_plan => nINDC_CURC_Quant
                                                         ,nquant_fact => nNumber);
        /* нераспределённое количество калькуляции входного документа */
        nINDC_CURC_QuantRest := c.quant_plan - nINDC_CURC_Quant;
        /* если Нераспределённое количество калькуляции текущего документа больше или равно Нераспределённому количеству калькуляции входного документа */
        if nCURS_QuantRest >= nINDC_CURC_QuantRest then
          /* используем Нераспределённое количество калькуляции входного документа */
          nQuant := nINDC_CURC_QuantRest;
          /* пересчитываем Нераспределённое количество калькуляции текущего документа */
          nCURS_QuantRest := nCURS_QuantRest - nQuant;
        /* если Нераспределённое количество калькуляции текущего документа меньше Нераспределённого количества калькуляции входного документа */
        else
          /* используем Нераспределённое количество калькуляции текущего документа */
          nQuant := nCURS_QuantRest;
          /* пересчитываем Нераспределённое количество калькуляции текущего документа */
          nCURS_QuantRest := nCURS_QuantRest - nQuant;
        end if;
         /* если есть количество для распределения */
        if nQuant != 0 then 
          /* Сохранение значений в переменную калькуляции текущего документа */
          rCURC.prn          := sp.rn;
          rCURC.company      := sp.company;
          rCURC.crn          := sp.crn;
          rCURC.numb         := null;
          rCURC.cost_article := c.cost_article;
          rCURC.cost_place   := c.cost_place;
          rCURC.cost_plan    := null;
          rCURC.cost_fact    := null;
          rCURC.priority     := c.priority;
          rCURC.faceaccount  := c.faceaccount;
          rCURC.graphpoint   := c.graphpoint;
          rCURC.finoper_type := c.finoper_type;
          rCURC.quant_plan   := nQuant;
          -- rCURC.quant_fact   := nQuant;
          rCURC.subdiv       := c.subdiv;
          /* добавление калькуляции текущего документа*/
          payaccinspclc_base_insert(rrow => rCURC, nrn => nNumber);
        end if;
      end loop;
    end loop;
    
  end PAYACCIN_RECREATE_PAISC;
  /*#########################################################################################################*/

  procedure PAYACCIN_RECALC_PERFORMANCE
  /*
  Заголовок. Пересчитать исполнение
  (пока работает только по приходным накладным)
  */
  (
   nRN      in number
  ) 
  is
    nNumber   pkg_std.tnumber; 
  begin
    /* Отключение регистрации */
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

    /* Обнуление исполнения в спецификациях (заголовок обновляется в триггере спецификаций)  */
    update payaccinspec 
       set planquant = 0
          ,factquant = 0
          ,plansumm  = 0
          ,factsumm  = 0
     where prn = nRN;

    /* Приходные накладные */
    /* Получение списка приходных накладных */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'PaymentAccountsIn'
                                              ,nin_document  => nRN
                                              ,sout_unitcode => 'IncomingInvoices'
                                              ,nident        => nRN );
    /* По отработанным РН поставщикам из списка */
    for c in ( select t.rn, t.company, t.work_date
                 from selectlist  sl
                     ,ininvoices  t
                where sl.ident    = nRN
                  and t.rn        = sl.document 
                  and t.status    = 2 )
    loop
      /* пересчёт */
      usr_pkg_ininvoices.ininvoices_recalc_performance( ncompany   => c.company
                                                       ,dwork_date => c.work_date
                                                       ,nr_rn      => c.rn
                                                       ,nr_ostatus => 0
                                                       ,nr_nstatus => 2 );
    end loop;                  
    /* Очистка */
    p_selectlist_clear( nident => nRN );


    /* РН на возврат поставщикам */
    /* Получение списка РН поставщикам */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'PaymentAccountsIn'
                                              ,nin_document  => nRN
                                              ,sout_unitcode => 'ReturnInvoicesToSuppliers'
                                              ,nident        => nRN );
    /* По отработанным РН поставщикам из списка */
    for c in ( select t.rn, t.company, t.work_date
                 from selectlist  sl
                     ,rinvtosup   t
                where sl.ident    = nRN
                  and t.rn        = sl.document 
                  and t.status    = 1 )
    loop
      /* пересчёт */
      usr_pkg_rinvtosup.rinvtosup_recalc_performance(ncompany   => c.company
                                                    ,dwork_date => c.work_date
                                                    ,nr_rn      => c.rn
                                                    ,nr_ostatus => 0
                                                    ,nr_nstatus => 2);
    end loop;                  
    /* Очистка */
    p_selectlist_clear( nident => nRN );

    /* Включение регистрации */
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
    
  end PAYACCIN_RECALC_PERFORMANCE;
  /*#########################################################################################################*/

  procedure PAYACCIN_CLEAR_FOR_UPDATE
  /*
  Заголовок. Очистка перед исправлением и восстановление после очистки
  При очистке удаляются связи, снимается отработка. При восстановлении отрабатывается, восстанавливаются связи 
  Обязательно выполнять в обоих режимах, иначе документ останется неотработанным и без связей
  */
  (
   nRN          in number       
  ,nMODE        in number       /* Режим выполнения: 0 - освободить, 1 - восстановить */
  ) 
  is
    rRow        payaccin%rowtype;
    nNumber     pkg_std.tnumber;
    sVarchar    pkg_std.tstring;
  begin
    /* Считывание */
    rRow := payaccin_get( nrn => nRN );

    /* 0 - Освободить */
    if nMODE = 0 then

      /* Копирование текущих значений в переменную-дубликат */
      usr_pkg_pub_const.rpayaccin := rRow;

      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
      /* Удаление выходных связей */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rRow.rn
                                          ,ncompany      => rRow.company
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                          ,nmode         => 0 );
      /* Установка статуса Не утверждён */
      p_payaccin_bset_status(ncompany   => rRow.company
                            ,nrn        => rRow.rn
                            ,nstatus    => 0
                            ,dwork_date => rRow.state_date);
      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

    /* 1 - Восстановить */
    elsif nMODE = 1 then

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
        /* Восстановление выходных связей */
        usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                            ,nrn           => usr_pkg_pub_const.rpayaccin.rn
                                            ,ncompany      => usr_pkg_pub_const.rpayaccin.company
                                            ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                            ,nmode         => 1 );
        /* Возвращение исходного статуса */
        p_payaccin_bset_status( ncompany   => usr_pkg_pub_const.rpayaccin.company
                               ,nrn        => usr_pkg_pub_const.rpayaccin.rn
                               ,nstatus    => usr_pkg_pub_const.rpayaccin.doc_state
                               ,dwork_date => usr_pkg_pub_const.rpayaccin.state_date );
        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Очистка переменных */
      usr_pkg_pub_const.arn_unit_list.delete;
      usr_pkg_pub_const.rpayaccin := null;
    else
      p_exception(0, 'Неверный режим работы.%s', sqlerrm ); 
    end if;

  end PAYACCIN_CLEAR_FOR_UPDATE;
  /*#########################################################################################################*/

  PROCEDURE PAYACCINBUFF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW       in payaccinbuff%rowtype  -- RN сформированного документа
  ) 
  is
  begin
    p_payaccinbuff_base_update(nrn           => rRow.rn
                              ,ncompany      => rRow.company
                              ,ncrn          => rRow.crn
                              ,ndoc_type     => rRow.doc_type
                              ,sdoc_pref     => rRow.doc_pref
                              ,sdoc_numb     => rRow.doc_numb
                              ,ddoc_date     => rRow.doc_date
                              ,sext_numb     => rRow.ext_numb
                              ,dreg_date     => rRow.reg_date
                              ,dpay_date     => rRow.pay_date
                              ,npayer        => rRow.jur_pers
                              ,npayeracc     => rRow.payeracc
                              ,nsupplier     => rRow.supplier
                              ,nsupplacc     => rRow.supplacc
                              ,nfaceacc      => rRow.faceacc
                              ,ngraphpoint   => rRow.graphpoint
                              ,ncurrency     => rRow.currency
                              ,ncurcours     => rRow.curcours
                              ,ncurbase      => rRow.curbase
                              ,nagnfi        => rRow.agnfi
                              ,nagnfo        => rRow.agnfo
                              ,nstore        => rRow.store
                              ,nvdoc_type    => rRow.vdoc_type
                              ,svdoc_num     => rRow.vdoc_num
                              ,dvdoc_date    => rRow.vdoc_date
                              ,npricewithtax => rRow.pricewithtax
                              ,nsumm         => rRow.summ
                              ,nsummwithnds  => rRow.summwithnds
                              ,nfa_currency  => null  /* не исправляется в процедуре */
                              ,nfa_basecours => rRow.fa_basecours
                              ,nfa_cours     => rRow.fa_cours
                              ,scomments     => rRow.comments
                              ,npaytype      => rRow.paytype
                              ,ndiscount     => rRow.discount);
  END PAYACCINBUFF_BASE_UPDATE;
  /*#########################################################################################################*/

  function PAYACCINSPEC_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return PAYACCINSPEC%ROWTYPE
  is
    rRow PAYACCINSPEC%ROWTYPE;
  begin
    begin
      select T.*
        into rRow
        from PAYACCINSPEC T
        where T.RN = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument =>  nRN, sunit_table => 'PAYACCINSPEC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPEC'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end PAYACCINSPEC_GET;
  /*#########################################################################################################*/
  
  PROCEDURE PAYACCINSPEC_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMEN             IN NUMBER DEFAULT NULL
  ,NNOMPACK           IN NUMBER DEFAULT NULL
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,SSERNUMB           IN VARCHAR2 DEFAULT NULL
  ,NCOUNTRY           IN NUMBER   DEFAULT NULL
  ,SGTD               IN VARCHAR2 DEFAULT NULL
  ,NSTORE             IN NUMBER   DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT PAYACCINSPEC%ROWTYPE 
  ) 
  is
    sMessage      pkg_std.tlstring; 
  BEGIN
    BEGIN
      SELECT *
        INTO rRow
        FROM PAYACCINSPEC T
       WHERE T.PRN                      = NPRN
         AND (NVL(T.NOMEN, 0)           = NVL(NNOMEN, 0) OR (NNOMEN IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMPACK, 0)         = NVL(NNOMPACK, 0) OR (NNOMPACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMMODIF, 0)        = NVL(NNOMMODIF, 0) OR (NNOMMODIF IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMMODIFPACK, 0)    = NVL(NNOMMODIFPACK, 0) OR (NNOMMODIFPACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.TAXGR, 0)           = NVL(NTAXGR, 0) OR (NTAXGR IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANT, 0)           = NVL(NQUANT, 0) OR (NQUANT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANTALT, 0)        = NVL(NQUANTALT, 0) OR (NQUANTALT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(round(T.PRICE, 0), 0) = NVL(round(NPRICE, 0), 0) OR (NPRICE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.SERNUMB, 0)         = NVL(SSERNUMB, 0) OR (SSERNUMB IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.COUNTRY, 0)         = NVL(NCOUNTRY, 0) OR (NCOUNTRY IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.GTD, 0)             = NVL(SGTD, 0) OR (SGTD IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.STORE, 0)           = NVL(NSTORE, 0) OR (NSTORE IS NULL AND NFLAG_OPTION = 1))
         AND ((T.BEGINDATE = DBEGINDATE OR (T.BEGINDATE IS NULL AND DBEGINDATE IS NULL)) OR (DBEGINDATE IS NULL AND NFLAG_OPTION = 1))
         AND ((T.ENDDATE   = DENDDATE   OR (T.ENDDATE   IS NULL AND DENDDATE   IS NULL)) OR (DENDDATE   IS NULL AND NFLAG_OPTION = 1))
         --and rownum = 1
         ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF NFLAGSMART = 0 /*and utilizer != 'KHOK'*/ THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'PaymentAccountsIn'
                                           ,nprn        => NPRN
                                           ,nnomen      => NNOMEN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,ssernumb    => SSERNUMB 
                                           ,ncountry    => NCOUNTRY 
                                           ,sgtd        => SGTD     
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Не найдена спецификация с параметрами: '||sMessage);
        END IF;
      WHEN TOO_MANY_ROWS THEN
        IF NTOO_MANY_ROWS = 0 AND NFLAGSMART = 0 THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'PaymentAccountsIn'
                                           ,nprn        => NPRN
                                           ,nnomen      => NNOMEN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,ssernumb    => SSERNUMB 
                                           ,ncountry    => NCOUNTRY 
                                           ,sgtd        => SGTD     
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Найдено больше одной спецификации с параметрами: '||sMessage);
        END IF;
      WHEN OTHERS THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'PaymentAccountsIn'
                                           ,nprn        => NPRN
                                           ,nnomen      => NNOMEN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,ssernumb    => SSERNUMB 
                                           ,ncountry    => NCOUNTRY 
                                           ,sgtd        => SGTD     
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Неопределённая ситуация при поиске спецификации с параметрами: '||sMessage);
    END;
  END PAYACCINSPEC_GET_BY_PARAMS;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow         payaccinspec%rowtype;
   rPayAccIn    payaccin%rowtype;
   rDicNomns    dicnomns%rowtype;
   nDPOS_Summ   pkg_std.tsumm; 
   bNeedUpdate  boolean := false;

   sVarchar     pkg_std.tstring;  
   nNumber      pkg_std.tnumber; 
   dDate        date;
  begin
    /* Считывание */
    rRow      := payaccinspec_get(nrn => nRN);
    rPayAccIn := payaccin_get(nrn => rRow.prn);

    /* ИСПРАВЛЕНИЯ */
    /* Если документ в каталоге Метрология, IT */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => '12043905;7609964') then

      /* не заполнено Оригинальное наименование */
      if rRow.original_name is null then
        /* считывание наименования номенклатуры в переменную спецификации */
        rDicNomns          := usr_pkg_dicnomns.dicnomns_get(nrn => rRow.nomen);
        rRow.original_name := rDicNomns.nomen_name;
        /* требуется исправление */
        bNeedUpdate := true;
      end if;

      /* Считываем максимальную сумму из связанных спецификаций заказа подразделений */
      begin
        select max(dpos.summ)
          into nDPOS_Summ
          from payaccinspclc      paisc
              ,payaccinspclc_ex   paisce
              ,departmentords     dpos
         where paisc.prn  = rRow.rn
           and paisce.prn = paisc.rn
           and dpos.rn    = paisce.departmentordsp;
      exception
        when no_data_found then
          pkg_msg.record_not_found(nflag_smart => 1, ndocument => rRow.rn, sunit_table => 'PAYACCINSPEC');
        when others then
          p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                     ,nrn, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPEC')));
      end;

      /* Если сумма не нулевая */
      if nvl(nDPOS_Summ, 0) != 0 then
        /* расчёт всех сумм */
        pkg_dictaxis_calc.p_calculate_base(nflag_smart => 0
                                          ,ncompany    => rRow.company
                                          ,ddate       => current_date
                                          ,nsumm_sign  => 1
                                          ,ninsumm     => nDPOS_Summ
                                          ,ntaxgr      => rRow.taxgr
                                          ,nquant      => rRow.quant
                                          ,nncp_sign   => 1);
        /* сохранение сумм в переменные */
        rRow.summ        := pkg_dictaxis_calc.f_get_value(0); /* Сумма без налогов (0) */
        rRow.summwithnds := pkg_dictaxis_calc.f_get_value(2); /* Сумма со всеми налогами (2) */
        rRow.summ_nds    := pkg_dictaxis_calc.f_get_value(8); /* НДС (8) */
        rRow.price       := rRow.summwithnds / rRow.quant;    /* Цена */
        /* требуется исправление */
        bNeedUpdate := true;
      end if;

      /* Исправление всех изменений в спецификации */
      if bNeedUpdate then
        payaccinspec_base_update(rrow => rRow);
      end if;

      /* Добавление свойств изменений в спецификации */
      pkg_docs_props_vals.modify(nproperty   => 7551156 /* Дней поставки */
                                ,sunitcode   => 'PaymentAccountsInSpecs'
                                ,ndocument   => rRow.rn
                                ,sstr_value  => sVarchar
                                ,nnum_value  => 7
                                ,ddate_value => dDate
                                ,nrn         => nNumber);
      pkg_docs_props_vals.modify(nproperty   => 20817235 /* Дата поставки */
                                ,sunitcode   => 'PaymentAccountsInSpecs'
                                ,ndocument   => rRow.rn
                                ,sstr_value  => sVarchar
                                ,nnum_value  => nNumber
                                ,ddate_value => rPayAccIn.doc_date + numtodsinterval(7, 'DAY') - 1
                                ,nrn         => nNumber);
    end if;    

    /* ПРОВЕРКИ */
    /* Базовая */
    payaccinspec_check_base(nrn => nRN, ncompany => nCOMPANY);
    
    /* Если счет создан в каталоге "СГИ", то автоматически добавляем калькуляцию */
    
   /* if rPayAccIn.Crn = 7551201 then \* Каталог  'Служба ГИ' *\
      usr_p_payaccinspclc_create(pin_doc => rRow.Rn , pin_com => nCOMPANY);
    end if;*/

  end PAYACCINSPEC_AINSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow         payaccinspec%rowtype;

   nNumber      pkg_std.tnumber;  
  begin
    /* Считывание в константу */
    rRow := payaccinspec_get( nrn => nRN ); 
    usr_pkg_pub_const.rpayaccinspec := rRow; 

    /* ПРОВЕРКИ */
    
  end PAYACCINSPEC_BUPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow         payaccinspec%rowtype;
  begin
    /* Считывание */
    /*rRow := payaccinspec_get(nrn => nRN);*/
   
    /* ПРОВЕРКИ */
    /* Базовая */
    payaccinspec_check_base( nrn => nRN, ncompany => nCOMPANY );
    
    /* Если исправляется модификация или количество */
    if rRow.nommodif != usr_pkg_pub_const.rpayaccinspec.nommodif 
    or rRow.quant    != usr_pkg_pub_const.rpayaccinspec.quant  then
      /* Выходные документы */
      payaccinspec_check_out_docs( rrow => rRow );
    end if;
    
    /* Заведем калькуляцию */
    usr_p_payaccinspclc_cre(nRN);
    
    

  end PAYACCINSPEC_AUPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow             payaccinspec%rowtype;
   rUDO_Prod_Cull   udo_prod_cull%rowtype;

   nNumber          pkg_std.tnumber;  
  begin
    /* Считывание в константу */
    rRow := payaccinspec_get(nrn => nRN); 

    /* ПРОВЕРКИ */
    /* Сертификация/входной контроль */
    payaccinspec_check_out_docs( rrow => rRow );

  end PAYACCINSPEC_BDELETE;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          payaccinspec%rowtype;
    rRow_Same     payaccinspec%rowtype;
    rPayAccIn     payaccin%rowtype;
    rNomen        dicnomns%rowtype;
    rNomModif     nommodif%rowtype;
    
    sVarchar      pkg_std.tstring; 
  begin
    /* Считывание */
    rRow      := payaccinspec_get(nrn => nRN);
    rPayAccIn := payaccin_get(nrn => rRow.prn);
    rNomen    := usr_pkg_dicnomns.dicnomns_get(nRN => rRow.nomen);
    if rRow.nommodif is not null then
      rNomModif := usr_pkg_dicnomns.nommodif_get(nrn => rRow.nommodif);
    else      
      p_exception(0, 'Не заполнено поле "Модификация". %s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn)); 
    end if;

    /* ИСПРАВЛЕНИЯ */
    /* Если свойство АвтРасчКальк = ДА */
/*    sVarchar := f_docs_props_get_str_value(nproperty => 91563402, sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn);
    if sVarchar = 'Да' or sVarchar is null then
      \* Если каталог Метрология и тип документа Товары *\
      if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => usr_pkg_pub_const.npai_cat_mtlg) 
      and payaccin_get_nomen_type(nrn => rRow.prn) = 1 then
        \* пересоздание калькуляций *\
        payaccin_recreate_paisc(nrn => rRow.prn);
      end if;
    end if;*/

    /* ПРОВЕРКИ */
    /* Наличие аналогичной спецификации */
    /* поиск по номенклатуре, модификации, цене, серии */
    payaccinspec_get_by_params( nflagsmart     => 1
                               ,ntoo_many_rows => 1
                               ,nprn           => rRow.prn
                               ,nnomen         => rRow.nomen
                               ,nnommodif      => rRow.nommodif
                               ,nprice         => rRow.price
                               ,ssernumb       => rRow.sernumb
                               ,rrow           => rRow_Same );
    /* если найдена, и RN отличен от текущей */
    if rRow_Same.rn is not null and rRow_Same.rn != rRow.rn then
      p_exception(0, 'В документе присутствует аналогичная спецификация. Номерклатура: <%s>, модификация: <"%s">, цена: <"%s">, серия: "%s". %s%s'
                 ,rNomen.nomen_code ||', '|| rNomen.nomen_name
                 ,rNomModif.Modif_code ||', '|| rNomModif.Modif_name
                 ,usr_f_n2ss( rRow.price )
                 ,rRow_Same.sernumb
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn)); 
    end if;                                               

    /* Если внешняя дата заголовка больше или равна 01.01.2026 */
    if cmp_dat_minmax( rPayAccIn.reg_date, to_date('01.01.2026', 'dd.mm.yyyy') ) >= 0 then
      /* Если налоговая группа НДС 20 */
      if rRow.taxgr = 502994 then
        /* Мнемокод налоговой группы */
        find_dictaxgr_rn( nflag_smart  => 0
                         ,nflag_option => 0
                         ,ncompany     => rRow.company
                         ,nrn          => rRow.taxgr
                         ,scode        => sVarchar );
        p_exception(0,'Запрещено использовать налоговую группу "%s", т.к. дата документа "%s" больше "%s". %s%s'
                   ,sVarchar
                   ,decode_date( rPayAccIn.reg_date )
                   ,decode_date( to_date('01.01.2026', 'dd.mm.yyyy') )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'PaymentAccountsInSpecs', ndocument => rRow.rn )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn ) ); 
      end if;
    end if;

    /* Расчёт сумм */
    pkg_dictaxis_calc.p_calculate_base(nflag_smart => 0
                                      ,ncompany    => rPayAccIn.company
                                      ,ddate       => rPayAccIn.doc_date
                                      ,nsumm_sign  => 1
                                      ,ninsumm     => rRow.summwithnds
                                      ,ntaxgr      => rRow.taxgr
                                      ,nquant      => 1
                                      ,nncp_sign   => 1);
    /* Проверка суммы без налогов */
    if trunc(rRow.summ, 0) != trunc(pkg_dictaxis_calc.f_get_value(0), 0) then
      p_exception(0, 'Поле "Сумма по документу. Без налогов" <%s> не соответствует сумме, расчитанной с учётом налоговой группы <%s>. %s%s'
                 ,rRow.summ
                 ,pkg_dictaxis_calc.f_get_value(0)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn)); 
    end if;

    /* По другим спецификациям с такой же номенклатурой, с незаполненной серией */
    for c in ( select t.rn, t.prn 
                 from payaccinspec t
                where t.rn      != rRow.rn
                  and t.prn      = rRow.prn
                  and t.nomen    = rRow.nomen
                  and t.nommodif = rRow.nommodif
                  and ( ( t.sernumb is null and rRow.sernumb is not null )
                        or
                        ( t.sernumb is not null and rRow.sernumb is null ) ) )
    loop
      p_exception(0, 'Не во всех спецификациях заполнена серия. Номенклатура: <%s>.%s'
                 ,rNomen.nomen_code ||', '|| rNomen.nomen_name ||', '|| rNomModif.modif_code ||', '|| rNomModif.modif_name
                 ,cr||cr||f_docdescrs_get_description('PaymentAccountsIn', c.prn) ); 
    end loop;                    

    /* Проверка связанных заказов подразделений на предмет обработки ЭРИ отделом Сертификации 
       KHOK 22/07/2024 */
    if rNomen.group_code = 13884309 then  /* это ЭРИ */
      sVarchar := null;
      for cer in (select dep.* 
                    from departmentord    dep,
                         payaccinspclc_ex ex,
                         payaccinspclc    clc
                   where clc.prn = rRow.Rn 
                     and ex.prn  = clc.rn
                     and ex.departmentord = dep.rn
                     and (udo_f_get_doc_prop_val_str(sproperty => 'Сертификация',
                                                     sunitcode => 'DepartmentsOrders',
                                                     ndocumet  => dep.rn) != 'Нет'
                          or
                          udo_f_get_doc_prop_val_str(sproperty => 'Сертификация',
                                                     sunitcode => 'DepartmentsOrders',
                                                     ndocumet  => dep.rn) is null)
      ) loop
        if cer.Cert_State != 2 then  /* Статус Сертификации не Обработано */
          sVarchar := sVarchar || trim(cer.Ord_Pref) || '-' || trim(cer.Ord_Numb) || '; ';
        end if;
      end loop;

      if sVarchar is not null --and utilizer != 'KHOK' 
      and cmp_vc2( usr_pkg_process.process_get, 'USR_P_PAIS_UPDATE' ) != 1 then
        p_exception(0,'Заказ подразделения ' || sVarchar || ' не обработан отделом Сертификации по номенклатуре ' || rNomen.Nomen_Name);
      end if;
    end if;

  end PAYACCINSPEC_CHECK_BASE;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_PAISC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in payaccinspec%rowtype
  ) 
  is
    nQuantPlanItog  pkg_std.tquant := 0; 
    nQuantFactItog  pkg_std.tquant := 0; 
    nExists         pkg_std.tnumber; 
  begin
    /* Итоговое количество по калькуляциям текущей спецификации */
    begin
      select nvl(sum(quant_plan), 0)
            ,nvl(sum(quant_Fact), 0)
            ,decode(count(*), 0, 0, 1)
        into nQuantPlanItog 
            ,nQuantFactItog 
            ,nExists
        from payaccinspclc
       where prn = rROW.RN;
    exception
      when no_data_found then
        nQuantPlanItog := 0;
        nQuantFactItog := 0;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске калькуляций. %s%s%s'
                   ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rROW.RN)
                   ,cr||f_docdescrs_get_description('PaymentAccountsIn', rROW.PRN)
                   ,cr||sqlerrm); 
    end;

    /* Если калькуляции существуют */
    if nExists = 1 then
      /* Если итоговое количество по калькуляциям не равно количеству спецификации */
      if cmp_num(nQuantPlanItog, rROW.QUANT) != 1 then
        p_exception(0, 'Сумма "Количество. План" в калькуляции <%s> не равна количеству в спецификации <%s>. %s%s'
                   ,nQuantPlanItog 
                   ,rROW.QUANT
                   ,cr||cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rROW.RN)
                   ,cr||cr||f_docdescrs_get_description('PaymentAccountsIn', rROW.PRN)); 
      end if;                 
    end if;                 

  end PAYACCINSPEC_CHECK_PAISC;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации заказа поставщикам
  */
  (
   rROW   in payaccinspec%rowtype
  ) 
  is
    nDeliveryOrd        pkg_std.tref; 
    rDeliveryOrdS       deliveryords%rowtype;
    nDLOS_QuantRemain   pkg_std.tquant; 
    rDicNomns           dicnomns%rowtype;
    
    nNumber             pkg_std.tnumber; 
  begin
    /* Считывание номенклатуры */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get(nrn => rRow.nomen);

    /* Если каталог "Метрология; IT; ОМТС" и тип номенклатуры НЕ Услуга */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rROW.CRN, shier_crn_list => '12043905;107388230;7594819')
    and rDicNomns.nomen_type != 2 then

      /* Связанный заказ */
      nDeliveryOrd := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                           ,sout_unitcode  => 'PaymentAccountsIn'
                                                           ,nout_document  => rROW.PRN
                                                           ,sin_unitcode   => 'DeliveryOrders');
      /* Если заказ найден*/
      if nDeliveryOrd is not null then                                                           
        /* аналогичная спецификация в заказе */
        usr_pkg_deliveryord.deliveryords_get_by_params(nprn         => nDeliveryOrd
                                                      ,nnom_modif   => rROW.nommodif
                                                      ,nnommod_pack => rROW.nommodifpack
                                                      ,rrow         => rDeliveryOrdS);
        /* количество остатка исполнения заказа */
        usr_pkg_deliveryord.deliveryords_get_pai_remain(rrow      => rDeliveryOrdS
                                                       ,ncalc_way => 0
                                                       ,nmod_sign => nNumber
                                                       ,nresult   => nDLOS_QuantRemain);
        /* если количество остатка исполнения заказа меньше нуля и каталог НЕ "ОМТС" */
        if nDLOS_QuantRemain < 0 
        and not usr_pkg_common.is_crn_in_hiercrn( nCRN => rROW.CRN, shier_crn_list => '7594819' ) then
          p_exception(0, 'Превышено количество в сформированных документах. Количество во входящем документе <%s>, превышение <%s>. %s%s'
                     ,rDeliveryOrdS.main_quant
                     ,nDLOS_QuantRemain
                     ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rRow.rn)
                     ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.prn)); 

        end if;
      else --if utilizer != 'KHOK' then
        p_exception(0, 'Документ не связан по входу с разделом <%s>. %s%s'
                   ,f_unitlist_getname(sunitcode => 'DeliveryOrders')
                   ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.prn)); 
      end if;
    end if;

  end PAYACCINSPEC_CHECK_INDOC;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_CHECK_OUT_DOCS
  /*
  Спецификация. Проверка выходных документов
  */
  (
   rROW             payaccinspec%rowtype
  ) 
  is
   nNumber          pkg_std.tnumber;  
  begin
    /* Получение списка Сертификация/Входной контроль, связанных по цепочке */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'PaymentAccountsIn'
                                              ,nin_document  => rROW.PRN
                                              ,sout_unitcode => 'UdoProdCull'
                                              ,srule_chains  => ';PaymentAccountsIn>IncomingInvoices>IncomingOrders>UdoProdCull;'
                                              ,nident        => rROW.RN );
    /* Если найдены Сертификация/Входной контроль, связанные по цепочке */
    if nNumber is not null then
      /* По спецификациям РН в подразделения */
      for c in ( select pcs.prn as pcs_prn
                   from selectlist          sl
                   join udo_prod_cull_sp    pcs 
                     on pcs.prn   = sl.document
                    and pcs.modif = rROW.NOMMODIF 
                   join udo_prod_cull_out   pco 
                     on pco.prn   = pcs.rn
                    and udo_pkg_prod_cull.cull_out_get_block_state( nrn => pco.rn, ddate => sysdate ) = 1
                  where sl.ident  = rROW.RN
                    --and utilizer not in ('STEPANOV_MV', 'KHOK')
              )
      loop
        /* Если состояние Сертификация/Входной контроль: Передано на склад, Проверено ВК, ожидание склада */
        p_exception(0, 'Исправление запрещено, т.к. документ "Сертификация/Входной контроль (результаты проверки)" отработан (заблокирован).%s%s%s'
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'UdoProdCull', ndocument => c.pcs_prn )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'PaymentAccountsInSpecs', ndocument => rROW.RN )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'PaymentAccountsIn', ndocument => rROW.PRN) );
      end loop;                  
      /* Очистка */
      p_selectlist_clear( nident => rROW.RN );

    end if;                                              

  end PAYACCINSPEC_CHECK_OUT_DOCS;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_INSERT
  /*
  Спецификация. Добавление
  */
  (
   rV_ROW       in v_payaccinspec%rowtype  -- RN сформированного документа
  ,nRN          out number
  ) 
  is
  begin
    p_payaccinspec_insert(nprn           => rV_ROW.NPRN
                         ,ncompany       => rV_ROW.nCOMPANY
                         ,snomen         => rV_ROW.SNOMEN
                         ,snommodif      => rV_ROW.SNOMMODIF
                         ,snompack       => rV_ROW.SNOMPACK
                         ,snommodifpack  => rV_ROW.SNOMMODIFPACK
                         ,sseria         => rV_ROW.SSERIA
                         ,scountry       => rV_ROW.SCOUNTRY
                         ,sgtd           => rV_ROW.SGTD
                         ,staxgr         => rV_ROW.STAXGR
                         ,nquant         => rV_ROW.NQUANT
                         ,nquantalt      => rV_ROW.NQUANTALT
                         ,dbegindate     => rV_ROW.DBEGINDATE
                         ,denddate       => rV_ROW.DENDDATE
                         ,nprice         => rV_ROW.NPRICE
                         ,npricemeas     => rV_ROW.NPRICEMEAS
                         ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                         ,nsumm          => rV_ROW.NSUMM
                         ,nsumm_nds      => rV_ROW.NSUMM_NDS
                         ,nautocalc_sign => rV_ROW.NAUTOCALC_SIGN
                         ,nplanquant     => rV_ROW.NPLANQUANT
                         ,nfactquant     => rV_ROW.NFACTQUANT
                         ,nplansumm      => rV_ROW.NPLANSUMM
                         ,nfactsumm      => rV_ROW.NFACTSUMM
                         ,sstore         => rV_ROW.SSTORE
                         ,scomments      => rV_ROW.SCOMMENTS
                         ,ndiscount      => rV_ROW.NDISCOUNT
                         ,soriginal_name => rV_ROW.SORIGINAL_NAME
                         ,nrn            => nRN);
  end PAYACCINSPEC_INSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_UPDATE
  /*
  Спецификация. Исправление
  */
  (
   rV_ROW           in v_payaccinspec%rowtype
  ,nFLAG_DEL_CALC   in number default 0     /* Удалять калькуляцию: 0 - нет, 1 - да */
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    nNumber   pkg_std.tnumber;  
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_payaccinspec_update(nrn            => rV_ROW.NRN
                           ,nprn           => rV_ROW.NPRN
                           ,ncompany       => rV_ROW.NCOMPANY
                           ,snomen         => rV_ROW.SNOMEN
                           ,snommodif      => rV_ROW.SNOMMODIF
                           ,snompack       => rV_ROW.SNOMPACK
                           ,snommodifpack  => rV_ROW.SNOMMODIFPACK
                           ,sseria         => rV_ROW.SSERIA
                           ,scountry       => rV_ROW.SCOUNTRY
                           ,sgtd           => rV_ROW.SGTD
                           ,staxgr         => rV_ROW.STAXGR
                           ,nquant         => rV_ROW.NQUANT
                           ,nquantalt      => rV_ROW.NQUANTALT
                           ,dbegindate     => rV_ROW.DBEGINDATE
                           ,denddate       => rV_ROW.DENDDATE
                           ,nprice         => rV_ROW.NPRICE
                           ,npricemeas     => rV_ROW.NPRICEMEAS
                           ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                           ,nsumm          => rV_ROW.NSUMM
                           ,nsumm_nds      => rV_ROW.NSUMM_NDS
                           ,nautocalc_sign => rV_ROW.NAUTOCALC_SIGN
                           ,nplanquant     => rV_ROW.NPLANQUANT
                           ,nfactquant     => rV_ROW.NFACTQUANT
                           ,nplansumm      => rV_ROW.NPLANSUMM
                           ,nfactsumm      => rV_ROW.NFACTSUMM
                           ,sstore         => rV_ROW.SSTORE
                           ,scomments      => rV_ROW.SCOMMENTS
                           ,ndiscount      => rV_ROW.NDISCOUNT
                           ,soriginal_name => rV_ROW.SORIGINAL_NAME
                           ,nflag_del_calc => nFLAG_DEL_CALC ); -- не удалять калькуляцию
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Исправление спецификации */
      payaccinspec_update( rv_row => rV_ROW, nflag_del_calc => nFLAG_DEL_CALC, nmode => 0 );

      /* Цикл по калькуляциям */
      for c in ( select t.*, count(*)over() as ncount from payaccinspclc t where t.prn = rV_ROW.NRN )
      loop
        /* Если калькуляция одна и задан параметр исправления калькуляций */
        if  c.ncount = 1 and nFLAG_DEL_CALC = 1 then
          /* исправляем колчиество в калькуляции */
          p_payaccinspclc_base_update( nrn           => c.rn
                                      ,ncompany      => c.company
                                      ,snumb         => c.numb
                                      ,ncost_article => c.cost_article
                                      ,ncost_place   => c.cost_place
                                      ,ncost_plan    => c.cost_plan
                                      ,ncost_fact    => c.cost_fact
                                      ,npriority     => c.priority
                                      ,nfaceaccount  => c.faceaccount
                                      ,ngraphpoint   => c.graphpoint
                                      ,nfinoper_type => c.finoper_type
                                      ,nquant_plan   => rV_ROW.NQUANT
                                      ,nquant_fact   => rV_ROW.NQUANT
                                      ,nsubdiv       => c.subdiv );
        end if;                                   
          
        /* Цикл по привязкам к заказам подразделений */
        for c1 in ( select t.*, count(*)over() as ncount from payaccinspclc_ex t where t.prn = c.rn )
        loop
          /* Если привязка одна и задан параметр исправления калькуляций */
          if c1.ncount = 1 and nFLAG_DEL_CALC = 1 then
            /* Удаляем существующую привязку */
            udo_pkg_payaccinspclc_ex.payaccinspclc_ex_bdel( nrn => c1.rn );
            /* Добавляем новую привязку */
            udo_pkg_payaccinspclc_ex.payaccinspclc_ex_ins(ncompany       => c.company
                                                         ,sfaceac        => null
                                                         ,nprn           => c.rn
                                                         ,ndepartmentord => c1.departmentord
                                                         ,nrn            => nNumber);
          end if;                                   
        end loop;                                                       
      end loop;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end PAYACCINSPEC_UPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW             in payaccinspec%rowtype
  ,nRN              out number
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nDUP_RN          in number default null  /* Для Режима 1. Размножаемая запись */
  ,nFLAG_DEL_CALC   in number default 0     /* Для Режима 1. Удалять калькуляцию: 0 - нет, 1 - да */
  ) 
  is
    rPayAccInSpClc    payaccinspclc%rowtype;
    nNumber           pkg_std.tnumber; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_payaccinspec_base_insert( nprn           => rROW.PRN
                                 ,ncompany       => rROW.COMPANY
                                 ,ncrn           => rROW.CRN
                                 ,nnomen         => rROW.NOMEN
                                 ,nnommodif      => rROW.NOMMODIF
                                 ,nnompack       => rROW.NOMPACK
                                 ,nnommodifpack  => rROW.NOMMODIFPACK
                                 ,ssernumb       => rROW.SERNUMB
                                 ,ncountry       => rROW.COUNTRY
                                 ,sgtd           => rROW.GTD
                                 ,ntaxgr         => rROW.TAXGR
                                 ,nquant         => rROW.QUANT
                                 ,nquantalt      => rROW.QUANTALT
                                 ,dbegindate     => rROW.BEGINDATE
                                 ,denddate       => rROW.ENDDATE
                                 ,nprice         => rROW.PRICE
                                 ,npricemeas     => rROW.PRICEMEAS
                                 ,nsummwithnds   => rROW.SUMMWITHNDS
                                 ,nsumm          => rROW.SUMM
                                 ,nsumm_nds      => rROW.SUMM_NDS
                                 ,nautocalc_sign => rROW.AUTOCALC_SIGN
                                 ,nplanquant     => rROW.PLANQUANT
                                 ,nfactquant     => rROW.FACTQUANT
                                 ,nplansumm      => rROW.PLANSUMM
                                 ,nfactsumm      => rROW.FACTSUMM
                                 ,nstore         => rROW.STORE
                                 ,scomments      => rROW.COMMENTS
                                 ,ndiscount      => rROW.DISCOUNT
                                 ,soriginal_name => rROW.ORIGINAL_NAME
                                 ,nmdmnomen      => rROW.MDMNOMEN
                                 ,nrn            => nRN );
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* Очистка перед исправлением */
      payaccin_clear_for_update( nrn => rROW.PRN, nmode => 0 );

      /* Выполнение штатной процедуры */
      payaccinspec_base_insert( rrow => rROW, nrn => nRN, nmode => 0 );

      /* Если задана размножаемая запись и не удалять калькуляции */
      if nDUP_RN is not null and nFLAG_DEL_CALC = 0 then
        /* По калькуляциям размножаемой спецификации */
        for c in ( select * from payaccinspclc where prn = nDUP_RN )
        loop
          /* Сохраняем запись в переменную */
          rPayAccInSpClc := c;
          /* Подменяем в переменной родительский документ */
          rPayAccInSpClc.prn := nRN;
          /* Добавляем калькуляцию к новой спецификации */
          payaccinspclc_base_insert( rrow => rPayAccInSpClc, nrn => rPayAccInSpClc.rn );

          /* По привязкам калькуляции к заказам подразделений размножаемой записи */
          for c1 in ( select * from payaccinspclc_ex where prn = c.rn )
          loop
            /* Добавляем привязку калькуляции к заказам подразделений к новой записи */
            udo_pkg_payaccinspclc_ex.payaccinspclc_ex_bins( nprn             => rPayAccInSpClc.rn
                                                           ,ndepartmentord   => c1.departmentord
                                                           ,ndepartmentordsp => c1.departmentordsp
                                                           ,nquant           => c1.quant
                                                           ,nstatus          => c1.status
                                                           ,sstate_auth      => c1.state_auth
                                                           ,state_date       => c1.state_date
                                                           ,nrn              => nNumber );
          end loop;
        end loop;
      end if;

      /* Восстановление после очистки */
      payaccin_clear_for_update( nrn => rROW.PRN, nmode => 1 );

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end PAYACCINSPEC_BASE_INSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in payaccinspec%rowtype
  ,nFLAG_DEL_CALC   in number default 0     /* Удалять калькуляцию: 0 - нет, 1 - да */
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    nNumber   pkg_std.tnumber;  
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_payaccinspec_base_update( nrn            => rROW.RN
                                 ,ncompany       => rROW.COMPANY
                                 ,nnomen         => rROW.NOMEN
                                 ,nnommodif      => rROW.NOMMODIF
                                 ,nnompack       => rROW.NOMPACK
                                 ,nnommodifpack  => rROW.NOMMODIFPACK
                                 ,ssernumb       => rROW.SERNUMB
                                 ,ncountry       => rROW.COUNTRY
                                 ,sgtd           => rROW.GTD
                                 ,ntaxgr         => rROW.TAXGR
                                 ,nquant         => rROW.QUANT
                                 ,nquantalt      => rROW.QUANTALT
                                 ,dbegindate     => rROW.BEGINDATE
                                 ,denddate       => rROW.ENDDATE
                                 ,nprice         => rROW.PRICE
                                 ,npricemeas     => rROW.PRICEMEAS
                                 ,nsummwithnds   => rROW.SUMMWITHNDS
                                 ,nsumm          => rROW.SUMM
                                 ,nsumm_nds      => rROW.SUMM_NDS
                                 ,nautocalc_sign => rROW.AUTOCALC_SIGN
                                 ,nplanquant     => rROW.PLANQUANT
                                 ,nfactquant     => rROW.FACTQUANT
                                 ,nplansumm      => rROW.PLANSUMM
                                 ,nfactsumm      => rROW.FACTSUMM
                                 ,nstore         => rROW.STORE
                                 ,scomments      => rROW.COMMENTS
                                 ,ndiscount      => rROW.DISCOUNT
                                 ,soriginal_name => rROW.ORIGINAL_NAME
                                 ,nmdmnomen      => rROW.MDMNOMEN
                                 ,nflag_del_calc => nFLAG_DEL_CALC );
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Цикл по калькуляциям */
      for c in ( select t.*, count(*)over() as ncount from payaccinspclc t where t.prn = rROW.RN )
      loop
        /* Если калькуляция одна и задан параметр исправления калькуляций */
        if  c.ncount = 1 and nFLAG_DEL_CALC = 1 then
          /* исправляем колчиество в калькуляции */
          p_payaccinspclc_base_update( nrn           => c.rn
                                      ,ncompany      => c.company
                                      ,snumb         => c.numb
                                      ,ncost_article => c.cost_article
                                      ,ncost_place   => c.cost_place
                                      ,ncost_plan    => c.cost_plan
                                      ,ncost_fact    => c.cost_fact
                                      ,npriority     => c.priority
                                      ,nfaceaccount  => c.faceaccount
                                      ,ngraphpoint   => c.graphpoint
                                      ,nfinoper_type => c.finoper_type
                                      ,nquant_plan   => rROW.QUANT
                                      ,nquant_fact   => rROW.QUANT
                                      ,nsubdiv       => c.subdiv );
        end if;                                   
          
        /* Цикл по привязкам к заказам подразделений */
        for c1 in ( select t.*, count(*)over() as ncount from payaccinspclc_ex t where t.prn = c.rn )
        loop
          /* Если привязка одна и задан параметр исправления калькуляций */
          if c1.ncount = 1 and nFLAG_DEL_CALC = 1 then
            /* Удаляем существующую привязку */
            udo_pkg_payaccinspclc_ex.payaccinspclc_ex_bdel( nrn => c1.rn );
            /* Добавляем новую привязку */
            udo_pkg_payaccinspclc_ex.payaccinspclc_ex_ins(ncompany       => c.company
                                                         ,sfaceac        => null
                                                         ,nprn           => c.rn
                                                         ,ndepartmentord => c1.departmentord
                                                         ,nrn            => nNumber);
          end if;                                   
        end loop;                                                       
      end loop;

      /* Исправление спецификации */
      payaccinspec_base_update( rrow => rROW, nflag_del_calc => nFLAG_DEL_CALC, nmode => 0 );

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end PAYACCINSPEC_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_GET_INDOC_QUANT
  /*
  Спецификация. Получить количество по приходным документам
  */
  (
   nRN          in number
  ,nQUANT       out number
  ,nQUANTALT    out number
  ) 
  is
    rRow          payaccinspec%rowtype;
    nNumber       pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := payaccinspec_get(nrn => nRN);
    
    /* Проверка */
    if rRow.nommodif is null then
      p_exception(0, 'В спецификации не задана модификация. Расчитать количество по приходным документам невозможно. %s%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rRow.rn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn)); 
    end if;
    
    /* Запись в selectlist RN связанных документов */
    /* Приходные накладные, созданные непосредственно из вх.счёта */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'PaymentAccountsIn'
                                              ,nin_document  => rRow.prn
                                              ,sout_unitcode => 'IncomingInvoices'
                                              ,srule_chains => ';PaymentAccountsIn>IncomingInvoices;'
                                              ,nident        => rRow.rn );
    /* Приходные ордера, созданные непосредственно из вх.счёта */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'PaymentAccountsIn'
                                              ,nin_document  => rRow.prn
                                              ,sout_unitcode => 'IncomingOrders'
                                              ,srule_chains => ';PaymentAccountsIn>IncomingOrders;'
                                              ,nident        => rRow.rn );
    /* РН на возврат поставщикам по всей цепочке связей */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'PaymentAccountsIn'
                                              ,nin_document  => rRow.prn
                                              ,sout_unitcode => 'ReturnInvoicesToSuppliers'
                                              ,srule_chains  => null
                                              ,nident        => rRow.rn );

    /* Подсчёт колчиества по связанным документам: приходные накладные + приходные ордера - РН поставщикам  */
    begin    
      select nvl(sum(a.nquant), 0), nvl(sum(a.nquantalt), 0)
        into nQUANT       , nQUANTALT
        from ( select t.quant as nquant, t.quantalt as nquantalt
                 from selectlist       sl
                     ,ininvoicesspecs  t
                     ,ininvoices       h
                where sl.ident    = rRow.rn
                  and t.prn       = sl.document
                  and sl.unitcode = 'IncomingInvoices' 
                  and t.modif     = rRow.nommodif
                  and h.rn        = t.prn
                  and h.status    = 2
               union all
               select t.factquant as nquant, t.factquantalt as nquantalt
                 from selectlist    sl
                     ,inorderspecs  t
                     ,inorders      h
                where sl.ident    = rRow.rn
                  and t.prn       = sl.document
                  and sl.unitcode = 'IncomingOrders' 
                  and t.nommodif  = rRow.nommodif
                  and h.rn        = t.prn
                  and h.docstatus = 2
               union all
               select (t.quant) * - 1 as nquant, (t.quantalt) * - 1 as nquantalt
                 from selectlist     sl
                     ,rinvtosupspecs t
                     ,rinvtosup      h
                where sl.ident    = rRow.rn
                  and t.prn       = sl.document
                  and sl.unitcode = 'ReturnInvoicesToSuppliers'
                  and t.nommodif  = rRow.nommodif
                  and h.rn        = t.prn
                  and h.status    = 1
                 ) a ;
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при подсчёте количества в приходных документах. %s%s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rRow.rn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rRow.prn)); 
    end;

  end PAYACCINSPEC_GET_INDOC_QUANT;
  /*#########################################################################################################*/
  
  procedure PAYACCINSPEC_GET_INDOC_REMAIN
  /*
  Спецификация. Получить остаток исполнения по приходным ордерам
  */
  (
   RROW         in payaccinspec%rowtype
  ,NCALC_WAY    in number -- возвращать оставшееся: 0 - количество, 1 - сумму
  ,NMOD_SIGN    out number -- спецификация включена во входящие счёта: 0 - нет, 1 - да
  ,NRESULT      out number -- результат: количество или сумма по которым не сформированы входящие счета на оплату
  ) 
  is
    nIdent         pkg_std.tref := gen_ident;
    rPayaccIn      payaccin%rowtype;
    nQuant         pkg_std.tquant;
    nACTM_Quant    pkg_std.tquant; -- согласованное кол-во в ОЕИ
    nACTSumm       pkg_std.tsumm;  -- сумма с налогом

    nNumber     pkg_std.tnumber;
  begin
    /* Заголовок */
    rPayaccIn := payaccin_get(nrn => RROW.PRN);
  
    /* использование пакета PKG_GOODSDOCS_SPEC для определения количества по позициям спецификации */
    /* инициализация пакета */
    pkg_goodsdocs_spec.init(ncompany => RROW.COMPANY, nident => nIdent);
    /* заполнение массива исходной спецификации из заказа */
    pkg_goodsdocs_spec.add_spec(nident         => nIdent
                               ,ndocument      => rPayaccIn.rn
                               ,sunitcode      => 'PaymentAccountsIn'
                               ,ndocument1     => RROW.RN
                               ,sunitcode1     => 'PaymentAccountsInSpecs'
                               ,nnomencls      => null 
                               ,numeas_main    => null 
                               ,nnomen         => RROW.NOMEN
                               ,nnomnpack      => RROW.NOMPACK
                               ,nnommodif      => RROW.NOMMODIF
                               ,nnomnmodifpack => RROW.NOMMODIFPACK
                               ,narticle       => null 
                               ,nstore         => RROW.STORE
                               ,ngoodsparty    => null 
                               ,ssernumb       => RROW.SERNUMB
                               ,ncountry       => RROW.COUNTRY
                               ,sgtd           => RROW.GTD
                               ,nquant         => RROW.QUANT
                               ,nsumm          => null 
                               ,ncurrency      => null 
                               ,ncurcours      => null 
                               ,ncurbase       => null);
    /* вычитание из исходной спецификации спецификаций всех порожденных из заказа документов */
    pkg_goodsdocs_spec.sub_cons_inc_spec(nident    => nIdent
                                        ,ndocument => rPayaccIn.rn
                                        ,sunitcode => 'PaymentAccountsIn'
                                        ,ncalc_way => 0); /* здесь пока рассчет только по кол-ву */
    /* вычисление количества */
    pkg_goodsdocs_spec.get_spec(nident    => nIdent
                               ,nquant    => nQuant
                               ,nsumm     => nACTSumm 
                               ,nmod_sign => nMOD_SIGN);
    /* Результат */
    case NCALC_WAY
      when 0 then
        nResult := nQuant;
      /*when 1 then
        nResult := nSUMTAX;*/
      else
        p_exception(0, 'Неверное <%s> значение параметра <nCALC_WAY>. %s%ss'
                   ,nCALC_WAY
                   ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rROW.RN)
                   ,cr||f_docdescrs_get_description('PaymentAccountsIn', rROW.PRN));
    end case;
  
  end PAYACCINSPEC_GET_INDOC_REMAIN;
  /*#########################################################################################################*/

  procedure PAYACCINSPEC_SPLIT
  /*
  Спецификация. Отделить от текущей записи с заданным количеством
  НЕ ДОРАБОТАНА!!!
  */
  (
   nRN                in number
  ,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
  ,nUSE_REST_QUANT    in number  /* Использовать недопоставленный остаток в качестве отделямого */
  ) 
  is
    rRow              payaccinspec%rowtype;
    rRowNew           payaccinspec%rowtype;
    nQuantNew2        pkg_std.tnumber := 0; 
    nQuant            pkg_std.tnumber := 0; 
    nQuantOld         pkg_std.tnumber := 0; 
    rInInvoicesSpC    ininvoicesspc%rowtype;
    rInInvoicesSpCNew ininvoicesspc%rowtype;
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Текущая запись */
    rRow    := payaccinspec_get( nrn => nRN );
    /* Новая запись  */
    rRowNew := rRow;

    /* Если использовать недопоставленный остаток */
    if cmp_num( nUSE_REST_QUANT, 1 ) = 1 then
      nQuantNew2 := rRow.quant - rRow.factquant;
      /* Иначе используем значение входного параметра */
    else 
      nQuantNew2 := nQUANT_NEW;
    end if;

    /* Проверки */
    if cmp_num( nQuantNew2, 0 ) = 1 then
      p_exception(0, 'Отделяемое количество <%s> не задано или равно нулю.%s%s'
                 ,nQuantNew2
                 ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.prn)); 
    elsif rRow.quant < nQuantNew2 then
      p_exception(0, 'Отделяемое количество <%s> больше исходного <%s>. %s%s'
                 ,nQuantNew2
                 ,rRow.quant
                 ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.prn)); 
    elsif rRow.quant - rRow.factquant < nQuantNew2 then
      p_exception(0, 'Отделяемое количество <%s> больше чем Непоставленное количество <%s>. %s%s'
                 ,nQuantNew2
                 ,rRow.quant - rRow.factquant
                 ,cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('PaymentAccountsIn', rRow.prn)); 
    end if;

    /* Количество до отделения */
    nQuant := rRow.quant; 

    /* Количество после отделения в старой спецификации */
    nQuantOld := nQuant - nQuantNew2;

    /* Заполнение переменных для текущей записи */
    rRow.summ         := rRow.summ        / nQuant * nQuantOld;
    rRow.summwithnds  := rRow.summwithnds / nQuant * nQuantOld;
    rRow.summ_nds     := rRow.summ_nds    / nQuant * nQuantOld;
    rRow.quant        := nQuantOld;
    /*rRow.factquant    := rRow.factquant   / nQuant * nQuantOld;
    rRow.factsumm     := rRow.factsumm    / nQuant * nQuantOld;*/
    rRow.sernumb      := rRow.rn;

    /* Заполнение переменных для новой записи */
    rRowNew.summ        := rRowNew.summ        / nQuant * nQuantNew2;
    rRowNew.summwithnds := rRowNew.summwithnds / nQuant * nQuantNew2;
    rRowNew.summ_nds    := rRowNew.summ_nds    / nQuant * nQuantNew2;
    rRowNew.quant       := nQuantNew2;
    rRowNew.factquant   := null;
    rRowNew.factsumm    := null;
    rRowNew.sernumb     := rRowNew.rn + 1;

    /* Проверка перед исправлением */
    /*payaccinspec_bupdate(nrn => rRow.rn, ncompany => rRow.company);*/
    /* Исправление текущей записи */
    payaccinspec_base_update( rrow => rRow, nmode => 0 );
    /* Проверка после исправления */
    /*payaccinspec_aupdate(nrn => rRow.rn, ncompany => rRow.company);*/

    /* Добавление новой записи */
    payaccinspec_base_insert( rrow => rRowNew, nrn => rRowNew.rn, nmode => 1, ndup_rn => rRow.rn );

    /* Проверка после добавления */
    payaccinspec_ainsert(nrn => rRowNew.rn, ncompany => rRowNew.company);

  end PAYACCINSPEC_SPLIT;
  /*#########################################################################################################*/  

  function PAYACCINSPCLC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return payaccinspclc%rowtype
  is
    rRow payaccinspclc%rowtype;
  begin
    begin
      select * into rRow from payaccinspclc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PAYACCINSPCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPCLC'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end PAYACCINSPCLC_GET;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_AINSERT
  /*
  Спецификация (калькуляция). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    payaccinspclc_check_base(nrn => nRN, ncompany => nCOMPANY);
    /* Добавление, исправление, удаление */
    payaccinspclc_check_iud(nrn => nRN);
  
  end PAYACCINSPCLC_AINSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BUPDATE
  /*
  Спецификация (калькуляция). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание */
    usr_pkg_pub_const.rpayaccinspclc := payaccinspclc_get(nrn => nRN); 
    
  end PAYACCINSPCLC_BUPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payaccinspclc%rowtype;
    rPayAccInSpec   payaccinspec%rowtype;
  begin
    /* Считывание */
    rrow          := payaccinspclc_get(nrn => nrn);
    rpayaccinspec := payaccinspec_get(nrn => rrow.prn);
  
    /* ПРОВЕРКИ */
    /* Добавление, исправление, удаление */
    if rrow.numb != usr_pkg_pub_const.rpayaccinspclc.numb
    or nvl(rrow.cost_place, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.cost_place, 0)
    or nvl(rrow.cost_plan, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.cost_plan, 0)
    or nvl(rrow.cost_fact, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.cost_fact, 0)
    or nvl(rrow.priority, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.priority, 0)
    or nvl(rRow.cost_article, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.cost_article, 0)
    or nvl(rrow.faceaccount, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.faceaccount, 0)
    or nvl(rrow.graphpoint, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.graphpoint, 0)
    or nvl(rrow.finoper_type, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.finoper_type, 0)
    or nvl(rrow.quant_plan, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.quant_plan, 0)
    or nvl(rrow.quant_fact, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.quant_fact, 0)
    or nvl(rrow.subdiv, 0) != nvl(usr_pkg_pub_const.rpayaccinspclc.subdiv, 0) then
      payaccinspclc_check_iud(nrn => nrn);
    end if;
  
    /* Базовая */
    payaccinspclc_check_base(nrn => nrn, ncompany => ncompany);
  
  end payaccinspclc_aupdate;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BDELETE
  /*
  Спецификация (калькуляция). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Добавление, исправление, удаление */
    payaccinspclc_check_iud(nrn => nRN);

  end PAYACCINSPCLC_BDELETE;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payaccinspclc%rowtype;
    rPayAccInSpec   payaccinspec%rowtype;
    rPayAccIn       payaccin%rowtype;
    rFaceAcc        faceacc%rowtype;
    rFpdArtcl       fpdartcl%rowtype;
    rPAISCFaceAcc   faceacc%rowtype;
    rPAISCProject   project%rowtype;
    rFinFlowType    finflowtype%rowtype;
  begin
    /* Считывание */
    rRow          := payaccinspclc_get(nrn => nRN);
    rPayAccInSpec := payaccinspec_get(nrn => rRow.prn);
    rPayAccIn     := payaccin_get(nrn => rPayAccInSpec.prn);
    rFaceAcc      := usr_pkg_faceacc.faceacc_get(nrn => rPayAccIn.faceacc);
    
    /* Если лицевой счёт задан в калькуляции */
    if rRow.faceaccount is not null then
      rPAISCFaceAcc     := usr_pkg_faceacc.faceacc_get(nrn => rRow.Faceaccount);
      /* Поиск проекта по лицевому счёту */
      rPAISCProject.rn  := usr_pkg_project.project_get_rn_by_faceacc( nflagsmart => 1, nfaceacc => rPAISCFaceAcc.rn );
      /* Считывание проекта */
      if rPAISCProject.rn is not null then
        rPAISCProject     := usr_pkg_project.project_get( nrn => rPAISCProject.rn );
      end if;
    end if;

    /* ПРОВЕРКИ */
    
     --- Проверка статьи затрат и каталога
    USR_P_payaccinspclc_CNTR_1(nRN);
    
    /* Количество. План */
    if nvl(rRow.quant_plan, 0) = 0 /*and utilizer != 'KHOK'*/ then
      p_exception(0, 'Поле "Количество. План" не заполнено в калькуляции. %s%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn)); 
    end if;
  
    /* Если ЗАПОЛНЕНА Статья затрат в калькуляции */
    if rRow.cost_article is not null then
      /* Считывание статьи затрат */
      rFpdArtcl    := udo_pkg_get.row_fpdartcl(nrn => rRow.cost_article, nsmart => 0);
    /* Если НЕ ЗАПОЛНЕНА Статья затрат в калькуляции */
    else
      /* Если ЗАПОЛНЕНА Статья затрат в лицевом счёте поставщика */
      if rFaceAcc.ieelement is not null then
        /* Считывание статьт затрат */
        rFpdArtcl := udo_pkg_get.row_fpdartcl(nrn => rFaceAcc.ieelement, nsmart => 0);
      end if;
    end if;
    
    /* Если статья затрат ЗАПОЛНЕНА в калькуляции или лицевом счёте поставщика */
    if rFpdArtcl.rn is not null then
      /* Считывание вида движения по элементу */
      if rFpdArtcl.def_flow is not null then
        rFinFlowType := udo_pkg_finplan_utils.finflowtype_get( nrn => rFpdArtcl.def_flow, nsmart => 0 );
      else
        p_exception(0, 'В статье "%s" не заполнено поле "Типовой вид движения". Обратитесь в ПЭО, Группа финансового планирования и бюджетирования.'
                   ,rFpdArtcl.code ); 
      end if;
      /* Вид движения по элементу в статье затрат не равен "Расход" */
      if rFinFlowType.type != 2 then      
        p_exception(0, 'В калькуляции, в поле "Статья затрат" указана статья <%s> с видом движения <%s>. '||
                       'Запрещено использовать статьи с таким видом движения.%s%s%s'
                   ,rFpdArtcl.code
                   ,case rFinFlowType.type 
                      when 0 then 'Остаток' 
                      when 1 then 'Приход' 
                      when 2 then 'Расход' 
                    else 'Не определён' end
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
      end if;                   
      /* Статья затрат НЕ В КАТАЛОГЕ "Статьи БДДС" */
      if not usr_pkg_common.is_crn_in_hiercrn(nCRN => rFpdArtcl.crn, shier_crn_list => 6171728) then      
        p_exception(0, 'В %s, в поле "Статья затрат" указана статья <%s> из каталога <%s>. Статьи из этого каталога запрещено использовать в данном разделе.%s%s%s'
                   ,case when rRow.cost_article is not null then 'калькуляции' else 'лицевом счёте поставщика' end
                   ,rFpdArtcl.code
                   ,usr_pkg_common.get_cat_higher_str(nRN => rFpdArtcl.crn, nsigns => 1)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
      end if;                   
      /* Статья затрат В КАТАЛОГЕ "IV_Тематические" или Статья затрат: Продажа товаров вСНГ, Экспорт услуг за руб, Экспорт товаров 
      и в калькуляции не заполнено Лицевой счёт */
      if ( usr_pkg_common.is_crn_in_hiercrn(nCRN => rFpdArtcl.crn, shier_crn_list => 6252667) 
         or rFpdArtcl.rn in (6172145, 6172148, 6172139) )
      and rPAISCFaceAcc.rn is null then
        p_exception(0, 'В %s, в поле "Статья затрат" указана статья <%s> из каталога <%s>, при этом в калькуляции не заполнено поле "Лицевой счёт (заказ)".%s%s%s'
                   ,case when rRow.cost_article is not null then 'калькуляции' else 'лицевом счёте поставщика' end
                   ,rFpdArtcl.code
                   ,usr_pkg_common.get_cat_higher_str(nRN => rFpdArtcl.crn, nsigns => 1)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
      end if;                   
      /* Лицевой счёт калькуляции заканчивается на "/77" и статья затрат НЕ "Покупка КИП", "ПриобрПрОборуд" */
      if ( nvl( rPAISCFaceAcc.Numb, 'null' ) like '%/77' or nvl( rPAISCFaceAcc.Numb, 'null' ) like '%/77-1' or nvl( rPAISCFaceAcc.Numb, 'null' ) like '%/77-2' )
      and rFpdArtcl.rn not in ( 6233008, 82333284 ) then
        p_exception(0, 'В %s, в поле "Статья затрат" указана статья <%s>, которую запрещено использовать для "Лицевого счёта (заказа)" <%s>.%s%s%s'
                   ,case when rRow.cost_article is not null then 'калькуляции' else 'лицевом счёте поставщика' end
                   ,rFpdArtcl.code
                   ,rPAISCFaceAcc.Numb
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
      end if; 
      /*
      ПО "Парус" Изменение. Быкова Ксения Валерьевна № 19428 от 08.07.2025 16:17
      Если статья затрат в лицевом счёте поставщика или в калькуляции заканчивается на «%_Б», то
      - если лицевой счёт в калькуляции не задан, выдаётся сообщение: Необходимо заполнить Лицевой счёт (заказ) в калькуляции, 
        т.к. статья затрат счёта на оплату "%s" является тематической или выбрать не тематическую статью затрат
      - если лицевой счёт в калькуляции не имеет связи с проектом или связан с проектом "22 (Накладные расходы)", выдаётся сообщение: Лицевой счёт (заказ) "%s" 
        в калькуляции не связан с проектом, или тип проекта "Накладные расходы". Выберите другой лицевой счёт (заказ)
      - если номер лицевого счёта в калькуляции начинается НЕ с: 1, 2, 8, 9, выдаётся сообщение: Лицевой счёт (заказ) "%s" 
        в калькуляции должен начинаться с чисел: 1, 2, 8, 9, т.к. статья затрат счёта на оплату "%s" является тематической. 
        Выберите корректный лицевой счёт или измените статью затрат на верную.
      - если номер лицевого счёта в калькуляции заканчивается на "/77" или "\77", выдаётся сообщение: Лицевой счёт (заказ) "%s" 
        запрещено использовать для статьи, выбранной в калькуляции т.к. статья затрат счёта на оплату "%s" является тематической. 
        Выберите другой лицевой счёт(заказ) или измените статью затрат.      
      */
      if rFpdArtcl.Code like '%_Б' then
        /* в калькуляции не задан лицевой счёт */
        if rPAISCFaceAcc.Numb is null then
          p_exception(0, 'Необходимо заполнить Лицевой счёт (заказ) в калькуляции, т.к. статья затрат счёта на оплату "%s" является тематической или выбрать 
                          нетематическую статью затрат.%s%s%s'
                     ,rFpdArtcl.Code
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
        else
          /* лицевой счёт калькуляции НЕ связан с проектом или у тип проекта "22 (Накладные расходы)" */
          if rPAISCProject.prjtype is null or rPAISCProject.prjtype = 175087845 then
            p_exception(0, 'Лицевой счёт (заказ) "%s" в калькуляции не связан с проектом, или тип проекта "Накладные расходы". 
                            Выберите другой лицевой счёт (заказ).%s%s%s'
                       ,rPAISCFaceAcc.Numb
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
          end if;
          /* лицевой счёт калькуляции начинается НЕ с: 1, 2, 8, 9 */
          if substr( rPAISCFaceAcc.Numb, 0, 1) not in ('1', '2', '8', '9') then
            p_exception(0, 'Лицевой счёт (заказ) "%s" в калькуляции должен начинаться с чисел: 1, 2, 8, 9, т.к. статья затрат счёта на оплату "%s" является тематической. 
                            Выберите корректный лицевой счёт или измените статью затрат на верную.%s%s%s'
                       ,rPAISCFaceAcc.Numb
                       ,rFpdArtcl.Code
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
          end if;
          /* лицевой счёт калькуляции начинается НЕ с: 1, 2, 8, 9 */
          if strextr( rPAISCFaceAcc.Numb, '/') = '/77'   or strextr( rPAISCFaceAcc.Numb, '\') = '\77' 
          or strextr( rPAISCFaceAcc.Numb, '/') = '/77-1' or strextr( rPAISCFaceAcc.Numb, '\') = '\77-1'
          or strextr( rPAISCFaceAcc.Numb, '/') = '/77-2' or strextr( rPAISCFaceAcc.Numb, '\') = '\77-2' then
            p_exception(0, 'Лицевой счёт (заказ) "%s" запрещено использовать для статьи, выбранной в калькуляции т.к. статья затрат счёта на оплату "%s" является тематической. 
                            Выберите другой лицевой счёт(заказ) или измените статью затрат.%s%s%s'
                       ,rPAISCFaceAcc.Numb
                       ,rFpdArtcl.Code
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                       ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
          end if;
        end if;
      end if;

      /*      
      \* Е.Столярский по просьбе Быковой К. Проверка ЛС по маске и тематических статей --- 04/07/2025  *\                  
      if (nvl( rPAISCFaceAcc.Numb, 'null' ) like '1____/%' or
          nvl( rPAISCFaceAcc.Numb, 'null' ) like '2____/%' or
          nvl( rPAISCFaceAcc.Numb, 'null' ) like '8____/%' or
          nvl( rPAISCFaceAcc.Numb, 'null' ) like '9____/%' ) then
          if nvl(rFpdArtcl.Code, 'null' ) not like '%_Б' then
             P_Exception(0,'Для тематического ЛС <%s> должна быть тематическая статья формата *_Б. Текущая статья <%s>. %s%s%s'
                        ,rPAISCFaceAcc.Numb
                        ,rFpdArtcl.Code
                        ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                        ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                        ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
          end if;
      else
         if  rFpdArtcl.Code like '%_Б' 
         and nvl( rPAISCFaceAcc.Numb, 'null' ) not in ('20220000', '10220000') then   
           P_Exception(0,'Для тематической статьи <%s> должен быть тематический ЛС. %s%s%s'
                      , rFpdArtcl.Code
                      ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                      ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                      ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
         end if;
      end if;
      */
    /* Если статья затрат НЕ ЗАПОЛНЕНА */
    else
      p_exception(0, 'В калькуляции, не указана "Статья затрат", при этом в лицевом счёте поставщика <%s> она также не указана.%s%s%s'
                 ,rFaceAcc.numb
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpec.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn) ); 
    end if;                 
    
  end PAYACCINSPCLC_CHECK_BASE;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  ) 
  is
    nHead           pkg_std.tref; 
    nSpec           pkg_std.tref; 
    nHeadState      pkg_std.tnumber; 
    nOutDocExists   pkg_std.tnumber := 0; 
    nFac            payaccinspclc.faceaccount%type;   
  begin
    /* Считывание RN заголовка, спецификации, статуса документа  */
    begin
      select h.rn , h.doc_state, s.rn , c.faceaccount
        into nHead, nHeadState , nSpec, nFac
        from payaccinspclc c
            ,payaccinspec  s
            ,payaccin      h
       where c.rn = nRN
         and s.rn = c.prn
         and h.rn = s.prn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PAYACCINSPCLC');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'PAYACCINSPCLC'))
                   ,cr||sqlerrm);
    end;

    /* Если сформированы приходные накладные, то лицевой счет (заказ) (ссылка  на Проект) править нельзя, т.к. он уже ушел в товарный запас */
    if  f_doclinks_link_out(sin_unitcode => 'PaymentAccountsIn', nin_document => nHead, sout_unitcode => 'IncomingInvoices') is not null      
    and cmp_num(usr_pkg_pub_const.rpayaccinspclc.FACEACCOUNT, nFac) = 0
    and not usr_pkg_common.is_lists_intersect(slist1 => 'PAYACCINSPCLC_CHECK_IUD.1', slist2 => usr_pkg_pub_const.sexceptionlist) 
    then 
      p_exception(1, 'Запрещено изменение "Лицевого счета (заказ)" калькуляций документа, т.к. по документу сформированы приходные накладные. %s%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => nRN)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => nSpec)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => nHead) );
    end if;

    /* Очистка списка исключений */
    usr_pkg_pub_const.sexceptionlist := null;
    
  end PAYACCINSPCLC_CHECK_IUD;
 /*#########################################################################################################*/

  procedure PAYACCINSPCLC_CHECK_PAISCE
  /*
  Калькуляция. Проверка привязок заказов подразделений
  */
  (
   rROW       in payaccinspclc%rowtype
  ) 
  is
    nQuantItog  pkg_std.tquant := 0; 
    nExists     pkg_std.tnumber; 
  begin
    /* Итоговое количество по привязкам к заказам подразделений текущей калькуляции */
    begin
      select nvl(sum(quant), 0), decode(count(*), 0, 0, 1)
        into nQuantItog        , nExists
        from payaccinspclc_ex
       where prn = rROW.RN;
    exception
      when no_data_found then
        nQuantItog := 0;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске привязки калькуляции к заказам подразделений.%s%s%s%s'
                   ,cr||cr||f_docdescrs_get_description('PaymentAccountsInSpecsCalcs', rROW.RN)
                   ,cr||cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rROW.PRN)
                   ,cr||cr||sqlerrm); 
    end;

    /* Если привязки к заказами подразделений существуют */
    if nExists = 1 then
      /* Количество по привязкам больше количества калькуляции */
      if nQuantItog > rROW.QUANT_PLAN /*and utilizer != 'KHOK'*/ then
        p_exception(0, 'Сумма по полю "Количество по заказу" <%s> в привязке к заказам подразделений больше поля "Количество. План" в калькуляции <%s>. %s%s%s'
                   ,nQuantItog 
                   ,rROW.QUANT_PLAN
                   ,cr||cr||f_docdescrs_get_description('PaymentAccountsInSpecsCalcs', rROW.RN)
                   ,cr||cr||f_docdescrs_get_description('PaymentAccountsInSpecs', rROW.PRN) ); 
      end if;                 
    end if;

  end PAYACCINSPCLC_CHECK_PAISCE;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_INSERT
  /*
  Спецификация (калькуляция). Добавление
  */
  (
   rV_ROW   in v_payaccinspclc%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_payaccinspclc_insert(ncompany      => rV_ROW.NCOMPANY
                          ,nprn          => rV_ROW.NPRN
                          ,snumb         => rV_ROW.SNUMB
                          ,scost_article => rV_ROW.SCOST_ARTICLE
                          ,scost_place   => rV_ROW.SCOST_PLACE
                          ,ncost_plan    => rV_ROW.NCOST_PLAN
                          ,ncost_fact    => rV_ROW.NCOST_FACT
                          ,npriority     => rV_ROW.NPRIORITY
                          ,sfaceaccount  => rV_ROW.SFACEACCOUNT
                          ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                          ,sfinoper_type => rV_ROW.SFINOPER_TYPE
                          ,nquant_plan   => rV_ROW.NQUANT_PLAN
                          ,nquant_fact   => rV_ROW.NQUANT_FACT
                          ,ssubdiv       => rV_ROW.SSUBDIV
                          ,nrn           => NRN);
  end PAYACCINSPCLC_INSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_UPDATE
  /*
  Спецификация (калькуляция). Исправление
  */
  (
   rV_ROW   in v_payaccinspclc%rowtype
  ) 
  is
  begin
    UDO_p_payaccinspclc_update(nrn           => rV_ROW.NRN
                          ,ncompany      => rV_ROW.NCOMPANY
                          ,snumb         => rV_ROW.SNUMB
                          ,scost_article => rV_ROW.SCOST_ARTICLE
                          ,scost_place   => rV_ROW.SCOST_PLACE
                          ,ncost_plan    => rV_ROW.NCOST_PLAN
                          ,ncost_fact    => rV_ROW.NCOST_FACT
                          ,npriority     => rV_ROW.NPRIORITY
                          ,sfaceaccount  => rV_ROW.SFACEACCOUNT
                          ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                          ,sfinoper_type => rV_ROW.SFINOPER_TYPE
                          ,nquant_plan   => rV_ROW.NQUANT_PLAN
                          ,nquant_fact   => rV_ROW.NQUANT_FACT
                          ,ssubdiv       => rV_ROW.SSUBDIV);
  end PAYACCINSPCLC_UPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое
  */
  (
   rROW   in payaccinspclc%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_payaccinspclc_base_insert(ncompany      => rROW.COMPANY
                               ,nprn          => rROW.PRN
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,ncost_plan    => rROW.COST_PLAN
                               ,ncost_fact    => rROW.COST_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nquant_plan   => rROW.QUANT_PLAN
                               ,nquant_fact   => rROW.QUANT_FACT
                               ,nsubdiv       => rROW.subdiv
                               ,nrn           => nRN);
  end PAYACCINSPCLC_BASE_INSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое
  */
  (
   rROW   in payaccinspclc%rowtype
  ) 
  is
  begin
    p_payaccinspclc_base_update(nrn           => rROW.RN
                               ,ncompany      => rROW.COMPANY
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,ncost_plan    => rROW.COST_PLAN
                               ,ncost_fact    => rROW.COST_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nquant_plan   => rROW.QUANT_PLAN
                               ,nquant_fact   => rROW.QUANT_FACT
                               ,nsubdiv       => rROW.SUBDIV);
  end PAYACCINSPCLC_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_GET_IIVSC_QUANT
  /*
  Спецификация (калькуляция). Получить количество по калькуляциям приходных накладных
  */
  (
   nRN          in number
  ,nQUANT_PLAN  out number
  ,nQUANT_FACT  out number
  ) 
  is
  begin
    begin
      select nvl(sum(a.quant_plan), 0), nvl(sum(a.quant_fact), 0)
        into nQUANT_PLAN              , nQUANT_FACT
        from (
              select sum(indsc.quant_plan) as quant_plan, sum(indsc.quant_fact) as quant_fact
                from payaccinspclc   paisc
                    ,payaccinspec    pais
                    ,doclinks        dl
                    ,ininvoicesspecs inds
                    ,ininvoicesspc   indsc
               where paisc.rn          = nRN
                 and pais.rn           = paisc.prn
                 and dl.in_document    = pais.prn
                 and dl.out_unitcode   = 'IncomingInvoices'
                 and dl.out_document   = inds.prn
                 and inds.modif        = pais.nommodif
                 and indsc.prn         = inds.rn
                 and indsc.faceaccount = paisc.faceaccount
                 and cmp_num(indsc.faceaccount, paisc.faceaccount) = 1 
                 /*and cmp_num(indsc.cost_article, paisc.cost_article) = 1*/ 
              union
              select sum(indsc.quant_plan) as quant_plan, sum(indsc.quant_fact) as quant_fact
                from payaccinspclc   paisc
                    ,payaccinspec    pais
                    ,doclinks        dl
                    ,inorderspecs    inds
                    ,inorderspecsclc indsc
               where paisc.rn          = nRN
                 and pais.rn           = paisc.prn
                 and dl.in_document    = pais.prn
                 and dl.out_unitcode   = 'IncomingOrders'
                 and dl.out_document   = inds.prn
                 and inds.nommodif     = pais.nommodif
                 and indsc.prn         = inds.rn
                 and cmp_num(indsc.faceaccount, paisc.faceaccount) = 1 
                 /*and cmp_num(indsc.cost_article, paisc.cost_article) = 1 */
             ) a
             ;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при подсчёте количества по калькуляциям приходных документов. %s', nRN); 
    end;
  end PAYACCINSPCLC_GET_IIVSC_QUANT;
  /*#########################################################################################################*/

  function PAYACCINSPCLC_EX_GET
  /*
  Спецификация (спецификация, калькуляция, заказ подразделений). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return payaccinspclc_ex%rowtype
  is
    rRow payaccinspclc_ex%rowtype;
  begin
    begin
      select * into rRow from payaccinspclc_ex where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument =>  nRN, sunit_table => 'PAYACCINSPCLC_EX');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPCLC_EX'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end PAYACCINSPCLC_EX_GET;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_EX_AINSERT
  /*
  Спецификация (спецификация, калькуляция, заказ подразделений). Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    payaccinspclc_ex_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PAYACCINSPCLC_EX_AINSERT;
  /*#########################################################################################################*/

  procedure PAYACCINSPCLC_EX_CHECK_BASE
  /*
  Спецификация (спецификация, калькуляция, заказ подразделений). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              payaccinspclc_ex%rowtype;
    rPayAccInSpClc    payaccinspclc%rowtype;
    rDepartmentOrd    departmentord%rowtype;
  begin
    /* Считывание */
    rRow            := payaccinspclc_ex_get(nrn => nRN);
    rPayAccInSpClc  := payaccinspclc_get(nrn => rRow.prn);
    rDepartmentOrd  := usr_pkg_departmentord.departmentord_get(nrn => rRow.departmentord);

    /* ПРОВЕРКИ */
    /* По другим привязкам заказов подразделений текущей калькуляции */
    for c in ( select * 
                 from payaccinspclc_ex 
                where prn = rRow.prn 
                  and rn != rRow.rn )
    loop
      /* если есть привязка к той же спецификации заказа, что и у текущей привязки */
      if cmp_num(c.departmentordsp, rRow.departmentordsp) = 1 then
        p_exception(0, 'Дублирование привязки заказа подразделения к калькуляции.%s%s%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => c.departmentord)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rPayAccInSpClc.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpClc.prn));  
      end if;                 
    end loop;

    /* Если лицевой счёт в калькуляции не равен лицевому счёту заказа подразделений */
    if cmp_num(rPayAccInSpClc.faceaccount, rDepartmentOrd.faceacc) != 1 then
      p_exception(0, 'Лицевой счёт в калькуляции <%s> не равен лицевому счёту заказа подразделений <%s>.%s%s%s'
                 ,get_faceacc_numb_id(nflag_smart => 1, nrn => rPayAccInSpClc.faceaccount)
                 ,get_faceacc_numb_id(nflag_smart => 1, nrn => rDepartmentOrd.faceacc)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rRow.departmentord)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => rPayAccInSpClc.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rPayAccInSpClc.prn));  
    end if;                 

  end PAYACCINSPCLC_EX_CHECK_BASE;
  /*#########################################################################################################*/

end USR_PKG_PAYACCIN;
/
