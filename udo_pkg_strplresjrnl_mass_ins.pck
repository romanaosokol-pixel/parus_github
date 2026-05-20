create or replace package UDO_PKG_STRPLRESJRNL_MASS_INS
is

  /* Таблица параметров */
  type TRECPARAM is record
  (
    sMASTERUNITCODE PKG_STD.tSTRING,   -- код master-раздела
    sSLAVEUNITCODE  PKG_STD.tSTRING,   -- код slave-раздела
    nMASTERRN       PKG_STD.tREF,      -- регистрационный номер master-записи
    nSLAVERN        PKG_STD.tREF,      -- регистрационный номер slave-записи  );
    --nCELL           PKG_STD.tNUMBER, -- место хранения (резервуар)
    nGOODSSUPPLY    PKG_STD.tREF,      -- товарный запас
    nNOMMODIF       PKG_STD.tREF,      -- модификация
    nARTICLE        PKG_STD.tREF,      -- Артикул
    nDOCTYPE        PKG_STD.tREF,      -- тип документа
    dDOCDATE        PKG_STD.tLDATE,    -- дата документа
    sDOCNUMB        PKG_STD.tSTRING,   -- номер документа
    sDOCPREF        PKG_STD.tSTRING,   -- префикс номера документа
    dRESERVING_DATE PKG_STD.tLDATE,    -- дата и время резервирования.
    nQUANT          PKG_STD.tQUANT,    -- количество в основной ЕИ
    nQUANTALT       PKG_STD.tQUANT,    -- количество в дополнительной ЕИ
    nQUANTPACK      PKG_STD.tQUANT     -- не используется (рассчитывается из ОЕИ)
  );
  
  /* Коллекция параметров */
  type TRECPARAMS is table of TRECPARAM index by PLS_INTEGER;
 
  /* Точка входа */
  Procedure SATRT
  (
    nCOMPANY         in number,           -- Рег номер организации
    sUNITCODE        in varchar2,         -- Код раздела 
    NIDENT           in number,           -- Идент выделенных записей
    sSTORE           in varchar2,         -- склад
    SCELL            in varchar2,         -- место хранения (резервуар)
    nRES_TYPE        in number default 0, -- тип резервирования (0 - приход, 1 - расход)
    nCHECK_PARTY     in number default 0, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
    NREPLACE         in number default 0,  -- Распределение с заменой найденных записей (0 - нет, 1 - да) 
    dRESERVINGDATE   in date,              -- дата и время резервирования.
    nRETURN          in number default 0, -- признак возвратной накладной (0 - нет, 1 - да)
    nOUTNOTE         out number
 ); 

  /* Пользовательская форма для Приходного ордера */
  procedure INORDERS_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада   
    SCELL            in out varchar2,      -- Мнемокод ячейки
    SCELL_ND         in out number         -- Доступность ячейки
  );
  
  /* Пользовательская форма для Расходной накладной в подразделение */
  procedure TRANSINVDEPT_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада  
    SCELL            in out varchar2,   -- Мнемокод ячейки
    SCELL_ND         in out number,     -- Доступность ячейки
    SCELL_NN         in out number,     -- Обязательность ячейки
    nRETURN          in out number,     -- признак возвратной накладной
    nRETURN_ND       in out number,     -- Доступность признак возвратной накладной
    nRES_TYPE_ND     in out number,     -- Доступность тип резервирования (0 - приход, 1 - расход)
    nREPLACE         in out number,     -- с заменой
    nREPLACE_ND      in out number,     -- Доступность с заменой
    nRES_TYPE        in out number      -- тип резервирования (0 - приход, 1 - расход)
  );
  
    procedure INCOMEFROMDEPS_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада  
    SCELL            in out varchar2,      -- Мнемокод ячейки
    SCELL_ND         in out number      -- Доступность ячейки
  );
  
  /* Пересчет на форме Расхода потребителям */
  procedure TRANSINVCUST_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада  
    SCELL            in out varchar2,   -- Мнемокод ячейки
    SCELL_ND         in out number,     -- Доступность ячейки
    SCELL_NN         in out number,     -- Обязательность ячейки 
    nRES_TYPE        in out number      -- тип резервирования (0 - приход, 1 - расход)
  );
  
  function FIND_STRPLRESJRNL_COUNTREC
  (
    NREPLACE             in number default 0,   -- Распределение с заменой найденных записей (0 - нет, 1 - да) 
    nRES_TYPE            in number,
    nCELL                in number,   -- место хранения (резервуар)
    nGOODSSUPPLY         in number,   -- товарный запас
    nNOMMODIF            in number,   -- модификация.
    NARTICLE             in number,   --
    nDOCTYPE             in number,   -- тип документа
    dDOCDATE             in date,     -- дата документа
    sDOCNUMB             in varchar2, -- номер документа
    sDOCPREF             in varchar2, -- префикс номера документ
    nSLAVERN             in number,
    sUNITCODE            in varchar2  -- Код раздела 
  ) return               number;

  /* Пользовательская форма для Акты списания недостач/оприходования излишков */
  procedure WROFFACTS_PRMS_FE
  (
    nCOMPANY     in number, -- Рег. номер организации
    nRN          in number, -- рег номер родителя
    sATRIB       in varchar2, -- Изменение атрибута
    nFIRST       in out number, -- признак первого запуска
    sSTORE       out varchar2, -- Мнемокод Склада
    sSTORE_ND    in out number, -- Доступность Склада  
    sCELL        in out varchar2, -- Мнемокод ячейки
    sCELL_ND     in out number, -- Доступность ячейки
    sCELL_NN     in out number, -- Обязательность ячейки
    nREPLACE     in out number, -- с заменой
    nREPLACE_ND  in out number, -- Доступность с заменой
    dRES_DATE    out date, -- дата резервирования
    sRES_TYPE    in out varchar2 -- Тип резервирования (Приход, Расход)
  );

