create or replace procedure UDO_P_PRJSTG_SHEET_MAKESPEC
(
  nCOMPANY in number, -- Организация
  nIDENT   in number, -- Идентификатор процесса
  nSHEET   in number -- Ведомость производства
) is
  /*
    -- Author  : ЦИТК ПАРУС (ASTAFIEV_D)
    -- Created : 08.06.2023
    -- Purpose : Действие "Сформировать спецификацию состояний производства" раздела "Проекты (этапы, ведомость производства)"
    Алгоритм:
  */
  /* Константы */
  sRTLST_TYPE constant PKG_STD.tSTRING := 'ТехПаспорт'; -- Тип документа маршрутного листа
  /* Типы */
  type tRLARTCS is table of number;
  rRLARTCS tRLARTCS; -- Серийные номера

  nCRN          PKG_STD.tREF; -- Каталог
  nJUR_PERS     PKG_STD.tREF; -- Юридическое лицо
  nPRJSTAGE     PKG_STD.tREF; -- Этап проекта
  nMATRES       PKG_STD.tREF; -- Изделие
  nMATRES_NOMEN PKG_STD.tREF; -- Номенклатура изделия
  nMATRES_MODIF PKG_STD.tREF; -- Модификация изделия
  nQUANT_FACT   number; -- Количество изделий (факт)
  nPRODORD      PKG_STD.tREF; -- Заказ на производство
  --  nPRODORDSP        PKG_STD.tREF;   -- Спецификация заказа на производство
  --  nPRODPLAN         PKG_STD.tREF;   -- План производства изделий (производственная программа)
  nPRODPLANSP PKG_STD.tREF; -- Строка плана производства изделий (производственная программа)
  nSHEETSP    PKG_STD.tREF; -- Строка спецификации ведомости производства
  nARTICLE    PKG_STD.tREF; -- Серийный номер
  --  nRTLST            PKG_STD.tREF;   -- Маршрутный лист
  nRTLST_TYPE PKG_STD.tREF; -- Тип документа маршрутного листа
  nSIGN_MODE  number := 0; -- Режим формирования спецификации: 0-по заводскому номеру; 1-по производственной программе;
  nINDX       number;
  sTMP        PKG_STD.tSTRING;
  --
  nPRODORDSP PKG_STD.tREF; -- строка заказа на производство
  --
  bEXEC      boolean; -- признак наличия данных

  /* Комплектовочные ведомости комплектующей */
  /*  procedure COMPL_DELIVSH_ADD(
            nCOMPANY        in number, -- Организация
            nSHEETSP        in number, -- Строка спецификации ведомости производства
            nROUTLST        in number  -- Маршрутный лист
            ) is
    nSHEETDLVSH     PKG_STD.tREF;    -- Комлектовочная ведомость ведомости производства
  begin
  
    \* Комплектовочные ведомости комплектующей *\
    for dlvsh in (
        select dl.out_document as RN 
          from doclinks dl
          where dl.in_unitcode  = 'CostRouteLists'
            and dl.in_document  = nROUTLST
            and dl.out_unitcode = 'CostDeliverySheets'
        ) loop
  
        \* Поиск комплектовочной ведомости *\
        UDO_PKG_PRJSTG_SHEET_BASE.FIND_DLVSH_DELIVSH(1, nSHEETSP, dlvsh.rn, nSHEETDLVSH);
                    
        \* Добавление записи комплектовочной ведомости *\
        if nSHEETDLVSH is null then
            UDO_PKG_PRJSTG_SHEET_BASE.DLVSH_INSERT(
                nCOMPANY     => nCOMPANY,
                nPRN         => nSHEETSP,
                nDELIVSH     => dlvsh.rn,
                nRN          => nSHEETDLVSH
                );
        end if;
    end loop;
  end COMPL_DELIVSH_ADD;*/

  /* Формирование иерархии состояний по производственной программе */
  /*  procedure SHEETSPEC_MAKE(
            nCOMPANY        in number,  -- Организация
            nSHEET          in number,  -- Ведомость производства
            nPRODPLANSP     in number,  -- Строка плана производства изделий (производственная программа)
            nARTICLE        in number   -- Серийный номер
            ) is
    nSHEETSP      PKG_STD.tREF;    -- Строка спецификации ведомости производства
    iORDER_NUMB   pls_integer;
  begin
  
    if nARTICLE is not null then
      iORDER_NUMB := UDO_F_FCPRODPLANSP_ARTCL_NUMB(0, nPRODPLANSP, nARTICLE); 
    end if;
  
    \* Иерархия производственной программы *\
    for rec in (
        select t.rn, t.prn, t.prn_node, t.matres, t.per_matres, t.nesting_level, t.part_of, t.up_level, t.prodcmp, t.prodcmpsp
         from FCPRODPLANSP t
         connect by prior t.rn = t.up_level
         start with t.rn = nPRODPLANSP
  --       order by siblings t.nrn
        ) loop
  
        \* Поиск записи *\
        UDO_PKG_PRJSTG_SHEET_BASE.FIND_SPEC_PRODPLAN(1, nSHEET, rec.rn, nSHEETSP);
          
        \* Добавление записи иерархии ведомости производства *\
        if nSHEETSP is null then
            UDO_PKG_PRJSTG_SHEET_BASE.SPEC_INSERT(
                nCOMPANY       => nCOMPANY,
                nPRN           => nSHEET,
                nMATRES        => rec.matres,
                nNESTING_LEVEL => rec.nesting_level,
                nPRODPLANSP    => rec.rn,
                nUP_LEVEL      => rec.up_level,
                nPRODCMP       => rec.prodcmp,
                PRODCMPSP      => rec.prodcmpsp,
                nRN            => nSHEETSP
                );
        end if;
  
        if nARTICLE is null then
            \* Маршрутные листы комплектующей *\
            for rlst in (
                select dl.out_document as RN
                  from doclinks dl
                  where dl.in_unitcode  = 'CostProductPlansSpecs'
                    and dl.in_document  = rec.rn
                    and dl.out_unitcode = 'CostRouteLists'
                ) loop
                \* Комплектовочные ведомости комплектующей *\
                COMPL_DELIVSH_ADD(nCOMPANY, nSHEETSP, rlst.rn);
            end loop;
        else
            for rlst in (
                select r.* 
                  from table(UDO_F_FCPRODPLANSP_ARTCL_DISTR(rec.rn, nCOMPANY, iORDER_NUMB)) r
                ) loop
                \* Комплектовочные ведомости комплектующей *\
                COMPL_DELIVSH_ADD(nCOMPANY, nSHEETSP, rlst.ROUTLST);
            end loop;
        end if;
    end loop;
  end SHEETSPEC_MAKE;*/

  /* ОСНОВНАЯ ПРОЦЕДУРА */
