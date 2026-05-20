create or replace procedure UDO_REP_FCPRODCMP_COMPARE
(
  nCOMPANY        in number,
  sRAZDEL         in varchar2, -- Наименование раздела
  nCMP_ROUTE      in number,   -- Сравнение маршрутов
  nCMP_MATER      in number,   -- Сравнение материалов
  nCMP_ALL        in number,   -- Сравнение по всем уровням
  nIDENT          in number,   -- Выбранные записи
  nRN             out number   -- Регистрационный номер
)
as
-- Основа из P_FCPRODCMP_COMPARE

  nPRODCMP_SRC    number := 0; -- Исходный производственный состав
  nPRODCMP_CMP    number := 0; -- Сравниваемый производственный состав
  nRows           number := 0;
  nSTR            number;
  --nHead           number := 0;
  nLastHRN        number := 0;
  --nProdRN         number := 0;
  sLastProd       varchar2(1024) := '';

 ----Переменные отчета "Сравнение Производственных составов"
  C_sIzdelie  constant PKG_STD.tSTRING := 's_Izdelie';
  C_sVer1     constant PKG_STD.tSTRING := 'sVer1';
  C_sVer2     constant PKG_STD.tSTRING := 'sVer2';
  C_sDate1    constant PKG_STD.tSTRING := 'sDate1';
  C_sDate2    constant PKG_STD.tSTRING := 'sDate2';

  LL_IZD      constant PKG_STD.tSTRING := 'L_IZD';
  C_sName     constant PKG_STD.tSTRING := 'sName';

  LL_LINE     constant PKG_STD.tSTRING := 'L_LINE';

  C_nStr1     constant PKG_STD.tSTRING := 'nStr1';
  C_nStr2     constant PKG_STD.tSTRING := 'nStr2';
  C_nName1    constant PKG_STD.tSTRING := 'nName1';
  C_nName2    constant PKG_STD.tSTRING := 'nName2';
  C_sGost1    constant PKG_STD.tSTRING := 'sGost1';
  C_sGost2    constant PKG_STD.tSTRING := 'sGost2';
  C_sKol1     constant PKG_STD.tSTRING := 'sKol1';
  C_sKol2     constant PKG_STD.tSTRING := 'sKol2';
  C_sPrim1    constant PKG_STD.tSTRING := 'sPrim1';
  C_sPrim2    constant PKG_STD.tSTRING := 'sPrim2';

  /* обработка строк спецификации ПС */
  procedure PRODCMPSP_PROCESS
  (
    nSTAGE          in number,  -- Этап (1, 2)
    nPRN1           in number,
    nHRN1           in number,
    nPRODCMPSP1     in number,
    nPRN2           in number,
    nHRN2           in number,
    nPRODCMPSP2     in number,
    nPRN            in number,
    nHRN            in number,
    nPRODCMPSP      in number
  )
  is
    rSP2            FCPRODCMPSP%rowtype;
    rSP             FCPRODCMPSP%rowtype;
    nCHANGE_KIND    FCPRODCMPSP.CHANGE_KIND%type;
    nSP             PKG_STD.tREF;
    rMR2            FCPRODCMPSPMR%rowtype;
    rMR             FCPRODCMPSPMR%rowtype;
    sModul1         varchar2(1024);
    sModul2         varchar2(1024);
    sGost1          varchar2(1024);
    sGost2          varchar2(1024);
  begin

    /* спецификация ПС1 */
    for rSP1 in
    (
      select sp.*--, prod.smtr_res_name
        from FCPRODCMPSP sp--, V_FCPRODCMP prod
       where sp.PRN = nPRN1
         --and sp.PRN = prod.nrn
         and ( sp.HRN       = nHRN1       or sp.HRN       is null and nHRN1       is null )
         and ( sp.PRODCMPSP = nPRODCMPSP1 or sp.PRODCMPSP is null and nPRODCMPSP1 is null )
         and ( sp.HIER_LEVEL <= 2 or 1 = nCMP_ALL )
      order by sp.hrn, sp.hier_level, sp.prodlist_numb
    )
    loop
