create or replace procedure UDO_REP_FCROUTLST_PASPORT (
       nCOMPANY   in number,   -- Организация
       sRazd      in varchar2, -- Раздел из которого запускается отчет
       nIdent     in number,   -- Выбранная строка
       --nSeparate  in number,   -- Печатать отдельные МЛ по каждому Зав.номеру
       nIzdelie   in number,   -- Выбор Изделия (Матресурс)
       nZakaz     in number,   -- Выбор Заказа
       sZavod     in varchar2, -- Заводской номер
       bBarcode   in number,   -- Печать штрихкодов
       bAddone    in number,   -- Дополнительная страница Операций
       bRemark    in number    -- Только Ведомость замечаний
) is
  --bBarcode number := 1; -- 16/07/2024. Теперь печать только со штрих-кодом /* 18/09/2024 Повторно со штрихкодом только для ПДО, остальным можно только без */
----Переменные отчета
  C_SLIST1    constant PKG_STD.TSTRING := 'TDSheet1'; -- Лист
  C_SLIST2    constant PKG_STD.TSTRING := 'TDSheet2'; -- Лист
  C_SLIST2_0  constant PKG_STD.TSTRING := 'TDSheet2_0'; -- Лист
  C_SLIST3    constant PKG_STD.TSTRING := 'TDSheet3'; -- Лист
  C_SLIST4    constant PKG_STD.TSTRING := 'TDSheet4'; -- Лист
  C_SLIST4_0  constant PKG_STD.TSTRING := 'TDSheet4_0'; -- Лист (пока не используется вообще)
  C_SLIST5    constant PKG_STD.TSTRING := 'TDSheet5'; -- Лист
  C_SLIST6    constant PKG_STD.TSTRING := 'TDSheet6'; -- Лист
  C_SLIST7    constant PKG_STD.TSTRING := 'TDSheet7'; -- Лист
  C_SLIST8    constant PKG_STD.TSTRING := 'TDSheet8'; -- Лист
  C_SLIST9    constant PKG_STD.TSTRING := 'TDSheet9'; -- Лист

-- Шапка
  C_sPrefNum constant PKG_STD.TSTRING := 'sPrefNum';
  C_sPaspNum constant PKG_STD.TSTRING := 'sPaspNum';
  C_sZayavka constant PKG_STD.TSTRING := 'S_Zayavka';
  --C_sDate    constant PKG_STD.TSTRING := 'S_Date';
  C_sZakaz   constant PKG_STD.TSTRING := 'S_Zakaz';
  C_sAddon   constant PKG_STD.TSTRING := 'S_Addon';
  C_sSP      constant PKG_STD.TSTRING := 'S_SP';
  C_sSB      constant PKG_STD.TSTRING := 'S_SB';
  C_sIZM     constant PKG_STD.TSTRING := 'S_Ident';
  C_sBAR     constant PKG_STD.TSTRING := 'sBar';
  C_sBARVal  constant PKG_STD.TSTRING := 'sBarVal';
  C_sProgr   constant PKG_STD.TSTRING := 'sProgram';

  C_sPages   constant PKG_STD.TSTRING := 'S_Pages';
  C_sPage1   constant PKG_STD.TSTRING := 'Page1';
  C_sPage2   constant PKG_STD.TSTRING := 'Page2';
  C_sPage3   constant PKG_STD.TSTRING := 'Page3';
  C_sPage4   constant PKG_STD.TSTRING := 'Page4';
  C_sPage5   constant PKG_STD.TSTRING := 'Page5';
  C_sPage6   constant PKG_STD.TSTRING := 'Page6';
  C_sPage7   constant PKG_STD.TSTRING := 'Page7';
  C_sPage8   constant PKG_STD.TSTRING := 'Page8';
  C_sPage9   constant PKG_STD.TSTRING := 'Page9';
  C_sPage10  constant PKG_STD.TSTRING := 'Page10';

  C_sIzdelie   constant PKG_STD.TSTRING := 'S_Izdelie';
  C_sZav       constant PKG_STD.TSTRING := 'S_Zav';
  C_sIzdelie1  constant PKG_STD.TSTRING := 'S_Izdelie1';
  C_sZav1      constant PKG_STD.TSTRING := 'S_Zav1';
  C_sUFKV      constant PKG_STD.TSTRING := 'S_UFKV';
  
  C_sIzdelie3  constant PKG_STD.TSTRING := 'S_Izdelie3';
  C_sZav3      constant PKG_STD.TSTRING := 'S_Zav3';
  C_sIzdelie4  constant PKG_STD.TSTRING := 'S_Izdelie4';
  C_sZav4      constant PKG_STD.TSTRING := 'S_Zav4';
  C_sIzdelie5  constant PKG_STD.TSTRING := 'S_Izdelie5';
  C_sZav5      constant PKG_STD.TSTRING := 'S_Zav5';

  C_sIzdelie7  constant PKG_STD.TSTRING := 'S_Izdelie7';
  C_sZav7      constant PKG_STD.TSTRING := 'S_Zav7';
  C_sIzdelie8  constant PKG_STD.TSTRING := 'S_Izdelie8';
  C_sZav8      constant PKG_STD.TSTRING := 'S_Zav8';
  C_sIzdelie9  constant PKG_STD.TSTRING := 'S_Izdelie9';
  C_sZav9      constant PKG_STD.TSTRING := 'S_Zav9';
  C_sIzdelie10 constant PKG_STD.TSTRING := 'S_Izdelie10';
  C_sZav10     constant PKG_STD.TSTRING := 'S_Zav10';

