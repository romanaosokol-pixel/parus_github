create or replace procedure UDO_P_REP_INCOMING_INVOICES(
       nCOMPANY in number,
       nYear    in integer, -- Год
       nMonthS  in number,  -- С месяца
       nMonthE  in number,  -- по месяц
       sArt     in varchar, -- Статья бюджета
       nLimit   in number,  -- Сумма для подкрашивания
       nNapr    in integer  -- 0- Расход или 1 - Приход
) is
 -- Отчет Детализация входящих счетов на оплату по статьям
 ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  LL_Pause   constant PKG_STD.TSTRING := 'L_Pause';
  LL_HEADArt constant PKG_STD.TSTRING := 'L_HeadArt';
  LL_LINEArt constant PKG_STD.TSTRING := 'L_LineArt';
  LL_HEAD    constant PKG_STD.TSTRING := 'L_Head';
  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
  
  nSTR       number;
  nPPArt     number := 1;
  nPP        number := 1;
     
  C_nPPArt             constant PKG_STD.TSTRING := 'nPP_Art';
  C_sArtName           constant PKG_STD.TSTRING := 'sArtName';
  C_nSUMArt            constant PKG_STD.TSTRING := 'nSUM_Art';
  
  C_nPP                constant PKG_STD.TSTRING := 'nPP';
  C_sPlat              constant PKG_STD.TSTRING := 'sPlat';
  C_dPlatDate          constant PKG_STD.TSTRING := 'dPlatDate';
  C_sAGENT             constant PKG_STD.TSTRING := 'sAGENT';
  C_nSUM               constant PKG_STD.TSTRING := 'nSUM';
  C_sComment           constant PKG_STD.TSTRING := 'sComment';

  C_sAccount           constant PKG_STD.TSTRING := 'sAccount';
  C_sPeriod            constant PKG_STD.TSTRING := 'S_Period';
  C_sDate              constant PKG_STD.TSTRING := 'S_Date';
  C_nItogo             constant PKG_STD.TSTRING := 'nItogo';

  dStart               date;
  dEnd                 date;
  nLimitColor          numeric(17,2) := 700000;
  nColor               number(4) := 6;
  nItogo               numeric(17,2) := 0;
  nCRN                 numeric(17,0) := 6260096;
  sArtName             varchar2(160) := '';

begin
--p_exception(0,'c ' || nMonthS || ': по ' || nMonthE || ': год ' || nYear || ': sArt ' || sArt);

  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sAccount);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPeriod);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_nItogo);

  -- Описываем строки отчета
  PRSG_EXCEL.LINE_DESCRIBE(LL_Pause);
  PRSG_EXCEL.LINE_DESCRIBE(LL_HEADArt);
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINEArt);
  PRSG_EXCEL.LINE_DESCRIBE(LL_HEAD);
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек по строкам
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINEArt, C_nPPArt);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINEArt, C_sArtName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINEArt, C_nSUMArt);
    
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPlat);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPlatDate);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sComment);

  if (nLimit is NULL) then nLimitColor := 700000; 
  else nLimitColor := nLimit;
  end if;

  if (nMonthS < 10) then 
        dStart := TO_DATE('0'||nMonthS||nYear, 'MMYYYY');
  else  dStart := TO_DATE(nMonthS||nYear, 'MMYYYY');
  end if;

  --dEnd := LAST_DAY(TO_DATE(nMonthE, 'MM'));
  if (nMonthE < 10) then 
        dEnd := LAST_DAY(TO_DATE('0'||nMonthE||nYear, 'MMYYYY'));
  else  dEnd := LAST_DAY(TO_DATE(nMonthE||nYear, 'MMYYYY'));
  end if;
