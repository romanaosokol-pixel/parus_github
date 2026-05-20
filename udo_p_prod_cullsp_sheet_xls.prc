create or replace procedure UDO_P_PROD_CULLSP_SHEET_XLS
(
  nCOMPANY in number,
  nIDENT   in number,
  sRazdel  in varchar
) as
  /*
    01/06/2023 Марков МВ.
    Сертификация / Входной контроль (спецификация)
    Отчет "Ведомость замечаний"
    UDO_PROD_CULLSP_SHEET_TMP
    
    Печать только по позициям, у которых есть текст в Примечании для строк Результаты ВК
  */
  cFORM   constant varchar2(20) := 'ведомость';
  sOrder  constant varchar2(200):= 'Ордер';
  sIzd    constant varchar2(480):= 'Изделие';
  sZav    constant varchar2(32) := 'sZav';
  cDEFF_1 constant varchar2(20) := 'замечание_1';
  cDEFF_2 constant varchar2(20) := 'замечание_2';
  
  cell_supplier constant varchar2(20) := 'SUPPLIER';

  --
  n           integer;
  nSHEET      integer;
  nSIGN_PRINT number(17);
  sFORM       varchar2(20);
  sMainProd   varchar2(2000) := null;
  sNote       varchar2(2000) := null;
  nNomen      DICNOMNS.RN%type := 0;
  sPartNote   UDO_PROD_CULLSP_SHEET_TMP.NOTES%type := null;
  dRegDate    date;
  sName       USERLIST.NAME%type := null;
  --
  procedure clear_tmp is
  begin
    delete from UDO_PROD_CULLSP_SHEET_TMP where AUTHID = utilizer;
  end clear_tmp;
  --
  procedure ins_tmp(rROW in out UDO_PROD_CULLSP_SHEET_TMP%rowtype) is
  begin
    insert into UDO_PROD_CULLSP_SHEET_TMP values rROW;
  end ins_tmp;

  -- подготовка данных
  procedure create_tmp
  (
    nID    in number,
    nCHECK out number
  ) is
    rTMP UDO_PROD_CULLSP_SHEET_TMP%rowtype;
  begin
    nCHECK      := 0;
    rTMP.Ident  := nID;
    rTMP.Authid := utilizer;
    for rec in (
      select SP.RN, SP.PRN,
             (select count(*) 
                from UDO_PROD_CULL_OUT SPO
               where SPO.PRN = SP.RN
                 and SPO.NOTE is not null) as SIGN_OUT
        from UDO_PROD_CULL_SP SP,
             SELECTLIST       SL
       where SL.IDENT = nID
         and SL.DOCUMENT = SP.RN
    ) loop
      if rec.sign_out > 0 then
        nCHECK        := nCHECK + rec.sign_out;
        rTMP.Sheet    := rec.prn;
        rTMP.Sheet_Sp := rec.rn;
        for rot in (select SPO.RN,
                           SPO.NOTE
                      from UDO_PROD_CULL_OUT SPO
                     where SPO.PRN = rec.rn
        ) loop
          rTMP.Sheet_Out := rot.rn;
          rTMP.Notes     := rot.note;

          ins_tmp(rROW => rTMP);
        end loop;
      end if;
    end loop;
  end create_tmp;

