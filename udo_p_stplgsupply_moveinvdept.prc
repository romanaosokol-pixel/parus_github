create or replace procedure UDO_P_STPLGSUPPLY_MOVEINVDEPT
(
  nCOMPANY        in number,      -- Организация
  nIDENT          in number,      -- Идентификатор процесса
  nCRN            in number,      -- Каталог документа
  nDOCTYPE        in number,      -- Тип документа
  sDOCPREF        in varchar2,    -- Префикс номера документа
  nSTORE          in number,      -- Склад
  nCELL           in number,      -- Место хранения - ячейка, куда перемещается товар
  nSHEEPVIEW      in number,      -- Вид отгрузки
  nSTOPER         in number,      -- Складская операция (расход)
  nIN_STOPER      in number,      -- Складская операция (приход)
  nQUANT          in number,      -- Количество перемещаемого товара в основной ЕИ
  nQUANTALT       in number,      -- Количество перемещаемого товара в дополнительной ЕИ
  sNOTE           in varchar2,    -- Примечание
  nCOUNT          out number,     -- Количество отработанных записей
  nIDENT_MSG      out number,     -- Идентификатор записей журнала сообщений (null, 0 - нет сообщений)
  nIDENT_DOC      out number,     -- Идентификатор записей расходных накладных (null, 0 - нет сформированных документов)
  nCONSOLIDATE    in number  default 1,    -- Консолидировать позиции (0-нет; 1-да)
  nSIGN_WORK      in number  default 1,    -- Отработка сформированных документов (0-нет; 1-да)
  nSAVE_DOCS      in number  default 0     -- Сохранять регистрационный номера документов (0-нет; 1-да)
)
as
  /* Формирование перемещения между местами хранения через документ "Расходная накладная на отпуск в подразделения" */
  type tDOCS       is table of number; -- Список сформированных документов
  rDOCS            tDOCS := tDOCS();
  dOPER_DATE       PKG_STD.tLDATE;   -- дата и время операции (при необходимости внести в параметры процедуры)
  nQUANT_SIGN      PKG_STD.tNUMBER;  -- признак (0 - переносить требуемое кол-во, 1 - переносить всё доступное)
  nMOVE_QUANT      PKG_STD.tQUANT;
  nMOVE_QUANTALT   PKG_STD.tQUANT;
  nMOVE_QUANTPACK  PKG_STD.tQUANT;
  nRES             PKG_STD.tNUMBER;
  nRES_QUANT       PKG_STD.tQUANT;
  nOPER_KIND       PKG_STD.tNUMBER;
  bCONSOLIDATE_    boolean := ( nvl(nCONSOLIDATE,1) = 1 ); -- Консолидировать позиции
  bSIGN_NEW        boolean;
--
  rMDL             TRANSINVDEPT%rowtype;      -- Запись образца заполнения документа
  rDOC             TRANSINVDEPT%rowtype;      -- Запись документа
  rSPEC            TRANSINVDEPTSPECS%rowtype; -- Запись спецификации
  nDOC             PKG_STD.tREF;
  sMSG             PKG_STD.tSTRING;
-- временные переменные
  nTMP             PKG_STD.tLNUMBER;
