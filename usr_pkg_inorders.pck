create or replace package USR_PKG_INORDERS IS
  /*
  Package предназначен для работы с разделом "Приходные ордера". Степанов М. 12/02/2022
  IncomingOrders            INORDERS          IO
  IncomingOrdersSpecs       INORDERSPECS      IOS
  IncomingOrdersSpecsCalcs  INORDERSPECSCLC   IOSC
  */

  /*#########################################################################################################*/

  function INORDERS_GET
  /*
  Заголовок. Считывание
  */
  (
   NRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return INORDERS%ROWTYPE;
  /*#########################################################################################################*/

  procedure INORDERS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_BASFACT
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_AASFACT
  /*
  Заголовок. Проверка после отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
 */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
 */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_ATRANSINVDEPT
  /*
  Заголовок. После формирования РН в подразделения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_ARINVTOSUP
  /*
  Заголовок. Проверка после формирования возвратной накладной в подразделения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_BMAKEPAYACCIN
  /*
  Заголовок. Формирование входящих счетов на оплату. Перед
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_JOINS
  /*
  Заголовок. Считывание RN полей
  */
  (
   rV_ROW   in  v_inorders%rowtype
  ,rROW     in out inorders%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDERS_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW    in out v_inorders%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure INORDERS_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_inorders%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure INORDERS_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW     in inorders%rowtype
  ,nDUP_RN  in number default null
  ,nRN      out number
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure INORDERS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW    in INORDERS%rowtype
  );
  /*#########################################################################################################*/

  /*** процедура пересчета исполнения у родительских документов 
  по мотивам P_INORDERS_BSET_STATUS ***/
  procedure INORDERS_RECALC_PERFORMANCE
  (
    nCOMPANY    in number,
    dWORK_DATE  in date,
    nR_RN       in number, -- RN приходного ордера
    nR_OSTATUS  in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
    nR_NSTATUS  in number  -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
  );
 /*#########################################################################################################*/

  procedure INORDERS_MAKE_TRANSINVDEPT
  /*
  Заголовок. Сформировать расходные накладные на отпуск в подразделения
  */
  (
   nRN          in number
  ,nCOMPANY     in number
  ,dDOCDATE     in date
  ,sCATALOG     in varchar2
  ,sSTOPER      in varchar2
  ,sSHEEPVIEW   in varchar2
  ,sFACEACC     in varchar2
  ,sIN_STORE    in varchar2
  ,sIN_STOPER   in varchar2
  ,sSUBDIV      in varchar2
  );
 /*#########################################################################################################*/

  procedure INORDERS_MAKE_RINVTOSUP
  /*
  Заголовок. Сформировать расходные накладные на возврат поставщикам
  */
  (
   nRN          in number
  ,nCOMPANY     in number
  );
  /*#########################################################################################################*/

  procedure INORDERS_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  );
  /*#########################################################################################################*/

  procedure INORDERS_RECREATE_IOSC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  );
  /*#########################################################################################################*/

  function INORDERS_GET_STATUS_NAME
  /*
  Заголовок. Наименование состояния
  */
  (
   nSTATE    in number 
  ) 
  return varchar2;
  /*#########################################################################################################*/

  procedure INORDERS_CLEAR_FOR_UPDATE
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

  procedure INORDERSBUFF_BASE_INSERT
  /*
  Заголовок (буфер). Добавление базовое
  */
  (
   rROW    in inordersbuff%rowtype
  ,nRN     out number 
  );
  /*#########################################################################################################*/

  procedure INORDERSBUFF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW    in inordersbuff%rowtype
  );
  /*#########################################################################################################*/

  function INORDERSPECS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0
  ) 
  return INORDERSPECS%ROWTYPE;
  /*#########################################################################################################*/
  
  PROCEDURE INORDERSPECS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
  ,nTOO_MANY_ROWS     in number default 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
  ,nPRN               in number
  ,nNOMPACK           in number default null
  ,nNOMMODIF          in number default null
  ,nNOMMODIFPACK      in number default null
  ,nTAXGR             in number default null
  ,nQUANT             in number default null
  ,nQUANTALT          in number default null
  ,nPRICE             in number default null
  ,nARTICLE           in number default null
  ,sSERNUMB           in varchar2 default null
  ,nCOUNTRY           in number   default null
  ,sGTD               in varchar2 default null
  ,rROW               out inorderspecs%rowtype 
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_IOSC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in inorderspecs%rowtype
  );
