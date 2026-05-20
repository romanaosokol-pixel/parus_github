create or replace package USR_PKG_DELIVERYORD is
  /*
  Package предназначен для работы с разделом "Заказы поставщикам". Степанов М. 01/12/2020
  DeliveryOrders              DELIVERYORD   DLO
  DeliveryOrdersSpec          DELIVERYORDS  DLOS
  DeliveryOrdersSpecCalcs     DELIVERYORDCS DLOSC
  -- Исполнение
  DeliveryOrdersPerform       DELIVERYORDP  DLOP      Заказы поставщикам (исполнение)
  DeliveryOrdersSpecPerform   DELIVERYORDPS DLOSP     Заказы поставщикам (спецификация, исполнение)
  */

  /*#########################################################################################################*/

  function DELIVERYORD_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return DELIVERYORD%ROWTYPE;
  /*#########################################################################################################*/

  function DELIVERYORD_GET_NOMEN_TYPE
  /*
  Заголовок. Получение типа номенклатур (1 - товар, 2 - услуга, 3 - тара, 9 - смешанный, 0 - нет спецификаций)
  */
  (
   nRN        in number -- RN записи
  ,nCOMPANY   in number
  ) 
  return number;
  /*#########################################################################################################*/

  procedure DELIVERYORD_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BCONFIRM
  /*
  Заголовок. Проверка перед подтверждением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_ACONFIRM
  /*
  Заголовок. Проверка после подтверждения
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BWOCONFIRM
  /*
  Заголовок. Проверка перед снятием подтверждения
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_AWOCONFIRM
  /*
  Заголовок. Проверка после снятия подтверждения
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BMAKEPAYACCIN
  /*
  Заголовок. Проверка перед формированием вх.счёта на оплату
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_AMAKEPAYACCIN
  /*
  Заголовок. Проверка после формирования вх.счёта на оплату
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BCNTRFACTCRTPAYACC
  /*
  Заголовок. Проверка перед УМТС. Сформировать счет-договор
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_ACNTRFACTCRTPAYACC
  /*
  Заголовок. Проверка после УМТС. Сформировать счет-договор
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BMAKEININVOICE
  /*
  Заголовок. Формирование приходной накладной
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BMAKEINORDER
  /*
  Заголовок. Формирование приходного ордера
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_CLEAR_FOR_UPDATE
  /*
  Заголовок. Очистка перед исправлением и восстановление после очистки
  При очистке удаляются связи, меняется статус на Не утверждён. При восстановлении возвращается статус, восстанавливаются связи 
  Обязательно выполнять в обоих режимах, иначе документ останется неотработанным и без связей
  */
  (
   nRN                in number 
  ,nMODE              in number /* Режим выполнения: 0 - освободить, 1 - восстановить */
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_deliveryord%rowtype
  ,nFLAG_MODE   in number default 1
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure DELIVERYORD_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in deliveryord%rowtype
  ,nFLAG_MODE   in number default 1
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDBUF_BASE_UPDATE
  /*
  Заголовок буфера. Базовое исправление
  */
  (
   RROW         DELIVERYORDBUF%ROWTYPE
  );
  /*#########################################################################################################*/

  FUNCTION DELIVERYORD_GET_STATUS_NAME
  /*
  Показать наименование состояния заголовка
  */
  (
   NORD_STATE    IN NUMBER -- номер статуса
  ) 
  RETURN VARCHAR2;
  /*#########################################################################################################*/

  PROCEDURE DELIVERYORD_MAKE_PAI
  /*
  Заголовок. Формирование входящех счётов на оплату
  */
  (
   nIDENT           in number
  ,nCOMPANY         in number
  ,sCATALOG         in varchar2
  ,dDATE            in date
  ,sSTORE           in varchar2
  ,sEXT_NUMB        in varchar2
  );
  /*#########################################################################################################*/

  PROCEDURE DELIVERYORD_DELETE_PAI
  /*
  Заголовок. Удаление входящех счётов на оплату
  */
  (
   NRN              IN NUMBER
  ,NNOT_APPROVE     IN NUMBER   -- изменять статус заказа на "Не утверждён"
  );
  /*#########################################################################################################*/

  function DELIVERYORD_GET_PAI_STATUS
  /*
  Показать состояние заказа в части исполнения его по входящим счетам на оплату: 0 - нет, 1 - частично, 2 - полностью, 3 - с превышением 
  */
  (
   NRN        IN NUMBER           -- RN записи
  ,NCALC_WAY  IN NUMBER DEFAULT 0 -- исполнение по: 0 -количеству, 1 - сумме
  ) 
  RETURN NUMBER;
  /*#########################################################################################################*/

  function DELIVERYORDP_GET
  /*
  Заголовок (исполнение). Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0  
  )
  return deliveryordp%rowtype;
  /*#########################################################################################################*/

  function DELIVERYORDP_GET_BY_PRN
  /*
  Заголовок (исполнение). Считывание по родителю
  */
  (
   nRN          in number /* RN родителя DELIVERYORD */
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordp%rowtype;
  /*#########################################################################################################*/

  function DELIVERYORDS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return DELIVERYORDS %ROWTYPE;
  /*#########################################################################################################*/
  
  PROCEDURE DELIVERYORDS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMEN             IN NUMBER DEFAULT NULL
  ,NNOM_PACK          IN NUMBER DEFAULT NULL
  ,NNOM_MODIF         IN NUMBER DEFAULT NULL
  ,NNOMMOD_PACK       IN NUMBER DEFAULT NULL
  ,NPR_MEAS           IN NUMBER DEFAULT NULL
  ,NPRODUCT           IN NUMBER DEFAULT NULL
  ,NTAX_GROUP         IN NUMBER DEFAULT NULL
  ,NMAIN_QUANT        IN NUMBER DEFAULT NULL
  ,NALT_QUANT         IN NUMBER DEFAULT NULL
  ,NEXP_PRICE         IN NUMBER DEFAULT NULL
  ,RROW               OUT DELIVERYORDS%ROWTYPE 
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDSBUF_BASE_INSERT
  /*
  Спецификация буфера. Добавление базовое 
  */
  (
   rDELIVERYORDSBUF   in deliveryordsbuf%rowtype
  ,rDELIVERYORDPSBUF  in deliveryordpsbuf%rowtype
  ,nRN                out number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDSBUF_BASE_UPDATE
  /*
  Спецификация буфера. Базовое исправление
  */
  (
   rDELIVERYORDSBUF   DELIVERYORDSBUF%ROWTYPE
  ,rDELIVERYORDPSBUF  DELIVERYORDPSBUF%ROWTYPE
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_UPDATE
  /*
  Спецификация. Исправление (снимается утверждение с заказа и спецификаций, удаляется и вновь добавляется спецификация с новыми параметрами)
  */
  (
   rV_ROW           in v_deliveryords%rowtype
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_DELETE
  /*
  Спецификация. Удаление (снимается утверждение с заказа и спецификаций, удаляется и вновь добавляется спецификация с новыми параметрами)
  */
  (
   RDELIVERYORDS  in deliveryords%rowtype
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW             in deliveryords%rowtype
  ,rDELIVERYORDPS   in deliveryordps%rowtype
  ,nDUP_RN          in number default null
  ,nIGNOREPERF      in number default 0
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN              out number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in deliveryords%rowtype
  ,rDELIVERYORDPS   in deliveryordps%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_CHECK_DLOSC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in deliveryords%rowtype
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDS_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации заказа подразделения
  */
  (
   rROW   in deliveryords%rowtype
  );
  /*#########################################################################################################*/

  PROCEDURE DELIVERYORDS_GET_PAI_REMAIN
  /*
  Спецификация. Получить остаток исполнения по входящим счетам на оплату
  */
  (
   RROW          IN DELIVERYORDS%ROWTYPE
  ,NCALC_WAY     IN NUMBER  -- возвращать оставшееся: 0 - количество, 1 - сумму
  ,NMOD_SIGN    OUT NUMBER  -- спецификация включена во входящие счёта: 0 - нет, 1 - да
  ,NRESULT      OUT NUMBER  -- результат: количество или сумма по которым не сформированы входящие счета на оплату
  );
/*#########################################################################################################*/

  function DELIVERYORDS_GET_STATE_BY_HEAD
  /*
  Спецификация (исполнение). Определение статуса по статусу заголовка
  */
  (
   NORD_STATE     in number -- статус заголовка
  ) 
  return number;
  /*#########################################################################################################*/

  function DELIVERYORDPS_GET
  /*
  Спецификация (исполнение). Считывание 
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordps%rowtype;
  /*#########################################################################################################*/

  function DELIVERYORDPS_GET_BY_PRN
  /*
  Спецификация (исполнение). Считывание по родителю
  */
  (
   nRN          in number /* RN родителя DELIVERYORDS */
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordps%rowtype;
  /*#########################################################################################################*/

  function DELIVERYORDCS_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  )
  return deliveryordcs%rowtype;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_AINSERT
  /*
  Спецификация (калькуляция). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BUPDATE
  /*
  Спецификация (калькуляция). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BDELETE
  /*
  Спецификация (калькуляция). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое 
  */
  (
   rROW       in deliveryordcs%rowtype
  ,nRN        out number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое 
  */
  (
   rROW       in deliveryordcs%rowtype
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  );
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_GET_PAISC_QUANT
  /*
  Спецификация (калькуляция). Получить количество по калькуляциям входящих счетов на оплату
  */
  (
   nRN          in number
  ,nQUANT_PLAN  out number
  ,nQUANT_FACT  out number
  );
/*#########################################################################################################*/


end USR_PKG_DELIVERYORD;
/
create or replace package body USR_PKG_DELIVERYORD is

  /*#########################################################################################################*/

  function DELIVERYORD_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryord%rowtype
  is
    rRow deliveryord%rowtype;
  begin
    begin
      select * into rRow from deliveryord where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'DELIVERYORD');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DELIVERYORD'))
                   ,cr||sqlerrm);
    end;

    return(rRow);

  end DELIVERYORD_GET;
  /*#########################################################################################################*/

  function DELIVERYORD_GET_NOMEN_TYPE
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
    p_deliveryord_exists(ncompany => nCOMPANY, nrn => nrn, ncrn => nNumber);
    
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
               from deliveryords t, dicnomns dnm
              where t.prn   = nRN
                and t.nomen = dnm.rn);
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'DELIVERYORD')), sqlerrm);
    end;

    return(nResult);

  end DELIVERYORD_GET_NOMEN_TYPE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow            deliveryord%rowtype;
  BEGIN
    -- Считывание
    -- rRow := DELIVERYORD_GET(NRN); 

    -- ПРОВЕРКИ
    -- Базовая
    DELIVERYORD_CHECK_BASE(NRN, NCOMPANY);

    /* По спецификациям */
    for c in (select * from deliveryords where prn = rRow.rn) 
    loop
      /* проверка спецификации */
      deliveryords_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;

  end DELIVERYORD_AINSERT;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;    
    -- Считывание
    -- USR_PKG_PUB_CONST.RDELIVERYORD := DELIVERYORD_GET(NRN); 

  end DELIVERYORD_BUPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow                     DELIVERYORD%ROWTYPE;
    
    sVarchar        PKG_STD.tSTRING; 
  BEGIN
    -- Считывание
    -- rRow := DELIVERYORD_GET(NRN); 

    -- ПРОВЕРКИ
    -- Базовая
    DELIVERYORD_CHECK_BASE(NRN, NCOMPANY);
    
  end DELIVERYORD_AUPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BCONFIRM
  /*
  Заголовок. Проверка перед подтверждением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rdeliveryord := deliveryord_get(nrn => NRN); */

    /* ПРОВЕРКИ */

  end DELIVERYORD_BCONFIRM;
  /*#########################################################################################################*/

  procedure DELIVERYORD_ACONFIRM
  /*
  Заголовок. Проверка после подтверждения
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow          deliveryord%rowtype;
  begin
    /* Считывание */
    rRow := deliveryord_get(nrn => NRN); 
    
    /* ПРОВЕРКИ */
    /* Базовая */
    deliveryord_check_base(nrn => NRN, ncompany => NCOMPANY);

    /* По спецификациям */
    for c in (select * from deliveryords where prn = rRow.rn)
    loop
      /* проверка превышения исполнения родительской спецификации заказа подразделения */
      deliveryords_check_indoc(rRow => c);
      /* проверка калькуляций */
      deliveryords_check_dlosc(rrow => c);
    end loop;

  end DELIVERYORD_ACONFIRM;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BWOCONFIRM
  /*
  Заголовок. Проверка перед снятием подтверждения
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    NULL;    
    -- Считывание
    /*USR_PKG_PUB_CONST.RDELIVERYORD := DELIVERYORD_GET(NRN); */

  end DELIVERYORD_BWOCONFIRM;
  /*#########################################################################################################*/

  procedure DELIVERYORD_AWOCONFIRM
  /*
  Заголовок. Проверка после снятия подтверждения
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
    
  end DELIVERYORD_AWOCONFIRM;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow          deliveryord%rowtype;
    nNumber       pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := deliveryord_get(nrn => NRN);
    
    /* Снятие утверждения */
    if rRow.ord_state != 0 then
      p_deliveryord_bset_state(nflag_smart => 0
                              ,nflag_mode  => 0
                              ,ncompany    => rRow.company
                              ,nrn         => rRow.rn
                              ,nnew_state  => 0
                              ,dstate_date => sysdate
                              ,nresult     => nNumber);
    end if;

  end DELIVERYORD_BDELETE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BMAKEPAYACCIN
  /*
  Заголовок. Проверка перед формированием вх.счёта на оплату
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
    rRow            DELIVERYORD%ROWTYPE;
  BEGIN
    NULL;  
  end DELIVERYORD_BMAKEPAYACCIN;
  /*#########################################################################################################*/

  procedure DELIVERYORD_AMAKEPAYACCIN
  /*
  Заголовок. Проверка после формирования вх.счёта на оплату
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow        deliveryord%rowtype;
    rPayAccIn   payaccin%rowtype;
  begin
    /* Заголовок */
    rRow := deliveryord_get(nrn => nRN);

    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select t.*
                from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable)) tp
                    ,payaccin t
              where tp.column_value = t.rn) 
    loop
      rPayAccIn := c;

      /* добавление к примечанию примечания из заказа поставщику */
      rPayAccIn.comments := strcombine(rPayAccIn.comments, rRow.note, cr);
      if rPayAccIn.comments is not null then
        usr_pkg_payaccin.payaccin_base_update(rrow => rPayAccIn, nstatus_ignore => 0);
      end if;

      /* проверка заголовка */
      usr_pkg_payaccin.payaccin_ainsert(nrn => rPayAccIn.rn, ncompany => rPayAccIn.company);
      
      /*Пересчитаем калькуляцию строки счета, для привязки ее к бюджетам*/
      usr_p_payaccinspclc_cre(nrn => c.rn);
    end loop;

  end DELIVERYORD_AMAKEPAYACCIN;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BCNTRFACTCRTPAYACC
  /*
  Заголовок. Проверка перед УМТС. Сформировать счет-договор
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
    rRow            DELIVERYORD%ROWTYPE;
  BEGIN
    /* Сохраняем RN в константу */
    usr_pkg_pub_const.nIdentBefore := nRN;

  end DELIVERYORD_BCNTRFACTCRTPAYACC;
  /*#########################################################################################################*/

  procedure DELIVERYORD_ACNTRFACTCRTPAYACC
  /*
  Заголовок. Проверка после УМТС. Сформировать счет-договор
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    sConnect_Ext    pkg_std.tstring := pkg_session.get_connect_ext; 
  begin
    /* По сформированным документам */
    for c in ( select t.*
                 from usr_t_inhierbuff tp, payaccin t
                where tp.identbefore = usr_pkg_pub_const.nIdentBefore
                  and tp.connect_ext = sConnect_Ext
                  and t.rn           = tp.out_document0 ) 
    loop
      /* Проверка после добавления */
      usr_pkg_payaccin.payaccin_ainsert( nrn => c.rn, ncompany => c.company );
    end loop;

    /* Очистка констант */
    delete from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nIdentBefore and connect_ext = sConnect_Ext;
    usr_pkg_pub_const.nIdentBefore := null;

  end DELIVERYORD_ACNTRFACTCRTPAYACC;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BMAKEININVOICE
  /*
  Заголовок. Формирование приходной накладной
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Запрет */
    p_exception(0, 'Запрещено формирование приходных накладных.%s'
               ,cr||f_docdescrs_get_description( sunitcode => 'DeliveryOrders', ndocument => nRN ) ); 

  end DELIVERYORD_BMAKEININVOICE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BMAKEINORDER
  /*
  Заголовок. Формирование приходного ордера
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Запрет */
    p_exception(0, 'Запрещено формирование приходных ордеров.%s'
               ,cr||f_docdescrs_get_description( sunitcode => 'DeliveryOrders', ndocument => nRN ) ); 

  end DELIVERYORD_BMAKEINORDER;
  /*#########################################################################################################*/

  procedure DELIVERYORD_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     deliveryord%rowtype;
    rFaceAcc        faceacc%rowtype;
  begin
    /* Заголовок */
    rRow := deliveryord_get(nrn => nRN);
    /* Лицевой счёт */
    if rRow.faceacc is not null then
      rFaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rRow.faceacc);
    end if;
  
    /* Для документов после даты 15/08/2023 */
    if rRow.ord_date > to_date('15.08.2023', 'dd.mm.yyyy') then
      /* Параметр "Цены с учётом налогов" */  
      if rRow.includetax = 0 then
        P_EXCEPTION(0, 'Параметр "Цены с учётом налогов" должен быть заполнен. Для исправления выполните процедуру <Исправить признак "Цены включают налоги">. %s'
                   ,CR||F_DOCDESCRS_GET_DESCRIPTION('DeliveryOrders', rRow.rn)
                   ); 
      end if;
    end if;

    /* Если лицевой счёт задан и его контрагент не равен контрагенту документа */
    if rFaceAcc.rn is not null 
    and nvl(rRow.agent, 0) != nvl(rFaceAcc.agent, 0) then
      p_exception(0, 'Контрагент документа <%s> не равен контрагенту лицевого счёта <%s>. %s'
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.agent)
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rFaceAcc.agent)
                 ,cr||f_docdescrs_get_description(sunitcode => 'DeliveryOrders', ndocument => rRow.rn)); 
    end if;
    
    /* Если каталог Метрология */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => usr_pkg_pub_const.ndlo_cat_mtlg) then
      /* Если подразделение НЕ Отдел метрологии */
      if rRow.subdiv != 89531486 then
        p_exception(0, 'Документ находится в каталоге <%s>, и в нём указано подразделение <%s>. Должно быть указано подразделение <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.subdiv)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => 89531486)
                   ,cr||f_docdescrs_get_description('DeliveryOrders', rRow.rn)); 
      end if;                 
      /* заказчик ответственный не задан */
      if rRow.acc_agent is null then
        p_exception(0, 'Не заполнено поле "Заказчик. Ответственный" . %s'
                   ,cr||f_docdescrs_get_description('DeliveryOrders', rRow.rn)); 
      end if;
    /* Если каталог НЕ Метрология */
    else
      /* Если подразделение Отдел метрологии */
      if rRow.subdiv = 89531486 then
        p_exception(0, 'Документ находится в каталоге <%s>, и в нём указано подразделение <%s>. Он должен находиться в каталоге <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.subdiv)
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => usr_pkg_pub_const.ndlo_cat_mtlg)
                   ,cr||f_docdescrs_get_description('DeliveryOrders', rRow.rn)); 
      end if;                 
    end if;
    
  end DELIVERYORD_CHECK_BASE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_CLEAR_FOR_UPDATE
  /*
  Заголовок. Очистка перед исправлением и восстановление после очистки
  При очистке удаляются связи, меняется статус на Не утверждён. При восстановлении возвращается статус, восстанавливаются связи 
  Обязательно выполнять в обоих режимах, иначе документ останется неотработанным и без связей
  */
  (
   nRN                in number 
  ,nMODE              in number /* Режим выполнения: 0 - освободить, 1 - восстановить */
  ) 
  is
    rDeliveryOrd    deliveryord%rowtype;
    rDeliveryOrdP   deliveryordp%rowtype;
  begin
    /* Считывание заголовка */
    rDeliveryOrd := deliveryord_get( nrn => nRN );

    /* 0 - Освободить */
    if nMODE = 0 then
      /* Удаляем связи заголовка */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rDeliveryOrd.rn
                                          ,ncompany      => rDeliveryOrd.company
                                          ,sunitcode     => 'PaymentAccountsIn'
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                          ,nmode         => nMODE );
      /* Считываем исполнение заголовка */
      rDeliveryOrdP := deliveryordp_get_by_prn( nrn => rDeliveryOrd.rn );
      /* Удаляем связи исполнения заголовка */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rDeliveryOrdP.rn
                                          ,ncompany      => rDeliveryOrdP.company
                                          ,sunitcode     => 'PaymentAccountsIn'
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list2
                                          ,nmode         => nMODE );
      /* Изменение статуса на "Не подтвержден" в заголовке  */
      update deliveryord 
         set ord_state = 0
       where rn = rDeliveryOrd.rn;

      /* Исправляем статус в исполнениях спецификаций */
      update deliveryordps 
         set perfs_state = 0 
       where prn in ( select rn from deliveryords where prn = rDeliveryOrd.rn );

    /* 1 - Восстановить */
    elsif nMODE = 1 then

      /* Возвращение предыдущего статуса заголовку */
      update deliveryord 
         set ord_state = rDeliveryOrd.ord_state 
       where rn = rDeliveryOrd.rn;

      /* Возвращение статуса исполнениям спецификаций */
      update deliveryordps 
         set perfs_state = deliveryords_get_state_by_head( nord_state => rDeliveryOrd.ord_state ) 
       where prn in ( select rn from deliveryords where prn = rDeliveryOrd.rn );

      /* Восстанавливаем связи заголовка */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rDeliveryOrd.rn
                                          ,ncompany      => rDeliveryOrd.company
                                          ,sunitcode     => 'PaymentAccountsIn'
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                          ,nmode         => nMODE );
         
      /* Считываем исполнение заголовка */
      rDeliveryOrdP := deliveryordp_get_by_prn( nrn => rDeliveryOrd.rn );
      /* Восстанавливаем связи исполнения заголовка */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rDeliveryOrdP.rn
                                          ,ncompany      => rDeliveryOrdP.company
                                          ,sunitcode     => 'PaymentAccountsIn'
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list2
                                          ,nmode         => nMODE );
      /* Очистка переменных */
      usr_pkg_pub_const.arn_unit_list.delete;
      usr_pkg_pub_const.arn_unit_list2.delete;

    else
      p_exception(0, 'Неверный режим работы.%s', sqlerrm ); 
    end if;

  end DELIVERYORD_CLEAR_FOR_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_deliveryord%rowtype
  ,nFLAG_MODE   in number default 1
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_DeliveryOrd  v_deliveryord%rowtype := rV_ROW;

    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_deliveryord_update(ncompany      => rV_ROW.NCOMPANY
                          ,nrn           => rV_ROW.NRN
                          ,sord_pref     => rV_ROW.SORD_PREF
                          ,sord_numb     => rV_ROW.SORD_NUMB
                          ,sagent        => rV_ROW.SAGENT
                          ,sfaceacc      => rV_ROW.SFACEACC
                          ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                          ,sord_doctype  => rV_ROW.SORD_DOCTYPE
                          ,dord_date     => rV_ROW.DORD_DATE
                          ,nord_state    => rV_ROW.NORD_STATE
                          ,dstate_date   => rV_ROW.DSTATE_DATE
                          ,sdisp_type    => rV_ROW.SDISP_TYPE
                          ,spay_type     => rV_ROW.SPAY_TYPE
                          ,sdeliv_diagr  => rV_ROW.SDELIV_DIAGR
                          ,scurrency     => rV_ROW.SCURRENCY
                          ,sstore        => rV_ROW.SSTORE
                          ,sacc_agent    => rV_ROW.SACC_AGENT
                          ,ssubdiv       => rV_ROW.SSUBDIV
                          ,dpay_date     => rV_ROW.DPAY_DATE
                          ,drelease_date => rV_ROW.DRELEASE_DATE
                          ,nord_period   => rV_ROW.NORD_PERIOD
                          ,nusecalendar  => rV_ROW.NUSECALENDAR
                          ,nperiod_corr  => rV_ROW.NPERIOD_CORR
                          ,nperiod_quant => rV_ROW.NPERIOD_QUANT
                          ,nperiod_type  => rV_ROW.NPERIOD_TYPE
                          ,nperiod_len   => rV_ROW.NPERIOD_LEN
                          ,natsametime   => rV_ROW.NATSAMETIME
                          ,nincludetax   => rV_ROW.NINCLUDETAX
                          ,nreduction    => rV_ROW.NREDUCTION
                          ,sjur_pers     => rV_ROW.SJUR_PERS
                          ,snote         => rV_ROW.SNOTE
                          ,sdelivdocnumb => rV_ROW.SDELIVDOCNUMB
                          ,ddelivdocdate => rV_ROW.DDELIVDOCDATE
                          ,sbarcode      => rV_ROW.SBARCODE
                          ,nflag_mode    => nFLAG_MODE);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Если документ НЕ "Не утвёрждён" */
      if rV_DeliveryOrd.nord_state != 0 then

        /* Очистка для исправления */
        usr_pkg_deliveryord.deliveryord_clear_for_update( nrn => rV_DeliveryOrd.nrn, nmode => 0 );

        /* Исправление */
        deliveryord_update(rv_row => rV_DeliveryOrd, nmode => 0);

        /* Восстановление после очистки для исправления */
        usr_pkg_deliveryord.deliveryord_clear_for_update( nrn => rV_DeliveryOrd.nrn, nmode => 1 );

      /* Если документ "Не утвёрждён" */
      else
        /* Исправление */
        deliveryord_update(rv_row => rV_DeliveryOrd, nmode => 0);
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
  end DELIVERYORD_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORD_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in deliveryord%rowtype
  ,nFLAG_MODE   in number default 1
  ) 
  is
  begin
    p_deliveryord_base_update(ncompany      => rROW.COMPANY
                             ,nrn           => rROW.RN
                             ,sord_pref     => rROW.ORD_PREF
                             ,sord_numb     => rROW.ORD_NUMB
                             ,nagent        => rROW.AGENT
                             ,nfaceacc      => rROW.FACEACC
                             ,ngraphpoint   => rROW.GRAPHPOINT
                             ,nord_doctype  => rROW.ORD_DOCTYPE
                             ,dord_date     => rROW.ORD_DATE
                             ,nord_state    => rROW.ORD_STATE
                             ,dstate_date   => rROW.STATE_DATE
                             ,ndisp_type    => rROW.DISP_TYPE
                             ,npay_type     => rROW.PAY_TYPE
                             ,ndeliv_diagr  => rROW.DELIV_DIAGR
                             ,ncurrency     => rROW.CURRENCY
                             ,nstore        => rROW.STORE
                             ,nacc_agent    => rROW.ACC_AGENT
                             ,nsubdiv       => rROW.SUBDIV
                             ,dpay_date     => rROW.PAY_DATE
                             ,drelease_date => rROW.RELEASE_DATE
                             ,nord_period   => rROW.ORD_PERIOD
                             ,nusecalendar  => rROW.USECALENDAR
                             ,nperiod_corr  => rROW.PERIOD_CORR
                             ,nperiod_quant => rROW.PERIOD_QUANT
                             ,nperiod_type  => rROW.PERIOD_TYPE
                             ,nperiod_len   => rROW.PERIOD_LEN
                             ,natsametime   => rROW.ATSAMETIME
                             ,nincludetax   => rROW.INCLUDETAX
                             ,nreduction    => rROW.REDUCTION
                             ,snote         => rROW.NOTE
                             ,njur_pers     => rROW.JUR_PERS
                             ,sdelivdocnumb => rROW.DELIVDOCNUMB
                             ,ddelivdocdate => rROW.DELIVDOCDATE
                             ,sbarcode      => rROW.BARCODE
                             ,nflag_mode    => nFLAG_MODE);
  end DELIVERYORD_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDBUF_BASE_UPDATE
  /*
  Заголовок буфера. Базовое исправление
  */
  (
   RROW         DELIVERYORDBUF%ROWTYPE
  ) 
  IS
  BEGIN
    P_DELIVERYORDBUF_BASE_UPDATE
    (
     NCOMPANY      => RROW.COMPANY
    ,NRN           => RROW.RN
    ,NCRN          => RROW.CRN
    ,SORD_PREF     => RROW.ORD_PREF
    ,SORD_NUMB     => RROW.ORD_NUMB
    ,NAGENT        => RROW.AGENT
    ,NFACEACC      => RROW.FACEACC
    ,NGRAPHPOINT   => RROW.GRAPHPOINT
    ,NORD_DOCTYPE  => RROW.ORD_DOCTYPE
    ,DORD_DATE     => RROW.ORD_DATE
    ,NORD_STATE    => RROW.ORD_STATE
    ,DSTATE_DATE   => RROW.STATE_DATE
    ,NDISP_TYPE    => RROW.DISP_TYPE
    ,NPAY_TYPE     => RROW.PAY_TYPE
    ,NDELIV_DIAGR  => RROW.DELIV_DIAGR
    ,NCURRENCY     => RROW.CURRENCY
    ,NSTORE        => RROW.STORE
    ,NACC_AGENT    => RROW.ACC_AGENT
    ,NSUBDIV       => RROW.SUBDIV
    ,DPAY_DATE     => RROW.PAY_DATE
    ,DRELEASE_DATE => RROW.RELEASE_DATE
    ,NORD_PERIOD   => RROW.ORD_PERIOD
    ,NUSECALENDAR  => RROW.USECALENDAR
    ,NPERIOD_CORR  => RROW.PERIOD_CORR
    ,NPERIOD_QUANT => RROW.PERIOD_QUANT
    ,NPERIOD_TYPE  => RROW.PERIOD_TYPE
    ,NPERIOD_LEN   => RROW.PERIOD_LEN
    ,NATSAMETIME   => RROW.ATSAMETIME
    ,NINCLUDETAX   => RROW.INCLUDETAX
    ,NREDUCTION    => RROW.REDUCTION
    ,SNOTE         => RROW.NOTE
    ,NJUR_PERS     => RROW.JUR_PERS
    ,SDELIVDOCNUMB => RROW.DELIVDOCNUMB
    ,DDELIVDOCDATE => RROW.DELIVDOCDATE
    ,SBARCODE      => RROW.BARCODE
    ,NFLAG_MODE    => 1
    );
  end DELIVERYORDBUF_BASE_UPDATE;
  /*#########################################################################################################*/

  FUNCTION DELIVERYORD_GET_STATUS_NAME
  /*
  Показать наименование состояния заголовка
  */
  (
   NORD_STATE    IN NUMBER -- номер статуса
  ) 
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN(CASE NORD_STATE
             WHEN 0 THEN 'Не подтвержден'
             WHEN 1 THEN 'Подтвержден'
             WHEN 2 THEN 'Согласование' 
             WHEN 3 THEN 'Закрыт' 
             WHEN 4 THEN 'Аннулирован'
             ELSE NULL
           END);
  END DELIVERYORD_GET_STATUS_NAME;
  /*#########################################################################################################*/

  PROCEDURE DELIVERYORD_MAKE_PAI
  /*
  Заголовок. Формирование входящех счётов на оплату
  */
  (
   nIDENT           in number
  ,nCOMPANY         in number
  ,sCATALOG         in varchar2
  ,dDATE            in date
  ,sSTORE           in varchar2
  ,sEXT_NUMB        in varchar2
  ) 
  IS
    nCount              pkg_std.tnumber; 
    nCatalog            pkg_std.tref; 
    rPayaccInBuff       payaccinbuff%rowtype;
  BEGIN
    /* Каталог Заказов поставщикам */
    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => nCOMPANY
                      ,nversion    => null
                      ,sunitcode   => 'PaymentAccountsIn'
                      ,sname       => sCATALOG
                      ,nrn         => nCatalog);
    /* Формирование буфера */
    for c in (select document from selectlist where ident = nIDENT)
    loop
      /* количество записей в selectlist */        
      p_deliveryord_makepayaccin(ncompany     => nCOMPANY
                                ,nident       => nIDENT
                                ,nrn          => c.document
                                ,np_rn        => null
                                ,ddate        => dDATE
                                ,sstore_title => sSTORE
                                ,nspec_empty  => 0
                                ,nres         => nCount);
    end loop;
    /* если буфер не сформировался */
    if nCount = 0  then
      p_exception(0, 'Формирование не выполненно. %s'
                 ,cr||f_docdescrs_get_description('DeliveryOrders', nIDENT)); 
    end if;

    /* По заголовкам буфера */
    for c in (select * from payaccinbuff where ident = nIDENT)
    loop
      /* считывание текущей записи в переменную */
      rPayaccInBuff := c;
      /* подмена значений в переменной */
      rPayaccInBuff.crn := nCatalog;
      rPayaccInBuff.ext_numb := trim(sEXT_NUMB);
      /* исправление записи буфера */
      usr_pkg_payaccin.payaccinbuff_base_update(rrow => rPayaccInBuff);
    end loop;

    /* Перенос из буфера */  
    p_payaccinbuff_makedoc(ncompany => nCOMPANY, nident => nIDENT);
    
    /* Очистка */  
    p_payaccinbuff_clear(ncompany => nCOMPANY, nident => nIDENT);

  END DELIVERYORD_MAKE_PAI;
  /*#########################################################################################################*/

  PROCEDURE DELIVERYORD_DELETE_PAI
  /*
  Заголовок. Удаление входящех счётов на оплату
  */
  (
   NRN              IN NUMBER
  ,NNOT_APPROVE     IN NUMBER   -- изменять статус заказа на "Не утверждён"
  ) 
  IS
    rRow          DELIVERYORD%ROWTYPE;
    nNumber       PKG_STD.tNUMBER; 
  BEGIN
    rRow := DELIVERYORD_GET(NRN);
    -- По выходным связам
    FOR C IN (SELECT PAI.*
                FROM DOCLINKS DL
                    ,PAYACCIN PAI
               WHERE DL.IN_DOCUMENT  = rRow.RN
                 AND DL.OUT_UNITCODE = 'PaymentAccountsIn'
                 AND DL.OUT_DOCUMENT = PAI.RN
             ) 
    LOOP
      IF C.DOC_STATE IN (2, 3) THEN
        P_EXCEPTION(0, 'Невозможно удалить связанный входящий счёт на оплату, т.к. его статус "Закрыт" или "Аннулирован".'||CHR(10)||'%s'
                       ,F_DOCDESCRS_GET_DESCRIPTION('DeliveryOrders', rRow.RN));
      ELSIF C.DOC_STATE IN (1) THEN
        P_PAYACCIN_SET_STATUS
        (
         NCOMPANY   => C.COMPANY
        ,NRN        => C.RN
        ,NSTATUS    => 0
        ,DWORK_DATE => CURRENT_DATE
        );
      END IF;
      -- Удаление
      P_PAYACCIN_DELETE(C.COMPANY, C.RN);
    END LOOP;

    -- Изменение статуса на "Не утверждён"
    IF NNOT_APPROVE = 1 THEN
      IF RROW.ORD_STATE != 0 THEN
        -- подтверждение
        P_DELIVERYORD_SET_STATE
        (
         NFLAG_SMART => 0
        ,NCOMPANY    => RROW.COMPANY
        ,NRN         => RROW.RN
        ,NFLAG_MODE  => 0
        ,NNEW_STATE  => 0
        ,DSTATE_DATE => CURRENT_DATE
        ,NRESULT     => nNumber
        );
      END IF;
    END IF;
    
  END DELIVERYORD_DELETE_PAI;
  /*#########################################################################################################*/

  function DELIVERYORD_GET_PAI_STATUS
  /*
  Показать состояние заказа в части исполнения его по входящим счетам на оплату: 0 - нет, 1 - частично, 2 - полностью, 3 - с превышением 
  */
  (
   NRN        IN NUMBER           -- RN записи
  ,NCALC_WAY  IN NUMBER DEFAULT 0 -- исполнение по: 0 -количеству, 1 - сумме
  ) 
  RETURN NUMBER
  IS
    rDELIVERYORDS DELIVERYORDS%ROWTYPE;
    nSpecRes      PKG_STD.tNUMBER := 0; 
    nPAIRes       PKG_STD.tNUMBER := 0; -- осталось неисполненным по вх.счетам
    nTMPRes       PKG_STD.tNUMBER; 
    nSpecExists   PKG_STD.tNUMBER := 0; -- в заказе есть спецификации
    nResult       PKG_STD.tNUMBER; 
    nNumber       PKG_STD.tNUMBER; 
  BEGIN
    -- По спецификациям и исполнениям спецификаций
    FOR C IN (
              SELECT T.RN, DECODE(NCALC_WAY, 0, E.ACTM_QUANT, 1, E.ACTSWTAX) AS NRES
                FROM DELIVERYORDS T
                    ,DELIVERYORDPS E
               WHERE T.PRN = NRN
                 AND E.PRN = T.RN
             )
    LOOP
      nSpecExists := 1; 
      nTMPRes := 0;
      rDELIVERYORDS := DELIVERYORDS_GET(C.RN);
      -- количество не исполненное по вх.счетам
      DELIVERYORDS_GET_PAI_REMAIN
      (
       RROW      => rDELIVERYORDS
      ,NCALC_WAY => NCALC_WAY
      ,NMOD_SIGN => nNumber
      ,NRESULT   => nTMPRes
      );
      nSpecRes := nSpecRes + C.NRES;
      nPAIRes  := nPAIRes + nTMPRes;
    END LOOP;
    -- Результат
    IF nSpecExists = 0 OR nPAIRes = nSpecRes THEN -- нет спецификаций
      nResult := 0;