--p_exception(0,nYear || '; dStart: ' || dStart || '; dEnd: ' || dEnd);
  
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sPeriod, 'За период с  ' || to_char(dStart, 'DD.MM.YYYY') ||  ' по ' || to_char(dEnd, 'DD.MM.YYYY'));

  if (sArt is NULL) then
    
    if (1 = nNapr) then 
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAccount, 'Суммы доходов по всем статьям');
      nCRN := 6260055; -- Приход
    else 
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAccount, 'Суммы расходов по всем статьям');
      nCRN := 6260096;   -- Расход
    end if;
      
    for arts in(
      select cat.name, art.crn, art.code, art.name art_name, sum(pn.pay_sum) pay_sum
          from V_BANKDOCS ba, PayNotes pn, FACEACC  fc, FPDARTCL art, ACATALOG cat
         where ba.COMPANY = NCOMPANY 
           and ba.BANK_DOCDATE >= dStart 
           and ba.BANK_DOCDATE <= dEnd
           and pn.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT = ba.rn)
           and PN.Faceacc = FC.RN and art.RN (+)= FC.IEELEMENT 
           and cat.rn = art.crn
           and ba.CRN in (select RN from ACATALOG connect by prior RN = CRN start with RN = nCRN) -- Расход или Приход          
         group by cat.name, art.crn, art.code, art.name
         order by cat.name, art.crn, art.code, art.name 
      ) loop
          
          nItogo := nItogo + arts.pay_sum;
          
          if arts.pay_sum >= nLimitColor then 
            nColor := 6;    -- желтый
          else nColor := 2; -- белый
          end if; 
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_nSUMArt,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => nColor);

          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINEArt);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nPPArt,       0, nSTR, nPPArt);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sArtName,     0, nSTR, arts.art_name);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMArt,      0, nSTR, arts.pay_sum);

          nPPArt := nPPArt + 1;

          if (arts.pay_sum > nLimitColor) then -- Рисуем детализацию
            
            nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_HEAD);
            
            for rec in(
              select pn.pay_sum, pn.pay_date, trim(pn.pay_prefix)||'-'||trim(pn.pay_number) pp_num, 
                     ba.dfrom_date, ba.agent_to, ba.agent_from, ba.pay_info,
                     trim(ba.sfrom_doctype)||'-'||trim(ba.sfrom_numb)||', '||to_char(ba.dfrom_date, 'DD.MM.YYY') ext_num
                     --UDO_F_PAYACCIN_EXT_NUMB(pn.rn) ext_num
                     --ba.bank_docdate, ba.agent_to_bankname, ba.sfrom_numb
                from V_BANKDOCS ba, PayNotes pn
               where ba.COMPANY = NCOMPANY 
                 and ba.BANK_DOCDATE >= dStart 
                 and ba.BANK_DOCDATE <= dEnd
                 and pn.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT = ba.rn)
                 and trim(UDO_F_PAYNOTES_ARTICLE(pn.RN)) = trim(arts.code)
               order by ba.bank_docdate, ba.bank_doctype, ba.sfrom_numb, pn.pay_number
            ) loop
                if rec.pay_sum >= nLimitColor then 
                  nColor := 6;    -- желтый
                else nColor := 2; -- белый
                end if; 
                PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_nSUM,
                                              sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                              sATTRIBUTE_VALUE => nColor);

                nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nPP);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlat,     0, nSTR, rec.ext_num); --pp_num);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_dPlatDate, 0, nSTR, rec.dfrom_date);
                if (1 = nNapr) then 
                     PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT, 0, nSTR, rec.agent_from);
                else PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT, 0, nSTR, rec.agent_to);
                end if;
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM,      0, nSTR, rec.pay_sum);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sComment,  0, nSTR, rec.pay_info);

                nPP := nPP + 1;  
                  
            end loop;          
            nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_Pause);
          end if;
          
      end loop;
      -- Заменяем формулу суммы на подсчитанное значение
      PRSG_EXCEL.CELL_FORMULA_DELETE(C_nItogo);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogo, nItogo);
      --удаляем ненужный заголовок
      PRSG_EXCEL.LINE_DELETE(LL_HEAD);
    else
      select t.name INTO sArtName from FPDARTCL t where t.code = TRIM(sArt);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAccount, 'Входящие счета на оплату по статье "' || sArtName || '"');

      for rec in(
        select pn.pay_sum, pn.pay_date, trim(pn.pay_prefix)||'-'||trim(pn.pay_number) pp_num,
               ba.dfrom_date, ba.agent_to, ba.agent_from, ba.pay_info,
               trim(ba.sfrom_doctype)||'-'||trim(ba.sfrom_numb)||', '||to_char(ba.dfrom_date, 'DD.MM.YYY') ext_num
               --UDO_F_PAYACCIN_EXT_NUMB(pn.rn) ext_num
               -- ba.bank_docdate, ba.agent_to_bankname, ba.sfrom_numb, 
               -- ba.pay_sum, ba.pay_info
          from V_BANKDOCS ba, PayNotes pn
         where ba.COMPANY = NCOMPANY 
           and ba.BANK_DOCDATE >= dStart 
           and ba.BANK_DOCDATE <= dEnd -- TO_DATE(ba.BANK_DOCDATE, 'DD.MM.YYYY') <= dEnd
           and pn.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT = ba.rn)
           and trim(UDO_F_PAYNOTES_ARTICLE(pn.RN)) = trim(sArt)
         order by ba.bank_docdate, ba.bank_doctype, ba.sfrom_numb, pn.pay_number
      ) loop

          nItogo := nItogo + rec.pay_sum;

          if rec.pay_sum >= nLimitColor then 
            nColor := 6;    -- желтый
          else nColor := 2; -- белый
          end if; 
          PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_nSUM,
                                        sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                        sATTRIBUTE_VALUE => nColor);

          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nPP);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlat,     0, nSTR, rec.ext_num); --pp_num); --rec.sfrom_numb);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_dPlatDate, 0, nSTR, rec.dfrom_date);
          if (1 = nNapr) then 
               PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT, 0, nSTR, rec.agent_from);
          else PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT, 0, nSTR, rec.agent_to);
          end if;
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM,      0, nSTR, rec.pay_sum);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sComment,  0, nSTR, rec.pay_info);

          nPP := nPP + 1;  
            
      end loop;
      --удаляем ненужный заголовок
      PRSG_EXCEL.LINE_DELETE(LL_HEADArt);

  end if;
  --удаляем технические строки
  PRSG_EXCEL.LINE_DELETE(LL_LINEArt);
  PRSG_EXCEL.LINE_DELETE(LL_LINE);
  PRSG_EXCEL.LINE_DELETE(LL_Pause);
  
end UDO_P_REP_INCOMING_INVOICES;
/

