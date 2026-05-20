create or replace procedure UDO_PR_DEPORDDIR_BLANK
(
  nCOMPANY                  in number,      -- Организация
  nIDENT                    in number,      -- Идентификатор отмеченных записей
  nKIND                     in number       -- Документация содержит требования об изготовлении по Положению РК-98 (РК-11), РК-98-КТ (РК-11-КТ)
) is
  -- Лист
  sSHEET_FORM               constant PKG_STD.tSTRING := 'BLANK';
  -- Титульник
  sCELL_DOC_NUMB            constant PKG_STD.tSTRING := '_DOC_NUMB';      -- Номер карты разрешений
  sCELL_DOC_DATE            constant PKG_STD.tSTRING := '_DOC_DATE';      -- Дата карты разрешений
  --
  sCELL_SENDTO              constant PKG_STD.tSTRING := '_SENDTO';        -- КР направить
  sCELL_SUBDIV              constant PKG_STD.tSTRING := '_SUBDIV';        -- Подразделение, оформившее КР
  sCELL_FACEACC             constant PKG_STD.tSTRING := '_FACEACC';       -- Номер заказа/заявки
  -- Таблица (Изделие)
  sLINE_MATRES              constant PKG_STD.tSTRING := '_MATRES';        -- Изделие
  sCELL_MATRES_NOMEN        constant PKG_STD.tSTRING := '_MATRES_NOMEN';  -- Номенклатура изделия
  --
  sCELL_DECNUMB             constant PKG_STD.tSTRING := '_DECNUMB';       -- Обозначение (децимальный номер ЮФКВ)
  sCELL_SERNUMB             constant PKG_STD.tSTRING := '_SERNUMB';       -- Заводской номер
  sCELL_STAGE               constant PKG_STD.tSTRING := '_STAGE';         -- Этап выявления отступления
  -- Таблица (Спецификация ведомости)
  sLINE_SPEC                constant PKG_STD.tSTRING := '_SPEC';          -- 
  sCELL_SPEC_NUMB           constant PKG_STD.tSTRING := '_SPEC_NUMB';     -- Номер по порядку
  sCELL_SPEC_NOMEN          constant PKG_STD.tSTRING := '_SPEC_NOMEN';    -- Требования КД (ТД) (Наименование исходной номенклатуры)
  sCELL_SPEC_NOTE           constant PKG_STD.tSTRING := '_SPEC_NOTE';     -- Содержание отступления
  sCELL_SPEC_QUANT          constant PKG_STD.tSTRING := '_SPEC_QUANT';    -- Количество по номенклатуре замены
  --
  sCELL_REASON              constant PKG_STD.tSTRING := '_REASON';        -- Причина отступления
  sCELL_REQSUBDIV           constant PKG_STD.tSTRING := '_REQSUBDIV';     -- Подразделение-инициатор (виновник) оформления КР
  sCELL_REQPERSON           constant PKG_STD.tSTRING := '_REQPERSON';     -- Cотрудник-инициатор (виновник) оформления КР
  sCELL_VALIDATY            constant PKG_STD.tSTRING := '_VALIDATY';      -- Обоснование, заключение

  -- Таблица (Согласовано)
  sLINE_AGRMNT              constant PKG_STD.tSTRING := '_AGRMNT';        -- 
  sCELL_AGRMNT_POST         constant PKG_STD.tSTRING := '_AGRMNT_POST';   -- Должность
  sCELL_AGRMNT_DATE         constant PKG_STD.tSTRING := '_AGRMNT_DATE';   -- Дата
  sCELL_AGRMNT_SIGN         constant PKG_STD.tSTRING := '_AGRMNT_SIGN';   -- Подпись
  sCELL_AGRMNT_PERSON       constant PKG_STD.tSTRING := '_AGRMNT_PERSON'; -- Фамилия и инициалы

  -- Таблица (Утверждено)
  sLINE_CONFRM              constant PKG_STD.tSTRING := '_CONFRM';        -- 
  sCELL_CONFRM_POST         constant PKG_STD.tSTRING := '_CONFRM_POST';   -- Должность
  sCELL_CONFRM_DATE         constant PKG_STD.tSTRING := '_CONFRM_DATE';   -- Дата
  sCELL_CONFRM_SIGN         constant PKG_STD.tSTRING := '_CONFRM_SIGN';   -- Подпись
  sCELL_CONFRM_PERSON       constant PKG_STD.tSTRING := '_CONFRM_PERSON'; -- Фамилия и инициалы
  
  /* переменные */
  bDATA_EXIST               boolean;

  /* Печать подписанта */
  procedure SIGNER_PRINT
  (
    nSIGNTYPE               in number,                -- Тип подписи (0-Согласовано; 1-Утверждено;)
    sPOST                   in varchar2,              -- Должность
    sPERSON                 in varchar2 default null, -- Фамилия и инициалы
    dDATE                   in date     default null, -- Дата
    sSIGN                   in varchar2 default null  -- Подпись
  ) is
    nLINE number;
  begin
    -- Согласовано
    if nSIGNTYPE = 0 then
      nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_AGRMNT);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_AGRMNT_POST, 0, nLINE, sPOST);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_AGRMNT_DATE, 0, nLINE, dDATE);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_AGRMNT_SIGN, 0, nLINE, sSIGN);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_AGRMNT_PERSON, 0, nLINE, sPERSON);
    -- Утверждено
    elsif nSIGNTYPE = 1 then
      nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_CONFRM);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_CONFRM_POST, 0, nLINE, sPOST);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_CONFRM_DATE, 0, nLINE, dDATE);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_CONFRM_SIGN, 0, nLINE, sSIGN);
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_CONFRM_PERSON, 0, nLINE, sPERSON);
    end if;

  end SIGNER_PRINT;
  
  /* Описание листа */
  procedure SHEET_DESCRIBE
  is
  begin
    /* описание строк и ячеек */
    -- Титульник
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_DOC_NUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_DOC_DATE );
    --
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_SENDTO );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_SUBDIV );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_FACEACC );

    -- Таблица (Изделие)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_MATRES );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_MATRES, sCELL_MATRES_NOMEN );    

    PRSG_EXCEL.CELL_DESCRIBE( sCELL_DECNUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_SERNUMB );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_STAGE );

    -- Таблица (Этапы выявления отступления)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_SPEC );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NUMB );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NOMEN );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NOTE );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_QUANT );    

    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REASON );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REQSUBDIV );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REQPERSON );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_VALIDATY );

    -- Таблица (Согласовано)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_AGRMNT );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGRMNT, sCELL_AGRMNT_POST );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGRMNT, sCELL_AGRMNT_DATE );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGRMNT, sCELL_AGRMNT_SIGN );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_AGRMNT, sCELL_AGRMNT_PERSON );    

    -- Таблица (Утверждено)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_CONFRM );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_CONFRM, sCELL_CONFRM_POST );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_CONFRM, sCELL_CONFRM_DATE );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_CONFRM, sCELL_CONFRM_SIGN );    
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_CONFRM, sCELL_CONFRM_PERSON );    

  end SHEET_DESCRIBE;

  /* Формирование рабочего листа */
  procedure SHEET_MAKE
  (
    sPREF                   in varchar2,  -- Префикс
    sNUMB                   in varchar2   -- Номер
  ) is
    -- Константы
    sSYMB_RPL               constant PKG_STD.tSTRING := ':\/?*[]'; -- Запрещенные симфолы в имени листа
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
    else
      sSHEET_NAME := sNUMB_;
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
    nPRODORD                PKG_STD.tREF;          -- Заказ на производство
    --rPRODORD                PRODUCTORD%rowtype;    -- Заказ на производство
    sORD_PREF               PKG_STD.tSTRING;
    sORD_NUMB               PKG_STD.tSTRING;
    sFACEACC                PKG_STD.tSTRING;    -- Номер заказа/заявки
    sDECNUMB                PKG_STD.tSTRING;    -- Обозначение (децимальный номер ЮФКВ)
    sDECNUMB_STR            PKG_STD.tSTRING;    -- Строка обозначений (децимальный номер ЮФКВ)
    sSERNUMB                PKG_STD.tSTRING;    -- Заводской номер
    sSERNUMB_STR            PKG_STD.tSTRING;    -- Строка заводских номеров
    nLINE                   PKG_STD.tNUMBER;
  begin
    
    for rec in (
        select t.*,
               trim(d.ord_pref)   as ORD_PREF,
               trim(d.ord_numb)   as ORD_NUMB,
               d.faceacc          as FACEACC
               from UDO_DEPORDDIR t,
                    DEPARTMENTORD d
               where t.rn      = nRN
                 and t.company = nCOMPANY
                 and t.depord  = d.rn (+)
        ) loop

        /* Формирование листа */
        SHEET_MAKE(rec.doc_pref, rec.doc_numb);

        /* Есть связь с «Заказы подразделений» */
        if rec.depord is not null then

          /* «Заказ на производство» связан с «Заказом подразделения» через раздел «Потребность производства…» или напрямую */
          nPRODORD := F_DOCLINKS_LINK_IN_RECURS_DOC(1, 'DepartmentsOrders', rec.depord, 'ProductionOrders');

          /* Считывание записи */
          if nPRODORD is not null then
            begin
            select trim(t.ord_pref)   as ORD_PREF,
                   trim(t.ord_numb)   as ORD_NUMB
                   into sORD_PREF,
                        sORD_NUMB
                   from PRODUCTORD t
                   where t.RN = nPRODORD;
            exception when NO_DATA_FOUND then 
                           PKG_MSG.RECORD_NOT_FOUND(nPRODORD, 'ProductionOrders');
            end;
            