--  sTMP             PKG_STD.tSTRING;

  /* добавление сообщения */
  procedure ADD_MSG(
            nRECTYPE        in number,  -- Вид сообщения: 0 - Сообщение, 1- Предупреждение, 2 - Ошибка
            sMSG            in varchar2 -- Текст сообщения
            ) is
    nMSG            PKG_STD.tREF;
  begin
    if rtrim(sMSG) is not null then
      if ( nIDENT_MSG = 0 ) then
        nIDENT_MSG := GEN_IDENT();
      end if;

      P_MSGJOURNAL_BASE_INSERT(
          nIDENT            => nIDENT_MSG,
          nRECTYPE          => nRECTYPE,
          sMSG_TEXT         => sMSG,
          nRN               => nMSG
          );
    end if;
  end ADD_MSG;

  /* ПАРАМЕТРЫ ПО УМОЛЧАНИЮ */
  procedure DOC_DEFAULT(
            rREC            in out transinvdept%rowtype -- Запись
            ) is
    sVAL      PKG_STD.tSTRING;
    rFCA      faceacc%rowtype;      -- Запись лицевого счета
    rIN_STORE azsazslistmt%rowtype; -- Запись склада-получателя
    nRESULT   number;
  begin
    -- Каталог
    if rREC.Crn is null then
      sVAL := GET_OPTIONS_STR('Realiz_InvDept_Catalog', rREC.Company);
      FIND_ACATALOG_NAME_EX(0, 1, rREC.Company, null, 'GoodsTransInvoicesToDepts', sVAL, rREC.Crn);
    end if;
    -- Корневой каталог
    if rREC.Crn is null then
      FIND_ROOT_CATALOG_EX(0, rREC.Company, null, 'GoodsTransInvoicesToDepts', rREC.Crn);
    end if;

    -- Тип
    if rREC.Doctype is null then
      sVAL := UDO_GET_OPTIONS_STR(0, 'Realiz_InvDept_DocType', rREC.Company);
      FIND_DOCTYPES_CODE_EX(0, 1, rREC.Company, sVAL, rREC.Doctype);
    end if;
    -- Дата документа
    if rREC.Docdate is null then
      rREC.Docdate := P_TOOLS_NOW;
    end if;
    -- Префикс документа
    if rtrim(rREC.Pref) is null then
      rREC.Pref := to_char(rREC.Docdate,'YYYY');
    end if;
    -- Номер документа
    if rtrim(rREC.Numb) is null then
      if rREC.Doctype is not null then
        P_TRANSINVDEPT_BASE_NEXTNUMB(rREC.Company, rREC.Jur_Pers, rREC.Docdate, rREC.Doctype, rREC.Pref, rREC.Numb);
      end if;
    end if;

    -- Лицевой счет
    if rREC.Faceacc is not null then
      P_FACEACC_EXISTS(rREC.Faceacc, rFCA);
    end if;
    
    -- МОЛ склада
    if rREC.Mol is null and rREC.Store is not null then
      begin
      select t.azs_agent into rREC.Mol
             from azsazslistmt t
             where t.rn = rREC.Store;
      exception when NO_DATA_FOUND then
                PKG_MSG.RECORD_NOT_FOUND(0, rREC.Store, 'AZSListView');
      end;
    end if;

    -- Складская операция
    if rREC.Stoper is null then
      sVAL := UDO_GET_OPTIONS_STR(0, 'Realiz_InvDept_StoreOper', rREC.Company);
      if rtrim(sVAL) is not null then
        FIND_DICSTOPR_CODE(0, nCOMPANY, sVAL, rREC.Stoper);
      end if;
    end if;

    -- Вид отгрузки
    if rREC.Sheepview is null then
      sVAL := UDO_GET_OPTIONS_STR(0, 'Realiz_InvDept_ShipType', rREC.Company);
      if rtrim(sVAL) is not null then
        FIND_DICSHPVW_CODE(0, nCOMPANY, sVAL, rREC.Sheepview);
      end if;
    end if;

    -- Склад получателя
    if rREC.In_Store is not null then
      begin
      select t.* into rIN_STORE
             from azsazslistmt t
             where t.rn = rREC.In_Store;
      exception when NO_DATA_FOUND then
                PKG_MSG.RECORD_NOT_FOUND(0, rREC.In_Store, 'AZSListView');
      end;
    end if;

    -- МОЛ склада получателя
    if rREC.In_Mol is null then
      rREC.In_Mol := rIN_STORE.Azs_Agent;
    end if;

    -- Складская операция
    if rREC.In_Stoper is null then
      sVAL := UDO_GET_OPTIONS_STR(0, 'Realiz_InvDept_InStoreOper', rREC.Company);
      if rtrim(sVAL) is not null then
        FIND_DICSTOPR_CODE(0, nCOMPANY, sVAL, rREC.In_Stoper);
      end if;
    end if;

    -- Валюта
    if rREC.Currency is null then
      rREC.Currency := F_CURBASE_GET_RN(1, rREC.Company);
      rREC.Curcours := 1;
      rREC.Curbase  := 1;
    end if;

    -- Кросс-курс лицевого счета
    if rREC.Faceacc is not null then
      -- Если валюта лицевого счета отличается от валюты документа
      if rFCA.Currency <> rREC.Currency then
          if (rREC.Fa_Curcours is null or rREC.Fa_Curbase is null) then
              P_CURRENCY_GET_COURSE_BASE(
                  nFLAG_SMART       => 1,                -- признак генерации исключения (0 - да, 1 - нет)
                  nCOMPANY          => rREC.Company,     -- организация
                  nCURRENCY_FROM    => rREC.Currency,    -- исходная валюта (если null - подразумевается базовая, но должна быть задана валюта эквивалента)
                  nCURRENCY_TO      => rFCA.Currency,    -- валюта эквивалента (если null - подразумевается базовая, но должна быть задана исходная валюта)
                  dCOURSE_DATE      => rREC.Docdate,     -- дата поиска курса
                  nOPERSIGN         => 1,                -- признак использования в учете (0 - внутренний курс, 1 - курс ЦБ)
                  nPLANSIGN         => 0,                -- тип курса (0 - не плановый, 1 - плановый)
                  nACCTYPE          => null,             -- вид учета
                  nUSESIGN          => 0,                -- признак использования (0 - везде, 1 - для сумм в базовой валюте, 2 - для сумм в валюте отчетности)
                  nCOURSE_SUM       => rREC.Fa_Curcours, -- единица котировки
                  nCOURSE_EQUAL     => rREC.Fa_Curbase,  -- курс
                  nRESULT           => nRESULT           -- результат поиска (0 - нет курсов, 1 - курс найден)
                  );
          end if;
      else
         rREC.Fa_Curcours := 1;
         rREC.Fa_Curbase  := 1;
      end if;
    else
      rREC.Fa_Curcours := null;
      rREC.Fa_Curbase  := null;
    end if;

    -- Курс валюты склада получателя
    if rREC.In_Store is not null then
      -- Если валюта склада получателя отличается от валюты документа
      if rIN_STORE.Currency <> rREC.Currency then
          -- Курс не задан
          if (rREC.In_Curcours is null or rREC.In_Curbase is null) then
              P_CURRENCY_GET_COURSE_BASE(
                  nFLAG_SMART       => 1,                  -- признак генерации исключения (0 - да, 1 - нет)
                  nCOMPANY          => rREC.Company,       -- организация
                  nCURRENCY_FROM    => rREC.Currency,      -- исходная валюта (если null - подразумевается базовая, но должна быть задана валюта эквивалента)
                  nCURRENCY_TO      => rIN_STORE.Currency, -- валюта эквивалента (если null - подразумевается базовая, но должна быть задана исходная валюта)
                  dCOURSE_DATE      => rREC.Docdate,       -- дата поиска курса
                  nOPERSIGN         => 1,                  -- признак использования в учете (0 - внутренний курс, 1 - курс ЦБ)
                  nPLANSIGN         => 0,                  -- тип курса (0 - не плановый, 1 - плановый)
                  nACCTYPE          => null,               -- вид учета
                  nUSESIGN          => 0,                  -- признак использования (0 - везде, 1 - для сумм в базовой валюте, 2 - для сумм в валюте отчетности)
                  nCOURSE_SUM       => rREC.In_Curcours,   -- единица котировки
                  nCOURSE_EQUAL     => rREC.In_Curbase,    -- курс
                  nRESULT           => nRESULT             -- результат поиска (0 - нет курсов, 1 - курс найден)
                  );
          end if;
      else
         rREC.In_Curcours := 1;
         rREC.In_Curbase  := 1;
      end if;
    else
      rREC.In_Curcours := null;
      rREC.In_Curbase  := null;
    end if;
    
  end DOC_DEFAULT;

  /* СОЗДАНИЕ РАСХОДНОЙ НАКЛАДНОЙ НА ОТПУСК В ПОДРАЗДЕЛЕНИЕ */
  procedure DOC_CREATE(
            rREC            in out nocopy TRANSINVDEPT%rowtype -- Запись
            ) is
  begin
    /* Параметры по умолчанию */
    DOC_DEFAULT(rREC);

    /* проверка прав доступа */
    PKG_ENV.ACCESS( rREC.Company, null, rREC.Crn, 'GoodsTransInvoicesToDepts', 'TRANSINVDEPT_INSERT' );

    /* Базовое добавление */
    P_TRANSINVDEPT_BASE_INSERT(
        nCOMPANY        => rREC.Company,
        nCRN            => rREC.Crn,
        nJUR_PERS       => rREC.Jur_Pers,
        nDOCTYPE        => rREC.Doctype,
        sPREF           => rREC.Pref,
        sNUMB           => rREC.Numb,
        dDOCDATE        => rREC.Docdate,
        nDIRDOC         => rREC.Dirdoc,
        sDIRNUMB        => rREC.Dirnumb,
        dDIRDATE        => rREC.Dirdate,
        nSTOPER         => rREC.Stoper,
        nFACEACC        => rREC.Faceacc,
        nGRAPHPOINT     => rREC.Graphpoint,
        nSTORE          => rREC.Store,
        nMOL            => rREC.Mol,
        nSHEEPVIEW      => rREC.Sheepview,
        nAGENT          => rREC.Agent,
        nSUBDIV         => rREC.Subdiv,
        nCURRENCY       => rREC.Currency,
        nCURCOURS       => rREC.Curcours,
        nCURBASE        => rREC.Curbase,
        nSUMMWITHNDS    => rREC.Summwithnds,
        nRECIPDOC       => rREC.Recipdoc,
        sRECIPNUMB      => rREC.Recipnumb,
        dRECIPDATE      => rREC.Recipdate,
        nFERRYMAN       => null,
        sGETCONFIRM     => null,
        sWAYBLADENUMB   => null,
        nDRIVER         => null,
        nCAR            => null,
        nROUTE          => null,
        nTRAILER1       => null,
        nTRAILER2       => null,
        nFA_CURCOURS    => rREC.Fa_Curcours,
        nFA_CURBASE     => rREC.Fa_Curbase,
        nIN_STORE       => rREC.In_Store,
        nIN_MOL         => rREC.In_Mol,
        nIN_STOPER      => rREC.In_Stoper,
        nIN_PARTY       => rREC.In_Party,
        sIN_PARTY       => rREC.In_Party_Code,
        nIN_CURCOURS    => rREC.In_Curcours,
        nIN_CURBASE     => rREC.In_Curbase,
        nVALID_DOCTYPE  => rREC.Valid_Doctype,
        sVALID_DOCNUMB  => rREC.Valid_Docnumb,
        dVALID_DOCDATE  => rREC.Valid_Docdate,
        sCOMMENTS       => rREC.Comments,
        sBARCODE        => rREC.Barcode,
        nRESERV_SIGN    => 0,   -- признак резервирования (0-не резервировать, 1-в зависимости от настройки)
        nRN             => rREC.Rn
        );
  end DOC_CREATE;

