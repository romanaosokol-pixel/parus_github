create or replace procedure UDO_P_MONTHLY_PLAN(nIDENT in number, sPeriod in varchar2, nLimit in number)
  ---- Процедура отчета "Ежемесячный отчет"
  -- Использовать UDO_V_FINPLAN_ARTS ???
is

  dDate date;
    ---- Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист 1'; -- Лист
  L_lStrD    constant PKG_STD.TSTRING := 'Dohod';
  L_lStrR    constant PKG_STD.TSTRING := 'Rashod';
  L_lStr     constant PKG_STD.TSTRING := 'Stroka'; -- Строки...
  L_lStrM    constant PKG_STD.TSTRING := 'Month';  --Месяц для больших сумм
  L_lStrMore constant PKG_STD.TSTRING := 'StrMore';-- Большие суммы
  L_lStrP    constant PKG_STD.TSTRING := 'Razriv';

/*    
  nItog01  number(17,2) := 0; nItog02  number(17,2) := 0; nItog03  number(17,2) := 0;
  nItog04  number(17,2) := 0; nItog05  number(17,2) := 0; nItog06  number(17,2) := 0;
  nItog07  number(17,2) := 0; nItog08  number(17,2) := 0; nItog09  number(17,2) := 0;
  nItog10  number(17,2) := 0; nItog11  number(17,2) := 0; nItog12  number(17,2) := 0;
  nItogF01  number(17,2) := 0; nItogF02  number(17,2) := 0; nItogF03  number(17,2) := 0;
  nItogF04  number(17,2) := 0; nItogF05  number(17,2) := 0; nItogF06  number(17,2) := 0;
  nItogF07  number(17,2) := 0; nItogF08  number(17,2) := 0; nItogF09  number(17,2) := 0;
  nItogF10  number(17,2) := 0; nItogF11  number(17,2) := 0; nItogF12  number(17,2) := 0;*/
  
  nSum01  number(17,2) := 0; nSum02  number(17,2) := 0; nSum03  number(17,2) := 0;
  nSum04  number(17,2) := 0; nSum05  number(17,2) := 0; nSum06  number(17,2) := 0;
  nSum07  number(17,2) := 0; nSum08  number(17,2) := 0; nSum09  number(17,2) := 0;
  nSum10  number(17,2) := 0; nSum11  number(17,2) := 0; nSum12  number(17,2) := 0;
      
  nSTR         number(17) := 0;
  nSTR_M       number(17) := 0;
  nSTR_More    number(17) := 0;
  nSTR_D       number(17) := 0;
  nSTR_R       number(17) := 0;
  nSTR_P       number(17) := 0;

  nColor       number(4) := 2;
  nPrevMonth   number(4) := 0;
  nRN_Year     number(8) := 0;

/*  sPeriodName  varchar2(64) := '';
  sItogName    varchar2(64) := '';
  sInMemo      varchar2(64) := '';
  sOtv         varchar2(64) := '';
  sArt         varchar2(8) := '00';*/
  
  C_sData        constant PKG_STD.TSTRING := 'Year';
  C_sYear        constant PKG_STD.TSTRING := 'YearText';

  C_sPunkt       constant PKG_STD.TSTRING := 'Punkt';
  C_sText        constant PKG_STD.TSTRING := 'Text';
  
  C_nVal01 constant PKG_STD.TSTRING := 'Znach01';
  C_nVal02 constant PKG_STD.TSTRING := 'Znach02';
  C_nVal03 constant PKG_STD.TSTRING := 'Znach03';
  C_nVal04 constant PKG_STD.TSTRING := 'Znach04';
  C_nVal05 constant PKG_STD.TSTRING := 'Znach05';
  C_nVal06 constant PKG_STD.TSTRING := 'Znach06';
  C_nVal07 constant PKG_STD.TSTRING := 'Znach07';
  C_nVal08 constant PKG_STD.TSTRING := 'Znach08';
  C_nVal09 constant PKG_STD.TSTRING := 'Znach09';
  C_nVal10 constant PKG_STD.TSTRING := 'Znach10';
  C_nVal11 constant PKG_STD.TSTRING := 'Znach11';
  C_nVal12 constant PKG_STD.TSTRING := 'Znach12';

  C_sMonthText constant PKG_STD.TSTRING := 'MonthText';
  C_nSumMore   constant PKG_STD.TSTRING := 'SumMore';
  C_nTextMore  constant PKG_STD.TSTRING := 'TextMore';
  
  begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);
  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sData);
  PRSG_EXCEL.CELL_DESCRIBE(C_sYear);
  
  -- Описываем добавляемые строки
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrM);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrMore);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrD);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrR);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrP);
    
  -- Описываем имена ячеек в добавляемых строках
  --PRSG_EXCEL.CELL_DESCRIBE(C_sTest);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sPunkt);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sText);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal01);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal02);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal03);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal04);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal05);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal06);  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal07);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal08);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal09);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal10);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal11);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nVal12);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrM, C_sMonthText);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrMore, C_nSumMore);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrMore, C_nTextMore);
    
  ---Заполнение шапки отчета
