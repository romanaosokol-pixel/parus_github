create or replace procedure UDO_P_WROFFACTSPECS_IMPCSV
(
  nCOMPANY                  in number,    -- Организация
  nIDENT                    in number,    -- Идентификатор процесса
  nPRN                      in number,    -- Регистрационный номер записи родителя
  nIDENT_MSG                out number    -- Идентификатор записей журнала сообщений (null, 0 - нет сообщений)
) as
  /*
    Процедура загрузки записей "Акты списания недостач/оприходования излишков (спецификация)" из текстового файла (*.CSV)
  */
  -- типы
  type tBUFFITEM is record(
       NOMEN      PKG_STD.tREF,
       MODIF      PKG_STD.tREF,
       SERNUMB    PKG_STD.tSTRING,
       QUANT      number,
       QUANTALT   number,
       NOTE       PKG_STD.tSTRING
       );
  type tBUFFITEMS is table of tBUFFITEM index by PKG_STD.tSTRING;
  mBUFF           tBUFFITEMS;       -- Перечень элементов
  --
  nCRN            PKG_STD.tREF;     -- Каталог
  nSTORE          PKG_STD.tREF;     -- Склад
  dDOCDATE        date;
  --
  nTRUE_REC       number := 0;      -- Признак формирования хотя бы одной записи (null - ошибка, 0 - нет, 1- да)
--  nWARNING        number;
  sMSG            PKG_STD.tSTRING;
