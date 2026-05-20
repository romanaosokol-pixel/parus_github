create or replace procedure USR_P_FACEACC_SET_OPERS
/* Процедура отражения исполнения товарных документов на заданном графике лицевого счёта. По мотивам одноимённой штатной процедуры */
(
  nCOMPANY          in number,
  nFACEACC          in number,
  nGRAPHPOINT       in number,
  nCURRENCY         in number,
  DDATE             in date,            -- дата пересчета курса валюты
  nINEXP_SIGN       in number,          -- приход в приходных документах - (0), расход в расходных документах (1), расход в приходных документах - (2), приход в расходных документах - (3)
  nPLAN_SIGN        in number,          -- исполнение по плану(1)
  nFACT_SIGN        in number,          -- исполненеи фактически(1)
  nMODIF            in number,
  nPACK             in number,
  sSERNUMB          in varchar2,        -- Серия
  nCOUNTRY          in number,          -- Страна производителя
  sGTD              in varchar2,        -- Реквизиты ГТД
  nARTICLE          in number,
  nROLLBACK         in number,          -- откат (1)
  nPLAN_QUANT       in number,          -- плановое количество
  nPLAN_QUANT_ALT   in number,          -- плановое количество
  nFACT_QUANT       in number,          -- фактическое количество
  nFACT_QUANT_ALT   in number,          -- фактическое количество
  nPLAN_SUM         in number,          -- плановая сумма исполнения в nCURRENCY, если null то базовой валюте
  nFACT_SUM         in number,          -- фактическая сумма исполнения в nCURRENCY, если null то  базовой валюте
  sSPEC_UNITCODE    in varchar2,        -- код раздела спецификации
  nSPEC_RN          in number           -- регистрационный номер записи спецификации
 ,nFAOP             in number           /* RN графика */
)
as
  vINEXP_SIGN       number;
  nSIGN             integer := sign( ( 3 / 2 ) - nINEXP_SIGN );
  vPSUM             PKG_STD.tSUMM := nPLAN_SUM;
  vFSUM             PKG_STD.tSUMM := nFACT_SUM;
  nNOMEN            PKG_STD.tREF;
  nNOMENPACK        PKG_STD.tREF;
  nPACK_QUANT       NOMNPACK.QUANT%type;
  vPLAN_QUANT       PKG_STD.tQUANT;
  vFACT_QUANT       PKG_STD.tQUANT;

  nDOC_SUM          PKG_STD.tLNUMBER;
  nDOC_SUMTAX       PKG_STD.tLNUMBER;
  nDOC_SUM_NDS      PKG_STD.tLNUMBER;

  nCONTRACT         PKG_STD.tREF;
  nBASE_CURRENCY    PKG_STD.tREF := nCURRENCY;
  nCOUR_SUM         PKG_STD.tLNUMBER;
  nCOUR_BSUM        PKG_STD.tLNUMBER;
  nRESULT           PKG_STD.tLNUMBER;
  vCURRENCY         PKG_STD.tREF;       -- валюта лицевого счета
  nACC_KIND         FACEACC.ACC_KIND%type;
  nLINK_TYPE_OLD    PKG_STD.tNUMBER;    -- 0 - план, 1 - факт, 2 - план/факт
  nLINK_TYPE        PKG_STD.tNUMBER;
  nFACT_QUANT_NEW   FCACOPERPLANS.FACT_QUANT%type;