begin
  if sRazdel = 'UdoProdCullSp' then 
    -- подготовка данных
    clear_tmp;
    create_tmp(nID => nIDENT, nCHECK => nSIGN_PRINT);
    --
    if nSIGN_PRINT <= 0 then
      p_exception(0, 'Нет данных для печати!');
    end if;
  end if;

  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cDEFF_1);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cDEFF_2);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => sOrder);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => sIzd);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => sZav);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cell_supplier);
  
  -- печать
  nSIGN_PRINT := 3;
  nSHEET      := 0;
  n           := 0;
  --nMaxRN      := 0;

  if sRazdel = 'UdoProdCullSp' then -- Входной контроль

  for rprt in 
    (select distinct T.NOTES, T.SHEET_OUT,
            NM.NOMEN_NAME, NM.RN,
            SP.QUANT, ED.MEAS_MNEMO,
            GP.SERNUMB,-- Серия
            UDO_F_PROD_CULL_SP_MAINPROD(sp.RN) sMainProd,
            DT.DOCCODE ||', '|| trim(ORD.INDOCPREF)||'-'||trim(ORD.INDOCNUMB)||' от '||to_char(ORD.INDOCDATE, 'DD.MM.YYYY') as sINV,
            'зак.№' || UDO_F_INORDERS_DEPORD_NUMB(ord.RN) as sOrdNum,
            f_docs_props_get_str_value(nproperty => 8027724, sunitcode => 'IncomingOrdersSpecs', ndocument => SPEC.RN) as sPriem,
            sup.agnname suppiler
            --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027724 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = SPEC.RN) as sPriem
       from UDO_PROD_CULLSP_SHEET_TMP T,
            UDO_PROD_CULL_SP          SP,
            DICNOMNS                  NM,
            DOCLINKS                  DL,
            INORDERS                  ORD,
            DOCTYPES                  DT,
            INORDERSPECS              SPEC,
            GOODSPARTIES              GP,
            DICMUNTS                  ED,
            agnlist                   SUP 
      where T.IDENT         = nIDENT
        and T.SHEET_SP      = SP.RN
        and SP.COMPANY      = nCOMPANY
        and SP.NOMEN        = NM.RN
        and DL.OUT_DOCUMENT = T.SHEET
        and DL.IN_UNITCODE  = 'IncomingOrders'
        and DL.IN_DOCUMENT  = ORD.RN
        and ORD.INDOCTYPE   = DT.RN
        and SPEC.PRN        = ORD.RN
        and SPEC.NOMMODIF   = SP.MODIF
        and GP.RN           = SP.GOODSPARTY
        and NM.UMEAS_MAIN   = ED.RN
        and ORD.CONTRAGENT = SUP.rn
       union -- если ВК создается из прихода из подразделений (например, от переработчика)
       select distinct T.NOTES, T.SHEET_OUT,
            NM.NOMEN_NAME, NM.RN,
            SP.QUANT, ED.MEAS_MNEMO,
            GP.SERNUMB,-- Серия
            UDO_F_PROD_CULL_SP_MAINPROD(sp.RN) sMainProd,
            DT.DOCCODE ||', '|| trim(ORD.PREF)||'-'||trim(ORD.NUMB)||' от '||to_char(ORD.DOCDATE, 'DD.MM.YYYY') as sINV,
            'Тема: ' || UDO_F_DEPARTMENTORD_SHEFR(ORD.FACEACC) as sOrdNum, --udo_f_transinvdept_main_prod(ord.RN)
            null as sPriem,
            null as supplier
       from UDO_PROD_CULLSP_SHEET_TMP T,
            UDO_PROD_CULL_SP          SP,
            DICNOMNS                  NM,
            DOCLINKS                  DL,
            TRANSINVDEPT              ORD,
            DOCTYPES                  DT,
            TRANSINVDEPTSPECS         SPEC,
            GOODSPARTIES              GP,
            DICMUNTS                  ED
      where T.IDENT         = nIDENT
        and T.SHEET_SP      = SP.RN
        and SP.COMPANY      = nCOMPANY
        and SP.NOMEN        = NM.RN
        and DL.OUT_DOCUMENT = T.SHEET
        and DL.IN_UNITCODE  = 'GoodsTransInvoicesToDepts'
        and DL.IN_DOCUMENT  = ORD.RN
        and ORD.DOCTYPE     = DT.RN
        and SPEC.PRN        = ORD.RN
        and SPEC.NOMMODIF   = SP.MODIF
        and GP.RN           = SP.GOODSPARTY
        and NM.UMEAS_MAIN   = ED.RN
        
      order by sMainProd, NOTES, NOMEN_NAME, SERNUMB
  ) loop

    if nSIGN_PRINT > 1 or sMainProd != rprt.sMainProd then
      -- новый лист
      nSHEET := nSHEET + 1;
      sFORM := cFORM||'_'||to_char(nSHEET);
      nSIGN_PRINT := 0;
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM => cFORM, sSHEET_NAME_TO => sFORM);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sFORM);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => sOrder, sCELL_VALUE => rprt.sInv);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => sIzd, sCELL_VALUE => 'Изделие: ' || rprt.sMainProd /*|| ' ' ||rprt.sPriem*/);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => sZav, sCELL_VALUE => trim(rprt.sOrdNum));
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cell_supplier, sCELL_VALUE => trim(rprt.suppiler));
      sMainProd := rprt.sMainProd;
    end if;

    begin
    select TT.REG_DATE, US.NAME 
      into dRegDate, sName
      from USERLIST US,
      (select 0 as sArc, UPD.REG_DATE, UL.RN, UL.AUTHID 
         from UPDATELIST_DETAIL UPD, UPDATELIST UL 
        where UL.Tablern = rprt.SHEET_OUT 
          and UL.RN = UPD.PRN
      union
       select 1 as sArc, UPD.REG_DATE, ULA.RN, ULA.AUTHID 
         from UPDATELIST_DETAIL_ARC UPD, UPDATELIST_ARC ULA 
        where ULA.Tablern = rprt.SHEET_OUT 
          and ULA.RN = UPD.PRN
        order by RN desc) TT
     where US.AUTHID = TT.AUTHID
       and rownum = 1
     order by TT.RN desc;
    end;

    -- печать
