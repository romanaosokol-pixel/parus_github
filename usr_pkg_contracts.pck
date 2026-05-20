create or replace package USR_PKG_CONTRACTS is

  /*
  Package предназначен для работы с разделом "Договоры". Степанов М. 11/12/2020
  Contracts
  ContractsStages
  FaceAccounts

  Если в договоре ручные суммы, то не должно быть лицевых счетов, иначе только расчётные суммы.
  Если в этапе ручные суммы, то не должно быть графиков, иначе только суммы по спецификации.
  */
  --#########################################################################################################

  function CONTRACTS_GET
  /*
  Договор. Считывание заголовка
  */
  (
   nRN          in number
  ,nFLAG_SMART  in number default 0
  )
  return CONTRACTS%rowtype;
  --#########################################################################################################

  function CONTRACTS_GET_DIRECT
  /*
  Договор. Направление: 0 - Покупка, 1- Продажа, 2 - Смешанный, 3 - Неопределён (лицевые счета остутствуют)
  */
  (
   NRN      in number
  )
  return number;
  --#########################################################################################################

  function CONTRACTS_GET_SALE_TYPE
  /*
  Договор. Тип продажи: 0 - Производство, 1 - ОКР, 2 - Коммерческий, 9 - Не определён
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default null
  ,nCOMPANY     in number
  )
  return number;
  --#########################################################################################################

  function CONTRACTS_GET_SALE_TYPE_NAME
  /*
  Договор. Наименование типа продажи
  */
  (
   nTYPE in number
  )
  return varchar2;
  --#########################################################################################################

  function CONTRACTS_GET_RESP_ECONOMIST
  /*
  Договор. Поиск мнемокода ответственного экономиста договора
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ,nCOMPANY   in number
  )
  return varchar2;
  --#########################################################################################################

  procedure CONTRACTS_BINSERT
  /*
  Договоры. Проверка перед добавлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_AINSERT
  /*
  Договоры. Проверка после добавления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );

  --#########################################################################################################
  procedure CONTRACTS_BUPDATE
  /*
  Договоры. Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_AUPDATE
  /*
  Договоры. Проверка после исправления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_BDELETE
  /*
  Договоры. Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_BPROCESS
  /*
  Договоры. Проверка после утверждения
  */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_APROCESS
  /*
  Договоры. Проверка после утверждения
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_ACLOSE
  /*
  Договоры. Проверка после закрытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure CONTRACTS_ACANCEL
  /*
  Договоры. Проверка после снятия утверждения
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################
  procedure CONTRACTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  PROCEDURE CONTRACTS_BASE_UPDATE
  /*
  Исправление договора базовое
  */
  (
   rCONTRACTS       in contracts%rowtype
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  PROCEDURE CONTRACTS_SUMM_RECALC
  /*
  Пересчёт сумм по договору
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  PROCEDURE CONTRACTS_UPDATE_SUM_TYPE
  /*
  Исправление признака "Расчётные суммы"
  */
  (
   nFLAGSMART     in number
  ,nRN            in number
  ,nSUM_TYPE      in number /* рассчётные сумм: 0 - нет, 1 - да */
  ,nTAXGR         in number default null
  ,nSUM           in number default null
  );
  --#########################################################################################################

  function STAGES_GET
  /*
  Договор (этапы). Считывание заголовка
  */
  (
   nRN          in number
  ,nFLAG_SMART  in number default 0
  )
  return STAGES%rowtype;
  --#########################################################################################################

  function STAGES_GET_BY_FACEACC
  /*
  Договор (этапы). Считывание заголовка по RN лицевого счёта
  */
  (
   nFACEACC     in number
  ,nFLAG_SMART  in number default 0
  )
  return stages%rowtype;
  --#########################################################################################################

  function STAGES_GET_STATUS_NAME
   /*
    Функция возвращает "Состояние"
    stages.status закрыт(0), открыт(1), анулирован(2), согласован(3) 
    Если stages.status = 0, а дата закрытия лицевого счета Faceacc.Fact_Close_Date is null , то состояние "Не открыт"    
  */
  (
    nrn in stages.rn%type
  )
  return varchar2;
   --#########################################################################################################

  function STAGES_GET_CPCL_SUM_BY_FPAC
  /*
  Этапы. Получить сумму из калькуляциий действующей структуры цены по списку статей затрат
  */
  (
   nFLAG_SMART    in number default 1
  ,nRN            in number
  ,sFPAC_LIST     in varchar2
  )
  return number;
  --#########################################################################################################

  procedure STAGES_BINSERT
  /*
  Договор (этапы). Проверка после добавления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure STAGES_AINSERT
  /*
  Договор (этапы).  Проверка после добавления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  );
  --#########################################################################################################

  procedure STAGES_BUPDATE
  /*
  Договор (этапы).  Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################
  procedure STAGES_AUPDATE
  /*
  Договор (этапы).  Проверка после исправления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );

  --#########################################################################################################
  procedure STAGES_BDELETE
  /*
  Договор (этапы).  Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure STAGES_BOPEN
  /*
  Договор (этапы).  Проверка до открытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure STAGES_AOPEN
  /*
  Договор (этапы).  Проверка после открытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure STAGES_BCLOSE
  /*
  Договор (этапы).  Проверка после закрытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure STAGES_ACLOSE
  /*
  Договор (этапы).  Проверка после закрытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  procedure STAGES_UPDATE
  /*
  Этапы. Исправление клиентское
  */
  (
   rV_ROW            in v_stages%rowtype
  ,rV_FACEACC        in v_faceacc%rowtype
  ,nFACEACC_EXIST     in number default 1  /* Лицевой счет: 0 - новый, 1 - существующий */
  ,nSIGN_DIR          in number default 0  /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ,nMODE              in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure STAGES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  );
  --#########################################################################################################

  PROCEDURE STAGES_BASE_UPDATE
  /*
  Исправление этапа базовое
  */
  (
   rSTAGES            in stages%rowtype
  ,rFACEACC           in faceacc%rowtype
  ,nSIGN_DIR          in number default 0  /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ,nMODE              in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  PROCEDURE STAGES_SUMM_RECALC
  /*
  Пересчёт сумм по этапу: сначала суммы исполнения, затем суммы этапа
  */
  (
   rSTAGES     in stages%rowtype
  ,rFACEACC    in faceacc%rowtype
  );
  --#########################################################################################################

  PROCEDURE STAGES_UPDATE_SUM_TYPE
  /*
  Исправление признака "Расчёт суммы"
  */
  (
   nFLAGSMART     in number
  ,nRN            in number
  ,nSUM_TYPE      in number   -- Рассчётные сумм: 0 - нет, 1 - да
  ,nTAXGR         in number default null
  ,nSUM           in number default null
  );
  --#########################################################################################################

  PROCEDURE STAGES_MAKE_DLO
  /*
  Спецификация. Сформировать заказ поставщику
  */
  (
   NCOMPANY        IN NUMBER
  ,NRN             IN NUMBER
  ,DDATE           IN DATE
  ,SACATALOG       IN VARCHAR2
  ,SDELIVDOCNUMB   IN VARCHAR2
  ,DDELIVDOCDATE   IN DATE
  ,DPAY_DATE       IN DATE
  ,DRELEASE_DATE   IN DATE
  ,SHEAD_NOTE      IN VARCHAR2
  ,SCURRENCY       IN VARCHAR2
  ,SFPAC           IN VARCHAR2
  ,SSUBDIV_FOR     IN VARCHAR2            -- Приобретено для
  ,SHPZ            IN VARCHAR2            -- ШПЗ
  ,NAPPROVE        IN NUMBER   DEFAULT 0  -- Утвердить
  ,NOUT_RN         OUT NUMBER             -- RN сформированного документа
  );
  --#########################################################################################################

  PROCEDURE STAGES_MAKE_PAI
  /*
  Спецификация. Сформировать входящий счёт на оплату
  */
  (
   NRN             in number
  ,NCOMPANY        in number -- RN компании
  ,NIDENT          in number
  ,DDATE           in date
  ,SACATALOG       in varchar2
  ,DPAY_DATE       in date
  ,SEXT_NUMB       in varchar2
  ,DREG_DATE       in date
  ,SHEAD_NOTE      in varchar2
  ,SCURRENCY       in varchar2
  ,SFPAC           in varchar2
  ,SSUBDIV         in varchar2 -- Подразделение для свойства входящего счёта на оплату
  ,SSUBDIV_FOR     in varchar2 -- Приобретено для
  ,SHPZ            in varchar2 -- ШПЗ
  ,SGOZ_SIGN       in varchar2 -- ПРИЗНАК ГОЗ ОПЛАТЫ
  ,STYPE           in varchar2 -- Тип ВСО
  ,NAPPROVE        in number   default 0 -- Утвердить
  ,NOUT_RN         out number  -- RN сформированного документа
  );
  --#########################################################################################################

  function STAGES_GET_SUM_TYPE_NAME
  /*
  Договор (этапы). Считывание заголовка
  */
  (
   nSUM_TYPE     in number
  )
  return varchar2;
   --#########################################################################################################

  procedure STAGES_AAPPROVE_CALC
  /*
    Договоры (этапы). Состоние . Утвердить калькуляцию. ПОСЛЕ
  */
  (
   nRn     in number
  );
   --#########################################################################################################

  function contrprstruct_get
  /*
    Договоры (этапы, структура цены). Считывание заголовка
    */
  (
    nrn         in number
   ,nflag_smart in number default 0
  ) return contrprclc%rowtype;

  --#########################################################################################################
  procedure contrprstruct_make_cntrl
  /* Договоры (этапы, структура цены). Проверка  на корректное значение, пересчет зависимых строк */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

  function contrprstruct_make_is_err
  /* Договоры (этапы, структура цены). Проверка  на корректное значение, пересчет зависимых строк */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  ) return number ;


  --#########################################################################################################
  procedure contrprstruct_set_act
   /*Договоры (этапы, структура цены) Контроль значений зависимых строк при смене состояния ПОСЛЕ*/
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

  --#########################################################################################################
  procedure contrprstruct_bapprove
  /* Договоры (этапы, структура цены) Контроль значений зависимых строк при установке признака (Действующая/Не действующая) . ДО */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

  --#########################################################################################################
  procedure contrprstruct_approve
  /* Договоры (этапы, структура цены) Контроль значений зависимых строк при установке признака (Действующая/Не действующая) . ПОСЛЕ */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

  --#########################################################################################################
  procedure contrprstruct_binsert
  /*
    Договоры (этапы, структура цены). Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

  --#########################################################################################################
  procedure contrprstruct_ainsert
  /* Договоры (этапы, структура цены).  Проверка после добавления */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure contrprstruct_bupdate
  /* Договоры (этапы, структура цены).  Проверка перед исправлением */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );
  --#########################################################################################################

  procedure contrprstruct_aupdate
  /*  Договоры (этапы, структура цены).  Проверка после исправления */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );
  --#########################################################################################################
  procedure contrprstruct_bdelete(nrn in number);

  procedure contrprstruct_adelete
  /* Договоры (этапы, структура цены).Калькуляция   Проверка перед исправлением */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );
  --#########################################################################################################

  function contrprclc_get
  /*
    Договор (этапы). Считывание заголовка
    */
  (
    nrn         in number
   ,nflag_smart in number default 0
  ) return contrprclc%rowtype;

  --#########################################################################################################
  procedure contrprclc_binsert
  /*
    Договор (этапы). Проверка после добавления
    */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

  --#########################################################################################################
  procedure contrprclc_ainsert
  /* Договор (этапы).  Проверка после добавления */
  (
    nrn      in number
   ,ncompany in number
  );
  --#########################################################################################################

  procedure contrprclc_bupdate
  /* Договор (этапы).  Проверка перед исправлением */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );
  --#########################################################################################################

  procedure contrprclc_aupdate
  /*  Договор (этапы).  Проверка после исправления */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );
  --#########################################################################################################
  procedure contrprclc_bdelete(nrn in number);

  procedure contrprclc_adelete
  /* Договор (этапы).Калькуляция   Проверка перед исправлением */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  );

--#########################################################################################################
procedure CONTRPRCLC_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
  );
 --#########################################################################################################

