create or replace procedure UDO_P_RLINVSHEET_SVOD_XLS
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    UDO_RLINVSHEET_SVOD_TMP
  */
  -- описание
  cFORM  constant varchar2(20) := 'ведомость';
  cNUMB  constant varchar2(20) := 'ведомость';
  cSKLAD constant varchar2(20) := 'склад';

  cLINE       constant varchar2(20) := 'строка';
  cNAME       constant varchar2(20) := 'наименование';
  cSER        constant varchar2(20) := 'серия';
  cPLACE      constant varchar2(20) := 'место';
  cQUANT      constant varchar2(20) := 'кол';
  cQUANT_FACT constant varchar2(20) := 'факт';

  n      integer;
  sNUMB  varchar2(2000);
  sSKLAD varchar2(2000);
  rTMP   UDO_RLINVSHEET_SVOD_TMP%rowtype;
begin
  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cNUMB);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cSKLAD);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cNAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cSER);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cPLACE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQUANT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQUANT_FACT);
  -- печать
  for rec in (select trim(SH.PREF) || '-' || trim(SH.NUMB) ||' от '|| decode_date(SH.DOCDATE) as NUMB,
                     ST.AZS_NUMBER,
                     SH.RN
                from RLINVSHEET   SH,
                     SELECTLIST   SL,
                     AZSAZSLISTMT ST
               where SL.IDENT = nIDENT
                 and SL.DOCUMENT = SH.RN
                 and SH.STORE = ST.RN) loop
    if sNUMB is null then
      sNUMB := rec.numb;
    else
      sNUMB := sNUMB || '; ' || rec.numb;
    end if;
    if sSKLAD is null then
      sSKLAD := rec.azs_number;
    else
      sSKLAD := sSKLAD || '; ' || rec.azs_number;
    end if;
    --
    for rsp in (select SP.ACCQUANT,
                       SP.FACTQUANT,
                       GP.SERNUMB,
                       SP.CELL_NUMB,
                       NM.NOMEN_NAME
                  from RLINVSHEETSPEC SP,
                       DICNOMNS       NM,
                       GOODSSUPPLY    GS,
                       GOODSPARTIES   GP
                 where SP.PRN = rec.rn
                   and SP.NOMEN = NM.RN
                   and SP.GOODSSUPPLY = GS.RN
                   and GS.PRN = GP.RN) loop
      rTMP.Ident      := nIDENT;
      rTMP.Nomen_Name := rsp.nomen_name;
      rTMP.Sernumb    := rsp.sernumb;
      rTMP.Place      := rsp.cell_numb;
      rTMP.Quant      := rsp.accquant;
      rTMP.quant_fact := rsp.factquant;
      insert into UDO_RLINVSHEET_SVOD_TMP values rTMP;
    end loop;
  end loop;
  -- печать
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cNUMB, sCELL_VALUE => sNUMB);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cSKLAD, sCELL_VALUE => sSKLAD);

  for rpr in (select T.NOMEN_NAME,
                     T.SERNUMB,
                     T.PLACE,
                     sum(T.QUANT)       QUANT,
                     sum(T.quant_fact)  QUANT_FACT
                from UDO_RLINVSHEET_SVOD_TMP T
               where T.IDENT = nIDENT
               group by T.NOMEN_NAME,
                        T.SERNUMB,
                        T.PLACE
               order by T.NOMEN_NAME,
                        T.SERNUMB,
                        T.PLACE) loop
    n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNAME,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rpr.nomen_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cSER, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rpr.sernumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPLACE, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rpr.place);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cQUANT, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, nCELL_VALUE => rpr.quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cQUANT_FACT, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, nCELL_VALUE => rpr.quant_fact);
  end loop;

  -- подчистка
  PRSG_EXCEL.LINE_DELETE(cLINE);
  delete from UDO_RLINVSHEET_SVOD_TMP where IDENT = nIDENT;

end;
/
