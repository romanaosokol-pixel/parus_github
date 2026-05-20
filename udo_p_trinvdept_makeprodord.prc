create or replace procedure UDO_P_TRINVDEPT_MAKEPRODORD
(
  nCOMPANY                  in number,    -- Организация
  nIDENT                    in number,    -- Идентификатор процесса
  nRN                       in number,    -- Регистрационный номер расходной накладной на отпуск в подразделение
  sCATALOG                  in varchar2,  -- Каталог
  sDOCTYPE                  in varchar2,  -- Тип документа
  sDOCPREF                  in varchar2,  -- Префикс документа
  dDOCDATE                  in date,      -- Дата документа
  sAGENT                    in varchar2,  -- Ответственный исполнитель
  sSUBDIV                   in varchar2,  -- Ответственное подразделение исполнитель
  dRELEASE_DATE             in date,      -- Дата исполнения
  nSIGN_CONFIRM             in number,    -- Признак формирования с подтверждением (0-нет, 1-да)
  nIDENT_BUFF               out number,   -- Идентификатор записей буфера (null, 0 - нет записей)
  nIDENT_MSG                out number,   -- Идентификатор записей журнала сообщений (null, 0 - нет сообщений)
  nCONSOLIDATE              in number default 0 -- Консолидировать позиции в единый заказ (0-нет; 1-да)
) is
/*
  -- Author  : ЦИТК ПАРУС (ASTAFIEV_D)
  -- Created : 29.05.2023
  -- Purpose : Действие "Сформировать заказы на производство" раздела "Расходные накладные на отпуск в подразделения"
  Алгоритм.
  - формирование возможно только для расходных накладных, у которых указан Вид отгрузки «Ремонт».
  - Получатель не должен быть склад – только подразделение и МОЛ. Соответственно, только отработка как факт. Это необходимо, чтобы передаваемое изделие не находилось в товарных запасах.
  - Для каждой строки расходной накладной формируется отдельный МЛ
  - Форма указания параметров:
    - Тип документа - ТП Ремонт. Закрыт для редактирования
    - Префикс – год даты документа
    - Дата – текущая дата. Доступно для редактирования
   - Заказ – номер лицевого счета из заголовка расходной накладной. Закрыт для редактирования
    - Каталог – корневой каталог раздела «Заказы на производство». Доступно для редактирования. Выбор из каталогов раздела.
  - Параметры МЛ, которые устанавливаются в процедуре формирования:
    - Изделие – материальный ресурс по спецификации накладной.
    - Количество – количество по спецификации накладной. Как правило серийные изделия и количество всегда 1.
    - Номер МЛ – автоматически по типу и префиксу
    - В подразделе «Серийные номера изделий» указать серийный номер изделия из спецификации. Указать именно в подразделе, а не в шапке МЛ.
    - Состояние – новый.
  - Связи формируются:
     - между заголовком накладной и заказом на производство;
     - между спецификацией накладной и спецификацией заказа на производство.
 */
  bCONSOLIDATE_   boolean := ( nvl(nCONSOLIDATE,0) = 1 ); -- Консолидировать позиции в единый заказ 
  nCRN            PKG_STD.tREF;
  nCATALOG        PKG_STD.tREF;     -- Каталог маршрутного листа
  nDOCTYPE        PKG_STD.tREF;     -- Тип документа
  sDOCNUMB        PKG_STD.tSTRING;  -- Номер документа
  nAGENT          PKG_STD.tREF;     -- Ответственный исполнитель
  nSUBDIV         PKG_STD.tREF;     -- Ответственное подразделение исполнитель
  nCURRENCY       PKG_STD.tREF;     -- Валюта
