create or replace procedure UDO_REP_ININVOICES_COMING(
    NCOMPANY  in number,  -- Организация
    sRAZDEL   in varchar, -- Раздел
    nIDENT    in number,  -- ИД помеченной записи
    nAgent    in number,  -- RN выбранного поставщика
    dBeg_Date in date,    -- Начало интервала
    dEnd_Date in date     -- Конец интервала
) is
  /*
    09/12/2022 Хохряков А.В.
    Отчет приходов по Приходным накладным по поставщику.

    Вызывается из разных разделов.
    1. Приходные накладные
  */
  
 ----Переменные отчета
  C_SLIST constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  C_sDate     constant PKG_STD.TSTRING := 'S_Date';
  C_sPost     constant PKG_STD.TSTRING := 'S_Post';
  C_sInterval constant PKG_STD.TSTRING := 'S_Interval';

  LL_LINE     constant PKG_STD.TSTRING := 'L_Line';  
  C_nPP       constant PKG_STD.TSTRING := 'nPP';
  C_sAGENT    constant PKG_STD.TSTRING := 'sAGENT';
  C_sINV_NUMB constant PKG_STD.TSTRING := 'sINV_NUMB';
  C_dINV_DATE constant PKG_STD.TSTRING := 'dINV_DATE';
  C_sINV_Pos  constant PKG_STD.TSTRING := 'sINV_Pos';
  C_sINV_Kol  constant PKG_STD.TSTRING := 'sINV_Kol';
  C_dSUMM     constant PKG_STD.TSTRING := 'dSUMM';
  C_sPAY_NUMB constant PKG_STD.TSTRING := 'sPAY_NUMB';
  C_dPAY_DATE constant PKG_STD.TSTRING := 'dPAY_DATE';
  C_sZayav    constant PKG_STD.TSTRING := 'sZayav';
  C_sTheme    constant PKG_STD.TSTRING := 'sTheme';

  nSTR      number;
  --nPost     number;
  sPost     varchar2(4000) := null;
  --sAgent    AGNLIST.AGNNAME%type := '???';

  nPP       PKG_STD.tNUMBER := 0;  -- Порядковый номер записи
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPost);
  PRSG_EXCEL.CELL_DESCRIBE(C_sInterval);

  -- Описываем строки и ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sINV_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dINV_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sINV_Pos);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sINV_Kol);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dSUMM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPAY_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPAY_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sZayav);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sTheme);

  delete from IDLIST ls where ls.hid = 771505102948;
  if nAgent is null then
    if 'AGNLIST' = sRAZDEL then
      for sel in (
        select distinct ag.rn ag_rn, ag.agnname 
        from SELECTLIST sl, AGNLIST ag
       where /*sl.rn = nIDENT and*/ sl.unitcode = sRAZDEL
         and sl.authid = USER
         and ag.rn = sl.document
      ) loop
        insert into IDLIST ( ID, HID ) values ( sel.ag_rn, 771505102948 );
        if sPost is null then 
             sPost := sel.agnname;
        else 
          if length(sPost) < 3830 then
            sPost := sPost || '; ' || trim(sel.agnname);
          end if;
        end if;
      end loop;
    else
      for sel in (
        select distinct ag.rn ag_rn, ag.agnname 
        from SELECTLIST sl, ININVOICES inv, AGNLIST ag
       where /*sl.rn = nIDENT and*/ sl.unitcode = sRAZDEL
         and sl.authid = USER
         and inv.rn = sl.document
         and inv.company = nCOMPANY
         and inv.AGENT = ag.rn
      ) loop
        insert into IDLIST ( ID, HID ) values ( sel.ag_rn, 771505102948 );
        if sPost is null then 
             sPost := sel.agnname;
        else 
          if length(sPost) < 3830 then
            sPost := sPost || '; ' || trim(sel.agnname);
          end if;
        end if;
      end loop;
    end if;
  else 
    --nPost := nAgent;
    insert into IDLIST ( ID, HID ) values ( nAgent, 771505102948 );
    begin
    select trim(ag.agnname) into sPost
      from AGNLIST ag
     where ag.rn = nAgent;
    exception
      when NO_DATA_FOUND then
        p_exception(0, 'Поставщик не найден. - ' || nIDENT || '-' || sRAZDEL);
    end;
  end if;
  
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, to_char(sysdate, 'DD.MM.YYYY HH24:MI'));
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sPost, sPost);
  if dBeg_Date is null and dEnd_Date is null then
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sInterval, 'За всю историю');
  elsif dBeg_Date is not null and dEnd_Date is null then
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sInterval, 'С '||to_char(dBeg_Date, 'DD.MM.YYYY')||' по '||to_char(sysdate, 'DD.MM.YYYY'));
  elsif dBeg_Date is null and dEnd_Date is not null then
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sInterval, 'За все время по '||to_char(dEnd_Date, 'DD.MM.YYYY'));
  else
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sInterval, 'С '||to_char(dBeg_Date, 'DD.MM.YYYY')||' по '||to_char(dEnd_Date, 'DD.MM.YYYY'));
  end if;
