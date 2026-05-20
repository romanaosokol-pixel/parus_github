create or replace procedure UDO_PR_PAYTOOL_CALC(
       nCOMPANY    in number,  -- Организация
       nIDENT      in numeric, -- Выбранные записи
       dCALC_DATE  in date    -- Дата на которую проводится расчет
) 
is
-- Сокращенная версия процедуры отчета "Остатки по своим счетам" UDO_P_ACCOUNT_BALANCE
-- В таблицу заносится не введенная Дата, а на 1 день меньше. Принимаем, что это остатки на конец дня.
  --nCOMPANY  number(17,0) := 90521;
  nJUR_PERS number(17,0) := 92147; -- Модуль
  nCurrency number(17,0) := 91318; -- RUB
  nNewRN    number(17,0);
  nRNTMP     FNCSREMN%rowtype;

  sStartDate varchar2(16) := '01-JAN-2021'; -- Имеем посчитанные остатки на 01.01.2021 и считаем дальше
  --nStartSum  number(17,2) := 0;       -- Остатки на 01.01.2021
  nStartDeb  number(17,2) := 0;       -- Дебет с 01.01.2021 до Начальной даты-1
  nStartCred number(17,2) := 0;       -- Кредит с 01.01.2021 до Начальной даты-1

begin

  sStartDate := '01-JAN-' || to_char(sysdate,'YYYY');
--p_exception(0,'nIDENT ' || nIDENT || '; dCALC_DATE ' || dCALC_DATE || '; sStartDate ' || sStartDate);

  for rec in (
    select fin.rn tool_rn, nvl(fin.currency, 91318) currency, fin.payer_acc acc_rn,-- dic.doc_rn, 
           anl.analytic1, nvl(anl.acnt_remn_sum, 0) acnt_remn_sum
      from FINPAYTOOL fin, DICANLS dic, ANLREMNS anl, selectlist sl
     where sl.ident = nIDENT
       and sl.document = fin.RN
       and fin.payer_acc = dic.doc_rn and dic.rn = anl.analytic1
       and anl.remn_date = sStartDate
     union -- Может не быть Аналитики !!!
    select fin.rn tool_rn, nvl(fin.currency, 91318) currency, fin.payer_acc acc_rn,-- dic.doc_rn, 
           NULL as analytic1, 0 as acnt_remn_sum --anl.analytic1, anl.acnt_remn_sum
      from FINPAYTOOL fin, DICANLS dic, ANLREMNS anl, selectlist sl
     where sl.ident = nIDENT
       and sl.document = fin.RN
       and dic.doc_rn (+)= fin.payer_acc  and anl.analytic1 (+)= dic.rn
       and anl.remn_date is null       
  ) loop
--p_exception(0,'fin.rn: ' || rec.tool_rn || '; fin.payer_acc:  ' || rec.acc_rn);

      begin  -- Дебет с даты подсчета остатков
        select sum(bank.pay_sum) into nStartDeb from BANKDOCS bank 
        where bank.agent_to_acc = rec.acc_rn and bank.bank_docdate between sStartDate and dCALC_DATE-1 -- от '01-JAN-2021'
        group by bank.agent_to_acc;
      exception when NO_DATA_FOUND then
        nStartDeb := 0;
      end;

      begin  -- Кредит с даты подсчета остатков
        select sum(bank.pay_sum) into nStartCred from BANKDOCS bank
        where bank.agent_from_acc = rec.acc_rn and bank.bank_docdate between sStartDate and dCALC_DATE-1 -- от '01-JAN-2021'
        group by bank.agent_from_acc;
      exception when NO_DATA_FOUND then
        nStartCred := 0;
      end;

--p_exception(0,'acnt_remn_sum: ' || rec.acnt_remn_sum || '; nStartDeb: ' || nStartDeb || '; nStartCred: ' || nStartCred); 
    begin
      select fnc.* into nRNTMP from FNCSREMN fnc
       where fnc.finpaytool = rec.tool_rn 
         and fnc.jur_pers = nJUR_PERS and COMPANY = nCOMPANY 
         --and to_char(fnc.remn_date, 'DD-MM-YYYY') = to_char(dCALC_DATE,'DD-MM-YYYY')
         and ROWNUM = 1 -- нужна только запись на последнюю дату
      order by fnc.remn_date DESC;
     exception
       when NO_DATA_FOUND then
         nRNTMP.RN := null;
    end;
    
    if (rec.currency is null or '' = rec.currency) then
      nCurrency := 91318; -- RUB
    else nCurrency := rec.currency;
    end if;

    if nRNTMP.RN is null then
      --if (rec.acnt_remn_sum + nStartDeb - nStartCred != 0) then Тут заносим данные, если даже они нулевые
  --p_exception(0,'Exist: tool_rn: ' || rec.tool_rn || '; nJUR_PERS: ' || nJUR_PERS || '; dCALC_DATE: ' || dCALC_DATE); 
        /* фиксация начала выполнения действия */
        PKG_ENV.PROLOGUE(nCOMPANY, null, null, nJUR_PERS, 'FinancialCashRemnants', 'FNCSREMN_INSERT', 'FNCSREMN');

        /* базовое добавление */
        P_FNCSREMN_BASE_INSERT(nCOMPANY    => nCOMPANY,
                               nJUR_PERS   => nJUR_PERS,
                               nFINPAYTOOL => rec.tool_rn,
                               dREMN_DATE  => dCALC_DATE-1,
                               nCURRENCY   => nCurrency,
                               nREMN_SUM   => rec.acnt_remn_sum + nStartDeb - nStartCred,
                               nRN         => nNewRN);

        /* фиксация окончания выполнения действия */
        PKG_ENV.EPILOGUE(nCOMPANY, null, null, nJUR_PERS, 'FinancialCashRemnants', 'FNCSREMN_INSERT', 'FNCSREMN', nNewRN);
      --end if;
    else
      if (nRNTMP.Remn_Sum != 0 or rec.acnt_remn_sum + nStartDeb - nStartCred != 0) then
        --p_exception(0,'Exist: tool_rn: ' || rec.tool_rn || '; nJUR_PERS: ' || nJUR_PERS || '; dCALC_DATE: ' || dCALC_DATE); 
        /* фиксация начала выполнения действия */
        PKG_ENV.PROLOGUE(nCOMPANY, null, null, nRNTMP.Jur_Pers, 'FinancialCashRemnants', 'FNCSREMN_UPDATE', 'FNCSREMN', nRNTMP.Rn);

        /* базовое исправление */
        P_FNCSREMN_BASE_UPDATE(nCOMPANY    => nRNTMP.Company,
                               nRN         => nRNTMP.Rn,
                               nJUR_PERS   => nRNTMP.Jur_Pers,
                               nFINPAYTOOL => nRNTMP.Finpaytool,
                               dREMN_DATE  => dCALC_DATE-1,
                               nCURRENCY   => nRNTMP.Currency,
                               nREMN_SUM   => rec.acnt_remn_sum + nStartDeb - nStartCred);

        /* фиксация окончания выполнения действия */
        PKG_ENV.EPILOGUE(nCOMPANY, null, null, nRNTMP.Jur_Pers, 'FinancialCashRemnants', 'FNCSREMN_UPDATE', 'FNCSREMN', nRNTMP.Rn);
      end if;
    end if;
  end loop;
end UDO_PR_PAYTOOL_CALC;
/