--  PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, d_year(dDate) || ' г. ');
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, sPeriod);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sYear, 'По состоянию на ' || to_char(SYSDATE, 'DD.MM.YYYY') || ' г. ');

/*  if (2020 = d_year(dDate)) then nRN_Year := 6271643; -- 2020
  else nRN_Year := 6510821; -- 2021
  end if;*/
  begin
      select f.RN, f.fp_fact_date into nRN_Year, dDate from UDO_T_FINPLAN f 
      where f.fp_vers = 1 and f.groupbudg = 6419333 and f.fp_type = 6336517 
      and f.fp_period in (select RN from ENPERIOD where pertype = 3 and code = sPeriod);
    exception
      when NO_DATA_FOUND then P_EXCEPTION(0, 'Бюджет на учетный период "' || sPeriod || '" не сформирован.');
  end;
--p_exception(0,'nRN_Year: ' || nRN_Year || '; dDate: ' || dDate );

  -- Берем строки сводного бюджета
  For par in (select fin.SART_NUMB, fin.SNAME, fin.SPARENT_ART_NUMB, fin.NLEVEL from UDO_V_FINPLAN_ARTS fin 
               where fin.NPRN = nRN_Year and fin.NDISPLAY=1 order by fin.SART_NUMB
  ) loop

      if (1 = par.NLEVEL) then
