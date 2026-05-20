create or replace package UDO_PKG_WINWORD is
  /*получить полный NAMESPACE используется если нужно обрабатывать XMLTYPE*/
  function GETWINWORD_NAMESPACE return varchar2;

  /*получить W NAMESPACE используется если нужно обрабатывать XMLTYPE*/
  function GETWINWORD_W_NAMESPACE return varchar2;

  /* Инициализация -перед любыми действиями с пакетом необходимо вызвать
     этот метод
     PAGEBREAK_IN_FIRST_PARAGRAPH - добавлять развыв страницы
     DELETE_FIELDS - удалять свойства документа
  */
  procedure PREPARE(PAGEBREAK_IN_FIRST_PARAGRAPH in boolean default false,
                    DELETE_FIELDS                in boolean default false);

  /*Загрузить шаблон из CLOB*/
  procedure LOAD(DATA in out nocopy clob);

  /*Загрузить шаблон из BLOB c указанием кодировки*/
  procedure LOAD(DATA in blob, SNLS_CHARSET_ID in varchar2);

  /*Добавить строки из ШАБЛОНА в конец таблицы ДОКУМЕНТА
   ntablenum - порядковый номер таблицы в шаблоне (и документе)
   nbeginrow - номер начальной строки в таблице ШАБЛОНА
   nendrow   - номер конечной строки в таблице ШАБЛОНА
  */
  function APPEND_TABLEROW(ntablenum in number,
                           nbeginrow in number,
                           nendrow   in number) return number;

  /*Удалить стоки из таблицы ДОКУМЕНТА
   ntablenum - порядковый номер таблицы в шаблоне
   nbeginrow - номер начальной строки в таблице ДОКУМЕНТА (а не ШАБЛОНА)
   nendrow   - номер конечной строки в таблице ДОКУМЕНТА (а не ШАБЛОНА)
  */
  procedure DELETE_TABLEROW(ntablenum in number,
                            nbeginrow in number,
                            nendrow   in number);

  /*Установить значение для поля документа
  SDOCPROP - имя поля
  SVALUE   - значение поля
  TABLEROW - если значение поля надо записать в строки
             таблицы, добавленные APPEND_TABLEROW,
             то указывается значение возвращенное APPEND_TABLEROW
  */
  procedure SET_DOCPROPERTY(SDOCPROP in varchar2,
                            SVALUE   in varchar2,
                            TABLEROW in number default null);

  /*Добавить новый шаблон в результирующий файл
    все команды после этого вызова будут применяться к этому шаблону*/
  procedure NEWPAGE;

  /*Весь текст в ячейках таблиц шаблона будут заменены на значение
    T<номер таблицы>R<номер строки в таблице>C<номер ячейки в строке>
    Это необходимо если шаблон содержит скрытые таблицы
    Нужно для корректных вызовов APPEND_TABLEROW и DELETE_TABLEROW
    */
  procedure SHOWTABLEDEBUG(DATA out clob);

  /*Получить  преобразованный документ MS Word*/
  procedure SAVE(DATA out clob);

end UDO_PKG_WINWORD;
/