--  C_nPP     constant PKG_STD.TSTRING := 'nPP';
  LL_LINE   constant PKG_STD.TSTRING := 'L_Line';
  C_sSName  constant PKG_STD.TSTRING := 'SName';
  C_nSKol   constant PKG_STD.TSTRING := 'SKol';
  C_sSNom   constant PKG_STD.TSTRING := 'SNom';

  LL_LINE2  constant PKG_STD.TSTRING := 'L_Line2';
  C_sSName2 constant PKG_STD.TSTRING := 'SName2';
  C_nSKol2  constant PKG_STD.TSTRING := 'SKol2';
  C_sSNom2  constant PKG_STD.TSTRING := 'SNom2';

  LL_LINE3  constant PKG_STD.TSTRING := 'L_Line3';
  C_sSPodr3 constant PKG_STD.TSTRING := 'SPodr3';
  C_sSOper3 constant PKG_STD.TSTRING := 'SOper3';
  --C_sPodp3  constant PKG_STD.TSTRING := 'SPodp3';
  C_sSName3 constant PKG_STD.TSTRING := 'SName3';
  LL_LINE3U  constant PKG_STD.TSTRING := 'L_Line3_U';
  C_sSOper3U constant PKG_STD.TSTRING := 'SOper3_U';
  C_sSName3U constant PKG_STD.TSTRING := 'SName3_U';
  LL_LINE3B  constant PKG_STD.TSTRING := 'L_Line3_B';
  C_sBar3    constant PKG_STD.TSTRING := 'sBar3';
  C_sBar3Val constant PKG_STD.TSTRING := 'sBar3Val';

  LL_LINE4  constant PKG_STD.TSTRING := 'L_Line4';
  C_sSPodr4 constant PKG_STD.TSTRING := 'SPodr4';
  C_sSOper4 constant PKG_STD.TSTRING := 'SOper4';
  C_sSName4 constant PKG_STD.TSTRING := 'SName4';
  --C_sPodp4  constant PKG_STD.TSTRING := 'SPodp4';
  LL_LINE4U  constant PKG_STD.TSTRING := 'L_Line4_U';
  C_sSOper4U constant PKG_STD.TSTRING := 'SOper4_U';
  C_sSName4U constant PKG_STD.TSTRING := 'SName4_U';
  LL_LINE4B  constant PKG_STD.TSTRING := 'L_Line4_B';
  C_sBar4    constant PKG_STD.TSTRING := 'sBar4';
  C_sBar4Val constant PKG_STD.TSTRING := 'sBar4Val';

  nSTR        number;
  nSTR2       number;
  nSTR3       number;
  nSTR4       number;
  nPP         number := 0;
  nPages      number := 1;
  nTP_NRN     number := 0;
  nNU_RN      number(17);
  nTP_ART     number(17);
  nPRODCMPSP  numeric(17) := null;
  nProgr      number(17);
  sZav        varchar2(18) := '';
  sZavFirst   varchar2(18) := '';
  nMaxRows1   number := 20;
  nMaxRows2   number := 64;
  nMaxRows3   number := 30;
  nSheet      number := 1; -- Размножение страницы "Составные части"
  nSheet4     number := 1; -- Размножение страницы "Операции"
  sSheetName  varchar2(16);-- Имя размножаемой стриницы
  --nHonest     number := 1; -- Четность пустой страницы
  nCRN        pkg_std.tref; 
  nJUR_PERS   pkg_std.tref; 
  

