create or replace procedure UDO_P_REP_INCOMING_PAYS(
       nIdent     in number,   -- Выбранная строка
       nCOMPANY   in number,   -- Организация
       sRazd      in varchar2, -- Раздел из которого запускается отчет
       sContr     in varchar2, -- Контрагент или null
       sPeriod    in varchar2  -- Период отчета
)
is
 -- Отчет Журнал входящих счетов на оплату за период
 ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
   
  C_nPP                constant PKG_STD.TSTRING := 'nPP';
  C_dPAY_DATE          constant PKG_STD.TSTRING := 'dPAY_DATE';
  C_sBank              constant PKG_STD.TSTRING := 'sBank';
  C_sDog               constant PKG_STD.TSTRING := 's_Dog';
  C_sAccount           constant PKG_STD.TSTRING := 'sAccount';
  C_sPlat              constant PKG_STD.TSTRING := 'sPlat';
  C_dPlatDate          constant PKG_STD.TSTRING := 'dPlatDate';
  C_sAGENT             constant PKG_STD.TSTRING := 'sAGENT';
  C_nSUM               constant PKG_STD.TSTRING := 'nSUM';
  C_sComment           constant PKG_STD.TSTRING := 'sComment';
  C_sStatus            constant PKG_STD.TSTRING := 'sStatus';
  C_sOtv               constant PKG_STD.TSTRING := 'sOtv';
  C_sInfo              constant PKG_STD.TSTRING := 's_Info';

  C_sTitle             constant PKG_STD.TSTRING := 'sTitle';
  C_sContr             constant PKG_STD.TSTRING := 'sContr';
  C_sDate              constant PKG_STD.TSTRING := 'S_Date';
  C_sPeriod            constant PKG_STD.TSTRING := 'S_Period';
  
  nSTR        number;
  nPP         number := 1;
  dStart      date := '01-JAN-' || to_char(sysdate,'YYYY'); -- по умолчанию смотрим за текущий год
  dEnd        date := '31-DEC-' || to_char(sysdate,'YYYY');
  sIncome     PAYACCIN.Comments%type := '';
  nPayCRN     number(17,0) := 0;
  nPaySum     number(17,2) := 0;
  sPayDate    varchar2(32) := '';
  sPayArt     varchar2(32) := '';
  sDocNum     varchar2(128) := '';
  nColor      number(4) := 2;
  
  sEVENT_STAT      varchar(32);
  sSEND_PERSON     varchar2(256);
/*  nEVENT           number(17,0);
  nEVENT_TYPE      number(17,0);
  sEVENT           varchar2(64);
  sEVENT_TYPE      varchar2(32);
  nEVENT_STAT      number(17,0);
  sINIT_PERSON     varchar2(256);
  sCLIENT_CLIENT   varchar2(256);
  sCLIENT_PERSON   varchar2(256);
  sSEND_USER_NAME  varchar2(256);
  nPOINT           number;*/
  
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  PRSG_EXCEL.CELL_DESCRIBE(C_sTitle);
  PRSG_EXCEL.CELL_DESCRIBE(C_sContr);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPeriod);

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPAY_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sBank);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAccount);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDog);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPlat);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPlatDate);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sComment);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sStatus);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sOtv);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sInfo);