create or replace package body UDO_PKG_WINWORD is

  --
  NXMLRN number := null;

  NDOCRN number := null;

  NPARUS_BODYRN number := null;

  SXMLNLS_CHARSET_ID varchar2(100) := null;

  BPAGE_IN_FIRST_PARAGRAPH boolean := false;
  NDELETE_FIELDS           number(1) := 0;
  --
  SWINWORD_AML_NAMESPACE_URI constant PKG_STD.TSTRING := 'http://schemas.microsoft.com/aml/2001/core';

  SWINWORD_DT_NAMESPACE_URI constant PKG_STD.TSTRING := 'uuid:C2F41010-65B3-11d1-A29F-00AA00C14882';

  SWINWORD_VE_NAMESPACE_URI constant PKG_STD.TSTRING := 'http://schemas.openxmlformats.org/markup-compatibility/2006';

  SWINWORD_O_NAMESPACE_URI constant PKG_STD.TSTRING := 'urn:schemas-microsoft-com:office:office';

  SWINWORD_V_NAMESPACE_URI constant PKG_STD.TSTRING := 'urn:schemas-microsoft-com:vml';

  SWINWORD_W10_NAMESPACE_URI constant PKG_STD.TSTRING := 'urn:schemas-microsoft-com:office:word';

  SWINWORD_W_NAMESPACE_URI constant PKG_STD.TSTRING := 'http://schemas.microsoft.com/office/word/2003/wordml';

  SWINWORD_WX_NAMESPACE_URI constant PKG_STD.TSTRING := 'http://schemas.microsoft.com/office/word/2003/auxHint';

  SWINWORD_WSP_NAMESPACE_URI constant PKG_STD.TSTRING := 'http://schemas.microsoft.com/office/word/2003/wordml/sp2';

  SWINWORD_SL_NAMESPACE_URI constant PKG_STD.TSTRING := 'http://schemas.microsoft.com/schemaLibrary/2003/core';

  /*
   XMLAttributes(sWINWORD_aml_NAMESPACE_URI as "xmlns:aml",
  sWINWORD_dt_NAMESPACE_URI as "xmlns:dt",
  sWINWORD_ve_NAMESPACE_URI as "xmlns:ve",
  sWINWORD_o_NAMESPACE_URI as "xmlns:o",
  sWINWORD_v_NAMESPACE_URI as "xmlns:v",
  sWINWORD_w10_NAMESPACE_URI as "xmlns:w10",
  sWINWORD_w_NAMESPACE_URI as "xmlns:w",
  sWINWORD_wx_NAMESPACE_URI as "xmlns:wx",
  sWINWORD_wsp_NAMESPACE_URI as "xmlns:wsp",
  sWINWORD_sl_NAMESPACE_URI as "xmlns:sl",
  );
  */
  SWINWORD_AML_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:aml="' ||
                                                     SWINWORD_AML_NAMESPACE_URI || '" ';

  SWINWORD_DT_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:dt="' ||
                                                    SWINWORD_DT_NAMESPACE_URI || '" ';

  SWINWORD_VE_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:ve="' ||
                                                    SWINWORD_VE_NAMESPACE_URI || '" ';

  SWINWORD_O_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:o="' ||
                                                   SWINWORD_O_NAMESPACE_URI || '" ';

  SWINWORD_V_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:v="' ||
                                                   SWINWORD_V_NAMESPACE_URI || '" ';

  SWINWORD_W10_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:w10="' ||
                                                     SWINWORD_W10_NAMESPACE_URI || '" ';

  SWINWORD_W_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:w="' ||
                                                   SWINWORD_W_NAMESPACE_URI || '" ';

  SWINWORD_WX_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:wx="' ||
                                                    SWINWORD_WX_NAMESPACE_URI || '" ';

  SWINWORD_WSP_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:wsp="' ||
                                                     SWINWORD_WSP_NAMESPACE_URI || '" ';

  SWINWORD_SL_NAMESPACE constant PKG_STD.TSTRING := ' xmlns:sl="' ||
                                                    SWINWORD_SL_NAMESPACE_URI || '" ';

  SWINWORD_NAMESPACE constant PKG_STD.TSTRING := trim(replace(SWINWORD_AML_NAMESPACE ||
                                                              SWINWORD_DT_NAMESPACE ||
                                                              SWINWORD_VE_NAMESPACE ||
                                                              SWINWORD_O_NAMESPACE ||
                                                              SWINWORD_V_NAMESPACE ||
                                                              SWINWORD_W10_NAMESPACE ||
                                                              SWINWORD_W_NAMESPACE ||
                                                              SWINWORD_WX_NAMESPACE ||
                                                              SWINWORD_WSP_NAMESPACE ||
                                                              SWINWORD_SL_NAMESPACE,
                                                              '  ',
                                                              ' '));
  /*получить полный NAMESPACE используется если нужно обрабатывать XMLTYPE*/
  function GETWINWORD_NAMESPACE return varchar2 as
  begin
    return SWINWORD_NAMESPACE;
  end;

  /*получить W NAMESPACE используется если нужно обрабатывать XMLTYPE*/
  function GETWINWORD_W_NAMESPACE return varchar2 as
  begin
    return SWINWORD_W_NAMESPACE;
  end;



  /* Инициализация -перед любыми действиями с пакетом необходимо вызвать
     этот метод
     PAGEBREAK_IN_FIRST_PARAGRAPH - добавлять развыв страницы
     DELETE_FIELDS - удалять свойства документа
  */
  procedure PREPARE(PAGEBREAK_IN_FIRST_PARAGRAPH in boolean default false,
                    DELETE_FIELDS                in boolean default false) as
  begin
    NXMLRN                   := null;
    NDOCRN                   := null;
    NPARUS_BODYRN            := null;
    SXMLNLS_CHARSET_ID       := null;
    BPAGE_IN_FIRST_PARAGRAPH := PAGEBREAK_IN_FIRST_PARAGRAPH;

    if DELETE_FIELDS then
      NDELETE_FIELDS := 1;
    else
      NDELETE_FIELDS := 0;
    end if;

    delete from UDO_T_WINWORD_DOCPROP;
    delete from UDO_T_WINWORD_PAGES;

    delete from udo_t_winword where authid = UTILIZER();
  end;

  /*Загрузить шаблон из BLOB c указанием кодировки*/
  procedure LOAD(DATA in blob, SNLS_CHARSET_ID in varchar2) as
    C clob;
    --
    L_DEST_OFFSET   integer;
    L_SOURCE_OFFSET integer;
    L_LANG_CONTEXT  integer;
    L_WARNING       integer;
    L_BLOB_CSID     integer;
    --
  begin
    SXMLNLS_CHARSET_ID := SNLS_CHARSET_ID;
    L_BLOB_CSID        := NLS_CHARSET_ID(SXMLNLS_CHARSET_ID);
    DBMS_LOB.CREATETEMPORARY(C, true);
    L_DEST_OFFSET   := 1;
    L_SOURCE_OFFSET := 1;
    L_LANG_CONTEXT  := DBMS_LOB.DEFAULT_LANG_CTX;
    L_WARNING       := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
    DBMS_LOB.CONVERTTOCLOB(DEST_LOB     => C,
                           SRC_BLOB     => DATA,
                           AMOUNT       => DBMS_LOB.LOBMAXSIZE,
                           DEST_OFFSET  => L_DEST_OFFSET,
                           SRC_OFFSET   => L_SOURCE_OFFSET,
                           BLOB_CSID    => L_BLOB_CSID,
                           LANG_CONTEXT => L_LANG_CONTEXT,
                           WARNING      => L_WARNING);
    --
    if SNLS_CHARSET_ID <> 'CL8MSWIN1251' then
      C := replace(C,
                   '<?xml version="1.0"?>',
                   '<?xml version="1.0" encoding="windows-1251"?>');
      C := replace(C,
                   '<?xml version="1.0" encoding="UTF-8"',
                   '<?xml version="1.0" encoding="windows-1251"');
    end if;
    LOAD(C);
    DBMS_LOB.FREETEMPORARY(C);
  end;

  FUNCTION PARSE_CLOB(DATA in clob) RETURN DBMS_XMLDOM.DOMDOCUMENT AS
    PARSER DBMS_XMLPARSER.PARSER;
    DOMDOC DBMS_XMLDOM.DOMDOCUMENT;
  BEGIN
    DOMDOC := null;
    PARSER := DBMS_XMLPARSER.NEWPARSER();
    begin
      DBMS_XMLPARSER.PARSECLOB(PARSER, DATA);
      DOMDOC := DBMS_XMLPARSER.GETDOCUMENT(PARSER);
      DBMS_XMLPARSER.FREEPARSER(PARSER);
      return DOMDOC;
    exception
      when others then
        DBMS_XMLPARSER.FREEPARSER(PARSER);
        raise;
    end;
  END;

  procedure GET_TEMPLATE(DATA in out nocopy clob, templrn out number) as
    NXMLRN2 number;

    NHAVE_FLDSIMPLE number(1);
    NHAVE_INSTRTEXT number(1);
    SMD5            varchar2(50);

    DOCPROP UDO_T_WINWORD_DOCPROP_TEMPL%rowtype;
    c       clob;
    c1      clob;
    --
    DOMDOC      DBMS_XMLDOM.DOMDOCUMENT;
    DOMROOT     DBMS_XMLDOM.DOMNODE;
    DOMBODY     DBMS_XMLDOM.DOMNODE;
    DOMNM       DBMS_XMLDOM.DOMNAMEDNODEMAP;
    DOMNL1      DBMS_XMLDOM.DOMNODELIST;
    DOMNL2      DBMS_XMLDOM.DOMNODELIST;
    DOMA        DBMS_XMLDOM.DOMATTR;
    L_ATTR      DBMS_XMLDOM.DOMATTR;
    TMP_ELEM    DBMS_XMLDOM.DOMELEMENT;
    PARENT_NODE DBMS_XMLDOM.DOMNODE;
    TMP_NODE    DBMS_XMLDOM.DOMNODE;
    TMP_NODE1   DBMS_XMLDOM.DOMNODE;
    TMP_NODE2   DBMS_XMLDOM.DOMNODE;
    TMP_NODE3   DBMS_XMLDOM.DOMNODE;
  begin
    SMD5 := RAWTOHEX(SYS.DBMS_CRYPTO.HASH(DATA, SYS.DBMS_CRYPTO.HMAC_MD5));

    for CURS in (select T.RN, T.OBJECT_DATA as SDATA
                   from UDO_T_WINWORD_TEMPL T
                  where T.MD5SUM = SMD5
                    and T.KIND = 'DOCUMENT') loop
      if DBMS_LOB.COMPARE(DATA, CURS.SDATA) = 0 then
        templrn := CURS.RN;
        return;
      end if;
    end loop;

    NXMLRN2 := GEN_ID();

    DOMDOC := PARSE_CLOB(DATA);
    --

    --- если документ парсится, то сразу сохраним
    insert into UDO_T_WINWORD_TEMPL
      (RN, OBJECT_DATA, md5sum, KIND)
    values
      (NXMLRN2, DATA, SMD5, 'DOCUMENT');

    begin
      DOMROOT := DBMS_XMLDOM.MAKENODE(DBMS_XMLDOM.GETDOCUMENTELEMENT(DOMDOC));
      --работаем с тэгом w:body
      DOMBODY := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMDOC),
                                                    '/w:wordDocument/w:body',
                                                    SWINWORD_W_NAMESPACE);
      --добавим в   w:body атрибуты как у корневого элемента для сохранения w:body отдельно
      TMP_ELEM := DBMS_XMLDOM.MAKEELEMENT(DOMBODY);
      DOMNM    := DBMS_XMLDOM.GETATTRIBUTES(DOMROOT);
      if not DBMS_XMLDOM.ISNULL(DOMNM) then
        for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNM) - 1 loop
          DOMA   := DBMS_XMLDOM.MAKEATTR(DBMS_XMLDOM.ITEM(DOMNM, I));
          L_ATTR := DBMS_XMLDOM.CREATEATTRIBUTE(DOMDOC,
                                                DBMS_XMLDOM.GETNAME(DOMA));
          DBMS_XMLDOM.SETVALUE(L_ATTR, DBMS_XMLDOM.GETVALUE(DOMA));
          L_ATTR := DBMS_XMLDOM.SETATTRIBUTENODE(TMP_ELEM, L_ATTR);
        end loop;
      end if;
      --
      DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMDOC),
                                              '/w:wordDocument/o:CustomDocumentProperties/*',
                                              SWINWORD_O_NAMESPACE ||
                                              SWINWORD_W_NAMESPACE);
      if not DBMS_XMLDOM.ISNULL(DOMNL1) then
        for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
          TMP_NODE          := DBMS_XMLDOM.ITEM(DOMNL1, I);
          NHAVE_FLDSIMPLE   := 0;
          NHAVE_INSTRTEXT   := 0;
          DOCPROP.PROPNAME  := replace(DBMS_XMLDOM.GETTAGNAME(DBMS_XMLDOM.MAKEELEMENT(TMP_NODE)),
                                       DBMS_XMLDOM.GETPREFIX(TMP_NODE) || ':',
                                       '');
          DOCPROP.PROPVALUE := DBMS_XMLDOM.GETNODEVALUE(DBMS_XMLDOM.GETFIRSTCHILD(TMP_NODE));
          null;
          if trim(DOCPROP.PROPVALUE) is null then
            P_EXCEPTION(0,
                        'Ошибка! В шаблоне свойство "' || DOCPROP.PROPNAME ||
                        '" не заполнено. ' ||
                        'Заполните любым значением свойства, ' ||
                        'кроме пробелов. Затем выполните Ctrl+A затем F9');
          end if;
          ------------
          ---впихнем атрибут PARUSFLD внутрь w:instrText
          DOMNL2 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMDOC),
                                                  '/w:wordDocument/w:body//w:instrText[text()=" DOCPROPERTY  ' ||
                                                  DOCPROP.PROPNAME ||
                                                  '  \* MERGEFORMAT "]
               /ancestor::w:r[1]/following-sibling::w:r[
               count(.|
               //w:wordDocument/w:body//w:instrText[text()=" DOCPROPERTY  ' ||
                                                  DOCPROP.PROPNAME ||
                                                  '  \* MERGEFORMAT "]
               /ancestor::w:r[1]/following-sibling::w:r[.//w:fldChar/@w:fldCharType="end"][1]/preceding-sibling::w:r
               )=
               count(
               /w:wordDocument/w:body//w:instrText[text()=" DOCPROPERTY  ' ||
                                                  DOCPROP.PROPNAME ||
                                                  '  \* MERGEFORMAT "]
               /ancestor::w:r[1]/following-sibling::w:r[.//w:fldChar/@w:fldCharType="end"][1]/preceding-sibling::w:r
               )
               ]//w:t[text()="' ||
                                                  DOCPROP.PROPVALUE || '"]',
                                                  SWINWORD_W_NAMESPACE);
          if not DBMS_XMLDOM.ISNULL(DOMNL2) then
            NHAVE_INSTRTEXT := 1;
            for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL2) - 1 loop
              TMP_NODE := DBMS_XMLDOM.ITEM(DOMNL2, I);
              TMP_ELEM := DBMS_XMLDOM.MAKEELEMENT(TMP_NODE);
              L_ATTR   := DBMS_XMLDOM.CREATEATTRIBUTE(DOMDOC, 'PARUSFLD');
              DBMS_XMLDOM.SETVALUE(L_ATTR, DOCPROP.PROPNAME);
              L_ATTR := DBMS_XMLDOM.SETATTRIBUTENODE(TMP_ELEM, L_ATTR);
            end loop;
          end if;
          -----------
          ---впихнем атрибут PARUSFLD внутрь w:instrText
          DOMNL2 := DBMS_XSLPROCESSOR.SELECTNODES(DOMBODY,
                                                  './/w:fldSimple[@w:instr=" DOCPROPERTY  ' ||
                                                  DOCPROP.PROPNAME ||
                                                  '  \* MERGEFORMAT "]/w:r/w:t[text()="' ||
                                                  DOCPROP.PROPVALUE || '"]',
                                                  SWINWORD_W_NAMESPACE);
          if not DBMS_XMLDOM.ISNULL(DOMNL2) then
            NHAVE_FLDSIMPLE := 1;
            for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL2) - 1 loop
              TMP_NODE := DBMS_XMLDOM.ITEM(DOMNL2, I);
              TMP_ELEM := DBMS_XMLDOM.MAKEELEMENT(TMP_NODE);
              L_ATTR   := DBMS_XMLDOM.CREATEATTRIBUTE(DOMDOC, 'PARUSFLD');
              DBMS_XMLDOM.SETVALUE(L_ATTR, DOCPROP.PROPNAME);
              L_ATTR := DBMS_XMLDOM.SETATTRIBUTENODE(TMP_ELEM, L_ATTR);
            end loop;
          end if;
          insert into UDO_T_WINWORD_DOCPROP_TEMPL
            (DOCRN, PROPNAME, PROPVALUE, HAVE_FLDSIMPLE, HAVE_INSTRTEXT)
          values
            (NXMLRN2,
             DOCPROP.PROPNAME,
             DOCPROP.PROPVALUE,
             NHAVE_FLDSIMPLE,
             NHAVE_INSTRTEXT);
        end loop;
      end if;
      -- обнулим значения полей в PARUSFLD
      DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DOMBODY,
                                              './/w:t[@PARUSFLD]',
                                              SWINWORD_W_NAMESPACE);
      if not DBMS_XMLDOM.ISNULL(DOMNL1) then
        for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
          TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
          if DBMS_XMLDOM.hasChildNodes(TMP_NODE1) then
            TMP_NODE2 := DBMS_XMLDOM.GETFIRSTCHILD(TMP_NODE1);
            TMP_NODE2 := DBMS_XMLDOM.removeChild(TMP_NODE1, TMP_NODE2);
          end if;
        end loop;
      end if;
      ---
      DBMS_LOB.CREATETEMPORARY(C, true);
      DBMS_XMLDOM.WRITETOCLOB(DOMBODY, C);
      --это мы подготовили тело документа с сохранением полей
      --
      --теперь подготовим тело документа с исключенными полями - признак замены будет
      --только атрибут PARUSFLD
      DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DOMBODY,
                                              './/w:fldSimple',
                                              SWINWORD_W_NAMESPACE);
      if not DBMS_XMLDOM.ISNULL(DOMNL1) then
        for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
          TMP_NODE    := DBMS_XMLDOM.ITEM(DOMNL1, I);
          PARENT_NODE := DBMS_XMLDOM.getParentNode(TMP_NODE);
          TMP_NODE3   := TMP_NODE;
          TMP_NODE1   := DBMS_XMLDOM.getFirstChild(TMP_NODE);
          while not DBMS_XMLDOM.ISNULL(TMP_NODE1) loop
            TMP_NODE2 := DBMS_XMLDOM.cloneNode(TMP_NODE1, true);
            TMP_NODE2 := DBMS_XMLDOM.insertBefore(PARENT_NODE,
                                                  TMP_NODE2,
                                                  TMP_NODE);
            TMP_NODE1 := DBMS_XMLDOM.GETNEXTSIBLING(TMP_NODE1);
          end loop;
          TMP_NODE := DBMS_XMLDOM.removeChild(PARENT_NODE, TMP_NODE);
        end loop;
      end if;
      --теперь вырежем w:instrText
      DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DOMBODY,
                                              './/w:instrText[starts-with(text()," DOCPROPERTY")]',
                                              SWINWORD_W_NAMESPACE);
      if not DBMS_XMLDOM.ISNULL(DOMNL1) then
        for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
          TMP_NODE := DBMS_XMLDOM.ITEM(DOMNL1, I);
          -- удалим первый снизу w:fldChar[@w:fldCharType="end"]
          TMP_NODE1 := DBMS_XSLPROCESSOR.SELECTSINGLENODE(TMP_NODE,
                                                          './ancestor::w:r[1]/following-sibling::w:r[.//w:fldChar/@w:fldCharType="end"][1]',
                                                          SWINWORD_W_NAMESPACE);
          if not DBMS_XMLDOM.isNull(TMP_NODE1) then
            PARENT_NODE := DBMS_XMLDOM.getParentNode(TMP_NODE1);
            TMP_NODE1   := DBMS_XMLDOM.removeChild(PARENT_NODE, TMP_NODE1);
          end if;
          -- удалим первый сверху w:fldChar[@w:fldCharType="begin"]
          TMP_NODE1 := DBMS_XSLPROCESSOR.SELECTSINGLENODE(TMP_NODE,
                                                          './ancestor::w:r[1]/preceding-sibling::w:r[.//w:fldChar/@w:fldCharType="begin"][1]',
                                                          SWINWORD_W_NAMESPACE);
          if not DBMS_XMLDOM.isNull(TMP_NODE1) then
            PARENT_NODE := DBMS_XMLDOM.getParentNode(TMP_NODE1);
            TMP_NODE1   := DBMS_XMLDOM.removeChild(PARENT_NODE, TMP_NODE1);
          end if;

          PARENT_NODE := DBMS_XMLDOM.getParentNode(TMP_NODE);
          TMP_NODE    := DBMS_XMLDOM.removeChild(PARENT_NODE, TMP_NODE);
        end loop;
      end if;

      DBMS_LOB.CREATETEMPORARY(C1, true);
      DBMS_XMLDOM.WRITETOCLOB(DOMBODY, C1);

      dbms_xmldom.freeDocument(DOMDOC);
    exception
      when OTHERS then
        if not dbms_xmldom.isNull(DOMDOC) then
          dbms_xmldom.freeDocument(DOMDOC);
        end if;
        raise;
    end;

    insert into UDO_T_WINWORD_TEMPL
      (RN, PRN, OBJECT_DATA, KIND, deletefields)
    values
      (gen_id(), NXMLRN2, C, 'BODY', 0);
    DBMS_LOB.FREETEMPORARY(C);
    insert into UDO_T_WINWORD_TEMPL
      (RN, PRN, OBJECT_DATA, KIND, deletefields)
    values
      (gen_id(), NXMLRN2, C1, 'BODY', 1);
    DBMS_LOB.FREETEMPORARY(C1);

    templrn := NXMLRN2;
    commit;
  end;

  /*Загрузить шаблон из CLOB*/
  procedure LOAD(DATA in out nocopy clob) as

    NTEMPLRN number := null;
  begin
    NXMLRN        := GEN_ID();
    NPARUS_BODYRN := GEN_ID();

    get_template(DATA, NTEMPLRN);
    --если уже был такой шаблон то загрузим результаты прежнего разбора
    if NTEMPLRN is not null then

      ---
      insert into UDO_T_WINWORD
        (RN, PRN, OBJECT_DATA, KIND, authid)
        select NXMLRN, null, OBJECT_DATA, 'DOCUMENT', UTILIZER()
          from UDO_T_WINWORD_TEMPL
         where RN = NTEMPLRN;
      insert into UDO_T_WINWORD
        (RN, PRN, OBJECT_DATA, KIND, authid, deletefields)
        select NPARUS_BODYRN,
               NXMLRN,
               OBJECT_DATA,
               'BODY',
               UTILIZER(),
               deletefields
          from UDO_T_WINWORD_TEMPL
         where PRN = NTEMPLRN
           and KIND = 'BODY'
           and deletefields = NDELETE_FIELDS;
      ---

      insert into UDO_T_WINWORD_DOCPROP
        (DOCRN, PROPNAME, PROPVALUE, HAVE_FLDSIMPLE, HAVE_INSTRTEXT)
        select NXMLRN,
               T.PROPNAME,
               T.PROPVALUE,
               T.HAVE_FLDSIMPLE,
               T.HAVE_INSTRTEXT
          from UDO_T_WINWORD_DOCPROP_TEMPL T
         where DOCRN = NTEMPLRN;
      ---
      NEWPAGE;
    else
      p_exception(0, 'Ошибка в обработке шаблона!');
    end if;

  end;


  /*Установить значение для поля документа
  SDOCPROP - имя поля
  SVALUE   - значение поля
  TABLEROW - если значение поля надо записать в строки
             таблицы, добавленные APPEND_TABLEROW,
             то указывается значение возвращенное APPEND_TABLEROW
  */
  procedure SET_DOCPROPERTY(SDOCPROP in varchar2,
                            SVALUE   in varchar2,
                            TABLEROW in number default null) as
    COUNT1 number;
  begin
    select count(*)
      into COUNT1
      from UDO_T_WINWORD_DOCPROP T
     where T.DOCRN = NXMLRN
       and T.PROPNAME = SDOCPROP;
    if COUNT1 = 0 then
      P_EXCEPTION(0,
                  'Ошибка! В шаблоне документа нет свойства документа с именем "' ||
                  SDOCPROP || '"');
    end if;
    begin
      insert into UDO_T_WINWORD_DOCPROP
        (DOCRN, PROPNAME, PROPVALUE)
      values
        (nvl(TABLEROW, NDOCRN), SDOCPROP, SVALUE);
    exception
      when others then
        update UDO_T_WINWORD_DOCPROP T
           set T.PROPVALUE = SVALUE
         where T.DOCRN = nvl(TABLEROW, NDOCRN)
           and T.PROPNAME = SDOCPROP;
    end;
  end;


  /*Добавить новый шаблон в результирующий файл
    все команды после этого вызова будут применяться к этому шаблону*/
  procedure NEWPAGE as
  begin
    NDOCRN := GEN_ID();
    insert into UDO_T_WINWORD_PAGES (RN, PRN) values (NDOCRN, NXMLRN);
  end;

  /*Добавить строки из ШАБЛОНА в конец таблицы ДОКУМЕНТА
   ntablenum - порядковый номер таблицы в шаблоне (и документе)
   nbeginrow - номер начальной строки в таблице ШАБЛОНА
   nendrow   - номер конечной строки в таблице ШАБЛОНА
  */
  function APPEND_TABLEROW(ntablenum in number,
                           nbeginrow in number,
                           nendrow   in number) return number as
    nrn1 number;
  begin
    if NDOCRN is null then
      p_exception(0,
                  'Ошибка! Отсутствует активная страница.');
    end if;
    if nbeginrow > nendrow then
      p_exception(0,
                  'Ошибка! Начальная строка больше конечной.');
    end if;

    nrn1 := gen_id();
    insert into udo_t_winword_tablerow
      (rn, prn, tablenum, beginrow, endrow, action)
    values
      (nrn1, NDOCRN, ntablenum, nbeginrow, nendrow, 'A');
    return nrn1;
  end;

  /*Удалить стоки из таблицы ДОКУМЕНТА
   ntablenum - порядковый номер таблицы в шаблоне
   nbeginrow - номер начальной строки в таблице ДОКУМЕНТА (а не ШАБЛОНА)
   nendrow   - номер конечной строки в таблице ДОКУМЕНТА (а не ШАБЛОНА)
  */
  procedure DELETE_TABLEROW(ntablenum in number,
                            nbeginrow in number,
                            nendrow   in number) as
    nrn1 number;
  begin
    if NDOCRN is null then
      p_exception(0,
                  'Ошибка! Отсутствует активная страница.');
    end if;
    if nbeginrow > nendrow then
      p_exception(0,
                  'Ошибка! Начальная строка больше конечной.');
    end if;

    nrn1 := gen_id();
    insert into udo_t_winword_tablerow
      (rn, prn, tablenum, beginrow, endrow, action)
    values
      (nrn1, NDOCRN, ntablenum, nbeginrow, nendrow, 'D');
  end;


  /*Получить  преобразованный документ MS Word*/
  procedure SAVE(DATA out clob) as

    --
    DOMDOC                      DBMS_XMLDOM.DOMDOCUMENT;
    DOMPAGE                     DBMS_XMLDOM.DOMDOCUMENT;
    DOMTEMPLPAGE                DBMS_XMLDOM.DOMDOCUMENT;
    DOMTABLEROW                 DBMS_XMLDOM.DOMDOCUMENT;
    DOMBODY                     DBMS_XMLDOM.DOMNODE;
    DOMCustomDocumentProperties DBMS_XMLDOM.DOMNODE;
    DOMNL1                      DBMS_XMLDOM.DOMNODELIST;
    TMP_ELEM                    DBMS_XMLDOM.DOMELEMENT;
    L_ATTR                      DBMS_XMLDOM.DOMATTR;
    TMP_NODE1                   DBMS_XMLDOM.DOMNODE;
    TMP_NODE2                   DBMS_XMLDOM.DOMNODE;
    TMP_TABLE                   DBMS_XMLDOM.DOMNODE;
    TMP_ROOT                    DBMS_XMLDOM.DOMNODE;
    --
    c         clob;
    emptybody clob;

    --
    s      varchar2(4000);
    count1 number;

    procedure set_docprop(DOMPAGE         in DBMS_XMLDOM.DOMDOCUMENT,
                          nprop_rn        in number,
                          spropname       in varchar2,
                          spropvalue      in varchar2,
                          nhave_fldsimple in number default 1,
                          nHAVE_INSTRTEXT in number default 1) as
      DOMNL1    DBMS_XMLDOM.DOMNODELIST;
      TMP_ELEM  DBMS_XMLDOM.DOMELEMENT;
      L_ATTR    DBMS_XMLDOM.DOMATTR;
      TMP_NODE1 DBMS_XMLDOM.DOMNODE;
      TMP_NODE2 DBMS_XMLDOM.DOMNODE;

    begin

      --  добавим новое свойство документа
      if NDELETE_FIELDS = 0 then
        TMP_ELEM  := DBMS_XMLDOM.createElement(DOMDOC,
                                               'o:' || spropname ||
                                               TO_CHAR(nprop_rn));
        TMP_NODE1 := DBMS_XMLDOM.makeNode(TMP_ELEM);

        L_ATTR := DBMS_XMLDOM.CREATEATTRIBUTE(DOMDOC, 'dt:dt');
        DBMS_XMLDOM.SETVALUE(L_ATTR, 'string');
        L_ATTR := DBMS_XMLDOM.SETATTRIBUTENODE(TMP_ELEM, L_ATTR);

        TMP_NODE1 := DBMS_XMLDOM.appendChild(DOMCustomDocumentProperties,
                                             TMP_NODE1);
        TMP_NODE2 := DBMS_XMLDOM.makeNode(dbms_xmldom.createTextNode(DOMDOC,
                                                                     spropvalue));
        TMP_NODE2 := DBMS_XMLDOM.appendChild(TMP_NODE1, TMP_NODE2);
      end if;
      ---
      --заменим значения
      --может нету этого поля в тексте документа - так может и не чесаться
      if nhave_fldsimple = 1 or nHAVE_INSTRTEXT = 1 then
        DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMPAGE),
                                                '/w:body//w:t[@PARUSFLD="' ||
                                                spropname || '"]',
                                                SWINWORD_W_NAMESPACE);
        if not DBMS_XMLDOM.ISNULL(DOMNL1) then
          for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
            TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
            DBMS_XMLDOM.removeAttribute(DBMS_XMLDOM.makeElement(TMP_NODE1),
                                        'PARUSFLD');
            TMP_NODE2 := DBMS_XMLDOM.makeNode(dbms_xmldom.createTextNode(DOMPAGE,
                                                                         spropvalue));
            TMP_NODE2 := DBMS_XMLDOM.appendChild(TMP_NODE1, TMP_NODE2);

          end loop;
        end if;
      end if;
      --
      if nhave_fldsimple = 1 and NDELETE_FIELDS = 0 then
        --надо заменить названия полей
        DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMPAGE),
                                                '/w:body//w:fldSimple[@w:instr=" DOCPROPERTY  ' ||
                                                spropname ||
                                                '  \* MERGEFORMAT "]/@w:instr',
                                                SWINWORD_W_NAMESPACE);
        if not DBMS_XMLDOM.ISNULL(DOMNL1) then
          for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
            TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
            DBMS_XMLDOM.setNodeValue(TMP_NODE1,
                                     ' DOCPROPERTY  ' || spropname ||
                                     TO_CHAR(nprop_rn) ||
                                     '  \* MERGEFORMAT ');
          end loop;
        end if;
      end if; --curs1.have_fldsimple = 1 and NDELETE_FIELDS=0
      --
      if nHAVE_INSTRTEXT = 1 and NDELETE_FIELDS = 0 then
        --надо заменить названия полей
        DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMPAGE),
                                                '/w:body//w:instrText[text()=" DOCPROPERTY  ' ||
                                                spropname ||
                                                '  \* MERGEFORMAT "]/text()',
                                                SWINWORD_W_NAMESPACE);
        if not DBMS_XMLDOM.ISNULL(DOMNL1) then
          for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
            TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
            DBMS_XMLDOM.setNodeValue(TMP_NODE1,
                                     ' DOCPROPERTY  ' || spropname ||
                                     TO_CHAR(nprop_rn) ||
                                     '  \* MERGEFORMAT ');
          end loop;
        end if;
      end if; --curs1.HAVE_INSTRTEXT = 1 and NDELETE_FIELDS=0

    end;

  begin
    select t.object_data into c from udo_t_winword t where T.RN = NXMLRN;
    DOMDOC := parse_clob(c);
    begin
      DOMBODY := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMDOC),
                                                    '/w:wordDocument/w:body',
                                                    SWINWORD_W_NAMESPACE);
      --
      if NDELETE_FIELDS = 0 then
        DOMCustomDocumentProperties := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMDOC),
                                                                          '/w:wordDocument/o:CustomDocumentProperties',
                                                                          SWINWORD_W_NAMESPACE ||
                                                                          SWINWORD_O_NAMESPACE);
      end if;

      TMP_NODE1 := DBMS_XMLDOM.GETFIRSTCHILD(DOMBODY);
      while not DBMS_XMLDOM.ISNULL(TMP_NODE1) loop
        TMP_NODE2 := TMP_NODE1;
        TMP_NODE1 := DBMS_XMLDOM.GETNEXTSIBLING(TMP_NODE1);
        TMP_NODE2 := DBMS_XMLDOM.removeChild(DOMBODY, TMP_NODE2);
        DBMS_XMLDOM.freeNode(TMP_NODE2);
      end loop;

      select object_data
        into c
        from UDO_T_WINWORD t
       where PRN = NXMLRN
         and rn = NPARUS_BODYRN
         and KIND = 'BODY'
            --   and t.deletefields = NDELETE_FIELDS
         and authid = UTILIZER();
      --подготовим пустой body
      DOMTEMPLPAGE := parse_clob(c);
      begin
        TMP_NODE1 := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMTEMPLPAGE),
                                                        '/w:body',
                                                        SWINWORD_W_NAMESPACE);

        TMP_NODE1 := DBMS_XMLDOM.GETFIRSTCHILD(TMP_NODE1);
        while not DBMS_XMLDOM.ISNULL(TMP_NODE1) loop

          TMP_NODE2 := TMP_NODE1;
          TMP_NODE1 := DBMS_XMLDOM.GETNEXTSIBLING(TMP_NODE1);
          TMP_NODE2 := DBMS_XMLDOM.removeChild(DBMS_XMLDOM.MAKENODE(DOMTEMPLPAGE),
                                               TMP_NODE2);
          DBMS_XMLDOM.freeNode(TMP_NODE2);
        end loop;
        dbms_lob.createtemporary(emptybody, true);
        DBMS_XMLDOM.writeToClob(DOMTEMPLPAGE, emptybody);

        dbms_xmldom.freeDocument(DOMTEMPLPAGE);
      exception
        when others then
          if not dbms_xmldom.isNull(DOMTEMPLPAGE) then
            dbms_xmldom.freeDocument(DOMTEMPLPAGE);
          end if;
          raise;
      end;

      for curs in (select rn,
                          decode(t.rn,
                                 (select min(rn)
                                    from UDO_T_WINWORD_PAGES t
                                   where t.prn = NXMLRN),
                                 1,
                                 0) as is_first,
                          decode(t.rn,
                                 (select max(rn)
                                    from UDO_T_WINWORD_PAGES t
                                   where t.prn = NXMLRN),
                                 1,
                                 0) as is_last
                     from UDO_T_WINWORD_PAGES t
                    where t.prn = NXMLRN
                    order by rn) loop

        DOMPAGE := parse_clob(c);
        begin
          -- всякие преобразования

          --сначала добавим разрывы страницы
          s := null;
          if BPAGE_IN_FIRST_PARAGRAPH = false and curs.is_last = 0 then
            s := '/w:body/descendant-or-self::w:p[last()]';
          end if;
          if BPAGE_IN_FIRST_PARAGRAPH = true and curs.is_first = 0 then
            s := '/w:body/descendant-or-self::w:p[1]';
          end if;
          if s is not null then
            TMP_NODE1 := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMPAGE),
                                                            s,
                                                            SWINWORD_W_NAMESPACE);
            if not DBMS_XMLDOM.isNull(TMP_NODE1) then
              TMP_ELEM  := DBMS_XMLDOM.createElement(DOMPAGE, 'w:r');
              TMP_NODE2 := DBMS_XMLDOM.appendChild(TMP_NODE1,
                                                   DBMS_XMLDOM.makeNode(TMP_ELEM));
              TMP_ELEM  := DBMS_XMLDOM.createElement(DOMPAGE, 'w:br');
              --
              L_ATTR := DBMS_XMLDOM.CREATEATTRIBUTE(DOMPAGE, 'w:type');
              DBMS_XMLDOM.SETVALUE(L_ATTR, 'page');
              L_ATTR := DBMS_XMLDOM.SETATTRIBUTENODE(TMP_ELEM, L_ATTR);
              --
              TMP_NODE1 := DBMS_XMLDOM.appendChild(TMP_NODE2,
                                                   DBMS_XMLDOM.makeNode(TMP_ELEM));
              --<w:br w:type="page"/>
            end if;
          end if;

          -- пройдемся по свойствам страницы

          for curs1 in (select Tt1.PROPNAME,
                               Tt1.PROPVALUE as templateVALUE,
                               Tt1.HAVE_FLDSIMPLE,
                               Tt1.HAVE_INSTRTEXT,
                               nvl(tt2.PROPVALUE, ' ') as PROPVALUE
                          from (select T1.PROPNAME,
                                       T1.PROPVALUE,
                                       T1.HAVE_FLDSIMPLE,
                                       T1.HAVE_INSTRTEXT
                                  from UDO_T_WINWORD_DOCPROP T1
                                 where T1.DOCRN = NXMLRN) tt1,
                               (select T2.PROPNAME, T2.PROPVALUE
                                  from UDO_T_WINWORD_DOCPROP T2
                                 where T2.DOCRN = curs.rn) tt2
                         where tt1.propname = tt2.propname(+)) loop
            set_docprop(DOMPAGE,
                        curs.rn,
                        curs1.PROPNAME,
                        curs1.propvalue,
                        curs1.have_fldsimple,
                        curs1.HAVE_INSTRTEXT);
          end loop;

          --а вот теперь будем работать с таблицами

          select count(*)
            into count1
            from dual
           where exists (select null
                    from udo_t_winword_tablerow t
                   where t.prn = curs.rn);
          if count1 <> 0 then
            --таки были таблицы на странице
            --можно в самом начале отпарсить шаблон, но мне как-то лениво хорошо писать
            --это теперь надо написать быстро

            DOMTEMPLPAGE := parse_clob(c);
            begin
              for curs1 in (select t.rn,
                                   t.tablenum,
                                   t.beginrow,
                                   t.endrow,
                                   t.action
                              from udo_t_winword_tablerow t
                             where t.prn = curs.rn
                             order by rn) loop
                --удалить строки
                if curs1.action = 'D' then
                  --я в xpath не помню как с по  отбирать
                  DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMPAGE),
                                                          '/w:body/descendant-or-self::w:tbl[' ||
                                                          to_char(curs1.tablenum) ||
                                                          ']/w:tr',
                                                          SWINWORD_W_NAMESPACE);
                  if not DBMS_XMLDOM.ISNULL(DOMNL1) then

                    for I in reverse greatest(0, curs1.beginrow - 1) .. (least(curs1.endrow,
                                                                               DBMS_XMLDOM.GETLENGTH(DOMNL1)) - 1) loop
                      TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
                      TMP_NODE2 := DBMS_XMLDOM.removeChild(DBMS_XMLDOM.getParentNode(TMP_NODE1),
                                                           TMP_NODE1);
                      DBMS_XMLDOM.freeNode(TMP_NODE2);
                    end loop;
                  end if;
                end if;
                ---
                if curs1.action = 'A' then
                  --создадим новый "чистенький" документ (с нужными пространствами имен)

                  DOMTABLEROW := parse_clob(emptybody);
                  begin
                    TMP_ROOT := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMTABLEROW),
                                                                   '/w:body',
                                                                   SWINWORD_W_NAMESPACE);
                    --начали копировать строки из шаблонного тела документа
                    DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMTEMPLPAGE),
                                                            '/w:body/descendant-or-self::w:tbl[' ||
                                                            to_char(curs1.tablenum) ||
                                                            ']/w:tr',
                                                            SWINWORD_W_NAMESPACE);
                    if not DBMS_XMLDOM.ISNULL(DOMNL1) then
                      for I in greatest(0, curs1.beginrow - 1) .. (least(curs1.endrow,
                                                                         DBMS_XMLDOM.GETLENGTH(DOMNL1)) - 1) loop

                        TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
                        TMP_NODE2 := DBMS_XMLDOM.importnode(DOMTABLEROW,
                                                            TMP_NODE1,
                                                            true);
                        TMP_NODE2 := DBMS_XMLDOM.appendChild(TMP_ROOT,
                                                             TMP_NODE2);

                      end loop;
                    end if;

                    --закончили копировать
                    --а теперь установим свойства в этом новодобавляемом row
                    for curs2 in (select Tt1.PROPNAME,
                                         Tt1.PROPVALUE as templateVALUE,
                                         Tt1.HAVE_FLDSIMPLE,
                                         Tt1.HAVE_INSTRTEXT,
                                         nvl(tt2.PROPVALUE, ' ') as PROPVALUE
                                    from (select T1.PROPNAME,
                                                 T1.PROPVALUE,
                                                 T1.HAVE_FLDSIMPLE,
                                                 T1.HAVE_INSTRTEXT
                                            from UDO_T_WINWORD_DOCPROP T1
                                           where T1.DOCRN = NXMLRN) tt1,
                                         (select T2.PROPNAME, T2.PROPVALUE
                                            from UDO_T_WINWORD_DOCPROP T2
                                           where T2.DOCRN = curs1.rn) tt2
                                   where tt1.propname = tt2.propname) loop
                      set_docprop(DOMTABLEROW,
                                  curs1.rn,
                                  curs2.PROPNAME,
                                  curs2.propvalue,
                                  curs2.have_fldsimple,
                                  curs2.HAVE_INSTRTEXT);
                    end loop;

                    --с заменами покончено
                    --теперь надо добавить готовые тэги w:tr на страницу
                    TMP_TABLE := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMPAGE),
                                                                    '/w:body/descendant-or-self::w:tbl[' ||
                                                                    to_char(curs1.tablenum) || ']',
                                                                    SWINWORD_W_NAMESPACE);
                    if not DBMS_XMLDOM.isNull(TMP_TABLE) then

                      TMP_NODE1 := DBMS_XSLPROCESSOR.SELECTSINGLENODE(DBMS_XMLDOM.MAKENODE(DOMTABLEROW),
                                                                      '/w:body',
                                                                      SWINWORD_W_NAMESPACE);
                      TMP_NODE1 := DBMS_XMLDOM.GETFIRSTCHILD(TMP_NODE1);

                      while not DBMS_XMLDOM.ISNULL(TMP_NODE1) loop

                        TMP_NODE2 := DBMS_XMLDOM.importnode(DOMPAGE,
                                                            TMP_NODE1,
                                                            true);
                        TMP_NODE2 := DBMS_XMLDOM.appendChild(TMP_TABLE,
                                                             TMP_NODE2);
                        TMP_NODE1 := DBMS_XMLDOM.GETNEXTSIBLING(TMP_NODE1);
                      end loop;
                    end if;
                    --закончили копировать на страницу
                    --
                    dbms_xmldom.freeDocument(DOMTABLEROW);
                  exception
                    when others then
                      if not dbms_xmldom.isNull(DOMTABLEROW) then
                        dbms_xmldom.freeDocument(DOMTABLEROW);
                      end if;
                      raise;
                  end;
                end if;

                null;
              end loop;
              null;
              dbms_xmldom.freeDocument(DOMTEMPLPAGE);
            exception
              when others then
                if not dbms_xmldom.isNull(DOMTEMPLPAGE) then
                  dbms_xmldom.freeDocument(DOMTEMPLPAGE);
                end if;
                raise;
            end;
          end if;
          --!а вот теперь будем работать с таблицами

          --! всякие преобразования
          --скопировать в результирующий
          TMP_NODE1 := DBMS_XMLDOM.GETFIRSTCHILD(DBMS_XMLDOM.MAKENODE(DBMS_XMLDOM.GETDOCUMENTELEMENT(DOMPAGE)));
          while not DBMS_XMLDOM.ISNULL(TMP_NODE1) loop
            TMP_NODE2 := DBMS_XMLDOM.importnode(DOMDOC, TMP_NODE1, true);
            TMP_NODE2 := DBMS_XMLDOM.appendChild(DOMBODY, TMP_NODE2);
            TMP_NODE1 := DBMS_XMLDOM.GETNEXTSIBLING(TMP_NODE1);
          end loop;
          --

          dbms_xmldom.freeDocument(DOMPAGE);
        exception
          when others then
            if not dbms_xmldom.isNull(DOMPAGE) then
              dbms_xmldom.freeDocument(DOMPAGE);
            end if;
            raise;
        end;
      end loop;

      DBMS_LOB.CREATETEMPORARY(data, true);
      DBMS_XMLDOM.WRITETOCLOB(DOMDOC, data);

      dbms_xmldom.freeDocument(DOMDOC);

    exception
      when others then
        if not dbms_xmldom.isNull(DOMDOC) then
          dbms_xmldom.freeDocument(DOMDOC);
        end if;
        raise;
    end;
    dbms_lob.freetemporary(emptybody);
  end;


  /*Весь текст в ячейках таблиц шаблона будут заменены на значение
    T<номер таблицы>R<номер строки в таблице>C<номер ячейки в строке>
    Это необходимо если шаблон содержит скрытые таблицы
    Нужно для корректных вызовов APPEND_TABLEROW и DELETE_TABLEROW
    */
  procedure SHOWTABLEDEBUG(DATA out clob) as

    DOMDOC                      DBMS_XMLDOM.DOMDOCUMENT;

    DOMNL1    DBMS_XMLDOM.DOMNODELIST;
    TMP_NODE1 DBMS_XMLDOM.DOMNODE;

    DOMNL2    DBMS_XMLDOM.DOMNODELIST;
    TMP_NODE2 DBMS_XMLDOM.DOMNODE;

    DOMNL3    DBMS_XMLDOM.DOMNODELIST;
    TMP_NODE3 DBMS_XMLDOM.DOMNODE;

    DOMNL4    DBMS_XMLDOM.DOMNODELIST;
    TMP_NODE4 DBMS_XMLDOM.DOMNODE;

    DOMNL5    DBMS_XMLDOM.DOMNODELIST;
    TMP_NODE5 DBMS_XMLDOM.DOMNODE;

    TMP_TEXT_NODE DBMS_XMLDOM.DOMNODE;

    TMP_NODE DBMS_XMLDOM.DOMNODE;
    TMP_ELEM DBMS_XMLDOM.DOMELEMENT;

    c clob;

  begin

    select t.object_data into c from udo_t_winword t where T.RN = NXMLRN;
    DOMDOC := parse_clob(c);
    begin
      DOMNL1 := DBMS_XSLPROCESSOR.SELECTNODES(DBMS_XMLDOM.MAKENODE(DOMDOC),
                                              '/w:wordDocument/w:body/descendant-or-self::w:tbl',
                                              SWINWORD_W_NAMESPACE);
      if not DBMS_XMLDOM.ISNULL(DOMNL1) then
        for I in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL1) - 1 loop
          TMP_NODE1 := DBMS_XMLDOM.ITEM(DOMNL1, I);
          --
          DOMNL2 := DBMS_XSLPROCESSOR.SELECTNODES(TMP_NODE1,
                                                  './/w:tr',
                                                  SWINWORD_W_NAMESPACE);
          if not DBMS_XMLDOM.ISNULL(DOMNL2) then
            for J in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL2) - 1 loop
              TMP_NODE2 := DBMS_XMLDOM.ITEM(DOMNL2, J);
              --
              DOMNL3 := DBMS_XSLPROCESSOR.SELECTNODES(TMP_NODE2,
                                                      './/w:tc',
                                                      SWINWORD_W_NAMESPACE);
              if not DBMS_XMLDOM.ISNULL(DOMNL3) then
                for K in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL3) - 1 loop
                  TMP_NODE3 := DBMS_XMLDOM.ITEM(DOMNL3, K);

                  DOMNL4 := DBMS_XSLPROCESSOR.SELECTNODES(TMP_NODE3,
                                                          './/w:t',
                                                          SWINWORD_W_NAMESPACE);
                  if not DBMS_XMLDOM.ISNULL(DOMNL4) then
                    for L in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL4) - 1 loop
                      TMP_NODE4     := DBMS_XMLDOM.ITEM(DOMNL4, L);
                      TMP_TEXT_NODE := DBMS_XMLDOM.getFirstChild(TMP_NODE4);
                      DBMS_XMLDOM.setNodeValue(TMP_TEXT_NODE,
                                               'T' || to_char(i + 1) || 'R' ||
                                               to_char(j + 1) || 'C' ||
                                               to_char(k + 1));
                    end loop; --L
                  else
                    null; --вставка <w:r><w:t>
                    DOMNL5 := DBMS_XSLPROCESSOR.SELECTNODES(TMP_NODE3,
                                                            './/w:p',
                                                            SWINWORD_W_NAMESPACE);
                    if not DBMS_XMLDOM.ISNULL(DOMNL5) then
                      for L in 0 .. DBMS_XMLDOM.GETLENGTH(DOMNL5) - 1 loop
                        TMP_NODE5     := DBMS_XMLDOM.ITEM(DOMNL5, L);
                        TMP_ELEM      := DBMS_XMLDOM.CREATEELEMENT(DOMDOC,
                                                                   'w:r');
                        TMP_NODE      := DBMS_XMLDOM.makeNode(TMP_ELEM);
                        TMP_NODE5     := DBMS_XMLDOM.appendChild(TMP_NODE5,
                                                                 TMP_NODE);
                        TMP_ELEM      := DBMS_XMLDOM.CREATEELEMENT(DOMDOC,
                                                                   'w:t');
                        TMP_NODE      := DBMS_XMLDOM.makeNode(TMP_ELEM);
                        TMP_NODE      := DBMS_XMLDOM.appendChild(TMP_NODE5,
                                                                 TMP_NODE);
                        TMP_TEXT_NODE := DBMS_XMLDOM.MAKENODE(DBMS_XMLDOM.CREATETEXTNODE(DOMDOC,
                                                                                         'T' ||
                                                                                         to_char(i + 1) || 'R' ||
                                                                                         to_char(j + 1) || 'C' ||
                                                                                         to_char(k + 1)));
                        TMP_TEXT_NODE := DBMS_XMLDOM.appendChild(TMP_NODE,
                                                                 TMP_TEXT_NODE);
                      end loop; --L
                      else
                        --не хочу я дальше добавлять тэги
                        p_exception(0,'Ошибка! В таблице '||to_char(I)|| ' строка '
                        ||to_char(J)||' ячейка '||to_char(K) ||' нет параграфа. Исправьте шаблон, напишите любой текст в ячейку');
                    end if; --DOMNL5
                  end if; --DOMNL4

                end loop; --K
              end if; --DOMNL3
            --
            end loop; --J
          end if; --DOMNL2
        --
        end loop; --I
      end if; --DOMNL1

      DBMS_LOB.CREATETEMPORARY(data, true);
      DBMS_XMLDOM.WRITETOCLOB(DOMDOC, data);
      dbms_xmldom.freeDocument(DOMDOC);
      null;
    exception
      when others then
        if not dbms_xmldom.isNull(DOMDOC) then
          dbms_xmldom.freeDocument(DOMDOC);
        end if;
        raise;
    end;
  end;

end UDO_PKG_WINWORD;
/

