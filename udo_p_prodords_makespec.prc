create or replace procedure UDO_P_PRODORDS_MAKESPEC
(
  nCOMPANY                  in number, -- Организация
  nORDSP                    in number  -- Строка заказа на производство
) is
/*
  11/07/2023 Марков МВ.
  Заказы на производство (спецификация)
  Действие "Показать состояние производства"
*/
  /* Константы */
  sRTLST_TYPE       constant PKG_STD.tSTRING := 'ТехПаспорт';   -- Тип документа маршрутного листа
  /* Типы */
  type tRLARTCS is table of number;
  rRLARTCS          tRLARTCS;        -- Серийные номера

  nCRN              PKG_STD.tREF;   -- Каталог
  nJUR_PERS         PKG_STD.tREF;   -- Юридическое лицо
  nPRJSTAGE         PKG_STD.tREF;   -- Этап проекта
  nMATRES           PKG_STD.tREF;   -- Изделие
  nMATRES_NOMEN     PKG_STD.tREF;   -- Номенклатура изделия
  nMATRES_MODIF     PKG_STD.tREF;   -- Модификация изделия
  nQUANT_FACT       number;         -- Количество изделий (факт)
  nPRODORD          PKG_STD.tREF;   -- Заказ на производство
--  nPRODORDSP        PKG_STD.tREF;   -- Спецификация заказа на производство
--  nPRODPLAN         PKG_STD.tREF;   -- План производства изделий (производственная программа)
  nPRODPLANSP       PKG_STD.tREF;   -- Строка плана производства изделий (производственная программа)
  nSHEETSP          PKG_STD.tREF;   -- Строка спецификации ведомости производства
  nARTICLE          PKG_STD.tREF;   -- Серийный номер
--  nRTLST            PKG_STD.tREF;   -- Маршрутный лист
  nRTLST_TYPE       PKG_STD.tREF;   -- Тип документа маршрутного листа
  nSIGN_MODE        number := 0;    -- Режим формирования спецификации: 0-по заводскому номеру; 1-по производственной программе;
  nINDX             number;
  sTMP              PKG_STD.tSTRING;

  /* Комплектовочные ведомости комплектующей */
  procedure COMPL_DELIVSH_ADD(
            nCOMPANY        in number, -- Организация
            nSHEETSP        in number, -- Строка спецификации ведомости производства
            nROUTLST        in number  -- Маршрутный лист
            ) is
    nSHEETDLVSH     PKG_STD.tREF;    -- Комлектовочная ведомость ведомости производства
  begin

    /* Комплектовочные ведомости комплектующей */
    for dlvsh in (
        select dl.out_document as RN
          from doclinks dl
          where dl.in_unitcode  = 'CostRouteLists'
            and dl.in_document  = nROUTLST
            and dl.out_unitcode = 'CostDeliverySheets'
        ) loop

        /* Поиск комплектовочной ведомости */
        UDO_PKG_PRJSTG_SHEET_BASE.FIND_DLVSH_DELIVSH(1, nSHEETSP, dlvsh.rn, nSHEETDLVSH);

        /* Добавление записи комплектовочной ведомости */
        if nSHEETDLVSH is null then
            UDO_PKG_PRJSTG_SHEET_BASE.DLVSH_INSERT(
                nCOMPANY     => nCOMPANY,
                nPRN         => nSHEETSP,
                nDELIVSH     => dlvsh.rn,
                nRN          => nSHEETDLVSH
                );
        end if;
    end loop;
  end COMPL_DELIVSH_ADD;

  /* Формирование иерархии состояний по производственной программе */
  procedure ORDSPROD_MAKE(
            nCOMPANY        in number,  -- Организация
            nORDSP          in number,  -- Ведомость производства
            nPRODPLANSP     in number,  -- Строка плана производства изделий (производственная программа)
            nARTICLE        in number   -- Серийный номер
            ) is
    nSHEETSP      PKG_STD.tREF;    -- Строка спецификации ведомости производства
    iORDER_NUMB   pls_integer;
  begin

    /* Иерархия производственной программы */
    for rec in (
        select t.rn, t.prn, t.prn_node, t.matres, t.per_matres, t.nesting_level, t.part_of, t.up_level, t.prodcmp, t.prodcmpsp
         from FCPRODPLANSP t
         connect by prior t.rn = t.up_level
         start with t.rn = nPRODPLANSP
  --       order by siblings t.nrn
        ) loop

        /* Поиск записи */
        UDO_PKG_PRJSTG_SHEET_BASE.FIND_SPEC_PRODPLAN(1, nSHEET, rec.rn, nSHEETSP);

        /* Добавление записи иерархии ведомости производства */
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
            /* Маршрутные листы комплектующей */
            for rlst in (
                select dl.out_document as RN
                  from doclinks dl
                  where dl.in_unitcode  = 'CostProductPlansSpecs'
                    and dl.in_document  = rec.rn
                    and dl.out_unitcode = 'CostRouteLists'
                ) loop
                /* Комплектовочные ведомости комплектующей */
                COMPL_DELIVSH_ADD(nCOMPANY, nSHEETSP, rlst.rn);
            end loop;
        else
            for rlst in (
                select r.*
                  from table(UDO_F_FCPRODPLANSP_ARTCL_DISTR(rec.rn, nCOMPANY, iORDER_NUMB)) r
                ) loop
                /* Комплектовочные ведомости комплектующей */
                COMPL_DELIVSH_ADD(nCOMPANY, nSHEETSP, rlst.ROUTLST);
            end loop;
        end if;
    end loop;
  end ORDSPROD_MAKE;