--            sORD_PREF := trim(rPRODORD.Ord_Pref);
--            sORD_NUMB := trim(rPRODORD.Ord_Numb);
          else
            sORD_PREF := rec.ord_pref;
            sORD_NUMB := rec.ord_numb;
          end if;

          /* Формируем Номер заказа/заявки */
          if sORD_PREF is not null then
            sFACEACC := GET_FACEACC_NUMB_ID(1, rec.faceacc) ||'/'|| sORD_PREF ||'-'|| sORD_NUMB;
          else
            sFACEACC := GET_FACEACC_NUMB_ID(1, rec.faceacc) ||'/'|| sORD_NUMB;
          end if;
        
        end if;

        -- Титульник
        --PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_DOC_NUMB, trim(rec.sdoc_numb) );
        --PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_DOC_DATE, to_char(rec.ddoc_date, 'DD.MM.YYYY') );
        --
        --PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SENDTO, null );
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SUBDIV, 'ОМТС' );
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_FACEACC, sFACEACC );

        
        
        /* Изделие */
        for ords in (
            select s.rn, n.nomen_name, rownum
                   from PRODUCTORDS s,
                        DICNOMNS    n
                   where s.prn   = nPRODORD
                     and s.nomen = n.rn
            ) loop
            if ords.rownum > 1 then
              nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_MATRES);
              PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_MATRES_NOMEN, 0, nLINE, ords.nomen_name);
            else
              PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_MATRES_NOMEN, 0, 0, ords.nomen_name);
            end if;

            /* Обозначение (децимальный номер ЮФКВ) */
            sDECNUMB := regexp_substr(ords.nomen_name, 'ЮФКВ([[:digit:]._]+[^[:space:](])');

            if sDECNUMB is not null then
              if sDECNUMB_STR is null then
                sDECNUMB_STR := sDECNUMB;
              else 
                sDECNUMB_STR := sDECNUMB_STR ||CR|| sDECNUMB;
              end if;
            end if;

            /* Серийные номера маршрутных листов */
            select listagg( r.code, '; ' ) within group (order by r.code )
              into sSERNUMB
              from RLARTICLES r,
                   (select nvl(s.article, f.article)  as article
                      from doclinks         d1,
                           doclinks         d2,
                           fcroutlst        f,
                           fcroutlstsernumb s
                     where d1.in_unitcode  = 'ProductionOrdersSpecs'
                       and d1.in_document  = ords.rn
                       and d1.out_unitcode = 'CostProductPlansSpecs'
                       and d2.in_unitcode  = d1.out_unitcode
                       and d2.in_document  = d1.out_document
                       and d2.out_unitcode = 'CostRouteLists'
                       and d2.out_document = f.rn
                       and f.rn            = s.prn (+)
                       ) t
              where t.article = r.rn;

            if sSERNUMB is not null then
              if sSERNUMB_STR is null then
                sSERNUMB_STR := sSERNUMB;
              else
                sSERNUMB_STR := sSERNUMB_STR ||CR|| sSERNUMB;
              end if;
            end if;
        end loop;

        /* Обозначение (децимальный номер ЮФКВ) */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_DECNUMB, sDECNUMB_STR);


        /* Заводской номер */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SERNUMB, sSERNUMB_STR);

        /* Этап выявления отступления */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_STAGE, 'Закупка по заказу');

        /* Спецификация ведомости замен */
        for spec in (
            select n1.nomen_name as SRC_NOMEN,
                   n2.nomen_name as CHNG_NOMEN,
                   t.qnt_chng    as CHNG_QUANT
              from DICNOMNS n1,
                   DICNOMNS n2,
                   (select t.numb, t.nomen, t.nomen_chng, t.qnt_chng
                           from UDO_DEPORDDIR_SP t
                           where t.PRN = rec.rn
                             and t.nomen_chng is not null
                    union
                    select t.numb, t.nomen, d.nomen_chng, d.qnt_chng
                           from UDO_DEPORDDIR_SP   t,
                                UDO_DEPORDDIR_CHNG d
                           where t.PRN = rec.rn
                             and d.prn = t.RN
                    ) t
              where t.nomen = n1.rn
                and t.nomen_chng = n2.rn
              order by t.numb, n2.nomen_code
            ) loop
            nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_SPEC);
            /* Номер по порядку */
            PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_NUMB,  0, nLINE, nLINE);
            /* Требования КД (ТД) (Наименование исходной номенклатуры) */
            PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_NOMEN, 0, nLINE, spec.src_nomen);
            /* Содержание отступления */
            PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_NOTE,  0, nLINE, spec.chng_nomen);
            /* Количество по номенклатуре замены */
            PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_QUANT, 0, nLINE, spec.chng_quant);
        end loop;

        /* Причина отступления */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_REASON, rec.reason);

        /* Подразделение-инициатор (виновник) оформления КР */
        --PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_REQSUBDIV, null);

        /* Cотрудник-инициатор (виновник) оформления КР */
        --PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_REQPERSON, null);

        /* Обоснование, заключение */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_VALIDATY, rec.BASIS);

        -- Таблица (Согласовано)
        if nKIND = 1 then
          SIGNER_PRINT(0, 'Начальник подразделения');
          SIGNER_PRINT(0, 'Зам. начальника производства по технологии и запуску в производство');
          SIGNER_PRINT(0, 'Начальник отдела разработчика');
          SIGNER_PRINT(0, 'Начальник конструкторского отдела');
          SIGNER_PRINT(0, 'Начальник ОТК');
          SIGNER_PRINT(0, 'Начальник производства');
          SIGNER_PRINT(0, 'Зам. Генерального директора по качеству');
          SIGNER_PRINT(0, 'Начальник ВП МО РФ');
        else
          SIGNER_PRINT(0, 'Начальник подразделения');
          SIGNER_PRINT(0, 'Зам. начальника производства по технологии и запуску в производство');
          SIGNER_PRINT(0, 'Начальник отдела разработчика');
          SIGNER_PRINT(0, 'Начальник конструкторского отдела');
          SIGNER_PRINT(0, 'Начальник ОТК');
          SIGNER_PRINT(0, 'Зам. Генерального директора по качеству');
          SIGNER_PRINT(0, 'От ВП МО РФ');
        end if;

        -- Таблица (Утверждено)
        if nKIND = 1 then
          SIGNER_PRINT(1, 'Главный конструктор');
          SIGNER_PRINT(1, 'Генеральный директор');
        else
          SIGNER_PRINT(1, 'Главный конструктор');
          SIGNER_PRINT(1, 'Начальник производства');
        end if;
    end loop;

    /* Удаление образцов строк */
    PRSG_EXCEL.LINE_DELETE(sLINE_SPEC);
    PRSG_EXCEL.LINE_DELETE(sLINE_AGRMNT);
    PRSG_EXCEL.LINE_DELETE(sLINE_CONFRM);
    
  end SHEET_PRINT;
  
begin

  /* Пролог */
  PRSG_EXCEL.PREPARE;

  bDATA_EXIST := false;
  for rep in (
      select SL.DOCUMENT
             from SELECTLIST SL
             where SL.IDENT = nIDENT
               and SL.UNITCODE = 'UdoDepordDir'
      ) loop
      bDATA_EXIST := true;

      /* Печать отчета */
      SHEET_PRINT( rep.DOCUMENT, nCOMPANY );
  end loop;

  /* Удаление образцов листов */
  if bDATA_EXIST then
    PRSG_EXCEL.SHEET_DELETE(sSHEET_FORM);
  end if;

end UDO_PR_DEPORDDIR_BLANK;
/