--
  nTMP              PKG_STD.tLNUMBER;

  /* считывание количества в упаковке */
  function GET_NOMNPACK_QUANT
  (
    nRN               in number
  )
  return number
  is
    nQUANT            NOMNPACK.QUANT%type;
  begin
    begin
      select QUANT
        into nQUANT
        from NOMNPACK
       where RN = nRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(nRN, 'NomenclatorPacking');
    end;

    return nQUANT;
  end GET_NOMNPACK_QUANT;

  /* пересчет поля «Обеспечено исполнением поставок / отгрузок»
    в дочерних записях «Связанных графиков поступления товаров и услуг» */
  procedure RECALC_PROV_QUANT
  (
    nACC_KIND           in number,
    nINEXP_SIGN         in number,
    nOPERPLAN           in number,
    nFACT_QUANT         in number,          -- Новое "Исполнено факт"
    nQUANT_MEAS         in number,
    nUMEAS_MAIN         in number,
    nUMEAS_ALT          in number,
    nNOMENPACK          in number
  )
  is
    nQUANT_IN_PACK      PKG_STD.tQUANT;
    nQUANT_IN_PACK_NEW  PKG_STD.tQUANT;
    nFACT_QUANT_        PKG_STD.tQUANT := nFACT_QUANT;
    nPROV_QUANT         FCACOPERPLANS_LINK.PROV_QUANT%type;
  begin
    /* вид лицевого счета «Продажа», а строка графика «Получение»,
      или вид лицевого счета «Покупка», а строка графика «Отпуск» */
    if ( nACC_KIND = 1 ) and ( nINEXP_SIGN = 0 ) or
       ( nACC_KIND = 0 ) and ( nINEXP_SIGN = 1 )
    then
      if ( nNOMENPACK is not null ) then
        nQUANT_IN_PACK := GET_NOMNPACK_QUANT(nNOMENPACK);
      end if;

      /* пересчет поля «Обеспечено исполнением поставок / отгрузок»
        в дочерних записях «Связанных графиков поступления товаров и услуг» */
      for rLINK in
      (
        select L.RN, OO.QUANT, OO.QUANT_MEAS,
               nvl(OO.NOMENPACK, MP.NOMENPACK) as NOMENPACK, N.UMEAS_MAIN, N.UMEAS_ALT, N.EQUAL
          from FCACOPERPLANS_LINK L,
               FCACOPERPLANS      OO,
               DICNOMNS           N,
               NOMNMODIFPACK      MP
         where nINEXP_SIGN     = 0
           and L.PLAN_IN       = nOPERPLAN
           and L.PLAN_OUT      = OO.RN
           and OO.NOMEN        = N.RN
           and OO.NOMMODIFPACK = MP.RN(+)
        union all
        select L.RN, OI.QUANT, OI.QUANT_MEAS,
               nvl(OI.NOMENPACK, MP.NOMENPACK) as NOMENPACK, N.UMEAS_MAIN, N.UMEAS_ALT, N.EQUAL
          from FCACOPERPLANS_LINK L,
               FCACOPERPLANS      OI,
               DICNOMNS           N,
               NOMNMODIFPACK      MP
         where nINEXP_SIGN     = 1
           and L.PLAN_OUT      = nOPERPLAN
           and L.PLAN_IN       = OI.RN
           and OI.NOMEN        = N.RN
           and OI.NOMMODIFPACK = MP.RN(+)
      )
      loop
        if ( rLINK.NOMENPACK is not null ) then
          nQUANT_IN_PACK_NEW := GET_NOMNPACK_QUANT(rLINK.NOMENPACK);
        end if;

        if ( rLINK.EQUAL = 0 ) then
          rLINK.EQUAL := 1;
        end if;

        if ( nQUANT_IN_PACK_NEW = 0 ) then
          nQUANT_IN_PACK_NEW := 1;
        end if;

        -- проверка на совпадение ЕИ
        if ( nQUANT_MEAS in ( 0,2 ) ) and ( nUMEAS_MAIN = rLINK.UMEAS_MAIN ) or
           ( nQUANT_MEAS = 1 ) and ( nUMEAS_ALT = rLINK.UMEAS_ALT )
        then
          -- пересчитаем в ЕИ текущей записи
          if ( nQUANT_MEAS = 0 ) then
            if ( rLINK.QUANT_MEAS = 1 ) then
              nPROV_QUANT := rLINK.QUANT / rLINK.EQUAL;
            elsif ( rLINK.QUANT_MEAS = 2 ) then
              nPROV_QUANT := rLINK.QUANT * nQUANT_IN_PACK_NEW;
            else  -- ( rLINK.QUANT_MEAS = 0 )
              nPROV_QUANT := rLINK.QUANT;
            end if;
          elsif ( nQUANT_MEAS = 1 ) then
            if ( rLINK.QUANT_MEAS = 0 ) then
              nPROV_QUANT := rLINK.QUANT * rLINK.EQUAL;
            elsif ( rLINK.QUANT_MEAS = 2 ) then
              nPROV_QUANT := rLINK.QUANT * nQUANT_IN_PACK_NEW * rLINK.EQUAL;
            else  -- ( rLINK.QUANT_MEAS = 1 )
              nPROV_QUANT := rLINK.QUANT;
            end if;
          elsif ( nQUANT_MEAS = 2 ) then
            if ( rLINK.QUANT_MEAS = 0 ) then
              nPROV_QUANT := rLINK.QUANT / nQUANT_IN_PACK;
            elsif ( rLINK.QUANT_MEAS = 1 ) then
              nPROV_QUANT := rLINK.QUANT / rLINK.EQUAL / nQUANT_IN_PACK;
            else  -- ( rLINK.QUANT_MEAS = 2 )
              nPROV_QUANT := rLINK.QUANT * nQUANT_IN_PACK_NEW / nQUANT_IN_PACK;
            end if;
          end if;

          nPROV_QUANT := least(nPROV_QUANT, nFACT_QUANT_);

          nFACT_QUANT_ := greatest(nFACT_QUANT_ - nPROV_QUANT, 0);

          update FCACOPERPLANS_LINK
             set PROV_QUANT = nPROV_QUANT
           where RN      = rLINK.RN
             and COMPANY = nCOMPANY;

          if ( SQL%NOTFOUND ) then
            P_EXCEPTION(0, 'Запись связи графиков поставок с графиками отгрузок не найдена.');
          end if;
        end if;
      end loop;
    end if;
  end RECALC_PROV_QUANT;

begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_FACEACC_SET_OPERS');

  /* если валюта не указана, то считываем базовую валюту */
  if ( nBASE_CURRENCY is null ) then
    FIND_CURRENCY_BASE(nCOMPANY, nBASE_CURRENCY);
  end if;

  /* считывание валюты ЛС */
  begin
    select CURRENCY, ACC_KIND
      into vCURRENCY, nACC_KIND
      from FACEACC
     where RN = nFACEACC;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nFACEACC, 'FaceAccounts');
  end;

  /* пересчет в валюту ЛС */
  if ( vCURRENCY <> nBASE_CURRENCY ) then
    FIND_CURRENCY_COURSE(vCURRENCY, 1, DDATE, nCOUR_SUM, nCOUR_BSUM, nRESULT);
    if ( nRESULT = 0 ) then
      P_EXCEPTION(0, 'Не найден курс пересчета валюты лицевого счета к базовой валюте на '||D2S(DDATE)||'.');
    end if;

    vPSUM := vPSUM * nCOUR_SUM / nCOUR_BSUM;
    vFSUM := vFSUM * nCOUR_SUM / nCOUR_BSUM;
  end if;

  begin
    select PRN
      into nNOMEN
      from NOMMODIF
     where RN = nMODIF;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nMODIF, 'NomenclatorModification');
  end;

  if ( nPACK is not null ) then
    /* считываем упаковку номенклатуры */
    begin
      select NOMENPACK
        into nNOMENPACK
        from NOMNMODIFPACK
       where RN = nPACK;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(nPACK, 'NomenclatorModifPacking');
    end;
  end if;

  select decode(nINEXP_SIGN, 0, 0, 1, 1, 2, 0, 3, 1)
    into vINEXP_SIGN
    from dual;

  /* отражение отработки */
  if ( nROLLBACK = 0 ) then
    for C in
    (
      select *
        from (
               select OP.RN, OP.QUANT_MEAS,
                      OP.BEGIN_DATE,
                      case
                        when dDATE between OP.BEGIN_DATE and OP.END_DATE then -- период включает дату отработки
                          0
                        when OP.END_DATE < dDATE then                      -- более ранний период
                          1
                        else -- dDATE < OP.BEGIN_DATE                      -- более поздний период
                          2
                      end PERIOD_TYPE,
                      OP.NOMMODIF, OP.NOMENPACK, OP.NOMMODIFPACK, OP.GRAPHPOINT, OP.SERNUMB, OP.COUNTRY, OP.GTD,
                      N.UMEAS_MAIN, N.UMEAS_ALT, nvl(OP.NOMENPACK, MP.NOMENPACK) as NOMENPACK_
                 from FCACOPERPLANS OP,
                      DICNOMNS      N,
                      NOMNMODIFPACK MP
                where OP.PRN          = NFACEACC
                  and OP.INEXP_SIGN   = vINEXP_SIGN
                  and OP.NOMEN        = nNOMEN
                  and OP.NOMEN        = N.RN
                  and OP.NOMMODIFPACK = MP.RN(+)
                  and (OP.NOMMODIF is null or nMODIF = OP.NOMMODIF)
                  and (OP.NOMMODIFPACK is null and CMP_NUM(OP.NOMENPACK,    nNOMENPACK) = 1 or
                       OP.NOMENPACK    is null and CMP_NUM(OP.NOMMODIFPACK, nPACK     ) = 1)
                  and (OP.SERNUMB    is null or OP.SERNUMB    = sSERNUMB   )
                  and (OP.COUNTRY    is null or OP.COUNTRY    = nCOUNTRY   )
                  and (OP.GTD        is null or OP.GTD        = sGTD       )
                  and (OP.ARTICLE    is null or OP.ARTICLE    = nARTICLE   )
                  and (OP.GRAPHPOINT is null or OP.GRAPHPOINT = nGRAPHPOINT)
                  and OP.RN = nFAOP /* RN графика */
             )
                -- приоритетный порядок: период включает дату отработки, ближайший ранний период, ближайший поздний период
       order by PERIOD_TYPE, decode(PERIOD_TYPE, 1, BEGIN_DATE, null) desc nulls last, decode(PERIOD_TYPE, 2, BEGIN_DATE, null) asc,
                -- сортировка по: Модификация, Упаковка номенклатуры, Упаковка модификации, Точка графика, Серия, Страна производителя, Реквизиты ГТД
                -- для этих полей: сначала непустые, потом пустые (asc подразумевает nulls last)
                NOMMODIF, NOMENPACK, NOMMODIFPACK, GRAPHPOINT, SERNUMB, COUNTRY, GTD
    )
    loop
      /* количество в ОЕИ */
      if ( C.QUANT_MEAS = 0 ) then
        vPLAN_QUANT := nPLAN_QUANT;
        vFACT_QUANT := nFACT_QUANT;
      /* количество в ДЕИ */
      elsif ( C.QUANT_MEAS = 1 ) then
        vPLAN_QUANT := nvl(nPLAN_QUANT_ALT, 0);
        vFACT_QUANT := nvl(nFACT_QUANT_ALT, 0);
      /* количество в упаковках */
      elsif ( C.QUANT_MEAS = 2 ) then
        nPACK_QUANT := GET_NOMNPACK_QUANT(nNOMENPACK);
        -- nPACK_QUANT > 0
        vPLAN_QUANT := nPLAN_QUANT / nPACK_QUANT;
        vFACT_QUANT := nFACT_QUANT / nPACK_QUANT;
      end if;

      if ( nPLAN_SIGN = 0 ) or ( vPLAN_QUANT < 0 ) then
        vPLAN_QUANT := 0;
      end if;

      if ( nFACT_SIGN = 0 ) or ( vFACT_QUANT < 0 ) then
        vFACT_QUANT := 0;
      end if;

      if ( vPLAN_QUANT = 0 ) and ( vFACT_QUANT = 0 ) and ( vPSUM = 0 ) and ( vFSUM = 0 ) then
        exit;
      end if;

      update FCACOPERPLANS
         set PLAN_SUM   = PLAN_SUM   + nSIGN * vPSUM,
             PLAN_QUANT = PLAN_QUANT + nSIGN * vPLAN_QUANT,
             FACT_SUM   = FACT_SUM   + nSIGN * vFSUM,
             FACT_QUANT = FACT_QUANT + nSIGN * vFACT_QUANT
       where RN = C.RN
      returning FACT_QUANT into nFACT_QUANT_NEW;

      if ( SQL%NOTFOUND ) then
        PKG_MSG.RECORD_NOT_FOUND(C.RN, 'FaceAccountsOperPlans');
      end if;

      /* тип связи */
      if ( nPLAN_SIGN = 1 ) and ( nFACT_SIGN = 1 ) then
        nLINK_TYPE := 2;
      elsif ( nPLAN_SIGN = 1 ) then
        nLINK_TYPE := 0;
      else -- ( nFACT_SIGN = 1 )
        nLINK_TYPE := 1;
      end if;

      /* считывание существующей связи */
      begin
        select LINK_TYPE
          into nLINK_TYPE_OLD
          from DOCLINKS
         where IN_DOCUMENT  = nSPEC_RN
           and IN_UNITCODE  = sSPEC_UNITCODE
           and OUT_DOCUMENT = C.RN
           and OUT_UNITCODE = 'FaceAccountsOperPlans';

        /* тип связи не совпадает с прежним */
        if ( CMP_NUM(nLINK_TYPE_OLD, nLINK_TYPE) = 0 ) then
          /* удаление связи */
          P_LINKSALL_REMOVE(nCOMPANY, sSPEC_UNITCODE, nSPEC_RN, 'FaceAccountsOperPlans', C.RN);
          /* тип связи - план/факт */
          nLINK_TYPE := 2;
        end if;
      exception
        when NO_DATA_FOUND then
          null;
      end;

      /* связывание спецификации товарного документа с записью графика */
      P_LINKSALL_LINK_DIRECT(nCOMPANY, sSPEC_UNITCODE, nSPEC_RN, null,
        dDATE, 0, 'FaceAccountsOperPlans', C.RN, null, dDATE, 0, 0/*nBREAKUP_KIND*/, nLINK_TYPE);

      /* в случае изменения «исполнено факт» */
      if ( nSIGN * vFACT_QUANT <> 0 ) then
        /* пересчет поля «Обеспечено исполнением поставок / отгрузок»
          в дочерних записях «Связанных графиков поступления товаров и услуг» */
        RECALC_PROV_QUANT
        (
          nACC_KIND,
          vINEXP_SIGN,      -- nINEXP_SIGN
          C.RN,             -- nOPERPLAN
          nFACT_QUANT_NEW,  -- nFACT_QUANT
          C.QUANT_MEAS,     -- nQUANT_MEAS
          C.UMEAS_MAIN,
          C.UMEAS_ALT,
          C.NOMENPACK_
        );
      end if;

      /* выход после первой найденной записи */
      exit;
    end loop;

  else /* ------------ ОТКАТ -------------- */

    for C in
    (
      select OP.*, L.LINK_TYPE,
             N.UMEAS_MAIN, N.UMEAS_ALT, nvl(OP.NOMENPACK, MP.NOMENPACK) as NOMENPACK_
        from DOCLINKS      L,
             FCACOPERPLANS OP,
             DICNOMNS      N,
             NOMNMODIFPACK MP
       where L.IN_UNITCODE   = sSPEC_UNITCODE
         and L.IN_DOCUMENT   = nSPEC_RN
         and L.OUT_UNITCODE  = 'FaceAccountsOperPlans'
         and L.OUT_DOCUMENT  = OP.RN
         and OP.NOMEN        = N.RN
         and OP.NOMMODIFPACK = MP.RN(+)
         and OP.RN           = nFAOP /* RN графика */
    )
    loop
      /* количество в ОЕИ */
      if ( C.QUANT_MEAS = 0 ) then
        vPLAN_QUANT := nPLAN_QUANT;
        vFACT_QUANT := nFACT_QUANT;
      /* количество в ДЕИ */
      elsif ( C.QUANT_MEAS = 1 ) then
        vPLAN_QUANT := nvl(nPLAN_QUANT_ALT, 0);
        vFACT_QUANT := nvl(nFACT_QUANT_ALT, 0);
      /* количество в упаковках */
      elsif ( C.QUANT_MEAS = 2 ) then
        nPACK_QUANT := GET_NOMNPACK_QUANT(nNOMENPACK);
        -- nPACK_QUANT > 0
        vPLAN_QUANT := nPLAN_QUANT / nPACK_QUANT;
        vFACT_QUANT := nFACT_QUANT / nPACK_QUANT;
      end if;

      if ( nPLAN_SIGN = 0 ) or ( vPLAN_QUANT < 0 ) then
        vPLAN_QUANT := 0;
      end if;

      if ( nFACT_SIGN = 0 ) or ( vFACT_QUANT < 0 ) then
        vFACT_QUANT := 0;
      end if;

      if ( vPLAN_QUANT = 0 ) and ( vFACT_QUANT = 0 ) and ( vPSUM = 0 ) and ( vFSUM = 0 ) then
        exit;
      end if;

      update FCACOPERPLANS
         set PLAN_SUM   = PLAN_SUM   - nSIGN * vPSUM,
             PLAN_QUANT = PLAN_QUANT - nSIGN * vPLAN_QUANT,
             FACT_SUM   = FACT_SUM   - nSIGN * vFSUM,
             FACT_QUANT = FACT_QUANT - nSIGN * vFACT_QUANT
       where RN = C.RN
      returning FACT_QUANT into nFACT_QUANT_NEW;

      if ( SQL%NOTFOUND ) then
        PKG_MSG.RECORD_NOT_FOUND(C.RN, 'FaceAccountsOperPlans');
      end if;

      /* удаление связи */
      P_LINKSALL_REMOVE(nCOMPANY, sSPEC_UNITCODE, nSPEC_RN, 'FaceAccountsOperPlans', C.RN);

      /* если тип удаленной связи план/факт, то восстанавливаем связь с новым типом при необходимости */
      if ( C.LINK_TYPE = 2 ) and ( ( nPLAN_SIGN = 0 ) or ( nFACT_SIGN = 0 ) ) then
        /* тип восстанавливаемой связи */
        if ( nPLAN_SIGN = 0 ) then
          nLINK_TYPE := 0;
        else -- ( nFACT_SIGN = 0 )
          nLINK_TYPE := 1;
        end if;

        /* связывание спецификации товарного документа с записью графика с другим типом связи */
        P_LINKSALL_LINK_DIRECT(nCOMPANY, sSPEC_UNITCODE, nSPEC_RN, null,
          dDATE, 0, 'FaceAccountsOperPlans', C.RN, null, dDATE, 0, 0/*nBREAKUP_KIND*/, nLINK_TYPE);
      end if;

      /* в случае изменения «исполнено факт» */
      if ( nSIGN * vFACT_QUANT <> 0 ) then
        /* пересчет поля «Обеспечено исполнением поставок / отгрузок»
          в дочерних записях «Связанных графиков поступления товаров и услуг» */
        RECALC_PROV_QUANT
        (
          nACC_KIND,
          C.INEXP_SIGN,     -- nINEXP_SIGN
          C.RN,             -- nOPERPLAN
          nFACT_QUANT_NEW,  -- nFACT_QUANT
          C.QUANT_MEAS,     -- nQUANT_MEAS
          C.UMEAS_MAIN,
          C.UMEAS_ALT,
          C.NOMENPACK_
        );
      end if;
    end loop;
  end if;

  /* пересчет сумм по этапу */
  P_STAGES_BASE_GETSUMS(nCOMPANY, nFACEACC, null, null, 1, 1, nDOC_SUM, nDOC_SUMTAX, nDOC_SUM_NDS);

  /* поиск договора */
  begin
    select C.RN
      into nCONTRACT
      from STAGES    S,
           CONTRACTS C
     where S.COMPANY = nCOMPANY
       and S.FACEACC = nFACEACC
       and S.PRN     = C.RN;
    exception
      when NO_DATA_FOUND then
        nCONTRACT := null;
  end;

  /* пересчитываем суммы договора */
  if ( nCONTRACT is not null ) then
    P_COTRACTS_SETSUMS(nCOMPANY, nCONTRACT, 1,
                       nDOC_SUM, nDOC_SUMTAX, nDOC_SUM_NDS,
                       nTMP, nTMP, nTMP,
                       nTMP,
                       nTMP, nTMP, nTMP,
                       nTMP, nTMP, nTMP,
                       nTMP, nTMP, nTMP,
                       nTMP, nTMP, nTMP);
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_FACEACC_SET_OPERS;
/