end UDO_PKG_STRPLRESJRNL_MASS_INS;
/
create or replace package body UDO_PKG_STRPLRESJRNL_MASS_INS
/* 
24/04/2025 Степанов М. Чтобы дата резервирования для списания использовалась из параметра 
24/04/2025 Степанов М. или выполняется пользовательская процедура
*/
is
  /* Поиск записи распределения по местам зранения */
  function FIND_STRPLRESJRNL_COUNTREC
  (
    NREPLACE     in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да) 
    nRES_TYPE    in number,
    nCELL        in number, -- место хранения (резервуар)
    nGOODSSUPPLY in number, -- товарный запас
    nNOMMODIF    in number, -- модификация.
    NARTICLE     in number, --
    nDOCTYPE     in number, -- тип документа
    dDOCDATE     in date, -- дата документа
    sDOCNUMB     in varchar2, -- номер документа
    sDOCPREF     in varchar2, -- префикс номера документ
    nSLAVERN     in number,
    sUNITCODE    in varchar2 -- Код раздела 
  ) return number is
    NCOUNT PKG_STD.tNUMBER;
    N      PKG_STD.tNUMBER := 0;
  begin
    -- при замене МХ - сначала удалим
    if NREPLACE = 1 then
      for del in (select T.COMPANY,
                         T.RN
                    from strplresjrnl t
                   where T.NOMMODIF = nNOMMODIF
                     and cmp_num(T.Article, NARTICLE) = 1 --
                        --and T.GOODSSUPPLY = nGOODSSUPPLY
                        --and T.CELL        = nCELL
                     and T.RES_TYPE = nRES_TYPE
                     and T.DOCTYPE = nDOCTYPE
                     and T.DOCPREF = sDOCPREF
                     and T.DOCNUMB = sDOCNUMB
                     and exists (select null
                            from DOCLINKS DL
                           where DL.OUT_DOCUMENT = t.rn
                             and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
                             and DL.IN_DOCUMENT = nSLAVERN
                             and DL.IN_UNITCODE = sUNITCODE)) loop
        P_STRPLRESJRNL_BASE_DELETE(nCOMPANY => del.company, nRN => del.rn);
        N := N + 1;
      end loop;
      if N = 0 then
        for del in (select T.COMPANY,
                           T.RN
                      from strplresjrnl t
                     where T.NOMMODIF = nNOMMODIF
                          --and cmp_num(T.Article, NARTICLE)   --
                          --and T.GOODSSUPPLY = nGOODSSUPPLY
                          --and T.CELL        = nCELL
                       and T.RES_TYPE = nRES_TYPE
                       and T.DOCTYPE = nDOCTYPE
                       and T.DOCPREF = sDOCPREF
                       and T.DOCNUMB = sDOCNUMB
                       and exists (select null
                              from DOCLINKS DL
                             where DL.OUT_DOCUMENT = t.rn
                               and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
                               and DL.IN_DOCUMENT = nSLAVERN
                               and DL.IN_UNITCODE = sUNITCODE)) loop
          P_STRPLRESJRNL_BASE_DELETE(nCOMPANY => del.company, nRN => del.rn);
          N := N + 1;
        end loop;
      end if;
    
    end if;
    --  begin 
    select Count(t.rn)
      into NCOUNT
      from strplresjrnl t
     where T.NOMMODIF = nNOMMODIF
       and T.GOODSSUPPLY = nGOODSSUPPLY
       and T.CELL = nCELL
       and T.DOCTYPE = nDOCTYPE
       and T.DOCPREF = sDOCPREF
       and T.DOCNUMB = sDOCNUMB
       and T.RES_TYPE = nRES_TYPE
       and T.DOCDATE = dDOCDATE
       and exists (select null
              from DOCLINKS DL
             where DL.OUT_DOCUMENT = t.rn
               and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
               and DL.IN_DOCUMENT = nSLAVERN
               and DL.IN_UNITCODE = sUNITCODE /*'GoodsTransInvoicesToDeptsSpecs'*/
            );
    --exception when NO_DATA_FOUND then
    if NCOUNT = 0 then
      -- begin 
      select Count(t.rn)
        into NCOUNT
        from strplresjrnl t
       where T.NOMMODIF = nNOMMODIF
         and T.GOODSSUPPLY = nGOODSSUPPLY
            --and T.CELL        = nCELL
         and T.DOCTYPE = nDOCTYPE
         and T.DOCPREF = sDOCPREF
         and T.RES_TYPE = nRES_TYPE
         and T.DOCNUMB = sDOCNUMB
         and exists (select null
                from DOCLINKS DL
               where DL.OUT_DOCUMENT = t.rn
                 and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
                 and DL.IN_DOCUMENT = nSLAVERN
                 and DL.IN_UNITCODE = sUNITCODE /* 'GoodsTransInvoicesToDeptsSpecs'*/
              );
      --and T.DOCDATE     = dDOCDATE;     
      -- exception when NO_DATA_FOUND then   
    end if;
    if NCOUNT = 0 and
       nRES_TYPE = 0 then
      -- begin
      select Count(t.rn)
        into NCOUNT
        from strplresjrnl t
       where T.NOMMODIF = nNOMMODIF
            --and T.GOODSSUPPLY = nGOODSSUPPLY
            --and T.CELL        = nCELL
         and T.DOCTYPE = nDOCTYPE
         and T.DOCPREF = sDOCPREF
         and T.RES_TYPE = nRES_TYPE
         and T.DOCNUMB = sDOCNUMB
         and exists (select null
                from DOCLINKS DL
               where DL.OUT_DOCUMENT = t.rn
                 and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
                 and DL.IN_DOCUMENT = nSLAVERN
                 and DL.IN_UNITCODE = sUNITCODE /*'GoodsTransInvoicesToDeptsSpecs'*/
              );
      --and T.DOCDATE     = dDOCDATE;
      -- exception when NO_DATA_FOUND then    
      --   NCOUNT := 0;
    end if;
    --    end;
    --  end;
    -- end;
  
    return NCOUNT;
  end FIND_STRPLRESJRNL_COUNTREC;

  /* Товарные запасы на местах хранения по товарному запасу  */
  procedure FIND_STPLGOODSSUPPLY
  (
    NCOMPANY     in number,
    nGOODSSUPPLY in number,
    nARTICLE     in number,
    nCELL        out number,
    NQUANT       out number,
    NQUANTALT    out number,
    NQUANTPACK   out number
  ) is
  begin
    begin
      select T.CELL,
             T.QUANT,
             t.quantalt,
             t.quantpack
        into nCELL,
             NQUANT,
             NQUANTALT,
             NQUANTPACK
        from STPLGOODSSUPPLY t
       where T.GOODSSUPPLY = nGOODSSUPPLY
         and T.COMPANY = NCOMPANY
         and T.QUANT > 0 -- 23/10/2022 Марков МВ. товарные запасы - это > 0
      ;
    exception
      when NO_DATA_FOUND then
        nCELL  := null;
        NQUANT := null;
      when TOO_MANY_ROWS then
        begin
          select T.CELL,
                 T.QUANT,
                 t.quantalt,
                 t.quantpack
            into nCELL,
                 NQUANT,
                 NQUANTALT,
                 NQUANTPACK
            from STPLGOODSSUPPLY t
           where T.GOODSSUPPLY = nGOODSSUPPLY
             and CMP_NUM(T.ARTICLE, nARTICLE) = 1
             and T.COMPANY = NCOMPANY
             and T.QUANT > 0 -- 23/10/2022 Марков МВ. товарные запасы - это > 0
          ;
        exception
          when NO_DATA_FOUND then
            nCELL  := null;
            NQUANT := null;
          when TOO_MANY_ROWS then
            nCELL  := null;
            NQUANT := null;
            /*p_exception(0,
            'Найдено более одной записи "Товарные запасы на местах хранения".');*/
        end;
    end;
  end FIND_STPLGOODSSUPPLY;

  /* Подготовка данных по Приходному ордеру */
  procedure GET_INORDERS_PRMS
  (
    nCOMPANY         in number,           -- Рег номер организации
    NIDENT           in number,           -- Идент выделенных записей
    RECPARAM         out TRECPARAMS       -- Коллеция параметров  
  ) 
  is
    sMASTERUNITCODE  PKG_STD.tSTRING := 'IncomingOrders';         -- код master-раздела
    sSLAVEUNITCODE   PKG_STD.tSTRING := 'IncomingOrdersSpecs';    -- код slave-раздела
    N                PKG_STD.tNUMBER := 0;                             -- номер записи
  begin
    
  for PO in (select I.INDOCTYPE, i.indocpref, i.indocnumb, i.indocdate, S.* 
               from INORDERS I, INORDERSPECS S, selectlist SL 
               where S.RN = SL.DOCUMENT
                 and S.PRN = I.RN 
                 and I.DOCSTATUS = 0 -- Только не отработанные  
                 and I.COMPANY = NCOMPANY 
                 and S.COMPANY = I.COMPANY
                 and SL.UNITCODE = sSLAVEUNITCODE
                 and SL.IDENT = NIDENT)loop
    N := N + 1;
  
       RECPARAM(n).sMASTERUNITCODE := sMASTERUNITCODE;
       RECPARAM(n).sSLAVEUNITCODE := sSLAVEUNITCODE;
       RECPARAM(n).nMASTERRN       := PO.PRN;
       RECPARAM(n).nSLAVERN        := PO.RN;
       RECPARAM(n).nGOODSSUPPLY    := PO.GOODSSUPPLY;
       RECPARAM(n).nNOMMODIF       := PO.NOMMODIF;
       RECPARAM(n).nARTICLE        := PO.Article;
       RECPARAM(n).nDOCTYPE        := PO.INDOCTYPE;
       RECPARAM(n).dDOCDATE        := PO.INDOCDATE;
       RECPARAM(n).sDOCNUMB        := PO.INDOCNUMB;
       RECPARAM(n).sDOCPREF        := PO.INDOCPREF;
       RECPARAM(n).dRESERVING_DATE := PO.INDOCDATE;
       RECPARAM(n).nQUANT          := PO.FACTQUANT;
       RECPARAM(n).nQUANTALT       := PO.FACTQUANTALT;
       RECPARAM(n).nQUANTPACK      := 0;  
  end loop;
  if N = 0 then
    p_exception(0,'Данных для распределения не найдено.');
  end if;
  end GET_INORDERS_PRMS;
  
  /* Подготовка данных по Приходу из подразделений */
  procedure GET_INCOMEFROMDEPS_PRMS
  (
    nCOMPANY         in number,           -- Рег номер организации
    NIDENT           in number,           -- Идент выделенных записей
    RECPARAM         out TRECPARAMS       -- Коллеция параметров  
  ) 
  is
    sMASTERUNITCODE  PKG_STD.tSTRING := 'IncomFromDeps';         -- код master-раздела
    sSLAVEUNITCODE   PKG_STD.tSTRING := 'IncomFromDepsSpecs';    -- код slave-раздела
    N                PKG_STD.tNUMBER := 0;                             -- номер записи
  begin
    
  for PO in (select I.DOC_TYPE, i.doc_pref, i.doc_numb, i.doc_date, S.* 
               from INCOMEFROMDEPS I, INCOMEFROMDEPSSPEC S, selectlist SL 
               where S.RN = SL.DOCUMENT
                 and S.PRN = I.RN 
                 and I.DOC_STATE = 0 -- Только не отработанные  
                 and I.COMPANY = NCOMPANY 
                 and S.COMPANY = I.COMPANY
                 and SL.UNITCODE = sSLAVEUNITCODE
                 and SL.IDENT = NIDENT)loop
    N := N + 1;
  
       RECPARAM(n).sMASTERUNITCODE := sMASTERUNITCODE;
       RECPARAM(n).sSLAVEUNITCODE := sSLAVEUNITCODE;
       RECPARAM(n).nMASTERRN       := PO.PRN;
       RECPARAM(n).nSLAVERN        := PO.RN;
       RECPARAM(n).nGOODSSUPPLY    := PO.SUPPLY;
       RECPARAM(n).nNOMMODIF       := PO.NOMMODIF;
       RECPARAM(n).nARTICLE        := PO.Article;
       RECPARAM(n).nDOCTYPE        := PO.DOC_TYPE;
       RECPARAM(n).dDOCDATE        := PO.DOC_DATE;
       RECPARAM(n).sDOCNUMB        := PO.DOC_NUMB;
       RECPARAM(n).sDOCPREF        := PO.DOC_PREF;
       RECPARAM(n).dRESERVING_DATE := PO.DOC_DATE;
       RECPARAM(n).nQUANT          := PO.QUANT_FACT;
       RECPARAM(n).nQUANTALT       := PO.QUANT_FACT_ALT;
       RECPARAM(n).nQUANTPACK      := 0;  
  end loop;
  if N = 0 then
    p_exception(0,'Данных для распределения не найдено.');
  end if;
  end GET_INCOMEFROMDEPS_PRMS;
  
  /* Подготовка данных по Приходному ордеру */
  procedure GET_TRANSINVDEPT_PRMS
  (
    nCOMPANY         in number,           -- Рег номер организации
    NIDENT           in number,           -- Идент выделенных записей
    nRES_TYPE        in number default 0, -- тип резервирования (0 - приход, 1 - расход)
    RECPARAM         out TRECPARAMS       -- Коллеция параметров  
  ) 
  is
    sMASTERUNITCODE  PKG_STD.tSTRING := 'GoodsTransInvoicesToDepts';         -- код master-раздела
    sSLAVEUNITCODE   PKG_STD.tSTRING := 'GoodsTransInvoicesToDeptsSpecs';    -- код slave-раздела
    N                PKG_STD.tNUMBER := 0;                             -- номер записи
  begin
    
  for PO in (select I.DOCTYPE, i.pref, i.numb, i.docdate, 
                    coalesce ( ( select gs.rn from GOODSPARTIES g, GOODSSUPPLY gs where g.rn = S.GOODSPARTY 
                                                                                 and gs.prn       = g.rn
                                                                                 and ((nRES_TYPE = 1 and gs.store     = i.store)
                                                                                     or (nRES_TYPE = 0 and gs.store      = i.in_store)) ),
                               ( select gs.rn from GOODSSUPPLY gs, ARTICLESSUPPLY ags 
                                                                               where ((nRES_TYPE = 1 and gs.store     = i.store)
                                                                                     or (nRES_TYPE = 0 and gs.store      = i.in_store))
                                                                                 and gs.rn = ags.prn
                                                                                 and ags.article = s.article )
                             ) GOODSSUPPLY
     ,nn.rn NOM, S.* 
               from TRANSINVDEPT I, TRANSINVDEPTSPECS S, NOMMODIF m, DICNOMNS NN, selectlist SL 
               where S.RN = SL.DOCUMENT 
                 and S.PRN = I.RN  
                 and I.COMPANY = NCOMPANY 
                 and S.COMPANY = I.COMPANY
                 and ( I.STATUS = 0 
                     or (I.STATUS = 1 and nvl(usr_pkg_process.process_get, 'null') in 'USR_P_TID_STRPLRESJRNL_MINS') ) -- не отработан 24/04/2025 Степанов М. или выполняется пользовательская процедура
                 and S.NOMMODIF = m.rn
                 and m.prn = nn.rn
                 and SL.UNITCODE = sSLAVEUNITCODE
                 and SL.IDENT = NIDENT)loop
    N := N + 1;
    /*if nRES_TYPE = 1 and PO.GOODSSUPPLY is null then
      p_exception(0,'Не указана партия и срия в строке спецификации с Номенклатурой - "%s" ', 
                    GET_DICNOMNS_CODE_ID (nFLAG_SMART => 0, nRN => PO.NOM));
    end if;*/
       RECPARAM(n).sMASTERUNITCODE := sMASTERUNITCODE;
       RECPARAM(n).sSLAVEUNITCODE := sSLAVEUNITCODE;
       RECPARAM(n).nMASTERRN       := PO.PRN;
       RECPARAM(n).nSLAVERN        := PO.RN;
       RECPARAM(n).nGOODSSUPPLY    := PO.GOODSSUPPLY;
       RECPARAM(n).nNOMMODIF       := PO.NOMMODIF;
       RECPARAM(n).nARTICLE        := PO.Article;
       RECPARAM(n).nDOCTYPE        := PO.DOCTYPE;
       RECPARAM(n).dDOCDATE        := PO.DOCDATE;
       RECPARAM(n).sDOCNUMB        := PO.NUMB;
       RECPARAM(n).sDOCPREF        := PO.PREF;
       RECPARAM(n).dRESERVING_DATE := PO.DOCDATE;
       RECPARAM(n).nQUANT          := PO.QUANT;
       RECPARAM(n).nQUANTALT       := PO.QUANTALT;
       RECPARAM(n).nQUANTPACK      := 0;  
  end loop;
  if nRES_TYPE = 1 and N = 0 then
    p_exception(0,'Данных для распределения не найдено.');
  end if;
  end GET_TRANSINVDEPT_PRMS;
  
  /* Подготовка данных по Расходу потребителям */
  procedure GET_TRANSINVCUST_PRMS
  (
    nCOMPANY         in number,           -- Рег номер организации
    NIDENT           in number,           -- Идент выделенных записей
    RECPARAM         out TRECPARAMS       -- Коллеция параметров  
  ) 
  is
    sMASTERUNITCODE  PKG_STD.tSTRING := 'GoodsTransInvoicesToConsumers';         -- код master-раздела
    sSLAVEUNITCODE   PKG_STD.tSTRING := 'GoodsTransInvoicesToConsumersSpecs';    -- код slave-раздела
    N                PKG_STD.tNUMBER := 0;                                       -- номер записи
  begin
    
    for PO in (select I.DOCTYPE, I.PREF, I.NUMB, I.DOCDATE,
                      S.RN, S.PRN, S.NOMMODIF, S.ARTICLE, S.QUANT, S.QUANTALT,                      
                      coalesce( (select gs.rn from GOODSSUPPLY GS where GS.PRN = S.GOODSPARTY and GS.STORE = I.STORE)
                        ,
                        (select gs.rn from ARTICLESSUPPLY AGS, GOODSSUPPLY GS where AGS.ARTICLE = S.ARTICLE and AGS.PRN = GS.RN and GS.STORE = I.STORE)  ) GOODSSUPPLY 
                 from TRANSINVCUST I,
                      TRANSINVCUSTSPECS S,
                      SELECTLIST SL                      
                 where SL.IDENT    = NIDENT
                   and SL.UNITCODE = sSLAVEUNITCODE
                   and S.RN        = SL.DOCUMENT
                   and S.COMPANY   = NCOMPANY 
                   and S.PRN       = I.RN 
                   and I.STATUS    = 0 -- Только не отработанные
              )
    loop
      N := N + 1;
      RECPARAM(n).sMASTERUNITCODE := sMASTERUNITCODE;
      RECPARAM(n).sSLAVEUNITCODE  := sSLAVEUNITCODE;
      RECPARAM(n).nMASTERRN       := PO.PRN;
      RECPARAM(n).nSLAVERN        := PO.RN;
      RECPARAM(n).nGOODSSUPPLY    := PO.GOODSSUPPLY;
      RECPARAM(n).nNOMMODIF       := PO.NOMMODIF;
      RECPARAM(n).nARTICLE        := PO.Article;
      RECPARAM(n).nDOCTYPE        := PO.DOCTYPE;
      RECPARAM(n).dDOCDATE        := PO.DOCDATE;
      RECPARAM(n).sDOCNUMB        := PO.NUMB;
      RECPARAM(n).sDOCPREF        := PO.PREF;
      RECPARAM(n).dRESERVING_DATE := PO.DOCDATE;
      RECPARAM(n).nQUANT          := PO.QUANT;
      RECPARAM(n).nQUANTALT       := PO.QUANTALT;
      RECPARAM(n).nQUANTPACK      := 0;  
    end loop;
    if N = 0 then
      p_exception(0,'Данных для распределения не найдено.');
    end if;
    
   end GET_TRANSINVCUST_PRMS;

  /* 28/10/2024 Марков МВ. Подготовка данных по Акты списания недостач/оприходования излишков */
  procedure GET_WROFFACTS_PRMS
  (
    nCOMPANY in number, -- Рег номер организации
    NIDENT   in number, -- Идент выделенных записей
    RECPARAM out TRECPARAMS -- Коллеция параметров  
  ) is
    sMASTERUNITCODE PKG_STD.tSTRING := 'WriteOffActs'; -- код master-раздела
    sSLAVEUNITCODE  PKG_STD.tSTRING := 'WriteOffActsSpecs'; -- код slave-раздела
    N               PKG_STD.tNUMBER := 0; -- номер записи
  begin
    -- каждую отмеченную запись
    for PO in (select W.DOCTYPE,
                      W.DOCPREF as PREF,
                      W.DOCNUMB as NUMB,
                      W.DOCDATE,
                      WS.RN,
                      WS.PRN,
                      WS.NOMMODIF,
                      WS.ARTICLE,
                      WS.QUANT,
                      WS.QUANTALT,
                      case
                        when WS.GOODSSUPPLY is not null then WS.GOODSSUPPLY
                        else
                          coalesce((select GS.RN
                                     from GOODSSUPPLY GS
                                    where GS.PRN = WS.GOODSPARTY
                                      and GS.STORE = W.STORE),
                                   (select GS.RN
                                      from ARTICLESSUPPLY AGS,
                                           GOODSSUPPLY    GS
                                     where AGS.ARTICLE = WS.ARTICLE
                                       and AGS.PRN = GS.RN
                                       and GS.STORE = W.STORE))
                      end as GOODSSUPPLY
                 from WROFFACTS     W,
                      WROFFACTSPECS WS,
                      SELECTLIST    SL
                where SL.IDENT = NIDENT
                  and SL.UNITCODE = sSLAVEUNITCODE
                  and WS.RN = SL.DOCUMENT
                  and WS.COMPANY = NCOMPANY
                  and WS.PRN = W.RN
                  and W.STATUS = 0 -- Только не отработанные
               ) loop
      N := N + 1;
      RECPARAM(n).sMASTERUNITCODE := sMASTERUNITCODE;
      RECPARAM(n).sSLAVEUNITCODE := sSLAVEUNITCODE;
      RECPARAM(n).nMASTERRN := PO.PRN;
      RECPARAM(n).nSLAVERN := PO.RN;
      RECPARAM(n).nGOODSSUPPLY := PO.GOODSSUPPLY;
      RECPARAM(n).nNOMMODIF := PO.NOMMODIF;
      RECPARAM(n).nARTICLE := PO.Article;
      RECPARAM(n).nDOCTYPE := PO.DOCTYPE;
      RECPARAM(n).dDOCDATE := PO.DOCDATE;
      RECPARAM(n).sDOCNUMB := PO.NUMB;
      RECPARAM(n).sDOCPREF := PO.PREF;
      RECPARAM(n).dRESERVING_DATE := PO.DOCDATE;
      RECPARAM(n).nQUANT := PO.QUANT;
      RECPARAM(n).nQUANTALT := PO.QUANTALT;
      RECPARAM(n).nQUANTPACK := 0;
    end loop;
    --
    if N = 0 then
      p_exception(0, 'Данных для распределения не найдено.');
    end if;
  end GET_WROFFACTS_PRMS;

  /* 21/05/2024 Марков МВ. Возвратная накладная зарегистрируем МХ для возврата */
  procedure SET_TRINVDEPT_STRPLACE_RETURN
  (
    nIDENT in number, -- отмеченные записи спецификации
    nCELL  in number -- место хранения
  ) is
    nRN PKG_STD.tREF;
  begin
    for rec in (select TDS.RN
                  from TRANSINVDEPTSPECS TDS,
                       SELECTLIST        SL
                 where SL.IDENT = nIDENT
                   and SL.DOCUMENT = TDS.RN) loop
      -- удалим старое значение
      delete from UDO_TRINVDEPT_STRPLACE_RETURN where PRN = rec.rn;
      nRN := gen_id;
      -- добавим МХ для строки спецификации на возврат
      insert into UDO_TRINVDEPT_STRPLACE_RETURN
        (RN,
         PRN,
         CELL)
      values
        (nRN,
         rec.rn,
         nCELL);
    end loop;
  end SET_TRINVDEPT_STRPLACE_RETURN;
  
  /* Создание записи по распределению по местам хранения */
  procedure STRPLRESJRNL_MAKE
  (
    nCOMPANY       in number, -- Рег номер организации
    nCELL          in number, -- место хранения (резервуар)
    nRES_TYPE      in number, -- тип резервирования (0 - приход, 1 - расход)
    nCHECK_PARTY   in number default 0, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
    NREPLACE       in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да)
    RECPARAM       in TRECPARAMS, -- Коллеция параметров 
    dRESERVINGDATE in date, -- дата и время резервирования.
    sUNITCODE      in varchar2, -- Код раздела 
    SOUTNOTE       out varchar2
  ) is
    nINDEX          PKG_STD.tNUMBER;
    NREC_COUNT      PKG_STD.tNUMBER;
    nRN             PKG_STD.tREF;
    nCELL_          PKG_STD.tREF;
    NQUANT_CL       PKG_STD.tQUANT;
    NQUANTALT_CL    PKG_STD.tQUANT;
    NQUANTPACK_CL   PKG_STD.tQUANT;
    nQUANT_S        PKG_STD.tQUANT;
    nQUANT_RES      PKG_STD.tQUANT;
    nQUANTALT_S     PKG_STD.tQUANT;
    nQUANTPACK_S    PKG_STD.tQUANT;
    N               PKG_STD.tNUMBER := 0;
    Q               PKG_STD.tNUMBER := 0;
    dRESERVING_DATE PKG_STD.tLDATE  := dRESERVINGDATE; /* 24/04/2025 Степанов М. Чтобы дата резервирования для списания использовалась из параметра */
    nCHECK_RSRV     PKG_STD.tNUMBER;
  begin
    nCELL_ := nCELL;
    /* Читаем индекс первого элемента коллекции Отправок */
    nINDEX := RECPARAM.FIRST();
    while (nINDEX is not null) loop
      Q := Q + 1;
      nCHECK_RSRV := 0;
      /* Поиск записи распределения по местам зранения */
      NREC_COUNT := FIND_STRPLRESJRNL_COUNTREC(NREPLACE     => NREPLACE,
                                               nRES_TYPE    => nRES_TYPE,
                                               nCELL        => nCELL,
                                               nGOODSSUPPLY => RECPARAM(nINDEX).nGOODSSUPPLY,
                                               nNOMMODIF    => RECPARAM(nINDEX).nNOMMODIF,
                                               NARTICLE     => RECPARAM(nINDEX).NARTICLE,
                                               nDOCTYPE     => RECPARAM(nINDEX).nDOCTYPE,
                                               dDOCDATE     => RECPARAM(nINDEX).dDOCDATE,
                                               sDOCNUMB     => RECPARAM(nINDEX).sDOCNUMB,
                                               sDOCPREF     => RECPARAM(nINDEX).sDOCPREF,
                                               nSLAVERN     => RECPARAM(nINDEX).nSLAVERN,
                                               sUNITCODE    => sUNITCODE);
    
      if NREC_COUNT = 0 then
      
        if nRES_TYPE = 1 then
          -- списание
          if RECPARAM(nINDEX).nGOODSSUPPLY is null then
            nINDEX := RECPARAM.NEXT(nINDEX);
            continue; -- p_exception(0,'Для расхода обязательно указание Товарного запаса');
          end if;
        
          /* Товарные запасы на местах хранения по товарному запасу  */
          /* иначе не подбирает несколько МХ
          FIND_STPLGOODSSUPPLY(NCOMPANY     => NCOMPANY,
          nGOODSSUPPLY => RECPARAM(nINDEX).nGOODSSUPPLY,
          nARTICLE     => RECPARAM(nINDEX).nARTICLE,
          nCELL        => nCELL_,
          NQUANT       => NQUANT_CL,
          NQUANTALT    => NQUANTALT_CL,
          NQUANTPACK   => NQUANTPACK_CL);*/
          
          nQUANT_RES := 0;
          for rrsv in (select T.CELL,
                              T.QUANT,
                              t.quantalt,
                              t.quantpack
                         from STPLGOODSSUPPLY t
                        where T.GOODSSUPPLY = RECPARAM(nINDEX).nGOODSSUPPLY
                          and (RECPARAM(nINDEX).nARTICLE is null or CMP_NUM(T.ARTICLE, RECPARAM(nINDEX).nARTICLE) = 1)
                          and T.COMPANY = NCOMPANY
                          and T.QUANT > 0 -- 23/10/2022 Марков МВ. товарные запасы - это > 0
                        order by T.QUANT
                       ) loop
            nCELL_        := rrsv.cell;
            NQUANT_CL     := rrsv.quant;
            NQUANTALT_CL  := rrsv.quantalt;
            NQUANTPACK_CL := rrsv.quantpack;
          
            if RECPARAM(nINDEX).nQUANT >= NQUANT_CL then
              nQUANT_S     := NQUANT_CL;
              nQUANTALT_S  := NQUANTALT_CL;
              nQUANTPACK_S := NQUANTPACK_CL;
            else
              nQUANT_S     := RECPARAM(nINDEX).nQUANT;
              nQUANTALT_S  := RECPARAM(nINDEX).nQUANTALT;
              nQUANTPACK_S := RECPARAM(nINDEX).nQUANTPACK;
            end if;
            nQUANT_RES := nQUANT_RES + nQUANT_S;
            P_STRPLRESJRNL_BASE_INSERT(nCOMPANY        => nCOMPANY, -- организация.
                                       sAUTHID         => UTILIZER, -- пользователь
                                       sMASTERUNITCODE => RECPARAM(nINDEX).sMASTERUNITCODE, -- код master-раздела
                                       sSLAVEUNITCODE  => RECPARAM(nINDEX).sSLAVEUNITCODE, -- код slave-раздела
                                       nMASTERRN       => RECPARAM(nINDEX).nMASTERRN, -- регистрационный номер master-записи
                                       nSLAVERN        => RECPARAM(nINDEX).nSLAVERN, -- регистрационный номер slave-записи
                                       nRACK           => null, -- не используется (по возможности убрать)
                                       nCELL           => nCELL_, -- место хранения (резервуар)
                                       nGOODSSUPPLY    => RECPARAM(nINDEX).nGOODSSUPPLY, -- товарный запас
                                       nRES_TYPE       => nRES_TYPE, -- тип резервирования (0 - приход, 1 - расход)
                                       nNOMMODIF       => RECPARAM(nINDEX).nNOMMODIF, -- модификация.
                                       nNOMNMODIFPACK  => null, -- упаковка модификации
                                       nARTICLE        => RECPARAM(nINDEX).nARTICLE, -- изделие на складе
                                       nGOODSUNIT      => null, -- грузовая единица
                                       nDOCTYPE        => RECPARAM(nINDEX).nDOCTYPE, -- тип документа
                                       dDOCDATE        => RECPARAM(nINDEX).dDOCDATE, -- дата документа
                                       sDOCNUMB        => RECPARAM(nINDEX).sDOCNUMB, -- номер документа
                                       sDOCPREF        => RECPARAM(nINDEX).sDOCPREF, -- префикс номера документа
                                       dRESERVING_DATE => dRESERVING_DATE, -- дата и время резервирования.
                                       dFREE_DATE      => null, -- дата и время снятия резервирования.
                                       nQUANT          => nQUANT_S, -- количество в основной ЕИ
                                       nQUANTALT       => nQUANTALT_S, -- количество в дополнительной ЕИ
                                       nQUANTPACK      => 0, --nQUANTPACK_S, -- не используется (рассчитывается из ОЕИ)
                                       nCHECK_PARTY    => 0, --nCHECK_PARTY, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
                                       nRN             => NRN);
            nCHECK_RSRV := 1;
            --
            if nQUANT_RES >= RECPARAM(nINDEX).nQUANT then
              exit;
            end if;
          end loop;
        
        else
          -- приход
          nQUANT_S     := RECPARAM(nINDEX).nQUANT;
          nQUANTALT_S  := RECPARAM(nINDEX).nQUANTALT;
          nQUANTPACK_S := RECPARAM(nINDEX).nQUANTPACK;
          -- создадим резерв
          if nCELL_ is not null then
            -- 23/10/2022 Марков МВ. Для пустых ячеек не будет добавления
            if dRESERVINGDATE is null then
              dRESERVING_DATE := RECPARAM(nINDEX).dRESERVING_DATE;
            
            else
              dRESERVING_DATE := dRESERVINGDATE;
            end if;
            P_STRPLRESJRNL_BASE_INSERT(nCOMPANY        => nCOMPANY, -- организация.
                                       sAUTHID         => UTILIZER, -- пользователь
                                       sMASTERUNITCODE => RECPARAM(nINDEX).sMASTERUNITCODE, -- код master-раздела
                                       sSLAVEUNITCODE  => RECPARAM(nINDEX).sSLAVEUNITCODE, -- код slave-раздела
                                       nMASTERRN       => RECPARAM(nINDEX).nMASTERRN, -- регистрационный номер master-записи
                                       nSLAVERN        => RECPARAM(nINDEX).nSLAVERN, -- регистрационный номер slave-записи
                                       nRACK           => null, -- не используется (по возможности убрать)
                                       nCELL           => nCELL_, -- место хранения (резервуар)
                                       nGOODSSUPPLY    => RECPARAM(nINDEX).nGOODSSUPPLY, -- товарный запас
                                       nRES_TYPE       => nRES_TYPE, -- тип резервирования (0 - приход, 1 - расход)
                                       nNOMMODIF       => RECPARAM(nINDEX).nNOMMODIF, -- модификация.
                                       nNOMNMODIFPACK  => null, -- упаковка модификации
                                       nARTICLE        => RECPARAM(nINDEX).nARTICLE, -- изделие на складе
                                       nGOODSUNIT      => null, -- грузовая единица
                                       nDOCTYPE        => RECPARAM(nINDEX).nDOCTYPE, -- тип документа
                                       dDOCDATE        => RECPARAM(nINDEX).dDOCDATE, -- дата документа
                                       sDOCNUMB        => RECPARAM(nINDEX).sDOCNUMB, -- номер документа
                                       sDOCPREF        => RECPARAM(nINDEX).sDOCPREF, -- префикс номера документа
                                       dRESERVING_DATE => dRESERVING_DATE, -- дата и время резервирования.
                                       dFREE_DATE      => null, -- дата и время снятия резервирования.
                                       nQUANT          => nQUANT_S, -- количество в основной ЕИ
                                       nQUANTALT       => nQUANTALT_S, -- количество в дополнительной ЕИ
                                       nQUANTPACK      => 0, --nQUANTPACK_S, -- не используется (рассчитывается из ОЕИ)
                                       nCHECK_PARTY    => 0, --nCHECK_PARTY, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
                                       nRN             => NRN);
            nCHECK_RSRV := 1;
          end if;
        end if;
        --
        if nCHECK_RSRV = 1 then
          -- резерв создали
          N := N + 1;
        end if;
      end if;
    
      nINDEX := RECPARAM.NEXT(nINDEX);
    end loop;
  
    SOUTNOTE := 'Отработано записей - ' || N || ' из ' || Q;
  end STRPLRESJRNL_MAKE;


  /* Точка входа */
  Procedure SATRT
  (
    nCOMPANY         in number,           -- Рег номер организации
    sUNITCODE        in varchar2,         -- Код раздела 
    NIDENT           in number,           -- Идент выделенных записей
    sSTORE           in varchar2,         -- склад
    SCELL            in varchar2,         -- место хранения (резервуар)
    nRES_TYPE        in number default 0, -- тип резервирования (0 - приход, 1 - расход)
    nCHECK_PARTY     in number default 0, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
    NREPLACE         in number default 0, -- Распределение с заменой найденных записей (0 - нет, 1 - да)
    dRESERVINGDATE   in date,             -- дата и время резервирования.
    nRETURN          in number default 0, -- признак возвратной накладной (0 - нет, 1 - да)
    nOUTNOTE         out number
  )
  is
    nCELL            PKG_STD.tREF;        -- Рег номер ячейки
    RECPARAM         TRECPARAMS;          -- Коллеция параметров  
    sOUTNOTE         PKG_STD.tSTRING;
    NRN_OUTNOTE      PKG_STD.tREF;
  begin
    if (nRES_TYPE = 0 and sSTORE is not null and SCELL is not null) then 
     /* Поиск ячейки */
      FIND_STPLCELLS_NUMB(nFLAG_SMART  => 0,
                          nFLAG_OPTION => 0,
                          nCOMPANY     => nCOMPANY,
                          nSTORE       => null,
                          sSTORE       => sSTORE,
                          sCELL        => SCELL,
                          nRN          => nCELL);
    elsif (nRES_TYPE = 0 and sSTORE is null and SCELL is not null)then 
      p_exception(0,'Не задан склад!');
    elsif (nRES_TYPE = 0 and sSTORE is not null and SCELL is  null) then
      p_exception(0,'Не задан номер ячейки!');
    elsif (nRES_TYPE = 0 and sSTORE is null and SCELL is  null)  then
      p_exception(0,'Не задан склад и номер ячейки!');
    elsif nRES_TYPE = 1 and sSTORE is null then
       p_exception(0,'Не задан склад');
    end if;                  
    case sUNITCODE
      when 'IncomingOrdersSpecs' then
        /* Подготовка данных по Приходному ордеру */
        GET_INORDERS_PRMS(nCOMPANY => nCOMPANY,
                          NIDENT   => NIDENT,
                          RECPARAM => RECPARAM);
       when 'GoodsTransInvoicesToDeptsSpecs' then
         /* Подготовка данных по Расходным накладным в подразделение */
         GET_TRANSINVDEPT_PRMS(nCOMPANY => nCOMPANY,
                               NIDENT   => NIDENT,
                               nRES_TYPE => nRES_TYPE,
                               RECPARAM => RECPARAM);
       when 'IncomFromDepsSpecs' then
         /* Подготовка данных по Приходам из подразделений */
         GET_INCOMEFROMDEPS_PRMS(nCOMPANY => nCOMPANY,
                                 NIDENT   => NIDENT,
                                 RECPARAM => RECPARAM);
       when 'GoodsTransInvoicesToConsumersSpecs' then
         /* Подготовка данных по Расходным накладным потребителям */
         GET_TRANSINVCUST_PRMS(nCOMPANY => NCOMPANY, 
                               NIDENT   => NIDENT,
                               RECPARAM => RECPARAM);
       when 'WriteOffActsSpecs' then
         /* Подготовка данных по Актам списания недостач/оприходования излишков */
         GET_WROFFACTS_PRMS(nCOMPANY => NCOMPANY, 
                            NIDENT   => NIDENT,
                            RECPARAM => RECPARAM);
     else
        p_exception(0,
                    'Раздел - "%s" не поддерживается',
                    sUNITCODE);
    end case;
    
    if nvl(nRETURN, 0) = 0 then
      -- обычная накладная
      /* Создание записи по распределению по местам хранения */
      STRPLRESJRNL_MAKE(nCOMPANY       => nCOMPANY,
                        nCELL          => nCELL,
                        nRES_TYPE      => nRES_TYPE,
                        RECPARAM       => RECPARAM,
                        NREPLACE       => NREPLACE,
                        nCHECK_PARTY   => nCHECK_PARTY,
                        dRESERVINGDATE => dRESERVINGDATE,
                        sUNITCODE      => sUNITCODE,
                        SOUTNOTE       => SOUTNOTE
                       );
       nOUTNOTE := gen_ident;
       /* Генерируем сообщение */ 
       P_MSGJOURNAL_BASE_INSERT(nIDENT => nOUTNOTE,nRECTYPE => 0,sMSG_TEXT => SOUTNOTE, nRN => NRN_OUTNOTE);
     
     else
       -- 21/05/2024 Марков МВ. Возвратная накладная
       -- зарегистрируем МХ для возврата
       SET_TRINVDEPT_STRPLACE_RETURN(nIDENT => nIDENT, nCELL => nCELL);
     end if;
                     
  end SATRT;

  /* Пользовательская форма для Приходного ордера */
  procedure INORDERS_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада  
    SCELL            in out varchar2,      -- Мнемокод ячейки
    SCELL_ND         in out number      -- Доступность ячейки
  )
  is 
    SREC_STORE       PKG_STD.tSTRING; 
    NREC_DOCSTATUS   PKG_STD.tNUMBER;          
  begin
     /* Поиск склада */
     begin 
      select S.AZS_NUMBER, I.DOCSTATUS into SREC_STORE, NREC_DOCSTATUS from INORDERS I, AZSAZSLISTMT S where I.RN = NRN and I.COMPANY = NCOMPANY and I.STORE = S.RN;
     exception when NO_DATA_FOUND then
       SREC_STORE := null;
     end;
    /* Открытие формы */
    if SATRIB is null then
      SSTORE := SREC_STORE;
      SSTORE_ND := 0;
      SCELL_ND := 1;
    if NREC_DOCSTATUS != 0 then 
      SSTORE := null;
      SCELL := null;
      SSTORE_ND := 0;
      SCELL_ND := 0;
      p_exception(0,'Массовое резервирование по месту хранения доступно только для документа в статусе "Не отработан".');
    end if;
    end if; 
    if SATRIB = 'SCELL' then
      SCELL := SCELL;
      SSTORE := SREC_STORE;
      SSTORE_ND := 0;
      SCELL_ND := 1;
    end if;
  end INORDERS_PRMS_FE;  

  /* Пользовательская форма для Расходной накладной в подразделение */
  procedure TRANSINVDEPT_PRMS_FE
  (
    NCOMPANY     in number, -- Рег. номер организации
    NRN          in number, -- рег номер родителя
    SATRIB       in varchar2, -- Изменение атрибута
    SSTORE       out varchar2, -- Мнемокод Склада
    SSTORE_ND    in out number, -- Доступность Склада  
    SCELL        in out varchar2, -- Мнемокод ячейки
    SCELL_ND     in out number, -- Доступность ячейки
    SCELL_NN     in out number, -- Обязательность ячейки
    nRETURN      in out number, -- признак возвратной накладной
    nRETURN_ND   in out number, -- Доступность признак возвратной накладной
    nRES_TYPE_ND in out number, -- Доступность тип резервирования (0 - приход, 1 - расход)
    nREPLACE     in out number, -- с заменой
    nREPLACE_ND  in out number, -- Доступность с заменой
    nRES_TYPE    in out number -- тип резервирования (0 - приход, 1 - расход)
  ) is
    SREC_STORE_OUT PKG_STD.tSTRING;
    SREC_STORE_IN  PKG_STD.tSTRING;
    NREC_DOCSTATUS PKG_STD.tNUMBER;
    --
    sIN_UNITCODE   PKG_STD.tSTRING;
    nIN_STOPER     PKG_STD.tREF;
    nIN_ST_RET     PKG_STD.tREF;
  begin
    /* Поиск склада */
    begin
      select S_O.Azs_Number,
             S.AZS_NUMBER,
             I.STATUS,
             (select L.IN_UNITCODE from DOCLINKS L where L.OUT_DOCUMENT = I.RN and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
               and L.IN_UNITCODE = 'GoodsTransInvoicesToDepts' and rownum < 2),
             STP.RN,
             STP.FACTRET_SIGN
        into SREC_STORE_OUT,
             SREC_STORE_IN,
             NREC_DOCSTATUS,
             sIN_UNITCODE,
             nIN_STOPER,
             nIN_ST_RET
        from TRANSINVDEPT I,
             AZSAZSLISTMT S_O,
             AZSAZSLISTMT S,
             AZSGSMWAYSTYPES STP
       where I.RN = NRN
         and I.COMPANY = NCOMPANY
         and I.Store = S_O.RN(+)
         and I.In_Store = S.RN(+)
         and I.STOPER = STP.RN;
    exception
      when NO_DATA_FOUND then
        SREC_STORE_OUT := null;
        SREC_STORE_IN  := null;
    end;
    /* Открытие формы */
    if SATRIB is null then
      SSTORE    := SREC_STORE_IN;
      SSTORE_ND := 0;
      SCELL_ND  := 1;
      nRETURN   := 0;
      nRETURN_ND := 0;
      if NREC_DOCSTATUS != 0 then
        SSTORE    := null;
        SCELL     := null;
        SSTORE_ND := 0;
        SCELL_ND  := 0;
        SCELL_NN  := 1;
        p_exception(0,
                    'Массовое резервирование по месту хранения доступно только для документа в статусе "Не отработан".');
      end if;
      -- 21/05/2024 марков МВ. для возвратных накладных
      if nIN_ST_RET = 1 then
        nRETURN      := 1;
        nRES_TYPE_ND := 0;
        nREPLACE     := 1;
        nREPLACE_ND  := 0;
        SSTORE       := SREC_STORE_OUT;
      end if;
      --
    end if;
    if SATRIB = 'SCELL' then
      SCELL     := SCELL;
      -- 21/05/2024 марков МВ. для возвратных накладных
      if nIN_ST_RET = 1 then
        SSTORE    := SREC_STORE_OUT;
      else
        SSTORE    := SREC_STORE_IN;
      end if;
      SSTORE_ND := 0;
      SCELL_ND  := 1;
      SCELL_NN  := 1;
    end if;
    if SATRIB = 'NRES_TYPE' then
      if nRES_TYPE = 1 then
        SCELL    := null;
        SCELL_ND := 0;
        SCELL_NN := 0;
        SSTORE   := SREC_STORE_OUT;
      else
        SCELL_ND := 1;
        SCELL_NN := 1;
        SSTORE   := SREC_STORE_IN;
      end if;
    end if;
  end TRANSINVDEPT_PRMS_FE;

  procedure INCOMEFROMDEPS_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада  
    SCELL            in out varchar2,      -- Мнемокод ячейки
    SCELL_ND         in out number      -- Доступность ячейки
  )
  is 
    SREC_STORE       PKG_STD.tSTRING; 
    NREC_DOCSTATUS   PKG_STD.tNUMBER;          
  begin
     /* Поиск склада */
     begin 
      select S.AZS_NUMBER, I.DOC_STATE into SREC_STORE, NREC_DOCSTATUS from INCOMEFROMDEPS I, AZSAZSLISTMT S where I.RN = NRN and I.COMPANY = NCOMPANY and I.STORE = S.RN;
     exception when NO_DATA_FOUND then
       SREC_STORE := null;
     end;
    /* Открытие формы */
    if SATRIB is null then
      SSTORE := SREC_STORE;
      SSTORE_ND := 0;
      SCELL_ND := 1;
    if NREC_DOCSTATUS != 0 then 
      SSTORE := null;
      SCELL := null;
      SSTORE_ND := 0;
      SCELL_ND := 0;
      p_exception(0,'Массовое резервирование по месту хранения доступно только для документа в статусе "Не отработан".');
    end if;
    end if; 
    if SATRIB = 'SCELL' then
      SCELL := SCELL;
      SSTORE := SREC_STORE;
      SSTORE_ND := 0;
      SCELL_ND := 1;
    end if;
  end INCOMEFROMDEPS_PRMS_FE;

  /* Пересчет на форме Расхода потребителям */
  procedure TRANSINVCUST_PRMS_FE
  (
    NCOMPANY         in number,         -- Рег. номер организации
    NRN              in number,         -- рег номер родителя
    SATRIB           in varchar2,       -- Изменение атрибута
    SSTORE           out varchar2,      -- Мнемокод Склада
    SSTORE_ND        in out number,     -- Доступность Склада  
    SCELL            in out varchar2,   -- Мнемокод ячейки
    SCELL_ND         in out number,     -- Доступность ячейки
    SCELL_NN         in out number,     -- Обязательность ячейки 
    nRES_TYPE        in out number      -- тип резервирования (0 - приход, 1 - расход)
  )
  is 
    SREC_STORE       PKG_STD.tSTRING;
    NREC_DOCSTATUS   PKG_STD.tNUMBER; 
  begin
     /* Поиск склада */
     begin 
      select S.AZS_NUMBER, I.STATUS, 1 - SOP.GSMWAYS_TYPE
        into SREC_STORE, NREC_DOCSTATUS, nRES_TYPE
        from TRANSINVCUST I,
             AZSAZSLISTMT S,
             AZSGSMWAYSTYPES SOP
       where I.RN      = NRN and 
             I.COMPANY = NCOMPANY and
             I.Store   = S.RN and
             I.STOPER  = SOP.RN;
     exception when NO_DATA_FOUND then
       SREC_STORE := null;
     end;
    /* Открытие формы */
    if SATRIB is null then
      SSTORE    := SREC_STORE;
      SSTORE_ND := 0;
      SCELL_ND  := 1;
      if NREC_DOCSTATUS != 0 then 
        SSTORE    := null;
        SCELL     := null;
        SSTORE_ND := 0;
        SCELL_ND  := 0;
        SCELL_NN  := 1;
        p_exception(0,'Массовое резервирование по месту хранения доступно только для документа в статусе "Не отработан".');
      end if;
      if nRES_TYPE = 1 then -- расход
        SCELL     := null;
        SSTORE_ND := 0;
        SCELL_ND  := 0;
        SCELL_NN  := 0;
      else -- приход
        SSTORE_ND := 0;
        SCELL_ND  := 1;
        SCELL_NN  := 1;
      end if;
    end if; 
  end TRANSINVCUST_PRMS_FE;

  /* Пользовательская форма для Акты списания недостач/оприходования излишков */
  procedure WROFFACTS_PRMS_FE
  (
    nCOMPANY    in number, -- Рег. номер организации
    nRN         in number, -- рег номер родителя
    sATRIB      in varchar2, -- Изменение атрибута
    nFIRST      in out number, -- признак первого запуска
    sSTORE      out varchar2, -- Мнемокод Склада
    sSTORE_ND   in out number, -- Доступность Склада  
    sCELL       in out varchar2, -- Мнемокод ячейки
    sCELL_ND    in out number, -- Доступность ячейки
    sCELL_NN    in out number, -- Обязательность ячейки
    nREPLACE    in out number, -- с заменой
    nREPLACE_ND in out number, -- Доступность с заменой
    dRES_DATE   out date, -- дата резервирования
    sRES_TYPE   in out varchar2 -- Тип резервирования (Приход, Расход)
  ) is
    nDOCSTATUS PKG_STD.tNUMBER;
    nACTTYPE   PKG_STD.tNUMBER;
    nCRN       PKG_STD.tREF;
    nRESULT    PKG_STD.tNUMBER;
  
  begin
    /* Поиск склада */
    begin
      select ST.AZS_NUMBER,
             W.STATUS,
             W.ACTTYPE,
             W.DOCDATE,
             W.CRN
        into sSTORE,
             nDOCSTATUS,
             nACTTYPE,
             dRES_DATE,
             nCRN
        from WROFFACTSPECS WS,
             WROFFACTS     W,
             AZSAZSLISTMT  ST
       where WS.RN = nRN
         and WS.PRN = W.RN
         and W.STORE = ST.RN;
    exception
      when no_data_found then
        null;
    end;
  
    -- права доступа
    PKG_ENV.SMART_ACCESS(nCOMPANY => nCOMPANY,
                         nVERSION => null,
                         nCATALOG => nCRN,
                         sUNIT    => 'WriteOffActsSpecs',
                         sACTION  => 'P_STRPLRESJRNL_MINS_WRAC',
                         nRESULT  => nRESULT,
                         sAUTHID  => utilizer);
    if nvl(nRESULT, 0) < 1 then
        sRES_TYPE   := 'У Вас нет прав на выполнение операции.';
        sSTORE      := null;
        sCELL       := null;
        sSTORE_ND   := 0;
        sCELL_ND    := 0;
        sCELL_NN    := 1;
        nREPLACE_ND := 0;
        nREPLACE    := 0;
        
        return;
    end if;
    /* Открытие формы */
    if sRES_TYPE = 'TPContentLabel1' then
      -- 
      if nACTTYPE = 0 then
        -- недостача - списание
        sRES_TYPE   := 'Расход';
        sCELL       := null;
        sCELL_ND    := 0;
        sCELL_NN    := 0;
        sSTORE_ND   := 0;
        nREPLACE_ND := 0;
        nREPLACE    := 1;
      else
        -- излишки - приход
        sRES_TYPE   := 'Приход';
        sSTORE_ND   := 1;
        sCELL_ND    := 0;
        sCELL_NN    := 1;
        nREPLACE_ND := 1;
        nREPLACE    := 0;
      end if;
      -- статус документа
      if nDOCSTATUS != 0 then
        -- Отработан - ничего недоступно
        sRES_TYPE   := 'Документ отработан';
        sSTORE      := null;
        sCELL       := null;
        sSTORE_ND   := 0;
        sCELL_ND    := 0;
        sCELL_NN    := 1;
        nREPLACE_ND := 0;
        nREPLACE    := 0;
      end if;
    end if;
  
    -- указали склад
    if SATRIB = 'SSTORE' then
      sCELL_ND := 1;
    end if;
  
    -- указали МХ
    if SATRIB = 'SCELL' then
      sCELL     := SCELL;
      sSTORE_ND := 0;
      sCELL_ND  := 1;
      sCELL_NN  := 1;
    end if;
  
    --
    /*if utilizer in ('CITK_MARKOV') then
        sSTORE_ND   := 1;
        sCELL_ND    := 1;
    end if;*/
  
  end WROFFACTS_PRMS_FE;

end UDO_PKG_STRPLRESJRNL_MASS_INS;
/
