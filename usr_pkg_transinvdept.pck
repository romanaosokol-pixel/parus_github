create or replace package USR_PKG_TRANSINVDEPT IS
  /*
  Package предназначен для работы с разделом "Расходные накладные на отпуск в подразделения". Степанов М. 12/04/2021
  GoodsTransInvoicesToDepts       TRANSINVDEPT        TID
  GoodsTransInvoicesToDeptsSpecs  TRANSINVDEPTSPECS   TIDS
  GoodsTransInvoicesToDeptsCalcs  TRANSINVDEPTCLC     TIDSC
  */
  /*#########################################################################################################*/

  function TRANSINVDEPT_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ) 
  return TRANSINVDEPT%ROWTYPE;
  /*#########################################################################################################*/

  function TRANSINVDEPT_IS_COMPLETED
  /*
  Заголовок. Накладная скомплектована
  */
  (
   nRN          in number 
  ) 
  return number;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BPROCESS
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_APROCESS
  /*
  Заголовок. Проверка после отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BPROCESSWITH
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_APROCESSWITH
  /*
  Заголовок. Проверка после отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BCANCEL
  /*
  Заголовок. Проверка перед снятием отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ACANCEL
  /*
  Заголовок. Проверка после отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ARESERV
  /*
  Заголовок. Проверка после резервирования
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ASTPL_PROC
  /*
  Заголовок. Проверка после списания с мест хранения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BSTPL_DIST_PROC
  /*
  Заголовок. Проверка до Распределение спецификации по местам хранения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ASTPL_DIST_PROC
  /*
  Заголовок. Проверка после распределения по местам хранения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AMAKEINVOICE
  /*
  Заголовок. Проверка после формирования возвратной накладной в подразделения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AMAKEPRODORD
  /*
  Заголовок. Проверка после формирования заказа на производство
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_INSERT
  /*
  Заголовок. Добавить
  */
  (
   rV_ROW   in out v_transinvdept%rowtype
  ,sMSG     out varchar2
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_UPDATE
  /*
  Заголовок. Добавить
  */
  (
   rV_ROW           in v_transinvdept%rowtype
  ,nSTATUS_IGNORE   in number default 0  /* Исправлять отработанный 0-нет, 1-да */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BASE_INSERT
  /*
  Заголовок. Добавить. Базовая
  */
  (
   rROW           in transinvdept%rowtype
  ,nRESERV_SIGN   in number default 0
  ,nRN            out number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BASE_UPDATE
  /*
  Заголовок. Исправить. Базовая
  */
  (
   rROW             in transinvdept%rowtype
  ,nSTATUS_IGNORE   in number default 0  /* Исправлять отработанный 0-нет, 1-да */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BASE_DELETE
  /*
  Заголовок. Удалить. Базовая
  */
  (
   nCOMPANY     in number
  ,nRN          in number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_MAKE_IFD
  /*
  Заголовок. Сформировать зеркальный документ в Приход из подразделений
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ,nIFD      out number
  );
  /*#########################################################################################################*/
  
  procedure TRANSINVDEPT_MAKE_TID
  /*
  Заголовок. Сформировать возвратную накладную на отпуск в подразделения
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,dDOCDATE         in date
  ,sCATALOG         in varchar2
  ,sSTORE           in varchar2
  ,nGOODSPARTIES    in number default null /* Приходная партия. Если не пустая, то формировать только по ней */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_MAKE_RITS
  /*
  Заголовок. Сформировать расходную накладную на возврат посавтщикам
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2
  ,sDOC_TYPE        in varchar2
  ,sDOC_PREF        in varchar2
  ,sSTORE_OPER      in varchar2
  ,sPAY_TYPE        in varchar2
  ,nWORK            in number default 0 /* Отработать: 0-нет, 1-да */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_LINK_TO_DPO
  /*
  Заголовок. Привязать отработанный документ к заказу подразделения
  */
  (
   nCOMPANY   in number
  ,nRN        in number /* РН в позразделение */
  ,nDPO       in number /* Заказ подразделения */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_SPRJ_COPY
  /*
  Заголовок. Копировани из мест хранения для списания в места хранения для распределения
  */
  (
   nRN        in number
  );
  /*########################################################################################################*/

  procedure TRANSINVDEPT_SPRJ_COPY_OTHER
  /*
  Процедура копирования резервирования по местам хранения в другой (или тот же) документ, из мест для списания или для распределения
  */
  (
   nFLAGSMART           in number default 0
  ,nRN_FROM             in number           /* Документ-источник. Заголовок. RN */
  ,nRES_TYPE_FROM       in number default 0 /* Документ-источник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,nRN_TO               in number           /* Документ-приёмник. Заголовок. RN */
  ,nRES_TYPE_TO         in number default 1 /* Документ-приёмник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,dRESERVING_DATE      in date             /* Документ-приёмник. Дата резервирования */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_SPRJ_MINS
  /*
  Заголовок. Массовое резервирование по местам хранения
  */
  (
   nCOMPANY       in number                 /* Рег номер организации */
  ,sUNITCODE      in varchar2 default null  /* Код раздела (не используется) */
  ,nCRN           in number   default null  /* каталог */
  ,nRN            in number                 /* Рег номер */
  ,nIDENT         in number   default null  /* Идент выделенных записей (не используется) */
  ,sSTORE         in varchar2 default null  /* склад */
  ,sCELL          in varchar2 default null  /* место хранения (резервуар) */
  ,nRES_TYPE      in number   default 1     /* тип резервирования (0 - приход, 1 - расход) */
  ,nREPLACE       in number   default 0     /* Распределение с заменой найденных записей (0 - нет, 1 - да) */
  ,nRETURN        in number   default 0     /* признак возвратной накладной (0 - нет, 1 - да) */
  ,dRESERVINGDATE in date     default null  /* дата и время резервирования. */
  ,nOUTNOTE       out number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_FIND_SPECS_SAME
  /*
  Заголовок. Поиск спецификаций с такой же Партией поставщика, и отправка уведомления, если найдены
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  function TRANSINVDEPTBUF_GET
  /*
  Заголовок (буфер). Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvdeptbuf%rowtype;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTBUF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW     in transinvdeptbuf%rowtype
  );
  /*#########################################################################################################*/

  function TRANSINVDEPTSPECS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return TRANSINVDEPTSPECS %ROWTYPE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BASE_INSERT
  /*
  Спецификация. Добавить. Базовая
  */
  (
   rROW           in transinvdeptspecs%rowtype
  ,nFROM_CLIENT   in number default 0
  ,nRN            out number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправить. Базовая
  */
  (
   rROW  in transinvdeptspecs%rowtype
  );
  /*#########################################################################################################*/

  PROCEDURE TRANSINVDEPTSPECS_BASE_DELETE
  /*
  Спецификация. Удалить. Базовая
  */
  (
   nCOMPANY     in number
  ,nRN          in number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_INSERT
  /*
  Спецификация. Добавить
  */
  (
   rV_ROW   in out v_transinvdeptspecs%rowtype
  ,sMSG     out varchar2
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_UPDATE
  /*
  Спецификация. Исправить
  */
  (
   rV_ROW  in v_transinvdeptspecs%rowtype
  );
  /*#########################################################################################################*/

  function TRANSINVDEPTCLC_GET
  /*
  Калькуляция. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvdeptclc%rowtype;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_AINSERT
  /*
  Калькуляция. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_BUPDATE
  /*
  Калькуляция. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_AUPDATE
  /*
  Калькуляция. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_BDELETE
  /*
  Калькуляция. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_CHECK_BASE
  /*
  Калькуляция. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

end USR_PKG_TRANSINVDEPT;
/
create or replace package body USR_PKG_TRANSINVDEPT is

  /*#########################################################################################################*/

  function TRANSINVDEPT_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvdept%rowtype
  is
    rRow transinvdept%rowtype;
  begin
    begin
      select * into rRow from transinvdept where RN = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'TRANSINVDEPT');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPT'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end TRANSINVDEPT_GET;
  /*#########################################################################################################*/

  function TRANSINVDEPT_IS_COMPLETED
  /*
  Заголовок. Накладная скомплектована
  */
  (
   nRN          in number 
  ) 
  return number
  is
    nNumber pkg_std.tnumber  := 0;
  begin
    begin
    select 1
      into nNumber
      from transinvdept t
          ,clnevents    ce
     where t.rn           = nRN
       and t.status       = 0
       and ce.linked_rn   = t.rn
       and ce.event_stat  in (40677676 /* Скомплектовано */
                             ,48933526 /* Передано в ОТК */
                             ,48933537 /* Скомплектовано с ОТК  */
                             ,40677679 /* ВыданоПроизводство  */
                             );
    exception
      when no_data_found then
        nNumber := 0;
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPT'))
                   ,cr||cr||sqlerrm );
    end;

    return(nNumber);

  end TRANSINVDEPT_IS_COMPLETED;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  Is
    rRow                transinvdept%rowtype; 
    rClnEvents          clnevents%rowtype; 

    nNumber             pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := transinvdept_get(nrn => NRN); 

    /* ИСПРАВЛЕНИЯ */
    /* Каталог 'Сборка, разборка' */
    if rRow.crn = 83372131 then
      /* Добавление зеркального документа в Приход из подразделений */
      transinvdept_make_ifd( nrn => rRow.rn, ncompany => rRow.company, nifd => nNumber );
    end if;

    /* Если примечание заполнено */
    if rRow.comments is not null then
      /* Поиск события статусной модели */
      rClnEvents.rn := usr_pkg_document.get_clnevents( nflagsmart => 1, nrn => rRow.rn );
      /* Если событие найдено */
      if rClnEvents.rn is not null then
        /* Считывание события */
        rClnEvents := usr_pkg_clnevents.clnevents_get( nrn => rClnEvents.rn );
        /* Добавление примечания к событию с новым текстом */
        usr_pkg_clnevents.clnevnotes_insert( ncompany     => rClnEvents.company
                                            ,nprn         => rClnEvents.rn
                                            ,snote_header => 'ПримечаниеРвПодр'
                                            ,snote        => rRow.comments
                                            ,nrn          => nNumber 
                                            ,nmode        => 1 );
      end if;
    end if;
    
    /* ПРОВЕРКИ */
    /* Базовая */
    transinvdept_check_base(nrn => NRN, ncompany => NCOMPANY);

    /* По спецификациям */
    for c in (select * from transinvdeptspecs where prn = NRN) 
    loop
      /* проверка спецификации */
      transinvdeptspecs_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;

  end TRANSINVDEPT_AINSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание */
    usr_pkg_pub_const.rtransinvdept := transinvdept_get(nrn => NRN); 

  end TRANSINVDEPT_BUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                transinvdept%rowtype; 
    rV_Row              v_transinvdept%rowtype; 
    sAcatalog           acatalog.name%type;
    nIncomFromDeps      pkg_std.tref; 
    rV_IncomeFromDeps   v_incomefromdeps%rowtype;
    rClnEvents          clnevents%rowtype;

    nNumber             pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow        := transinvdept_get(nrn => NRN); 
    sAcatalog   := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* ИСПРАВЛЕНИЯ */
    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      /* Представление заголовка */
      select *  into rV_Row from v_transinvdept where nrn = rRow.rn;
      /* Считывание  связанного по выходу документа */
      nIncomFromDeps := f_doclinks_link_out_doc('GoodsTransInvoicesToDepts', rRow.rn, 'IncomFromDeps');
      /* если не найден */
      if nIncomFromDeps is null then
        p_exception(0, 'Документ в каталоге "%s" не имеет связанного документа в разделе "%s". %s'
                   ,sAcatalog
                   ,f_unitlist_getname(sunitcode => 'IncomFromDeps')
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end if;
      select * into rV_IncomeFromDeps from v_incomefromdeps where nrn = nIncomFromDeps;
      /* подмена значений в записи связанного документа */
      rV_IncomeFromDeps.ddoc_date       := rV_Row.ddocdate;
      rV_IncomeFromDeps.sdoc_pref       := rV_Row.spref;
      rV_IncomeFromDeps.sout_department := rV_Row.ssubdiv;
      rV_IncomeFromDeps.sout_faceacc    := rV_Row.sfaceacc;
      rV_IncomeFromDeps.sstore          := rV_Row.sstore;
      rV_IncomeFromDeps.sagent          := rV_Row.smol;
      rV_IncomeFromDeps.snote           := rV_Row.scomments;      
      /* исправление связанного документа */
      P_INCOMEFROMDEPS_UPDATE(NRN               => rV_IncomeFromDeps.nrn
                             ,NCOMPANY          => rV_IncomeFromDeps.ncompany
                             ,SJUR_PERS         => rV_IncomeFromDeps.sjur_pers
                             ,SDOC_TYPE         => rV_IncomeFromDeps.sdoc_type
                             ,SDOC_PREF         => rV_IncomeFromDeps.sdoc_pref
                             ,SDOC_NUMB         => rV_IncomeFromDeps.sdoc_numb
                             ,DDOC_DATE         => rV_IncomeFromDeps.ddoc_date
                             ,SVALID_DOCTYPE    => rV_IncomeFromDeps.svalid_doctype
                             ,SVALID_DOCNUMB    => rV_IncomeFromDeps.svalid_docnumb
                             ,DVALID_DOCDATE    => rV_IncomeFromDeps.dvalid_docdate
                             ,SOUT_DEPARTMENT   => rV_IncomeFromDeps.sout_department
                             ,SOUT_FACEACC      => rV_IncomeFromDeps.sout_faceacc
                             ,SOUT_GRAPHPOINT   => rV_IncomeFromDeps.sout_graphpoint
                             ,SOUT_STORE        => rV_IncomeFromDeps.sout_store
                             ,SPARTY_AGENT      => rV_IncomeFromDeps.sparty_agent
                             ,SSTORE            => rV_IncomeFromDeps.sstore
                             ,SAGENT            => rV_IncomeFromDeps.sagent
                             ,SCURRENCY         => rV_IncomeFromDeps.scurrency
                             ,SSTORE_OPER       => rV_IncomeFromDeps.sstore_oper
                             ,SPARTY            => rV_IncomeFromDeps.sparty
                             ,SNOTE             => rV_IncomeFromDeps.snote
                             ,NCURCOURS         => rV_IncomeFromDeps.ncurcours
                             ,NCURBASECOURS     => rV_IncomeFromDeps.ncurbasecours
                             ,NCURCOURS_DOC     => rV_IncomeFromDeps.ncurcours_doc
                             ,NCURBASECOURS_DOC => rV_IncomeFromDeps.ncurbasecours_doc
                             ,SBARCODE          => rV_IncomeFromDeps.sbarcode);
    end if;

    /* Если изменилось примечание */
    if cmp_vc2( usr_pkg_pub_const.rtransinvdept.comments, rRow.comments ) != 1 then
      /* Поиск события статусной модели */
      rClnEvents.rn := usr_pkg_document.get_clnevents( nflagsmart => 1, nrn => rRow.rn );
      /* Если событие найдено */
      if rClnEvents.rn is not null then
        /* Считывание события */
        rClnEvents := usr_pkg_clnevents.clnevents_get( nrn => rClnEvents.rn );
        /* Добавление примечания к событию с новым текстом */
        usr_pkg_clnevents.clnevnotes_insert( ncompany     => rClnEvents.company
                                            ,nprn         => rClnEvents.rn
                                            ,snote_header => 'ПримечаниеРвПодр'
                                            /* вырезаем старое примечание из нового, чтобы записать только новое */
                                            ,snote        => usr_f_trim( replace( rRow.comments, usr_pkg_pub_const.rtransinvdept.comments ) ) 
                                            ,nrn          => nNumber 
                                            ,nmode        => 1 );
      end if;
    end if;
    
    
    /* ПРОВЕРКИ */
    /* Базовая */
    transinvdept_check_base(nrn => NRN, ncompany => NCOMPANY);
    
    /* Исправление склада-получателя */
    if nvl(rRow.in_store, 0) != nvl(usr_pkg_pub_const.rtransinvdept.in_store, 0) then
      /* Наличие распределения по местам хранения */
      for c in (
                select sprj.rn
                  from doclinks     dl
                      ,strplresjrnl sprj
                 where dl.in_document  = nRN
                   and dl.out_document = sprj.rn
                   and sprj.res_type   = 0
               )
      loop
        p_exception(0, 'Исправление склада-получателя запрещено, т.к. у документа есть записи резервирования распределения по местам хранения. '||
                   cr||' Склад-получатель до: %s'||
                   cr||' Склад-получатель после: %s. %s'
                   ,f_dicstore_get_numb(nstore => usr_pkg_pub_const.rtransinvdept.in_store)
                   ,f_dicstore_get_numb(nstore => rRow.in_store)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end loop;
    end if;

  end TRANSINVDEPT_AUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BDELETE
  /*
  Заголовок. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  Is
    rRow            transinvdept%rowtype; 
    sAcatalog       acatalog.name%type;
    nIncomFromDeps  pkg_std.tref; 
  begin
    /* Считывание */
    rRow        := TRANSINVDEPT_GET(NRN); 
    sAcatalog   := GET_ACATALOG_NAME_ID(0, rRow.crn);

    /* ИСПРАВЛЕНИЯ */
    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then

      /* Удаление журнала резервирования по местам хранения */
      usr_pkg_document.strplresjrnl_delete(NRN => rRow.rn);

      /* Считывание  связанного по выходу документа */
      nIncomFromDeps := f_doclinks_link_out_doc('GoodsTransInvoicesToDepts', rRow.rn, 'IncomFromDeps');

      /* если связанный документ найден */
      if nIncomFromDeps is not null then
        /* удаление */
        p_incomefromdeps_delete(ncompany => rRow.company, nrn => nIncomFromDeps);
      end if;
    end if;
    
    /* ПРОВЕРКИ */

  end TRANSINVDEPT_BDELETE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end TRANSINVDEPT_BMOVE_IN;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  Is
    rRow        transinvdept%rowtype;
    sAcatalog   acatalog.name%type;
  BeGIN
    /* Считывание */
    rRow      := TRANSINVDEPT_GET(NRN); 
    sAcatalog := GET_ACATALOG_NAME_ID(0, rRow.crn);

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      p_exception(0, 'Запрещено переносить документ из каталога "%s". %s'
                 ,sAcatalog
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn) ); 
    end if;

  end TRANSINVDEPT_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdept%rowtype;
  begin
    /* Заголовок  */  
    rRow := transinvdept_get(NRN);

    /* Запрет отработки как план */
    if rRow.status = 1 then
      p_exception(0, 'Запрещено отрабатывать документ как план %s.%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn) ); 
    end if;

  end TRANSINVDEPT_AASPLAN;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BPROCESS
  /*
   Заголовок. Проверка перед отработкой
   */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
    nfl             integer := 0;
    rRow            transinvdept%rowtype; 
    rStOper         azsgsmwaystypes%rowtype; 
    nInDocument     pkg_std.tref; 
    nQuantRes       pkg_std.tquant; 
  begin
    /*Городецкий 13-01-2025*/
    begin
      select 1
        into nfl
        from transinvdeptspecs ts
       where ts.prn = nrn
         and rownum = 1;
    exception
      when no_data_found then
        nfl := 0;
    end;
    p_exception(nfl, 'Нельзя отрабатывать накладную, не содержащую спецификации.');
  
    /* Считывание */
    rRow := transinvdept_get(nrn => nRN); 

    /* Складская операция отправителя */
    select * into rStOper from azsgsmwaystypes where rn = rRow.stoper;

    /* RN входного документа в разделе РН в подразделения */
    nInDocument := f_doclinks_link_in_doc(sout_unitcode => 'GoodsTransInvoicesToDepts', nout_document => rRow.rn, sin_unitcode => 'GoodsTransInvoicesToDepts');
    
    /* ИСПРАВЛЕНИЯ */
    /* Если есть связи по входу с разделом РН в подразделения */
    if nInDocument is not null then

      /* Если складская операция отправителя имеет тип "Расход"  */
      if ( rStOper.gsmways_type = 0 ) then
        /* Удаление входных связей с разделом РН в подразделения (для пользовательской процедуры формирования РН в подр. из РН в подр.) */
        usr_pkg_pub_const.aRN_Unit_List.delete;
        usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 0
                                           ,nrn           => rRow.rn
                                           ,ncompany      => rRow.company
                                           ,sunitcode     => 'GoodsTransInvoicesToDepts'
                                           ,arn_unit_list => usr_pkg_pub_const.aRN_Unit_List
                                           ,nmode         => 0 );
      end if;
      
      /* Если лицевой счёт списания 10/1, 12/1, ??? 0000 */
      if rRow.faceacc in (6991753, 56844386/*, 13098607*/) then
        /* По спецификациям */
        for c in (select * from transinvdeptspecs where prn = rRow.rn)
        loop
          nQuantRes := 0;
          /* Исполнение заказа подразделений (резервы под заказ и выдача в производство) */
          for c1 in ( select t.*
                        from resjournal       rj
                            ,goodssupply      gs
                            ,udo_depords_prf  t
                       where gs.store         = rRow.store
                         and gs.prn           = c.goodsparty
                         and rj.supply        = gs.rn
                         and rj.res_end_date  is null
                         and t.rsrv           = rj.rn )
          loop   
            /* Вычисление количества для снятия с резерва */
            nQuantRes := c.quant - nQuantRes;
            nQuantRes := least(nQuantRes, c1.quant);
            /* Снятие с резерва */
            udo_p_departmentords_rsrv_free(nrn => c1.rsrv, ncompany => c.company, nquant => nQuantRes);
          end loop;
        end loop;
      end if;
    end if;

  end TRANSINVDEPT_BPROCESS;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_APROCESS
  /*
  Заголовок. Проверка после отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            transinvdept%rowtype; 
    nIncomeFromDeps pkg_std.tref; 
    rStOper         azsgsmwaystypes%rowtype; 
    rIn_Store       azsazslistmt%rowtype; 
    nGP_PayAccIn    pkg_std.tref; 
    nGP_AgnList     pkg_std.tref; 
    rGP_PayAccIn    payaccin%rowtype; 
    rPAI_AgnList    agnlist%rowtype; 
    rGP_AgnList     agnlist%rowtype; 
    rGoodsParties   goodsparties%rowtype; 
    nInOrders       pkg_std.tnumber; 
    
    nNumber         pkg_std.tnumber; 
    sVarchar        pkg_std.tstring; 
    cClob           clob;
    nCLC_Q         TRANSINVDEPTCLC.QUANT_PLAN%type;
    
  begin
    /* Считывание */
    rRow := transinvdept_get(nrn => NRN); 
    /* Поиск входной связи Пиходный ордер -> Сертификация -> Расходная накладная в подразделение */
    nInOrders := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                               ,sout_unitcode => 'GoodsTransInvoicesToDepts'
                                               ,nout_document => rROW.RN
                                               ,sin_unitcode  => 'IncomingOrders' 
                                               ,srule_chains  => ';GoodsTransInvoicesToDepts<UdoProdCull<IncomingOrders;' );
    /* ИСПРАВЛЕНИЯ */
    /* Каталоги 'Сборка, разборка' */
    if rRow.crn = 83372131 then
      /* Считывание связанного документа в Приходе из подразделений */
      nIncomeFromDeps := usr_pkg_doclinks.doclinks_link_out_doc(ntoo_many_rows => 0
                                                               ,sin_unitcode   => 'GoodsTransInvoicesToDepts'
                                                               ,nin_document   => rRow.rn
                                                               ,sout_unitcode  => 'IncomFromDeps');
      /* отработка */
      p_incomefromdeps_set_status(ncompany    => rRow.company
                                  ,nrn        => nIncomeFromDeps
                                  ,nident     => null
                                  ,nstatus    => 2
                                  ,dworkdate  => rRow.work_date
                                  ,nwarning   => nNumber
                                  ,smsg       => sVarchar
                                  ,nshow_msg  => nNumber);
    end if;

    /* Если вид отгрузки "Проверено ОТК" */
    if rRow.sheepview in ( 50928185 ) then 
      /* Копирование доп.данных из свойств спецификации в приходную партию */
      usr_pkg_document.spec_props_copy_to_gp( nprn => rRow.rn ); 
    end if;

    
    /* ПРОВЕРКИ */
    /* Базовая */
    transinvdept_check_base(nrn => NRN, ncompany => NCOMPANY);
    
    /* Складская операция отправителя */
    select * into rstoper from azsgsmwaystypes where rn = rrow.stoper;
    
    /* Если указан склад-получатель, и складская операция расход, и выполняется НЕ Отработка с приходом */
    if  rRow.in_store is not null 
    and rStOper.gsmways_type = 0
    and rRow.in_status      != 1 then
      p_exception(0, 'В документе указан склад-получатель. Выполните "Отработать с приходом" или очистите поле Склад-получатель в заголовке. %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if;

    /* Не указаны ни склад-получатель, ни лицевой счёт */
    if rRow.in_store is null and rRow.faceacc is null then
      p_exception(0, 'В документе не указаны ни склад-получатель, ни лицевой счёт. %s'
                 ,cr||cr|| f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn ) ); 
    end if;

    /* Каталоги 'Сборка, разборка' */
    if rRow.crn = 83372131 then
      /* Дата отработки равна дате документа */
      if cmp_dat(rRow.work_date, rRow.docdate) != 1 then
        p_exception(0, 'Дата отработки %s не равна дате документа %s. %s'
                   ,d2s(rRow.work_date)
                   ,d2s(rRow.docdate)
                   ,cr||f_docdescrs_get_description('GoodsTransInvoicesToDepts', rRow.rn)); 
      end if;
      /* Если дата отработки с приходом не пустая, должна равняться дате отработки*/
      if rRow.in_work_date is not null 
      and cmp_dat(rRow.in_work_date, rRow.docdate) != 1 then
        p_exception(0, 'Дата отработки с приходом %s не равна дате отработки %s. %s'
                   ,D2S(rRow.in_work_date)
                   ,D2S(rRow.docdate)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end if;
    end if;

    /* Дата отработки больше текущей даты */
    if cmp_dat_minmax(rRow.work_date, current_date) > 0 then
      p_exception(0, 'Дата отработки %s больше текущей даты %s. %s'
                 ,d2s(rRow.work_date)
                 ,d2s(current_date)
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if;

    /* Если каталог Метрология */
    if cmp_num(rRow.crn, usr_pkg_pub_const.ntid_cat_mtlg) = 1 then
      /* Контрагент "Администратор" */
      if nvl(rRow.in_mol, 0) = 1079705 then
        p_exception(0, 'В поле "Получатель. МОЛ" указан неверный контрагент". %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end if;
      /* Вид отгрузки Мат.ценности */
      /*if cmp_num(rRow.sheepview, 100723866) != 1 then
        p_exception(0, 'В поле "Вид отгрузки" должно быть указано <ВнутПеремМЦ>. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end if;*/
    end if;    

    /* Склад-получатель указан */
    if rRow.in_store is not null then
      /* Считывание записи склада-получателя */
      rIn_Store := udo_pkg_get.row_store(nrn => rRow.in_store, nsmart => 0);
      /* вид склада Сертификация */
      if nvl(rIn_Store.stkind, 0) = 47814988 then
        /* базовое перемещение документа в разделе в каталог Сертификация */
        pkg_document.base_move(imove_type => 1
                              ,sunitcode => 'GoodsTransInvoicesToDepts'
                              ,ndocument => rRow.rn
                              ,ntarget   => 47815697);
                              
       /* Городецкий 18/03/2025  Снятие резервирования с отработанной накланой на склад сертификации */                       
                              
       usr_p_transinvdept_res_del(nrn => rRow.rn, nskl_type => rIn_Store.stkind);
          
      end if;

      /* Каталог склада Поставщики_Брак */
      if rIn_Store.crn = 41446847 then

        /* Уведомление в ОМТС */
        /* По спецификациям */
        for c in (select dnm.nomen_code
                        ,dnm.nomen_name
                        ,nm.modif_code
                        ,nm.modif_name
                        ,icd.code
                        ,gp.sernumb
                        ,t.quant
                        ,t.summwithnds
                        ,icd.entry_date
                        ,gp.rn as gp_rn
                        ,rownum
                    from transinvdeptspecs t
                        ,dicnomns         dnm
                        ,nommodif         nm
                        ,goodsparties     gp
                        ,incomdoc         icd
                   where t.prn        = rRow.rn
                     and nm.rn        = t.nommodif
                     and dnm.rn       = nm.prn
                     and t.goodsparty = gp.rn
                     and gp.indoc     = icd.rn )
        loop
          /* Если первая запись */
          if c.rownum = 1 then
            /* Считывание данных приходных документов приходной партии товара */
            usr_pkg_goodsparties.goodsparties_get_indocs_data(ssernumb        => c.sernumb
                                                             ,nflagsmart      => 1
                                                             ,ntoo_many_rows  => 1
                                                             ,ngp             => nNumber
                                                             ,nio             => nNumber
                                                             ,nios            => nNumber
                                                             ,niiv            => nNumber
                                                             ,niivs           => nNumber
                                                             ,npai            => nGP_PayAccIn
                                                             ,npais           => nNumber
                                                             ,nce             => nNumber
                                                             ,nal             => nGP_AgnList);
          end if;
          /* Формирование текста спецификации */
          cClob := strcombine(cClob, cr|| c.nomen_name ||', '|| c.modif_name );
          cClob := strcombine(cClob, c.sernumb, ', Серия: ');
          cClob := strcombine(cClob, to_char(c.entry_date, 'dd.mm.yyyy'), ', Поступление: ');
        end loop;
        /* Считывание входящего счёта и контрагента его поставщика */
        if nGP_PayAccIn is not null then
          rGP_PayAccIn := usr_pkg_payaccin.payaccin_get(nrn => nGP_PayAccIn);
          rPAI_AgnList := usr_pkg_agnlist.agnlist_get(nrn => rGP_PayAccIn.supplier);
        end if;
        /* Считывание контрагента инициатора вх.счёта */
        if nGP_AgnList is not null then
          rGP_AgnList  := usr_pkg_agnlist.agnlist_get(nrn => nGP_AgnList);
        end if;
        /* Отправка уведомления в ОМТС */
        usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany     => rRow.company
                                                   ,sdescription => 'Отработан документ на склад "Поставщики_Брак". ' ||pkg_document.make_number(ndoc_type => null, sdoc_pref => rRow.pref, sdoc_numb => rRow.numb, ddoc_date => rRow.docdate)
                                                   ,sto_list     => 'snab@module.ru'
                                                   ,stitle       => 'Отработан документ на склад "Поставщики_Брак" в разделе: "'||f_unitlist_getname(sunitcode => 'GoodsTransInvoicesToDepts')||'"'
                                                   ,ctext        => pkg_document.make_number(ndoc_type => null, sdoc_pref => rRow.pref, sdoc_numb => rRow.numb, ddoc_date => rRow.docdate)
                                                                    ||cr||'Склад: '|| rIn_Store.azs_number
                                                                    ||cr||'Поставщик: '|| rPAI_AgnList.agnabbr
                                                                    ||cr||'Инициатор вх.счёта: ' || rGP_AgnList.agnabbr
                                                                    ||cr||cClob /* спецификации */
                                                   ,nrn          => nNumber);
      end if;
    end if;

    /* По спецификациям */
    for c in (select * from transinvdeptspecs where prn = rRow.rn)
    loop
      /* Партия или изделие должны быть заполнены */
      if c.goodsparty is null and c.article is null 
      and not usr_pkg_common.is_lists_intersect(slist1 => 'TRANSINVDEPT_APROCESS.1', slist2 => usr_pkg_pub_const.sexceptionlist) then
        p_exception(0, 'В спецификации не указана партия или изделие. %s%s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => c.rn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => c.prn)); 
      end if;

      /* Каталог склада-получателя Поставщики_Брак */
      if rIn_Store.crn = 41446847 then
        /* Приходная партия текущей спецификации */
        rGoodsParties := usr_pkg_goodsparties.goodsparties_get( nrn => c.goodsparty );
        /* По другим спецификациям текущего документа, у которых другая приходная партия */
        for c1 in ( select t.rn, t.prn, icd.code, gp.sernumb
                      from transinvdeptspecs  t
                          ,goodsparties       gp
                          ,incomdoc           icd
                     where t.prn         = c.prn
                       and t.rn         != c.rn
                       and t.goodsparty  = gp.rn
                       and gp.indoc      = icd.rn
                       and gp.indoc     != rGoodsParties.indoc )
        loop
          p_exception(0, 'В документе присутствует спецификация с другой партией прихода <%s>. %s%s'
                     ,'Партия: ' || c1.code || ', Серия: ' || c1.sernumb
                     ,cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => c1.rn )
                     ,cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => c1.prn ) ); 
        end loop;               
      end if;

      /* Если есть входная связь Пиходный ордер -> Сертификация -> Расходная накладная в подразделение */
      if nInOrders is not null then
        /* Считаем количество по калькуляциям */
        select nvl( sum( quant_plan ), 0 )
          into nCLC_Q  
          from transinvdeptclc
         where prn = c.rn;

        /* Если количество по калькуляциям не равно количеству в спецификации */
        if cmp_num( nCLC_Q, c.quant ) != 1 then
          p_exception(0, 'Количество план по калькуляциям <%s> не равно количеству в спецификаци <%s>.%s%s'
                     ,nCLC_Q
                     ,c.quant
                     ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => c.rn )
                     ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => c.prn ) ); 
        end if;                   
      end if;

    end loop;

    /* Если список удалённых связей не пустой */
    if usr_pkg_pub_const.aRN_Unit_List.count != 0 then
      /* Восстановление связей с разделом РН в подразделения */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 0
                                         ,nrn           => rRow.rn
                                         ,ncompany      => rRow.company
                                         ,sunitcode     => 'GoodsTransInvoicesToDepts'
                                         ,arn_unit_list => usr_pkg_pub_const.aRN_Unit_List
                                         ,nmode         => 1 );
      /* Очистка списка удалённых связей */
      usr_pkg_pub_const.aRN_Unit_List.delete;
    end if;

  end TRANSINVDEPT_APROCESS;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BPROCESSWITH
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
    /* Считывание */
    /*USR_PKG_PUB_CONST.RTRANSINVDEPT := TRANSINVDEPT_GET(NRN); 
    USR_PKG_DOCS_PROPS_VALS.GET_VALS_DOCUMENT_TYPE(NRN, USR_PKG_PUB_CONST.aPropsBefore);*/

  end TRANSINVDEPT_BPROCESSWITH;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_APROCESSWITH
  /*
  Заголовок. Проверка после отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdept%rowtype;
  begin
    /* Считывание записи */
    rRow := transinvdept_get(NRN);

    /* ПРОВЕРКИ */
    if cmp_dat(rRow.in_work_date, rRow.docdate) != 1 then
      p_exception(0, 'Дата отработки с приходом %s не равна дате документа %s.%s'
                 ,d2s(rRow.in_work_date)
                 ,d2s(rRow.docdate)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn) ); 
    end if;

    /* Базовая */
    transinvdept_check_base(nrn => NRN, ncompany => NCOMPANY);
    
  end TRANSINVDEPT_APROCESSWITH;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BCANCEL
  /*
  Заголовок. Проверка перед снятием отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    sAcatalog       acatalog.name%type;
    nIncomFromDeps  pkg_std.tref; 
    rRow            transinvdept%rowtype; 
    rStOper         azsgsmwaystypes%rowtype; 
  begin
    /* Считывание */
    usr_pkg_pub_const.rtransinvdept := transinvdept_get(nrn => NRN); 
    rRow        := usr_pkg_pub_const.rtransinvdept; 
    sAcatalog   := get_acatalog_name_id(nflag_smart => 0, nrn => usr_pkg_pub_const.rtransinvdept.crn);
    usr_pkg_pub_const.nRef := null;
    /* Складская операция отправителя */
    select * into rStOper from azsgsmwaystypes where rn = rRow.stoper;

    /* ИСПРАВЛЕНИЯ  */
    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      /* Считывание  связанного по выходу документа */
      nIncomFromDeps := F_DOCLINKS_LINK_OUT_DOC('GoodsTransInvoicesToDepts', usr_pkg_pub_const.rtransinvdept.rn, 'IncomFromDeps');
      /* если связь есть */
      if nIncomFromDeps is not null then
        /* разрываем связь для отмены отработки */
        pkg_doclinks.remove(sin_unitcode  => 'GoodsTransInvoicesToDepts'
                           ,nin_document  => usr_pkg_pub_const.rtransinvdept.rn
                           ,sout_unitcode => 'IncomFromDeps'
                           ,nout_document => nIncomFromDeps);
        /* сохраняем RN связанного документа */
        usr_pkg_pub_const.nRef := nIncomFromDeps;
      end if;
    end if;

    /* Если складская операция отправителя имеет тип "Приход" и есть связи по входу с разделом РН в подразделения */
    if ( rStOper.gsmways_type <> 1 ) 
    and f_doclinks_link_in(sout_unitcode => 'GoodsTransInvoicesToDepts', nout_document => rRow.rn, sin_unitcode => 'GoodsTransInvoicesToDepts') is not null then
      /* Удаление входных связей с разделом РН в подразделения */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 0
                                         ,nrn           => rRow.rn
                                         ,ncompany      => rRow.company
                                         ,sunitcode     => 'GoodsTransInvoicesToDepts'
                                         ,arn_unit_list => usr_pkg_pub_const.aRN_Unit_List
                                         ,nmode         => 0 );
    end if;
 
  end TRANSINVDEPT_BCANCEL;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ACANCEL
  /*
  Заголовок. Проверка после отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            transinvdept%rowtype; 
    sAcatalog       acatalog.name%type;
    
    nNumber         pkg_std.tnumber; 
    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание */
    rRow        := transinvdept_get(nrn => NRN); 
    sAcatalog   := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* ИСПРАВЛЕНИЯ  */
    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      /* если в переменной сохранён RN документа, с которым разорвали связь до отмены отработки */
      if usr_pkg_pub_const.nRef is not null then
        /* восстанавливаем связь */
        PKG_DOCLINKS.LINK(NFLAG_SMART   => 0
                         ,NCOMPANY      => rRow.company
                         ,SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                         ,NIN_DOCUMENT  => rRow.rn
                         ,SOUT_UNITCODE => 'IncomFromDeps'
                         ,NOUT_DOCUMENT => usr_pkg_pub_const.nRef);
        /* снимаем отработку со связанного документа */
        P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY   => rRow.company
                                   ,NRN        => usr_pkg_pub_const.nRef
                                   ,NIDENT     => null
                                   ,NSTATUS    => 0
                                   ,DWORKDATE  => rRow.work_date
                                   ,NWARNING   => nNumber
                                   ,SMSG       => sVarchar
                                   ,NSHOW_MSG  => nNumber);
        /* очищаем RN связанного документа */
        usr_pkg_pub_const.nRef := null;
      end if;
    end if;

    /* Если список удалённых связей не пустой */
    if usr_pkg_pub_const.alinks.count != 0 then
      /* Восстановление связей с разделом РН в подразделения */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 0
                                         ,nrn           => rRow.rn
                                         ,ncompany      => rRow.company
                                         ,sunitcode     => 'GoodsTransInvoicesToDepts'
                                         ,arn_unit_list => usr_pkg_pub_const.aRN_Unit_List
                                         ,nmode         => 1 );
      /* Очистка списка удалённых связей */
      usr_pkg_pub_const.aRN_Unit_List.delete;
    end if;

    /* ПРОВЕРКИ */
    
  end TRANSINVDEPT_ACANCEL;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ARESERV
  /*
  Заголовок. Проверка после резервирования
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end TRANSINVDEPT_ARESERV;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ASTPL_PROC
  /*
  Заголовок. Проверка после Списание спецификации с мест хранения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end TRANSINVDEPT_ASTPL_PROC;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BSTPL_DIST_PROC
  /*
  Заголовок. Проверка до Распределение спецификации по местам хранения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              transinvdept%rowtype;
    nIN_GOODSUPPLY    pkg_std.tref; 
  begin

    /* Считывание записи */
    rRow := transinvdept_get(nrn => NRN);

    /* Если склад-получатель "П04", "П02" */
    if nvl(usr_pkg_process.get_parus_process(sunitcode => 'GoodsTransInvoicesToDepts', nmode => 1), null) in ('TRANSINVDEPT_STPLACES_DIST_PROCESS')
    and nvl(rRow.in_store, 0) in ( 19555162, 129586336 ) then
      /* Запись партии в журнал резервирования по местам хранения. Взято из P_TRANSINVDEPT_BSET_STATUS строка 3111 */
      for R in
      (
        select S.RN RN_DOC,
               S.QUANT QUANT_DOC,
               S.PRICE,
               S.PRICEMEAS,
               S.SUMMWITHNDS,
               S.ARTICLE,
               S.CARDNUMB,
               NG.PRICE_METH_IN,
               L.OUT_DOCUMENT nSTOREOP_RN,
               L.IN_DOCUMENT DOCUMENT,
               SOJ.GOODSSUPPLY,
               SOJ.QUANT,
               SOJ.QUANTALT,
               SOJ.REGPRICE,
               SOJ.REGPRICEMEAS,
               SOJ.SUMMTAX,
               SOJ.SUMM,
               SOJ.SUMM_NDS
          from TRANSINVDEPTSPECS S,
               DOCLINKS          L,
               STOREOPERJOURN    SOJ,
               NOMMODIF          M,
               DICNOMNS          N,
               DICGNOMN          NG
         where S.PRN          = rRow.rn
           and S.NOMMODIF     = M.RN
           and M.PRN          = N.RN
           and N.GROUP_CODE   = NG.RN
           and S.RN           = L.IN_DOCUMENT
           and L.IN_UNITCODE  = 'GoodsTransInvoicesToDeptsSpecs'
           and L.OUT_UNITCODE = 'StoreOpersJournal'
           and L.OUT_DOCUMENT = SOJ.RN
           and SOJ.OPER_TYPE  = 0
      )
      loop
        /* ищем товарный запас */
        begin
          select GS.RN/*, GS.PRN, GS.CARDNUMB*/
            into nIN_GOODSUPPLY/*, nPARTY_RN, sIN_CARDNUMB*/
            from GOODSSUPPLY GS,
                 GOODSSUPPLY GSO
           where GS.STORE = rRow.in_store
             and GS.PRN   = GSO.PRN
             and GSO.RN   = R.GOODSSUPPLY;
        exception
          when NO_DATA_FOUND then
            nIN_GOODSUPPLY := null;
        end;

        /* установка товарного запаса в журнале резервирования по местам хранения */
        if nin_goodsupply is null then
          p_strplresjrnl_set_goodssupply(ncompany     => ncompany
                                        ,nrn          => r.rn_doc
                                        ,sunitcode    => 'GoodsTransInvoicesToDeptsSpecs'
                                        ,nres_type    => 0 /*nRES_TYPE*(приход)*/
                                        ,ngoodssupply => nin_goodsupply);
        end if;
      end loop;  -- R
    end if;

  end TRANSINVDEPT_BSTPL_DIST_PROC;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_ASTPL_DIST_PROC
  /*
  Заголовок. Проверка после Распределение спецификации по местам хранения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow              transinvdept%rowtype;*/
  begin
    null;
    /* Считывание записи */
    /*rRow := transinvdept_get(nrn => NRN);*/

  end TRANSINVDEPT_ASTPL_DIST_PROC;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AMAKEINVOICE
  /*
  Заголовок. Проверка после формирования возвратной накладной в подразделения
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRowNew    transinvdept%rowtype;
  begin
    /* Копирование буфера документов во временную таблицу */
    delete from usr_t_inhierbuff_common;
    insert into usr_t_inhierbuff_common ( select * from inhierbuff_common );

    /* По заголовкам сформированных документов */
    for c in ( select distinct out_document0 from usr_t_inhierbuff_common ) 
    loop
      /* Проверка заголовка после добавления */
      transinvdept_ainsert( nrn => c.out_document0, ncompany => nCOMPANY );
      /* Считывание заголовка сформированной накладной */
      rRowNew := transinvdept_get( nrn => c.out_document0 );
      /* Склад-получатель должен быть либо не задан, либо это склад Модуль-Воронеж */
      if rRowNew.In_Store is not null and rRowNew.In_Store != 21648922 then
        p_exception(0, 'Запрещено формировать возвратные накладные с указанием склада-получателя, кроме "Модуль-Воронеж".%s'
                    ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRowNew.rn ) ); 
      end if;
    end loop;

  end TRANSINVDEPT_AMAKEINVOICE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_AMAKEPRODORD
  /*
  Заголовок. Проверка после формирования заказа на производство
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdept%rowtype;
  begin
    /* Считывание записи */
    rRow := transinvdept_get(nrn => NRN);

    /* ПРОВЕРКИ */
    /* Лицевой счёт "02023/1" */
    if nvl(rRow.faceacc, 0) = 83660497 then
      p_exception(0, 'Запрещено использовать лицевой счёт %s.%s'
                  ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if;

  end TRANSINVDEPT_AMAKEPRODORD;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            transinvdept%rowtype;
    rV_Row          v_transinvdept%rowtype; 
    sAcatalog       acatalog.name%type;
    nDepartmentOrd  pkg_std.tref; 
    rDepartmentOrd  departmentord%rowtype; 
    rStore          azsazslistmt%rowtype; 
    rIn_Store       azsazslistmt%rowtype; 
  begin
    /* Считывание */
    rRow        := transinvdept_get(nrn => NRN); 
    rStore      := udo_pkg_get.row_store(nrn => rRow.store);
    sAcatalog   := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);
    if rRow.in_store is not null then
      rIn_Store := udo_pkg_get.row_store(nrn => rRow.in_store);
    end if;

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /*if cmp_num(rRow.faceacc, 83660497) = 1 \*and utilizer != 'KHOK'*\ then
      p_exception(0, 'Запрещено использовать лицевой счёт %s.%s'
                  ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                  ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if; */

    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      /* Считывание из представления */
      select * into rV_Row from v_transinvdept where nrn = rRow.rn;

      /* Правильность заполнения полей */
      if cmp_vc2(rV_Row.sdoctype, 'СборРазбор') != 1 
      or cmp_vc2(rV_Row.sstoper, 'РасходВнутр') != 1
      or rV_Row.sfaceacc   is null
      or rV_Row.ssheepview not in ('Сборка', 'Разборка')
      or rV_Row.ssubdiv    is null
      or rV_Row.sin_store  is not null
      or rV_Row.sin_mol    is null
      or rV_Row.sin_stoper is not null
      or rV_Row.sin_party  is not null then
        p_exception(0, 'В документе "%s" должны быть заполнены поля следующим образом: %s. %s'
                   ,sAcatalog
                   ,      'Документ. Тип: "СборРазбор"'
                    ||cr||'Складская операция: "РасходВнутр"'
                    ||cr||'Лицевой счёт: <Заполнено>' 
                    ||cr||'Вид отгрузки: "Сборка" или "Разборка"' 
                    ||cr||'Подразделение: <Заполнено>'
                    ||cr||'Получатель. Склад: <Пусто>'
                    ||cr||'Получатель. МОЛ: <Заполнено>' 
                    ||cr||'Получатель. Складская операция: <Пусто>'
                    ||cr||'Получатель. Партия: <Пусто>'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)
                   ); 
      end if;
    end if;

    /* Связанный заказ подразделений. Любой */
    nDepartmentOrd := f_doclinks_link_in_doc(sout_unitcode => 'GoodsTransInvoicesToDepts', nout_document => rRow.rn, sin_unitcode  => 'DepartmentsOrders'); 
    if nDepartmentOrd is not null then
      rDepartmentOrd := usr_pkg_departmentord.departmentord_get(nrn => nDepartmentOrd);
    end if;
        
    /* ПРОВЕРКИ */
    /* Проверка префикса, номера */
    usr_pkg_document.check_pref_numb( spref => rRow.pref
                                     ,snumb => rRow.numb
                                     ,ddate => rRow.docdate );

    /* Связанный заказ поставщикам существует */
    if rDepartmentOrd.rn is not null then
      /* Каталог текущего документа 'Отдел метрологии' */
      if rRow.crn = usr_pkg_pub_const.ntid_cat_mtlg then
        /* каталог заказа подразделений НЕ 'Отдел метрологии' */
        if rDepartmentOrd.crn != usr_pkg_pub_const.ndpo_cat_mtlg then
          p_exception(0, 'Каталог документа <%s> не равен каталогу заказа подразделения <%s>.%s'
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rDepartmentOrd.crn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rDepartmentOrd.rn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn) ); 
        end if;
      /* Каталог текущего документа НЕ 'Отдел метрологии' */
      else      
        /* каталог входного документа 'Отдел метрологии' */
        if rDepartmentOrd.crn = usr_pkg_pub_const.ndpo_cat_mtlg then
          p_exception(0, 'Каталог документа <%s> не равен каталогу заказа подразделения <%s>. %s'
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rDepartmentOrd.crn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rDepartmentOrd.rn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn) ); 
        end if;
      end if;
    /* Связанный заказ поставщикам НЕ существует */
    /*else 
      \* Каталог текущего документа 'Отдел метрологии' *\
      if cmp_num(rRow.crn, usr_pkg_pub_const.ntid_cat_mtlg) = 1 then
        p_exception(0, 'Документ не связан с заказом подразделений. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end if;*/
    end if;
    
    /* Каталог склада-получателя "Сертификация" */
    if rIn_Store.crn = 12737559 then
      /* Каталог документа НЕ "Сертификация" */
      if rRow.crn != 47815697 then
        p_exception(0, 'Склад-получатель <%s> находится в каталоге <%s>, при этом документ находится в каталоге <%s>.%s'
                   ,rIn_Store.azs_number
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rIn_Store.crn)
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
      end if;
      /* Лицевой счёт не пустой */
      /*if rRow.faceacc is not null then
        p_exception(0, 'Склад-получатель <%s> находится в каталоге <%s>, лицевой счёт не должен быть заполнен в документе.%s'
                   ,rIn_Store.azs_number
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rIn_Store.crn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn ) ); 
      end if;*/
    end if;

    /* Склад-отправитель равен складу-получатею, 
       у него нет признаков необходимости распределения/списания с мест хранения, 
       этот склад не "ВремПеремещение" */
    if  cmp_num( rStore.rn, rIn_Store.rn ) = 1 
    and rStore.process_sign      = 0 
    and rStore.distribution_sign = 0 
    and rStore.rn               != 20300310 then
      p_exception(0, 'Запрещено указывать в один и тот же склад в полях "Отправитель" и "Получатель" за исключением документов перемещения по местам хранения и склада "ВремПеремещение".%s'
                 ,cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn ) ); 
    end if;

    /* Микроэлектроника */
    /*if rRow.in_store = 32814621 and rRow.crn != 95911302 then
      p_exception(0, 'Склад-получатель <%s>, каталог документа <%s>. Документ должен находиться в каталоге <%s>.%s'
                 ,f_dicstore_get_numb(nstore => rRow.in_store)
                 ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                 ,get_acatalog_name_id(nflag_smart => 0, nrn => 95911302)
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if;*/

    /* Если вид отгрузки НЕ "Проверено ОТК", и задана Партия получателя */
    /*if  rRow.sheepview != 50928185 and rRow.in_party is not null then 
      p_exception(0, 'У документа с видом отгрузки <%s> не должно быть заполнено поле "Партия".%s'
                 ,usr_pkg_common.dicshpvw_get_code( nrn => rRow.sheepview, nflagsmart => 1 )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn ) ); 
    end if;*/

  end TRANSINVDEPT_CHECK_BASE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_INSERT
  /*
  Заголовок. Добавить
  */
  (
   rV_ROW   in out v_transinvdept%rowtype
  ,sMSG     out varchar2
  ) 
  is
  begin
    p_transinvdept_insert(ncompany       => rV_ROW.NCOMPANY
                         ,ncrn           => rV_ROW.NCRN
                         ,sjur_pers      => rV_ROW.SJUR_PERS
                         ,sdoctype       => rV_ROW.SDOCTYPE
                         ,spref          => rV_ROW.SPREF
                         ,snumb          => rV_ROW.SNUMB
                         ,ddocdate       => rV_ROW.DDOCDATE
                         ,sdirdoc        => rV_ROW.SDIRDOC
                         ,sdirnumb       => rV_ROW.SDIRNUMB
                         ,ddirdate       => rV_ROW.DDIRDATE
                         ,sstoper        => rV_ROW.SSTOPER
                         ,sfaceacc       => rV_ROW.SFACEACC
                         ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                         ,sstore         => rV_ROW.SSTORE
                         ,smol           => rV_ROW.SMOL
                         ,ssheepview     => rV_ROW.SSHEEPVIEW
                         ,sagent         => rV_ROW.SAGENT
                         ,ssubdiv        => rV_ROW.SSUBDIV
                         ,scurrency      => rV_ROW.SCURRENCY
                         ,ncurcours      => rV_ROW.NCURCOURS
                         ,ncurbase       => rV_ROW.NCURBASE
                         ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                         ,srecipdoc      => rV_ROW.SRECIPDOC
                         ,srecipnumb     => rV_ROW.SRECIPNUMB
                         ,drecipdate     => rV_ROW.DRECIPDATE
                         ,sferryman      => rV_ROW.SFERRYMAN
                         ,sgetconfirm    => rV_ROW.SGETCONFIRM
                         ,swaybladenumb  => rV_ROW.SWAYBLADENUMB
                         ,sdriver        => rV_ROW.SDRIVER
                         ,scar           => rV_ROW.SCAR
                         ,sroute         => rV_ROW.SROUTE
                         ,strailer1      => rV_ROW.STRAILER1
                         ,strailer2      => rV_ROW.STRAILER2
                         ,nfa_curcours   => rV_ROW.NFA_CURCOURS
                         ,nfa_curbase    => rV_ROW.NFA_CURBASE
                         ,sin_store      => rV_ROW.SIN_STORE
                         ,sin_mol        => rV_ROW.SIN_MOL
                         ,sin_stoper     => rV_ROW.SIN_STOPER
                         ,sin_party      => rV_ROW.SIN_PARTY
                         ,nin_curcours   => rV_ROW.NIN_CURCOURS
                         ,nin_curbase    => rV_ROW.NIN_CURBASE
                         ,svalid_doctype => rV_ROW.SVALID_DOCTYPE
                         ,svalid_docnumb => rV_ROW.SVALID_DOCNUMB
                         ,dvalid_docdate => rV_ROW.DVALID_DOCDATE
                         ,scomments      => rV_ROW.SCOMMENTS
                         ,sbarcode       => rV_ROW.SBARCODE
                         ,sord_doctype   => rV_ROW.SORD_DOCTYPE
                         ,sord_docnumb   => rV_ROW.SORD_DOCNUMB
                         ,dord_docdate   => rV_ROW.DORD_DOCDATE
                         ,nneed_util     => rV_ROW.NNEED_UTIL
                         ,nrn            => rV_ROW.NRN
                         ,smsg           => sMSG);
  end TRANSINVDEPT_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_UPDATE
  /*
  Заголовок. Добавить
  */
  (
   rV_ROW           in v_transinvdept%rowtype
  ,nSTATUS_IGNORE   in number default 0  /* Исправлять отработанный 0-нет, 1-да */
  ) 
  is
  begin
    /* Если Исправлять отработанный */
    if nSTATUS_IGNORE = 1 then
      /* Если исходный статус НЕ "Не отработан" */
      if rV_ROW.nSTATUS != 0 then
        /* Подменяем на "Не отработан" */
        update transinvdept set status = 0 where rn = rV_ROW.nRN;
      end if;
    end if;

    p_transinvdept_update(nrn            => rV_ROW.NRN
                         ,ncompany       => rV_ROW.NCOMPANY
                         ,sjur_pers      => rV_ROW.SJUR_PERS
                         ,sdoctype       => rV_ROW.SDOCTYPE
                         ,spref          => rV_ROW.SPREF
                         ,snumb          => rV_ROW.SNUMB
                         ,ddocdate       => rV_ROW.DDOCDATE
                         ,sdirdoc        => rV_ROW.SDIRDOC
                         ,sdirnumb       => rV_ROW.SDIRNUMB
                         ,ddirdate       => rV_ROW.DDIRDATE
                         ,sstoper        => rV_ROW.SSTOPER
                         ,sfaceacc       => rV_ROW.SFACEACC
                         ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                         ,sstore         => rV_ROW.SSTORE
                         ,smol           => rV_ROW.SMOL
                         ,ssheepview     => rV_ROW.SSHEEPVIEW
                         ,sagent         => rV_ROW.SAGENT
                         ,ssubdiv        => rV_ROW.SSUBDIV
                         ,scurrency      => rV_ROW.SCURRENCY
                         ,ncurcours      => rV_ROW.NCURCOURS
                         ,ncurbase       => rV_ROW.NCURBASE
                         ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                         ,srecipdoc      => rV_ROW.SRECIPDOC
                         ,srecipnumb     => rV_ROW.SRECIPNUMB
                         ,drecipdate     => rV_ROW.DRECIPDATE
                         ,sferryman      => rV_ROW.SFERRYMAN
                         ,sgetconfirm    => rV_ROW.SGETCONFIRM
                         ,swaybladenumb  => rV_ROW.SWAYBLADENUMB
                         ,sdriver        => rV_ROW.SDRIVER
                         ,scar           => rV_ROW.SCAR
                         ,sroute         => rV_ROW.SROUTE
                         ,strailer1      => rV_ROW.STRAILER1
                         ,strailer2      => rV_ROW.STRAILER2
                         ,nfa_curcours   => rV_ROW.NFA_CURCOURS
                         ,nfa_curbase    => rV_ROW.NFA_CURBASE
                         ,sin_store      => rV_ROW.SIN_STORE
                         ,sin_mol        => rV_ROW.SIN_MOL
                         ,sin_stoper     => rV_ROW.SIN_STOPER
                         ,sin_party      => rV_ROW.SIN_PARTY
                         ,nin_curcours   => rV_ROW.NIN_CURCOURS
                         ,nin_curbase    => rV_ROW.NIN_CURBASE
                         ,svalid_doctype => rV_ROW.SVALID_DOCTYPE
                         ,svalid_docnumb => rV_ROW.SVALID_DOCNUMB
                         ,dvalid_docdate => rV_ROW.DVALID_DOCDATE
                         ,scomments      => rV_ROW.SCOMMENTS
                         ,sbarcode       => rV_ROW.SBARCODE
                         ,sord_doctype   => rV_ROW.SORD_DOCTYPE
                         ,sord_docnumb   => rV_ROW.SORD_DOCNUMB
                         ,dord_docdate   => rV_ROW.DORD_DOCDATE
                         ,nneed_util     => rV_ROW.NNEED_UTIL);
    /* Если Исправлять отработанный */
    if nSTATUS_IGNORE = 1 then
      /* Если исходный статус НЕ "Не отработан" */
      if rV_ROW.NSTATUS != 0 then
        /* Возвращаем исходный */
        update transinvdept set status = rV_ROW.NSTATUS where rn = rV_ROW.NRN;
      end if;
    end if;
  end TRANSINVDEPT_UPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BASE_INSERT
  /*
  Заголовок. Добавить. Базовая
  */
  (
   rROW           in transinvdept%rowtype
  ,nRESERV_SIGN   in number default 0
  ,nRN            out number
  ) 
  is
  begin
    p_transinvdept_base_insert(ncompany       => rROW.COMPANY
                              ,ncrn           => rROW.CRN
                              ,njur_pers      => rROW.JUR_PERS
                              ,ndoctype       => rROW.DOCTYPE
                              ,spref          => rROW.PREF
                              ,snumb          => rROW.NUMB
                              ,ddocdate       => rROW.DOCDATE
                              ,ndirdoc        => rROW.DIRDOC
                              ,sdirnumb       => rROW.DIRNUMB
                              ,ddirdate       => rROW.DIRDATE
                              ,nstoper        => rROW.STOPER
                              ,nfaceacc       => rROW.FACEACC
                              ,ngraphpoint    => rROW.GRAPHPOINT
                              ,nstore         => rROW.STORE
                              ,nmol           => rROW.MOL
                              ,nsheepview     => rROW.SHEEPVIEW
                              ,nagent         => rROW.AGENT
                              ,nsubdiv        => rROW.SUBDIV
                              ,ncurrency      => rROW.CURRENCY
                              ,ncurcours      => rROW.CURCOURS
                              ,ncurbase       => rROW.CURBASE
                              ,nsummwithnds   => rROW.SUMMWITHNDS
                              ,nrecipdoc      => rROW.RECIPDOC
                              ,srecipnumb     => rROW.RECIPNUMB
                              ,drecipdate     => rROW.RECIPDATE
                              ,nferryman      => rROW.FERRYMAN
                              ,sgetconfirm    => rROW.GETCONFIRM
                              ,swaybladenumb  => rROW.WAYBLADENUMB
                              ,ndriver        => rROW.DRIVER
                              ,ncar           => rROW.CAR
                              ,nroute         => rROW.ROUTE
                              ,ntrailer1      => rROW.TRAILER1
                              ,ntrailer2      => rROW.TRAILER2
                              ,nfa_curcours   => rROW.FA_CURCOURS
                              ,nfa_curbase    => rROW.FA_CURBASE
                              ,nin_store      => rROW.IN_STORE
                              ,nin_mol        => rROW.IN_MOL
                              ,nin_stoper     => rROW.IN_STOPER
                              ,nin_party      => rROW.IN_PARTY
                              ,sin_party      => rROW.IN_PARTY
                              ,nin_curcours   => rROW.IN_CURCOURS
                              ,nin_curbase    => rROW.IN_CURBASE
                              ,nvalid_doctype => rROW.VALID_DOCTYPE
                              ,svalid_docnumb => rROW.VALID_DOCNUMB
                              ,dvalid_docdate => rROW.VALID_DOCDATE
                              ,scomments      => rROW.COMMENTS
                              ,sbarcode       => rROW.BARCODE
                              ,nreserv_sign   => nRESERV_SIGN
                              ,nord_doctype   => rROW.ORD_DOCTYPE
                              ,sord_docnumb   => rROW.ORD_DOCNUMB
                              ,dord_docdate   => rROW.ORD_DOCDATE
                              ,nneed_util     => rROW.NEED_UTIL
                              ,nrn            => nRN);
  end TRANSINVDEPT_BASE_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BASE_UPDATE
  /*
  Заголовок. Исправить. Базовая
  */
  (
   rROW             in transinvdept%rowtype
  ,nSTATUS_IGNORE   in number default 0  /* Исправлять отработанный 0-нет, 1-да */
  ) 
  is
  begin
    /* Если Исправлять отработанный */
    if nSTATUS_IGNORE = 1 then
      /* Если исходный статус НЕ "Не отработан" */
      if rROW.STATUS != 0 then
        /* Подменяем на "Не отработан" */
        update transinvdept set status = 0 where rn = rROW.RN;
      end if;
    end if;

    /* Исправление */
    p_transinvdept_base_update(nrn            => rROW.RN
                              ,ncompany       => rROW.COMPANY
                              ,njur_pers      => rROW.JUR_PERS
                              ,ndoctype       => rROW.DOCTYPE
                              ,spref          => rROW.PREF
                              ,snumb          => rROW.NUMB
                              ,ddocdate       => rROW.DOCDATE
                              ,ndirdoc        => rROW.DIRDOC
                              ,sdirnumb       => rROW.DIRNUMB
                              ,ddirdate       => rROW.DIRDATE
                              ,nstoper        => rROW.STOPER
                              ,nfaceacc       => rROW.FACEACC
                              ,ngraphpoint    => rROW.GRAPHPOINT
                              ,nstore         => rROW.STORE
                              ,nmol           => rROW.MOL
                              ,nsheepview     => rROW.SHEEPVIEW
                              ,nagent         => rROW.AGENT
                              ,nsubdiv        => rROW.SUBDIV
                              ,ncurrency      => rROW.CURRENCY
                              ,ncurcours      => rROW.CURCOURS
                              ,ncurbase       => rROW.CURBASE
                              ,nsummwithnds   => rROW.SUMMWITHNDS
                              ,nrecipdoc      => rROW.RECIPDOC
                              ,srecipnumb     => rROW.RECIPNUMB
                              ,drecipdate     => rROW.RECIPDATE
                              ,nferryman      => rROW.FERRYMAN
                              ,sgetconfirm    => rROW.GETCONFIRM
                              ,swaybladenumb  => rROW.WAYBLADENUMB
                              ,ndriver        => rROW.DRIVER
                              ,ncar           => rROW.CAR
                              ,nroute         => rROW.ROUTE
                              ,ntrailer1      => rROW.TRAILER1
                              ,ntrailer2      => rROW.TRAILER2
                              ,nfa_curcours   => rROW.FA_CURCOURS
                              ,nfa_curbase    => rROW.FA_CURBASE
                              ,nin_store      => rROW.IN_STORE
                              ,nin_mol        => rROW.IN_MOL
                              ,nin_stoper     => rROW.IN_STOPER
                              ,nin_party      => rROW.IN_PARTY
                              ,sin_party      => rROW.IN_PARTY
                              ,nin_curcours   => rROW.IN_CURCOURS
                              ,nin_curbase    => rROW.IN_CURBASE
                              ,nvalid_doctype => rROW.VALID_DOCTYPE
                              ,svalid_docnumb => rROW.VALID_DOCNUMB
                              ,dvalid_docdate => rROW.VALID_DOCDATE
                              ,scomments      => rROW.COMMENTS
                              ,sbarcode       => rROW.BARCODE
                              ,nord_doctype   => rROW.ORD_DOCTYPE
                              ,sord_docnumb   => rROW.ORD_DOCNUMB
                              ,dord_docdate   => rROW.ORD_DOCDATE
                              ,nneed_util     => rROW.NEED_UTIL);
    /* Если Исправлять отработанный */
    if nSTATUS_IGNORE = 1 then
      /* Если исходный статус НЕ "Не отработан" */
      if rROW.STATUS != 0 then
        /* Возвращаем исходный */
        update transinvdept set status = rROW.STATUS where rn = rROW.RN;
      end if;
    end if;
    
  end TRANSINVDEPT_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_BASE_DELETE
  /*
  Заголовок. Удалить. Базовая
  */
  (
   nCOMPANY     in number
  ,nRN          in number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_transinvdept_base_delete( ncompany => nCOMPANY, nrn => nRN );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* По спецификациям текущего документа */
      for c in ( select rn, company from transinvdeptspecs where prn = nRN )
      loop
        /* Проверка перед удалением */
        transinvdeptspecs_bdelete( nrn => c.rn, ncompany => c.company );
      end loop;

      /* Удаление базовой процедурой с указанием в сообщении реквизитов документа */
      begin
        transinvdept_base_delete( ncompany => nCOMPANY, nrn => nRN, nmode => 0 );
      exception when others then
        p_exception(0, error_text||'%s' 
                    ,cr||cr|| f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => nRN ) ); 
      end;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  END TRANSINVDEPT_BASE_DELETE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_MAKE_IFD
  /*
  Заголовок. Сформировать зеркальный документ в Приход из подразделений
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ,nIFD      out number
  ) 
  is
    rRow              transinvdept%rowtype;
    rV_Row            v_transinvdept%rowtype;
    sAcatalog         acatalog.name%type;
    rV_IncomeFromDeps V_IncomeFromDeps%rowtype;
  begin
    /* Считывание */
    rRow      := transinvdept_get(nrn => NRN);
    sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);
    select * into rV_Row from v_transinvdept where nrn = rRow.rn;

    /*- Наполнение переменных */
    rV_IncomeFromDeps.ncompany  := rV_Row.ncompany;
    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => rV_Row.ncompany
                      ,nversion    => null
                      ,sunitcode   => 'IncomFromDeps'
                      ,sname       => sAcatalog
                      ,NRN         => rV_IncomeFromDeps.ncrn);
    rV_IncomeFromDeps.sjur_pers := rV_Row.sjur_pers;
    rV_IncomeFromDeps.sdoc_type := rV_Row.sdoctype;
    rV_IncomeFromDeps.ddoc_date := rV_Row.ddocdate;
    rV_IncomeFromDeps.sdoc_pref := rV_Row.spref;
    p_incomefromdeps_getnextnumb(ncompany  => rV_Row.ncompany
                                ,sjur_pers => rV_Row.sjur_pers
                                ,ddoc_date => rV_IncomeFromDeps.ddoc_date
                                ,stype     => rV_IncomeFromDeps.sdoc_type
                                ,spref     => rV_IncomeFromDeps.sdoc_pref
                                ,snumb     => rV_IncomeFromDeps.sdoc_numb);
    rV_IncomeFromDeps.sstore_oper       := 'ПриходВнутр';
    rV_IncomeFromDeps.ncurcours         := rV_Row.ncurcours;
    rV_IncomeFromDeps.ncurbasecours     := rV_Row.ncurbase;
    rV_IncomeFromDeps.ncurcours_doc     := rV_Row.ncurcours;
    rV_IncomeFromDeps.ncurbasecours_doc := rV_Row.ncurbase;
    rV_IncomeFromDeps.sout_department   := rV_Row.ssubdiv;
    rV_IncomeFromDeps.sout_faceacc      := rV_Row.sfaceacc;
    rV_IncomeFromDeps.sstore            := rV_Row.sstore;
    rV_IncomeFromDeps.sagent            := rV_Row.smol;
    rV_IncomeFromDeps.scurrency         := rV_Row.scurrency;
    rV_IncomeFromDeps.snote             := rV_Row.scomments;

    /* Добавление */
    usr_pkg_incomefromdeps.incomefromdeps_insert(rv_row => rV_IncomeFromDeps, ndup_rn => null, nrn => rV_IncomeFromDeps.nrn);

    /* Установка связи */
    pkg_doclinks.link(nflag_smart       => 0
                     ,ncompany          => rV_Row.ncompany
                     ,sin_unitcode      => 'GoodsTransInvoicesToDepts'
                     ,nin_document      => rV_Row.nrn
                     ,sout_unitcode     => 'IncomFromDeps'
                     ,nout_document     => rV_IncomeFromDeps.nrn);
    /* RN сформированного документа */
    nIFD := rV_IncomeFromDeps.nrn;

  end TRANSINVDEPT_MAKE_IFD;
  /*#########################################################################################################*/
  
  procedure TRANSINVDEPT_MAKE_TID
  /*
  Заголовок. Сформировать возвратную накладную на отпуск в подразделения
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,dDOCDATE         in date
  ,sCATALOG         in varchar2
  ,sSTORE           in varchar2
  ,nGOODSPARTIES    in number default null /* Приходная партия. Если не пустая, то формировать только по ней */
  )
  is
    nCatalog          pkg_std.tref;
    nStore            pkg_std.tref;
    nMOL              pkg_std.tref; 
    rTransInvDeptBuf  transinvdeptbuf%rowtype;
    bFlag             boolean := false;

    nNumber         pkg_std.tnumber;
    sVarchar        pkg_std.tstring; 
  begin
    /* Каталог */
    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => nCOMPANY
                      ,nversion    => null
                      ,sunitcode   => 'GoodsTransInvoicesToDepts'
                      ,sname       => sCATALOG
                      ,nrn         => nCatalog);
    /* Склад и МОЛ */
    if sSTORE is not null then
      find_dicstore_numb(nflag_smart => 0, ncompany => nCOMPANY, snumb => sSTORE, nrn => nStore);
      find_dicstore_attr(nflag_smart => 0
                        ,nflag_azs   => 0
                        ,ncompany    => nCOMPANY
                        ,snumb       => sSTORE
                        ,nrn         => nStore
                        ,nmol        => nMOL
                        ,smol        => sVarchar
                        ,npbe        => nNumber
                        ,spbe        => sVarchar
                        ,ncurrency   => nNumber
                        ,scurrency   => sVarchar);
    end if;
    /* Складская операция прихода на склад возвратной накладной из подразделения (Закупки Склад Реализация). 
       Если не задана в параметрах, подставляем в параметры */
    if get_options_str(scode => 'Realiz_InvDept_RetInStoreOper', ncomp_vers => nCOMPANY) is null then
      usr_pkg_common.options_set(scode       => 'Realiz_InvDept_RetInStoreOper'
                                ,sauthid     => utilizer
                                ,ncompany    => nCOMPANY
                                ,sstr_value  => 'ПриходВозвр'
                                ,nnum_value  => null
                                ,ddate_value => null
                                ,nrn         => nNumber);
      /* признак исправления параметра */
      bFlag := true;
    end if;

    /* Формирование буфера */
    p_selectlist_insert_ext(nident     => nRN
                           ,ndocument  => nRN
                           ,sunitcode  => 'GoodsTransInvoicesToDepts'
                           ,ndocument1 => null
                           ,sunitcode1 => null
                           ,ncrn       => null
                           ,nrn        => nNumber);
    p_transinvdept_makeinvoice( ncompany => nCOMPANY, nident => nRN, ntrue_rec => nNumber );
    /* если не сформировался */
    if nNumber = 0 then
      p_exception(0, 'Возвратная накладная в подразделение не сформирована. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => nRN)); 
    end if;

    /* По буферу */
    for c in ( select * from transinvdeptbuf where ident = nRN )
    loop
      /* проверка сумм */
      p_transinvdeptbuf_checkinvsums(ncompany => c.company, nrn => c.rn, nwarrning => nNumber);
      /* результат проверки */
      if nNumber = 1 then
        p_exception(0, 'Сформировано возвратных накладных в подразделение на сумму, большую, чем в исходном документе. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => nRN)); 
      end if;
      /* подстановка значений в переменную для исправления */
      rTransInvDeptBuf              := c;
      rTransInvDeptBuf.docdate      := nvl(dDOCDATE, rTransInvDeptBuf.docdate);
      rTransInvDeptBuf.crn          := nvl(nCatalog, rTransInvDeptBuf.crn);
      rTransInvDeptBuf.store        := nvl(nStore, rTransInvDeptBuf.store);
      rTransInvDeptBuf.mol          := nvl(nMOL, rTransInvDeptBuf.mol);
      /* исправление */
      usr_pkg_transinvdept.transinvdeptbuf_base_update(rrow => rTransInvDeptBuf);
    end loop;

    /* Если задана приходная партия */
    if nGOODSPARTIES is not null then
      /* по спецификациям буфера кроме заданных в параметре */
      for c in (select * from transinvdeptspbuf where ident = nRN and goodsparty != nGOODSPARTIES)
      loop
        /* удаление */
        p_trinvdeptspbuf_base_delete(nrn => c.rn, ncompany => c.company);
      end loop;
    end if;

    /* Перенос буфера */
    p_transinvdeptbuf_makeinvbuf( ncompany => nCOMPANY, nident => nRN );

    /* Очистка */
    p_selectlist_clear( nident => nRN );
    p_transinvdeptbuf_clean( ncompany => nCOMPANY, nident => nRN );

    /* Обнуление значения параметра */
    if bFlag then
      usr_pkg_common.options_set(scode       => 'Realiz_InvDept_RetInStoreOper'
                                ,sauthid     => utilizer
                                ,ncompany    => nCOMPANY
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => null
                                ,nrn         => nNumber);
    end if;

  end TRANSINVDEPT_MAKE_TID;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_MAKE_RITS
  /*
  Заголовок. Сформировать расходную накладную на возврат посавтщикам
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2
  ,sDOC_TYPE        in varchar2
  ,sDOC_PREF        in varchar2
  ,sSTORE_OPER      in varchar2
  ,sPAY_TYPE        in varchar2
  ,nWORK            in number default 0 /* Отработать: 0-нет, 1-да */
  )
  is
    rRow              transinvdept%rowtype;
    nIO               pkg_std.tref;
    nRInvToSup        pkg_std.tref; 
    rRInvToSup        rinvtosup%rowtype;
    rRInvToSupSpecs   rinvtosupspecs%rowtype;
    rRInvToSupClc     rinvtosupclc%rowtype;
    rInOrderSpecs     inorderspecs%rowtype;
    sDicShpVw         dicshpvw.code%type;

    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring; 
  begin
    /* Считывание текущего документа */
    rRow := transinvdept_get(nrn => nRN);

    /* Проверка отработки текущего документа */
    if rRow.status != 1 then
      p_exception(0, 'Документ не отработан в учёте.%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn));
    end if;

    /* Поиск Rn приходого ордера поставки, и проверка, что он один */
    begin
       select distinct usr_pkg_goodsparties.goodsparties_get_indocs_data(ssernumb       => gp.sernumb
                                                                        ,nflagsmart     => 1
                                                                        ,ntoo_many_rows => 1
                                                                        ,sparam         => 'nIO')
         into nIO
         from transinvdeptspecs t
             ,goodsparties      gp
        where t.prn = rRow.rn
          and gp.rn = t.goodsparty;
    exception
      when no_data_found then
          p_exception(0, 'Не найден приходный ордер для серии.%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn));
      when too_many_rows then
          p_exception(0, 'Найдено больше одного приходного ордера.%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn));
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске приходного ордера.%s%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)
                     ,cr||cr||sqlerrm );
    end;

    /* Формирование РН на возврат поставщикам из приходого ордера */
    /* сохранение настроек пользователя раздела Расходные накладные на возврат поставщикам */
    usr_pkg_common.options_save_unit_params(sunitcode => 'ReturnInvoicesToSuppliers');
    /* исправление настроек пользователя раздела Расходные накладные на возврат поставщикам */
    usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_RInvToSup_DocType'     , sstr_val => sDOC_TYPE);
    usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_RInvToSup_Prefix'      , sstr_val => sDOC_PREF);
    usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_RInvToSup_StoreOper'   , sstr_val => sSTORE_OPER);
    usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_RInvToSup_Catalog'     , sstr_val => sCATALOG);
    usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_RInvToSup_Pays_PayType', sstr_val => sPAY_TYPE);
    usr_pkg_common.options_set_str(ncompany => rRow.company, scode => 'Realiz_RInvToSup_Store'       , sstr_val => f_dicstore_get_numb(nstore => rRow.in_store));
    /* формирование накладной */
    usr_pkg_inorders.inorders_make_rinvtosup( nrn => nIO, ncompany => rRow.company );
    /* восстановление настроек пользователя */
    usr_pkg_common.options_restore_unit_params;

    /* Удаление спецификаций РН на возврат поставщикам  */
    /* отключение регистрации */
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
    for c in ( select s.rn, s.prn
                 from ( select distinct out_document0 from usr_t_inhierbuff_common ) t
                 join rinvtosupspecs          s  on s.prn = t.out_document0 )
    loop
      /* удаление */
      p_rinvtosupspecs_base_delete(ncompany => rRow.company, nrn => c.rn);
      /* сохранение RN заголовка */
      nRInvToSup := c.prn;
    end loop;
    /* включение регистрации */
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

    /* Считывание заголовка расходной накладной на возврат поставщикам */
    rRInvToSup := usr_pkg_rinvtosup.rinvtosup_get(nrn => nRInvToSup);

    /* Замена склада и МОЛ в расходной накладной на возврат поставщикам складом-получателем текущего документа */
    rRInvToSup.store := rRow.in_store;
    rRInvToSup.mol   := rRow.in_mol;
    usr_pkg_rinvtosup.rinvtosup_base_update(rrow => rRInvToSup);
    /* Вид отгрузки. Мнемокод */
    select code into sDicShpVw from dicshpvw where rn = rRow.sheepview;
    /* Копирование вида отгрузки в свойство РН на возврат поставщикам */
    pkg_docs_props_vals.modify(nproperty   => 193749297
                              ,sunitcode   => 'ReturnInvoicesToSuppliers'
                              ,ndocument   => rRInvToSup.rn
                              ,sstr_value  => sDicShpVw
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => nNumber);

    /* По спецификациям текущего документа */
    for c in (
              /* по накладной, в которой не было подмены партии */
              select t.*
                    ,gp.sernumb
                    ,gs.rn      as gs_rn
                from transinvdeptspecs t
                join goodsparties      gp  on gp.rn    = t.goodsparty
                join goodssupply       gs  on gs.prn   = gp.rn
                                          and gs.store = rRow.in_store
               where t.prn    = rRow.rn
              union                 
              /* по накладной, в которой была подмена партии */
              select t.*
                    ,gp.sernumb
                    ,gs.rn      as gs_rn
                from transinvdeptspecs t
                join transinvdept      h    on h.rn     = t.prn
                join incomdoc          icd  on nvl( icd.code, 'null' ) = nvl( h.in_party_code, 'null' )
                join goodsparties      gp   on gp.indoc = icd.rn
                join goodssupply       gs   on gs.prn   = gp.rn
                                           and gs.store = rRow.in_store
               where h.rn     = rRow.rn
             )
    loop
      /* Считывание аналогичной спецификации в приходном ордере */
      usr_pkg_inorders.inorderspecs_get_by_params(nprn      => nIO
                                                 ,nnommodif => c.nommodif
                                                 ,narticle  => c.article
                                                 ,ssernumb  => c.sernumb
                                                 ,rrow      => rInOrderSpecs);
      /* Заполнение переменных */
      rRInvToSupSpecs.company         := c.company;
      rRInvToSupSpecs.prn             := rRInvToSup.rn;
      rRInvToSupSpecs.taxgr           := rInOrderSpecs.taxgr;
      rRInvToSupSpecs.goodssupply     := c.gs_rn;
      rRInvToSupSpecs.sernumb         := c.sernumb;
      rRInvToSupSpecs.nommodif        := c.nommodif;
      rRInvToSupSpecs.nomnmodifpack   := c.nomnmodifpack;
      rRInvToSupSpecs.article         := c.article;
      rRInvToSupSpecs.cell            := c.cell;
      pkg_dictaxis_calc.p_calculate_base(nflag_smart => 0
                                        ,ncompany    => c.company
                                        ,ddate       => rRInvToSup.docdate
                                        ,nsumm_sign  => 0 /* без налогов */
                                        ,ninsumm     => c.summwithnds
                                        ,ntaxgr      => rInOrderSpecs.taxgr
                                        ,nquant      => 1
                                        ,nncp_sign   => 1);
      rRInvToSupSpecs.summ            := pkg_dictaxis_calc.f_get_value(nident => 0); -- Сумма без налогов       (0)
      rRInvToSupSpecs.summtax         := pkg_dictaxis_calc.f_get_value(nident => 2); -- Сумма со всеми налогами (2)
      rRInvToSupSpecs.summ_nds        := pkg_dictaxis_calc.f_get_value(nident => 8); -- НДС                     (8)
      rRInvToSupSpecs.price           := rRInvToSupSpecs.summtax / c.quant;
      rRInvToSupSpecs.pricemeas       := c.pricemeas;
      rRInvToSupSpecs.quant           := c.quant;
      rRInvToSupSpecs.quantalt        := c.quantalt;
      rRInvToSupSpecs.coeff           := 0;
      rRInvToSupSpecs.coeff_val_sign  := 0;
      rRInvToSupSpecs.coeff_calc_sign := 1;
      rRInvToSupSpecs.autocalc_sign   := 1;
      rRInvToSupSpecs.begindate       := null;
      rRInvToSupSpecs.enddate         := null;
      rRInvToSupSpecs.note            := substr(c.note, 0, 239);
      rRInvToSupSpecs.original_name   := rInOrderSpecs.original_name;
      /* Добавление спецификации */
      usr_pkg_rinvtosup.rinvtosupspecs_base_insert(rrow => rRInvToSupSpecs, nmode => 0, nrn => rRInvToSupSpecs.rn);
            
      /* По калькуляциям спецификации текущего документа  */
      for c1 in (select * from transinvdeptclc where prn = c.rn)
      loop
        /* Заполнение переменных */
        rRInvToSupClc.prn          := rRInvToSupSpecs.rn;
        rRInvToSupClc.company      := c1.company;
        rRInvToSupClc.numb         := c1.numb;
        rRInvToSupClc.cost_article := c1.cost_article;
        rRInvToSupClc.cost_place   := c1.cost_place;
        rRInvToSupClc.cost_plan    := c1.cost_plan;
        rRInvToSupClc.cost_fact    := c1.cost_fact;
        rRInvToSupClc.priority     := c1.priority;
        rRInvToSupClc.faceacc      := c1.faceaccount;
        rRInvToSupClc.graphpoint   := c1.graphpoint;
        rRInvToSupClc.finoper_type := c1.finoper_type;
        rRInvToSupClc.quant_plan   := c1.quant_plan;
        rRInvToSupClc.quant_fact   := c1.quant_fact;
        rRInvToSupClc.subdiv       := c1.subdiv;
        /* Добавление калькуляции */
        usr_pkg_rinvtosup.rinvtosupclc_base_insert(rrow => rRInvToSupClc, nrn => nNumber);
      end loop;

    end loop;

    /* Установка связи */
    pkg_doclinks.link(nflag_smart   => 0
                     ,ncompany      => rRow.company
                     ,sin_unitcode  => 'GoodsTransInvoicesToDepts'
                     ,nin_document  => rRow.rn
                     ,sout_unitcode => 'ReturnInvoicesToSuppliers'
                     ,nout_document => rRInvToSup.rn);

    /* Отработка*/
    if nvl( nWORK, 0 )  = 1 then
      p_rinvtosup_bset_status( ncompany   => rRInvToSup.company
                              ,nrn        => rRInvToSup.rn
                              ,nstatus    => 2
                              ,dwork_date => rRInvToSup.docdate
                              ,nwarning   => nNumber
                              ,smsg       => sVarchar );
    end if;

  end TRANSINVDEPT_MAKE_RITS;
  /*#########################################################################################################*/


  procedure TRANSINVDEPT_LINK_TO_DPO
  /*
  Заголовок. Привязать отработанный документ к заказу подразделения
  */
  (
   nCOMPANY   in number
  ,nRN        in number /* РН в позразделение */
  ,nDPO       in number /* Заказ подразделения */
  )
  as
    rRow          transinvdept%rowtype;
    rStoreOper    azsgsmwaystypes%rowtype;
    /* для процедуры RECALC_PERFORMANCE*/
    nIDENT        pkg_std.tnumber;
    nDOP_RN       pkg_std.tref;
    dWORK_DATE    date;
    nGSMWAYS_TYPE pkg_std.tnumber;
    nOLD_STATUS   pkg_std.tnumber := 0;
    nSTATUS       pkg_std.tnumber := 1;
    nDO_LINK_WAY  pkg_std.tnumber := 1;

    nNumber       pkg_std.tref;

    /*** процедура пересчета исполнения у родительских документов ***/
    procedure RECALC_PERFORMANCE
    as
     nSO_SIGN         PKG_STD.tNUMBER;  -- знак зависит от складской операции (1-расход, -1-приход)
     nRTN_SO_SIGN     PKG_STD.tNUMBER;  -- знак зависит от складской операции (0-расход, 1-приход)
     nPLAN_SIGN       PKG_STD.tNUMBER;  -- знак суммирования плана (-1,0,1)
     nFACT_SIGN       PKG_STD.tNUMBER;  -- знак суммирования факта (-1,0,1)
     nRTN_PLAN_SIGN   PKG_STD.tNUMBER;  -- знак суммирования плана (-1,0,1)
     nRTN_FACT_SIGN   PKG_STD.tNUMBER;  -- знак суммирования факта (-1,0,1)
    begin

      /* если нет ни одного родительского документа - выходим */
      if nDOP_RN is null then
        return;
      end if;
      /* инициализация пакета расчета исполнения товарных позиций */
      PKG_GOODSDOCS_PERF_CRM.INIT( nCOMPANY, nIDENT );
      /* установка родительского заказа подразделения (поиск заказа идет в FIND_PARENT_REMOVE_RES) */
      nDOP_RN := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nIDENT, 'GoodsTransInvoicesToDepts', nRN, 'DepartmentsOrdersPerform', nDOP_RN );

      /* определим складскую операцию документа */
      if nGSMWAYS_TYPE = 0 then
        nSO_SIGN     := 1;  -- расход
        nRTN_SO_SIGN := 0;
      else
        nSO_SIGN     := -1; -- приход
        nRTN_SO_SIGN := 1;
      end if;

      /* выставим знаки суммирования плана и факта */
      if (nOLD_STATUS = 0) and (nSTATUS in (1,2)) then -- был не отработан
        nPLAN_SIGN := nSO_SIGN * nDO_LINK_WAY;
        nFACT_SIGN := nSO_SIGN; -- если накладная сделана через распоряжение, отражаем только на факте
        nRTN_PLAN_SIGN := nRTN_SO_SIGN * nDO_LINK_WAY;
        nRTN_FACT_SIGN := nRTN_SO_SIGN;
      elsif (nOLD_STATUS in (1,2)) and (nSTATUS = 0) then -- был отработан
        nPLAN_SIGN := - nSO_SIGN * nDO_LINK_WAY;
        nFACT_SIGN := - nSO_SIGN; -- если накладная сделана через распоряжение, отражаем только на факте
        nRTN_PLAN_SIGN := - nRTN_SO_SIGN * nDO_LINK_WAY;
        nRTN_FACT_SIGN := - nRTN_SO_SIGN;
      else -- в других ситуациях пересчет не нужен (состояние не меняется)
        return;
      end if;

      /* отражение исполнения по спецификациям расходной накладной на отпуск в подразделение */
      for Rec in (
        select T.CURRENCY, T.CURCOURS, T.CURBASE,
               F.CURRENCY FA_CURRENCY, T.FA_CURCOURS, T.FA_CURBASE,
               M.PRN NOMEN, S.NOMMODIF, S.NOMNMODIFPACK, S.ARTICLE,
               T.STORE, S.GOODSPARTY,
               S.QUANT, S.QUANTALT, S.SUMMWITHNDS
          from TRANSINVDEPT      T,
               TRANSINVDEPTSPECS S,
               NOMMODIF          M,
               FACEACC           F
         where T.RN       = nRN
           and S.PRN      = T.RN
           and S.NOMMODIF = M.RN
           and T.FACEACC  = F.RN (+)
      )
      loop
        /* суммирование исполнения */
        PKG_GOODSDOCS_PERF_CRM.SET_PERF( nIDENT, 1/*SIGN_PACK*/, null/*NOMENCLS*/, null/*UMEAS_MAIN*/,
          Rec.NOMEN, null/*NOMNPACK*/, Rec.NOMMODIF, Rec.NOMNMODIFPACK, Rec.ARTICLE,
          Rec.STORE, Rec.GOODSPARTY, null/*SERNUMB*/, null/*COUNTRY*/, null/*GTD*/,
          Rec.QUANT, Rec.QUANTALT, Rec.QUANT, Rec.QUANTALT,
          Rec.QUANT/*nRTN_PLANM_QUANT*/, Rec.QUANTALT/*nRTN_PLANA_QUANT*/,
          Rec.QUANT/*nRTN_FACTM_QUANT*/, Rec.QUANTALT/*nRTN_FACTA_QUANT*/,
          Rec.SUMMWITHNDS, Rec.SUMMWITHNDS,
          nPLAN_SIGN, nFACT_SIGN, nRTN_PLAN_SIGN, nRTN_FACT_SIGN,
          Rec.CURRENCY, Rec.CURCOURS, Rec.CURBASE,
          Rec.FA_CURRENCY, Rec.FA_CURBASE, Rec.FA_CURCOURS, dWORK_DATE );
      end loop;
      /* сохранение рассчитаного исполнения в родительских документах */
      PKG_GOODSDOCS_PERF_CRM.SAVE_PARENT( nIDENT );
    end RECALC_PERFORMANCE;

  begin
    /* Считывание*/
    rRow := transinvdept_get(nrn => nRN);
    select *  into rStoreOper from azsgsmwaystypes where rn  = rRow.stoper;
    select rn into nDOP_RN    from departmentordp  where prn = nDPO;

    /* Проверка отработанности документа*/
    if rRow.status != 1 then
      p_exception(0, 'Документ не отработан. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if;

    /* Установка саязи с заказом подразделения */
    pkg_doclinks.link(nflag_smart   => 0
                     ,ncompany      => rRow.company
                     ,sin_unitcode  => 'DepartmentsOrders'
                     ,nin_document  => nDPO
                     ,sout_unitcode => 'GoodsTransInvoicesToDepts'
                     ,nout_document => rRow.rn);
    /* Установка саязи с исполнением заказа подразделения */
    pkg_doclinks.link(nflag_smart   => 0
                     ,ncompany      => 90521
                     ,sin_unitcode  => 'DepartmentsOrdersPerform'
                     ,nin_document  => nDOP_RN
                     ,sout_unitcode => 'GoodsTransInvoicesToDepts'
                     ,nout_document => rRow.rn);

    /* Генерация Ident */
    nIdent := gen_ident;
    p_selectlist_insert(nident    => nIdent
                       ,ndocument => rRow.rn
                       ,sunitcode => 'GoodsTransInvoicesToDepts'
                       ,nrn       => nNumber);

    /* Заполнение переменных для процедуры */
    dWORK_DATE    := rRow.work_date;
    nGSMWAYS_TYPE := rStoreOper.gsmways_type;

    /* Процедура отражения исполнения на заказе подразделения */
    recalc_performance;

    /* Очистка Ident */
    p_selectlist_clear(nident => nIdent);
    
  end TRANSINVDEPT_LINK_TO_DPO;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_SPRJ_COPY
  /*
  Заголовок. Копирование из мест хранения для списания в места хранения для распределения
  */
  (
   nRN        in number
  )
  as
    nres         pkg_std.tREF;
    nin_store    pkg_std.tREF;
    nrack        pkg_std.tREF;
    ncell        pkg_std.tREF;
    ngoodssupply pkg_std.tREF;
    ncount       number;
  begin
    /* Количество резервов */
    select count(1)
      into ncount
      from doclinks l, strplresjrnl r
     where l.in_document  = nRN
       and l.in_unitcode  = 'GoodsTransInvoicesToDepts'
       and l.out_unitcode = 'StoragePlacesResJournal'
       and r.rn           = l.out_document
       and r.res_type     = 0;

    /* Если резервы уже созданы, то выдаем сообщение об ошибке */
    if (ncount > 0) then
      p_exception(0, 'Резервы уже созданы');
    end if;

    /* Склад */
    select n.in_store into nin_store from transinvdept n where n.rn = nRN;

    /* Цикл по расходным резервам */
    for r in (select r.*
                from doclinks l, strplresjrnl r
               where l.in_document  = nRN
                 and l.in_unitcode  = 'GoodsTransInvoicesToDepts'
                 and l.out_unitcode = 'StoragePlacesResJournal'
                 and r.rn           = l.out_document
                 and r.res_type     = 1) 
    loop
      /* Товарный запас */
      begin
          select gs_i.rn
            into ngoodssupply
            from goodssupply gs_o, goodssupply gs_i
           where gs_o.rn    = r.goodssupply
             and gs_i.prn   = gs_o.prn
             and gs_i.store = nin_store;
      exception
      when no_data_found then
      ngoodssupply:=null;
      end;
      /* Стеллаж */
      select r_i.rn
        into nrack
        from stplracks r_o, stplracks r_i
       where r_o.rn = r.rack
         and r_i.store = nin_store
         and r_i.company = r_o.company
         and r_i.pref = r_o.pref
         and r_i.numb = r_o.numb;
      /* Ячейка */
      select c_i.rn
        into ncell
        from stplcells c_o, stplcells c_i
       where c_o.rn = r.cell
         and c_i.prn = nrack
         and c_i.pref = c_o.pref
         and c_i.numb = c_o.numb;

      /* Выполняем резервирование */
      p_strplresjrnl_base_insert(ncompany        => r.company,
                                 sauthid         => r.authid,
                                 smasterunitcode => 'GoodsTransInvoicesToDepts',
                                 sslaveunitcode  => 'GoodsTransInvoicesToDeptsSpecs',
                                 nmasterrn       => nRN,
                                 nslavern        => f_doclinks_link_in_doc(sout_unitcode => 'StoragePlacesResJournal',
                                                                           nout_document => r.rn,
                                                                           sin_unitcode  => 'GoodsTransInvoicesToDeptsSpecs'),
                                 nrack           => nrack,
                                 ncell           => ncell,
                                 ngoodssupply    => ngoodssupply,
                                 nres_type       => 0,
                                 nnommodif       => r.nommodif,
                                 nnomnmodifpack  => r.nomnmodifpack,
                                 narticle        => r.article,
                                 ngoodsunit      => r.goodsunit,
                                 ndoctype        => r.doctype,
                                 ddocdate        => r.docdate,
                                 sdocnumb        => r.docnumb,
                                 sdocpref        => r.docpref,
                                 dreserving_date => r.reserving_date,
                                 dfree_date      => null,
                                 nquant          => r.quant,
                                 nquantalt       => r.quantalt,
                                 nquantpack      => r.quantpack,
                                 ncheck_party    => 0,
                                 nrn             => nres);
    end loop;
    
  end TRANSINVDEPT_SPRJ_COPY;
  /*########################################################################################################*/

  procedure TRANSINVDEPT_SPRJ_COPY_OTHER
  /*
  Процедура копирования резервирования по местам хранения в другой (или тот же) документ, из мест для списания или для распределения
  */
  (
   nFLAGSMART           in number default 0
  ,nRN_FROM             in number           /* Документ-источник. Заголовок. RN */
  ,nRES_TYPE_FROM       in number default 0 /* Документ-источник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,nRN_TO               in number           /* Документ-приёмник. Заголовок. RN */
  ,nRES_TYPE_TO         in number default 1 /* Документ-приёмник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,dRESERVING_DATE      in date             /* Документ-приёмник. Дата резервирования */
  )
  as
    rRow    transinvdept%rowtype;
  begin
    /* Считывание заголовка документа-источника */
    rRow := transinvdept_get( nrn => nRN_FROM ); 

    /* Проверка отработанности документа-источника для случаев, когда попирование выполняется из "приход (для распределения)" */
    if rRow.in_status != 1 and nRES_TYPE_FROM = 0 then
      p_exception( nFLAGSMART, 'Документ-источник не отработан. Копирование из "Места хранения для распределния" не будет выполнено.%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
    end if;

    /* По спецификациям документа-источника и приёмника */
    for c in ( 
              select t1.rn as t1_rn, t1.prn as t1_prn, t2.rn as t2_rn, t2.prn as t2_prn
                    ,dt2.doccode  as dt2_doccode, h2.pref as h2_pref, h2.numb as h2_numb, h2.docdate as h2_docdate
                from transinvdeptspecs t1
                    ,transinvdeptspecs t2
                join transinvdept      h2  on h2.rn  = t2.prn
                join doctypes          dt2 on dt2.rn = h2.doctype
               where t1.prn      = nRN_FROM
                 and t2.prn      = nRN_TO
                 and cmp_num( t1.goodsparty, t2.goodsparty) = 1
                 and cmp_num( t1.article   , t2.article   ) = 1
             )
    loop
      /* Копирование */
      usr_pkg_strplresjrnl.strplresjrnl_copy( nflagsmart         => nFLAGSMART
                                             ,nrn_from           => c.t1_rn
                                             ,nres_type_from     => nRES_TYPE_FROM
                                             ,nrn_to             => c.t2_rn
                                             ,nprn_to            => c.t2_prn
                                             ,nres_type_to       => nRES_TYPE_TO
                                             ,smasterunitcode_to => 'GoodsTransInvoicesToDepts'
                                             ,sslaveunitcode_to  => 'GoodsTransInvoicesToDeptsSpecs'
                                             ,sdoctype           => c.dt2_doccode
                                             ,sdocpref           => c.h2_pref
                                             ,sdocnumb           => c.h2_numb
                                             ,ddocdate           => c.h2_docdate
                                             ,dreserving_date    => dRESERVING_DATE );
    end loop;

  end TRANSINVDEPT_SPRJ_COPY_OTHER;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_SPRJ_MINS
  /*
  Заголовок. Массовое резервирование по местам хранения
  */
  (
   nCOMPANY       in number                 /* Рег номер организации */
  ,sUNITCODE      in varchar2 default null  /* Код раздела (не используется) */
  ,nCRN           in number   default null  /* каталог */
  ,nRN            in number                 /* Рег номер */
  ,nIDENT         in number   default null  /* Идент выделенных записей (не используется) */
  ,sSTORE         in varchar2 default null  /* склад */
  ,sCELL          in varchar2 default null  /* место хранения (резервуар) */
  ,nRES_TYPE      in number   default 1     /* тип резервирования (0 - приход, 1 - расход) */
  ,nREPLACE       in number   default 0     /* Распределение с заменой найденных записей (0 - нет, 1 - да) */
  ,nRETURN        in number   default 0     /* признак возвратной накладной (0 - нет, 1 - да) */
  ,dRESERVINGDATE in date     default null  /* дата и время резервирования. */
  ,nOUTNOTE       out number
  ) 
  as
    nCRN2      pkg_std.tref     := nCRN;  
    sStore2    pkg_std.tstring  := sSTORE;
    sCell2     pkg_std.tstring  := sCELL;
    nRes_Type2 pkg_std.tnumber  := nRES_TYPE;
    nReplace2  pkg_std.tnumber  := nREPLACE;
    nReturn2   pkg_std.tnumber  := nRETURN;

    nNumber  pkg_std.tnumber;
    sVarchar pkg_std.tstring;
  begin
    /* Каталог документа. RN */
    if nCRN2 is null then
      p_transinvdept_exists( ncompany => nCOMPANY, nrn => nRN, ncrn => nCRN2 );
    end if;

    /* Пересчёт параметров */
    udo_p_transinvdept_prms_fe(N_RN => null
                              ,ncompany     => nCOMPANY
                              ,nrn          => nRN
                              ,satrib       => null
                              ,sstore       => sStore2
                              ,sstore_nd    => sVarchar
                              ,scell        => sCell2
                              ,scell_nd     => nNumber
                              ,scell_nn     => nNumber
                              ,nreturn      => nReturn2
                              ,nreturn_nd   => nNumber
                              ,nres_type_nd => nNumber
                              ,nreplace     => nReplace2
                              ,nreplace_nd  => nNumber
                              ,nres_type    => nRes_Type2);
    udo_p_transinvdept_prms_fe(N_RN => null
                              ,ncompany     => nCOMPANY
                              ,nrn          => nRN
                              ,satrib       => 'SCELL'
                              ,sstore       => sStore2
                              ,sstore_nd    => sVarchar
                              ,scell        => sCell2
                              ,scell_nd     => nNumber
                              ,scell_nn     => nNumber
                              ,nreturn      => nReturn2
                              ,nreturn_nd   => nNumber
                              ,nres_type_nd => nNumber
                              ,nreplace     => nReplace2
                              ,nreplace_nd  => nNumber
                              ,nres_type    => nRes_Type2);
    udo_p_transinvdept_prms_fe(N_RN => null
                              ,ncompany     => nCOMPANY
                              ,nrn          => nRN
                              ,satrib       => 'NRES_TYPE'
                              ,sstore       => sStore2
                              ,sstore_nd    => sVarchar
                              ,scell        => sCell2
                              ,scell_nd     => nNumber
                              ,scell_nn     => nNumber
                              ,nreturn      => nReturn2
                              ,nreturn_nd   => nNumber
                              ,nres_type_nd => nNumber
                              ,nreplace     => nReplace2
                              ,nreplace_nd  => nNumber
                              ,nres_type    => nRes_Type2);

    /* Запись спецификаций в selectlist */
    for c in ( select rn from transinvdeptspecs where prn = nRN )
    loop
      p_selectlist_insert(nident    => nRN
                         ,ndocument => c.rn
                         ,sunitcode => 'GoodsTransInvoicesToDeptsSpecs'
                         ,nrn       => nNumber);
    end loop;
    /* Процедура резервирования */
    udo_p_strplresjrnl_mins_trd(ncompany       => nCompany
                               ,sunitcode      => 'GoodsTransInvoicesToDeptsSpecs'
                               ,ncrn           => nCRN2
                               ,nrn            => nRN
                               ,nident         => nRN
                               ,sstore         => sStore2
                               ,scell          => sCell2
                               ,nres_type      => nRes_Type2
                               ,nreplace       => nReplace2
                               ,nreturn        => nReturn2
                               ,dreservingdate => dRESERVINGDATE
                               ,noutnote       => nOUTNOTE);
    /* Очистка selectlist */
    p_selectlist_clear(nident => nRN);

  end TRANSINVDEPT_SPRJ_MINS;
  /*#########################################################################################################*/

  procedure TRANSINVDEPT_FIND_SPECS_SAME
  /*
  Заголовок. Поиск спецификаций с такой же Партией поставщика, и отправка уведомления, если найдены
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  as
    rGoodsParties       goodsparties%rowtype;
    rIncomDoc           incomdoc%rowtype;
    sSupplier_Party     pkg_std.tstring; 
    sDescription        pkg_std.tstring; 
    cText               clob := ' ';
    nCount              pkg_std.tnumber := 0; 
    nProject            pkg_std.tref; 

    nNumber             pkg_std.tnumber; 
  begin
    /* По спецификациям */
    for c in (select * from transinvdeptspecs where prn = NRN) 
    loop
      /* Составление текста для рассылки о приходе с партией поставщика, которая есть на складе */
      /* Партия товара текущей записи */
      rGoodsParties    := usr_pkg_goodsparties.goodsparties_get( nrn => c.goodsparty );
      /* Поиск RN партии товара, по которой был приход серии */
      rGoodsParties.rn := usr_pkg_goodsparties.goodsparties_get_indocs_data( ssernumb => rGoodsParties.sernumb, sparam => 'nGP' );
      /* Считывание партии товара, по которой был приход серии */
      rGoodsParties    := usr_pkg_goodsparties.goodsparties_get( nrn => rGoodsParties.rn );
      /* Считывание приходной партии, по которой был приход серии */
      rIncomDoc        := usr_pkg_goodsparties.incomdoc_get( nrn => rGoodsParties.indoc );
      /* Партия поставщика из свойства */
      sSupplier_Party  := usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 69192082, ndocument => rGoodsParties.rn );
      /* Проект партии товара */
      select max( pjs.prn )
        into nProject
        from goodssupply    gs
        join goodssupplyclc gsc on gsc.prn     = gs.rn
        join projectstage   pjs on pjs.faceacc = gsc.faceacc
       where gs.prn = rGoodsParties.rn;

      /* По приходным партиям с такой же партией поставщика */
      for c in ( 
                 select *
                   from ( select t.rn
                                ,t.sernumb
                                ,t.nommodif
                                ,icd.agent
                                ,( select sum( s.restfact ) from goodssupply s where s.prn = t.RN )               as restfact
                                ,usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 69192082, ndocument => t.rn )  as Supplier_Party
                                ,( select max( pjs.prn )
                                     from goodssupply    gs
                                     join goodssupplyclc gsc on gsc.prn     = gs.rn
                                     join projectstage   pjs on pjs.faceacc = gsc.faceacc
                                    where gs.prn = t.rn )                                                         as project
                            from goodsparties t 
                            join incomdoc     icd on icd.rn = t.indoc ) gp
                  where gp.rn                != rGoodsParties.rn
                    and gp.nommodif           = rGoodsParties.nommodif
                    and gp.agent              = rIncomDoc.agent
                    and gp.Supplier_Party     = sSupplier_Party
                    and gp.Supplier_Party     is not null and sSupplier_Party is not null
                    /* and nvl( gp.project, -1 ) = nvl( nProject, -1 ) */
                    and gp.restfact          != 0
                    and gp.rn                 = nvl( usr_pkg_goodsparties.goodsparties_get_indocs_data( ssernumb       => gp.sernumb
                                                                                                       ,nflagsmart     => 1
                                                                                                       ,ntoo_many_rows => 1
                                                                                                       ,sparam         => 'nGP' ), -1 )
               )
      loop
        /* Счётчик найденных совпадений */
        nCount := nCount + 1;

        /* Если первое найденное совпадение */
        if nCount = 1 then
          /* Формирование текста сообщения. Текущая спецификация */
          cText := strcombine( cText
                              ,f_docdescrs_get_description( sunitcode => 'GoodsParties', ndocument => rGoodsParties.rn ) ||', Проект: '|| usr_pkg_project.project_get_code_id( nflagsmart => 1, nrn => nProject )
                              ,cr||'-------------------------'||cr||'Для спецификации: ' );
          /* Добавляем заголовок к тексту сообщения */
          cText := strcombine( cText, 'Найдены приходные партии: ', cr||cr);
        end if;

        /* Добавление к сообщению описания найденной приходной партии с такой же партией поставщика */
        cText := strcombine( cText
                            ,f_docdescrs_get_description( sunitcode => 'GoodsParties', ndocument => c.rn ) ||', Проект: '|| usr_pkg_project.project_get_code_id( nflagsmart => 1, nrn => c.Project ) 
                            ,cr||cr );
      end loop;               
    end loop;

    /* Если были найдены партии с такой же партией поставщика */
    if nCount != 0 then
      /* Тема */
      sDescription := 'Поступление на склад позиций с партией поставщика, которая уже есть на складе.';
      /* Содержание */
      /* Реквизиты накладной */
      cText := cr|| 'Накладная: ' || f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => nRN ) ||cr|| cText;
      /* Отправка */
      usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany         => nCOMPANY
                                                  ,sdescription     => sDescription
                                                  ,sto_list         => usr_pkg_usergrp.usergrp_get_mail_list( nrn => 260498698, nflagsmart => 0 ) /* Отд.сертификации */
                                                  ,stitle           => sDescription
                                                  ,ctext            => cText
                                                  ,nrn              => nNumber );
    end if;

  end TRANSINVDEPT_FIND_SPECS_SAME;
  /*#########################################################################################################*/

  function TRANSINVDEPTBUF_GET
  /*
  Заголовок (буфер). Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvdeptbuf%rowtype
  is
    rRow transinvdeptbuf%rowtype;
  begin
    begin
      select * into rRow from transinvdeptbuf where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'TRANSINVDEPTBUF');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPTBUF'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end TRANSINVDEPTBUF_GET;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTBUF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW     in transinvdeptbuf%rowtype
  ) 
  is
  begin
    p_transinvdeptbuf_base_update(nrn            => rROW.RN
                                 ,ncompany       => rROW.COMPANY
                                 ,nident         => rROW.IDENT
                                 ,ncrn           => rROW.CRN
                                 ,njur_pers      => rROW.JUR_PERS
                                 ,ndoctype       => rROW.DOCTYPE
                                 ,spref          => rROW.PREF
                                 ,snumb          => rROW.NUMB
                                 ,ddocdate       => rROW.DOCDATE
                                 ,nstatus        => rROW.STATUS
                                 ,ndirdoc        => rROW.DIRDOC
                                 ,sdirnumb       => rROW.DIRNUMB
                                 ,ddirdate       => rROW.DIRDATE
                                 ,nstoper        => rROW.STOPER
                                 ,nfaceacc       => rROW.FACEACC
                                 ,ngraphpoint    => rROW.GRAPHPOINT
                                 ,nstore         => rROW.STORE
                                 ,nmol           => rROW.MOL
                                 ,nsheepview     => rROW.SHEEPVIEW
                                 ,nagent         => rROW.AGENT
                                 ,nsubdiv        => rROW.SUBDIV
                                 ,ncurrency      => rROW.CURRENCY
                                 ,ncurcours      => rROW.CURCOURS
                                 ,ncurbase       => rROW.CURBASE
                                 ,nsummwithnds   => rROW.SUMMWITHNDS
                                 ,nrecipdoc      => rROW.RECIPDOC
                                 ,srecipnumb     => rROW.RECIPNUMB
                                 ,drecipdate     => rROW.RECIPDATE
                                 ,nferryman      => rROW.FERRYMAN
                                 ,sgetconfirm    => rROW.GETCONFIRM
                                 ,swaybladenumb  => rROW.WAYBLADENUMB
                                 ,ndriver        => rROW.DRIVER
                                 ,ncar           => rROW.CAR
                                 ,nroute         => rROW.ROUTE
                                 ,ntrailer1      => rROW.TRAILER1
                                 ,ntrailer2      => rROW.TRAILER2
                                 ,nin_store      => rROW.IN_STORE
                                 ,nin_mol        => rROW.IN_MOL
                                 ,nfa_curcours   => rROW.FA_CURCOURS
                                 ,nfa_curbase    => rROW.FA_CURBASE
                                 ,nin_stoper     => rROW.IN_STOPER
                                 ,sin_party      => rROW.IN_PARTY_CODE
                                 ,nin_curcours   => rROW.IN_CURCOURS
                                 ,nin_curbase    => rROW.IN_CURBASE
                                 ,nvalid_doctype => rROW.VALID_DOCTYPE
                                 ,svalid_docnumb => rROW.VALID_DOCNUMB
                                 ,dvalid_docdate => rROW.VALID_DOCDATE
                                 ,scomments      => rROW.COMMENTS
                                 ,sbarcode       => rROW.BARCODE
                                 ,nord_doctype   => rROW.ORD_DOCTYPE
                                 ,sord_docnumb   => rROW.ORD_DOCNUMB
                                 ,dord_docdate   => rROW.ORD_DOCDATE
                                 ,nneed_util     => rROW.NEED_UTIL);
  end TRANSINVDEPTBUF_BASE_UPDATE;
  /*#########################################################################################################*/

  function TRANSINVDEPTSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvdeptspecs%rowtype
  is
    rRow transinvdeptspecs%rowtype;
  begin
    begin
      select * into rRow from transinvdeptspecs where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'TRANSINVDEPTSPECS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPTSPECS')) 
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end TRANSINVDEPTSPECS_GET;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              transinvdeptspecs%rowtype;
  begin
    /* Считывание */
    rRow := transinvdeptspecs_get(nrn => NRN);

    /* ПРОВЕРКИ */
    /* Проверка прав на действие с ЗАГОЛОВКОМ по статусной модели */
    pkg_unitstmod.exec_processing( ncompany  => rRow.company
                                  ,sunitcode => 'GoodsTransInvoicesToDepts'
                                  ,ndocument => rRow.prn
                                  ,saction   => 'TRANSINVDEPTSPECS_INSERT'
                                  ,smode     => 'BEFORE'
                                  ,nstandard => 2
                                  ,nbusproc  => null );
    /* Проверка вместо ключа C_TRANSINVDEPTSPECS_UK в таблице */
    for c in (select t.*
                from transinvdeptspecs t 
               where t.prn        = rRow.prn
                 and t.rn        != rRow.rn
                 and nvl(t.nommodif, 0)   = nvl(rRow.nommodif, 0)
                 and nvl(t.article, 0)    = nvl(rRow.article, 0)
                 and nvl(t.goodsparty, 0) = nvl(rRow.goodsparty, 0)
             )
    loop
      p_exception(0, 'Дублирование спецификации. %s %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.prn)); 
    end loop;
    /* Базовая */
    transinvdeptspecs_check_base(nrn => NRN, ncompany => NCOMPANY);

  end TRANSINVDEPTSPECS_AINSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdeptspecs%rowtype;
  begin
    /* Считывание */
    rRow := transinvdeptspecs_get( nrn => NRN );
    usr_pkg_pub_const.rtransinvdeptspecs := rRow; 

    /* Проверка прав на действие с ЗАГОЛОВКОМ по статусной модели */
    pkg_unitstmod.exec_processing( ncompany  => rRow.company
                                  ,sunitcode => 'GoodsTransInvoicesToDepts'
                                  ,ndocument => rRow.prn
                                  ,saction   => 'TRANSINVDEPTSPECS_UPDATE'
                                  ,smode     => 'BEFORE'
                                  ,nstandard => 2
                                  ,nbusproc  => null );
  end TRANSINVDEPTSPECS_BUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdeptspecs%rowtype;
  begin
    /* Считывание */
    rRow := transinvdeptspecs_get(nrn => NRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    transinvdeptspecs_check_base(nrn => NRN, ncompany => NCOMPANY);

    /* Исправление модификации */
    if rRow.nommodif != usr_pkg_pub_const.rtransinvdeptspecs.nommodif then
      /* Наличие распределения по местам хранения */
      for c in ( select sprj.rn
                   from doclinks     dl
                       ,strplresjrnl sprj
                  where dl.in_document  = nRN
                    and dl.out_document = sprj.rn )
      loop
        p_exception(0, 'Исправление номенклатуры или модификации запрещено, т.к. у спецификации есть записи резервирования по местам хранения. %s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)); 
      end loop;
    end if;

    /* Исправление количества */
    /*if rRow.quant != usr_pkg_pub_const.rtransinvdeptspecs.quant then
      \* Наличие распределения по местам хранения *\
      for c in ( select sprj.rn
                   from doclinks     dl
                       ,strplresjrnl sprj
                  where dl.in_document  = nRN
                    and dl.out_document = sprj.rn )
      loop
        p_exception(0, 'Исправление количества запрещено, т.к. у спецификации есть записи резервирования по местам хранения. %s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)); 
      end loop;
    end if;*/

  end TRANSINVDEPTSPECS_AUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdeptspecs%rowtype;
  begin
    /* Считывание */
    rRow := transinvdeptspecs_get( nrn => nRN );

    /* ИСПРАВЛЕНИЯ */
    /* Удаление входных связей с Сертификация/Входной контроль (результаты проверки) */
    pkg_doclinks.remove( sin_unitcode  => 'UdoProdCullSpOut'
                        ,nin_document  => null
                        ,sout_unitcode => 'GoodsTransInvoicesToDeptsSpecs'
                        ,nout_document => rRow.rn );

    /* ПРОВЕРКИ */
    /* Проверка прав на действие с ЗАГОЛОВКОМ по статусной модели */
    pkg_unitstmod.exec_processing( ncompany  => rRow.company
                                  ,sunitcode => 'GoodsTransInvoicesToDepts'
                                  ,ndocument => rRow.prn
                                  ,saction   => 'TRANSINVDEPTSPECS_DELETE'
                                  ,smode     => 'BEFORE'
                                  ,nstandard => 2
                                  ,nbusproc  => null );
  end TRANSINVDEPTSPECS_BDELETE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            transinvdeptspecs%rowtype;
    rHead           transinvdept%rowtype;
    rStoper         azsgsmwaystypes%rowtype;
    rIn_Stoper      azsgsmwaystypes%rowtype;
    nRestFact       pkg_std.tquant; 
    rDicNomns       dicnomns%rowtype;
    nDicNomns       pkg_std.tref; 
    rStore          azsazslistmt%rowtype; 
    rIn_Store       azsazslistmt%rowtype; 
    rGoodsParties   goodsparties%rowtype; 
    
    nNumber         pkg_std.tnumber; 
    sVarchar        pkg_std.tstring; 
  begin
    null;
    /* Считывание */
    rRow := transinvdeptspecs_get(nrn => NRN);
    rHead := transinvdept_get(nrn => rRow.prn);
    /* Склад-отправитель */
    rStore := udo_pkg_get.row_store(nrn => rHead.store, nsmart => 0);
    /* Склад-получатель */
    if rHead.in_store is not null then
      rIn_Store := udo_pkg_get.row_store(nrn => rHead.in_store, nsmart => 0);
    end if;
    /* Складская операция-отправителя */
    rStoper := udo_pkg_get.row_stoper(nrn => rHead.stoper, nsmart => 1);
    /* Складская операция-получателя */
    if rHead.in_stoper is not null then
      rIn_Stoper := udo_pkg_get.row_stoper(nrn => rHead.in_stoper, nsmart => 1);
    end if; 
    /* Номенклатура */
    nDicNomns := usr_pkg_DicNomns.nommodif_get_prn_by_rn(nrn => rRow.nommodif);
    rDicNomns := usr_pkg_DicNomns.dicnomns_get(nrn => nDicNomns);

    /* ИСПРАВЛЕНИЯ */


    /* ПРОВЕРКИ */

    /* Если не заполнено изделие*/
    if rRow.article is null 
    and not usr_pkg_common.is_lists_intersect(slist1 => 'TRANSINVDEPTSPECS_CHECK_BASE.1', slist2 => usr_pkg_pub_const.sexceptionlist) then

      /* Направление складской операции-отправителя Расход */
      if rStoper.gsmways_type = 0 then 
        /* остаток по модификации и складу-отправителю на дату документа */
        usr_p_get_rest_quant(nstore     => rHead.store
                            ,ddate      => rHead.docdate
                            ,nrestfact  => nRestFact
                            ,nreserv    => nNumber
                            ,nsale      => nNumber);
        /* количество в сепцификации больше товарного запаса */
        if rRow.quant > nRestFact then
          p_exception(0, 'Количество в спецификации <%s> больше количества номенклатуры <%s> на складе <%s>. %s%s'
                     ,rRow.quant
                     ,nRestFact
                     ,f_dicstore_get_numb(nstore => rHead.store)
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.prn)); 
        end if;
      /* Направление складской операции-получателя Расход и задан склад-получатель */
      elsif rIn_Stoper.gsmways_type = 0 
      and rHead.in_store is not null then 
        /* остаток по модификации и складу-получателю на дату документа */
        usr_p_get_rest_quant(nstore     => rHead.in_store
                            ,ddate      => rHead.docdate
                            ,nrestfact  => nRestFact
                            ,nreserv    => nNumber
                            ,nsale      => nNumber);
        /* количество в сепцификации больше товарного запаса */
        if rRow.quant > nRestFact then
          p_exception(0, 'Количество в спецификации <%s> больше количества номенклатуры <%s> на складе <%s>. %s%s'
                     ,rRow.quant
                     ,nRestFact
                     ,f_dicstore_get_numb(nstore => rHead.in_store)
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)
                     ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.prn)); 
        end if;
      end if;
      
      /* Дробное количество для группы ЭРИ */
      if rDicNomns.group_code = 13884309
      and trunc(rRow.quant) != rRow.quant then
        select group_code into sVarchar from dicgnomn where rn = rDicNomns.group_code;
        p_exception(0, 'Дробное количество в спецификации <%s> у номенклатуры с группой <%s>. %s%s'
                   ,rRow.quant
                   ,sVarchar
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.prn)); 
      end if;

      /* 30/03/2026 KHOK. Серии строк Расходников на Сертификацию должны быть в одной Теме */
      for c in (select t.*
                  from transinvdeptspecs t 
                 where t.prn        = rRow.prn
                   and t.rn        != rRow.rn
               )
      loop
        if c.crn = 47815697 and
           INSTR(STR1 => UDO_F_TRANSINVDEPTSPECS_TEMA(NRN => c.rn),
                 STR2 => UDO_F_TRANSINVDEPTSPECS_TEMA(NRN => rRow.Rn)) = 0 and
           INSTR(STR1 => UDO_F_TRANSINVDEPTSPECS_TEMA(NRN => rRow.rn),
                 STR2 => UDO_F_TRANSINVDEPTSPECS_TEMA(NRN => c.Rn)) = 0 --and utilizer not in ('SUROVA_EV', 'FEDOREEV_RE')
        then
            p_exception(0, 'Тема Серии существующих строк накладной - "' || nvl(UDO_F_TRANSINVDEPTSPECS_TEMA(NRN => c.rn), '?') ||
                           '", а Тема Серии добавляемой строки - "' || nvl(UDO_F_TRANSINVDEPTSPECS_TEMA(NRN => rRow.Rn), '?') || '"');
        end if; 
      end loop;
    end if;

    /* Очистка списка исключений */
    usr_pkg_pub_const.sexceptionlist := null;
    
  end TRANSINVDEPTSPECS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BASE_INSERT
  /*
  Спецификация. Добавить. Базовая
  */
  (
   rROW           in transinvdeptspecs%rowtype
  ,nFROM_CLIENT   in number default 0
  ,nRN            out number
  ) 
  is
  begin
    p_transinvdeptsp_base_insert(ncompany         => rROW.COMPANY
                                ,nprn             => rROW.PRN
                                ,nagent           => rROW.AGENT
                                ,ngoodsparty      => rROW.GOODSPARTY
                                ,nnommodif        => rROW.NOMMODIF
                                ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                ,narticle         => rROW.ARTICLE
                                ,ncell            => rROW.CELL
                                ,ntemperature     => rROW.TEMPERATURE
                                ,nprice           => rROW.PRICE
                                ,nquant           => rROW.QUANT
                                ,nquantalt        => rROW.QUANTALT
                                ,ncoeff           => rROW.COEFF
                                ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                ,npricemeas       => rROW.PRICEMEAS
                                ,nsummwithnds     => rROW.SUMMWITHNDS
                                ,dbegindate       => rROW.BEGINDATE
                                ,denddate         => rROW.ENDDATE
                                ,snote            => rROW.NOTE
                                ,sbcode           => rROW.BCODE
                                ,scardnumb        => rROW.CARDNUMB
                                ,sstrcode         => rROW.STRCODE
                                ,ncons_rate       => rROW.CONS_RATE
                                ,nservlife        => rROW.SERVLIFE
                                ,nrevreas         => rROW.REVREAS
                                ,sres_comms       => rROW.RES_COMMS
                                ,nrn              => nRN
                                ,nfrom_client     => nFROM_CLIENT);
  end TRANSINVDEPTSPECS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправить. Базовая
  */
  (
   rROW  in transinvdeptspecs%rowtype
  ) 
  is
  begin
    p_transinvdeptsp_base_update(nRN              => rROW.RN
                                ,nCOMPANY         => rROW.COMPANY
                                ,nAGENT           => rROW.AGENT
                                ,nGOODSPARTY      => rROW.GOODSPARTY
                                ,nNOMMODIF        => rROW.NOMMODIF
                                ,nNOMNMODIFPACK   => rROW.NOMNMODIFPACK
                                ,nARTICLE         => rROW.ARTICLE
                                ,nCELL            => rROW.CELL
                                ,nTEMPERATURE     => rROW.TEMPERATURE
                                ,nPRICE           => rROW.PRICE
                                ,nQUANT           => rROW.QUANT
                                ,nQUANTALT        => rROW.QUANTALT
                                ,nCOEFF           => rROW.COEFF
                                ,nCOEFF_VAL_SIGN  => rROW.COEFF_VAL_SIGN
                                ,nCOEFF_CALC_SIGN => rROW.COEFF_CALC_SIGN
                                ,nPRICEMEAS       => rROW.PRICEMEAS
                                ,nSUMMWITHNDS     => rROW.SUMMWITHNDS
                                ,dBEGINDATE       => rROW.BEGINDATE
                                ,dENDDATE         => rROW.ENDDATE
                                ,sNOTE            => rROW.NOTE
                                ,sBCODE           => rROW.BCODE
                                ,sCARDNUMB        => rROW.CARDNUMB
                                ,sstrcode         => rROW.STRCODE
                                ,ncons_rate       => rROW.CONS_RATE
                                ,nservlife        => rROW.SERVLIFE
                                ,nrevreas         => rROW.REVREAS
                                ,sres_comms       => rROW.RES_COMMS      
                                );
  end TRANSINVDEPTSPECS_BASE_UPDATE;
  /*#########################################################################################################*/

  PROCEDURE TRANSINVDEPTSPECS_BASE_DELETE
  /*
  Спецификация. Удалить. Базовая
  */
  (
   nCOMPANY     in number
  ,nRN          in number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rRow          transinvdeptspecs%rowtype;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_transinvdeptsp_base_delete( ncompany => nCOMPANY, nrn => nRN );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Проверка перед удалением */
      transinvdeptspecs_bdelete( nrn => nRN, ncompany => nCOMPANY );

      /* Удаление базовой процедурой с указанием в сообщении реквизитов документа */
      begin
        transinvdeptspecs_base_delete( ncompany => nCOMPANY, nrn => nRN );
      exception when others then
        rRow := transinvdeptspecs_get( nrn => nRN );
        p_exception(0, error_text||'%s%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rRow.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.prn)); 
      end;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  END TRANSINVDEPTSPECS_BASE_DELETE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_INSERT
  /*
  Спецификация. Добавить
  */
  (
   rV_ROW   in out v_transinvdeptspecs%rowtype
  ,sMSG     out varchar2
  ) 
  is
  begin
    p_transinvdeptspecs_insert(ncompany         => rV_ROW.NCOMPANY
                              ,nprn             => rV_ROW.NPRN
                              ,sagent           => rV_ROW.SAGENT
                              ,ssernumb         => rV_ROW.SSERNUMB
                              ,scountry         => rV_ROW.SCOUNTRY
                              ,sgtd             => rV_ROW.SGTD
                              ,sgoodsparty      => rV_ROW.SGOODSPARTY
                              ,snomen           => rV_ROW.SNOMEN
                              ,snommodif        => rV_ROW.SNOMMODIF
                              ,snomnmodifpack   => rV_ROW.SNOMNMODIFPACK
                              ,sarticle         => rV_ROW.SARTICLE
                              ,scell            => rV_ROW.SCELL
                              ,ntemperature     => rV_ROW.NTEMPERATURE
                              ,nprice           => rV_ROW.NPRICE
                              ,nquant           => rV_ROW.NQUANT
                              ,nquantalt        => rV_ROW.NQUANTALT
                              ,ncoeff           => rV_ROW.NCOEFF
                              ,ncoeff_val_sign  => rV_ROW.NCOEFF_VAL_SIGN
                              ,ncoeff_calc_sign => rV_ROW.NCOEFF_CALC_SIGN
                              ,npricemeas       => rV_ROW.NPRICEMEAS
                              ,nsummwithnds     => rV_ROW.NSUMMWITHNDS
                              ,dbegindate       => rV_ROW.DBEGINDATE
                              ,denddate         => rV_ROW.DENDDATE
                              ,snote            => rV_ROW.SNOTE
                              ,sbcode           => rV_ROW.SBCODE
                              ,scardnumb        => rV_ROW.SCARDNUMB
                              ,sstrcode         => rV_ROW.SSTRCODE
                              ,ncons_rate       => rV_ROW.NCONS_RATE
                              ,nservlife        => rV_ROW.NSERVLIFE
                              ,srevreas         => rV_ROW.SREVREAS
                              ,sres_comms       => rV_ROW.SRES_COMMS
                              ,nrn              => rV_ROW.NRN 
                              ,smsg             => sMSG);
  end TRANSINVDEPTSPECS_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTSPECS_UPDATE
  /*
  Спецификация. Исправить
  */
  (
   rV_ROW  in v_transinvdeptspecs%rowtype
  ) 
  is
    sVarchar    pkg_std.tstring; 
  begin
    p_transinvdeptspecs_update(nrn              => rV_ROW.nRN
                              ,ncompany         => rV_ROW.nCOMPANY
                              ,sagent           => rV_ROW.sAGENT
                              ,ssernumb         => rV_ROW.sSERNUMB
                              ,scountry         => rV_ROW.sCOUNTRY
                              ,sgtd             => rV_ROW.sGTD
                              ,sgoodsparty      => rV_ROW.sGOODSPARTY
                              ,snomen           => rV_ROW.sNOMEN
                              ,snommodif        => rV_ROW.sNOMMODIF
                              ,snomnmodifpack   => rV_ROW.sNOMNMODIFPACK
                              ,sarticle         => rV_ROW.sARTICLE
                              ,scell            => rV_ROW.sCELL
                              ,ntemperature     => rV_ROW.nTEMPERATURE
                              ,nprice           => rV_ROW.nPRICE
                              ,nquant           => rV_ROW.nQUANT
                              ,nquantalt        => rV_ROW.nQUANTALT
                              ,ncoeff           => rV_ROW.nCOEFF
                              ,ncoeff_val_sign  => rV_ROW.nCOEFF_VAL_SIGN
                              ,ncoeff_calc_sign => rV_ROW.nCOEFF_CALC_SIGN
                              ,npricemeas       => rV_ROW.nPRICEMEAS
                              ,nsummwithnds     => rV_ROW.nSUMMWITHNDS
                              ,dbegindate       => rV_ROW.dBEGINDATE
                              ,denddate         => rV_ROW.dENDDATE
                              ,snote            => rV_ROW.sNOTE
                              ,sbcode           => rV_ROW.sBCODE
                              ,scardnumb        => rV_ROW.sCARDNUMB
                              ,sstrcode         => rV_ROW.SSTRCODE
                              ,ncons_rate       => rV_ROW.NCONS_RATE
                              ,nservlife        => rV_ROW.NSERVLIFE
                              ,srevreas         => rV_ROW.SREVREAS
                              ,sres_comms       => rV_ROW.SRES_COMMS
                              ,smsg             => sVarchar
                              );
  end TRANSINVDEPTSPECS_UPDATE;
  /*#########################################################################################################*/

  function TRANSINVDEPTCLC_GET
  /*
  Калькуляция. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvdeptclc%rowtype
  is
    rRow transinvdeptclc%rowtype;
  begin
    begin
      select * into rRow from transinvdeptclc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'TRANSINVDEPTCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPTCLC')) 
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end TRANSINVDEPTCLC_GET;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_AINSERT
  /*
  Калькуляция. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                transinvdeptclc%rowtype;
    rTransInvDeptSpecs  transinvdeptspecs%rowtype;
    nInOrders           pkg_std.tref; 
  begin
    /* Считывание */
    rRow                := transinvdeptclc_get( nrn => NRN );
    rTransInvDeptSpecs  := transinvdeptspecs_get( nrn => rRow.prn );
    /* Поиск входной связи Пиходный ордер -> Сертификация -> Расходная накладная в подразделение */
    nInOrders := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                               ,sout_unitcode => 'GoodsTransInvoicesToDepts'
                                               ,nout_document => rTransInvDeptSpecs.prn
                                               ,sin_unitcode  => 'IncomingOrders' 
                                               ,srule_chains  => ';GoodsTransInvoicesToDepts<UdoProdCull<IncomingOrders;' );

    /* ПРОВЕРКИ */
    if nInOrders is not null 
    and not usr_pkg_common.is_lists_intersect(slist1 => 'TRANSINVDEPTCLC_AINSERT.1', slist2 => usr_pkg_pub_const.sexceptionlist) then
      p_exception(0, 'Запрещено исправление калькуляций документа, т.к. он создан по данным приходного ордера.%s%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rTransInvDeptSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rTransInvDeptSpecs.prn ) ); 
    end if;
                    
    /* Базовая */
    transinvdeptclc_check_base(nrn => NRN, ncompany => NCOMPANY);

  end TRANSINVDEPTCLC_AINSERT;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_BUPDATE
  /*
  Калькуляция. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                transinvdeptclc%rowtype;
    rTransInvDeptSpecs  transinvdeptspecs%rowtype;
    nInOrders           pkg_std.tref; 
  begin
    /* Считывание */
    rRow                := transinvdeptclc_get( nrn => NRN );
    rTransInvDeptSpecs  := transinvdeptspecs_get( nrn => rRow.prn );
    /* Поиск входной связи Пиходный ордер -> Сертификация -> Расходная накладная в подразделение */
    nInOrders := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                               ,sout_unitcode => 'GoodsTransInvoicesToDepts'
                                               ,nout_document => rTransInvDeptSpecs.prn
                                               ,sin_unitcode  => 'IncomingOrders' 
                                               ,srule_chains  => ';GoodsTransInvoicesToDepts<UdoProdCull<IncomingOrders;' );
    /* ПРОВЕРКИ */
    if nInOrders is not null 
    and not usr_pkg_common.is_lists_intersect(slist1 => 'TRANSINVDEPTCLC_BUPDATE', slist2 => usr_pkg_pub_const.sexceptionlist) then
      p_exception(0, 'Запрещено исправление калькуляций документа, т.к. он создан по данным приходного ордера.%s%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rTransInvDeptSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rTransInvDeptSpecs.prn ) ); 
    end if;
    
  end TRANSINVDEPTCLC_BUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_AUPDATE
  /*
  Калькуляция. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     transinvdeptclc%rowtype;
  begin
    /* Считывание */
    /*rRow := transinvdeptclc_get(nrn => NRN);*/
    null;
  end TRANSINVDEPTCLC_AUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_BDELETE
  /*
  Калькуляция. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                transinvdeptclc%rowtype;
    rTransInvDeptSpecs  transinvdeptspecs%rowtype;
    nInOrders           pkg_std.tref; 
  begin
    /* Считывание */
    rRow                := transinvdeptclc_get( nrn => NRN );
    rTransInvDeptSpecs  := transinvdeptspecs_get( nrn => rRow.prn );
    /* Поиск входной связи Пиходный ордер -> Сертификация -> Расходная накладная в подразделение */
    nInOrders := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                               ,sout_unitcode => 'GoodsTransInvoicesToDepts'
                                               ,nout_document => rTransInvDeptSpecs.prn
                                               ,sin_unitcode  => 'IncomingOrders' 
                                               ,srule_chains  => ';GoodsTransInvoicesToDepts<UdoProdCull<IncomingOrders;' );
    /* ПРОВЕРКИ */
    if nInOrders is not null then
      p_exception(0, 'Запрещено исправление калькуляций документа, т.к. он создан по данным приходного ордера.%s%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDeptsSpecs', ndocument => rTransInvDeptSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rTransInvDeptSpecs.prn ) ); 
    end if;

  end TRANSINVDEPTCLC_BDELETE;
  /*#########################################################################################################*/

  procedure TRANSINVDEPTCLC_CHECK_BASE
  /*
  Калькуляция. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            transinvdeptclc%rowtype;
  begin
    null;
  end TRANSINVDEPTCLC_CHECK_BASE;
  /*#########################################################################################################*/

end USR_PKG_TRANSINVDEPT;
/
