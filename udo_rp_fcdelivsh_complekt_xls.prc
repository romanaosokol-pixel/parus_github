create or replace procedure UDO_RP_FCDELIVSH_COMPLEKT_XLS
(
  nCOMPANY in number,
  nIDENT   in number,
  sInSTORE   in varchar
) as
  /*
    25/05/2023 Столярский Е.
    Комплектовочные ведомости (Подбор ТМЦ)
    Отчет "Комплектовочная ведомость (Подбор ТМЦ)" - для склада
  */
  -- описание отчета
  cFORM  constant varchar2(20) := 'Комплектация';
  cHEAD  constant varchar2(20) := 'DOC_NUMB';
  cCOMPLECT constant varchar2(20) := 'DOC_COMPLECT';
  cZAKAZ   constant varchar2(20) := 'DOC_ZAKAZ';
  cTEMA  constant varchar2(20) := 'DOC_TEMA';
  cDOC_QUANT  constant varchar2(20) := 'DOC_QUANT';
  --
  cLINE_1 constant varchar2(20) := 'LLINE';
  --

  cNPP_2      constant varchar2(20) := 'NPP';
  SARTICLE    constant varchar2(20) := 'SARTICLE';
  sNOMENMANE  constant varchar2(20) := 'sNOMENMANE';
  cQUANT      constant varchar2(20) := 'QUANT';
  cSERNUMB    constant varchar2(20) := 'SERNUMB';
  E_CODE      constant varchar2(20) := 'E_CODE';
  SEL_STORE   constant varchar2(20) := 'SEL_STORE';
  --
  n       integer;
  iCOUNT  integer;
  nMATRES number(17);
  sARTCL  varchar2(2000);
  nQUANT  number(17);
  sNUMB   varchar2(240);
  sORD    varchar2(2000);
  sVERS   varchar2(240);
  sTEMA   varchar2(240);
  sDOCS   varchar2(2000);
  dTMP    date;
  sTMP   PKG_STD.tSTRING;

begin
  --
