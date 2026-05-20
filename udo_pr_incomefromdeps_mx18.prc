create or replace procedure UDO_PR_INCOMEFROMDEPS_MX18
(
  nCOMPANY                  in number,      -- Организация
  nIDENT                    in number,      -- Идентификатор отмеченных записей
  sMOL_OUT_POST             in varchar2,    -- Отпустил (должность)
  sMOL_OUT_PERS             in varchar2,    -- Отпустил (ФИО)
  sMOL_IN_POST              in varchar2,    -- Получил (должность)
  sMOL_IN_PERS              in varchar2     -- Получил (ФИО)
) is
  /* ФОРМИРОВАНИЕ ОТЧЕТА: Накладная на передачу готовой продукции в места хранения "Унифицированная форма МХ-18 (335018)" */

  -- Лист
  sSHEET_FORM               constant PKG_STD.tSTRING := 'BLANK';
  -- Титульник
  sCELL_DOCNUMB             constant PKG_STD.tSTRING := '_DOCNUMB';       -- Номер документа
  sCELL_DOCDATE             constant PKG_STD.tSTRING := '_DOCDATE';       -- Дата документа
  sCELL_ORGNAME             constant PKG_STD.tSTRING := '_ORGNAME';       -- Реквизиты организации
  sCELL_STORE               constant PKG_STD.tSTRING := '_STORE';         -- Подразделение-отправитель

  sCELL_REQNUMB             constant PKG_STD.tSTRING := '_REQNUMB';       -- Номер заявки
  sCELL_REQDATE             constant PKG_STD.tSTRING := '_REQDATE';       -- Дата заявки

  sCELL_PRJNAME             constant PKG_STD.tSTRING := '_PRJNAME';       -- Тема
  sCELL_PRJSTAGE            constant PKG_STD.tSTRING := '_PRJSTAGE';      -- Этап
  sCELL_FACEACC             constant PKG_STD.tSTRING := '_FACEACC';       -- Номер заказа

  --
  sCELL_STORE_OUT           constant PKG_STD.tSTRING := '_STORE_OUT';     -- Подразделение-отправитель
  sCELL_STORE_IN            constant PKG_STD.tSTRING := '_STORE_IN';      -- Подразделение-получатель

  -- Таблица (Спецификация ведомости)
  sLINE_SPEC                constant PKG_STD.tSTRING := '_SPEC';          --
  sCELL_SPEC_NAME           constant PKG_STD.tSTRING := '_SPEC_NAME';     -- Наименование
  sCELL_SPEC_SERNUMB        constant PKG_STD.tSTRING := '_SPEC_SERNUMB';  -- Заводской номер
  sCELL_SPEC_UMEAS          constant PKG_STD.tSTRING := '_SPEC_UMEAS';    -- Единица измерерния
  sCELL_SPEC_OKEI           constant PKG_STD.tSTRING := '_SPEC_OKEI';     -- Код ОКЕИ
  sCELL_SPEC_QUANT          constant PKG_STD.tSTRING := '_SPEC_QUANT';    -- Количество
  --
  sCELL_TOTAL_QUANT         constant PKG_STD.tSTRING := '_TOTAL_QUANT';   -- Итого количество
  sCELL_TOTAL_QNTTXT        constant PKG_STD.tSTRING := '_TOTAL_QNTTXT';  -- Итого количество прописью

  sCELL_MOL_OUT_PERS        constant PKG_STD.tSTRING := '_MOL_OUT_PERS'; -- Отпустил (ФИО)
  sCELL_MOL_OUT_POST        constant PKG_STD.tSTRING := '_MOL_OUT_POST'; -- Отпустил (Должность)
  sCELL_MOL_IN_PERS         constant PKG_STD.tSTRING := '_MOL_IN_PERS';  -- Получил (ФИО)
  sCELL_MOL_IN_POST         constant PKG_STD.tSTRING := '_MOL_IN_POST';  -- Получил (Должность)

  /* переменные */
  bDATA_EXIST               boolean;

  /* Количество прописью */
  function QUANT2TEXT
  (
    nVALUE                  in number
  ) return varchar2 is
    sRESULT PKG_STD.tSTRING;
  begin
    sRESULT := NUM2TEXT(nVALUE);
    
    return(sRESULT);
  end QUANT2TEXT;

  /* Реквизиты подписанта */
  procedure SIGNER_ATTR
  (
    nMOL                    in number,    -- МОЛ
    dON_DATE                in date,      -- На дату
    sPERSON                 out varchar2, -- ФИО
    sPOST                   out varchar2  -- Должность
  ) is
  begin
    
    /* ФИО, Должность */ 
    begin
      select a.agnname, a.emppost
        into sPERSON, sPOST
        from AGNLIST A
        where a.rn = nMOL;
    exception when NO_DATA_FOUND then null;
    end;

  end SIGNER_ATTR;

  /* Описание листа */
  procedure SHEET_DESCRIBE
  is
  begin
    /* описание строк и ячеек */
    -- Титульник
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_DOCNUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_DOCDATE );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_ORGNAME );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_STORE );
    --
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_STORE_OUT );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_STORE_IN );
    --
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REQNUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REQDATE );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_PRJNAME );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_PRJSTAGE );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_FACEACC );

    -- Таблица (Спецификация)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_SPEC );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NAME );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_SERNUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_UMEAS );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_OKEI );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_QUANT );

    PRSG_EXCEL.CELL_DESCRIBE( sCELL_TOTAL_QUANT );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_TOTAL_QNTTXT );

    -- Подписанты
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_MOL_OUT_PERS );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_MOL_OUT_POST );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_MOL_IN_PERS );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_MOL_IN_POST );

  end SHEET_DESCRIBE;

  /* Формирование рабочего листа */
  procedure SHEET_MAKE
  (
    sPREF                   in varchar2,  -- Префикс
    sNUMB                   in varchar2   -- Номер
  ) is
    -- Константы
    sSYMB_RPL               constant PKG_STD.tSTRING := ':\/?*[]'; -- Запрещенные символы в имени листа
    sSYMB_NEW               constant PKG_STD.tSTRING := '#######'; -- Шаблон замены
    -- Переменные
    sPREF_                  PKG_STD.tSTRING; --
    sNUMB_                  PKG_STD.tSTRING; --
    sSHEET_NAME             PKG_STD.tSTRING; -- Имя текущего листа
  begin

    /* Заменяем запрещенные символы */
    sPREF_ := translate(trim(sPREF), sSYMB_RPL, sSYMB_NEW);
    sNUMB_ := translate(trim(sNUMB), sSYMB_RPL, sSYMB_NEW);

    /* Формируем имя Excel-листа */
    if sPREF_ is not null then
         sSHEET_NAME := sPREF_ ||'-'|| sNUMB_;
    else sSHEET_NAME := sNUMB_;
    end if;

    /* Копирование листа */
    PRSG_EXCEL.SHEET_COPY(
        sSHEET_NAME_FROM => sSHEET_FORM,
        sSHEET_NAME_TO   => sSHEET_NAME,
        nMOVE_TO_END     => 1
        );

    /* Выбор листа */
    PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSHEET_NAME);

    /* Описание листа */
    SHEET_DESCRIBE;

  end SHEET_MAKE;

  /* Описание листа */
  procedure SHEET_PRINT
  (
    nRN                     in number,  -- Регистрационный номер
    nCOMPANY                in number   -- Организация
  ) is
  --  rDEPTORD                DEPARTMENTORD%rowtype; -- Запись заявки подразделения
    --nPRODORD                PKG_STD.tREF;          -- Заказ на производство
    --rPRODORD                PRODUCTORD%rowtype;    -- Заказ на производство
    sDOC_PREF               PKG_STD.tSTRING;
    sDOC_NUMB               PKG_STD.tSTRING;
    dDOC_DATE               date;
    sSTORE_OUT              PKG_STD.tSTRING;    -- Структурное подразделение-отправитель (склад)
    sSTORE_IN               PKG_STD.tSTRING;    -- Структурное подразделение-получатель (склад)
    nMOL_OUT                PKG_STD.tREF;       -- МОЛ-отправитель
    nMOL_IN                 PKG_STD.tREF;       -- МОЛ-получатель
    sPERSON                 PKG_STD.tSTRING;    -- Подписант
    sPOST                   PKG_STD.tSTRING;    -- Должность
    sPRJNAME                PKG_STD.tSTRING;    -- Тема
    sFACEACC                PKG_STD.tSTRING;    -- Номер заказа
    --sSERNUMB                PKG_STD.tSTRING;    -- Заводской номер
    --sSERNUMB_STR            PKG_STD.tSTRING;    -- Строка заводских номеров
    sREQNUMB                PKG_STD.tSTRING;    -- Номер заявки
    nTOTAL                  number;
    sTOTAL_TEXT             PKG_STD.tSTRING;
    nLINE                   PKG_STD.tNUMBER;
  begin

    /* Считывание реквизитов */
    begin
    select trim(t.doc_pref), trim(t.doc_numb), t.doc_date,
           st1.azs_name, st1.azs_agent,
           st2.azs_name, t.agent,
           UDO_F_FACEACC_GET_SHEFR(t.out_faceacc),
           f.numb,
           UDO_F_INCOMFROMDEPS_PRODNUM(t.rn)    ---Е. Столярский
      into sDOC_PREF, sDOC_NUMB, dDOC_DATE,
           sSTORE_OUT, nMOL_OUT,
           sSTORE_IN,  nMOL_IN,
           sPRJNAME, sFACEACC,
           sREQNUMB
      from INCOMEFROMDEPS t,
           AZSAZSLISTMT   st1,
           AZSAZSLISTMT   st2,
           FACEACC        f
     where t.rn           = nRN
       and t.company      = nCOMPANY
       and t.out_store    = st1.rn (+)
       and t.store        = st2.rn
       and t.out_faceacc  = f.rn (+);
    exception when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nRN, 'IncomFromDeps');
    end;

    /* Формирование листа */
    SHEET_MAKE(sDOC_PREF, sDOC_NUMB);

    -- Титульник
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_DOCNUMB, ''''||sDOC_NUMB );
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_DOCDATE, to_char(dDOC_DATE, 'DD.MM.YYYY') );
    --
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_STORE, sSTORE_OUT );
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_STORE_OUT, sSTORE_OUT );
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_STORE_IN, sSTORE_IN );
    /* Тема */
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_PRJNAME, sPRJNAME);
    /* Номер заказа */
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_FACEACC, sFACEACC );
    /* Номер заявки */
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_REQNUMB, sREQNUMB );
        /* Заводской номер */
--        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SERNUMB, sSERNUMB_STR);

    /* Спецификация */
    nTOTAL := 0;
    for spec in (
        select --n.nomen_code    as sNOMEN, n.nomen_name    as sNOMENNAME,
               mat.code        as sModif,
               mat.name        as sModifName, -- KHOK
               u.meas_mnemo    as sMEAS_MAIN,
               u.code_okei     as sMEAS_OKEI,
               s.quant_fact    as nQUANT,
               UDO_F_RLARTICLES_MNF_NUMB(s.article) as sARTICLE  ---Е. Столярский
          from INCOMEFROMDEPSSPEC s,
               FCMATRESOURCE      mat,
               NOMMODIF           m,
               DICNOMNS           n,
               DICMUNTS           u,
               RLARTICLES         r                        
          where s.prn        = nRN
            and s.nommodif   = mat.nomen_modif
            and s.nommodif   = m.rn
            and m.prn        = n.rn
            and n.umeas_main = u.rn
            and s.article    = r.rn (+)                    
          order by m.modif_name, r.code
        ) loop
        nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_SPEC);
        /* Наименование */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_NAME,  0, nLINE, spec.sModifName /*sNOMENNAME*/||' ('||spec.sarticle||')');   ---Е. Столярский
        /* Заводской номер */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_SERNUMB, 0, nLINE, spec.sModif /*sNOMEN*/ /*spec.sarticle*/); ---Е. Столярский
        /* Единица измерения*/
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_UMEAS,  0, nLINE, spec.smeas_main);
        /* ОКЕИ */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_OKEI,  0, nLINE, spec.smeas_okei);
        /* Количество */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_QUANT, 0, nLINE, spec.nquant);
        
        nTOTAL := nTOTAL + spec.nquant;
        
    end loop;

    /* Итого */
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_TOTAL_QUANT, nTOTAL);

    /* Количество прописью */
    sTOTAL_TEXT := QUANT2TEXT(nTOTAL);
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_TOTAL_QNTTXT, sTOTAL_TEXT);

    -- Подписанты
    -- Отпустил
    SIGNER_ATTR(nMOL_OUT, dDOC_DATE, sPERSON, sPOST);
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_MOL_OUT_PERS, coalesce(sPERSON, sMOL_OUT_PERS) );
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_MOL_OUT_POST, coalesce(sPOST, sMOL_OUT_POST) );
    -- Получил
    SIGNER_ATTR(nMOL_IN, dDOC_DATE, sPERSON, sPOST);
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_MOL_IN_PERS, coalesce(sPERSON, sMOL_IN_PERS) );
    PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_MOL_IN_POST, coalesce(sPOST, sMOL_IN_POST) );


    /* Удаление образцов строк */
    PRSG_EXCEL.LINE_DELETE(sLINE_SPEC);

  end SHEET_PRINT;

/* Основная процедура */
begin

  /* Пролог */
  PRSG_EXCEL.PREPARE;

  bDATA_EXIST := false;
  for rep in (
      select SL.DOCUMENT
             from SELECTLIST SL
             where SL.IDENT = nIDENT
               and SL.UNITCODE = 'IncomFromDeps'
      ) loop
      bDATA_EXIST := true;

      /* Печать отчета */
      SHEET_PRINT( rep.DOCUMENT, nCOMPANY );
  end loop;

  /* Удаление образцов листов */
  if bDATA_EXIST then
    PRSG_EXCEL.SHEET_DELETE(sSHEET_FORM);
  end if;

end UDO_PR_INCOMEFROMDEPS_MX18;
/