end USR_PKG_CONTRACTS;
/
create or replace package body USR_PKG_CONTRACTS is

  --#########################################################################################################

  function CONTRACTS_GET
  /*
  Договор. Считывание заголовка
  */
  (
   nRN          in number
  ,nFLAG_SMART  in number default 0
  )
  return contracts%rowtype
  is
    rRow contracts%rowtype;
  begin
    begin
      select * into rRow from contracts where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAG_SMART, ndocument => nRN, sunit_table => 'CONTRACTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'CONTRACTS')));
    end;
    return(rRow);
  end CONTRACTS_GET;
  --#########################################################################################################

  function CONTRACTS_GET_DIRECT
  /*
  Договор. Направление: 0 - Покупка, 1- Продажа, 2 - Смешанный, 9 - Неопределён (лицевые счета остутствуют)
  */
  (
   NRN      in number
  )
  return number
  is
    nResult   pkg_std.tcoeff;
  begin
    select sum(fa.acc_kind) / count(*)
      into nResult
      from stages st, faceacc fa
     where st.prn = NRN
       and fa.rn  = st.faceacc;

    if nResult is null then
      nResult := 9;
    elsif nResult = 0 then
      nResult := 0;
    elsif nResult = 1 then
      nResult := 1;
    else
      nResult := 2;
    end if;

    return(nResult );
  end CONTRACTS_GET_DIRECT;
  --#########################################################################################################

  function CONTRACTS_GET_SALE_TYPE
  /*
  Договор. Тип продажи: 0 - Производство, 1 - ОКР, 2 - Коммерческий, 9 - Не определён
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default null
  ,nCOMPANY     in number
  )
  return number
  is
    nCRN          pkg_std.tref;
    nProject      pkg_std.tref;
    sProjectType  project.code%type;
    nResult       pkg_std.tnumber;

    nNumber       pkg_std.tnumber;
  begin
    /* По проектам */
    for c in (
              select prj.rn, prjt.code, count(*)over() as ncount
                from doclinks dl, project prj, prjtype prjt
               where dl.out_document = nRN
                 and dl.in_unitcode  = 'Projects'
                 and dl.in_document  = prj.rn
                 and prj.prjtype     = prjt.rn
             )
    loop
      /* проверка количества связанных проектов */
      if c.ncount != 1 then
        p_exception(nFLAGSMART, 'Договор связан с более, чем одним проектом. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => nRN));
      end if;
      /* сохранение RN и мнемокода */
      nProject      := c.rn;
      sProjectType  := c.code;
    end loop;

    /* Проект есть */
    if nProject is not null then
      /* тип проекта - ОКР*/
      if nvl(sProjectType, 'null') in ('11', '12', '14', '15') then
        nResult := 1;
      /* иначе - Производство */
      else
        nResult := 0;
      end if;
    /* Проекта нет */
    else
      /* поиск каталога договора */
      p_contracts_exists(ncompany => nCOMPANY, nrn => nRN, ncrn => nCRN, njur_pers => nNumber );
      /* каталог договора Коммерция */
      if usr_pkg_common.is_crn_in_hiercrn(nCRN => nCRN, shier_crn_list => 7814275) then
        nResult := 2;
      else
        nResult := 9;
        p_exception(nFLAGSMART, 'Не удалось определить тип продажи договора. %s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => nRN));
      end if;
    end if;

    return(nResult );
    
  end CONTRACTS_GET_SALE_TYPE;
  --#########################################################################################################

  function CONTRACTS_GET_SALE_TYPE_NAME
  /*
  Договор. Наименование типа продажи
  */
  (
   nTYPE in number
  )
  return varchar2
  is
    sResult  pkg_std.tstring;
  begin
    sResult := case nTYPE
                 when 0 then 'Производство'
                 when 1 then 'ОКР'
                 when 2 then 'Коммерческий'
                 when 3 then 'Не определён'
               else
                 null
               end;
    return(sResult);
  end CONTRACTS_GET_SALE_TYPE_NAME;
  --#########################################################################################################

  function CONTRACTS_GET_RESP_ECONOMIST
  /*
  Договор. Поиск мнемокода ответственного экономиста договора
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ,nCOMPANY   in number
  )
  return varchar2
  is
    nSaleType     pkg_std.tnumber;
    nProject      pkg_std.tref; 
    sResult       pkg_std.tstring;
  begin
    /* Тип продажи */
    nSaleType := contracts_get_sale_type(nrn => nRN, nflagsmart => nFLAGSMART, ncompany => nCOMPANY);

    /* Не определён */
    if nSaleType = 9 then
      p_exception(nFLAGSMART, 'Не определён тип продажи договора. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => nRN));

    /* Производство, ОКР */
    elsif nSaleType in (0, 1) then
      /* Считываем из свойства в Проекте */
      nProject := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'Contracts'
                                                       ,nout_document  => nRN
                                                       ,sin_unitcode   => 'Projects');
      sResult := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, ndocument => nProject);

    /* Коммерческий */
    elsif nSaleType = 2 then
      /* Считываем из свойства в Договоре */
      sResult := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, ndocument => nRN);

    /* Неверный тип */
    else
      p_exception(nFLAGSMART, 'Неверный тип продажи договора. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => nRN));
    end if;

    /* Результат */
    return(sResult);

  end CONTRACTS_GET_RESP_ECONOMIST;
  --#########################################################################################################

  procedure CONTRACTS_BINSERT
  /*
  Договоры. Проверка перед добавлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    -- Очистка констант
    usr_pkg_pub_const.rcontracts := null;
  end CONTRACTS_BINSERT;
  --#########################################################################################################

  procedure CONTRACTS_AINSERT
  /*
  Договоры. Проверка после добавления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
    rContracts        contracts%rowtype;
    nStagesExists     pkg_std.tnumber := 0;
  begin
    /* Заголовок */
    rContracts   := CONTRACTS_GET(NRN);
    
   
    /* Нналичие этапов */
    for c in (select 1 from stages t where t.prn  = rContracts.rn) loop nStagesExists := 1; exit; end loop;

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    contracts_check_base(rContracts.rn, rContracts.company);

    -- Очистка констант
    usr_pkg_pub_const.rcontracts := null;

  end CONTRACTS_AINSERT;
  --#########################################################################################################

  procedure CONTRACTS_BUPDATE
  /*
  Договоры. Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    -- Считывание
    usr_pkg_pub_const.rcontracts := CONTRACTS_GET(NRN);
  end CONTRACTS_BUPDATE;
  --#########################################################################################################

  procedure CONTRACTS_AUPDATE
  /*
  Договоры. Проверка после исправления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
    rContracts    contracts%rowtype;
  begin
    -- Запись договора
    rContracts := CONTRACTS_GET(NRN);

    -- ПРОВЕРКИ
    -- Базовая
    
    CONTRACTS_CHECK_BASE(rContracts.rn, rContracts.company);

    /*-- Если исправляются тип, префикс, номер, дата договора
    if cmp_num(rContracts.doc_type, usr_pkg_pub_const.rcontracts.doc_type) != 1
    or cmp_vC2(rContracts.doc_pref, usr_pkg_pub_const.rcontracts.doc_pref) != 1
    or cmp_vC2(rContracts.doc_numb, usr_pkg_pub_const.rcontracts.doc_numb) != 1
    or cmp_dat(rContracts.doc_date, usr_pkg_pub_const.rcontracts.doc_date) != 1 then
      -- исправление разрешено делать только процедурой
      if NVL(usr_pkg_process.get_parus_process('Contracts'), 'null') not in ('CONTRACTS_UPDATE_DETAILS') then
        P_EXCEPTION(0, 'Исправление реквизитов договора разрешено делать только действием <'||GET_UNITFUNC_NAME_CODE(1, 'CONTRACTS_UPDATE_DETAILS')||'>. '||CR||
                        F_DOCDESCRS_GET_DESCRIPTION('Contracts', rContracts.rn));
      end if;
      -- проверка префикса и номера
      CONTRACTS_CHECK_PREF_NUMB(rContracts);
    end if;*/

    -- Очистка констант
    usr_pkg_pub_const.rStages := null;

  end CONTRACTS_AUPDATE;
  --#########################################################################################################

  procedure CONTRACTS_BDELETE
  /*
  Договоры. Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    null;

  end CONTRACTS_BDELETE;
  --#########################################################################################################

  procedure CONTRACTS_BPROCESS
  /*
  Договоры. Проверка после утверждения
  */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
  )
  is
    rRow              contracts%rowtype;
  begin
    /* Заголовок */
    rRow := contracts_get(nrn => NRN);
    usr_pkg_pub_const.rcontracts := rRow;

    /* Договор в каталоге ОМТС */
/*    if usr_pkg_common.is_crn_in_hiercrn(ncrn => rRow.crn, shier_crn_list => 6282354) then

      \* поиск присоединённого документа к договору *\
      nNumber := 0;
      for c in (select t.rn
                  from filelinksunits t
                 where t.table_prn = rRow.rn)
      loop
        nNumber := 1;
        exit;
      end loop;

      \* присоединённый документ не найден *\
      if cmp_num(nNumber, 0) = 1 then
        p_exception(0, 'К договору не присоединены документы. %s'
                   ,cr||f_docdescrs_get_description('Contracts', rRow.rn));
      end if;
    end if;*/

  end CONTRACTS_BPROCESS;
  --#########################################################################################################

procedure contracts_aprocess
/*
  Договоры. Проверка после утверждения
  */
(
  nrn      in number
 ,ncompany in number -- RN компании
) is
  rrow          contracts%rowtype;
  rjuracc       agnacc%rowtype;
  rbankacctypes bankacctypes%rowtype;
  rgovcntrid    govcntrid%rowtype;

  nnumber  pkg_std.tnumber;
  svarchar pkg_std.tstring;
  v_send varchar2(2000);
  v_nrn number(17);
  cText    pkg_std.tlstring;
  sTitle   pkg_std.tstring;
begin
  /* Заголовок */
  rrow := contracts_get(nrn => nrn);

  /* Реквизиты юр.лица */
  if rrow.jur_acc is not null
  then
    rjuracc := usr_pkg_agnlist.agnacc_get(nrn => rrow.jur_acc);
  end if;

  /* Тип банковского счёта юр.лица */
  if rjuracc.bankacc_type is not null
  then
    rbankacctypes := usr_pkg_agnlist.bankacctypes_get(nrn => rjuracc.bankacc_type);
  end if;

  /* ИГК */
  if rrow.govcntrid is not null
  then
    begin
      select * into rgovcntrid from govcntrid where rn = rrow.govcntrid;
    exception
      when no_data_found then
        p_exception(0
                   ,'Не найден ИГК для договора. %s'
                   ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                     ,ndocument => rrow.rn));
      when too_many_rows then
        p_exception(0
                   ,'Найдено больше одного ИГК для договора. %s'
                   ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                     ,ndocument => rrow.rn));
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при ИГК для договора.'
                   ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                     ,ndocument => rrow.rn));
    end;
  end if;

  /* ПРОВЕРКИ */

  /* Только если до утверждения статус был Не утверждён */
  if usr_pkg_pub_const.rcontracts.status = 0
  then
 
    /* Базовая */
    contracts_check_base(nrn      => nrn
                        ,ncompany => ncompany);
  
    /*Есди договор содержит  этапы в которых указана статья затрат 
          Тематические доходы (Бюджет), 
          Субсидии на разработки и 
          Продажа товаров в СНГ.
    */

    begin
      for cur in (select nvl(usr_f_cont_producttype_get(st.prn)
                            ,'НЕ ЗАДАН') tp
                    from stages st
                    join faceacc f
                      on f.rn = st.faceacc
                   where st.prn = nrn
                     and f.ieelement in (6172145 /* Продажа товаров вСНГ */
                                        ,6172140 /* Тематические доходы (Бюджет) */
                                        ,110949068 /* 06 Субсидии на разработки */)
                     and rownum = 1)
      loop
      
        if cur.tp = 'НЕ ЗАДАН'
        then
          p_exception(0
                     ,'Для договоров, этапы которых содержат статьи бюджета:"Продажа товаров вСНГ","Тематические доходы (Бюджет)","Субсидии на разработки", обязательно задавать "Тип продукции". По всем вопросам обращайтесь в ПЭО');
        end if;
      end loop;
    end;
  
    /* Если заполнен ИГК */
    if rgovcntrid.rn is not null
    then
      /* Если реквизит юр.лица НЕ "167524" */
      if cmp_num(rjuracc.rn
                ,1027894) != 1
      then
      
        /* Тип банковского реквизита юр.лица НЕ Специальный, УФК */
        if nvl(rbankacctypes.rn
              ,-999) not in (1080004
                            ,6525523)
        then
          p_exception(0
                     ,'В договоре указан ИГК. Банковский реквизит <%s> юр.лица <%s> должен иметь тип "Специальный" или "УФК". %s'
                     ,rjuracc.strcode
                     ,get_jurpersons_code_id(nflag_smart => 1
                                            ,njur_pers   => rrow.jur_pers)
                     ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                       ,ndocument => rrow.rn));
        end if;
      
        /* Банковский реквизит юр.лица отсутствует в ИГК */
        begin
          select null
            into nnumber
            from govcntridbanks
           where prn = rgovcntrid.rn
             and agnacc = rjuracc.rn;
        exception
          when no_data_found then
            p_exception(0
                       ,'Банковский реквизит <%s> юр.лица <%s> отсутствует в реквизитах для ИГК <%s>. %s'
                       ,rjuracc.strcode
                       ,get_jurpersons_code_id(nflag_smart => 1
                                              ,njur_pers   => rrow.jur_pers)
                       ,rgovcntrid.code
                       ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                         ,ndocument => rrow.rn));
          when too_many_rows then
            null;
          when others then
            p_exception(0
                       ,'Неопределённая ситуация при поиске банковского реквизита <%s> юр.лица <%s> в реквизитах для ИГК <%s>. %s'
                       ,rjuracc.strcode
                       ,get_jurpersons_code_id(nflag_smart => 1
                                              ,njur_pers   => rrow.jur_pers)
                       ,rgovcntrid.code
                       ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                         ,ndocument => rrow.rn));
        end;
      end if;
      /* Если НЕ заполнен ИГК */
    else
      /* Тип банковского реквизита юр.лица Специальный */
      if nvl(rbankacctypes.rn
            ,-999) in (1080004)
      then
        p_exception(0
                   ,'В договоре не указан ИГК. При этом банковский реквизит <%s> юр.лица <%s> имеет тип "Специальный". %s'
                   ,rjuracc.strcode
                   ,get_jurpersons_code_id(nflag_smart => 1
                                          ,njur_pers   => rrow.jur_pers)
                   ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                     ,ndocument => rrow.rn));
      end if;
    end if;
  
    /* Тип банковского реквизита юр.лица Специальный */
    if cmp_num(rbankacctypes.rn
              ,1080004) = 1
    then
    
      /* Если префикс договора 1/ или 2/ */
      if trim(rrow.doc_pref) like '1/%'
         or trim(rrow.doc_pref) like '2/%'
      then
      
        /* Поиск других договоров с таким же префиксом и банковским реквизитом юр.лица */
        svarchar := null;
        select listagg(t.sdetails
                      ,'; ') within group(order by t.sdetails)
          into svarchar
          from (select rn
                      ,doc_pref
                      ,jur_acc
                      ,pkg_document.make_number(ndoc_type => doc_type
                                               ,sdoc_pref => doc_pref
                                               ,sdoc_numb => doc_numb
                                               ,ddoc_date => doc_date) as sdetails
                  from contracts) t
         where t.rn != rrow.rn
           and (trim(t.doc_pref) like '1/%' or trim(t.doc_pref) like '2/%')
           and cmp_num(t.jur_acc
                      ,rrow.jur_acc) = 1;
      
        /* Если такие договоры найдены */
        if svarchar is not null
        then
          p_exception(0
                     ,'Найдены договоры <%s> с таким же префиксом <%s> и реквизитом юр.лица <%s> с типом <%s>. %s'
                     ,svarchar
                     ,trim(rrow.doc_pref)
                     ,rjuracc.strcode
                     ,rbankacctypes.code
                     ,cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                       ,ndocument => rrow.rn));
        end if;
      end if;
    end if;
  
    /* По этапам */
    for c in (select * from stages where prn = nrn)
    loop
      /* базовая проверка этапа */
      stages_check_base(nrn      => c.rn
                       ,ncompany => c.company);
    end loop;
  
  end if;

  /* РАССЫЛКИ */
  /* Только если до утверждения статус был Не утверждён */
  
  
  if usr_pkg_pub_const.rcontracts.status = 0
  then
    /* Префикс начинается с "1/" */
    if trim(rrow.doc_pref) like '1/%'
    then
    
  ---  if user = 'GOR' then P_exception(0, usr_pkg_pub_const.rcontracts.status); end if; 
      /* Сообщение Тюменцевой, Куроедовой, Надеевой, Васькиной, Говоровой и Быковой */
      
      v_send := 'y.tyumentseva@module.ru;a.kuroedova@module.ru;i.nadeeva@module.ru;e.vaskina@module.ru;anna@module.ru;k.bykova@module.ru';
     --- v_send := 'o.gorodetskiy@module.ru';    
      cText := strcombine(cText, cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                                                 ,ndocument => rrow.rn) || cr ||
                                                'Ответственный экономист: ' || nvl(contracts_get_resp_economist(nrn        => rrow.rn
                                                                                                               ,nflagsmart => 1
                                                                                                               ,ncompany   => rrow.company)
                                                                                  ,'Не определён'), null);
      
      Usr_Pkg_Maillst.MAILLST_INSERT_EXS_EXT_SEND(
              nCOMPANY => ncompany
             ,sDESCRIPTION => 'Утверждён тематический договор'
             ,sto_list => v_send
             ,sTITLE => 'Утверждён тематический договор'
             ,cTEXT => cText               
             ,nRN => v_nrn);
      
      /*pkg_exs_ext_mail.send_by_list(sto_list => 'y.tyumentseva@module.ru;a.kuroedova@module.ru;i.nadeeva@module.ru;e.vaskina@module.ru;anna@module.ru;k.bykova@module.ru'
                                   ,stitle   => 'Утверждён тематический договор'
                                   ,ctext    => cr || f_docdescrs_get_description(sunitcode => 'Contracts'
                                                                                 ,ndocument => rrow.rn) || cr ||
                                                'Ответственный экономист: ' || nvl(contracts_get_resp_economist(nrn        => rrow.rn
                                                                                                               ,nflagsmart => 1
                                                                                                               ,ncompany   => rrow.company)
                                                                                  ,'Не определён')
                                   ,nformat  => pkg_exs_ext_mail.nformat_text);*/
    end if;
  end if;