/*  function GET_LUNA (vpan in varchar) return varchar2
  is
    xx integer;
    s integer := 0;
    begin
    for i in 1..length(vpan)
    loop
        xx := to_number(substr(vpan,length(vpan)-i+1,1));
        if mod(i,2) != 0 then xx:=xx*2; if xx>9 then xx:=xx-9; end if; end if;
        s := s+xx;
    end loop;
    s := 10-mod(s,10);
    if s = 10 then s:=0; end if;
    return(to_char(s));
  end;*/

  /* Добавить операцию */
  procedure OPER_ADD (
    smatres_name in varchar2,
    sSUBDIV      in varchar2,
    sSUBDIV_EX   in varchar2,
    sOPER_NUMB   in varchar2,
    sOPER        in varchar2,
    sBarCode     in varchar2,
    nStrRN       in number,
    nMerge       in integer
  ) is
  begin 
    if (nPP < nMaxRows3) then
        if 1 = nMerge or INSTR(sOPER_NUMB, '#') > 0 then
          nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3U);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper3U, 0, nSTR3, trim(sOPER_NUMB));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName3U, 0, nSTR3, trim(sOPER));
        else
          nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3);
          if sSUBDIV is null or sSUBDIV not in('ОТК', 'ВП', 'Разр', 'ГК', 'Комис.', 'АО "ИСС"') then
               PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr3, 0, nSTR3, 'ПО'    || ' ' ||nvl(sSUBDIV_EX, ''));
          else PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr3, 0, nSTR3, sSUBDIV || ' ' ||nvl(sSUBDIV_EX, ''));
          end if;
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper3, 0, nSTR3, trim(sOPER_NUMB));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName3, 0, nSTR3, trim(sOPER));

          if 1 = bBarcode then
            nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3B);
            --PRSG_EXCEL.CELL_FORMULA_WRITE(C_sBar3, 0, nSTR3, '=Code_128('||sZav||'O'||nStrRN||')'); -- Code_39
            PRSG_EXCEL.CELL_FORMULA_WRITE(C_sBar3Val, 0, nSTR3, sZav||'O'||nStrRN);
          end if;
        end if;
    else
        if nMaxRows3 = nPP then
          for Lcntr IN nPP..nMaxRows3-1 -- добавляем пустые строки
          loop
            nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr3, 0, nSTR3, '');
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper3, 0, nSTR3, '');
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName3, 0, nSTR3, '');
          end loop;
          PRSG_EXCEL.LINE_DELETE(LL_LINE3); -- удаляем техническую строку на третьей странице
          PRSG_EXCEL.LINE_DELETE(LL_LINE3U);
          PRSG_EXCEL.LINE_DELETE(LL_LINE3B);

          PRSG_EXCEL.SHEET_SELECT(C_SLIST4); -- МАРШРУТНЫЙ ЛИСТ (продолжение)
          nPages := nPages + 1;
          PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie4, smatres_name);
          PRSG_EXCEL.CELL_DESCRIBE(C_sZav4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav4, sZav);
          PRSG_EXCEL.CELL_DESCRIBE(C_sPage4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage4, nPages);

          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSPodr4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSOper4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSName4);
          --PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sPodp4);
          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4U);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4U, C_sSOper4U);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4U, C_sSName4U);

          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4B);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4B, C_sBar4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4B, C_sBar4Val);
        --else
          --PRSG_EXCEL.LINE_DELETE(LL_LINE3); -- удаляем техническую строку на третьей странице
        end if;

        if /*false and*/ (nPP > nMaxRows3*(nSheet4+1)) then -- несколько продолжений Продолжения Операций
          PRSG_EXCEL.LINE_DELETE(LL_LINE4); -- удаляем техническую строку на четвертой и т.д. страницах
          PRSG_EXCEL.LINE_DELETE(LL_LINE4U);
          PRSG_EXCEL.LINE_DELETE(LL_LINE4B);

          nSheet4 := nSheet4 + 1;
          sSheetName := 'TDSheet4_'||nSheet4;
          PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet4_0',
                                sSHEET_NAME_TO     => sSheetName,
                                sSHEET_NAME_BEFORE => null,
                                nMOVE_TO_END       => 1);
          PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);

          nPages := nPages + 1;
          PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie4, smatres_name);
          PRSG_EXCEL.CELL_DESCRIBE(C_sZav4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav4, sZav);
          PRSG_EXCEL.CELL_DESCRIBE(C_sPage4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage4, nPages);

          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSPodr4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSOper4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSName4);
          --PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sPodp4);
          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4U);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4U, C_sSOper4U);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4U, C_sSName4U);

          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4B);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4B, C_sBar4);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4B, C_sBar4Val);
        end if;

        if 1 = nMerge or INSTR(sOPER_NUMB, '#') > 0 then
          nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE4U);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper4U, 0, nSTR4, trim(sOPER_NUMB));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName4U, 0, nSTR4, trim(sOPER));
        else
          nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE4);
          if sSUBDIV is null or sSUBDIV not in('ОТК', 'ВП', 'Разр', 'ГК', 'Комис.', 'АО "ИСС"') then
               PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr4, 0, nSTR4, 'ПО'    || ' ' ||nvl(sSUBDIV_EX, ''));
          else PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr4, 0, nSTR4, sSUBDIV || ' ' ||nvl(sSUBDIV_EX, ''));
          end if;
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper4, 0, nSTR4, trim(sOPER_NUMB));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName4, 0, nSTR4, trim(sOPER));

          if 1 = bBarcode then
            nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE4B);
            --PRSG_EXCEL.CELL_FORMULA_WRITE(C_sBar4, 0, nSTR4, '=Code_128('||sZav||'O'||nStrRN||')'); -- Code_39
            PRSG_EXCEL.CELL_FORMULA_WRITE(C_sBar4Val, 0, nSTR4, sZav||'O'||nStrRN);
          end if;
        end if;
      end if; 
  end;  -- OPER_ADD
  
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST1); -- Главная страница  -- Составные части
  -- Описываем имена ячеек в шапке
  PRSG_EXCEL.CELL_DESCRIBE(C_sPrefNum);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPaspNum);
  PRSG_EXCEL.CELL_DESCRIBE(C_sZayavka);
  --PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sZakaz);
  PRSG_EXCEL.CELL_DESCRIBE(C_sAddon);

  PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie);
  PRSG_EXCEL.CELL_DESCRIBE(C_sZav);
  PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie1);
  PRSG_EXCEL.CELL_DESCRIBE(C_sZav1);
  PRSG_EXCEL.CELL_DESCRIBE(C_sUFKV);
  PRSG_EXCEL.CELL_DESCRIBE(C_sSP);
  PRSG_EXCEL.CELL_DESCRIBE(C_sSB);
  PRSG_EXCEL.CELL_DESCRIBE(C_sIZM);
  PRSG_EXCEL.CELL_DESCRIBE(C_sBAR);
  PRSG_EXCEL.CELL_DESCRIBE(C_sBARVal);
  PRSG_EXCEL.CELL_DESCRIBE(C_sProgr);

  PRSG_EXCEL.CELL_DESCRIBE(C_sPage1);
--PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage1, nPages); -- неизменна
-- Описываем ячейки спецификации
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