/* ОСНОВНАЯ ПРОЦЕДУРА */
begin
  /* начальная инициализация */
  dOPER_DATE  := trunc(sysdate); -- Внимание! пока все операции рассматриваем с точностью до одного дня.
  nIDENT_MSG  := 0;
  nCOUNT      := 0;

  /* определяем признак и количество к переносу */
  if (nQUANT is null and nQUANTALT is null) then
    nQUANT_SIGN := 1; -- переносить всё доступное
  else
    nQUANT_SIGN    := 0; -- переносить требуемое кол-во
    nMOVE_QUANT    := nvl(nQUANT, 0);
    nMOVE_QUANTALT := nvl(nQUANTALT, 0);
    /* если требумое количество нулевое - выход */
    if (nMOVE_QUANT = 0) and (nMOVE_QUANTALT = 0) then return; end if;
  end if;

  /* цикл по отмеченным записям товарных запасов на местах хранения */
  for rec in (
      select GS.RN, GS.CELL, GS.JUR_PERS,
             P.RN as GOODSPARTY, P.INDOC, P.NOMMODIF, P.NOMNMODIFPACK, P.SERNUMB, P.COUNTRY, P.GTD,
             GS.GOODSSUPPLY,  GS.ARTICLE, GS.GOODSUNIT, RK.STORE,
             SH.MIN_FA_REST, SH.MIN_FA_RESTALT, nvl(NP.QUANT, 0) QUANT_IN_PACK
        from SELECTLIST        SL,
             STPLGOODSSUPPLY   GS,
             STPLGSSUPPLYHIST  SH,
             GOODSSUPPLY       S,
             GOODSPARTIES      P,
             NOMNMODIFPACK     MP,
             NOMNPACK          NP,
             STPLCELLS         CL,
             STPLRACKS         RK
       where SL.IDENT        = nIDENT
         and SL.UNITCODE     = 'StoragePlacesGoodsSupply'
         and SL.AUTHID       = UTILIZER
         and SL.DOCUMENT     = GS.RN
         and GS.COMPANY      = nCOMPANY
         and GS.RN           = SH.PRN
         and CL.RN           = GS.CELL
         and RK.RN           = CL.PRN
         and SH.DATE_FROM   <= dOPER_DATE
         and (SH.DATE_TO is null or (SH.DATE_TO >= dOPER_DATE))
         and GS.GOODSSUPPLY  = S.RN (+)
         and S.PRN           = P.RN (+)
         and P.NOMNMODIFPACK = MP.RN (+)
         and MP.NOMENPACK    = NP.RN (+)
         and cmp_num(GS.CELL, nCELL) = 0 -- Места хранения должны отличаться
      order by GS.JUR_PERS, RK.STORE -- необходимо для консолидации
      ) loop
      /* фиксация начала выполнения действия */
      PKG_ENV.PROLOGUE( nCOMPANY, null, null, Rec.JUR_PERS, 'StoragePlacesGoodsSupply', 'STPLGOODSSUPPLY_MOVEGOODS', 'STPLGOODSSUPPLY', Rec.RN );

      /* если на МХ есть кол-во в ОЕИ доступное для изъятия */
      if (nQUANT_SIGN = 0) or (Rec.MIN_FA_REST > 0) or (Rec.MIN_FA_RESTALT > 0) then
        /* инициализируем количество к переносу, для случая переноса на доступное кол-во */
        if (nQUANT_SIGN = 1) then
          nMOVE_QUANT    := Rec.MIN_FA_REST;
          nMOVE_QUANTALT := Rec.MIN_FA_RESTALT;
        else
          /* иначе, если задана ГЕ, переносим всегда только 1 штуку */
          if Rec.GOODSUNIT is not null then
            nMOVE_QUANT    := 1;
            nMOVE_QUANTALT := 0;
          end if;
        end if;
        /* проверка возможности списания товара с места хранения */
        /* Внимание! Если nQUANT_SIGN = 0, необходимо выдать сообщение об ошибке, а иначе просто не перемещать */
        P_STRPLRESJRNL_CONSUME_VERIFY( nQUANT_SIGN, nCOMPANY, 1 /* nCHECK_TYPE */, dOPER_DATE, Rec.CELL, Rec.GOODSSUPPLY,
                                       Rec.ARTICLE, Rec.GOODSUNIT, nMOVE_QUANT, nMOVE_QUANTALT, nRES, nTMP, nTMP, sMSG );
        /* Сохраняем в журнале сообщений */
        ADD_MSG(1, sMSG);
        /* если проверка прошла успешно, проверяем возможность размешения товара на месте хранения */
        if (nRES = 1) then
          P_STRPLRESJRNL_INCOME_VERIFY( nQUANT_SIGN, nCOMPANY, 1 /* nCHECK_TYPE */, dOPER_DATE, nCELL, Rec.GOODSSUPPLY,
                                        null/*NOMEN*/, null/*NOMMODIF*/, null/*NOMNMODIFPACK*/, Rec.ARTICLE, Rec.GOODSUNIT,
                                        nMOVE_QUANT, nMOVE_QUANTALT, nRES, nRES_QUANT, sMSG );
          /* Сохраняем в журнале сообщений */
          ADD_MSG(1, sMSG);
          /* если проверка прошла успешно, перемещаем ТЗ на новое МХ */
          if (nRES = 1) then
            /* рассчитываем списываемое кол-во в упаковках, если они есть */
            if (Rec.QUANT_IN_PACK <> 0) then
              nMOVE_QUANTPACK := nMOVE_QUANT / Rec.QUANT_IN_PACK;
            else
              nMOVE_QUANTPACK := 0;
            end if;
            /* определение вида перемещения */
            if nSTORE <> Rec.STORE then
              nOPER_KIND := 0; -- внешнее перемещение
            elsif nSTORE = Rec.STORE then
              nOPER_KIND := 1; -- внутреннее перемещение
            end if;

            /* Смена реквизитов консолидации */
            bSIGN_NEW := ( cmp_num(rMDL.Jur_Pers, rec.jur_pers) = 0 or cmp_num(rMDL.Store, rec.store) = 0 );

            /* Устанавливаем параметры образца заполнения */
            if bSIGN_NEW then
                rMDL := null;
                rMDL.Company  := nCOMPANY;
                rMDL.Jur_Pers := rec.jur_pers;
                rMDL.Crn      := nCRN;
                rMDL.Doctype  := nDOCTYPE;
                rMDL.Docdate  := dOPER_DATE;
                rMDL.Pref     := sDOCPREF;
                rMDL.Sheepview := nSHEEPVIEW;
                rMDL.Store    := rec.store;
                rMDL.Stoper    := nSTOPER;
                rMDL.In_Store  := nSTORE;
                rMDL.In_Stoper := nIN_STOPER;
                rMDL.Comments  := sNOTE;
                /* Параметры по умолчанию */
                DOC_DEFAULT(rMDL);
                rMDL.Numb     := null;
            end if;
            
            /* Устанавливаем параметры по образцу */
            if bSIGN_NEW or not bCONSOLIDATE_ then
              rDOC := rMDL;
              /* Создание расходной накладной на отпуск в подразделение */
              DOC_CREATE(rDOC);
              /* Добавляем в список документов */
              rDOCS.Extend;
              rDOCS(rDOCS.Count) := rDOC.Rn;
            end if;

            /* Устанавливаем параметры строки спецификации */
            rSPEC := null;
            rSPEC.Company         := rDOC.Company;
            rSPEC.Prn             := rDOC.Rn;
            rSPEC.Goodsparty      := rec.goodsparty;
            rSPEC.Nommodif        := rec.nommodif;
            rSPEC.Nomnmodifpack   := rec.nomnmodifpack;
            rSPEC.Article         := rec.article;
            rSPEC.Price           := 0;
            rSPEC.Quant           := nMOVE_QUANT;
            rSPEC.Quantalt        := nMOVE_QUANTALT;
            rSPEC.Coeff_Val_Sign  := 0;
            rSPEC.Coeff_Calc_Sign := 1;
            rSPEC.Pricemeas       := 0;
            rSPEC.Summwithnds     := rSPEC.Price * rSPEC.Quant;
            
            /* Коэффициент пересчета */
            begin
            select n.equal
                   into rSPEC.Coeff
                   from nommodif m, dicnomns n
                   where m.rn  = rSPEC.Nommodif
                     and m.prn = n.rn;
            exception when NO_DATA_FOUND then
                      PKG_MSG.RECORD_NOT_FOUND(0, rSPEC.Nommodif, 'NomenclatorModification');
            end;
            
            /* Добавление строки спецификации */
            P_TRANSINVDEPTSP_BASE_INSERT(
                nCOMPANY          => rSPEC.Company,
                nPRN              => rSPEC.Prn,
                nAGENT            => rSPEC.Agent,
                nGOODSPARTY       => rSPEC.Goodsparty,
                nNOMMODIF         => rSPEC.Nommodif,
                nNOMNMODIFPACK    => rSPEC.Nomnmodifpack,
                nARTICLE          => rSPEC.Article,
                nCELL             => rSPEC.Cell,
                nTEMPERATURE      => rSPEC.Temperature,
                nPRICE            => rSPEC.Price,
                nQUANT            => rSPEC.Quant,
                nQUANTALT         => rSPEC.Quantalt,
                nCOEFF            => rSPEC.Coeff,
                nCOEFF_VAL_SIGN   => rSPEC.Coeff_Val_Sign,
                nCOEFF_CALC_SIGN  => rSPEC.Coeff_Calc_Sign,
                nPRICEMEAS        => rSPEC.Pricemeas,
                nSUMMWITHNDS      => rSPEC.Summwithnds,
                dBEGINDATE        => rSPEC.Begindate,
                dENDDATE          => rSPEC.Enddate,
                sNOTE             => rSPEC.Note,
                sBCODE            => rSPEC.Bcode,        -- Штрих-код
                sCARDNUMB         => rSPEC.Cardnumb,     -- Номер карточки складского учета
                nRN               => rSPEC.Rn
                );

            /* проверка количеств при резервирования  */
            P_STRPLRESJRNL_CHECK_QUANTS(
                nCOMPANY      => nCOMPANY,
                nRN           => null,      -- RN записи резервирования
                nCELL         => rec.Cell,  -- МХ
                nRES_TYPE     => 1,         -- тип резервирования (0 - приход, 1 - расход)
                sUNITCODE     => 'GoodsTransInvoicesToDeptsSpecs',
                nMRN          => rDOC.Rn,
                nSRN          => rSPEC.Rn,
                nQUANT        => rSPEC.Quant,
                nQUANTALT     => rSPEC.Quantalt
                );

            /* Места хранения для списания */
            P_STRPLRESJRNL_BASE_INSERT(
                nCOMPANY             => nCOMPANY,
                sAUTHID              => UTILIZER,
                sMASTERUNITCODE      => 'GoodsTransInvoicesToDepts',
                sSLAVEUNITCODE       => 'GoodsTransInvoicesToDeptsSpecs',
                nMASTERRN            => rDOC.Rn,
                nSLAVERN             => rSPEC.Rn,
                nRACK                => null,             -- не используется (по возможности убрать)
                nCELL                => rec.Cell,         -- место хранения (резервуар)
                nGOODSSUPPLY         => rec.goodssupply,  -- товарный запас
                nRES_TYPE            => 1,                -- тип резервирования (0 - приход, 1 - расход)
                nNOMMODIF            => rSPEC.Nommodif,
                nNOMNMODIFPACK       => rSPEC.Nomnmodifpack,
                nARTICLE             => rec.article,      -- изделие на складе
                nGOODSUNIT           => null,             -- грузовая единица
                nDOCTYPE             => rDOC.Doctype,
                dDOCDATE             => rDOC.Docdate,
                sDOCNUMB             => rDOC.Numb,
                sDOCPREF             => rDOC.Pref,
                dRESERVING_DATE      => dOPER_DATE,       -- дата и время резервирования.
                dFREE_DATE           => null,             -- дата и время снятия резервирования.
                nQUANT               => rSPEC.Quant,      -- количество в основной ЕИ
                nQUANTALT            => rSPEC.Quantalt,   -- количество в дополнительной ЕИ
                nQUANTPACK           => null,             -- не используется (рассчитывается из ОЕИ)
                nCHECK_PARTY         => 0,                -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
                nRN                  => nTMP
                );

            /* Места хранения для распределения */
            P_STRPLRESJRNL_BASE_INSERT(
                nCOMPANY             => nCOMPANY,
                sAUTHID              => UTILIZER,
                sMASTERUNITCODE      => 'GoodsTransInvoicesToDepts',
                sSLAVEUNITCODE       => 'GoodsTransInvoicesToDeptsSpecs',
                nMASTERRN            => rDOC.Rn,
                nSLAVERN             => rSPEC.Rn,
                nRACK                => null,             -- не используется (по возможности убрать)
                nCELL                => nCELL,            -- место хранения (резервуар)
                nGOODSSUPPLY         => rec.goodssupply,  -- товарный запас
                nRES_TYPE            => 0,                -- тип резервирования (0 - приход, 1 - расход)
                nNOMMODIF            => rSPEC.Nommodif,
                nNOMNMODIFPACK       => rSPEC.Nomnmodifpack,
                nARTICLE             => rec.article,      -- изделие на складе
                nGOODSUNIT           => null,             -- грузовая единица
                nDOCTYPE             => rDOC.Doctype,
                dDOCDATE             => rDOC.Docdate,
                sDOCNUMB             => rDOC.Numb,
                sDOCPREF             => rDOC.Pref,
                dRESERVING_DATE      => dOPER_DATE,       -- дата и время резервирования.
                dFREE_DATE           => null,             -- дата и время снятия резервирования.
                nQUANT               => rSPEC.Quant,      -- количество в основной ЕИ
                nQUANTALT            => rSPEC.Quantalt,   -- количество в дополнительной ЕИ
                nQUANTPACK           => null,             -- не используется (рассчитывается из ОЕИ)
                nCHECK_PARTY         => 0,                -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
                nRN                  => nTMP
                );

            /* увеличиваем счетчик отработанных записей */
            nCOUNT := nCOUNT + 1;
          end if;
        end if;
      else
        /* Формируем сообщение */
        sMSG := F_FORMAT_MESSAGE_TEXT( 'Для товарного запаса "%s" (код партии "%s", серия "%s") на месте хранения нет требуемого количества в ОЕИ доступном для изъятия', null,
                                       UDO_GET_NOMMODIF_CODE_ID(1, rec.nommodif), UDO_GET_INCOMDOC_CODE_ID(1, rec.indoc), rec.sernumb );
        /* Сохраняем в журнале сообщений */
        ADD_MSG(1, sMSG);
      end if;
      /* фиксация окончания выполнения действия */
      PKG_ENV.EPILOGUE( nCOMPANY, null, null, Rec.JUR_PERS, 'StoragePlacesGoodsSupply', 'STPLGOODSSUPPLY_MOVEGOODS', 'STPLGOODSSUPPLY', Rec.RN );
  end loop;

  /* Цикл по сформированным документам */
  if rDOCS.Count > 0 then
      for indx in rDOCS.First .. rDOCS.Last
          loop
          nDOC := rDOCS(indx);
          /* Отработка */
          if nvl(nSIGN_WORK,1) = 1 then
            P_TRANSINVDEPT_BSET_STATUS(nCOMPANY, nDOC, 2, 1, dOPER_DATE, dOPER_DATE, nIDENT_MSG);
            /* Списание с МХ */
            P_STRPLRESJRNL_GTINV2D_PROCESS(nCOMPANY, nDOC, 1, dOPER_DATE);
            /* Оприходование на новое МХ */
            P_STRPLRESJRNL_GTINV2D_PROCESS(nCOMPANY, nDOC, 0, dOPER_DATE);
          end if;
          
          /* Сохранение документа */
          if nvl(nSAVE_DOCS,0) = 1 or GET_OPTIONS_NUM('Realiz_Show_Documents', nCOMPANY) = 1 then
            /* Идентификатор документов */
            if nIDENT_DOC is null then
              P_SELECTLIST_GENIDENT(nIDENT_DOC);
            end if;
            P_SELECTLIST_INSERT(nIDENT_DOC, nDOC, 'GoodsTransInvoicesToDepts', nTMP);
          end if;
      end loop;
  end if;

  /* Контроль выходных параметров */
  nIDENT_MSG := nvl(nIDENT_MSG,0);
  nIDENT_DOC := nvl(nIDENT_DOC,0);

end UDO_P_STPLGSUPPLY_MOVEINVDEPT;
/