/*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_INDOC
  /*
  Спецификация. Проверка с приходной накладной
  */
  (
   rROW           in inorderspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_OUT_DOCS
  /*
  Спецификация. Проверка выходных документов
  */
  (
   rROW             inorderspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_JOINS
  /*
  Спецификация. Считывание RN полей
  */
  (
   rV_ROW   in  v_inorderspecs%rowtype
  ,rROW     in out inorderspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW       in inorderspecs%rowtype
  ,nDUP_RN    in number
  ,nDUP_CLC   in number
  ,nRN        out number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW     in inorderspecs%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_SEPARATION
  /*
  Спецификация. Разбивка на строки с одной штукой
  */
  (
   nRN                in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_MSG_SEND
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW         in inorderspecs%rowtype
  ,rROW_BEFORE  in inorderspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDSPBUFF_BASE_INSERT
  /*
  Спецификация (буфер). Добавление базовое
  */
  (
   rROW         in inordspbuff%rowtype
  ,nSOURCE_RN   in number
  ,nRN          out number 
  );
  /*#########################################################################################################*/

  procedure INORDSPBUFF_BASE_UPDATE
  /*
  Спецификация (буфер). Исправление базовое
  */
  (
   rROW               in inordspbuff%rowtype
  ,nFLAG_DEL_CALC     in number default 0
  );
  /*#########################################################################################################*/

  procedure INORDSPBUFF_UPDATE_PCR
  /*
  Спецификация. Исправление поля "Правило расчета учетной цены" (PRICE_CALC_RULE)
  */
  (
   nFLAGSMART         in number default 0
  ,nRN                in number
  ,nPRICE_CALC_RULE   in number /* 0 - включают, 1 - не включают */
  );
  /*#########################################################################################################*/  

  function INORDERSPECSCLC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0
  ) 
  return inorderspecsclc%rowtype;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_AINSERT
  /*
  Спецификация (калькуляция). После добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BUPDATE
  /*
  Спецификация (калькуляция). Перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_AUPDATE
  /*
  Спецификация (калькуляция). После исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BDELETE
  /*
  Спецификация (калькуляция). Перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_JOINS
  /*
  Калькуляция. Считывание RN полей
  */
  (
   rV_ROW   in  v_inorderspecsclc%rowtype
  ,rROW     in out inorderspecsclc%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое
  */
  (
   rROW   in INORDERSPECSCLC%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое
  */
  (
   rROW   in inorderspecsclc%rowtype
  );
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_GET_IIVSC_QNT
  /*
  Спецификация (калькуляция). Получить количество по калькуляциям выходных документов
  */
  (
   nRN          in number
  ,nQUANT_PLAN  out number
  ,nQUANT_FACT  out number
  );
  /*#########################################################################################################*/

  procedure INORDERSPECS_UPDATE_PCR
  /*
  Спецификация. Исправление поля "Правило расчета учетной цены" (PRICE_CALC_RULE)
  */
  (
   nFLAGSMART         in number default 0
  ,nRN                in number
  ,nPRICE_CALC_RULE   in number /* 0 - включают, 1 - не включают */
  );
  /*#########################################################################################################*/

end USR_PKG_INORDERS;

/*
CREATE PUBLIC SYNONYM USR_PKG_INORDERS FOR USR_PKG_INORDERS;
GRANT EXECUTE ON USR_PKG_INORDERS TO PUBLIC;
*/
/
create or replace package body USR_PKG_INORDERS is

  /*#########################################################################################################*/

  function INORDERS_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0
  ) 
  return inorders%rowtype
  is
    rRow inorders%rowtype;
  begin
    begin
      select * into rRow from inorders where RN = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'INORDERS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERS')) 
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end INORDERS_GET;
  /*#########################################################################################################*/

  procedure INORDERS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow     inorders%rowtype;*/
  begin
    /* Считывание */
    /* rRow := INORDERS_GET(nRN); */

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    inorders_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* По спецификациям */
    for c in (select * from inorderspecs where prn = nRN) 
    loop
      /* проверка спецификации */
      inorderspecs_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;

  end INORDERS_AINSERT;
  /*#########################################################################################################*/

  procedure INORDERS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
    /* Считывание */
    /* usr_pkg_pub_const.rinorders := INORDERS_GET(nRN); */
  end INORDERS_BUPDATE;
  /*#########################################################################################################*/

  procedure INORDERS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     INORDERS%ROWTYPE;
  begin
    /* Считывание */
    /* rRow := INORDERS_GET(nRN);*/

    /* ПРОВЕРКИ */
    /* Базовая */
    inorders_check_base(nrn => nRN, ncompany => nCOMPANY);
/*
    -- Если исправляются тип, префикс, номер, дата договора
    if cmp_num(rRow.INDOCTYPE, USR_PKG_PUB_CONST.RINORDERS.INDOCTYPE) != 1
    or cmp_vc2(rRow.INDOCPREF, USR_PKG_PUB_CONST.RINORDERS.INDOCPREF) != 1
    or cmp_vc2(rRow.INDOCNUMB, USR_PKG_PUB_CONST.RINORDERS.INDOCNUMB) != 1
    or cmp_dat(rRow.INDOCDATE, USR_PKG_PUB_CONST.RINORDERS.INDOCDATE) != 1 then
      -- проверка префикса и номера
      INORDERS_CHECK_PREF_NUMB(rRow);
    end if;  
*/

  end INORDERS_AUPDATE;
  /*#########################################################################################################*/

  procedure INORDERS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     inorders%rowtype;
  begin
    /* Считывание */
     rRow := inorders_get( nrn => nRN ); 

    /* ПРОВЕРКИ */
    /* Свойство "Заблокирован" равно "Да" */  
    if cmp_vc2( usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 269610684, ndocument => rRow.rn ), 'Да' ) = 1 then
      p_exception(0, 'Документ заблокирован. Обратитесь в бухгалтерию. %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn ) ); 
    end if;
    
    /* По спецификациям */
    for c in ( select * from inorderspecs where prn = nRN )
    loop
      /* Проверка */
      inorderspecs_bdelete( nrn => c.rn, ncompany => c.company );
    end loop;
    
  end INORDERS_BDELETE;
  /*#########################################################################################################*/

  procedure INORDERS_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     inorders%rowtype;
  begin
    /* Считывание */  
    rRow := inorders_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Запрет отработки как план */
    if rRow.docstatus = 1 then
      P_EXCEPTION(0, 'Запрещено отрабатывать документ как план %s.'||CR||'%s'
                 ,F_DOCDESCRS_GET_DESCRIPTION('IncomingOrders', rRow.rn)
                 ); 
    end if;

  end INORDERS_AASPLAN;
  /*#########################################################################################################*/

  procedure INORDERS_BASFACT
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
  end INORDERS_BASFACT;
  /*#########################################################################################################*/

  procedure INORDERS_AASFACT
  /*
  Заголовок. Проверка после отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          inorders%rowtype;
    nDicnomns     pkg_std.tref; 
    rDicnomns     dicnomns%rowtype;
    rDicGNomn     dicgnomn%rowtype;
    
    nNumber       pkg_std.tnumber; 
  begin
    /* Заголовок */
    rRow := inorders_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */
    /* Копирование доп.данных из свойств спецификации в приходную партию */
    usr_pkg_document.spec_props_copy_to_gp( nprn => rRow.rn );

    /* ПРОВЕРКИ */
    /* Базовая */
    inorders_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Дата отработки равна дате документа */
    if cmp_dat(rRow.work_date, rRow.indocdate) != 1 then
      p_exception(0, 'Дата отработки %s не равна дате документа %s.'||CR||'%s'
                 ,D2S(rRow.work_date)
                 ,D2S(rRow.indocdate)
                 ,f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)
                 ); 
    /* Дата отработки больше текущей даты */
    elsif cmp_dat_minmax( rRow.work_date, sysdate ) > 0 then
      p_exception(0, 'Дата отработки %s больше текущей даты %s.'||cr||'%s'
                 ,d2s( rRow.work_date )
                 ,d2s( sysdate )
                 ,f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn) ); 
    end if;

    /* По спецификациям */
    for c in (select * from inorderspecs where prn = rRow.rn)
    loop

      /* Если не заданы даты: изготовления */
      if usr_pkg_docs_props_vals.get_val_date( ndoc_prop => 211014548, ndocument => c.rn ) is null 
      and nvl( usr_pkg_process.process_get, 'null') not in ( 'USR_P_DOCS_REPLACE_FACEACC' ) then

        /* номенклатура */
        nDicnomns := usr_pkg_dicnomns.nommodif_get_prn_by_rn(nflagsmart => 0, nrn => c.nommodif);
        rDicnomns := usr_pkg_dicnomns.dicnomns_get(nrn => nDicnomns, nflagsmart => 0);

        /* группа ТМЦ */
        if rDicnomns.group_code is not null then
          select * into rDicGNomn from dicgnomn where rn = rDicnomns.group_code; 
        end if;

        /* если группа ТМЦ "ПП, ЭРИ" */
        if rDicGNomn.rn is not null and rDicGNomn.rn in (13885759, 13884309) then
          p_exception(0, 'Не заполнено свойство спецификации: "Дата изготовления (дата)". Группа номенклатуры <%s>.%s'
                     ,rDicGNomn.group_name
                     ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', c.rn)
                     ); 
        end if;
      end if;

      /* Если складская операция НЕ "ПриходВнешОХ" */
      if rRow.stopertype != 52984971 then
        /* проверка калькуляций */
        inorderspecs_check_iosc(rrow => c);
        /* проверка родительской спецификации */
        inorderspecs_check_indoc( rrow => c );
      end if;

    end loop;

  end INORDERS_AASFACT;
  /*#########################################################################################################*/

  procedure INORDERS_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Удаление дополнительных данных приходной партии из раздела Сертификаты в приходных партиях спецификаций */
    for c in (select distinct crts.prn
                from inorderspecs     t
                    ,goodssupply      gs
                    ,certificationsp  crts
               where t.prn      = nRN
                 and gs.rn      = t.goodssupply
                 and crts.party = gs.prn)
    loop
      p_certification_base_delete(ncompany => nCOMPANY, nrn => c.prn);
    end loop;             

  end INORDERS_BCANCEL;
  /*#########################################################################################################*/

  procedure INORDERS_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end INORDERS_ACANCEL;
  /*#########################################################################################################*/

  procedure INORDERS_ATRANSINVDEPT
  /*
  Заголовок. После формирования РН в подразделения
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
      usr_pkg_transinvdept.transinvdept_ainsert(nrn => c.out_document0, ncompany => nCOMPANY);
    end loop;

  end INORDERS_ATRANSINVDEPT;
  /*#########################################################################################################*/

  procedure INORDERS_ARINVTOSUP
  /*
  Заголовок. Проверка после формирования возвратной накладной в подразделения
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
      usr_pkg_rinvtosup.rinvtosup_ainsert(nrn => c.out_document0, ncompany => nCOMPANY);
    end loop;
    
  end INORDERS_ARINVTOSUP;
  /*#########################################################################################################*/

  procedure INORDERS_BMAKEPAYACCIN
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
               ,cr||f_docdescrs_get_description( sunitcode => 'IncomingOrdersSpecs', ndocument => nRN ) ); 

  end INORDERS_BMAKEPAYACCIN;
  /*#########################################################################################################*/

  procedure INORDERS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            inorders%rowtype;
    nInInvoices     pkg_std.tref; 
    rInInvoices     ininvoices%rowtype;
    nSummTax        pkg_std.tsumm; 
    nSumm           pkg_std.tsumm; 
    
    nNumber         pkg_std.tnumber; 
  begin
    /* Заголовок */
    rRow := inorders_get(nrn => nRN);
    /* Связанная приходная накладная. Должна быть только одна  */
    nInInvoices := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'IncomingOrders'
                                                        ,nout_document  => rRow.rn
                                                        ,sin_unitcode   => 'IncomingInvoices');
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Свойство "Заблокирован" равно "Да" */  
    if cmp_vc2( usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 269610684, ndocument => rRow.rn), 'Да' ) = 1 then
      p_exception(0, 'Документ заблокирован. Обратитесь в бухгалтерию. %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
    end if;

    /* Параметр "Цены включают налоги" */  
    if rRow.signtax = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" должен быть заполнен. Для исправления выполните процедуру <Исправить признак "Цены включают налоги">. %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
    end if;

    /* Склад ВремПеремещение */  
    if rRow.store = 20300310 then
      p_exception(0, 'Запрещено указывать склад <%s>. %s'
                 ,cr||cr||f_dicstore_get_numb(nstore => rRow.store)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
    end if;

    /* Приходная накладная есть */
    if nInInvoices is not null then
      /* Считывание приходной накладной */
      rInInvoices := usr_pkg_ininvoices.ininvoices_get(nrn => nInInvoices);
      /* Суммы товарных спецификаций приходной накладной */
      nSummTax := usr_pkg_ininvoices.ininvoices_get_summ_nomen_type( nrn => rInInvoices.rn, nnomen_type => 1, nsumm => nSumm, nsumm_nds => nNumber );

      /* Каталог текущего документа 'Метрология' */
      if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => usr_pkg_pub_const.nio_cat_mtlg) then
        /* каталог входного документа НЕ 'Метрология' */
        if not usr_pkg_common.is_crn_in_hiercrn(nCRN => rInInvoices.crn, shier_crn_list => usr_pkg_pub_const.niiv_cat_mtlg) then
          p_exception(0, 'Каталог документа <%s> не равен каталогу входного документа <%s>. %s'
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rInInvoices.crn)
                     ,cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
        end if;
      /* Каталог текущего документа НЕ 'Метрологии' */
      else      
        /* каталог входного документа 'Метрология' */
        if usr_pkg_common.is_crn_in_hiercrn(nCRN => rInInvoices.crn, shier_crn_list => usr_pkg_pub_const.niiv_cat_mtlg) then
          p_exception(0, 'Каталог документа <%s> не равен каталогу входного документа <%s>. %s'
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn)
                     ,get_acatalog_name_id(nflag_smart => 0, nrn => rInInvoices.crn)
                     ,cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
        end if;
      end if;

      /* Проверка сумм с приходной накладной */
      if cmp_num( nSummTax, rRow.plansumtax ) != 1 
      or cmp_num( nSumm   , rRow.plansum    ) != 1 then
        p_exception(0, 'Сумма приходного ордера не равна сумме товарных спецификаций приходной накладной: с НДС "%s", без НДС "%s". %s%s %s'
                   ,usr_f_n2ss( nSummTax )
                   ,usr_f_n2ss( nSumm )
                   ,cr||usr_f_n2ss( rRow.plansumtax )
                   ,cr||usr_f_n2ss( rRow.plansum )
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn) ); 
      end if;

    /* Приходной накладной нет */
    else
      /* если складская операция НЕ "ПриходВнешОХ"
       , префикс документа НЕ "Остатки"
       , каталог НЕ "ИМПОРТ_1С"
       , процедура не Исправление ЛС в заказе поставщикам */
      if rRow.stopertype != 52984971 
      and cmp_vc2(trim(rRow.indocpref), 'Остатки') != 1 
      and rRow.crn not in (13125642) 
      and nvl(usr_pkg_process.process_get, 'null') not in ( 'USR_P_DOCS_REPLACE_FACEACC' ) then
        p_exception(0, 'Приходный ордер не связан с приходной накладной. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.rn)); 
      end if;
    end if;

  end INORDERS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure INORDERS_JOINS
  /*
  Заголовок. Считывание RN полей
  */
  (
   rV_ROW   in  v_inorders%rowtype
  ,rROW     in out inorders%rowtype
  ) 
  is
  begin
     rROW.company := rV_ROW.ncompany;
     p_inorders_joins(ncompany      => rV_ROW.ncompany
                     ,sjur_pers     => rV_ROW.sjur_pers
                     ,njur_pers     => rROW.jur_pers
                     ,scontragent   => rV_ROW.sseller
                     ,ncontragent   => rROW.contragent
                     ,sfaceacc      => rV_ROW.sfaceacc
                     ,nfaceacc      => rROW.faceacc
                     ,sgraphpoint   => rV_ROW.sgraphpoint
                     ,ngraphpoint   => rROW.graphpoint
                     ,sagent        => rV_ROW.sagent
                     ,nagent        => rROW.agent
                     ,scurrency     => rV_ROW.scurrency
                     ,ncurrency     => rROW.currency
                     ,sstore        => rV_ROW.sstore
                     ,nstore        => rROW.store
                     ,sparty        => rV_ROW.sparty
                     ,nparty        => rROW.party
                     ,sstopertype   => rV_ROW.sstopertype
                     ,nstopertype   => rROW.stopertype
                     ,sdoctype1     => rV_ROW.sindoctype
                     ,ndoctype1     => rROW.indoctype
                     ,sdoctype2     => rV_ROW.sdirectdoctype
                     ,ndoctype2     => rROW.directdoctype
                     ,sdoctype3     => rV_ROW.sinvdoctype
                     ,ndoctype3     => rROW.invdoctype
                     ,sdoctype4     => rV_ROW.sconfdoctype
                     ,ndoctype4     => rROW.confdoctype
                     ,sagnfifo      => rV_ROW.sagnfifo
                     ,nagnfifo      => rROW.agnfifo
                     ,spayconf_type => rV_ROW.spayconf_type
                     ,npayconf_type => rROW.payconf_type
                     ,sreg_agent    => rV_ROW.sreg_agent
                     ,nreg_agent    => rROW.reg_agent
                     /* Обновление 2024/03/28 */
                     ,sCUSTOMER     => rV_ROW.sCUSTOMER       /*  Заказчик */
                     ,nCUSTOMER     => rROW.CUSTOMER          /*  Заказчик */
                     ,sSHIP_DOCTYPE => rV_ROW.sSHIP_DOCTYPE   /*  Документ об отгрузке */
                     ,nSHIP_DOCTYPE => rROW.SHIP_DOCTYPE      /*  Документ об отгрузке */
                     ,sINSURED      => rV_ROW.sINSURED        /*  Страхователь */
                     ,nINSURED      => rROW.INSURED           /*  Страхователь */
                     );
  end INORDERS_JOINS;
  /*#########################################################################################################*/

  procedure INORDERS_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW    in out v_inorders%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    p_inorders_insert(ncompany       => rV_ROW.NCOMPANY
                     ,ncrn           => rV_ROW.NCRN
                     ,sjur_pers      => rV_ROW.SJUR_PERS
                     ,sseller        => rV_ROW.SSELLER
                     ,sfaceacc       => rV_ROW.SFACEACC
                     ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                     ,sparty         => rV_ROW.SPARTY
                     ,sstore         => rV_ROW.SSTORE
                     ,sstopertype    => rV_ROW.SSTOPERTYPE
                     ,sindoctype     => rV_ROW.SINDOCTYPE
                     ,sindocpref     => rV_ROW.SINDOCPREF
                     ,sindocnumb     => rV_ROW.SINDOCNUMB
                     ,dindocdate     => rV_ROW.DINDOCDATE
                     ,ndocstatus     => rV_ROW.NDOCSTATUS
                     ,sdirectdoctype => rV_ROW.SDIRECTDOCTYPE
                     ,sdirectdocnumb => rV_ROW.SDIRECTDOCNUMB
                     ,ddirectdocdate => rV_ROW.DDIRECTDOCDATE
                     ,sinvdoctype    => rV_ROW.SINVDOCTYPE
                     ,sinvdocnumb    => rV_ROW.SINVDOCNUMB
                     ,dinvdocdate    => rV_ROW.DINVDOCDATE
                     ,sconfdoctype   => rV_ROW.SCONFDOCTYPE
                     ,sconfdocnumb   => rV_ROW.SCONFDOCNUMB
                     ,dconfdocdate   => rV_ROW.DCONFDOCDATE
                     ,nsigntax       => rV_ROW.NSIGNTAX
                     ,scurrency      => rV_ROW.SCURRENCY
                     ,ncurcours      => rV_ROW.NCURCOURS
                     ,ncurbasecours  => rV_ROW.NCURBASECOURS
                     ,nacc_cours     => rV_ROW.NACC_COURS
                     ,nacc_basecours => rV_ROW.NACC_BASECOURS
                     ,nfa_cours      => rV_ROW.NFA_COURS
                     ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                     ,sagent         => rV_ROW.SAGENT
                     ,scomments      => rV_ROW.SCOMMENTS
                     ,sagnfifo       => rV_ROW.SAGNFIFO
                     ,sbarcode       => rV_ROW.SBARCODE
                     ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                     ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                     ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                     ,sreg_agent     => rV_ROW.SREG_AGENT
                     ,norder_type    => rV_ROW.NORDER_TYPE
                     ,scustomer      => rV_ROW.SCUSTOMER
                     ,splace         => rV_ROW.SPLACE
                     ,sship_doctype  => rV_ROW.SSHIP_DOCTYPE
                     ,sship_docnumb  => rV_ROW.SSHIP_DOCNUMB
                     ,dship_docdate  => rV_ROW.DSHIP_DOCDATE
                     ,sinsured       => rV_ROW.SINSURED
                     /* Обновление 2025/10 */
                     ,dPERIOD_FROM   => rV_ROW.dPERIOD_FROM       -- Отчётный период с
                     ,dPERIOD_TO     => rV_ROW.dPERIOD_TO         -- Отчётный период по
                     ,sBUILDING      => rV_ROW.sBUILDING          -- Стройка
                     ,sOBJECT_NAME   => rV_ROW.sOBJECT_NAME       -- Объект
                     ,sOBJECT_CODE   => rV_ROW.sOBJECT_CODE       -- Уникальный код объекта
                     ,nSUM_WORK      => rV_ROW.nSUM_WORK          -- Сумма НДС с начала выполнения работ
                     ,nSUM_YEAR      => rV_ROW.nSUM_YEAR          -- Сумма НДС с начала года
                     ,nSUM_PERIOD    => rV_ROW.nSUM_PERIOD        -- Сумма НДС в том числе за отчетный период
                     ,nrn            => rV_ROW.NRN);
  end INORDERS_INSERT;
  /*#########################################################################################################*/

  procedure INORDERS_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_inorders%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_Inorders      v_inorders%rowtype := rV_ROW;
    rInOrders        inorders%rowtype;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_inorders_update(nrn            => rV_ROW.NRN
                       ,ncompany       => rV_ROW.NCOMPANY
                       ,sjur_pers      => rV_ROW.SJUR_PERS
                       ,sseller        => rV_ROW.SSELLER
                       ,sfaceacc       => rV_ROW.SFACEACC
                       ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                       ,sparty         => rV_ROW.SPARTY
                       ,sstore         => rV_ROW.SSTORE
                       ,sstopertype    => rV_ROW.SSTOPERTYPE
                       ,sindoctype     => rV_ROW.SINDOCTYPE
                       ,sindocpref     => rV_ROW.SINDOCPREF
                       ,sindocnumb     => rV_ROW.SINDOCNUMB
                       ,dindocdate     => rV_ROW.DINDOCDATE
                       ,sdirectdoctype => rV_ROW.SDIRECTDOCTYPE
                       ,sdirectdocnumb => rV_ROW.SDIRECTDOCNUMB
                       ,ddirectdocdate => rV_ROW.DDIRECTDOCDATE
                       ,sinvdoctype    => rV_ROW.SINVDOCTYPE
                       ,sinvdocnumb    => rV_ROW.SINVDOCNUMB
                       ,dinvdocdate    => rV_ROW.DINVDOCDATE
                       ,sconfdoctype   => rV_ROW.SCONFDOCTYPE
                       ,sconfdocnumb   => rV_ROW.SCONFDOCNUMB
                       ,dconfdocdate   => rV_ROW.DCONFDOCDATE
                       ,nsigntax       => rV_ROW.NSIGNTAX
                       ,scurrency      => rV_ROW.SCURRENCY
                       ,ncurcours      => rV_ROW.NCURCOURS
                       ,ncurbasecours  => rV_ROW.NCURBASECOURS
                       ,nacc_cours     => rV_ROW.NACC_COURS
                       ,nacc_basecours => rV_ROW.NACC_BASECOURS
                       ,nfa_cours      => rV_ROW.NFA_COURS
                       ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                       ,sagent         => rV_ROW.SAGENT
                       ,scomments      => rV_ROW.SCOMMENTS
                       ,sagnfifo       => rV_ROW.SAGNFIFO
                       ,sbarcode       => rV_ROW.SBARCODE
                       ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                       ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                       ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                       ,sreg_agent     => rV_ROW.SREG_AGENT
                       ,norder_type    => rV_ROW.NORDER_TYPE
                       ,scustomer      => rV_ROW.SCUSTOMER
                       ,splace         => rV_ROW.SPLACE
                       ,sship_doctype  => rV_ROW.SSHIP_DOCTYPE
                       ,sship_docnumb  => rV_ROW.SSHIP_DOCNUMB
                       ,dship_docdate  => rV_ROW.DSHIP_DOCDATE
                       ,sinsured       => rV_ROW.SINSURED
                     /* Обновление 2025/10 */
                       ,dPERIOD_FROM   => rV_ROW.dPERIOD_FROM       -- Отчётный период с
                       ,dPERIOD_TO     => rV_ROW.dPERIOD_TO         -- Отчётный период по
                       ,sBUILDING      => rV_ROW.sBUILDING          -- Стройка
                       ,sOBJECT_NAME   => rV_ROW.sOBJECT_NAME       -- Объект
                       ,sOBJECT_CODE   => rV_ROW.sOBJECT_CODE       -- Уникальный код объекта
                       ,nSUM_WORK      => rV_ROW.nSUM_WORK          -- Сумма НДС с начала выполнения работ
                       ,nSUM_YEAR      => rV_ROW.nSUM_YEAR          -- Сумма НДС с начала года
                       ,nSUM_PERIOD    => rV_ROW.nSUM_PERIOD        -- Сумма НДС в том числе за отчетный период
                       );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Считывание заголовка для очистки */
      rInorders := usr_pkg_inorders.inorders_get( nrn => rV_ROW.NRN );

      /* Если статус документа НЕ "Не отработан" */
      if rV_Inorders.ndocstatus != 0 then

        /* Очистка заголовка для исправления */
        inorders_clear_for_update( nrn => rInOrders.rn, nmode => 0 );

        /* Исправление оригинала штатное */
        inorders_update( rv_row => rV_Inorders, nmode => 0 );

        /* Восстановление заголовка после исправления */
        inorders_clear_for_update( nrn => rInOrders.rn, nmode => 1 );

      /* Если статус документа "Не отработан" */
      else
        /* Исправление */
        inorders_update( rv_row => rV_Inorders, nmode => 0 );
     end if;    

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end INORDERS_UPDATE;
  /*#########################################################################################################*/

  procedure INORDERS_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW     in inorders%rowtype
  ,nDUP_RN  in number default null
  ,nRN      out number
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    nSP             pkg_std.tref;
    rInOrderSpecs   inorderspecs%rowtype;

  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_inorders_base_insert(ncompany       => rROW.COMPANY
                            ,ncrn           => rROW.CRN
                            ,njur_pers      => rROW.JUR_PERS
                            ,ncontragent    => rROW.CONTRAGENT
                            ,nfaceacc       => rROW.FACEACC
                            ,ngraphpoint    => rROW.GRAPHPOINT
                            ,sparty_code    => rROW.PARTY_CODE
                            ,nparty         => rROW.PARTY
                            ,nstore         => rROW.STORE
                            ,nstopertype    => rROW.STOPERTYPE
                            ,nindoctype     => rROW.INDOCTYPE
                            ,sindocpref     => rROW.INDOCPREF
                            ,sindocnumb     => rROW.INDOCNUMB
                            ,dindocdate     => rROW.INDOCDATE
                            ,ndirectdoctype => rROW.DIRECTDOCTYPE
                            ,sdirectdocnumb => rROW.DIRECTDOCNUMB
                            ,ddirectdocdate => rROW.DIRECTDOCDATE
                            ,ninvdoctype    => rROW.INVDOCTYPE
                            ,sinvdocnumb    => rROW.INVDOCNUMB
                            ,dinvdocdate    => rROW.INVDOCDATE
                            ,nconfdoctype   => rROW.CONFDOCTYPE
                            ,sconfdocnumb   => rROW.CONFDOCNUMB
                            ,dconfdocdate   => rROW.CONFDOCDATE
                            ,nsigntax       => rROW.SIGNTAX
                            ,ncurrency      => rROW.CURRENCY
                            ,ncurcours      => rROW.CURCOURS
                            ,ncurbasecours  => rROW.CURBASECOURS
                            ,nacc_cours     => rROW.ACC_COURS
                            ,nacc_basecours => rROW.ACC_BASECOURS
                            ,nfa_cours      => rROW.FA_COURS
                            ,nfa_basecours  => rROW.FA_BASECOURS
                            ,nagent         => rROW.AGENT
                            ,scomments      => rROW.COMMENTS
                            ,nagnfifo       => rROW.AGNFIFO
                            ,sbarcode       => rROW.BARCODE
                            ,npayconf_type  => rROW.PAYCONF_TYPE
                            ,spayconf_numb  => rROW.PAYCONF_NUMB
                            ,dpayconf_date  => rROW.PAYCONF_DATE
                            ,nreg_agent     => rROW.REG_AGENT
                            /* Обновление 2024/03/28 */
                            ,nORDER_TYPE    => rROW.ORDER_TYPE      /*  Вид записи */
                            ,nCUSTOMER      => rROW.CUSTOMER        /*  Заказчик */
                            ,sPLACE         => rROW.PLACE           /*  Место поставки товара */
                            ,nSHIP_DOCTYPE  => rROW.SHIP_DOCTYPE    /*  Документ об отгрузке (тип) */
                            ,sSHIP_DOCNUMB  => rROW.SHIP_DOCNUMB    /*  Документ об отгрузке (номер) */
                            ,dSHIP_DOCDATE  => rROW.SHIP_DOCDATE    /*  Документ об отгрузке (дата) */
                            ,nINSURED       => rROW.INSURED         /*  Страхователь */
                            /* Обновление 2025/10 */
                            ,dPERIOD_FROM    => rROW.PERIOD_FROM    -- Отчётный период с
                            ,dPERIOD_TO      => rROW.PERIOD_TO      -- Отчётный период по
                            ,sBUILDING       => rROW.BUILDING       -- Стройка
                            ,sOBJECT_NAME    => rROW.OBJECT_NAME    -- Объект
                            ,sOBJECT_CODE    => rROW.OBJECT_CODE    -- Уникальный код объекта
                            ,nSUM_WORK       => rROW.SUM_WORK       -- Сумма НДС с начала выполнения работ
                            ,nSUM_YEAR       => rROW.SUM_YEAR       -- Сумма НДС с начала года
                            ,nSUM_PERIOD     => rROW.SUM_PERIOD     -- Сумма НДС в том числе за отчетный период
                            ,nrn            => nRN);
    /* Режим выполнения: 1 - пользовательский.  */
    elsif nMODE = 1 then
      
      /* вызов базового добавления */
      inorders_base_insert( rrow => rRow, nrn => nRN, nmode => 0 );

      /* размножение спецификаций */
      if ( nDUP_RN is not null ) then

        /* Приходные ордера (спецификация) */
        for rec in ( select * from inorderspecs where prn = nDUP_RN )
        loop
          rInOrderSpecs     := rec;
          rInOrderSpecs.prn := nRN;
          /* базовое добавление спецификации */
          inorderspecs_base_insert( rrow => rInOrderSpecs, ndup_rn => rec.rn, ndup_clc => 1, nrn => nSP );

          /* размножение свойств спецификации */
          pkg_docs_props_vals.duplicate( sunitcode => 'IncomingOrdersSpecs', ndocument_from => rec.RN, ndocument_to => nSP );

          /* размножение прослеживаемости */
          if ( procedure_exists( 'P_INORDERSPECSPTR_DUPLICATE' ) <> 0 ) then
            execute immediate pkg_sql_call.make_stored( 'P_INORDERSPECSPTR_DUPLICATE' )
              using in rec.COMPANY,
                    in rec.RN,
                    in nSP;
          end if;
        end loop;
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end INORDERS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INORDERS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW    in INORDERS%rowtype
  ) 
  is
  begin
    P_INORDERS_BASE_UPDATE(nRN            => rROW.RN
                          ,nCOMPANY       => rROW.COMPANY
                          ,nJUR_PERS      => rROW.JUR_PERS
                          ,nCONTRAGENT    => rROW.CONTRAGENT
                          ,nFACEACC       => rROW.FACEACC
                          ,nGRAPHPOINT    => rROW.GRAPHPOINT
                          ,sPARTY_CODE    => rROW.PARTY_CODE
                          ,nPARTY         => rROW.PARTY
                          ,nSTORE         => rROW.STORE
                          ,nSTOPERTYPE    => rROW.STOPERTYPE
                          ,nINDOCTYPE     => rROW.INDOCTYPE
                          ,sINDOCPREF     => rROW.INDOCPREF
                          ,sINDOCNUMB     => rROW.INDOCNUMB
                          ,dINDOCDATE     => rROW.INDOCDATE
                          ,nDIRECTDOCTYPE => rROW.DIRECTDOCTYPE
                          ,sDIRECTDOCNUMB => rROW.DIRECTDOCNUMB
                          ,dDIRECTDOCDATE => rROW.DIRECTDOCDATE
                          ,nINVDOCTYPE    => rROW.INVDOCTYPE
                          ,sINVDOCNUMB    => rROW.INVDOCNUMB
                          ,dINVDOCDATE    => rROW.INVDOCDATE
                          ,nCONFDOCTYPE   => rROW.CONFDOCTYPE
                          ,sCONFDOCNUMB   => rROW.CONFDOCNUMB
                          ,dCONFDOCDATE   => rROW.CONFDOCDATE
                          ,nSIGNTAX       => rROW.SIGNTAX
                          ,nCURRENCY      => rROW.CURRENCY
                          ,nCURCOURS      => rROW.CURCOURS
                          ,nCURBASECOURS  => rROW.CURBASECOURS
                          ,nACC_COURS     => rROW.ACC_COURS
                          ,nACC_BASECOURS => rROW.ACC_BASECOURS
                          ,nFA_COURS      => rROW.FA_COURS
                          ,nFA_BASECOURS  => rROW.FA_BASECOURS
                          ,nAGENT         => rROW.AGENT
                          ,sCOMMENTS      => rROW.COMMENTS
                          ,nAGNFIFO       => rROW.AGNFIFO
                          ,sBARCODE       => rROW.BARCODE
                          ,nPAYCONF_TYPE  => rROW.PAYCONF_TYPE
                          ,sPAYCONF_NUMB  => rROW.PAYCONF_NUMB
                          ,dPAYCONF_DATE  => rROW.PAYCONF_DATE
                          ,nREG_AGENT     => rROW.REG_AGENT
                          /* Обновление 2024/03/28 */
                          ,nORDER_TYPE    => rROW.ORDER_TYPE      /*  Вид записи */
                          ,nCUSTOMER      => rROW.CUSTOMER        /*  Заказчик */
                          ,sPLACE         => rROW.PLACE           /*  Место поставки товара */
                          ,nSHIP_DOCTYPE  => rROW.SHIP_DOCTYPE    /*  Документ об отгрузке (тип) */
                          ,sSHIP_DOCNUMB  => rROW.SHIP_DOCNUMB    /*  Документ об отгрузке (номер) */
                          ,dSHIP_DOCDATE  => rROW.SHIP_DOCDATE    /*  Документ об отгрузке (дата) */
                          ,nINSURED       => rROW.INSURED         /*  Страхователь */
                          /* Обновление 2025/10 */
                          ,dPERIOD_FROM    => rROW.PERIOD_FROM    -- Отчётный период с
                          ,dPERIOD_TO      => rROW.PERIOD_TO      -- Отчётный период по
                          ,sBUILDING       => rROW.BUILDING       -- Стройка
                          ,sOBJECT_NAME    => rROW.OBJECT_NAME    -- Объект
                          ,sOBJECT_CODE    => rROW.OBJECT_CODE    -- Уникальный код объекта
                          ,nSUM_WORK       => rROW.SUM_WORK       -- Сумма НДС с начала выполнения работ
                          ,nSUM_YEAR       => rROW.SUM_YEAR       -- Сумма НДС с начала года
                          ,nSUM_PERIOD     => rROW.SUM_PERIOD     -- Сумма НДС в том числе за отчетный период
                          );

  end INORDERS_BASE_UPDATE;
  /*#########################################################################################################*/

  /*** процедура пересчета исполнения у родительских документов 
  по мотивам P_INORDERS_BSET_STATUS ***/
  procedure INORDERS_RECALC_PERFORMANCE
  (
    nCOMPANY    in number,
    dWORK_DATE  in date,
    nR_RN       in number, -- RN приходного ордера
    nR_OSTATUS  in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
    nR_NSTATUS  in number  -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
  )
  is
    nR_IDENT    PKG_STD.tNUMBER;  -- идентификатор процесса отражения.
    nR_ORDER    PKG_STD.tREF;     -- RN периода исполнения заказа поставщику
    nR_PACCIN   PKG_STD.tREF;     -- RN входящего счета на оплату
    nPLAN_SIGN  PKG_STD.tNUMBER;  -- знак суммирования плана (-1,0,1)
    nFACT_SIGN  PKG_STD.tNUMBER;  -- знак суммирования факта (-1,0,1)
  begin
    /* инициализация пакета расчета исполнения товарных позиций */
    PKG_GOODSDOCS_PERF_CRM.INIT( nCOMPANY, nR_IDENT );

    /* поиск родительского заказа поставщикам (работа идет с конкретным периодом) */
    /* связь ищем только по указанным цепочкам, т.к. необходимо исключить цепочки с Приходными накладными */
    nR_ORDER := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nR_IDENT, 'IncomingOrders', nR_RN, 'DeliveryOrdersPerform', null,
                                                        ';IncomingOrders<DeliveryOrdersPerform;'||
                                                        'IncomingOrders<PaymentAccountsIn<DeliveryOrdersPerform;'||
                                                        'IncomingOrders<WarrantMaterialValues<DeliveryOrdersPerform;'||
                                                        'IncomingOrders<WarrantMaterialValues<PaymentAccountsIn<DeliveryOrdersPerform;' );
    /* поиск родительского входящего счета на оплату */
    /* связь ищем только по указанным цепочкам, т.к. необходимо исключить цепочки с Приходными накладными */
    nR_PACCIN := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nR_IDENT, 'IncomingOrders', nR_RN, 'PaymentAccountsIn', null,
                                                         ';IncomingOrders<PaymentAccountsIn;'||
                                                         'IncomingOrders<WarrantMaterialValues<PaymentAccountsIn;' );

    /* если нет ни одного родительского документа - выходим */
    if (nR_ORDER is null and nR_PACCIN is null) then return; end if;

    /* выставим знаки суммирования плана и факта */
    nPLAN_SIGN := 0;
    nFACT_SIGN := 0;
    if (nR_OSTATUS = 0) then -- был не отработан
      if (nR_NSTATUS = 1) then -- будет планом
        nPLAN_SIGN := 1; nFACT_SIGN := 0;
      elsif (nR_NSTATUS = 2) then -- будет фактом
        nPLAN_SIGN := 1; nFACT_SIGN := 1;
      else return; end if; -- на всякий случай
    elsif (nR_OSTATUS = 1) then -- был планом
      if (nR_NSTATUS = 0) then -- будет не отработан
        nPLAN_SIGN := -1; nFACT_SIGN := 0;
      elsif (nR_NSTATUS = 2) then -- будет фактом
        nPLAN_SIGN := 0; nFACT_SIGN := 1;
      else return; end if; -- на всякий случай
    elsif (nR_OSTATUS = 2) then -- был фактом
      if (nR_NSTATUS = 0) then -- будет не отработан
        nPLAN_SIGN := -1; nFACT_SIGN := -1;
      elsif (nR_NSTATUS = 1) then -- будет планом
        nPLAN_SIGN := 0; nFACT_SIGN := -1;
      else return; end if; -- на всякий случай
    end if;

    /* отражение исполнения по спецификациям приходного ордера */
    for INOS in ( select O.CURRENCY, O.CURCOURS, O.CURBASECOURS,
                         F.CURRENCY FA_CURRENCY, O.FA_BASECOURS, O.FA_COURS,
                         M.PRN NOMEN, S.NOMMODIF, S.NOMNMODIFPACK, S.ARTICLE,
                         O.STORE, S.SERNUMB, S.COUNTRY, S.GTD,
                         S.PLANQUANT, S.PLANQUANTALT, S.PLANSUMTAX
                    from INORDERS     O,
                         INORDERSPECS S,
                         NOMMODIF     M,
                         FACEACC      F
                   where O.RN       = nR_RN
                     and O.RN       = S.PRN
                     and S.NOMMODIF = M.RN
                     and O.FACEACC  = F.RN )
      loop
      /* суммирование исполнения */
      PKG_GOODSDOCS_PERF_CRM.SET_PERF( nR_IDENT, 1/*SIGN_PACK*/,
                                       null/*NOMENCLS*/, null/*UMEAS_MAIN*/,
                                       INOS.NOMEN, null/*NOMNPACK*/, INOS.NOMMODIF, INOS.NOMNMODIFPACK, INOS.ARTICLE,
                                       INOS.STORE, null/*GOODSPARTY*/, INOS.SERNUMB, INOS.COUNTRY, INOS.GTD,
                                       INOS.PLANQUANT, INOS.PLANQUANTALT,
                                       INOS.PLANQUANT, INOS.PLANQUANTALT,
                                       0/*nRTN_PLANM_QUANT*/, 0/*nRTN_PLANA_QUANT*/,
                                       0/*nRTN_FACTM_QUANT*/, 0/*nRTN_FACTA_QUANT*/,
                                       INOS.PLANSUMTAX, INOS.PLANSUMTAX,
                                       nPLAN_SIGN, nFACT_SIGN,
                                       0/*nRTN_PLAN_SIGN*/, 0/*nRTN_FACT_SIGN*/,
                                       INOS.CURRENCY, INOS.CURCOURS, INOS.CURBASECOURS,
                                       INOS.FA_CURRENCY, INOS.FA_BASECOURS, INOS.FA_COURS, dWORK_DATE );
    end loop;
    /* сохранение рассчитаного исполнения в родительских документах */
    PKG_GOODSDOCS_PERF_CRM.SAVE_PARENT( nR_IDENT );
  end INORDERS_RECALC_PERFORMANCE;
 /*#########################################################################################################*/

  procedure INORDERS_MAKE_TRANSINVDEPT
  /*
  Заголовок. Сформировать расходные накладные на отпуск в подразделения
  */
  (
   nRN          in number
  ,nCOMPANY     in number
  ,dDOCDATE     in date
  ,sCATALOG     in varchar2
  ,sSTOPER      in varchar2
  ,sSHEEPVIEW   in varchar2
  ,sFACEACC     in varchar2
  ,sIN_STORE    in varchar2
  ,sIN_STOPER   in varchar2
  ,sSUBDIV      in varchar2
  ) 
  is
    sIN_MOL           agnlist.agnabbr%type;
    
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    /* Добавление документа в selectlist */
    p_selectlist_insert_ext( nident     => nRN
                            ,ndocument  => nRN
                            ,sunitcode  => 'IncomingOrders'
                            ,ndocument1 => null
                            ,sunitcode1 => null
                            ,ncrn       => null
                            ,nrn        => nNumber );
    /* Если склад-получатель задан, ищмем его МОЛ */
    if sIN_STORE is not null then
      find_dicstore_attr( nflag_smart => 0
                         ,nflag_azs   => 0
                         ,ncompany    => nCOMPANY
                         ,snumb       => sIN_STORE
                         ,nrn         => nNumber
                         ,nmol        => nNumber
                         ,smol        => sIN_MOL
                         ,npbe        => nNumber
                         ,spbe        => sVarchar
                         ,ncurrency   => nNumber
                         ,scurrency   => sVarchar );
    end if;
    /* Формирование буфера */
    p_inorders_make_invdepts( ncompany    => nCOMPANY
                             ,nident      => nRN
                             ,ddocdate    => dDOCDATE
                             ,scatalog    => sCATALOG
                             ,sstoper     => sSTOPER
                             ,ssheepview  => sSHEEPVIEW
                             ,sfaceacc    => sFACEACC
                             ,sgraphpoint => null
                             ,sin_store   => sIN_STORE
                             ,sin_stoper  => sIN_STOPER
                             ,ssubdiv     => sSUBDIV
                             ,sin_mol     => sIN_MOL
                             ,nby_clc_fa  => 0
                             ,nres        => nNumber );
    /* По заголовкам буфера */
    for c in ( select * from transinvdeptbuf where ident = nRN )
    loop
      /* штатная проверка */
      p_transinvdeptbuf_checkinvsums( ncompany => c.company, nrn => c.rn, nwarrning => nNumber );
      /*
      \* считывание текущей записи в переменную *\
      rTransInvDeptBuf := c;
      \* подмена значений в переменной *\
      rTransInvDeptBuf.crn := nCatalog;
      rTransInvDeptBuf.stopertype := nStoreOper;
      \* исправление записи буфера *\
      inordersbuff_base_update(rrow => rTransInvDeptBuf);
      */
    end loop;

    /* Перенос буфера */
    p_transinvdeptbuf_makeinvbuf(ncompany => nCOMPANY, nident => nRN);

    /* Очистка */
    p_selectlist_clear( nident => nRN);
    p_transinvdeptbuf_clean(ncompany => nCOMPANY, nident => nRN );

  end INORDERS_MAKE_TRANSINVDEPT;
 /*#########################################################################################################*/

  procedure INORDERS_MAKE_RINVTOSUP
  /*
  Заголовок. Сформировать расходные накладные на возврат поставщикам
  */
  (
   nRN          in number
  ,nCOMPANY     in number
  ) 
  is
  begin
    p_inorders_makerinvtosup(ncompany => nCOMPANY, nrn => nRN, nident => nRN);
    p_rinvtosupbuff_makeinvbuf(ncompany => nCOMPANY, nident => nRN);
    p_rinvtosupbuff_clean(ncompany => nCOMPANY, nident => nRN);

  end INORDERS_MAKE_RINVTOSUP;
  /*#########################################################################################################*/

  procedure INORDERS_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  ) 
  is
    rRow        inorders%rowtype;
    rSpec       inorderspecs%rowtype;
  begin
    /* Заголовок  */
    rRow := INORDERS_GET(nRN);
    
    /* Проверка параметров*/    
    /* Не задан */
    if nSIGNTAX is null then
      P_EXCEPTION(0, 'Не задан параметр процедуры "Цены включают налоги". %s'
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomingOrders', rRow.rn)); 
    elsif nSIGNTAX not in (0, 1) then
      P_EXCEPTION(0, 'Неверное значение: "%s" параметра процедуры "Цены включают налоги". %s'
                 ,nSIGNTAX
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomingOrders', rRow.rn)); 
    end if;
    /* Имеет такое же значение, как в документе */
    if (rRow.signtax = nSIGNTAX and nSIGNTAX is not null)
    and nFLAGSMART = 0 then
      P_EXCEPTION(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.signtax when 0 then 'Нет' else 'Да' end
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomingOrders', rRow.rn)); 
    end if;
      
    /* Исправление заголовка */
    update INORDERS
       set signtax = nSIGNTAX
     where rn = rRow.rn;

    /* По спецификациям */
    for c in (select * from INORDERSPECS where PRN = rRow.rn)
    loop
      /* Сохранение записи в переменную */
      rSpec := c;
      /* Расчёт сумм от суммы с налогами */
      PKG_DICTAXIS_CALC.P_CALCULATE_BASE
      (
       nFLAG_SMART => 0
      ,nCOMPANY    => rRow.company
      ,dDATE       => rRow.indocdate
      ,nSUMM_SIGN  => 1
      ,nINSUMM     => rSpec.factsumtax
      ,nTAXGR      => rSpec.taxgr
      ,nQUANT      => rSpec.factquant
      ,nNCP_SIGN   => 1
      );
      /* Расчёт и сохранение цены в переменную */
      rSpec.price := case nSIGNTAX 
                       when 0 then PKG_DICTAXIS_CALC.F_GET_VALUE(0) /* Сумма без налогов (0) */
                       else PKG_DICTAXIS_CALC.F_GET_VALUE(2)        /* Сумма со всеми налогами (2) */
                     end  / rSpec.factquant; 
      /* Исправление спецификации */
      INORDERSPECS_BASE_UPDATE(RROW => rSpec);
    end loop;

  end INORDERS_UPDATE_SIGNTAX;
  /*#########################################################################################################*/

  procedure INORDERS_RECREATE_IOSC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  ) 
  is
    rRow                  inorders%rowtype;
    nINDH                 pkg_std.tref;          /* входной документ. Заголовок. RN */
    rINDS                 payaccinspec%rowtype;  /* входной документ. Спецификация. Запись */
    nINDC_CURC_Quant      pkg_std.tnumber;       /* распределённое количество калькуляции входного документа */
    nINDC_CURC_QuantRest  pkg_std.tnumber;       /* нераспределённое количество калькуляции входного документа */
    nCURS_QuantRest       pkg_std.tnumber;       /* нераспределённое количество калькуляции текущего документа */
    nQuant                pkg_std.tnumber;       /* количество для распределения */
    rCURC                 inorderspecsclc%rowtype; /* калькуляция текущего документа. Запись */
    
    nNumber           pkg_std.tnumber; 
  begin
    /* Заголовок  */
    rRow := inorders_get(nrn => nRN);

    /* Удаление калькуляций во всех спецификациях текущего документа */
    for c in (select rn, company from inorderspecsclc where prn in (select rn from inorderspecs where prn =  nRN))
    loop
      p_inorderspecsclc_base_delete(nrn => c.rn, ncompany => c.company);
    end loop;
    
    /* По спецификациям текущего документа */
    for sp in (select * from inorderspecs where prn =  nRN)
    loop
      /* Поиск заголовка входного документа */
      nINDH := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                    ,sout_unitcode  => 'IncomingOrders'
                                                    ,nout_document  => sp.prn
                                                    ,sin_unitcode   => 'PaymentAccountsIn');
      /* поиск аналогичной спецификации входного документа */
      usr_pkg_payaccin.payaccinspec_get_by_params(nprn          => nINDH
                                                 ,nnommodif     => sp.nommodif
                                                 ,nnommodifpack => sp.nomnmodifpack
                                                 ,ntaxgr        => sp.taxgr
                                                 ,rrow          => rINDS);
      /* Нераспределённое количество калькуляции текущего документа = количество по спецификации текущего документа */
      nCURS_QuantRest := sp.factquant;

      /* По калькуляциям спецификации входного документа с сортировкой по номеру ЛС */
      for c in (select t.*
                  from payaccinspclc t, faceacc fa
                 where t.prn         = rINDS.rn
                   and t.faceaccount = fa.rn
                order by fa.numb)
      loop
        /* распределённое количество калькуляции входного документа */
        usr_pkg_payaccin.payaccinspclc_get_iivsc_quant(nrn         => c.rn
                                                      ,nquant_plan => nNumber
                                                      ,nquant_fact => nINDC_CURC_Quant);
        /* нераспределённое количество калькуляции входного документа */
        nINDC_CURC_QuantRest := c.quant_fact - nINDC_CURC_Quant;
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
          rCURC.quant_fact   := nQuant;
          rCURC.subdiv       := c.subdiv;
          /* добавление калькуляции текущего документа*/
          inorderspecsclc_base_insert(rrow => rCURC, nrn => nNumber);
        end if;
      end loop;
    end loop;
    
  end INORDERS_RECREATE_IOSC;
  /*#########################################################################################################*/

  function INORDERS_GET_STATUS_NAME
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
  END INORDERS_GET_STATUS_NAME;
  /*#########################################################################################################*/

  procedure INORDERS_CLEAR_FOR_UPDATE
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
    rRow        inorders%rowtype;
    nNumber     pkg_std.tnumber;
    sVarchar    pkg_std.tstring;
  begin
    /* Считывание */
    rRow := inorders_get( nrn => nRN );

    /* 0 - Освободить */
    if nMODE = 0 then

      /* Копирование текущих значений в переменную-дубликат */
      usr_pkg_pub_const.rinorders := rRow;

      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

      /* Сохранение настроек раздела OptionsSystemLocal */
      usr_pkg_common.options_save_unit_params( sunitcode => 'OptionsSystemLocal', sauthid => utilizer );
      /* Заменяем значение в парметре "Способ изменения учетной цены при внешнем оприходовании в существующую партию товара" на "Не исправлять" */
      usr_pkg_common.options_set(scode       => 'Realiz_RegPrices_ExtIncome_ChangeMethod'
                                ,sauthid     => utilizer
                                ,ncompany    => usr_pkg_pub_const.rinorders.company
                                ,sstr_value  => 2
                                ,nnum_value  => null
                                ,ddate_value => null
                                ,nrn         => nNumber
                                ,nmode       => 1);
      /* Добавление дубликата */
      usr_pkg_pub_const.rinorders.indocpref := '0099';
      inorders_base_insert( rrow    => usr_pkg_pub_const.rinorders
                           ,ndup_rn => usr_pkg_pub_const.rinorders.rn
                           ,nrn     => usr_pkg_pub_const.rinorders.rn
                           ,nmode   => 1 );
      /* Отработка дубликата */
      p_inorders_bset_status( ncompany    => usr_pkg_pub_const.rinorders.company
                             ,nrn         => usr_pkg_pub_const.rinorders.rn
                             ,nstatus     => 2
                             ,dwork_date  => usr_pkg_pub_const.rinorders.work_date
                             ,nflag_reset => 0
                             ,nwarning    => nNumber
                             ,smsg        => sVarchar );
      /* Удаление выходных связей у оригинала с разделами: Сертификация/Входной контроль; Расходные накладные на отпуск в подразделения */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rRow.rn
                                          ,ncompany      => rRow.company
                                          ,sunitcode     => 'UdoProdCull;GoodsTransInvoicesToDepts;ReturnInvoicesToSuppliers'
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                          ,nmode         => 0 );
      /* Снятие отработки с оригинала */
      p_inorders_bset_status( ncompany    => rRow.company
                             ,nrn         => rRow.rn
                             ,nstatus     => 0
                             ,dwork_date  => rRow.work_date
                             ,nflag_reset => 1
                             ,nwarning    => nNumber
                             ,smsg        => sVarchar );
      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

    /* 1 - Восстановить */
    elsif nMODE = 1 then

      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
      /* Отработка оригинала */
      p_inorders_bset_status( ncompany    => rRow.company
                             ,nrn         => rRow.rn
                             ,nstatus     => 2
                             ,dwork_date  => rRow.work_date
                             ,nflag_reset => 0
                             ,nwarning    => nNumber
                             ,smsg        => sVarchar );
      /* Восстановление выходных связей у оригинала */
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                          ,nrn           => rRow.rn
                                          ,ncompany      => rRow.company
                                          ,arn_unit_list => usr_pkg_pub_const.arn_unit_list
                                          ,nmode         => 1 );
      /* Снятие отработки с дубликата */
      p_inorders_bset_status( ncompany    => usr_pkg_pub_const.rinorders.company
                             ,nrn         => usr_pkg_pub_const.rinorders.rn
                             ,nstatus     => 0
                             ,dwork_date  => usr_pkg_pub_const.rinorders.work_date
                             ,nflag_reset => 1
                             ,nwarning    => nNumber
                             ,smsg        => sVarchar );
      /* Удаление дубликата */
      p_inorders_base_delete( ncompany => usr_pkg_pub_const.rinorders.company, nrn => usr_pkg_pub_const.rinorders.rn );

      /* Восстановление настроек раздела OptionsSystemLocal */
      usr_pkg_common.options_restore_unit_params;

      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Очистка переменных */
      usr_pkg_pub_const.arn_unit_list.delete;
      usr_pkg_pub_const.rinorders := null;
    else
      p_exception(0, 'Неверный режим работы.%s', sqlerrm ); 
    end if;

  end INORDERS_CLEAR_FOR_UPDATE;
  /*#########################################################################################################*/

  procedure INORDERSBUFF_BASE_INSERT
  /*
  Заголовок (буфер). Добавление базовое
  */
  (
   rROW    in inordersbuff%rowtype
  ,nRN     out number 
  ) 
  is
  begin
    p_inordersbuff_base_insert( ncompany         => rROW.COMPANY
                               ,ncrn             => rROW.CRN
                               ,njur_pers        => rROW.JUR_PERS
                               ,nsource_crn      => rROW.SOURCE_CRN
                               ,ssource_unitcode => rROW.SOURCE_UNITCODE
                               ,nsource_rn       => rROW.SOURCE_RN
                               ,nident           => rROW.IDENT
                               ,ncontragent      => rROW.CONTRAGENT
                               ,nfaceacc         => rROW.FACEACC
                               ,ngraphpoint      => rROW.GRAPHPOINT
                               ,sparty_code      => rROW.PARTY_CODE
                               ,nstore           => rROW.STORE
                               ,nstopertype      => rROW.STOPERTYPE
                               ,nindoctype       => rROW.INDOCTYPE
                               ,sindocpref       => rROW.INDOCPREF
                               ,sindocnumb       => rROW.INDOCNUMB
                               ,dindocdate       => rROW.INDOCDATE
                               ,ndirectdoctype   => rROW.DIRECTDOCTYPE
                               ,sdirectdocnumb   => rROW.DIRECTDOCNUMB
                               ,ddirectdocdate   => rROW.DIRECTDOCDATE
                               ,ninvdoctype      => rROW.INVDOCTYPE
                               ,sinvdocnumb      => rROW.INVDOCNUMB
                               ,dinvdocdate      => rROW.INVDOCDATE
                               ,nconfdoctype     => rROW.CONFDOCTYPE
                               ,sconfdocnumb     => rROW.CONFDOCNUMB
                               ,dconfdocdate     => rROW.CONFDOCDATE
                               ,nsigntax         => rROW.SIGNTAX
                               ,ncurrency        => rROW.CURRENCY
                               ,ncurcours        => rROW.CURCOURS
                               ,ncurbasecours    => rROW.CURBASECOURS
                               ,nacc_cours       => rROW.ACC_COURS
                               ,nacc_basecours   => rROW.ACC_BASECOURS
                               ,nfa_cours        => rROW.FA_COURS
                               ,nfa_basecours    => rROW.FA_BASECOURS
                               ,nagent           => rROW.AGENT
                               ,scomments        => rROW.COMMENTS
                               ,nagnfifo         => rROW.AGNFIFO
                               ,sbarcode         => rROW.BARCODE
                               ,npayconf_type    => rROW.PAYCONF_TYPE
                               ,spayconf_numb    => rROW.PAYCONF_NUMB
                               ,dpayconf_date    => rROW.PAYCONF_DATE
                               ,nreg_agent       => rROW.REG_AGENT
                               ,norder_type      => rROW.ORDER_TYPE
                               ,ncustomer        => rROW.CUSTOMER
                               ,splace           => rROW.PLACE
                               ,nship_doctype    => rROW.SHIP_DOCTYPE
                               ,sship_docnumb    => rROW.SHIP_DOCNUMB
                               ,dship_docdate    => rROW.SHIP_DOCDATE
                               ,ninsured         => rROW.INSURED
                               ,dperiod_from     => rROW.PERIOD_FROM
                               ,dperiod_to       => rROW.PERIOD_TO
                               ,sbuilding        => rROW.BUILDING
                               ,sobject_name     => rROW.OBJECT_NAME
                               ,sobject_code     => rROW.OBJECT_CODE
                               ,nsum_work        => rROW.SUM_WORK
                               ,nsum_year        => rROW.SUM_YEAR
                               ,nsum_period      => rROW.SUM_PERIOD
                               ,nrn              => nRN );
  end INORDERSBUFF_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INORDERSBUFF_BASE_UPDATE
  /*
  Заголовок (буфер). Исправление базовое
  */
  (
   rROW    in inordersbuff%rowtype
  ) 
  is
  begin
    p_inordersbuff_base_update(nrn            => rRow.rn
                              ,ncrn           => rRow.crn
                              ,ncompany       => rRow.company
                              ,njur_pers      => rRow.jur_pers
                              ,ncontragent    => rRow.contragent
                              ,nfaceacc       => rRow.faceacc
                              ,ngraphpoint    => rRow.graphpoint
                              ,sparty_code    => rRow.party_code
                              ,nstore         => rRow.store
                              ,nstopertype    => rRow.stopertype
                              ,nindoctype     => rRow.indoctype
                              ,sindocpref     => rRow.indocpref
                              ,sindocnumb     => rRow.indocnumb
                              ,dindocdate     => rRow.indocdate
                              ,ndirectdoctype => rRow.directdoctype
                              ,sdirectdocnumb => rRow.directdocnumb
                              ,ddirectdocdate => rRow.directdocdate
                              ,ninvdoctype    => rRow.invdoctype
                              ,sinvdocnumb    => rRow.invdocnumb
                              ,dinvdocdate    => rRow.invdocdate
                              ,nconfdoctype   => rRow.confdoctype
                              ,sconfdocnumb   => rRow.confdocnumb
                              ,dconfdocdate   => rRow.confdocdate
                              ,nsigntax       => rRow.signtax
                              ,ncurrency      => rRow.currency
                              ,ncurcours      => rRow.curcours
                              ,ncurbasecours  => rRow.curbasecours
                              ,nacc_cours     => rRow.acc_cours
                              ,nacc_basecours => rRow.acc_basecours
                              ,nfa_cours      => rRow.fa_cours
                              ,nfa_basecours  => rRow.fa_basecours
                              ,nagent         => rRow.agent
                              ,scomments      => rRow.comments
                              ,nagnfifo       => rRow.agnfifo
                              ,sbarcode       => rRow.barcode
                              ,npayconf_type  => rRow.payconf_type
                              ,spayconf_numb  => rRow.payconf_numb
                              ,dpayconf_date  => rRow.payconf_date
                              ,nreg_agent     => rRow.reg_agent
                              /* Обновление 2024/03/28 */
                              ,nORDER_TYPE    => rRow.ORDER_TYPE      /*  Вид записи */
                              ,nCUSTOMER      => rRow.CUSTOMER        /*  Заказчик */
                              ,sPLACE         => rRow.PLACE           /*  Место поставки товара */
                              ,nSHIP_DOCTYPE  => rRow.SHIP_DOCTYPE    /*  Документ об отгрузке (тип) */
                              ,sSHIP_DOCNUMB  => rRow.SHIP_DOCNUMB    /*  Документ об отгрузке (номер) */
                              ,dSHIP_DOCDATE  => rRow.SHIP_DOCDATE    /*  Документ об отгрузке (дата) */
                              ,nINSURED       => rRow.INSURED         /*  Страхователь */
                            /* Обновление 2025/10 */
                              ,dPERIOD_FROM    => rROW.PERIOD_FROM    -- Отчётный период с
                              ,dPERIOD_TO      => rROW.PERIOD_TO      -- Отчётный период по
                              ,sBUILDING       => rROW.BUILDING       -- Стройка
                              ,sOBJECT_NAME    => rROW.OBJECT_NAME    -- Объект
                              ,sOBJECT_CODE    => rROW.OBJECT_CODE    -- Уникальный код объекта
                              ,nSUM_WORK       => rROW.SUM_WORK       -- Сумма НДС с начала выполнения работ
                              ,nSUM_YEAR       => rROW.SUM_YEAR       -- Сумма НДС с начала года
                              ,nSUM_PERIOD     => rROW.SUM_PERIOD     -- Сумма НДС в том числе за отчетный период
                              );
  end INORDERSBUFF_BASE_UPDATE;
  /*#########################################################################################################*/

  function INORDERSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0
  ) 
  return INORDERSPECS%ROWTYPE
  is
    rRow INORDERSPECS%ROWTYPE;
  begin
    begin
      select * into rRow from inorderspecs where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'INORDERSPECS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERSPECS')) 
                   ,cr||cr||sqlerrm );
    end;

    return(rRow);

  end INORDERSPECS_GET;
  /*#########################################################################################################*/
  
  PROCEDURE INORDERSPECS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
  ,nTOO_MANY_ROWS     in number default 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
  ,nPRN               in number
  ,nNOMPACK           in number default null
  ,nNOMMODIF          in number default null
  ,nNOMMODIFPACK      in number default null
  ,nTAXGR             in number default null
  ,nQUANT             in number default null
  ,nQUANTALT          in number default null
  ,nPRICE             in number default null
  ,nARTICLE           in number default null
  ,sSERNUMB           in varchar2 default null
  ,nCOUNTRY           in number   default null
  ,sGTD               in varchar2 default null
  ,rROW               out inorderspecs%rowtype 
  ) 
  is
  begin
    begin
      select *
        into rRow
        from inorderspecs t
       where t.prn                    = nPRN
         and (nvl(t.nomnmodifpack, 0) = nvl(nNOMPACK, 0)      or (nNOMPACK is null and nFLAG_OPTION = 1))
         and (nvl(t.nommodif, 0)      = nvl(nNOMMODIF, 0)     or (nNOMMODIF is null and nFLAG_OPTION = 1))
         and (nvl(t.nomnmodifpack, 0) = nvl(nNOMMODIFPACK, 0) or (nNOMMODIFPACK is null and nFLAG_OPTION = 1))
         and (nvl(t.taxgr, 0)         = nvl(nTAXGR, 0)        or (nTAXGR is null and nFLAG_OPTION = 1))
         and (nvl(t.factquant, 0)     = nvl(nQUANT, 0)        or (nQUANT is null and nFLAG_OPTION = 1))
         and (nvl(t.factquantalt, 0)  = nvl(nQUANTALT, 0)     or (nQUANTALT is null and nFLAG_OPTION = 1))
         and (nvl(t.price, 0)         = nvl(nPRICE, 0)        or (nPRICE is null and nFLAG_OPTION = 1))
         and (nvl(t.article, 0)       = nvl(nARTICLE, 0)      or (nARTICLE is null and nFLAG_OPTION = 1))
         and (nvl(t.sernumb, 0)       = nvl(sSERNUMB, 0)      or (sSERNUMB is null and nFLAG_OPTION = 1))
         and (nvl(t.country, 0)       = nvl(nCOUNTRY, 0)      or (nCOUNTRY is null and nFLAG_OPTION = 1))
         and (nvl(t.gtd, 0)           = nvl(sGTD, 0)          or (sGTD is null and nFLAG_OPTION = 1))
         ;
    exception
      when no_data_found then
        if nFLAGSMART = 0 then
          p_exception(0 ,'Не найдено спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,nPRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'INORDERSPECS')));
        end if;
      when too_many_rows then
        if nTOO_MANY_ROWS = 0 and nFLAGSMART = 0 then
          p_exception(0, 'Найдено больше одной спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,nPRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'INORDERSPECS')));
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске спецификации для заголовка с RN <%s> записи в разделе <%s>. %s'
                   ,nPRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'INORDERSPECS')), sqlerrm);
    end;
  END INORDERSPECS_GET_BY_PARAMS;
  /*#########################################################################################################*/

  procedure INORDERSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              inorderspecs%rowtype;
    nInDoc            pkg_std.tref; 
  begin
    /* Считывание */
    rRow := inorderspecs_get(nrn => nRN);
    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'IncomingOrders'
                                                   ,nout_document  => rRow.prn
                                                   ,sin_unitcode   => 'IncomingInvoices');
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Если документ имеет связь по входу и выполняется штатное действие */
    if nInDoc is not null 
    and nvl( usr_pkg_process.get_parus_process, 'null' ) in ('INORDERSPECS_INSERT') then
      p_exception(0, 'Запрещены изменения Приходного ордера. Для исправления удалите Приходный ордер, внесите исправление '||
                  'в Приходную накладную, повторно сформируйте Приходный ордер.%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn ) ); 
    end if;                 
    /* Базовая*/
    inorderspecs_check_base(nrn => nRN, ncompany => nCOMPANY);

  end INORDERSPECS_AINSERT;
  /*#########################################################################################################*/

  procedure INORDERSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            inorderspecs%rowtype;
    nInDoc          pkg_std.tref; 
  begin
    /* Считывание */
    rRow  := inorderspecs_get(nrn => nRN);
    usr_pkg_pub_const.rinorderspecs := rRow;
    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'IncomingOrders'
                                                   ,nout_document  => rRow.prn
                                                   ,sin_unitcode   => 'IncomingInvoices');
    /* ПРОВЕРКИ */
    /* Если документ имеет связь по входу и выполняется штатное действие */
    if nInDoc is not null 
    and nvl( usr_pkg_process.get_parus_process, 'null' ) in ('INORDERSPECS_UPDATE') then
      p_exception(0, 'Запрещены изменения Приходного ордера. Для исправления удалите Приходный ордер, внесите исправление '||
                  'в Приходную накладную, повторно сформируйте Приходный ордер.%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn ) ); 
    end if;                 

    /* Выходных документов */
    inorderspecs_check_out_docs( rrow => rRow );

  end INORDERSPECS_BUPDATE;
  /*#########################################################################################################*/

  procedure INORDERSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              inorderspecs%rowtype;
    rInOrders         inorders%rowtype;
  begin
    /* Считывание */
    rRow      := inorderspecs_get( nrn => nRN );
    rInOrders := inorders_get( nrn => rRow.prn );

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    inorderspecs_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Если документ отработан */
    /*if rInOrders.docstatus = 2 then
      \* Рассылка уведомления *\
      inorderspecs_msg_send( rrow => rRow, rrow_before => usr_pkg_pub_const.rinorderspecs );
    end if;*/
    
  end INORDERSPECS_AUPDATE;
  /*#########################################################################################################*/

  procedure INORDERSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      inorderspecs%rowtype;
    nInDoc    pkg_std.tref; 
  begin
    /* Считывание */
    rRow  := inorderspecs_get(nrn => nRN);
    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'IncomingOrders'
                                                   ,nout_document  => rRow.prn
                                                   ,sin_unitcode   => 'IncomingInvoices');

    /* ИСПРАВЛЕНИЯ */
    /* удаление связей по DocLinks у документа */
    p_linksall_delete_full_out( ncompany => rRow.company, sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn );
    p_linksall_delete_full_in ( ncompany => rRow.company, sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn );

    /* ПРОВЕРКИ */
    /* Если документ имеет связь по входу и выполняется штатное действие */
    if nInDoc is not null 
    and nvl( usr_pkg_process.get_parus_process, 'null' ) in ('INORDERSPECS_DELETE') then
      p_exception(0, 'Запрещены изменения Приходного ордера. Для исправления удалите Приходный ордер, внесите исправление '||
                  'в Приходную накладную, повторно сформируйте Приходный ордер.%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn ) ); 
    end if;                 
    /* Выходных документов */
    inorderspecs_check_out_docs( rrow => rRow );

  end INORDERSPECS_BDELETE;
  /*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow              inorderspecs%rowtype;
    rInOrders         inorders%rowtype;
    rRlArticles       rlarticles%rowtype;
    nArticleSsupply   pkg_std.tref; 
    rGoodsSupply      goodssupply%rowtype;

    nNumber           pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow      := inorderspecs_get(nrn => nRN);
    rInOrders := inorders_get(nrn => rRow.prn);
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
                                   ,ddate        => rInOrders.indocdate
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
    /* Количество план и факт */
    if rRow.planquant != rRow.factquant then
      p_exception(0, '"Количество. По документу": <%s> не равно "Количество. Фактически принято": <%s>. %s%s'
                 ,rRow.planquant
                 ,rRow.factquant
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn)); 
    end if;

    /* Суммы план и факт */
    if rRow.plansum    != rRow.factsum
    or rRow.plansumtax != rRow.factsumtax
    or rRow.plansumnds != rRow.factsumnds then
      p_exception(0, '"Суммы. По документу" не равны "Суммы. Фактически принято".%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn)); 
    end if;

    /* Для документов после даты 15/08/2023 */
    if rInOrders.indocdate > to_date('15.08.2023', 'dd.mm.yyyy') then
      /* Правило расчёта учётной цены */
      if rRow.price_calc_rule != 1 then
        P_EXCEPTION(0, 'Параметр "Учётная цена и правила расчёта" на вкладке "Дополнительно" должен иметь значение "Не включать налоги". '||
                   'Для исправления выполните процедуру <Исправить признак "Цены включают налоги">.%s%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn)); 
      end if;
    end if;
    
    /* Cуммы по документу и учётная */
    if trunc(rRow.plansum) != trunc(rRow.acc_summ) then
      p_exception(0, '"Сумма по документу. Без налогов" <%s> не равна "Учётная сумма" на вкладке "Дополнительно" <%s>. %s%s'
                 ,trim(n2ss(rRow.plansum))
                 ,trim(n2ss(rRow.acc_summ))
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn)); 
    end if;

    /* Если изделие числится в учёте */
    if rGoodsSupply.restfact != 0 then 
       p_exception(0, 'Изделие <%s> числится в учёте на дату документа <%s>. Повторный приход запрещён. %s%s'
                  ,rRlArticles.code
                  ,decode_date(rInOrders.indocdate)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rRow.prn)); 
    end if;

  end INORDERSPECS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_IOSC
  /*
  Спецификация. Проверка калькуляций
  */
  (
   rROW   in inorderspecs%rowtype
  ) 
  is
    nQuantPlanItog  pkg_std.tnumber := 0; 
    bFlag           boolean := false;
  begin
    /* По калькуляциям */
    for c in (select * from inorderspecsclc where prn = rROW.RN)
    loop
      /* Если каталог Метрология\ Услуги. План. Метрология */
      if not usr_pkg_common.is_crn_in_hiercrn(nCRN => rROW.CRN, shier_crn_list => usr_pkg_pub_const.nio_cat_mtlgservicesplan ) then
        if c.faceaccount is null then
          p_exception(0, 'Поле "Лицевой счёт (заказ)" не заполнено в калькуляции. %s%s'
                     ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rROW.RN)
                     ,cr||f_docdescrs_get_description('IncomingOrders', rROW.PRN)); 
        end if;                 
        if nvl(c.quant_plan, 0) = 0 then
          p_exception(0, 'Поле "Количество. План" не заполнено в калькуляции. %s%s'
                     ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rROW.RN)
                     ,cr||f_docdescrs_get_description('IncomingOrders', rROW.PRN)); 
        end if;                 
      end if;                 
      /* подсчёт количеств по всем калькуляциям */
      nQuantPlanItog := nQuantPlanItog + nvl(c.quant_plan, 0); 
      /* признак, что заходили сюда */
      bFlag := true;
    end loop;
    
     /* Если каталог Метрология */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rROW.CRN, shier_crn_list => usr_pkg_pub_const.nio_cat_mtlg)   then
      /* Нет калькуляций */
      if not bFlag then
        p_exception(0, 'Для спецификации отсутствуют калькуляции. %s%s'
                   ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rROW.RN)
                   ,cr||f_docdescrs_get_description('IncomingOrders', rROW.PRN)); 
      end if;                 
      /* Проверка итога по количеству калькуляции и количества в спецификации */
      if nQuantPlanItog != rROW.FACTQUANT then
        p_exception(0, 'Сумма по полю "Количество. План" в калькуляции <%s> не равно количеству в спецификации <%s>. %s%s'
                   ,nQuantPlanItog 
                   ,rROW.FACTQUANT
                   ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rROW.RN)
                   ,cr||f_docdescrs_get_description('IncomingOrders', rROW.PRN)); 
      end if;                 
    end if;                 
    
  end INORDERSPECS_CHECK_IOSC;