--p_exception(0, nPRN1 || ' vs ' || nPRN2);
      /* поиск записи спецификации ПС2 */
      begin
        select sp.*
          into rSP2
          from FCPRODCMPSP sp
         where PRN     = nPRN2
           and MTR_RES = rSP1.MTR_RES
           and ( HRN           = nHRN2              or HRN           is null and nHRN2              is null )
           and ( PRODLSTSP     = rSP1.PRODLSTSP     or PRODLSTSP     is null and rSP1.PRODLSTSP     is null )
           and ( PRODLIST_NUMB = rSP1.PRODLIST_NUMB or PRODLIST_NUMB is null and rSP1.PRODLIST_NUMB is null )
           and ( LOSTTYPE      = rSP1.LOSTTYPE      or LOSTTYPE      is null and rSP1.LOSTTYPE      is null )
           and ( PRODCMPSP     = nPRODCMPSP2        or PRODCMPSP     is null and nPRODCMPSP2        is null )
           -- ??? and ( PRODCMPSP     = rSP1.PRODCMPSP     or PRODCMPSP     is null and rSP1.PRODCMPSP     is null )
--           and ( SUBDIV_SUPPL  = rSP1.SUBDIV_SUPPL  or SUBDIV_SUPPL  is null and rSP1.SUBDIV_SUPPL  is null )
--           and ( SUBDIV_RECIP  = rSP1.SUBDIV_RECIP  or SUBDIV_RECIP  is null and rSP1.SUBDIV_RECIP  is null )
           and ( trim(NOTE)    = trim(rSP1.Note)    or NOTE          is null and rSP1.Note          is null )
           and ( HIER_LEVEL <= 2 or 1 = nCMP_ALL )
        order by sp.hrn, sp.hier_level, sp.prodlist_numb;
      exception
        when NO_DATA_FOUND then
          rSP2 := null;
      end;
--p_exception(0, nPRN1 || ' vs ' || nPRN2);
      begin
        select mr.name, upper(MD.MODIF_NAME) as MODIF_CODE  
          into sModul1, sGost1
          from FCMATRESOURCE mr, NOMMODIF MD 
          where mr.rn = rSP1.Mtr_Res and nCOMPANY = 90521 
            and mr.NOMEN_MODIF = MD.RN;
      exception
        when NO_DATA_FOUND then
          sModul1 := '???';
      end;
      if INSTR(sModul1, '(000') > 0 then
        sModul1 := SUBSTR(sModul1, 0, INSTR(sModul1, '(000')-1);
      end if;
      if INSTR(sGost1, 'ГОСТ') > 0 then 
        sGost1 := substr(sGost1, instr(sGost1, 'ГОСТ'));
      elsif INSTR(sGost1, 'АЛЯР') > 0 then 
        sGost1 := substr(sGost1, instr(sGost1, 'АЛЯР'));
      elsif INSTR(sGost1, 'РЮМК') > 0 then 
        sGost1 := substr(sGost1, instr(sGost1, 'РЮМК'));
      elsif INSTR(sGost1, '000') > 0 then 
        sGost1 := substr(sGost1, instr(sGost1, '_')+1);
      end if;      

      /* запись НЕ НАЙДЕНА */
      if ( rSP2.RN is null ) then
        --nHier2 := rSP1.hier_level;

        if 0 = nLastHRN or nLastHRN != rSP1.Hrn then -- выводим заголовок каждого модуля
          begin
            select f.name into sLastProd
              from FCPRODCMPSP sp, FCMATRESOURCE F
             where sp.rn = rSP1.Hrn
               and sp.MTR_RES = F.RN;
          exception
            when NO_DATA_FOUND then
              sLastProd := '---';
          end;
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr1,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 2);
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr2,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 2);
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nName1, --C_sName,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 8); -- бирюзовый

          --nSTR := PRSG_EXCEL.LINE_APPEND(LL_IZD);
          --nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_IZD);
          nSTR := PRSG_EXCEL.LINE_APPEND(LL_LINE);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1,  0, nSTR, sLastProd);
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nName1, --C_sName,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 2);
        end if;

        if ( 1 = nSTAGE ) then
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr1,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 3); -- красный
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr2,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 2);
        else -- ( nSTAGE = 2 )
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr1,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 2);
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr2,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => 4); -- зеленый
        end if;

