create or replace package USR_PKG_STRPLRESJRNL as
  -- Степанов М. 01/12/2020
  /*
  'StoragePlacesResJournal'   STRPLRESJRNL  SPJ 
  */

  /*#########################################################################################################*/

  function STRPLRESJRNL_GET
  /*
  Лицевой счёт. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return strplresjrnl%rowtype ;
  /* ######################################################################################################### */

  procedure STRPLRESJRNL_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN      in number
  ,nCOMPANY in number
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_INSERT
  /*
  Заголовок. Добавление клиентское
  */
  (
   rV_ROW           in v_strplresjrnl%rowtype
  ,sMASTERUNITCODE  in varchar2
  ,sSLAVEUNITCODE   in varchar2
  ,nMASTERRN        in number
  ,nSLAVERN         in number
  ,nRN              out number
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_UPDATE
  /*
  Заголовок. Исправление клиентское
  */
  (
   rV_ROW           in v_strplresjrnl%rowtype
  ,sSLAVEUNITCODE   in varchar2
  ,nSLAVERN         in number
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW             in strplresjrnl%rowtype
  ,sMASTERUNITCODE  in varchar2
  ,sSLAVEUNITCODE   in varchar2
  ,nMASTERRN        in number
  ,nSLAVERN         in number
  ,nCHECK_PARTY     in number default 0     /* признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено) */
  ,nLINK_TYPE       in number default null  /* тип связи с журналом ( = null - резервирование ручное, <> null - резервирование автоматическое) */
  ,nFLAG_SMART      in number default 0
  ,nRN              out number
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in strplresjrnl%rowtype
  ,nCHECK_PARTY     in number default 0     /* признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено) */
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*########################################################################################################*/

  procedure STRPLRESJRNL_COPY
  /*
  Процедура копирования резервирования по местам хранения из спецификации документа в другую спецификацию
  Чтобы копировались из "приход" (места для распределения), надо, чтобы документ-источник был отработан
  */
  (
   nFLAGSMART           in number default 0
  ,nRN_FROM             in number               /* Документ-источник. Спецификация . RN */
  ,nRES_TYPE_FROM       in number default 1     /* Документ-источник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,nRN_TO               in number               /* Документ-приёмник. Спецификация. RN */
  ,nPRN_TO              in number               /* Документ-приёмник. Заголовок. RN */
  ,nRES_TYPE_TO         in number default 0     /* Документ-приёмник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,sMASTERUNITCODE_TO   in varchar2             /* Документ-приёмник. Заголовок. Код раздела  */
  ,sSLAVEUNITCODE_TO    in varchar2             /* Документ-приёмник. Спецификация. Код раздела  */
  ,sDOCTYPE             in varchar2             /* Документ-приёмник. Заголовок. Тип */
  ,sDOCPREF             in varchar2             /* Документ-приёмник. Заголовок. Префикс */
  ,sDOCNUMB             in varchar2             /* Документ-приёмник. Заголовок. Номер */
  ,dDOCDATE             in date                 /* Документ-приёмник. Заголовок. Дата */
  ,dRESERVING_DATE      in date default null    /* Документ-приёмник. Дата резервирования */
  );
  /*#########################################################################################################*/

end USR_PKG_STRPLRESJRNL;
/
create or replace package body USR_PKG_STRPLRESJRNL as

  /*#########################################################################################################*/

  function STRPLRESJRNL_GET
  /*
  Лицевой счёт. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return strplresjrnl%rowtype 
  is
    rRow strplresjrnl%rowtype;
  begin
    begin
      select t.* into rRow from strplresjrnl t where t.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nrn, sunit_table => 'STRPLRESJRNL' );
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STRPLRESJRNL'))
                   ,cr||sqlerrm);
    end;
    return(rrow);
  end STRPLRESJRNL_GET;
  /* ######################################################################################################### */

  procedure STRPLRESJRNL_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    /* Считывание */
    /*rrow := strplresjrnl_get(nrn => nrn);*/
  
    /* ИСПРАВЛЕНИЯ */
  
    /* ПРОВЕРКИ */
    /* Базовая */
    strplresjrnl_check_base(nrn => nRN, ncompany => nCOMPANY);
  
  end STRPLRESJRNL_AINSERT;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    null;
  end STRPLRESJRNL_BUPDATE;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    /* Проверка базовая */
    strplresjrnl_check_base(nrn, ncompany);

  end STRPLRESJRNL_AUPDATE;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ) 
  is
  begin
    null;
    /* Считывание */

  end STRPLRESJRNL_BDELETE;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
    rRow      strplresjrnl%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := strplresjrnl_get(nrn => nrn);*/
  
    /* ПРОВЕРКИ */
  
  end STRPLRESJRNL_CHECK_BASE;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_INSERT
  /*
  Заголовок. Добавление клиентское
  */
  (
   rV_ROW           in v_strplresjrnl%rowtype
  ,sMASTERUNITCODE  in varchar2
  ,sSLAVEUNITCODE   in varchar2
  ,nMASTERRN        in number
  ,nSLAVERN         in number
  ,nRN              out number
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_strplresjrnl_insert(ncompany        => rV_Row.ncompany
                           ,smasterunitcode => sMASTERUNITCODE
                           ,sslaveunitcode  => sSLAVEUNITCODE
                           ,nmasterrn       => nMASTERRN
                           ,nslavern        => nSLAVERN
                           ,sstore          => rV_Row.sstore
                           ,srack_pref      => rV_Row.srack_pref
                           ,srack_numb      => rV_Row.srack_numb
                           ,scell_pref      => rV_Row.scell_pref
                           ,scell_numb      => rV_Row.scell_numb
                           ,ngoodssupply    => rV_Row.ngoodssupply
                           ,nres_type       => rV_Row.nres_type
                           ,snomen          => rV_Row.snomen
                           ,snommodif       => rV_Row.snommodif
                           ,snomnmodifpack  => rV_Row.snomnmodifpack
                           ,nnommodif       => rV_Row.nnommodif
                           ,nnomnmodifpack  => rV_Row.nnomnmodifpack
                           ,sarticle        => rV_Row.sarticle
                           ,narticle        => rV_Row.narticle
                           ,sgoodsunit      => rV_Row.sgoodsunit
                           ,sdoctype        => rV_Row.sdoctype
                           ,ddocdate        => rV_Row.ddocdate
                           ,sdocnumb        => rV_Row.sdocnumb
                           ,sdocpref        => rV_Row.sdocpref
                           ,dreserving_date => rV_Row.dreserving_date
                           ,dfree_date      => rV_Row.dfree_date
                           ,nquant          => rV_Row.nquant
                           ,nquantalt       => rV_Row.nquantalt
                           ,nquantpack      => rV_Row.nquantpack
                           ,nrn             => nRN);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end STRPLRESJRNL_INSERT;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_UPDATE
  /*
  Заголовок. Исправление клиентское
  */
  (
   rV_ROW           in v_strplresjrnl%rowtype
  ,sSLAVEUNITCODE   in varchar2
  ,nSLAVERN         in number
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_strplresjrnl_update(nrn             => rV_Row.nrn
                           ,ncompany        => rV_Row.ncompany
                           ,sslaveunitcode  => sSLAVEUNITCODE
                           ,nslavern        => nSLAVERN
                           ,sstore          => rV_Row.sstore
                           ,srack_pref      => rV_Row.srack_pref
                           ,srack_numb      => rV_Row.srack_numb
                           ,scell_pref      => rV_Row.scell_pref
                           ,scell_numb      => rV_Row.scell_numb
                           ,ngoodssupply    => rV_Row.ngoodssupply
                           ,nres_type       => rV_Row.nres_type
                           ,snomen          => rV_Row.snomen
                           ,snommodif       => rV_Row.snommodif
                           ,snomnmodifpack  => rV_Row.snomnmodifpack
                           ,nnommodif       => rV_Row.nnommodif
                           ,nnomnmodifpack  => rV_Row.nnomnmodifpack
                           ,sarticle        => rV_Row.sarticle
                           ,narticle        => rV_Row.narticle
                           ,sgoodsunit      => rV_Row.sgoodsunit
                           ,dreserving_date => rV_Row.dreserving_date
                           ,dfree_date      => rV_Row.dfree_date
                           ,nquant          => rV_Row.nquant
                           ,nquantalt       => rV_Row.nquantalt
                           ,nquantpack      => rV_Row.nquantpack);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end STRPLRESJRNL_UPDATE;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW             in strplresjrnl%rowtype
  ,sMASTERUNITCODE  in varchar2
  ,sSLAVEUNITCODE   in varchar2
  ,nMASTERRN        in number
  ,nSLAVERN         in number
  ,nCHECK_PARTY     in number default 0     /* признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено) */
  ,nLINK_TYPE       in number default null  /* тип связи с журналом ( = null - резервирование ручное, <> null - резервирование автоматическое) */
  ,nFLAG_SMART      in number default 0
  ,nRN              out number
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_strplresjrnl_base_insert(ncompany        => rROW.COMPANY
                                ,sauthid         => rROW.AUTHID
                                ,smasterunitcode => sMASTERUNITCODE
                                ,sslaveunitcode  => sSLAVEUNITCODE
                                ,nmasterrn       => nMASTERRN
                                ,nslavern        => nSLAVERN
                                ,nrack           => rROW.RACK
                                ,ncell           => rROW.CELL
                                ,ngoodssupply    => rROW.GOODSSUPPLY
                                ,nres_type       => rROW.RES_TYPE
                                ,nnommodif       => rROW.NOMMODIF
                                ,nnomnmodifpack  => rROW.NOMNMODIFPACK
                                ,narticle        => rROW.ARTICLE
                                ,ngoodsunit      => rROW.GOODSUNIT
                                ,ndoctype        => rROW.DOCTYPE
                                ,ddocdate        => rROW.DOCDATE
                                ,sdocnumb        => rROW.DOCNUMB
                                ,sdocpref        => rROW.DOCPREF
                                ,dreserving_date => rROW.RESERVING_DATE
                                ,dfree_date      => rROW.FREE_DATE
                                ,nquant          => rROW.QUANT
                                ,nquantalt       => rROW.QUANTALT
                                ,nquantpack      => rROW.QUANTPACK
                                ,ncheck_party    => nCHECK_PARTY
                                ,nrn             => nRN
                                ,nlink_type      => nLINK_TYPE
                                ,nflag_smart     => nFLAG_SMART);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end STRPLRESJRNL_BASE_INSERT;
  /*#########################################################################################################*/

  procedure STRPLRESJRNL_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in strplresjrnl%rowtype
  ,nCHECK_PARTY     in number default 0     /* признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено) */
  ,nMODE            in number default 0     /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_strplresjrnl_base_update(ncompany        => rROW.COMPANY
                                ,nrn             => rROW.RN
                                ,sauthid         => rROW.AUTHID
                                ,ncell           => rROW.CELL
                                ,ngoodssupply    => rROW.GOODSSUPPLY
                                ,nnommodif       => rROW.NOMMODIF
                                ,nnomnmodifpack  => rROW.NOMNMODIFPACK
                                ,narticle        => rROW.ARTICLE
                                ,ngoodsunit      => rROW.GOODSUNIT
                                ,dreserving_date => rROW.RESERVING_DATE
                                ,nquant          => rROW.QUANT
                                ,nquantalt       => rROW.QUANTALT
                                ,ncheck_party    => nCHECK_PARTY);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end STRPLRESJRNL_BASE_UPDATE;
  /*########################################################################################################*/

  procedure STRPLRESJRNL_COPY
  /*
  Процедура копирования резервирования по местам хранения из спецификации документа в другую спецификацию
  Чтобы копировались из "приход" (места для распределения), надо, чтобы документ-источник был отработан
  */
  (
   nFLAGSMART           in number default 0
  ,nRN_FROM             in number               /* Документ-источник. Спецификация . RN */
  ,nRES_TYPE_FROM       in number default 1     /* Документ-источник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,nRN_TO               in number               /* Документ-приёмник. Спецификация. RN */
  ,nPRN_TO              in number               /* Документ-приёмник. Заголовок. RN */
  ,nRES_TYPE_TO         in number default 0     /* Документ-приёмник. Тип резервирования (0 - приход (для распределения), 1 - расход (для списания)) */
  ,sMASTERUNITCODE_TO   in varchar2             /* Документ-приёмник. Заголовок. Код раздела  */
  ,sSLAVEUNITCODE_TO    in varchar2             /* Документ-приёмник. Спецификация. Код раздела  */
  ,sDOCTYPE             in varchar2             /* Документ-приёмник. Заголовок. Тип */
  ,sDOCPREF             in varchar2             /* Документ-приёмник. Заголовок. Префикс */
  ,sDOCNUMB             in varchar2             /* Документ-приёмник. Заголовок. Номер */
  ,dDOCDATE             in date                 /* Документ-приёмник. Заголовок. Дата */
  ,dRESERVING_DATE      in date default null    /* Документ-приёмник. Дата резервирования */
  )
  as
    rV_StrPlResJrnl     v_strplresjrnl%rowtype;
    nCount              pkg_std.tnumber := 0;  
    nNumber             pkg_std.tnumber;  
  begin
    /* По журналу резервирования по местам хранения спецификации-источника с заданным типом резервирования */
    for c in ( select t.* 
                 from v_strplresjrnl  t
                 join doclinks        dl on dl.out_document = t.nrn
                                        and dl.in_document  = nRN_FROM
                where t.nres_type = nRES_TYPE_FROM )
    loop
      /* Счётчик записей */
      nCount := nCount + 1;
      /* Сохранение в переменную */
      rV_StrPlResJrnl := c;
      /* Подмена значений в переменной */
      rV_StrPlResJrnl.ngoodssupply    := case nRES_TYPE_TO when 1 then rV_StrPlResJrnl.ngoodssupply else null end;
      rV_StrPlResJrnl.nres_type       := nRES_TYPE_TO;
      rV_StrPlResJrnl.sdoctype        := sDOCTYPE;
      rV_StrPlResJrnl.sdocpref        := sDOCPREF;
      rV_StrPlResJrnl.sdocnumb        := sDOCNUMB;
      rV_StrPlResJrnl.ddocdate        := dDOCDATE;
      rV_StrPlResJrnl.dreserving_date := nvl( dRESERVING_DATE, rV_StrPlResJrnl.dreserving_date );
      rV_StrPlResJrnl.dfree_date      := null;
      /* Добавление резервирования по месту хранения */
      begin 
        usr_pkg_strplresjrnl.strplresjrnl_insert(rv_row          => rV_StrPlResJrnl
                                                ,smasterunitcode => sMASTERUNITCODE_TO
                                                ,sslaveunitcode  => sSLAVEUNITCODE_TO
                                                ,nmasterrn       => nPRN_TO
                                                ,nslavern        => nRN_TO
                                                ,nrn             => nNumber );
      exception when others then
        p_exception(nFLAGSMART, '%s Склад %s, Номенклатура "%s", модификация "%s", серия "%s", количество"%s", стеллаж/ячейка "%s", дата/время резервирования %s. %s%'
                   ,sqlerrm||cr
                   ,rV_StrPlResJrnl.sstore
                   ,rV_StrPlResJrnl.snomen
                   ,rV_StrPlResJrnl.snommodif
                   ,rV_StrPlResJrnl.ssernumb 
                   ,usr_f_n2sq(rV_StrPlResJrnl.nquant)
                   ,trim(rV_StrPlResJrnl.scell_pref ) ||'-'|| trim( rV_StrPlResJrnl.scell_numb )
                   ,dts2s( rV_StrPlResJrnl.dreserving_date )
                   , cr||cr||f_docdescrs_get_description( sunitcode => sSLAVEUNITCODE_TO , ndocument => nRN_TO )
                   ||cr||cr||f_docdescrs_get_description( sunitcode => sMASTERUNITCODE_TO, ndocument => nPRN_TO )
                   ||cr||cr||dbms_utility.format_call_stack ); 
      end;
    end loop;
    
    /* Если не найдены записи резервирования */
    if nCount = 0 then
      p_exception( nFLAGSMART, 'Не найдены записи резервирования по местам хранения для спецификации %s.', nRN_FROM );
    end if; 

  end STRPLRESJRNL_COPY;
  /*#########################################################################################################*/

end USR_PKG_STRPLRESJRNL;
/