-- Описываем имена ячеек в строках
--  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSKol);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSNom);

  if 'ProjectsStages' = sRazd then -- Экономисты должны указать Изделие и Заказ на производство
    if nIzdelie is null or nZakaz is null then
      p_exception(0, 'Необходимо указать и Изделие и Номер заказа на производство!');
    end if;
    sZav := trim(sZavod);
    begin
    select t.rn, nu.rn
      into nTP_NRN, nNU_RN
      from FCROUTLST t, FCROUTLSTSERNUMB nu, RLARTICLES R
     where t.matres = nIzdelie
       and t.prodcmp is not null
       and t.faceacc = nZakaz
       and nu.prn = t.rn
       and r.rn = nu.article
       and substr(r.code, 13) = sZav;
    exception
      when NO_DATA_FOUND then
        p_exception(0, 'Маршрутный лист не найден!');
      when TOO_MANY_ROWS then
        p_exception(0, 'По запросу найдено несколько маршрутных листов!');
    end;
    --p_exception(0, nTP_NRN);

  else -- CostRouteListsSerialNumbers (Серийный номер изделия)
  for list in(
    select t.nprn, t.narticle, 
           substr(t.sarticle, instr(t.sarticle, '_')+1)/*15/08/2023 Марков МВ. не всегда 13 substr(t.sarticle,13)*/ sarticle, 
           t.nrn as nu_rn -- RLARTICLES R where T.ARTICLE = R.RN
          ,t.ncrn
          ,t.njur_pers
      from (select t.*, row_number() over (order by t.sarticle) as seqnum,
                   count(*) over () as cnt
            from SELECTLIST SL, V_FCROUTLSTSERNUMB t
            where SL.IDENT = nIdent and t.NRN = SL.DOCUMENT 
            order by t.sarticle) t 
     where seqnum = 1
    union all
    select t.nprn, t.narticle, 
           substr(t.sarticle, instr(t.sarticle, '_')+1)/*15/08/2023 Марков МВ. не всегда 13 substr(t.sarticle,13)*/ sarticle, 
           t.nrn as nu_rn
          ,t.ncrn
          ,t.njur_pers
      from (select t.*, row_number() over (order by t.sarticle) as seqnum,
                   count(*) over () as cnt
            from SELECTLIST SL, V_FCROUTLSTSERNUMB t
            where SL.IDENT = nIdent and t.NRN = SL.DOCUMENT 
            order by t.sarticle) t 
     where seqnum = cnt
  ) loop
      nTP_ART := list.narticle;
      nTP_NRN := list.nprn;
      nNU_RN  := list.nu_rn;
      if (sZav is null or sZavFirst != list.sarticle) then
        sZav := sZav || '-' || list.sarticle;
        sZavFirst := list.sarticle;
      end if;
    --p_exception(0,'nTP_NRN: ' || nTP_NRN || ' sZav: ' || sZav || ' sarticle: ' || list.sarticle);
      nCRN      := list.ncrn;
      nJUR_PERS := list.njur_pers;
  end loop;
  sZav := substr(sZav, 2);
  end if;

  /* Проверка заполненности данных у МЛ */
  begin
    if bRemark != 0 then
      select count(t.rn) into nPP from FCROUTLSTSP t where t.PRN = nTP_NRN;
      if nPP = 0 then 
        p_exception(0, 'У Маршрутного листа отсутствуют строки операций.'); 
      end if;
      select t.state into nPP from FCROUTLST t where t.RN = nTP_NRN;
      if nPP != 1 and nPP != 2 then
        p_exception(0, 'Маршрутный лист должен быть в состоянии "В работе" или "Исполнен".');
      end if;
    else 
      /* Состояние документа Новый */
      select t.state into nPP from FCROUTLST t where t.RN = nTP_NRN;
      if nPP = 0 and utilizer != 'KHOK' then
        p_exception(0, 'Запрещено печатать маршрутный лист в состоянии "Новый".');
      end if;

      /* Если отчёт со штрихкодом уже был распечатан ранее */
      if udo_f_fcroutlstsn_print(nrn => nNU_RN) > 0 and 1 = bBarcode then
        /* Проверка права "Повторная печать маршрутного листа" */
        pkg_env.prologue(ncompany   => nCOMPANY
                        ,nversion   => null
                        ,ncatalog   => nCRN
                        ,njur_pers  => nJUR_PERS
                        ,nhierarchy => null
                        ,sunit      => 'CostRouteListsSerialNumbers'
                        ,saction    => 'USR_FCROUTLSTSERNUMB_REPRINT'
                        ,stable     => 'FCROUTLSTSERNUMB'
                        ,ndocument  => nNU_RN
                        ,saltmsg    => cr||cr||'Документ уже был распечан <'||udo_f_fcroutlstsn_print(nrn => nNU_RN)||'> раз. '||
                                       cr||'Снимите галочку "Печать со штрихкодом", используйте параметр отчёта "Только ведомость замечаний" или обратитесь в ПДО.'||
                                       cr||f_docdescrs_get_description(sunitcode => 'CostRouteListsSerialNumbers', ndocument => nNU_RN)||cr||cr  );

        pkg_env.epilogue(ncompany   => nCOMPANY
                        ,nversion   => null
                        ,ncatalog   => nCRN
                        ,njur_pers  => nJUR_PERS
                        ,nhierarchy => null
                        ,sunit      => 'CostRouteListsSerialNumbers'
                        ,saction    => 'USR_FCROUTLSTSERNUMB_REPRINT'
                        ,stable     => 'FCROUTLSTSERNUMB'
                        ,ndocument  => nNU_RN);
      end if; 
    end if;
  end;

  /* Цикл */
  for rec in(
    select trim(lst.docpref) || trim(lst.docnumb) pref_numb, lst.barcode, 
           lst.rn, /*lst.prodcmp, */lst.prodcmpsp, lst.exec_date, lst.matres,
           MR.NAME smatres_name, F.NUMB sfaceacc_numb, 
           SUBSTR(D.NOMEN_NAME, INSTR(D.NOMEN_NAME, 'ЮФКВ')) as UFKV, /*MA.STRING_VALUE,*/
           trim(lst.docpref) || '-' || trim(lst.docnumb) /*|| ' от ' || to_char(lst.docdate, 'DD.MM.YYYY')*/ as PaspNum,
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13459637 and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) SB,
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13459644 and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) SP, 
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13459654 and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) IZM,
           UDO_F_FCROUTLST_CHNOT_NUMBIZ(lst.prodcmpsp) NUMBIZ, 
           UDO_F_FCROUTLST_CHNOT_IDIZ(lst.prodcmpsp) IDIZ,
           --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13459633 and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) sZav, 
           UDO_F_GET_DOC_PROP_VAL_STR(SPROPERTY => 'ПРИМЕЧАНИЕ_МК',
                                      SUNITCODE => 'CostRouteLists',
                                      NDOCUMET  => lst.RN) Addon,
           (select sp.FCROUTSHT
              from FCROUTLSTSP sp
             where sp.prn = lst.rn 
               and sp.FCROUTSHT is not null
               and rownum = 1) as nFCROUTSHT, -- МК, указанная в спецификации
           (select MA.STRING_VALUE
              from UDO_MODIF_ATTR MA
             where MA.prn = MR.nomen_modif 
               and MA.ATTRIBUTE_ID = 9
               and rownum = 1) as STRING_VALUE -- Аттрибут из Интермех
      from FCROUTLST lst
      left outer join FACEACC        F  on lst.FACEACC = F.RN
      inner      join FCMATRESOURCE  MR on lst.MATRES  = MR.RN
      inner      join DICNOMNS       D  on MR.NOMENCLATURE = D.RN
      --left       join UDO_MODIF_ATTR MA on MA.PRN = MR.NOMEN_MODIF and MA.ATTRIBUTE_ID = 9 and rownum = 1 -- Аттрибут из Интермех
     where lst.rn = nTP_NRN
   ) loop

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrefNum, rec.PaspNum);
    if 1 = bBarcode then
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sPaspNum, 'ТЕХНОЛОГИЧЕСКИЙ ПАСПОРТ' /*№ ' || rec.PaspNum*/);
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sZayavka, UDO_F_FCROUTLST_PRODUCT_NUM(rec.rn));
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz,   rec.sfaceacc_numb);
    else PRSG_EXCEL.CELL_VALUE_WRITE(C_sPaspNum, '!!! НЕ ДЛЯ ПЕЧАТИ !!!');
    end if;
    --PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, to_char(rec.exec_date, 'DD.MM.YYYY'));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sAddon, rec.Addon);

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie,  rec.smatres_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav,      sZav);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie1, rec.smatres_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav1,     sZav);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sUFKV,     nvl(rec.STRING_VALUE, rec.UFKV));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sSP,       rec.sp);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sSB,       nvl(rec.SB, rec.NUMBIZ )); /* KHOK. Теперь эти данные грузятся из IPS */
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIZM,      nvl(rec.IZM, rec.IDIZ));   /* Здесь и выше могут быть расхождения */
    if 1 = bBarcode then
      --PRSG_EXCEL.CELL_VALUE_WRITE(C_sBAR, '=Code_128('||rec.rn||')'); -- Code_128
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sBARVal, rec.rn);
    end if;

    begin
    select count(stsp.rn) 
      into nProgr
      from FCROUTLSTSP stsp 
     where stsp.PRN = rec.rn
       and (stsp.OPER_TPS in (20722558, 70904437) or
            stsp.oper_uk in ('Программирование', 'Проверка и программирование'));
    end;
    if nProgr = 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sProgr, 'Не требуется');
    end if;
    
    -->> 26/12/2023 KHOK Для ремонтных МЛ ищем ПС по заводскому номеру
    if rec.prodcmpsp is not null then
      nPRODCMPSP := rec.prodcmpsp;
    else
      begin
        select max(RL.PRODCMPSP) -- наверняка же самый свежий будет
          into nPRODCMPSP
          from FCROUTLSTSERNUMB SER,
               FCROUTLST        RL
         where SER.ARTICLE = nTP_ART 
           and SER.prn     = RL.RN
           and RL.DOCTYPE  = 12140413; -- обычные МЛ
      exception
        when NO_DATA_FOUND then
          nPRODCMPSP := null;
      end;
    end if;
    --<< 26/12/2023 KHOK Для ремонтных МЛ ищем ПС по заводскому номеру

    nPP := 0;
    if 0 = bRemark then -- Печатаем не только Ведомость замечаний
    for spec in(
       select /*nm.nomen_name*/ f.NAME as smtr_res_name, sp.quant as nquant 
       from FCPRODCMPSP    sp,
            FCMATRESOURCE  F --, DICNOMNS       NM
        where sp.hrn = nPRODCMPSP
          --and (sp.smtr_res_name like '%ЮФКВ%' or '%НСЖК%' or '%КМИВ%' or '%ЮПИЯ')
          --and sp.smtr_res_name like '% ____.%' and sp.smtr_res_name not like '%.__.%'
          --and nm.nomen_name like '% ____.%' and nm.nomen_name not like '%.__.%'
          --and f.NAME like '% ____.%' and f.NAME not like '%.__.%'
          and f.NAME like '%ЮФКВ.%'
          and sp.prodlist_numb is not null
          and sp.quant > 0
          and sp.MTR_RES     = F.RN
          --and F.NOMENCLATURE = NM.RN
        order by sp.hier_level, sp.prodlist_numb--, f.NAME
    ) loop --11348697; 40492852 -- ->nprodcmp

      nPP := nPP + 1;
      if (nPP < nMaxRows1) then
        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName, 0, nSTR, spec.smtr_res_name); --.scomplete_name); 
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol,  0, nSTR, spec.nquant); --.nprod_quant);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom,   0, nSTR, '');
      else
        if nMaxRows1 = nPP then -- Заполнили строки на первой странице
          PRSG_EXCEL.LINE_DELETE(LL_LINE); -- удаляем техническую строку на первой странице

          PRSG_EXCEL.SHEET_SELECT(C_SLIST2); -- Начинаем Составные части (продолжение)
          nPages := nPages + 1;
          PRSG_EXCEL.CELL_DESCRIBE(C_sPage2);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage2, nPages);

          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE2);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sSName2);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_nSKol2);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sSNom2);
        end if;

        if (nPP-nMaxRows1 = nMaxRows2*nSheet) then -- несколько продолжений Продолжения
          PRSG_EXCEL.LINE_DELETE(LL_LINE2); -- удаляем техническую строку на второй и т.д. страницах

          nSheet := nSheet + 1;
          sSheetName := 'TDSheet2_'||nSheet;
          PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet2_0',
                                sSHEET_NAME_TO     => sSheetName,
                                sSHEET_NAME_BEFORE => null,
                                nMOVE_TO_END       => 0);
          PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);

          nPages := nPages + 1;
          PRSG_EXCEL.CELL_DESCRIBE(C_sPage2);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage2, nPages);     

          PRSG_EXCEL.LINE_DESCRIBE(LL_LINE2);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sSName2);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_nSKol2);
          PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sSNom2);

          nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE2);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName2, 0, nSTR2, spec.smtr_res_name); --.scomplete_name);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol2,  0, nSTR2, spec.nquant);
          --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom2,  0, nSTR2, '');
        else
          nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE2);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName2, 0, nSTR2, spec.smtr_res_name); --.scomplete_name);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol2,  0, nSTR2, spec.nquant);
          --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom2,  0, nSTR2, '');
        end if;          
      end if;

    end loop;

    if false then -- не выводим вторую страницу если на ней нет данных 
      if nPP < nMaxRows1 then -- Составные части уместились на первой странице

        for Lcntr IN nPP..nMaxRows1-2 -- добавляем пустые строки на первой странице
        loop
          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName, 0, nSTR, '');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol,  0, nSTR, '');
          --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom,  0, nSTR, '');
        end loop;
        PRSG_EXCEL.LINE_DELETE(LL_LINE); -- удаляем техническую строку на первой странице

        PRSG_EXCEL.SHEET_SELECT(C_SLIST2); -- Составные части (продолжение)
        nPages := nPages + 1;
        PRSG_EXCEL.CELL_DESCRIBE(C_sPage2);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage2, nPages);

        PRSG_EXCEL.LINE_DESCRIBE(LL_LINE2);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sSName2);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_nSKol2);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sSNom2);

        for Lcntr IN nPP..nMaxRows2 -- добавляем пустые строки на Продолжение
        loop
          nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE2);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName2, 0, nSTR2, '');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol2,  0, nSTR2, '');
          --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom2,  0, nSTR2, '');
        end loop;

      else 

        if nPP < nMaxRows2+nMaxRows1 then
          PRSG_EXCEL.SHEET_SELECT(C_SLIST2); -- Составные части (продолжение)
          --nPages := nPages + 1;
          for Lcntr IN nPP..nMaxRows2+nMaxRows1 -- добавляем пустые строки на Продолжение
          loop
            nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE2);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName2, 0, nSTR2, '');
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol2,  0, nSTR2, '');
            --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom2,  0, nSTR2, '');
          end loop;
        else
          for Lcntr IN nPP-nMaxRows2..nMaxRows2+nMaxRows1 -- добавляем пустые строки на продолжении Продолжения
            loop
              nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE2);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName2, 0, nSTR2, '');
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol2,  0, nSTR2, '');
              --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom2,  0, nSTR2, '');
            end loop;
        end if;    
        PRSG_EXCEL.LINE_DELETE(LL_LINE2); -- удаляем техническую строку на второй странице

      end if;
    else
      if nPP < nMaxRows1 then -- Составные части уместились на первой странице

        for Lcntr IN nPP..nMaxRows1-2 -- добавляем пустые строки на первой странице
        loop
          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName, 0, nSTR, '');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSKol,  0, nSTR, '');
          --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSNom,  0, nSTR, '');
        end loop;
        PRSG_EXCEL.LINE_DELETE(LL_LINE); -- удаляем техническую строку на первой странице

      end if;
    end if;

    if nPP < nMaxRows1 then
      PRSG_EXCEL.SHEET_DELETE(C_SLIST2);
    end if;
    
