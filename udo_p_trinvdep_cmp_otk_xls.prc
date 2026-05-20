create or replace procedure UDO_P_TRINVDEP_CMP_OTK_XLS
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    08/09/2022 Марков МВ.
    Расходные накладные на отпуск в подразделения
    Отчет "Комплектовочная ведомость (накладные)" - для ОТК
  */
  -- описание отчета
  cFORM  constant varchar2(20) := 'Комплектация';
  cHEAD  constant varchar2(20) := 'заголовок';
  cARTCL constant varchar2(20) := 'изделие';
  cQUANT constant varchar2(20) := 'количество';
  cNUMB  constant varchar2(20) := 'номер';
  cORD   constant varchar2(20) := 'заявка';
  cVERS  constant varchar2(20) := 'версия';
  cTEMA  constant varchar2(20) := 'тема';
  cDOCS  constant varchar2(20) := 'требование';
  --
  cLINE_1 constant varchar2(20) := 'строка_1';
  cLINE_3 constant varchar2(20) := 'строка_3';
  --
  cLINE_2  constant varchar2(20) := 'строка_2';
  cNPP_2   constant varchar2(20) := 'нпп_2';
  cNAME_2  constant varchar2(20) := 'наименование_2';
  cCODE_2  constant varchar2(20) := 'обозначение_2';
  cVZAM_2  constant varchar2(20) := 'в_зам_2';
  cDIFF_2  constant varchar2(20) := 'замена_2';
  cQNT_2   constant varchar2(20) := 'количество_2';
  cQNT_T_2 constant varchar2(20) := 'кол_всего_2';
  cPOS_2   constant varchar2(20) := 'позиция_2';
  cSER_2   constant varchar2(20) := 'серия_2';
  cPARTY_2 constant varchar2(20) := 'партия_2';
  cPLACE_2 constant varchar2(20) := 'место_2';
  cMAKE_2  constant varchar2(20) := 'изготовл_2';
  cSERT_2  constant varchar2(20) := 'сертиф_2';
  cSROK_2  constant varchar2(20) := 'срок_2';
  --
  n       integer;
  iCOUNT  integer;
  nMATRES number(17);
  sARTCL  varchar2(2000);
  nQUANT  number(17);
  sNUMB   varchar2(2000);
  sORD    varchar2(2000);
  sVERS   varchar2(240);
  sTEMA   varchar2(240);
  sDOCS   varchar2(2000);
  dTMP    date;
  sTMP    varchar2(2000);
  sPLACES PKG_STD.tSTRING;
  sZamena varchar2(240);

  sSERNUMB varchar2(240);
  sPLACES_prev PKG_STD.tSTRING;
  nQUANT_FACT number(17);
  --
  function get_matres_name(nMODIF in number) return varchar2 is
    sRES varchar2(2000);
  begin
    select MR.NAME
      into sRES
      from FCMATRESOURCE MR
     where MR.NOMEN_MODIF = nMODIF;
    return sRES;
  exception
    when no_data_found then
      return '';
  end get_matres_name;
  
