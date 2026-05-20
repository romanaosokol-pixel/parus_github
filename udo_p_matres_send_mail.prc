create or replace procedure UDO_P_MATRES_SEND_MAIL(nCOMPANY in number -- рег. номер организации
                                                   ) as
  /*
      01/06/2023 Марков МВ.
      Материальные ресурсы
      Отправка e-mail сообщения технологам о новых записях за предыдущий день
  */
  STO_LIST PKG_STD.tSTRING; -- Перечень E-mail адресов
  /* Сообщение */
  CTEXT PKG_STD.tSTRING;
  /* Тема */
  STITLE PKG_STD.tSTRING;
  --
  cDATA              clob;
  nFILE_BUFFER_IDENT number(17) := gen_ident;
  dBEG               date := trunc(sysdate) - 1;
  dEND               date := dBEG;
  sFILE_NAME         varchar2(240) := 'mtr_parus_' || to_char(sysdate - 1, 'yyyymmdd');
  sMSG_TEXT          varchar2(4000);
  iCNT               integer;

  /* доп.параметры нмоенклатуры */
  function nomen_params(nRN in number) return varchar2 is
    sRES  varchar2(2000);
    sCODE DICNOMNS.NOMEN_CODE%type;
    sUMTS DOCS_PROPS_VALS.STR_VALUE%type;
    sCTLG ACATALOG.NAME%type;
  begin
    begin
      select NM.NOMEN_CODE,
             (select DV.STR_VALUE
                from DOCS_PROPS_VALS DV
               where DV.UNIT_RN = NM.RN
                 and DV.DOCS_PROP_RN = 19579777), -- УМТС. Группа номенклатуры
             C.NAME
        into sCODE,
             sUMTS,
             sCTLG
        from DICNOMNS NM,
             ACATALOG C
       where NM.RN = nRN
         and NM.CRN = C.RN;
    exception
      when no_data_found then
        return ';;';
    end;
    -- Мнемокод
    sRES := sCODE;
    -- Группа УМТС
    if rtrim(sUMTS) is not null then
      sRES := sRES || ';' || sUMTS;
    else
      sRES := sRES || ';';
    end if;
    -- Каталог номенклатора
    sRES := sRES || ';' || sCTLG;
    return sRES;
  end nomen_params;

begin

  /* Выгрузка журнала в файл */
  begin
    -- Перенос в CLOB
    dbms_lob.createtemporary(cDATA, true);
  
    -- заговлок
    sMSG_TEXT := 'Наименование;Обозначение;Мнемокод;Группа УМТС;Каталог номенклатора' || chr(10);
    dbms_lob.writeappend(lob_loc => cDATA, amount => length(sMSG_TEXT), buffer => sMSG_TEXT);
    -- строки
    iCNT := 0;
    for rec in (select distinct MR.NOMENCLATURE,
                                MR.CODE,
                                MR.NAME
                  from UPDATELIST_ARC A,
                       FCMATRESOURCE  MR
                 where trunc(A.MODIFDATE) between dBEG and dEND
                   and A.TABLENAME = 'FCMATRESOURCE'
                   and A.TABLERN = MR.RN
                   and MR.company = nCOMPANY --90521
                   and A.OPERATION = 'I'
                 order by mr.name) loop
      iCNT      := iCNT + 1;
      rec.name  := replace(rec.name, CR, ' ');
      sMSG_TEXT := rec.name;
      sMSG_TEXT := sMSG_TEXT || ';' || rec.code;
      -- доп.параметры номенклатуры
      sMSG_TEXT := sMSG_TEXT || ';' || nomen_params(nRN => rec.nomenclature);
      sMSG_TEXT := sMSG_TEXT || chr(10);
      dbms_lob.writeappend(lob_loc => cDATA, amount => length(sMSG_TEXT), buffer => sMSG_TEXT);
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
    STO_LIST := 'v.talanova@module.ru;i.yastrebova@module.ru;m.markov@module.ru;a.khokhryakov@module.ru;v.fanov@module.ru;i.kanaev@module.ru';
    --STO_LIST := 'm.markov@module.ru;i.kanaev@module.ru';
    -- Заголовок
    STITLE := 'Список новых номенклатур';
    -- Сообщение
    CTEXT := 'Новые номенклатуры.' || chr(10) || 'За ' || to_char(dBEG, 'dd.mm.yyyy') || chr(10) ||
             'Смотри прикрепленный файл.';
    --CTEXT := 'Загрузка спецификаций из Интермех. За весь период.';
    CTEXT := CTEXT || CR || 'Добавлено ' || to_char(iCNT) || ' новых номенклатур (модификаций).';
    CTEXT := CTEXT || CR || CR || 'Получатели данного письма:' || CR || 
                                  'v.talanova@module.ru' || CR ||
                                  'i.yastrebova@module.ru' || CR || 
                                  'm.markov@module.ru' || CR || 
                                  'a.khokhryakov@module.ru' || CR ||
                                  'v.fanov@module.ru' || CR || 
                                  'i.kanaev@module.ru';
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

end;
/
