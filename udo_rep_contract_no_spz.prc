create or replace procedure UDO_REP_CONTRACT_NO_SPZ(
       nCOMPANY   in number,   -- Организация
       sRazd      in varchar2, -- Раздел из которого запускается отчет
       sOtv       in varchar2, -- Ответственный или null
       nSPZ       in number default 0 -- Только незаполненные; 1 -- Все данные
) is
-- Отчет по ШПЗ у договоров
----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

-- Шапка
  C_sHead    constant PKG_STD.TSTRING := 'sHead';
  C_sOtv     constant PKG_STD.TSTRING := 'sOtv';
  C_sDate    constant PKG_STD.TSTRING := 'Data';

  LL_TYPE    constant PKG_STD.TSTRING := 'L_Type';
  C_sType    constant PKG_STD.TSTRING := 's_Type';

  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
  C_nPP      constant PKG_STD.TSTRING := 'nPP';
  C_sDog     constant PKG_STD.TSTRING := 's_Dog';
  C_sStage   constant PKG_STD.TSTRING := 's_Stage';
  C_dDate    constant PKG_STD.TSTRING := 'd_Date';
  C_sSPZ     constant PKG_STD.TSTRING := 's_SPZ';
  C_sEconom  constant PKG_STD.TSTRING := 's_Econom';

  nSTR        number;
  nPP         number := 1;
  sEco        varchar2(64) := '';
    
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке
  PRSG_EXCEL.CELL_DESCRIBE(C_sHead);
  PRSG_EXCEL.CELL_DESCRIBE(C_sOtv);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_TYPE);
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек в строках
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_TYPE, C_sType);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDog);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sStage);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dDate);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSPZ);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sEconom);

  if (1 = nSPZ) then
       PRSG_EXCEL.CELL_VALUE_WRITE(C_sHead, 'ШПЗ договоров');
--  else PRSG_EXCEL.CELL_VALUE_WRITE(C_sHead, ' ');
  end if;

  if (sOtv is not NULL) then
       PRSG_EXCEL.CELL_VALUE_WRITE(C_sOtv, 'По Экономисту ' || sOtv);
  else PRSG_EXCEL.CELL_VALUE_WRITE(C_sOtv, ' ');
  end if;
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY HH:MM:SS'));
  
--p_exception(0,'Раздел: ' || sRazd);
  if ('Contracts' = sRazd) then
    sEco := trim(SUBSTR(sOtv, 1, INSTR(sOtv, ' ')-1));

    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_TYPE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sType, 0, nSTR, 'Поставка');
--p_exception(0,'Экономист: ' || sEco);

    for rec in(
      select * from V_ACATALOG cat
       where UNITCODE='Contracts' and COMPANY=nCOMPANY 
         and RN in (select RN from ACATALOG connect by prior RN = CRN start with CRN = '1073180') 
--         and (cat.name = sOtv or sOtv is NULL)
         and (cat.name like '%'||sEco||'%' or sOtv is NULL)
      order by SIGNS, CRN, NAME
    ) loop

      for doc in(
        select c.sdoc_type, c.sdoc_pref, c.sdoc_numb, to_char(c.ddoc_date, 'DD.MM.YYYY') ddoc_date, 
               nvl(UDO_F_STAGES_BUHNUM(s.nrn), '---') sSPZ, s.snumb,
              (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1082887 and UNITCODE = 'Contracts' and UNIT_RN = c.NRN) sEconom
          from V_CONTRACTS c, V_STAGES s
         where c.nCOMPANY = 90521 
           and c.NCRN = rec.rn 
           and s.nprn = c.nrn
           and (UDO_F_STAGES_BUHNUM(s.nrn) is null or nSPZ = 1)
         order by c.SAGENT, c.sdoc_pref, c.sdoc_numb, s.snumb
      ) loop

        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,     0, nSTR, nPP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,    0, nSTR, trim(doc.sdoc_type) || ' ' || trim(doc.sdoc_pref) || ', ' || trim(doc.sdoc_numb));
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage,  0, nSTR, trim(doc.snumb));
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dDate,   0, nSTR, doc.ddoc_date);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPZ,    0, nSTR, doc.sSPZ);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sEconom, 0, nSTR, doc.sEconom);

        nPP := nPP + 1;
      end loop;
    end loop;

    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_TYPE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sType, 0, nSTR, 'НИОКР');

    for rec in(
      select * from V_ACATALOG cat
       where UNITCODE='Contracts' and COMPANY=nCOMPANY 
         and RN in (select RN from ACATALOG connect by prior RN = CRN start with CRN = '1026676') 
--         and (cat.name = sOtv or sOtv is NULL)
         and (cat.name like '%'||sEco||'%' or sOtv is NULL)
      order by SIGNS, CRN, NAME
    ) loop

      for doc in(
        select c.sdoc_type, c.sdoc_pref, c.sdoc_numb,  to_char(c.ddoc_date, 'DD.MM.YYYY') ddoc_date,
               nvl(UDO_F_STAGES_BUHNUM(s.nrn), '---') sSPZ, s.snumb,
              (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1082887 and UNITCODE = 'Contracts' and UNIT_RN = c.NRN) sEconom
          from V_CONTRACTS c, V_STAGES s
         where c.nCOMPANY = 90521 
           and c.NCRN = rec.rn 
           and s.nprn = c.nrn
           and (UDO_F_STAGES_BUHNUM(s.nrn) is null or nSPZ = 1)
         order by c.SAGENT, c.sdoc_pref, c.sdoc_numb, s.snumb
      ) loop

        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,     0, nSTR, nPP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,    0, nSTR, trim(doc.sdoc_type) || ' ' || trim(doc.sdoc_pref) || ', ' || trim(doc.sdoc_numb));
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage,  0, nSTR, trim(doc.snumb));
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dDate,   0, nSTR, doc.ddoc_date);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPZ,    0, nSTR, doc.sSPZ);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sEconom, 0, nSTR, doc.sEconom);

        nPP := nPP + 1;

      end loop;
    end loop;

    --удаляем техническую строку
    PRSG_EXCEL.LINE_DELETE(LL_TYPE);
    PRSG_EXCEL.LINE_DELETE(LL_LINE);
  else 
    p_exception(0,'Неверный раздел' || sRazd);
  end if;

end UDO_REP_CONTRACT_NO_SPZ;
/

