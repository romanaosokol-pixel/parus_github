create or replace procedure UDO_P_TRINVDEPT_MAKEROUTLST
(
  nCOMPANY                  in number,    -- Организация
  nIDENT                    in number,    -- Идентификатор процесса
  nRN                       in number,    -- Регистрационный номер расходной накладной на отпуск в подразделение
  sCATALOG                  in varchar2,  -- Каталог
  sDOCTYPE                  in varchar2,  -- Тип документа
  sDOCPREF                  in varchar2,  -- Префикс документа
  dDOCDATE                  in date,      -- Дата документа
  nSIGN_CONFIRM             in number,    -- Признак формирования с подтверждением (0-нет, 1-да)
  nIDENT_BUFF               out number,   -- Идентификатор записей буфера (null, 0 - нет записей)
  nIDENT_MSG                out number,   -- Идентификатор записей журнала сообщений (null, 0 - нет сообщений)
  nSAVE_DOCS                in number default 0  -- Сохранять регистрационный номера документов (0-нет, 1-да)
) is
/*
  -- Author  : ЦИТК ПАРУС (ASTAFIEV_D)
  -- Created : 24.05.2023
  -- Purpose : Действие "Сформировать маршрутные листы на ремонт" раздела "Расходные накладные на отпуск в подразделения"
  Алгоритм.
  - формирование возможно только для расходных накладных, у которых указан Вид отгрузки «Ремонт».
  - Получатель не должен быть склад – только подразделение и МОЛ. Соответственно, только отработка как факт. Это необходимо, чтобы передаваемое изделие не находилось в товарных запасах.
  - Для каждой строки расходной накладной формируется отдельный МЛ
  - Форма указания параметров:
    - Тип документа - ТП Ремонт. Закрыт для редактирования
    - Префикс – год даты документа
    - Дата – текущая дата. Доступно для редактирования
   - Заказ – номер лицевого счета из заголовка расходной накладной. Закрыт для редактирования
    - Каталог – корневой каталог раздела «Маршрутные листы». Доступно для редактирования. Выбор из каталогов раздела.
  - Параметры МЛ, которые устанавливаются в процедуре формирования:
    - Изделие – материальный ресурс по спецификации накладной.
    - Количество – количество по спецификации накладной. Как правило серийные изделия и количество всегда 1.
    - Номер МЛ – автоматически по типу и префиксу
    - В подразделе «Серийные номера изделий» указать серийный номер изделия из спецификации. Указать именно в подразделе, а не в шапке МЛ.
    - Состояние – новый.
  - Добавить линки:
     - между заголовком накладной и МЛ
     - между спецификацией накладной и МЛ.
 */
  nCRN            PKG_STD.tREF;
  nCATALOG        PKG_STD.tREF;     -- Каталог маршрутного листа
  nDOCTYPE        PKG_STD.tREF;     -- Тип документа
  nMATRES         PKG_STD.tREF;
  nRTLST          PKG_STD.tREF;
  sSHEEPVIEW      PKG_STD.tSTRING;
  -- Служебные
  nTRUE_REC       number := 0;      -- Признак формирования хотя бы одной записи (null - ошибка, 0 - нет, 1- да)
  nTMP            number;
  sTMP            PKG_STD.tSTRING;

  /* добавление сообщения */
  procedure ADD_MSG
  (
    nRECTYPE        in number,  -- Вид сообщения: 0 - Сообщение, 1- Предупреждение, 2 - Ошибка
    sMSG            in varchar2 -- Текст сообщения
  ) is
    nMSG            PKG_STD.tREF;
  begin
    if ( nIDENT_MSG = 0 ) then
      nIDENT_MSG := GEN_IDENT();
    end if;

    P_MSGJOURNAL_BASE_INSERT(
        nIDENT            => nIDENT_MSG,
        nRECTYPE          => nRECTYPE,
        sMSG_TEXT         => sMSG,
        nRN               => nMSG
        );
  end ADD_MSG;