-------------------------------------------------
    PRSG_EXCEL.SHEET_SELECT(C_SLIST3); -- МАРШРУТНЫЙ ЛИСТ
    nPages := nPages + 1;
    nPP    := 0;
    
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie3);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie3, rec.smatres_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav3);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav3, sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPage3);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage3, nPages);

    PRSG_EXCEL.LINE_DESCRIBE(LL_LINE3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3, C_sSPodr3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3, C_sSOper3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3, C_sSName3);
    --PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3, C_sPodp3);
    PRSG_EXCEL.LINE_DESCRIBE(LL_LINE3U);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3U, C_sSName3U);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3U, C_sSOper3U);

    PRSG_EXCEL.LINE_DESCRIBE(LL_LINE3B);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3B, C_sBar3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE3B, C_sBar3Val);

    /* Печатаем примечание о ВК (если в МК явно не указан признак не печатать)*/
    if upper(nvl(prsf_prop_sget(nCOMPVERS => ncompany,
                                sUNITCODE => 'CostRouteSheets',
                                nDOCUMENT => rec.nFCROUTSHT,
                                sPROPCODE => 'ПРИЗНАК_ВК'), 'ДА')) != 'НЕТ' then 
/*      if 0 = nPP then
           PRSG_EXCEL.MERGE_CELLS(sCELL_NAME_FROM    => C_sSName3,
                                 iCELL_INDEX_X_FROM => 0,
                                 iCELL_INDEX_Y_FROM => nSTR3,
                                 sCELL_NAME_TO      => C_sPodp3,
                                 iCELL_INDEX_X_TO   => 0,
                                 iCELL_INDEX_Y_TO   => nSTR3);
           PRSG_EXCEL.MERGE_CELLS(sCELL_NAME_FROM => C_sSName3, sCELL_NAME_TO => C_sPodp3);
      end if;*/
      nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3U);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName3U, 0, nSTR3, 'Входной контроль комплектующих изделий и материалов проводится по ЮФКВ.25200.00001 ТИ');
      nPP := 1;
    end if;