--  P_exception(0,'err='||sInSTORE);
  begin
    select distinct DL.MATRES
      into nMATRES
      from FCDELIVSH  DL
     where DL.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT);
  exception
    when no_data_found then
      p_exception(0, 'Данные для печати не найдены.');
    when too_many_rows then
      null;
    /*  p_exception(0,
                  'Ведомость печатается только для одного вида изделия.');*/
  end;
  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cHEAD);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cCOMPLECT);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cZAKAZ);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cTEMA);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cDOC_QUANT);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_1);
  --
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cNPP_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => SARTICLE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => sNOMENMANE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cQUANT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cSERNUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => E_CODE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => SEL_STORE);
  -- печать
  nQUANT := 0;
  -- по документам
  for rdc in (select trim(TD.PREF) || '-' || trim(TD.NUMB) NUMB,
                     TD.DOCDATE
                from FCDELIVSH    TD,
                     SELECTLIST   SL
               where SL.DOCUMENT = TD.RN
                 and SL.IDENT = nIDENT
                order by TD.DOCDATE, TD.PREF, TD.NUMB) loop
    if dTMP is null then
      dTMP := rdc.docdate;
    else
      if dTMP != rdc.docdate then
        sDOCS := sDOCS||' от '||to_char(dTMP, 'dd.mm.yyyy');
      end if;
      dTMP := rdc.docdate;
    end if;
    if sDOCS is null then
      sDOCS := rdc.numb;
    else
      sDOCS := sDOCS||';'||rdc.numb;
    end if;
  end loop;
  sDOCS := sDOCS||' от '||to_char(dTMP, 'dd.mm.yyyy');
  --
  for rrl in (select NM.NOMEN_NAME,
                     NM.NOMEN_CODE,
                     DL.QUANT QUANT_PLAN,
                     trim(DL.PREF) || '-' || trim(DL.NUMB)   as TR_NUMB,
                     UDO_F_FCDELIVSH_PRODUCT_NUM(DL.RN)      as ORD_NUM,
                     UDO_F_FCDELIVSH_MAIN_NUMB(NRN => DL.RN) as sProd_NUM,
                     UDO_F_FCDELIVSH_PRJSHEFR(Nprod_order => DL.Prod_Order) as TEMA
                     
                from FCROUTLST      RL,
                     DOCLINKS       LR,
                     FCDELIVSH      DL,
                     FCMATRESOURCE  MR,
                     DICNOMNS       NM
               where DL.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                 and LR.OUT_DOCUMENT = DL.RN
                 and LR.OUT_UNITCODE = 'CostDeliverySheets'
                 and LR.IN_DOCUMENT = RL.RN
                 and LR.IN_UNITCODE = 'CostRouteLists'
                 and DL.MATRES = MR.RN
                 and MR.NOMENCLATURE = NM.RN
               order by RL.RN) loop
    --
    if rrl.sProd_NUM is not null then
    if sNUMB is null then
      sNUMB := rrl.sProd_NUM;
    else
      if instr(sNUMB, rrl.sProd_NUM) > 0 then
        null;
      else
        sNUMB := sNUMB || '; ' || rrl.sProd_NUM;
      end if;
    end if;
    end if;
    --
    if rrl.ord_num is not null then
    if sORD is null then
      sORD := rrl.ord_num;
    else
      if instr(sORD, rrl.ord_num) > 0 then
        null;
      else
        sORD := sORD || '; ' || rrl.ord_num;
      end if;
    end if;
    end if;
    --
    if trim(rrl.sProd_NUM) <> '-' then
      sTMP := rrl.nomen_name || ' № '|| rrl.sProd_NUM;
    else
      sTMP := rrl.nomen_name;
    end if;
    if sARTCL is null then
      sARTCL := sTMP;
    else
      if instr(sARTCL, rrl.nomen_name) > 0 then
        null;
      else
        if length(sARTCL || '; ' || sTMP) <= 2000 then
          sARTCL := sARTCL || '; ' ||sTMP;
        end if;
      end if;
    end if;
    --
    nQUANT := nQUANT + rrl.quant_plan;
    sTEMA  := rrl.tema;
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME  => cHEAD,
                              sCELL_VALUE => 'Ведомость комплектования '||rrl.TR_NUMB||' от ' || to_char(sysdate, 'dd.mm.yyyy HH24:MI'));
  end loop;
  --
