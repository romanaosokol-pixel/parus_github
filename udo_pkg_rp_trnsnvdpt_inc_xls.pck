create or replace package 
UDO_PKG_RP_TRNSNVDPT_INC_XLS
is
  
  /* Формирование отчет */
  procedure XLS_MAKE
  (
    NCOMPANY          in number,     -- Организация
    NIDENT            in number,     -- ИД помеченных записей  
    SRAZDEL           in varchar2    -- Раздел
  );
  
end UDO_PKG_RP_TRNSNVDPT_INC_XLS;
/
create or replace package body UDO_PKG_RP_TRNSNVDPT_INC_XLS
/*
Отчет. Журнал регистрации ТМЦ на Входной Контроль
05/07/2024 Степанов М. Добавил Дату перепроверки
*/
 is

  SHEET_DATA     PKG_STD.TSTRING := 'TDSheet'; -- Титульный лист.
  LINE_DATA      PKG_STD.TSTRING := 'ДАННЫЕ'; -- Линия отчета с данными
  ILINE_DATA_BEG integer := 3; -- Номер начальной строки

  /* Выбор листа и Объявление ячеек листа  */
  procedure CELL_DESCRIBE_SHEET_DATA is
  begin
    PRSG_EXCEL.SHEET_SELECT(SHEET_DATA);
    /* Параметры отчета */
    --PRSG_EXCEL.CELL_DESCRIBE(SZAG_PR);
    PRSG_EXCEL.LINE_DESCRIBE(LINE_DATA);
  end;

  /* Запись значения ячеек строки таблицы */
  procedure TABCELL_WRITE
  (
    NCOLUMN   in varchar2, -- Имя колонки в отчете
    SROW_NAME in varchar2, -- Имя строки в отчете
    SVALUE    in varchar2 := null, -- Значение (строка)
    NVALUE    in number := null, -- Значение (число)
    SFORMULA  in varchar2 := null -- формула
  ) is
    SXLSNAME PKG_STD.TSTRING; -- Имя ячейки на Excel-листе
  begin
    SXLSNAME := NCOLUMN || SROW_NAME;
    PRSG_EXCEL.CELL_DESCRIBE(SXLSNAME);
    case
      when SVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(SXLSNAME, SVALUE);
      when NVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(SXLSNAME, NVALUE);
      when SFORMULA is not null then
        PRSG_EXCEL.CELL_FORMULA_WRITE(SXLSNAME, SFORMULA);
      else
        null;
    end case;
  
  end TABCELL_WRITE;

  procedure SHEET_DATA_MAKE
  (
    NCOMPANY in number, -- Организация
    NRN      in number  -- Рег. номер ПО
  ) is
    NPP        PKG_STD.TNUMBER := 0; -- Порядковый номер записи контрактов
    IXLSNAME   PKG_STD.TNUMBER; -- Номер ячейки 
    NLINE_CONT PKG_STD.TNUMBER; -- Порядковый номер линии договоров  
    DSYSDAT    PKG_STD.TSTRING := TO_CHAR(sysdate, 'dd.mm.yyyy');
    sModif     PKG_STD.TSTRING;
  begin
    /* Объявление ячеек */
    CELL_DESCRIBE_SHEET_DATA;

    /* Данные */
    for CUR in (select TO_CHAR(T.DOCDATE, 'dd.mm.yyyy') DOCDATE,
                       N.NOMEN_NAME, m.modif_name,
                       UDO_F_TRANSINVDEPT_EXTNUMB(NRN => T.RN) DOC,
                       UDO_PKG_TRINVDEPSPECS_PROPS.PRODUCER(NRN => SP.RN) PRODUCER,
                       UDO_PKG_TRINVDEPSPECS_PROPS.SERNUMBER(NRN => SP.RN) SERNUMBER,
                       SP.QUANT,
                       UDO_PKG_TRINVDEPSPECS_PROPS.PROD_DATE(NRN => SP.RN) PROD_DATE,
                       /* 05/07/2024 Степанов М. Добавил Дату перепроверки */
                       USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(NRN         => SP.GOODSPARTY
                                                                          ,NFLAGSMART  => 1
                                                                          ,NDOCS_PROPS => 134301298) as RECHECK_DATE 
                  from TRANSINVDEPT      T,
                       TRANSINVDEPTSPECS SP,
                       NOMMODIF          M,
                       DICNOMNS          N
                 where T.RN = NRN
                   and T.COMPANY = NCOMPANY
                   and SP.PRN = T.RN
                   and SP.NOMMODIF = M.RN
                   and M.PRN = N.RN
                union all
                select TO_CHAR(T.INDOCDATE, 'dd.mm.yyyy') DOCDATE,
                       N.NOMEN_NAME, m.modif_name,
                       /*INVDOCTYPE ||*/ trim(T.INVDOCNUMB) || ', ' || to_char(T.INVDOCDATE, 'DD.MM.YYYY') DOC,
                       ag.agnname PRODUCER,
                       SP.SERNUMB SERNUMBER,
                       SP.FACTQUANT,
                       F_DOCS_PROPS_BASE_STR_VALUE(nPROPERTY => 12114824,
                                                   sUNITCODE => 'IncomingOrdersSpecs',
                                                   nDOCUMENT => sp.RN) PROD_DATE,
                       /* 05/07/2024 Степанов М. Добавил Дату перепроверки */                                                   
                       F_DOCS_PROPS_BASE_STR_VALUE(nPROPERTY => 134301298,
                                                   sUNITCODE => 'IncomingOrdersSpecs',
                                                   nDOCUMENT => sp.RN) RECHECK_DATE
                  from INORDERS     T, 
                       INORDERSPECS SP,
                       NOMMODIF     M,
                       DICNOMNS     N,
                       agnlist      ag
                 where T.RN = NRN
                   and T.COMPANY = NCOMPANY
                   and SP.PRN = T.RN
                   and SP.NOMMODIF = M.RN
                   and M.PRN = N.RN   
                   and ag.rn = t.CONTRAGENT
                 order by NOMEN_NAME    
    ) loop
      sModif := SUBSTR(cur.modif_name, INSTR(cur.modif_name, '_')+1);
      /* Формирование номера строки */
      case NPP
        when 0 then
             NLINE_CONT := PRSG_EXCEL.LINE_APPEND(LINE_DATA);
        else NLINE_CONT := PRSG_EXCEL.LINE_CONTINUE(LINE_DATA);
      end case;
      NPP := NPP + 1;
      IXLSNAME := ILINE_DATA_BEG + NLINE_CONT;
      TABCELL_WRITE(NCOLUMN => 'A', SROW_NAME => IXLSNAME, SVALUE => CUR.DOCDATE);
      TABCELL_WRITE(NCOLUMN => 'B', SROW_NAME => IXLSNAME, SVALUE => CUR.NOMEN_NAME ||' ('||sModif||')'); --nomen_code);
      if length(CUR.DOC) > 0 then
           TABCELL_WRITE(NCOLUMN => 'C', SROW_NAME => IXLSNAME, SVALUE => CUR.DOC || CHR(13) || CUR.PRODUCER);
      else TABCELL_WRITE(NCOLUMN => 'C', SROW_NAME => IXLSNAME, SVALUE => CUR.PRODUCER);
      end if;
      TABCELL_WRITE(NCOLUMN => 'D', SROW_NAME => IXLSNAME, SVALUE => CUR.SERNUMBER || ' /' || CUR.QUANT);
      TABCELL_WRITE(NCOLUMN => 'E', SROW_NAME => IXLSNAME, SVALUE => strcombine(CUR.PROD_DATE, CUR.RECHECK_DATE, '/ ')); /* 05/07/2024 Степанов М. Добавил Дату перепроверки */
      TABCELL_WRITE(NCOLUMN => 'H', SROW_NAME => IXLSNAME, SVALUE => 'Соответствует');
      TABCELL_WRITE(NCOLUMN => 'I', SROW_NAME => IXLSNAME, SVALUE => DSYSDAT);
    
    end loop;
  
    PRSG_EXCEL.LINE_DELETE(LINE_DATA);
  end SHEET_DATA_MAKE;

  /* Формирование отчет */
  procedure XLS_MAKE
  (
    NCOMPANY in number, -- Организация
    NIDENT   in number, -- ИД помеченных записей  
    SRAZDEL  in varchar2
  ) is

  SUNITCODE PKG_STD.TSTRING := SRAZDEL; --'GoodsTransInvoicesToDepts' or 'IncomingOrders'
  begin
    for DD in (select S.DOCUMENT
                 from SELECTLIST S
                where S.IDENT = NIDENT
                  and S.UNITCODE = SUNITCODE
                  and ROWNUM = 1)
    loop
      SHEET_DATA_MAKE(NCOMPANY => NCOMPANY, NRN => DD.DOCUMENT);
    end loop;
  end XLS_MAKE;

end UDO_PKG_RP_TRNSNVDPT_INC_XLS;
/