end contracts_aprocess;
  --#########################################################################################################

  procedure CONTRACTS_BCLOSE
  /*
  Договоры. Проверка до закрытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    null;
  end CONTRACTS_BCLOSE;
  --#########################################################################################################

  procedure CONTRACTS_ACLOSE
  /*
  Договоры. Проверка после закрытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    /* ПРОВЕРКИ */
    /* По этапам */
    for c in (select * from stages where prn = nRN)
    loop
      stages_bclose(nrn => c.rn, ncompany => c.company);
      stages_aclose(nrn => c.rn, ncompany => c.company);
    end loop;

  end CONTRACTS_ACLOSE;
  --#########################################################################################################

  procedure CONTRACTS_ACANCEL
  /*
  Договоры. Проверка после снятия утверждения
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    null;
  end CONTRACTS_ACANCEL;
  --#########################################################################################################

  procedure CONTRACTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number /* RN компании */
  )
  is
    rRow              contracts%rowtype;
    nStagesExists     pkg_std.tnumber := 0;
    
  procedure govcntridbanks_add
  (
    ncompany in number
   ,nigk     in number
   ,nagnacc  in number
  ) is
  
    v_sagent  agnlist.agnabbr%type;
    v_sagnacc agnacc.strcode%type;
    v_RS      agnacc.agnacc%type;  
    v_nrn     govcntridbanks.rn%type;

  begin
  
    /* Перенос реквизита контрагента в реквизиты ИГК   
       Если и ИГК и Реквизит заполнены */
  
    if nigk is null
       or nagnacc is null
    then
      return;
    end if;
  
    begin
      select a.agnabbr
            ,ac.strcode
            ,ac.AGNACC
        into v_sagent
            ,v_sagnacc
            ,v_RS
        from agnacc ac
        join agnlist a
          on a.rn = ac.agnrn
       where ac.rn = nagnacc;
    exception
      when no_data_found then
        return;
    end;
  
 if substr(v_rs, 4, 3) != '028'
  then
    /* Обычные счета не переносим */
  
    begin
      /* Если реквизита в конкретном ИГК нет, то добавим его */
      select gb.rn
        into v_nrn
        from govcntridbanks gb
       where gb.prn = nigk
         and gb.agnacc = nagnacc
         and gb.company = ncompany;
    exception
      when no_data_found then
      
        /*Если реквизит есть в другом ИГК, то выведем сообщение об ошибке */
      
        for cur in (select gi.code
                      from govcntrid gi
                      join govcntridbanks gib
                        on gib.prn = gi.rn
                      join agnacc r
                        on r.rn = gib.agnacc
                     where gi.company = ncompany
                       and r.strcode = v_sagnacc
                       and gi.rn != nigk)
        loop
          p_exception(0,
                      'Вы выбрали реквизит банковского счета %s, но он уже использован для Идентификатора '||
                      'государственного контракта с № %s,а вы в договоре указали другой ИГК!. '||
                      'Если у вас есть вопросы по исправлению ситуации, обратитесь в ПЭО.', 
                      v_sagnacc, cur.code);        
        end loop;
      
        p_govcntridbanks_insert(ncompany => ncompany, nprn => nigk, sagent => v_sagent, sagnacc => v_sagnacc, nrn => v_nrn);
    end;
  end if;  end;  
   
  
  begin
    /* Заголовок */
    rRow := contracts_get(nRN);
    
    /* Все Договора теперь входящие */     
    P_exception(1 - rRow.Inout_Sign , 'Обязательно установите признак "Входящий" и в поле внешний номер внесите оригинальный номер договора!');
    
    /*Обязательность даты регистрации*/    
    if rRow.REG_DATE is null 
      then P_exception(0, 'Обязательно заполните дату регистрации - датой оригинального договора!');
    end if;
    
    /* Перенос Реквизита контрагента в ИГК */
  
     govcntridbanks_add(rrow.company, rrow.govcntrid, rrow.agnacc);

    /* Наличие этапов */
    for c in (select 1 from stages t where t.prn = rRow.rn) loop nStagesExists := 1; exit; end loop;

    /* Признак Доп.соглашение */
    if rRow.ext_agreement != 0 then
      p_exception(0, 'Запрещено использовать признак "Дополнительное соглашение" в договоре. '
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => rRow.rn) );
    end if;

    /* Если ручной рассчёт сумм */
    if rRow.sum_type = 0 then
      p_exception(0, 'Не установлен параметр "Расчётные суммы" на вкладке "Суммы исполнения". '||
                  'Для исправления утверждённого договора используйте процедуру "Исправить признак "Расчёт суммы" на значение "Да". %s%s'
                 ,cr||f_docdescrs_get_description('Contracts', rRow.rn));
    end if;

    /* Префикс-номер */
    for c in (select t.crn
                from contracts t
               where upper(trim(t.doc_pref)) = upper(trim(rRow.doc_pref))
                 and upper(trim(t.doc_numb)) = upper(trim(rRow.doc_numb))
                 and t.rn != rRow.rn)
    loop
      p_exception(0, 'Существует договор с такими же значениями полей "Префикс-Номер" в каталоге <%s>. %s'
                 ,usr_pkg_common.get_cat_higher_str(nrn => c.crn, nsigns => 1)
                 ,cr||f_docdescrs_get_description('Contracts', rRow.rn));
    end loop;

    /* дата окончания не заполнена
    if rRow.end_date is null then
      P_EXCEPTION(0, 'Не заполнена дата окончания договора.'||CR||'%s'
                 ,usr_f_get_docdescrs(rRow.rn, 'Contracts'));
    end if;*/

  end CONTRACTS_CHECK_BASE;
  --#########################################################################################################

  procedure CONTRACTS_BASE_UPDATE
  /*
  Исправление договора базовое
  */
  (
   rCONTRACTS       in contracts%rowtype
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      /* Исправление */
      p_contracts_base_update(ncompany        => rCONTRACTS.COMPANY
                             ,nrn             => rCONTRACTS.RN
                             ,nprn            => rCONTRACTS.PRN
                             ,njur_pers       => rCONTRACTS.JUR_PERS
                             ,njur_acc        => rCONTRACTS.JUR_ACC
                             ,ndoc_type       => rCONTRACTS.DOC_TYPE
                             ,sdoc_pref       => rCONTRACTS.DOC_PREF
                             ,sdoc_numb       => rCONTRACTS.DOC_NUMB
                             ,ddoc_date       => rCONTRACTS.DOC_DATE
                             ,sext_number     => rCONTRACTS.EXT_NUMBER
                             ,dreg_date       => rCONTRACTS.REG_DATE
                             ,ninout_sign     => rCONTRACTS.INOUT_SIGN
                             ,nfalse_doc      => rCONTRACTS.FALSE_DOC
                             ,next_agreement  => rCONTRACTS.EXT_AGREEMENT
                             ,nagent          => rCONTRACTS.AGENT
                             ,nagnacc         => rCONTRACTS.AGNACC
                             ,nexecutive      => rCONTRACTS.EXECUTIVE
                             ,nsubdivision    => rCONTRACTS.SUBDIVISION
                             ,dbegin_date     => rCONTRACTS.BEGIN_DATE
                             ,dend_date       => rCONTRACTS.END_DATE
                             ,ntaxgr          => rCONTRACTS.TAXGR
                             ,nsum_type       => rCONTRACTS.SUM_TYPE
                             ,ndoc_sum        => rCONTRACTS.DOC_SUM
                             ,ndoc_sumtax     => rCONTRACTS.DOC_SUMTAX
                             ,ndoc_sum_nds    => rCONTRACTS.DOC_SUM_NDS
                             ,nautocalc_sign  => rCONTRACTS.AUTOCALC_SIGN
                             ,ncurrency       => rCONTRACTS.CURRENCY
                             ,ncurcours       => rCONTRACTS.CURCOURS
                             ,ncurbase        => rCONTRACTS.CURBASE
                             ,nbudgexpend_sp  => rCONTRACTS.BUDGEXPEND_SP
                             ,ssubject        => rCONTRACTS.SUBJECT
                             ,snote           => rCONTRACTS.NOTE
                             ,sbarcode        => rCONTRACTS.BARCODE
                             ,sreg_no         => rCONTRACTS.REG_NO
                             ,dreg_date_r     => rCONTRACTS.REG_DATE_R
                             ,nsecret_sign    => rCONTRACTS.SECRET_SIGN
                             ,nordlocmod      => rCONTRACTS.ORDLOCMOD
                             ,dauct_date      => rCONTRACTS.AUCT_DATE
                             ,nval_doctype    => rCONTRACTS.VAL_DOCTYPE
                             ,sval_number     => rCONTRACTS.VAL_NUMBER
                             ,dval_date       => rCONTRACTS.VAL_DATE
                             ,slaw_solut      => rCONTRACTS.LAW_SOLUT
                             ,sdoc_id         => rCONTRACTS.DOC_ID
                             ,dpub_date       => rCONTRACTS.PUB_DATE
                             ,spub_info       => rCONTRACTS.PUB_INFO
                             ,nsolut_sign     => rCONTRACTS.SOLUT_SIGN
                             ,nlot_numb       => rCONTRACTS.LOT_NUMB
                             ,nexcoreasons    => rCONTRACTS.EXCOREASONS
                             ,ncoprchjustif   => rCONTRACTS.COPRCHJUSTIF
                             ,nstatus_sign    => rCONTRACTS.STATUS_SIGN
                             ,sprint_form     => rCONTRACTS.PRINT_FORM
                             ,sdescription    => rCONTRACTS.DESCRIPTION
                             ,sval_req        => rCONTRACTS.VAL_REQ
                             ,ngovcntrid      => rCONTRACTS.GOVCNTRID
                             ,ngovdeford_exec => rCONTRACTS.GOVDEFORD_EXEC
                             ,nsign_frame     => rCONTRACTS.SIGN_FRAME);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Если договор НЕ "Не утверждён" */
      if rCONTRACTS.STATUS != 0 then
        /* Измененяем статус на НЕ Утверждён */
        update contracts set status = 0 where rn = rContracts.rn;
      end if;

      /* Исправление штатное */
      contracts_base_update(rcontracts => rCONTRACTS, nmode => 0);

      /* Если договор был НЕ "Не утверждён" */
      if rCONTRACTS.STATUS != 0 then
        /* Возвращаем исходный статус */
        update contracts set status = rCONTRACTS.STATUS where rn = rCONTRACTS.RN;
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE);
    end if;

  end CONTRACTS_BASE_UPDATE;
  --#########################################################################################################

  procedure CONTRACTS_SUMM_RECALC
  /*
  Пересчёт сумм по договору
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
    nNumber       PKG_STD.tNUMBER;
  begin
    -- расчёт с исправлением сумм
    P_COTRACTS_SETSUMS
    (
     NCOMPANY          => NCOMPANY
    ,NRN               => NRN
    ,NMODIFFLAG        => 1
    ,NDOC_SUM          => nNumber
    ,NDOC_SUMTAX       => nNumber
    ,NDOC_SUM_NDS      => nNumber
    ,NDOC_INGOOD_SUM   => nNumber
    ,NPLAN_INGOOD_SUM  => nNumber
    ,NFACT_INGOOD_SUM  => nNumber
    ,NFACT_DEFICIT_SUM => nNumber
    ,NDOC_OUTGOOD_SUM  => nNumber
    ,NPLAN_OUTGOOD_SUM => nNumber
    ,NFACT_OUTGOOD_SUM => nNumber
    ,NDOC_OUTSERV_SUM  => nNumber
    ,NPLAN_OUTSERV_SUM => nNumber
    ,NFACT_OUTSERV_SUM => nNumber
    ,NDOC_OUTPAY_SUM   => nNumber
    ,NPLAN_OUTPAY_SUM  => nNumber
    ,NFACT_OUTPAY_SUM  => nNumber
    ,NDOC_INPAY_SUM    => nNumber
    ,NPLAN_INPAY_SUM   => nNumber
    ,NFACT_INPAY_SUM   => nNumber
    );
  end CONTRACTS_SUMM_RECALC;
  --#########################################################################################################

  PROCEDURE CONTRACTS_UPDATE_SUM_TYPE
  /*
  Исправление признака "Расчётные суммы"
  */
  (
   nFLAGSMART     in number
  ,nRN            in number
  ,nSUM_TYPE      in number /* рассчётные сумм: 0 - нет, 1 - да */
  ,nTAXGR         in number default null
  ,nSUM           in number default null
  )
  is
    rRow    contracts%rowtype;
  BEGIN
    /* Запись */
    rRow := contracts_get(nrn => nRN);

    /* Проверка входных параметров */
    if cmp_num(v1 => rRow.sum_type, v2 => nSUM_TYPE) = 1 then
      if nFLAGSMART = 0 then
        p_exception(0, 'Параметр "Расчёт суммы" в документе <%s> равен параметру процедуры <%s>. %s%s'
                   ,rRow.sum_type
                   ,nSUM_TYPE
                   ,cr||f_docdescrs_get_description('Contracts', rRow.rn));
      else
        return;
      end if;
    end if;

    /* Если НЕ рассчётные суммы */
    if nSUM_TYPE = 0 then
      /* не задана налоговая группа*/
      if rrow.taxgr is null and nTAXGR is null then
        p_exception(0, 'Не задана налоговая группа при том, что параметр "Расчёт суммы" имеет значение <Нет>. %s%s'
                   ,cr||f_docdescrs_get_description('Contracts', rRow.rn));
      end if;

      /* подстановка значений в переменную */
      rRow.sum_type     := 0;
      rRow.taxgr        := nvl(nTAXGR, rRow.taxgr);
      rRow.doc_sum_nds  := nvl(nSUM, rRow.doc_sum_nds);
      pkg_dictaxis_calc.p_calculate_base
      (
       nflag_smart => 0
      ,ncompany    => rRow.company
      ,ddate       => rRow.begin_date
      ,nsumm_sign  => 1
      ,ninsumm     => rRow.doc_sum_nds
      ,ntaxgr      => rRow.taxgr
      ,nquant      => 0
      ,nncp_sign   => 1
      );
      rRow.doc_sum     := pkg_dictaxis_calc.f_get_value(0);
      rRow.doc_sumtax  := pkg_dictaxis_calc.f_get_value(2);
      rRow.doc_sum_nds := pkg_dictaxis_calc.f_get_value(8);

      /* Исправление */
      contracts_base_update(rcontracts => rRow, nmode => 1);

    /* Если рассчётные суммы */
    elsif nSUM_TYPE = 1 then
      rRow.sum_type := 1;
      rRow.taxgr    := null;

      /* Исправление */
      contracts_base_update(rcontracts => rRow, nmode => 1);

      /* Пересчёт сумм */
      contracts_summ_recalc(ncompany => rRow.COMPANY, nrn => rRow.RN);

    else
      p_exception(0, 'Неверное значение <%s> параметра "nSUM_TYPE". %s'
                 ,nSUM_TYPE
                 ,cr||f_docdescrs_get_description('Contracts', rRow.rn));
    end if;

  END CONTRACTS_UPDATE_SUM_TYPE;
  --#########################################################################################################

  function STAGES_GET
  /*
  Договор (этапы). Считывание заголовка
  */
  (
   nRN          in number
  ,nFLAG_SMART  in number default 0
  )
  return stages%rowtype
  is
    rRow stages%rowtype;
  begin
    begin
      select * into rRow from stages where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAG_SMART, ndocument => nRN, sunit_table => 'STAGES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'STAGES')));
    end;
    return(rRow);
  end STAGES_GET;
  --#########################################################################################################

  function STAGES_GET_BY_FACEACC
  /*
  Договор (этапы). Считывание заголовка по RN лицевого счёта
  */
  (
   nFACEACC     in number
  ,nFLAG_SMART  in number default 0
  )
  return stages%rowtype
  is
    rRow stages%rowtype;
  begin
    begin
      select * into rRow from stages where faceacc = nFACEACC;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAG_SMART, ndocument => nFACEACC, sunit_table => 'STAGES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN лицевого счёта %s в разделе %s.'
                   ,nFACEACC, f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'STAGES')));
    end;
    return(rRow);
  end STAGES_GET_BY_FACEACC;
  --#########################################################################################################
  
  function STAGES_GET_STATUS_NAME
  /*
    Функция возвращает "Состояние"
    stages.status закрыт(0), открыт(1), анулирован(2), согласован(3) 
    Если stages.status = 0, а дата закрытия лицевого счета Faceacc.Fact_Close_Date is null , то состояние "Не открыт"    
  */
  (nrn in stages.rn%type) return varchar2 as
    sresult pkg_std.tstring;
  begin
    begin
      select case
               when st.status = 0
                    and f.fact_close_date is null then
                'Не открыт'
               when st.status = 0
                    and f.fact_close_date is not null then
                'Закрыт'
               when st.status = 1 then
                'Открыт'
               when st.status = 2 then
                'Анулирован'
               when st.status = 3 then
                'Согласован'
               else
                'Не определен'
             end
        into sresult
      
        from stages st
        join faceacc f
          on f.rn = st.faceacc
       where st.rn = nrn;
    exception
      when no_data_found then
        return 'Не найден';
      
    end;
  
    return sresult;
  
  end stages_get_status_name;
   --#########################################################################################################

  function STAGES_GET_CPCL_SUM_BY_FPAC
  /*
  Этапы. Получить сумму из калькуляциий действующей структуры цены по списку статей затрат
  */
  (
   nFLAG_SMART    in number default 1
  ,nRN            in number
  ,sFPAC_LIST     in varchar2
  )
  return number 
  is
   nRes    pkg_std.tsumm; 
  begin
    begin
      select sum( cn.cost_sum )
        into nRes
        from contrprstruct  cprs
            ,contrprclc     cn
            ,fpdartcl       fp
       where cprs.prn        = nRN
         and cn.prn          = cprs.rn
         and cprs.sign_act   = 1
         and cn.cost_article = fp.rn
         and strin( ssubstr => fp.code, ssource => sFPAC_LIST, sdelim => ';' ) = 1 ;
   exception
     when no_data_found then
       pkg_msg.record_not_found(nflag_smart => nFLAG_SMART, ndocument => nrn, sunit_table => 'CONTRPRCLC');
     when others then
       p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                  ,nRN, f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CONTRPRCLC') ) );
   end;

   return nRes;

   end STAGES_GET_CPCL_SUM_BY_FPAC;
  --#########################################################################################################

  procedure STAGES_BINSERT
  /*
  Договор (этапы). Проверка после добавления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    -- Очистка констант
    usr_pkg_pub_const.rStages := null;
  end STAGES_BINSERT;
  --#########################################################################################################

  procedure STAGES_AINSERT
  /*
  Договор (этапы).  Проверка после добавления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  )
  is
    rRow            stages%rowtype;
    rDoc            contracts%rowtype;
    rFaceAcc        faceacc%rowtype;
    nFAOP_Exists    pkg_std.tnumber := 0;
  begin
    /* Этап */
    rRow := stages_get(nrn => nRN);
    /* Договор */
    rDoc := contracts_get(nrn => rRow.Prn);
    /* Лицевой счёт */
    rFaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rRow.faceacc);
    /* Наличие графиков в лицевом счёте */
    /*for c in (select null from fcacoperplans where prn = rFaceAcc.rn) loop nFAOP_Exists := 1; exit; end loop;*/

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* KHOK 13/12/2024 Если префикс договора 3/ или 4/  */
    if trim(rDoc.doc_pref) like '3/%' or trim(rDoc.doc_pref) like '4/%' then
      /* Лицевой счет должен иметь тип Закупка */
      if rFaceAcc.Acc_Kind = 1 then
        p_exception(0,'В закупочном договоре Лицевой счет не может быть с типом "Продажа".'); 
      end if;
    end if;
    /* Базовая */
    stages_check_base(nrn => nRN, ncompany => nCOMPANY);
    USr_pkg_faceacc.FACEACC_AINSERT(NRN => rRow.Faceacc, NCOMPANY => rRow.Company);

  end STAGES_AINSERT;
  --#########################################################################################################

  procedure STAGES_BUPDATE
  /*
  Договор (этапы).  Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    usr_pkg_pub_const.rstages := stages_get(nrn => NRN);
  end STAGES_BUPDATE;
  --#########################################################################################################

  procedure STAGES_AUPDATE
  /*
  Договор (этапы).  Проверка после исправления
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
    rRow            stages%rowtype;
  begin
    -- Заголовок
    rRow := stages_get(nrn => NRN);

    -- Проверки
    -- Базовая
    stages_check_base(nrn => rRow.rn, ncompany => rRow.company);

    -- Очистка констант
    usr_pkg_pub_const.rstages := null;
    usr_pkg_faceacc.faceacc_aupdate(nrn => rROW.faceacc, ncompany => rROW.company);

  end STAGES_AUPDATE;
  --#########################################################################################################

  procedure STAGES_BDELETE
  /*
  Договор (этапы).  Проверка перед исправлением
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    null;
  end STAGES_BDELETE;
  --#########################################################################################################

  procedure STAGES_BOPEN
  /*
  Договор (этапы).  Проверка до открытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
  begin
    null;
    /*usr_pkg_pub_const.rstages := stages_get(nrn => NRN); */
  end STAGES_BOPEN;
  --#########################################################################################################