--p_exception(0,'sRazd ' || sRazd); -- BankDocuments or PaymentAccountsIn
--p_exception(0,instr(sPeriod, ';') || ': sContr ' || sContr || '; sPeriod ' || sPeriod || '; dStart ' || dStart || '; dEnd ' || dEnd);

  if (sContr is not NULL) then
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sContr, 'По контрагенту "' || sContr || '"');
/*    FIND_AGNLIST_CODE(nFLAG_SMART  => 1,
                      nFLAG_OPTION => 0,
                      nCOMPANY     => nCOMPANY,
                      sCODE        => sContr,
                      nRN          => nContrRN);*/
  else
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sContr, ' ');
  end if;

  if (sPeriod is not NULL) then
    if (instr(sPeriod, ';') = 0) then
      select enp.startdate, enp.enddate into dStart, dEnd from ENPERIOD enp where enp.code = sPeriod; --enp.RN = nPeriod;
    else p_exception(0,'Множественные интервалы "' || sPeriod || '" недопустимы. Пожалуйста, выберите только один интервал.');
    end if;
  end if;

  PRSG_EXCEL.CELL_VALUE_WRITE(C_sPeriod, 'За период с  ' || to_char(dStart, 'DD.MM.YYYY') ||  ' по ' || to_char(dEnd, 'DD.MM.YYYY'));
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));

  if (sRazd = 'BankDocuments') then
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sTitle, 'Реестр счетов по банковским документам');

    for rec in(
      select UDO_F_PAYNOTES_ARTICLE(pn.RN) pay_art, pn.pay_date, 
             ba.bank_docdate, ba.agent_to_bankname, --agent_to_bankacc); --
             ba.sfrom_doctype, ba.sfrom_numb, ba.dfrom_date, 
             ba.agent_from, ba.agent_to, ba.pay_sum, ba.pay_info--, acc.agnacc
             , ba.rn, pn.rn pn_rn
             --case when acc.bankacc_type = 1080004 then 'ОБС ' when acc.bankacc_type = 6525523 then 'УФК ' else 'р/с ' end acc_type --р/с:535778
        from /*SELECTLIST sl, */V_BANKDOCS ba, PayNotes pn --, AGNACC acc
       where --sl.ident = nIdent and sl.document = ba.rn and 
             ba.COMPANY = NCOMPANY 
         and pn.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT = ba.rn and SIN_UNITCODE='BankDocuments' and SUNITCODE='PayNotes' )
         and ba.BANK_DOCDATE >= dStart --TO_DATE('01/01/2022','dd/mm/yyyy')  
         and ba.BANK_DOCDATE <= dEnd   --TO_DATE('31/12/2022','dd/mm/yyyy') 
         and (ba.agent_to = sContr or sContr is NULL)
         and ba.CRN in (select RN from ACATALOG connect by prior RN = CRN start with RN = '6260096') -- Расход
         --and ba.CRN in (select RN from ACATALOG connect by prior RN = CRN start with RN = '6260055') -- Приход
         --and acc.rn = ba.agent_to_acc_rn
       order by ba.bank_docdate, ba.bank_doctype, ba.sfrom_numb --, ba.agent_from
    ) loop
--p_exception(0,'rec.pn_rn ' || rec.pn_rn);
                          
        begin
          select m.scomments, m.svdoc_num,
                (select sEVENT_STAT from V_CLNEVENTS_STATMOD where sLINKED_UNIT = 'PaymentAccountsIn' and nLINKED_RN = nRN),
                (select sEXECUTER   from V_CLNEVENTS_STATMOD where sLINKED_UNIT = 'PaymentAccountsIn' and nLINKED_RN = nRN)
          into sIncome, sDocNum, sEVENT_STAT, sSEND_PERSON
          from V_PAYACCIN M where nCOMPANY=90521 and 
               M.nRN in (select NDOCUMENT from V_DOCLINKS_INOUT_OUT_EXT where NOUT_DOCUMENT = rec.pn_rn /*(select pn.rn from PAYNOTES pn
      where rownum = 1 and COMPANY=90521 
        and pn.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT=rec.rn and SIN_UNITCODE='BankDocuments' and SUNITCODE='PayNotes'))*/ 
           and SOUT_UNITCODE='PayNotes' and SUNITCODE='PaymentAccountsIn');                          
        exception 
          when NO_DATA_FOUND then
            sIncome := '-'; sEVENT_STAT := '';
        end;

        if    sEVENT_STAT = 'Отработан' then nColor := 43;   -- зеленый -- EVENT_STAT: 7195939
        elsif sEVENT_STAT = 'ИнформЗаказчика' then nColor := 8;
        else  nColor := 2; -- белый /*sEVENT_STAT := substr(sSEND_PERSON, 1, instr(sSEND_PERSON, '#')-1);*/
        end if;
        PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_sStatus,
                                   sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                   sATTRIBUTE_VALUE => nColor);

        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nPP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE, 0, nSTR, rec.bank_docdate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,    0, nSTR, rec.agent_to);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,      0, nSTR, sDocNum);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlat,     0, nSTR, trim(rec.sfrom_doctype)||'-'||trim(rec.sfrom_numb)||', '||to_char(rec.dfrom_date, 'DD.MM.YYYY'));
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_dPlatDate, 0, nSTR, rec.dfrom_date);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM,      0, nSTR, rec.pay_sum);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sAccount,  0, nSTR, rec.pay_art); --rec.acc_type || rec.agnacc);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sComment,  0, nSTR, rec.pay_info);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sStatus,   0, nSTR, sEVENT_STAT); -- Статус счета
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sOtv,      0, nSTR, substr(sSEND_PERSON, 1, instr(sSEND_PERSON, '#')-1)); -- Ответственный
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sInfo,     0, nSTR, /*rec.add_info ||'. '||*/ sIncome); -- Дополнительная информация
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sBank,     0, nSTR, rec.agent_to_bankname);

        nPP := nPP + 1;  
          
    end loop;

  else
    
    select pay.crn, cat.name into nPayCRN, sDocNum
      from SELECTLIST sl, PAYACCIN pay, ACATALOG cat
     where sl.ident = nIdent and sl.document = pay.rn and cat.rn = pay.crn
       and ROWNUM = 1;