--p_exception(0, nPost || ': ' || dBeg_Date || '-' || dEnd_Date);

  for ss in(
    select N.NOMEN_NAME, spec.original_name, trim(to_char(spec.price, '999G999G999G999D99')) sPrice, 
           spec.quant, spec.summtax,
           --dt1.doccode || ', ' || trim(inv.pref)|| '-' || trim(inv.numb) inv_numb, 
           inv.ext_numb inv_ext, to_char(inv.doc_date, 'DD.MM.YYYY') inv_date, --inv.summtax,
           ag.agnname,
           --dt2.doccode || ', ' || trim(pa.doc_pref)|| '-' || trim(pa.doc_numb) pay_numb, 
           pa.ext_numb pay_ext, to_char(pa.doc_date, 'DD.MM.YYYY') pay_date, --pa.summwithnds
           UDO_F_PAYACCINSP_EXT_DEPORD(pay_spec.rn) sZayav, 
           UDO_F_ININVOICESSPC_SHEFR(clc.rn) sTheme
      from ININVOICESSPECS spec,
           DICNOMNS   N,
           ININVOICES inv, 
           DOCTYPES   dt1,
           AGNLIST    ag,
           DOCLINKS   dl,
           PAYACCIN   pa,
           DOCTYPES   dt2,
           ININVOICESSPC clc,
           PAYACCINSPEC pay_spec
     where spec.prn = inv.rn
       and spec.NOMEN = N.RN
       and inv.agent in (select L.ID from IDLIST L where L.HID = 771505102948) -- = nPost
       and ((inv.doc_date between dBeg_Date and dEnd_Date and dBeg_Date is not null and dEnd_Date is not null)
         or (inv.doc_date >= dBeg_Date  and dBeg_Date is not null and dEnd_Date is null)
         or (inv.doc_date < dEnd_Date+1 and dEnd_Date is not null and dBeg_Date is null)
         or (dBeg_Date is null and dEnd_Date is null)
           )
       and inv.doctype = dt1.rn
       and inv.AGENT   = ag.rn
       and dl.out_document = inv.rn
       and dl.out_unitcode = 'IncomingInvoices'
       and dl.in_unitcode  = 'PaymentAccountsIn' 
       and dl.in_document  = pa.rn
       and pa.doc_type = dt2.rn
       and pay_spec.prn = pa.rn
       and pay_spec.nomen = spec.nomen
       and pay_spec.nommodif = spec.modif
       and clc.prn = spec.rn
    order by sTheme, inv.doc_date, NOMEN_NAME, inv_ext --, ag.agnname
  ) loop

    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
    nPP := nPP + 1;   
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nPP);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,    0, nSTR, ss.agnname);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sINV_NUMB, 0, nSTR, ss.inv_ext); --ss.inv_numb || ' ('||ss.inv_ext||')');
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dINV_DATE, 0, nSTR, ss.inv_date);
    if upper(trim(ss.NOMEN_NAME)) != upper(trim(ss.original_name)) then
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sINV_Pos,  0, nSTR, trim(ss.NOMEN_NAME) || ' (' || trim(ss.original_name) || ')');
    else PRSG_EXCEL.CELL_VALUE_WRITE(C_sINV_Pos,  0, nSTR, trim(ss.NOMEN_NAME));
    end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sINV_Kol,  0, nSTR, ss.quant || ' * ' || ss.sPrice);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dSUMM,     0, nSTR, ss.summtax);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_NUMB, 0, nSTR, ss.pay_ext); --ss.pay_numb || ' ('||ss.pay_ext||')');
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE, 0, nSTR, ss.pay_date);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZayav,    0, nSTR, trim(ss.sZayav));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sTheme,    0, nSTR, trim(ss.sTheme));

  end loop;
  --удаляем технические строки
  PRSG_EXCEL.LINE_DELETE(LL_LINE);

end UDO_REP_ININVOICES_COMING;
/

