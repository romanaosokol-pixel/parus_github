create or replace procedure UDO_REP_PAYACCIN_CHANGE_STATUS(
       nIdent     in number,   -- Выбранная строка
       nCOMPANY   in number,   -- Организация
       sRazd      in varchar2, -- Раздел из которого запускается отчет
       sIspol     in varchar2, -- Исполнитель
       sContr     in varchar2, -- Контрагент или null
       sStatus    in varchar2, -- Установленный статус
       sPeriod    in varchar2  -- Период отчета
) is
 -- Отчет о счетах согласованных пользователем за период времени.
 ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';

  C_nPP      constant PKG_STD.TSTRING := 'nPP';
  C_dPAY     constant PKG_STD.TSTRING := 'dPAY_DATE';
  C_sDog               constant PKG_STD.TSTRING := 's_Dog';
  C_sAccount           constant PKG_STD.TSTRING := 'sAccount';
  C_sPlat              constant PKG_STD.TSTRING := 'sPlat';
  C_dDateSogl          constant PKG_STD.TSTRING := 'Date_Sogl';
  C_sAGENT             constant PKG_STD.TSTRING := 'sAGENT';
  C_nSUM               constant PKG_STD.TSTRING := 'nSUM';
  C_sComment           constant PKG_STD.TSTRING := 'sComment';
  C_sStatus            constant PKG_STD.TSTRING := 'sStatus';
  C_sInfo              constant PKG_STD.TSTRING := 's_Info';
    
  C_sTitle   constant PKG_STD.TSTRING := 'sTitle';
  C_sContr   constant PKG_STD.TSTRING := 'sContr';
  C_HStatus  constant PKG_STD.TSTRING := 'H_Status';
  C_sDate    constant PKG_STD.TSTRING := 'S_Date';
  C_sPeriod  constant PKG_STD.TSTRING := 'S_Period';
  
  nSTR        number;
  nPP         number := 0;
  dStart      date := '01-JAN-' || to_char(sysdate,'YYYY'); -- по умолчанию смотрим за текущий год
  dEnd        date := '31-DEC-' || to_char(sysdate,'YYYY');
  sIncome     varchar2(256) := '';
  --nPayCRN     number(17,0) := 0;
  sPayDate    varchar2(32) := '';
  sPayArt     varchar2(32) := '';
  sUser       varchar2(128) := '';
  nColor      number(4) := 2;
  
  nEVENT           number(17,0);
  nEVENT_TYPE      number(17,0);
  sEVENT           varchar2(64);
  sEVENT_TYPE      varchar2(32);
  nEVENT_STAT      number(17,0);
  sEVENT_STAT      varchar(32) := '';
  sINIT_PERSON     varchar2(64);
  sCLIENT_CLIENT   varchar2(64);
  sCLIENT_PERSON   varchar2(64);
  sSEND_PERSON     varchar2(64);
  sSEND_USER_NAME  varchar2(64);
  nPOINT           number;
      
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  PRSG_EXCEL.CELL_DESCRIBE(C_sTitle);
  PRSG_EXCEL.CELL_DESCRIBE(C_sContr);
  PRSG_EXCEL.CELL_DESCRIBE(C_HStatus);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPeriod);

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPAY);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAccount);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDog);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPlat);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dDateSogl);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sComment);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sStatus);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sInfo);

  if (sPeriod is not NULL) then
    if (instr(sPeriod, ';') = 0) then
--      P_ENPERIOD_BY_APERIOD
      select enp.startdate, enp.enddate into dStart, dEnd from ENPERIOD enp where enp.code = sPeriod; --enp.RN = nPeriod;
    else p_exception(0,'Множественные интервалы "' || sPeriod || '" недопустимы. Пожалуйста, выберите только один интервал.');
    end if;
  end if;

--p_exception(0,instr(sPeriod, ';') || ': sContr ' || sContr || '; sPeriod ' || sPeriod || '; dStart ' || dStart || '; dEnd ' || dEnd);
  if (sContr is not NULL) then
       PRSG_EXCEL.CELL_VALUE_WRITE(C_sContr, 'По контрагенту "' || sContr || '"');
  else PRSG_EXCEL.CELL_VALUE_WRITE(C_sContr, ' ');
  end if;

  PRSG_EXCEL.CELL_VALUE_WRITE(C_HStatus, 'По статусу:  ' || sStatus);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sPeriod, 'За период с  ' || to_char(dStart, 'DD.MM.YYYY') ||  ' по ' || to_char(dEnd, 'DD.MM.YYYY'));
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));

  if ('PaymentAccountsIn' = sRazd) then
    FIND_USERLIST_BY_AUTHID(nFLAG_SMART => 0, sAUTHID => sIspol, sNAME => sUser);