if false and utilizer = 'KHOK' then
    if 0 = n and (sPartNote is null or UPPER(trim(sPartNote)) != UPPER(trim(rprt.notes))) then
      if sNote is null then
        sNote := rprt.nomen_name || ' (' || rprt.sernumb || ' - ' || rprt.quant || ' ' || rprt.meas_mnemo || ')';
      else 
        if trim(nNomen) = rprt.rn then 
          if nNomen = 0 then sNote := sNote || '; '; end if;
          sNote := sNote || '(' || rprt.sPriem || ' ' || rprt.sernumb || ' - ' || rprt.quant || ' ' || rprt.meas_mnemo || ')';
        else 
          --sNomen := rprt.nomen_name;
          nNomen := rprt.rn;
          sNote := sNote || '; ' || chr(10) || rprt.nomen_name || ' (' || rprt.sernumb || ' - ' || rprt.quant || ' ' || rprt.meas_mnemo || ')';
        end if;
      end if;
--if utilizer = 'KHOK' then p_exception(0,n||nSIGN_PRINT||sNote); end if; 
    else
      sNote := sNote || chr(10) || sPartNote || chr(10) || to_char(dRegDate, 'DD.MM.YYYY HH24:MI') || chr(10) || sName;
--if utilizer = 'KHOK' then p_exception(0,n||sPartNote||nSIGN_PRINT||sNote); end if; 
      nSIGN_PRINT := nSIGN_PRINT + 1;
      if nSIGN_PRINT = 1 then
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDEFF_1, sCELL_VALUE => sNote);
      elsif nSIGN_PRINT = 2 then
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDEFF_2, sCELL_VALUE => sNote);
      else
        p_exception(0, 'nSIGN_PRINT = %s', nSIGN_PRINT);
      end if;
      n := n + 1;

      --sPartNote := rprt.notes;
      sNote := rprt.nomen_name || ' (' || rprt.sernumb || ' - ' || rprt.quant || ' ' || rprt.meas_mnemo || ')';
    end if;

    sPartNote := rprt.notes;

else
    nSIGN_PRINT := nSIGN_PRINT + 1;
    sNote := rprt.nomen_name || ' (' || rprt.sPriem || ' ' || rprt.sernumb || ' - ' || rprt.quant || ' ' || rprt.meas_mnemo || ')' || chr(10) || 
             rprt.notes || chr(10) || to_char(dRegDate, 'DD.MM.YYYY HH24:MI') || chr(10) || sName;

    if nSIGN_PRINT = 1 then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDEFF_1, sCELL_VALUE => sNote);
    elsif nSIGN_PRINT = 2 then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDEFF_2, sCELL_VALUE => sNote);
    else
      p_exception(0, 'nSIGN_PRINT = %s', nSIGN_PRINT);
    end if;
    n := n + 1;
end if; -- KHOK    
  end loop;

  --elsif sRazdel = 'CostRouteListsSerialNumbers' then -- Маршрутные листы (Заводские номера)
  elsif sRazdel = 'CostRouteLists' then -- Маршрутные листы

  for rprt in (
    select trim(lst.docpref) || trim(lst.docnumb) pref_numb, 
           UDO_F_FCROUTLST_PRODUCT_NUM(LST.RN) sOrd,
           UDO_F_FCROUTLST_SERNUMB(LST.RN) sZav,
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027724 and UNITCODE = 'CostRouteLists' and UNIT_RN = LST.RN) sPriem,
           MTR.NAME sMainProd--, FA.NUMB sfaceacc_numb
      from SELECTLIST       SL,
           --FCROUTLSTSERNUMB SER,
           FCROUTLST        LST,
           FACEACC          FA,
           FCMATRESOURCE    MTR 
      where SL.IDENT    = nIDENT 
        and SL.DOCUMENT = LST.RN --SER.RN
        --and SER.PRN     = LST.RN
        and LST.FACEACC = FA.RN
        and LST.MATRES  = MTR.RN
    ) loop
      nSHEET := nSHEET + 1;
      sFORM := cFORM||'_'||to_char(nSHEET);
      nSIGN_PRINT := 0;
      PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM => cFORM, sSHEET_NAME_TO => sFORM);
      PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sFORM);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => sOrder, sCELL_VALUE => 'Заказ на производство: ' || rprt.sOrd);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => sIzd,   sCELL_VALUE => 'Изделие: ' || rprt.sMainProd);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => sZav,   sCELL_VALUE => 'зав.№ ' || trim(rprt.sZav) || ' (' || rprt.sPriem || ')');

      n := n + 1;
  end loop;

  end if;

--if /*false and*/ utilizer = 'KHOK' then
  if sNote is not null then
    if n = 0 then
      sNote := sNote || '. '|| chr(10) || sPartNote || chr(10) || 
               to_char(dRegDate, 'DD.MM.YYYY HH24:MI') || chr(10) || sName;
    end if;

    if nSIGN_PRINT = 1 then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDEFF_1, sCELL_VALUE => sNote);
    elsif nSIGN_PRINT = 2 then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDEFF_2, sCELL_VALUE => sNote);
    else
      p_exception(0, 'nSIGN_PRINT = %s', nSIGN_PRINT);
    end if;
    n := n + 1;
  end if;
--end if;

  --p_exception(0, 'n = %s', n);
  -- подчистка
  if n > 0 then PRSG_EXCEL.SHEET_DELETE(sSHEET_NAME => cFORM); end if;
  
end;
/
