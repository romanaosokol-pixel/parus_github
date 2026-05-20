create or replace package USR_PKG_DEPARTMENTORD is
  /*
  Package предназначен для работы с разделом "Заказы подразделений". Степанов М. 01/12/2020
  DepartmentsOrders             DEPARTMENTORD     DPO
  DepartmentsOrdersBuff         DEPARTMENTORDBUF  DPOB
  DepartmentsOrdersSpecs        DEPARTMENTORDS    DPOS
  DepartmentsOrdersSpecsCalcs   DEPORDSPCLC       DPOSC
  DepartmentsOrdersSpecsPerform DEPARTMENTORDPS   DPOSP
  */

  --#########################################################################################################

  function DEPARTMENTORD_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return departmentord%rowtype;
  --#########################################################################################################

  function DEPARTMENTORD_GET_BY_SERNUMB
  /*
  Заголовок. Поиск по серии
  */
  (
   nFLAGSMART       in number default 0
  ,nTOO_MANY_ROWS   in number default 0
  ,sSERNUMB         in number
  ) 
  return number;
  --#########################################################################################################

  procedure DEPARTMENTORD_AINSERT
  /*
  Заголовок. После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_BUPDATE
  /*
  Заголовок. Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_AUPDATE
  /*
  Заголовок. После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_BCONFIRM
  /*
  Заголовок. Перед подтверждением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_ACONFIRM
  /*
  Заголовок. После подтверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_BWOCONFIRM
  /*
  Заголовок. Перед снятием подтверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_AWOCONFIRM
  /*
  Заголовок. После снятия подтверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_BCLOSE
  /*
  Заголовок. Перед Закрытие
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_ACLOSE
  /*
  Заголовок. После Закрытие
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_BANNUL
  /*
  Заголовок. Перед Аннулирование
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_AANNUL
  /*
  Заголовок. После Аннулирование
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_AMAKETITD
  /*
  Заголовок. После формирования РН в подразделения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_AMAKEPRODORD
  /*
  Заголовок. После формирования Заказа на производство
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_AMAKEDELIVORD
  /*
  Заголовок. После формирования Заказа поставщику
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in departmentord%rowtype
  ,nSUM_OUT     out number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure DEPARTMENTORD_UPDATE
  /*
  Заголовок. Клиентское исправление
  */
  (
   rV_ROW        in v_departmentord%rowtype
  ,nFLAG_MODE    in number
  ,nSUM_OUT     out number
  );
  --#########################################################################################################

  FUNCTION DEPARTMENTORD_GET_STATUS_NAME
  /*
  Показать наименование состояния заголовка
  */
  (
   nORD_STATE    IN NUMBER -- номер статуса
  ) 
  RETURN VARCHAR2;
  --#########################################################################################################
  
  FUNCTION DEPARTMENTORD_GET_MAIN_PROD
  /*
   Показать RN мат. ресурс головного изделия (выдает набор всех головных изделий документа)
  */
  (
   nRn    IN DEPARTMENTORD.RN%type
  ) 
  RETURN fcmatresource.rn%type ;
  --#########################################################################################################
  
  
  procedure DEPARTMENTORD_MAKE_DELIVERYORD
  /*
  Заголовок. Формирование приходного ордера
  */
  (
   nIDENT     in number
  ,nCOMPANY   in number
  ,sCATALOG   in varchar2
  ,dDATE      in date
  ,sFACEACC   in varchar2
  ,aRNLIST    out udo_tp_numtable
  );
  --#########################################################################################################

  procedure DEPARTMENTORDBUF_BASE_UPDATE
  /*
  Заголовок (буфер). Базовое исправление
  */
  (
   rROW         in departmentordbuf%rowtype
  );
  --#########################################################################################################

  function DEPARTMENTORDS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN       in number
  ) 
  return DEPARTMENTORDS%ROWTYPE;
  --#########################################################################################################
  
  PROCEDURE DEPARTMENTORDS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,nTOO_MANY_ROWS     in number default 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,nPRN               in number
  ,nNOMEN             in number default null
  ,nNOM_PACK          in number default null
  ,nNOM_MODIF         in number default null
  ,nNOMMOD_PACK       in number default null
  ,nPR_MEAS           in number default null
  ,nPRODUCT           in number default null
  ,nMAIN_QUANT        in number default null
  ,nALT_QUANT         in number default null
  ,nEXP_PRICE         in number default null
  ,rROW               out departmentords%rowtype 
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_AINSERT
  /*
  Спецификация. После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_BUPDATE
  /*
  Спецификация. Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_AUPDATE
  /*
  Спецификация. После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_BDELETE
  /*
  Спецификация. Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_BCNFINS
  /*
  Спецификация. Перед Добавить после утверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_BCNFUPD
  /*
  Спецификация. Перед Исправить после утверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_INSERT_DPOSC
  /*
  Спецификация. Добавить калькуляцию
  */
  (
   nRN            in number
  ,nFACEACCOUNT   in number
  ,nQUANT         in number   /* Количество. Если не задано, то берётся из спецификации */
  ,nDPOSC         out number
  );
  --#########################################################################################################
  
  procedure DEPARTMENTORDS_GET_DLO_REMAIN
  /*
  Спецификация. Получить остаток исполнения по заказам поставщикам
  */
  (
   rROW         in departmentords%rowtype
  ,nCALC_WAY    in number -- возвращать оставшееся: 0 - количество, 1 - сумму
  ,nMOD_SIGN    out number -- спецификация включена во входящие счёта: 0 - нет, 1 - да
  ,nRESULT      out number -- результат: количество или сумма по которым не сформированы входящие счета на оплату
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_BASE_UPDATE
  /*
  Спецификация. Базовое исправление
  Количество в исполнение подставляем из спецификации
  */
  (
   rROW             in departmentords%rowtype
  ,nFROM_CHANGE     in number default 0  /* если ругается, пробуем здесь поставить 1 */
  ,nFLAG_DEL_CALC   in number default 0
  ,nSUM_OUT         out number
  ,nCALC_MODE       in number default 1  /* Количества и суммы в исполнении подменять значениями спецификации: 0 - нет, 1 - да */
  );
  --#########################################################################################################

  procedure DEPARTMENTORDS_UPDATE
  /*
  Спецификация. Исправление 
  Количество в исполнение подставляем из спецификации
  */
  (
   rV_ROW           in v_departmentords%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ,nSUM_OUT         out number
  ,nCALC_MODE       in number default 1  /* Количества и суммы в исполнении подменять значениями спецификации: 0 - нет, 1 - да */
  );
  --#########################################################################################################

  function DEPORDSPCLC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return depordspclc%rowtype;
  --#########################################################################################################

  procedure DEPORDSPCLC_AINSERT
  /*
  Спецификация. После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPORDSPCLC_BUPDATE
  /*
  Спецификация. Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPORDSPCLC_AUPDATE
  /*
  Спецификация. После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPORDSPCLC_BDELETE
  /*
  Спецификация. Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPORDSPCLC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  --#########################################################################################################

  function DEPARTMENTORDPS_GET
  /*
  Спецификация (исполнение). Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return departmentordps%rowtype;
  --#########################################################################################################

  function DEPARTMENTORDPS_GET_BY_DPOS
  /*
  Спецификация (исполнение). Поиск RN исполнения по спецификации
  */
  (
   nRN      in number -- RN записи
  ) 
  return number;
  --#########################################################################################################

  procedure DEPARTMENTORDPS_AINSERT
  /*
  Спецификация (исполнение). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDPS_BUPDATE
  /*
  Спецификация (исполнение). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDPS_AUPDATE
  /*
  Спецификация (исполнение). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDPS_BDELETE
  /*
  Спецификация (исполнение). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure DEPARTMENTORDPS_CHECK_BASE
  /*
  Спецификация (исполнение). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
--#########################################################################################################

end USR_PKG_DEPARTMENTORD;
/
create or replace package body USR_PKG_DEPARTMENTORD is

  --#########################################################################################################

  function DEPARTMENTORD_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number -- RN записи
  ) 
  return departmentord%rowtype
  is
    rRow departmentord%rowtype;
  begin
    begin
      select T.*
        into rRow
        from DEPARTMENTORD T
       where T.RN = nRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(nRN, GET_UNITLIST_CODE_TABLE(1, 'DEPARTMENTORD'));
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DEPARTMENTORD'))||'>.');
    end;
    return(rRow);
  end DEPARTMENTORD_GET;
  --#########################################################################################################

  function DEPARTMENTORD_GET_BY_SERNUMB
  /*
  Заголовок. Поиск по серии
  */
  (
   nFLAGSMART       in number default 0
  ,nTOO_MANY_ROWS   in number default 0
  ,sSERNUMB         in number
  ) 
  return number
  is
    nPayAccInSpec   pkg_std.tref; 
    nRef            pkg_std.tref; 
  begin
    /* Поиск спецификации входящего счёта */
    nPayAccInSpec := usr_pkg_goodsparties.goodsparties_get_indocs_data(ssernumb       => sSERNUMB
                                                                      ,nflagsmart     => nFLAGSMART
                                                                      ,ntoo_many_rows => nTOO_MANY_ROWS
                                                                      ,sparam         => 'nPAIS');
    /* Поиск заказа */
    begin
      select paisce.departmentord
        into nRef
        from payaccinspclc    paisc
            ,payaccinspclc_ex paisce
       where paisc.prn  = nPayAccInSpec
         and paisce.prn = paisc.rn;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найден документ в разделе <%s> по серии <%s>.'
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DEPARTMENTORD')), sSERNUMB);
      when too_many_rows then
        if nFLAGSMART = 0 then
          p_exception(nTOO_MANY_ROWS, 'Не найден документ в разделе <%s> по серии <%s>.'
                     ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DEPARTMENTORD')), sSERNUMB);
        end if;                   
      when others then
          p_exception(0, 'Неопределённая ситуация при поиске документа в разделе <%s> по серии <%s>.'
                     ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DEPARTMENTORD')), sSERNUMB);
    end;

    return(nRef);

  end DEPARTMENTORD_GET_BY_SERNUMB;
  --#########################################################################################################

  procedure DEPARTMENTORD_AINSERT
  /*
  Заголовок. После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            departmentord%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    -- Считывание
    -- rRow := DEPARTMENTORD_GET(nRN); 

    -- ПРОВЕРКИ
    -- Базовая
    DEPARTMENTORD_CHECK_BASE(nRN, nCOMPANY);

  end DEPARTMENTORD_AINSERT;
  --#########################################################################################################

  procedure DEPARTMENTORD_BUPDATE
  /*
  Заголовок. Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
    -- Считывание
    -- USR_PKG_PUB_CONST.RDEPARTMENTORD := DEPARTMENTORD_GET(nRN); 

  end DEPARTMENTORD_BUPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORD_AUPDATE
  /*
  Заголовок. После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     departmentord%rowtype;
    
  begin
    -- Считывание
    -- rRow := DEPARTMENTORD_GET(nRN); 

    -- ПРОВЕРКИ
    -- Базовая
    DEPARTMENTORD_CHECK_BASE(nRN, nCOMPANY);
    
  end DEPARTMENTORD_AUPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORD_BCONFIRM
  /*
  Заголовок. Перед подтверждением
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ) 
  is
    rRow  departmentord%rowtype;
    nfl   integer := 0;
  begin
    /* Считывание*/
    rRow := departmentord_get( nrn => nRN ); 
    usr_pkg_pub_const.rdepartmentord := rRow;

    for cur in ( select pr.rn
                       ,pr.code
                       ,pr.name
                   from departmentord t
                   join projectstage ps
                     on ps.faceacc = t.faceacc
                   join project pr
                     on pr.rn = ps.prn
                  where t.rn = nrn )
    loop
       --- Найден проект.
      /* 22/07/2025 KHOK. В Ремонтном Проекте 99 Ответственных добавляем в каждый этап 
         01/10/2025 KHOK. Для Свободного остатка 0000 Ответственные в Заказе подразделения */
      if cur.rn not in (57720547,156141477) then 
      -- Поверим, есть ли ответственный (Главный конструктор) для раздела
      begin
        select 1
          into nfl
          from udo_prjexec_list pe
         where pe.prn = cur.rn -- RN проекта
           and pe.exec_role = 0 --Ответственный (Главный конструктор) (признак 0)
              --- and pe.sign_depord = 1 -- Заказы подразделений Да  (Сначала без учета признака)
           and rownum = 1 -- Достаточно одного
        ;
      exception
        when no_data_found then
          p_exception(0
                     ,'Не определен ответственный (Главный конструктор) ' ||
                      'для раздела "Заказы подразделений". Его требуется определить перед отработкой заказа.' ||
                      chr(10) || chr(10) || 'Для проекта с кодом: "%s"' || chr(10) ||
                      'наименованием: "%s"' ||
                      chr(10) || 'Обратитесь к экономистам.'
                     ,cur.code
                     ,cur.name);
      end;
      
      begin
        select 1
          into nfl
          from udo_prjexec_list pe
         where pe.prn = cur.rn -- RN проекта
           and pe.exec_role = 0 --Ответственный (Главный конструктор) (признак 0)
           and pe.sign_depord = 1 -- Заказы подразделений Да
           and rownum = 1 -- Достаточно одного
        ;
      exception
        when no_data_found then
          p_exception(0
                     ,'У Ответственного (Главного конструктора) для раздела "Заказы подразделений" не поставлен признак доступности "Да". Его требуется установить перед отработкой заказа.' || 
                      chr(10) || 'Обратитесь к экономистам.' ||
                      chr(10) || chr(10) || 'Для проекта с кодом: "%s"' || 
                      chr(10) || 'наименованием: "%s"'
                     ,cur.code
                     ,cur.name);
      end;
      end if;

      nfl := 1; -- есть Проект с Этапом с таким ЛС
    end loop;

    /*Для каталогов IT и СГИ будем контролировать наличие калькуляции с лицевым счетом, присутствующим в 
     бюджетном распределении */
    if rRow.Crn in (20958317, 245535558)
      then
         /* Проверим, что статья лицевого задана и она входит в перечень контролируемых */
          
         begin
            
           select 1
             into nfl
             from faceacc f
            where f.rn = rRow.faceacc
                 /*Свойство статьи затрат IS_PEO = 1 , определяет обязательность контроля */
              and usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 218817422, 
                                                      sunitcode => 'FinPlanArticles', 
                                                      ndocument => f.ieelement) = 1;
         exception
           when no_data_found then
             nfl := 0;
         end;
          
      if nfl = 1
      then
        ---- Это контролируемая статья
        select count(fa.rn) into nfl from usr_t_alloc_arts fa where fa.faceacc_cost = rRow.faceacc;
            
        p_exception(nfl
                   ,'Не найдена строка бюджетного распределения с Лицевым счетом, указанным в Заказе подразделения.' 
                   || chr(10) ||'Обратитесь к экономистам.');
            
      end if;
    end if;

    /* ПРОВЕРКИ */
    /* 13/08/2025 KHOK. Утверждение Заказа подразделения только после обработки Сертификатчиками: Свойство Сертификация либо Да, либо Только импорт 
                        и Статус сертификации не Обработано */
    if  nvl( usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 68734548, ndocument => rRow.rn ), 'null' ) in ('Да', 'Только импорт')
    and rRow.cert_state != 2 then
      p_exception(0, 'Заказ подразделения не обработан отделом Сертификации. %s'
                 ,cr||cr||f_docdescrs_get_description( 'DepartmentsOrders', rRow.rn ) ); 
    end if;
    
    /* По спецификациям */
    for c in ( select * from departmentords where prn = rRow.rn )   
    loop
      /* Проверка после добавления */
      departmentords_ainsert( nrn => c.rn, ncompany => c.company );
      
      /* УМТС_Ответственный */
      if usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 180597323, ndocument => c.nomen ) is null then
        p_exception(0, 'В документе присутствует спецификация, у которой в Номенклаторе не задано свойство "УМТС. Ответственный закупщик". %s%s'
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'DepartmentsOrdersSpecs', ndocument => c.rn ) 
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'DepartmentsOrders'     , ndocument => c.prn ) ); 
      end if;
      /* УМТС. Группа номенклатуры */
      if usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 19579777, ndocument => c.nomen ) is null then
        p_exception(0, 'В документе присутствует спецификация, у которой в Номенклаторе не задано свойство "УМТС. Группа номенклатуры". %s%s'
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'DepartmentsOrdersSpecs', ndocument => c.rn ) 
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'DepartmentsOrders'     , ndocument => c.prn ) ); 
      end if;
    end loop;

  end departmentord_bconfirm;
  --#########################################################################################################

  procedure DEPARTMENTORD_ACONFIRM
  /*
  Заголовок. После подтверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          departmentord%rowtype;
  begin
    null;
    -- Считывание
    -- rRow := DEPARTMENTORD_GET(nRN); 
    
    /* ПРОВЕРКИ */
    /* Базовая */
    departmentord_check_base( nrn => nRN, ncompany => nCOMPANY );

    /* Очистка */
    usr_pkg_pub_const.rdepartmentord := null;

  end DEPARTMENTORD_ACONFIRM;
  --#########################################################################################################

  procedure DEPARTMENTORD_BWOCONFIRM
  /*
  Заголовок. Перед снятием подтверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          departmentord%rowtype;
  begin
    null;
    /* Считывание*/
    /*rRow := departmentord_get( nrn => nRN ); 
    usr_pkg_pub_const.rdepartmentord := rRow;*/

  end DEPARTMENTORD_BWOCONFIRM;
  --#########################################################################################################

  procedure DEPARTMENTORD_AWOCONFIRM
  /*
  Заголовок. После снятия подтверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;    
  end DEPARTMENTORD_AWOCONFIRM;
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_BCLOSE
  /*
  Заголовок. Перед Закрытие
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow    departmentord%rowtype;
    nIdent  pkg_std.tref; 
  begin
    /* Считывание*/
    rRow := departmentord_get( nrn => nRN ); 
    usr_pkg_pub_const.rdepartmentord := rRow;

    /* ПРОВЕРКИ */
    /* 02/03/2026. ПДО и ОМТС договорились, что не закрываем Заказы подразделений, пока не закрыт Заказ на производство */
    /* Получение списка заказов на производство */
    nIdent := f_doclinks_link_in_recurs_doc( nflag_mode    => 0
                                            ,sout_unitcode => 'DepartmentsOrders'
                                            ,nout_document => rRow.rn 
                                            ,sin_unitcode  => 'ProductionOrders' 
                                            ,nident        => rRow.rn );
    /* Если найдены входные документы */
    if nIdent is not null then
      /* По связанным входным документам */
      for c in ( select t.rn, t.ord_state
                   from selectlist        sl
                   join productord        t  on t.rn        = sl.document
                                            and t.ord_state not in ( 3, 4 ) /* 3-закрыт, 4-аннулирован */
                  where sl.ident  = nIdent )
      loop
        p_exception(0, 'Запрещено закрытие, т.к. входящий Заказ на производство "%s" имеет статус "%s".%s'
                   ,f_docdescrs_get_description( sunitcode => 'ProductionOrders', ndocument => c.rn )
                   ,usr_pkg_productord.productord_get_status_name( nord_state => c.ord_state )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'DepartmentsOrders', ndocument => rROW.RN ) );
      end loop;                  

      /* Очистка */
      p_selectlist_clear( nident => nIdent );
    end if;                                              

  end DEPARTMENTORD_BCLOSE;
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_ACLOSE
  /*
  Заголовок. После Закрытие
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;    
    /* Очистка */
    usr_pkg_pub_const.rdepartmentord := null;

  end DEPARTMENTORD_ACLOSE;
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_BANNUL
  /*
  Заголовок. Перед Аннулирование
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
    -- Считывание
    /*USR_PKG_PUB_CONST.RDEPARTMENTORD := DEPARTMENTORD_GET(nRN); */

    /* Если есть выходные связи */
    if nvl( f_doclinks_link_exists( sunitcode => 'DepartmentsOrders', ndocument => nRN ), -1 ) in ( 2, 3 ) then
      p_exception(0, 'Запрещено аннулирование, т.к. документ имеет связи по выходу.%s'
                 ,cr||cr|| f_docdescrs_get_description( sunitcode => 'DepartmentsOrders', ndocument => nRN ) );
    end if;                   

  end DEPARTMENTORD_BANNUL;
  /*#########################################################################################################*/

  procedure DEPARTMENTORD_AANNUL
  /*
  Заголовок. После Аннулирование
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;    
  end DEPARTMENTORD_AANNUL;
  --#########################################################################################################

  procedure DEPARTMENTORD_AMAKETITD
  /*
  Заголовок. После формирования РН в подразделения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select column_value from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable))) 
    loop
      /* проверка заголовка */
      usr_pkg_transinvdept.transinvdept_ainsert(nrn => c.column_value , ncompany => nCOMPANY);
    end loop;

  end DEPARTMENTORD_AMAKETITD;
  --#########################################################################################################

  procedure DEPARTMENTORD_AMAKEPRODORD
  /*
  Заголовок. После формирования Заказа на производство
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end DEPARTMENTORD_AMAKEPRODORD;
  --#########################################################################################################

  procedure DEPARTMENTORD_AMAKEDELIVORD
  /*
  Заголовок. После формирования Заказа поставщику
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
      usr_pkg_deliveryord.deliveryord_ainsert(nrn => c.column_value , ncompany => nCOMPANY);
    end loop;

  end DEPARTMENTORD_AMAKEDELIVORD;
  --#########################################################################################################

  procedure DEPARTMENTORD_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      departmentord%rowtype;
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Заголовок */
    rRow := departmentord_get(nrn => NRN);
    
    /* Снятие утверждения */
    if rRow.ord_state != 0 then
      p_departmentord_bset_state(nflag_smart  => 0
                                ,nflag_mode   => 0
                                ,ncompany     => rRow.company
                                ,nrn          => rRow.rn
                                ,nnew_state   => 0
                                ,dstate_date  => current_date
                                ,nreserv_sign => 1
                                ,nsign_warn   => 1
                                ,nsign_coord  => 1
                                ,nresult      => nNumber);
    end if;

  end DEPARTMENTORD_BDELETE;
  --#########################################################################################################

  procedure DEPARTMENTORD_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     departmentord%rowtype;
  begin
    /* Считывание */
    rRow := departmentord_get(nrn => nRN);
    
    /* Запрет использования подразделение модуль */
    if rRow.Subdiv = 1026748 then 
       P_Exception(0, 'Подразделение "Модуль" использовать в заказах запрещено. Выберите реальное подразделение заказа.');
    end if ;
    /* Если каталог Метрология */
    if rRow.crn = 88796919 then
      /* подразделение НЕ Отдел метрологии */
      if nvl(rRow.acc_subdiv, 0) != 89531486 then
        p_exception(0, 'Документ находится в каталоге <%s>, и в нём указано подразделение-исполнитель <%s>. Должно быть указано подразделение-исполнитель <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.acc_subdiv)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => 89531486)
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;                 
    /* Если каталог НЕ Метрология */
    else
      /* Если подразделение Отдел метрологии */
      if nvl(rRow.acc_subdiv, 0) = 89531486 then
        p_exception(0, 'Документ находится в каталоге <%s>, и в нём указано подразделение-исполнитель <%s>. Он должен находиться в каталоге <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.acc_subdiv)
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => 88796919)
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;                 
    end if;

    /* Если каталог IT */
    if rRow.crn = 20958317 then
      /* подразделение НЕ IT */
      if nvl(rRow.acc_subdiv, 0) != 7365434 then
        p_exception(0, 'Документ находится в каталоге <%s>, и в нём указано подразделение-исполнитель <%s>. Должно быть указано подразделение-исполнитель <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.acc_subdiv)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => 7365434)
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;                 
    /* Если каталог НЕ IT */
    else
      /* Если подразделение Отдел метрологии */
      if nvl(rRow.acc_subdiv, 0) = 7365434 then
        p_exception(0, 'Документ находится в каталоге <%s>, и в нём указано подразделение-исполнитель <%s>. Он должен находиться в каталоге <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.acc_subdiv)
                   ,get_acatalog_name_id(nflag_smart => 1, nrn => 20958317)
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;                 
    end if;

    /* Если каталог Метрология, IT */
    if rRow.crn in (88796919, 20958317) then
      /* заказчик ответственный не задан */
      if rRow.agent is null then
        p_exception(0, 'Не заполнено поле "Заказчик. Ответственный" . %s'
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;
      /* исполнитель ответственный не задан */
      if rRow.acc_agent is null then
        p_exception(0, 'Не заполнено поле "Исполнитель. Ответственный" . %s'
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;
      /* свойство НОМ_ЗЯВКИ не заполнено */
      if f_docs_props_get_str_value(nproperty => 8027721, sunitcode => 'DepartmentsOrders', ndocument => rRow.rn) is null then
        p_exception(0, 'Не заполнено свойство "Номер заявки". %s'
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rRow.rn)); 
      end if;    
    end if;

    /* Лицевой счёт не задан */
    if rRow.faceacc is null then
    null; /*07-04-2026  Городецкий, если лицевой счет не задан, то это закупка ВНЕ проекта */
     /* p_exception(0, 'Не заполнено поле "Заказчик. Лицевой счёт". %s'
                 ,cr||f_docdescrs_get_description( sunitcode => 'DepartmentsOrders', ndocument => rRow.rn ) ); */
    else
      /* Лицевой счёт не является ШПЗ */
      if cmp_num( usr_pkg_faceacc.faceacc_is_product_cost_code(nflagsmart => 1, nrn => rRow.faceacc ), 1 ) != 1 then
        p_exception(0, 'В поле "Заказчик. Лицевой счёт" указан лицевой счёт <%s>, который не является шифром производственных затрат (не связан с проектом). %s'
                   ,get_faceacc_numb_id( nflag_smart => 1, nrn => rRow.faceacc)
                   ,cr||f_docdescrs_get_description( sunitcode => 'DepartmentsOrders', ndocument => rRow.rn ) ); 
      end if;
    end if;

  end DEPARTMENTORD_CHECK_BASE;
  --#########################################################################################################

  procedure DEPARTMENTORD_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in departmentord%rowtype
  ,nSUM_OUT     out number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rDepartmentOrd    departmentord%rowtype;
    aRnlist           udo_tp_numtable := udo_tp_numtable(); 
    aRnlist2          udo_tp_numtable := udo_tp_numtable(); 
    nOrd_State        pkg_std.tnumber; 

    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_departmentord_base_update(ncompany      => rROW.COMPANY
                                 ,nrn           => rROW.RN
                                 ,njur_pers     => rROW.JUR_PERS
                                 ,sord_pref     => rROW.ORD_PREF
                                 ,sord_numb     => rROW.ORD_NUMB
                                 ,nagent        => rROW.AGENT
                                 ,nfaceacc      => rROW.FACEACC
                                 ,ngraphpoint   => rROW.GRAPHPOINT
                                 ,nsubdiv       => rROW.SUBDIV
                                 ,nord_doctype  => rROW.ORD_DOCTYPE
                                 ,dord_date     => rROW.ORD_DATE
                                 ,nord_state    => rROW.ORD_STATE
                                 ,dstate_date   => rROW.STATE_DATE
                                 ,ncurrency     => rROW.CURRENCY
                                 ,nstore        => rROW.STORE
                                 ,nacc_agent    => rROW.ACC_AGENT
                                 ,nacc_subdiv   => rROW.ACC_SUBDIV
                                 ,drelease_date => rROW.RELEASE_DATE
                                 ,nord_period   => rROW.ORD_PERIOD
                                 ,nusecalendar  => rROW.USECALENDAR
                                 ,nperiod_corr  => rROW.PERIOD_CORR
                                 ,nperiod_quant => rROW.PERIOD_QUANT
                                 ,nperiod_type  => rROW.PERIOD_TYPE
                                 ,nperiod_len   => rROW.PERIOD_LEN
                                 ,nemergord     => rROW.EMERGORD
                                 ,natsametime   => rROW.ATSAMETIME
                                 ,nfinacccnt    => rROW.FINACCCNT
                                 ,nfinartcl     => rROW.FINARTCL
                                 ,nplan_period  => rROW.PLAN_PERIOD
                                 ,snote         => rROW.NOTE
                                 ,sbarcode      => rROW.BARCODE
                                 ,nstore_in     => rROW.STORE_IN
                                 ,nflag_mode    => 0
                                 ,nsum_out      => nSUM_OUT);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Используем другую переменную, чтобы в ней можно было менять значения */
      rDepartmentOrd := rROW;

      /* Удаление выходных связей с планом закупок */
      usr_pkg_doclinks.doclinks_reset_out(nflagsmart    => 0
                                         ,ncompany      => rDepartmentOrd.company
                                         ,sin_unitcode  => 'DepartmentsOrders'
                                         ,nin_document  => rDepartmentOrd.rn
                                         ,sout_unitcode => 'BuyPlanes'
                                         ,aout_document => aRnlist
                                         ,nmode         => 0);
      usr_pkg_doclinks.doclinks_reset_out(nflagsmart    => 0
                                         ,ncompany      => rDepartmentOrd.company
                                         ,sin_unitcode  => 'DepartmentsOrders'
                                         ,nin_document  => rDepartmentOrd.rn
                                         ,sout_unitcode => 'BuyPlaneSpecs'
                                         ,aout_document => aRnlist2
                                         ,nmode         => 0);

      /* Изменение статуса на Не согласован */
      p_departmentord_set_state(nflag_smart  => 0
                               ,nflag_mode   => 0
                               ,ncompany     => rDepartmentOrd.company
                               ,nrn          => rDepartmentOrd.rn
                               ,nnew_state   => 0
                               ,dstate_date  => rDepartmentOrd.state_date
                               ,nreserv_sign => 0
                               ,nsign_warn   => 0
                               ,nresult      => nNumber
                               ,smsg         => sVarchar);

      /* Сохранение исходного статуса и подмена его в переменной */
      rDepartmentOrd.ord_state := 0;
      
      /* Исправление */
      departmentord_base_update(rrow => rDepartmentOrd, nsum_out => nNumber, nmode => 0);

      /* Восстановление выходных связей с планом закупок */
      usr_pkg_doclinks.doclinks_reset_out(nflagsmart    => 0
                                         ,ncompany      => rDepartmentOrd.company
                                         ,sin_unitcode  => 'DepartmentsOrders'
                                         ,nin_document  => rDepartmentOrd.rn
                                         ,sout_unitcode => 'BuyPlanes'
                                         ,aout_document => aRnlist
                                         ,nmode         => 1);
      usr_pkg_doclinks.doclinks_reset_out(nflagsmart    => 0
                                         ,ncompany      => rDepartmentOrd.company
                                         ,sin_unitcode  => 'DepartmentsOrders'
                                         ,nin_document  => rDepartmentOrd.rn
                                         ,sout_unitcode => 'BuyPlaneSpecs'
                                         ,aout_document => aRnlist2
                                         ,nmode         => 1);
      /* Возвращение исходного статуса */
      p_departmentord_set_state(nflag_smart  => 0
                               ,nflag_mode   => 0
                               ,ncompany     => rDepartmentOrd.company
                               ,nrn          => rDepartmentOrd.rn
                               ,nnew_state   => rROW.ord_state
                               ,dstate_date  => rROW.state_date
                               ,nreserv_sign => 0
                               ,nsign_warn   => 0
                               ,nresult      => nNumber
                               ,smsg         => sVarchar);
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end DEPARTMENTORD_BASE_UPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORD_UPDATE
  /*
  Заголовок. Клиентское исправление
  */
  (
   rV_ROW        in v_departmentord%rowtype
  ,nFLAG_MODE    in number
  ,nSUM_OUT     out number
  ) 
  is
  begin
    p_departmentord_update(ncompany      => rV_ROW.ncompany
                          ,nrn           => rV_ROW.nrn
                          ,sjur_pers     => rV_ROW.sjur_pers
                          ,sord_pref     => rV_ROW.sord_pref
                          ,sord_numb     => rV_ROW.sord_numb
                          ,sagent        => rV_ROW.sagent
                          ,sfaceacc      => rV_ROW.sfaceacc
                          ,sgraphpoint   => rV_ROW.sgraphpoint
                          ,ssubdiv       => rV_ROW.ssubdiv
                          ,sord_doctype  => rV_ROW.sord_doctype
                          ,dord_date     => rV_ROW.dord_date
                          ,nord_state    => rV_ROW.nord_state
                          ,dstate_date   => rV_ROW.dstate_date
                          ,scurrency     => rV_ROW.scurrency
                          ,sstore        => rV_ROW.sstore
                          ,sacc_agent    => rV_ROW.sacc_agent
                          ,sacc_subdiv   => rV_ROW.sacc_subdiv
                          ,drelease_date => rV_ROW.drelease_date
                          ,nord_period   => rV_ROW.nord_period
                          ,nusecalendar  => rV_ROW.nusecalendar
                          ,nperiod_corr  => rV_ROW.nperiod_corr
                          ,nperiod_quant => rV_ROW.nperiod_quant
                          ,nperiod_type  => rV_ROW.nperiod_type
                          ,nperiod_len   => rV_ROW.nperiod_len
                          ,nemergord     => rV_ROW.nemergord
                          ,natsametime   => rV_ROW.natsametime
                          ,sfinacccnt    => rV_ROW.sfinacccnt
                          ,sfinartcl     => rV_ROW.sfinartcl
                          ,splan_period  => rV_ROW.splan_period
                          ,snote         => rV_ROW.snote
                          ,sbarcode      => rV_ROW.sbarcode
                          ,sstore_in     => rV_ROW.sstore_in
                          ,nflag_mode    => nFLAG_MODE
                          ,nsum_out      => nSUM_OUT);
  end DEPARTMENTORD_UPDATE;
  --#########################################################################################################

  FUNCTION DEPARTMENTORD_GET_STATUS_NAME
  /*
  Показать наименование состояния заголовка
  */
  (
   nORD_STATE    IN NUMBER -- номер статуса
  ) 
  return VARCHAR2
  IS
  begin
    RETURN(CASE NORD_STATE
             when 0 then 'Не утверждён'
             when 1 then 'Утверждён'
             when 2 then 'Согласование' 
             when 3 then 'Закрыт' 
             when 4 then 'Аннулирован'
             ELSE null
           END);
  END DEPARTMENTORD_GET_STATUS_NAME;
  --#########################################################################################################
  
 function DEPARTMENTORD_GET_MAIN_PROD
 /*
   Показать RN мат. ресурс головного изделия (выдает набор всех головных изделий документа)
   */
 (nrn in departmentord.rn%type) return fcmatresource.rn%type is
 
   nres fcmatresource.rn%type;
 begin
   begin
     select distinct mr.rn
       into nres
       from doclinks dl2
       join doclinks dl3
         on dl3.out_document = dl2.in_document
        and dl3.in_unitcode = 'ProductionOrdersSpecs'
       join productords zps
         on zps.rn = dl3.in_document
       join fcmatresource mr
         on mr.nomen_modif = zps.nom_modif
      where dl2.out_document = nrn
        and dl2.in_unitcode = 'CostProductExpenseActs'
        and dl2.out_unitcode = 'DepartmentsOrders'
        and rownum = 1; --- У заказа подразделений должно быть ТОЛЬКО одно головное изделия (в старых документах не так!)
   
   exception
     when no_data_found then
       nres := null;
   end;
 
   return nres;
 end;
  
  --#########################################################################################################
  
  procedure DEPARTMENTORD_MAKE_DELIVERYORD
  /*
  Заголовок. Формирование приходного ордера
  */
  (
   nIDENT     in number
  ,nCOMPANY   in number
  ,sCATALOG   in varchar2
  ,dDATE      in date
  ,sFACEACC   in varchar2
  ,aRNLIST    out udo_tp_numtable
  ) 
  is
    nFaceAcc            pkg_std.tref;
    nAgent              pkg_std.tref;
    rDeliveryOrdBuf     deliveryordbuf%rowtype;
    rDeliveryOrdPsBuf   deliveryordpsbuf%rowtype;
    nCatalog            pkg_std.tref; 
    nCount              pkg_std.tnumber := 0; 
  
    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring; 
  begin
    /* Каталог Заказов поставщикам */
    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => nCOMPANY
                      ,nversion    => null
                      ,sunitcode   => 'DeliveryOrders'
                      ,sname       => sCATALOG
                      ,nrn         => nCatalog);
    /* Лицевой счёт Заказов поставщикам */
    p_faceacctrade_getattr(ncompany       => nCOMPANY
                          ,sfaceacc       => sFACEACC
                          ,nfaceacc       => nFaceAcc
                          ,nagent         => nAgent
                          ,sagent         => sVarchar
                          ,nagnacc        => nNumber
                          ,sagnacc        => sVarchar
                          ,nreceiver      => nNumber
                          ,sreceiver      => sVarchar
                          ,nsender        => nNumber
                          ,ssender        => sVarchar
                          ,ntarif         => nNumber
                          ,starif         => sVarchar
                          ,npay_type      => nNumber
                          ,spay_type      => sVarchar
                          ,nship_type     => nNumber
                          ,sship_type     => sVarchar
                          ,ndiscount      => nNumber
                          ,ncurrency      => nNumber
                          ,scurrency      => sVarchar
                          ,nexecutive     => nNumber
                          ,sexecutive     => sVarchar
                          ,nsubdivision   => nNumber
                          ,ssubdivision   => sVarchar
                          ,svalid_doctype => sVarchar
                          ,svalid_docnumb => sVarchar
                          ,dvalid_docdate => sVarchar
                          ,sagn_trans     => sVarchar
                          ,saddr_agent    => sVarchar
                          ,saddr_agnacc   => sVarchar);
    /* Формирование буфера */
    p_departmentord_makedelivord(ncompany      => nCOMPANY
                                ,nident        => nIdent
                                ,ddate         => dDATE
                                ,nrel_time     => 0
                                ,npay_time     => 0
                                ,snom_group    => null
                                ,snom_catalog  => null
                                ,snomen        => null
                                ,sc_accsubdiv  => null
                                ,sc_accagent   => null
                                ,dsrl_date     => null
                                ,derl_date     => null
                                ,nflag_nullrec => 0
                                ,nmove_periods => 0
                                ,ntrue_rec     => nCount);
    /* если буфер не сформировался */
    if nCount = 0  then
      p_exception(0, 'Формирование не выполненно. %s'
                 ,cr||f_docdescrs_get_description('DepartmentsOrders', nIDENT)); 
    end if;
    
    /* По заголовкам буфера */
    for c in (select * from deliveryordbuf where ident = nIdent)
    loop
      /* считывание текущей записи в переменную */
      rDeliveryOrdBuf         := c;
      /* подмена значений в переменной */
      rDeliveryOrdBuf.faceacc := nFaceAcc;
      rDeliveryOrdBuf.agent   := nAgent;
      rDeliveryOrdBuf.crn     := nCatalog;
      /* исправление записи буфера */
      usr_pkg_deliveryord.deliveryordbuf_base_update(rrow => rDeliveryOrdBuf);
    end loop;
    
    /* Перенос из буфера */  
    p_deliveryordbuf_makedoc(ncompany => nCOMPANY, nident => nIdent, nmove_periods => 0);
    
    /* Очистка */
    p_selectlist_clear(nident => nIdent);
    p_deliveryordbuf_clean(ncompany => nCOMPANY, nident => nIdent);
  
    /* Список сформированных документов */
    aRNLIST := usr_pkg_pub_const.arnlist;

  end DEPARTMENTORD_MAKE_DELIVERYORD;
  --#########################################################################################################

  procedure DEPARTMENTORDBUF_BASE_UPDATE
  /*
  Заголовок (буфер). Базовое исправление
  */
  (
   rROW         in departmentordbuf%rowtype
  ) 
  is
  begin
    p_departmentordbuf_base_update(ncompany      => rROW.COMPANY
                                  ,ncrn          => rROW.CRN
                                  ,nrn           => rROW.RN
                                  ,njur_pers     => rROW.JUR_PERS
                                  ,sord_pref     => rROW.ORD_PREF
                                  ,sord_numb     => rROW.ORD_NUMB
                                  ,nagent        => rROW.AGENT
                                  ,nfaceacc      => rROW.FACEACC
                                  ,ngraphpoint   => rROW.GRAPHPOINT
                                  ,nsubdiv       => rROW.SUBDIV
                                  ,nord_doctype  => rROW.ORD_DOCTYPE
                                  ,dord_date     => rROW.ORD_DATE
                                  ,nord_state    => rROW.ORD_STATE
                                  ,dstate_date   => rROW.STATE_DATE
                                  ,ncurrency     => rROW.CURRENCY
                                  ,nstore        => rROW.STORE
                                  ,nacc_agent    => rROW.ACC_AGENT
                                  ,nacc_subdiv   => rROW.ACC_SUBDIV
                                  ,drelease_date => rROW.RELEASE_DATE
                                  ,nord_period   => rROW.ORD_PERIOD
                                  ,nusecalendar  => rROW.USECALENDAR
                                  ,nperiod_corr  => rROW.PERIOD_CORR
                                  ,nperiod_quant => rROW.PERIOD_QUANT
                                  ,nperiod_type  => rROW.PERIOD_TYPE
                                  ,nperiod_len   => rROW.PERIOD_LEN
                                  ,nemergord     => rROW.EMERGORD
                                  ,natsametime   => rROW.ATSAMETIME
                                  ,nplan_period  => rROW.PLAN_PERIOD
                                  ,snote         => rROW.NOTE
                                  ,sbarcode      => rROW.BARCODE
                                  ,nstore_in     => rROW.STORE_IN
                                  ,nflag_mode    => 1);
  end DEPARTMENTORDBUF_BASE_UPDATE;
  --#########################################################################################################

  function DEPARTMENTORDS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return departmentords%rowtype
  is
    rRow departmentords%rowtype;
  begin
    begin
      select T.*
        into rRow
        from DEPARTMENTORDS T
       where T.RN = nRN;
    exception
      when NO_DATA_FOUND then
        pkg_msg.record_not_found(nRN, GET_UNITLIST_CODE_TABLE(1, 'DEPARTMENTORDS'));
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||F_UNITLIST_GETNAME('DepartmentsOrdersSpec')||'>.');
    end;
    return(rRow);
  end DEPARTMENTORDS_GET;
  --#########################################################################################################
  
  PROCEDURE DEPARTMENTORDS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,nTOO_MANY_ROWS     in number default 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,nPRN               in number
  ,nNOMEN             in number default null
  ,nNOM_PACK          in number default null
  ,nNOM_MODIF         in number default null
  ,nNOMMOD_PACK       in number default null
  ,nPR_MEAS           in number default null
  ,nPRODUCT           in number default null
  ,nMAIN_QUANT        in number default null
  ,nALT_QUANT         in number default null
  ,nEXP_PRICE         in number default null
  ,rROW               out departmentords%rowtype 
  ) 
  IS
  begin
    begin
      select *
        into rRow
        from DEPARTMENTORDS T
       where T.PRN                  = NPRN
         and (NVL(T.NOMEN, 0)       = NVL(NNOMEN, 0) or (NNOMEN is null and NFLAG_OPTION = 1))
         and (NVL(T.NOM_PACK, 0)    = NVL(NNOM_PACK, 0) or (NNOM_PACK is null and NFLAG_OPTION = 1))
         and (NVL(T.NOM_MODIF, 0)   = NVL(NNOM_MODIF, 0) or (NNOM_MODIF is null and NFLAG_OPTION = 1))
         and (NVL(T.NOMMOD_PACK, 0) = NVL(NNOMMOD_PACK, 0) or (NNOMMOD_PACK is null and NFLAG_OPTION = 1))
         and (NVL(T.PR_MEAS, 0)     = NVL(NPR_MEAS, 0) or (NPR_MEAS is null and NFLAG_OPTION = 1))
         and (NVL(T.PRODUCT, 0)     = NVL(NPRODUCT, 0) or (NPRODUCT is null and NFLAG_OPTION = 1))
         and (NVL(T.MAIN_QUANT, 0)  = NVL(NMAIN_QUANT, 0) or (NMAIN_QUANT is null and NFLAG_OPTION = 1))
         and (NVL(T.ALT_QUANT, 0)   = NVL(NALT_QUANT, 0) or (NALT_QUANT is null and NFLAG_OPTION = 1))
         and (NVL(T.EXP_PRICE, 0)   = NVL(NEXP_PRICE, 0) or (NEXP_PRICE is null and NFLAG_OPTION = 1))
         ;
    exception
      when NO_DATA_FOUND then
        IF NFLAGSMART = 0 then
          P_EXCEPTION(0 ,'Не найдено спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DEPARTMENTORDS')));
        END IF;
      when TOO_MANY_ROWS then
        IF NTOO_MANY_ROWS = 0 and NFLAGSMART = 0 then
          P_EXCEPTION(0, 'Найдено больше одной спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DEPARTMENTORDS')));
        END IF;
      when OTHERS then
        P_EXCEPTION(0, 'Неопределённая ситуация при поиске спецификации для заголовка с RN <%s> записи в разделе <%s>'
                   ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'DEPARTMENTORDS')));
    END;
  END DEPARTMENTORDS_GET_BY_PARAMS;
  --#########################################################################################################

  procedure DEPARTMENTORDS_AINSERT
  /*
  Спецификация. После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              departmentords%rowtype;
    
    nNumber     pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow            := departmentords_get(nrn => nRN);

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая */
    DEPARTMENTORDS_CHECK_BASE(nRN, nCOMPANY);
    
  end DEPARTMENTORDS_AINSERT;
  
  --#########################################################################################################

  procedure DEPARTMENTORDS_BUPDATE
  /*
  Спецификация. Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPARTMENTORDS_BUPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORDS_AUPDATE
  /*
  Спецификация. После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    -- Проверка базовая
    DEPARTMENTORDS_CHECK_BASE(nRN, nCOMPANY);
  end DEPARTMENTORDS_AUPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORDS_BDELETE
  /*
  Спецификация. Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPARTMENTORDS_BDELETE;
  --#########################################################################################################

  procedure DEPARTMENTORDS_BCNFINS
  /*
  Спецификация. Перед Добавить после утверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    bExistsAllRights  boolean;
  begin
    /* Наличие у пользователя роли 'Все права' */
    for c in (select null from userroles where authid = utilizer and roleid = 90519)
    loop
      bExistsAllRights := true;
      exit;
    end loop;
    /* Запрет действия */
    if not bExistsAllRights then
      p_exception(0, 'Документ утверждён. Используйте Распоряжения об изменении.'); 
    end if;
  end DEPARTMENTORDS_BCNFINS;
  --#########################################################################################################

  procedure DEPARTMENTORDS_BCNFUPD
  /*
  Спецификация. Перед Исправить после утверждения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    bExistsAllRights  boolean;
  begin
    /* Наличие у пользователя роли 'Все права' */
    for c in (select null from userroles where authid = utilizer and roleid = 90519)
    loop
      bExistsAllRights := true;
      exit;
    end loop;
    /* Запрет действия */
    if not bExistsAllRights then
      p_exception(0, 'Документ утверждён. Используйте Распоряжения об изменении. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => nRN)); 
    end if;               
  end DEPARTMENTORDS_BCNFUPD;
  --#########################################################################################################

  procedure DEPARTMENTORDS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        departmentords%rowtype;
    rDicNomns   dicnomns%rowtype;
    nCount      pkg_std.tnumber := 0; 
  begin
    /* Считывание */
    rRow      := departmentords_get( nrn => nRN );
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rRow.nomen );

    /* ПРОВЕРКИ */
    /* Проверка отсутствия таких же спецификаций */
    select count(*)
      into nCount
      from departmentords 
     where prn         = rRow.prn 
       and nomen       = rRow.nomen
       and nom_modif   = rRow.nom_modif
       and main_quant != 0 ;
    if nCount > 1 then
      p_exception(0, 'В документе уже присутствует спецификация с такими же номенклатурой и модификацией. %s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rRow.rn ) 
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rRow.prn ) ); 
    end if;

    /* Если каталог номернклатуры "Я_НЕ ИСПОЛЬЗОВАТЬ (дубли)", "МЦСТ (НЕ ИСПОЛЬЗОВАТЬ В ИЗДЕЛИЯХ!)" */
    if rDicNomns.crn in ( 64228178,  51476137) then 
      p_exception(0, 'Запрещено использовать номенклатуру "%s", "%s", т.к. она находится в каталоге "%s". %s%s'
                 ,rDicNomns.nomen_code
                 ,rDicNomns.nomen_name
                 ,get_acatalog_name_id( nflag_smart => 1, nrn => rDicNomns.crn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rRow.rn ) 
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rRow.prn ) ); 
    end if;
    
  end DEPARTMENTORDS_CHECK_BASE;
  --#########################################################################################################

  procedure DEPARTMENTORDS_INSERT_DPOSC
  /*
  Спецификация. Добавить калькуляцию
  */
  (
   nRN            in number
  ,nFACEACCOUNT   in number
  ,nQUANT         in number   /* Количество. Если не задано, то берётся из спецификации */
  ,nDPOSC         out number
  ) 
  is
    rRow     departmentords%rowtype;
  begin
    rRow := departmentords_get(nrn => nRN);
    p_depordspclc_base_insert(ncompany      => rRow.company
                             ,nprn          => rRow.rn
                             ,snumb         => null
                             ,ncost_article => null
                             ,ncost_place   => null
                             ,ncost_plan    => null
                             ,ncost_fact    => null
                             ,npriority     => null
                             ,nfaceaccount  => nFACEACCOUNT
                             ,ngraphpoint   => null
                             ,nfinoper_type => null
                             ,nquant_plan   => nvl(nQUANT, rRow.main_quant)
                             ,nquant_fact   => nvl(nQUANT, rRow.main_quant)
                             ,nsubdiv       => null
                             ,nrn           => nDPOSC);
  end DEPARTMENTORDS_INSERT_DPOSC;
  --#########################################################################################################
  
  procedure DEPARTMENTORDS_GET_DLO_REMAIN
  /*
  Спецификация. Получить остаток исполнения по заказам поставщикам
  */
  (
   rROW         in departmentords%rowtype
  ,nCALC_WAY    in number -- возвращать оставшееся: 0 - количество, 1 - сумму
  ,nMOD_SIGN    out number -- спецификация включена во входящие счёта: 0 - нет, 1 - да
  ,nRESULT      out number -- результат: количество или сумма по которым не сформированы входящие счета на оплату
  ) 
  is
    nIdent         pkg_std.tref := gen_ident;
    rDepartmentOrd departmentord%rowtype;
    nQuant         pkg_std.tquant;
    nACTM_Quant    pkg_std.tquant; -- согласованное кол-во в ОЕИ
    nACTSumm       pkg_std.tsumm;  -- сумма с налогом
  begin
    /* Заголовок */
    rDepartmentOrd := departmentord_get(nrn => rROW.PRN);
  
    /* использование пакета PKG_GOODSDOCS_SPEC для определения количества по позициям спецификации */
    /* инициализация пакета */
    pkg_goodsdocs_spec.init(ncompany => rDepartmentOrd.company, nident => nIdent);
  
    /* "Количество согласованное в текущем периоде исполнения спецификации заказа" - "Количество исполненное фактическое" */
    nQuant := f_departmentordps_get_nparam(nflag_smart => 1
                                          ,nprn        => rROW.RN
                                          ,nflag_mode  => 0
                                          ,sparname    => 'ACTM_QUANT') 
                                          -
              f_departmentordps_get_nparam(nflag_smart => 1
                                          ,nprn        => rROW.RN
                                          ,nflag_mode  => 0
                                          ,sparname    => 'P_FACTM_QUANT');
    /* количество в ОЕИ > 0 */
    if (nQuant > 0) then
      pkg_goodsdocs_spec.add_spec(nident          => nIdent
                                 ,ndocument       => rDepartmentOrd.rn
                                 ,sunitcode       => 'DepartmentsOrders'
                                 ,ndocument1      => rROW.RN
                                 ,sunitcode1      => 'DepartmentsOrdersSpecs'
                                 ,nnomencls       => null
                                 ,numeas_main     => null
                                 ,nnomen          => rROW.nomen
                                 ,nnomnpack       => rROW.nom_pack
                                 ,nnommodif       => rROW.nom_modif
                                 ,nnomnmodifpack  => rROW.nommod_pack
                                 ,narticle        => rROW.product
                                 ,nstore          => rDepartmentOrd.store
                                 ,ngoodsparty     => null
                                 ,ssernumb        => null
                                 ,ncountry        => null
                                 ,sgtd            => null
                                 ,nquant          => nQuant
                                 ,nsumm           => f_departmentordps_get_nparam(nflag_smart => 1
                                                                                 ,nprn        => rROW.RN
                                                                                 ,nflag_mode  => 0
                                                                                 ,sparname    => 'ACTSUMM')
                                 ,ncurrency       => rDepartmentOrd.currency
                                 ,ncurcours       => null
                                 ,ncurbase        => null);
    end if;
  
    /* вычитание из исходной спецификации спецификаций всех порожденных заказов */
    pkg_goodsdocs_spec.sub_out_ord(nident    => nIDENT
                                  ,ndocument => rDepartmentOrd.rn
                                  ,sunitcode => 'DepartmentsOrders'
                                  ,ncalc_way => nCALC_WAY);
    /* вычисление количества */
    pkg_goodsdocs_spec.get_spec(nident    => nIdent
                               ,nquant    => nACTM_Quant
                               ,nsumm     => nACTSumm
                               ,nmod_sign => nMOD_SIGN);
    /* Результат */
    case nCALC_WAY
      when 0 then
        nRESULT := nACTM_Quant;
      when 1 then
        nRESULT := nACTSumm;
      else
        p_exception(0, 'Неверное <%s> значение параметра <nCALC_WAY>. %s%ss'
                   ,nCALC_WAY
                   ,cr||f_docdescrs_get_description('DepartmentsOrdersSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('DepartmentsOrders', rDepartmentOrd.rn));
    end case;
  
  end DEPARTMENTORDS_GET_DLO_REMAIN;
  --#########################################################################################################

  procedure DEPARTMENTORDS_BASE_UPDATE
  /*
  Спецификация. Базовое исправление
  Количество в исполнение подставляем из спецификации
  */
  (
   rROW             in departmentords%rowtype
  ,nFROM_CHANGE     in number default 0  /* если ругается, пробуем здесь поставить 1 */
  ,nFLAG_DEL_CALC   in number default 0
  ,nSUM_OUT         out number
  ,nCALC_MODE       in number default 1  /* Количества и суммы в исполнении подменять значениями спецификации: 0 - нет, 1 - да */
  ) 
  is
    nDepartmentOrdPS    pkg_std.tref; 
    rDepartmentOrdPS    departmentordps%rowtype;
  begin
    /* Считывание записи исполнения */
    nDepartmentOrdPS := departmentordps_get_by_dpos(nrn => rROW.RN);
    rDepartmentOrdPS := departmentordps_get(nrn => nDepartmentOrdPS);

    /* Подмена значений в исполнении */
    if nCALC_MODE = 1 then
      rDepartmentOrdPS.actm_quant  := rROW.MAIN_QUANT ;
      rDepartmentOrdPS.acta_quant  := rROW.ALT_QUANT  ;
      rDepartmentOrdPS.custm_quant := rROW.MAIN_QUANT ;
      rDepartmentOrdPS.custa_quant := rROW.ALT_QUANT  ;
      rDepartmentOrdPS.execm_quant := rROW.MAIN_QUANT ;
      rDepartmentOrdPS.execa_quant := rROW.ALT_QUANT  ;
      rDepartmentOrdPS.actsumm     := rROW.SUMM       ;
      rDepartmentOrdPS.custsumm    := rROW.SUMM       ;
      rDepartmentOrdPS.execsumm    := rROW.SUMM       ;
    elsif nCALC_MODE = 0 then
      null;
    else
      p_exception(0, 'Неверное значение <%s> параметра <nCALC_MODE>', nCALC_MODE); 
    end if;

    /* Исправление */
    p_departmentords_base_update(ncompany       => rROW.COMPANY
                                ,nrn            => rROW.RN
                                ,nnomencls      => rROW.NOMENCLS
                                ,nnomen         => rROW.NOMEN
                                ,nnom_pack      => rROW.NOM_PACK
                                ,nnom_modif     => rROW.NOM_MODIF
                                ,nnommod_pack   => rROW.NOMMOD_PACK
                                ,numeas_main    => rROW.UMEAS_MAIN
                                ,nproduct       => rROW.PRODUCT
                                ,nexp_price     => rROW.EXP_PRICE
                                ,nmin_price     => rROW.MIN_PRICE
                                ,nmax_price     => rROW.MAX_PRICE
                                ,npr_meas       => rROW.PR_MEAS
                                ,nstore         => rROW.STORE
                                ,nfinacccnts    => rROW.FINACCCNTS
                                ,nfinartcls     => rROW.FINARTCLS
                                ,snote          => rROW.NOTE
                                ,nagent         => rROW.AGENT
                                ,nstore_in      => rROW.STORE_IN
                                ,nmdmnomen      => rROW.MDMNOMEN
                                ,nperfs_state   => rDepartmentOrdPS.perfs_state
                                ,dcs_date       => rDepartmentOrdPS.cs_date
                                ,dactpf_date    => rDepartmentOrdPS.actpf_date
                                ,dcust_date     => rDepartmentOrdPS.cust_date
                                ,dexec_date     => rDepartmentOrdPS.exec_date
                                ,nactm_quant    => rDepartmentOrdPS.actm_quant  
                                ,nacta_quant    => rDepartmentOrdPS.acta_quant  
                                ,ncustm_quant   => rDepartmentOrdPS.custm_quant 
                                ,ncusta_quant   => rDepartmentOrdPS.custa_quant 
                                ,nexecm_quant   => rDepartmentOrdPS.execm_quant 
                                ,nexeca_quant   => rDepartmentOrdPS.execa_quant 
                                ,nactsumm       => rDepartmentOrdPS.actsumm     
                                ,ncustsumm      => rDepartmentOrdPS.custsumm    
                                ,nexecsumm      => rDepartmentOrdPS.execsumm    
                                ,nfrom_change   => nFROM_CHANGE
                                ,nsum_out       => nSUM_OUT
                                ,nflag_del_calc => nFLAG_DEL_CALC);
  end DEPARTMENTORDS_BASE_UPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORDS_UPDATE
  /*
  Спецификация. Исправление 
  */
  (
   rV_ROW           in v_departmentords%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ,nSUM_OUT         out number
  ,nCALC_MODE       in number default 1  /* Количества и суммы в исполнении подменять значениями спецификации: 0 - нет, 1 - да */
  ) 
  is
    rV_Row2   v_departmentords%rowtype  := rV_ROW;
  begin
    /* Подмена значений в исполнении */
    if nCALC_MODE = 1 then
      rV_Row2.Nactm_quant  :=  rV_Row2.nmain_quant;
      rV_Row2.Nacta_quant  :=  rV_Row2.nalt_quant;
      rV_Row2.ncustm_quant :=  rV_Row2.nmain_quant;
      rV_Row2.ncusta_quant :=  rV_Row2.nalt_quant;
      rV_Row2.nexecm_quant :=  rV_Row2.nmain_quant;
      rV_Row2.nexeca_quant :=  rV_Row2.nalt_quant;
      rV_Row2.nactsumm     :=  rV_Row2.nsumm;
      rV_Row2.ncustsumm    :=  rV_Row2.nsumm;
      rV_Row2.nexecsumm    :=  rV_Row2.nsumm;
    elsif nCALC_MODE = 0 then
      null;
    else
      p_exception(0, 'Неверное значение <%s> параметра <nCALC_MODE>', nCALC_MODE); 
    end if;

    /* Исправление */
    p_departmentords_update(ncompany       => rV_Row2.ncompany
                           ,nrn            => rV_Row2.nrn
                           ,snomencls      => rV_Row2.snomencls
                           ,snomen         => rV_Row2.snomen
                           ,snom_pack      => rV_Row2.snom_pack
                           ,snom_modif     => rV_Row2.snom_modif
                           ,snommod_pack   => rV_Row2.snommod_pack
                           ,sumeas_main    => rV_Row2.sumeas_main
                           ,sproduct       => rV_Row2.sproduct
                           ,nexp_price     => rV_Row2.nexp_price
                           ,nmin_price     => rV_Row2.nmin_price
                           ,nmax_price     => rV_Row2.nmax_price
                           ,npr_meas       => rV_Row2.npr_meas
                           ,sstore         => rV_Row2.sstore
                           ,sfinacccnts    => rV_Row2.sfinacccnts
                           ,sfinartcls     => rV_Row2.sfinartcls
                           ,snote          => rV_Row2.snote
                           ,sagent         => rV_Row2.sagent
                           ,sstore_in      => rV_Row2.sstore_in
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
                           ,nactsumm       => rV_Row2.nactsumm    
                           ,ncustsumm      => rV_Row2.ncustsumm   
                           ,nexecsumm      => rV_Row2.nexecsumm   
                           ,nsum_out       => nSUM_OUT
                           ,nflag_del_calc => nFLAG_DEL_CALC);

  end DEPARTMENTORDS_UPDATE;
  --#########################################################################################################

  function DEPORDSPCLC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return depordspclc%rowtype
  is
    rRow depordspclc%rowtype;
  begin
    begin
      select * into rRow from depordspclc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'DEPORDSPCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DEPORDSPCLC')));
    end;
    return(rRow);
  end DEPORDSPCLC_GET;
  --#########################################################################################################

  procedure DEPORDSPCLC_AINSERT
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
    depordspclc_check_base(nRN, nCOMPANY);
    
  end DEPORDSPCLC_AINSERT;
  --#########################################################################################################

  procedure DEPORDSPCLC_BUPDATE
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
  end DEPORDSPCLC_BUPDATE;
  --#########################################################################################################

  procedure DEPORDSPCLC_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    -- Проверка базовая
    depordspclc_check_base(nRN, nCOMPANY);
  end DEPORDSPCLC_AUPDATE;
  --#########################################################################################################

  procedure DEPORDSPCLC_BDELETE
  /*
  Спецификация (калькуляция). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPORDSPCLC_BDELETE;
  --#########################################################################################################

  procedure DEPORDSPCLC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPORDSPCLC_CHECK_BASE;
  --#########################################################################################################

  function DEPARTMENTORDPS_GET
  /*
  Спецификация (исполнение). Считывание
  */
  (
   nRN      in number -- RN записи
  ) 
  return departmentordps%rowtype
  is
    rRow departmentordps%rowtype;
  begin
    begin
      select * into rRow from departmentordps where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'DEPARTMENTORDPS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DEPARTMENTORDPS')));
    end;
    return(rRow);
  end DEPARTMENTORDPS_GET;
  --#########################################################################################################

  function DEPARTMENTORDPS_GET_BY_DPOS
  /*
  Спецификация (исполнение). Поиск RN исполнения по спецификации
  */
  (
   nRN      in number -- RN записи
  ) 
  return number
  is
    tRef    pkg_std.tref; 
  begin

    begin
      select rn into tRef from departmentordps where prn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'DEPARTMENTORDPS');
      when too_many_rows then
        p_exception(0, 'Найдено больше одной записи исполнения для спецификации. %s%s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => nRN));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске исполнения для спецификации. %s%s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => nRN));
    end;

    return(tRef);

  end DEPARTMENTORDPS_GET_BY_DPOS;
  --#########################################################################################################

  procedure DEPARTMENTORDPS_AINSERT
  /*
  Спецификация (исполнение). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    departmentordps_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end DEPARTMENTORDPS_AINSERT;
  --#########################################################################################################

  procedure DEPARTMENTORDPS_BUPDATE
  /*
  Спецификация (исполнение). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPARTMENTORDPS_BUPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORDPS_AUPDATE
  /*
  Спецификация (исполнение). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    departmentordps_check_base(nrn => nRN, ncompany => nCOMPANY);

  end DEPARTMENTORDPS_AUPDATE;
  --#########################################################################################################

  procedure DEPARTMENTORDPS_BDELETE
  /*
  Спецификация (исполнение). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPARTMENTORDPS_BDELETE;
  --#########################################################################################################

  procedure DEPARTMENTORDPS_CHECK_BASE
  /*
  Спецификация (исполнение). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DEPARTMENTORDPS_CHECK_BASE;
--#########################################################################################################

end USR_PKG_DEPARTMENTORD;
/