--if utilizer = 'KHOK' then p_exception(0,rec.rn); end if;
    if 1 = bBarcode then nMaxRows3 := 20; end if;

    /* Цикл по операциям МЛ */
    for ml in( -- V_FCROUTLSTSP_ES ?
      select stsp.rn, stsp.oper_numb, stsp.barcode,
             nvl(stsp.oper_uk, nvl(op.name, '?')) || 
             case when trim(stsp.note) is not null then ' ('||stsp.note||')' else null end as soper, 
             nvl(ins_h.code, ins_s.code) as ssubdiv,
             prsf_prop_sget(nCOMPVERS => stsp.company,
                            sUNITCODE => 'CostRouteListsSpecs',
                            nDOCUMENT => stsp.RN,
                            sPROPCODE => 'ПОДР_ДОП') as sPodrList,
             case -- 27/12/2022 Марков МВ. Если не всегда есть ссылки на запись, то необходимо всегда проверять на NULL
               when stsp.fcroutshtsp is not null then
             prsf_prop_sget(nCOMPVERS => htsp.company,
                            sUNITCODE => 'CostRouteSheetsSpecs',
                            nDOCUMENT => htsp.RN,
                            sPROPCODE => 'ПРИМЕЧАНИЕ_МК')
             else ''
             end as sNOTE_EX,
             case
               when stsp.fcroutshtsp is not null then
             prsf_prop_sget(nCOMPVERS => htsp.company,
                            sUNITCODE => 'CostRouteSheetsSpecs',
                            nDOCUMENT => htsp.RN,
                            sPROPCODE => 'ПОДР_ДОП')
             else ''
             end as sPodr,
             case
               when stsp.fcroutshtsp is not null then
             prsf_prop_sget(nCOMPVERS => htsp.company,
                            sUNITCODE => 'CostRouteSheets',
                            nDOCUMENT => htsp.prn,
                            sPROPCODE => 'МК_ДЕЦИМ_НОМ')
             else ''
             end as sDCML_NUMB,
             Lag (nvl(stsp.oper_uk, nvl(op.code, '?')),1) over (ORDER BY stsp.numb) as sprev_oper               
        from FCROUTLSTSP    stsp, 
             FCROUTSHTSP    htsp,
             INS_DEPARTMENT ins_s,
             INS_DEPARTMENT ins_h,
             FCOPERTYPES    op
       where stsp.PRN         = rec.rn
         and stsp.fcroutshtsp = htsp.rn (+)
         and stsp.oper_tps = op.rn (+)
         and stsp.subdiv = ins_s.rn (+)
         and htsp.subdiv = ins_h.rn (+)
       order by nvl(stsp.numb, htsp.numb) -- сначала последовательность в Маршрутной карте, потом добавленное в самом МЛ
    ) loop 
	    if (nPP in (0,1) and ml.sDCML_NUMB is not null) then -- Децимальный номер Маршрутной карты
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName3, 0, nSTR3, 'Номер тех. процесса '||trim(ml.sDCML_NUMB));
      end if;

      nPP := nPP + 1;
      /* Добавляем строку операции */
      OPER_ADD(sMATRES_NAME => rec.smatres_name,
               sSUBDIV      => ml.ssubdiv, 
               sSUBDIV_EX   => nvl(ml.sPodrList, ml.spodr),
               sOPER_NUMB   => ml.oper_numb,
               sOPER        => trim(ml.soper), --case when ml.sprev_oper = ml.soper then '' else ml.soper end, -- ?надо с учетом stsp.note?
               sBarCode     => ml.barcode,
               nStrRN       => ml.rn,
               nMerge       => 0);
     
      if ml.sNOTE_EX is not null then 
        nPP := nPP + 1;
        /* Добавляем строку для примечания */
        OPER_ADD(sMATRES_NAME => rec.smatres_name,
                 sSUBDIV      => '', 
                 sSUBDIV_EX   => '',
                 sOPER_NUMB   => '',
                 sOPER        => ml.sNOTE_EX,
                 sBarCode     => null,
                 nStrRN       => ml.rn,
                 nMerge       => 1);
      end if;          
    end loop;

    if nMaxRows3 > nPP then
      for Lcntr IN nPP..nMaxRows3 -- добавляем пустые строки
      loop
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE3);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr3, 0, nSTR3, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper3, 0, nSTR3, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName3, 0, nSTR3, '');
      end loop;
      PRSG_EXCEL.LINE_DELETE(LL_LINE3); -- удаляем техническую строку на третьей странице
      PRSG_EXCEL.LINE_DELETE(LL_LINE3U); 
      PRSG_EXCEL.LINE_DELETE(LL_LINE3B); 

    -- ??? не печатаем лист, если на нем нет никаких данных ???
      if MOD(nPages, 2) != 0 or 1 = bAddone  then
        PRSG_EXCEL.SHEET_SELECT(C_SLIST4); -- МАРШРУТНЫЙ ЛИСТ (продолжение)
        nPages := nPages + 1;
        PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie4);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie4, rec.smatres_name);
        PRSG_EXCEL.CELL_DESCRIBE(C_sZav4);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav4, sZav);
        PRSG_EXCEL.CELL_DESCRIBE(C_sPage4);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage4, nPages);

        PRSG_EXCEL.LINE_DESCRIBE(LL_LINE4);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSPodr4);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSOper4);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sSName4);
        --PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE4, C_sPodp4);
        for Lcntr IN 1..nMaxRows3 -- добавляем пустые строки
        loop
          nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE4);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr4, 0, nSTR4, '');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper4, 0, nSTR4, '');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName4, 0, nSTR4, '');
        end loop;
        PRSG_EXCEL.LINE_DELETE(LL_LINE4);
        --PRSG_EXCEL.LINE_DELETE(LL_LINE4U);
        --PRSG_EXCEL.LINE_DELETE(LL_LINE4B);
      else
        PRSG_EXCEL.SHEET_DELETE(C_SLIST4);
      end if;
    else
      --PRSG_EXCEL.LINE_DELETE(LL_LINE3); -- удаляем техническую строку на третьей странице
      for Lcntr IN nPP..nMaxRows3 -- добавляем пустые строки
      loop
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_LINE4);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSPodr4, 0, nSTR4, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSOper4, 0, nSTR4, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSName4, 0, nSTR4, '');
      end loop;
      PRSG_EXCEL.LINE_DELETE(LL_LINE4); -- удаляем техническую строку на четвертой странице
      PRSG_EXCEL.LINE_DELETE(LL_LINE4U);
      PRSG_EXCEL.LINE_DELETE(LL_LINE4B);
    end if;
