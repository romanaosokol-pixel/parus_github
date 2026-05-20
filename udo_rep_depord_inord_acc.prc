create or replace procedure UDO_REP_DEPORD_INORD_ACC (
       sRAZDEL    in varchar2, -- Раздел из которого запускается отчет
       nIDENT     in number   -- Выбранная строка Заказа подразделений
) is
   -- Отчет Приходы от поставщиков по Заказу подразделений
   -- 17.03.2023 KHOK

  C_SLIST1    constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  LL_LINE     constant PKG_STD.TSTRING := 'L_Line';
  C_nPP       constant PKG_STD.TSTRING := 'nPP';
  nSTR        number;
  nRows       number := 0;
  iLINE_BEG   PKG_STD.tNUMBER := 2;  -- Начальная строка данных
  iXLSNAME    PKG_STD.tNUMBER;       -- Номер ячейки 

  /* Запись значения ячеек строки таблицы */
  procedure TABCELL_WRITE
  (
    nCOLUMN   in varchar2,       -- Имя колонки в отчете
    sROW_NAME in varchar2,       -- Имя строки в отчете
    sVALUE    in varchar2:=null, -- Значение (строка)
    nVALUE    in number  :=null  -- Значение (число)
  ) 
  is
  sXLSNAME PKG_STD.tSTRING; -- Имя ячейки на Excel-листе
  begin
    sXLSNAME := nCOLUMN||sROW_NAME;
    PRSG_EXCEL.CELL_DESCRIBE(sXLSNAME); 
   case
      when sVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(sXLSNAME, sVALUE);
      when nVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(sXLSNAME, nVALUE);
      else
        null;
    end case;
 
  end TABCELL_WRITE;
  
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;
  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST1); -- Главная страница  -- Составные части
  -- Описываем имена ячеек в шапке
  --PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie);
  --PRSG_EXCEL.CELL_DESCRIBE(C_nIzd);
  -- Описываем ячейки спецификации 
  --PRSG_EXCEL.LINE_DESCRIBE(LL_GAP);
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);

  if 'DepartmentsOrders' = sRAZDEL then
    for sel in (
select T.RN                                        as nRN,
       T.PRN                                       as nPRN,
       MD.RN                                       as nMODIF,
       NM.RN                                       as nNOMEN,
       MD.MODIF_CODE                               as sNOMMODIF_MODIF_CODE,
       MD.MODIF_NAME                               as sNOMMODIF_MODIF_NAME,
       NM.NOMEN_CODE                               as sPRN_NOMEN_CODE,
       NM.NOMEN_NAME                               as sPRN_NOMEN_NAME,
       A.AGNABBR                                   as sAGNABBR,
       A.AGNNAME                                   as sAGNNAME,
       IO.INDOCDATE                                as dDOCDATE,
       IO.CONFDOCNUMB                              as sDOCNUMB,
       T.SERNUMB                                   as sSERNUMB,
       T.FACTQUANT                                 as nFACTQUANT,
       T.FACTSUMTAX                                as nFACTSUMTAX,
       round(T.FACTSUMTAX / T.FACTQUANT, 4)        as nPRICE,
       T.FACTSUM                                   as nFACTSUM,
       T.PRICE                                     as nprice_wo_nds,
       IO.INVDOCNUMB || ', ' || to_char(IO.Invdocdate, 'DD.MM.YYYY') as INVDOCNUMB,
       UDO_F_INORDERSPECS_DAYS_FACT(nRN => T.RN)   as nDAYS_FACT,
       (select DV.NUM_VALUE
          from DOCLINKS     L,
               PAYACCINSPEC PIS,
               DOCS_PROPS_VALS DV
         where L.OUT_UNITCODE = 'IncomingOrders'
           and L.OUT_DOCUMENT = T.PRN
           and L.IN_UNITCODE = 'PaymentAccountsIn'
           and L.IN_DOCUMENT = PIS.PRN
           and PIS.NOMMODIF = T.NOMMODIF
           and DV.UNIT_RN = PIS.RN
           and DV.DOCS_PROP_RN = 7551156 -- Дней поставки
           /*and rownum < 2*/)                     as nDAYS_PLAN,
       (select m.ext_numb || ' от ' || to_char(m.doc_date, 'DD.MM.YYYY')
          from PAYACCIN M
         where COMPANY=90521
           and (M.RN in (select v.NDOCUMENT
                           from V_DOCLINKS_INOUT_OUT_EXT v
                          where v.NOUT_DOCUMENT = IO.RN
                            and v.SOUT_UNITCODE = 'IncomingOrders'
                            and v.SUNITCODE = 'PaymentAccountsIn')
             or M.RN in (select v2.NDOCUMENT
                           from V_DOCLINKS_INOUT_OUT_EXT v1,
                                V_DOCLINKS_INOUT_OUT_EXT v2
                          where v1.NOUT_DOCUMENT = IO.RN
                            and v1.SOUT_UNITCODE = 'IncomingOrders'
                            and v1.SUNITCODE = 'IncomingInvoices'
                            and v2.NOUT_DOCUMENT = v1.ndocument
                            and v2.SOUT_UNITCODE = 'IncomingInvoices'
                            and v2.SUNITCODE = 'PaymentAccountsIn')
                   --and rownum = 1
               )
          and m.ext_numb is not null
          /*and rownum = 1*/)                      as sPayaccNumb, -- KHOK
       UDO_F_INORDERSPECS_DAYS_FACT(t.RN) N45232700, 
       (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027724 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = t.RN) S8027724,
       (select NUM_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13884319 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = t.RN) N13884319, 
       (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = t.RN) S12114824
 
  from SELECTLIST sl,
       DEPARTMENTORDS dep,
       INORDERSPECS T,
       NOMMODIF     MD,
       DICNOMNS     NM,
       INORDERS     IO,
       AGNLIST      A
 where /*sl.rn = nIDENT and*/ sl.unitcode = sRAZDEL and sl.authid = USER
   and sl.document = dep.prn --= 56024939
/*1=1 and dep.prn = 56024939
 and nm.rn = 6872320*/
   and dep.nom_modif = t.nommodif
   and T.NOMMODIF = MD.RN
   and MD.PRN = NM.RN
   and T.PRN = IO.RN
   and IO.CONTRAGENT = A.RN
   order by sprn_nomen_name, sagnabbr, spayaccnumb--, ddocdate
  ) loop

    nRows := nRows + 1;   
    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP, 0, nSTR, nRows);
--PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => null, iCELL_INDEX_X => 1, iCELL_INDEX_Y => nSTR, nCELL_VALUE => nRows);
      iXLSNAME := iLINE_BEG + nSTR;
      TABCELL_WRITE('B', iXLSNAME, sel.invdocnumb); -- УПД, Дата
      TABCELL_WRITE('C', iXLSNAME, sel.spayaccnumb); -- Номер и дата счета
      TABCELL_WRITE('D', iXLSNAME, sel.sdocnumb); -- Документ
      TABCELL_WRITE('E', iXLSNAME, to_char(sel.ddocdate, 'DD.MM.YYYY')); -- Дата прихода
      TABCELL_WRITE('F', iXLSNAME, sel.sagnabbr); -- Поставщик
      TABCELL_WRITE('G', iXLSNAME, sel.sagnname); -- Поставщик, наименование
      TABCELL_WRITE('H', iXLSNAME, sel.sprn_nomen_code); -- Номенклатура
      TABCELL_WRITE('I', iXLSNAME, sel.sprn_nomen_name); -- Наименование номенклатуры
      TABCELL_WRITE('J', iXLSNAME, sel.snommodif_modif_code); -- Модификация
      TABCELL_WRITE('K', iXLSNAME, sel.snommodif_modif_name); -- Наименование модификации
      TABCELL_WRITE('L', iXLSNAME, to_char(sel.ssernumb)); -- Серия
      TABCELL_WRITE('M', iXLSNAME, sel.s8027724); -- ПРИЕМКА
      TABCELL_WRITE('N', iXLSNAME, sel.nfactquant); -- Количество фактически в осн. ЕИ
      TABCELL_WRITE('O', iXLSNAME, sel.nprice); -- Цена
      TABCELL_WRITE('P', iXLSNAME, sel.nfactsumtax); -- Сумма с налогами фактически
      TABCELL_WRITE('Q', iXLSNAME, sel.nprice_wo_nds); -- Цена без НДС
      TABCELL_WRITE('R', iXLSNAME, sel.nfactsum); -- Сумма без налогов фактически
      TABCELL_WRITE('S', iXLSNAME, sel.ndays_plan); -- Дней, план
      TABCELL_WRITE('T', iXLSNAME, nvl(sel.n45232700, sel.ndays_fact)); -- #Факт, дни поставки
      TABCELL_WRITE('U', iXLSNAME, sel.n13884319); -- НомерПП
      TABCELL_WRITE('V', iXLSNAME, sel.s12114824); -- Дата производства

  end loop;
  end if;
  --удаляем технические строки
  if nRows > 0 then  PRSG_EXCEL.LINE_DELETE(LL_LINE); end if;
  
end UDO_REP_DEPORD_INORD_ACC;
/