--  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cNUMB, sCELL_VALUE => sNUMB);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cTEMA, sCELL_VALUE => sTEMA);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cZAKAZ, sCELL_VALUE => sORD);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cCOMPLECT, sCELL_VALUE => sARTCL);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDOC_QUANT, sCELL_VALUE => sInSTORE);
  --
  iCOUNT := 0;
  for recs in (select sum(TT.QUANT)      as nQUANT,
                    --  sum(TT.QUANT_FACT) as QUANT_FACT,
                    --  sum(TT.DL_QUANT)   as DL_QUANT,
                    --  TT.NOMEN_FACT,
                      TT.NOMEN_PLAN,
                      TT.MODIF_PLAN,
                      TT.NM_FACT_RN,
                      TT.NM_PLAN_RN,
                 --     TT.POS,
                      TT.SERNUMB,
                      TT.CERTIFICATE,
                      TT.dMake,
                      TT.MAKED,
                      TT.scells,
                      TT.sPoz,
                      TT.MEAS_MNEMO
                  --    TT.AZS_NUMBER
                 from (select FCPL.QUANT as QUANT,
                          --    DLS.QUANT_PLAN,
                          --    DLS.QUANT_CMPL as QUANT_FACT,
                          --    DL.QUANT as DL_QUANT,
                              null /*NMF.RN*/ as NM_FACT_RN,
                              null /*NMF.NOMEN_NAME*/ as NOMEN_FACT,
                              NMP.RN as NM_PLAN_RN,
                              NMP.NOMEN_NAME as NOMEN_PLAN,
                              case
                                when instr(MDP.MODIF_NAME, '_') > 0
                                  then replace(MDP.MODIF_NAME, NMP.NOMEN_CODE||'_')
                                else ' '
                              end as MODIF_PLAN,
                            --  UDO_F_FCDELIVSHSP_SEAT_PRODLST(NRN => DLS.RN) as POS,
                              GP.SERNUMB,
                              GP.CERTIFICATE,
                              (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW 
                                where DOCS_PROP_RN = 41270835 
                                  and UNITCODE = 'GoodsParties' and UNIT_RN = GP.RN) as dMake,
                              (select DV.STR_VALUE
                                 from INORDERSPECS    IOS,
                                      GOODSSUPPLY     GS,
                                      DOCS_PROPS_VALS DV
                                where GS.PRN = GP.RN
                                  and IOS.GOODSSUPPLY = GS.RN
                                  and DV.UNIT_RN = IOS.RN
                                  and DV.DOCS_PROP_RN = 12114824
                                  and rownum < 2) as MAKED,
                              nvl(CDS.scells,'- нет -')     as scells,
                              UDO_F_FCDELIVSHSP_POS_PRODLST(DLS.RN) as sPoz,
                              DUN.MEAS_MNEMO
                        --      STR.AZS_NUMBER ||' - '||sInSTORE  as AZS_NUMBER
                         from FCDELIVSHSP       DLS,
                              FCMATRESOURCE     MRP,
                              DICNOMNS          NMP,
                              NOMMODIF          MDP,
                              GOODSPARTIES      GP,
                              FCDELIVSH         DL,
                              FCDELIVSHSPCMPL   FCPL,
                              UDO_V_STPLGOODSSUPPLY_CDSSC CDS,
                              DICMUNTS           DUN
                           --   AZSAZSLISTMT       STR
                        where DLS.PRN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                          and DLS.MATRES = MRP.RN
                          and DLS.STATE = 1 -- СОСТОЯНИЕ В РАБОТЕ
                          and MRP.NOMENCLATURE = NMP.RN
                          and NMP.UMEAS_MAIN = DUN.RN
                          and MRP.NOMEN_MODIF = MDP.RN
                          and FCPL.prn = DLS.RN
                          and FCPL.PARTY = GP.RN
                          and DLS.PRN = DL.RN
                          and GREATEST(DLS.quant_dlvr, UDO_F_FCDELIVSHSP_1C_LOAD(DLS.RN)) < DLS.QUANT_CMPL
                          and (sInSTORE like '%'||CDS.sstore||'%' or sInSTORE is null)
                          and CDS.nPrn (+) = FCPL.RN) TT
                group by TT.NOMEN_FACT,
                         TT.NOMEN_PLAN,
                         TT.MODIF_PLAN,
                         TT.NM_FACT_RN,
                         TT.NM_PLAN_RN,
                      --   TT.POS,
                         TT.SERNUMB,
                         TT.CERTIFICATE,
                         TT.dMake,
                         TT.MAKED,
                         TT.scells,
                         TT.sPoz,
                         TT.MEAS_MNEMO
                       --  TT.AZS_NUMBER
                order by to_number(TT.sPoz), TT.NOMEN_FACT) loop
  
    iCOUNT := iCOUNT + 1;
    n      := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_1);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNPP_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => to_char(recs.sPoz));
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => sNOMENMANE,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.nomen_plan);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => SARTICLE , iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => recs.modif_plan);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cQUANT,  iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, nCELL_VALUE => recs.nQUANT);
   /* if recs.nm_fact_rn != recs.nm_plan_rn then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDIFF_2,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => recs.nomen_fact);
    end if;*/
  /*  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                nCELL_VALUE   => round(recs.quant_fact / recs.dl_quant, 0));
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_T_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                nCELL_VALUE   => recs.quant_fact);*/
--    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPOS_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => recs.pos);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSERNUMB,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.sernumb);
   
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => E_CODE,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.MEAS_MNEMO);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => SEL_STORE,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.scells/*||' / '||recs.AZS_NUMBER*/);
  
/*    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSERT_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.certificate);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cSROK_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => '');
*/  
  end loop;

  -- подчистка
  PRSG_EXCEL.LINE_DELETE(cLINE_1);

end;
/