--p_exception(0,'Исполнитель: ' || sIspol || ' Сотрудник: '|| sUser|| ' Статус: '|| sStatus);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sTitle, 'Реестр счетов согласованных ' || sUser);  

    for rec in(
      select hist.dchange_date, UDO_F_PAYACCIN_FACEACC_ARTICLE(vpay.nrn) sPayArt, vpay.*--, ev.*, hist.*
        from V_CLNEVNHIST hist, CLNEVENTS ev, V_PAYACCIN vpay
       where hist.nCOMPANY = 90521 and hist.sauthid = sIspol --'SAVINKOV_II' 
         and hist.dchange_date between dStart and dEnd
         and hist.sevent_stat = sStatus
         and hist.nprn = ev.rn
         and ev.linked_unit = 'PaymentAccountsIn' and ev.linked_rn = vpay.nrn
         and (vpay.ssupplier = sContr or sContr is NULL)
       order by vpay.ssupplier, vpay.sext_numb, vpay.nsummwithnds
    ) loop
    
      -- Смотрим наличие фактического платежа
      begin
       select to_char(vpay.pay_date, 'DD.MM.YYYY') into sPayDate
         from PAYNOTES vpay where COMPANY=NCOMPANY and vpay.signplan = 0 
          and vpay.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT= rec.nrn and SIN_UNITCODE='PaymentAccountsIn' and SUNITCODE='PayNotes')
          and ROWNUM = 1
          order by pay_date asc;
      exception 
       when NO_DATA_FOUND then
         sPayDate := '-';
      end;

      -- Текущий статус счета
      P_UNITSTMOD_GET_EVENT(sUNITCODE   => 'PaymentAccountsIn',
                        nDOCUMENT       => rec.nrn,
                        nEVENT          => nEVENT,
                        nEVENT_TYPE     => nEVENT_TYPE,
                        sEVENT          => sEVENT,
                        sEVENT_TYPE     => sEVENT_TYPE,
                        nEVENT_STAT     => nEVENT_STAT,
                        sEVENT_STAT     => sEVENT_STAT,
                        sINIT_PERSON    => sINIT_PERSON,
                        sCLIENT_CLIENT  => sCLIENT_CLIENT,
                        sCLIENT_PERSON  => sCLIENT_PERSON,
                        sSEND_PERSON    => sSEND_PERSON,
                        sSEND_USER_NAME => sSEND_USER_NAME,
                        nPOINT => nPOINT);
        
      if    sEVENT_STAT = 'Отработан'       then nColor := 43;   -- зеленый -- EVENT_STAT: 7195939
      elsif sEVENT_STAT = 'ИнформЗаказчика' then nColor := 8;
      else  --sEVENT_STAT := substr(sSEND_PERSON, 1, instr(sSEND_PERSON, '#')-1); 
            nColor := 2; -- белый
      end if;
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_sStatus,
                                 sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                 sATTRIBUTE_VALUE => nColor);    
      
      if '-' = sPayDate -- Неоплачено
      then nColor := 6; -- желтый
      else nColor := 2; -- белый
      end if;
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_dPAY,
                                 sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                 sATTRIBUTE_VALUE => nColor); 
	    -- Дополнительная информация
      begin
      select listagg(trim(inv.sdoctype)||', '||trim(inv.spref)||'-'||trim(inv.snumb)||', '||to_char(inv.ddoc_date, 'DD.MM.YYYY'), '; ') 
             within group (order by vpay.rn) into sIncome
        from PAYACCIN vpay, V_ININVOICES inv
       where vpay.rn = rec.nrn
         and inv.nrn in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT 
                          where NIN_DOCUMENT=vpay.rn and SIN_UNITCODE='PaymentAccountsIn' and SUNITCODE='IncomingInvoices');
      exception
         when NO_DATA_FOUND then
           sIncome := '';
      end;
                                             
      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      nPP := nPP + 1;  
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nPP);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY,      0, nSTR, sPayDate); --rec.dbank_date);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,    0, nSTR, rec.ssupplier);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,      0, nSTR, rec.svdoc_type || ' ' || rec.svdoc_num);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlat,     0, nSTR, rec.sext_numb); --trim(rec.sfrom_doctype)||'-'||trim(rec.sfrom_numb)||', '||to_char(rec.dfrom_date, 'DD.MM.YYYY'));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dDateSogl, 0, nSTR, to_char(rec.dchange_date,'DD.MM.YYYY HH:MM:SS'));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM,      0, nSTR, rec.nsummwithnds);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAccount,  0, nSTR, rec.sPayArt); --rec.pay_art);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sComment,  0, nSTR, rec.scomments);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStatus,   0, nSTR, sEVENT_STAT); -- Статус счета
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sInfo,     0, nSTR, sIncome); -- Дополнительная информация
        
    end loop;

  else
     p_exception(0,'Неверный раздел' || sRazd);
  end if;  
  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_LINE);
    
end UDO_REP_PAYACCIN_CHANGE_STATUS;
/