procedure STAGES_AOPEN
/*
  Договор (этапы).  Проверка после открытия
*/
(
  nrn      in number
 ,ncompany in number -- RN компании
) is
  sres varchar2(2000);
begin
  begin
    /*  Проверим, что задан ШПЗ */
    for cur in ( /*select fl.code
                                    ,ac.name
                                    ,st.numb
                                from stages st
                                join faceacc f
                                  on f.rn = st.faceacc
                                join fpdartcl fl
                                  on fl.rn = f.ieelement
                                join contracts dog
                                  on dog.rn = st.prn
                                join acatalog ac
                                  on ac.rn = dog.crn
                
                               where st.rn = nrn
                                 and (fl.code in ('Расходы на КА_Б'
                                                 ,'Прочие тем.расходы_Б'
                                                 ,'Расходы на иниц._Б') or
                                     (fl.code = 'Расходы на ПКИ_Б' and ac.name = 'ВЭД'))
                
                                 and exists (select 1
                                        from fcacoperplans fop
                                       where fop.prn = f.rn
                                         and fop.inexp_sign = 1 -- расход
                                         and usr_f_fcacoperplans_cipher(nprn      => f.rn
                                                                       ,ncompany  => f.company
                                                                       ,nnomprice => fop.nomprice) is null -- Нет ШПЗ
                                      )*/
                
                select distinct st.prn
                                ,f.rn
                                ,fl.code sos_zatr
                                ,ac.name dog_cat
                                ,trim(st.numb) stg_nmb
                                ,(select max(fp.rn) from  FCACOPERPLANS FP where fp.prn = f.rn and  FP.Inexp_Sign = 1) FPRN  ---(Есть график отпуска) 
                                ,coalesce((select 1
                                            from contrprstruct t
                                           where t.prn = st.rn
                                             and t.state = 2
                                             and rownum = 1)
                                         ,0) is_str_price -- Есть действующая структура цены
                                ,coalesce((select 1
                                            from fcacoperplans t
                                            join fcacoperplansclc ts
                                              on ts.prn = t.rn
                                           where t.prn = f.rn
                                             and t.inexp_sign = 1 -- расход
                                             and rownum = 1)
                                         ,0) is_gr_calc --- Есть калькуляция графика
                                 
                                ,(select max(1)
                                    from fcacoperplans t
                                   where t.prn = f.rn
                                     and t.inexp_sign = 1 -- расход
                                     and usr_f_fcacoperplans_cipher(nprn      => f.rn
                                                                   ,ncompany  => f.company
                                                                   ,nnomprice => t.nomprice) is null -- Нет ШПЗ  
                                     and rownum = 1) no_shpz --  хоть в одном из графиков отгрузки нет ШПЗ, при этом САМ график отгрузки есть!
                                 
                                ,coalesce((select max(1)
                                            from fcacoperplans t
                                          
                                           where t.prn = f.rn
                                             and t.inexp_sign = 1 -- расход 
                                             and rownum = 1)
                                         ,0) is_fop --- Есть график отгрузки
                
                  from stages st
                  join faceacc f
                    on f.rn = st.faceacc
                  join fpdartcl fl
                    on fl.rn = f.ieelement
                  join contracts dog
                    on dog.rn = st.prn
                  join acatalog ac
                    on ac.rn = dog.crn
                  ---left join FCACOPERPLANS FP on fp.prn = f.rn and  FP.Inexp_Sign = 1 ---(график отпуска)
                
                 where st.rn = nrn)
    loop
    
      if cur.FPRN is not null and --- Есть хоть один график отпуска
        (cur.sos_zatr in ('Расходы на КА_Б'
                          ,'Прочие тем.расходы_Б'
                          ,'Расходы на иниц._Б') or
         (cur.sos_zatr = 'Расходы на ПКИ_Б' and cur.dog_cat = 'ВЭД'))
         and (cur.is_fop = 0 or cur.no_shpz = 1) then
      
        p_exception(0
                   ,case cur.dog_cat
                      when 'ВЭД' then
                       'Для договоров в каталоге ВЭД: '
                      else
                       ''
                    end ||
                    'Перед открытием договора, для статьи затрат "%s", заданной в этапе договора (правила формирования), обязательно указать ШПЗ в Графике отпуска товаров и услуг.'
                   ,cur.sos_zatr);
      
      end if;
    
      if cur.sos_zatr in ('Продажа товаров вСНГ'
                         ,'ЭкспортУслугЗарубеж'
                         ,'Экспорт товаров')
         and not (cur.is_str_price = 1 or cur.is_fop = 1) then
        p_exception(0
                   ,'Для этапа договора со статьей затрат %s обязательно задание Структуры цены.'
                   ,cur.sos_zatr);
      
      end if;
    
    end loop;
  
  end;

  /* Проверим, что в структуре этапа есть действущая */
  begin
    for cur in (select 1
                  from stages st
                  join faceacc f
                    on f.rn = st.faceacc
                   and f.acc_kind = 1
                  join acatalog AC on ac.rn = st.crn 
                 where st.rn = nrn
                   and not exists (select 1
                          from contrprstruct ct
                         where ct.prn = st.rn
                           and ct.sign_act = 1)
                   and ac.name != 'Финансовые'  /* 24-07-2025 По требованию Тюменцевой исключены договора в каталоге */      
                           
                           )
    loop
      
      p_exception(0
                 ,'Переведите структуру цены этапа в состояние "Действующая" перед открытием этапа.');
      
    end loop;
  end;

  usr_p_fcacoperplans_sum_cntrl(nrn => nrn, ndelta => 1, out_res => sres);
/*  if sres is not null and utilizer != 'KHOK' then
    p_exception(0, sres);
  end if;*/
end stages_aopen;
  --#########################################################################################################

  procedure STAGES_BCLOSE
  /*
  Договор (этапы).  Проверка после закрытия
  */
  (
   NRN      in number
  ,NCOMPANY in number -- RN компании
  )
  is
    rRow            stages%rowtype;
  begin
    /* Считывание */
    rRow := stages_get(nrn => nRN);
    usr_pkg_pub_const.rstages := rRow;

    /* ПРОВЕРКИ */
    /* проверка лицевого счёта */
    usr_pkg_faceacc.faceacc_bclose(nrn => rRow.faceacc, ncompany => rRow.company);

  end STAGES_BCLOSE;
  --#########################################################################################################

  procedure STAGES_ACLOSE
  /*
  Договор (этапы).  Проверка после закрытия
  */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
  )
  is
    rRow            stages%rowtype;
    V_FL number(1);    
  begin
    /* Считывание */
    rRow := stages_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Лицевой счёт */
    usr_pkg_faceacc.faceacc_aclose(nrn => rRow.faceacc, ncompany => rRow.company);
    
    begin
    /* Если закрываем этап и больше открытых нет, то закрываем и договор датой закрытия этапа */
        for cur in (select st.prn
                          ,st.company
                          ,st.end_date
                      from stages st
                     where st.rn = nrn)
        loop
        
          begin
          
            select 1
              into v_fl
              from stages st
            
             where st.prn = cur.prn
               and st.rn != nrn
               and st.status != 0
               and rownum = 1;
          exception
            when no_data_found then
              /*Закрываем договор, т.к. больше открытых эапов нет */
            null;
            
              /* Тут только базовая процедура возможна */
              P_CONTRACTS_BASE_SETSTATUS(ncompany  => ncompany
                                   ,nrn       => cur.prn
                                   ,nstatus   => 2
                                   ,dworkdate => nvl(cur.end_date
                                                    ,sysdate));
          end;
        
        end loop;

      end;
    
    
    

  end STAGES_ACLOSE;
  --#########################################################################################################

  procedure STAGES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
  )
  is
    rRow         stages%rowtype;
  begin
    /* Заголовок */
    rRow := stages_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Отражение на сумме договора Куроедова 11-08-2025  Естиь этапы которые не отражаются на сумме*/
/*    if rRow.sign_sum != 1 then
      p_exception(0, 'Не установлен параметр "Отражается на сумме договора". %s%s'
                 ,cr||f_docdescrs_get_description('ContractsStages', rRow.rn)
                 ,cr||f_docdescrs_get_description('Contracts', rRow.prn));
    end if;*/

    /* По графикам этапа */
    for c in (select * from fcacoperplans where prn = rRow.faceacc)
    loop
      /* поиск графика в текущем этапе с другой налоговой группой */
      /*for c2 in (select *
                   from fcacoperplans t
                  where t.prn    = c.prn
                    and t.rn    != c.rn
                    and t.taxgr != c.taxgr)
      loop
        p_exception(0, 'Разные налоговые группы в графиках товаров:%s%s'
                   ,cr||f_docdescrs_get_description('FaceAccountsOperOutPlans', c.rn)
                   ,cr||f_docdescrs_get_description('FaceAccountsOperOutPlans', c2.rn));
      end loop;*/
      /* в этапе расчёт сумм НЕ По спецификации */
      if rRow.sum_type != 1 and utilizer not in ( 'KHOK', 'BYKOVA_KV', 'STEPANOV_MV' ) then
        p_exception(0, 'У этапа договора есть графики товаров, при этом параметр "Расчёт сумм" имеет значение <%s>. '||
                       'Выберите значение <По спецификации>. '||
                       'Для исправления этапа утверждённого договора используйте процедуру "Исправить признак "Расчёт суммы". %s%s'
                   ,stages_get_sum_type_name(rRow.sum_type)
                   ,cr||f_docdescrs_get_description('ContractsStages', rRow.rn)
                   ,cr||f_docdescrs_get_description('Contracts', rRow.prn));
      end if;
    end loop;

    /* Если расчёт суммы Вручную */
    if rRow.sum_type = 0 then
      /* не указана сумма */
      if rRow.stage_sum = 0 then
        p_exception(0, 'Не задана сумма этапа. Введите сумму или выберите <По спецификации> в поле "Расчёт суммы". %s%s'
                   ,cr||f_docdescrs_get_description('ContractsStages', rRow.rn)
                   ,cr||f_docdescrs_get_description('Contracts', rRow.prn));
      end if;
      /* не указана налоговая группа */
      if rRow.taxgr is null then
        p_exception(0, 'Не заполнено поле "Налоговая группа" в этапе. %s'
                   ,cr||f_docdescrs_get_description('ContractsStages', rRow.rn)
                   ,cr||f_docdescrs_get_description('Contracts', rRow.prn));
      end if;
    end if;
    
    /*Если состав затрат этапа (лицевого счета) входит в список....  или 
    каталог договора: "Продажа товаров вСНГ" 
    или один из подкаталогов каталога ПЭО (с любым составом затрат)    
    , то в догооре обязательно должен быть указано значение свойства "Экономист ПЭО"*/
    