begin

  /* Считывание записи родителя */
  begin
    select ps.crn,
           ps.jur_pers,
           t.prn,
           t.matres,
           t.quant_fact
      into nCRN,
           nJUR_PERS,
           nPRJSTAGE,
           nMATRES,
           nQUANT_FACT
      from UDO_PROJECTSTAGE_SHT t,
           PROJECTSTAGE         ps
     where t.rn = nSHEET
       and t.prn = ps.rn
       and ps.company = nCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, nSHEET, 'UDOProjectsStagesSheet');
  end;

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJUR_PERS,
                   null,
                   'UDOProjectsStagesSheet',
                   'UDO_PRJSTG_SHEET_MAKESPEC',
                   'UDO_PROJECTSTAGE_SHT',
                   nSHEET);

  /* Разрешение ссылок */
  FIND_DOCTYPES_CODE_EX(0, 0, nCOMPANY, sRTLST_TYPE, nRTLST_TYPE);

  /* Очистка спецификации ведомости производства */
  UDO_P_PRODSHEET_CLEAN(nCOMPANY, nIDENT);

  /* Очистка спецификации ведомости производства */
  --  UDO_PKG_PRJSTG_SHEET_BASE.SPEC_CLEAR(nCOMPANY, nSHEET);

  /* Реквизиты изделия */
  begin
    select mr.nomenclature,
           mr.nomen_modif
      into nMATRES_NOMEN,
           nMATRES_MODIF
      from fcmatresource mr
     where mr.rn = nMATRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, nMATRES, 'CostMaterialResources');
  end;

  /* Серийные номера изделий по ведомости */
  select pr.article bulk collect
    into rRLARTCS
    from UDO_PROJECTSTAGE_SHT_ART pr,
         RLARTICLES               ra
   where pr.prn = nSHEET
     and pr.article = ra.rn
   order by ra.name;

  /* Серийные номера изделий по производственной программе */
  if rRLARTCS.Count = 0 then
    nSIGN_MODE := 1;
  end if;

  -- по указанному заводскому номеру
  bEXEC := true;
  if nSIGN_MODE = 0 then
      /* Серийный номер */
      nINDX := rRLARTCS.First;
    
    /* Цикл по серийным номерам */
    loop
      bEXEC := false;
      /* Серийный номер */
      if nINDX is not null then
        nARTICLE := rRLARTCS(nINDX);
      else
        nARTICLE := null;
      end if;
    
      /* Формирование по заводскому номеру */
      /* Определяем строку производственного плана через маршрутный лист */
      begin
        select ps.rn,
               (select ORDS.RN
                  from PRODUCTORDS ORDS,
                       DOCLINKS    L
                 where L.OUT_DOCUMENT = PS.PRN_NODE
                   and L.OUT_UNITCODE = 'CostProductPlansSpecs'
                   and L.IN_DOCUMENT = ORDS.RN
                   and L.IN_UNITCODE = 'ProductionOrdersSpecs')
          into nPRODPLANSP,
               nPRODORDSP
          from FCROUTLST    R,
               DOCLINKS     D,
               FCPRODPLANSP PS
         where d.in_unitcode = 'CostProductPlansSpecs'
           and d.in_document = ps.rn
           and d.out_unitcode = 'CostRouteLists'
           and d.out_document = r.rn
           and r.doctype = nRTLST_TYPE
           and r.matres = nMATRES
           and exists (select null
                  from FCROUTLSTSERNUMB rs
                 where rs.prn = r.rn
                   and rs.article = nARTICLE
                   and nARTICLE is not null);
      exception
        when NO_DATA_FOUND then
          nPRODPLANSP := null;
      end;
 
      -- 11/07/2023 Марков МВ.
      if nPRODPLANSP is null then
        if nARTICLE is not null then
          begin
            select replace(RA.CODE, NM.NOMEN_CODE || '_')
              into sTMP
              from RLARTICLES RA,
                   NOMMODIF   MD,
                   DICNOMNS   NM
             where RA.RN = nARTICLE
               and RA.NOMMODIF = MD.RN
               and MD.PRN = NM.RN;
          exception
            when no_data_found then
              p_exception(0, 'Серийный номер изделия не найден. RN: %s', nARTICLE);
          end;
          null; --12/09/2023 Марков МВ. p_exception(0, 'Заводской номер %s не включен в производственную программу.', sTMP);
        else
          p_exception(0,
                      'Строка Ведомости производства не включена в производственную программу.'||chr(10)||
                      'nARTICLE = %s'||chr(10)||
                      'nMATRES = %s',
                      nARTICLE, nMATRES);
        end if;
      
      else
        /* Иерархия производственной программы */
        /*          SHEETSPEC_MAKE(
                        nCOMPANY        => nCOMPANY,
                        nSHEET          => nSHEET,
                        nPRODPLANSP     => nPRODPLANSP,
                        nARTICLE        => nARTICLE
                        );
        */
        /* Иерархия производственной программы */
        UDO_P_PRODSHEET_APPEND(nCOMPANY    => nCOMPANY,
                               nIDENT      => nIDENT,
                               nPRODORDSP  => nPRODORDSP,
                               nPRODPLANSP => nPRODPLANSP,
                               nARTICLE    => nARTICLE);
      end if;
    
      /* Следующий серийный номер */
      nINDX := rRLARTCS.Next(nINDX);
      exit when nINDX is null;
    end loop;
  
  else
    /* Заказ на производство */
    nPRODORD := F_DOCLINKS_LINK_OUT_DOC('UDOProjectsStagesSheet', nSHEET, 'ProductionOrders');
  
    /* Цикл по строкам спецификации заказа на производство */
    for ords in (select rs.rn
                   from PRODUCTORDS rs
                  where rs.prn = nPRODORD
                    and rs.nomen = nMATRES_NOMEN
                    and cmp_num(rs.nom_modif, nMATRES_MODIF) = 1) loop
    
      bEXEC := false;
      /* Строка плана производства (годовой) */
      nPRODPLANSP := F_DOCLINKS_LINK_OUT_DOC('ProductionOrdersSpecs', ords.rn, 'CostProductPlansSpecs');
    
      /* Строка плана производства */
      begin
        select ps.rn
          into nPRODPLANSP
          from FCPRODPLANSP ps
         where ps.prn_node = nPRODPLANSP
           and ps.nesting_level = 0;
      exception
        when NO_DATA_FOUND then
          null;
      end;

      /* Серийный номер */
      nINDX := rRLARTCS.First;
    
      /* Цикл по серийным номерам */
      loop
        /* Серийный номер */
        if nINDX is not null then
          nARTICLE := rRLARTCS(nINDX);
        else
          nARTICLE := null;
        end if;
      
        /* Формирование по заводскому номеру */
        if nSIGN_MODE = 0 then
          /* Определяем строку производственного плана через маршрутный лист */
          begin
            select ps.rn
              into nPRODPLANSP
              from FCROUTLST    R,
                   DOCLINKS     D,
                   FCPRODPLANSP PS
             where d.in_unitcode = 'CostProductPlansSpecs'
               and d.in_document = ps.rn
               and d.out_unitcode = 'CostRouteLists'
               and d.out_document = r.rn
               and r.doctype = nRTLST_TYPE
               and r.matres = nMATRES
               and (nARTICLE is null or exists (select null
                                                  from FCROUTLSTSERNUMB rs
                                                 where rs.prn = r.rn
                                                   and rs.article = nARTICLE));
          exception
            when NO_DATA_FOUND then
              nPRODPLANSP := null;
          end;
        end if;
      
        -- 11/07/2023 Марков МВ.
        if nPRODPLANSP is null then
          if nARTICLE is not null then
            begin
              select replace(RA.CODE, NM.NOMEN_CODE || '_')
                into sTMP
                from RLARTICLES RA,
                     NOMMODIF   MD,
                     DICNOMNS   NM
               where RA.RN = nARTICLE
                 and RA.NOMMODIF = MD.RN
                 and MD.PRN = NM.RN;
            exception
              when no_data_found then
                p_exception(0, 'Серийный номер изделия не найден. RN: %s', nARTICLE);
            end;
            null; --12/09/2023 Марков МВ. p_exception(0, 'Заводской номер %s не включен в производственную программу.', sTMP);
          else
            p_exception(0,
                        'Строка Ведомости производства не включена в производственную программу.');
          end if;
        
        else
          /* Иерархия производственной программы */
          /*          SHEETSPEC_MAKE(
                          nCOMPANY        => nCOMPANY,
                          nSHEET          => nSHEET,
                          nPRODPLANSP     => nPRODPLANSP,
                          nARTICLE        => nARTICLE
                          );
          */
          /* Иерархия производственной программы */
          UDO_P_PRODSHEET_APPEND(nCOMPANY    => nCOMPANY,
                                 nIDENT      => nIDENT,
                                 nPRODORDSP  => ords.rn,
                                 nPRODPLANSP => nPRODPLANSP,
                                 nARTICLE    => nARTICLE);
        end if;
      
        /* Следующий серийный номер */
        nINDX := rRLARTCS.Next(nINDX);
        exit when nINDX is null;
      end loop;
    
    end loop;
  end if;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJUR_PERS,
                   null,
                   'UDOProjectsStagesSheet',
                   'UDO_PRJSTG_SHEET_MAKESPEC',
                   'UDO_PROJECTSTAGE_SHT',
                   nSHEET);

  -- контроль наличия данных
  if bEXEC then
    p_exception(0, 'Номенклатура по ведомости производства не найдена в заказах на производства.');
  end if;
  
end UDO_P_PRJSTG_SHEET_MAKESPEC;
/
