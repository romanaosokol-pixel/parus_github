create or replace procedure UDO_REP_DELIVERYLIST(
  nCOMPANY           in number,  -- Организация
  nIDENT             in number,  -- Отмеченные записи Комплектовочной ведомости
  sRazd              in varchar2 -- Раздел из которого запускается отчет
) is
 ----Переменные отчета "Комплектовочная ведомость"
  C_sNum      constant PKG_STD.tSTRING := 's_Num';
  C_sIzd      constant PKG_STD.tSTRING := 's_Izd';
  C_sKol      constant PKG_STD.tSTRING := 's_Kol';
  C_sZayav    constant PKG_STD.tSTRING := 's_Zayav';
  C_sZav      constant PKG_STD.tSTRING := 's_Zav';
  C_sTheme    constant PKG_STD.tSTRING := 's_Theme';

  LL_LINE     constant PKG_STD.tSTRING := 'L_LINE';

  C_nPP         constant PKG_STD.tSTRING := 'nPP';
  C_sName       constant PKG_STD.tSTRING := 'sName';
  C_sDoc        constant PKG_STD.tSTRING := 'sDoc';
  C_sZamen      constant PKG_STD.tSTRING := 'sZamen';
  C_sNomenkl    constant PKG_STD.tSTRING := 'sNomenkl';
  C_sNomenklNew constant PKG_STD.tSTRING := 'sNomenklNew';
  C_sKolSP      constant PKG_STD.tSTRING := 'sKolSP';
  C_sKolTot     constant PKG_STD.tSTRING := 'sKolTot';
  C_sObozn      constant PKG_STD.tSTRING := 'sObozn';
  C_sDate       constant PKG_STD.tSTRING := 'sDate';
  C_sSert       constant PKG_STD.tSTRING := 'sSert';
  C_sSrok       constant PKG_STD.tSTRING := 'sSrok';

  sSheetName     varchar2(32) := 'Лист';
  nSheet         integer := 0;
  nSTR           number;
  
begin
--p_exception(0,'Раздел: '||sRazd); -- CostDeliveryLists
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  for rec in(
      select lst.*
      from SELECTLIST   sl,
           V_FCDELIVERYLIST lst,
           V_FCROUTLST rout
      where sl.ident = nIDENT
        and lst.nrn = sl.document
        and lst.ncompany = UDO_REP_DELIVERYLIST.nCOMPANY
        and rout.nrn = (select dl.ndocument from V_DOCLINKS_INOUT_OUT dl where NOUT_DOCUMENT=lst.nrn and SOUT_UNITCODE='CostDeliveryLists' and SUNITCODE='CostRouteLists')
--      order by lst.smatres_code
    ) loop
      nSheet := nSheet + 1;

      sSheetName := 'Лист'||nSheet;
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'Лист0',
                            sSHEET_NAME_TO     => sSheetName,
                            sSHEET_NAME_BEFORE => null,
                            nMOVE_TO_END       => 1);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);

      PRSG_EXCEL.CELL_DESCRIBE(C_sNum);
      PRSG_EXCEL.CELL_DESCRIBE(C_sIzd);
      PRSG_EXCEL.CELL_DESCRIBE(C_sKol);
      PRSG_EXCEL.CELL_DESCRIBE(C_sZayav);
      PRSG_EXCEL.CELL_DESCRIBE(C_sZav);
      PRSG_EXCEL.CELL_DESCRIBE(C_sTheme);

      PRSG_EXCEL.CELL_VALUE_WRITE(C_sNum, '');
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzd, rec.smatres_name);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol, rec.nquant);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sZayav, rec.sprod_order);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav, '');
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sTheme, '');

      -- Описываем ячейки спецификации 
      PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

      -- Описываем имена ячеек в шапке и подвале
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sName);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDoc);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sZamen);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNomenkl);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNomenklNew);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sKolSP);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sKolTot);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sObozn);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDate);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSert);      
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sSrok);      

      for spec in(
          select lst.*
          from V_FCDELIVERYLISTSP lst
          where lst.nprn = rec.nrn
          order by lst.sprlstsp
        ) loop

        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,         0, nSTR, trim(spec.sprlstsp));
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sName,       0, nSTR, spec.smatrespl_name);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sDoc,        0, nSTR, spec);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sZamen,      0, nSTR, spec);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomenkl,    0, nSTR, spec.smatrespl_nomen);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomenklNew, 0, nSTR, spec);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sKolSP,      0, nSTR, spec.nquant_plan);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sKolTot,     0, nSTR, spec.nquant_fact);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sObozn,      0, nSTR, spec);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate,       0, nSTR, spec);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSert,       0, nSTR, spec);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSrok,       0, nSTR, spec);

        end loop;
        --удаляем техническую строку
        PRSG_EXCEL.LINE_DELETE(LL_LINE);

    end loop;

    PRSG_EXCEL.SHEET_DELETE('Лист0');

end UDO_REP_DELIVERYLIST;
/