begin
  for cur in (select sz.code
                    ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник'
                                                        ,sunitcode  => 'Contracts'
                                                        ,ndocument  => st.prn) otv
                from stages st
                join faceacc f
                  on f.rn = st.faceacc
                join fpdartcl sz
                  on sz.rn = f.ieelement
               where st.rn = nrn
                 and (usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 218817422, sunitcode => 'FinPlanArticles', ndocument => sz.rn) = 1
                      /*sz.code in ('Продажа товаров вСНГ'
                                 ,'Темат. доходы_Б'
                                 ,'Продажа товаров вСНГ'
                                 ,'Расходы на КА_Б'
                                 ,'Прочие тем.расходы_Б'
                                 ,'Расходы на иниц._Б'
                                 ,'Субсидии на разработки_Б')*/ or
                      st.crn in (select a.rn
                                   from acatalog a
                                  where a.docname = 'Contracts'
                                    and a.company = 90521
                                 connect by prior a.rn = a.crn
                                  start with a.name = 'ПЭО'))
              
              )
  loop
  
    if cur.otv is null
    then
      p_exception(0
                 ,'Перед созданием этапа требуется обязательно задать в договоре значение свойства "Экономист ПЭО"');
    end if;
  
  end loop;

end;
    
    
    
    

  end STAGES_CHECK_BASE;
  --#########################################################################################################

  procedure STAGES_UPDATE
  /*
  Этапы. Исправление клиентское
  */
  (
   rV_ROW            in v_stages%rowtype
  ,rV_FACEACC        in v_faceacc%rowtype
  ,nFACEACC_EXIST     in number default 1  /* Лицевой счет: 0 - новый, 1 - существующий */
  ,nSIGN_DIR          in number default 0  /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ,nMODE              in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  is
    rV_RowTMP         v_stages%rowtype := rV_ROW;
    rContracts        contracts%rowtype;
    nContractsStatus  pkg_std.tnumber;
    bContractsChange  boolean := false;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then

      /* Исправление */
      p_stages_update(ncompany       => rV_ROW.NCOMPANY
                     ,nrn            => rV_ROW.NRN
                     ,snumb          => rV_ROW.SNUMB
                     ,next_agreement => rV_ROW.NEXT_AGREEMENT
                     ,nsign_sum      => rV_ROW.NSIGN_SUM
                     ,dbegin_date    => rV_ROW.DBEGIN_DATE
                     ,dend_date      => rV_ROW.DEND_DATE
                     ,sdirector      => rV_ROW.SDIRECTOR
                     ,sjur_acc       => rV_ROW.SJUR_ACC
                     ,staxgr         => rV_ROW.STAXGR
                     ,nsum_type      => rV_ROW.NSUM_TYPE
                     ,nstage_sum     => rV_ROW.NSTAGE_SUM
                     ,nstage_sumtax  => rV_ROW.NSTAGE_SUMTAX
                     ,nstage_sum_nds => rV_ROW.NSTAGE_SUM_NDS
                     ,nautocalc_sign => rV_ROW.NAUTOCALC_SIGN
                     ,sdescription   => rV_ROW.SDESCRIPTION
                     ,scomments      => rV_ROW.SCOMMENTS
                     ,nfaceacc_exist => nFACEACC_EXIST
                     ,sfaceacccrn    => rV_ROW.SFACEACCCRN
                     ,sagent         => rV_ROW.SAGENT
                     ,sfinerule      => rV_ROW.SFINERULE
                     ,sfaceacc       => rV_ROW.SFACEACC
                     ,nacc_kind      => rV_ROW.NACC_KIND
                     ,sexecutive     => rV_ROW.SEXECUTIVE
                     ,scurrency      => rV_FACEACC.SCURRENCY
                     ,ncredit_sum    => rV_ROW.NCREDIT_SUM
                     ,sfcacgr        => rV_ROW.SFCACGR
                     ,sagnacc        => rV_ROW.SAGNACC
                     ,sagentfi       => rV_ROW.SAGENTFI
                     ,sagentfo       => rV_ROW.SAGENTFO
                     ,sagent_trans   => rV_ROW.SAGENT_TRANS
                     ,ssubdiv        => rV_ROW.SSUBDIV
                     ,starif         => rV_ROW.STARIF
                     ,ndiscount      => rV_ROW.NDISCOUNT
                     ,spay_type      => rV_ROW.SPAY_TYPE
                     ,sship_type     => rV_ROW.SSHIP_TYPE
                     ,nprice_type    => rV_ROW.NPRICE_TYPE
                     ,dprice_date    => rV_ROW.DPRICE_DATE
                     ,nsigntax       => rV_ROW.NSIGNTAX
                     ,nsame_nomn     => rV_ROW.NSAME_NOMN
                     ,sfinaccnt      => rV_ROW.SFINACCNT
                     ,srespmanager   => rV_ROW.SRESPMANAGER
                     ,sieelement     => rV_ROW.SIEELEMENT
                     ,sfinsource     => rV_ROW.SFINSOURCE
                     ,spaytool       => rV_ROW.SPAYTOOL
                     ,spayprior      => rV_ROW.SPAYPRIOR
                     ,spayrule       => rV_ROW.SPAYRULE
                     ,sspec_mark     => rV_ROW.SSPEC_MARK
                     ,saddr_agent    => rV_ROW.SADDR_AGENT
                     ,saddr_agnacc   => rV_ROW.SADDR_AGNACC);
    
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Считывание договора */
      rContracts := contracts_get(nrn => RV_ROW.nPRN);
      /* Текущий статус */
      nContractsStatus := rContracts.status;

      /* Если этап НЕ Открыт */
      if rV_RowTMP.nstatus != 1 then

        /* Если договор НЕ "Утверждён" */
        if rContracts.status != 1 then
          /* Измененяем статус на "Утверждён" */
          update contracts set status = 1 where rn = rContracts.rn;
          /* Записываем новый статус договора */
          nContractsStatus := 1;
        end if;

        /* Открываем этап */
        p_stages_base_setstatus(ncompany    => rV_RowTMP.ncompany
                               ,nrn         => rV_RowTMP.nrn
                               ,nstatus     => 0
                               ,dworkdate   => rV_FACEACC.dFACT_OPEN_DATE
                               ,nssfod_sign => 0);
        rV_RowTMP.nstatus := 0;
      end if;

      /* Если договор НЕ "НЕ Утверждён" */
      if nContractsStatus != 0 then
        /* Измененяем статус на "НЕ Утверждён" */
        update contracts set status = 0 where rn = rContracts.rn;
        /* Записываем новый статус договора */
        nContractsStatus := 0;
      end if;

      /* Исправление этапа штатно */
      stages_update( rv_row => rV_RowTMP, rv_faceacc => rV_FACEACC, nsign_dir => nsign_dir, nmode => 0 );

      /* Если исходный статус договора отличается от текущего */
      if rContracts.status != nContractsStatus then
        /* Возвращаем исходный статус  */
        update contracts set status = rContracts.status where rn = rContracts.rn;
      end if;

      /* Если исходный статус договора отличается от текущего */
      if rV_ROW.nSTATUS != rV_RowTMP.nstatus then
        /* Возвращаем предыдущий статус этапу */
        p_stages_base_setstatus(ncompany    => rV_ROW.NCOMPANY
                               ,nrn         => rV_ROW.NRN
                               ,nstatus     => rV_ROW.NSTATUS
                               ,dworkdate   => case rV_ROW.NsTATUS
                                                  when 0 then rV_FACEACC.dFACT_CLOSE_DATE
                                                  when 1 then rV_FACEACC.dFACT_OPEN_DATE
                                                  else null
                                                end
                               ,nssfod_sign => 0);
        end if;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE);
    end if;

  end STAGES_UPDATE;
  --#########################################################################################################

  procedure STAGES_BASE_UPDATE
  /*
  Исправление этапа базовое
  */
  (
   rSTAGES            in stages%rowtype
  ,rFACEACC           in faceacc%rowtype
  ,nSIGN_DIR          in number default 0  /* Исправление при отработке/снятии отработки распоряжения (0 - нет, 1 - да) */
  ,nMODE              in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  is
    rStagesTMP        stages%rowtype := rSTAGES;
    rContracts        contracts%rowtype;
    nContractsStatus  pkg_std.tnumber;
    bContractsChange  boolean := false;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then

      /* Исправление */
      p_stages_base_update
      (
       ncompany       => rSTAGES.COMPANY
      ,nrn            => rSTAGES.RN
      ,snumb          => rSTAGES.NUMB
      ,next_agreement => rSTAGES.EXT_AGREEMENT
      ,nsign_sum      => rSTAGES.SIGN_SUM
      ,dbegin_date    => rSTAGES.BEGIN_DATE
      ,dend_date      => rSTAGES.END_DATE
      ,ndirector      => rSTAGES.DIRECTOR
      ,njur_acc       => rSTAGES.JUR_ACC
      ,ntaxgr         => rSTAGES.TAXGR
      ,nsum_type      => rSTAGES.SUM_TYPE
      ,nstage_sum     => rSTAGES.STAGE_SUM
      ,nstage_sumtax  => rSTAGES.STAGE_SUMTAX
      ,nstage_sum_nds => rSTAGES.STAGE_SUM_NDS
      ,nautocalc_sign => rSTAGES.AUTOCALC_SIGN
      ,sdescription   => rSTAGES.DESCRIPTION
      ,scomments      => rSTAGES.COMMENTS
      ,nexpstruct     => rFACEACC.EXPSTRUCT
      ,nincomeclass   => rSTAGES.INCOMECLASS
      ,neconclass     => rSTAGES.ECONCLASS
      ,ndicbunts      => rSTAGES.DICBUNTS
      ,naccfndsrc     => rSTAGES.ACCFNDSRC
      ,nbfpurpcodes   => rSTAGES.BFPURPCODES
      ,nfaceacc_crn   => rFACEACC.CRN
      ,nagent         => rFACEACC.AGENT
      ,nfinerule      => rFACEACC.FINERULE
      ,sfaceacc       => rFACEACC.NUMB
      ,nacc_kind      => rFACEACC.ACC_KIND
      ,nexecutive     => rFACEACC.EXECUTIVE
      ,ncurrency      => rFACEACC.CURRENCY
      ,ncredit_sum    => rFACEACC.CREDIT_SUM
      ,nfcacgr        => rFACEACC.FCACGR
      ,nagnacc        => rFACEACC.AGNACC
      ,nagnfi         => rFACEACC.AGNFI
      ,nagnfo         => rFACEACC.AGNFO
      ,nagn_trans     => rFACEACC.AGN_TRANS
      ,nsubdiv        => rFACEACC.SUBDIV
      ,ntarif         => rFACEACC.TARIF
      ,ndiscount      => rFACEACC.DISCOUNT
      ,npay_type      => rFACEACC.PAY_TYPE
      ,nship_type     => rFACEACC.SHIP_TYPE
      ,nprice_type    => rFACEACC.PRICE_TYPE
      ,dprice_date    => rFACEACC.PRICE_DATE
      ,nsigntax       => rFACEACC.SIGNTAX
      ,nsame_nomn     => rFACEACC.SAME_NOMN
      ,nfinaccnt      => rFACEACC.FINACCNT
      ,nrespmanager   => rFACEACC.RESPMANAGER
      ,nieelement     => rFACEACC.IEELEMENT
      ,nfinsource     => rFACEACC.FINSOURCE
      ,npaytool       => rFACEACC.PAYTOOL
      ,npayprior      => rFACEACC.PAYPRIOR
      ,npayrule       => rFACEACC.PAYRULE
      ,nspec_mark     => rFACEACC.SPEC_MARK
      ,nbudgexpend_sp => rFACEACC.BUDGEXPEND_SP
      ,naddr_agent    => rFACEACC.ADDR_AGENT
      ,naddr_agnacc   => rFACEACC.ADDR_AGNACC
      ,nsign_dir      => nSIGN_DIR);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Считывание договора */
      rContracts       := contracts_get(nrn => RSTAGES.PRN);
      /* Текущий статус */
      nContractsStatus := rContracts.status;

      /* Если этап НЕ Открыт */
      if rStagesTMP.status != 1 then

        /* Если договор НЕ "Утверждён" */
        if rContracts.status != 1 then
          /* Измененяем статус на "Утверждён" */
          update contracts set status = 1 where rn = rContracts.rn;
          /* Записываем новый статус договора */
          nContractsStatus := 1;
        end if;

        /* Открываем этап */
        p_stages_base_setstatus(ncompany    => rStagesTMP.company
                               ,nrn         => rStagesTMP.rn
                               ,nstatus     => 0
                               ,dworkdate   => rFACEACC.FACT_OPEN_DATE
                               ,nssfod_sign => 0);
        rStagesTMP.status := 0;
      end if;

      /* Если договор НЕ "НЕ Утверждён" */
      if nContractsStatus != 0 then
        /* Измененяем статус на "НЕ Утверждён" */
        update contracts set status = 0 where rn = rContracts.rn;
        /* Записываем новый статус договора */
        nContractsStatus := 0;
      end if;

      /* Исправление этапа штатно */
      stages_base_update(rstages => rStagesTMP, rfaceacc => rFACEACC, nsign_dir => nsign_dir, nmode => 0);

      /* Если исходный статус договора отличается от текущего */
      if rContracts.status != nContractsStatus then
        /* Возвращаем исходный статус  */
        update contracts set status = rContracts.status where rn = rContracts.rn;
      end if;

      /* Если исходный статус договора отличается от текущего */
      if rSTAGES.STATUS != rStagesTMP.status then
        /* Возвращаем предыдущий статус этапу */
        p_stages_base_setstatus(ncompany    => rSTAGES.COMPANY
                               ,nrn         => rSTAGES.RN
                               ,nstatus     => rSTAGES.STATUS
                               ,dworkdate   => case rSTAGES.sTATUS
                                                  when 0 then rFACEACC.FACT_CLOSE_DATE
                                                  when 1 then rFACEACC.FACT_OPEN_DATE
                                                  else null
                                                end
                               ,nssfod_sign => 0);
        end if;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE);
    end if;

  end STAGES_BASE_UPDATE;
  --#########################################################################################################

  procedure STAGES_SUMM_RECALC
  /*
  Пересчёт сумм по этапу: сначала суммы исполнения, затем суммы этапа
  */
  (
   rSTAGES     in stages%rowtype
  ,rFACEACC    in faceacc%rowtype
  )
  is
    rStagesTmp        stages%rowtype;
    rContracts        contracts%rowtype;
    bContractsChange  boolean := false;
  begin
    /* Считывание договора */
    rContracts := contracts_get(nrn => rSTAGES.PRN);

    /* Расчёт с исправлением сумм исполнения */
    p_faceacc_set_opersums
    (
     ncompany       => rFACEACC.COMPANY
    ,nrn            => rFACEACC.RN
    ,noper          => NULL
    ,doper_date_new => current_date
    ,doper_date_old => current_date
    ,nchange_kind   => 1
    ,nsign_dir      => 0
    );

    /* Расчёт сумм этапа */
    rStagesTmp := rSTAGES;

    p_stages_base_getsums
    (
     ncompany     => rSTAGES.COMPANY
    ,nfaceacc     => rSTAGES.FACEACC
    ,nsum_type    => rSTAGES.SUM_TYPE
    ,nacc_kind    => rFACEACC.ACC_KIND
    ,nread_stage  => 1
    ,nrclc_stage  => 1
    ,nsumm        => rStagesTmp.STAGE_SUM
    ,nsummtax     => rStagesTmp.STAGE_SUMTAX
    ,nsumm_nds    => rStagesTmp.STAGE_SUM_NDS
    );

    /* Исправление сумм этапа */
    stages_base_update(rstages => rStagesTmp, rfaceacc => rFACEACC, nmode => 1);

  end STAGES_SUMM_RECALC;
  --#########################################################################################################

  PROCEDURE STAGES_UPDATE_SUM_TYPE
  /*
  Исправление признака "Расчёт суммы"
  */
  (
   nFLAGSMART     in number
  ,nRN            in number
  ,nSUM_TYPE      in number   -- Рассчётные сумм: 0 - нет, 1 - да
  ,nTAXGR         in number default null
  ,nSUM           in number default null
  )
  is
    rRow     stages%rowtype;
    rFaceacc    faceacc%rowtype;
    rContracts  contracts%rowtype;
  BEGIN
    /* Считывание */
    rRow        := stages_get(nRN);
    rFaceacc    := usr_pkg_faceacc.faceacc_get(rRow.faceacc);
    rContracts  := contracts_get(rRow.prn);

    /* Проверка параметра */
    if cmp_num(rRow.sum_type, nSUM_TYPE) = 1 then
      if nFLAGSMART = 0 then
        p_exception(0, 'Параметр "Расчёт суммы" в документе <%s> равен параметру процедуры <%s>. %s%s'
                   ,rRow.sum_type
                   ,nSUM_TYPE
                   ,cr||f_docdescrs_get_description('ContractsStages', rRow.rn)
                   ,cr||f_docdescrs_get_description('Contracts', rRow.prn));
      else
        return;
      end if;
    end if;

    /* Рассчёт сумм: 0 - вручную */
    if nSUM_TYPE = 0 then
      /* подмена значений в переменную */
      rRow.sum_type      := 0;
      rRow.taxgr         := nTAXGR;
      rRow.stage_sumtax  := nvl(nSUM, rRow.stage_sumtax);
      pkg_dictaxis_calc.p_calculate_base
      (
       nflag_smart => 0
      ,ncompany    => rRow.company
      ,ddate       => rRow.begin_date
      ,nsumm_sign  => 1
      ,ninsumm     => rRow.stage_sumtax
      ,ntaxgr      => rRow.taxgr
      ,nquant      => 0
      ,nncp_sign   => 1
      );
      rRow.stage_sum     := pkg_dictaxis_calc.f_get_value(0);
      rRow.stage_sumtax  := pkg_dictaxis_calc.f_get_value(2);
      rRow.stage_sum_nds := pkg_dictaxis_calc.f_get_value(8);
      /* исправление */
      stages_base_update(rstages => rRow, rfaceacc => rFaceacc, nmode => 1);
    /* Рассчёт сумм: 1 - по спецификации */
    elsif nSUM_TYPE = 1 then
      /* подмена значений в переменную */
      rRow.sum_type := 1;
      rRow.taxgr    := NULL;
      /* исправление */
      stages_summ_recalc(rstages => rRow, rfaceacc => rFaceacc);
    /*elsif nSUM_TYPE = 2 then
      \* подмена значений в переменную *\
      rRow.sum_type := 2;
      rRow.taxgr    := NULL;
      \* исправление *\
      --stages_summ_recalc(rRow, rFaceacc); -- Надо выполнить действия Инициализация истории исполнения и Коррекция по истории исполнения*/
    else
      p_exception(0, 'Неверное значение <%s> параметра <nSUM_TYPE>. %s%s'
                 ,stages_get_sum_type_name(nSUM_TYPE)
                 ,cr||f_docdescrs_get_description('ContractsStages', rRow.rn)
                 ,cr||f_docdescrs_get_description('Contracts', rRow.prn));
    end if;

  END STAGES_UPDATE_SUM_TYPE;
  --#########################################################################################################

  procedure STAGES_MAKE_DLO
  /*
  Спецификация. Сформировать заказ поставщику
  */
  (
   NCOMPANY        in number
  ,NRN             in number
  ,DDATE           IN DATE
  ,SACATALOG       IN VARCHAR2
  ,SDELIVDOCNUMB   IN VARCHAR2
  ,DDELIVDOCDATE   IN DATE
  ,DPAY_DATE       IN DATE
  ,DRELEASE_DATE   IN DATE
  ,SHEAD_NOTE      IN VARCHAR2
  ,SCURRENCY       IN VARCHAR2
  ,SFPAC           IN VARCHAR2
  ,SSUBDIV_FOR     IN VARCHAR2            -- Приобретено для
  ,SHPZ            IN VARCHAR2            -- ШПЗ
  ,NAPPROVE        in number   DEFAULT 0  -- Утвердить
  ,NOUT_RN         OUT NUMBER             -- RN сформированного документа
  )
  is
    NIDENT              PKG_STD.tREF := GEN_IDENT;
    NTRUE_REC           PKG_STD.tNUMBER;
    rV_DELIVERYORDBUF   V_DELIVERYORDBUF%ROWTYPE;

    nNumber         PKG_STD.tNUMBER;
  begin
    null;
    /*-- Добавление в селектлист
    P_SELECTLIST_INSERT_EXT(NIDENT, NRN, 'ContractsStages', NULL, NULL, NULL, nNumber);

    -- Формирование буфера
    P_FACEACCTRADE_MAKEDELIVERYORD
    (
     NCOMPANY           => NCOMPANY
    ,NIDENT             => NIDENT
    ,NCR_FROM           => 0
    ,DDATE              => DDATE
    ,NFLAG_NULLREC      => 1
    ,NFLAG_QUANTREC     => 1
    ,NFLAG_IGNOREPERIOD => 0
    ,NTRUE_REC          => NTRUE_REC
    );
    -- проверка формирования
    if nTRUE_REC IS NULL then
      P_EXCEPTION(0, 'Ошибка при Формирование заказа поставщикам.'||CR||USR_F_GET_DOCDESCRS(NRN, 'ContractsStages'));
    elsif nTRUE_REC = 0 then
      P_EXCEPTION(0, 'Формирование входящего заказа поставщикам не выполнено.'||CR||USR_F_GET_DOCDESCRS(NRN, 'ContractsStages'));
    end if;

    -- Цикл по буферу заголовков
    for c in (select T.* FROM V_DELIVERYORDBUF T where T.nIDENT = NIDENT)
    loop
      -- переопределение
      rV_DELIVERYORDBUF := C;
      rV_DELIVERYORDBUF.SCATALOG      := NVL(SACATALOG, rV_DELIVERYORDBUF.SCATALOG);
      rV_DELIVERYORDBUF.SCURRENCY     := NVL(SCURRENCY, rV_DELIVERYORDBUF.SCURRENCY);
      rV_DELIVERYORDBUF.DPAY_DATE     := NVL(DPAY_DATE, rV_DELIVERYORDBUF.DPAY_DATE);
      rV_DELIVERYORDBUF.DRELEASE_DATE := NVL(DRELEASE_DATE, rV_DELIVERYORDBUF.DRELEASE_DATE);
      rV_DELIVERYORDBUF.SDELIVDOCNUMB := NVL(SDELIVDOCNUMB, rV_DELIVERYORDBUF.SDELIVDOCNUMB);
      rV_DELIVERYORDBUF.DDELIVDOCDATE := NVL(DDELIVDOCDATE, rV_DELIVERYORDBUF.DDELIVDOCDATE);
      rV_DELIVERYORDBUF.SNOTE         := NVL(SHEAD_NOTE, rV_DELIVERYORDBUF.SNOTE);
       \*    -- тип документа
      if ( SDOCTYPE IS NOT NULL and RTRIM( SDOCTYPE ) IS NOT NULL ) then
        FIND_DOCTYPES_CODE (RDELIVERYORDBUF.COMPANY, SDOCTYPE, 'DeliveryOrders', 2, USR_PKG_PUB_CONST.RDELIVERYORDBUF.DOCTYPE);
      end if;*\
      -- исправление
      P_DELIVERYORDBUF_UPDATE
      (
       NCOMPANY      => rV_DELIVERYORDBUF.nCOMPANY
      ,NRN           => rV_DELIVERYORDBUF.nRN
      ,SCATALOG      => rV_DELIVERYORDBUF.sCATALOG
      ,SORD_PREF     => rV_DELIVERYORDBUF.sORD_PREF
      ,SORD_NUMB     => rV_DELIVERYORDBUF.sORD_NUMB
      ,SAGENT        => rV_DELIVERYORDBUF.sAGENT
      ,SFACEACC      => rV_DELIVERYORDBUF.sFACEACC
      ,SGRAPHPOINT   => rV_DELIVERYORDBUF.sGRAPHPOINT
      ,SORD_DOCTYPE  => rV_DELIVERYORDBUF.sORD_DOCTYPE
      ,DORD_DATE     => rV_DELIVERYORDBUF.dORD_DATE
      ,NORD_STATE    => rV_DELIVERYORDBUF.nORD_STATE
      ,DSTATE_DATE   => rV_DELIVERYORDBUF.dSTATE_DATE
      ,SDISP_TYPE    => rV_DELIVERYORDBUF.sDISP_TYPE
      ,SPAY_TYPE     => rV_DELIVERYORDBUF.sPAY_TYPE
      ,SDELIV_DIAGR  => rV_DELIVERYORDBUF.sDELIV_DIAGR
      ,SCURRENCY     => rV_DELIVERYORDBUF.sCURRENCY
      ,SSTORE        => rV_DELIVERYORDBUF.sSTORE
      ,SACC_AGENT    => rV_DELIVERYORDBUF.sACC_AGENT
      ,SSUBDIV       => rV_DELIVERYORDBUF.sSUBDIV
      ,DPAY_DATE     => rV_DELIVERYORDBUF.dPAY_DATE
      ,DRELEASE_DATE => rV_DELIVERYORDBUF.dRELEASE_DATE
      ,NORD_PERIOD   => rV_DELIVERYORDBUF.nORD_PERIOD
      ,NUSECALENDAR  => rV_DELIVERYORDBUF.nUSECALENDAR
      ,NPERIOD_CORR  => rV_DELIVERYORDBUF.nPERIOD_CORR
      ,NPERIOD_QUANT => rV_DELIVERYORDBUF.nPERIOD_QUANT
      ,NPERIOD_TYPE  => rV_DELIVERYORDBUF.nPERIOD_TYPE
      ,NPERIOD_LEN   => rV_DELIVERYORDBUF.nPERIOD_LEN
      ,NATSAMETIME   => rV_DELIVERYORDBUF.nATSAMETIME
      ,NINCLUDETAX   => rV_DELIVERYORDBUF.nINCLUDETAX
      ,NREDUCTION    => rV_DELIVERYORDBUF.nREDUCTION
      ,SNOTE         => rV_DELIVERYORDBUF.sNOTE
      ,SJUR_PERS     => rV_DELIVERYORDBUF.sJUR_PERS
      ,SDELIVDOCNUMB => rV_DELIVERYORDBUF.sDELIVDOCNUMB
      ,DDELIVDOCDATE => rV_DELIVERYORDBUF.dDELIVDOCDATE
      ,SBARCODE      => rV_DELIVERYORDBUF.sBARCODE
      ,NFLAG_MODE    => 1
      );
    end loop;
    -- Перенос буфера
    P_DELIVERYORDBUF_MAKEDOC(NCOMPANY, NIDENT, 0);
    P_SELECTLIST_CLEAR(NIDENT);
    P_DELIVERYORDBUF_CLEAN(NCOMPANY, NIDENT);

    -- По сформированным заказам поставщикам
    for c in (select COLUMN_VALUE, COUNT(*) OVER() AS NCOUNT FROM TABLE(CAST(USR_PKG_PUB_CONST.ARNLIST AS UDO_T_NUMTABLE)))
    loop
      -- проверка количества сформированных документов
      if C.NCOUNT != 1 then
        P_EXCEPTION(0, 'Сформировано больше одного заказа поставщикам.'||CR||USR_F_GET_DOCDESCRS(NRN, 'ContractsStages'));
      end if;
      -- Заполнение свойств
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_DATE('Ожид_дата', 'DeliveryOrders', C.COLUMN_VALUE, DRELEASE_DATE);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('Приобретено для', 'DeliveryOrders', C.COLUMN_VALUE, SSUBDIV_FOR);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('ЦФУ', 'DeliveryOrders', C.COLUMN_VALUE, SFPAC);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('ШПЗ_КГОЗ', 'DeliveryOrders', C.COLUMN_VALUE, SHPZ);
      -- выходной документ RN
      NOUT_RN := C.COLUMN_VALUE;
    end loop;

    -- Очистка константы
    USR_PKG_PUB_CONST.ARNLIST.delete;

    -- Утверждение
    if NAPPROVE = 1 then
      P_DELIVERYORD_SET_STATE
      (
       NFLAG_SMART => 0
      ,NCOMPANY    => rV_DELIVERYORDBUF.nCOMPANY
      ,NRN         => NOUT_RN
      ,NFLAG_MODE  => 0
      ,NNEW_STATE  => 1
      ,DSTATE_DATE => CURRENT_DATE
      ,NRESULT     => nNumber
      );
    end if;
    */
  end STAGES_MAKE_DLO;
  --#########################################################################################################

  procedure STAGES_MAKE_PAI
  /*
  Спецификация. Сформировать входящий счёт на оплату
  */
  (
   NRN             in number
  ,NCOMPANY        in number -- RN компании
  ,NIDENT          in number
  ,DDATE           in date
  ,SACATALOG       in varchar2
  ,DPAY_DATE       in date
  ,SEXT_NUMB       in varchar2
  ,DREG_DATE       in date
  ,SHEAD_NOTE      in varchar2
  ,SCURRENCY       in varchar2
  ,SFPAC           in varchar2
  ,SSUBDIV         in varchar2 -- Подразделение для свойства входящего счёта на оплату
  ,SSUBDIV_FOR     in varchar2 -- Приобретено для
  ,SHPZ            in varchar2 -- ШПЗ
  ,SGOZ_SIGN       in varchar2 -- ПРИЗНАК ГОЗ ОПЛАТЫ
  ,STYPE           in varchar2 -- Тип ВСО
  ,NAPPROVE        in number   default 0 -- Утвердить
  ,NOUT_RN         out number  -- RN сформированного документа
  )
  is
    rV_PAYACCINBUFF V_PAYACCINBUFF%ROWTYPE;
    nTAX_GROUP      PKG_STD.tREF;
    nTRUE_REC       PKG_STD.tNUMBER;
    NPRICE          PKG_STD.tSUMM;
    NACTSWOTAX      PKG_STD.tSUMM;
    NSUM_NDS        PKG_STD.tSUMM;
    sUserPerson     PKG_STD.tSTRING;
    sUserAgent      PKG_STD.tSTRING;

    nNumber         PKG_STD.tNUMBER;
    sVarchar        PKG_STD.tSTRING;
  begin
    null;
    /*-- Добавление в селектлист
    P_SELECTLIST_INSERT_EXT(NIDENT, NRN, 'ContractsStages', NULL, NULL, NULL, nNumber);

    -- Формирование буфера
    P_FACEACCTRADE_MAKEPAYACCIN
    (
     NCOMPANY           => NCOMPANY
    ,NIDENT             => NIDENT
    ,NCR_FROM           => 0
    ,DDATE              => DDATE
    ,NFLAG_NULLREC      => 1
    ,NFLAG_QUANTREC     => 1
    ,NTRUE_REC          => nTRUE_REC
    );
    -- проверка формирования
    if nTRUE_REC IS NULL then
      P_EXCEPTION(0, 'Ошибка при Формирование входящего счёта на оплату.'||CR||USR_F_GET_DOCDESCRS(NRN, 'ContractsStages'));
    elsif nTRUE_REC = 0 then
      P_EXCEPTION(0, 'Формирование входящего счёта на оплату не выполненно.'||CR||USR_F_GET_DOCDESCRS(NRN, 'ContractsStages'));
    end if;

    -- Цикл по буферу заголовков
    for c in (select * from V_PAYACCINBUFF T where T.NIDENT = NIDENT)
    loop
      rV_PAYACCINBUFF := C;
      -- переопределение
      rV_PAYACCINBUFF.SCATALOG  := NVL(SACATALOG, rV_PAYACCINBUFF.SCATALOG);
      rV_PAYACCINBUFF.SCURRENCY := NVL(SCURRENCY, rV_PAYACCINBUFF.SCURRENCY);
      rV_PAYACCINBUFF.DDOC_DATE := NVL(DDATE    , rV_PAYACCINBUFF.DDOC_DATE);
      rV_PAYACCINBUFF.DPAY_DATE := NVL(DPAY_DATE, rV_PAYACCINBUFF.DPAY_DATE);
      rV_PAYACCINBUFF.SEXT_NUMB := NVL(SEXT_NUMB, rV_PAYACCINBUFF.SEXT_NUMB);
      rV_PAYACCINBUFF.DREG_DATE := NVL(DREG_DATE, rV_PAYACCINBUFF.DREG_DATE);
      rV_PAYACCINBUFF.SCOMMENTS := NVL(SHEAD_NOTE, rV_PAYACCINBUFF.SCOMMENTS);
      -- исправление
      P_PAYACCINBUFF_UPDATE
      (
       NRN            => rV_PAYACCINBUFF.NRN
      ,NCOMPANY       => rV_PAYACCINBUFF.NCOMPANY
      ,NCRN           => rV_PAYACCINBUFF.NCRN
      ,SDOC_TYPE      => rV_PAYACCINBUFF.SDOC_TYPE
      ,SDOC_PREF      => rV_PAYACCINBUFF.SDOC_PREF
      ,SDOC_NUMB      => rV_PAYACCINBUFF.SDOC_NUMB
      ,DDOC_DATE      => rV_PAYACCINBUFF.DDOC_DATE
      ,SEXT_NUMB      => rV_PAYACCINBUFF.SEXT_NUMB
      ,DREG_DATE      => rV_PAYACCINBUFF.DREG_DATE
      ,DPAY_DATE      => rV_PAYACCINBUFF.DPAY_DATE
      ,SPAYER         => rV_PAYACCINBUFF.SPAYER
      ,SPAYERACC      => rV_PAYACCINBUFF.SPAYERACC
      ,SSUPPLIER      => rV_PAYACCINBUFF.SSUPPLIER
      ,SSUPPLACC      => rV_PAYACCINBUFF.SSUPPLACC
      ,SFACEACC       => rV_PAYACCINBUFF.SFACEACC
      ,SGRAPHPOINT    => rV_PAYACCINBUFF.SGRAPHPOINT
      ,SCURRENCY      => rV_PAYACCINBUFF.SCURRENCY
      ,NCURCOURS      => rV_PAYACCINBUFF.NCURCOURS
      ,NCURBASE       => rV_PAYACCINBUFF.NCURBASE
      ,SAGNFI         => rV_PAYACCINBUFF.SAGNFI
      ,SAGNFO         => rV_PAYACCINBUFF.SAGNFO
      ,SSTORE         => rV_PAYACCINBUFF.SSTORE
      ,SVDOC_TYPE     => rV_PAYACCINBUFF.SVDOC_TYPE
      ,SVDOC_NUM      => rV_PAYACCINBUFF.SVDOC_NUM
      ,DVDOC_DATE     => rV_PAYACCINBUFF.DVDOC_DATE
      ,NPRICEWITHTAX  => rV_PAYACCINBUFF.NPRICEWITHTAX
      ,NSUMM          => rV_PAYACCINBUFF.NSUMM
      ,NSUMMWITHNDS   => rV_PAYACCINBUFF.NSUMMWITHNDS
      ,NFA_CURRENCY   => rV_PAYACCINBUFF.NFA_CURRENCY
      ,NFA_BASECOURSE => rV_PAYACCINBUFF.NFA_BASECOURSE
      ,NFA_COURSE     => rV_PAYACCINBUFF.NFA_COURSE
      ,SCOMMENTS      => rV_PAYACCINBUFF.SCOMMENTS
      ,SPAYTYPE       => rV_PAYACCINBUFF.SPAYTYPE
      ,NDISCOUNT      => rV_PAYACCINBUFF.NDISCOUNT
      );
    end loop;

    -- Перенос буфера, очистка
    P_PAYACCINBUFF_MAKEDOC(NCOMPANY, NIDENT);
    P_SELECTLIST_CLEAR(NIDENT);

    -- Контрагент текущего пользователя
    FIND_PERSON_AUTHID(sUserPerson, sVarchar, sVarchar, sVarchar);
    FIND_CLNPERSONS_AGENT(0, NCOMPANY, sUserPerson, nNumber, sUserAgent);

    -- По сформированным заказам поставщикам
    for c in (select COLUMN_VALUE, COUNT(*) OVER() AS NCOUNT FROM TABLE(CAST(USR_PKG_PUB_CONST.ARNLIST AS UDO_T_NUMTABLE)))
    loop
      -- проверка количества сформированных документов
      if C.NCOUNT != 1 then
        P_EXCEPTION(0, 'Сформировано больше одного входящего счёта на оплату.'||CR||USR_F_GET_DOCDESCRS(NRN, 'ContractsStages'));
      end if;
      -- заполнение свойств
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('Приобретено для', 'PaymentAccountsIn', C.COLUMN_VALUE, SSUBDIV_FOR);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('ЦФУ', 'PaymentAccountsIn', C.COLUMN_VALUE, SFPAC);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('Отв', 'PaymentAccountsIn', C.COLUMN_VALUE, sUserAgent);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('Подразделение', 'PaymentAccountsIn', C.COLUMN_VALUE, SSUBDIV);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('ШПЗ_КГОЗ', 'PaymentAccountsIn', C.COLUMN_VALUE, SHPZ);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('ГОЗ_ПРИЗНАК', 'PaymentAccountsIn', C.COLUMN_VALUE, SGOZ_SIGN);
      UDO_PKG_DOCS_PROPS_VALS.P_DOCS_PROPS_VALS_MODIFY_STR('Тип ВСО', 'PaymentAccountsIn', C.COLUMN_VALUE, STYPE);
      -- выходной документ RN
      NOUT_RN := C.COLUMN_VALUE;
    end loop;

    -- Очистка константы
    USR_PKG_PUB_CONST.ARNLIST.delete;

    -- Утверждение
    if NAPPROVE = 1 then
      P_PAYACCIN_SET_STATUS(rV_PAYACCINBUFF.NCOMPANY, NOUT_RN, 1, CURRENT_DATE);
    end if;*/

  end STAGES_MAKE_PAI;
  --#########################################################################################################

  function STAGES_GET_SUM_TYPE_NAME
  /*
  Договор (этапы). Считывание заголовка
  */
  (
   nSUM_TYPE     in number
  )
  return varchar2
  is
  begin
    return(case nSUM_TYPE
             when 0 then 'Вручную'
             when 1 then 'По спецификации'
             when 2 then 'По платежам'
           else
             null
           end);
  end STAGES_GET_SUM_TYPE_NAME;
 --#########################################################################################################

  procedure STAGES_AAPPROVE_CALC
  /*
    Договоры (этапы). Состоние . Утвердить калькуляцию. ПОСЛЕ
  */
  (
   nRn     in number
  ) is
  sRes varchar2(2000);
  begin

  begin
  for cur in (select 1
                from stages st

               where st.rn = nrn
                 and not exists (select 1
                        from contrprstruct ct
                       where ct.prn = st.rn
                         and ct.sign_act = 1))
  loop
    p_exception(0
               ,'Переведите структуру цены этапа в состояние "Действующая" перед согласованием калькуляции цены.');
  end loop;