--        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        nSTR := PRSG_EXCEL.LINE_APPEND(LL_LINE);

        /* вид изменения */
        if ( 1 = nSTAGE ) then
          nCHANGE_KIND := 1;  -- Удалена
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr1,  0, nSTR, 'Del: ' || trim(rSP1.Prodlist_Numb));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul1);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost1, 0, nSTR, sGost1);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol1,  0, nSTR, rSP1.Quant);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim1, 0, nSTR, rSP1.Note);
        else -- ( nSTAGE = 2 )
          nCHANGE_KIND := 0;  -- Добавлена
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr2,  0, nSTR, 'Add: ' || trim(rSP1.Prodlist_Numb));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nName2, 0, nSTR, sModul1);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost2, 0, nSTR, sGost1);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol2,  0, nSTR, rSP1.Quant);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim2, 0, nSTR, rSP1.Note);
        end if;
        --sLastProd := trim(rSP1.Prodlist_Numb);
        nLastHRN := rSP1.Hrn;

        /* рекурсивная обработка строк спецификации ПС - по значению поля "Для комплектующей" */
        PRODCMPSP_PROCESS
        (
          nSTAGE,
          nPRN1,
          nHRN1,
          rSP1.RN,        -- nPRODCMPSP1
          nPRN2,
          nHRN2,
          rSP2.RN,        -- nPRODCMPSP2
          nPRN,
          nHRN,
          nSP             -- nPRODCMPSP
        );

      /* запись найдена */
      else
/*        if ( 1 = nSTAGE ) then
             nProdRN := rSP1.Hrn;
        else nProdRN := rSP2.Hrn;
        end if;   */     

        begin
        select mr.name, upper(MD.MODIF_NAME) as MODIF_CODE  
          into sModul2, sGost2
          from FCMATRESOURCE mr, NOMMODIF MD 
          where mr.rn = rSP2.Mtr_Res and nCOMPANY = 90521 
            and mr.NOMEN_MODIF = MD.RN;
        exception
          when NO_DATA_FOUND then
            sModul2 := '???';
        end;
        if INSTR(sModul2, '(000') > 0 then
          sModul2 := SUBSTR(sModul2, 0, INSTR(sModul2, '(000')-1);
        end if;
        if INSTR(sGost2, 'ГОСТ') > 0 then 
          sGost2 := substr(sGost2, instr(sGost2, 'ГОСТ'));
        elsif INSTR(sGost2, 'АЛЯР') > 0 then 
          sGost2 := substr(sGost2, instr(sGost2, 'АЛЯР'));
        elsif INSTR(sGost2, 'РЮМК') > 0 then 
          sGost2 := substr(sGost2, instr(sGost2, 'РЮМК'));
        elsif INSTR(sGost2, '000') > 0 then 
          sGost2 := substr(sGost2, instr(sGost2, '_')+1);
        end if;

        /* этап 1 */
        if ( nSTAGE = 1 ) then
          if ( rSP2.QUANT = rSP1.QUANT )
            and ( nCMP_ROUTE = 1 and CMP_VC2(rSP2.ROUTE,       rSP1.ROUTE      ) = 1
                                 and CMP_NUM(rSP2.ROUTE_BEGIN, rSP1.ROUTE_BEGIN) = 1
                                 and CMP_NUM(rSP2.FCROUTE,     rSP1.FCROUTE    ) = 1 or
                  nCMP_ROUTE = 0 )
          then
            rSP := rSP1;
            rSP.CHANGE_KIND := null;
          else
            rSP := rSP2;
            rSP.CHANGE_KIND := 2;  -- Изменена
            
            PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr1,
                                          sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                          sATTRIBUTE_VALUE => 6);
            PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr2,
                                          sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                          sATTRIBUTE_VALUE => 6);

            nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr1,  0, nSTR, 'Upd: ' || trim(rSP1.Prodlist_Numb));
            if rSP1.ROUTE is not null then
                 PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul1 || ' (' || rSP1.ROUTE || ')');
            else PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul1);
            end if;
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost1, 0, nSTR, sGost1);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol1,  0, nSTR, rSP1.Quant);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim1, 0, nSTR, rSP1.Note);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr2,  0, nSTR, 'Upd: ' || trim(rSP2.Prodlist_Numb));
            if rSP2.ROUTE is not null then
                 PRSG_EXCEL.CELL_VALUE_WRITE(C_nName2, 0, nSTR, sModul2 || ' (' || rSP2.ROUTE || ')');
            else PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul2);
            end if;
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost2, 0, nSTR, sGost2);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol2,  0, nSTR, rSP2.Quant);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim2, 0, nSTR, rSP2.Note);
        end if;

        /* этап 2 */
        else  -- ( nSTAGE = 2 )
          nSP := rSP2.RN;
        end if;  -- ( nSTAGE = 1 )

        /* сравнение материалов */
        if ( nCMP_MATER = 1 ) then