/*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_INDOC
  /*
  Спецификация. Проверка с приходной накладной
  */
  (
   rROW           in inorderspecs%rowtype
  ) 
  is
    nInDoc              pkg_std.tref; 
    rInDocSpec          ininvoicesspecs%rowtype;
    sVarchar            pkg_std.tstring; 
  begin
    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'IncomingOrders'
                                                   ,nout_document  => rROW.PRN
                                                   ,sin_unitcode   => 'IncomingInvoices');
    /* Если документ найден */
    if nInDoc is not null then

      /* Аналогичная спецификацию во входном документе */               
      usr_pkg_ininvoices.ininvoicesspecs_get_by_params
      (
       nflagsmart => 0
      ,nprn       => nInDoc
      ,nmodif     => RROW.NOMMODIF
      ,ntaxgr     => RROW.TAXGR
      ,nquant     => RROW.PLANQUANT
      ,nquantalt  => RROW.PLANQUANTALT
      ,narticle   => RROW.ARTICLE
      ,ssernumb   => RROW.SERNUMB
      ,ncountry   => RROW.COUNTRY
      ,sgtd       => RROW.GTD
      ,rrow       => rInDocSpec
      );

      /* Сравнение сумм и количества с входным документом */
      if rRow.plansum    != rInDocSpec.summ      
      or rRow.plansumtax != rInDocSpec.summtax
      or rRow.plansumnds != rInDocSpec.summ_nds  
      or rRow.factquant  != rInDocSpec.quant then
        p_exception(0, 'Суммы или количество не равны спецификации входного документа <%s>. %s%s'
                   ,f_docdescrs_get_description(sunitcode => 'IncomingInvoices', ndocument => nInDoc)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rROW.RN)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rROW.PRN)); 
      end if;

      /* По калькуляциям */
      for c in ( select cost_article, cost_place, cost_plan, faceaccount, quant_plan
                   from inorderspecsclc t
                  where t.prn = rROW.RN
                 minus
                 select cost_article, cost_place, cost_plan, faceaccount, quant_plan
                   from ininvoicesspc t
                  where t.prn = rInDocSpec.rn )
      loop
        sVarchar := rRow.rn;
        sVarchar := strcombine( sVarchar, usr_pkg_fpdartcl.fpdartcl_get_code( nrn => c.cost_article, nflagsmart => 1 ), cr||'Статья затрат: ');
        sVarchar := strcombine( sVarchar, get_faceacc_numb_id( nflag_smart => 1, nrn => c.faceaccount ), cr||'Лицевой счёт: ');
        sVarchar := strcombine( sVarchar, c.quant_plan, cr||'Количество план: ');
        p_exception(0, 'Не найдена калькуляция входного документа. %s%s%s'
                   ,cr||sVarchar
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rROW.RN ) 
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rROW.PRN ) ); 
      end loop;
    end if;

  end INORDERSPECS_CHECK_INDOC;
  /*#########################################################################################################*/

  procedure INORDERSPECS_CHECK_OUT_DOCS
  /*
  Спецификация. Проверка выходных документов
  */
  (
   rROW             inorderspecs%rowtype
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
    /* Если найдены Сертификация/Входной контроль, связанные по цепочке */
    if nNumber is not null then
      /* По спецификациям РН в подразделения */
      for c in ( select pcs.prn as pcs_prn
                   from selectlist        sl
                   join udo_prod_cull_sp  pcs 
                     on pcs.prn   = sl.document
                    and pcs.modif = rROW.nommodif
                   join udo_prod_cull_out pco 
                     on pco.prn   = pcs.rn
                    and udo_pkg_prod_cull.cull_out_get_block_state( nrn => pco.rn, ddate => sysdate ) = 1
                  where sl.ident  = rROW.RN
              )
      loop
        /* Если состояние Сертификация/Входной контроль: Передано на склад, Проверено ВК, ожидание склада */
        p_exception(0, 'Исправление запрещено, т.к. документ "Сертификация/Входной контроль (результаты проверки)" отработан (заблокирован).%s%s%s'
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'UdoProdCull', ndocument => c.pcs_prn )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'IncomingOrdersSpecs', ndocument => rROW.RN )
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'IncomingOrders', ndocument => rROW.PRN) );
      end loop;                  
      /* Очистка */
      p_selectlist_clear( nident => rROW.RN );

    end if;                                              

  end INORDERSPECS_CHECK_OUT_DOCS;
  /*#########################################################################################################*/

  procedure INORDERSPECS_JOINS
  /*
  Спецификация. Считывание RN полей
  */
  (
   rV_ROW   in  v_inorderspecs%rowtype
  ,rROW     in out inorderspecs%rowtype
  ) 
  is
    nNumber     pkg_std.tnumber; 
  begin
    rROW.company := rV_ROW.ncompany;
    p_inorderspecs_joins(ncompany       => rV_ROW.nCOMPANY
                          ,snomen         => rV_ROW.SNOMEN
                          ,nnomen         => nNumber
                          ,staxgr         => rV_ROW.STAXGR
                          ,ntaxgr         => rROW.TAXGR
                          ,snomnmodifpack => rV_ROW.SNOMNMODIFPACK
                          ,nnomnmodifpack => rROW.NOMNMODIFPACK
                          ,snommodif      => rV_ROW.SNOMMODIF
                          ,nnommodif      => rROW.NOMMODIF
                          ,sarticle       => rV_ROW.SARTICLE
                          ,narticle       => rROW.ARTICLE
                          ,nstore         => null
                          ,scell          => rV_ROW.SCELL
                          ,ncell          => rROW.CELL
                          ,scountry       => rV_ROW.SCOUNTRY
                          ,ncountry       => rROW.COUNTRY
                          ,sproducer      => rV_ROW.SPRODUCER
                          ,nproducer      => rROW.PRODUCER
                          ,sumeas_storage => rV_ROW.SUMEAS_STORAGE
                          ,numeas_storage => rROW.UMEAS_STORAGE
                          /*Обновление 2024/03/28 */
                          ,sCOUNTRY_DOC   => rV_ROW.sCOUNTRY_DOC
                          ,nCOUNTRY_DOC   => rROW.COUNTRY_DOC
                          ,sCOUNTRY_FACT  => rV_ROW.sCOUNTRY_FACT
                          ,nCOUNTRY_FACT  => rROW.COUNTRY_FACT
                          );
  end INORDERSPECS_JOINS;
  /*#########################################################################################################*/

  procedure INORDERSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW       in inorderspecs%rowtype
  ,nDUP_RN    in number
  ,nDUP_CLC   in number
  ,nRN        out number
  ) 
  is
  begin
    p_inorderspecs_base_insert(ncompany         => rROW.COMPANY
                              ,nprn             => rROW.PRN
                              ,nnommodif        => rROW.NOMMODIF
                              ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                              ,narticle         => rROW.ARTICLE
                              ,ncell            => rROW.CELL
                              ,ntaxgr           => rROW.TAXGR
                              ,nplanquant       => rROW.PLANQUANT
                              ,nfactquant       => rROW.FACTQUANT
                              ,nplanquantalt    => rROW.PLANQUANTALT
                              ,nfactquantalt    => rROW.FACTQUANTALT
                              ,nprice           => rROW.PRICE
                              ,npricemeas       => rROW.PRICEMEAS
                              ,nprice_calc_rule => rROW.PRICE_CALC_RULE
                              ,nnds_coeff_sign  => rROW.NDS_COEFF_SIGN
                              ,nnds_coeff       => rROW.NDS_COEFF
                              ,nacc_price       => rROW.ACC_PRICE
                              ,nacc_pricemeas   => rROW.ACC_PRICEMEAS
                              ,nacc_summ        => rROW.ACC_SUMM
                              ,dexpiry_date     => rROW.EXPIRY_DATE
                              ,scertificate     => rROW.CERTIFICATE
                              ,nplansum         => rROW.PLANSUM
                              ,nplansumtax      => rROW.PLANSUMTAX
                              ,nplansumnds      => rROW.PLANSUMNDS
                              ,nfactsum         => rROW.FACTSUM
                              ,nfactsumtax      => rROW.FACTSUMTAX
                              ,nfactsumnds      => rROW.FACTSUMNDS
                              ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                              ,snote            => rROW.NOTE
                              ,ssernumb         => rROW.SERNUMB
                              ,sbarcode         => rROW.BARCODE
                              ,ncountry         => rROW.COUNTRY
                              ,sgtd             => rROW.GTD
                              ,nproducer        => rROW.PRODUCER
                              ,nstorage_time    => rROW.STORAGE_TIME
                              ,numeas_storage   => rROW.UMEAS_STORAGE
                              ,soriginal_name   => rROW.ORIGINAL_NAME
                              ,dprod_date       => rROW.PROD_DATE
                              ,scardnumb        => rROW.CARDNUMB
                              ,nmdmnomen        => rROW.MDMNOMEN
                              /*Обновление 2024/03/28 */
                              ,sSTR_CODE        => rROW.STR_CODE         /*  Код строки */
                              ,nBRAK_QUANT      => rROW.BRAK_QUANT       /*  Брак и бой в ЕИ цены */
                              ,nBRAK_SUM        => rROW.BRAK_SUM         /*  Брак и бой сумма с налогами */
                              ,nCOUNTRY_DOC     => rROW.COUNTRY_DOC      /*  Страна по документу */
                              ,nCOUNTRY_FACT    => rROW.COUNTRY_FACT     /*  Страна фактически */
                              ,sREG_NUM         => rROW.REG_NUM          /*  Несоответствующий регистрационный номер */
                              ,sMISMATCH        => rROW.MISMATCH         /*  Несоответствие требованиям и характеристикам */
                              ,sOTHER           => rROW.OTHER            /*  Прочее */
                              ,ndup_rn          => nDUP_RN 
                              ,ndup_clc         => nDUP_CLC
                              ,nrn              => nRN);
  end INORDERSPECS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INORDERSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW     in inorderspecs%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rInOrders           inorders%rowtype;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_inorderspecs_base_update(nrn              => rROW.RN
                                ,nprn             => rROW.PRN
                                ,ncompany         => rROW.COMPANY
                                ,nnommodif        => rROW.NOMMODIF
                                ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                ,narticle         => rROW.ARTICLE
                                ,ncell            => rROW.CELL
                                ,ntaxgr           => rROW.TAXGR
                                ,nplanquant       => rROW.PLANQUANT
                                ,nfactquant       => rROW.FACTQUANT
                                ,nplanquantalt    => rROW.PLANQUANTALT
                                ,nfactquantalt    => rROW.FACTQUANTALT
                                ,nprice           => rROW.PRICE
                                ,npricemeas       => rROW.PRICEMEAS
                                ,nprice_calc_rule => rROW.PRICE_CALC_RULE
                                ,nnds_coeff_sign  => rROW.NDS_COEFF_SIGN
                                ,nnds_coeff       => rROW.NDS_COEFF
                                ,nacc_price       => rROW.ACC_PRICE
                                ,nacc_pricemeas   => rROW.ACC_PRICEMEAS
                                ,nacc_summ        => rROW.ACC_SUMM
                                ,dexpiry_date     => rROW.EXPIRY_DATE
                                ,scertificate     => rROW.CERTIFICATE
                                ,nplansum         => rROW.PLANSUM
                                ,nplansumtax      => rROW.PLANSUMTAX
                                ,nplansumnds      => rROW.PLANSUMNDS
                                ,nfactsum         => rROW.FACTSUM
                                ,nfactsumtax      => rROW.FACTSUMTAX
                                ,nfactsumnds      => rROW.FACTSUMNDS
                                ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                ,snote            => rROW.NOTE
                                ,ssernumb         => rROW.SERNUMB
                                ,sbarcode         => rROW.BARCODE
                                ,ncountry         => rROW.COUNTRY
                                ,sgtd             => rROW.GTD
                                ,nproducer        => rROW.PRODUCER
                                ,nstorage_time    => rROW.STORAGE_TIME
                                ,numeas_storage   => rROW.UMEAS_STORAGE
                                ,soriginal_name   => rROW.ORIGINAL_NAME
                                ,dprod_date       => rROW.PROD_DATE
                                ,scardnumb        => rROW.CARDNUMB
                                ,nmdmnomen        => rROW.MDMNOMEN
                                /*обновление 2024/03/28 */
                                ,sstr_code        => rROW.STR_CODE         /*  Код строки */
                                ,nbrak_quant      => rROW.BRAK_QUANT       /*  Брак и бой в ЕИ цены */
                                ,nbrak_sum        => rROW.BRAK_SUM         /*  Брак и бой сумма с налогами */
                                ,ncountry_doc     => rROW.COUNTRY_DOC      /*  Страна по документу */
                                ,ncountry_fact    => rROW.COUNTRY_FACT     /*  Страна фактически */
                                ,sreg_num         => rROW.REG_NUM          /*  Несоответствующий регистрационный номер */
                                ,smismatch        => rROW.MISMATCH         /*  Несоответствие требованиям и характеристикам */
                                ,sother           => rROW.OTHER            /*  Прочее */
                                );
    /* Режим выполнения: 1 - пользовательский. 
       Если документ отработан, нимает отработку, исправляет, повторно отрабатывает. Иначе просто исправляет */
    elsif nMODE = 1 then

      /* Считывание заголовка */
      rInOrders := inorders_get( nrn => rROW.PRN );

      /* Если статус документа НЕ "Не отработан" */
      if rInOrders.docstatus != 0 then

        /* проверка до исправления */
        usr_pkg_inorders.inorderspecs_bupdate( nrn => rROW.RN, ncompany => rROW.COMPANY );

        /* Очистка заголовка для исправления */
        inorders_clear_for_update( nrn => rInOrders.rn, nmode => 0 );
        /* Исправление штатное */
        inorderspecs_base_update( rrow => rROW, nmode => 0 );

        /* Восстановление заголовка после исправления */
        inorders_clear_for_update( nrn => rInOrders.rn, nmode => 1 );

        /* проверка после исправления */
        usr_pkg_inorders.inorderspecs_aupdate( nrn => rROW.RN, ncompany => rROW.COMPANY );

      /* Если статус документа "Не отработан" */
      else
        /* Исправление штатное */
        inorderspecs_base_update( rrow => rROW, nmode => 0 );
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end INORDERSPECS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure INORDERSPECS_SEPARATION
  /*
  Спецификация. Разбивка на строки с одной штукой
  */
  (
   nRN                in number
  ) 
  is
    rRow              inorderspecs%rowtype;
    nCount            pkg_std.tnumber := 0; 
    nInOrderSpecs     pkg_std.tref; 
    rInOrderSpecsClc  inorderspecsclc%rowtype;
  begin
    /* Считывание */
    rRow      := inorderspecs_get(nrn => nRN);

    /* Проверки */
    if rRow.planquant != trunc(rRow.planquant) then
      p_exception(0, 'Указано дробное количество <%s>. %s%s'
                 ,rRow.planquant
                 ,cr||f_docdescrs_get_description('IncomingOrdersSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('IncomingOrders', rRow.prn)); 
    end if;

    /* Сохранение количества в переменную */
    nCount := rRow.factquant; 
    
    /* Исправление текущей записи. Количество указываем 1, в серию пишем Rn спецификации */
    /* пересчёт сумм в переменной на 1 шт. */
    rRow.plansum    := rRow.plansum    / rRow.planquant;
    rRow.factsum    := rRow.factsum    / rRow.factquant;
    rRow.plansumtax := rRow.plansumtax / rRow.planquant;
    rRow.factsumtax := rRow.factsumtax / rRow.factquant;
    rRow.plansumnds := rRow.plansumnds / rRow.planquant;
    rRow.factsumnds := rRow.factsumnds / rRow.factquant;
    rRow.acc_summ   := rRow.acc_summ   / rRow.factquant;
    /* подстановка в переменную количества 1 шт. */
    rRow.planquant := 1;
    rRow.factquant := 1;
    rRow.sernumb   := rRow.rn;
    /* исправление */
    inorderspecs_base_update(rrow => rRow);
 
    /* Исправление калькуляций текущей записи */
    for c in (select *
                from inorderspecsclc iosc
               where iosc.prn = rRow.rn)
    loop
      rInOrderSpecsClc := c;
      rInOrderSpecsClc.cost_plan := rInOrderSpecsClc.cost_plan / rInOrderSpecsClc.quant_plan;
      rInOrderSpecsClc.cost_fact := rInOrderSpecsClc.cost_fact / rInOrderSpecsClc.quant_fact;
      rInOrderSpecsClc.quant_plan := 1;
      rInOrderSpecsClc.quant_fact := 1;
      inorderspecsclc_base_update(rrow => rInOrderSpecsClc);
    end loop;               
    
    /* Добавление новых записей по 1 штуке */
    while nCount != 1
    loop
      /* счётчик количества */
      nCount       := nCount - 1;
      /* обнуляем серию в переменной и добавляем новую спецификацию */
      /*rRow.sernumb := null;*/
      inorderspecs_base_insert(rrow     => rRow
                              ,ndup_rn  => rRow.rn
                              ,ndup_clc => 1
                              ,nrn      => nInOrderSpecs);
      inorderspecs_ainsert(nrn => nInOrderSpecs, ncompany => rRow.company);

      /* записываем в переменную новый RN его же в серию. Исправляем новую спецификацию */
      /*rRow.rn      := nInOrderSpecs;
      rRow.sernumb := nInOrderSpecs;
      inorderspecs_base_update(rrow => rRow);
      inorderspecs_aupdate(nrn => rRow.rn, ncompany => rRow.company);*/
    end loop;

  end INORDERSPECS_SEPARATION;
  /*#########################################################################################################*/

  procedure INORDERSPECS_MSG_SEND
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW         in inorderspecs%rowtype
  ,rROW_BEFORE  in inorderspecs%rowtype
  ) 
  is
    nPayAccIn         pkg_std.tref; 
    nUserAgn          pkg_std.tref; 
    rAgnList          agnlist%rowtype;
    rClnEvents        clnevents%rowtype;
    sCtext            pkg_std.tstring; 
    sTo_List          pkg_std.tstring := 'd.nikolenko@module.ru;olga81@module.ru;r.buchenkov@module.ru';

    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring;
  begin
    /* Составление текста результатов исправления */
    if cmp_num( usr_pkg_dicnomns.nommodif_get_prn_by_rn( nflagsmart => 1, nrn => rRow_Before.nommodif )
              , usr_pkg_dicnomns.nommodif_get_prn_by_rn( nflagsmart => 1, nrn => rRow.nommodif ) ) != 1 then
      sCtext := strcombine( sCtext, get_dicnomns_code_id( nflag_smart => 1
                                                         ,nrn => usr_pkg_dicnomns.nommodif_get_prn_by_rn( nflagsmart => 1, nrn => rRow_Before.nommodif ) )
                                  , 'Номенклатура было: ' );
      sCtext := strcombine( sCtext, get_dicnomns_code_id( nflag_smart => 1
                                                         ,nrn => usr_pkg_dicnomns.nommodif_get_prn_by_rn( nflagsmart => 1, nrn => rRow.nommodif ) )
                                  , ', стало: ' );
    end if;
    if cmp_num( rRow_Before.nommodif, rRow.nommodif ) != 1 then
      sCtext := strcombine( sCtext, usr_pkg_dicnomns.nommodif_get_code_by_rn( nflagsmart => 1, nrn => rRow_Before.nommodif ), cr||'Модификация было: ' ) ;
      sCtext := strcombine( sCtext, usr_pkg_dicnomns.nommodif_get_code_by_rn( nflagsmart => 1, nrn => rRow.nommodif ), ', стало: ' );
    end if;
    if cmp_num( rRow_Before.TaxGr, rROW.TAXGR ) != 1 then
      sVarchar := null;
      find_dictaxgr_rn( nflag_smart  => 0
                       ,nflag_option => 0
                       ,ncompany     => rRow_Before.company
                       ,nrn          => rRow_Before.taxgr
                       ,scode        => sVarchar );
      sCtext := strcombine( sCtext, sVarchar, cr||'Налоговая группа было: ' );
      sVarchar := null;
      find_dictaxgr_rn( nflag_smart  => 0
                       ,nflag_option => 0
                       ,ncompany     => rRow_Before.company
                       ,nrn          => rROW.TAXGR
                       ,scode        => sVarchar );
      sCtext := strcombine( sCtext, sVarchar, ', стало: ' );
    end if;
    if cmp_num( rRow_Before.factquant, rROW.FACTQUANT ) != 1 then
      sCtext := strcombine( sCtext, usr_f_n2sq( rRow_Before.factquant ), cr||'Количество было: ' );
      sCtext := strcombine( sCtext, usr_f_n2sq( rROW.FACTQUANT ), ', стало: ' );
    end if;
    if cmp_num( rRow_Before.price, rROW.PRICE ) != 1 then
      sCtext := strcombine( sCtext, usr_f_n2ss( rRow_Before.price ), cr||'Цена было: ' );
      sCtext := strcombine( sCtext, usr_f_n2ss( rROW.PRICE ), ', стало: ' );
    end if;
    if cmp_num( rRow_Before.factsum, rROW.FACTSUM )  != 1 then
      sCtext := strcombine( sCtext, usr_f_n2ss( rRow_Before.factsum ), cr||'Сумма без НДС было: ' );
      sCtext := strcombine( sCtext, usr_f_n2ss( rROW.FACTSUM ), ', стало: ' );
    end if;
    if cmp_num( rRow_Before.factsumtax, rROW.FACTSUMTAX ) != 1 then
      sCtext := strcombine( sCtext, usr_f_n2ss( rRow_Before.factsumtax ), cr||'Сумма с НДС было: ' );
      sCtext := strcombine( sCtext, usr_f_n2ss( rROW.FACTSUMTAX ), ', стало: ' );
    end if;
    if cmp_num( rRow_Before.factsumnds, rROW.FACTSUMNDS ) != 1 then
      sCtext := strcombine( sCtext, usr_f_n2ss( rRow_Before.factsumnds ), cr||'Сумма НДС было: ' );
      sCtext := strcombine( sCtext, usr_f_n2ss( rROW.FACTSUMNDS ), ', стало: ' );
    end if;
    if cmp_vc2( rRow_Before.original_name, rROW.ORIGINAL_NAME ) != 1 then
      sCtext := strcombine( sCtext, rRow_Before.original_name, cr||'Оригинальное наименование было: ' );
      sCtext := strcombine( sCtext, rROW.ORIGINAL_NAME, ', стало: ' );
    end if;
    /*if cmp_vc2( rRow_Before.note, rROW.NOTE ) != 1 then
      sCtext := strcombine( sCtext, rRow_Before.note ), 'Примечание было:' );
      sCtext := strcombine( sCtext, rROW.NOTE ), 'Примечание стало:' );
    end if;*/

    /* Если текст изменений не пустой */
    if sCtext is not null then
      /* Добавление в начало текста изменений */
      /* Номер по порядку спецификации из свойства */
      sVarchar := null;
      sVarchar := usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 13884319, sunitcode => 'IncomingOrdersSpecs', ndocument => rROW.RN );
      sCtext   := strcombine( sVarchar, sCtext, cr||'Номер по порядку: ' ) ;
      /* RN спецификации */
      sCtext := strcombine( sCtext, rROW.RN, cr||'RN: ' ) ;

      /* RN родительского входящего счёта */
      nPayAccIn := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                 ,sout_unitcode => 'IncomingOrders'
                                                 ,nout_document => rROW.PRN
                                                 ,sin_unitcode  => 'PaymentAccountsIn' );
      /* поиск контрагента пользователя */
      find_agnlist_authid( nflag_option => 0
                          ,ncompany     => rROW.COMPANY
                          ,spers_authid => utilizer
                          ,nagent       => nUserAgn );
      /* считывание контрагента пользователя */
      rAgnList := usr_pkg_agnlist.agnlist_get( nrn => nUserAgn );
      /* добавление контрагента пользователя в рассылку */
      sTo_List := strcombine( sTo_List, rAgnList.mail, ';' );
      /* поиск события */
      rClnEvents.rn := usr_pkg_document.get_clnevents( nflagsmart => 1, nrn => nPayAccIn );
      /* если событие найдено */
      if rClnEvents.rn is not null then
        rClnEvents := usr_pkg_clnevents.clnevents_get( nrn => rClnEvents.rn );
        /* поиск инициатора события */
        if rClnEvents.init_person is not null then
          rAgnList := null;
          find_clnpersons_agent( nflag_smart  => 1
                                ,ncompany     => rROW.COMPANY
                                ,sperson_code => get_clnpersons_code_id( nflag_smart => 1, nrn => rClnEvents.init_person )
                                ,nrn          => rAgnList.rn
                                ,sagnabbr     => rAgnList.agnabbr );
          /* считывание адреса инициатора события */
          if rAgnList.rn is not null then                                    
            rAgnList := usr_pkg_agnlist.agnlist_get( nrn => rAgnList.rn );
            /* добавление адреса инициатора события в список рассылки */
            sTo_List := strcombine( sTo_List, rAgnList.mail, ';' );
          end if;
        end if;
      end if;

      /* реквизиты документа */
      sVarchar := f_docdescrs_get_description( sunitcode => 'IncomingOrders', ndocument => rROW.PRN );

      /* Отправка уведомления */
      usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany     => rROW.company
                                                 ,sdescription => 'Исправлен отработанный приходный ордер ' || sVarchar
                                                 ,sto_list     => usr_pkg_common.get_list_distinct( sTo_List )
                                                 ,stitle       => 'Исправлен отработанный приходный ордер ' || sVarchar
                                                 ,ctext        => trim ( sCtext )
                                                 ,nrn          => nNumber);
    end if;

  end INORDERSPECS_MSG_SEND;
  /*#########################################################################################################*/

  procedure INORDSPBUFF_BASE_INSERT
  /*
  Спецификация (буфер). Добавление базовое
  */
  (
   rROW         in inordspbuff%rowtype
  ,nSOURCE_RN   in number
  ,nRN          out number 
  ) 
  is
  begin
    p_inordspbuff_base_insert( ncompany         => rROW.COMPANY
                              ,nprn             => rROW.PRN
                              ,nnomen           => rROW.NOMEN
                              ,nnomnpack        => rROW.NOMNPACK
                              ,nnommodif        => rROW.NOMMODIF
                              ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                              ,narticle         => rROW.ARTICLE
                              ,ncell            => rROW.CELL
                              ,ntaxgr           => rROW.TAXGR
                              ,nplanquant       => rROW.PLANQUANT
                              ,nfactquant       => rROW.FACTQUANT
                              ,nplanquantalt    => rROW.PLANQUANTALT
                              ,nfactquantalt    => rROW.FACTQUANTALT
                              ,nprice           => rROW.PRICE
                              ,npricemeas       => rROW.PRICEMEAS
                              ,nprice_calc_rule => rROW.PRICE_CALC_RULE
                              ,nnds_coeff_sign  => rROW.NDS_COEFF_SIGN
                              ,nnds_coeff       => rROW.NDS_COEFF
                              ,nacc_price       => rROW.ACC_PRICE
                              ,nacc_pricemeas   => rROW.ACC_PRICEMEAS
                              ,dexpiry_date     => rROW.EXPIRY_DATE
                              ,scertificate     => rROW.CERTIFICATE
                              ,snote            => rROW.NOTE
                              ,nplansum         => rROW.PLANSUM
                              ,nplansumtax      => rROW.PLANSUMTAX
                              ,nplansumnds      => rROW.PLANSUMNDS
                              ,nfactsum         => rROW.FACTSUM
                              ,nfactsumtax      => rROW.FACTSUMTAX
                              ,nfactsumnds      => rROW.FACTSUMNDS
                              ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                              ,ssernumb         => rROW.SERNUMB
                              ,sbarcode         => rROW.BARCODE
                              ,ncountry         => rROW.COUNTRY
                              ,sgtd             => rROW.GTD
                              ,nproducer        => rROW.PRODUCER
                              ,nstorage_time    => rROW.STORAGE_TIME
                              ,numeas_storage   => rROW.UMEAS_STORAGE
                              ,soriginal_name   => rROW.ORIGINAL_NAME
                              ,dprod_date       => rROW.PROD_DATE
                              ,scardnumb        => rROW.CARDNUMB
                              ,nmdmnomen        => rROW.MDMNOMEN
                              ,sstr_code        => rROW.STR_CODE
                              ,nbrak_quant      => rROW.BRAK_QUANT
                              ,nbrak_sum        => rROW.BRAK_SUM
                              ,ncountry_doc     => rROW.COUNTRY_DOC
                              ,ncountry_fact    => rROW.COUNTRY_FACT
                              ,sreg_num         => rROW.REG_NUM
                              ,smismatch        => rROW.MISMATCH
                              ,sother           => rROW.OTHER
                              ,nrn              => nRN
                              ,nsource_rn       => nSOURCE_RN );
  end INORDSPBUFF_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INORDSPBUFF_BASE_UPDATE
  /*
  Спецификация (буфер). Исправление базовое
  */
  (
   rROW               in inordspbuff%rowtype
  ,nFLAG_DEL_CALC     in number default 0
  ) 
  is
  begin
    p_inordspbuff_base_update( nrn              => rROW.RN
                              ,nprn             => rROW.PRN
                              ,ncompany         => rROW.COMPANY
                              ,nnomen           => rROW.NOMEN
                              ,nnomnpack        => rROW.NOMNPACK
                              ,nnommodif        => rROW.NOMMODIF
                              ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                              ,narticle         => rROW.ARTICLE
                              ,ncell            => rROW.CELL
                              ,ntaxgr           => rROW.TAXGR
                              ,nplanquant       => rROW.PLANQUANT
                              ,nfactquant       => rROW.FACTQUANT
                              ,nplanquantalt    => rROW.PLANQUANTALT
                              ,nfactquantalt    => rROW.FACTQUANTALT
                              ,nprice           => rROW.PRICE
                              ,npricemeas       => rROW.PRICEMEAS
                              ,nprice_calc_rule => rROW.PRICE_CALC_RULE
                              ,nnds_coeff_sign  => rROW.NDS_COEFF_SIGN
                              ,nnds_coeff       => rROW.NDS_COEFF
                              ,nacc_price       => rROW.ACC_PRICE
                              ,nacc_pricemeas   => rROW.ACC_PRICEMEAS
                              ,nacc_summ        => rROW.ACC_SUMM
                              ,dexpiry_date     => rROW.EXPIRY_DATE
                              ,scertificate     => rROW.CERTIFICATE
                              ,snote            => rROW.NOTE
                              ,nplansum         => rROW.PLANSUM
                              ,nplansumtax      => rROW.PLANSUMTAX
                              ,nplansumnds      => rROW.PLANSUMNDS
                              ,nfactsum         => rROW.FACTSUM
                              ,nfactsumtax      => rROW.FACTSUMTAX
                              ,nfactsumnds      => rROW.FACTSUMNDS
                              ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                              ,ssernumb         => rROW.SERNUMB
                              ,sbarcode         => rROW.BARCODE
                              ,ncountry         => rROW.COUNTRY
                              ,sgtd             => rROW.GTD
                              ,nproducer        => rROW.PRODUCER
                              ,nstorage_time    => rROW.STORAGE_TIME
                              ,numeas_storage   => rROW.UMEAS_STORAGE
                              ,soriginal_name   => rROW.ORIGINAL_NAME
                              ,dprod_date       => rROW.PROD_DATE
                              ,scardnumb        => rROW.CARDNUMB
                              ,nmdmnomen        => rROW.MDMNOMEN
                              ,sstr_code        => rROW.STR_CODE
                              ,nbrak_quant      => rROW.BRAK_QUANT
                              ,nbrak_sum        => rROW.BRAK_SUM
                              ,ncountry_doc     => rROW.COUNTRY_DOC
                              ,ncountry_fact    => rROW.COUNTRY_FACT
                              ,sreg_num         => rROW.REG_NUM
                              ,smismatch        => rROW.MISMATCH
                              ,sother           => rROW.OTHER
                              ,nflag_del_calc   => nFLAG_DEL_CALC );
  end INORDSPBUFF_BASE_UPDATE;
    /*#########################################################################################################*/

  procedure INORDSPBUFF_UPDATE_PCR
  /*
  Спецификация. Исправление поля "Правило расчета учетной цены" (PRICE_CALC_RULE)
  */
  (
   nFLAGSMART         in number default 0
  ,nRN                in number
  ,nPRICE_CALC_RULE   in number /* 0 - включают, 1 - не включают */
  ) 
  is
    rRow              inordspbuff%rowtype;
    rInOrdersBuff     inordersbuff%rowtype;
  begin
    /* Считывание */
    begin
      select * into rRow from inordspbuff where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nrn, get_unitlist_code_table(1, 'INORDSPBUFF'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(get_unitlist_code_table(1, 'INORDSPBUFF')));
    end;
    /* Заголовок */
    select * into rInOrdersBuff from inordersbuff where rn = rRow.prn;

    /* Проверка параметров*/    
    /* Не задан */
    if nPRICE_CALC_RULE is null then
      p_exception(0, 'Не задан параметр процедуры "Правила расчёта учётной цены". %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)); 
    elsif nPRICE_CALC_RULE not in (0, 1) then
      p_exception(0, 'Неверное значение: "%s" параметра процедуры "Правила расчёта учётной цены". %s'
                 ,nPRICE_CALC_RULE
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)); 
    end if;

    /* Имеет такое же значение, как в документе */
    if (rRow.price_calc_rule != nPRICE_CALC_RULE and nPRICE_CALC_RULE is not null)
    and nFLAGSMART = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.price_calc_rule when 0 then 'Да' else 'Нет' end
                ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)); 
    end if;
      
    /* Расчёт сумм */
    pkg_dictaxis_calc.p_calculate_base( nflag_smart => 0
                                       ,ncompany    => rRow.company
                                       ,ddate       => rInOrdersBuff.indocdate
                                       ,nsumm_sign  => 1 /* сумма с налогами */
                                       ,ninsumm     => rRow.factsumtax
                                       ,ntaxgr      => rRow.taxgr
                                       ,nquant      => 1
                                       ,nncp_sign   => 1 );

    /* Сохранение сумм в переменную */
    rRow.acc_summ := case nPRICE_CALC_RULE
                       when 0 then pkg_dictaxis_calc.f_get_value(2) /* Сумма со всеми налогами (2) */
                       else pkg_dictaxis_calc.f_get_value(0)        /* Сумма без налогов (0) */
                     end;
    rRow.acc_price := rRow.acc_summ / rRow.factquant;               /* Цена */

    /* Исправление спецификации */
    rRow.price_calc_rule := nPRICE_CALC_RULE;
    inordspbuff_base_update(rrow => rRow);

    
  end INORDSPBUFF_UPDATE_PCR;
  /*#########################################################################################################*/  

  function INORDERSPECSCLC_GET
  /*
  Спецификация (калькуляция). Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0
  ) 
  return inorderspecsclc%rowtype
  is
    rRow inorderspecsclc%rowtype;
  begin
    begin
      select * into rRow from inorderspecsclc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'INORDERSPECSCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERSPECSCLC')) 
                   ,cr||cr||sqlerrm);
    end;

    return(rRow);

  end INORDERSPECSCLC_GET;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_AINSERT
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
    inorderspecsclc_check_base(nrn => nRN, ncompany => nCOMPANY);
    /* Добавление, исправление, удаление */
    inorderspecsclc_check_iud(nrn => nRN);

  end INORDERSPECSCLC_AINSERT;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BUPDATE
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
  end INORDERSPECSCLC_BUPDATE;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_AUPDATE
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
    inorderspecsclc_check_base(nrn => nRN, ncompany => nCOMPANY);
    /* Добавление, исправление, удаление */
    inorderspecsclc_check_iud(nrn => nRN);

  end INORDERSPECSCLC_AUPDATE;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BDELETE
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
    inorderspecsclc_check_iud(nrn => nRN);

  end INORDERSPECSCLC_BDELETE;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_CHECK_BASE
  /*
  Спецификация (калькуляция). Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              inorderspecsclc%rowtype;
    rInOrderSpecs     inorderspecs%rowtype;
  begin
    /* Считывание */
    rRow          := inorderspecsclc_get( nrn => nRN );
    rInOrderSpecs := inorderspecs_get( nrn => rRow.prn );

    /* ПРОВЕРКИ */
    /* Лицевой счёт не задан */
    if rRow.faceaccount is null then
      p_exception(0, 'Не задан лицевой счёт в калькуляции спецификации приходного ордера.%s%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecsCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rInOrderSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rInOrderSpecs.prn ) );
    end if;
    /* Дублирование калькуляций */
    for c in ( select t1.rn
                 from inorderspecsclc t1
                     ,inorderspecsclc t2
                where t1.prn  = rRow.prn
                  and t1.prn  = t2.prn
                  and t1.rn  != t2.rn
                  and nvl( t1.faceaccount, -1 ) = nvl( t2.faceaccount, -1 ) )
    loop
      p_exception(0, 'Дублирование калькуляции спецификации приходного ордера.%s%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecsCalcs', ndocument => c.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rInOrderSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rInOrderSpecs.prn ) );
    end loop;

  end INORDERSPECSCLC_CHECK_BASE;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_CHECK_IUD
  /*
  Спецификация (калькуляция). Проверка при добавлении/исправлении/удалении
  */
  (
   nRN        in number
  ) 
  is
    rRow            inorderspecsclc%rowtype;
    rInOrderSpecs   inorderspecs%rowtype;
    nHead           pkg_std.tref; 
    nSpec           pkg_std.tref; 
    nHeadState      pkg_std.tnumber; 
    nInDoc          pkg_std.tref; 
  begin
    /* Считывание */
    rRow          := inorderspecsclc_get( nrn => nRN );
    rInOrderSpecs := inorderspecs_get( nrn => rRow.prn );
    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode  => 'IncomingOrders'
                                                   ,nout_document  => rInOrderSpecs.prn
                                                   ,sin_unitcode   => 'IncomingInvoices');
    /* ПРОВЕРКИ */
    /* Если документ имеет связь по входу и выполняется штатное действие */
    if nInDoc is not null 
    and not usr_pkg_common.is_lists_intersect(slist1 => 'INORDERSPECSCLC_CHECK_IUD.1', slist2 => usr_pkg_pub_const.sexceptionlist) then
      p_exception(0, 'Запрещены изменения Приходного ордера. Для исправления удалите Приходный ордер, внесите исправление '||
                  'в Приходную накладную, повторно сформируйте Приходный ордер.%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rInOrderSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => rInOrderSpecs.prn ) ); 
    end if;                 


    /* Считывание RN заголовка, спецификации и статуса документа */
    begin
      select h.rn , h.docstatus, s.rn
        into nHead, nHeadState , nSpec
        from inorderspecsclc c
            ,inorderspecs    s
            ,inorders        h
       where c.rn = nRN
         and s.rn  = c.prn
         and h.rn   = s.prn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'INORDERSPECSCLC');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERSPECSCLC'))
                   ,cr||cr||sqlerrm);
    end;

    /* Статус документа отличен от  "Не утверждён" */
    if nHeadState != 0 --and utilizer != 'KHOK'
    and not usr_pkg_common.is_lists_intersect(slist1 => 'INORDERSPECSCLC_CHECK_IUD.1', slist2 => usr_pkg_pub_const.sexceptionlist) then 
      /* сообщение */
      p_exception(0, 'Запрещены изменения документа в статусе <%s>. %s%s.'
                 ,inorders_get_status_name(nstate => nHeadState)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => nSpec)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomingOrders', ndocument => nHead));
    end if;

    /* Очистка списка исключений */
    if usr_pkg_pub_const.sexceptionlist is not null then
      usr_pkg_pub_const.sexceptionlist := null;
    end if;

  end INORDERSPECSCLC_CHECK_IUD;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_JOINS
  /*
  Калькуляция. Считывание RN полей
  */
  (
   rV_ROW   in  v_inorderspecsclc%rowtype
  ,rROW     in out inorderspecsclc%rowtype
  ) 
  is
  begin
    rROW.company := rV_ROW.ncompany;
    p_inorderspecsclc_joins(ncompany      => rV_ROW.nCOMPANY
                           ,scost_article => rV_ROW.SCOST_ARTICLE
                           ,scost_place   => rV_ROW.SCOST_PLACE
                           ,sfaceaccount  => rV_ROW.SFACEACCOUNT
                           ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                           ,sfinoper_type => rV_ROW.SFINOPER_TYPE
                           ,ssubdiv       => rV_ROW.SSUBDIV
                           ,ncost_article => rROW.COST_ARTICLE
                           ,ncost_place   => rROW.COST_PLACE
                           ,nfaceaccount  => rROW.FACEACCOUNT
                           ,ngraphpoint   => rROW.GRAPHPOINT
                           ,nfinoper_type => rROW.FINOPER_TYPE
                           ,nsubdiv       => rROW.SUBDIV);
  end INORDERSPECSCLC_JOINS;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BASE_INSERT
  /*
  Спецификация (калькуляция). Добавление базовое
  */
  (
   rROW   in inorderspecsclc%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_inorderspecsclc_base_insert(ncompany      => rROW.COMPANY
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
  end INORDERSPECSCLC_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_BASE_UPDATE
  /*
  Спецификация (калькуляция). Исправление базовое
  */
  (
   rROW   in inorderspecsclc%rowtype
  ) 
  is
  begin
      p_inorderspecsclc_base_update(nrn           => rRow.rn
                               ,ncompany      => rRow.company
                               ,snumb         => rRow.numb
                               ,ncost_article => rRow.cost_article
                               ,ncost_place   => rRow.cost_place
                               ,ncost_plan    => rRow.cost_plan
                               ,ncost_fact    => rRow.cost_fact
                               ,npriority     => rRow.priority
                               ,nfaceaccount  => rRow.faceaccount
                               ,ngraphpoint   => rRow.graphpoint
                               ,nfinoper_type => rRow.finoper_type
                               ,nquant_plan   => rRow.quant_plan
                               ,nquant_fact   => rRow.quant_fact
                               ,nsubdiv       => rRow.subdiv);

  end INORDERSPECSCLC_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure INORDERSPECSCLC_GET_IIVSC_QNT
  /*
  Спецификация (калькуляция). Получить количество по калькуляциям выходных документов
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
                from inorderspecsclc  paisc
                    ,inorderspecs     pais
                    ,doclinks         dl
                    ,rinvtosupspecs   inds
                    ,rinvtosupclc     indsc
               where paisc.rn          = nRN
                 and pais.rn           = paisc.prn
                 and dl.in_document    = pais.prn
                 and dl.out_unitcode   = 'ReturnInvoicesToSuppliers'
                 and dl.out_document   = inds.prn
                 and inds.nommodif     = pais.nommodif
                 and indsc.prn         = inds.rn
                 and indsc.faceacc     = paisc.faceaccount
                 and nvl(indsc.faceacc, 0) =  nvl(paisc.faceaccount, 0)
             ) a
             ;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при подсчёте количества по калькуляциям приходных документов. %s', nRN); 
    end;
  end INORDERSPECSCLC_GET_IIVSC_QNT;
  /*#########################################################################################################*/

  procedure INORDERSPECS_UPDATE_PCR
  /*
  Спецификация. Исправление поля "Правило расчета учетной цены" (PRICE_CALC_RULE)
  */
  (
   nFLAGSMART         in number default 0
  ,nRN                in number
  ,nPRICE_CALC_RULE   in number /* 0 - включают, 1 - не включают */
  ) 
  is
    rRow              inorderspecs%rowtype;
    rInOrders         inorders%rowtype;
  begin
    /* Считывание */
    rRow      := inorderspecs_get(nrn => nRN);
    rInOrders := inorders_get(nrn => rRow.prn);

    /* Проверка параметров*/    
    /* Не задан */
    if nPRICE_CALC_RULE is null then
      P_EXCEPTION(0, 'Не задан параметр процедуры "Правила расчёта учётной цены". %s'
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomingOrdersSpecs', rRow.rn)); 
    elsif nPRICE_CALC_RULE not in (0, 1) then
      p_exception(0, 'Неверное значение: "%s" параметра процедуры "Правила расчёта учётной цены". %s'
                 ,nPRICE_CALC_RULE
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)); 
    end if;

    /* Имеет такое же значение, как в документе */
   /* if (rRow.price_calc_rule = nPRICE_CALC_RULE and nPRICE_CALC_RULE is not null )
    and nFLAGSMART = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.price_calc_rule when 0 then 'Да' else 'Нет' end
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomingOrdersSpecs', ndocument => rRow.rn)); 
    end if;*/
      
    /* Расчёт сумм */
    pkg_dictaxis_calc.p_calculate_base
    (
     nflag_smart => 0
    ,ncompany    => rRow.company
    ,ddate       => rInOrders.indocdate
    ,nsumm_sign  => 1   /* сумма с налогами */
    ,ninsumm     => rRow.factsumtax
    ,ntaxgr      => rRow.taxgr
    ,nquant      => 1
    ,nncp_sign   => 1
    );

    /* Сохранение сумм в переменную */
    rRow.acc_summ := case nPRICE_CALC_RULE
                       when 0 then pkg_dictaxis_calc.f_get_value(2) /* Сумма со всеми налогами (2) */
                       else pkg_dictaxis_calc.f_get_value(0)        /* Сумма без налогов (0) */
                     end;
    rRow.acc_price := rRow.acc_summ / rRow.factquant;               /* Цена */

    /* Исправление спецификации */
    rRow.price_calc_rule := nPRICE_CALC_RULE;
    inorderspecs_base_update(rROW => rRow);
    
  end INORDERSPECS_UPDATE_PCR;
  /*#########################################################################################################*/

end USR_PKG_INORDERS;
/*
CREATE PUBLIC SYNONYM USR_PKG_INORDERS FOR USR_PKG_INORDERS;
GRANT EXECUTE ON USR_PKG_INORDERS TO PUBLIC;
*/
/