--  nMATRES         PKG_STD.tREF;
  nDOC            PKG_STD.tREF;
  nSPEC           PKG_STD.tREF;
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

  /* Генерация следующего номера записи буфера формирования заказа на производство */
  procedure DOC_GETNEXTNUMB(
            nCOMPANY             in number,    -- Организация
            nIDENT               in number,    -- Идентификатор
            nDOC_TYPE            in number,    -- Тип документа
            sDOC_PREF            in varchar2,  -- Префикс
            sDOC_NUMB            out varchar2  -- Номер документа
            ) is
  begin

    PKG_DOCUMENT.NEXT_NUMBER(
        nCOMPANY        => nCOMPANY,
        nFLD_SIZE       => 80,
        sUK_OPTION      => null,
        sSEC_TBL        => 'PRODUCTORD',
        sSEC_JPRS_FLD   => null,
        sSEC_YEAR_FLD   => null,
        sSEC_TYPE_FLD   => 'ORD_DOCTYPE',
        sSEC_PREF_FLD   => 'ORD_PREF',
        sSEC_NUMB_FLD   => 'ORD_NUMB',
        sBUF_TBL        => 'PRODUCTORDBUF',
        sBUF_IDENT_FLD  => 'IDENT',
        sBUF_JPRS_FLD   => null,
        sBUF_YEAR_FLD   => null,
        sBUF_TYPE_FLD   => 'ORD_DOCTYPE',
        sBUF_PREF_FLD   => 'ORD_PREF',
        sBUF_NUMB_FLD   => 'ORD_NUMB',
        nIDENT          => nIDENT,
        nJUR_PERS       => null,
        nYEAR           => null,
        nTYPE           => nDOC_TYPE,
        sPREF           => sDOC_PREF,
        sNUMB           => sDOC_NUMB
        );

  end DOC_GETNEXTNUMB;

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
  PKG_ENV.PROLOGUE(nCOMPANY, null, nCRN, 'GoodsTransInvoicesToDepts', 'UDO_TRINVDEPT_MAKEPRODORD', 'TRANSINVDEPT', nRN);

  /* Проверка */
  if cmp_vc2(upper(sSHEEPVIEW), 'РЕМОНТ') = 0 then
    p_exception(0, 'Формирование ремонтного заказа на производство возможно только для расходной накладной с видом отгрузки «Ремонт».');
  end if;
  
  /* Разрешение ссылок */

  -- Каталог
  if sCATALOG is not null then
    FIND_ACATALOG_NAME_EX(0,0, nCOMPANY, null, 'ProductionOrders', sCATALOG, nCATALOG);
  else
    FIND_ROOT_CATALOG(nCOMPANY, 'ProductionOrders', nCATALOG);
  end if;

  -- Тип документа
  if rtrim(sDOCTYPE) is not null then
    FIND_DOCTYPES_CODE_EX(0,0, nCOMPANY, sDOCTYPE, nDOCTYPE);
  end if;

  -- Ответственный исполнитель
  if rtrim(sAGENT) is not null then
    FIND_AGNLIST_CODE(0,0, nCOMPANY, sAGENT, nAGENT);
  end if;

  -- Ответственное подразделение исполнитель
  FIND_SUBDIVS_CODE(0, nCOMPANY, sSUBDIV, nSUBDIV);

  /* буфер для наследования документов: конструктор */
  PKG_INHIER.CONSTRUCTOR_EXT( nCOMPANY,nIDENT );
  /* подготовка к привязке документа */
  PKG_INHIER.PREP_LINK( nIDENT );

  /* регистрация входного раздела */
  PKG_INHIER.SET_IN_UNIT( nIDENT,0,'GoodsTransInvoicesToDepts','UDO_TRINVDEPT_MAKEPRODORD','TRANSINVDEPT' );
  PKG_INHIER.SET_IN_UNIT( nIDENT,1,'GoodsTransInvoicesToDeptsSpecs' );
  /* регистрация выходного раздела */
  PKG_INHIER.SET_OUT_UNIT( nIDENT,0,'ProductionOrders' );
  PKG_INHIER.SET_OUT_UNIT( nIDENT,1,'ProductionOrdersSpecs');

  /* установка входного документа */
  PKG_INHIER.SET_IN_DOC( nIDENT,0,nRN,nCRN );

  /* Для каждой строки расходной накладной формируется отдельный маршрутный лист */
  for rec in (
      select T.SUBDIV, T.FACEACC, T.GRAPHPOINT, M.PRN as NOMEN,
             TS.*
        from TRANSINVDEPT      T,
             TRANSINVDEPTSPECS TS,
             NOMMODIF          M,
             (select DOCUMENT from SELECTLIST SL where IDENT = nIDENT and SL.UNITCODE = 'GoodsTransInvoicesToDeptsSpecs') SL
        where T.RN        = nRN
          and TS.PRN      = T.RN
          and TS.NOMMODIF = M.RN
          and F_DOCLINKS_LINK_OUT_DOC('GoodsTransInvoicesToDeptsSpecs', TS.RN, 'ProductionOrders') is null
          -- Нижеследующие два условия имеют такой смысл:
          -- Отбирать из спецификации только те записи которые есть в SELECTLIST,
          -- а если SELECTLIST пустой, то отбирать все записи
          and TS.RN = SL.DOCUMENT (+)
          and ((SL.DOCUMENT is not null) or not exists(select null from SELECTLIST where IDENT = nIDENT and UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'))
         ---------------------------------------------------------------------------------------------
      ) loop

      /* Подбор материального ресурса */
      --P_FCMATRESOURCE_CHOICE(1, nCOMPANY, rec.nomen, rec.nommodif, nMATRES);

      if rec.Faceacc is not null then
        /* валюта лицевого счета */
        begin
          select CURRENCY
            into nCURRENCY
            from FACEACC
           where RN = rec.Faceacc;
        exception
          when NO_DATA_FOUND then
            PKG_MSG.RECORD_NOT_FOUND(rec.Faceacc, 'FaceAccounts');
        end;
      else
        -- Базовая валюта
        nCURRENCY := F_CURBASE_GET_RN(0, nCOMPANY);
      end if;


      if ( nDOC is null or not bCONSOLIDATE_ ) then
          /* Генерация следующего номера */
          DOC_GETNEXTNUMB(nCOMPANY, nIDENT, nDOCTYPE, sDOCPREF, sDOCNUMB);

          /* Добавление записи в буфер формирования */
          P_PRODUCTORDBUF_BASE_INSERT(
              nCOMPANY        => nCOMPANY,
              nCRN            => nCATALOG,
              nIDENT          => nIDENT,
              nIN_DOCRN       => rec.rn,
              sUNITCODE       => 'GoodsTransInvoicesToDeptsSpecs',
              sORD_PREF       => sDOCPREF,
              sORD_NUMB       => sDOCNUMB,
              nAGENT          => nAGENT,
              nFACEACC        => rec.faceacc,
              nGRAPHPOINT     => rec.graphpoint,
              nSUBDIV         => nSUBDIV,
              nORD_DOCTYPE    => nDOCTYPE,
              dORD_DATE       => dDOCDATE,
              nORD_STATE      => 0,
              dSTATE_DATE     => null,
              nCURRENCY       => nCURRENCY,
              nSTORE          => null,
              nACC_AGENT      => null,
              nACC_SUBDIV     => null,
              dRELEASE_DATE   => dRELEASE_DATE,
              nORD_PERIOD     => 0,
              nUSECALENDAR    => 0,
              nPERIOD_CORR    => 1,
              nPERIOD_QUANT   => 1,
              nPERIOD_TYPE    => 0,
              nPERIOD_LEN     => 1,
              nATSAMETIME     => 1,
              sNOTE           => null,
              sBARCODE        => null,
              nMAT_PRICE      => 0,
              nFCEXACT        => null,
              dFRM_DATE       => null,
              nCOEFF_TARIF    => null,
              nCALCSCHM       => null,
              nTARIF          => null,
              nREADY_PROD     => 0,
              nCOST_PLAN      => 0,
              nCOST_FACT      => 0,
              nCOST_NPZ       => 0,
              nRN             => nDOC
              );

          /* установка буферного документа 0 */
          PKG_INHIER.SET_BUFF_DOC(nIDENT, 0, nDOC);

          /* создание в буфере записи периода исполнения заказа на производство */
          P_PRODUCTORDPBUF_BASE_INSERT(
              nCOMPANY        => nCOMPANY,
              nPRN            => nDOC,
              nPERF_NUMB      => 1,
              dPERF_DATE      => dRELEASE_DATE,
              nPSUMM          => 0,
              nPERF_PLAN_SUM  => 0,
              nPERF_FACT_SUM  => 0,
              nRN             => nTMP
              );

          /* фиксируем добавление записи */
          nTRUE_REC := nTRUE_REC + 1;
      end if;

      /* установка входного документа */
      PKG_INHIER.SET_IN_DOC( nIDENT,1,rec.rn );

      /* Добавление строки спецификации в буфер формирования */
      P_PRODUCTORDSBUF_BASE_INSERT(
          nCOMPANY      => nCOMPANY,
          nPRN          => nDOC,
          nIDENT        => nIDENT,
          nNOMEN        => rec.nomen,
          nNOM_PACK     => null,
          nNOM_MODIF    => rec.nommodif,
          nNOMMOD_PACK  => rec.nomnmodifpack,
          nPRODUCT      => rec.article,
          nEXP_PRICE    => rec.price,
          nPR_MEAS      => rec.pricemeas,
          nSTORE        => null,
          sNOTE         => null,
          nCOST_PLAN    => 0,
          nCOST_FACT    => 0,
          nCOST_NPZ     => 0,
        -- для исполнения.
          dACTPF_DATE   => dRELEASE_DATE,
          nACTM_QUANT   => rec.quant,
          nACTA_QUANT   => rec.quantalt,
          nACTSUMM      => rec.summwithnds,
          nIGNOREPERF   => 0,   -- 1 - игнорировать исполнение
          nRN           => nSPEC
          );

      /* установка буферного документа 1 */
      PKG_INHIER.SET_BUFF_DOC(nIDENT, 1, nSPEC);
      /* привязка входного документа к буферному */
      PKG_INHIER.LINK_IN(nIDENT);

  end loop;

  /* Должный быть выполненны операции */
  if nvl(nTRUE_REC,0) = 0 then
    nIDENT_BUFF := 0;
    /* если записей не создали, то удаляем параметры связывания */
    PKG_INHIER.DESTRUCTOR( nIDENT );
    p_exception(0, 'Нет данных для формирования документа.');
  else
    /* требуется подтверждение */
    if nvl(nSIGN_CONFIRM,0) = 1 then
      nIDENT_BUFF := nIDENT;
    end if;
  end if;

  /* При отработке без подтверждения */
  if nvl(nSIGN_CONFIRM,0) = 0 then
    /* Переносим из буфера */
    P_PRODUCTORDBUF_REPLACE(
        nCOMPANY        => nCOMPANY,
        nIDENT          => nIDENT,
        nMOVE_PERIODS   => 0
        );
  end if;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY, null, nCRN, 'GoodsTransInvoicesToDepts', 'UDO_TRINVDEPT_MAKEPRODORD', 'TRANSINVDEPT', nRN);

end UDO_P_TRINVDEPT_MAKEPRODORD;
/