--p_exception(0, rSP1.RN || ' to ' || rSP2.RN);
          
          for rMR1 in
          (
            select * from FCPRODCMPSPMR where PRN = rSP1.RN
          )
          loop 
            /* поиск записи материала ПС2 */
            begin
              select * into rMR2 from FCPRODCMPSPMR where PRN = rSP2.RN
                 and MTR_RES = rMR1.MTR_RES
                 and ( FPDACCNT      = rMR1.FPDACCNT      or FPDACCNT      is null and rMR1.FPDACCNT      is null )
                 and ( MATSHEET      = rMR1.MATSHEET      or MATSHEET      is null and rMR1.MATSHEET      is null )
                 and ( MATSHEET_NUMB = rMR1.MATSHEET_NUMB or MATSHEET_NUMB is null and rMR1.MATSHEET_NUMB is null )
                 and ( SUBDIV_SUPPL  = rMR1.SUBDIV_SUPPL  or SUBDIV_SUPPL  is null and rMR1.SUBDIV_SUPPL  is null )
                 and ( ROUTSHT       = rMR1.ROUTSHT       or ROUTSHT       is null and rMR1.ROUTSHT       is null )
                 and ( ROUTSHTSP     = rMR1.ROUTSHTSP     or ROUTSHTSP     is null and rMR1.ROUTSHTSP     is null )
                 and ( PRODCOND      = rMR1.PRODCOND      or PRODCOND      is null and rMR1.PRODCOND      is null );
            exception
              when NO_DATA_FOUND then
                rMR2 := null;
            end;

            /* этап 1 */
            if ( nSTAGE = 1 ) then
              /* запись материала НЕ НАЙДЕНА */
              if ( rMR2.RN is null ) then
                rMR := rMR1;
                rMR.CHANGE_KIND := 1;  --  Удалена
                PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr1,
                                              sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                              sATTRIBUTE_VALUE => 7); -- красный
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr1,  0, nSTR, 'Del: ' || trim(rMR1.MATSHEET_NUMB));
                --PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul1);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost1, 0, nSTR, rMR1.NORMA);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol1,  0, nSTR, rMR1.Quant);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim1, 0, nSTR, rMR1.Note);
              /* запись материала НАЙДЕНА и в ней норма НЕ СОВПАДАЕТ */
              elsif ( rMR2.NORMA <> rMR1.NORMA ) then
                rMR := rMR2;
                rMR.CHANGE_KIND := 2;  --  Изменена

                PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr1,  0, nSTR, 'Upd: ' || trim(rMR1.MATSHEET_NUMB));
                --PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul1);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost1, 0, nSTR, rMR1.NORMA);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol1,  0, nSTR, rMR1.Quant);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim1, 0, nSTR, rMR1.Note);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr2,  0, nSTR, 'Upd: ' || trim(rMR2.MATSHEET_NUMB));
                --PRSG_EXCEL.CELL_VALUE_WRITE(C_nName2, 0, nSTR, sModul2);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost2, 0, nSTR, rMR2.NORMA);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol2,  0, nSTR, rMR2.Quant);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim2, 0, nSTR, rMR2.Note);
              else
                rMR := rMR1;
                rMR.CHANGE_KIND := null;
              end if;
            /* этап 2 */
            else  -- ( nSTAGE = 2 )
              /* запись материала НЕ НАЙДЕНА */
              if ( rMR2.RN is null ) then
                rMR := rMR1;
                rMR.CHANGE_KIND := 0;  --  Добавлена
                PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => C_nStr2,
                                              sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                              sATTRIBUTE_VALUE => 10); -- зеленый
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nStr2,  0, nSTR, 'Add: ' || trim(rMR1.MATSHEET_NUMB));
                --PRSG_EXCEL.CELL_VALUE_WRITE(C_nName1, 0, nSTR, sModul1);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sGost2, 0, nSTR, rMR1.NORMA);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol2,  0, nSTR, rMR1.Quant);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim2, 0, nSTR, rMR1.Note);
              else
                rMR := null;
              end if;
            end if;
          end loop;  -- rMR1
        end if;  -- ( nCMP_MATER = 1 )

        /* рекурсивная обработка строк спецификации ПС - по значению поля "Для комплектующей" */
        PRODCMPSP_PROCESS
        (
          nSTAGE,
          nPRN1,
          nHRN1,
          rSP1.RN,        -- nPRODCMPSP1
          nPRN2,
          nHRN2,
          rSP2.RN,        -- nPRODCMPSP2
          nPRN,
          nHRN,
          nSP             -- nPRODCMPSP
        );

        /* рекурсивная обработка строк спецификации ПС - по значению поля "Родитель в иерархии" */
        PRODCMPSP_PROCESS
        (
          nSTAGE,
          nPRN1,
          rSP1.RN,        -- nHRN1
          null,           -- nPRODCMPSP1
          nPRN2,
          rSP2.RN,        -- nHRN2
          null,           -- nPRODCMPSP2
          nPRN,
          nSP,            -- nHRN
          null            -- nPRODCMPSP
        );
      end if;  -- ( rSP2.RN is null )
    end loop;  -- rSP1
  end PRODCMPSP_PROCESS;

