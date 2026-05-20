create or replace procedure UDO_REP_INORDERS_VEDOMOST(
  nCOMPANY           in number,   -- Организация
  nIDENT             in number,   -- Отмеченные записи накладных
  sRazd              in varchar2, -- Раздел из которого запускается отчет
  sSysDate           in number    -- Печатать дату в заголовке
) is
 -- 26/06/2023 Хохряков А.В.
 ----Переменные отчета "Ведомость приема-передачи документов для бухгалтерии"
  C_SLIST    constant PKG_STD.tSTRING := 'Лист1'; 
  C_sNameFrom constant PKG_STD.tSTRING := 'Name_From';
  C_sNameTo   constant PKG_STD.tSTRING := 'Name_To';
  sDate         constant PKG_STD.tSTRING := 'sDate';  

  LL_LINE    constant PKG_STD.tSTRING := 'L_Line';
  C_nPP      constant PKG_STD.tSTRING := 'nPP';
  C_sOrd     constant PKG_STD.tSTRING := 'sOrd';
  C_dOrd     constant PKG_STD.tSTRING := 'dOrd';
  C_sPost    constant PKG_STD.tSTRING := 'sPost';
  C_nSumm    constant PKG_STD.tSTRING := 'nSumm';
  C_sForm    constant PKG_STD.tSTRING := 'sForm';
  C_sDoc     constant PKG_STD.tSTRING := 'sDoc';
  C_sDocPost constant PKG_STD.tSTRING := 'sDocPost';
  C_dDocPost constant PKG_STD.tSTRING := 'dDocPost';

  nSTR       number;
  nRow       integer := 0;
  sFrom      USERLIST.NAME%type;
  sOrig      PKG_STD.tSTRING;

  nNumber    pkg_std.tnumber; 
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => C_SLIST);
  
  PRSG_EXCEL.CELL_DESCRIBE(C_sNameFrom);
  PRSG_EXCEL.CELL_DESCRIBE(C_sNameTo);
  PRSG_EXCEL.CELL_DESCRIBE(sDate);  

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sOrd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dOrd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPost);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSumm);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sForm);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDoc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDocPost);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dDocPost);

  for rec in(
      select ord.rn ord_nrn, dt1.doccode || ', ' || trim(ord.indocpref) || '-' || trim(ord.indocnumb) DocNum, 
             to_char(ord.indocdate, 'DD.MM.YYYY') indocdate, inv.SUMMTAX, -- сумма с НДС из накладной
             dt2.doccode invDocCode, trim(ord.invdocnumb) InvDocNum,
             to_char(ord.invdocdate, 'DD.MM.YYYY') invdocdate,
             ag.agnname, dt0.doccode sUPD,
             inv.rn as inv_rn
/*            ,(select distinct case fl.file_type when 7618744 then 'Оригинал (1)' when 80802744 then 'Копия (1)' else '-' end 
               from FILELINKSUNITS un,
                    FILELINKS      fl
              where un.table_prn = inv.rn
                and fl.rn        = un.FILELINKS_PRN
                and rownum = 1
              \*order by fl.load_date desc*\) as sOrig*/
      from SELECTLIST sl,
           INORDERS   ord,
           DOCTYPES   dt1,
           DOCTYPES   dt2,
           AGNLIST    ag,
           DOCLINKS   dl,
           ININVOICES inv,
           DOCTYPES   dt0
      where sl.ident = nIDENT
        and sl.document = ord.rn
        and ord.company = UDO_REP_INORDERS_VEDOMOST.nCOMPANY
        and dt1.rn = ord.indoctype
        and dt2.rn (+)= ord.invdoctype
        and ag.rn = ord.contragent
        and dl.out_document = ord.rn and dl.out_unitcode = 'IncomingOrders'
        and dl.in_unitcode = 'IncomingInvoices' and dl.in_document = inv.rn
        and dt0.rn = inv.doctype
      order by /*ord.indocdate, */ord.indocpref, ord.indocnumb
  ) loop
    begin
    select LISTAGG (TT.SORIG, '; ') WITHIN GROUP (order by null desc) 
      into sOrig
      from (select distinct case fl.file_type when 7618744 then 'Оригинал (1)' when 80802744 then 'Копия (1)' else '-' end as sOrig
              from FILELINKSUNITS un,
                   FILELINKS      fl
             where un.table_prn = rec.inv_rn
               and fl.rn        = un.FILELINKS_PRN
             order by fl.load_date desc) TT;
    exception
      when NO_DATA_FOUND then
        sOrig := to_char(null);
    end;

    nRow := nRow + 1;
    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,      0, nSTR, nRow);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sOrd,     0, nSTR, rec.DocNum);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dOrd,     0, nSTR, rec.indocdate);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPost,    0, nSTR, rec.agnname);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSumm,    0, nSTR, rec.SUMMTAX); -- сумма с НДС из накладной
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sForm,    0, nSTR, sOrig);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDoc,     0, nSTR, nvl(rec.invDocCode, rec.sUPD));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDocPost, 0, nSTR, rec.InvDocNum);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dDocPost, 0, nSTR, rec.invdocdate);

    /* Записываем "Да" в свойство "Заблокирован" */
    pkg_docs_props_vals.modify(nproperty   => 269610684
                              ,sunitcode   => 'IncomingOrders'
                              ,ndocument   => rec.ord_nrn
                              ,sstr_value  => 'Да'
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => nNumber);
  end loop;    

  FIND_USERLIST_BY_AUTHID(nFLAG_SMART => 0,
                          sAUTHID     => utilizer,
                          sNAME       => sFrom);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sNameFrom, sFrom || ' (' || to_char(sysdate, 'DD.MM.YYYY') || ')');
  
  if sSysDate = 1 then 
    PRSG_EXCEL.CELL_VALUE_WRITE(sDate, 'Ведомость приема-передачи документов для бухгалтерии. ' || to_char(sysdate, 'DD.MM.YYYY'));
  end if;
  --PRSG_EXCEL.CELL_VALUE_WRITE(C_sNameTo, utilizer);

  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_LINE);

end UDO_REP_INORDERS_VEDOMOST;
/
