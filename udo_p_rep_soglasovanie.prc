create or replace procedure UDO_P_REP_SOGLASOVANIE
(
  NPROCESS        in number, -- идентификатор процесса
  NIDENT          in number  -- идентификатор выбранной записи
)
is
  /* Процедура для пользовательского отчета Лист согласования */

  BREP    BLOB;
  CREP    CLOB;
  nROW    number;
  -- Поля документа
  DOC_NUM     constant PKG_STD.TSTRING := 'DOC_NUM';
  DOC_SUM     constant PKG_STD.TSTRING := 'DOC_SUM';
  DOC_TAX     constant PKG_STD.TSTRING := 'DOC_TAX';
  DOG_TYPE    constant PKG_STD.TSTRING := 'DOG_TYPE';
  DOC_DOG     constant PKG_STD.TSTRING := 'DOC_DOG';
  DOC_REASON  constant PKG_STD.TSTRING := 'DOC_REASON';
  DOC_THEME   constant PKG_STD.TSTRING := 'DOC_THEME';
  DOC_SOURCE  constant PKG_STD.TSTRING := 'DOC_SOURCE';
  DOC_COMMENT constant PKG_STD.TSTRING := 'DOC_COMMENT';
  DDATE       constant PKG_STD.TSTRING := 'DDATE';
  S_POST      constant PKG_STD.TSTRING := 'S_POST';
  S_SIGN      constant PKG_STD.TSTRING := 'S_SIGN';
  S_DATE      constant PKG_STD.TSTRING := 'S_DATE';
  S_FIO       constant PKG_STD.TSTRING := 'S_FIO';
  S_COMMENT   constant PKG_STD.TSTRING := 'S_COMMENT';

  sNumb       varchar2(2048) := '';
  sShifr      varchar2(128) := '';
  sDog        varchar2(128) := '';

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
  sStatus          varchar2(256) := 'РегистрацияВхСч';
  --sComment         varchar2(256) := '';
  nPOINT           PKG_STD.tREF;
begin
  -- считывание шаблона
--p_exception(0, 'Процедура в процессе совершенствования!');

  begin
    select T.TEMPLATE_DATA
      into BREP
      from USERREPORTS T
     where T.COMPANY = Pkg_Session.GET_COMPANY()
       and T.RN = PKG_USERREPORTS.GET_REPORT();
  exception when no_data_found then
     p_exception(0 , 'Шаблон отчета не найден.');
  end;

  --инициализация
  UDO_PKG_WINWORD.PREPARE(PAGEBREAK_IN_FIRST_PARAGRAPH => false, DELETE_FIELDS => true);

  for cur in (
    select t.nrn, t.ddoc_date, t.nsumm, t.nsummwithnds, t.scurrency, t.sext_numb, t.spayeracc, 
     nvl(t.svdoc_type, '-') svdoc_type, t.svdoc_num, t.dvdoc_date, t.scomments,
     UDO_F_PAYACCIN_PAYTYPE(t.nRN) sType, UDO_F_PAYACCIN_FACEACC_ARTICLE(t.nRN) sArt, 
     nvl(UDO_F_PAYACCIN_TEMA(t.nRN), 'Общехозяйственный') sShifr, 
     agn.agnacc, MB.AGNNAME sbanknameacc
    from SELECTLIST SL, V_PAYACCIN t, AGNACC agn,
         AGNLIST  al, AGNBANKS B, AGNLIST MB
    where SL.IDENT = UDO_P_REP_SOGLASOVANIE.NIDENT
      and SL.DOCUMENT  = t.NRN
      and t.npayeracc  = agn.rn
      and agn.AGNRN    = al.RN
      and agn.AGNBANKS = B.RN(+)
      and B.AGNRN      = MB.RN(+)
    ) loop

      for rec in (
        select Shifr, Numb, rn from (
            select UDO_F_PAYACCINSPECLC_SHEFR(spec.rn) Shifr, 
                   UDO_F_PAYACCINSPEC_DOGNUMB(spec.rn) Numb,
                   row_number() over (partition by UDO_F_PAYACCINSPECLC_SHEFR(spec.rn), UDO_F_PAYACCINSPEC_DOGNUMB(spec.rn) 
                                          order by UDO_F_PAYACCINSPECLC_SHEFR(spec.rn), UDO_F_PAYACCINSPEC_DOGNUMB(spec.rn)
                                      ) as rn
            from PAYACCINSPEC spec
            where spec.prn = cur.NRN --73266494 
            order by Shifr, length(Numb) desc, Numb
        ) where rn = 1
      ) loop

        if sShifr is null or sShifr != rec.shifr then
           if sShifr is not null then
             sNumb := sNumb || '; ';
           end if;
           sNumb := sNumb || rec.Shifr || ' (' || rec.Numb;
           sShifr := rec.Shifr;
        else
          if instr(sNumb, rec.Numb) = 0 
             and instr(sNumb, substr(rec.Numb, 0, instr(rec.Numb, ';')-1)) = 0 
             and instr(sNumb, substr(rec.Numb, 0, instr(rec.Numb, ';')-1), -1) = 0 
          then
            if sDog is null or sDog != rec.Numb then
               sNumb := sNumb || ', '|| rec.Numb;
               sDog := rec.Numb;
            end if;
          end if;
        end if;

      end loop;

      if sNumb is not null then
           sNumb := sNumb || ')';
      else sNumb := '-';
      end if;

    /* инициализация файла для пользователя */
    nROW := null;
    UDO_PKG_WINWORD.LOAD(DATA => BREP, SNLS_CHARSET_ID => 'UTF8');

  -- Документ
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_NUM,
                                    SVALUE   => cur.sext_numb || ', ' || to_char(cur.ddoc_date,'DD.MM.YYYY')); -- Внешний номер
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_SUM,
                                    SVALUE   => trim(to_char(cur.nsummwithnds, 'B99,999,999,999.09')) || ' '|| cur.scurrency); -- Сумма с налогом
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_TAX,
                                    SVALUE   => trim(to_char(cur.nsummwithnds-cur.nsumm, 'B99,999,999,999.09'))); -- НДС
    if ('-' != cur.svdoc_type) then
      UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOG_TYPE,
                                      SVALUE   => cur.svdoc_type); -- тип Договора
      UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_DOG,
                                      SVALUE   => cur.svdoc_num || ' от ' || to_char(cur.dvdoc_date,'DD.MM.YYYY')); -- Договор
    else
      UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOG_TYPE, SVALUE => 'Договор');
      UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_DOG,  SVALUE => 'не указан');
    end if;
    if ('-' != sNumb and ', ' != sNumb) then
         UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_THEME, SVALUE => sNumb);
    else UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_THEME, SVALUE => cur.sShifr);
    end if;
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_REASON,
                                    SVALUE   => cur.sArt); -- Статья затрат
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_SOURCE,
                                    SVALUE   => cur.sType || ', ' || cur.agnacc || ', ' || cur.sbanknameacc); -- Источник оплаты