--p_exception(0,' nCOMPANY ' || nCOMPANY || '; nPayCRN ' || nPayCRN);
    if ('Служба ГИ' = sDocNum) then
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sTitle, 'Реестр счетов СГИ, Соловьева Надежда Александровна (тел.416)');
    else PRSG_EXCEL.CELL_VALUE_WRITE(C_sTitle, 'Реестр счетов ' || sDocNum);
    end if;

    for rec in(
      select fa.rn fa_rn, UDO_F_FACEACC_ARTICLE(pay.nfaceacc) pay_art, --UDO_F_PAYACCIN_FACEACC_ARTICLE(pay.nrn) pay_art,
             --pay.ddoc_date, pay.ssupplier, pay.sdoc_numb, pay.ddoc_date, pay.sext_numb, pay.nsummwithnds, pay.scomments,
             case
               when pay.nfactpaysumm > 0 then 'Оплачено'
               else '---'
             end add_info,
             pay.nsummwithnds*pay.ncurbase as nSummPayed,
             (select sEXECUTER from V_CLNEVENTS_STATMOD where sLINKED_UNIT = 'PaymentAccountsIn' and nLINKED_RN = pay.nrn) sSEND_PERSON,
             pay.* --pay.svdoc_num
        from V_PAYACCIN pay, /*PayNotes pn,*/ FACEACC fc, FPDARTCL fa
       where pay.ncompany = NCOMPANY
         and pay.ndoc_state != 2 -- Кроме аннулированных
         --and pn.signplan = 1     -- Смотрим только данные плановых платежей
         --and pn.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT=pay.nrn and SIN_UNITCODE='PaymentAccountsIn' and SUNITCODE='PayNotes')  
         /*and pay.ddoc_date >= dStart --TO_DATE('01/01/2022','dd/mm/yyyy')  
         and pay.ddoc_date <= dEnd  */
         and pay.dreg_date >= dStart 
         and pay.dreg_date <= dEnd   
         and (pay.ssupplier = sContr or sContr is NULL)
         and pay.NCRN in (select RN from ACATALOG connect by prior RN = CRN start with RN = nPayCRN) -- Служба ГИ???
         and FC.rn = pay.nfaceacc
         and FC.IEELEMENT = FA.RN         
       order by pay.ssupplier, pay.ddoc_date, trim(pay.sdoc_numb)
    ) loop
