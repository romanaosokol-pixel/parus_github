create or replace procedure UDO_REP_INORDERS_LIST(
  nCOMPANY      in number
 ,dDOC_BEG      in date
 ,dDOC_END      in date
) is

  C_SLIST   constant PKG_STD.TSTRING := 'TDSheet'; -- Лист

  LL_LINE   constant PKG_STD.TSTRING := 'L_LINE';  -- Строка
  C_dDateIn constant PKG_STD.TSTRING := 'S_DateIn';
  C_sName   constant PKG_STD.TSTRING := 'S_Name';
  C_sDoc    constant PKG_STD.TSTRING := 'S_Doc';
  C_sSeria  constant PKG_STD.TSTRING := 'S_Seria';
  C_dMade   constant PKG_STD.TSTRING := 'S_DateMade';
  C_sGarant constant PKG_STD.TSTRING := 'S_Garant';
  C_sSert   constant PKG_STD.TSTRING := 'S_Sert';
  C_sSost   constant PKG_STD.TSTRING := 'S_Sost';
  C_sDocOut constant PKG_STD.TSTRING := 'S_DateOut';
  C_sNote   constant PKG_STD.TSTRING := 'S_Note';

  nSTR        number;
  
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;
--p_exception(0,'dDOC_BEG: ' || dDOC_BEG || '; dDOC_END: ' || dDOC_END);

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST); 
  
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
-- Описываем имена ячеек в строках
--  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dDateIn);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDoc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSeria);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dMade);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sGarant);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSert);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSost);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDocOut);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNote);
  
  for rec in(
      select to_char(ord.dindocdate, 'DD.MM.YY') dindocdate, 
             trim(ord.sindocnumb) || ' от ' || to_char(ord.dinvdocdate, 'DD.MM.YYYY') || ' / ' || 
                  ord.sinvdocnumb || ' / '  || ord.sseller sSeller, 
             to_char(ord.doutdoc_date, 'DD.MM.YY') doutdoc_date,
             spec.snomenname, spec.ssernumb || '  / ' || spec.nfactquant sSeria,
             spec.snote, spec.nstorage_time, spec.scertificate,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = spec.NRN) sMade,
             case spec.nplanquant - spec.nfactquant
               when 0 then 'Соответствует'
               else 'Не соответствует' 
             end sSost
        from V_INORDERS ord, V_INORDERSPECS spec
       where ord.ncompany = UDO_REP_INORDERS_LIST.nCOMPANY
         and ord.dindocdate between dDOC_BEG and dDOC_END
         and spec.nprn = ord.nrn
         and spec.snomenname not like '%Доставка%' and spec.snomenname not like 'Тара%'
       order by ord.dindocdate, ord.sseller, ord.dinvdocdate, ord.sinvdocnumb, spec.snomenname
  ) loop
    
    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dDateIn, 0, nSTR, rec.dindocdate);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sName,   0, nSTR, rec.snomenname);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDoc,    0, nSTR, rec.sSeller);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sSeria,  0, nSTR, rec.sSeria);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dMade,   0, nSTR, rec.sMade);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sGarant, 0, nSTR, rec.nstorage_time);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sSert,   0, nSTR, rec.scertificate);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sSost,   0, nSTR, rec.sSost);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDocOut, 0, nSTR, rec.doutdoc_date);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNote,   0, nSTR, rec.snote);
  end loop;
  
  PRSG_EXCEL.LINE_DELETE(LL_LINE); -- удаляем техническую строку
        
end UDO_REP_INORDERS_LIST;
/

