create or replace procedure UDO_PR_TRANSINVDEPT_DELIVSH(
       nCOMPANY             in number, -- Организация
       nIDENT               in number, -- Идентификатор помеченных записей
       nSIGN_AGG            in number  -- Сводный (0-Нет; 1-Да)
       ) is
  /* ФОРМИРОВАНИЕ ОТЧЕТА: Комплектация по накладным */
  type tDOC is table of varchar2(240);
  rDOC tDOC := tDOC();
  bNEXT boolean;

  -- Лист
  sSHEET_FORM_DOC           constant PKG_STD.tSTRING := 'Комплектация';
  sSHEET_FORM_AGG           constant PKG_STD.tSTRING := 'СВОД';
  -- Титульник
  sCELL_REPNAME             constant PKG_STD.tSTRING := '_REPNAME';           -- Наименование отчета
  -- Заголовок
  sLINE_HEADER              constant PKG_STD.tSTRING := '_HEADER';            -- 
  sCELL_HEADER_DOCNUMB      constant PKG_STD.tSTRING := '_HEADER_DOCNUMB';    -- Номер документа (накладная)
  sCELL_HEADER_ARTICLE      constant PKG_STD.tSTRING := '_HEADER_ARTICLE';    -- Изделие
  sCELL_HEADER_REQNUMB      constant PKG_STD.tSTRING := '_HEADER_REQNUMB';    -- Номер заявки
  sCELL_HEADER_FACEACC      constant PKG_STD.tSTRING := '_HEADER_FACEACC';    -- Номер заказа
  sCELL_HEADER_TOTAL        constant PKG_STD.tSTRING := '_HEADER_TOTAL';      -- Количество позиций

  -- Таблица (Спецификация)
  sLINE_SPEC                constant PKG_STD.tSTRING := '_SPEC';              -- 
  sCELL_SPEC_NUMB           constant PKG_STD.tSTRING := '_SPEC_NUMB';         -- Номер п/п
  sCELL_SPEC_CODE           constant PKG_STD.tSTRING := '_SPEC_CODE';         -- Артикул
  sCELL_SPEC_NOMEN          constant PKG_STD.tSTRING := '_SPEC_NOMEN';        -- Наименование
  sCELL_SPEC_SERNUMB        constant PKG_STD.tSTRING := '_SPEC_SERNUMB';      -- Заводской номер
  sCELL_SPEC_UMEAS          constant PKG_STD.tSTRING := '_SPEC_UMEAS';        -- Единица измерерния
  sCELL_SPEC_QUANT          constant PKG_STD.tSTRING := '_SPEC_QUANT';        -- Количество
  sCELL_SPEC_STORAGE        constant PKG_STD.tSTRING := '_SPEC_STORAGE';      -- Место хранения
  -- Подвал
  sCELL_RESPONSIBLE         constant PKG_STD.tSTRING := '_RESPONSIBLE';       -- Ответственный

  -- Таблица (Свод)
  -- Заголовок
  sCELL_AGG_DOCNUMB      constant PKG_STD.tSTRING := '_AGG_DOCNUMB';    -- Номер документа (накладная)
  sCELL_AGG_ARTICLE      constant PKG_STD.tSTRING := '_AGG_ARTICLE';    -- Изделие
  sCELL_AGG_REQNUMB      constant PKG_STD.tSTRING := '_AGG_REQNUMB';    -- Номер заявки
  sCELL_AGG_FACEACC      constant PKG_STD.tSTRING := '_AGG_FACEACC';    -- Номер заказа
  -- строки
  sLINE_AGG_SPEC            constant PKG_STD.tSTRING := '_AGG_SPEC';          -- 
  sCELL_AGG_SPEC_NUMB       constant PKG_STD.tSTRING := '_AGG_SPEC_NUMB';     -- Номер п/п
  sCELL_AGG_SPEC_NOMEN      constant PKG_STD.tSTRING := '_AGG_SPEC_NOMEN';    -- Наименование
  sCELL_AGG_SPEC_CODE       constant PKG_STD.tSTRING := '_AGG_SPEC_CODE';     -- Артикул
  sCELL_AGG_SPEC_SERNUMB    constant PKG_STD.tSTRING := '_AGG_SPEC_SERNUMB';  -- Заводской номер
  sCELL_AGG_SPEC_PLACE      constant PKG_STD.tSTRING := '_AGG_SPEC_PLACE';    -- Места хранения
  sCELL_AGG_SPEC_TOTAL      constant PKG_STD.tSTRING := '_AGG_SPEC_TOTAL';    -- Всего
  sCELL_AGG_SPEC_POSITION   constant PKG_STD.tSTRING := '_AGG_SPEC_POSITION'; -- Позиционное обозначение
  -- колонки
  sCLMN_AGG_ARTCL           constant PKG_STD.tSTRING := '_AGG_ARTCL';         --
  sCELL_AGG_ARTCL_NAME      constant PKG_STD.tSTRING := '_AGG_ARTCL_NAME';    -- Изделие
  --
  sCLMN_AGG_BLANK           constant PKG_STD.tSTRING := '_AGG_BLANK';         --
  -- общие ячейки
  sCELL_AGG_QUANT           constant PKG_STD.tSTRING := '_AGG_QUANT';         -- Количество

  /* Штрих-код заголовка */
  sHEARD_BARCODE          constant PKG_STD.tSTRING := 'sHEARD_BARCODE';

  /* переменные */
  bDATA_EXIST               boolean;

  /* Описание листа */
  procedure SHEET_DESCRIBE_DOC
  is
  begin
    /* описание строк и ячеек */
    -- Титульник
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REPNAME );
    -- Заголовок
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_HEADER );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_HEADER, sCELL_HEADER_DOCNUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_HEADER, sCELL_HEADER_ARTICLE );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_HEADER, sCELL_HEADER_REQNUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_HEADER, sCELL_HEADER_FACEACC );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_HEADER, sCELL_HEADER_TOTAL );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_HEADER, sHEARD_BARCODE );
    
    -- Таблица (Спецификация)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_SPEC );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_CODE );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NOMEN );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_SERNUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_UMEAS );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_QUANT );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_STORAGE );

    -- Подвал
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_RESPONSIBLE );

  end SHEET_DESCRIBE_DOC;

  /* Описание листа СВОД */
  procedure SHEET_DESCRIBE_AGG
  is
  begin
    -- Титульник
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_AGG_DOCNUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_AGG_ARTICLE );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_AGG_REQNUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_AGG_FACEACC );

    -- Таблица (Спецификация)
    -- строки
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_AGG_SPEC );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_NUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_NOMEN );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_CODE );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_SERNUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_PLACE );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_QUANT );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_TOTAL );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGG_SPEC, sCELL_AGG_SPEC_POSITION );
    -- колонки
    PRSG_EXCEL.COLUMN_DESCRIBE( sCLMN_AGG_ARTCL );
    PRSG_EXCEL.COLUMN_CELL_DESCRIBE( sCLMN_AGG_ARTCL, sCELL_AGG_ARTCL_NAME );
    PRSG_EXCEL.COLUMN_CELL_DESCRIBE( sCLMN_AGG_ARTCL, sCELL_AGG_QUANT );
    --
    PRSG_EXCEL.COLUMN_DESCRIBE( sCLMN_AGG_BLANK );

    -- Подвал

  end SHEET_DESCRIBE_AGG;

  /* Печать листа (Комплектация) */
  procedure SHEET_PRINT_DOC
  (
    nRN                     in number,  -- Регистрационный номер
    nCOMPANY                in number   -- Организация
  ) is
    sDOC_PREF               PKG_STD.tSTRING;
    sDOC_NUMB               PKG_STD.tSTRING;
    dDOC_DATE               date;
    sARTICLE                PKG_STD.tSTRING;    -- Изделие
    sSERNUMB                PKG_STD.tSTRING;    -- Заводские номера
    sREQNUMB                PKG_STD.tSTRING;    -- Номер заявки
    sFACEACC                PKG_STD.tSTRING;    -- Номер заказа
    bSTORAGE_PLACE           boolean;
    -- Служебные
    nLINE                   PKG_STD.tNUMBER;
    nFIRST_LINE             PKG_STD.tNUMBER;
    sVALUE                  PKG_STD.tSTRING;
    iCOUNT                  PKG_STD.tNUMBER;
  begin

    /* Считывание реквизитов */
    begin
    select trim(t.pref), trim(t.numb), t.docdate,
           UDO_F_TRANSINVDEPT_MAIN_PROD(t.rn), -- Изделие
           UDO_F_TRANSINVDEPT_MAIN_NUMB(t.rn), -- Заводские номера
           UDO_F_INVDEPT_DEPORD(t.rn),         -- Заявка
           GET_FACEACC_NUMB_ID(1, t.faceacc)
      into sDOC_PREF, sDOC_NUMB, dDOC_DATE,
           sARTICLE, sSERNUMB,
           sREQNUMB,
           sFACEACC
      from TRANSINVDEPT   t
     where t.rn           = nRN
       and t.company      = nCOMPANY;
    exception when NO_DATA_FOUND then
              PKG_MSG.RECORD_NOT_FOUND(nRN, 'GoodsTransInvoicesToDepts');
    end;

    /* Формирование листа */
    --SHEET_MAKE(sDOC_PREF, sDOC_NUMB);

    -- Заголовок
    nLINE := PRSG_EXCEL.LINE_CONTINUE(sLINE_HEADER);

    /* Номер документа (накладная) */
    sVALUE := trim(sDOC_PREF) || '-' || trim(sDOC_NUMB) || ' от ' || to_char(dDOC_DATE, 'dd.mm.yyyy');
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_HEADER_DOCNUMB,  0, nLINE, sVALUE);

    /* Изделие */
    if sSERNUMB is not null then
        if instr(sARTICLE, '(000') > 0 then
            sVALUE := SUBSTR(sARTICLE, 0, INSTR(sARTICLE, '(000')) || 'зав.№' || sSERNUMB || ')';
        else
            sVALUE := sARTICLE || ' (зав.№' || sSERNUMB || ')';
        end if;
    else
        sVALUE := sARTICLE;
    end if;
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_HEADER_ARTICLE, 0, nLINE, sVALUE);

    /* Номер заявки */
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_HEADER_REQNUMB,  0, nLINE, sREQNUMB);
    /* Номер заказа */
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_HEADER_FACEACC,  0, nLINE, sFACEACC);
    /* Штрих-код */
    PRSG_EXCEL.CELL_VALUE_WRITE(scell_name =>  sHEARD_BARCODE,  icell_index_x => 0, icell_index_y => nLINE,   ncell_value => nRN); 

    /* Спецификация */
    iCOUNT := 0;
    for recs in (
        select TDS.RN,
               TDS.QUANT,
               TDS.GOODSPARTY,
               upper(MD.MODIF_NAME) as MODIF_CODE,
               case
                 when (select count(*) from UDO_MODIF_ATTR ATTR where ATTR.PRN = MD.RN) > 0 then
                   nvl(UDO_PKG_FCMATRES_UTL.MODIF_IPS_NAME(nFLAG_SMART => 1, nRN => MD.RN), NM.NOMEN_NAME)
                 else NM.NOMEN_NAME
               end as NOMEN_NAME,
               MU.MEAS_MNEMO,
               GP.SERNUMB
          from TRANSINVDEPTSPECS TDS,
               NOMMODIF          MD,
               DICNOMNS          NM,
               DICMUNTS          MU,
               GOODSPARTIES      GP
         where TDS.PRN = nRN
           and TDS.NOMMODIF = MD.RN
           and MD.PRN = NM.RN
           and NM.UMEAS_MAIN = MU.RN
           and GP.RN (+)= TDS.GOODSPARTY
        ) loop
        -- по местам хранения
        bSTORAGE_PLACE := false;
        for rpl in (
            select trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) CELL,
                   sum(VPL.nQUANT) as nQUANT /* 09/09/2025 KHOK. Суммирование лежащего на одном месте. */
              from V_STRPLRESJRNL_DOCS VPL,
                   STPLCELLS           CEL
             where VPL.nres_type = 1
               and VPL.ncell = CEL.RN
               and exists (select null
                             from V_DOCLINKS_INOUT_IN_EXT DLIN
                            where (DLIN.NIN_DOCUMENT = recs.rn)
                              and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                              and (DLIN.NDOCUMENT = VPL.NRN))
             group by trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB)
        ) loop
            iCOUNT := iCOUNT + 1;
            bSTORAGE_PLACE := true;
            nLINE := PRSG_EXCEL.LINE_CONTINUE(sLINE_SPEC);
            
            if iCOUNT = 1 then
              nFIRST_LINE := nLINE;
            end if;
            
            /* Номер п/п */
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_NUMB, 0, nLINE, to_char(iCOUNT));
            /* Артикул */
            if instr(recs.modif_code, '_') > 0 and
               length(substr(recs.modif_code, instr(recs.modif_code, '_')+1)) > 3
              then
              sVALUE := substr(recs.modif_code, instr(recs.modif_code, '_')+1);
              PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_CODE, 0, nLINE, sVALUE);
            end if;
            /* Наименование */
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_NOMEN, 0, nLINE, recs.nomen_name);
            /* Заводской номер*/
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_SERNUMB, 0, nLINE, recs.sernumb);
            /* Количество */
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_QUANT, 0, nLINE, rpl.nquant);
            /* Единица измерения */
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_UMEAS, 0, nLINE, recs.meas_mnemo);
            /* Место хранения */
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_STORAGE, 0, nLINE, rpl.cell);
        end loop;

        -- Не по местам хранения
        if not bSTORAGE_PLACE then
          iCOUNT := iCOUNT + 1;
          nLINE := PRSG_EXCEL.LINE_CONTINUE(sLINE_SPEC);

          if iCOUNT = 1 then
            nFIRST_LINE := nLINE;
          end if;

          /* Номер п/п */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_NUMB, 0, nLINE, to_char(iCOUNT));
          /* Артикул */
          if instr(recs.modif_code, '_') > 0 and
               length(substr(recs.modif_code, instr(recs.modif_code, '_')+1)) > 3
              then
            sVALUE := substr(recs.modif_code, instr(recs.modif_code, '_')+1);
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_CODE, 0, nLINE, sVALUE);
          end if;
          /* Наименование */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_NOMEN, 0, nLINE, recs.nomen_name);
          /* Заводской номер */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_SERNUMB, 0, nLINE, recs.sernumb);
          /* Количество */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_QUANT, 0, nLINE, recs.quant);
          /* Единица измерения */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_SPEC_UMEAS, 0, nLINE, recs.meas_mnemo);
        end if;
    end loop;

    if nvl(nLINE, 0) > 0 and nvl(nFIRST_LINE, 0) > 0 then
      /* Форматирование первой строки */
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_NUMB, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium'); -- xlThick
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_NOMEN, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_CODE, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_SERNUMB, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_UMEAS, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_QUANT, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_STORAGE, 0, nFIRST_LINE, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      /* Форматирование последней строки */
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_NUMB, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_NOMEN, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_CODE, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_SERNUMB, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_UMEAS, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_QUANT, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_SPEC_STORAGE, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
    end if;

    /* Количество позиций */
    nLINE := PRSG_EXCEL.LINE_INDEX(sLINE_HEADER);
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_HEADER_TOTAL, 0, nLINE, iCOUNT);

  end SHEET_PRINT_DOC;

  /* Печать листа (СВОД) */
  procedure SHEET_PRINT_AGG
  (
    nCOMPANY                in number,  -- Организация
    nIDENT                  in number   -- Идентификатор помеченных записей
  ) is
    type tCLMPROD is table of number index by PKG_STD.tSTRING;
    rCLMPROD  tCLMPROD; -- Перечень изделий с адресом колонки
    sCUR_FULLNAME           PKG_STD.tSTRING; -- Текущее полное наименование строки
    sFULLNAME               PKG_STD.tSTRING; -- Полное наименование строки
    -- Служебные
    nLINE                   PKG_STD.tNUMBER;
    nCOLUMN                 PKG_STD.tNUMBER;
    sVALUE                  PKG_STD.tSTRING;
    sPLACES                 PKG_STD.tSTRING;
    sPOS                    PKG_STD.tSTRING;
    bPLACE                  boolean;
    type tCELL is table of varchar2(30);
    rCELL tCELL := tCELL();
    sArticle    varchar2(4000); -- Агрегация изделий
    sZakaz      varchar2(4000); -- Агрегация заказов на производство
    nMODIF_PLAN_RN          PKG_STD.tNUMBER;
    sNOMEN_PLAN             PKG_STD.tSTRING;
    sMODIF_PLAN             PKG_STD.tSTRING;
  begin
  
    /* Выбор листа */
    PRSG_EXCEL.SHEET_SELECT(sSHEET_FORM_AGG);
    /* Описание листа */
    SHEET_DESCRIBE_AGG;

    rCLMPROD.Delete;
    /* Собираем заказы на производство */
    for rec in (
      select distinct nvl(UDO_F_INVDEPT_DEPORD(T.RN), ' - ') as ZAKAZ -- Заказ на производство
        from TRANSINVDEPT T,
             SELECTLIST   SL
       where SL.IDENT       = nIDENT
         and SL.UNITCODE    = 'GoodsTransInvoicesToDepts'
         and SL.DOCUMENT    = T.RN
         and T.COMPANY      = nCOMPANY
       order by ZAKAZ
    ) loop
      if sZakaz is null then
        sZakaz := rec.ZAKAZ;
      elsif length(sZakaz) + length(rec.ZAKAZ) < 4000 then
        sZakaz := sZakaz || '; ' || rec.ZAKAZ;
      end if;
    end loop;

    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_FACEACC, sZakaz);

    /* Формируем перечень колонок */
    for rec in (
        select distinct nvl(UDO_F_TRANSINVDEPT_MAIN_PROD(T.RN),'<пусто>') as ARTICLE -- Изделие
          from TRANSINVDEPT T,
               SELECTLIST   SL
         where SL.IDENT       = nIDENT
           and SL.UNITCODE    = 'GoodsTransInvoicesToDepts'
           and SL.DOCUMENT    = T.RN
           and T.COMPANY      = nCOMPANY
         order by ARTICLE
        ) loop
        if sArticle is null then
          sArticle := rec.article;
        elsif length(sArticle) + length(rec.article) < 4000 then
          sArticle := sArticle || '; ' || rec.article;
        end if;

        /* Добавляем колонку */
        nCOLUMN := PRSG_EXCEL.COLUMN_APPEND(sCLMN_AGG_ARTCL);
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_ARTCL_NAME, nCOLUMN, 0, rec.article);
        /* Кэшируем колонку изделия */
        rCLMPROD(rec.article) := nCOLUMN;
    end loop;

    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_ARTICLE, sArticle);
    
    /* печать заголовка */
    if rDOC.Count > 0 then
      sPLACES := '';
      sPOS    := '';
      for Idx in rDOC.First..rDOC.Last loop
        if rtrim(sPLACES) is null then
          sPLACES := rDOC(Idx);
        else
          sPLACES := sPLACES || '; ' || rDOC(Idx);
        end if;
      end loop;
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_DOCNUMB, rDOC.Count);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_REQNUMB, sPLACES);
    end if;
    
    /* Цикл по строкам спецификаций */
    for spec in (
        with tSPECDATA as (
             select nvl(UDO_F_TRANSINVDEPT_MAIN_PROD(ts.prn),'<пусто>') as ARTICLE, -- Изделие
                    upper(M.MODIF_NAME) as MODIF_CODE,
                    N.NOMEN_NAME,
                    MU.MEAS_MNEMO,
                    GP.SERNUMB,
                    TS.QUANT
                    --,TS.RN
               from TRANSINVDEPTSPECS TS,
                    SELECTLIST        SL,
                    NOMMODIF          M,
                    DICNOMNS          N,
                    DICMUNTS          MU,
                    GOODSPARTIES      GP
              where SL.IDENT       = nIDENT
                and SL.UNITCODE    = 'GoodsTransInvoicesToDepts'
                and SL.DOCUMENT    = TS.PRN
                and TS.COMPANY     = nCOMPANY
                and TS.NOMMODIF    = M.RN
                and M.PRN          = N.RN
                and N.UMEAS_MAIN   = MU.RN
                and TS.GOODSPARTY  = GP.RN (+)
             )
         select T.ARTICLE,      -- Изделие
                T.MODIF_CODE, 
                T.NOMEN_NAME,
                T.SERNUMB, 
                sum(t.QUANT) as QUANT
           from tSPECDATA T
          group by T.ARTICLE, T.MODIF_CODE, T.NOMEN_NAME, T.SERNUMB
          order by T.NOMEN_NAME, T.SERNUMB -- Сортировка должна быть обязательно!
        ) loop

        sFULLNAME := spec.nomen_name || spec.sernumb;
        /* Сменилась номенклатура, артикул, заводской номер (серия) */
        if cmp_vc2(sFULLNAME, sCUR_FULLNAME) = 0 then
          sCUR_FULLNAME := sFULLNAME;
          nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_AGG_SPEC);
          /* Номер п/п */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_NUMB, 0, nLINE, to_char(nLINE));
          /* Наименование */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_NOMEN, 0, nLINE, spec.nomen_name);
          /* Артикул */
          if instr(spec.modif_code, '_') > 0 and
               length(substr(spec.modif_code, instr(spec.modif_code, '_')+1)) > 3
              then
            sVALUE := substr(spec.modif_code, instr(spec.modif_code, '_')+1);
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_CODE, 0, nLINE, sVALUE);
          end if;
          /* Заводской номер */
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_SERNUMB, 0, nLINE, spec.sernumb);
          /* Места хранения */
          sPLACES := '';
          sPOS    := '';
          rCELL   := tCELL();
          for rpl in(with tSPECDATA as (
                         select TS.RN,
                                upper(M.MODIF_NAME) as MODIF_CODE,
                                N.NOMEN_NAME,
                                GP.SERNUMB,
                                M.RN as fact_rn
                           from TRANSINVDEPTSPECS TS,
                                SELECTLIST        SL,
                                NOMMODIF          M,
                                DICNOMNS          N,
                                GOODSPARTIES      GP
                          where SL.IDENT       = nIDENT
                            and SL.UNITCODE    = 'GoodsTransInvoicesToDepts'
                            and SL.DOCUMENT    = TS.PRN
                            and TS.COMPANY     = nCOMPANY
                            and TS.NOMMODIF    = M.RN
                            and M.PRN          = N.RN
                            and TS.GOODSPARTY  = GP.RN (+)
                         )
             select T.RN, T.fact_rn
               from tSPECDATA T
              where T.MODIF_CODE = spec.modif_code
                and T.SERNUMB    = spec.sernumb
                and T.NOMEN_NAME = spec.nomen_name
          ) loop
            /* Начало. 09/09/2025 KHOK. Добавление Позиционного обозначения и Оригинальной номенклатуры */
            /* Позиционное обозначение */
            begin
              select LISTAGG(TT.sPos, '; ') WITHIN GROUP (order by NULL) 
                into sPos
                from (select distinct UDO_F_TRANSINVDEPTSPECS_SEATS(nrn => rpl.rn) as sPos 
                        from DUAL) TT;
            exception
              when NO_DATA_FOUND then sPos := to_char(null);
            end;            
            /* Оригинальная (плановая) номенклатура в КВ */
            begin
              select MDP.RN, NMP.NOMEN_NAME,
                     case
                        when instr(MDP.MODIF_NAME, '_') > 0
                          then replace(MDP.MODIF_NAME, NMP.NOMEN_CODE||'_')
                        else ''
                     end as MODIF_PLAN
                     /*,DLS.RN as DELIVSH_SP*/
                into nMODIF_PLAN_RN, sNOMEN_PLAN, sMODIF_PLAN
                from DOCLINKS          LT,
                     FCDELIVSHSP       DLS,
                     FCMATRESOURCE     MRP,
                     DICNOMNS          NMP,
                     NOMMODIF          MDP
               where LT.OUT_DOCUMENT  = rpl.rn
                 and LT.IN_DOCUMENT   = DLS.RN
                 and LT.IN_UNITCODE   = 'CostDeliverySheetsSpec'
                 and DLS.MATRES       = MRP.RN
                 and MRP.NOMENCLATURE = NMP.RN
                 and MRP.NOMEN_MODIF  = MDP.RN;
            exception
              when NO_DATA_FOUND then nMODIF_PLAN_RN := 0;
            end;

            if nMODIF_PLAN_RN != 0 and nMODIF_PLAN_RN != rpl.fact_rn then /* Дополняем Наименование и Артикул*/
              PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_NOMEN, 0, nLINE, spec.nomen_name || cr || 'замена у ' || sNOMEN_PLAN);            
              PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_CODE,  0, nLINE, sVALUE || cr || '('||sMODIF_PLAN||')');
            end if;
            /* Конец. 09/09/2025 KHOK. Добавление Позиционного обозначения и Оригинальной номенклатуры */

            -- места хранения
            for rpls in(select distinct VP.SCELL_CODE
                          from V_STRPLRESJRNL_DOCS VP
                         where VP.NRES_TYPE = 1
                           and exists (select *
                               from V_DOCLINKS_INOUT_IN_EXT DLIN
                              where (DLIN.NIN_DOCUMENT = rpl.rn)
                                and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                and (DLIN.NDOCUMENT = VP.NRN))) loop
              -- места хранения
              if rCELL.Count <= 0 then
                rCELL.Extend;
                rCELL(rCELL.Last) := rpls.scell_code;
              else
                bPLACE := false;
                for Idx in rCELL.First..rCELL.Last loop
                  if rCELL(Idx) = rpls.scell_code then
                    bPLACE := true;
                  end if;
                end loop;
                if not bPLACE then
                  rCELL.Extend;
                  rCELL(rCELL.Last) := rpls.scell_code;
                end if;
              end if;
            end loop;
          end loop;
          if rCELL.Count > 0 then
            for Idx in rCELL.First..rCELL.Last loop
              if rtrim(sPLACES) is null then
                sPLACES := rCELL(Idx);
              else
                if length(sPLACES||chr(10)||rCELL(Idx)) <= 2000 then
                  sPLACES := sPLACES||chr(10)||rCELL(Idx);
                end if;
              end if;
            end loop;
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_PLACE, 0, nLINE, sPLACES);
          end if;
        end if;

        /* Определяем колонку */
        if rCLMPROD.Exists(spec.article) then
          nCOLUMN := rCLMPROD(spec.article);
        else
          /* Добавляем колонку  */
          nCOLUMN := PRSG_EXCEL.COLUMN_APPEND(sCLMN_AGG_ARTCL);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_ARTCL_NAME, nCOLUMN, 0, spec.article);
          /* Кэшируем колонку изделия */
          rCLMPROD(spec.article) := nCOLUMN;
        end if;
        
        /* Количество */
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_QUANT, nCOLUMN, nLINE, spec.quant);

        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_AGG_SPEC_POSITION, 0, nLINE, sPOS);
        
    end loop;

    if nLINE > 0 then
      /* Форматирование первой строки */
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_NUMB,     0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium'); -- xlThick
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_NOMEN,    0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_CODE,     0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_SERNUMB,  0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_PLACE,    0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_TOTAL,    0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_POSITION, 0, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
      /* Форматирование последней строки */
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_NUMB,     0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_NOMEN,    0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_CODE,     0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_SERNUMB,  0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_PLACE,    0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_TOTAL,    0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_SPEC_POSITION, 0, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');

      for indx in 1 .. PRSG_EXCEL.COLUMN_INDEX(sCLMN_AGG_ARTCL)
          loop
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_QUANT, indx, 1, 'Borders(xlEdgeTop).Weight', 'xlMedium');
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_AGG_QUANT, indx, nLINE, 'Borders(xlEdgeBottom).Weight', 'xlMedium');
      end loop;
    end if;

    /* Удаление образцов */
    PRSG_EXCEL.LINE_DELETE(sLINE_AGG_SPEC);
    PRSG_EXCEL.COLUMN_DELETE(sCLMN_AGG_ARTCL);
    PRSG_EXCEL.COLUMN_DELETE(sCLMN_AGG_BLANK);

  end SHEET_PRINT_AGG;
  