end;


    usr_p_fcacoperplans_sum_cntrl(nrn => nRn, ndelta => 1, out_res => sRes);
    if sRes is not null then
      p_exception(0, sRes);
    end if;
  end;
   --#########################################################################################################
  function CONTRPRSTRUCT_GET
  /*
    Договоры (этапы, структура цены). Считывание заголовка
    */
  (
   nRN         in number
  ,nFLAG_SMART in number default 0
  )
   RETURN CONTRPRCLC%ROWTYPE is
   begin
     return null;
   end;

  --#########################################################################################################
   procedure CONTRPRSTRUCT_MAKE_CNTRL
  /*
    Договоры (этапы, структура цены). Проверка после утверждения структуры
  Процедура контролирует, что все зависимы строки коррктно рассчитаны. А именно, после операции "формирования" на структуре цены,
  зависимые строки не меняют своего значения.
  Нужно если внешней процедурой поменяли значения строк от которых зависят значения других строк */

  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
   ) is

   nDUP_RN contrprstruct.rn%type;
   nCLC CONTRPRCLC.rn%type;

  begin

    --- P_EXCEPTION(0, NRn);
    --- Скопируем структуру в 50 год и пересчитаем ее (будем эмулировать зпуск действия  "формирования" на копии структуры цены)

    for doc in (select t.prn
                      ,t.price_kind
                      ,t.calcschm
                      ,t.calc_indir
                      ,t.state /* Состояние (0 - Новая, 1 - Согласована, 2 - Утверждена, 3 - Аннулирована) */
                      ,t.sign_act
                  from CONTRPRSTRUCT t
                  join finstate fs
                    on fs.rn = t.price_kind
                  join prjcalcschm pm
                    on pm.rn = t.calcschm
                 where t.rn = nrn
                 --- and T.State in (1,2)
                   and t.sign_act = 1 -- Проверка только для недействующей, переходящих в действующие

                )
    loop

      /* копируем шапку */

  ---  P_EXCEPTION(0, doc.state);

      p_contrprstruct_base_insert(ncompany    => ncompany
                                ,nprn        => doc.prn
                                ,nprice_kind => doc.price_kind
                                ,ncalcschm   => doc.calcschm
                                ,ddate_from  => to_date('01-01.1950', 'DD.MM.YYYY')
                                ,ddate_to    => to_date('01-01.1950', 'DD.MM.YYYY')
                                ,nsumm       => 0
                                ,nsumm_base  => 0
                                ,nsumm_fact  => 0
                                ,nsumm_fin   => 0
                                ,ncalc_indir => doc.calc_indir
                                ,nrn         => nDUP_RN);

      /* Копируем спецификацию */

      for rCLC in
    (
      select c.*
        from contrprclc  c
       where c.prn = nRN
       --  and S.CALCSCHM = nCALCSCHM  -- не изменилось поле «Схема калькуляции»
    )
    loop

   begin
      P_CONTRPRCLC_BASE_INSERT
      (
        nCOMPANY,
        nDUP_RN,            -- Вставляем в новую структуру
        rCLC.NUMB,
        rCLC.COST_ARTICLE,
        rCLC.SIGN_MAIN,
        rCLC.EXP_TYPE,
        rCLC.COST_SUM,
        rCLC.SUM_FACT,
        rCLC.SUM_FIN,
        rCLC.PERCENT_PLAN,
        rCLC.PERCENT_FACT,
        nCLC            -- nRN
      );

     end;

    end loop;

      /* пересчитываем */
      p_contrprstruct_make(ncompany => ncompany, nrn => ndup_rn);


    --- сравним исходную структуру и скопированную

    for cur in (

                select t.cost_article
                       ,t.cost_sum
                  from contrprclc t
                 where t.prn = nrn --- Наш исходный

                minus

                select t.cost_article
                       ,t.cost_sum
                  from contrprclc t
                 where t.prn = ndup_rn --- Пересчитанный
                )
    loop

      for err in (select (select t.cost_sum
                            from contrprclc t
                           where t.prn = nrn --- Наш исходный
                             and t.cost_article = cur.cost_article) sum_ish
                        ,(select t.cost_sum
                            from contrprclc t
                           where t.prn = ndup_rn --- Пересчитанный
                             and t.cost_article = cur.cost_article) sum_calc
                        ,fp.code
                    from fpdartcl fp
                   where fp.rn = cur.cost_article)
      loop

        p_exception(0
                   ,'Значение расчетной статьи не равно сумме входящих в нее статей. Выполните на структуре цены действие "Сформировать"!' ||
                    chr(10) || 'По статье "%s" ожидалось %s, а заведено %s'
                   ,err.code
                   ,err.sum_calc
                   ,err.sum_ish);

      end loop;
     end loop;
      --- Удаляем фиктивную структуру

   p_contrprstruct_base_delete(nrn => ndup_rn, ncompany => ncompany);
    end loop;


  end;


  function CONTRPRSTRUCT_MAKE_IS_ERR
  /*
      Договоры (этапы, структура цены). Проверка после утверждения структуры
    Процедура контролирует, что все зависимы строки коррктно рассчитаны. А именно, после операции "формирования" на структуре цены,
    зависимые строки не меняют своего значения.
    Нужно если внешней процедурой поменяли значения строк от которых зависят значения других строк */

  (
    nrn      in number
   ,ncompany in number -- RN компании
  ) return number is

    ndup_rn contrprstruct.rn%type;
    nclc    contrprclc.rn%type;

    nres number(1) := 0;

  begin

    --- P_EXCEPTION(0, NRn);
    --- Скопируем структуру в 50 год и пересчитаем ее (будем эмулировать зпуск действия  "формирования" на копии структуры цены)

    for doc in (select t.prn
                      ,t.price_kind
                      ,t.calcschm
                      ,t.calc_indir
                      ,t.state /* Состояние (0 - Новая, 1 - Согласована, 2 - Утверждена, 3 - Аннулирована) */
                      ,t.sign_act
                  from contrprstruct t
                  join finstate fs
                    on fs.rn = t.price_kind
                  join prjcalcschm pm
                    on pm.rn = t.calcschm
                 where t.rn = nrn
                      --- and T.State in (1,2)
                   and t.sign_act = 1 -- Проверка только для недействующей, переходящих в действующие

                )
    loop

      /* копируем шапку */

      ---  P_EXCEPTION(0, doc.state);

      p_contrprstruct_base_insert(ncompany    => ncompany
                                 ,nprn        => doc.prn
                                 ,nprice_kind => doc.price_kind
                                 ,ncalcschm   => doc.calcschm
                                 ,ddate_from  => to_date('01-01.1950', 'DD.MM.YYYY')
                                 ,ddate_to    => to_date('01-01.1950', 'DD.MM.YYYY')
                                 ,nsumm       => 0
                                 ,nsumm_base  => 0
                                 ,nsumm_fact  => 0
                                 ,nsumm_fin   => 0
                                 ,ncalc_indir => doc.calc_indir
                                 ,nrn         => ndup_rn);

      /* Копируем спецификацию */

      for rclc in (select c.*
                     from contrprclc c
                    where c.prn = nrn
                   --  and S.CALCSCHM = nCALCSCHM  -- не изменилось поле «Схема калькуляции»
                   )
      loop

        begin
          p_contrprclc_base_insert(ncompany
                                  ,ndup_rn
                                  , -- Вставляем в новую структуру
                                   rclc.numb
                                  ,rclc.cost_article
                                  ,rclc.sign_main
                                  ,rclc.exp_type
                                  ,rclc.cost_sum
                                  ,rclc.sum_fact
                                  ,rclc.sum_fin
                                  ,rclc.percent_plan
                                  ,rclc.percent_fact
                                  ,nclc -- nRN
                                   );

        end;

      end loop;

      /* пересчитываем */
      p_contrprstruct_make(ncompany => ncompany, nrn => ndup_rn);

      --- сравним исходную структуру и скопированную

      for cur in (

                  select t.cost_article
                         ,t.cost_sum
                    from contrprclc t
                   where t.prn = nrn --- Наш исходный

                  minus

                  select t.cost_article
                         ,t.cost_sum
                    from contrprclc t
                   where t.prn = ndup_rn --- Пересчитанный
                  )
      loop

        for err in (select (select t.cost_sum
                              from contrprclc t
                             where t.prn = nrn --- Наш исходный
                               and t.cost_article = cur.cost_article) sum_ish
                          ,(select t.cost_sum
                              from contrprclc t
                             where t.prn = ndup_rn --- Пересчитанный
                               and t.cost_article = cur.cost_article) sum_calc
                          ,fp.code
                      from fpdartcl fp
                     where fp.rn = cur.cost_article)
        loop

          /* Есть расхождения между тем что есть и что будет после расчета
          Удаляем фиктивную структуру и возвращаем 1
          */
          p_contrprstruct_base_delete(nrn => ndup_rn, ncompany => ncompany);
          return 1;

        end loop;
      end loop;
      --- Удаляем фиктивную структуру

    end loop;

    /* НЕТ расхождений между тем что есть и что будет после расчета
    Удаляем фиктивную структуру и возвращаем 0
    */
    p_contrprstruct_base_delete(nrn => ndup_rn, ncompany => ncompany);
    return 0;

  end;

  --#########################################################################################################
  procedure CONTRPRSTRUCT_SET_ACT
    /*Договоры (этапы, структура цены) Контроль значений зависимых строк при смене состояния ПОСЛЕ*/
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
   ) is
   begin
     USR_PKG_CONTRACTS.CONTRPRSTRUCT_MAKE_CNTRL(nRN, nCOMPANY);
   end;

   --#########################################################################################################
 procedure contrprstruct_bapprove
 /* Договоры (этапы, структура цены) Контроль значений зависимых строк при установке признака (Действующая/Не действующая) . ДО */
 (
   nrn      in number
  ,ncompany in number -- RN компании
 ) is
   nfl       number(3) := 0;
   nsign_act contrprstruct.sign_act%type := 0;
   /* проверим, есть ли сформированная калькуляция структуры цены */

 begin
   begin
     select ct.sign_act into nsign_act from CONTRPRSTRUCT ct where ct.rn = nrn;
   end;

   if nsign_act = 0 then
     --- Мы устанавливаем признак "Действующая

     begin

       select count(t.rn)
         into nfl
         from contrprclc t
        where t.prn = nrn
          and rownum = 1;


       if nfl = 0 then
         -- Делают действующей без заведения калькуляции, но мы ее сами создадим
         p_contrprstruct_make(ncompany => ncompany, nrn => nrn);
       end if;
     end;
   end if;

 end;

  --#########################################################################################################
  procedure contrprstruct_approve
  /* Договоры (этапы, структура цены) Контроль значений зависимых строк при установке признака (Действующая/Не действующая) . ПОСЛЕ */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  ) is
    sres varchar2(2000);
  begin

    /* Если калькуляция утверждена, то менять статус на не действующую Нельзя" */

    for cur in (select ct.sign_act
                  from contrprstruct ct
                  join stages st
                    on st.rn = ct.prn
                 where ct.rn = nrn
                   and st.calc_approved = 1 -- А калькуляция уже утверждена
                   and ct.sign_act = 0 -- ПОСЛЕ действия струткура цены стала НЕ Действующая
                )

    loop

      p_exception(0
                 ,'Перед тем как снять признак "Действуюшая" со структуры цены требуется отменить согласование калькуляции этапа проекта!');

    end loop;

    /*Контроль правильности признака разнесения косвенных затрат*/
    usr_p_contrprstruct_is_err2(nrn => nrn, nsign_act => 1, out_res => sres);
    if sres is not null then
      p_exception(0, sres);
    end if;
    usr_pkg_contracts.contrprstruct_make_cntrl(nrn, ncompany);
  end;

  --#########################################################################################################
  procedure CONTRPRSTRUCT_BINSERT
  /*
    Договоры (этапы, структура цены). Проверка после добавления
    */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
   ) is
   nduprn contrprstruct.rn%type;