begin
  select count(sl.rn) into nRows from SELECTLIST sl
   where sl.authid = utilizer and sl.unitcode = sRAZDEL;
     --and sl.session_id = GET_SESSION_VERSION(/*'CostProductComposition'*/);
--p_exception(0, 'Выделено: ' || nRows);  
   
  if nRows != 2 then
    p_exception(0, 'Должно быть выделено два Производственных состава!');
  end if;
--  p_exception(0, nIDENT);  

  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => 'Лист1');

  PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie);
  PRSG_EXCEL.CELL_DESCRIBE(C_sVer1);
  PRSG_EXCEL.CELL_DESCRIBE(C_sVer2);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate1);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate2);

  for sel in (
    select ps.rn/* sl.document*/ ps_rn, ps.numb, ps.frm_date, ps.purpose,
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 9674317 and UNITCODE = 'CostProductComposition' and UNIT_RN = ps.rn) sIzd 

      from SELECTLIST sl, FCPRODCMP ps
     where /*sl.rn = nIDENT and */sl.unitcode = sRAZDEL
       and sl.authid = USER
       and ps.company = nCOMPANY
       and ps.rn = sl.document
     order by ps.frm_date
  ) loop
--p_exception(0, nRows);
    if 0 = nPRODCMP_SRC then
         nPRODCMP_SRC := sel.ps_rn;
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie, sel.sizd);
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sVer1, trim(sel.numb) || ' (' || sel.purpose || ')');
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate1, sel.frm_date);
    else 
      nPRODCMP_CMP := sel.ps_rn;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sVer2, trim(sel.numb) || ' (' || sel.purpose || ')');
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate2, sel.frm_date);
    end if;
  end loop;