--  sTMP            PKG_STD.tSTRING;

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

  /* выделение строки из файла */
  function F_READ_LINE
  (
    cFILE           in clob,
    nOFFSET         in out number
  ) return varchar2 is
    nPOS          pls_integer;
    nAMOUNT       pls_integer;
    sLINE         PKG_STD.tSTRING;
  begin
    nPOS    := DBMS_LOB.INSTR(LOB_LOC => cFILE, PATTERN => CR, OFFSET => nOFFSET);
    nAMOUNT := nPOS - nOFFSET;

    if nAMOUNT = 0 then
      nOFFSET := nOFFSET + 2;
      nPOS    := DBMS_LOB.INSTR(LOB_LOC => cFILE, PATTERN => CR, OFFSET => nOFFSET);
      nAMOUNT := nPOS - nOFFSET;
    end if;

    if nPOS > 0 then
      begin
        DBMS_LOB.READ(LOB_LOC => cFILE, AMOUNT => nAMOUNT, OFFSET => nOFFSET, BUFFER => sLINE);
      exception
        when others then
          P_EXCEPTION(0, 'Неправильный формат файла! nPOS "%s";  nAMOUNT "%s"; nOFFSET "%s"; sLINE "%s";', nPOS, nAMOUNT, nOFFSET, sLINE);
      end;
      nOFFSET := nPOS + 2;
    else
      nAMOUNT := (DBMS_LOB.GETLENGTH(LOB_LOC => cFILE) - nOFFSET) + 1;
      if nAMOUNT > 0 then
        DBMS_LOB.READ(LOB_LOC => cFILE, AMOUNT => nAMOUNT, OFFSET => nOFFSET, BUFFER => sLINE);
        nOFFSET := nOFFSET + nAMOUNT;
      else
        sLINE := null;
      end if;
    end if;
    /* Возвращаем результат */
    return(sLINE);
  end F_READ_LINE;

  /* Разбор строки */
  procedure LINE_PARSE
  (
    sLINE           in varchar2,  -- Исходная строка
    nNOMEN          out number,   -- Номенклатура
    nMODIF          out number,   -- Модификация
    sSERNUMB        out varchar2, -- Серия
    nQUANT          out number,   -- Количество в ОЕИ
    nQUANTALT       out number,   -- Количество в ДЕИ
    sNOTE           out varchar2  -- Примечание
  ) is
    sNOMEN_NAME  PKG_STD.tSTRING;
    sSTRQUANT    PKG_STD.tSTRING;
    nCOEFF       number;
    sMSGTEXT     PKG_STD.tSTRING;
  begin

    /* Серия */
    sSERNUMB := trim(strtok(sLINE, ';', 1));
    /* Номенклатура */
    sNOMEN_NAME   := trim(strtok(sLINE, ';', 3));
    /* Примечание */
    sNOTE         := sNOMEN_NAME;

    /* Поиск партии серии */
    if sSERNUMB is not null then
      begin
        with tDATA as (
             select distinct
                    n.rn                               as NOMEN,
                    n.equal                            as EQUAL,
                    gp.nommodif                        as NOMMODIF,
                    cmp_vc2(n.nomen_name, sNOMEN_NAME) as SIGN_NOMEN,
                    count( distinct gp.nommodif) over () as ROWCNT
               from goodsparties gp,
                    nommodif m,
                    dicnomns n
              where gp.company  = nCOMPANY
                and gp.sernumb  = sSERNUMB
                and gp.nommodif = m.rn
                and m.prn       = n.rn
              )
        select t.NOMEN, t.NOMMODIF, t.EQUAL
               into nNOMEN, nMODIF, nCOEFF
               from tDATA t
               where t.ROWCNT = 1 or SIGN_NOMEN = 1;
      exception when NO_DATA_FOUND then
                     sMSGTEXT := F_FORMAT_MESSAGE_TEXT('Приходная партия номенклатура "%s" с серией "%s" не определена.', 'PARSE', sNOMEN_NAME, sSERNUMB);
                when TOO_MANY_ROWS then
                     sMSGTEXT := F_FORMAT_MESSAGE_TEXT('Для серии "%s" определено несколько приходных партий с различными номенклатурами.', 'PARSE', sSERNUMB);
      end;
      if sMSGTEXT is not null then
        ADD_MSG(2, sMSGTEXT);
      end if;
    end if;

    /* Количество в ОЕИ */
    sSTRQUANT := strtok(sLINE, ';', 2);
    sSTRQUANT := replace(sSTRQUANT, ' ');
    begin
      nQUANT := to_number(replace(sSTRQUANT, ',', '.'));
    exception when others then
      sMSGTEXT := F_FORMAT_MESSAGE_TEXT('Ошибка преобразования строки "%s" в количество.', 'PARSE', sSTRQUANT);
      ADD_MSG(2, sMSGTEXT);
    end;

    /* Количество в ДЕИ */
    if nQUANT is not null and nCOEFF is not null then
      nQUANTALT := nQUANT * nCOEFF;
    else
      nQUANTALT := null;
    end if;

  end LINE_PARSE;

  /* Загрузка во временную таблицу из файлового буфера */
  procedure LOAD_FILE
  is
    rITEM     tBUFFITEM;
    nNOMEN    PKG_STD.tREF;
    nMODIF    PKG_STD.tREF;
    sSERNUMB  PKG_STD.tSTRING;
    nQUANT    number;
    nQUANTALT number;
    sNOTE     PKG_STD.tSTRING;
    --
    sLINE     PKG_STD.tLSTRING;
    nOFFSET   pls_integer := 1;
  begin

    for rFILE in (
        select FB.DATA,
               FB.FILENAME
          from FILE_BUFFER FB
         where FB.IDENT = nIDENT
        ) loop
    
        -- запомним лоб
        if DBMS_LOB.ISOPEN(LOB_LOC => rFILE.DATA) = 0 then
          DBMS_LOB.OPEN(LOB_LOC => rFILE.DATA, OPEN_MODE => DBMS_LOB.LOB_READONLY);
        end if;

        begin
          ---Цикл по строчкам файла
          loop
            sLINE := F_READ_LINE(rFILE.DATA, nOFFSET);
            exit when sLINE is null;
              
            /* Разбор строки */
            LINE_PARSE(sLINE, nNOMEN, nMODIF, sSERNUMB, nQUANT, nQUANTALT, sNOTE);

            /* Добавление строки спецификации */
            if nNOMEN is not null and nQUANT is not null then
               rITEM := null;
               /* Поиск строки */
               if not mBUFF.Exists(sSERNUMB) then
                 rITEM.NOMEN    := nNOMEN;
                 rITEM.MODIF    := nMODIF;
                 rITEM.SERNUMB  := sSERNUMB;
                 rITEM.QUANT    := nQUANT;
                 rITEM.QUANTALT := nQUANTALT;
                 rITEM.NOTE     := sNOTE;
               else
                 rITEM := mBUFF(sSERNUMB);
                 rITEM.QUANT    := rITEM.QUANT + nQUANT;
                 rITEM.QUANTALT := rITEM.QUANTALT + nQUANTALT;
               end if;
               mBUFF(sSERNUMB) := rITEM;
            end if;
          end loop;
          -- закроем лоб
          if DBMS_LOB.ISOPEN(LOB_LOC => rFILE.DATA) = 1 then
            DBMS_LOB.CLOSE(LOB_LOC => rFILE.DATA);
          end if;
        exception
          when others then
             -- закроем лоб
            if DBMS_LOB.ISOPEN(LOB_LOC => rFILE.DATA) = 1 then
              DBMS_LOB.CLOSE(LOB_LOC => rFILE.DATA);
            end if;
            raise;
        end;
    end loop;
  end LOAD_FILE;

  /* Загрузка во временную таблицу из файлового буфера */
  procedure MAKE_SPEC
  (
    nPRN            in number,
    nSTORE          in number,
    dRDATE          in date default null
  ) is
    rITEM       tBUFFITEM;
    nQUANT      number;
    nQUANTALT   number;
    nSPEC       PKG_STD.tREF;
    nRQUANT     number;
    nRQUANTALT  number;
    sMSGTEXT    PKG_STD.tSTRING;
    indx        PKG_STD.tSTRING;
  begin

    indx := mBUFF.First;
    ---Цикл по элементам буфера
    while (indx is not null)
      loop
      rITEM := mBUFF(indx);

      if nvl(rITEM.QUANT,0) > 0 and rITEM.MODIF is not null then
          nRQUANT    := rITEM.QUANT;
          nRQUANTALT := rITEM.QUANTALT;
          -- Подбор партий
          for rec in (
              select gp.indoc      as PARTY,
                     gs.rn         as GOODSSUPPLY,
                     h.restfact    as RESTFACT,
                     h.restfactalt as RESTFACTALT
                from goodsparties gp,
                     goodssupply  gs,
                     goodssupplyhist h,
                     incomdoc     p
                where gp.nommodif = rITEM.MODIF
                  and gp.sernumb  = rITEM.SERNUMB
                  and gp.rn       = gs.prn
                  and gs.store    = nSTORE
                  and h.prn       = gs.rn
                  and h.date_from <= nvl(dRDATE, P_TOOLS_NOW)
                  and (h.date_to >= nvl(dRDATE, P_TOOLS_NOW) or h.date_to is null)
                  and h.restfact > 0
                  and gp.indoc   = p.rn
                order by p.entry_date, p.rn
              ) loop

              /* Проверка на дублирование строки спецификации */
              begin
                select ts.rn into nSPEC
                  from WROFFACTSPECS ts
                 where ts.prn         = nPRN
                   and ts.nommodif    = rITEM.MODIF
                   and ts.goodssupply = rec.goodssupply;
              exception when NO_DATA_FOUND then nSPEC := null;
              end;

              if nSPEC is null then
                /* Определяем количество партии */
                nQUANT    := least(nRQUANT, rec.restfact);
                nQUANTALT := least(nRQUANTALT, rec.restfactalt);

                /* Добавление записи */
                P_WROFFACTSPECS_BASE_INSERT(
                    nCOMPANY        => nCOMPANY,
                    nPRN            => nPRN,
                    nGOODSSUPPLY    => rec.goodssupply,
                    nNOMMODIF       => rITEM.MODIF,
                    nNOMMODIFPACK   => null,
                    nARTICLE        => null,
                    nCELL           => null,
                    nQUANT          => nQUANT,
                    nQUANTALT       => nQUANTALT,
                    nPRICE          => 0,
                    nPRICEMEAS      => 0,
                    nSUMM           => 0,
                    sNOTE           => null,
                    nRN             => nSPEC
                    );
                nRQUANT    := nRQUANT - nQUANT;
                nRQUANTALT := nRQUANTALT - nQUANTALT;
                /* фиксируем добавление спецификации */
                nTRUE_REC := nTRUE_REC + 1;
              else
                sMSGTEXT := F_FORMAT_MESSAGE_TEXT( 'Строка спецификации акта списания недостач/оприходования излишков (номенклатура "%s", серия "%s", партия "%s") уже существует.', 'INSERT',
                                                   rITEM.NOTE, rITEM.SERNUMB, UDO_GET_INCOMDOC_CODE_ID(1, rec.party));
                ADD_MSG(1, sMSGTEXT);
              end if;
              /* Досрочный выход */
              exit when nRQUANT <= 0;
          end loop;
          /* Нераспределенный остаток */
          if nRQUANT > 0 then
            sMSGTEXT := F_FORMAT_MESSAGE_TEXT( 'Остаток товарного запаса для номенклатуры "%s" серия "%s" недостаточен (требуется = %s, доступно = %s).', 'INSERT',
                                               rITEM.NOTE, rITEM.SERNUMB, rITEM.QUANT, rITEM.QUANT - nRQUANT);
            ADD_MSG(1, sMSGTEXT);
          end if;
      end if;
      /* Следующий */
      begin
      indx := mBUFF.Next(indx);
      exception
        when others then
          p_exception(0, 'indx = %s, count = %s', indx, mBUFF.Count);
      end;
    end loop;
  end MAKE_SPEC;

/* ОСНОВНАЯ ПРОЦЕДУРА */
begin
  /* Инициализация */
  nIDENT_MSG  := 0;

  /* Считывание записи */
  begin
  select t.crn, t.store, t.docdate
         into nCRN, nSTORE, dDOCDATE
         from WROFFACTS t
         where t.rn = nPRN;
  exception when NO_DATA_FOUND then
            PKG_MSG.RECORD_NOT_FOUND(0, nPRN, 'WriteOffActs');
  end;

  /* Проверка прав доступа */
  PKG_ENV.ACCESS(nCOMPANY, null, nCRN, 'WriteOffActs', 'UDO_WROFFACTSPECS_IMPCSV');

  /* Загрузка из текстового файла в буфер */
  LOAD_FILE;

  /* Обработка буфера и перенос в таблицы */
  MAKE_SPEC(nPRN, nSTORE, dDOCDATE);

  /* Должный быть выполненны операции */
  if nTRUE_REC = 0 then
    p_exception(0, 'Нет данных для формирования документа.');
  end if;

end UDO_P_WROFFACTSPECS_IMPCSV;
/