/*        switch (par.sart_numb)
        case '0': nColor := 4; break;
        otherwise: nColor := 2;
        end;*/
        if ('0' = par.sart_numb or '5' = par.sart_numb) then
          nColor := 4;
        --else if ('4' = par.sart_numb) then
          --nColor := 15;
        else nColor := 27;
        end if;
      else nColor := 2;
      end if;
                               
      if ('1' = par.sart_numb) then nSTR_D := PRSG_EXCEL.LINE_CONTINUE(L_lStrD); end if;
      if ('2' = par.sart_numb) then nSTR_R := PRSG_EXCEL.LINE_CONTINUE(L_lStrR); end if;

      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_sPunkt, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_sText,  'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal01, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal02, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal03, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal04, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal05, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal06, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal07, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal08, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal09, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal10, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal11, 'Interior.ColorIndex', nColor);
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(C_nVal12, 'Interior.ColorIndex', nColor);

      nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr); 
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPunkt, 0, nSTR, par.sart_numb);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sText, 0, nSTR, par.sname);

      -- Идем по месяцам для каждой строки сводного бюджета
      For art in (select SUBSTR(SART_NUMB_NAME, 1, INSTR(SART_NUMB_NAME, '-', 1)-2) as SART_NUMB, nnumb, nval
                 from UDO_V_FINPLAN_ARTS_V fav
                 where NMASTERRN = nRN_Year and NDISPLAY = 1 
                       and SUBSTR(SART_NUMB_NAME, 1, INSTR(SART_NUMB_NAME, '-', 1)-2) = par.sart_numb
                 order by sgroup_name, sart_numb_name
      ) loop

        if (1 = art.nnumb) then         nSum01 := art.nval;
        elsif (2 = art.nnumb) then      nSum02 := art.nval;
        elsif (3 = art.nnumb) then      nSum03 := art.nval;
        elsif (4 = art.nnumb) then      nSum04 := art.nval;
        elsif (5 = art.nnumb) then      nSum05 := art.nval;
        elsif (6 = art.nnumb) then      nSum06 := art.nval;
        elsif (7 = art.nnumb) then      nSum07 := art.nval;
        elsif (8 = art.nnumb) then      nSum08 := art.nval;
        elsif (9 = art.nnumb) then      nSum09 := art.nval;
        elsif (10 = art.nnumb) then     nSum10 := art.nval;
        elsif (11 = art.nnumb) then     nSum11 := art.nval;
        elsif (12 = art.nnumb) then     nSum12 := art.nval;        
        end if;
        
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal01, 0, nSTR, nSum01);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal02, 0, nSTR, nSum02);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal03, 0, nSTR, nSum03);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal04, 0, nSTR, nSum04);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal05, 0, nSTR, nSum05);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal06, 0, nSTR, nSum06);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal07, 0, nSTR, nSum07);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal08, 0, nSTR, nSum08);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal09, 0, nSTR, nSum09);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal10, 0, nSTR, nSum10);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal11, 0, nSTR, nSum11);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nVal12, 0, nSTR, nSum12);
        
      end loop;

    end loop;

    nSTR_P := PRSG_EXCEL.LINE_CONTINUE(L_lStrP);  -- Разрыв

    For art in (select fal.nsrc_summ, 
                       fal.DSRC_DATE, 
                       to_char(fal.DSRC_DATE, 'MONTH-YYYY') as MoreMonth, --trim(fal.SNOTE) as SNOTE,
                       '(' || UDO_F_FINPLAN_PAYNUMB(NRN) || ') ' || trim(UDO_F_FINPLAN_PAYCOMENT(NRN)) ExtNote --S6731952 and S6731957 
                  from UDO_V_FINPLAN_ARTS_LNK fal
                  where fal.nsrc_summ > nLimit and d_year(fal.DSRC_DATE) = d_year(dDate)
                    and fal.NART in (select PR.RN from UDO_T_FINPLAN_ARTS PR, SELECTLIST Sl where PR.PRN = SL.DOCUMENT and SL.IDENT = nIDENT )
                  order by dsrc_date
    ) loop
      
      if (d_month(art.DSRC_DATE) != nPrevMonth) then
        nSTR_M := PRSG_EXCEL.LINE_CONTINUE(L_lStrM);  -- Месяц для больших сумм
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sMonthText, 0, nSTR_M, art.MoreMonth);
        nPrevMonth := d_month(art.DSRC_DATE);
      end if;
      
      nSTR_More := PRSG_EXCEL.LINE_CONTINUE(L_lStrMore);  -- Большие суммы
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSumMore, 0, nSTR_More, art.nsrc_summ);
      --if ('' != art.snote) then PRSG_EXCEL.CELL_VALUE_WRITE(C_nTextMore, 0, nSTR_More, art.snote);
      if ('() ' != art.ExtNote) then
         PRSG_EXCEL.CELL_VALUE_WRITE(C_nTextMore, 0, nSTR_More, art.ExtNote);
      else
         PRSG_EXCEL.CELL_VALUE_WRITE(C_nTextMore, 0, nSTR_More, ' ');
      end if;        

    end loop;
          
    PRSG_EXCEL.LINE_DELETE(L_lStrP);
    PRSG_EXCEL.LINE_DELETE(L_lStrR);
    PRSG_EXCEL.LINE_DELETE(L_lStrD);
    PRSG_EXCEL.LINE_DELETE(L_lStrM);
    PRSG_EXCEL.LINE_DELETE(L_lStrMore);
    PRSG_EXCEL.LINE_DELETE(L_lStr);

end UDO_P_MONTHLY_PLAN;

/*
grant EXECUTE on UDO_P_MONTHLY_PLAN to public;
*/
/