-------------------------------------------------
    
    /* Карта режимов сушки */
    if nPages >= 4 then -- извращение со сдвигом страниц в конец листа при большом количестве операций МЛ
      sSheetName := 'Лист5';
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet5',
                            sSHEET_NAME_TO     => sSheetName,
                            sSHEET_NAME_BEFORE => null,
                            nMOVE_TO_END       => 1);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);
      PRSG_EXCEL.SHEET_DELETE(C_SLIST5);
    else 
      PRSG_EXCEL.SHEET_SELECT(C_SLIST5); 
    end if;
    nPages := nPages + 1;
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie5);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie5, rec.smatres_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav5);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav5, sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPage5);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage5, nPages);
--08.02.2024
-- select * UDO_FCROUTLSTDR DR where DR.PRN = FCROUTLST.RN 

    /* Пустой лист для четности */
    if (MOD(nPages, 2) != 0) then
      if nPages >= 5 then
        sSheetName := 'Лист6';
        PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet6',
                              sSHEET_NAME_TO     => sSheetName,
                              sSHEET_NAME_BEFORE => null,
                              nMOVE_TO_END       => 1);
        PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);
        PRSG_EXCEL.SHEET_DELETE(C_SLIST6);
      else 
        PRSG_EXCEL.SHEET_SELECT(C_SLIST6);
      end if;
      nPages := nPages + 1;
      PRSG_EXCEL.CELL_DESCRIBE(C_sPage6);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage6, nPages);
    else
      PRSG_EXCEL.SHEET_DELETE(C_SLIST6);
    end if;
    end if;  -- Когда не только Ведомость замечаний

    /* Ведомость замечаний 1 */
    if nPages >= 6 then -- извращение со сдвигом страниц в конец листа при большом количестве операций МЛ
      sSheetName := 'Лист7';
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet7',
                            sSHEET_NAME_TO     => sSheetName,
                            sSHEET_NAME_BEFORE => null,
                            nMOVE_TO_END       => 1);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);
      PRSG_EXCEL.SHEET_DELETE(C_SLIST7);
    else 
      PRSG_EXCEL.SHEET_SELECT(C_SLIST7);
    end if;
    nPages := nPages + 1;
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie7);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie7, rec.smatres_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav7);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav7, sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPage7);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage7, nPages);
    
    /* Ведомость замечаний 2 */
    if nPages >= 7 then -- извращение со сдвигом страниц в конец листа при большом количестве операций МЛ
      sSheetName := 'Лист8';
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet8',
                            sSHEET_NAME_TO     => sSheetName,
                            sSHEET_NAME_BEFORE => null,
                            nMOVE_TO_END       => 1);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);
      PRSG_EXCEL.SHEET_DELETE(C_SLIST8);
    else 
      PRSG_EXCEL.SHEET_SELECT(C_SLIST8);
    end if;
    nPages := nPages + 1;
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie8);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie8, rec.smatres_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav8);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav8, sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPage8);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage8, nPages);

    /* Лист регистрации изменений (две стриницы на одном листе) */
    if nPages >= 8 then -- извращение со сдвигом страниц в конец листа при большом количестве операций МЛ
      sSheetName := 'Лист9';
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet9',
                            sSHEET_NAME_TO     => sSheetName,
                            sSHEET_NAME_BEFORE => null,
                            nMOVE_TO_END       => 1);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);
      PRSG_EXCEL.SHEET_DELETE(C_SLIST9);
    else 
      PRSG_EXCEL.SHEET_SELECT(C_SLIST9);
    end if;
    nPages := nPages + 1;
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie9);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie9, rec.smatres_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav9);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav9, sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPage9);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage9, nPages);
    nPages := nPages + 1;
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie10);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie10, rec.smatres_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav10);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav10, sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPage10);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPage10, nPages);


    PRSG_EXCEL.SHEET_SELECT(C_SLIST1); -- возврат на первую страницу
    PRSG_EXCEL.CELL_DESCRIBE(C_sPages);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPages, nPages);

  end loop;

  PRSG_EXCEL.SHEET_DELETE(C_SLIST2_0);
  PRSG_EXCEL.SHEET_DELETE(C_SLIST4_0);
  if 1 = bRemark then
    PRSG_EXCEL.SHEET_DELETE(C_SLIST1);
    PRSG_EXCEL.SHEET_DELETE(C_SLIST2);
    PRSG_EXCEL.SHEET_DELETE(C_SLIST3);
    PRSG_EXCEL.SHEET_DELETE(C_SLIST4);
    PRSG_EXCEL.SHEET_DELETE(C_SLIST5);
    PRSG_EXCEL.SHEET_DELETE(C_SLIST6);
    PRSG_EXCEL.SHEET_DELETE(C_SLIST9);
  end if;