--p_exception(0, nPRODCMP_SRC || ' и ' || nPRODCMP_CMP);
  
  /* поиск изделия */
  --FIND_FCMATRES_BY_NOM_AND_MODIF(0, nCOMPANY, sNOMEN, sMODIF, nMTR_RES);
  /* поиск сравниваемого производственного состава */
  --FIND_FCPRODCMP_NUMB(0, 0, nCOMPANY, nMTR_RES, sCMP_TYPE, sCMP_NUMB, nPRODCMP_CMP);
  /* считывание сравниваемого производственного состава */
  --P_FCPRODCMP_EXISTS(nPRODCMP_CMP, nCOMPANY, nCRN);
  /* фиксация начала выполнения действия */
  --PKG_ENV.PROLOGUE(nCOMPANY, null, nCRN, null, null, 'CostProductComposition', 'FCPRODCMP_COMPARE', 'FCPRODCMP', nPRODCMP_CMP);
  /* поиск каталога */
  --FIND_ACATALOG_NAME(0, nCOMPANY, null, 'CostProductComposition', sCATALOG, nCRN);
  /* поиск типа документа */
  --FIND_DOCTYPES_CODE_EX(0, 1, nCOMPANY, sDOCTYPE, nDOCTYPE);
  /* поиск исходного производственного состава */
  --FIND_FCPRODCMP_NUMB(0, 0, nCOMPANY, nMTR_RES, sSRC_TYPE, sSRC_NUMB, nPRODCMP_SRC);

  if ( nPRODCMP_CMP = nPRODCMP_SRC ) then
    P_EXCEPTION(0, 'Исходный производственный состав не должен быть одинаков со сравниваемым составом.');
  end if;

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_IZD);
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_IZD, C_sName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nStr1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nStr2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nName1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nName2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sGost1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sGost2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sKol1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sKol2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPrim1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPrim2);
  
  /* рекурсивная обработка строк спецификации ПС - этап 1 */
  PRODCMPSP_PROCESS
  (
    1,              -- nSTAGE
    nPRODCMP_SRC,   -- nPRN1
    null,           -- nHRN1
    null,           -- nPRODCMPSP1
    nPRODCMP_CMP,   -- nPRN2
    null,           -- nHRN2
    null,           -- nPRODCMPSP2
    nRN,            -- nPRN
    null,           -- nHRN
    null            -- nPRODCMPSP
  );

  /* этап 2 */
  PRODCMPSP_PROCESS
  (
    2,              -- nSTAGE
    nPRODCMP_CMP,   -- nPRN1
    null,           -- nHRN1
    null,           -- nPRODCMPSP1
    nPRODCMP_SRC, --nRN,            -- nPRN2
    null,           -- nHRN2
    null,           -- nPRODCMPSP2
    nRN,            -- nPRN
    null,           -- nHRN
    null           -- nPRODCMPSP
  );

  /* фиксация окончания выполнения действия */
--  PKG_ENV.EPILOGUE(nCOMPANY, null, nCRN, null, null, 'CostProductComposition', 'FCPRODCMP_COMPARE', 'FCPRODCMP', nPRODCMP_CMP);

  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_IZD);
  PRSG_EXCEL.LINE_DELETE(LL_LINE);

end UDO_REP_FCPRODCMP_COMPARE;
/