/* ОСНОВНАЯ ПРОЦЕДУРА */
begin
  /* Инициализация */
  nIDENT_BUFF := 0;
  nIDENT_MSG  := 0;

  /* Считывание записи */
  begin
    select t.crn, s.code
      into nCRN, sSHEEPVIEW
      from transinvdept t,
           dicshpvw     s
      where t.rn        = nRN
        and t.company   = nCOMPANY
        and t.sheepview = s.rn;
  exception
    when NO_DATA_FOUND then
         PKG_MSG.RECORD_NOT_FOUND(0, nRN, 'GoodsTransInvoicesToDepts');
  end;

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY, null, nCRN, 'GoodsTransInvoicesToDepts', 'UDO_TRINVDEPT_MAKEROUTLST', 'TRANSINVDEPT', nRN);

  /* Проверка */
  if cmp_vc2(upper(sSHEEPVIEW), 'РЕМОНТ') = 0 then
    p_exception(0, 'Формирование ремонтной ведомости возможно только для расходной накладной с видом отгрузки «Ремонт».');
  end if;
  
  /* Разрешение ссылок */

  -- Каталог
  if sCATALOG is not null then
    FIND_ACATALOG_NAME_EX(0,0, nCOMPANY, null, 'CostRouteLists', sCATALOG, nCATALOG);
  else
    FIND_ROOT_CATALOG(nCOMPANY, 'CostRouteLists', nCATALOG);
  end if;

  -- Тип документа
  if rtrim(sDOCTYPE) is not null then
    FIND_DOCTYPES_CODE_EX(0,0, nCOMPANY, sDOCTYPE, nDOCTYPE);
  end if;

  /* буфер для наследования документов: конструктор */
  PKG_INHIER.CONSTRUCTOR_EXT( nCOMPANY,nIDENT );
  /* подготовка к привязке документа */
  PKG_INHIER.PREP_LINK( nIDENT );

  /* регистрация входного раздела */
  PKG_INHIER.SET_IN_UNIT( nIDENT,0,'GoodsTransInvoicesToDepts','UDO_TRINVDEPT_MAKEROUTLST','TRANSINVDEPT' );
  --PKG_INHIER.SET_IN_UNIT( nIDENT,1,'GoodsTransInvoicesToDeptsSpecs' );
  /* регистрация выходного раздела */
  PKG_INHIER.SET_OUT_UNIT( nIDENT,0,'CostRouteLists' );

  /* установка входного документа */
  PKG_INHIER.SET_IN_DOC( nIDENT,0,nRN,nCRN );

  /* Для каждой строки расходной накладной формируется отдельный маршрутный лист */
  for rec in (
      select T.JUR_PERS, T.FACEACC, M.PRN as NOMEN,
             TS.*
        from TRANSINVDEPT      T,
             TRANSINVDEPTSPECS TS,
             NOMMODIF          M,
             (select DOCUMENT from SELECTLIST SL where IDENT = nIDENT and SL.UNITCODE = 'GoodsTransInvoicesToDeptsSpecs') SL
        where T.RN        = nRN
          and TS.PRN      = T.RN
          and TS.NOMMODIF = M.RN
          and F_DOCLINKS_LINK_OUT_DOC('GoodsTransInvoicesToDeptsSpecs', TS.RN, 'CostRouteLists') is null
          -- Нижеследующие два условия имеют такой смысл:
          -- Отбирать из спецификации только те записи которые есть в SELECTLIST,
          -- а если SELECTLIST пустой, то отбирать все записи
          and TS.RN = SL.DOCUMENT (+)
          and ((SL.DOCUMENT is not null) or not exists(select null from SELECTLIST where IDENT = nIDENT and UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'))
         ---------------------------------------------------------------------------------------------
      ) loop

      /* установка входного документа */
     -- PKG_INHIER.SET_IN_DOC( nIDENT,1,rec.rn );

      /* Подбор материального ресурса */
      P_FCMATRESOURCE_CHOICE(1, nCOMPANY, rec.nomen, rec.nommodif, nMATRES);

      /* Добавление записи в буфер формирования */
      UDO_PKG_FCRTLSTBUF.DOC_BASE_INSERT(
          nCOMPANY          => nCOMPANY,
          nIDENT            => nIDENT,
          nCRN              => nCATALOG,
          nDOCTYPE          => nDOCTYPE,
          sDOCPREF          => sDOCPREF,
          sDOCNUMB          => null,
          dDOCDATE          => dDOCDATE,
          sBARCODE          => null,
          nJUR_PERS         => rec.jur_pers,
          nSTATE            => 0,
          dCHANGE_DATE      => null,
          nFACEACC          => rec.faceacc,
          nPR_COND          => null,
          nMATRES           => nMATRES,
          nNOMCLASSIF       => null,
          nARTICLE          => null,
          nQUANT            => rec.quant,
          nMATRES_PLAN      => null,
          nMEASURE_TYPE     => 0,
          nQUANT_PLAN       => 0,
          nMATRES_FACT      => null,
          nQUANT_FACT       => 0,
          dOUT_DATE         => null,
          nBLANK            => null,
          nDETAILS_COUNT    => null,
          nSUPPLY           => null,
          nSTORAGE          => null,
          nSTORAGE_IN       => null,
          nPRODCMP          => null,
          nPRODCMPSP        => null,
          dREL_DATE         => null,
          nREL_QUANT        => 0,
          nPRIOR_ORDER      => null,
          nPRIOR_PARTY      => null,
          nROUTSHT          => null,
          nROUTE            => null,
          nCALC_SCHEME      => null,
          nPER_MATRES       => null,
          nCOST_ARTICLE     => null,
          nVALID_DOCTYPE    => null,
          sVALID_DOCNUMB    => null,
          dVALID_DOCDATE    => null,
          sNOTE             => null,
          nPARTY            => null,
          dEXEC_DATE        => null,
          nCATEGORY         => 0,
          nSEP_LSTSP        => null,
          sSEP_NUMB         => null,
          sINT_NUMB         => null,
          nRN               => nRTLST,
          nSOURCE_RN        => rec.rn,
          sSOURCE_UNIT      => 'GoodsTransInvoicesToDeptsSpecs'
          );

      if rec.article is not null then
        /* Добавление серийного номера в буфер формирования */
        UDO_PKG_FCRTLSTBUF.SERNUM_BASE_INSERT(
            nCOMPANY          => nCOMPANY,
            nPRN              => nRTLST,
            nIDENT            => nIDENT,
            nARTICLE          => rec.article,  -- Серийный номер изделия
            nRN               => nTMP
            );
      end if;

      /* фиксируем добавление записи */
      nTRUE_REC := nTRUE_REC + 1;

  end loop;

  /* Должный быть выполненны операции */
  if nvl(nTRUE_REC,0) = 0 then
    nIDENT_BUFF := 0;
    /* если записей не создали, то удаляем параметры связывания */
    PKG_INHIER.DESTRUCTOR( nIDENT );
    p_exception(0, 'Нет данных для формирования документа.');
  else
    /* привязка входного документа к буферному */
    PKG_INHIER.LINK_IN( nIDENT );
    /* требуется подтверждение */
    if nvl(nSIGN_CONFIRM,0) = 1 then
      nIDENT_BUFF := nIDENT;
    end if;
  end if;

  /* При отработке без подтверждения */
  if nvl(nSIGN_CONFIRM,0) = 0 then
    /* Переносим из буфера */
    UDO_P_FCRTLSTBUF_REPLACE(
        nCOMPANY        => nCOMPANY,
        nIDENT          => nIDENT,
        nMAKE_DOCLINK   => 1,
        nSAVE_DOCS      => nvl(nSAVE_DOCS,0)
        );
  end if;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY, null, nCRN, 'GoodsTransInvoicesToDepts', 'UDO_TRINVDEPT_MAKEROUTLST', 'TRANSINVDEPT', nRN);

end UDO_P_TRINVDEPT_MAKEROUTLST;
/

