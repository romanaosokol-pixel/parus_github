create or replace package USR_PKG_TRANSINVCUST is
  /*
  create public synonym usr_pkg_transinvcust for usr_pkg_transinvcust;
  grant execute on usr_pkg_transinvcust to public;

  Package предназначен для работы с разделом "Расходные накладные на отпуск потребителям".
  GoodsTransInvoicesToConsumers       TRANSINVCUST                TIC
  GoodsTransInvoicesToConsumersSpecs  TRANSINVCUSTSPECS           TICS
  GoodsTransInvoicesToConsumersCalcs  TRINVCUSTCLC                TICSC
  */
  /*#########################################################################################################*/

  function TRANSINVCUST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvcust%rowtype;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BDELETE
  /*
  Заголовок. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BPROCESS
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) ;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_APROCESS
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMAKEINV
  /*
  Заголовок. Формирование возвратных расходных накладных. До
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AMAKEINV
  /*
  Заголовок. Формирование возвратных расходных накладных. После
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ); 
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMAKEININV
  /*
  Заголовок. Формирование приходных накладных. До
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AMAKEININV
  /*
  Заголовок. Формирование приходных накладных. После
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMAKEACCFI
  /*
  Заголовок. Формирование входящего счета-фактуры. До
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AMAKEACCFI
  /*
  Заголовок. Формирование входящего счета-фактуры. После
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_INSERT
  /*
  Заголовок. Добавить
  */
  (
   rV_ROW       in out v_transinvcust%rowtype
  ,nDUP_RN      in number
  ,sMSG         out varchar2
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_UPDATE
  /*
  Заголовок. Исправить
  */
  (
   rV_ROW       in v_transinvcust%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BASE_INSERT
  /*
  Заголовок. Добавить базовая
  */
  (
   rROW           in transinvcust%rowtype
  ,nRESERV_SIGN   in number 
  ,nRN            out number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BASE_UPDATE
  /*
  Заголовок. Исправить базовая
  */
  (
   rROW         in transinvcust%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ); 
  /*#########################################################################################################*/

  /* процедура пересчета исполнения у родительских документов 
  по мотивам P_TRANSINVCUST_BSET_STATUS */
  procedure TRANSINVCUST_RECALC_PERF
  (
   nCOMPANY        in number            /* организация */
  ,nRN             in number            /* RN накладной на отпуск потребителям */
  ,nSTATUS         in number            /* состояние (0 - снять отработку, 1 - отработать как план, 2 - отработать как Факт) */
  ,dWORK_DATE      in date              /* дата смены состояния */
  );
  /*########################################################################################################*/

  procedure TRANSINVCUST_SPRJ_COPY_OTHER
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

  procedure TRANSINVCUST_CREATE_COPY
  /*
  Заголовок. Создать копии документа
  Нужно для случаев, когда исправляемая накладная содержит изделие, которое числится у нас на складе.
  Делаем копию накладной, отгружаем по ней такие изделия.
  */
  (
   nRN              in number
  ,aRN_LIST         out udo_tp_numtable
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_DELETE_COPY
  /*
  Заголовок. Удалить копии
  */
  (
   nCOMPANY   in number
  ,aRN_LIST   in udo_tp_numtable
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_MAKEINV
  /*
  Заголовок. Формирование возвратных расходных накладных
  */
  (
   nRN   in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_MAKEININV
  /*
  Заголовок. Формирование приходных накладных
  */
  (
   nRN          in number  
  ,nCOMPANY     in number  
  ,nIDENT       in number  
  ,sCATALOG     in varchar2
  ,sDOCTYPE     in varchar2
  ,sPREF        in varchar2
  ,dDOCDATE     in date
  ,sEXT_NUMB    in varchar2
  ,dDEXT_DATE   in date
  ,sSTORE       in varchar2
  ,sSTOREOPER   in varchar2
  ,sFACEACC     in varchar2
  ,nMAKE_IO     in number       /* формировать приходные ордера */
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUST_MAKEACCFI
  /*
  Заголовок. Формирование входящего счета-фактуры
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,sCATALOG         in varchar2               /* мнемокод каталога ВСФ */
  ,sPREFIX          in varchar2               /* префикс ВСФ */
  ,dDATE            in date                   /* дата ВСФ */
  ,dINC_DATE        in date                   /* дата поступления документа */
  ,sIN_NUMBER       in varchar2               /* номер поставщика */
  ,sAGNFO           in varchar2 default null  /* грузоотправитель */
  ,sAGNACC          in varchar2               /* банковские реквизиты поставщика */
  ,sSELFAGNACC      in varchar2               /* банковские реквизиты покупателя */
  ,sCURRENCY        in varchar2               /* валюта формируемого ВСФ */
  ,nGROUPMASTER     in number   default 0     /* консолидация заголовков (0-нет, 1-по контрагенту, 2-по ЛС) */
  ,nGROUPSLAVE      in number   default 0     /* консолидация спецификаций (0-нет, 1-по номенклатуре, 2-по модификациям) */
  ,nGROUPPRICE      in number   default 0     /* консолидация спецификаций по цене (0-нет, 1-да) */
  ,nAUTOCALCSIGN    in number   default 1     /* производить автаматический пересчет сумм в спецификации (0-нет, 1-да) */
  ,nTRUE_REC        out number                /* признак cформирования хотя бы одной записи (null - ошибка, 0 - нет, >=1 - да) */
  );
  /*#########################################################################################################*/

  function TRANSINVCUSTSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return TRANSINVCUSTSPECS%ROWTYPE;
  /*#########################################################################################################*/
  
  PROCEDURE TRANSINVCUSTSPECS_GET_BY_PRM
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,NGOODSPARTY        IN NUMBER   DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT TRANSINVCUSTSPECS%ROWTYPE 
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации
  */
  (
   rROW   in transinvcustspecs%rowtype
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_INSERT
  /*
  Спецификация. Добавить
  */
  (
   rV_ROW       in out v_transinvcustspecs%rowtype
  ,sMSG         out varchar2
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_UPDATE
  /*
  Спецификация. Исправить
  */
  (
   rV_ROW           in v_transinvcustspecs%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ,sMSG             out varchar2
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_UPDATE
  /*
  Спецификация. Исправить. Для вызова из процедур
  */
  (
   nRN                  in number
  ,sTAXGR               in varchar2
  ,nSUMMWITHNDS         in number
  ,nGET_PRICE_FROM_FA   in number     /* Использовать цену из графика отпуска */
  ,nUPDATE_WORKED       in number     /* Исправлять отработанный документ */
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BASE_INSERT
  /*
  Спецификация. Добавить базовая
  */
  (
   rROW           in transinvcustspecs%rowtype
  ,nFROM_CLIENT   in number default 0
  ,nRN            out number
  );
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправить базовая
  */
  (
   rROW         in transinvcustspecs%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TICS_TICSC_INSERT
  /*
  Спецификация. Добавить калькуляцию
  */
  (
   rV_ROW         in v_transinvcustspecs%rowtype
  ,rV_FAOOP       in v_fcacoperplans%rowtype
  ,nTICSC         out number
  );
  /*#########################################################################################################*/

  procedure TICS_TICSC_BASE_INSERT  
  /*
  Спецификация. Добавить калькуляцию базовая
  */
  (
   rROW           in transinvcustspecs%rowtype
  ,rFAOOP         in fcacoperplans%rowtype
  ,nTICSC         out number
  );
  /*#########################################################################################################*/

  function TRINVCUSTCLC_GET
  /*
  Строки калькуляции. Считывание записи
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return trinvcustclc%rowtype;
  /*#########################################################################################################*/
  
  PROCEDURE TRINVCUSTCLC_GET_BY_PRM
  /*
  Строки калькуляции. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number   default 0
  ,nFLAG_OPTION       in number   default 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
  ,nTOO_MANY_ROWS     in number   default 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
  ,nPRN               in number
  ,sNUMB              in varchar2 default null
  ,nCOST_ARTICLE      in number   default null
  ,nCOST_PLACE        in number   default null
  ,nFACEACCOUNT       in number   default null
  ,nGRAPHPOINT        in number   default null
  ,nFINOPER_TYPE      in number   default null
  ,nQUANT_PLAN        in number   default null
  ,nQUANT_FACT        in number   default null
  ,nSUBDIV            in number   default null
  ,rROW               out trinvcustclc%rowtype 
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_AINSERT
  /*
  Строки калькуляции. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BUPDATE
  /*
  Строки калькуляции. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_AUPDATE
  /*
  Строки калькуляции. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BDELETE
  /*
  Строки калькуляции. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_ADELETE
  /*
  Строки калькуляции. Проверка после удаления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_CHECK_BASE
  /*
  Строки калькуляции. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_INSERT
  /*
  Строки калькуляции. Добавить
  */
  (
   rV_ROW       in v_trinvcustclc%rowtype
  ,nRN          out number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_UPDATE
  /*
  Строки калькуляции. Исправить
  */
  (
   rV_ROW           in v_trinvcustclc%rowtype
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BASE_INSERT
  /*
  Строки калькуляции. Добавить базовая
  */
  (
   rROW           in trinvcustclc%rowtype
  ,nRN            out number
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BASE_UPDATE
  /*
  Строки калькуляции. Исправить базовая
  */
  (
   rROW         in trinvcustclc%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

end USR_PKG_TRANSINVCUST;
/
create or replace package body USR_PKG_TRANSINVCUST is

  /*#########################################################################################################*/

  function TRANSINVCUST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvcust%rowtype
  is
    rRow transinvcust%rowtype;
  begin
    begin
      select * into rRow from transinvcust where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'TRANSINVCUST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVCUST'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end TRANSINVCUST_GET;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    transinvcust_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* По спецификациям */
    for c in (select * from transinvcustspecs where prn = nRN) 
    loop
      /* проверка спецификации */
      transinvcustspecs_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;

  end TRANSINVCUST_AINSERT;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BUPDATE
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
  end TRANSINVCUST_BUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    transinvcust_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end TRANSINVCUST_AUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BDELETE
  /*
  Заголовок. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;    
  end TRANSINVCUST_BDELETE;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end TRANSINVCUST_BMOVE_IN;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
  begin
    null;
  end TRANSINVCUST_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BPROCESS
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    nfl integer := 0;
  
  begin
    /*Городецкий 13-01-2025*/
    begin
      select 1
        into nfl
        from transinvcustspecs ts
       where ts.prn = nrn
         and rownum = 1;
    exception
      when no_data_found then
        nfl := 0;
    end;
    p_exception(nfl
               ,'Нельзя отрабатывать накладную, не содержащую спецификации.');
  end TRANSINVCUST_BPROCESS;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_APROCESS
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow                transinvcust%rowtype; 
    rFaceAcc            faceacc%rowtype;
    rFcAcOperPlans      fcacoperplans%rowtype;
    nTICS_SummWithNDS   pkg_std.tsumm; 

    nNumber   pkg_std.tnumber;
  begin
    /* Считывание */
    rRow      := transinvcust_get( nrn => nRN );
    rFaceAcc  := usr_pkg_faceacc.faceacc_get( nrn => rRow.faceacc );

    /* ПРОВЕРКИ */
    /* Если статья лицевого счёта: Темат. доходы_Б, Продажа товаров вСНГ, СубсидииРазработки_Б */
    if nvl( rFaceAcc.ieelement, -999 ) in ( 6172140, 6172145, 110949068) 
    and upper( nvl( usr_pkg_process.process_get, 'null') ) not in ('55555') then
      /* Если тип документа "ОтпМатНаСт" и сумма накладной с НДС не равна нулю */
      if  rRow.doctype = 52567222 
      and cmp_num( rRow.summwithnds, 0 ) != 1 then
        p_exception(0, 'Запрещено формировать документ с ненулевой суммой с типом "%s" для лицевого счёта "%s" со статьёй затрат "%s".%s'
                   ,get_doctypes_code_id( nflag_smart => 1, nrn => rRow.doctype )
                   ,rFaceAcc.numb
                   ,usr_pkg_fpdartcl.fpdartcl_get_code( nrn => rFaceAcc.ieelement, nflagsmart => 1 )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn ) ); 
      end if;
      /* Проверка лицевого счёта на превышение отгрузки */
      usr_pkg_faceacc.faceacc_check_over_ship( nflagsmart => 0
                                              ,rrow       => rFaceAcc
                                              ,ddate      => rRow.docdate
                                              ,ndiff      => nNumber );
    end if;

    /* По спецификациям */
    for c in (select * from transinvcustspecs where prn = nRN)
    loop
      /* По калькуляциям спецификации */
      for c1 in (select * from trinvcustclc where prn = c.rn)
      loop
        /* Проверка */
        trinvcustclc_check_base( nrn => c1.rn, ncompany => c1.company );

        /* Связанный график отпуска */
        usr_pkg_faceacc.fcacoperplans_get_by_params( nflagsmart     => 1
                                                    ,ntoo_many_rows => 0
                                                    ,ngraphpoint    => c1.graphpoint
                                                    ,rrow           => rFcAcOperPlans );
        /* Пересчёт графика отпуска */
        usr_pkg_faceacc.fcacoperoutplans_recalc( nrn => rFcAcOperPlans.rn );
      end loop;
    end loop;

  end TRANSINVCUST_APROCESS;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end TRANSINVCUST_BCANCEL;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow            transinvcust%rowtype; 
    rFaceAcc        faceacc%rowtype; 
    rFcAcOperPlans  fcacoperplans%rowtype;

    nNumber   pkg_std.tnumber;
  begin
    /* Считывание */
    rRow      := transinvcust_get( nrn => nRN );
    rFaceAcc  := usr_pkg_faceacc.faceacc_get( nrn => rRow.faceacc );

    /* ПРОВЕРКИ */
    /* Базовая */
    transinvcust_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Если статья лицевого счёта: Темат. доходы_Б, Продажа товаров вСНГ */
    if nvl( rFaceAcc.ieelement, -999 ) in ( 6172140, 6172145) 
    and upper( nvl( usr_pkg_process.process_get, 'null') ) not in ('55555') then
      /* Проверка лицевого счёта на превышение отгрузки */
      usr_pkg_faceacc.faceacc_check_over_ship( nflagsmart => 0
                                              ,rrow       => rFaceAcc
                                              ,ddate      => rRow.docdate
                                              ,ndiff      => nNumber );
    end if;

    /* По спецификациям */
    for c in (select * from transinvcustspecs where prn = nRN)
    loop
      /* Проверка после базовая */
      transinvcustspecs_check_base(nrn => c.rn, ncompany => c.company);

      /* По калькуляциям спецификации */
      for c1 in (select * from trinvcustclc where prn = c.rn)
      loop
        /* Связанный график отпуска */
        usr_pkg_faceacc.fcacoperplans_get_by_params( nflagsmart     => 1
                                                    ,ntoo_many_rows => 0
                                                    ,ngraphpoint    => c1.graphpoint
                                                    ,rrow           => rFcAcOperPlans );
        /* Пересчёт графика отпуска */
        usr_pkg_faceacc.fcacoperoutplans_recalc( nrn => rFcAcOperPlans.rn );

      end loop;
    end loop;

  end TRANSINVCUST_ACANCEL;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMAKEINV
  /*
  Заголовок. Формирование возвратных расходных накладных. До
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;

  end TRANSINVCUST_BMAKEINV;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AMAKEINV
  /*
  Заголовок. Формирование возвратных расходных накладных. После
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* Копирование буфера документов во временную таблицу */
    delete from usr_t_inhierbuff_common;
    insert into usr_t_inhierbuff_common ( select * from inhierbuff_common );

    /* По заголовкам сформированных документов */
    for c in (select distinct out_document0 from usr_t_inhierbuff_common ) 
    loop
      /* проверка выходного документа */
      transinvcust_ainsert( nrn => c.out_document0, ncompany => nCOMPANY );
    end loop;

  end TRANSINVCUST_AMAKEINV;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMAKEININV
  /*
  Заголовок. Формирование приходных накладных. До
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;

  end TRANSINVCUST_BMAKEININV;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AMAKEININV
  /*
  Заголовок. Формирование приходных накладных. После
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* Копирование буфера документов во временную таблицу */
    delete from usr_t_inhierbuff_common;
    insert into usr_t_inhierbuff_common ( select * from inhierbuff_common );

    /* По заголовкам сформированных документов */
    for c in (select distinct out_document0 from usr_t_inhierbuff_common ) 
    loop
      /* проверка выходного документа */
      usr_pkg_ininvoices.ininvoices_ainsert( nrn => c.out_document0, ncompany => nCOMPANY );
    end loop;
    
  end TRANSINVCUST_AMAKEININV;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BMAKEACCFI
  /*
  Заголовок. Формирование входящего счета-фактуры. До
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;

  end TRANSINVCUST_BMAKEACCFI;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_AMAKEACCFI
  /*
  Заголовок. Формирование входящего счета-фактуры. После
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* Копирование буфера документов во временную таблицу */
    delete from usr_t_inhierbuff_common;
    insert into usr_t_inhierbuff_common ( select * from inhierbuff_common );

    /* По заголовкам сформированных документов */
    for c in (select distinct out_document0 from usr_t_inhierbuff_common ) 
    loop
      /* проверка выходного документа */
      usr_pkg_dicaccfi.dicaccfi_ainsert( nrn => c.out_document0, ncompany => nCOMPANY );
    end loop;

  end TRANSINVCUST_AMAKEACCFI;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow                transinvcust%rowtype; 
    nSheepDirsCust      pkg_std.tref; 
    rSheepDirsCust      sheepdirscust%rowtype; 
    rStOper             AZSGSMWAYSTYPES%rowtype; 

    nNumber             pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := transinvcust_get(nrn => nRN);
    rStOper := udo_pkg_get.row_stoper(nrn => rRow.stoper);
    
     /* Проверка свойства "Направления" калькуляции статьи затрат заданной в лицевом счете. Должна быть "Приход" 
     Городецкий 09-04-2026 По заявке Быкова Ксения 80426/24305
     */
    usr_p_tid_faceacc_cntrl(nrn => rRow.Faceacc);

    /* Связанный входной документ */
    nSheepDirsCust := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                           ,sout_unitcode  => 'GoodsTransInvoicesToConsumers'
                                                           ,nout_document  => rRow.rn
                                                           ,sin_unitcode   => 'SheepDirectToConsumers');
    /* ПРОВЕРКИ */
    /* Заполнен параметр "Акт передачи работ (услуг)" */
    if rRow.servact_sign = 1 then
      /* Тип документа НЕ "АктВыпРаб" */
      if rRow.doctype != 503094 then
        p_exception(0, 'В документе заполнен параметр "Акт передачи работ (услуг). Выберите тип документа "АктВыпРаб".%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn) ); 
      end if;
      /* Складская операция НЕ "РасходВнеш" */
      if rRow.stoper != 12078560 then
        p_exception(0, 'В документе заполнен параметр "Акт передачи работ (услуг). Выберите складскую операцию "РасходВнеш".%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn) ); 
      end if;
      /* Вид отгрузки НЕ "ВыпРабИсп" */
      if rRow.sheepview != 503003 then
        p_exception(0, 'В документе заполнен параметр "Акт передачи работ (услуг). Выберите вид отгрузки "ВыпРабИсп".%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn) ); 
      end if;
    /* НЕ заполнен параметр "Акт передачи работ (услуг)" */
    /*else
      \* Тип документа ОтпМатНаСт Складская операция "ОтгрПродукции"*\
      if not (rRow.doctype = 52567222 and rRow.stoper != 6169967 
      \* Тип документа ТН Складская операция "ОтгрПродукции"*\
      or not (rRow.doctype = 1074554 and rRow.stoper != 6169967 
      then
          p_exception(0, 'В документе заполнен параметр "Акт передачи работ (услуг). @ОтгрПродукции#
          Выберите тип документа "ОтпМатНаСт".%s'
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn) ); 
      end if;
      \* Складская операция  *\
      if rRow.stoper != 12078560 then
        p_exception(0, 'В документе заполнен параметр "Акт передачи работ (услуг). Выберите складскую операцию "РасходВнеш".%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn) ); 
      end if;
      \* Вид отгрузки *\
      if rRow.stoper != 503003 then
        p_exception(0, 'В документе заполнен параметр "Акт передачи работ (услуг). Выберите вид отгрузки "ВыпРабИсп".%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn) ); 
      end if;
    */
    end if;

    /* Если входной документ найден */
    if nSheepDirsCust is not null then
      /* Считывание заголовка */
      rSheepDirsCust := usr_pkg_sheepdirscust.sheepdirscust_get(nrn => nSheepDirsCust); 

      /* Ответственный */
      if cmp_num(rRow.acc_agent, rSheepDirsCust.acc_agent) != 1 then
        p_exception(0, 'Разные Ответственые в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.acc_agent)
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rSheepDirsCust.acc_agent)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Подразделение */
      if cmp_num(rRow.subdiv, rSheepDirsCust.subdiv) != 1 then
        p_exception(0, 'Разные Подразделения в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.subdiv)
                   ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rSheepDirsCust.subdiv)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Контрагент */
      if cmp_num(rRow.agent, rSheepDirsCust.agent) != 1 then
        p_exception(0, 'Разные Контрагенты в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.agent)
                   ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rSheepDirsCust.agent)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Лицевой счёт */
      if cmp_num(rRow.faceacc, rSheepDirsCust.faceacc) != 1 then
        p_exception(0, 'Разные Лицевые счета в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => rSheepDirsCust.faceacc)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Склад */
      if cmp_num(rRow.store, rSheepDirsCust.store) != 1 then
        p_exception(0, 'Разные Склады в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,f_dicstore_get_numb(nstore => rRow.store)
                   ,f_dicstore_get_numb(nstore => rSheepDirsCust.store)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Валюта */
      if cmp_num(rRow.currency, rSheepDirsCust.currency) != 1 then
        p_exception(0, 'Разные Валюты в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,f_dicstore_get_numb(nstore => rRow.store)
                   ,f_dicstore_get_numb(nstore => rSheepDirsCust.store)
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Складская операция */
      if cmp_num(rRow.stoper, rSheepDirsCust.stoper) != 1 then
        p_exception(0, 'Разные Складские операции в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,rRow.stoper
                   ,rSheepDirsCust.stoper
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Сумма с налогами */
      if cmp_num(rRow.summwithnds, rSheepDirsCust.summwithnds) != 1 then
        p_exception(0, 'Разные Суммы с налогами в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,rRow.summwithnds
                   ,rSheepDirsCust.summwithnds
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
      /* Сумма без налогов */
      if cmp_num(rRow.summ, rSheepDirsCust.summ) != 1 then
        p_exception(0, 'Разные Суммы без налогов в Расходной накладной потребителям <%s> и Распоряжении на отгрузку <%s>. %s.'
                   ,rRow.summ
                   ,rSheepDirsCust.summ
                   ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
      end if;
    end if;

  end TRANSINVCUST_CHECK_BASE;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_INSERT
  /*
  Заголовок. Добавить
  */
  (
   rV_ROW       in out v_transinvcust%rowtype
  ,nDUP_RN      in number
  ,sMSG         out varchar2
  ) 
  is
  begin
    p_transinvcust_insert(ncompany       => rV_ROW.NCOMPANY
                         ,ncrn           => rV_ROW.NCRN
                         ,sjur_pers      => rV_ROW.SJUR_PERS
                         ,sdoctype       => rV_ROW.SDOCTYPE
                         ,spref          => rV_ROW.SPREF
                         ,snumb          => rV_ROW.SNUMB
                         ,ddocdate       => rV_ROW.DDOCDATE
                         ,nauto_curcours => rV_ROW.NAUTO_CURCOURS
                         ,dsaledate      => rV_ROW.DSALEDATE
                         ,saccdoc        => rV_ROW.SACCDOC
                         ,saccnumb       => rV_ROW.SACCNUMB
                         ,daccdate       => rV_ROW.DACCDATE
                         ,sdirdoc        => rV_ROW.SDIRDOC
                         ,sdirnumb       => rV_ROW.SDIRNUMB
                         ,ddirdate       => rV_ROW.DDIRDATE
                         ,sstoper        => rV_ROW.SSTOPER
                         ,sfaceacc       => rV_ROW.SFACEACC
                         ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                         ,sagent         => rV_ROW.SAGENT
                         ,starif         => rV_ROW.STARIF
                         ,nservact_sign  => rV_ROW.NSERVACT_SIGN
                         ,sstore         => rV_ROW.SSTORE
                         ,smol           => rV_ROW.SMOL
                         ,ssheepview     => rV_ROW.SSHEEPVIEW
                         ,spaytype       => rV_ROW.SPAYTYPE
                         ,ndiscount      => rV_ROW.NDISCOUNT
                         ,scurrency      => rV_ROW.SCURRENCY
                         ,ncurcours      => rV_ROW.NCURCOURS
                         ,ncurbase       => rV_ROW.NCURBASE
                         ,nfa_cours      => rV_ROW.NFA_COURS
                         ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                         ,nsumm          => rV_ROW.NSUMM
                         ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                         ,srecipdoc      => rV_ROW.SRECIPDOC
                         ,srecipnumb     => rV_ROW.SRECIPNUMB
                         ,drecipdate     => rV_ROW.DRECIPDATE
                         ,sferryman      => rV_ROW.SFERRYMAN
                         ,sshipper       => rV_ROW.SSHIPPER
                         ,sagnfifo       => rV_ROW.SAGNFIFO
                         ,sforwarder     => rV_ROW.SFORWARDER
                         ,swaybladenumb  => rV_ROW.SWAYBLADENUMB
                         ,sdriver        => rV_ROW.SDRIVER
                         ,scar           => rV_ROW.SCAR
                         ,sroute         => rV_ROW.SROUTE
                         ,strailer1      => rV_ROW.STRAILER1
                         ,strailer2      => rV_ROW.STRAILER2
                         ,scomments      => rV_ROW.SCOMMENTS
                         ,sacc_agent     => rV_ROW.SACC_AGENT
                         ,ssubdiv        => rV_ROW.SSUBDIV
                         ,sbarcode       => rV_ROW.SBARCODE
                         ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                         ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                         ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                         ,sreg_agent     => rV_ROW.SREG_AGENT
                         ,ndup_rn        => nDUP_RN
                         ,nrn            => rV_ROW.nRN
                         ,smsg           => sMSG);
  end TRANSINVCUST_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_UPDATE
  /*
  Заголовок. Исправить
  */
  (
   rV_ROW       in v_transinvcust%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_Row2     v_transinvcust%rowtype := rV_ROW;
    aRN_List    udo_tp_numtable := udo_tp_numtable();
    
    nNumber     pkg_std.tnumber; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_transinvcust_update(nrn            => rV_ROW.NRN
                           ,ncompany       => rV_ROW.NCOMPANY
                           ,sjur_pers      => rV_ROW.SJUR_PERS
                           ,sdoctype       => rV_ROW.SDOCTYPE
                           ,spref          => rV_ROW.SPREF
                           ,snumb          => rV_ROW.SNUMB
                           ,ddocdate       => rV_ROW.DDOCDATE
                           ,nauto_curcours => rV_ROW.NAUTO_CURCOURS
                           ,nstatus        => rV_ROW.NSTATUS
                           ,dsaledate      => rV_ROW.DSALEDATE
                           ,saccdoc        => rV_ROW.SACCDOC
                           ,saccnumb       => rV_ROW.SACCNUMB
                           ,daccdate       => rV_ROW.DACCDATE
                           ,sdirdoc        => rV_ROW.SDIRDOC
                           ,sdirnumb       => rV_ROW.SDIRNUMB
                           ,ddirdate       => rV_ROW.DDIRDATE
                           ,sstoper        => rV_ROW.SSTOPER
                           ,sfaceacc       => rV_ROW.SFACEACC
                           ,sgraphpoint    => rV_ROW.SGRAPHPOINT
                           ,sagent         => rV_ROW.SAGENT
                           ,starif         => rV_ROW.STARIF
                           ,nservact_sign  => rV_ROW.NSERVACT_SIGN
                           ,sstore         => rV_ROW.SSTORE
                           ,smol           => rV_ROW.SMOL
                           ,ssheepview     => rV_ROW.SSHEEPVIEW
                           ,spaytype       => rV_ROW.SPAYTYPE
                           ,ndiscount      => rV_ROW.NDISCOUNT
                           ,scurrency      => rV_ROW.SCURRENCY
                           ,ncurcours      => rV_ROW.NCURCOURS
                           ,ncurbase       => rV_ROW.NCURBASE
                           ,nfa_cours      => rV_ROW.NFA_COURS
                           ,nfa_basecours  => rV_ROW.NFA_BASECOURS
                           ,nsumm          => rV_ROW.NSUMM
                           ,nsummwithnds   => rV_ROW.NSUMMWITHNDS
                           ,srecipdoc      => rV_ROW.SRECIPDOC
                           ,srecipnumb     => rV_ROW.SRECIPNUMB
                           ,drecipdate     => rV_ROW.DRECIPDATE
                           ,sferryman      => rV_ROW.SFERRYMAN
                           ,sshipper       => rV_ROW.SSHIPPER
                           ,sagnfifo       => rV_ROW.SAGNFIFO
                           ,sforwarder     => rV_ROW.SFORWARDER
                           ,swaybladenumb  => rV_ROW.SWAYBLADENUMB
                           ,sdriver        => rV_ROW.SDRIVER
                           ,scar           => rV_ROW.SCAR
                           ,sroute         => rV_ROW.SROUTE
                           ,strailer1      => rV_ROW.STRAILER1
                           ,strailer2      => rV_ROW.STRAILER2
                           ,scomments      => rV_ROW.SCOMMENTS
                           ,sacc_agent     => rV_ROW.SACC_AGENT
                           ,ssubdiv        => rV_ROW.SSUBDIV
                           ,sbarcode       => rV_ROW.SBARCODE
                           ,spayconf_type  => rV_ROW.SPAYCONF_TYPE
                           ,spayconf_numb  => rV_ROW.SPAYCONF_NUMB
                           ,dpayconf_date  => rV_ROW.DPAYCONF_DATE
                           ,sreg_agent     => rV_ROW.SREG_AGENT);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Если статус документа НЕ "Не отработан" */
      if rV_Row2.nstatus != 0 then

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Добавление дубликатов */
        transinvcust_create_copy( nrn => rV_Row2.nrn, arn_list => aRN_List );

        /* Обнуление даты формирования товарного отчёта */
        update transinvcust
           set salesreportdate = null
         where rn = rV_Row2.nrn;

        /* Снятие отработки с оригинала */
        p_transinvcust_bset_status( ncompany   => rV_Row2.ncompany
                                   ,nrn        => rV_Row2.nrn
                                   ,nstatus    => 0
                                   ,dwork_date => /*rV_Row2.dwork_date*/sysdate
                                   ,nident     => nNumber );
        rV_Row2.nstatus := 0;

        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

        /* Исправление оригинала штатное */
        transinvcust_update( rv_row => rV_Row2, nmode => 0);

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Отработка оригинала */
        p_transinvcust_bset_status( ncompany   => rV_Row2.ncompany
                                   ,nrn        => rV_Row2.nrn
                                   ,nstatus    => 2
                                   ,dwork_date => rV_Row2.dwork_date
                                   ,nident     => nNumber );
        /* Удаление дубликата */
        transinvcust_delete_copy( ncompany => rV_Row2.ncompany, arn_list => aRN_List );

        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Если статус документа "Не отработан" */
      else
         /* Исправление */
        transinvcust_update( rv_row => rV_Row2, nmode => 0 );
      end if;    

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end TRANSINVCUST_UPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BASE_INSERT
  /*
  Заголовок. Добавить базовая
  */
  (
   rROW           in transinvcust%rowtype
  ,nRESERV_SIGN   in number 
  ,nRN            out number
  ) 
  is
  begin
    p_transinvcust_base_insert(ncompany       => rROW.COMPANY
                              ,ncrn           => rROW.CRN
                              ,njur_pers      => rROW.JUR_PERS
                              ,ndoctype       => rROW.DOCTYPE
                              ,spref          => rROW.PREF
                              ,snumb          => rROW.NUMB
                              ,ddocdate       => rROW.DOCDATE
                              ,nauto_curcours => rROW.AUTO_CURCOURs
                              ,dsaledate      => rROW.SALEDATE
                              ,naccdoc        => rROW.ACCDOC
                              ,saccnumb       => rROW.ACCNUMB
                              ,daccdate       => rROW.ACCDATE
                              ,ndirdoc        => rROW.DIRDOC
                              ,sdirnumb       => rROW.DIRNUMB
                              ,ddirdate       => rROW.DIRDATE
                              ,nstoper        => rROW.STOPER
                              ,nfaceacc       => rROW.FACEACC
                              ,ngraphpoint    => rROW.GRAPHPOINT
                              ,nagent         => rROW.AGENT
                              ,ntarif         => rROW.TARIF
                              ,nservact_sign  => rROW.SERVACT_SIGN
                              ,nstore         => rROW.STORE
                              ,nmol           => rROW.MOL
                              ,nsheepview     => rROW.SHEEPVIEW
                              ,npaytype       => rROW.PAYTYPE
                              ,ndiscount      => rROW.DISCOUNT
                              ,ncurrency      => rROW.CURRENCY
                              ,ncurcours      => rROW.CURCOURS
                              ,ncurbase       => rROW.CURBASE
                              ,nfa_cours      => rROW.FA_COURS
                              ,nfa_basecours  => rROW.FA_BASECOURS
                              ,nsumm          => rROW.SUMM
                              ,nsummwithnds   => rROW.SUMMWITHNDS
                              ,nrecipdoc      => rROW.RECIPDOC
                              ,srecipnumb     => rROW.RECIPNUMB
                              ,drecipdate     => rROW.RECIPDATE
                              ,nferryman      => rROW.FERRYMAN
                              ,nshipper       => rROW.SHIPPER
                              ,nagnfifo       => rROW.AGNFIFO
                              ,nforwarder     => rROW.FORWARDER
                              ,swaybladenumb  => rROW.WAYBLADENUMB
                              ,ndriver        => rROW.DRIVER
                              ,ncar           => rROW.CAR
                              ,nroute         => rROW.ROUTE
                              ,ntrailer1      => rROW.TRAILER1
                              ,ntrailer2      => rROW.TRAILER2
                              ,scomments      => rROW.COMMENTS
                              ,nreserv_sign   => nRESERV_SIGN
                              ,nacc_agent     => rROW.ACC_AGENT
                              ,nsubdiv        => rROW.SUBDIV
                              ,sbarcode       => rROW.BARCODE
                              ,npayconf_type  => rROW.PAYCONF_TYPE
                              ,spayconf_numb  => rROW.PAYCONF_NUMB
                              ,dpayconf_date  => rROW.PAYCONF_DATE
                              ,nreg_agent     => rROW.REG_AGENT
                              ,nrn            => nRN);
  end TRANSINVCUST_BASE_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_BASE_UPDATE
  /*
  Заголовок. Исправить базовая
  */
  (
   rROW         in transinvcust%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_transinvcust_base_update(nrn            => rROW.RN
                                ,ncompany       => rROW.COMPANY
                                ,njur_pers      => rROW.JUR_PERS
                                ,ndoctype       => rROW.DOCTYPE
                                ,spref          => rROW.PREF
                                ,snumb          => rROW.NUMB
                                ,ddocdate       => rROW.DOCDATE
                                ,nauto_curcours => rROW.AUTO_CURCOURS
                                ,dsaledate      => rROW.SALEDATE
                                ,naccdoc        => rROW.ACCDOC
                                ,saccnumb       => rROW.ACCNUMB
                                ,daccdate       => rROW.ACCDATE
                                ,ndirdoc        => rROW.DIRDOC
                                ,sdirnumb       => rROW.DIRNUMB
                                ,ddirdate       => rROW.DIRDATE
                                ,nstoper        => rROW.STOPER
                                ,nfaceacc       => rROW.FACEACC
                                ,ngraphpoint    => rROW.GRAPHPOINT
                                ,nagent         => rROW.AGENT
                                ,ntarif         => rROW.TARIF
                                ,nservact_sign  => rROW.SERVACT_SIGN
                                ,nstore         => rROW.STORE
                                ,nmol           => rROW.MOL
                                ,nsheepview     => rROW.SHEEPVIEW
                                ,npaytype       => rROW.PAYTYPE
                                ,ndiscount      => rROW.DISCOUNT
                                ,ncurrency      => rROW.CURRENCY
                                ,ncurcours      => rROW.CURCOURS
                                ,ncurbase       => rROW.CURBASE
                                ,nfa_cours      => rROW.FA_COURS
                                ,nfa_basecours  => rROW.FA_BASECOURS
                                ,nsumm          => rROW.SUMM
                                ,nsummwithnds   => rROW.SUMMWITHNDS
                                ,nrecipdoc      => rROW.RECIPDOC
                                ,srecipnumb     => rROW.RECIPNUMB
                                ,drecipdate     => rROW.RECIPDATE
                                ,nferryman      => rROW.FERRYMAN
                                ,nshipper       => rROW.SHIPPER
                                ,nagnfifo       => rROW.AGNFIFO
                                ,nforwarder     => rROW.FORWARDER
                                ,swaybladenumb  => rROW.WAYBLADENUMB
                                ,ndriver        => rROW.DRIVER
                                ,ncar           => rROW.CAR
                                ,nroute         => rROW.ROUTE
                                ,ntrailer1      => rROW.TRAILER1
                                ,ntrailer2      => rROW.TRAILER2
                                ,scomments      => rROW.COMMENTS
                                ,nacc_agent     => rROW.ACC_AGENT
                                ,nsubdiv        => rROW.SUBDIV
                                ,sbarcode       => rROW.BARCODE
                                ,npayconf_type  => rROW.PAYCONF_TYPE
                                ,spayconf_numb  => rROW.PAYCONF_NUMB
                                ,dpayconf_date  => rROW.PAYCONF_DATE
                                ,nreg_agent     => rROW.REG_AGENT);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then */

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end TRANSINVCUST_BASE_UPDATE;
  /*#########################################################################################################*/

  /* процедура пересчета исполнения у родительских документов 
  по мотивам P_TRANSINVCUST_BSET_STATUS */
  procedure TRANSINVCUST_RECALC_PERF
  (
   nCOMPANY        in number            /* организация */
  ,nRN             in number            /* RN накладной на отпуск потребителям */
  ,nSTATUS         in number            /* состояние (0 - снять отработку, 1 - отработать как план, 2 - отработать как Факт) */
  ,dWORK_DATE      in date              /* дата смены состояния */
  )
  as
    nCRN                  PKG_STD.tREF;
    nOLD_STATUS           PKG_STD.tNUMBER;      -- старое состояние (0 - не отработан; 1 - отработан как план; 2 - отработан как факт)
    nDOCTYPE              PKG_STD.tREF;
    sPREF                 TRANSINVCUST.PREF%TYPE;
    sNUMB                 TRANSINVCUST.NUMB%TYPE;
    dDOCDATE              PKG_STD.tLDATE;
    nFACEACC              PKG_STD.tREF;
    sFACEACC              FACEACC.NUMB%TYPE;
    nFA_CURRENCY          PKG_STD.tREF;
    nGRAPHPOINT           PKG_STD.tREF;
    nAGENT                PKG_STD.tREF;
    nPAYTYPE              PKG_STD.tREF;
    nCURRENCY             PKG_STD.tREF;
    nSUMM                 TRANSINVCUST.SUMM%TYPE;
    nSUMMWITHNDS          TRANSINVCUST.SUMMWITHNDS%TYPE;
    nSERV_SUM             TRANSINVCUST.SERV_SUMM%TYPE;
    nSERV_SUM_NDS         TRANSINVCUST.SERV_SUMM_NDS%TYPE;
    nSUMM_BASE            PKG_STD.tSUMM := 0;
    nSUMMWITHNDS_BASE     PKG_STD.tSUMM := 0;
    nSERV_SUM_BASE        PKG_STD.tSUMM := 0;
    nSERV_SUM_NDS_BASE    PKG_STD.tSUMM := 0;
    nSUMMWITHNDS_ACC      PKG_STD.tSUMM := 0;
    nSERV_SUM_ACC         PKG_STD.tSUMM := 0;
    nSTOPER               PKG_STD.tREF;
    nACCDOC               PKG_STD.tREF;
    sACCNUMB              TRANSINVCUST.ACCNUMB%TYPE;
    dACCDATE              PKG_STD.tLDATE;
    nSHEEP_RN             PKG_STD.tREF;

    nGSMWAYS_TYPE         PKG_STD.tNUMBER;                   -- тип складской операции (0 - расход, 1 - приход)
    nKEEP_SIGN            PKG_STD.tNUMBER;                   -- признак ответственного хранения (0 - нет, 1 - да)
    nFACTRET_SIGN         PKG_STD.tNUMBER;                   -- признак возврата (0 - прямая (операция, факт), 1 - возврат)
    nINEXP_SIGN           PKG_STD.tNUMBER;                   -- тип складской операции (1 - Расход, 3 - Приход)
    nFACT_SIGN            PKG_STD.tNUMBER;
    nPLAN_SIGN            PKG_STD.tNUMBER;
    nROLLBACK             PKG_STD.tNUMBER;

    nPLAN_QUANT           PKG_STD.tQUANT;
    nPLAN_QUANT_ALT       PKG_STD.tQUANT;
    nFACT_QUANT           PKG_STD.tQUANT;
    nFACT_QUANT_ALT       PKG_STD.tQUANT;
    nPLAN_SUM             PKG_STD.tSUMM;
    nFACT_SUM             PKG_STD.tSUMM;
    nCURBASE              PKG_STD.tLNUMBER;
    nCURCOURS             PKG_STD.tLNUMBER;
    nFA_COURS             PKG_STD.tLNUMBER;
    nFA_BASECOURS         PKG_STD.tLNUMBER;
    nSTORE                PKG_STD.tREF;
    nSTORE_TYPE           PKG_STD.tNUMBER;
    nSTORE_CURR           PKG_STD.tREF;
    nPAYTPE               PKG_STD.tREF;
    nMOL                  PKG_STD.tREF;
    nSUBDIV               PKG_STD.tREF;
    /* параметры для пересчета количества в ДЕИ при считывании коэф. из ТЗ */
    nTARIF                PKG_STD.tREF;
    nINCNDS               PKG_STD.tNUMBER;

    nRESTFACT             GOODSSUPPLYHIST.RESTFACT%type;
    nRESTPLAN             GOODSSUPPLYHIST.RESTPLAN%type;
    nRESERV               GOODSSUPPLYHIST.RESERV%type;
    nMIN_RESTFACT         GOODSSUPPLYHIST.MIN_RESTFACT%type;
    nMIN_RESTPLAN         GOODSSUPPLYHIST.MIN_RESTPLAN%type;
  -- переменные для обработки возврата на другой склад
    nUSE_STORE_KOEFF      PKG_STD.tNUMBER;
    nPROCESS_SIGN         PKG_STD.tNUMBER;
    nDISTRIBUTION_SIGN    PKG_STD.tNUMBER;

    nJUR_PERS             PKG_STD.tREF;
    dOLD_WORK_DATE        PKG_STD.tLDATE;
    nBASE_CURRENCY        PKG_STD.tREF;
  -- переменные для снятия резервирования и отражения исполнения.
    nPACC_RN              PKG_STD.tREF;     -- RN родительского счета на оплату
    nCO_RN                PKG_STD.tREF;     -- RN родительского заказа потребителей
    nCOP_RN               PKG_STD.tREF;     -- RN родительского периода исполнения заказа потребителей
    nLINK_WAY             PKG_STD.tNUMBER;  -- связь через  (0-первый родитель распоряжение, 1-первый родитель не распоряжение)
  -- временные переменные
    cCURSOR               PKG_CURSORS.CurType;
    vREMNS                PKG_FACEACCTRADE.TFACEACC_REMNS;
    nRES                  PKG_STD.tLNUMBER;
    nTMP                  PKG_STD.tNUMBER;

    /* процедура поиска родительских документов и снятия резервирования с них */
    procedure FIND_PARENT_REMOVE_RES is
    begin
      /* начальная инициализация зависимых переменных */
      nLINK_WAY := 1;
      /* ищем связь со счетом на оплату */
      /* цепочка GoodsTransInvoicesToConsumers<GoodsTransInvoicesToConsumers<PaymentAccounts НЕ рассматривается! */
      nPACC_RN := F_DOCLINKS_LINK_IN_RECURS_DOC( 1/*FLAG_MODE*/, 'GoodsTransInvoicesToConsumers', nRN, 'PaymentAccounts',
                                                 ';GoodsTransInvoicesToConsumers<PaymentAccounts;' );
      /* если связь не найдена, ищем связь со счетом по цепочкам где первый родитель - распоряжение */
      if nPACC_RN is null then
        nPACC_RN := F_DOCLINKS_LINK_IN_RECURS_DOC( 1/*FLAG_MODE*/, 'GoodsTransInvoicesToConsumers', nRN, 'PaymentAccounts',
                                                   ';GoodsTransInvoicesToConsumers<SheepDirectToConsumers<PaymentAccounts;' );
        if nPACC_RN is not null then nLINK_WAY := 0; end if;
      end if;
      /* ищем связь с заказом потребителей по цепочкам где распоряжение не является первым родителем */
      nCOP_RN := F_DOCLINKS_LINK_IN_RECURS_DOC( 1/*FLAG_MODE*/, 'GoodsTransInvoicesToConsumers', nRN, 'ConsumersOrdersPerform',
                                                ';GoodsTransInvoicesToConsumers<ConsumersOrdersPerform;'||
                                                'GoodsTransInvoicesToConsumers<PaymentAccounts<ConsumersOrdersPerform;'||
                                                'GoodsTransInvoicesToConsumers<GoodsTransInvoicesToConsumers<ConsumersOrdersPerform;'||
                                                'GoodsTransInvoicesToConsumers<GoodsTransInvoicesToConsumers<PaymentAccounts<ConsumersOrdersPerform;'||
                                                'GoodsTransInvoicesToConsumers<GoodsTransInvoicesToConsumers<SheepDirectToConsumers<ConsumersOrdersPerform;'||
                                                'GoodsTransInvoicesToConsumers<GoodsTransInvoicesToConsumers<SheepDirectToConsumers<PaymentAccounts<ConsumersOrdersPerform;' );
      /* если связь не найдена, ищем связь с заказом потребителей по цепочкам где первый родитель - распоряжение */
      if nCOP_RN is null then
        nLINK_WAY := 0;
        nCOP_RN := F_DOCLINKS_LINK_IN_RECURS_DOC( 1/*FLAG_MODE*/, 'GoodsTransInvoicesToConsumers', nRN, 'ConsumersOrdersPerform',
                                                  ';GoodsTransInvoicesToConsumers<SheepDirectToConsumers<ConsumersOrdersPerform;'||
                                                  'GoodsTransInvoicesToConsumers<SheepDirectToConsumers<PaymentAccounts<ConsumersOrdersPerform;' );
      end if;
    end FIND_PARENT_REMOVE_RES;

    /* процедура пересчета исполнения у родительских документов */
    procedure RECALC_PERFORMANCE
    is
      nIDENT      PKG_STD.tNUMBER;  -- идентификатор процесса отражения.
      nSO_SIGN    PKG_STD.tNUMBER;  -- знак зависит от складской операции (1-расход, -1-приход)
      nPLAN_SIGN  PKG_STD.tNUMBER;  -- знак суммирования плана (-1,0,1)
      nFACT_SIGN  PKG_STD.tNUMBER;  -- знак суммирования факта (-1,0,1)
    begin
      /* если нет ни одного родительского документа - выходим */
      if nCOP_RN is null then
        return;
      end if;
      /* инициализация пакета расчета исполнения товарных позиций */
      PKG_GOODSDOCS_PERF_CRM.INIT( nCOMPANY, nIDENT );
      /* установка родительского заказа потребителей (поиск заказа идет в FIND_PARENT_REMOVE_RES) */
      nCOP_RN := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nIDENT, 'GoodsTransInvoicesToConsumers', nRN, 'ConsumersOrdersPerform', nCOP_RN );

      /* определим складскую операцию документа */
      if nGSMWAYS_TYPE = 0 then
        nSO_SIGN := 1; -- расход
      else
        nSO_SIGN := -1; -- приход
      end if;
      /* выставим знаки суммирования плана и факта */
      if (nOLD_STATUS = 0) and (nSTATUS in (1,2)) then -- был не отработан
        nPLAN_SIGN := nSO_SIGN * nLINK_WAY;
        nFACT_SIGN := nSO_SIGN;   -- если накладная сделана напрямую через распоряжение, отражаем только на факте
      elsif (nOLD_STATUS in (1,2)) and (nSTATUS = 0) then -- был отработан
        nPLAN_SIGN := - nSO_SIGN * nLINK_WAY;
        nFACT_SIGN := - nSO_SIGN; -- если накладная сделана напрямую через распоряжение, отражаем только на факте
      else return; -- на всякий случай
      end if;

      /* суммирование исполнения по спецификациям расходной накладной на отпуск потребителям */
      for Rec in (
        select T.CURRENCY, T.CURCOURS, T.CURBASE,
               F.CURRENCY FA_CURRENCY, T.FA_BASECOURS, T.FA_COURS,
               M.PRN NOMEN, S.NOMMODIF, S.NOMNMODIFPACK, S.ARTICLE,
               T.STORE, S.GOODSPARTY,
               S.QUANT, S.QUANTALT, S.SUMMWITHNDS
          from TRANSINVCUST      T,
               TRANSINVCUSTSPECS S,
               NOMMODIF          M,
               FACEACC           F
         where T.RN       = nRN
           and S.PRN      = T.RN
           and S.NOMMODIF = M.RN
           and T.FACEACC  = F.RN )
      loop
        /* суммирование исполнения */
        PKG_GOODSDOCS_PERF_CRM.SET_PERF( nIDENT, 1/*SIGN_PACK*/, null/*NOMENCLS*/, null/*UMEAS_MAIN*/,
          Rec.NOMEN, null/*NOMNPACK*/, Rec.NOMMODIF, Rec.NOMNMODIFPACK, Rec.ARTICLE,
          Rec.STORE, Rec.GOODSPARTY, null/*SERNUMB*/, null/*COUNTRY*/, null/*GTD*/,
          Rec.QUANT, Rec.QUANTALT, Rec.QUANT, Rec.QUANTALT,
          0/*nRTN_PLANM_QUANT*/, 0/*nRTN_PLANA_QUANT*/,
          0/*nRTN_FACTM_QUANT*/, 0/*nRTN_FACTA_QUANT*/,
          Rec.SUMMWITHNDS, Rec.SUMMWITHNDS,
          nPLAN_SIGN, nFACT_SIGN, 0/*nRTN_PLAN_SIGN*/, 0/*nRTN_FACT_SIGN*/,
          Rec.CURRENCY, Rec.CURCOURS, Rec.CURBASE,
          Rec.FA_CURRENCY, Rec.FA_BASECOURS, Rec.FA_COURS, dWORK_DATE );
      end loop;
      /* сохранение рассчитаного исполнения в родительских документах */
      PKG_GOODSDOCS_PERF_CRM.SAVE_PARENT( nIDENT );
    end RECALC_PERFORMANCE;

  /* тело основной процедуры */
  begin
    /* считывание текущих параметров записи */
    begin
      select /*+ ORDERED */ T.CRN, decode(T.STATUS,0,0,1,2,2,1), T.DOCTYPE, T.PREF, T.NUMB, T.DOCDATE, T.FACEACC, T.GRAPHPOINT,
             T.AGENT, T.PAYTYPE, T.CURRENCY, T.CURBASE, T.CURCOURS, T.FA_COURS, T.FA_BASECOURS,
             T.SUMM, T.SUMMWITHNDS, T.SERV_SUMM, T.SERV_SUMM_NDS, T.STOPER, T.ACCDOC, T.ACCNUMB, T.ACCDATE, T.STORE,
             SO.GSMWAYS_TYPE, SO.KEEP_SIGN, decode(SO.GSMWAYS_TYPE, 0, 1, 1, 3), SO.FACTRET_SIGN,
             nvl(S.STORE_TYPE,0), S.CURRENCY, S.CALC_TYPE, S.PROCESS_SIGN, S.DISTRIBUTION_SIGN,
             T.JUR_PERS, T.WORK_DATE, T.TARIF, T.MOL, T.SUBDIV, F.NUMB, F.CURRENCY, DT.INCNDS
        into nCRN, nOLD_STATUS, nDOCTYPE, sPREF, sNUMB, dDOCDATE, nFACEACC, nGRAPHPOINT,
             nAGENT, nPAYTYPE, nCURRENCY, nCURBASE, nCURCOURS, nFA_COURS, nFA_BASECOURS,
             nSUMM, nSUMMWITHNDS, nSERV_SUM, nSERV_SUM_NDS, nSTOPER, nACCDOC, sACCNUMB, dACCDATE, nSTORE,
             nGSMWAYS_TYPE, nKEEP_SIGN, nINEXP_SIGN, nFACTRET_SIGN,
             nSTORE_TYPE, nSTORE_CURR, nUSE_STORE_KOEFF, nPROCESS_SIGN, nDISTRIBUTION_SIGN,
             nJUR_PERS, dOLD_WORK_DATE, nTARIF, nMOL, nSUBDIV, sFACEACC, nFA_CURRENCY, nINCNDS
        from TRANSINVCUST    T,
             AZSGSMWAYSTYPES SO,
             AZSAZSLISTMT    S,
             FACEACC         F,
             DICTARIF        DT
       where T.RN      = nRN
         and T.COMPANY = nCOMPANY
         and T.STOPER  = SO.RN
         and T.FACEACC = F.RN
         and T.TARIF   = DT.RN
         and T.STORE   = S.RN (+);
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(nRN, 'GoodsTransInvoicesToConsumers');
    end;

    /* проверка смены состояния */
    if (nSTATUS = nOLD_STATUS ) then
      return;
    end if;

    /* проверка наличия связи с товарными отчетами (такие накладные не подлежат отработке, могут быть только в неотработанном виде) */
    if F_DOCLINKS_LINK_IN_DOC( 'GoodsTransInvoicesToConsumers', nRN, 'TradeReports' ) is not null then
      P_EXCEPTION( 0,'Расходная накладная на отпуск потребителям сформирована из товарного отчета. Изменение состояния документа недопустимо.' );
    end if;

    /* декодирование параметров складской операции */
    if (nINEXP_SIGN = 1) and (nFACTRET_SIGN = 1) then
      nINEXP_SIGN := 2;
    end if;

    /* поиск базовой валюты */
    FIND_CURRENCY_BASE( nCOMPANY, nBASE_CURRENCY );

    /* рассчет сумм в базовой валюте */
    for Rec in
    (
      select T.TAXGR, T.QUANT, T.SUMM, T.SUMMWITHNDS, T.SUMM_NDS, D.NOMEN_TYPE
        from TRANSINVCUSTSPECS T,
             NOMMODIF          N,
             DICNOMNS          D
       where T.PRN = nRN
         and T.NOMMODIF = N.RN
         and N.PRN = D.RN
    )
    loop
      PKG_DICTAXIS_CALC.P_RESULT_CURSOR_BASE_EX( 1, nCOMPANY, dWORK_DATE, null/*nSUMM_SIGN*/, Rec.SUMM, Rec.SUMMWITHNDS, Rec.SUMM_NDS,
                                                 nCURCOURS, nCURBASE, Rec.TAXGR, nTARIF, Rec.QUANT, cCURSOR );
      if cCURSOR%ISOPEN then
        close cCURSOR;
      end if;

      if REC.NOMEN_TYPE in ( 1,3 ) then -- товар
        nSUMM_BASE := nvl(nSUMM_BASE,0) + PKG_DICTAXIS_CALC.F_GET_VALUE ( 20 );
        nSUMMWITHNDS_BASE := nvl(nSUMMWITHNDS_BASE,0) + PKG_DICTAXIS_CALC.F_GET_VALUE ( 21 );
      elsif REC.NOMEN_TYPE = 2 then -- услуга
        nSERV_SUM_BASE := nvl(nSERV_SUM_BASE,0) + PKG_DICTAXIS_CALC.F_GET_VALUE ( 20 );
        nSERV_SUM_NDS_BASE := nvl(nSERV_SUM_NDS_BASE,0) + PKG_DICTAXIS_CALC.F_GET_VALUE ( 21 );
      end if;

      if (nFA_CURRENCY = nBASE_CURRENCY) and (nCURBASE/nCURCOURS = nFA_COURS/nFA_BASECOURS) then
        PKG_DICTAXIS_CALC.P_RESULT_CURSOR_BASE_EX ( 1, nCOMPANY, dWORK_DATE, null/*nSUMM_SIGN*/, Rec.SUMM, Rec.SUMMWITHNDS, Rec.SUMM_NDS,
                                                    nFA_BASECOURS, nFA_COURS, Rec.TAXGR, nTARIF, Rec.QUANT, cCURSOR);
        if cCURSOR%ISOPEN then
          close cCURSOR;
        end if;

        if Rec.NOMEN_TYPE in ( 1,3 ) then -- товар
          nSUMMWITHNDS_ACC := nvl(nSUMMWITHNDS_ACC,0) + PKG_DICTAXIS_CALC.F_GET_VALUE ( 21 );
        elsif Rec.NOMEN_TYPE = 2 then -- услуга
          nSERV_SUM_ACC := nvl(nSERV_SUM_ACC,0) + PKG_DICTAXIS_CALC.F_GET_VALUE ( 21 );
        end if;
      else
        if Rec.NOMEN_TYPE in ( 1,3 ) then -- товар
          nSUMMWITHNDS_ACC := nvl(nSUMMWITHNDS_ACC,0) + Rec.SUMMWITHNDS * nFA_COURS/nFA_BASECOURS;
        elsif Rec.NOMEN_TYPE = 2 then -- услуга
          nSERV_SUM_ACC := nvl(nSERV_SUM_ACC,0) + Rec.SUMMWITHNDS * nFA_COURS/nFA_BASECOURS;
        end if;
      end if;
    end loop;

    /* проверка связи с распоряжением */
    begin
      select D.RN
        into nSHEEP_RN
        from DOCLINKS      L,
             SHEEPDIRSCUST D
       where L.OUT_DOCUMENT = nRN
         and L.OUT_UNITCODE = 'GoodsTransInvoicesToConsumers'
         and L.IN_UNITCODE  = 'SheepDirectToConsumers'
         and L.IN_DOCUMENT  = D.RN
         and D.STATUS       = 1; -- отработано
    exception
      when NO_DATA_FOUND then
        nSHEEP_RN := null;
    end;

    if (nSTATUS = 1) and nSHEEP_RN is not null then
      P_EXCEPTION( 0, 'Расходная накладная на отпуск потребителям создана из распоряжения. Отработка как план недопустима.' );
    end if;

    /* поиск родительсих документов и снятие резервирования с них */
    FIND_PARENT_REMOVE_RES;

    /* очистка переменных пакета обмена */
    PKG_EXCHANGE.SET_QUANT(0, null);
    PKG_EXCHANGE.SET_QUANT(1, null);
    PKG_EXCHANGE.SET_QUANT(2, null);
    PKG_EXCHANGE.SET_QUANT(3, null);
    PKG_EXCHANGE.SET_QUANT(4, null);
    PKG_EXCHANGE.SET_QUANT(5, null);

    /* корректировка товарных запасов и отражения на ЛС */
    for C in
    (
      select S.*, GS.RN GOODSSUPPLY, ID.ENTRY_DATE,
             D.RN NOMEN, D.NOMEN_CODE, NM.MODIF_CODE, NP.CODE PACK_CODE,
             D.NOMEN_TYPE, D.SIGN_LIQUID,
             GP.SERNUMB, GP.COUNTRY, GP.GTD
        from TRANSINVCUSTSPECS S,
             NOMMODIF          NM,
             DICNOMNS          D,
             NOMNMODIFPACK     NMP,
             NOMNPACK          NP,
             GOODSPARTIES      GP,
             INCOMDOC          ID,
             GOODSSUPPLY       GS
       where S.PRN           = nRN
         and S.NOMMODIF      = NM.RN
         and NM.PRN          = D.RN
         and S.NOMNMODIFPACK = NMP.RN (+)
         and NMP.NOMENPACK   = NP.RN  (+)
         and S.GOODSPARTY    = GP.RN  (+)
         and GP.INDOC        = ID.RN  (+)
         and GP.RN           = GS.PRN (+)
         and GS.STORE (+)    = nSTORE
    )
    loop
 
      /* инициализация переменных пакета обмена значениями остатков на дату отработки */
      PKG_EXCHANGE.SET_QUANT(0, nvl(nRESTFACT,0));
      PKG_EXCHANGE.SET_QUANT(1, nvl(nRESTPLAN,0));
      PKG_EXCHANGE.SET_QUANT(2, nvl(nRESERV,0));
      PKG_EXCHANGE.SET_QUANT(3, nvl(C.QUANT,0));
      PKG_EXCHANGE.SET_QUANT(4, nvl(nMIN_RESTFACT,0));
      PKG_EXCHANGE.SET_QUANT(5, nvl(nMIN_RESTPLAN,0));

      /* отражение на графиках ЛС */
      nFACT_SIGN      := 0;
      nPLAN_SIGN      := 0;
      nROLLBACK       := 0;
      nPLAN_QUANT     := 0;
      nPLAN_QUANT_ALT := 0;
      nFACT_QUANT     := 0;
      nFACT_QUANT_ALT := 0;
      nPLAN_SUM       := 0;
      nFACT_SUM       := 0;

      if (nSTATUS = 0) then  -- снять отработку
        nROLLBACK       := 1;
        if nSHEEP_RN is null then
          nPLAN_SIGN      := 1;
          nPLAN_QUANT     := C.QUANT;
          nPLAN_QUANT_ALT := C.QUANTALT;
          nPLAN_SUM       := C.SUMMWITHNDS;
        end if;
        if nOLD_STATUS = 2 then
          nFACT_SIGN      := 1;
          nFACT_QUANT     := C.QUANT;
          nFACT_QUANT_ALT := C.QUANTALT;
          nFACT_SUM       := C.SUMMWITHNDS;
        end if;
      elsif (nSTATUS = 1) then  -- отработать как план
        if (nOLD_STATUS = 0) and nSHEEP_RN is null then
          nPLAN_SIGN      := 1;
          nPLAN_QUANT     := C.QUANT;
          nPLAN_QUANT_ALT := C.QUANTALT;
          nPLAN_SUM       := C.SUMMWITHNDS;
        elsif nOLD_STATUS = 2 then
          nROLLBACK       := 1;
          nFACT_SIGN      := 1;
          nFACT_QUANT     := C.QUANT;
          nFACT_QUANT_ALT := C.QUANTALT;
          nFACT_SUM       := C.SUMMWITHNDS;
        end if;
      elsif (nSTATUS = 2) then  -- отработать как факт
        nFACT_SIGN      := 1;
        nFACT_QUANT     := C.QUANT;
        nFACT_QUANT_ALT := C.QUANTALT;
        nFACT_SUM       := C.SUMMWITHNDS;
        if (nOLD_STATUS = 0) and nSHEEP_RN is null then
          nPLAN_SIGN      := 1;
          nPLAN_QUANT     := C.QUANT;
          nPLAN_QUANT_ALT := C.QUANTALT;
          nPLAN_SUM       := C.SUMMWITHNDS;
        end if;
      end if;

      P_FACEACC_SET_OPERS( nCOMPANY, nFACEACC, nGRAPHPOINT, null, dWORK_DATE, nINEXP_SIGN, nPLAN_SIGN, nFACT_SIGN, C.NOMMODIF, C.NOMNMODIFPACK,
                           C.SERNUMB, C.COUNTRY, C.GTD,
                           C.ARTICLE, nROLLBACK,
                           nPLAN_QUANT, nPLAN_QUANT_ALT, nFACT_QUANT, nFACT_QUANT_ALT, nPLAN_SUM * nCURBASE/nCURCOURS, nFACT_SUM  * nCURBASE/nCURCOURS,
                           'GoodsTransInvoicesToConsumersSpecs', C.RN );
    end loop;

    /* отражение в Журнале отгрузок и ЛС */
    vREMNS := PKG_FACEACCTRADE.CLEAR_REMNS;
    vREMNS.nCURRENCY := nFA_CURRENCY;
    if (nSTATUS = 0) then -- снять отработку

      if (nOLD_STATUS = 1) then  -- отработан как план
        if (nINEXP_SIGN = 2) then
          vREMNS.nPLAN_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
        else
          vREMNS.nPLAN_SHIP := nSUMMWITHNDS_ACC;
          vREMNS.nPLAN_SERV := nSERV_SUM_ACC;
        end if;
      elsif (nOLD_STATUS = 2) then -- отработан как факт
        if (nINEXP_SIGN = 2) then
          vREMNS.nFACT_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
          if nSHEEP_RN is null  then
            vREMNS.nPLAN_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
          end if;
        else
          vREMNS.nFACT_SHIP := nSUMMWITHNDS_ACC;
          vREMNS.nFACT_SERV := nSERV_SUM_ACC;
          if nSHEEP_RN is null then
            vREMNS.nPLAN_SHIP := nSUMMWITHNDS_ACC;
            vREMNS.nPLAN_SERV := nSERV_SUM_ACC;
          end if;
        end if;
      end if;
      P_LIABNOTESTRADE_BASE_DELETE( nCOMPANY, null, vREMNS, 'GoodsTransInvoicesToConsumers', nRN, nRES );

    elsif (nSTATUS = 1) then -- отработать как план

      if (nOLD_STATUS = 2) then
        if (nINEXP_SIGN = 2) then
          vREMNS.nFACT_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
          if nSHEEP_RN is null then
            vREMNS.nPLAN_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
          end if;
        else
          vREMNS.nFACT_SHIP := nSUMMWITHNDS_ACC;
          vREMNS.nFACT_SERV := nSERV_SUM_ACC;
          if nSHEEP_RN is null then
            vREMNS.nPLAN_SHIP := nSUMMWITHNDS_ACC;
            vREMNS.nPLAN_SERV := nSERV_SUM_ACC;
          end if;
        end if;

        /* удалить, откатить план/факт */
        P_LIABNOTESTRADE_BASE_DELETE( nCOMPANY, null, vREMNS, 'GoodsTransInvoicesToConsumers', nRN, nRES, 2 );
        vREMNS := PKG_FACEACCTRADE.CLEAR_REMNS;
        vREMNS.nCURRENCY := nFA_CURRENCY;
      end if;

      if (nINEXP_SIGN = 2) then
        vREMNS.nPLAN_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
      else
        if nSHEEP_RN is null then
          vREMNS.nPLAN_SHIP := nSUMMWITHNDS_ACC;
          vREMNS.nPLAN_SERV := nSERV_SUM_ACC;
        end if;
      end if;

      if nSHEEP_RN is null then
        P_LIABNOTESTRADE_BASE_INSERT( nCOMPANY, nJUR_PERS, sPREF, nFACEACC, nGRAPHPOINT, dWORK_DATE, nAGENT, null,
          nACCDOC, dACCDATE, sACCNUMB, nCURRENCY, vREMNS, nSUMM, nSUMMWITHNDS, nSUMM_BASE, nSUMMWITHNDS_BASE,
          nSERV_SUM, nSERV_SUM_NDS, nSERV_SUM_BASE, nSERV_SUM_NDS_BASE, nSUMMWITHNDS_ACC, nSERV_SUM_ACC,
          nSTOPER, nPAYTYPE, nDOCTYPE, PKG_DOCUMENT.MAKE_NUMBER_EX(nCOMPANY, sPREF, sNUMB), dDOCDATE,
          0/*nSTATE_SIGN*/, 1/*nDOC_STATE*/, null, null, 'GoodsTransInvoicesToConsumers', nRN, nTMP );
      end if;

    elsif (nSTATUS = 2) then -- отработать как факт

      if (nOLD_STATUS = 1) then
        if (nINEXP_SIGN = 2) then
          vREMNS.nPLAN_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
        else
          vREMNS.nPLAN_SHIP := nSUMMWITHNDS_ACC;
          vREMNS.nPLAN_SERV := nSERV_SUM_ACC;
        end if;

        if nSHEEP_RN is null then
          /* удалить, откатить план */
          P_LIABNOTESTRADE_BASE_DELETE( nCOMPANY, null, vREMNS, 'GoodsTransInvoicesToConsumers', nRN, nRES, 1 );
        end if;
        vREMNS := PKG_FACEACCTRADE.CLEAR_REMNS;
        vREMNS.nCURRENCY := nFA_CURRENCY;
      end if;

      if (nINEXP_SIGN = 2) then
        vREMNS.nFACT_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
        if nSHEEP_RN is null then
          vREMNS.nPLAN_INCOME := nSUMMWITHNDS_ACC + nSERV_SUM_ACC;
        end if;
      else
        vREMNS.nFACT_SHIP := nSUMMWITHNDS_ACC;
        vREMNS.nFACT_SERV := nSERV_SUM_ACC;
        if nSHEEP_RN is null then
          vREMNS.nPLAN_SHIP := nSUMMWITHNDS_ACC;
          vREMNS.nPLAN_SERV := nSERV_SUM_ACC;
        end if;
      end if;

      /* если накладная сформирована из распоряжения, ищем плановую запись в журнале отгрузок */
      begin
        select /*+ ORDERED */ LN.RN
          into nRES
          from DOCLINKS       L,
               DOCLINKS       L1,
               LIABILITYNOTES LN
          where L.OUT_DOCUMENT  = nRN
            and L.OUT_UNITCODE  = 'GoodsTransInvoicesToConsumers'
            and L.IN_UNITCODE   = 'SheepDirectToConsumers'
            and L1.IN_DOCUMENT  = L.IN_DOCUMENT
            and L1.IN_UNITCODE  = 'SheepDirectToConsumers'
            and L1.OUT_UNITCODE = 'LiabilitiesNotes'
            and L1.OUT_DOCUMENT = LN.RN
            and LN.STATE_SIGN   = 0;
      exception
        when NO_DATA_FOUND then
          nRES := null;
      end;

      P_LIABNOTESTRADE_BASE_INSERT( nCOMPANY, nJUR_PERS, sPREF, nFACEACC, nGRAPHPOINT, dWORK_DATE, nAGENT, null,        -- факт/закрыт, отработать план/факт
        nACCDOC, dACCDATE, sACCNUMB, nCURRENCY, vREMNS, nSUMM, nSUMMWITHNDS, nSUMM_BASE, nSUMMWITHNDS_BASE,
        nSERV_SUM, nSERV_SUM_NDS, nSERV_SUM_BASE, nSERV_SUM_NDS_BASE, nSUMMWITHNDS_ACC, nSERV_SUM_ACC,
        nSTOPER, nPAYTPE, nDOCTYPE, PKG_DOCUMENT.MAKE_NUMBER_EX(nCOMPANY, sPREF, sNUMB), dDOCDATE,
        1/*nSTATE_SIGN*/, 1/*nDOC_STATE*/, nRES, null, 'GoodsTransInvoicesToConsumers', nRN, nTMP );
    end if;

    /* исправление исполнения у родительских документов */
    RECALC_PERFORMANCE;

  end TRANSINVCUST_RECALC_PERF;
  /*########################################################################################################*/

  procedure TRANSINVCUST_SPRJ_COPY_OTHER
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
    rRow    transinvcust%rowtype;
  begin
    /* Считывание заголовка документа-источника */
    rRow := transinvcust_get( nrn => nRN_FROM ); 

    /* Проверка отработанности документа-источника для случаев, когда попирование выполняется из "приход (для распределения)" */
    if rRow.status != 1 and nRES_TYPE_FROM = 0 then
      p_exception( nFLAGSMART, 'Документ-источник не отработан. Копирование из "Места хранения для распределния" не будет выполнено.%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn)); 
    end if;

    /* По спецификациям документа-источника и приёмника */
    for c in ( 
              select t1.rn as t1_rn, t1.prn as t1_prn, t2.rn as t2_rn, t2.prn as t2_prn
                    ,dt2.doccode  as dt2_doccode, h2.pref as h2_pref, h2.numb as h2_numb, h2.docdate as h2_docdate
                from transinvcustspecs t1
                    ,transinvcustspecs t2
                join transinvcust      h2  on h2.rn  = t2.prn
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
                                             ,smasterunitcode_to => 'GoodsTransInvoicesToConsumers'
                                             ,sslaveunitcode_to  => 'GoodsTransInvoicesToConsumersSpecs'
                                             ,sdoctype           => c.dt2_doccode
                                             ,sdocpref           => c.h2_pref
                                             ,sdocnumb           => c.h2_numb
                                             ,ddocdate           => c.h2_docdate
                                             ,dreserving_date    => dRESERVING_DATE );
    end loop;

  end TRANSINVCUST_SPRJ_COPY_OTHER;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_CREATE_COPY
  /*
  Заголовок. Создать копию документа
  Нужно для случаев, когда исправляемая накладная содержит изделие, которое числится у нас на складе.
  Делаем копию накладной, отгружаем по ней такие изделия.
  */
  (
   nRN              in number
  ,aRN_LIST         out udo_tp_numtable
  ) 
  is
    rHead               transinvcust%rowtype;
    rHeadCopy           transinvcust%rowtype;
    rSpecCopy           transinvcustspecs%rowtype;
    rStrPlResJrnl       strplresjrnl%rowtype;
    nIndex              pkg_std.tnumber := 0; 
    nCount              pkg_std.tnumber := 0; 
    
    nNumber     pkg_std.tnumber; 
  begin
    /* Инициализация */
    aRN_LIST := udo_tp_numtable();

    /* Считывание оригинала */
    rHead := transinvcust_get( nrn => nRN);

    /* По спецификациям оригинала, В КОТОРЫХ ЕСТЬ ИЗДЕЛИЯ и у этого изделия есть остаток. С сортировкой по складу */
    for c in ( 
               select t.*, a.*
                     ,h.doctype, h.pref, h.numb, h.docdate
                     ,ds.azs_number as ds_azs_number
                     ,lag(a.gs_store, 1) over(order by a.gs_store) as gs_store_lag
                 from transinvcustspecs t
                 join transinvcust      h  on h.rn  = t.prn
                 join azsazslistmt      ds on ds.rn = h.store
                 join ( 
                       select gs.rn as gs_rn, gs.prn as gs_prn, gs.store as gs_store, gs.restfact as gs_restfact
                             ,ats.article as ats_article, icd.stor_sign as icd_stor_sign
                         from goodssupply     gs  
                         join goodsparties    gp  on gp.rn   = gs.prn
                         join incomdoc        icd on icd.rn  = gp.indoc
                    left join articlessupply  ats on ats.prn = gs.rn
                        where gs.restfact != 0
                      ) a
                   on (  nvl( a.gs_prn     , -1 ) = nvl( t.goodsparty, -1 ) 
                      or nvl( a.ats_article, -1 ) = nvl( t.article   , -1 ) )
                where t.prn     = rHead.rn
                  and t.article is not null
               order by a.gs_store
             )
    loop
      /* Счётчик */
      nCount := nCount+1;

      /* Считывание текущей спецификации */
      rSpecCopy := transinvcustspecs_get( nrn => c.rn );

      /* Если текущий склад не равен предыдущему или первая запись */
      if cmp_num( c.gs_store, c.gs_store_lag ) != 1 or nCount = 1 then
        
        /* Копирование заголовка в переменную-копию */
        rHeadCopy := rHead;

        /* Добавление заголовка-копии */
        /* подменяем переменные */
        rHeadCopy.pref            := n2si( c.gs_store );
        rHeadCopy.docdate         := trunc( sysdate );
        rHeadCopy.status          := 0;
        rHeadCopy.work_date       := null;
        rHeadCopy.salesreportdate := null;
        rHeadCopy.store           := c.gs_store;
        /* если признак партии - ответственное хранение, подменяем складскую операцию на "РасходВнешОХ" */
        if c.icd_stor_sign = 1 then 
          rHeadCopy.stoper := 53471831;
        end if;
        /* добавляем */
        transinvcust_base_insert( rrow => rHeadCopy, nreserv_sign => 0, nrn => rHeadCopy.rn );

        /* Сохраняем добавленный заголовок в массив */
        nIndex := nIndex + 1;
        aRN_LIST.EXTEND;
        aRN_LIST( nIndex  ) := rHeadCopy.rn;
      end if;

      /* Добавляем спецификацию */
      rSpecCopy.prn         := rHeadCopy.rn;
      rSpecCopy.goodsparty  := c.gs_prn;
      transinvcustspecs_base_insert( rrow => rSpecCopy, nrn => rSpecCopy.rn );

      /* По местам хранения изделия */
      for C2 in ( 
                 select *
                   from stplgoodssupply  t  
                  where (  nvl( t.goodssupply, -1 ) = nvl( c.gs_rn      , -1 )       
                        or nvl( t.article    , -1 ) = nvl( c.ats_article, -1 ) )     
                    and t.quant != 0
                )
      loop                
        /* Заполение переменных для места хранения */
        rStrPlResJrnl.company        := c2.company;
        rStrPlResJrnl.authid         := utilizer;
        rStrPlResJrnl.cell           := c2.cell;
        rStrPlResJrnl.goodssupply    := c2.goodssupply;
        rStrPlResJrnl.res_type       := 1;
        rStrPlResJrnl.nommodif       := c.nommodif;
        rStrPlResJrnl.nomnmodifpack  := c.nomnmodifpack;
        rStrPlResJrnl.article        := c.article;
        rStrPlResJrnl.doctype        := c.doctype;
        rStrPlResJrnl.docpref        := trim(c.pref); 
        rStrPlResJrnl.docnumb        := trim(c.numb);
        rStrPlResJrnl.docdate        := c.docdate;
        rStrPlResJrnl.reserving_date := rHeadCopy.docdate;
        rStrPlResJrnl.free_date      := null;
        rStrPlResJrnl.quant          := c2.quant;
        rStrPlResJrnl.quantalt       := c2.quantalt;
        /* Добавление резервирования по МХ */
        usr_pkg_strplresjrnl.strplresjrnl_base_insert(rrow            => rStrPlResJrnl
                                                     ,smasterunitcode => 'GoodsTransInvoicesToConsumers'
                                                     ,sslaveunitcode  => 'GoodsTransInvoicesToConsumersSpecs'
                                                     ,nmasterrn       => rHeadCopy.rn
                                                     ,nslavern        => rSpecCopy.rn
                                                     ,nflag_smart     => 0
                                                     ,nrn             => rStrPlResJrnl.rn
                                                     ,nmode           => 0 );
      end loop;
    end loop;
    
    /* По добавленным копиям */
    for c in ( select column_value from table( cast( aRN_LIST as udo_tp_numtable ) ) ) 
    loop
      /* Отработка в учёте */
      p_transinvcust_bset_status(ncompany   => rHeadCopy.company
                                ,nrn        => c.column_value
                                ,nstatus    => 2
                                ,dwork_date => rHeadCopy.docdate
                                ,nident     => c.column_value );
    end loop;

  end TRANSINVCUST_CREATE_COPY;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_DELETE_COPY
  /*
  Заголовок. Удалить копии
  */
  (
   nCOMPANY   in number
  ,aRN_LIST   in udo_tp_numtable
  ) 
  is
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    /* По RN заголовков копий */
    for c in ( select column_value from table( cast( aRN_LIST as udo_tp_numtable ) ) ) 
    loop
      /* Снятие отработки */
      p_transinvcust_bset_status(ncompany   => nCOMPANY
                                ,nrn        => c.column_value
                                ,nstatus    => 0
                                ,dwork_date => sysdate
                                ,nident     => c.column_value );
      /* Удаление резервирования по местам хранения */
      usr_pkg_document.strplresjrnl_base_delete( nrn => c.column_value );
      /* Удаление документа */
      p_transinvcust_base_delete( ncompany => nCOMPANY, nrn => c.column_value );
    end loop;

  end TRANSINVCUST_DELETE_COPY;

  /*#########################################################################################################*/

  procedure TRANSINVCUST_MAKEINV
  /*
  Заголовок. Формирование возвратных расходных накладных
  */
  (
   nRN   in number
  ) 
  is
    rV_Row      v_transinvcust%rowtype;

    sVarchar    pkg_std.tstring; 
  begin
    /* Считывание */
    select * into rV_Row from v_transinvcust where nrn = transinvcust_makeinv.nrn;

    /* Формирование буфера */
    p_transinvcust_makeinvoice( ncompany => rV_Row.ncompany, nrn => rV_Row.nrn, nident => rV_Row.nrn );

    /* Перенос из буфера */
    p_transinvcustbuf_makeinvbuf(ncompany => rV_Row.ncompany, nident => rV_Row.nrn, smsg => sVarchar );

  end TRANSINVCUST_MAKEINV;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_MAKEININV
  /*
  Заголовок. Формирование приходных накладных
  */
  (
   nRN          in number  
  ,nCOMPANY     in number  
  ,nIDENT       in number  
  ,sCATALOG     in varchar2
  ,sDOCTYPE     in varchar2
  ,sPREF        in varchar2
  ,dDOCDATE     in date
  ,sEXT_NUMB    in varchar2
  ,dDEXT_DATE   in date
  ,sSTORE       in varchar2
  ,sSTOREOPER   in varchar2
  ,sFACEACC     in varchar2
  ,nMAKE_IO     in number       /* формировать приходные ордера */
  ) 
  is
    nNumber   pkg_std.tnumber; 
    sVarchar  pkg_std.tstring; 
  begin
    /* Формирование буфера */
    usr_p_tic_make_ininvoice( nrn        => nRN
                             ,nident     => nIDENT
                             ,scatalog   => sCATALOG
                             ,sdoctype   => sDOCTYPE
                             ,spref      => sPREF
                             ,ddocdate   => dDOCDATE
                             ,sext_numb  => sEXT_NUMB
                             ,ddext_date => dDEXT_DATE
                             ,sstore     => sSTORE
                             ,sstoreoper => sSTOREOPER
                             ,sfaceacc   => sFACEACC );
    /* Перенос из буфера */
    usr_p_ticbuf_make_ininvoicebuf( ncompany => nCOMPANY, nident => nIDENT );

    /* Если Формировать приходные ордера */
    if cmp_num( nMAKE_IO, 1 ) = 1 then 
      /* По заголовкам сформированных документов */
      for c in ( select distinct out_document0 from usr_t_inhierbuff_common ) 
      loop
        /* Отработка */
        p_ininvoices_bset_status( ncompany   => nCOMPANY
                                 ,nrn        => c.out_document0
                                 ,nstatus    => 2
                                 ,dwork_date => dDOCDATE
                                 ,nwarning   => nNumber
                                 ,smsg       => sVarchar );
        /* Формирование приходного ордера */
        usr_pkg_ininvoices.ininvoices_make_inorders( nrn => c.out_document0, ncompany => nCOMPANY, sstore => sSTORE, nmode => 1 ); 
      end loop;
    end if;

  end TRANSINVCUST_MAKEININV;
  /*#########################################################################################################*/

  procedure TRANSINVCUST_MAKEACCFI
  /*
  Заголовок. Формирование входящего счета-фактуры
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,sCATALOG         in varchar2               /* мнемокод каталога ВСФ */
  ,sPREFIX          in varchar2               /* префикс ВСФ */
  ,dDATE            in date                   /* дата ВСФ */
  ,dINC_DATE        in date                   /* дата поступления документа */
  ,sIN_NUMBER       in varchar2               /* номер поставщика */
  ,sAGNFO           in varchar2 default null  /* грузоотправитель */
  ,sAGNACC          in varchar2               /* банковские реквизиты поставщика */
  ,sSELFAGNACC      in varchar2               /* банковские реквизиты покупателя */
  ,sCURRENCY        in varchar2               /* валюта формируемого ВСФ */
  ,nGROUPMASTER     in number   default 0     /* консолидация заголовков (0-нет, 1-по контрагенту, 2-по ЛС) */
  ,nGROUPSLAVE      in number   default 0     /* консолидация спецификаций (0-нет, 1-по номенклатуре, 2-по модификациям) */
  ,nGROUPPRICE      in number   default 0     /* консолидация спецификаций по цене (0-нет, 1-да) */
  ,nAUTOCALCSIGN    in number   default 1     /* производить автаматический пересчет сумм в спецификации (0-нет, 1-да) */
  ,nTRUE_REC        out number                /* признак cформирования хотя бы одной записи (null - ошибка, 0 - нет, >=1 - да) */
  ) 
  is
    sVarchar    pkg_std.tstring; 
    nNumber     pkg_std.tnumber; 
  begin
    p_selectlist_insert_ext( nident     => nRN
                            ,ndocument  => nRN
                            ,sunitcode  => 'GoodsTransInvoicesToConsumers'
                            ,ndocument1 => null
                            ,sunitcode1 => null
                            ,ncrn       => null
                            ,nrn        => nNumber );
    p_transinvcust_createacfi( ncompany      => nCOMPANY
                              ,nident        => nRN
                              ,scatalog      => sCATALOG     
                              ,sprefix       => sPREFIX      
                              ,ddate         => dDATE        
                              ,dinc_date     => dINC_DATE    
                              ,sin_number    => sIN_NUMBER   
                              ,sagnfo        => sAGNFO       
                              ,sagnacc       => sAGNACC      
                              ,sselfagnacc   => sSELFAGNACC  
                              ,scurrency     => sCURRENCY    
                              ,ngroupmaster  => nGROUPMASTER 
                              ,ngroupslave   => nGROUPSLAVE  
                              ,ngroupprice   => nGROUPPRICE  
                              ,nautocalcsign => nAUTOCALCSIGN
                              ,ntrue_rec     => nTRUE_REC );
    p_selectlist_clear( nident => nRN );

  end TRANSINVCUST_MAKEACCFI;
  /*#########################################################################################################*/

  function TRANSINVCUSTSPECS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return transinvcustspecs%rowtype
  is
    rRow transinvcustspecs%rowtype;
  begin
    begin
      select * into rRow from transinvcustspecs where rn = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'TRANSINVCUSTSPECS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVCUSTSPECS'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end TRANSINVCUSTSPECS_GET;
  /*#########################################################################################################*/
  
  PROCEDURE TRANSINVCUSTSPECS_GET_BY_PRM
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
  ,NPRN               IN NUMBER
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,NGOODSPARTY        IN NUMBER   DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT TRANSINVCUSTSPECS%ROWTYPE 
  ) 
  IS
    sMessage          pkg_std.tstring; 
    rV_GoodsParties   v_goodsparties%rowtype;

    sVarchar          pkg_std.tstring; 
  BEGIN
    BEGIN
      SELECT *
        INTO rRow
        FROM TRANSINVCUSTSPECS T
       WHERE T.PRN                    = NPRN
         AND (NVL(T.NOMMODIF, 0)      = NVL(NNOMMODIF, 0) OR (NNOMMODIF IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMNMODIFPACK, 0) = NVL(NNOMMODIFPACK, 0) OR (NNOMMODIFPACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.TAXGR, 0)         = NVL(NTAXGR, 0) OR (NTAXGR IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANT, 0)         = NVL(NQUANT, 0) OR (NQUANT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANTALT, 0)      = NVL(NQUANTALT, 0) OR (NQUANTALT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.PRICE, 0)         = NVL(NPRICE, 0) OR (NPRICE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.ARTICLE, 0)       = NVL(NARTICLE, 0) OR (NARTICLE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.GOODSPARTY, 0)    = NVL(NGOODSPARTY, 0) OR (NGOODSPARTY IS NULL AND NFLAG_OPTION = 1))
         AND ((T.BEGINDATE = DBEGINDATE OR (T.BEGINDATE IS NULL AND DBEGINDATE IS NULL)) OR (DBEGINDATE IS NULL AND NFLAG_OPTION = 1))
         AND ((T.ENDDATE   = DENDDATE   OR (T.ENDDATE   IS NULL AND DENDDATE   IS NULL)) OR (DENDDATE   IS NULL AND NFLAG_OPTION = 1))
         ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF NFLAGSMART = 0 THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'GoodsTransInvoicesToConsumers'
                                           ,nprn        => NPRN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,narticle    => NARTICLE
                                           ,ngoodsparty => NGOODSPARTY
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);

          P_EXCEPTION(0 , sMessage);
        END IF;
      WHEN TOO_MANY_ROWS THEN
        IF NTOO_MANY_ROWS = 0 AND NFLAGSMART = 0 THEN
          P_EXCEPTION(0, 'Найдено больше одной спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'TRANSINVCUSTSPECS')));
        END IF;
      WHEN OTHERS THEN
        P_EXCEPTION(0, 'Неопределённая ситуация при поиске спецификации для заголовка с RN <%s> записи в разделе <%s>'
                   ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'TRANSINVCUSTSPECS')));
    END;
  END TRANSINVCUSTSPECS_GET_BY_PRM;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Проверка базовая */
    transinvcustspecs_check_base(nrn => NRN, ncompany => NCOMPANY);

  end TRANSINVCUSTSPECS_AINSERT;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    usr_pkg_pub_const.rtransinvcustspecs := transinvcustspecs_get( nrn => nRN );
  end TRANSINVCUSTSPECS_BUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow            transinvcustspecs%rowtype;
    rFcAcOperPlans  fcacoperplans%rowtype;
    rTrInvCustClc   trinvcustclc%rowtype;

    sVarchar        pkg_std.tstring; 
    nNumber         pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := transinvcustspecs_get( nrn => nRN );
    /* Калькуляция, если она одна. Иначе сообщение об ошибке - надо удалить, чтобы осталась одна */
    trinvcustclc_get_by_prm( nflagsmart => 1, ntoo_many_rows => 0, nprn => rRow.rn, rrow => rTrInvCustClc );
    /* График отпуска по точке графика калькуляции */
    usr_pkg_faceacc.fcacoperplans_get_by_params( nflagsmart     => 1
                                                ,ntoo_many_rows => 0
                                                ,ngraphpoint    => rTrInvCustClc.graphpoint
                                                ,rrow           => rFcAcOperPlans );
    /* ИСПРАВЛЕНИЯ */
    /* Если калькуляция найдена */
    if rTrInvCustClc.rn is not null then
      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

      /* Удаление */
      trinvcustclc_bdelete(nrn => rTrInvCustClc.rn, ncompany => rTrInvCustClc.company );
      p_trinvcustclc_base_delete( nrn => rTrInvCustClc.rn, ncompany => rTrInvCustClc.company );
      trinvcustclc_adelete(nrn => rTrInvCustClc.rn, ncompany => rTrInvCustClc.company );

      /* Добавление новой */
      tics_ticsc_base_insert( rrow => rRow, rFAOOP => rFcAcOperPlans, nTICSC => rTrInvCustClc.rn );
      trinvcustclc_ainsert( nrn => rTrInvCustClc.rn, ncompany => rTrInvCustClc.company );

      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
    end if;

    /* ПРОВЕРКИ */
    /* Базовая */
    transinvcustspecs_check_base(nrn => NRN, ncompany => NCOMPANY);
    
  end TRANSINVCUSTSPECS_AUPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* ИСПРАВЛЕНИЯ */
    /* удаление связей по DocLinks у документа */
    p_linksall_delete_full_out( ncompany => nCOMPANY, sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => nRN );
    p_linksall_delete_full_in ( ncompany => nCOMPANY, sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => nRN );

  end TRANSINVCUSTSPECS_BDELETE;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              transinvcustspecs%rowtype;

    nNumber           pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := transinvcustspecs_get(nrn => NRN);
    /* Проверка исполнения родительской спецификации */
    usr_pkg_transinvcust.transinvcustspecs_check_indoc(rrow => rRow);
    
  end TRANSINVCUSTSPECS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_CHECK_INDOC
  /*
  Спецификация. Проверка превышения исполнения родительской спецификации
  */
  (
   rROW   in transinvcustspecs%rowtype
  ) 
  is
    nInDoc              pkg_std.tref; 
    rInDocSpec          sheepdirscustspecs%rowtype;
    nQuant_Rest         pkg_std.tquant; 
    
    nNumber             pkg_std.tnumber; 
  begin
    /* Связанный входной документ */
    nInDoc := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                   ,sout_unitcode  => 'GoodsTransInvoicesToConsumers'
                                                   ,nout_document  => rROW.PRN
                                                   ,sin_unitcode   => 'SheepDirectToConsumers');
    /* Если входной документ найден*/
    if nInDoc is not null then                                                           
      /* аналогичная спецификация во входном документе */
      usr_pkg_sheepdirscust.sheepdirscustspecs_get_by_prm(nprn      => nInDoc
                                                         ,nnommodif => rROW.NOMMODIF
                                                         ,ntaxgr    => rROW.TAXGR
                                                         ,nquant    => rROW.QUANT
                                                         ,nquantalt => rROW.QUANTALT
                                                         ,nprice    => rROW.PRICE
                                                         ,narticle  => rROW.ARTICLE
                                                         ,rrow      => rInDocSpec);
      /* количество остатка исполнения спецификации входного документа */
      usr_pkg_sheepdirscust.sheepdircs_get_out_doc_exec(rrow        => rInDocSpec
                                                       ,nquant_exec => nNumber
                                                       ,nquant_rest => nQuant_Rest );
      /* если количество остатка исполнения спецификации входного документа меньше нуля */
      if nQuant_Rest /*<*/  != 0 then
        p_exception(0, 'Количество в спецификации Распоряжения <%s> не равно количеству Расходной накладной потребителям <%s>. %s%s'
        /*p_exception(0, 'Превышено количество в сформированных документах. Количество во входящем документе <%s>, превышение <%s>. %s%s'*/
                   ,rInDocSpec.quant
                   ,nQuant_Rest
                   ,cr||f_docdescrs_get_description('GoodsTransInvoicesToConsumersSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('GoodsTransInvoicesToConsumers', rRow.prn)); 

      end if;
    /*else
      p_exception(0, 'Документ не связан по входу с разделом <%s>. %s%s'
                 ,get_unitlist_code_table(nflag_smart => 1, stable_name => 'SHEEPDIRSCUST')
                 ,cr||f_docdescrs_get_description('GoodsTransInvoicesToConsumersSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('GoodsTransInvoicesToConsumers', rRow.prn)); */
    end if;
    
  end TRANSINVCUSTSPECS_CHECK_INDOC;

  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_INSERT
  /*
  Спецификация. Добавить
  */
  (
   rV_ROW       in out v_transinvcustspecs%rowtype
  ,sMSG         out varchar2
  ) 
  is
  begin
    p_transinvcustspecs_insert(ncompany         => rV_ROW.NCOMPANY
                              ,nprn             => rV_ROW.NPRN
                              ,staxgr           => rV_ROW.STAXGR
                              ,sgoodsparty      => rV_ROW.SGOODSPARTY
                              ,snomen           => rV_ROW.SNOMEN
                              ,snommodif        => rV_ROW.SNOMMODIF
                              ,snomnmodifpack   => rV_ROW.SNOMNMODIFPACK
                              ,sarticle         => rV_ROW.SARTICLE
                              ,scell            => rV_ROW.SCELL
                              ,shlcargoclass    => rV_ROW.SHLCARGOCLASS
                              ,ntemperature     => rV_ROW.NTEMPERATURE
                              ,nprice           => rV_ROW.NPRICE
                              ,ndiscount        => rV_ROW.NDISCOUNT
                              ,nquant           => rV_ROW.NQUANT
                              ,nquantalt        => rV_ROW.NQUANTALT
                              ,ncoeff           => rV_ROW.NCOEFF
                              ,ncoeff_val_sign  => rV_ROW.NCOEFF_VAL_SIGN
                              ,ncoeff_calc_sign => rV_ROW.NCOEFF_CALC_SIGN
                              ,npricemeas       => rV_ROW.NPRICEMEAS
                              ,nsumm            => rV_ROW.NSUMM
                              ,nsummwithnds     => rV_ROW.NSUMMWITHNDS
                              ,nsumm_nds        => rV_ROW.NSUMM_NDS
                              ,nautocalc_sign   => rV_ROW.NAUTOCALC_SIGN
                              ,dbegindate       => rV_ROW.DBEGINDATE
                              ,denddate         => rV_ROW.DENDDATE
                              ,ssernumb         => rV_ROW.SSERNUMB
                              ,scountry         => rV_ROW.SCOUNTRY
                              ,sgtd             => rV_ROW.SGTD
                              ,snote            => rV_ROW.SNOTE
                              ,nrn              => rV_ROW.NRN
                              ,smsg             => sMSG);
  end TRANSINVCUSTSPECS_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_UPDATE
  /*
  Спецификация. Исправить
  */
  (
   rV_ROW           in v_transinvcustspecs%rowtype
  ,nFLAG_DEL_CALC   in number default 0
  ,sMSG             out varchar2
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_Row2         v_transinvcustspecs%rowtype := rV_ROW;
    rTransInvCust   transinvcust%rowtype;
    aRN_List        udo_tp_numtable := udo_tp_numtable();
    
    nNumber   pkg_std.tnumber; 
    sVarchar  pkg_std.tstring; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
       p_transinvcustspecs_update(nrn              => rV_ROW.NRN
                                 ,ncompany         => rV_ROW.NCOMPANY
                                 ,nprn             => rV_ROW.NPRN
                                 ,staxgr           => rV_ROW.STAXGR
                                 ,sgoodsparty      => rV_ROW.SGOODSPARTY
                                 ,snomen           => rV_ROW.SNOMEN
                                 ,snommodif        => rV_ROW.SNOMMODIF
                                 ,snomnmodifpack   => rV_ROW.SNOMNMODIFPACK
                                 ,sarticle         => rV_ROW.SARTICLE
                                 ,scell            => rV_ROW.SCELL
                                 ,shlcargoclass    => rV_ROW.SHLCARGOCLASS
                                 ,ntemperature     => rV_ROW.NTEMPERATURE
                                 ,nprice           => rV_ROW.NPRICE
                                 ,ndiscount        => rV_ROW.NDISCOUNT
                                 ,nquant           => rV_ROW.NQUANT
                                 ,nquantalt        => rV_ROW.NQUANTALT
                                 ,ncoeff           => rV_ROW.NCOEFF
                                 ,ncoeff_val_sign  => rV_ROW.NCOEFF_VAL_SIGN
                                 ,ncoeff_calc_sign => rV_ROW.NCOEFF_CALC_SIGN
                                 ,npricemeas       => rV_ROW.NPRICEMEAS
                                 ,nsumm            => rV_ROW.NSUMM
                                 ,nsummwithnds     => rV_ROW.NSUMMWITHNDS
                                 ,nsumm_nds        => rV_ROW.NSUMM_NDS
                                 ,nautocalc_sign   => rV_ROW.NAUTOCALC_SIGN
                                 ,dbegindate       => rV_ROW.DBEGINDATE
                                 ,denddate         => rV_ROW.DENDDATE
                                 ,ssernumb         => rV_ROW.SSERNUMB
                                 ,scountry         => rV_ROW.SCOUNTRY
                                 ,sgtd             => rV_ROW.SGTD
                                 ,snote            => rV_ROW.SNOTE
                                 ,smsg             => sMSG
                                 ,nflag_del_calc   => nFLAG_DEL_CALC);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then 
      /* Считывание заголовка */
      rTransInvCust := transinvcust_get( nrn => rV_Row2.nprn );

      /* Если статус документа НЕ "Не отработан" */
      if rTransInvCust.status != 0 then

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Добавление копий заголовков */
        transinvcust_create_copy( nrn => rTransInvCust.rn, arn_list => aRN_List );

        /* Обнуление даты формирования товарного отчёта */
        update transinvcust
           set salesreportdate = null
         where rn = rTransInvCust.rn;

        /* Снятие отработки */
        p_transinvcust_bset_status( ncompany   => rTransInvCust.company
                                   ,nrn        => rTransInvCust.rn
                                   ,nstatus    => 0
                                   ,dwork_date => rTransInvCust.work_date
                                   ,nident     => nNumber );

        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

        /* Исправление спецификации */
        transinvcustspecs_update( rv_row => rV_Row2, smsg => sVarchar, nmode => 0 );

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Отработка */
        p_transinvcust_bset_status( ncompany   => rTransInvCust.company
                                   ,nrn        => rTransInvCust.rn
                                   ,nstatus    => 2
                                   ,dwork_date => rTransInvCust.work_date
                                   ,nident     => nNumber );
        /* Удаление копии */
        transinvcust_delete_copy( ncompany => rV_Row2.ncompany, arn_list => aRN_List );

        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Если статус документа "Не отработан" */
      else
         /* Исправление */
        transinvcustspecs_update( rv_row => rV_Row2, smsg => sVarchar, nmode => 0 );
      end if;    

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end TRANSINVCUSTSPECS_UPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_UPDATE
  /*
  Спецификация. Исправить. Для вызова из процедур
  */
  (
   nRN                  in number
  ,sTAXGR               in varchar2
  ,nSUMMWITHNDS         in number
  ,nGET_PRICE_FROM_FA   in number     /* Использовать цену из графика отпуска */
  ,nUPDATE_WORKED       in number     /* Исправлять отработанный документ */
  )
  is
    rV_Row          v_transinvcustspecs%rowtype;
    rTransInvCust   transinvcust%rowtype;
    rFaceAcc        faceacc%rowtype;
    rFcAcOperPlans  fcacoperplans%rowtype;
    rTrInvCustClc   trinvcustclc%rowtype;
    
    nNumber         pkg_std.tnumber; 
    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание */
    /* Текущая запись */
    begin select * into rV_Row from v_transinvcustspecs where nrn = transinvcustspecs_update.nrn; end;

    /* Заголовок */
    rTransInvCust := transinvcust_get( nrn => rV_Row.nprn );
    /* Лицевой счёт */
    rFaceAcc      := usr_pkg_faceacc.faceacc_get( nrn => rTransInvCust.faceacc );

    /* Проверка параметров */
    if sTAXGR || nSUMMWITHNDS is null and cmp_num( nGET_PRICE_FROM_FA, 0 ) = 1  then
      p_exception(0, 'Не заполнены входные параметры. %s%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rV_Row.nrn ) 
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rV_Row.nprn ) );
    elsif cmp_num( nGET_PRICE_FROM_FA, 1 ) = 1 and nSUMMWITHNDS is not null then
      p_exception(0, 'Запрещено одновременно заполнять параметры "Сумма" и "Использовать цену из графика отпуска". %s%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rV_Row.nrn ) 
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rV_Row.nprn ) );
    end if;

    /* Если Использовать цену из графика отпуска */
    if cmp_num( nGET_PRICE_FROM_FA, 1 ) = 1 then
      /* поиск единственной калькуляции в спецификации */
      trinvcustclc_get_by_prm( nflagsmart => 0, ntoo_many_rows => 0, nprn => rV_Row.nrn, rrow => rTrInvCustClc );
      /* поиск графика отпуска по точке графика калькуляции */
      usr_pkg_faceacc.fcacoperplans_get_by_params( ngraphpoint => rTrInvCustClc.graphpoint, rrow => rFcAcOperPlans );
      /* сумма с ндс, рассчитанная по цене графика отпуска */
      rV_Row.nsummwithnds := rFcAcOperPlans.summwithnds / rFcAcOperPlans.quant * rV_Row.nquant;
    /* Если задана сумма во входном параметре */
    elsif nSUMMWITHNDS is not null then
      /* сумма из параметра */
      rV_Row.nsummwithnds := nSUMMWITHNDS;
    end if;

    /* Подмена налоговой группы */
    rV_Row.staxgr := nvl( sTAXGR, rV_Row.staxgr );

    /* Пересчёт сумм */
    usr_pkg_dictaxgr.dictaxis_calc( ddate        => rTransInvCust.docdate
                                   ,ncompany     => rTransInvCust.company
                                   ,staxgr       => rV_Row.staxgr
                                   ,ninsumm      => rV_Row.nsummwithnds
                                   ,nquant       => rV_Row.nquant
                                   ,nsumm        => rV_Row.nsumm
                                   ,nsummwithnds => rV_Row.nsummwithnds
                                   ,nsumm_nds    => rV_Row.nsumm_nds   
                                   ,nprice       => nNumber );
    rV_Row.nprice := case rFaceAcc.signtax when 0 then rV_Row.nsumm else rV_Row.nsummwithnds end / rV_Row.nquant;
    rV_Row.nprice := round( rV_Row.nprice, 2 );

    /* Исправление */
    transinvcustspecs_update( rv_row => rV_Row, smsg => sVarchar, nmode => nUPDATE_WORKED );
    transinvcustspecs_aupdate( nrn => rV_Row.nrn, ncompany => rV_Row.ncompany );

  end TRANSINVCUSTSPECS_UPDATE;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BASE_INSERT
  /*
  Спецификация. Добавить базовая
  */
  (
   rROW           in transinvcustspecs%rowtype
  ,nFROM_CLIENT   in number default 0
  ,nRN            out number
  ) 
  is
  begin
    p_trninvcustspecs_base_insert(ncompany         => rROW.COMPANY
                                 ,nprn             => rROW.PRN
                                 ,ntaxgr           => rROW.TAXGR
                                 ,ngoodsparty      => rROW.GOODSPARTY
                                 ,nnommodif        => rROW.NOMMODIF
                                 ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                 ,narticle         => rROW.ARTICLE
                                 ,ncell            => rROW.CELL
                                 ,nhlcargoclass    => rROW.HLCARGOCLASS
                                 ,ntemperature     => rROW.TEMPERATURE
                                 ,nprice           => rROW.PRICE
                                 ,ndiscount        => rROW.DISCOUNT
                                 ,nquant           => rROW.QUANT
                                 ,nquantalt        => rROW.QUANTALT
                                 ,ncoeff           => rROW.COEFF
                                 ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                 ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                 ,npricemeas       => rROW.PRICEMEAS
                                 ,nsumm            => rROW.SUMM
                                 ,nsummwithnds     => rROW.SUMMWITHNDS
                                 ,nsumm_nds        => rROW.SUMM_NDS
                                 ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                 ,dbegindate       => rROW.BEGINDATE
                                 ,denddate         => rROW.ENDDATE
                                 ,snote            => rROW.NOTE
                                 ,nrn              => nRN
                                 ,nfrom_client     => nFROM_CLIENT);
  end TRANSINVCUSTSPECS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure TRANSINVCUSTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправить базовая
  */
  (
   rROW         in transinvcustspecs%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rTransInvCust     transinvcust%rowtype;
    aRN_List        udo_tp_numtable := udo_tp_numtable();
    
    nNumber   pkg_std.tnumber; 
    sVarchar  pkg_std.tstring; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_trninvcustspecs_base_update(nrn              => rROW.RN
                                   ,ncompany         => rROW.COMPANY
                                   ,ntaxgr           => rROW.TAXGR
                                   ,ngoodsparty      => rROW.GOODSPARTY
                                   ,nnommodif        => rROW.NOMMODIF
                                   ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                   ,narticle         => rROW.ARTICLE
                                   ,ncell            => rROW.CELL
                                   ,nhlcargoclass    => rROW.HLCARGOCLASS
                                   ,ntemperature     => rROW.TEMPERATURE
                                   ,nprice           => rROW.PRICE
                                   ,ndiscount        => rROW.DISCOUNT
                                   ,nquant           => rROW.QUANT
                                   ,nquantalt        => rROW.QUANTALT
                                   ,ncoeff           => rROW.COEFF
                                   ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                   ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                   ,npricemeas       => rROW.PRICEMEAS
                                   ,nsumm            => rROW.SUMM
                                   ,nsummwithnds     => rROW.SUMMWITHNDS
                                   ,nsumm_nds        => rROW.SUMM_NDS
                                   ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                   ,dbegindate       => rROW.BEGINDATE
                                   ,denddate         => rROW.ENDDATE
                                   ,snote            => rROW.NOTE);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then 

      /* Считывание заголовка */
      rTransInvCust := transinvcust_get(nrn => rROW.PRN);

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Добавление копий заголовков */
        transinvcust_create_copy( nrn => rTransInvCust.rn, arn_list => aRN_List );

        /* Обнуление даты формирования товарного отчёта */
        update transinvcust
           set salesreportdate = null
         where rn = rTransInvCust.rn;

        /* Снятие отработки */
        p_transinvcust_bset_status( ncompany   => rTransInvCust.company
                                   ,nrn        => rTransInvCust.rn
                                   ,nstatus    => 0
                                   ,dwork_date => rTransInvCust.work_date
                                   ,nident     => nNumber );
        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

        /* Исправление спецификации */
        transinvcustspecs_base_update( rrow => RROW, nmode => 0 );

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

        /* Отработка */
        p_transinvcust_bset_status( ncompany   => rTransInvCust.company
                                   ,nrn        => rTransInvCust.rn
                                   ,nstatus    => 2
                                   ,dwork_date => rTransInvCust.work_date
                                   ,nident     => nNumber );
        /* Удаление копии */
        transinvcust_delete_copy( ncompany => rROW.COMPANY, arn_list => aRN_List );

        /* Пересчёт исполнений родительских документов */
        transinvcust_recalc_perf( ncompany   => rTransInvCust.company
                                 ,nrn        => rTransInvCust.rn
                                 ,nstatus    => 2
                                 ,dwork_date => rTransInvCust.work_date );
        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end TRANSINVCUSTSPECS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure TICS_TICSC_INSERT
  /*
  Спецификация. Добавить калькуляцию
  */
  (
   rV_ROW         in v_transinvcustspecs%rowtype
  ,rV_FAOOP       in v_fcacoperplans%rowtype
  ,nTICSC         out number
  ) 
  is
    rV_TransInvCust   v_transinvcust%rowtype;
    rV_TrInvCustClc   v_trinvcustclc%rowtype;
  begin
    /* Считывание заголовка */
    select * into rV_TransInvCust from v_transinvcust where nrn = rV_ROW.NPRN;
    /* Заполнение переменных */
    rV_TrInvCustClc.ncompany     := rV_ROW.NCOMPANY;
    rV_TrInvCustClc.ncrn         := rV_ROW.NCRN;
    rV_TrInvCustClc.nprn         := rV_ROW.NRN;
    rV_TrInvCustClc.sfaceaccount := rV_TransInvCust.sfaceacc;
    rV_TrInvCustClc.sgraphpoint  := rV_FAOOP.SGRAPHPOINT;
    rV_TrInvCustClc.nquant_plan  := rV_ROW.NQUANT;  /* Количество из спецификации */
    rV_TrInvCustClc.nquant_fact  := rV_TrInvCustClc.nquant_plan;
    rV_TrInvCustClc.ncost_plan   := rV_ROW.NSUMMWITHNDS / rV_TrInvCustClc.nquant_plan;
    rV_TrInvCustClc.ncost_fact   := rV_ROW.NSUMMWITHNDS / rV_TrInvCustClc.nquant_fact;
    /* Добавление */
    trinvcustclc_insert( rv_row  => rV_TrInvCustClc, nrn => nTICSC );

  end TICS_TICSC_INSERT;
  /*#########################################################################################################*/

  procedure TICS_TICSC_BASE_INSERT  
  /*
  Спецификация. Добавить калькуляцию базовая
  */
  (
   rROW           in transinvcustspecs%rowtype
  ,rFAOOP         in fcacoperplans%rowtype
  ,nTICSC         out number
  ) 
  is
    rTransInvCust   transinvcust%rowtype;
    rTrInvCustClc   trinvcustclc%rowtype;
  begin
    /* Считывание заголовка */
    rTransInvCust := transinvcust_get( nrn => rROW.PRN );
    /* Заполнение переменных */
    rTrInvCustClc.prn         := rROW.RN;
    rTrInvCustClc.faceaccount := rTransInvCust.faceacc;
    rTrInvCustClc.graphpoint  := rFAOOP.GRAPHPOINT;
    rTrInvCustClc.quant_plan  := rROW.QUANT;  /* Количество из спецификации */
    rTrInvCustClc.quant_fact  := rTrInvCustClc.quant_plan;
    rTrInvCustClc.cost_plan   := rROW.SUMMWITHNDS / rTrInvCustClc.quant_plan;
    rTrInvCustClc.cost_fact   := rROW.SUMMWITHNDS / rTrInvCustClc.quant_fact;
    /* Добавление */
    trinvcustclc_base_insert( rrow => rTrInvCustClc, nrn => nTICSC );

  end TICS_TICSC_BASE_INSERT  ;
  /*#########################################################################################################*/

  function TRINVCUSTCLC_GET
  /*
  Строки калькуляции. Считывание записи
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return trinvcustclc%rowtype
  is
    rRow trinvcustclc%rowtype;
  begin
    begin
      select * into rRow from trinvcustclc where rn = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'TRINVCUSTCLC' );
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRINVCUSTCLC' ) ) );
    end;
    return(rRow);
  end TRINVCUSTCLC_GET;
  /*#########################################################################################################*/
  
  PROCEDURE TRINVCUSTCLC_GET_BY_PRM
  /*
  Строки калькуляции. Получение записи по параметрам
  */
  (
   nFLAGSMART         in number   default 0
  ,nFLAG_OPTION       in number   default 1 /* использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных */
  ,nTOO_MANY_ROWS     in number   default 0 /* 0 - только единственную запись, 1 - первую попавшуюся из нескольких */
  ,nPRN               in number
  ,sNUMB              in varchar2 default null
  ,nCOST_ARTICLE      in number   default null
  ,nCOST_PLACE        in number   default null
  ,nFACEACCOUNT       in number   default null
  ,nGRAPHPOINT        in number   default null
  ,nFINOPER_TYPE      in number   default null
  ,nQUANT_PLAN        in number   default null
  ,nQUANT_FACT        in number   default null
  ,nSUBDIV            in number   default null
  ,rROW               out trinvcustclc%rowtype 
  ) 
  is
  begin
    begin
      select *
        into rROW
        from trinvcustclc t
       where t.prn                        = nPRN
         and (nvl(t.numb        , 'null') = nvl(sNUMB        , 'null') or (sNUMB         is null and nFLAG_OPTION = 1))
         and (nvl(t.cost_article, -999  ) = nvl(nCOST_ARTICLE, -999  ) or (nCOST_ARTICLE is null and nFLAG_OPTION = 1))
         and (nvl(t.cost_place  , -999  ) = nvl(nCOST_PLACE  , -999  ) or (nCOST_PLACE   is null and nFLAG_OPTION = 1))
         and (nvl(t.faceaccount , -999  ) = nvl(nFACEACCOUNT , -999  ) or (nFACEACCOUNT  is null and nFLAG_OPTION = 1))
         and (nvl(t.graphpoint  , -999  ) = nvl(nGRAPHPOINT  , -999  ) or (nGRAPHPOINT   is null and nFLAG_OPTION = 1))
         and (nvl(t.finoper_type, -999  ) = nvl(nFINOPER_TYPE, -999  ) or (nFINOPER_TYPE is null and nFLAG_OPTION = 1))
         and (nvl(t.quant_plan  , -999  ) = nvl(nQUANT_PLAN  , -999  ) or (nQUANT_PLAN   is null and nFLAG_OPTION = 1))
         and (nvl(t.quant_fact  , -999  ) = nvl(nQUANT_FACT  , -999  ) or (nQUANT_FACT   is null and nFLAG_OPTION = 1))
         and (nvl(t.subdiv      , -999  ) = nvl(nSUBDIV      , -999  ) or (nSUBDIV       is null and nFLAG_OPTION = 1))
         ;
    exception
      when no_data_found then
          p_exception(nFLAGSMART, 'Не найдена калькуляция для спецификации с RN <%s> в разделе <%s>'
                     ,nPRN, f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRINVCUSTCLC' ) ) );
      when too_many_rows then
        p_exception( sign( nTOO_MANY_ROWS + nFLAGSMART ),'Найдено больше одной калькуляция для спецификации с RN <%s> в разделе <%s>'
                   ,nPRN, f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRINVCUSTCLC' ) ) );
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске калькуляция для спецификации с RN <%s> записи в разделе <%s>'
                   ,nPRN, f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRINVCUSTCLC' ) ) );
    end;
    
  end TRINVCUSTCLC_GET_BY_PRM;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_AINSERT
  /*
  Строки калькуляции. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                trinvcustclc%rowtype;
    rTransInvCustSpecs  transinvcustspecs%rowtype;
    rTransInvCust       transinvcust%rowtype;
    rFcAcOperPlans      fcacoperplans%rowtype;
  begin
    /* Считывание */
    rRow                := trinvcustclc_get( nrn => NRN );
    rTransInvCustSpecs  := transinvcustspecs_get( nrn => rRow.prn );
    /* Связанный график отпуска */
    usr_pkg_faceacc.fcacoperplans_get_by_params( nflagsmart     => 1
                                                ,ntoo_many_rows => 0
                                                ,ngraphpoint    => rRow.graphpoint
                                                ,rrow           => rFcAcOperPlans );
    /* ИСПРАВЛЕНИЯ */
    /* Пересчёт графика отпуска */
    usr_pkg_faceacc.fcacoperoutplans_recalc( nrn => rFcAcOperPlans.rn );

    /* ПРОВЕРКИ */
    /* Проверка базовая */
    trinvcustclc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end TRINVCUSTCLC_AINSERT;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BUPDATE
  /*
  Строки калькуляции. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow                trinvcustclc%rowtype;
  begin
    /* Считывание */
    rRow := trinvcustclc_get( nrn => NRN );
    /* Запрет */
    p_exception(0, 'Запрещено исправление калькуляций. Используйте удаление и повторное добавление. %s%s%s'
             ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
             ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rRow.prn ) ); 
  end TRINVCUSTCLC_BUPDATE;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_AUPDATE
  /*
  Строки калькуляции. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    trinvcustclc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end TRINVCUSTCLC_AUPDATE;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BDELETE
  /*
  Строки калькуляции. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    usr_pkg_pub_const.rtrinvcustclc := trinvcustclc_get( nrn => nRN );
  end TRINVCUSTCLC_BDELETE;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_ADELETE
  /*
  Строки калькуляции. Проверка после удаления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                trinvcustclc%rowtype;
    rTransInvCustSpecs  transinvcustspecs%rowtype;
    rTransInvCust       transinvcust%rowtype;
    rFcAcOperPlans      fcacoperplans%rowtype;
  begin
    /* Считывание */
    rRow                := usr_pkg_pub_const.rtrinvcustclc;
    rTransInvCustSpecs  := transinvcustspecs_get( nrn => rRow.prn );
    rTransInvCust       := transinvcust_get( nrn => rTransInvCustSpecs.prn );
    /* Связанный график отпуска */
    usr_pkg_faceacc.fcacoperplans_get_by_params( nflagsmart     => 1
                                                ,ntoo_many_rows => 0
                                                ,ngraphpoint    => rRow.graphpoint
                                                ,rrow           => rFcAcOperPlans );
    /* ИСПРАВЛЕНИЯ */
    /* Пересчёт графика отпуска */
    usr_pkg_faceacc.fcacoperoutplans_recalc( nrn => rFcAcOperPlans.rn );

  end TRINVCUSTCLC_ADELETE;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_CHECK_BASE
  /*
  Строки калькуляции. Проверка базовая
  Спецификация может иметь только одну калькуляцию, в которой такое же количество и цена.
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                trinvcustclc%rowtype;
    rFcAcGraphPoints    fcacgraphpoints%rowtype;
    rFcAcOperOutPlans   fcacoperplans%rowtype;
    rTransInvCustSpecs  transinvcustspecs%rowtype;
    rTransInvCust       transinvcust%rowtype;
    nTICSC_Quant_Tot    pkg_std.tquant;  
    nDicNomns           pkg_std.tref; 

    nCount              pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow                := trinvcustclc_get( nrn => NRN );
    rTransInvCustSpecs  := transinvcustspecs_get( nrn => rRow.prn );
    rTransInvCust       := transinvcust_get( nrn => rTransInvCustSpecs.prn );
    rFcAcGraphPoints    := usr_pkg_faceacc.fcacgraphpoints_get( nrn => rRow.graphpoint );
    usr_pkg_faceacc.fcacoperplans_get_by_params( nflagsmart     => 1
                                                ,ntoo_many_rows => 0
                                                ,ngraphpoint    => rRow.graphpoint
                                                ,rrow           => rFcAcOperOutPlans );
    nDicNomns           := usr_pkg_dicnomns.nommodif_get_prn_by_rn( nflagsmart => 0, nrn => rTransInvCustSpecs.nommodif );
    /* Количество, сумма, количетсво строк в калькуляциях спецификации */
    select nvl( sum( quant_plan ), 0 )
          ,count(*)
      into nTICSC_Quant_Tot
          ,nCount
      from trinvcustclc 
     where prn = rTransInvCustSpecs.rn;

    /* ПРОВЕРКИ */
    /* Больше одной калькуляции для спецификации */
    /*if nCount > 1 then
      p_exception(0, 'Спецификация имеет <%s> калькуляции. %s%s'
                 ,nCount
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCustSpecs.prn ) ); 
    end if;*/
    /* Количество в калькуяляциях не равно спецификации */
    if nTICSC_Quant_Tot != rTransInvCustSpecs.quant then
      p_exception(0, 'Количество в калькуляциях <%s> не равно количеству в спецификации <%s>. %s%s'
                 ,nTICSC_Quant_Tot
                 ,rTransInvCustSpecs.quant
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCustSpecs.prn ) ); 
    end if;

    /* Количество по плану не равно фактически */
    if cmp_num( rRow.quant_plan, rRow.quant_fact ) != 1 then
      p_exception(0, '"Количество. План" <%s> не равно "Количество. Факт" <%s>. %s%s%s'
               ,rRow.quant_plan
               ,rRow.quant_fact
               ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
               ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
               ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;
    /* Цена по плану не равна фактически */
    if cmp_num( rRow.cost_plan, rRow.cost_fact ) != 1 then
      p_exception(0, '"Затраты на единицу. План" <%s> не равно "Затраты на единицу. Факт" <%s>. %s%s%s'
                 ,rRow.cost_plan
                 ,rRow.cost_fact
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;
    /* Цена по плану не равна цене в спецификации */
    if cmp_num( round( rRow.cost_plan, 2), round( rTransInvCustSpecs.summwithnds / rTransInvCustSpecs.quant, 2) ) != 1 then
      p_exception(0, '"Затраты на единицу. План" <%s> не равно цене с НДС в спецификации <%s>. %s%s%s'
                 ,round( rRow.cost_plan, 2)
                 ,round( rTransInvCustSpecs.summwithnds / rTransInvCustSpecs.quant, 2)
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;
    /* Лицевой счёт заголовка не равен лицевому счёту точки графика */
    if cmp_num( rRow.faceaccount, rFcAcGraphPoints.prn ) != 1 then
      p_exception(0, 'Лицевой счёт документа <%s> не равен лицевому счёту точки графика калькуляции <%s>. %s%s%s'
                 ,get_faceacc_numb_id( nflag_smart => 1, nrn => rTransInvCust.faceacc)
                 ,nvl( get_faceacc_numb_id( nflag_smart => 1, nrn => rFcAcGraphPoints.prn ), 'Не задан' )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;
    /* Номенклатура спецификации не равна номенклатуре графика отпуска */
    if cmp_num( nDicNomns, rFcAcOperOutPlans.nomen ) != 1 then
      p_exception(0, 'Номенклатура спецификации <%s> не равна номенклатуре графика отпуска <%s>. %s%s%s'
                 ,get_dicnomns_code_id( nflag_smart => 1, nrn => nDicNomns )
                 ,get_dicnomns_code_id( nflag_smart => 1, nrn => rFcAcOperOutPlans.nomen )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;
    /* Модификация спецификации не равна модификации графика отпуска */
    if cmp_num( rTransInvCustSpecs.nommodif, rFcAcOperOutPlans.nommodif ) != 1 then
      p_exception(0, 'Модификация спецификации <%s> не равна модификации графика отпуска <%s>. %s%s%s'
                 ,usr_pkg_dicnomns.nommodif_get_code_by_rn( nflagsmart => 1, nrn => rTransInvCustSpecs.nommodif )
                 ,usr_pkg_dicnomns.nommodif_get_code_by_rn( nflagsmart => 1, nrn => rFcAcOperOutPlans.nommodif )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;
    /* Налоговая группа спецификации не равна налоговой группе графика отпуска */

/*From: Степанов Михаил Владимирович <m.stepanov@module.ru> 
Sent: Wednesday, February 25, 2026 2:07 PM
To: 'Ольга' <o.chikunova@module.ru>
Cc: Алексей Вячеславович Хохряков (a.khokhryakov@module.ru) <a.khokhryakov@module.ru>; Анна Борисовна Куроедова (a.kuroedova@module.ru) <a.kuroedova@module.ru>; Виталий Алексеевич Фанов (v.fanov@module.ru) <v.fanov@module.ru>
Subject: RE: привязка накладных.

Ольга, я исправил процедуру, которая накручивала НДС, проверьте, пожалуйста.
Также пор вашей просьбе отключил проверку соответствия налоговой группы в накладной и графике отпуска. Предупреждаю, что в результате суммы исполнения этапа договора и суммы самого этапа не будут соответствовать. В частности сумма без НДС и сумма НДС. В этой части исполнение договора будет не корректным.


    if cmp_num( rTransInvCustSpecs.taxgr, rFcAcOperOutPlans.taxgr ) != 1 then
      p_exception(0, 'Налоговая группа спецификации <%s> не равна налоговой группе графика отпуска <%s>. %s%s%s'
                 ,usr_pkg_dictaxgr.dictaxgr_get_code( nrn => rTransInvCustSpecs.taxgr, ncompany => rTransInvCustSpecs.company, nflagsmart => 1 )
                 ,usr_pkg_dictaxgr.dictaxgr_get_code( nrn => rFcAcOperOutPlans.taxgr , ncompany => rFcAcOperOutPlans.company , nflagsmart => 1 )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;*/
    /* Цена с НДС в спецификации не равна цене графика отпуска */
    /*if cmp_num( round( rTransInvCustSpecs.summwithnds / rTransInvCustSpecs.quant, 2 ) 
              , round( rFcAcOperOutPlans.summwithnds / rFcAcOperOutPlans.quant  , 2 ) ) != 1 then
      p_exception(0, 'Цена с НДС в спецификации <%s> не равна цене с НДС в графике отпуска <%s>. %s%s%s'
                 ,round( rTransInvCustSpecs.summwithnds / rTransInvCustSpecs.quant, 2 )
                 ,round( rFcAcOperOutPlans.summwithnds / rFcAcOperOutPlans.quant  , 2 )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersCalcs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumersSpecs', ndocument => rTransInvCustSpecs.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers'     , ndocument => rTransInvCust.rn ) ); 
    end if;*/

  end TRINVCUSTCLC_CHECK_BASE;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_INSERT
  /*
  Строки калькуляции. Добавить
  */
  (
   rV_ROW       in v_trinvcustclc%rowtype
  ,nRN          out number
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    /*rV_Row2 v_trinvcustclc%rowtype := rV_ROW;
    rTics   transinvcustspecs%rowtype;*/
    /*rTic    transinvcust%rowtype;*/
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_trinvcustclc_insert(ncompany      => rV_ROW.NCOMPANY
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
                           ,nrn           => nRN);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then 
      \* Считывание  *\
      rTics := transinvcustspecs_get( nrn => rV_Row2.nprn );
      \*rTic  := transinvcust_get( nrn => rTics.prn );*\
      \* Подменяем значения *\
      rV_Row2.nprn         := rTics.rn;
      rV_Row2.ncompany     := rTics.company;
      rV_Row2.ncrn         := rTics.crn;
      \*rV_Row2.sfaceaccount := get_faceacc_numb_id( nflag_smart => 0, nrn => rTic.faceacc );*\

      \* Добавление штатное *\
      trinvcustclc_insert( rv_row => rV_Row2, nrn => nRN, nmode => 0 );*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end TRINVCUSTCLC_INSERT;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_UPDATE
  /*
  Строки калькуляции. Исправить
  */
  (
   rV_ROW           in v_trinvcustclc%rowtype
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_trinvcustclc_update( nrn           => rV_ROW.NRN
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
                            ,ssubdiv       => rV_ROW.SSUBDIV );
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then */
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end TRINVCUSTCLC_UPDATE;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BASE_INSERT
  /*
  Строки калькуляции. Добавить базовая
  */
  (
   rROW           in trinvcustclc%rowtype
  ,nRN            out number
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    /*rRow2   trinvcustclc%rowtype := rROW;
    rTics   transinvcustspecs%rowtype;*/
    /*rTic    transinvcust%rowtype;*/
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_trinvcustclc_base_insert( ncompany      => rROW.COMPANY
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
                                 ,nrn           => nRN );
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then 
      \* Считывание  *\
      rTics := transinvcustspecs_get( nrn => rRow2.prn );
      \*rTic  := transinvcust_get( nrn => rTics.prn );*\
      \* Подменяем значения *\
      rRow2.prn         := rTics.rn;
      rRow2.company     := rTics.company;
      rRow2.crn         := rTics.crn;
      \*rRow2.faceaccount := rTic.faceacc;*\

      \* Добавление штатное *\
      trinvcustclc_base_insert( rrow => rRow2, nrn => nRN, nmode => 0 );*/
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end TRINVCUSTCLC_BASE_INSERT;
  /*#########################################################################################################*/

  procedure TRINVCUSTCLC_BASE_UPDATE
  /*
  Строки калькуляции. Исправить базовая
  */
  (
   rROW         in trinvcustclc%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_trinvcustclc_base_update( nrn           => rROW.RN
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
                                 ,nsubdiv       => rROW.SUBDIV );
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then */
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end TRINVCUSTCLC_BASE_UPDATE;
  /*#########################################################################################################*/

end USR_PKG_TRANSINVCUST;
/
