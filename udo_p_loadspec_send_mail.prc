create or replace procedure UDO_P_LOADSPEC_SEND_MAIL(
       nCOMPANY in number -- рег. номер организации
) is
  /*
      27/02/2023 Марков МВ.
      Загрузке из внешних источников
      Отправка e-mail сообщения Носову В. о загрузках спецификаций за неделю.
  */
  STO_LIST PKG_STD.tSTRING; -- Перечень E-mail адресов
  /* Сообщение */
  CTEXT PKG_STD.tSTRING;
  /* Тема */
  STITLE PKG_STD.tSTRING;
  --
  cDATA              clob;
  nFILE_BUFFER_IDENT number(17) := gen_ident;
  sFILE_NAME         varchar2(240) := 'ips_parus_' || to_char(sysdate, 'ddmmyyyy');
  dEND               date := trunc(sysdate)-1;
  dBEG               date := dEND;
  sMSG_TEXT          varchar2(4000);
  iCNT               integer;
  iCNT_LOAD          integer;
  iCNT_STATE         integer;

begin

  /* Выгрузка журнала в файл */
  begin
    -- Перенос в CLOB
    dbms_lob.createtemporary(cDATA, true);
  
    -- заговлок
    sMSG_TEXT := 'Наименование файла;Дата загрузки;Загрузка;Извещение;Извещение об изменении;Состояние;Не подобрано' || chr(10);
    dbms_lob.writeappend(lob_loc => cDATA, amount => length(sMSG_TEXT), buffer => sMSG_TEXT);
    -- строки
    iCNT := 0;
    iCNT_LOAD := 0;
    iCNT_STATE := 0;
    for rec in (select T.*,
                       case
                         when T.STATE = 0 then 'Новая'
                         when T.STATE = 1 then 'Утверждена'
                         when T.STATE = 2 then 'Отклонена'
                         else 'Не указано'
                       end as sSTATE,
                       (select ATTR.STRING_VALUE
                          from UDO_LOADEXT_ORD_ATTR ATTR,
                               UDO_LOADEXT_ORD_SP   SP
                         where SP.PRN = T.RN
                           and SP.SIGN_HEAD = 1
                           and ATTR.PRN = SP.RN
                           and ATTR.ATTRIBUTE_ID = 17918
                           and rownum < 2) as sDIFF,
                       case
                         when exists (select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */
                                null
                                 from DOCLINKS L
                                where L.IN_DOCUMENT = T.RN
                                  and L.IN_UNITCODE = 'UdoLoadextOrd'
                                  and L.OUT_UNITCODE = 'CostProductListNotifies') then
                          (select case
                                    when exists (select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */
                                           null
                                            from DOCLINKS L
                                           where L.IN_DOCUMENT = PC.RN
                                             and L.IN_UNITCODE = 'CostProductListNotifies'
                                             and L.OUT_UNITCODE = 'CostProductLists') then
                                         'Отработано'
                                    else 'Не отработано'
                                  end
                             from DOCLINKS  L,
                                  FCPLCHNOT PC
                            where L.IN_DOCUMENT = T.RN
                              and L.IN_UNITCODE = 'UdoLoadextOrd'
                              and L.OUT_UNITCODE = 'CostProductListNotifies'
                              and L.OUT_DOCUMENT = PC.RN)
                         when exists (select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */
                                null
                                 from DOCLINKS L
                                where L.IN_DOCUMENT = T.RN
                                  and L.IN_UNITCODE = 'UdoLoadextOrd'
                                  and L.OUT_UNITCODE = 'CostProductLists') then
                              'Спецификация'
                         else ''
                       end as sPLCHNOT,
                       (select count(sp.rn)
                          from udo_loadext_ord_sp sp
                         where sp.prn = t.rn
                           and sp.modif is null)  as NOT_NOMEN,
                       pkg_document.MAKE_NUMBER(nDOC_TYPE => t.doc_type,
                                                sDOC_PREF => t.doc_pref,
                                                sDOC_NUMB => t.doc_numb,
                                                dDOC_DATE => t.doc_date) as sDOC
                  from UDO_LOADEXT_ORD T
                 where T.COMPANY = nCOMPANY
                   and T.LOAD = 1 -- только загрузка спецификаций
                   and (trunc(T.LOAD_DATE) between dBEG and dEND or
                        (T.STATE_DATE is not null and T.STATE_DATE between dBEG and dEND)) ) loop
      iCNT      := iCNT + 1;
      sMSG_TEXT := rec.file_name;
      sMSG_TEXT := sMSG_TEXT || ';' || to_char(rec.load_date, 'dd.mm.yyyy');
      sMSG_TEXT := sMSG_TEXT || ';' || rec.sdoc;
      sMSG_TEXT := sMSG_TEXT || ';' || rec.sdiff;
      sMSG_TEXT := sMSG_TEXT || ';' || rec.splchnot;
      sMSG_TEXT := sMSG_TEXT || ';' || rec.sstate;
      sMSG_TEXT := sMSG_TEXT || ';' || rec.not_nomen;
      sMSG_TEXT := sMSG_TEXT || chr(10);
      dbms_lob.writeappend(lob_loc => cDATA, amount => length(sMSG_TEXT), buffer => sMSG_TEXT);
      --
      if rec.load_date between dBEG and dEND then
        iCNT_LOAD := iCNT_LOAD + 1;
      end if;
      if rec.state_date is not null and rec.state_date between dBEG and dEND and rec.state = 1 then
        iCNT_STATE := iCNT_STATE + 1;
      end if;
    end loop;
  
    if iCNT > 0 then
      -- добавляем запись в FILE_BUFFER
      insert into FILE_BUFFER
        (IDENT,
         FILENAME,
         DATA)
      values
        (nFILE_BUFFER_IDENT,
         sFILE_NAME || '.csv',
         cDATA);
    end if;
  
    -- освобождаем буфер
    dbms_lob.freetemporary(cDATA);
    cDATA := null;
  exception
    when OTHERS then
      dbms_lob.freetemporary(cDATA);
      cDATA := null;
      raise;
  end;

  if nvl(iCNT, 0) > 0 then
    -- получатель
    STO_LIST := 'v.nosov@module.ru;m.markov@module.ru;a.khokhryakov@module.ru';
    -- Заголовок
    STITLE := 'Загрузка спецификаций из Интермех';
    -- Сообщение
    CTEXT := 'Загрузка спецификаций из Интермех.' || chr(10) || 'За период с ' || to_char(dBEG, 'dd.mm.yyyy') || ' по ' ||
             to_char(dEND, 'dd.mm.yyyy');
    --CTEXT := 'Загрузка спецификаций из Интермех. За весь период.';
    CTEXT := CTEXT || CR || 'Загружено ' || to_char(iCNT_LOAD) || ' спецификаций.';
    CTEXT := CTEXT || CR || 'Утверждено ' || to_char(iCNT_STATE) || ' спецификаций.';
    CTEXT := CTEXT || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';
    /* Отправка E-mail сообщения (по списку получателей) */
    PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST           => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                  STITLE             => STITLE, -- Тема
                                  CTEXT              => CTEXT,
                                  NFILE_BUFFER_IDENT => nFILE_BUFFER_IDENT, -- Прикладываемые документы (идентификатор файлового буфера)
                                  NFORMAT            => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
    -- подчистка
    --p_file_buffer_clear(nIDENT => nFILE_BUFFER_IDENT);
  end if;
end UDO_P_LOADSPEC_SEND_MAIL;
/

