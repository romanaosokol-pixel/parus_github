create or replace procedure UDO_REP_SEPACCOP(
       nCOMPANY   in number,   -- Организация
       sRazd      in varchar2, -- Раздел из которого запускается отчет
       sPeriod    in varchar2, -- Период отчета
       nMln       in integer   -- Смотреть только 3 миллиона
) is
 -- Отчет траты по Отдельному счету за период
 ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  L_lStrBank constant PKG_STD.TSTRING := 'BankLine'; -- Строка названия банка
  L_lStr     constant PKG_STD.TSTRING := 'Stroka';   -- Строки данных
  L_lStrI    constant PKG_STD.TSTRING := 'Itog';     -- Строка Всего

  L_lColS    constant PKG_STD.TSTRING := 'SepCol';   -- Колонка Отдельный счет

  C_sBank    constant PKG_STD.TSTRING := 'BankStart';
  C_sKod     constant PKG_STD.TSTRING := 'Kod';
  C_sSchet   constant PKG_STD.TSTRING := 'Schet';
  C_sIGK     constant PKG_STD.TSTRING := 'IGK';
  C_sDog     constant PKG_STD.TSTRING := 'sDog';
  C_sClient  constant PKG_STD.TSTRING := 'sClient';
  C_nOstatok constant PKG_STD.TSTRING := 'nRest';
  C_nCredit  constant PKG_STD.TSTRING := 'Credit';
  C_nPlan    constant PKG_STD.TSTRING := 'Plan';
  C_nRest    constant PKG_STD.TSTRING := 'PayRest';
  C_sSepAcc  constant PKG_STD.TSTRING := 'SepAcc';

  C_sDate    constant PKG_STD.TSTRING := 'Date';
  C_sPeriod  constant PKG_STD.TSTRING := 'S_Period';

  nSTR       number(17) := 1;
  dStart      date := '01-JAN-' || to_char(sysdate,'YYYY'); -- по умолчанию смотрим за текущий год
  dEnd        date := '31-DEC-' || to_char(sysdate,'YYYY');
  nCredit    number(17,2) := 0;       -- Банковские документы за период
  nPlan      number(17,2) := 0;       -- Входящие счета на оплату по расчетному счету
  --nSepacc    BANKDOCS.Sepaccop%type;
  nBank      number := 0;
    
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPeriod);

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrI);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrBank);

  PRSG_EXCEL.COLUMN_DESCRIBE(L_lColS);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrBank, C_sBank);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sKod);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sSchet);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sIGK);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDog);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sClient);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nOstatok);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nCredit);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPlan);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nRest);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sSepAcc);
  
  if (sPeriod is not NULL) then
    if (instr(sPeriod, ';') = 0) then
      select enp.startdate, enp.enddate into dStart, dEnd from ENPERIOD enp where enp.code = sPeriod;
    else p_exception(0,'Множественные интервалы "' || sPeriod || '" недопустимы. Пожалуйста, выберите только один интервал.');
    end if;
  end if;

  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sPeriod, 'За период с  ' || to_char(dStart, 'DD.MM.YYYY') ||  ' по ' || to_char(dEnd, 'DD.MM.YYYY'));

  For rec in (
    select acc.rn acc_rn, acc.agnacc, acc.strcode, acc.agnbanks, acc.bankacc_type,
           GET_AGNACC_GOVCNTRID(acc.rn) sGovID, ag.agnabbr,-- acc.treas_agnacc,
           --,UDO_F_AGENTACC_DOGNUMB(acc.RN) sDog
           UDO_F_AGENTACC_BALANCE(acc.RN) nSum,
           cn.ext_number, ag_co.agnname
     from AGNACC acc, AGNBANKS bank, AGNLIST ag,
          CONTRACTS     cn,
          GOVCNTRIDBANKS  gb,
          AGNLIST ag_co
    where acc.AGNRN = 92146 -- RN "Модуль" в AGNLIST
      and acc.bankacc_type = 1080004 -- Специальный
      and acc.AGNBANKS = bank.rn
      and bank.agnrn = ag.rn
      and gb.agnacc = cn.JUR_ACC
      and acc.rn    = cn.JUR_ACC
      and cn.company = nCOMPANY 
      and trim(cn.doc_pref) not like '3/%' -- оставляем только основные договоры
      and not exists (select null 
                        from stages          st
                            ,FACEACC         fc
                       where FC.rn = st.faceacc
                         and fc.ACC_KIND = 0
                         and st.prn = cn.rn
                    )
      and ag_co.rn = cn.agent
    union all  -- AGNBANKS может быть NULL !!!
    select acc.rn acc_rn, acc.agnacc, acc.strcode, acc.agnbanks, acc.bankacc_type, 
           GET_AGNACC_GOVCNTRID(acc.rn) sGovID, '!!!' agnabbr,-- acc.treas_agnacc
           --,UDO_F_AGENTACC_DOGNUMB(acc.RN) sDog
           UDO_F_AGENTACC_BALANCE(acc.RN) nSum,
           cn.ext_number, ag_co.agnname
    from AGNACC         acc,
         CONTRACTS      cn,
         GOVCNTRIDBANKS gb,
         AGNLIST        ag_co
    where acc.AGNRN = 92146
      and acc.bankacc_type = 1080004 -- Специальный
      and acc.AGNBANKS is null
      and gb.agnacc = cn.JUR_ACC
      and acc.rn    = cn.JUR_ACC
      and cn.company = nCOMPANY 
      and trim(cn.doc_pref) not like '3/%' -- оставляем только основные договоры
      and not exists (select null 
                        from stages          st
                            ,FACEACC         fc
                       where FC.rn = st.faceacc
                         and fc.ACC_KIND = 0
                         and st.prn = cn.rn
                    )
      and ag_co.rn = cn.agent
    order by agnabbr, strcode
  ) loop