begin
  for cur in (select t.prn
                    ,t.company
                    ,coalesce(t.date_to, t.date_from, sysdate) date_sign
                from contrprstruct t
               where t.rn = nrn
                 and t.calc_indir = 1)

  loop
    -- Проверим, есть ли действующая структура с признаком расчет косвенных затрат «По калькуляции»
    begin

      select str.rn
        into nduprn
        from contrprstruct str
       where str.prn = cur.prn
         and str.calc_indir = 1
         and str.sign_act = 1;

    exception
      when no_data_found then

        p_contrprstruct_set_state(ncompany    => cur.company
                                 ,nrn         => nrn
                                 ,nstate      => 1
                                 ,dstate_date => cur.date_sign);

        p_contrprstruct_set_act(ncompany  => cur.company
                               ,nrn       => nrn
                               ,nsign_act => 1
                               ,ddate     => cur.date_sign);
    end;

  end loop;

end;
  --#########################################################################################################
  procedure CONTRPRSTRUCT_AINSERT
  /*Договоры (этапы, структура цены).  Проверка после добавления */
  (
    nrn      in number
   ,ncompany in number
  ) is
    nfl integer := 1;
  begin
    begin

      
      /* Если других действующих структур с признаком "по калькуляции" нет, то делаем действующей эту (если она по калькуляции)*/
      for cur in (select t.prn
                        ,t.company
                        ,t.calc_indir
                    from contrprstruct t
                   where t.rn = nrn)
      loop
       
        --- Если расчет косвенных затрат "по калькуляции" и действующих цен по калькуляции нет, то утверждаем вводимую структуру

        if cur.calc_indir = 1 then
          for d in (select *
                      from contrprstruct t
                     where t.prn = cur.prn
                       and t.rn != nrn
                       and t.calc_indir = 1
                       and t.sign_act = 1)
          loop
            nfl := 0;
          end loop;

          if nfl = 1 then
            /*Утверждаем*/
            p_contrprstruct_set_state(ncompany    => cur.company
                                     ,nrn         => nrn
                                     ,nstate      => 2
                                     ,dstate_date => sysdate);
            /*Формируем строки*/
            p_contrprstruct_make(ncompany => cur.company, nrn => nrn);

            /*Делаем действующей*/
            p_contrprstruct_set_act(ncompany  => cur.company
                                   ,nrn       => nrn
                                   ,nsign_act => 1
                                   ,ddate     => sysdate);
          end if;
        else

          p_contrprstruct_make(ncompany => cur.company, nrn => nrn);
        end if;

      end loop;
    end;
  end;

  --#########################################################################################################

  procedure CONTRPRSTRUCT_BUPDATE
  /* Договоры (этапы, структура цены).  Проверка перед исправлением */
  (
   nRN      in number
   ,nCOMPANY in number -- RN компании
   ) is
   begin
     null;
   end;
  --#########################################################################################################

  procedure CONTRPRSTRUCT_AUPDATE
  /*  Договоры (этапы, структура цены).  Проверка после исправления */
  (nRN      in number
   ,nCOMPANY in number -- RN компании
   ) is
   begin
     null;
   end;
  --#########################################################################################################
  procedure CONTRPRSTRUCT_BDELETE(NRN IN NUMBER) is
   begin
     null;
   end;

  procedure CONTRPRSTRUCT_ADELETE
  /* Договоры (этапы, структура цены)  Проверка перед исправлением */
  (
   nRN      in number
  ,nCOMPANY in number -- RN компании
   ) is
   begin
     null;
   end;
  --#########################################################################################################



  function CONTRPRCLC_GET
  /* Договоры (этапы, структура цены, калькуляция). Считывание заголовка */
  (
   nRN         in number
  ,nFLAG_SMART in number default 0
  )
  return contrprclc%rowtype is

  rRow contrprclc%rowtype;

  begin
    begin
      select * into rRow from contrprclc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAG_SMART,
                                 ndocument   => nRN,
                                 sunit_table => ' CONTRPRCLC');
      when others then
        p_exception(0,
                    'Неопределённая ситуация при считывании строки калькуляции затрат с RN %s в разделе %s.',
                    nRN,
                    f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1,
                                                               stable_name => ' CONTRPRCLC')));
    end;
    return(rRow);
  END CONTRPRCLC_GET;

  --#########################################################################################################
  procedure CONTRPRCLC_BINSERT
  /*
    Договор (этапы).Калькуляция Проверка после добавления
    */
  (
    nRN      IN NUMBER
   ,nCOMPANY IN NUMBER -- RN компании
   ) IS
  BEGIN
    -- Очистка констант
    usr_pkg_pub_const.rStages := NULL;
  END CONTRPRCLC_BINSERT;

  --#########################################################################################################