/*  if nPP < nMaxRows1 then
    PRSG_EXCEL.SHEET_DELETE(C_SLIST2);
  end if;*/
  
  /* Марков МВ. контроль печати техпаспорта */
  if utilizer not in ('KHOK', 'CITK_MARKOV', 'STEPANOV_MV', 'FANOV_VA') then
    for rpr in(
      select SER.RN from SELECTLIST SL, FCROUTLSTSERNUMB SER where SL.IDENT = nIDENT and SL.DOCUMENT = SER.RN
    ) loop
      if nvl(bRemark, 0) > 0 then -- Только Ведомость замечаний
        insert into UDO_FCROUTLSTSERNUMB_STATE(RN, PRN, STATE, STATE_DATE, AUTHID)
        values(gen_id, rpr.rn, 95, sysdate, utilizer);
      else
        if nvl(bBarcode, 0) > 0 then
          insert into UDO_FCROUTLSTSERNUMB_STATE(RN, PRN, STATE, STATE_DATE, AUTHID)
          values(gen_id, rpr.rn, 98, sysdate, utilizer);
        else
          insert into UDO_FCROUTLSTSERNUMB_STATE(RN, PRN, STATE, STATE_DATE, AUTHID)
          values(gen_id, rpr.rn, 99, sysdate, utilizer);
        end if;
      end if;
    end loop;
  end if;

end UDO_REP_FCROUTLST_PASPORT;
/
