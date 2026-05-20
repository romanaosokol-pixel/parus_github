create or replace procedure UDO_P_PACCIN_LATE_PAY
(
  nCOMPANY  in number,
  nCATALOG  in number,
  nDOCUMENT in number,
  nRESULT   out number
) is
  SAGMAIL  PKG_STD.tSTRING; -- Адрес E-mail
  STO_LIST PKG_STD.tSTRING; -- Перечень E-mail адресов
  /* Тема */
  STITLE PKG_STD.tSTRING;
  /* Сообщение */
  CTEXT PKG_STD.tSTRING;
begin
  nRESULT := 1;
  begin
    CTEXT := 'Необходимо скоро оплатить:' || CR;
  
    for rec in (select D$.*
                  from (select M.*,
                               trim(TO_CHAR(m.planpaysumm - m.factpaysumm, '999G999G999G999D99MI')) sSum,
                               cur.intcode,
                               ag.agnname,
                               UDO_F_PAYACCIN_TEMA(m.RN) S8940828,
                               (select sEVENT_STAT
                                  from V_CLNEVENTS_STATMOD
                                 where sLINKED_UNIT = 'PaymentAccountsIn'
                                   and nLINKED_RN = m.RN) SSM$STATUS,
                               (select SEXECUTER
                                  from V_CLNEVENTS_STATMOD
                                 where sLINKED_UNIT = 'PaymentAccountsIn'
                                   and nLINKED_RN = m.RN) SSM$SEXECUTER,
                               UDO_F_PAYACCIN_STATUS_DATE(m.RN) D12031331,
                               UDO_F_PAYACCIN_EXT_NUMB_OWN(m.RN) S6947466
                        --, UDO_F_PAYACCIN_SUBTRACTSUMM(m.RN) N11908421
                          from PAYACCIN M,
                               AGNLIST  ag,
                               CURNAMES cur
                         where m.COMPANY = nCOMPANY
                           and m.doc_state = 1
                           and m.pay_date is not null
                           and m.reg_date > '01-jan-2022'
                           and m.pay_date <= sysdate + 3
                           and m.summwithnds > m.factpaysumm
                           and ag.rn = m.supplier
                           and cur.rn = m.currency
                         order by m.pay_date,
                                  agnname,
                                  S8940828,
                                  m.reg_date,
                                  m.summwithnds) D$
                --where SSM$STATUS = 'УтверждВходСчетФЭО'
                 where UPPER(SSM$SEXECUTER) like '%НАДЕЕВА%'
                 order by S8940828, D$.agnname
    ) loop
      -- Сообщение
      if length(rec.S8940828) > 0 then
        CTEXT := CTEXT || CR || 'Тема: ' || rec.S8940828 || '. ';
      end if;
      CTEXT := CTEXT || CR || '    Дата платежа: ' || to_char(rec.pay_date, 'DD.MM.YYYY') || ';   Номер счета: ' ||
              rec.s6947466 || ';   Сумма платежа: ' || rec.sSum || ' ' || rec.intcode --rec.N11908421 
               || ';   Поставщик: ' || rec.agnname;
    end loop;
  
    -- получатели
    SAGMAIL  := 'a.khokhryakov@module.ru';
    STO_LIST := SAGMAIL || ';i.nadeeva@module.ru;y.tyumentseva@module.ru;r.surov@module.ru';
    -- Заголовок
    STITLE := 'Предстоящие Счета на оплату';
    CTEXT  := CTEXT || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на это сообщение.';
  
    /* Отправка E-mail сообщения (по списку получателей) */
    PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                  STITLE   => STITLE, -- Тема
                                  CTEXT    => CTEXT,
                                  NFORMAT  => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
  end;

end UDO_P_PACCIN_LATE_PAY;
/