/*        P_UNITSTMOD_GET_EVENT(sUNITCODE   => 'PaymentAccountsIn',
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
                          nPOINT => nPOINT);*/

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
      -- Считаем сумму фактических платежей
      begin
       select sum(vpay.pay_sum) into nPaySum
         from PAYNOTES vpay where COMPANY=NCOMPANY and vpay.signplan = 0 
          and vpay.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT= rec.nrn and SIN_UNITCODE='PaymentAccountsIn' and SUNITCODE='PayNotes');
      exception 
       when NO_DATA_FOUND then
         nPaySum := 0;
      end;
            
      -- Смотрим номер статьи расхода
      begin
        select substr(fca.art_numb, 3) into sPayArt from UDO_T_FINPLAN_CONF_ARTS fca 
        where fca.fpdartcl = rec.fa_rn
          and ROWNUM = 1;
      exception 
       when NO_DATA_FOUND then
         sPayArt := '-';
      end;
        
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

      if    sEVENT_STAT = 'Отработан'       then nColor := 43;   -- зеленый -- EVENT_STAT: 7195939
      elsif sEVENT_STAT = 'ИнформЗаказчика' then nColor := 8;
      else  --sEVENT_STAT := substr(sSEND_PERSON, 1, instr(sSEND_PERSON, '#')-1); 
            nColor := 2; -- белый
      end if;
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_sStatus,
                                 sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                 sATTRIBUTE_VALUE => nColor);    
      
      if '-' = sPayDate or rec.nSummPayed > nPaySum -- Неоплачено или частично  != nsummwithnds ???
      then nColor := 6; -- желтый
      else nColor := 2; -- белый
      end if;
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME    => C_dPAY_DATE,
                                 sATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                 sATTRIBUTE_VALUE => nColor); 
                                      
      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nPP);
      if rec.nSummPayed > nPaySum then -- Оплачено частично != nsummwithnds ???
           PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE, 0, nSTR, sPayDate || ' Частично ' || nPaySum);
      elsif rec.ncurrency != 91318 then
           PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE, 0, nSTR, sPayDate || ' в рублях ' || TO_CHAR(nPaySum, '999G999G999D99'));
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE, 0, nSTR, sPayDate);
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,    0, nSTR, rec.ssupplier);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,      0, nSTR, rec.svdoc_num);
--      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlat,     0, nSTR, 'ПП-'||trim(rec.sdoc_numb)||', '||to_char(rec.ddoc_date, 'DD.MM.YYYY')||' ('||rec.sext_numb||')');
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlat,     0, nSTR, to_char(rec.ddoc_date, 'DD.MM.YYYY')||' ('||rec.sext_numb||')');
      --PRSG_EXCEL.CELL_VALUE_WRITE(C_dPlatDate, 0, nSTR, rec.dfrom_date);
      if rec.ncurrency != 91318 then
           PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM, 0, nSTR, TO_CHAR(rec.nsummwithnds, '999G999G999D99') || ' ' || rec.scurrency);
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM, 0, nSTR, rec.nsummwithnds);
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAccount,  0, nSTR, sPayArt); --rec.pay_art);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sComment,  0, nSTR, rec.scomments);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStatus,   0, nSTR, sEVENT_STAT); -- Статус счета
      if instr(rec.sSEND_PERSON, '#') > 0 then  -- Ответственный
           PRSG_EXCEL.CELL_VALUE_WRITE(C_sOtv, 0, nSTR, substr(rec.sSEND_PERSON, 1, instr(rec.sSEND_PERSON, '#')-1));
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_sOtv, 0, nSTR, substr(rec.sSEND_PERSON, 0, instr(rec.sSEND_PERSON, ' ')-1) || 
                                                        substr(rec.sSEND_PERSON, instr(rec.sSEND_PERSON, ' '), 2) || '.' ||
                                                        substr(rec.sSEND_PERSON, instr(rec.sSEND_PERSON, ' ', -1)+1, 1) || '.');
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sInfo,     0, nSTR, /*rec.add_info ||'. '||*/ sIncome); -- Дополнительная информация
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sBank,     0, nSTR, ''); --rec.agent_to_bankname);

      nPP := nPP + 1;  
          
    end loop;

  end if;
  
  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_LINE);
  
end UDO_P_REP_INCOMING_PAYS;
/