/*    if 0 = nBank or nBank != rec.agnbanks then
      nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStrBank);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sBank, 0, nSTR, rec.agnabbr);
    end if;
    nBank := rec.agnbanks;*/
    if rec.nSum > 0 then
      if 0 = nBank or nBank != rec.agnbanks then
        nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStrBank);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sBank, 0, nSTR, rec.agnabbr);
      end if;
      nBank := rec.agnbanks;
        nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr); -- nSTR := PRSG_EXCEL.LINE_APPEND(L_lStr);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sKod,    0, nSTR, rec.strcode);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSchet,  0, nSTR, rec.agnacc);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sIGK,    0, nSTR, rec.sGovID);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,    0, nSTR, rec.ext_number);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sClient, 0, nSTR, rec.agnname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nOstatok,0, nSTR, rec.nSum);  

    --  begin -- Кредит за период
    For pays in (
        select sum(bank.pay_sum) nCredit, sep.code sSepacc, sep.rn sep_rn --bank.sepaccop nSepacc
          from BANKDOCS bank, SEPACCOP sep 
         where bank.agent_from_acc = rec.acc_rn and bank.bank_docdate between dStart and dEnd
           and (6412933 = sep.rn or 0 = nMln)
           and sep.rn (+)= bank.sepaccop 
         group by bank.agent_from_acc, sep.code, sep.rn
         order by sSepacc
    ) loop

      if pays.nCredit != 0 then
        nPlan := 0;              
        begin
          select sum(pay.summwithnds) into nPlan 
            from PAYACCIN pay 
            where pay.payeracc = rec.acc_rn and pay.doc_state = 1
              and (pay.factpaysumm = 0 or pay.factpaysumm < pay.summwithnds);
        exception when NO_DATA_FOUND then
          nPlan := 0;              
        end;
        
/*        nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr); -- nSTR := PRSG_EXCEL.LINE_APPEND(L_lStr);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sKod,    0, nSTR, rec.strcode);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSchet,  0, nSTR, rec.agnacc);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sIGK,    0, nSTR, rec.sGovID);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,    0, nSTR, rec.ext_number);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sClient, 0, nSTR, rec.agnname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nOstatok,0, nSTR, rec.nSum);*/
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nCredit, 0, nSTR, pays.nCredit);
        if 6412933 = pays.sep_rn then -- В рамках 3 млн
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan, 0, nSTR, nPlan);
        else
          PRSG_EXCEL.CELL_FORMULA_DELETE(C_nRest, 0, nSTR); 
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nRest, 0, nSTR, ' ');
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSepAcc, 0, nSTR, pays.sSepacc);
      end if;

    end loop;
  end if; -- rec.nSum > 0

  end loop;
  --удаляем технические строки
  --PRSG_EXCEL.LINE_DELETE(L_lStrI);
  PRSG_EXCEL.LINE_DELETE(L_lStr);
  PRSG_EXCEL.LINE_DELETE(L_lStrBank);
  
  if (1 = nMln) then -- только 3 миллиона
    PRSG_EXCEL.COLUMN_DELETE(sCOLUMN_NAME => L_lColS, iCOLUMN_INDEX => 0);
  end if;   

end UDO_REP_SEPACCOP;
/