/* ОСНОВНАЯ ПРОЦЕДУРА */
begin

  /* Считывание записи родителя */
  begin
    select P.RN, P.CRN, PS.MAIN_QUANT, PS.NOMEN, PS.NOM_MODIF,
           (select MR.RN from FCMATRESOURCE MR where MR.NOMEN_MODIF = PS.NOM_MODIF)
      into nPRODORD, nCRN, nQUANT_FACT, nMATRES_NOMEN, nMATRES_MODIF,
           nMATRES
      from PRODUCTORD  P,
           PRODUCTORDS PS
      where PS.RN      = nORDSP
        and PS.PRN     = P.RN
        and P.COMPANY = nCOMPANY;
  exception
    when NO_DATA_FOUND then
         PKG_MSG.RECORD_NOT_FOUND(0, nORDSP, 'ProductionOrdersSpecs');
  end;

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY, null, nCRN, 'ProductionOrdersSpecs', 'UDO_PRJSTG_SHEET_MAKESPEC', 'PRODUCTORDS', nORDSP);

  /* Разрешение ссылок */
  FIND_DOCTYPES_CODE_EX(0,0, nCOMPANY, sRTLST_TYPE, nRTLST_TYPE);

  /* Очистка спецификации ведомости производства */
  --UDO_PKG_PRJSTG_SHEET_BASE.SPEC_CLEAR(nCOMPANY, nSHEET);

  /* Серийные номера изделий по производственной программе */
  nSIGN_MODE := 1;

  /* Цикл по строкам спецификации заказа на производство */
  for ords in (
      select rs.rn
        from PRODUCTORDS rs
        where rs.rn = nORDSP
      ) loop

      /* Строка плана выпуска (годовой) */
      nPRODPLANSP := F_DOCLINKS_LINK_OUT_DOC('ProductionOrdersSpecs', ords.rn, 'CostProductPlansSpecs');
      if nPRODPLANSP is null then
        p_exception(0, 'Строка Заказа на производство не включена в план выпуска.');
      end if;

      /* Строка плана производства */
      begin
        select ps.rn
          into nPRODPLANSP
          from FCPRODPLANSP ps
          where ps.prn_node = nPRODPLANSP
            and ps.nesting_level = 0;
      exception when NO_DATA_FOUND then
        p_exception(0, 'Строка Заказа на производство не включена в производственную программу.');
      end;

      /* Иерархия производственной программы */
      ORDSPROD_MAKE(
            nCOMPANY        => nCOMPANY,
            nORDSP          => nORDSP,
            nPRODPLANSP     => nPRODPLANSP,
            nARTICLE        => nARTICLE
            );

  end loop;

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY, null, nCRN, 'ProductionOrdersSpecs', 'UDO_PRJSTG_SHEET_MAKESPEC', 'PRODUCTORDS', nORDSP);

end UDO_P_PRODORDS_MAKESPEC;
/