/* Основная процедура */
begin

  /* Пролог */
  PRSG_EXCEL.PREPARE;

  bDATA_EXIST := false;

  /* Выбор листа */
  PRSG_EXCEL.SHEET_SELECT(sSHEET_FORM_DOC);
  /* Описание листа */
  SHEET_DESCRIBE_DOC;

  for rep in (
      select T.RN,
             trim(T.PREF)||'-'||trim(T.NUMB) as DOCUM
        from SELECTLIST SL,
             TRANSINVDEPT T
       where SL.IDENT    = nIDENT
         and SL.UNITCODE = 'GoodsTransInvoicesToDepts'
         and SL.DOCUMENT = T.RN
         and T.COMPANY   = nCOMPANY
         /*and exists (select null from DOCLINKS DL 
                            where DL.OUT_DOCUMENT = T.RN
                              and DL.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                              and DL.IN_UNITCODE  = 'CostDeliverySheets')*/ -- KHOK по заявке Сергеевой 05535.
       order by T.PREF, 
                T.NUMB
      ) loop
      bDATA_EXIST := true;

      /* Печать отчета */
      SHEET_PRINT_DOC( rep.RN, nCOMPANY );
      
      -- сводные данные
      if nvl(nSIGN_AGG, 0) = 1 then
        -- номер накладной
        rDOC.Extend;
        rDOC(rDOC.Last) := rep.docum;
      end if;
      
  end loop;

  if not bDATA_EXIST then
    p_exception(0, 'Печать комплектации возможна только для накладных, связанных с комплектовочной ведомостью.');
  end if;

  /* Удаление образцов строк */
  PRSG_EXCEL.LINE_DELETE(sLINE_HEADER);
  PRSG_EXCEL.LINE_DELETE(sLINE_SPEC);

  /* Сводный отчет */
  if nvl(nSIGN_AGG, 0) = 1 then
    SHEET_PRINT_AGG(nCOMPANY, nIDENT);
  end if;

  /* Удаление образцов листов */
  if nvl(nSIGN_AGG, 0) = 0 then
    PRSG_EXCEL.SHEET_DELETE(sSHEET_FORM_AGG);
  end if;

end UDO_PR_TRANSINVDEPT_DELIVSH;
/