/*    ELSIF nPAIRes = nSpecRes THEN
      nResult := 0;*/
    ELSIF nPAIRes = 0 THEN 
      nResult := 2;
    ELSIF nPAIRes < 0 THEN 
      nResult := 3;
    ELSE 
      nResult := 1;
    END IF;

    RETURN(nResult);

  END DELIVERYORD_GET_PAI_STATUS;
  /*#########################################################################################################*/

  function DELIVERYORDP_GET
  /*
  Заголовок (исполнение). Считывание 
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordp%rowtype
  is
    rRow deliveryordp%rowtype;
  begin
    begin
      select * into rRow from deliveryordp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'DELIVERYORDP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DELIVERYORDP'))
                   ,cr||sqlerrm);
    end;

    return(rRow);

  end DELIVERYORDP_GET;
  /*#########################################################################################################*/

  function DELIVERYORDP_GET_BY_PRN
  /*
  Заголовок (исполнение). Считывание по родителю
  */
  (
   nRN          in number   /* RN родителя DELIVERYORD */
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordp%rowtype
  is
    rRow deliveryordp%rowtype;
  begin
    begin
      select * into rRow from deliveryordp where prn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'DELIVERYORDP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DELIVERYORDP'))
                   ,cr||sqlerrm);
    end;

    return( rRow );

  end DELIVERYORDP_GET_BY_PRN;
  /*#########################################################################################################*/

  function DELIVERYORDS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number /* RN заголовка DELIVERYORD */
  ,nFLAGSMART   in number default 0  
  ) 
  return DELIVERYORDS%ROWTYPE
  is
    rRow DELIVERYORDS%ROWTYPE;
  begin
    begin
      select T.*
        into rRow
        from DELIVERYORDS T
        where T.RN = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'DELIVERYORDS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(NRN), 'Не задан')||'> '||
        'в разделе <'||F_UNITLIST_GETNAME('DeliveryOrdersSpec')||'>.');
    end;
    return(rRow);
  end DELIVERYORDS_GET;
  /*#########################################################################################################*/
  
  PROCEDURE DELIVERYORDS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMEN             IN NUMBER DEFAULT NULL
  ,NNOM_PACK          IN NUMBER DEFAULT NULL
  ,NNOM_MODIF         IN NUMBER DEFAULT NULL
  ,NNOMMOD_PACK       IN NUMBER DEFAULT NULL
  ,NPR_MEAS           IN NUMBER DEFAULT NULL
  ,NPRODUCT           IN NUMBER DEFAULT NULL
  ,NTAX_GROUP         IN NUMBER DEFAULT NULL
  ,NMAIN_QUANT        IN NUMBER DEFAULT NULL
  ,NALT_QUANT         IN NUMBER DEFAULT NULL
  ,NEXP_PRICE         IN NUMBER DEFAULT NULL
  ,RROW               OUT DELIVERYORDS%ROWTYPE 
  ) 
  IS
  BEGIN
    BEGIN
      SELECT *
        INTO rRow
        FROM DELIVERYORDS T
       WHERE T.PRN                  = NPRN
         AND (NVL(T.NOMEN, 0)       = NVL(NNOMEN, 0) OR (NNOMEN IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOM_PACK, 0)    = NVL(NNOM_PACK, 0) OR (NNOM_PACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOM_MODIF, 0)   = NVL(NNOM_MODIF, 0) OR (NNOM_MODIF IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMMOD_PACK, 0) = NVL(NNOMMOD_PACK, 0) OR (NNOMMOD_PACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.PR_MEAS, 0)     = NVL(NPR_MEAS, 0) OR (NPR_MEAS IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.PRODUCT, 0)     = NVL(NPRODUCT, 0) OR (NPRODUCT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.TAX_GROUP, 0)   = NVL(NTAX_GROUP, 0) OR (NTAX_GROUP IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.MAIN_QUANT, 0)  = NVL(NMAIN_QUANT, 0) OR (NMAIN_QUANT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.ALT_QUANT, 0)   = NVL(NALT_QUANT, 0) OR (NALT_QUANT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.EXP_PRICE, 0)   = NVL(NEXP_PRICE, 0) OR (NEXP_PRICE IS NULL AND NFLAG_OPTION = 1))
         ;
    EXCEPTION
      WHEN NO_DATA_FOUND  THEN
        IF NFLAGSMART = 0 THEN
          P_EXCEPTION(0 ,'Не найдено спецификации для заголовка с RN <%s> записи в разделе <%s>. Модификация: <%s>'
                     ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DELIVERYORDS'))
                     ,usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => NNOM_MODIF)
                     );
        END IF;
      WHEN TOO_MANY_ROWS THEN
        IF NTOO_MANY_ROWS = 0 AND NFLAGSMART = 0 THEN
          P_EXCEPTION(0, 'Найдено больше одной спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DELIVERYORDS')));
        END IF;
      WHEN OTHERS THEN
        P_EXCEPTION(0, 'Неопределённая ситуация при поиске спецификации для заголовка с RN <%s> записи в разделе <%s>'
                   ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DELIVERYORDS')));
    END;
  END DELIVERYORDS_GET_BY_PARAMS;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    -- Проверка базовая
    DELIVERYORDS_CHECK_BASE(NRN, NCOMPANY);
  end DELIVERYORDS_AINSERT;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end DELIVERYORDS_BUPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    -- Проверка базовая
    DELIVERYORDS_CHECK_BASE(NRN, NCOMPANY);
  end DELIVERYORDS_AUPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  BEGIN
    NULL;
    -- Проверка базовая
    DELIVERYORDS_CHECK_BASE(NRN, NCOMPANY);
  end DELIVERYORDS_BDELETE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     deliveryords%rowtype;
  begin
    null;
    /* Считывание */
    rRow := deliveryords_get(nrn => nRN);
    
    if rRow.Nom_Modif is null then 
      P_exception(0, 'В позиции спецификации Заказа поставщику обязательно заполнять модификацию номенклатуры');    
    end if;

    /* ПРОВЕРКИ */
    
  end DELIVERYORDS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure DELIVERYORDSBUF_BASE_INSERT
  /*
  Спецификация буфера. Добавление базовое 
  */
  (
   rDELIVERYORDSBUF   in deliveryordsbuf%rowtype
  ,rDELIVERYORDPSBUF  in deliveryordpsbuf%rowtype
  ,nRN                out number
  ) 
  is
  begin
    p_deliveryordsbuf_base_insert(ncompany     => rDELIVERYORDSBUF.COMPANY
                                 ,nprn         => rDELIVERYORDSBUF.PRN
                                 ,nident       => rDELIVERYORDSBUF.IDENT
                                 ,nnomen       => rDELIVERYORDSBUF.nOMEN
                                 ,nnom_pack    => rDELIVERYORDSBUF.NOM_PACK
                                 ,nnom_modif   => rDELIVERYORDSBUF.NOM_MODIF
                                 ,nnommod_pack => rDELIVERYORDSBUF.NOMMOD_PACK
                                 ,nproduct     => rDELIVERYORDSBUF.PRODUCT
                                 ,ntax_group   => rDELIVERYORDSBUF.TAX_GROUP
                                 ,nexp_price   => rDELIVERYORDSBUF.EXP_PRICE
                                 ,npr_meas     => rDELIVERYORDSBUF.PR_MEAS
                                 ,nstore       => rDELIVERYORDSBUF.STORE
                                 ,nposreduct   => rDELIVERYORDSBUF.POSREDUCT
                                 ,snote        => rDELIVERYORDSBUF.NOTE
                                 ,nmdmnomen    => rDELIVERYORDSBUF.MDMNOMEN
                                 ,dactpf_date  => rDELIVERYORDPSBUF.actpf_date
                                 ,nactm_quant  => rDELIVERYORDPSBUF.actm_quant
                                 ,nacta_quant  => rDELIVERYORDPSBUF.acta_quant
                                 ,nactswtax    => rDELIVERYORDPSBUF.actswtax
                                 ,nactswotax   => rDELIVERYORDPSBUF.actswotax
                                 ,nignoreperf  => 0
                                 ,nrn          => nRN);
  end DELIVERYORDSBUF_BASE_INSERT;
  /*#########################################################################################################*/

  procedure DELIVERYORDSBUF_BASE_UPDATE
  /*
  Спецификация буфера. Базовое исправление
  */
  (
   rDELIVERYORDSBUF   DELIVERYORDSBUF%ROWTYPE
  ,rDELIVERYORDPSBUF  DELIVERYORDPSBUF%ROWTYPE
  ) 
  IS
  BEGIN
    P_DELIVERYORDSBUF_BASE_UPDATE
    (
     NCOMPANY       => rDELIVERYORDSBUF.COMPANY
    ,NRN            => rDELIVERYORDSBUF.RN
    ,NNOMEN         => rDELIVERYORDSBUF.NOMEN
    ,NNOM_PACK      => rDELIVERYORDSBUF.NOM_PACK
    ,NNOM_MODIF     => rDELIVERYORDSBUF.NOM_MODIF
    ,NNOMMOD_PACK   => rDELIVERYORDSBUF.NOMMOD_PACK
    ,NPRODUCT       => rDELIVERYORDSBUF.PRODUCT
    ,NTAX_GROUP     => rDELIVERYORDSBUF.TAX_GROUP
    ,NEXP_PRICE     => rDELIVERYORDSBUF.EXP_PRICE
    ,NPR_MEAS       => rDELIVERYORDSBUF.PR_MEAS
    ,NSTORE         => rDELIVERYORDSBUF.STORE
    ,NPOSREDUCT     => rDELIVERYORDSBUF.POSREDUCT
    ,SNOTE          => rDELIVERYORDSBUF.NOTE
    ,NMDMNOMEN      => rDELIVERYORDSBUF.MDMNOMEN
    ,NPERFS_STATE   => rDELIVERYORDPSBUF.PERFS_STATE
    ,DCS_DATE       => rDELIVERYORDPSBUF.CS_DATE
    ,DACTPF_DATE    => rDELIVERYORDPSBUF.ACTPF_DATE
    ,DCUST_DATE     => rDELIVERYORDPSBUF.CUST_DATE
    ,DEXEC_DATE     => rDELIVERYORDPSBUF.EXEC_DATE
    ,NACTM_QUANT    => rDELIVERYORDPSBUF.ACTM_QUANT
    ,NACTA_QUANT    => rDELIVERYORDPSBUF.ACTA_QUANT
    ,NCUSTM_QUANT   => rDELIVERYORDPSBUF.CUSTM_QUANT
    ,NCUSTA_QUANT   => rDELIVERYORDPSBUF.CUSTA_QUANT
    ,NEXECM_QUANT   => rDELIVERYORDPSBUF.EXECM_QUANT
    ,NEXECA_QUANT   => rDELIVERYORDPSBUF.EXECA_QUANT
    ,NACTSWTAX      => rDELIVERYORDPSBUF.ACTSWTAX
    ,NACTSWOTAX     => rDELIVERYORDPSBUF.ACTSWOTAX
    ,NCUSTSWTAX     => rDELIVERYORDPSBUF.CUSTSWTAX
    ,NCUSTSWOTAX    => rDELIVERYORDPSBUF.CUSTSWOTAX
    ,NEXECSWTAX     => rDELIVERYORDPSBUF.EXECSWTAX
    ,NEXECSWOTAX    => rDELIVERYORDPSBUF.EXECSWOTAX
    ,NIGNOREPERF    => 0
    ,NFLAG_DEL_CALC => 1
    );
  end DELIVERYORDSBUF_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_UPDATE
  /*
  Спецификация. Исправление (снимается утверждение с заказа и спецификаций, удаляется и вновь добавляется спецификация с новыми параметрами)
  */
  (
   rV_ROW           in v_deliveryords%rowtype
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_Row2         v_deliveryords%rowtype := rV_ROW;

  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_deliveryords_update(ncompany       => rV_Row2.ncompany
                           ,nrn            => rV_Row2.nrn
                           ,snomen         => rV_Row2.snomen
                           ,snom_pack      => rV_Row2.snom_pack
                           ,snom_modif     => rV_Row2.snom_modif
                           ,snommod_pack   => rV_Row2.snommod_pack
                           ,sproduct       => rV_Row2.sproduct
                           ,stax_group     => rV_Row2.stax_group
                           ,nexp_price     => rV_Row2.nexp_price
                           ,npr_meas       => rV_Row2.npr_meas
                           ,sstore         => rV_Row2.sstore
                           ,nposreduct     => rV_Row2.nposreduct
                           ,snote          => rV_Row2.snote
                           ,nperfs_state   => rV_Row2.nperfs_state
                           ,dcs_date       => rV_Row2.dcs_date
                           ,dactpf_date    => rV_Row2.dactpf_date
                           ,dcust_date     => rV_Row2.dcust_date
                           ,dexec_date     => rV_Row2.dexec_date
                           ,nactm_quant    => rV_Row2.nactm_quant
                           ,nacta_quant    => rV_Row2.nacta_quant
                           ,ncustm_quant   => rV_Row2.ncustm_quant
                           ,ncusta_quant   => rV_Row2.ncusta_quant
                           ,nexecm_quant   => rV_Row2.nexecm_quant
                           ,nexeca_quant   => rV_Row2.nexeca_quant
                           ,nactswtax      => rV_Row2.nactswtax
                           ,nactswotax     => rV_Row2.nactswotax
                           ,ncustswtax     => rV_Row2.ncustswtax
                           ,ncustswotax    => rV_Row2.ncustswotax
                           ,nexecswtax     => rV_Row2.nexecswtax
                           ,nexecswotax    => rV_Row2.nexecswotax
                           );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Очистка заголовка */
      usr_pkg_deliveryord.deliveryord_clear_for_update( nrn => rV_Row2.nprn, nmode => 0 );

      /* Исправление спецификации */
      rV_Row2.nperfs_state := 0;
      deliveryords_update( rv_row => rV_Row2, nmode => 0 );

      /* Восстановление заголовка */
      usr_pkg_deliveryord.deliveryord_clear_for_update( nrn => rV_Row2.nprn, nmode => 1 );
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end DELIVERYORDS_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_DELETE
  /*
  Спецификация. Удаление (снимается утверждение с заказа и спецификаций, удаляется и вновь добавляется спецификация с новыми параметрами)
  */
  (
   RDELIVERYORDS  in deliveryords%rowtype
  ) 
  is
    rDeliveryOrd    deliveryord%rowtype;
  begin
    -- Заголовок
    rDeliveryOrd := deliveryord_get(RDELIVERYORDS.PRN);
      
    -- Отключение регистрации
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
    -- Изменение статуса на "неподтвержден" в заголовке и исполнениях спецификаций
    update deliveryord 
       set ord_state = 0 
     where rn = rDeliveryOrd.rn;
    update deliveryordps 
       set perfs_state = 0 
     where prn in (select dos.rn from deliveryords dos where dos.prn = rDeliveryOrd.rn);
    -- Включение регистрации
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
       
    -- Исправление спецификации
    pkg_doclinks_smart.smart_link(rDeliveryOrd.rn, 'DeliveryOrders' );
    p_deliveryords_delete(RDELIVERYORDS.company, RDELIVERYORDS.rn);
    pkg_doclinks_smart.hard_link(rDeliveryOrd.rn, 'DeliveryOrders' );

    -- Отключение регистрации
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
    -- Возвращение предыдущего статуса заголовку, а спецификации - по статусу заголовка
    update deliveryord 
       set ord_state = rDeliveryOrd.ord_state 
     where rn = rDeliveryOrd.rn;
    update deliveryordps 
       set perfs_state = deliveryords_get_state_by_head(rDeliveryOrd.ord_state) 
     where prn in (select dos.rn from deliveryords dos where dos.prn = rDeliveryOrd.rn);
    -- Включение регистрации
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

  end DELIVERYORDS_DELETE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW             in deliveryords%rowtype
  ,rDELIVERYORDPS   in deliveryordps%rowtype
  ,nDUP_RN          in number default null
  ,nIGNOREPERF      in number default 0
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN              out number
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_deliveryords_base_insert(ncompany     => rROW.company
                                ,nprn         => rROW.prn
                                ,nnomen       => rROW.nomen
                                ,nnom_pack    => rROW.nom_pack
                                ,nnom_modif   => rROW.nom_modif
                                ,nnommod_pack => rROW.nommod_pack
                                ,nproduct     => rROW.product
                                ,ntax_group   => rROW.tax_group
                                ,nexp_price   => rROW.exp_price
                                ,npr_meas     => rROW.pr_meas
                                ,nstore       => rROW.store
                                ,nposreduct   => rROW.posreduct
                                ,snote        => rROW.note
                                ,nmdmnomen    => rROW.mdmnomen
                                ,ndup_rn      => nDUP_RN
                                ,dactpf_date  => rDELIVERYORDPS.ACTPF_DATE
                                ,nactm_quant  => rDELIVERYORDPS.ACTM_QUANT
                                ,nacta_quant  => rDELIVERYORDPS.ACTA_QUANT
                                ,nactswtax    => rDELIVERYORDPS.ACTSWTAX
                                ,nactswotax   => rDELIVERYORDPS.ACTSWOTAX
                                ,nignoreperf  => nIGNOREPERF
                                ,nrn          => nRN );

    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/
    
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end DELIVERYORDS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in deliveryords%rowtype
  ,rDELIVERYORDPS   in deliveryordps%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rDeliveryOrdPS2 deliveryordps%rowtype := rDELIVERYORDPS;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_deliveryords_base_update( ncompany       => rROW.COMPANY
                                 ,nrn            => rROW.RN
                                 ,nnomen         => rROW.NOMEN
                                 ,nnom_pack      => rROW.NOM_PACK
                                 ,nnom_modif     => rROW.NOM_MODIF
                                 ,nnommod_pack   => rROW.NOMMOD_PACK
                                 ,nproduct       => rROW.PRODUCT
                                 ,ntax_group     => rROW.TAX_GROUP
                                 ,nexp_price     => rROW.EXP_PRICE
                                 ,npr_meas       => rROW.PR_MEAS
                                 ,nstore         => rROW.STORE
                                 ,nposreduct     => rROW.POSREDUCT
                                 ,snote          => rROW.NOTE
                                 ,nmdmnomen      => rROW.MDMNOMEN
                                 ,nperfs_state   => rDeliveryOrdPS2.perfs_state 
                                 ,dcs_date       => rDeliveryOrdPS2.cs_date
                                 ,dactpf_date    => rDeliveryOrdPS2.actpf_date
                                 ,dcust_date     => rDeliveryOrdPS2.cust_date
                                 ,dexec_date     => rDeliveryOrdPS2.exec_date
                                 ,nactm_quant    => rDeliveryOrdPS2.actm_quant
                                 ,nacta_quant    => rDeliveryOrdPS2.acta_quant
                                 ,ncustm_quant   => rDeliveryOrdPS2.custm_quant
                                 ,ncusta_quant   => rDeliveryOrdPS2.custa_quant
                                 ,nexecm_quant   => rDeliveryOrdPS2.execm_quant
                                 ,nexeca_quant   => rDeliveryOrdPS2.execa_quant
                                 ,nactswtax      => rDeliveryOrdPS2.actswtax
                                 ,nactswotax     => rDeliveryOrdPS2.actswotax
                                 ,ncustswtax     => rDeliveryOrdPS2.custswtax
                                 ,ncustswotax    => rDeliveryOrdPS2.custswotax
                                 ,nexecswtax     => rDeliveryOrdPS2.execswtax
                                 ,nexecswotax    => rDeliveryOrdPS2.execswotax
                                 ,nflag_del_calc => nFLAG_DEL_CALC );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Очистка заголовка перед исправлением */
      usr_pkg_deliveryord.deliveryord_clear_for_update( nrn => rROW.PRN, nmode => 0 );

      /* Исправление спецификации */
      rDeliveryOrdPS2.perfs_state := 0;
      deliveryords_base_update( rrow => rROW, rdeliveryordps => rDeliveryOrdPS2, nflag_del_calc => nFLAG_DEL_CALC, nmode => 0 );

      /* Восстановление заголовка после очистки */
      usr_pkg_deliveryord.deliveryord_clear_for_update( nrn => rROW.PRN, nmode => 1 );
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end DELIVERYORDS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_CHECK_DLOSC
  /*
  Спецификация. Проверка калькуляций 
  */
  (
   rROW   in deliveryords%rowtype
  ) 
  is
    nQuantPlanItog  pkg_std.tnumber := 0; 
    nQuantFactItog  pkg_std.tnumber := 0; 
  begin
    /* Если каталог Метрология */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rROW.CRN, shier_crn_list => usr_pkg_pub_const.ndlo_cat_mtlg) then

      /* Итоговое количество по калькуляциям текущей спецификации */
      begin
        select nvl(sum(quant_plan), 0)
              ,nvl(sum(quant_Fact), 0)
          into nQuantPlanItog
              ,nQuantFactItog
          from deliveryordcs
         where prn = rROW.RN;
      exception
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске калькуляций.'
                     ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rROW.RN)
                     ,cr||f_docdescrs_get_description('DeliveryOrders', rROW.PRN)); 
      end;

      /* Проверка суммы по количеству калькуляции и количеству спецификации */
      if nQuantPlanItog != rROW.main_quant then
        p_exception(0, 'Сумма по полю "Количество. План" в калькуляции <%s> не равно количеству в спецификации <%s>. %s%s'
                   ,nQuantPlanItog
                   ,rROW.main_quant
                   ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rROW.RN)
                   ,cr||f_docdescrs_get_description('DeliveryOrders', rROW.PRN)); 
      end if;                 
      /*if nQuantFactSum != rROW.main_quant then
        p_exception(0, 'Сумма по полю "Количество. Факт" в калькуляции <%s> не равно количеству в спецификации <%s>. %s%s'
                   ,nQuantFactSum
                   ,rROW.main_quant
                   ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rROW.RN)
                   ,cr||f_docdescrs_get_description('DeliveryOrders', rROW.PRN)); 
      end if;*/
    end if;                 

  end DELIVERYORDS_CHECK_DLOSC;
  /*#########################################################################################################*/

  procedure DELIVERYORDS_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации заказа подразделения
  */
  (
   rROW   in deliveryords%rowtype
  ) 
  is
    nBuyPlane           pkg_std.tref; 
    
    nNumber             pkg_std.tnumber; 
  begin
    /* Если каталог "Метрология;IT" */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rROW.CRN, shier_crn_list => '88804043;20958771') then

      /* Связанный план закупок */
      nBuyPlane := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                                        ,sout_unitcode  => 'DeliveryOrders'
                                                        ,nout_document  => rROW.PRN
                                                        ,sin_unitcode   => 'BuyPlanes');
      /* Если план закупок найден */
      if nBuyPlane is null then
        p_exception(0, 'Документ не связан по входу с разделом <%s>. %s%s'
                   ,f_unitlist_getname(sunitcode => 'BuyPlanes')
                   ,cr||f_docdescrs_get_description('DeliveryOrdersSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('DeliveryOrders', rRow.prn)); 
      end if;

      /* Связанный заказ подразделения */
/*      nDepartmentOrd := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                                             ,sout_unitcode  => 'DeliveryOrders'
                                                             ,nout_document  => rROW.PRN
                                                             ,sin_unitcode   => 'DepartmentsOrders');
      \* Если заказ подразделения найден*\
      if nDepartmentOrd is not null then                                                           
        \* аналогичная спецификация в заказе подразделения *\
        usr_pkg_departmentord.departmentords_get_by_params(nprn           => nDepartmentOrd
                                                          ,nnom_modif     => rROW.NOM_MODIF
                                                          ,nnommod_pack   => rROW.NOMMOD_PACK
                                                          ,rrow           => rDepartmentOrdS);
        \* количество остатка исполнения заказа подразделения *\
        usr_pkg_departmentord.departmentords_get_dlo_remain(rrow      => rDepartmentOrdS
                                                           ,ncalc_way => 0
                                                           ,nmod_sign => nNumber
                                                           ,nresult   => nDPOS_QuantRemain);
        \* если количество остатка исполнения заказа подразделения меньше нуля *\
        if nDPOS_QuantRemain < 0 then
          p_exception(0, 'Превышено количество в сформированных документах. Количество во входящем документе <%s>, превышение <%s>. %s%s'
                     ,rDepartmentOrdS.main_quant
                     ,nDPOS_QuantRemain
                     ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rRow.rn)
                     ,cr||f_docdescrs_get_description('DeliveryOrders', rRow.prn)); 

        end if;
      end if;
*/
    end if;
    
  end DELIVERYORDS_CHECK_INDOC;
  /*#########################################################################################################*/

  PROCEDURE DELIVERYORDS_GET_PAI_REMAIN
  /*
  Спецификация. Получить остаток исполнения по входящим счетам на оплату
  */
  (
   RROW          IN DELIVERYORDS%ROWTYPE
  ,NCALC_WAY     IN NUMBER  -- возвращать оставшееся: 0 - количество, 1 - сумму
  ,NMOD_SIGN    OUT NUMBER  -- спецификация включена во входящие счёта: 0 - нет, 1 - да
  ,NRESULT      OUT NUMBER  -- результат: количество или сумма по которым не сформированы входящие счета на оплату
  ) 
  IS
    nIdent          PKG_STD.tREF := GEN_IDENT; 
    rDELIVERYORD    DELIVERYORD%ROWTYPE;
    dMAX_PERF_DATE  DATE;
    nPERF_RN        PKG_STD.tREF; 
    nQUANT          PKG_STD.tNUMBER; 
    nSUMTAX         PKG_STD.tNUMBER; 
    nCURCOURS       PKG_STD.tNUMBER; 
    nCURBASECOURS   PKG_STD.tNUMBER; 
    nCurResult      PKG_STD.tNUMBER; 
    nBASE_CURRENCY  PKG_STD.tNUMBER; 
    rDELIVERYORDPS  DELIVERYORDPS%ROWTYPE;
  BEGIN
    -- Заказ. Заголовок 
    --if utilizer != 'KHOK' then
    rDELIVERYORD := DELIVERYORD_GET(RROW.PRN);
/*    else
      --RROW.PRN := 179021201;
      rDELIVERYORD := DELIVERYORD_GET(179021201);
      if utilizer = 'KHOK' then p_exception(0,RROW.PRN \*rDELIVERYORD.Ord_Numb || '-' || rDELIVERYORD..PERF_DATE*\); end if;
    end if;*/
    -- Даты
    select MIN(PERF_DATE)
      into dMAX_PERF_DATE
      from DELIVERYORDP
     where PRN = RROW.PRN and
           PERF_DATE >= /*dDATE*/rDELIVERYORD.ORD_DATE and
           COMPANY = RROW.COMPANY;

    if dMAX_PERF_DATE is null then
      select MAX(PERF_DATE)
        into dMAX_PERF_DATE
        from DELIVERYORDP
       where PRN = RROW.PRN and
             COMPANY = RROW.COMPANY;
    end if;
    if dMAX_PERF_DATE is null then
    --if utilizer != 'KHOK' then
      P_EXCEPTION( 0,'Запись исполнения заказа поставщику (RN: '||nvl(to_char(RROW.PRN),'<null>')||') не найдена.' );
/*    else
      dMAX_PERF_DATE := '30-JUN-2025';
    end if;*/
    end if;

    -- Исполнение. Заголовок
--    if utilizer != 'KHOK' then
    select RN
      into nPERF_RN 
      from DELIVERYORDP
     where COMPANY = RROW.COMPANY
       and PRN     = RROW.PRN
       and PERF_NUMB in (select MIN(PERF_NUMB) from DELIVERYORDP where PRN = RROW.PRN and PERF_DATE = dMAX_PERF_DATE and COMPANY = RROW.COMPANY);
/*    else
      nPERF_RN := 179021204;
    end if;*/

    -- Исполнение. Спецификация
--    if utilizer != 'KHOK' then
    select *
      into rDELIVERYORDPS
      from DELIVERYORDPS
     where COMPANY = rROW.COMPANY
       and PRN = rROW.RN;
/*    else
    select *
      into rDELIVERYORDPS
      from DELIVERYORDPS
     where COMPANY = rROW.COMPANY
       and PRN = 179021207;
    end if;*/

    -- курс валюты документа
    FIND_CURRENCY_BASE(RROW.COMPANY, nBASE_CURRENCY );
    if rDELIVERYORD.CURRENCY <> nBASE_CURRENCY then
      FIND_CURRENCY_COURSE( rDELIVERYORD.CURRENCY, 1, rDELIVERYORD.ORD_DATE, nCURCOURS, nCURBASECOURS, nCurResult );
      if nCurResult = 0 then
        nCURCOURS     :=1;
        nCURBASECOURS :=1;
      end if;
    end if;

    /* заполнение массива исходной спецификации из заказа */
    PKG_GOODSDOCS_CALC.INIT(RROW.COMPANY, nIdent);
    PKG_GOODSDOCS_SPEC.ADD_SPEC( nIdent, RROW.PRN, 'DeliveryOrders', RROW.RN, 'DeliveryOrdersSpec',
                                 null/*NOMENCLS*/, null/*UMEAS_MAIN*/,
                                 RROW.NOMEN, RROW.NOM_PACK, RROW.NOM_MODIF, RROW.NOMMOD_PACK, null/*nARTICLE*/,
                                 RROW.STORE, null/*nGOODSPARTY*/, null/*sSERNUMB*/, null/*nCOUNTRY*/, null/*sGTD*/,
                                 rDELIVERYORDPS.ACTM_QUANT, rDELIVERYORDPS.ACTSWTAX, rDELIVERYORD.CURRENCY, nCURCOURS, nCURBASECOURS);
    /* вычитание из исходной спецификации спецификаций всех порожденных из заказа документов. */
    PKG_GOODSDOCS_SPEC.SUB_DELIV_PAI_SPEC(nIdent, nPERF_RN, 'DeliveryOrdersPerform', nCALC_WAY);
    /* получение количества и суммы */
    PKG_GOODSDOCS_SPEC.GET_SPEC( nIdent, nQUANT, nSUMTAX, nMOD_SIGN );
    
    -- Результат
    CASE NCALC_WAY 
      WHEN 0 THEN
        nResult := nQUANT;
      WHEN 1 THEN
        nResult := nSUMTAX;
    ELSE
      p_exception(0, 'Неверное <%s> значение параметра <nCALC_WAY>. %s%ss'
                 ,nCALC_WAY
                 ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rROW.RN)
                 ,cr||f_docdescrs_get_description('DeliveryOrders', rROW.PRN));
    END CASE;
--end if;
  END DELIVERYORDS_GET_PAI_REMAIN;
/*#########################################################################################################*/

  function DELIVERYORDS_GET_STATE_BY_HEAD
  /*
  Спецификация (исполнение). Определение статуса по статусу заголовка
  */
  (
   NORD_STATE     in number -- статус заголовка
  ) 
  return number
  is
  begin
    -- Проверка
    if NORD_STATE not in (0, 1, 2, 3, 4 ) then
      p_exception(0, 'Неверное значение статуса %s', NORD_STATE); 
    end if;
    --  Результат    
    return(
           case NORD_STATE
             when 0 then 0
             when 1 then 3
             when 2 then 3
             when 3 then 4
             when 4 then 4
           end
          );
  end DELIVERYORDS_GET_STATE_BY_HEAD;
  /*#########################################################################################################*/

  function DELIVERYORDPS_GET
  /*
  Спецификация (исполнение). Считывание 
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordps%rowtype
  is
    rRow deliveryordps%rowtype;
  begin
    begin
      select * into rRow from DELIVERYORDPS where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'DELIVERYORDPS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DELIVERYORDPS'))
                   ,cr||sqlerrm);
    end;

    return(rRow);

  end DELIVERYORDPS_GET;
  /*#########################################################################################################*/

  function DELIVERYORDPS_GET_BY_PRN
  /*
  Спецификация (исполнение). Считывание по родителю
  */
  (
   nRN          in number /* RN родителя DELIVERYORDS */
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordps%rowtype
  is
    rRow deliveryordps%rowtype;
  begin
    begin
      select * into rRow from deliveryordps where prn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'DELIVERYORDPS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DELIVERYORDPS'))
                   ,cr||sqlerrm);
    end;

    return( rRow );

  end DELIVERYORDPS_GET_BY_PRN;
  /*#########################################################################################################*/

  function DELIVERYORDCS_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN          in number -- RN записи
  ,nFLAGSMART   in number default 0  
  ) 
  return deliveryordcs%rowtype
  is
    rRow deliveryordcs%rowtype;
  begin
    begin
      select * into rRow from deliveryordcs where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'DELIVERYORDCS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DELIVERYORDCS')));
    end;
    return(rRow);
  end DELIVERYORDCS_GET;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_AINSERT
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
    deliveryordcs_check_base(nrn => nRN, ncompany => nCOMPANY);
    /* Добавление, исправление, удаление */
    deliveryordcs_check_iud(nrn => nRN);

  end DELIVERYORDCS_AINSERT;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BUPDATE
  /*
  Спецификация (калькуляция). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DELIVERYORDCS_BUPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    deliveryordcs_check_base(nrn => nRN, ncompany => nCOMPANY);
    /* Добавление, исправление, удаление */
    deliveryordcs_check_iud(nrn => nRN);

  end DELIVERYORDCS_AUPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BDELETE
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
    deliveryordcs_check_iud(nrn => nRN);

  end DELIVERYORDCS_BDELETE;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow  deliveryordcs%rowtype;
  begin
    /* Считывание */
    rRow := deliveryordcs_get(nrn => nRN);

    if rRow.faceaccount is null then
      p_exception(0, 'Поле "Лицевой счёт (заказ)" не заполнено в калькуляции. %s%s'
                 ,cr||f_docdescrs_get_description('DeliveryOrdersSpecCalcs', rRow.rn)
                 ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rRow.prn)); 
    end if;                 
    if nvl(rRow.quant_plan, 0) = 0 then
      p_exception(0, 'Поле "Количество. План" не заполнено в калькуляции. %s%s'
                 ,cr||f_docdescrs_get_description('DeliveryOrdersSpecCalcs', rRow.rn)
                 ,cr||f_docdescrs_get_description('DeliveryOrdersSpec', rRow.prn)); 
    end if;                 

  end DELIVERYORDCS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  ) 
  is
    nHead         pkg_std.tref; 
    nSpec         pkg_std.tref; 
    nHeadState    pkg_std.tnumber; 
  begin
    /* Считывание RN заголовка, спецификации и статуса документа */
    begin
      select h.rn , h.ord_state, s.rn
        into nHead, nHeadState , nSpec
        from deliveryordcs c
            ,deliveryords  s
            ,deliveryord   h
       where c.rn = nRN
         and s.rn = c.prn
         and h.rn = s.prn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'DELIVERYORDCS');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'DELIVERYORDCS'))
                   ,cr||sqlerrm);
    end;

    /* Статус документа отличен от  "Не утверждён" */
    if nHeadState != 0 --and utilizer != 'KHOK'
    and not usr_pkg_common.is_lists_intersect(slist1 => 'DELIVERYORDCS_CHECK_IUD.1', slist2 => usr_pkg_pub_const.sexceptionlist) then 
      /* сообщение */
      p_exception(0, 'Запрещены изменения документа в статусе <%s>. %s%s.'
                 ,deliveryord_get_status_name(nord_state => nHeadState)
                 ,cr||f_docdescrs_get_description(sunitcode => 'DeliveryOrdersSpec', ndocument => nSpec)
                 ,cr||f_docdescrs_get_description(sunitcode => 'DeliveryOrders', ndocument => nHead));
    end if;

    /* Очистка списка исключений */
    usr_pkg_pub_const.sexceptionlist := null;

  end DELIVERYORDCS_CHECK_IUD;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое 
  */
  (
   rROW       in deliveryordcs%rowtype
  ,nRN        out number
  ) 
  is
  begin
    p_deliveryordcs_base_insert(ncompany      => rROW.COMPANY
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
                               ,nsubdiv       => rROW.SUBDIV
                               ,nrn           => nRN);
  end DELIVERYORDCS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое 
  */
  (
   rROW       in deliveryordcs%rowtype
  ) 
  is
  begin
    p_deliveryordcs_base_update(nrn           => rROW.RN
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
  end DELIVERYORDCS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure DELIVERYORDCS_GET_PAISC_QUANT
  /*
  Спецификация (калькуляция). Получить количество по калькуляциям входящих счетов на оплату
  */
  (
   nRN          in number
  ,nQUANT_PLAN  out number
  ,nQUANT_FACT  out number
  ) 
  is
  begin
    begin
      select nvl(sum(oclc.quant_plan), 0), nvl(sum(oclc.quant_fact), 0)
        into nQUANT_PLAN                 , nQUANT_FACT
        from deliveryordcs   clc
            ,deliveryords    sp
            ,doclinks        dl
            ,payaccinspec    osp
            ,payaccinspclc   oclc
       where clc.rn            = nRN
         and sp.rn             = clc.prn
         and dl.in_document    = sp.prn
         and dl.out_unitcode   = 'PaymentAccountsIn'
         and dl.out_document   = osp.prn
         and osp.nommodif      = sp.nom_modif
         and oclc.prn          = osp.rn
         and nvl(oclc.faceaccount, 0) = nvl(clc.faceaccount, 0)
         /*and cmp_num(oclc.cost_article, clc.cost_article) = 1*/;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при подсчёте количества по калькуляциям приходных накладных. %s', nRN); 
    end;
  end DELIVERYORDCS_GET_PAISC_QUANT;
/*#########################################################################################################*/

end USR_PKG_DELIVERYORD;
/