begin
  --
  begin
    select distinct DL.MATRES
      into nMATRES
      from FCDELIVSH DL,
           DOCLINKS  L
     where L.OUT_DOCUMENT in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
       and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
       and L.IN_DOCUMENT = DL.RN
       and L.IN_UNITCODE = 'CostDeliverySheets'
       and dl.company = nCOMPANY;
  exception
    when no_data_found then --nMATRES := 0;
      p_exception(0, 'Данные для печати не найдены.');
    when too_many_rows then
      p_exception(0, 'Ведомость печатается только для одного вида изделия.');
  end;
  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cHEAD);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cARTCL);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cQUANT);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cNUMB);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cORD);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cVERS);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cTEMA);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cDOCS);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_1);
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_3);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cNPP_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cNAME_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cCODE_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cVZAM_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cDIFF_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cQNT_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cQNT_T_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cPOS_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cSER_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cPARTY_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cPLACE_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cMAKE_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cSERT_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cSROK_2);
  -- печать
  nQUANT := 0;
  -- по документам
  for rdc in (select trim(TD.PREF) || '-' || trim(TD.NUMB) NUMB,
                     TD.DOCDATE
                from TRANSINVDEPT TD,
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
    else sDOCS := sDOCS||'; '||rdc.numb;
    end if;
  end loop;
  sDOCS := sDOCS||' от '||to_char(dTMP, 'dd.mm.yyyy');
  --
  for rrl in (select NM.NOMEN_NAME,
                     NM.NOMEN_CODE,
                     DL.QUANT QUANT_PLAN,
                     trim(TD.PREF) || '-' || trim(TD.NUMB) as TR_NUMB,
                     (select UDO_PKG_FCPRODPLAN_UTL.SP_GET_PRODORD(nPRODPLANSP => PSP2.RN)
                        from FCPRODPLANSP PSP1,
                             DOCLINKS     LPS1,
                             FCPRODPLANSP PSP2
                       where LPS1.OUT_UNITCODE = 'CostRouteLists'
                         and LPS1.OUT_DOCUMENT = RL.RN
                         and LPS1.IN_UNITCODE = 'CostProductPlansSpecs'
                         and LPS1.IN_DOCUMENT = PSP1.RN
                         and PSP1.PRN_NODE = PSP2.RN
                         and rownum < 2) as ORD_NUM,
                     UDO_F_INVDEPT_OTK_ISP(nRN => TD.RN) as sOTK, -- KHOK 03.05.2023
                     UDO_F_TRANSINVDEPT_MAIN_NUMB(NRN => TD.RN) as ARTCL,
                     (select STR_VALUE
                        from V_DOCS_PROPS_VALS_SHADOW
                       where DOCS_PROP_RN = 13459644
                         and UNITCODE = 'CostRouteLists'
                         and UNIT_RN = rl.RN) VERS,
                     (select P.NAME_USL
                        from PROJECT      P,
                             PROJECTSTAGE PS
                       where PS.FACEACC = RL.FACEACC
                         and PS.PRN = P.RN) as TEMA
                from FCROUTLST      RL,
                     DOCLINKS       LR,
                     FCDELIVSH      DL,
                     DOCLINKS       LD,
                     FCMATRESOURCE  MR,
                     DICNOMNS       NM,
                     TRANSINVDEPT   TD
               where TD.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                 and LD.OUT_DOCUMENT = TD.RN
                 and LD.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                 and LD.IN_DOCUMENT = DL.RN
                 and LD.IN_UNITCODE = 'CostDeliverySheets'
                 and LR.OUT_DOCUMENT = DL.RN
                 and LR.OUT_UNITCODE = 'CostDeliverySheets'
                 and LR.IN_DOCUMENT = RL.RN
                 and LR.IN_UNITCODE = 'CostRouteLists'
                 and DL.MATRES = MR.RN
                 and MR.NOMENCLATURE = NM.RN
               order by RL.RN) loop
    --
    if rrl.artcl is not null then
    if sNUMB is null then
      sNUMB := rrl.artcl;
    else
      if instr(sNUMB, rrl.artcl) = 0 then
        sNUMB := sNUMB || ';' || rrl.artcl;
      end if;
    end if;
    end if;
    --
    if rrl.ord_num is not null then
      if sORD is null then
        sORD := rrl.ord_num;
      else
        if instr(sORD, rrl.ord_num) = 0 then
          sORD := sORD || ';' || rrl.ord_num;
        end if;
      end if;
    end if;
    if length(rrl.sOTK) > 3 then
      if instr(sORD, rrl.sOTK) = 0 then
        sORD := sORD || '; ' || rrl.sOTK;
      end if;
    end if;
    --
    if sARTCL is null then
      sARTCL := rrl.nomen_name;
    else
      if instr(sARTCL, rrl.nomen_name) > 0 then
        null;
      else
        if length(sARTCL || ';' || rrl.nomen_name) <= 2000 then
          sARTCL := sARTCL || ';' || rrl.nomen_name;
        end if;
      end if;
    end if;
    --
    nQUANT := nQUANT + rrl.QUANT_PLAN;
    sTEMA  := rrl.TEMA;
    if rtrim(rrl.VERS) is not null then
      sVERS  := rrl.VERS;
    end if;
  end loop;
  --
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME  => cHEAD,
                              sCELL_VALUE => 'Ведомость комплектования от ' || to_char(sysdate, 'dd.mm.yyyy HH24:MI'));
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cNUMB,  sCELL_VALUE => sNUMB);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cQUANT, nCELL_VALUE => nQUANT);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cTEMA,  sCELL_VALUE => sTEMA);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cORD,   sCELL_VALUE => sORD);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cARTCL, sCELL_VALUE => sARTCL);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cDOCS,  sCELL_VALUE => sDOCS);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cVERS,  sCELL_VALUE => sVERS);
  --
  iCOUNT := 0;
  
  /* 28/03/2024 Марков МВ. изменил выборку для исключения дублей
  
  for recs in (select sum(TT.QUANT_FACT) as QUANT_FACT,
                      -- 07/11/2023 Марков МВ. Так нельзя!!!! sum(TT.QUANT_FACT_NEW) as QUANT_FACT_NEW,
                      sum(TT.DL_QUANT)   as DL_QUANT,
                      sum(TT.QUANT_PLAN) as QUANT_PLAN,
                      TT.NOMEN_FACT,
                      TT.NOMEN_PLAN,
                      TT.MODIF_PLAN,
                      TT.MODIF_FACT,
                      TT.NM_FACT_RN,
                      TT.NM_PLAN_RN,
                      TT.POS,
                      TT.SERNUMB,
                      TT.CERTIFICATE,
                      TT.dMake,
                      TT.MAKED
                 from (select --TDS.QUANT,
                              DLS.QUANT_PLAN,
                              TDS.QUANT      as QUANT_FACT,
                              --DLSCMPL.Quant  as QUANT_FACT_NEW,
                              DL.QUANT       as DL_QUANT,
                              --NMF.RN as NM_FACT_RN,
                              MDF.RN         as NM_FACT_RN,
                              NMF.NOMEN_NAME as NOMEN_FACT,
                              --NMP.RN as NM_PLAN_RN,
                              MDP.RN         as NM_PLAN_RN,
                              NMP.NOMEN_NAME as NOMEN_PLAN,
                              case
                                when instr(MDP.MODIF_NAME, '_') > 0
                                  then replace(MDP.MODIF_NAME, NMP.NOMEN_CODE||'_')
                                else ''
                              end as MODIF_PLAN,
                              case
                                when instr(MDF.MODIF_NAME, '_') > 0
                                  then replace(MDF.MODIF_NAME, NMF.NOMEN_CODE||'_')
                                else ''
                              end as MODIF_FACT,
                              UDO_F_FCDELIVSHSP_SEAT_PRODLST(NRN => DLS.RN) as POS,
                              -- 21/09/2023 Марков МВ. для серийных номеров нет партии, а ссылка на серийный номер
                              case
                                when TDS.ARTICLE is not null then
                                  (select replace(RA.CODE, NMF.NOMEN_CODE||'_')
                                     from RLARTICLES RA
                                    where RA.RN = TDS.ARTICLE)
                                when TDS.GOODSPARTY is not null then
                                  (select GP.SERNUMB from GOODSPARTIES GP where GP.RN = TDS.GOODSPARTY)
                                else null
                              end           as SERNUMB,
                              case
                                when TDS.ARTICLE is not null and TD.STATUS = 0 then
                                  (select GP.CERTIFICATE 
                                     from ARTICLESSUPPLY ASP, GOODSSUPPLY GS, GOODSPARTIES GP
                                    where ASP.ARTICLE = TDS.ARTICLE
                                      and ASP.PRN = GS.RN
                                      and GS.PRN = GP.RN)
                                when TDS.GOODSPARTY is not null then
                                  (select GP.CERTIFICATE from GOODSPARTIES GP where GP.RN = TDS.GOODSPARTY)
                                else null
                              end           as CERTIFICATE,
                              case
                                when TDS.GOODSPARTY is not null then
                                  (select STR_VALUE
                                     from V_DOCS_PROPS_VALS_SHADOW 
                                    where DOCS_PROP_RN = 41270835 
                                      and UNITCODE = 'GoodsParties' 
                                      and UNIT_RN = TDS.GOODSPARTY)
                                else null
                              end           as dMake,
                              case
                                when TDS.GOODSPARTY is not null then
                                  (select DV.STR_VALUE
                                     from INORDERSPECS    IOS,
                                          GOODSSUPPLY     GS,
                                          DOCS_PROPS_VALS DV
                                    where GS.PRN = TDS.GOODSPARTY
                                      and IOS.GOODSSUPPLY = GS.RN
                                      and DV.UNIT_RN = IOS.RN
                                      and DV.DOCS_PROP_RN = 12114824
                                      and rownum < 2)
                                else null
                              end           as MAKED
                              -- Марков МВ. посмотрим по 1с
                              \*,(select
                                 from UDO_NOMODIF_SERIES NS
                                where NS.PRN = TDS.NOMMODIF
                                  and *\
                         from TRANSINVDEPTSPECS TDS,
                              DOCLINKS          LT,
                              --FCDELIVSHSPCMPL   DLSCMPL,
                              FCDELIVSHSP       DLS,
                              FCMATRESOURCE     MRF,
                              DICNOMNS          NMF,
                              FCMATRESOURCE     MRP,
                              DICNOMNS          NMP,
                              NOMMODIF          MDP,
                              NOMMODIF          MDF,
                              -- 21/09/2023 Марков МВ. GOODSPARTIES      GP,
                              FCDELIVSH         DL,
                              TRANSINVDEPT      TD
                        where TDS.PRN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                          and LT.OUT_DOCUMENT = TDS.RN
                          and LT.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                          and LT.IN_DOCUMENT = DLS.RN
                          and LT.IN_UNITCODE = 'CostDeliverySheetsSpec'
                          and MRF.NOMEN_MODIF = TDS.NOMMODIF
                          and MRF.NOMENCLATURE = NMF.RN
                          and DLS.MATRES = MRP.RN
                          and MRP.NOMENCLATURE = NMP.RN
                          and MRP.NOMEN_MODIF = MDP.RN
                          and MRF.NOMEN_MODIF = MDF.RN
                          -- 21/09/2023 Марков МВ. and TDS.GOODSPARTY = GP.RN
                          and DLS.PRN = DL.RN
                          --and dlscmpl.party = tds.goodsparty
                          --and dls.matres = dlscmpl.MATRES
                          --and dls.rn  = dlscmpl.prn
                          and TDS.PRN = TD.RN) TT
                group by TT.NOMEN_FACT,
                         TT.NOMEN_PLAN,
                         TT.MODIF_PLAN,
                         TT.MODIF_FACT,
                         TT.NM_FACT_RN,
                         TT.NM_PLAN_RN,
                         TT.POS,
                         TT.SERNUMB,
                         TT.CERTIFICATE,
                         TT.dMake,
                         TT.MAKED
                order by TT.NOMEN_FACT) loop*/
  nQUANT_FACT := 0;
  -- по каждой позиции спецификации требования
  for recs in (select TDS.QUANT      as QUANT_FACT,
                      TDS.RN,
                      TD.STATUS,
                      MDF.RN         as NM_FACT_RN,
                      NMF.NOMEN_NAME as NOMEN_FACT,
                      case
                        when instr(MDF.MODIF_NAME, '_') > 0 then
                         replace(MDF.MODIF_NAME, NMF.NOMEN_CODE || '_')
                        else ''
                      end            as MODIF_FACT,
                      -- 21/09/2023 Марков МВ. для серийных номеров нет партии, а ссылка на серийный номер
                      case
                        when TDS.ARTICLE is not null then
                         (select replace(RA.CODE, NMF.NOMEN_CODE || '_') from RLARTICLES RA where RA.RN = TDS.ARTICLE)
                        when TDS.GOODSPARTY is not null then
                         (select GP.SERNUMB from GOODSPARTIES GP where GP.RN = TDS.GOODSPARTY)
                        else null
                      end            as SERNUMB,
                      case
                        when TDS.ARTICLE is not null and
                             TD.STATUS = 0 then
                         (select GP.CERTIFICATE
                            from ARTICLESSUPPLY ASP,
                                 GOODSSUPPLY    GS,
                                 GOODSPARTIES   GP
                           where ASP.ARTICLE = TDS.ARTICLE
                             and ASP.PRN = GS.RN
                             and GS.PRN = GP.RN)
                        when TDS.GOODSPARTY is not null then
                         (select GP.CERTIFICATE from GOODSPARTIES GP where GP.RN = TDS.GOODSPARTY)
                        else null
                      end            as CERTIFICATE,
                      /* Дата изготовления. Начало. */ -- ??? UDO_F_TRINDEPTSPECS_PROVDATE(TDS.RN) ??? KHOK
                      UDO_F_TRINDEPTSPECS_PROVDATE(TDS.RN) as dMake,
                      F_DOCS_PROPS_GET_STR_VALUE(nPROPERTY => 69192082, --'Партия поставщика'
                                                 sUNITCODE => 'GoodsParties',
                                                 nDOCUMENT => TDS.GOODSPARTY) as sParty /* 16/12/2025 KHOK */
                      /*case
                        when TDS.GOODSPARTY is not null then
                         (select STR_VALUE
                            from V_DOCS_PROPS_VALS_SHADOW
                           where DOCS_PROP_RN = 41270835
                             and UNITCODE = 'GoodsParties'
                             and UNIT_RN = TDS.GOODSPARTY)
                        else null
                      end            as dMake,
                      case
                        when TDS.GOODSPARTY is not null then
                         (select DV.STR_VALUE
                            from INORDERSPECS    IOS,
                                 GOODSSUPPLY     GS,
                                 DOCS_PROPS_VALS DV
                           where GS.PRN = TDS.GOODSPARTY
                             and IOS.GOODSSUPPLY = GS.RN
                             and DV.UNIT_RN = IOS.RN
                             and DV.DOCS_PROP_RN = 12114824
                             and rownum < 2)
                        else null
                      end            as MAKED,
                      -- Марков МВ. посмотрим по 1с
                      case
                        when TDS.GOODSPARTY is not null then
                         (select NS.PROD_DATE
                            from UDO_NOMODIF_SERIES NS,
                                 GOODSPARTIES       GP
                           where NS.PRN = TDS.NOMMODIF
                             and GP.RN = TDS.GOODSPARTY
                             and trim(GP.SERNUMB) = trim(NS.SERIES))
                      end            as MAKED_1C*/
                      /* Дата изготовления. Конец. */
                 from TRANSINVDEPTSPECS TDS,
                      FCMATRESOURCE     MRF,
                      DICNOMNS          NMF,
                      NOMMODIF          MDF,
                      TRANSINVDEPT      TD
                where TD.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                  and TDS.PRN = TD.RN
                  and MRF.NOMEN_MODIF = TDS.NOMMODIF
                  and MRF.NOMENCLATURE = NMF.RN
                  and MRF.NOMEN_MODIF = MDF.RN
                order by NMF.NOMEN_NAME, SERNUMB
    ) loop
      -- связаные строки КВ
      for rkvs in(select DLS.QUANT_PLAN,
                         DLS.QUANT_PROD,
                         DL.QUANT       as DL_QUANT,
                         MDP.RN         as MODIF_PLAN_RN,
                         NMP.NOMEN_NAME as NOMEN_PLAN,
                         case
                            when instr(MDP.MODIF_NAME, '_') > 0
                              then replace(MDP.MODIF_NAME, NMP.NOMEN_CODE||'_')
                            else ''
                         end as MODIF_PLAN,
                         UDO_F_FCDELIVSHSP_SEAT_PRODLST(NRN => DLS.RN) as POS,
                         -- сколько приходится на строку КВ
                         UDO_PKG_TRANSINVDEP_BASE_UTL.F_GET_CMPL_BY_SPEC(nSPEC => recs.rn, nSHEET => DLS.RN) as QUANT_KV,
                         DLS.RN as DELIVSH_SP
                    from DOCLINKS          LT,
                         FCDELIVSHSP       DLS,
                         FCDELIVSH         DL,
                         FCMATRESOURCE     MRP,
                         DICNOMNS          NMP,
                         NOMMODIF          MDP
                   where LT.OUT_DOCUMENT = recs.rn
                     and LT.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                     and LT.IN_DOCUMENT = DLS.RN
                     and LT.IN_UNITCODE = 'CostDeliverySheetsSpec'
                     and DLS.PRN = DL.RN
                     and DLS.MATRES = MRP.RN
                     and MRP.NOMENCLATURE = NMP.RN
                     and MRP.NOMEN_MODIF = MDP.RN
      ) loop
        -- места хранения. KHOK 24/09/2024 По заявке Погонина.
        begin
        select listagg(PP.SCELL_CODE, '; ') WITHIN GROUP (order by PP.SCELL_CODE)
          into sPLACES
          from(select distinct VP.SCELL_CODE
                 from V_STRPLRESJRNL_DOCS VP
                where VP.NRES_TYPE = 1
                  and exists (select *
                                from V_DOCLINKS_INOUT_IN_EXT DLIN
                               where (DLIN.NIN_DOCUMENT = recs.rn)
                                 and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                 and (DLIN.NDOCUMENT = VP.NRN))
               ) PP;
        exception
          when NO_DATA_FOUND then sPLACES := '-';
        end;

        if recs.nm_fact_rn != rkvs.MODIF_PLAN_RN then
          /* 14/07/2025 KHOK. Основание изменения */
          begin        
            select distinct CASE 
                    WHEN SP.SIGN_PI = 1       then 'ПИ'
                    WHEN SP.CORR_SPEC = 1     then 'КС'
                    WHEN SP.SIGN_PERMCARD = 1 then 'КР'
                    WHEN SP.ANALOG = 1        then 'Аналог'
                    WHEN SP.D28 = 1           then 'Д28'
                    ELSE 'Д28.'
                    END || chr(13) || sub.val_numb 
              into sZamena
              from UDO_FCDELIVSHSUB sub
                  ,UDO_DEPORDDIR    dir
                  ,UDO_DEPORDDIR_SP sp
                  ,UDO_DEPORDDIR_CHNG chg
             where sub.PRN = rkvs.DELIVSH_SP
               and trim(dir.doc_pref) = substr(sub.val_numb, 0, 4)
               and trim(dir.doc_numb) = substr(sub.val_numb, INSTR(sub.val_numb, '-')+1)
               and sp.prn = dir.rn
               and chg.prn = sp.rn
               and sp.modif = rkvs.MODIF_PLAN_RN
               and chg.modif_chng = recs.nm_fact_rn
               and trim(sub.val_numb) is not null
               /*and sub.used = 1
               and rownum < 2*/
               ;
          exception
            when NO_DATA_FOUND then sZamena := to_char(null);
          end;
        else sZamena := to_char(null);
        end if;
      /*15/09/2025 KHOK. Попытка просуммировать одинаковое */
