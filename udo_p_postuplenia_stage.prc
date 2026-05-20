create or replace procedure UDO_P_POSTUPLENIA_STAGE (nIDENT in number, nStage in number /* 0 - без этапов, 1 - с этапами */)
  ---- Процедура отчета "Ожидаемые поступления"
is
    ---- Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Sheet1'; -- Лист
  -- Строки...
  L_lStr     constant PKG_STD.TSTRING := 'Stroka';
  L_lStrItog constant PKG_STD.TSTRING := 'Itogo';
  L_lStrSum  constant PKG_STD.TSTRING := 'Vsego';

  sKontr varchar(128) := '';
  nKontr number(17) := -1;
  nItog  number(17) := 0;
  nGot   number(17) := 0;
  nOur   number(17) := 0;
  nTotal number(17) := 0;
  nTotalGot number(17) := 0;
  nTotalOur number(17) := 0;
  
  nSTR         number(17) := 1;
  nSTR_I       number(17) := 1;
  nSTR_S       number(17) := 1;

  C_sType        constant PKG_STD.TSTRING := 'TypeO';        -- Тип отчета (только для этапов)
  C_sData        constant PKG_STD.TSTRING := 'Data';         -- Дата отчета
  C_sKontr       constant PKG_STD.TSTRING := 'Kontr';        -- Контрагент
  C_sTheme       constant PKG_STD.TSTRING := 'Theme';        -- Тема договора
  C_sDog         constant PKG_STD.TSTRING := 'Dog';          -- Номер договора
  C_nSumm        constant PKG_STD.TSTRING := 'Summ';         -- Сумма договора c НДС
  C_nGot         constant PKG_STD.TSTRING := 'Got';          -- Получено по договору
  C_nOur         constant PKG_STD.TSTRING := 'Our';          -- Осталось получить
  
  C_sItogName    constant PKG_STD.TSTRING := 'Itogo_Name';
  C_nItog        constant PKG_STD.TSTRING := 'Itog';
  C_nItogGot     constant PKG_STD.TSTRING := 'ItogGot';
  C_nItogOur     constant PKG_STD.TSTRING := 'ItogOur';
  C_nTotal       constant PKG_STD.TSTRING := 'Total';
  C_nTotalGot    constant PKG_STD.TSTRING := 'TotalGot';
  C_nTotalOur    constant PKG_STD.TSTRING := 'TotalOur';

  begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sData);
  PRSG_EXCEL.CELL_DESCRIBE(C_sType);

  -- Описываем добавляемые строки
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrItog);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrSum);
    
  -- Описываем имена ячеек в добавляемых строках
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sKontr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sTheme);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDog);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSumm);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nGot);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nOur);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrItog, C_sItogName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrItog, C_nItog);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrItog, C_nItogGot);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrItog, C_nItogOur);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrSum, C_nTotal);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrSum, C_nTotalGot);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrSum, C_nTotalOur);
    
  ---Заполнение шапки отчета
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));
  if (1 = nStage) then
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sType, 'По этапам');
  else
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sType, 'По договорам');
  end if;
  
  ---Перебираем договора
  For rec in (
    select con.sagent, con.sdoc_type, con.sdoc_pref, con.sdoc_numb, 
    con.nagent, --nvl(con.ssubject, '???') theme, 
    con.ndoc_sum, con.ndoc_sumtax, con.nfact_inpay_sum, con.nplan_inpay_sum,
    trim(con.sdoc_type) || ' ' || trim(con.sdoc_pref) || '-' || trim(con.sdoc_numb) sdoc_name, con.nrn,
    nvl((select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Contracts' and UNIT_RN = NRN), '-') S1076177, 
    --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 6000371 and UNITCODE = 'Contracts' and UNIT_RN = NRN) S6000371, 
    UDO_F_GET_USL_NAME(NRN) S6447919 from V_CONTRACTS con where NCRN in (select /*+ PUSH_SUBQ */ RN from ACATALOG 
    connect by prior RN = CRN start with RN = '1026676' /*НИОКР /* '6322649' - Общехозяйственные */) 
    and nCOMPANY = 90521
    union
    select con.sagent, con.sdoc_type, con.sdoc_pref, con.sdoc_numb, 
    con.nagent, --nvl(con.ssubject, '???') theme, 
    con.ndoc_sum, con.ndoc_sumtax, con.nfact_inpay_sum, con.nplan_inpay_sum,
    trim(con.sdoc_type) || ' ' || trim(con.sdoc_pref)|| '-' || trim(con.sdoc_numb) sdoc_name, con.nrn,
    nvl((select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Contracts' and UNIT_RN = NRN), '-') S1076177, 
    --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 6000371 and UNITCODE = 'Contracts' and UNIT_RN = NRN) S6000371, 
    UDO_F_GET_USL_NAME(NRN) S6447919 from V_CONTRACTS con where NCRN in (select /*+ PUSH_SUBQ */ RN from ACATALOG 
    connect by prior RN = CRN start with RN = '1073180' /* Поставка */) 
    and nCOMPANY = 90521  
    order by SAGENT, sdoc_type, sdoc_pref, sdoc_numb --, sdoc_name
    ) loop
    
    if (rec.s1076177 != '-') then -- выводим только Продажи (Шифр_поБУ не пустой!)
      if (1 = nStage) then -- смотрим по этапам
        ---Перебираем этапы
        For eta in (select nstage_sumtax, nfactrest, nfact_payed, nvl(trim(sdescription), '-') sdescription
          , nvl(UDO_F_STAGES_BUHNUM(NRN),'-') BUHNUM
          /*, V_STAGES.*, UDO_F_STAGES_BUHNUM(NRN) S1076183, UDO_F_STAGES_TRANSINVCUSTSUM(NRN) N6171372, 
          UDO_F_STAGES_START_DATE(NRN) D6169011, UDO_F_STAGES_END_DATE(NRN) D6169012, UDO_F_STAGE_ARTICLE(NRN) S6352977*/ 
          from V_STAGES where NPRN = rec.nrn /*1027033*/ and NACC_KIND = 1 /* Продажа */ 
          order by SNUMB
        ) loop
        
        if (-1 != nKontr and nKontr != rec.nagent) then
          -- Выводим строку Итого по Контрагенту
          nSTR_I := PRSG_EXCEL.LINE_CONTINUE(L_lStrItog);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sItogName, 0, nSTR_I, 'Итого (' || sKontr || '):');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog, 0, nSTR_I, nItog);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogGot, 0, nSTR_I, nGot);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogOur, 0, nSTR_I, nOur);
          
          nTotal := nTotal + nItog;
          nTotalGot := nTotalGot + nGot;
          nTotalOur := nTotalOur + nOur;
          
          nItog := 0;
          nGot := 0;
          --nOur := 0;
        end if;

        nKontr := rec.nagent;
        sKontr := rec.sagent;
        nItog := nItog + eta.nstage_sumtax;
        nGot := nGot + eta.nfact_payed;
        nOur := nItog - nGot; 
        
        nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sKontr, 0, nSTR, rec.sagent);
        if (eta.sdescription != '-') then
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sTheme, 0, nSTR, eta.sdescription);
        else
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sTheme, 0, nSTR, rec.S6447919 /*theme*/);
        end if;
        if (eta.buhnum != '-') then
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog, 0, nSTR, rec.sdoc_name || ' (' || eta.buhnum || ')');
        else
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog, 0, nSTR, rec.sdoc_name);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nSumm, 0, nSTR, eta.nstage_sumtax);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nGot, 0, nSTR, eta.nfact_payed);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nOur, 0, nSTR, eta.nstage_sumtax - eta.nfact_payed);
        end loop;
      else -- смотрим по договорам
        if (-1 != nKontr and nKontr != rec.nagent) then
          -- Выводим строку Итого по Контрагенту
          nSTR_I := PRSG_EXCEL.LINE_CONTINUE(L_lStrItog);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sItogName, 0, nSTR_I, 'Итого (' || sKontr || '):');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog, 0, nSTR_I, nItog);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogGot, 0, nSTR_I, nGot);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogOur, 0, nSTR_I, nOur);
          
          nTotal := nTotal + nItog;
          nTotalGot := nTotalGot + nGot;
          nTotalOur := nTotalOur + nOur;
          
          nItog := 0;
          nGot := 0;
          --nOur := 0;
        end if;

        nKontr := rec.nagent;
        sKontr := rec.sagent;
        nItog := nItog + rec.ndoc_sumtax;
        nGot := nGot + rec.nfact_inpay_sum;
        nOur := nItog - nGot;
        
        nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sKontr, 0, nSTR, rec.sagent);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sTheme, 0, nSTR, rec.S6447919 /*theme*/);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog, 0, nSTR, rec.sdoc_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nSumm, 0, nSTR, rec.ndoc_sumtax);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nGot, 0, nSTR, rec.nfact_inpay_sum);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nOur, 0, nSTR, rec.ndoc_sumtax - rec.nfact_inpay_sum);
      end if;
    end if;
 
  end loop;
            
  -- Выводим строку Итого для последнего Контрагента
  nSTR_I := PRSG_EXCEL.LINE_CONTINUE(L_lStrItog);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sItogName, 0, nSTR_I, 'Итого (' || sKontr || '):');
  PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog, 0, nSTR_I, nItog);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogGot, 0, nSTR_I, nGot);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogOur, 0, nSTR_I, nOur);
  
  nTotal := nTotal + nItog;
  nTotalGot := nTotalGot + nGot;
  nTotalOur := nTotalOur + nOur;
  
  -- Выводим общий итог
  nSTR_S := PRSG_EXCEL.LINE_CONTINUE(L_lStrSum);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_nTotal, 0, nSTR_S, nTotal);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_nTotalGot, 0, nSTR_S, nTotalGot);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_nTotalOur, 0, nSTR_S, nTotalOur);
    
  PRSG_EXCEL.LINE_DELETE(L_lStrSum);
  PRSG_EXCEL.LINE_DELETE(L_lStrItog);
  PRSG_EXCEL.LINE_DELETE(L_lStr);

end UDO_P_POSTUPLENIA_STAGE;
/