procedure contrprclc_ainsert
/* Договор (этапы).Калькуляция  Проверка после добавления */
(
  nRN      in number
 ,nCOMPANY in number
) is
begin
  contrprclc_check_base(nRN, nCOMPANY);
end;
  --#########################################################################################################

  procedure CONTRPRCLC_BUPDATE
  /* Договор (этапы).Калькуляция  Проверка перед исправлением */
  (
    nrn      in number
   ,ncompany in number -- RN компании
  ) is
  begin
    null;
  end contrprclc_bupdate;
  --#########################################################################################################

  procedure CONTRPRCLC_AUPDATE
  /* Договор (этапы).Калькуляция  Проверка после исправления */
  (
    nRN      in number
   ,nCOMPANY in number -- RN компании
  ) is

  begin
   CONTRPRCLC_CHECK_BASE(nRN, nCOMPANY);
  end contrprclc_aupdate;
  /*#########################################################################################################*/

  /* Договор (этапы). Калькуляция  ДО удаления */
  procedure CONTRPRCLC_BDELETE(nrn in number) is
  begin
    usr_pkg_pub_const.rcontrprclc := contrprclc_get(nrn => nrn);
  end;
  /*#########################################################################################################*/

  procedure CONTRPRCLC_ADELETE
  /* Договор (этапы).Калькуляция  После удаления */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    /* Проводим переформирование калькуляции после каждого Удаления */

    /* Формируем калькуляцию  */
    p_contrprstruct_make(ncompany => ncompany, nrn => usr_pkg_pub_const.rcontrprclc.prn);

  end contrprclc_adelete;
--#########################################################################################################

procedure CONTRPRCLC_CHECK_BASE
/*
  Заголовок. Проверка общая
  */
(
  nRN      in number
 ,nCOMPANY in number -- RN компании
) is

  iFL  integer := 0;
  sRES varchar2(2000);

begin

  for cur in (select cl.prn
                    ,str.calc_indir /*  0-  прямые, 1 - калькуляция */
                    ,str.state /* Состояние (0 - Новая, 1 - Согласована, 2 - Утверждена, 3 - Аннулирована) */
                    ,shm.code
                    ,shm.rn
                    ,(select nvl(max(1), 0)
                        from prjcalcschmart t
                       where t.prn = shms.rn
                         and rownum = 1) dep
                from contrprclc cl
                join contrprstruct str
                  on str.rn = cl.prn
                join prjcalcschm shm
                  on shm.rn = str.calcschm
                join prjcalcschmsp shms
                  on shms.prn = shm.rn
                 and shms.fpdartcl = cl.cost_article
               where cl.rn = nrn)
  loop

    ifl := 1; -- Мы нашли статью в схеме калькуляции
    if cur.state != 0 then
      p_exception(0
                 ,'Изменение калькуляции в структуре цены, которая' ||
                  ' находится не в состоянии "Новая", невозможно.'||cr||
                  'Перед внесением измененний переведите структуру цены в состояние "Новая".');
    end if;

    if cur.calc_indir = 1 then

      p_exception(0
                 ,'Данная структура цены имеет признак расчета косвенных затрат "По калькуляции", соответственно ' ||
                  ' содержание калькуляции структуры цены определяется калькуляцией графика отпуска товаров и услуг данного этапа.' || cr ||
                  'Для формирвания калькуляции структуры цены воспользуйтесь действием "Сформировать" на структуре цены.');
    end if;

    if cur.dep = 1 then
      sres := ';';
      for err in (select fp.code
                    from contrprclc cl
                    join contrprstruct str
                      on str.rn = cl.prn
                    join prjcalcschm shm
                      on shm.rn = str.calcschm
                    join prjcalcschmsp sp
                      on sp.prn = shm.rn
                     and sp.fpdartcl = cl.cost_article
                    join prjcalcschmart s
                      on s.prn = sp.rn
                    join fpdartcl fp
                      on fp.rn = s.fpdartcl
                  ---
                   where cl.rn = nrn)
      loop
        if length(sres) < 1770 then
          sres := sres || ';' || err.code;
        end if;
      end loop;
      sres := substr(sres, 3);
      p_exception(0
                 ,'Статья %s рассчитывается на основании других строк калькуляции (%s). Ее прямое редактирование недопустимо. ' ||
                  'Для переcчета значения воспользуйтесь действием "Сформировать" на структуре цены.'
                 ,cur.code
                 ,sres);

    end if;

    if cur.calc_indir = 0 then
      p_contrprstruct_make(ncompany => ncompany, nrn => cur.prn);
    end if;

  /* Формируем калькуляцию  */

  end loop;
  if ifl = 0 then
    begin
      select 'Невозможно добавление статьи с кодом: ' || fp.code || ' наименованием: ' || fp.name ||
             ', отсутствующей в схеме калькуляции структуры цены"' || shm.code ||
             '". Рекомендуем воспользоваться действием "Сформировать" на структуре цены.'
        into sres
        from contrprclc cl
        join contrprstruct str
          on str.rn = cl.prn
        join prjcalcschm shm
          on shm.rn = str.calcschm
        join fpdartcl fp
          on fp.rn = cl.cost_article
       where cl.rn = nrn;
    exception
      when no_data_found then
        sres := 'Не найдена статья калькуляции'; -- скорее всего невозможно
    end;

    p_exception(0, sres);
  end if;
end;




end USR_PKG_CONTRACTS;
/
