create or replace procedure UDO_P_STATUS_HIST(nRN in number)
is
    ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  L_lStr     constant PKG_STD.TSTRING := 'Stroka';
  L_lStrH    constant PKG_STD.TSTRING := 'Head';
  L_lStrR    constant PKG_STD.TSTRING := 'Reason';
  L_lStrT    constant PKG_STD.TSTRING := 'Title';
  
  C_sName    constant PKG_STD.TSTRING := 'Zagolovok';
  C_sData    constant PKG_STD.TSTRING := 'Date';
  C_sPrim    constant PKG_STD.TSTRING := 'Prim';

  C_sDay    constant PKG_STD.TSTRING := 'Day';
  C_sAction constant PKG_STD.TSTRING := 'Action';
  C_sAuthor constant PKG_STD.TSTRING := 'Author';
  C_sStatus constant PKG_STD.TSTRING := 'Status';
  C_sMoved  constant PKG_STD.TSTRING := 'Moved';
  C_sNotes  constant PKG_STD.TSTRING := 'Notes';

  sNumb            varchar2(128);
  sComment         varchar2(240);
  nSTR             number(17) := 1;
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

begin
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  --PRSG_EXCEL.CELL_DESCRIBE(C_sName);
  --PRSG_EXCEL.CELL_DESCRIBE(C_sData);

  -- Описываем ячейки спецификации материалов
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrH);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrH, C_sName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrH, C_sData);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrR, C_sPrim);
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrT);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDay);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sAction);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sAuthor);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sStatus);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sMoved);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sNotes);

  ---Заполнение шапки отчета
  --PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));  
    
  For list in (
    select s1.document from SELECTLIST s1 where s1.ident = nRN
    ) loop
  --p_exception(0,'list.document ' || list.document);

    select trim(t.sdoc_type)||' '||trim(t.sdoc_pref)||'-'||trim(t.sdoc_numb)||', '||to_char(t.ddoc_date,'DD.MM.YYYY'), t.scomments
      into sNumb, sComment
      from V_PAYACCIN t where t.nRN = list.document;
--  PRSG_EXCEL.CELL_VALUE_WRITE(C_sName, 'История статусов ' || sNumb);
    nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
    nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStrH);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sName, 0, nSTR, 'История статусов ' || sNumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 0, nSTR, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));
    nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStrR);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPrim, 0, nSTR, sComment);
    nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStrT);
  
    P_UNITSTMOD_GET_EVENT('PaymentAccountsIn', list.document, nEVENT, nEVENT_TYPE, sEVENT, sEVENT_TYPE, nEVENT_STAT, sEVENT_STAT, sINIT_PERSON, sCLIENT_CLIENT, sCLIENT_PERSON, sSEND_PERSON, sSEND_USER_NAME, nPOINT);
  
    For rec in (
      select * from V_CLNEVNHIST hist 
       where nCOMPANY = 90521 and NPRN = nEVENT 
       order by dCHANGE_DATE_TS
      ) loop
      nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);

      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDay, 0, nSTR, rec.dchange_date);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAction, 0, nSTR, trim(rec.saction_name));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAuthor, 0, nSTR, trim(rec.sauthname));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStatus, 0, nSTR, trim(rec.sevent_stat_name));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sMoved, 0, nSTR, trim(SUBSTRING(rec.ssend_person, '#')));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sNotes, 0, nSTR, trim(rec.sreason));
      
      end loop;
    end loop;

    PRSG_EXCEL.LINE_DELETE(L_lStr);
    PRSG_EXCEL.LINE_DELETE(L_lStrT);
    PRSG_EXCEL.LINE_DELETE(L_lStrR);
    PRSG_EXCEL.LINE_DELETE(L_lStrH);
        
end UDO_P_STATUS_HIST;
/

