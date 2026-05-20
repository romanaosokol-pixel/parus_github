create or replace procedure UDO_P_SYS_DIR_RESENT_MAIL
(
  nIDENT in number -- Запись документа
) is
  rDIR     UDO_DEPORDDIR%rowtype; -- Запись документа
  nTYPE    number(1) := 0;
  nAGN     PKG_STD.tREF; -- Рег номер контрагента
  SAGMAIL  PKG_STD.tSTRING; -- Адрес E-mail
  STO_LIST PKG_STD.tSTRING; -- Перечень E-mail адресов
  /* Сообщение */
  CTEXT PKG_STD.tSTRING; -- Необходимо согласовать спецификацию счета';
  /* Тема */
  STITLE PKG_STD.tSTRING; -- := 'Ведомость замен <Номер ведомости> на согласование';
  --
  sORD_NUMB varchar2(240);
  sORD_DATE varchar2(40);
  sORD_Z    varchar2(2000);
  nFACEACC  number(17);
begin
  if utilizer not in ('CITK_MARKOV', 'KHOK') then p_exception(0, 'Нет прав доступа на выполнение процедуры. Обратитесь к Администратору!'); end if;
  -- ведомость замен
  begin
    select D.* into rDIR from UDO_DEPORDDIR D, SELECTLIST SL where SL.IDENT = nIDENT and SL.DOCUMENT = D.RN;
  exception
    when no_data_found then
      p_exception(0, 'Не отмечено ни одной записи.');
    when too_many_rows then
      p_exception(0, 'Отмечено более одной записи.');
  end;
  --
  if nvl(nTYPE, 0) = 0 then
    STITLE := 'Ведомость замен ' || trim(rDIR.Doc_Pref) || '-' || trim(rDIR.Doc_Numb) || ' на согласование';
  elsif nTYPE = 1 then
    STITLE := 'Ведомость замен ' || trim(rDIR.Doc_Pref) || '-' || trim(rDIR.Doc_Numb) || ' повторное согласование';
  else
    p_exception(0, 'Не определен тип сообщения.');
  end if;
  -- заказ подразделения
  begin
    select trim(ORD.ORD_PREF) || '-' || trim(ORD.ORD_NUMB),
           to_char(ORD.ORD_DATE, 'dd.mm.yyyy'),
           ORD.FACEACC,
           (select DV.STR_VALUE
              from DOCS_PROPS_VALS DV
             where DV.UNIT_RN = ORD.RN
               and DV.DOCS_PROP_RN = 8027721) -- Номер заявки
      into sORD_NUMB,
           sORD_DATE,
           nFACEACC,
           sORD_Z
      from DEPARTMENTORD ORD
     where ORD.RN = rDIR.Depord;
  exception
    when no_data_found then
      -- Нет связанного заказа - некому отправлять
      return;
  end;
  /* Определим Ответственного контрагента */
  nAGN := UDO_F_FACEACC_GET_AGENT(nRN => nFACEACC);
  /* Найдем e-mail ответственнго */
  begin
    select ag.mail into SAGMAIL from agnlist ag where ag.rn = nAGN;
  exception
    when NO_DATA_FOUND then
      SAGMAIL := null;
  end;
  /* Соберем e-mail ответственных */
  STO_LIST := SAGMAIL;
  --
  STO_LIST := STO_LIST;
  /* Сообщение */
  CTEXT := 'По заказу подразделения ' || sORD_NUMB || ' (заявка ' || sORD_Z || ') от ' || sORD_DATE || chr(10) ||
           'Ведомость замен ' || trim(rDIR.Doc_Pref) || '-' || trim(rDIR.Doc_Numb) || ' от ' ||
           to_char(rDIR.Doc_Date, 'dd.mm.yyyy') || '.';
  if nvl(nTYPE, 0) = 0 then
    CTEXT := CTEXT || chr(10) || 'Необходимо согласование позиций.';
  else
    CTEXT := CTEXT || chr(10) || 'Необходимо повторное согласование позиций.';
  end if;
  CTEXT := CTEXT || CR || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';

  /* Отправка E-mail сообщения (по списку получателей) */
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT,
                                --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);

  /* контрольное Сообщение */
  CTEXT := 'По заказу подразделения ' || sORD_NUMB || ' (заявка ' || sORD_Z || ') от ' || sORD_DATE || chr(10) ||
           'Ведомость замен ' || trim(rDIR.Doc_Pref) || '-' || trim(rDIR.Doc_Numb) || ' от ' ||
           to_char(rDIR.Doc_Date, 'dd.mm.yyyy') || '.';
  if nvl(nTYPE, 0) = 0 then
    CTEXT := CTEXT || chr(10) || 'Необходимо согласование позиций.';
  else
    CTEXT := CTEXT || chr(10) || 'Необходимо повторное согласование позиций.';
  end if;
  CTEXT    := substr(CTEXT || CR || CR || CR || 'Данное сообщение направлено:' || CR || STO_LIST,
                     1,
                     4000);
  STO_LIST := 'm.markov@module.ru;v.fanov@module.ru;a.khokhryakov@module.ru';
  /* Отправка E-mail сообщения (по списку получателей) */
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT,
                                --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);

end;
/