--                                    SVALUE   => cur.sType || ', ' || cur.spayeracc); -- Источник оплаты
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DOC_COMMENT,
                                    SVALUE   => cur.scomments);  -- Примечание
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => DDATE,
                                    SVALUE   => to_char(sysdate,'DD.MM.YYYY HH24:MI'));

    P_UNITSTMOD_GET_EVENT('PaymentAccountsIn', cur.nrn, nEVENT, nEVENT_TYPE, sEVENT, sEVENT_TYPE, nEVENT_STAT, sEVENT_STAT, sINIT_PERSON, sCLIENT_CLIENT, sCLIENT_PERSON, sSEND_PERSON, sSEND_USER_NAME, nPOINT);

--p_exception(0, nEVENT);
    /* цикл по согласованиям */
    for rec in (select hist.sauthid, hist.sauthname, hist.dchange_date, hist.sevent_stat, hist.sevent_stat_name, 
                       hist.ssend_person, hist.saction_code, hist.snote,
                       agn.agnabbr, agn.emppost
      from V_CLNEVNHIST hist, CLNPERSONS cln, agnlist agn --,USERLIST ul
       where nCOMPANY = Pkg_Session.GET_COMPANY()
         and NPRN = nEVENT --and hist.ssend_person is not null
         and cln.pers_authid (+)= hist.sauthid
         and agn.rn (+)= cln.pers_agent
         and (/*agn.agnabbr != trim(SUBSTR(hist.ssend_person, 1, INSTR(hist.ssend_person, '#')-1)) or*/ 
             'CLNEVENTS_LINKED_UNIT_ACTION' = hist.saction_code or 'CLNEVENTS_CHANGE_STATE' = hist.saction_code)
--         and ul.authid = hist.sauthid
--         and agn.rn = ul.rn
       order by dCHANGE_DATE_TS
       ) loop

       if ('CLNEVENTS_CHANGE_STATE' = rec.saction_code) then
        -- номер строки
        nROW := UDO_PKG_WINWORD.APPEND_TABLEROW(ntablenum => 1,
                                                nbeginrow => 2,
                                                nendrow   => 2);
        -- запись в ячейки строки
        UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => S_POST,
                                        SVALUE   => rec.emppost,
                                        TABLEROW => nROW);
        UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => S_SIGN,
                                        SVALUE   => sStatus, --trim(rec.sevent_stat_name),
                                        TABLEROW => nROW);
        UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => S_DATE,
                                        SVALUE   => to_char(rec.dchange_date,'DD.MM.YYYY'),
                                        TABLEROW => nROW);
        UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => S_FIO,
                                        SVALUE   => rec.agnabbr,
                                        TABLEROW => nROW);
        UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => S_COMMENT,
                                        SVALUE   => rec.snote,
                                        TABLEROW => nROW);
      end if;

      sStatus := trim(rec.sevent_stat_name);

    end loop rec;

    -- очистка шаблона строк
    UDO_PKG_WINWORD.DELETE_TABLEROW(ntablenum => 1,
                                    nbeginrow => 2,
                                    nendrow   => 2);
    -- сохранение отчета
    UDO_PKG_WINWORD.SAVE(DATA => CREP);

    -- отладка
    --UDO_PKG_WINWORD.SHOWTABLEDEBUG(CREP);

    -- запись в буфер для отображения
    p_file_buffer_insert(nIDENT    => NPROCESS,
                         cFILENAME => '.DOC',
                         cDATA     => CREP,
                         bLOBDATA  => null);

    end loop cur;

end ;
/