/*if utilizer = 'KHOK' then
      if sZamena is null and sSERNUMB = recs.sernumb and sPLACES = sPLACES_prev then
        nQUANT_FACT := nQUANT_FACT + recs.quant_fact;
--if utilizer = 'KHOK' then p_exception(0,sSERNUMB || ' - ' ||nQUANT_FACT); end if; 
      else
        nQUANT_FACT := recs.quant_fact;
        iCOUNT := iCOUNT + 1;
        n      := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_2);
      end if;
      \* Конец суммирования *\
else*/
    nQUANT_FACT := recs.quant_fact;
    ---- печать
    iCOUNT := iCOUNT + 1;
    n      := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_2);
--end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNPP_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => to_char(iCOUNT));
    sTMP := get_matres_name(nMODIF => rkvs.MODIF_PLAN_RN); --recs.nm_plan_rn);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNAME_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => nvl(sTMP, rkvs.nomen_plan)); --recs.nomen_plan));
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cCODE_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rkvs.modif_plan); --recs.modif_plan);
    if recs.nm_fact_rn != rkvs.MODIF_PLAN_RN then --recs.nm_plan_rn then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cVZAM_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => sZamena);

      sTMP := get_matres_name(nMODIF => recs.nm_fact_rn);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDIFF_2,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => nvl(sTMP, recs.nomen_fact||' ('||recs.MODIF_FACT||')'));
    end if;
 
  
   PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_2,
                               iCELL_INDEX_X => 0,
                               iCELL_INDEX_Y => n,
                             --  nCELL_VALUE   =>  round(rkvs.quant_plan / rkvs.dl_quant, 0)); -- recs.quant_plan / recs.dl_quant, 0));
                             nCELL_VALUE   =>  round(nvl(rkvs.quant_plan / rkvs.dl_quant, rkvs.quant_prod), 0)); -- 12/11/2025 Марков МВ. количество на изделие
                                
                             
    -- 16/05/2024 Марков МВ.
    -- бывают странные случаи, когда одна срока комплектования на два документа!?!?!
    if /*KHOK recs.quant_fact*/ nQUANT_FACT >= rkvs.quant_kv then
      -- количество из спецификации накладной
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_T_2,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rkvs.quant_kv) ;--recs.quant_fact);  
    else
      -- количество из комплектования КВ
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_T_2,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => nQUANT_FACT /*KHOK recs.quant_fact*/);
    end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPOS_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rkvs.pos); --recs.pos);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSER_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.sernumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cPARTY_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.sParty);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cPLACE_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => sPLACES);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cMAKE_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => nvl(recs.dMake, to_char(null))); --nvl(recs.maked, recs.MAKED_1C)));
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSERT_2,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => recs.certificate);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cSROK_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => '');

      end loop;

    sSERNUMB := recs.sernumb;
    sPLACES_prev := sPLACES;
  end loop;
  --end loop;

  -- подчистка
  PRSG_EXCEL.LINE_DELETE(cLINE_1);
  PRSG_EXCEL.LINE_DELETE(cLINE_2);
  PRSG_EXCEL.LINE_DELETE(cLINE_3);
end;
/
