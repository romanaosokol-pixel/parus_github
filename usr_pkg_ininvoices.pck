create or replace package USR_PKG_ININVOICES IS
  /*
  Package предназначен для работы с разделом "Приходные накладные". Степанов М. 12/02/2022
  IncomingInvoices                IIV
  IncomingInvoicesSpecs           IIVS
  IncomingInvoicesSpecsCalcs      IIVSC
  IncomingInvoicesBuff            IIVB
  IncomingInvoicesSpecsBuff       IIVBS
  IncomingInvoicesSpecsCalcsBuff  IIVBSC
  */
  /*#########################################################################################################*/

  function ININVOICES_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ININVOICES%ROWTYPE;
  /*#########################################################################################################*/

  function ININVOICES_GET_SUMM_NOMEN_TYPE
  /*
  Заголовок. Получить сумму документа с налогами по заданному типу номенклатуры. Также дополнительно передаются сумма без НДС и сумма НДС
  */
  (
   nFLAGSMART   in number default 0 
  ,nRN          in number             /* RN заголовка */
  ,nNOMEN_TYPE  in number default 1
  ,nSUMM        out number
  ,nSUMM_NDS    out number
  ) 
  return number;
  /*#########################################################################################################*/

  procedure ININVOICES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_BASFACT
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_AASFACT
  /*
  Заголовок. Проверка после отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_AMAKEINORDERS
  /*
  Заголовок. Проверка после Формирование приходных ордеров
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_BMAKEPAYACCIN
  /*
  Заголовок. Формирование входящих счетов на оплату. Перед
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW    in out v_ininvoices%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure ININVOICES_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_ininvoices%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure ININVOICES_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW    in ininvoices%rowtype
  ,nRN     out number
  );
  /*#########################################################################################################*/

  procedure ININVOICES_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW     in ininvoices%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICES_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  );
  /*#########################################################################################################*/

  procedure ININVOICES_MAKE_INORDERS
  /*
  Заголовок. Формирование приходного ордера
  */
  (
   nRN                in number
  ,nCOMPANY           in number
  ,sSTORE             in varchar2    
  ,nSIGNCURRENCYSTORE in number   default 1
  ,sCURRENCY          in varchar2 default null   
  ,nCURCOURS          in number   default null
  ,nCURBASECOURS      in number   default null
  ,nORDER_TYPE        in number   default 0   
  ,nMODE              in number   default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  FUNCTION ININVOICES_GET_STATUS_NAME
  /*
  Заголовок. Наименование состояния
  */
  (
   nSTATE    in number 
  ) 
  return varchar2;
  /*#########################################################################################################*/

  procedure ININVOICES_RECREATE_IIVSC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  );
  --#########################################################################################################

  procedure ININVOICES_RECALC_BY_SPECS
  /* Процедура пересчета суммы заголовка по данным спецификаций (по мотивам p_ininvoicesspecs_recalc) */
  (
   nRN                in number
  );
  --#########################################################################################################

  /*** процедура пересчета исполнения у родительских документов **
  по мотивам P_ININVOICES_BSET_STATUS */
  procedure ININVOICES_RECALC_PERFORMANCE
  (
    nCOMPANY    in number,
    dWORK_DATE  in date,
    nR_RN       in number, -- RN приходной накладной
    nR_OSTATUS  in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
    nR_NSTATUS  in number  -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
  );
  /*#########################################################################################################*/

  procedure ININVOICES_CLEAR_FOR_UPDATE
  /*
  Заголовок. Очистка перед исправлением и восстановление после очистки
  При очистке удаляются связи, снимается отработка. При восстановлении отрабатывается, восстанавливаются связи 
  Обязательно выполнять в обоих режимах, иначе документ останется неотработанным и без связей
  */
  (
   rROW         in out ininvoices%rowtype
  ,nMODE        in number       /* Режим выполнения: 0 - освободить, 1 - восстановить */
  );
  /*#########################################################################################################*/

  function ININVOICESBUFF_GET
  /*
  Заголовок (буфер). Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoicesbuff%rowtype;
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_UPDATE
  /*
  Заголовок (буфер). Исправление 
  */
  (
   rV_ROW   in v_ininvoicesbuff%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_BASE_INSERT
  /*
  Заголовок (буфер). Добавление базовое
  */
  (
   rROW   in ininvoicesbuff%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW                   in ininvoicesbuff%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  );
  /*#########################################################################################################*/

  function ININVOICESSPECS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ININVOICESSPECS %ROWTYPE;
  /*#########################################################################################################*/
  
  PROCEDURE ININVOICESSPECS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,nTOO_MANY_ROWS     in number default 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,nPRN               in number
  ,nNOMEN             in number default null
  ,nMODIF             in number default null
  ,nPACK              in number default null
  ,nTAXGR             in number default null
  ,nQUANT             in number default null
  ,nQUANTALT          in number default null
  ,nPRICE             in number default null
  ,nARTICLE           in number default null
  ,sSERNUMB           in varchar2 default null
  ,nCOUNTRY           in number   default null
  ,sGTD               in varchar2 default null
  ,dBEGINDATE         in date default null
  ,dENDDATE           in date default null
  ,rROW               out ininvoicesspecs%rowtype 
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_GET_GP
  /*
  Спецификация. Получить RN партии товара
  */
  (
   nFLAG_SMART  in number
  ,nRN          in number
  ,nGP          out number
  );
  /*#########################################################################################################*/

  function ININVOICESSPECS_GET_GP
  /*
  Спецификация. Получить RN партии товара
  */
  (
   nFLAG_SMART  in number
  ,nRN          in number
  ) 
  return number;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_AASFACT
  /*
  Спецификация. Проверка для вызова в проверке после отработки
  */
  (
   rROW              in ininvoicesspecs%rowtype
  ,rININVOICES       in ininvoices%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_IOSC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in ininvoicesspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации входящего счёта
  */
  (
   rROW   in ininvoicesspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_OUT_DOCS
  /*
  Спецификация. Проверка выходных документов
  */
  (
   rROW             ininvoicesspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW                   in ininvoicesspecs%rowtype
  ,nRN                    out number
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW                   in ininvoicesspecs%rowtype
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  ,nOUT_DOC_UPDATE        in number default 0 /* Исправлять выходные документы*/
  ,nMODE                  in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_INSERT
  /*
  Спецификация. Добавление клиентское
  */
  (
   rV_ROW                  in v_ininvoicesspecs%rowtype
  ,nRN                    out number
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_UPDATE
  /*
  Спецификация. Исправление клиентское
  */
  (
   rV_ROW                  in v_ininvoicesspecs%rowtype
  ,nFLAG_DEL_CALC          in number default 0
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_SEPARATION
  /*
  Спецификация. Разбивка на строки с одной штукой
  */
  (
   nRN                in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_SPLIT
  /*
  Спецификация. Отделить от текущей записи с заданным количеством
  */
  (
   nRN                in number
  ,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
  );
  /*#########################################################################################################*/

  function ININVOICESSPBUFF_GET
  /*
  Спецификация (буфер). Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoicesspbuff%rowtype;
  /*#########################################################################################################*/

  procedure ININVOICESSPBUFF_UPDATE
  /*
  Спецификация (буфер). Исправление
  */
  (
   rV_ROW           in v_ininvoicesspbuff%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPBUFF_BASE_INSERT
  /*
  Спецификация (буфер). Добавление базовое
  */
  (
   rROW   in ininvoicesspbuff%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPBUFF_BASE_UPDATE
  /*
  Спецификация (буфер). Исправление базовое
  */
  (
   rROW   in ininvoicesspbuff%rowtype
  ); 
  /*#########################################################################################################*/  

  function ININVOICESSPC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoicesspc%rowtype;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_AINSERT
  /*
  Спецификация (калькуляция). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BUPDATE
  /*
  Спецификация (калькуляция). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BDELETE
  /*
  Спецификация (калькуляция). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое
  */
  (
   rROW   in ininvoicesspc%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое
  */
  (
   rROW   in ininvoicesspc%rowtype
  );
  /*#########################################################################################################*/

end USR_PKG_ININVOICES;

/*
CREATE PUBLIC SYNONYM USR_PKG_ININVOICES FOR USR_PKG_ININVOICES;
GRANT EXECUTE ON USR_PKG_ININVOICES TO PUBLIC;
*/
/
create or replace package body USR_PKG_ININVOICES is

  /*#########################################################################################################*/

  function ININVOICES_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN        in number -- RN записи
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoices%rowtype
  is
    rRow ininvoices%rowtype;
  begin
    begin
      select * into rRow from ininvoices where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ININVOICES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICES'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end ININVOICES_GET;
  /*#########################################################################################################*/

  function ININVOICES_GET_SUMM_NOMEN_TYPE
  /*
  Заголовок. Получить сумму документа с налогами по заданному типу номенклатуры. Также дополнительно передаются сумма без НДС и сумма НДС
  */
  (
   nFLAGSMART   in number default 0 
  ,nRN          in number             /* RN заголовка */
  ,nNOMEN_TYPE  in number default 1
  ,nSUMM        out number
  ,nSUMM_NDS    out number
  ) 
  return number
  is
    nSummTax  pkg_std.tsumm; 
  begin
    begin
      select sum( t.summtax ), sum( t.summ ), sum( t.summ_nds )
        into nSummTax        , nSUMM        , nSUMM_NDS
        from ininvoicesspecs  t
            ,dicnomns         dnm
       where t.prn          = nRN
         and dnm.rn         = t.nomen 
         and dnm.nomen_type = nNOMEN_TYPE;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ININVOICES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICES'))
                   ,cr||sqlerrm);
    end;

    return( nSummTax );

  end ININVOICES_GET_SUMM_NOMEN_TYPE;
  /*#########################################################################################################*/

  procedure ININVOICES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          ininvoices%rowtype;
    nPers_Agent   pkg_std.tref; 
    sNumbMax      pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := ininvoices_get(nrn => nRN);

    /* ИСПРАВЛЕНИЕ */
    /* Если не задан ответственный за оформление */
    if rRow.reg_agent is null then
      /* контрагент текущего пользователя */
      find_clnpersons_authid_ex(ncompany     => rRow.company
                               ,ddate        => current_date
                               ,spers_authid => utilizer
                               ,npers_agent  => nPers_Agent);
      rRow.reg_agent := nPers_Agent;
      /* исправление */
      ininvoices_base_update(rrow => rRow);
    end if;
    
    /* ПРОВЕРКИ */
    /* Базовая */
    ininvoices_check_base(nRN, nCOMPANY);

    /* Префикс-номер */
    /* считывание максимального номера */
    begin
      select trim(max(t.numb))
        into sNumbMax
        from ininvoices t
       where t.doctype = rRow.doctype
         and cmp_vc2(t.pref, rRow.pref) = 1
         and t.rn     != rRow.rn;
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при определении максимального номера документа. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    end;
    /* прибавляем единицу к максимальному номеру */
    sNumbMax := NVL(S2N(sNumbMax), 0) + 1;
    /* проверка реквизитов */
    usr_pkg_document.check_pref_numb(spref    => rRow.pref
                                    ,snumb    => rRow.numb
                                    ,ddate    => rRow.doc_date
                                    ,snumbmax => sNumbMax);

    /* По спецификациям */
    for c in (select * from ininvoicesspecs where prn = nRN) 
    loop
      /* проверка спецификации */
      ininvoicesspecs_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;

  end ININVOICES_AINSERT;
  /*#########################################################################################################*/

  procedure ININVOICES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /*null;*/
    /* Считывание */
     usr_pkg_pub_const.rininvoices := ININVOICES_GET(nrn => nRN); 

  end ININVOICES_BUPDATE;
  /*#########################################################################################################*/

  procedure ININVOICES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     ininvoices%rowtype;
  begin
    /* Считывание */
    rRow := ininvoices_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая*/
    ininvoices_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Если изменились реквизиты */
    if pkg_flag.get_flag = 0 --and utilizer != 'KHOK'
    and ( rRow.doctype != nvl(usr_pkg_pub_const.rininvoices.doctype, 0) 
        or cmp_vc2(rRow.pref    , usr_pkg_pub_const.rininvoices.pref    ) != 1
        or cmp_vc2(rRow.numb    , usr_pkg_pub_const.rininvoices.numb    ) != 1
        or cmp_dat(rRow.doc_date, usr_pkg_pub_const.rininvoices.doc_date) != 1 
        ) then
     p_exception(0, 'Запрещено изменять поля: Тип, Префикс, Номер, Дата. ' || cr || 'До исправления: %s' || cr ||'После исправления: %s. %s'
                ,cr || pkg_document.make_number(ndoc_type => usr_pkg_pub_const.rininvoices.doctype 
                                               ,sdoc_pref => usr_pkg_pub_const.rininvoices.pref    
                                               ,sdoc_numb => usr_pkg_pub_const.rininvoices.numb    
                                               ,ddoc_date => usr_pkg_pub_const.rininvoices.doc_date)
                ,cr || pkg_document.make_number(ndoc_type => rRow.doctype 
                                               ,sdoc_pref => rRow.pref    
                                               ,sdoc_numb => rRow.numb    
                                               ,ddoc_date => rRow.doc_date)
                ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    end if;

  end ININVOICES_AUPDATE;
  /*#########################################################################################################*/

  procedure ININVOICES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end ININVOICES_BDELETE;
  /*#########################################################################################################*/

  procedure ININVOICES_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     ininvoices%rowtype;
  begin
    -- ИСПРАВЛЕНИЯ

    -- ПРОВЕРКИ
    -- Заголовок  
    rRow := ININVOICES_GET(nRN);

    -- Запрет отработки как план
    if rRow.status = 1 then
      P_EXCEPTION(0, 'Запрещено отрабатывать документ как план %s.'||CR||'%s'
                 ,F_DOCDESCRS_GET_DESCRIPTION('IncomingInvoices', rRow.rn)
                 ); 
    end if;

  end ININVOICES_AASPLAN;
  /*#########################################################################################################*/

  procedure ININVOICES_BASFACT
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
  
  end ININVOICES_BASFACT;
  /*#########################################################################################################*/

  procedure ININVOICES_AASFACT
  /*
  Заголовок. Проверка после отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          ininvoices%rowtype;
    
    sVarchar      pkg_std.tstring; 
  begin
    -- ИСПРАВЛЕНИЯ

    -- ПРОВЕРКИ
    -- Базовая
    ininvoices_check_base(nrn => nRN, ncompany => nCOMPANY);

    -- Заголовок  
    rRow := ininvoices_get(nrn => nRN);

    -- Дата отработки равна дате документа
    if cmp_dat(rRow.work_date, rRow.doc_date) != 1 then
      p_exception(0, 'Дата отработки %s не равна дате документа %s.%s'
                 ,d2s(rRow.work_date)
                 ,d2s(rRow.doc_date)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    /* Дата отработки больше текущей даты */
    elsif cmp_dat_minmax( rRow.work_date, sysdate ) > 0 then
      p_exception(0, 'Дата отработки %s больше текущей даты %s.'||cr||'%s'
                 ,d2s( rRow.work_date )
                 ,d2s( sysdate )
                 ,f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn) ); 
    end if;

    /* По спецификациям */
    for c in (select * from ininvoicesspecs where prn = rRow.rn)
    loop
      /* проверка после отработки */
      ininvoicesspecs_aasfact( rROW => c, rININVOICES => rRow );

      /* По калькуляциям */
      for c1 in ( select * from ininvoicesspc where prn = c.rn )
      loop
        /* проверка базовая */
        ininvoicesspc_check_base( nRN => c1.rn, ncompany => c1.company );
      end loop;

    end loop;

  end ININVOICES_AASFACT;
  /*#########################################################################################################*/

  procedure ININVOICES_AMAKEINORDERS
  /*
  Заголовок. Проверка после Формирование приходных ордеров
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Копирование буфера документов во временную таблицу */
    delete from usr_t_inhierbuff_common;
    insert into usr_t_inhierbuff_common ( select * from inhierbuff_common )  ;
    
    /* По заголовкам сформированных документов */
    for c in (select distinct out_document0 from usr_t_inhierbuff_common ) 
    loop
      /* проверка заголовка */
      usr_pkg_inorders.inorders_ainsert( nrn => c.out_document0, ncompany => nCOMPANY );
    end loop;

  end ININVOICES_AMAKEINORDERS;
  /*#########################################################################################################*/

  procedure ININVOICES_BMAKEPAYACCIN
  /*
  Заголовок. Формирование входящих счетов на оплату. Перед
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Запрет */
    p_exception(0, 'Запрещено формирование входящих счетов из приходных ордеров.%s'
               ,cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoices', ndocument => nRN ) ); 

  end ININVOICES_BMAKEPAYACCIN;
  /*#########################################################################################################*/

  procedure ININVOICES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        ininvoices%rowtype;
    nPayAccIn   pkg_std.tref; 
    rPayAccIn   payaccin%rowtype;
  begin
    /* Заголовок  */
    rRow := Ininvoices_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */


    /* ПРОВЕРКИ */
    /* Параметр "Цены включают налоги" */  
    if rRow.signtax = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" должен быть заполнен. Для исправления выполните процедуру <Исправить признак "Цены включают налоги">. %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    end if;

    /* Склад ВремПеремещение */  
    if rRow.store = 20300310 then
      p_exception(0, 'Запрещено указывать склад <%s>. %s'
                 ,cr||cr||f_dicstore_get_numb(nstore => rRow.store)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
    end if;

    /* Связанный входящий счёт на оплату. Любой */
    nPayAccIn := f_doclinks_link_in_doc(sout_unitcode => 'IncomingInvoices', nout_document => rRow.rn, sin_unitcode  => 'PaymentAccountsIn'); 
    if nPayAccIn is not null then
      rPayAccIn := usr_pkg_payaccin.payaccin_get(nrn => nPayAccIn);
    end if;

    /* Каталог 'Метрология' */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => usr_pkg_pub_const.niiv_cat_mtlg) then
      /* каталог входного документа НЕ 'Метрология' и документ существует  */
      if  not usr_pkg_common.is_crn_in_hiercrn(nCRN => rPayAccIn.crn, shier_crn_list => usr_pkg_pub_const.npai_cat_mtlg)
      and rPayAccIn.rn is not null then
        p_exception(0, 'Каталог документа <%s> не равен каталогу входного документа <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rPayAccIn.crn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
      end if;
    /* Каталог НЕ 'Отдел метрологии' */
    else      
      /* каталог входного документа 'Метрология' и документа существует*/
      if  usr_pkg_common.is_crn_in_hiercrn(nCRN => rPayAccIn.crn, shier_crn_list => usr_pkg_pub_const.npai_cat_mtlg)
      and rPayAccIn.rn is not null then
        p_exception(0, 'Каталог документа <%s> не равен каталогу входного документа <%s>. %s'
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                   ,get_acatalog_name_id(nflag_smart => 0, nrn => rPayAccIn.crn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
      end if;
    end if;
    
  end ININVOICES_CHECK_BASE;
  /*#########################################################################################################*/

  procedure ININVOICES_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW    in out v_ininvoices%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    p_ininvoices_insert(ncompany       => rV_ROW.NCOMPANY
                       ,ncrn           => rV_ROW.NCRN
                       ,sjur_pers      => rV_ROW.SJUR_PERS
                       ,sdoctype       => rV_ROW.SDOCTYPE
                       ,spref          => rV_ROW.SPREF
                       ,snumb          => rV_ROW.SNUMB
                       ,ddoc_date      => rV_ROW.DDOC_DATE
                       ,nservact_sign  => rV_ROW.NSERVACT_SIGN
                       ,sext_numb      => rV_ROW.SEXT_NUMB
                       ,dext_date      => rV_ROW.DEXT_DATE
                       ,svalid_doctype => rV_ROW.SVALID_DOCTYPE
                       ,svalid_docnumb => rV_ROW.SVALID_DOCNUMB
                       ,dvalid_docdate => rV_ROW.DVALID_DOCDATE
                       ,sstore         => rV_ROW.SSTORE
                       ,sparty         => rV_ROW.SPARTY
                       ,sfaceacc       => rV_ROW.SFACEACC
                       ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                       ,sagent         => rV_ROW.SAGENT
                       ,scurrency      => rV_ROW.SCURRENCY
                       ,sstoreoper     => rV_ROW.SSTOREOPER
                       ,ncurcours      => rV_ROW.NCURCOURS
                       ,ncurbasecours  => rV_ROW.NCURBASECOURS
                       ,nsigntax       => rV_ROW.NSIGNTAX
                       ,snote          => rV_ROW.SNOTE
                       ,nfa_cours      => rV_ROW.NFA_COURS
                       ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                       ,sagnfifo       => rV_ROW.SAGNFIFO
                       ,ndiscount      => rV_ROW.NDISCOUNT
                       ,sbarcode       => rV_ROW.SBARCODE
                       ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                       ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                       ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                       ,sreg_agent     => rV_ROW.SREG_AGENT
                       ,nrn            => rV_ROW.NRN);
  end ININVOICES_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICES_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_ininvoices%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_InInvoices   v_ininvoices%rowtype := rV_ROW;
    rInInvoices     ininvoices%rowtype;

  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_ininvoices_update(ncompany       => rV_ROW.NCOMPANY
                         ,nrn            => rV_ROW.NRN
                         ,sjur_pers      => rV_ROW.SJUR_PERS
                         ,sdoctype       => rV_ROW.SDOCTYPE
                         ,spref          => rV_ROW.SPREF
                         ,snumb          => rV_ROW.SNUMB
                         ,ddoc_date      => rV_ROW.DDOC_DATE
                         ,nservact_sign  => rV_ROW.NSERVACT_SIGN
                         ,sext_numb      => rV_ROW.SEXT_NUMB
                         ,dext_date      => rV_ROW.DEXT_DATE
                         ,svalid_doctype => rV_ROW.SVALID_DOCTYPE
                         ,svalid_docnumb => rV_ROW.SVALID_DOCNUMB
                         ,dvalid_docdate => rV_ROW.DVALID_DOCDATE
                         ,sstore         => rV_ROW.SSTORE
                         ,sparty         => rV_ROW.SPARTY
                         ,sfaceacc       => rV_ROW.SFACEACC
                         ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                         ,sagent         => rV_ROW.SAGENT
                         ,scurrency      => rV_ROW.SCURRENCY
                         ,sstoreoper     => rV_ROW.SSTOREOPER
                         ,ncurcours      => rV_ROW.NCURCOURS
                         ,ncurbasecours  => rV_ROW.NCURBASECOURS
                         ,nsigntax       => rV_ROW.NSIGNTAX
                         ,snote          => rV_ROW.SNOTE
                         ,nfa_cours      => rV_ROW.NFA_COURS
                         ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                         ,sagnfifo       => rV_ROW.SAGNFIFO
                         ,ndiscount      => rV_ROW.NDISCOUNT
                         ,sbarcode       => rV_ROW.SBARCODE
                         ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                         ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                         ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                         ,sreg_agent     => rV_ROW.SREG_AGENT);

    /* Режим выполнения: 1 - пользовательский. 
       Если документ отработан, нимает отработку, исправляет, повторно отрабатывает. Иначе просто исправляет */
    elsif nMODE = 1 then

      /* Считывание заголовка для очистки */
      rInInvoices := ininvoices_get( nrn => rV_InInvoices.nrn );

      /* Если документ НЕ не отработан */
      if rV_InInvoices.nstatus != 0 then

        /* Очистка перед исправлением */
        usr_pkg_ininvoices.ininvoices_clear_for_update( rrow => rInInvoices, nmode => 0 );

        /* Исправление штатное */
        ininvoices_update(rv_row => rV_InInvoices, nmode => 0);

        /* Восстановление после очистки */
        usr_pkg_ininvoices.ininvoices_clear_for_update( rrow => rInInvoices, nmode => 1 );

      /* Если документ не отработан */
      else
        /* Исправление штатное */
        ininvoices_update( rv_row => rV_InInvoices, nmode => 0 );
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end ININVOICES_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICES_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW    in ininvoices%rowtype
  ,nRN     out number
  ) 
  is
  begin
    p_ininvoices_base_insert(ncompany       => rROW.COMPANY
                            ,ncrn           => rROW.CRN
                            ,njur_pers      => rROW.JUR_PERS
                            ,ndoctype       => rROW.DOCTYPE
                            ,spref          => rROW.PREF
                            ,snumb          => rROW.NUMB
                            ,ddoc_date      => rROW.DOC_DATE
                            ,nservact_sign  => rROW.SERVACT_SIGN
                            ,sext_numb      => rROW.EXT_NUMB
                            ,dext_date      => rROW.EXT_DATE
                            ,nvalid_doctype => rROW.VALID_DOCTYPE
                            ,svalid_docnumb => rROW.VALID_DOCNUMB
                            ,dvalid_docdate => rROW.VALID_DOCDATE
                            ,nstore         => rROW.STORE
                            ,sparty         => rROW.PARTY
                            ,nfaceacc       => rROW.FACEACC
                            ,ngraphpoint    => rROW.GRAPHPOINT
                            ,nagent         => rROW.AGENT
                            ,ncurrency      => rROW.CURRENCY
                            ,nstoreoper     => rROW.STOREOPER
                            ,ncurcours      => rROW.CURCOURS
                            ,ncurbasecours  => rROW.CURBASECOURS
                            ,nsigntax       => rROW.SIGNTAX
                            ,snote          => rROW.NOTE
                            ,nfa_cours      => rROW.FA_COURS
                            ,nfa_basecours  => rROW.FA_BASECOURS
                            ,nagnfifo       => rROW.AGNFIFO
                            ,ndiscount      => rROW.DISCOUNT
                            ,sbarcode       => rROW.BARCODE
                            ,npayconf_type  => rROW.PAYCONF_TYPE
                            ,spayconf_numb  => rROW.PAYCONF_NUMB
                            ,dpayconf_date  => rROW.PAYCONF_DATE
                            ,nreg_agent     => rROW.REG_AGENT
                            ,nrn            => nRN);
  end ININVOICES_BASE_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICES_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW    in ininvoices%rowtype
  ) 
  is
  begin
    P_ININVOICES_BASE_UPDATE(nRN            => rROW.RN
                            ,nCOMPANY       => rROW.COMPANY
                            ,nJUR_PERS      => rROW.JUR_PERS
                            ,nDOCTYPE       => rROW.DOCTYPE
                            ,sPREF          => rROW.PREF
                            ,sNUMB          => rROW.NUMB
                            ,dDOC_DATE      => rROW.DOC_DATE
                            ,nSERVACT_SIGN  => rROW.SERVACT_SIGN
                            ,sEXT_NUMB      => rROW.EXT_NUMB
                            ,dEXT_DATE      => rROW.EXT_DATE
                            ,nVALID_DOCTYPE => rROW.VALID_DOCTYPE
                            ,sVALID_DOCNUMB => rROW.VALID_DOCNUMB
                            ,dVALID_DOCDATE => rROW.VALID_DOCDATE
                            ,nSTORE         => rROW.STORE
                            ,nPARTY_RN      => rROW.PARTY_RN
                            ,sPARTY         => rROW.PARTY
                            ,nFACEACC       => rROW.FACEACC
                            ,nGRAPHPOINT    => rROW.GRAPHPOINT
                            ,nAGENT         => rROW.AGENT
                            ,nCURRENCY      => rROW.CURRENCY
                            ,nSTOREOPER     => rROW.STOREOPER
                            ,nCURCOURS      => rROW.CURCOURS
                            ,nCURBASECOURS  => rROW.CURBASECOURS
                            ,nSIGNTAX       => rROW.SIGNTAX
                            ,sNOTE          => rROW.NOTE
                            ,nFA_COURS      => rROW.FA_COURS
                            ,nFA_BASECOURS  => rROW.FA_BASECOURS
                            ,nAGNFIFO       => rROW.AGNFIFO
                            ,nDISCOUNT      => rROW.DISCOUNT
                            ,sBARCODE       => rROW.BARCODE
                            ,nPAYCONF_TYPE  => rROW.PAYCONF_TYPE
                            ,sPAYCONF_NUMB  => rROW.PAYCONF_NUMB
                            ,dPAYCONF_DATE  => rROW.PAYCONF_DATE
                            ,nREG_AGENT     => rROW.REG_AGENT);

  end ININVOICES_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICES_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  ) 
  is
    rRow        ininvoices%rowtype;
    rSpec       ininvoicesspecs%rowtype;
    nNumber     pkg_std.tnumber; 
  begin
    /* Заголовок  */
    rRow := ININVOICES_GET(nRN);
    
    /* Проверка параметров*/    
    /* Не задан */
    if nSIGNTAX is null then
      p_exception(0, 'Не задан параметр процедуры "Цены включают налоги". %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    elsif nSIGNTAX not in (0, 1) then
      p_exception(0, 'Неверное значение: "%s" параметра процедуры "Цены включают налоги". %s'
                 ,nSIGNTAX
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    end if;
    /* Имеет такое же значение, как в документе */
    if ( rRow.signtax = nSIGNTAX and nSIGNTAX is not null )
    and nFLAGSMART = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.signtax when 0 then 'Нет' else 'Да' end
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.rn)); 
    end if;
      
    /* Исправление заголовка */
    rRow.signtax := nSIGNTAX;
    ininvoices_base_update(rrow => rRow);

    /* По спецификациям */
    for c in (select * from ininvoicesspecs where prn = rRow.rn)
    loop
      /* Сохранение записи в переменную */
      rSpec := c;
      /* Расчёт сумм */
      pkg_dictaxis_calc.p_calculate_base
      (
       nflag_smart => 0
      ,ncompany    => rRow.company
      ,ddate       => rRow.doc_date
      ,nsumm_sign  => nSIGNTAX
      ,ninsumm     => case nSIGNTAX when 0 then rSpec.summ else rSpec.summtax end 
      ,ntaxgr      => rSpec.taxgr
      ,nquant      => rSpec.quant
      ,nncp_sign   => 1
      );
      /* Сохранение сумм в переменную */
      rSpec.summ     := PKG_DICTAXIS_CALC.F_GET_VALUE(0); /* Сумма без налогов (0) */
      rSpec.summtax  := PKG_DICTAXIS_CALC.F_GET_VALUE(2); /* Сумма со всеми налогами (2) */
      rSpec.summ_nds := PKG_DICTAXIS_CALC.F_GET_VALUE(8); /* НДС (8) */
      rSpec.price    := case nSIGNTAX when 0 then rSpec.summ else rSpec.summtax end / rSpec.quant; /* Цена */
      /* Исправление спецификации */
      ININVOICESSPECS_BASE_UPDATE(RROW => rSpec, NSUMM_ININVOICES => nNumber, NSUMMTAX_ININVOICES => nNumber);
    end loop;

  end ININVOICES_UPDATE_SIGNTAX;
  /*#########################################################################################################*/

  procedure ININVOICES_MAKE_INORDERS
  /*
  Заголовок. Формирование приходного ордера
  */
  (
   nRN                in number
  ,nCOMPANY           in number
  ,sSTORE             in varchar2    
  ,nSIGNCURRENCYSTORE in number   default 1
  ,sCURRENCY          in varchar2 default null   
  ,nCURCOURS          in number   default null
  ,nCURBASECOURS      in number   default null
  ,nORDER_TYPE        in number   default 0   
  ,nMODE              in number   default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  is
    nNumber   pkg_std.tnumber;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      /* Формирование буфера */
      p_ininvoices_create_inorder(nrn                => nRN
                                 ,ncompany           => nCOMPANY
                                 ,sstore             => sSTORE
                                 ,nsigncurrencystore => 1
                                 ,scurrency          => null
                                 ,ncurcours          => null
                                 ,ncurbasecours      => null
                                 ,norder_type        => 0            -- тип ордера (0 - Приходный ордер, 1 - Акт приёмки товаров, работ, услуг)
                                 ,nident             => nRN
                                 ,ncount             => nNumber );
      /* Исправление параметра Цены включают налоги */
      for c in (select * from inordspbuff where ident = nRN and price_calc_rule != 1)
      loop
        usr_pkg_inorders.inordspbuff_update_pcr( nflagsmart => 1, nrn => c.rn, nprice_calc_rule => 1 );
      end loop;

      /* Перенос буфера */
      p_inordersbuff_makedoc( ncompany => nCOMPANY, nident => nRN );

      /* Очистка буфера */
      p_inordersbuff_pack( nident => nRN );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* Формирование буфера */
      usr_p_iiv_create_inorder( nrn         => nRN
                               ,nident      => nRN
                               ,sstore      => sSTORE
                               ,norder_type => nORDER_TYPE );
      /* Исправление параметра Цены включают налоги */
      for c in (select * from inordspbuff where ident = nRN and price_calc_rule != 1)
      loop
        usr_pkg_inorders.inordspbuff_update_pcr( nflagsmart => 1, nrn => c.rn, nprice_calc_rule => 1 );
      end loop;

      /* Перенос буфера */
      usr_p_inordersbuff_makedoc( ncompany => nCOMPANY, nident => nRN );

      /* Очистка буфера */
      p_inordersbuff_pack( nident => nRN );

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end ININVOICES_MAKE_INORDERS;
  /*#########################################################################################################*/

  FUNCTION ININVOICES_GET_STATUS_NAME
  /*
  Заголовок. Наименование состояния
  */
  (
   nSTATE    in number 
  ) 
  return varchar2
  is
  begin
    return(case nSTATE
             when 0 then 'Не отработан'
             when 1 then 'Отработан как план'
             when 2 then 'Отработан как факт' 
             else null
           end);
  END ININVOICES_GET_STATUS_NAME;
  /*#########################################################################################################*/

  procedure ININVOICES_RECREATE_IIVSC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  ) 
  is
    rRow                  ininvoices%rowtype;
    nINDH                 pkg_std.tref;           /* входной документ. Заголовок. RN */
    rINDS                 payaccinspec%rowtype;   /* входной документ. Спецификация. Запись */
    nINDC_CURC_Quant      pkg_std.tnumber;        /* распределённое количество калькуляции входного документа */
    nINDC_CURC_QuantRest  pkg_std.tnumber;        /* нераспределённое количество калькуляции входного документа */
    nCURS_QuantRest       pkg_std.tnumber;        /* нераспределённое количество калькуляции текущего документа */
    nQuant                pkg_std.tnumber;        /* количество для распределения */
    rCURC                 ininvoicesspc%rowtype;  /* калькуляция текущего документа. Запись */
    rDicNomns             dicnomns%rowtype;
    rDicMUnts             dicmunts%rowtype;
    
    nNumber           pkg_std.tnumber; 
  begin
    /* Заголовок  */
    rRow := ininvoices_get(nrn => nRN);

    /* Удаление калькуляций во всех спецификациях текущего документа */
    for c in (select rn, company from ininvoicesspc where prn in (select rn from ininvoicesspecs where prn =  nRN))
    loop
      p_ininvoicesspc_base_delete(nrn => c.rn, ncompany => c.company);
    end loop;
    
    /* По спецификациям текущего документа */
    for sp in (select * from ininvoicesspecs where prn =  nRN)
    loop
      /* Считывание номенклатуры и единицы измерения */
      rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => sp.nomen );
      rDicMUnts := udo_pkg_get.row_dicmunts( nrn => rDicNomns.umeas_main );

      /* Поиск заголовка входного документа */
      nINDH := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                    ,sout_unitcode  => 'IncomingInvoices'
                                                    ,nout_document  => sp.prn
                                                    ,sin_unitcode   => 'PaymentAccountsIn');
      /* поиск аналогичной спецификации входного документа */
      usr_pkg_payaccin.payaccinspec_get_by_params(nprn          => nINDH
                                                 ,nnommodif     => sp.modif
                                                 ,nnommodifpack => sp.pack
                                                 ,narticle      => sp.article
                                                 ,rrow          => rINDS);

      /* Нераспределённое количество калькуляции текущего документа = количество по спецификации текущего документа */
      nCURS_QuantRest := sp.quant;

      /* По калькуляциям спецификации входного документа с сортировкой по номеру ЛС */
      for c in (select t.*
                  from payaccinspclc t, faceacc fa
                 where t.prn         = rINDS.rn
                   and t.faceaccount = fa.rn
                order by fa.numb)
      loop
        /* распределённое количество калькуляции входного документа */
        usr_pkg_payaccin.payaccinspclc_get_iivsc_quant(nrn         => c.rn
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
          nQuant          := nCURS_QuantRest;
          /* пересчитываем Нераспределённое количество калькуляции текущего документа */
          nCURS_QuantRest := nCURS_QuantRest - nQuant;
        end if;
         /* если есть количество для распределения */
        if nQuant != 0 then 
          /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
          if rDicMUnts.meas_type = 1 then
            nQuant := round( nQuant );
          end if;
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
          /*rCURC.quant_fact   := nQuant;*/
          rCURC.subdiv       := c.subdiv;
          /* добавление калькуляции текущего документа*/
          ininvoicesspc_base_insert(rrow => rCURC, nrn => nNumber);
        end if;
      end loop;
    end loop;
  end ININVOICES_RECREATE_IIVSC;
  --#########################################################################################################

  procedure ININVOICES_RECALC_BY_SPECS
  /* Процедура пересчета суммы заголовка по данным спецификаций (по мотивам p_ininvoicesspecs_recalc) */
  (
   nRN                in number
  )
  is
    rRow              ininvoices%rowtype;
    nNumber           pkg_std.tnumber; 
  begin
    /* Заголовок */
    rRow := ininvoices_get( nrn => nRN );

    /* По спецификациям с расчётом сумм */
    for c in ( select sum( summ ) as summ, sum( summtax ) as summtax from ininvoicesspecs where prn = rRow.rn )
    loop           
      /* Исправление */
      p_ininvoicesspecs_recalc( nprn                => rRow.rn
                               ,nsumm               => c.summ    - rRow.summ
                               ,nsummtax            => c.summtax - rRow.summtax
                               ,nsumm_ininvoices    => nNumber
                               ,nsummtax_ininvoices => nNumber );
    end loop;                          
    
  end ININVOICES_RECALC_BY_SPECS;
  --#########################################################################################################

  /*** процедура пересчета исполнения у родительских документов **
  по мотивам P_ININVOICES_BSET_STATUS */
  procedure ININVOICES_RECALC_PERFORMANCE
  (
    nCOMPANY    in number,
    dWORK_DATE  in date,
    nR_RN       in number, -- RN приходной накладной
    nR_OSTATUS  in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
    nR_NSTATUS  in number  -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
  )
  is
    nR_IDENT    PKG_STD.tNUMBER;  -- идентификатор процесса отражения.
    nR_ORDER    PKG_STD.tREF;     -- RN периода исполнения заказа поставщику
    nR_PACCIN   PKG_STD.tREF;     -- RN входящего счета на оплату
    nPLAN_SIGN  PKG_STD.tNUMBER;  -- знак суммирования плана (-1,0,1)
    nFACT_SIGN  PKG_STD.tNUMBER;  -- знак суммирования факта (-1,0,1)

    /* отражение в калькуляции при отражении исполнения */
    bCLC_PERF   boolean := ( nR_OSTATUS = 2 ) or ( nR_NSTATUS = 2 );
    /* идентификатор записей соответствия исходных и отражаемых товарных позиций в SELECTLIST */
    nIDENT_SL   PKG_STD.tNUMBER;
  begin
    if ( bCLC_PERF ) then
      nIDENT_SL := GEN_IDENT;
    end if;

    /* инициализация пакета расчета исполнения товарных позиций */
    PKG_GOODSDOCS_PERF_CRM.INIT( nCOMPANY, nR_IDENT, nIDENT_SL );
    /* поиск родительского заказа поставщикам (работа идет с конкретным периодом, связь ищем только по указанным цепочкам) */
    nR_ORDER := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nR_IDENT, 'IncomingInvoices', nR_RN, 'DeliveryOrdersPerform', null,
                                                        ';IncomingInvoices<DeliveryOrdersPerform;'||
                                                        'IncomingInvoices<PaymentAccountsIn<DeliveryOrdersPerform;' );
    /* поиск родительского входящего счета на оплату (связь ищем только по указанным цепочкам) */
    nR_PACCIN := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nR_IDENT, 'IncomingInvoices', nR_RN, 'PaymentAccountsIn', null,
                                                         ';IncomingInvoices<PaymentAccountsIn;' );
    /* если нет ни одного родительского документа - выходим */
    if ( nR_ORDER is null ) and ( nR_PACCIN is null ) then
      return;
    end if;

    /* выставим знаки суммирования плана и факта */
    nPLAN_SIGN := 0;
    nFACT_SIGN := 0;
    if    ( nR_OSTATUS = 0 ) then -- был не отработан
      if    ( nR_NSTATUS = 1 ) then -- будет планом
        nPLAN_SIGN := 1;
        nFACT_SIGN := 0;
      elsif ( nR_NSTATUS = 2 ) then -- будет фактом
        nPLAN_SIGN := 1;
        nFACT_SIGN := 1;
      else
        return;
      end if; -- на всякий случай
    elsif ( nR_OSTATUS = 1 ) then -- был планом
      if    ( nR_NSTATUS = 0 ) then -- будет не отработан
        nPLAN_SIGN := -1;
        nFACT_SIGN := 0;
      elsif ( nR_NSTATUS = 2 ) then -- будет фактом
        nPLAN_SIGN := 0;
        nFACT_SIGN := 1;
      else
        return;
      end if; -- на всякий случай
    elsif ( nR_OSTATUS = 2 ) then -- был фактом
      if    ( nR_NSTATUS = 0 ) then -- будет не отработан
        nPLAN_SIGN := -1;
        nFACT_SIGN := -1;
      elsif ( nR_NSTATUS = 1 ) then -- будет планом
        nPLAN_SIGN := 0;
        nFACT_SIGN := -1;
      else
        return;
      end if; -- на всякий случай
    end if;

    /* отражение исполнения по спецификациям приходной накладной */
    for INIS in ( select I.CURRENCY, I.CURCOURS, I.CURBASECOURS,
                         F.CURRENCY FA_CURRENCY, I.FA_BASECOURS, I.FA_COURS,
                         S.NOMEN, S.MODIF, S.PACK, S.ARTICLE,
                         nvl(S.STORE, I.STORE) STORE, S.SERNUMB, S.COUNTRY, S.GTD,
                         S.QUANT, S.QUANTALT, S.SUMMTAX,
                         S.RN
                    from ININVOICES      I,
                         ININVOICESSPECS S,
                         FACEACC         F
                   where I.RN      = nR_RN
                     and I.RN      = S.PRN
                     and I.FACEACC = F.RN )
    loop
      /* суммирование исполнения */
      PKG_GOODSDOCS_PERF_CRM.SET_PERF( nR_IDENT, 1/*SIGN_PACK*/,
                                       null/*NOMENCLS*/, null/*UMEAS_MAIN*/,
                                       INIS.NOMEN, null/*NOMNPACK*/, INIS.MODIF, INIS.PACK, INIS.ARTICLE,
                                       INIS.STORE, null/*GOODSPARTY*/, INIS.SERNUMB, INIS.COUNTRY, INIS.GTD,
                                       INIS.QUANT, INIS.QUANTALT,
                                       INIS.QUANT, INIS.QUANTALT,
                                       0/*nRTN_PLANM_QUANT*/, 0/*nRTN_PLANA_QUANT*/,
                                       0/*nRTN_FACTM_QUANT*/, 0/*nRTN_FACTA_QUANT*/,
                                       INIS.SUMMTAX, INIS.SUMMTAX,
                                       nPLAN_SIGN, nFACT_SIGN,
                                       0/*nRTN_PLAN_SIGN*/, 0/*nRTN_FACT_SIGN*/,
                                       INIS.CURRENCY, INIS.CURCOURS, INIS.CURBASECOURS,
                                       -- 04/03/2025 Марков МВ. перепутали курсы местами. INIS.FA_CURRENCY, INIS.FA_BASECOURS, INIS.FA_COURS, dWORK_DATE,
                                       INIS.FA_CURRENCY, INIS.FA_COURS, INIS.FA_BASECOURS, dWORK_DATE,
                                       INIS.RN, 'IncomingInvoicesSpecs' );
    end loop;

    /* сохранение рассчитаного исполнения в родительских документах */
    PKG_GOODSDOCS_PERF_CRM.SAVE_PARENT( nR_IDENT );

    if ( bCLC_PERF ) then
      /* отражение в калькуляции при отражении исполнения */
      if ( PKG_OBJECT_DESC.EXISTS_PROCEDURE('P_ININVOICESSPC_SET_PERF') > 0 ) then
        execute immediate PKG_SQL_CALL.MAKE_STORED('P_ININVOICESSPC_SET_PERF')
        using in nCOMPANY,
              in nIDENT_SL,
              in nR_NSTATUS;
      end if;

      /* очистка SELECTLIST */
      P_SELECTLIST_CLEAR(nIDENT_SL);
    end if;  -- ( bCLC_PERF )
    
  end ININVOICES_RECALC_PERFORMANCE;
  /*#########################################################################################################*/

  procedure ININVOICES_CLEAR_FOR_UPDATE
  /*
  Заголовок. Очистка перед исправлением и восстановление после очистки
  При очистке удаляются связи, снимается отработка. При восстановлении отрабатывается, восстанавливаются связи 
  Обязательно выполнять в обоих режимах, иначе документ останется неотработанным и без связей
  */
  (
   rROW         in out ininvoices%rowtype
  ,nMODE        in number       /* Режим выполнения: 0 - освободить, 1 - восстановить */
  ) 
  is
    nNumber     pkg_std.tnumber;
    sVarchar    pkg_std.tstring;
  begin
    /* 0 - Освободить */
    if nMODE = 0 then

      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

      /* Удаление выходных связей с разделом Приходные ордера (только!)*/
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rROW.rn
                                          ,ncompany      => rROW.company
                                          ,sunitcode     => 'IncomingOrders'
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                          ,nmode         => 0 );
      /* Снятие отработки */
      p_ininvoices_bset_status( ncompany   => rROW.company
                               ,nrn        => rROW.rn
                               ,nstatus    => 0
                               ,dwork_date => rROW.doc_date
                               ,nwarning   => nNumber
                               ,smsg       => sVarchar );
      /* Подмена статуса на Не отработан */
--        rROW.status := 0;
      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;


    /* 1 - Восстановить */
    elsif nMODE = 1 then

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Восстановление связей */
        usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                            ,nrn           => rROW.rn
                                            ,ncompany      => rROW.company
                                            ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                            ,nmode         => 1 );
        /* Отработка */
        p_ininvoices_bset_status( ncompany   => rROW.company
                                 ,nrn        => rROW.rn
                                 ,nstatus    => 2
                                 ,dwork_date => rROW.doc_date
                                 ,nwarning   => nNumber
                                 ,smsg       => sVarchar );
        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Очистка переменных */
      usr_pkg_pub_const.arn_unit_list.delete;

    else
      p_exception(0, 'Неверный режим работы.%s', sqlerrm ); 
    end if;

  end ININVOICES_CLEAR_FOR_UPDATE;
  /*#########################################################################################################*/

  function ININVOICESBUFF_GET
  /*
  Заголовок (буфер). Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoicesbuff%rowtype
  is
    rRow ininvoicesbuff%rowtype;
  begin
    begin
      select * into rRow from ininvoicesbuff where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ININVOICESBUFF');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESBUFF'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end ININVOICESBUFF_GET;
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_UPDATE
  /*
  Заголовок (буфер). Исправление 
  */
  (
   rV_ROW   in v_ininvoicesbuff%rowtype
  ) 
  is
  begin
    p_ininvoicesbuff_update(nrn            => rV_ROW.NRN
                           ,ncompany       => rV_ROW.NCOMPANY
                           ,scrn           => rV_ROW.SCRN
                           ,sjur_pers      => rV_ROW.SJUR_PERS
                           ,sdoctype       => rV_ROW.SDOCTYPE
                           ,spref          => rV_ROW.SPREF
                           ,snumb          => rV_ROW.SNUMB
                           ,sext_numb      => rV_ROW.SEXT_NUMB
                           ,dext_date      => rV_ROW.DEXT_DATE
                           ,ddoc_date      => rV_ROW.DDOC_DATE
                           ,nstatus        => rV_ROW.NSTATUS
                           ,nservact_sign  => rV_ROW.NSERVACT_SIGN
                           ,dwork_date     => rV_ROW.DWORK_DATE
                           ,svalid_doctype => rV_ROW.SVALID_DOCTYPE
                           ,svalid_docnumb => rV_ROW.SVALID_DOCNUMB
                           ,dvalid_docdate => rV_ROW.DVALID_DOCDATE
                           ,sstore         => rV_ROW.SSTORE
                           ,sparty_rn      => rV_ROW.NPARTY_RN
                           ,sparty         => rV_ROW.SPARTY
                           ,sfaceacc       => rV_ROW.SFACEACC
                           ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                           ,sagent         => rV_ROW.SAGENT
                           ,scurrency      => rV_ROW.SCURRENCY
                           ,sstoreoper     => rV_ROW.SSTOREOPER
                           ,ncurcours      => rV_ROW.NCURCOURS
                           ,ncurbasecours  => rV_ROW.NCURBASECOURS
                           ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                           ,nfa_cours      => rV_ROW.NFA_COURS
                           ,nsigntax       => rV_ROW.NSIGNTAX
                           ,nsumm          => rV_ROW.NSUMM
                           ,nsummtax       => rV_ROW.NSUMMTAX
                           ,nplanpaysumm   => rV_ROW.NPLANPAYSUMM
                           ,nfactpaysumm   => rV_ROW.NFACTPAYSUMM
                           ,snote          => rV_ROW.SNOTE
                           ,sagnfifo       => rV_ROW.SAGNFIFO
                           ,ndiscount      => rV_ROW.NDISCOUNT
                           ,sbarcode       => rV_ROW.SBARCODE
                           ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                           ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                           ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                           ,sreg_agent     => rV_ROW.SREG_AGENT);
  end ININVOICESBUFF_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_BASE_INSERT
  /*
  Заголовок (буфер). Добавление базовое
  */
  (
   rROW   in ininvoicesbuff%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_ininvoicesbuff_base_insert( ncompany         => rRow.company
                                 ,ncrn             => rRow.crn
                                 ,njur_pers        => rRow.jur_pers
                                 ,nident           => rRow.ident
                                 ,nsource_rn       => rRow.source_rn
                                 ,ssource_unitcode => rRow.source_unitcode
                                 ,ndoctype         => rRow.doctype
                                 ,spref            => rRow.pref
                                 ,snumb            => rRow.numb
                                 ,ddoc_date        => rRow.doc_date
                                 ,nservact_sign    => rRow.servact_sign
                                 ,sext_numb        => rRow.ext_numb
                                 ,dext_date        => rRow.ext_date
                                 ,nvalid_doctype   => rRow.valid_doctype
                                 ,svalid_docnumb   => rRow.valid_docnumb
                                 ,dvalid_docdate   => rRow.valid_docdate
                                 ,nstore           => rRow.store
                                 ,nparty_rn        => rRow.party_rn
                                 ,sparty           => rRow.party
                                 ,nfaceacc         => rRow.faceacc
                                 ,ngraphpoint      => rRow.graphpoint
                                 ,nagent           => rRow.agent
                                 ,ncurrency        => rRow.currency
                                 ,nstoreoper       => rRow.storeoper
                                 ,ncurcours        => rRow.curcours
                                 ,ncurbasecours    => rRow.curbasecours
                                 ,nfa_basecours    => rRow.fa_basecours
                                 ,nfa_cours        => rRow.fa_cours
                                 ,nsigntax         => rRow.signtax
                                 ,snote            => rRow.note
                                 ,nagnfifo         => rRow.agnfifo
                                 ,ndiscount        => rRow.discount
                                 ,sbarcode         => rRow.barcode
                                 ,npayconf_type    => rRow.payconf_type
                                 ,spayconf_numb    => rRow.payconf_numb
                                 ,dpayconf_date    => rRow.payconf_date
                                 ,nreg_agent       => rRow.reg_agent
                                 ,nrn              => nRN );
  end ININVOICESBUFF_BASE_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW   in ininvoicesbuff%rowtype
  ) 
  is
  begin
    p_ininvoicesbuff_base_update(nrn            => rROW.rn
                                ,ncompany       => rROW.company
                                ,ncrn           => rROW.crn
                                ,njur_pers      => rROW.jur_pers
                                ,ndoctype       => rROW.doctype
                                ,spref          => rROW.pref
                                ,snumb          => rROW.numb
                                ,ddoc_date      => rROW.doc_date
                                ,sext_numb      => rROW.ext_numb
                                ,dext_date      => rROW.ext_date
                                ,nstatus        => rROW.status
                                ,nservact_sign  => rROW.servact_sign
                                ,dwork_date     => rROW.work_date
                                ,nvalid_doctype => rROW.valid_doctype
                                ,svalid_docnumb => rROW.valid_docnumb
                                ,dvalid_docdate => rROW.valid_docdate
                                ,nstore         => rROW.store
                                ,nparty_rn      => rROW.party_rn
                                ,sparty         => rROW.party
                                ,nfaceacc       => rROW.faceacc
                                ,ngraphpoint    => rROW.graphpoint
                                ,nagent         => rROW.agent
                                ,ncurrency      => rROW.currency
                                ,nstoreoper     => rROW.storeoper
                                ,ncurcours      => rROW.curcours
                                ,ncurbasecours  => rROW.curbasecours
                                ,nfa_basecours  => rROW.fa_basecours
                                ,nfa_cours      => rROW.fa_cours
                                ,nsigntax       => rROW.signtax
                                ,nsumm          => rROW.summ
                                ,nsummtax       => rROW.summtax
                                ,nplanpaysumm   => rROW.planpaysumm
                                ,nfactpaysumm   => rROW.factpaysumm
                                ,snote          => rROW.note
                                ,nagnfifo       => rROW.agnfifo
                                ,ndiscount      => rROW.discount
                                ,sbarcode       => rROW.barcode
                                ,npayconf_type  => rROW.payconf_type
                                ,spayconf_numb  => rROW.payconf_numb
                                ,dpayconf_date  => rROW.payconf_date
                                ,nreg_agent     => rROW.reg_agent);
  end ININVOICESBUFF_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESBUFF_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  ) 
  is
    rRow        ininvoicesbuff%rowtype;
    rSpec       ininvoicesspbuff%rowtype;
  begin
    /* Заголовок  */
    rRow := ininvoicesbuff_get(nrn => nRN);
    
    /* Проверка параметров*/    
    /* Не задан */
    if nSIGNTAX is null then
      p_exception(0, 'Не задан параметр процедуры "Цены включают налоги". %s'
                 ,cr||f_docdescrs_get_description('IncomingInvoicesBuff', rRow.rn)); 
    elsif nSIGNTAX not in (0, 1) then
      p_exception(0, 'Неверное значение: "%s" параметра процедуры "Цены включают налоги". %s'
                 ,nSIGNTAX
                 ,cr||f_docdescrs_get_description('IncomingInvoicesBuff', rRow.rn)); 
    end if;
    /* Имеет такое же значение, как в документе */
    if ( rRow.signtax = nSIGNTAX and nSIGNTAX is not null )
    and nFLAGSMART = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.signtax when 0 then 'Нет' else 'Да' end
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesBuff', ndocument => rRow.rn)); 
    end if;
      
    /* Исправление заголовка */
    rRow.signtax := nSIGNTAX;
    ininvoicesbuff_base_update(rrow => rRow);

    /* По спецификациям */
    for c in (select * from ininvoicesspbuff where prn = rRow.rn)
    loop
      /* Сохранение записи в переменную */
      rSpec := c;
      /* Расчёт сумм */
      pkg_dictaxis_calc.p_calculate_base
      (
       nflag_smart => 0
      ,ncompany    => rRow.company
      ,ddate       => rRow.doc_date
      ,nsumm_sign  => 1
      ,ninsumm     => rSpec.summtax 
      ,ntaxgr      => rSpec.taxgr
      ,nquant      => 1
      ,nncp_sign   => 1
      );
      /* Сохранение сумм в переменную */
      /*
      rSpec.summ     := pkg_dictaxis_calc.f_get_value(0); \* Сумма без налогов (0) *\
      rSpec.summtax  := pkg_dictaxis_calc.f_get_value(2); \* Сумма со всеми налогами (2) *\
      rSpec.summ_nds := pkg_dictaxis_calc.f_get_value(8); \* НДС (8) *\
      */
      rSpec.price    := case nSIGNTAX when 0 then rSpec.summ else rSpec.summtax end / rSpec.quant; /* Цена */
      /* Исправление спецификации */
      ininvoicesspbuff_base_update(RROW => rSpec);
    end loop;

  end ININVOICESBUFF_UPDATE_SIGNTAX;
  /*#########################################################################################################*/

  function ININVOICESSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ININVOICESSPECS%ROWTYPE
  is
    rRow ININVOICESSPECS%ROWTYPE;
  begin
    begin
      select t.*
        into rRow
        from ininvoicesspecs t
        where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ININVOICESSPECS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESSPECS'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end ININVOICESSPECS_GET;
  /*#########################################################################################################*/
  
  PROCEDURE ININVOICESSPECS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,nTOO_MANY_ROWS     in number default 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,nPRN               in number
  ,nNOMEN             in number default null
  ,nMODIF             in number default null
  ,nPACK              in number default null
  ,nTAXGR             in number default null
  ,nQUANT             in number default null
  ,nQUANTALT          in number default null
  ,nPRICE             in number default null
  ,nARTICLE           in number default null
  ,sSERNUMB           in varchar2 default null
  ,nCOUNTRY           in number   default null
  ,sGTD               in varchar2 default null
  ,dBEGINDATE         in date default null
  ,dENDDATE           in date default null
  ,rROW               out ininvoicesspecs%rowtype 
  ) 
  is
    sMessage    pkg_std.tlstring;
  begin
    begin
      select *
        into rRow
        from ininvoicesspecs t
       where t.prn                      = nPRN
         and (nvl(t.nomen, 0)           = nvl(nNOMEN, 0)    or (nNOMEN    is null and nFLAG_OPTION = 1))
         and (nvl(t.modif, 0)           = nvl(nMODIF, 0)    or (nMODIF    is null and nFLAG_OPTION = 1))
         and (nvl(t.pack, 0)            = nvl(nPACK, 0)     or (nPACK     is null and nFLAG_OPTION = 1))
         and (nvl(t.taxgr, 0)           = nvl(nTAXGR, 0)    or (nTAXGR    is null and nFLAG_OPTION = 1))
         and (nvl(t.quant, 0)           = nvl(nQUANT, 0)    or (nQUANT    is null and nFLAG_OPTION = 1))
         and (nvl(t.quantalt, 0)        = nvl(nQUANTALT, 0) or (nQUANTALT is null and nFLAG_OPTION = 1))
         and (nvl(round(t.price, 0), 0) = nvl(round(nPRICE, 0), 0)    or (nPRICE    is null and nFLAG_OPTION = 1))
         and (nvl(t.article, 0)         = nvl(nARTICLE, 0)  or (nARTICLE  is null and nFLAG_OPTION = 1))
         and (nvl(t.sernumb, 0)         = nvl(sSERNUMB, 0)  or (sSERNUMB  is null and nFLAG_OPTION = 1))
         and (nvl(t.country, 0)         = nvl(nCOUNTRY, 0)  or (nCOUNTRY  is null and nFLAG_OPTION = 1))
         and (nvl(t.gtd, 0)             = nvl(sGTD, 0)      or (sGTD      is null and nFLAG_OPTION = 1))
         and ((t.begindate = dbegindate or (t.begindate is null and dBEGINDATE is null)) or (dBEGINDATE is null and nFLAG_OPTION = 1))
         and ((t.enddate   = denddate   or (t.enddate   is null and dENDDATE   is null)) or (dENDDATE   is null and nFLAG_OPTION = 1))
         ;
    exception
      when no_data_found then
        if nFLAGSMART = 0 then
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'IncomingInvoices'
                                           ,nprn        => nPRN
                                           ,nnomen      => nNOMEN
                                           ,nnommodif   => nMODIF
                                           ,ntaxgr      => nTAXGR
                                           ,nquant      => nQUANT
                                           ,nprice      => nPRICE
                                           ,narticle    => nARTICLE
                                           ,ssernumb    => sSERNUMB 
                                           ,ncountry    => nCOUNTRY 
                                           ,sgtd        => sGTD     
                                           ,dbegindate  => dBEGINDATE
                                           ,denddate    => dENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Не найдена спецификация с параметрами: '||sMessage);
        end if;
      when too_many_rows then
        if nTOO_MANY_ROWS = 0 AND nFLAGSMART = 0 then
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'IncomingInvoices'
                                           ,nprn        => nPRN
                                           ,nnomen      => nNOMEN
                                           ,nnommodif   => nMODIF
                                           ,ntaxgr      => nTAXGR
                                           ,nquant      => nQUANT
                                           ,nprice      => nPRICE
                                           ,narticle    => nARTICLE
                                           ,ssernumb    => sSERNUMB 
                                           ,ncountry    => nCOUNTRY 
                                           ,sgtd        => sGTD     
                                           ,dbegindate  => dBEGINDATE
                                           ,denddate    => dENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Найдено больше одной спецификации с параметрами: '||sMessage);
        end IF;
      when others then
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'IncomingInvoices'
                                           ,nprn        => nPRN
                                           ,nnomen      => nNOMEN
                                           ,nnommodif   => nMODIF
                                           ,ntaxgr      => nTAXGR
                                           ,nquant      => nQUANT
                                           ,nprice      => nPRICE
                                           ,narticle    => nARTICLE
                                           ,ssernumb    => sSERNUMB 
                                           ,ncountry    => nCOUNTRY 
                                           ,sgtd        => sGTD     
                                           ,dbegindate  => dBEGINDATE
                                           ,denddate    => dENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Неопределённая ситуация при поиске спецификации с параметрами: '||sMessage);
    end;
  end ININVOICESSPECS_GET_BY_PARAMS;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_GET_GP
  /*
  Спецификация. Получить RN партии товара
  */
  (
   nFLAG_SMART  in number
  ,nRN          in number
  ,nGP          out number
  ) 
  is
    rRow          ininvoicesspecs%rowtype;
    rInInvoices   ininvoices%rowtype;
    
    nNumber       pkg_std.tnumber; 
  begin
    rRow        := ininvoicesspecs_get(nrn => nRN, nflagsmart => nFLAG_SMART);
    rInInvoices := ininvoices_get(nrn => rRow.prn, nflagsmart => nFLAG_SMART);
    
    find_goodsparties_by_doc_base(ncompany      => rRow.company
                                 ,nflag_smart   => nFLAG_SMART
                                 ,nindoc        => rInInvoices.party_rn
                                 ,nnomen        => rRow.nomen
                                 ,nnommodif     => rRow.modif
                                 ,nnommodifpack => rRow.pack
                                 ,ssernumb      => rRow.sernumb
                                 ,ncountry      => rRow.country
                                 ,sgtd          => rRow.gtd
                                 ,nrn           => nGP
                                 ,nfound        => nNumber);
  end ININVOICESSPECS_GET_GP;
  /*#########################################################################################################*/

  function ININVOICESSPECS_GET_GP
  /*
  Спецификация. Получить RN партии товара
  */
  (
   nFLAG_SMART  in number
  ,nRN          in number
  ) 
  return number
  is
    nRef          pkg_std.tref; 
  begin
    ininvoicesspecs_get_gp(nflag_smart => nFLAG_SMART, nrn => nRN, ngp => nRef);
    return(nRef);
  end ININVOICESSPECS_GET_GP;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            ininvoicesspecs%rowtype;
    rDicNomns       dicnomns%rowtype;
    
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    /* Считывание */
    rRow      := ininvoicesspecs_get( nrn => nRN );
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rRow.nomen );

    /* ИСПРАВЛЕНИЯ */
    /* Если не заполнено Оригинальное наименование */
    if rRow.original_name is null then
      /* подмена наименования из номенклатора */
      rRow.original_name := rDicNomns.nomen_name;
      /* исправление */
      ininvoicesspecs_base_update( rrow => rRow, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber );
    end if;

    /* Если свойство АвтРасчКальк = ДА */
    sVarchar := f_docs_props_get_str_value(nproperty => 91563402, sunitcode => 'IncomingInvoices', ndocument => rRow.prn);
    if sVarchar = 'Да' or sVarchar is null then
      /* Если каталог Метрология */
      if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => '99269117' ) then
        /* пересоздание калькуляций */
        ininvoices_recreate_iivsc(nrn => rRow.prn);
      end if;
    end if;

    /* ПРОВЕРКИ */
    /* Базовая */
    ininvoicesspecs_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end ININVOICESSPECS_AINSERT;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            ininvoicesspecs%rowtype;
  begin
    null;
    /* Считывание */
    rRow  := ininvoicesspecs_get(nrn => nRN);
    usr_pkg_pub_const.rininvoicesspecs := rRow;
    usr_pkg_docs_props_vals.get_vals_document_type(ndocument => rRow.rn, apropvals => usr_pkg_pub_const.aprops);
    
    /* ПРОВЕРКИ */
    /* Выходных документов */
    ininvoicesspecs_check_out_docs( rrow => rRow );
    
  end ININVOICESSPECS_BUPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            ininvoicesspecs%rowtype;
    aPropVals       usr_pkg_pub_const.tdocs_props_vals;
  begin
    /* Считывание */
    rRow  := ininvoicesspecs_get(nrn => nRN);
    usr_pkg_docs_props_vals.get_vals_document_type(ndocument => rRow.rn, apropvals => aPropVals);

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    ininvoicesspecs_check_base(nrn => nRN, ncompany => nCOMPANY);
    
    /* Поле Дата производства */
    if cmp_vc2(
               usr_pkg_pub_const.rininvoicesspecs.prod_date
              ,rRow.prod_date
              ) != 1 
    and nvl(usr_pkg_process.process_get, 'null') not in ('USR_P_IIVS_UPDATE_DETAILS', 'USR_P_IIVS_SPLIT', 'USR_P_IIVS_SEPARATION') then
      p_exception(0, 'Поле "Дата производства" разрешено исправлять только пользовательской процедурой. Значение до: <%s>, значение после: <%s> %s%s'
                 ,decode_date(usr_pkg_pub_const.rininvoicesspecs.prod_date) 
                 ,decode_date(rRow.prod_date)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rRow.rn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.prn)); 
    end if;              

    /* Свойство Дата производства */
    if cmp_vc2(
               usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'Дата производства', apropvals => usr_pkg_pub_const.aprops)
              ,usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'Дата производства', apropvals => aPropVals)
              ) != 1 
    and nvl(usr_pkg_process.process_get, 'null') not in ('USR_P_IIVS_UPDATE_DETAILS', 'USR_P_IIVS_SPLIT', 'USR_P_IIVS_SEPARATION') then
      p_exception(0, 'Свойство "Дата производства" разрешено исправлять только пользовательской процедурой. Значение до: <%s>, значение после: <%s> %s%s'
                 ,usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'Дата производства', apropvals => usr_pkg_pub_const.aprops)
                 ,usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'Дата производства', apropvals => aPropVals)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rRow.rn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.prn)); 
    end if;              

  end ININVOICESSPECS_AUPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow         ininvoicesspecs%rowtype;

  begin
    /* Считывание */
    rRow := ininvoicesspecs_get(nrn => nRN); 

    /* ПРОВЕРКИ */
    /* Выходные документы */
    ininvoicesspecs_check_out_docs( rrow => rRow );
    
  end ININVOICESSPECS_BDELETE;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_AASFACT
  /*
  Спецификация. Проверка для вызова в проверке после отработки
  */
  (
   rROW              in ininvoicesspecs%rowtype
  ,rININVOICES       in ininvoices%rowtype
  ) 
  IS
    rDicNomns         dicnomns%rowtype;
    rDicGNomn         dicgnomn%rowtype;
    rDicMUnts         dicmunts%rowtype;
    rRlArticles       rlarticles%rowtype;
    nArticleSsupply   pkg_std.tref; 
    rGoodsSupply      goodssupply%rowtype;

    sVarchar          pkg_std.tstring;
    nNumber           pkg_std.tnumber; 
  begin
    /* СЧИТЫВАНИЕ */
    /* Номенклатура */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rROW.NOMEN, nflagsmart => 0 );
    rDicMUnts := udo_pkg_get.row_dicmunts( nrn => rDicNomns.umeas_main );
    /* Расчёт сумм */
    pkg_dictaxis_calc.p_calculate_base(nflag_smart => 0
                                      ,ncompany    => rININVOICES.COMPANY
                                      ,ddate       => rININVOICES.DOC_DATE
                                      ,nsumm_sign  => 1
                                      ,ninsumm     => rROW.SUMMTAX
                                      ,ntaxgr      => rROW.TAXGR
                                      ,nquant      => 1
                                      ,nncp_sign   => 1);
      
    /* ПРОВЕРКИ */
    /* Базовая */
    ininvoicesspecs_check_base( nrn => rROW.RN, ncompany => rROW.COMPANY );

    /* Если внешняя дата заголовка больше или равна 01.01.2026 */
    if cmp_dat_minmax( rININVOICES.DOC_DATE, to_date('01.01.2026', 'dd.mm.yyyy') ) >= 0 then
      /* Если налоговая группа НДС 20 */
      if rROW.TAXGR = 502994 then
        /* Мнемокод налоговой группы */
        find_dictaxgr_rn( nflag_smart  => 0
                         ,nflag_option => 0
                         ,ncompany     => rROW.COMPANY
                         ,nrn          => rROW.TAXGR
                         ,scode        => sVarchar );
        p_exception(0, 'Запрещено использовать налоговую группу "%s", т.к. дата документа "%s" больше "%s". %s%s'
                   ,sVarchar
                   ,decode_date( rININVOICES.DOC_DATE )
                   ,decode_date( to_date('01.01.2026', 'dd.mm.yyyy') )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoices', ndocument => rROW.PRN ) ); 
      end if;
    end if;

    /* Проверка суммы без налогов */
    if round( rROW.SUMM, -1 ) != round( pkg_dictaxis_calc.f_get_value(0), -1 ) then
      p_exception(0, 'Поле "Сумма по документу. Без налогов" <%s> не соответствует сумме, расчитанной с учётом налоговой группы <%s>. %s%s'
                 ,rROW.SUMM
                 ,pkg_dictaxis_calc.f_get_value(0)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rROW.PRN)); 
    end if;

    /* Количество дробное при том, что едицина измерения целая */
    if rDicMUnts.meas_type = 1
    and nvl( rROW.QUANT, 0 ) != round( nvl( rROW.QUANT, 0 ) )  then
      p_exception(0, 'Количество <%s> не должно быть дробным для единицы измерения <%s>. %s%s'
                 ,rROW.QUANT
                 ,rDicMUnts.meas_mnemo
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoices', ndocument => rROW.PRN ) ); 
    end if;                 

    /* Если тип номенклатуры НЕ услуга */
    if rDicNomns.nomen_type != 2 then

      /* проверка спецификации входного документа */
      ininvoicesspecs_check_indoc( rrow => rROW );

      /* Если складская операция НЕ ПриходВнешОХ */
      if rININVOICES.STOREOPER != 52984971 then
        /* проверка калькуляций */
        ininvoicesspecs_check_iosc( rrow => rROW );
      end if;

      /* если каталог Метрология */
      if usr_pkg_common.is_crn_in_hiercrn( nCRN => rRow.CRN, shier_crn_list => usr_pkg_pub_const.niiv_cat_mtlg ) then
        /* проверка количества */
        if rROW.QUANT != 1 then
          p_exception(0, 'Поле "Количество должно иметь значение <1>. %s%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN)
                     ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rROW.PRN)); 
        end if;
      end if;

      /* Если не заданы даты: изготовления */
      if usr_pkg_docs_props_vals.get_val_date( ndoc_prop => 211014548, ndocument => rROW.rn ) is null 
      and nvl( usr_pkg_process.process_get, 'null') not in ( 'USR_P_DOCS_REPLACE_FACEACC' ) then

        /* группа ТМЦ */
        if rDicnomns.group_code is not null then
          rDicGNomn := udo_pkg_get.row_dicgnomn( nrn => rDicnomns.group_code );
        end if;

        /* если группа ТМЦ "ПП, ЭРИ" */
        if rDicGNomn.rn is not null and rDicGNomn.rn in (13885759, 13884309) then
          p_exception(0, 'Не заполнено свойство спецификации: "Дата изготовления (дата)". Группа номенклатуры <%s>.%s'
                     ,rDicGNomn.group_name
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN )
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rROW.PRN ) ); 
        end if;
      end if;
    end if;
    
  end ININVOICESSPECS_AASFACT;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow              ininvoicesspecs%rowtype;
    rInInvoices       ininvoices%rowtype;
    rRlArticles       rlarticles%rowtype;
    nArticleSsupply   pkg_std.tref; 
    rGoodsSupply      goodssupply%rowtype;

    sVarchar          pkg_std.tstring;
    nNumber           pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow        := ininvoicesspecs_get(nrn => nRN);
    rInInvoices := ininvoices_get(nrn => rRow.prn);
    /* Изделие */
    if rRow.article is not null then
      /* Считывание записи изделия */
      rRlArticles := usr_pkg_rlarticles.rlarticles_get(nrn => rRow.article);
      /* Изделие на складе */
      find_articlessupply_by_article(nflag_smart  => 1
                                    ,nflag_option => 1
                                    ,ncompany     => rRow.company
                                    ,narticle     => rRlArticles.rn
                                    ,sarticle     => null
                                    ,nrn          => nArticleSsupply
                                    ,nship_plan   => nNumber);
      /* Товарный запас по изделию на складе */
      if nArticleSsupply is not null then
        usr_pkg_goodsparties.goodssupply_get_by_gssa(nflagsmart => 0
                                                    ,ngssa      => nArticleSsupply
                                                    ,ncompany   => rRow.company
                                                    ,nrn        => rGoodsSupply.rn);
      end if;                                                  
      /* Данные товарного запаса */
      if rGoodsSupply.rn is not null then
        find_goodssupply_full_by_rn(ncompany     => rRow.company
                                   ,nflag_smart  => 0
                                   ,nrn          => rGoodsSupply.rn
                                   ,ddate        => rInInvoices.doc_date
                                   ,nrestplan    => nNumber
                                   ,nrestplanalt => nNumber
                                   ,nrestfact    => rGoodsSupply.restfact
                                   ,nrestfactalt => nNumber
                                   ,nreserv      => nNumber
                                   ,nreservalt   => nNumber);
      end if;                                 
    end if;    

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Если изделие числится в учёте */
    if nvl(rGoodsSupply.restfact, 0) != 0 then 
       p_exception(0, 'Изделие <%s> числится в учёте на дату документа <%s>. Повторный приход запрещён. %s%s'
                  ,rRlArticles.code
                  ,decode_date(rInInvoices.doc_date)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rRow.rn)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rRow.prn)); 
    end if;
    
  end ININVOICESSPECS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_IOSC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in ininvoicesspecs%rowtype
  ) 
  is
    nQuantPlanItog   pkg_std.tlquant := 0; 
    nQuantFactItog   pkg_std.tlquant := 0; 
  begin
    /* Итоговое количество по калькуляциям текущей спецификации */
    begin
      select nvl(sum(quant_plan), 0)
            ,nvl(sum(quant_Fact), 0)
        into nQuantPlanItog
            ,nQuantFactItog
        from ininvoicesspc 
       where prn = rROW.RN;
    exception
      when no_data_found then
        p_exception(0, 'В спецификации отсутствуют калькуляции. %s%s'
                   ,cr||cr||f_docdescrs_get_description('IncomingInvoicesSpecs', ndocument => rROW.RN)
                   ,cr||cr||f_docdescrs_get_description('IncomingInvoices', ndocument => rROW.PRN)); 
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске калькуляций.'
                   ,cr||cr||f_docdescrs_get_description('IncomingInvoicesSpecs', ndocument => rROW.RN)
                   ,cr||cr||f_docdescrs_get_description('IncomingInvoices', ndocument => rROW.PRN)); 
    end;

    /* Проверка итогового количества калькуляции и количества в спецификации */
    if nQuantPlanItog != rROW.quant then
      p_exception(0, 'Сумма по полю "Количество. План" в калькуляции <%s> не равно количеству в спецификации <%s>. %s%s'
                 ,usr_f_n2sq( nQuantPlanItog )
                 ,usr_f_n2sq( rROW.QUANT )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rROW.PRN)); 
    end if;                 
    if nQuantFactItog != rROW.quant then
      p_exception(0, 'Сумма по полю "Количество. Факт" в калькуляции <%s> не равно количеству в спецификации <%s>. %s%s'
                 ,usr_f_n2sq( nQuantFactItog )
                 ,usr_f_n2sq( rROW.QUANT )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => rROW.PRN)); 
    end if;                 
  end ININVOICESSPECS_CHECK_IOSC;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации входящего счёта
  */
  (
   rROW   in ininvoicesspecs%rowtype
  ) 
  is
    rHead               ininvoices%rowtype;
    nInDoc              pkg_std.tref; 
    rInDoc              payaccin%rowtype;
    rInDocSpec          payaccinspec%rowtype;
    nInDocSpec_QntRem   pkg_std.tquant; 
    d2025               date := to_date( '01.01.2026', 'dd.mm.yyyy' );
    rDicNomns           dicnomns%rowtype;
    rDicMUnts           dicmunts%rowtype;
    nPercTolerance      pkg_std.tnumber; 
    
    nNumber             pkg_std.tnumber; 
    sVarchar            pkg_std.tstring; 
    dDate               date;
  begin
    /* Считывание родительского заголовка */
    rHead := ininvoices_get(nrn => rROW.PRN, nflagsmart => 0);
    /* Номенклатура */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rROW.NOMEN, nflagsmart => 0 );
    /* Единица измерения */
    rDicMUnts := udo_pkg_get.row_dicmunts( nrn => rDicNomns.umeas_main );

    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                   ,sout_unitcode  => 'IncomingInvoices'
                                                   ,nout_document  => rROW.PRN
                                                   ,sin_unitcode   => 'PaymentAccountsIn');
    /* Если входной документ найден */
    if nInDoc is not null then
      /* Считывание заголовка связанного документа */
      rInDoc := usr_pkg_payaccin.payaccin_get(nrn => nInDoc);

      /* Если дата связанного документа меньше 31/12/2025 */
      if  cmp_dat_minmax( rInDoc.reg_date, d2025 ) < 0
      and cmp_dat_minmax( rHead.doc_date , d2025 ) >= 0  then
        /* Поиск аналогичной спецификации во входном документе без учета цены */
        usr_pkg_payaccin.payaccinspec_get_by_params(nflagsmart  => 0
                                                   ,nprn        => nInDoc
                                                   ,nnomen      => rROW.NOMEN
                                                   ,nnommodif   => rROW.MODIF
                                                   ,ntaxgr      => rROW.TAXGR
                                                   ,rrow        => rInDocSpec);
      else                                                 
        /* Поиск аналогичной спецификации во входном документе с учетом цены */
        usr_pkg_payaccin.payaccinspec_get_by_params(nflagsmart  => 0
                                                   ,nprn        => nInDoc
                                                   ,nnomen      => rROW.NOMEN
                                                   ,nnommodif   => rROW.MODIF
                                                   ,ntaxgr      => rROW.TAXGR
                                                   ,nprice      => case when rHead.currency = rInDoc.currency then rROW.PRICE end
                                                   ,rrow        => rInDocSpec);
      end if;

      /* количество остатка исполнения спецификации входного документа */
      usr_pkg_payaccin.payaccinspec_get_indoc_remain(rrow      => rInDocSpec
                                                    ,ncalc_way => 0
                                                    ,nmod_sign => nNumber
                                                    ,nresult   => nInDocSpec_QntRem);
      /* Если категория единицы измерения Штучная */
      if rDicMUnts.category = 8 then
        /* если количество остатка исполнения спецификации входного документа меньше нуля */
        if nInDocSpec_QntRem < 0 then
          p_exception(0, 'Превышено количество в сформированных документах. Количество во входящем документе: %s. Превышение: %s. %s%s'
                     ,usr_f_n2sq( rInDocSpec.quant )
                     ,usr_f_n2sq( abs( nInDocSpec_QntRem ) )
                     ,cr||f_docdescrs_get_description('IncomingInvoicesSpecs', rRow.rn)
                     ,cr||f_docdescrs_get_description('IncomingInvoices', rRow.prn)); 
        end if;
      /* Если категория единицы измерения НЕ Штучная */
      else
        /* Процент толерантности из константы */
        find_constant_by_name( ncompany  => rRow.company
                              ,sname     => 'Процент_толерантности'
                              ,dfrom     => null
                              ,checkonly => 0
                              ,ntype     => nNumber
                              ,nvalue    => nPercTolerance
                              ,svalue    => sVarchar
                              ,dvalue    => dDate );
        /* если количество остатка исполнения спецификации входного документа + толерантность меньше нуля */
        if nInDocSpec_QntRem + rInDocSpec.quant * ( nPercTolerance / 100 ) < 0 then
          p_exception(0, 'Превышено количество в сформированных документах. '||cr||
                         'Количество во входящем документе: %s. '||cr||
                         'Толерантность 10%: %s. '||cr||
                         'Получено: %s. '||cr||
                         'Превышение: %s.%s%s'
                     ,usr_f_n2sq( rInDocSpec.quant )
                     ,usr_f_n2sq( rInDocSpec.quant * ( nPercTolerance / 100 ) )
                     ,usr_f_n2sq( rInDocSpec.factquant )
                     ,usr_f_n2sq( abs( nInDocSpec_QntRem ) )
                     ,cr||cr||f_docdescrs_get_description( 'IncomingInvoicesSpecs', rRow.rn )
                     ,cr||cr||f_docdescrs_get_description( 'IncomingInvoices', rRow.prn ) ); 
        end if;
      end if;
    else
      /* Если каталог Метрология, ОМТС */
      if  usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => '99269117;7522612') -- 82207905 - Микроэлектроника!
      and pkg_flag.get_flag = 0  then
        p_exception(0, 'Документ не связан по входу с разделом <%s>. %s%s'
                   ,get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCIN')
                   ,cr||f_docdescrs_get_description('IncomingInvoicesSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('IncomingInvoices', rRow.prn)); 
      end if;
    end if;
    
  end ININVOICESSPECS_CHECK_INDOC;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_CHECK_OUT_DOCS
  /*
  Спецификация. Проверка выходных документов
  */
  (
   rROW             ininvoicesspecs%rowtype
  ) 
  is
   nNumber          pkg_std.tnumber;  
  begin
    /* Получение списка Сертификация/Входной контроль, связанных по цепочке */
    nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                              ,sin_unitcode  => 'IncomingInvoices'
                                              ,nin_document  => rROW.PRN
                                              ,sout_unitcode => 'UdoProdCull'
                                              ,srule_chains  => ';IncomingInvoices>IncomingOrders>UdoProdCull;'
                                              ,nident        => rROW.RN );
    /* Если найдены Сертификация/Входной контроль, связанные по цепочке, и если не включен флаг */
    if nNumber is not null     
    and pkg_flag.get_flag !=1 then
      /* По спецификациям РН в подразделения */
      for c in ( select pcs.prn as pcs_prn
                   from selectlist        sl
                   join udo_prod_cull_sp  pcs 
                     on pcs.prn   = sl.document
                    and pcs.modif = rROW.modif
                   join udo_prod_cull_out pco 
                     on pco.prn   = pcs.rn
                    and udo_pkg_prod_cull.cull_out_get_block_state( nrn => pco.rn, ddate => sysdate ) = 1
                  where sl.ident  = rROW.RN
                   -- and utilizer not in ('STEPANOV_MV', 'KHOK')
              )
      loop
        /* Если состояние Сертификация/Входной контроль: Передано на склад, Проверено ВК, ожидание склада */
        p_exception(0, 'Исправление запрещено, т.к. документ "Сертификация/Входной контроль (результаты проверки)" отработан (заблокирован).%s%s%s'
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'UdoProdCull', ndocument => c.pcs_prn )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'IncomingInvoicesSpecs', ndocument => rROW.RN )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'IncomingInvoices', ndocument => rROW.PRN) );
      end loop;                  
      /* Очистка */
      p_selectlist_clear( nident => rROW.RN );

    end if;                                              

  end ININVOICESSPECS_CHECK_OUT_DOCS;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW                   in ininvoicesspecs%rowtype
  ,nRN                    out number
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  ) 
  is
  begin
    p_ininvoicesspecs_base_insert(ncompany            => rROW.COMPANY
                                 ,nprn                => rROW.PRN
                                 ,nnomen              => rROW.NOMEN
                                 ,nmodif              => rROW.MODIF
                                 ,npack               => rROW.PACK
                                 ,narticle            => rROW.ARTICLE
                                 ,ntaxgr              => rROW.TAXGR
                                 ,nstore              => rROW.STORE
                                 ,nquant              => rROW.QUANT
                                 ,nquantalt           => rROW.QUANTALT
                                 ,nprice              => rROW.PRICE
                                 ,npricemeas          => rROW.PRICEMEAS
                                 ,nsumm               => rROW.SUMM
                                 ,nsummtax            => rROW.SUMMTAX
                                 ,nsumm_nds           => rROW.SUMM_NDS
                                 ,nautocalc_sign      => rROW.AUTOCALC_SIGN
                                 ,dsrok               => rROW.SROK
                                 ,ssertificate        => rROW.SERTIFICATE
                                 ,snote               => rROW.NOTE
                                 ,dbegindate          => rROW.BEGINDATE
                                 ,denddate            => rROW.ENDDATE
                                 ,ssernumb            => rROW.SERNUMB
                                 ,sbarcode            => rROW.BARCODE
                                 ,ncountry            => rROW.COUNTRY
                                 ,sgtd                => rROW.GTD
                                 ,nproducer           => rROW.PRODUCER
                                 ,nstorage_time       => rROW.STORAGE_TIME
                                 ,numeas_storage      => rROW.UMEAS_STORAGE
                                 ,ndiscount           => rROW.DISCOUNT
                                 ,soriginal_name      => rROW.ORIGINAL_NAME
                                 ,dprod_date          => rROW.PROD_DATE
                                 ,nmdmnomen           => rROW.MDMNOMEN
                                 ,nrn                 => nRN
                                 ,nsumm_ininvoices    => nSUMM_ININVOICES
                                 ,nsummtax_ininvoices => nSUMMTAX_ININVOICES);
  end ININVOICESSPECS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW                   in ininvoicesspecs%rowtype
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  ,nOUT_DOC_UPDATE        in number default 0 /* Исправлять выходные документы*/
  ,nMODE                  in number default 0 /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rInInvoices     ininvoices%rowtype;

    rRow_before       ininvoicesspecs%rowtype;
    rInOrderSpecs     inorderspecs%rowtype;
    rInOrderSpecsNew  inorderspecs%rowtype;
    rGoodsSupply      goodssupply%rowtype;
    rGoodsSupplyNew   goodssupply%rowtype;
    rProd_Cull_Sp     udo_prod_cull_sp%rowtype;
    rProd_Cull_Out    udo_prod_cull_out%rowtype;

    nNumber         pkg_std.tnumber;
  begin
    if nMODE = 0 then
      P_ININVOICESSPECS_BASE_UPDATE(nRN                 => rRow.RN
                                   ,nPRN                => rRow.PRN
                                   ,nNOMEN              => rRow.NOMEN
                                   ,nMODIF              => rRow.MODIF
                                   ,nPACK               => rRow.PACK
                                   ,nARTICLE            => rRow.ARTICLE
                                   ,nTAXGR              => rRow.TAXGR
                                   ,nSTORE              => rRow.STORE
                                   ,nQUANT              => rRow.QUANT
                                   ,nQUANTALT           => rRow.QUANTALT
                                   ,nPRICE              => rRow.PRICE
                                   ,nPRICEMEAS          => rRow.PRICEMEAS
                                   ,nSUMM               => rRow.SUMM
                                   ,nSUMMTAX            => rRow.SUMMTAX
                                   ,nSUMM_NDS           => rRow.SUMM_NDS
                                   ,nAUTOCALC_SIGN      => rRow.AUTOCALC_SIGN
                                   ,dSROK               => rRow.SROK
                                   ,sSERTIFICATE        => rRow.SERTIFICATE
                                   ,sNOTE               => rRow.NOTE
                                   ,dBEGINDATE          => rRow.BEGINDATE
                                   ,dENDDATE            => rRow.ENDDATE
                                   ,sSERNUMB            => rRow.SERNUMB
                                   ,sBARCODE            => rRow.BARCODE
                                   ,nCOUNTRY            => rRow.COUNTRY
                                   ,sGTD                => rRow.GTD
                                   ,nPRODUCER           => rRow.PRODUCER
                                   ,nSTORAGE_TIME       => rRow.STORAGE_TIME
                                   ,nUMEAS_STORAGE      => rRow.UMEAS_STORAGE
                                   ,nDISCOUNT           => rRow.DISCOUNT
                                   ,sORIGINAL_NAME      => rRow.ORIGINAL_NAME
                                   ,dPROD_DATE          => rRow.PROD_DATE
                                   ,nMDMNOMEN           => rRow.MDMNOMEN
                                   ,nSUMM_ININVOICES    => nSUMM_ININVOICES
                                   ,nSUMMTAX_ININVOICES => nSUMMTAX_ININVOICES);
    /* Режим выполнения: 1 - пользовательский. 
       Если документ отработан, нимает отработку, исправляет, повторно отрабатывает. Иначе просто исправляет */
    elsif nMODE = 1 then

      /* Состояние до исправления */
      rRow_before := ininvoicesspecs_get( nrn => rROW.RN );

      /* Считывание заголовка */
      rInInvoices := ininvoices_get( nrn => rROW.PRN );

      /* Если документ НЕ не отработан */
      if rInInvoices.status != 0 then

        /* Очистка перед исправлением */
        usr_pkg_ininvoices.ininvoices_clear_for_update( rrow => rInInvoices, nmode => 0 );

        /* Исправление штатное */
        ininvoicesspecs_base_update( rrow => rROW, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber, nmode => 0 );

        /* Восстановление после очистки */
        usr_pkg_ininvoices.ininvoices_clear_for_update( rrow => rInInvoices, nmode => 1 );

        /* Если исправлять выходные документы */
        if nOUT_DOC_UPDATE = 1 then 
          /* Связанный приходный ордер */
          rInOrderSpecs.prn := usr_pkg_doclinks.doclinks_link_out_doc( ntoo_many_rows => 0
                                                                      ,sin_unitcode   => 'IncomingInvoices'
                                                                      ,nin_document   => rRow_before.prn 
                                                                      ,sout_unitcode  => 'IncomingOrders' );
          /* Аналогичная спецификация приходного ордера */
          usr_pkg_inorders.inorderspecs_get_by_params( nflagsmart => 1
                                                      ,nprn       => rInOrderSpecs.prn
                                                      ,nnommodif  => rRow_before.modif
                                                      ,narticle   => rRow_before.article
                                                      ,ssernumb   => rRow_before.sernumb
                                                      ,rrow       => rInOrderSpecs );
          /* Если найдена аналогичная спецификация приходного ордера */
          if rInOrderSpecs.rn is not null then
            /* Считывание товарного запаса */
            rGoodsSupply := usr_pkg_goodsparties.goodssupply_get( nrn => rInOrderSpecs.goodssupply, nflagsmart => 1 );

            /* Замена значений в аналогичной спецификации приходного ордера */
            rInOrderSpecs.original_name := rROW.ORIGINAL_NAME;
            rInOrderSpecs.note          := rROW.NOTE;
            rInOrderSpecs.taxgr         := rROW.TAXGR;
            rInOrderSpecs.nommodif      := rROW.MODIF;
            rInOrderSpecs.planquant     := rROW.QUANT; 
            rInOrderSpecs.factquant     := rROW.QUANT; 
            rInOrderSpecs.plansum       := rROW.SUMM; 
            rInOrderSpecs.plansumtax    := rROW.SUMMTAX;
            rInOrderSpecs.plansumnds    := rROW.SUMM_NDS;
            rInOrderSpecs.factsum       := rROW.SUMM; 
            rInOrderSpecs.factsumtax    := rROW.SUMMTAX;
            rInOrderSpecs.factsumnds    := rROW.SUMM_NDS;
            rInOrderSpecs.price         := rROW.PRICE; 
            rInOrderSpecs.acc_price     := rROW.SUMM / case rROW.QUANT when 0 then 1 else rROW.QUANT end; 
            rInOrderSpecs.acc_summ      := rROW.SUMM; 

            /* Проверка выходных документов */
            usr_pkg_inorders.inorderspecs_check_out_docs( rrow => rInOrderSpecs );

            /* Исправленние аналогичной спецификации приходного ордера */
            /* исправление */
            usr_pkg_inorders.inorderspecs_base_update( rRow => rInOrderSpecs, nmode => 1 );
              
            /* Считывание нового состояния спецификации приходного ордера */
            rInOrderSpecsNew := usr_pkg_inorders.inorderspecs_get(nrn => rInOrderSpecs.rn );
            /* Считывание ного товарного запаса */
            if rInOrderSpecsNew.goodssupply is not null then
              rGoodsSupplyNew := usr_pkg_goodsparties.goodssupply_get( nrn => rInOrderSpecsNew.goodssupply );
            else
              /* если новый товарный запас не найден, выходим */
              return;
            end if;
              
            /* По связанным спецификациям Сертификация/Входной контроль */
            for c1 in (
                       select t.*
                         from doclinks          dl
                             ,udo_prod_cull_sp  t
                        where dl.in_document  = rInOrderSpecs.prn 
                          and dl.out_document = t.prn 
                          and cmp_num( t.goodsparty, rGoodsSupply.prn ) = 1
                      )
            loop
              /* Сохранение в переменную */
              rProd_Cull_Sp := c1;
              /* Подмена значений на новые */
              rProd_Cull_Sp.goodsparty := rGoodsSupplyNew.prn;
              rProd_Cull_Sp.nomen      := usr_pkg_dicnomns.nommodif_get_prn_by_rn( nrn => rInOrderSpecsNew.nommodif );
              rProd_Cull_Sp.modif      := rInOrderSpecsNew.nommodif;
              rProd_Cull_Sp.quant      := rInOrderSpecsNew.factquant;

              /* Исправление */
              usr_pkg_prod_cull.prod_cull_sp_base_update( rrow => rProd_Cull_Sp );
                
              /* Результатам сертификации */
              for c2 in ( select * from udo_prod_cull_out t where t.prn = c1.rn )
              loop
                /* Сохранение в переменную */
                rProd_Cull_Out := c2;
               /* Подмена значений на новые */
                rProd_Cull_Out.supply := rGoodsSupplyNew.rn;
                rProd_Cull_Out.quant  := rInOrderSpecsNew.factquant;
                /* Исправление */
                usr_pkg_prod_cull.prod_cull_out_base_update( rrow => rProd_Cull_Out );
              end loop;                  
            end loop;
          end if;
        end if;

      /* Если документ не отработан */
      else                               
        /* Исправление штатное */
        ininvoicesspecs_base_update( rrow => rROW, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber, nmode => 0 );
      end if;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end ININVOICESSPECS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_INSERT
  /*
  Спецификация. Добавление клиентское
  */
  (
   rV_ROW                  in v_ininvoicesspecs%rowtype
  ,nRN                    out number
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  ) 
  is
  begin
    p_ininvoicesspecs_insert(ncompany            => rV_ROW.NCOMPANY
                            ,nprn                => rV_ROW.NPRN
                            ,snomen              => rV_ROW.SNOMEN
                            ,smodif              => rV_ROW.SMODIF
                            ,spack               => rV_ROW.SPACK
                            ,sarticle            => rV_ROW.SARTICLE
                            ,staxgr              => rV_ROW.STAXGR
                            ,sstore              => rV_ROW.SSTORE
                            ,nquant              => rV_ROW.NQUANT
                            ,nquantalt           => rV_ROW.NQUANTALT
                            ,nprice              => rV_ROW.NPRICE
                            ,npricemeas          => rV_ROW.NPRICEMEAS
                            ,nsumm               => rV_ROW.NSUMM
                            ,nsummtax            => rV_ROW.NSUMMTAX
                            ,nsumm_nds           => rV_ROW.NSUMM_NDS
                            ,nautocalc_sign      => rV_ROW.NAUTOCALC_SIGN
                            ,dsrok               => rV_ROW.DSROK
                            ,ssertificate        => rV_ROW.SSERTIFICATE
                            ,snote               => rV_ROW.SNOTE
                            ,dbegindate          => rV_ROW.DBEGINDATE
                            ,denddate            => rV_ROW.DENDDATE
                            ,ssernumb            => rV_ROW.SSERNUMB
                            ,sbarcode            => rV_ROW.SBARCODE
                            ,scountry            => rV_ROW.SCOUNTRY
                            ,sgtd                => rV_ROW.SGTD
                            ,sproducer           => rV_ROW.SPRODUCER
                            ,nstorage_time       => rV_ROW.NSTORAGE_TIME
                            ,sumeas_storage      => rV_ROW.SUMEAS_STORAGE
                            ,ndiscount           => rV_ROW.NDISCOUNT
                            ,soriginal_name      => rV_ROW.SORIGINAL_NAME
                            ,dprod_date          => rV_ROW.DPROD_DATE
                            ,nrn                 => nRN
                            ,nsumm_ininvoices    => nSUMM_ININVOICES
                            ,nsummtax_ininvoices => nSUMMTAX_ININVOICES);
  end ININVOICESSPECS_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_UPDATE
  /*
  Спецификация. Исправление клиентское
  */
  (
   rV_ROW                  in v_ininvoicesspecs%rowtype
  ,nFLAG_DEL_CALC          in number default 0
  ,nSUMM_ININVOICES       out number
  ,nSUMMTAX_ININVOICES    out number
  ) 
  is
  begin
    p_ininvoicesspecs_update(ncompany            => rV_ROW.NCOMPANY
                            ,nrn                 => rV_ROW.NRN
                            ,nprn                => rV_ROW.NPRN
                            ,snomen              => rV_ROW.SNOMEN
                            ,smodif              => rV_ROW.SMODIF
                            ,spack               => rV_ROW.SPACK
                            ,sarticle            => rV_ROW.SARTICLE
                            ,staxgr              => rV_ROW.STAXGR
                            ,sstore              => rV_ROW.SSTORE
                            ,nquant              => rV_ROW.NQUANT
                            ,nquantalt           => rV_ROW.NQUANTALT
                            ,nprice              => rV_ROW.NPRICE
                            ,npricemeas          => rV_ROW.NPRICEMEAS
                            ,nsumm               => rV_ROW.NSUMM
                            ,nsummtax            => rV_ROW.NSUMMTAX
                            ,nsumm_nds           => rV_ROW.NSUMM_NDS
                            ,nautocalc_sign      => rV_ROW.NAUTOCALC_SIGN
                            ,dsrok               => rV_ROW.DSROK
                            ,ssertificate        => rV_ROW.SSERTIFICATE
                            ,snote               => rV_ROW.SNOTE
                            ,dbegindate          => rV_ROW.DBEGINDATE
                            ,denddate            => rV_ROW.DENDDATE
                            ,ssernumb            => rV_ROW.SSERNUMB
                            ,sbarcode            => rV_ROW.SBARCODE
                            ,scountry            => rV_ROW.SCOUNTRY
                            ,sgtd                => rV_ROW.SGTD
                            ,sproducer           => rV_ROW.SPRODUCER
                            ,nstorage_time       => rV_ROW.NSTORAGE_TIME
                            ,sumeas_storage      => rV_ROW.SUMEAS_STORAGE
                            ,ndiscount           => rV_ROW.NDISCOUNT
                            ,soriginal_name      => rV_ROW.SORIGINAL_NAME
                            ,dprod_date          => rV_ROW.DPROD_DATE
                            ,nsumm_ininvoices    => nSUMM_ININVOICES
                            ,nsummtax_ininvoices => nSUMMTAX_ININVOICES
                            ,nflag_del_calc      => nFLAG_DEL_CALC);

  end ININVOICESSPECS_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_SEPARATION
  /*
  Спецификация. Разбивка на строки с одной штукой
  */
  (
   nRN                in number
  ) 
  is
    rRow              ininvoicesspecs%rowtype;
    nCount            pkg_std.tnumber := 0; 
    nInInvoicesSpecs  pkg_std.tref; 
    rInInvoicesSpC    ininvoicesspc%rowtype;
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := ininvoicesspecs_get(nrn => nRN);

    /* Проверки */
    if rRow.quant != trunc(rRow.quant) then
      p_exception(0, 'Указано дробное количество <%s>. %s%s'
                 ,rRow.quant
                 ,cr||f_docdescrs_get_description('IncomingInvoicesSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('IncomingInvoices', rRow.prn)); 
    end if;

    /* Сохранение количества в переменную */
    nCount := rRow.quant; 
    
    /* Исправление текущей записи. Количество указываем 1, в серию пишем Rn спецификации */
    /* пересчёт сумм в переменной на 1 шт. */
    rRow.summ     := rRow.summ     / rRow.quant;
    rRow.summtax  := rRow.summtax  / rRow.quant;
    rRow.summ_nds := rRow.summ_nds / rRow.quant;

    /* подстановка в переменную количества 1 шт. */
    rRow.quant := 1;

    /* исправление */
    ininvoicesspecs_base_update(rrow => rRow, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber);
    /* проверка после исправления*/
    ininvoicesspecs_aupdate(nrn => rRow.rn, ncompany => rRow.company);
 
    /* Исправление калькуляций текущей записи */
    for c in (select *
                from ininvoicesspc t
               where t.prn = rRow.rn)
    loop
      rInInvoicesSpC := c;
      rInInvoicesSpC.cost_plan := rInInvoicesSpC.cost_plan / rInInvoicesSpC.quant_plan;
      rInInvoicesSpC.quant_plan := 1;
      ininvoicesspc_base_update(rrow => rInInvoicesSpC);
      /* проверка после исправления */
      ininvoicesspc_aupdate(nrn => rInInvoicesSpC.rn, ncompany => rInInvoicesSpC.company);
    end loop;               
    
    /* Добавление новых записей по 1 штуке */
    while nCount != 1
    loop
      /* счётчик количества */
      nCount := nCount - 1;
      /* обнуляем серию в переменной и добавляем новую спецификацию */
      ininvoicesspecs_base_insert(rrow => rRow, nrn => nInInvoicesSpecs, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber);
      /* проверка после добавления */
      ininvoicesspecs_ainsert(nrn => nInInvoicesSpecs, ncompany => rRow.company);
    end loop;

  end ININVOICESSPECS_SEPARATION;
  /*#########################################################################################################*/

  procedure ININVOICESSPECS_SPLIT
  /*
  Спецификация. Отделить от текущей записи с заданным количеством
  */
  (
   nRN                in number
  ,nQUANT_NEW         in number  /* Количество отделямое в новую спецификацию */
  ) 
  is
    rRow              ininvoicesspecs%rowtype;
    rRowNew           ininvoicesspecs%rowtype;
    nQuant            pkg_std.tnumber := 0; 
    nQuantOld         pkg_std.tnumber := 0; 
    rInInvoicesSpC    ininvoicesspc%rowtype;
    rInInvoicesSpCNew ininvoicesspc%rowtype;
    rDicNomns         dicnomns%rowtype;
    rDicMUnts         dicmunts%rowtype;
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow    := ininvoicesspecs_get(nrn => nRN);
    /* Считывание номенклатуры и единицы измерения */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rRow.nomen );
    rDicMUnts := udo_pkg_get.row_dicmunts( nrn => rDicNomns.umeas_main );

    /* Новая запись спецификации */
    rRowNew := rRow;

    /* Проверки */
    if nvl(nQUANT_NEW, 0) = 0 then
      p_exception(0, 'Отделяемо количество <%s> не задано или равно нулю.%s%s'
                 ,nQUANT_NEW
                 ,cr||f_docdescrs_get_description('IncomingInvoicesSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('IncomingInvoices', rRow.prn)); 
    elsif rRow.quant < nQUANT_NEW then
      p_exception(0, 'Отделяемо количество <%s> больше исходного <%s>. %s%s'
                 ,nQUANT_NEW
                 ,rRow.quant
                 ,cr||f_docdescrs_get_description('IncomingInvoicesSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('IncomingInvoices', rRow.prn)); 
    end if;

    
    /* Количество до отделения */
    nQuant := rRow.quant; 

    /* Количество после отделения в старой спецификации */
    nQuantOld := nQuant - nQUANT_NEW;

    /* Заполнение переменных для новой записи */
    rRowNew.summ     := rRow.summ     / nQuant * nQUANT_NEW;
    rRowNew.summtax  := rRow.summtax  / nQuant * nQUANT_NEW;
    rRowNew.summ_nds := rRow.summ_nds / nQuant * nQUANT_NEW;
    /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
    if rDicMUnts.meas_type = 1 then
      rRowNew.quant := round( nQUANT_NEW );
    else
      rRowNew.quant := nQUANT_NEW;
    end if;

    /* Заполнение переменных для текущей записи */
    rRow.summ     := rRow.summ     / nQuant * nQuantOld;
    rRow.summtax  := rRow.summtax  / nQuant * nQuantOld;
    rRow.summ_nds := rRow.summ_nds / nQuant * nQuantOld;
    /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
    if rDicMUnts.meas_type = 1 then
      rRow.quant := round( nQuantOld );
    else
      rRow.quant := nQuantOld;
    end if;

    /* Исправление текущей записи */
    ininvoicesspecs_base_update(rrow => rRow, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber);
    /* Проверка после исправления */
    ininvoicesspecs_aupdate(nrn => rRow.rn, ncompany => rRow.company);

    /* Добавление новой записи */
    ininvoicesspecs_base_insert(rrow => rRowNew, nrn => rRowNew.rn, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber);
    /* Проверка после добавления */
    ininvoicesspecs_ainsert(nrn => rRowNew.rn, ncompany => rRowNew.company);

    /* По калькуляциям текущей записи */
    for c in (select *
                from ininvoicesspc t
               where t.prn = rRow.rn)
    loop
      /* Исправление калькуляций в старой спецификации */
      rInInvoicesSpC := c;
      rInInvoicesSpC.quant_plan := rInInvoicesSpC.quant_plan * nQuantOld / nQuant;
      rInInvoicesSpC.quant_fact := rInInvoicesSpC.quant_fact * nQuantOld / nQuant;
      /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
      if rDicMUnts.meas_type = 1 then
        rInInvoicesSpC.quant_plan := round( rInInvoicesSpC.quant_plan );
        rInInvoicesSpC.quant_fact := round( rInInvoicesSpC.quant_fact );
      end if;
      ininvoicesspc_base_update(rrow => rInInvoicesSpC);
      /* Проверка после исправления */
      ininvoicesspc_aupdate(nrn => rInInvoicesSpC.rn, ncompany => rInInvoicesSpC.company);

      /* Добавление калькуляций в новую спецификацию */
      rInInvoicesSpCNew := c;
      rInInvoicesSpCNew.quant_plan := rInInvoicesSpCNew.quant_plan * nQUANT_NEW / nQuant;
      rInInvoicesSpCNew.quant_fact := rInInvoicesSpCNew.quant_fact * nQUANT_NEW / nQuant;
      /* если единица измерения номенклатуры целая, то округляем расчитанное количество */
      if rDicMUnts.meas_type = 1 then
        rInInvoicesSpCNew.quant_plan := round( rInInvoicesSpCNew.quant_plan );
        rInInvoicesSpCNew.quant_fact := round( rInInvoicesSpCNew.quant_fact );
      end if;
      
      /* Если расчитанное количество калькуляции не равно нулю */
      if cmp_num( rInInvoicesSpCNew.quant_plan, 0 ) != 1 then
        rInInvoicesSpCNew.prn := rRowNew.rn;
        /* Добавление */
        ininvoicesspc_base_insert(rrow => rInInvoicesSpCNew, nrn => rInInvoicesSpCNew.rn);
        /* Проверка после добавления */
        ininvoicesspc_aupdate(nrn => rInInvoicesSpCNew.rn, ncompany => rInInvoicesSpCNew.company);
        end if;
    end loop;               
    
  end ININVOICESSPECS_SPLIT;
  /*#########################################################################################################*/

  function ININVOICESSPBUFF_GET
  /*
  Спецификация (буфер). Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoicesspbuff%rowtype
  is
    rRow ininvoicesspbuff%rowtype;
  begin
    begin
      select * into rRow from ininvoicesspbuff where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ININVOICESSPBUFF');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESSPBUFF'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end ININVOICESSPBUFF_GET;
  /*#########################################################################################################*/

  procedure ININVOICESSPBUFF_UPDATE
  /*
  Спецификация (буфер). Исправление
  */
  (
   rV_ROW           in v_ininvoicesspbuff%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ) 
  is
  begin
    p_ininvoicesspbuff_update( ncompany       => rV_ROW.NCOMPANY
                              ,nrn            => rV_ROW.NRN
                              ,snomen         => rV_ROW.SNOMEN
                              ,smodif         => rV_ROW.SMODIF
                              ,snomnpack      => rV_ROW.SNOMNPACK
                              ,spack          => rV_ROW.SPACK
                              ,sarticle       => rV_ROW.SARTICLE
                              ,staxgr         => rV_ROW.STAXGR
                              ,sstore         => rV_ROW.SSTORE
                              ,nquant         => rV_ROW.NQUANT
                              ,nquantalt      => rV_ROW.NQUANTALT
                              ,nprice         => rV_ROW.NPRICE
                              ,npricemeas     => rV_ROW.NPRICEMEAS
                              ,nsumm          => rV_ROW.NSUMM
                              ,nsummtax       => rV_ROW.NSUMMTAX
                              ,nsumm_nds      => rV_ROW.NSUMM_NDS
                              ,nautocalc_sign => rV_ROW.NAUTOCALC_SIGN
                              ,dsrok          => rV_ROW.DSROK
                              ,ssertificate   => rV_ROW.SSERTIFICATE
                              ,snote          => rV_ROW.SNOTE
                              ,dbegindate     => rV_ROW.DBEGINDATE
                              ,denddate       => rV_ROW.DENDDATE
                              ,ssernumb       => rV_ROW.SSERNUMB
                              ,sbarcode       => rV_ROW.SBARCODE
                              ,scountry       => rV_ROW.SCOUNTRY
                              ,sgtd           => rV_ROW.SGTD
                              ,sproducer      => rV_ROW.SPRODUCER
                              ,nstorage_time  => rV_ROW.NSTORAGE_TIME
                              ,sumeas_storage => rV_ROW.SUMEAS_STORAGE
                              ,ndiscount      => rV_ROW.NDISCOUNT
                              ,soriginal_name => rV_ROW.SORIGINAL_NAME
                              ,dprod_date     => rV_ROW.DPROD_DATE
                              ,nflag_del_calc => nFLAG_DEL_CALC );
  end ININVOICESSPBUFF_UPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPBUFF_BASE_INSERT
  /*
  Спецификация (буфер). Добавление базовое
  */
  (
   rROW   in ininvoicesspbuff%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_ininvoicesspbuff_base_insert( ncompany       => rRow.company
                                   ,nprn           => rRow.prn
                                   ,nnomen         => rRow.nomen
                                   ,nnomnpack      => rRow.nomnpack
                                   ,nmodif         => rRow.modif
                                   ,npack          => rRow.pack
                                   ,narticle       => rRow.article
                                   ,ntaxgr         => rRow.taxgr
                                   ,nstore         => rRow.store
                                   ,nquant         => rRow.quant
                                   ,nquantalt      => rRow.quantalt
                                   ,nprice         => rRow.price
                                   ,npricemeas     => rRow.pricemeas
                                   ,nsumm          => rRow.summ
                                   ,nsummtax       => rRow.summtax
                                   ,nsumm_nds      => rRow.summ_nds
                                   ,nautocalc_sign => rRow.autocalc_sign
                                   ,dsrok          => rRow.srok
                                   ,ssertificate   => rRow.sertificate
                                   ,snote          => rRow.note
                                   ,dbegindate     => rRow.begindate
                                   ,denddate       => rRow.enddate
                                   ,ssernumb       => rRow.sernumb
                                   ,sbarcode       => rRow.barcode
                                   ,ncountry       => rRow.country
                                   ,sgtd           => rRow.gtd
                                   ,nproducer      => rRow.producer
                                   ,nstorage_time  => rRow.storage_time
                                   ,numeas_storage => rRow.umeas_storage
                                   ,ndiscount      => rRow.discount
                                   ,soriginal_name => rRow.original_name
                                   ,dprod_date     => rRow.prod_date
                                   ,nmdmnomen      => rRow.mdmnomen
                                   ,nrn            => nRN );
  end ININVOICESSPBUFF_BASE_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICESSPBUFF_BASE_UPDATE
  /*
  Спецификация (буфер). Исправление базовое
  */
  (
   rROW   in ininvoicesspbuff%rowtype
  ) 
  is
  begin
    p_ininvoicesspbuff_base_update(ncompany       => rROW.COMPANY
                                  ,nrn            => rROW.RN
                                  ,nnomen         => rROW.NOMEN
                                  ,nnomnpack      => rROW.NOMNPACK
                                  ,nmodif         => rROW.MODIF
                                  ,npack          => rROW.PACK
                                  ,narticle       => rROW.ARTICLE
                                  ,ntaxgr         => rROW.TAXGR
                                  ,nstore         => rROW.STORE
                                  ,nquant         => rROW.QUANT
                                  ,nquantalt      => rROW.QUANTALT
                                  ,nprice         => rROW.PRICE
                                  ,npricemeas     => rROW.PRICEMEAS
                                  ,nsumm          => rROW.SUMM
                                  ,nsummtax       => rROW.SUMMTAX
                                  ,nsumm_nds      => rROW.SUMM_NDS
                                  ,nautocalc_sign => rROW.AUTOCALC_SIGN
                                  ,dsrok          => rROW.SROK
                                  ,ssertificate   => rROW.SERTIFICATE
                                  ,snote          => rROW.NOTE
                                  ,dbegindate     => rROW.BEGINDATE
                                  ,denddate       => rROW.ENDDATE
                                  ,ssernumb       => rROW.SERNUMB
                                  ,sbarcode       => rROW.BARCODE
                                  ,ncountry       => rROW.COUNTRY
                                  ,sgtd           => rROW.GTD
                                  ,nproducer      => rROW.PRODUCER
                                  ,nstorage_time  => rROW.STORAGE_TIME
                                  ,numeas_storage => rROW.UMEAS_STORAGE
                                  ,ndiscount      => rROW.DISCOUNT
                                  ,soriginal_name => rROW.ORIGINAL_NAME
                                  ,dprod_date     => rROW.PROD_DATE
                                  ,nmdmnomen      => rROW.MDMNOMEN);
  end ININVOICESSPBUFF_BASE_UPDATE;
  /*#########################################################################################################*/  

  function ININVOICESSPC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return ininvoicesspc%rowtype
  is
    rRow ininvoicesspc%rowtype;
  begin
    begin
      select * into rRow from ininvoicesspc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ININVOICESSPC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESSPC'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end ININVOICESSPC_GET;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_AINSERT
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
    /* Добавление, исправление, удаление */
    ininvoicesspc_check_iud(nrn => nRN);
    /* Базовая */
    ininvoicesspc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end ININVOICESSPC_AINSERT;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BUPDATE
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
  end ININVOICESSPC_BUPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_AUPDATE
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
    /* Добавление, исправление, удаление */
    ininvoicesspc_check_iud(nrn => nRN);
    /* Базовая */
    ininvoicesspc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end ININVOICESSPC_AUPDATE;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BDELETE
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
    ininvoicesspc_check_iud(nrn => nRN);

  end ININVOICESSPC_BDELETE;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow               ininvoicesspc%rowtype;
   rInInvoicesSpecs   ininvoicesspecs%rowtype;
   rDicNomns          dicnomns%rowtype;
   rDicMUnts          dicmunts%rowtype;
   nSPZ               pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow             := ininvoicesspc_get(nrn => nRN);
    rInInvoicesSpecs := ininvoicesspecs_get( nrn => rRow.prn );
    rDicNomns        := usr_pkg_dicnomns.dicnomns_get( nrn => rInInvoicesSpecs.nomen );
    rDicMUnts        := udo_pkg_get.row_dicmunts( nrn => rDicNomns.umeas_main );

    /* Лицевой счёт */
    if rRow.faceaccount is null then
      p_exception(0, 'Поле "Лицевой счёт (заказ)" не заполнено в калькуляции. %s%s'
                 ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rRow.prn)); 
    end if;
    /* Должны быть этапы в проектах */
    begin
      select prst.rn 
        into nSPZ 
        from PROJECTSTAGE prst 
       where prst.faceacc = rRow.faceaccount
          or rRow.faceaccount in (8566334); -- Склад СЗ
    exception
      when NO_DATA_FOUND then
      p_exception(0, 'Выбранный в калькуляции Лицевой счёт (заказ) отсутствует в этапах проектов. %s%s'
                 ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rRow.prn)); 
    end;

    /* Количество. План */
    if nvl(rRow.quant_plan, 0) = 0 then
      p_exception(0, 'Поле "Количество. План" не заполнено в калькуляции. %s'
                 ,cr||cr||f_docdescrs_get_description('IncomingInvoicesSpecs', rRow.prn)); 
    end if;                 

    /* Количество дробное при том, что едицина измерения целая */
    if  rDicMUnts.meas_type = 1
    and nvl( rRow.quant_plan, 0 ) != round( nvl( rRow.quant_plan, 0 ) )  then
      p_exception(0, 'Количество <%s> в калькуляции не должно быть дробным для единицы измерения <%s>. %s%s'
                 ,rRow.quant_plan
                 ,rDicMUnts.meas_mnemo
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoicesSpecsCalcs', ndocument => rRow.rn ) 
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'IncomingInvoicesSpecs', ndocument => rRow.prn ) ); 
    end if;

  end ININVOICESSPC_CHECK_BASE;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_CHECK_IUD
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
      select h.rn , h.status, s.rn
        into nHead, nHeadState , nSpec
        from ininvoicesspc    c
            ,ininvoicesspecs  s
            ,ininvoices       h
       where c.rn = nRN
         and s.rn  = c.prn
         and h.rn   = s.prn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'ININVOICESSPC');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'ININVOICESSPC'))
                   ,cr||sqlerrm);
    end;

    /* Статус документа отличен от "Не утверждён" */
    if nHeadState != 0 --and utilizer != 'KHOK'
    and not usr_pkg_common.is_lists_intersect(slist1 => 'ININVOICESSPC_CHECK_IUD.1', slist2 => usr_pkg_pub_const.sexceptionlist) 
    then 
      /* сообщение */
      p_exception(0, 'Запрещены изменения документа в статусе <%s>. %s%s.'
                 ,ininvoices_get_status_name(nstate => nHeadState)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoicesSpecs', ndocument => nSpec)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => nHead));
    end if;

    /* Очистка списка исключений */
    if usr_pkg_pub_const.sexceptionlist is not null then
      usr_pkg_pub_const.sexceptionlist := null;
    end if;

  end ININVOICESSPC_CHECK_IUD;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое
  */
  (
   rROW   in ininvoicesspc%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_ininvoicesspc_base_insert(ncompany      => rROW.COMPANY
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

  end ININVOICESSPC_BASE_INSERT;
  /*#########################################################################################################*/

  procedure ININVOICESSPC_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое
  */
  (
   rROW   in ininvoicesspc%rowtype
  ) 
  is
  begin
    p_ininvoicesspc_base_update(nrn           => rROW.RN
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
  end ININVOICESSPC_BASE_UPDATE;
  /*#########################################################################################################*/

end USR_PKG_ININVOICES;
/*
CREATE PUBLIC SYNONYM USR_PKG_ININVOICES FOR USR_PKG_ININVOICES;
GRANT EXECUTE ON USR_PKG_ININVOICES TO PUBLIC;
*/
/
