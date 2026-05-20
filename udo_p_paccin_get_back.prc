create or replace procedure UDO_P_PACCIN_GET_BACK(
    nCOMPANY      in number,
    dDATE_START   in date,  -- Начало периода 
    dDATE_END     in date,  -- Конец периода
    bAll          in number -- Если надо вообще все
) is
-- Отчет по счетам, вернувшимся инициатору.
  nCatalog  USERLIST.CRN%type; -- Подразделение пользователя
  nEVENT           number(17);
  nEVENT_TYPE      number(17);
  sEVENT           varchar2(128);
  sEVENT_TYPE      varchar2(128);
  nEVENT_STAT      number(17);
  sEVENT_STAT      varchar2(256);
  sINIT_PERSON     varchar2(128);
  sCLIENT_CLIENT   varchar2(128);
  sCLIENT_PERSON   varchar2(128);
  sSEND_PERSON     varchar2(128);
  sSEND_USER_NAME  varchar2(128);
  nPOINT           PKG_STD.tREF;

  nSTR         number;
  nPP          number := 0;
  dStart      date := '01-JAN-' || to_char(sysdate,'YYYY'); -- по умолчанию смотрим за текущий год
  dEnd        date := sysdate;

  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  C_s_Dates  constant PKG_STD.TSTRING := 's_Dates';

  LL_LINE    constant PKG_STD.TSTRING := 'L_LINE';
  C_nPP      constant PKG_STD.TSTRING := 'nPP';
  C_sAuth    constant PKG_STD.TSTRING := 'sAuth';
  C_sExt     constant PKG_STD.TSTRING := 'sExt';
  C_sDate    constant PKG_STD.TSTRING := 'sDate';
  C_sPost    constant PKG_STD.TSTRING := 'sPost';
  C_sNote    constant PKG_STD.TSTRING := 'sNote';
  C_sComment constant PKG_STD.TSTRING := 'sComment';
  C_sReturn  constant PKG_STD.TSTRING := 'sReturn';
begin
  begin
    if 'KHOK' = utilizer then
         select t.cRN into nCatalog from USERLIST t where t.authid = 'LUKASHINA_MA';
    else select t.cRN into nCatalog from USERLIST t where t.authid = utilizer;
    end if;
  exception
    when NO_DATA_FOUND then nCatalog := 0;
  end;  

  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);
  PRSG_EXCEL.CELL_DESCRIBE(C_s_Dates);

  -- Описываем строки и ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAuth);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sExt);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDate);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPost);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNote);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sComment);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sReturn);

  if dDATE_START is not null then dStart := dDATE_START; end if;
  if dDATE_END is not null then dEnd := dDATE_END; end if;

  if bAll = 1 then
       PRSG_EXCEL.CELL_VALUE_WRITE(C_s_Dates, 'Возврат счетов с ' || to_char(dStart, 'DD.MM.YYYY') || ' по ' || to_char(dEnd, 'DD.MM.YYYY'));
  else PRSG_EXCEL.CELL_VALUE_WRITE(C_s_Dates, 'Cчета вернувшиеся на регистрацию с ' || to_char(dStart, 'DD.MM.YYYY') || ' по ' || to_char(dEnd, 'DD.MM.YYYY'));
  end if;

  for pays in ( select D$.* from 
   (select pa.*, UDO_F_PAYACCIN_AUTHOR(pa.nrn) sAuth,
        (select sEVENT_STAT from V_CLNEVENTS_STATMOD where sLINKED_UNIT = 'PaymentAccountsIn' and nLINKED_RN = pa.nrn) SSM$STATUS
      from V_PAYACCIN pa 
     where pa.ncompany = nCOMPANY
       --and pa.ddoc_date between dDATE_START and dDATE_END+1
       and trim(UDO_F_PAYACCIN_AUTHOR(pa.nrn)) in (select trim(uss.name) from USERLIST uss where uss.crn = nCatalog)
       order by UDO_F_PAYACCIN_AUTHOR(pa.nrn)) D$
        where SSM$STATUS = 'РегистрацияВхСч' or bAll = 1
    ) loop

      P_UNITSTMOD_GET_EVENT('PaymentAccountsIn', pays.nrn, nEVENT, nEVENT_TYPE, sEVENT, sEVENT_TYPE, nEVENT_STAT, sEVENT_STAT, sINIT_PERSON, sCLIENT_CLIENT, sCLIENT_PERSON, sSEND_PERSON, sSEND_USER_NAME, nPOINT);
    
      for stat in (
        select hist.* from V_CLNEVNHIST hist
         where nCOMPANY = 90521 
           and NPRN = nEVENT
           and hist.ssend_person_agnname in (select trim(uss.name) from USERLIST uss where uss.crn = nCatalog)
           and hist.sauthname != hist.ssend_person_agnname
           and hist.saction_code = 'CLNEVNOTES_INSERT'
           and hist.dchange_date between dStart and dEnd+1
         order by dCHANGE_DATE_TS desc
        ) loop

        --if stat.nevent_note = 59341240 then
          nPP := nPP + 1;
          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,      0, nSTR, nPP);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sAuth,    0, nSTR, pays.sAuth);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sExt,     0, nSTR, pays.sEXT_NUMB);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate,    0, nSTR, pays.dREG_DATE);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPost,    0, nSTR, pays.ssupplier);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sNote,    0, nSTR, trim(pays.scomments));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sComment, 0, nSTR, trim(stat.snote));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sReturn,  0, nSTR, stat.snote_authname);
        --end if;

      end loop;

    end loop;
  --удаляем технические строки
  PRSG_EXCEL.LINE_DELETE(LL_LINE);
end UDO_P_PACCIN_GET_BACK;
/

