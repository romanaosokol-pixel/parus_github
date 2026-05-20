create or replace procedure UDO_P_PRODPLAN_DEFF_TMP
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    04/03/2023 Марков МВ.
    Дефицит по запускам
    По отмеченным записям строк производственной программы
    UDO_PRODPLAN_DEFF_TMP_PSP -- список строк плана производства
    UDO_PRODPLAN_DEFF_TMP_ART -- список маршрутных листов и серийных номеров готовых изделий
    UDO_PRODPLAN_DEFF_TMP_DSE -- список сборочных единиц к готовым изделиям, включая готовое изделие
    UDO_PRODPLAN_DEFF_TMP_DSH -- список КВ по сборочным единицам
    UDO_PRODPLAN_DEFF_TMP_DSH_SVOD -- сводный список по дефициту
    UDO_PRODPLAN_DEFF_TMP_DIR -- список замен по номенклатурам
    UDO_PRODPLAN_DEFF_TMP_BUY -- план закупок
  */

  rPSP UDO_PRODPLAN_DEFF_TMP_PSP%rowtype;
  rART UDO_PRODPLAN_DEFF_TMP_ART%rowtype;
  rDSE UDO_PRODPLAN_DEFF_TMP_DSE%rowtype;
  rDSH UDO_PRODPLAN_DEFF_TMP_DSH%rowtype;
  rSVD UDO_PRODPLAN_DEFF_TMP_DSH_SVOD%rowtype;
  nTMP number(17);
  --
  procedure clear_tmp is
  begin
    delete from UDO_PRODPLAN_DEFF_TMP_PSP where AUTHID = utilizer;
    delete from UDO_PRODPLAN_DEFF_TMP_ART where AUTHID = utilizer;
    delete from UDO_PRODPLAN_DEFF_TMP_DSE where AUTHID = utilizer;
    delete from UDO_PRODPLAN_DEFF_TMP_DSH where AUTHID = utilizer;
    delete from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD where AUTHID = utilizer;
    delete from UDO_PRODPLAN_DEFF_TMP_DIR where AUTHID = utilizer;
    delete from UDO_PRODPLAN_DEFF_TMP_BUY where AUTHID = utilizer;
  end clear_tmp;
  --
  procedure ins_psp(rROW in out UDO_PRODPLAN_DEFF_TMP_PSP%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_PSP values rROW;
  end ins_psp;
  --
  procedure ins_art(rROW in out UDO_PRODPLAN_DEFF_TMP_ART%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_ART values rROW;
  end ins_art;
  --
  procedure ins_dse(rROW in out UDO_PRODPLAN_DEFF_TMP_DSE%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_DSE values rROW;
  end ins_dse;
  --
  procedure ins_dsh(rROW in out UDO_PRODPLAN_DEFF_TMP_DSH%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_DSH values rROW;
  end ins_dsh;
  --
  procedure ins_svd(rROW in out UDO_PRODPLAN_DEFF_TMP_DSH_SVOD%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_DSH_SVOD values rROW;
  end ins_svd;
  --
  procedure ins_dir(rROW in out UDO_PRODPLAN_DEFF_TMP_DIR%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_DIR values rROW;
  end ins_dir;
  --
  procedure ins_buy(rROW in out UDO_PRODPLAN_DEFF_TMP_BUY%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODPLAN_DEFF_TMP_BUY values rROW;
  end ins_buy;
  --
  procedure dse_list(nPSP_RN in number) is
  begin
    for rds in (select PSP.RN,
                       PSP.PRN_NODE,
                       LST.RN as LST_RN,
                       RA.RN as ART_RN,
                       (select count(*)
                          from DOCLINKS LD
                         where LD.IN_DOCUMENT = LST.RN
                           and LD.IN_UNITCODE = 'CostRouteLists'
                           and LD.OUT_UNITCODE = 'CostDeliverySheets') SH_CNT
                  from FCPRODPLANSP     PSP,
                       FCROUTLST        LST,
                       DOCLINKS         L,
                       FCROUTLSTSERNUMB LSR,
                       RLARTICLES       RA
                 where PSP.PRN_NODE = nPSP_RN
                   and L.IN_DOCUMENT = PSP.RN
                   and L.OUT_DOCUMENT = LST.RN
                   and LSR.PRN = LST.RN
                   and LSR.ARTICLE = RA.RN
                   and not exists (select null
                          from DOCLINKS           LI,
                               INCOMEFROMDEPSSPEC IFS
                         where LI.IN_DOCUMENT = LST.RN
                           and LI.OUT_DOCUMENT = IFS.PRN
                           and IFS.ARTICLE = LSR.ARTICLE)
                 order by PSP.RN) loop
      -- дсе
      rDSE.Prodplansp := rds.rn;
      rDSE.Prn_Node   := rds.prn_node;
      rDSE.Lst        := rds.lst_rn;
      rDSE.Article    := rds.art_rn;
      rDSE.Sh_Cnt     := rds.sh_cnt;
      ins_dse(rROW => rDSE);
    end loop;
  end dse_list;
  -- комплектование
  procedure cmpl_create(nLST in number) is
  begin
    for rcmp in (select SHS.RN,
                        SHS.PRN,
                        SHS.MATRES,
                        SHS.QUANT_PLAN,
                        SHS.QUANT_CMPL,
                        SHS.QUANT_DLVR,
                        (select nvl(sum(TDS.QUANT), 0) from TRANSINVDEPT TD, TRANSINVDEPTSPECS TDS, DOCLINKS LT
                          where LT.IN_UNITCODE = 'CostDeliverySheets' and LT.IN_DOCUMENT = SHS.PRN
                            and LT.OUT_UNITCODE = 'GoodsTransInvoicesToDepts' and LT.OUT_DOCUMENT = TD.RN
                            and TDS.PRN = TD.RN and TDS.NOMMODIF = MR.NOMEN_MODIF) as TD_QUANT
                   from FCROUTLST   LST,
                        FCDELIVSHSP SHS,
                        DOCLINKS    L,
                        FCMATRESOURCE MR
                  where LST.RN = nLST
                    and L.IN_DOCUMENT = LST.RN
                    and L.IN_UNITCODE = 'CostRouteLists'
                    and L.OUT_DOCUMENT = SHS.PRN
                    and L.OUT_UNITCODE = 'CostDeliverySheets'
                    and SHS.MATRES = MR.RN
                    and exists (select null
                           from FCPRODCMPSP CSP
                          where CSP.HRN = LST.PRODCMPSP
                            and CSP.MTR_RES = SHS.MATRES
                            and CSP.SIGN_RES > 0)) loop
      rDSH.Sheet      := rcmp.prn;
      rDSH.Cmpl_Rn    := rcmp.rn;
      rDSH.Cmpl_Plan  := rcmp.matres;
      rDSH.Quant_Plan := rcmp.quant_plan;
      if rcmp.td_quant > rcmp.quant_dlvr then
        rDSH.Quant_Dlvr := rcmp.td_quant;
      else
        rDSH.Quant_Dlvr := rcmp.quant_dlvr;
      end if;
      if rDSH.Quant_Dlvr > rcmp.quant_cmpl then
        rDSH.Quant_Cmpl := rDSH.Quant_Dlvr;
      else
        rDSH.Quant_Cmpl := rcmp.quant_cmpl;
      end if;
      ins_dsh(rROW => rDSH);
    end loop;
  end cmpl_create;
  -- свод
  procedure cmpl_svod
  (
    nPRN in number,
    nFA  in number
  ) is
  begin
    rSVD.Faceacc    := nFA;
    rSVD.Quant_Rest := 0;
    rSVD.Quant_Rsrv := 0;
    for rsv in (select DSH.CMPL_PLAN,
                       nvl(sum(DSH.QUANT_PLAN - DSH.QUANT_CMPL), 0) as DEFF
                  from UDO_PRODPLAN_DEFF_TMP_DSH DSH,
                       UDO_PRODPLAN_DEFF_TMP_DSE DSE
                 where DSE.IDENT = nIDENT
                   and DSE.PRN = nPRN
                   and DSH.IDENT = nIDENT
                   and DSH.PRN = DSE.RN
                   and (DSH.QUANT_PLAN - DSH.QUANT_CMPL) > 0
                 group by DSH.CMPL_PLAN) loop
      rSVD.Cmpl_Plan  := rsv.cmpl_plan;
      rSVD.Quant_Deff := rsv.deff;
      ins_svd(rROW => rSVD);
    end loop;
  end cmpl_svod;
  --
  procedure deff_set_prm is
    type tFA is table of varchar2(80);
    rFA    tFA := tFA();
    nQUANT number(17, 3);
    sTMP   varchar2(2000);
    bNEXT  boolean;
  begin
    for rdf in (select SVD.CMPL_PLAN,
                       SVD.QUANT_DEFF,
                       SVD.FACEACC,
                       SVD.RN,
                       MR.NOMENCLATURE,
                       MR.NOMEN_MODIF
                  from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD,
                       FCMATRESOURCE                  MR
                 where SVD.IDENT = nIDENT
                   and SVD.CMPL_PLAN = MR.RN) loop
      -- посмотрим ТЗ
      for rspl in (select nvl(sum(GS.RESTFACT), 0) as RESTFACT,
                          nvl(sum(GS.RESERV), 0) as RESERV
                     from GOODSPARTIES GP,
                          GOODSSUPPLY  GS
                    where GP.NOMMODIF = rdf.nomen_modif
                      and GS.PRN = GP.RN
                      and GS.RESTFACT > 0
                      and exists
                    (select null
                             from GOODSSUPPLYCLC GSC
                            where GSC.PRN = GS.RN
                              and GSC.FACEACC in
                                  (select PRS.FACEACC
                                     from PROJECTSTAGE PRS
                                    where PRS.PRN = (select PS.PRN from PROJECTSTAGE PS where PS.FACEACC = rdf.faceacc))
                              and GSC.QUANT_FACT > 0)) loop
        update UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD
           set SVD.QUANT_REST = rspl.restfact,
               SVD.QUANT_RSRV = rspl.reserv
         where SVD.RN = rdf.rn;
      end loop;
      -- свободный остаток
      for rsfi in (select nvl(sum(GS.RESTFACT), 0) as RESTFACT,
                          nvl(sum(GS.RESERV), 0) as RESERV
                     from GOODSPARTIES GP,
                          GOODSSUPPLY  GS
                    where GP.NOMMODIF = rdf.nomen_modif
                      and GS.PRN = GP.RN
                      and GS.RESTFACT > 0
                      and (GS.RESTFACT - GS.RESERV) > 0) loop
        update UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD
           set SVD.QUANT_FILL = rsfi.restfact - rsfi.reserv
         where SVD.RN = rdf.rn;
      end loop;
      -- общий остаток
      nQUANT := 0;
      sTMP   := '';
      rFA    := tFA();
      for rsfu in (select GS.RESTFACT,
                          GS.RN
                     from GOODSPARTIES GP,
                          GOODSSUPPLY  GS
                    where GP.NOMMODIF = rdf.nomen_modif
                      and GS.PRN = GP.RN
                      and GS.RESTFACT > 0) loop
        nQUANT := nQUANT + rsfu.restfact;
        --
        for rfc in (select FA.NUMB
                      from GOODSSUPPLYCLC GSC,
                           FACEACC        FA
                     where GSC.PRN = rsfu.rn
                       and GSC.FACEACC = FA.RN
                       and GSC.QUANT_FACT > 0) loop
          if rFA.Count > 0 then
            bNEXT := true;
            for Idx in rFA.First .. rFA.Last loop
              if rFA(Idx) = rfc.numb then
                bNEXT := false;
              end if;
            end loop;
          else
            bNEXT := true;
          end if;
          if bNEXT then
            rFA.Extend;
            rFA(rFA.Last) := rfc.numb;
          end if;
        end loop;
      end loop;
      sTMP := '';
      if rFA.Count > 0 then
        for Idx in rFA.First .. rFA.Last loop
          sTMP := substr(nvl(sTMP, '') || rFA(Idx) || '; ', 1, 2000);
        end loop;
        sTMP := rtrim(sTMP, '; ');
      end if;
      update UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD
         set SVD.QUANT_FULL = nQUANT,
             SVD.FA_FULL    = sTMP
       where SVD.RN = rdf.rn;
    end loop;
  end deff_set_prm;
  --
  procedure dirr_set_prm is
    type tFA is table of varchar2(80);
    rFA    tFA := tFA();
    nQUANT number(17, 3);
    sTMP   varchar2(2000);
    bNEXT  boolean;
  begin
    for rdf in (select DR.CMPL_PLAN,
                       SVD.FACEACC,
                       DR.RN,
                       MR.NOMENCLATURE,
                       MR.NOMEN_MODIF
                  from UDO_PRODPLAN_DEFF_TMP_DIR DR,
                       UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD,
                       FCMATRESOURCE             MR
                 where DR.IDENT = nIDENT
                   and DR.PRN = SVD.RN
                   and DR.CMPL_PLAN = MR.RN) loop
      -- посмотрим ТЗ
      for rspl in (select nvl(sum(GS.RESTFACT), 0) as RESTFACT,
                          nvl(sum(GS.RESERV), 0) as RESERV
                     from GOODSPARTIES GP,
                          GOODSSUPPLY  GS
                    where GP.NOMMODIF = rdf.nomen_modif
                      and GS.PRN = GP.RN
                      and GS.RESTFACT > 0
                      and exists
                    (select null
                             from GOODSSUPPLYCLC GSC
                            where GSC.PRN = GS.RN
                              and GSC.FACEACC in
                                  (select PRS.FACEACC
                                     from PROJECTSTAGE PRS
                                    where PRS.PRN = (select PS.PRN from PROJECTSTAGE PS where PS.FACEACC = rdf.faceacc))
                              and GSC.QUANT_FACT > 0)) loop
        update UDO_PRODPLAN_DEFF_TMP_DIR DR
           set DR.QUANT_REST = rspl.restfact,
               DR.QUANT_RSRV = rspl.reserv
         where DR.RN = rdf.rn;
      end loop;
      -- свободный остаток
      for rsfi in (select nvl(sum(GS.RESTFACT), 0) as RESTFACT,
                          nvl(sum(GS.RESERV), 0) as RESERV
                     from GOODSPARTIES GP,
                          GOODSSUPPLY  GS
                    where GP.NOMMODIF = rdf.nomen_modif
                      and GS.PRN = GP.RN
                      and GS.RESTFACT > 0
                      and (GS.RESTFACT - GS.RESERV) > 0) loop
        update UDO_PRODPLAN_DEFF_TMP_DIR DR
           set DR.QUANT_FILL = rsfi.restfact - rsfi.reserv
         where DR.RN = rdf.rn;
      end loop;
      -- общий остаток
      nQUANT := 0;
      sTMP   := '';
      rFA    := tFA();
      for rsfu in (select GS.RESTFACT,
                          GS.RN
                     from GOODSPARTIES GP,
                          GOODSSUPPLY  GS
                    where GP.NOMMODIF = rdf.nomen_modif
                      and GS.PRN = GP.RN
                      and GS.RESTFACT > 0) loop
        nQUANT := nQUANT + rsfu.restfact;
        --
        for rfc in (select FA.NUMB
                      from GOODSSUPPLYCLC GSC,
                           FACEACC        FA
                     where GSC.PRN = rsfu.rn
                       and GSC.FACEACC = FA.RN
                       and GSC.QUANT_FACT > 0) loop
          if rFA.Count > 0 then
            bNEXT := true;
            for Idx in rFA.First .. rFA.Last loop
              if rFA(Idx) = rfc.numb then
                bNEXT := false;
              end if;
            end loop;
          else
            bNEXT := true;
          end if;
          if bNEXT then
            rFA.Extend;
            rFA(rFA.Last) := rfc.numb;
          end if;
        end loop;
      end loop;
      sTMP := '';
      if rFA.Count > 0 then
        for Idx in rFA.First .. rFA.Last loop
          sTMP := substr(nvl(sTMP, '') || rFA(Idx) || '; ', 1, 2000);
        end loop;
        sTMP := rtrim(sTMP, '; ');
      end if;
      update UDO_PRODPLAN_DEFF_TMP_DIR DR
         set DR.QUANT_FULL = nQUANT,
             DR.FA_FULL    = sTMP
       where DR.RN = rdf.rn;
    end loop;
  end dirr_set_prm;
  -- укажем замены по своду
  procedure dirr_set_svod is
  begin
    for rsv in (select SVD.RN,
                       (select nvl(sum(DR.QUANT_REST), 0) from UDO_PRODPLAN_DEFF_TMP_DIR DR where DR.PRN = SVD.RN) as CHNG_REST,
                       (select nvl(sum(DR.QUANT_RSRV), 0) from UDO_PRODPLAN_DEFF_TMP_DIR DR where DR.PRN = SVD.RN) as CHNG_RSRV,
                       (select nvl(sum(DR.QUANT_FILL), 0) from UDO_PRODPLAN_DEFF_TMP_DIR DR where DR.PRN = SVD.RN) as CHNG_FILL,
                       (select nvl(sum(DR.QUANT_FULL), 0) from UDO_PRODPLAN_DEFF_TMP_DIR DR where DR.PRN = SVD.RN) as CHNG_FULL
                  from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD
                 where SVD.IDENT = nIDENT) loop
      update UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SV
         set SV.CNHG_RSRV = rsv.chng_rsrv,
             SV.CNHG_REST = rsv.chng_rest,
             SV.CNHG_FILL = rsv.chng_fill,
             SV.CNHG_FULL = rsv.chng_full
       where SV.RN = rsv.rn;
    end loop;
  end dirr_set_svod;
  
  -- план закупок
  procedure deff_dirr is
    type tORD is table of number(17);
    rORD  tORD := tORD();
    bNEXT boolean;
    rDIR  UDO_PRODPLAN_DEFF_TMP_DIR%rowtype;
  begin
    rDIR.Ident  := nIDENT;
    rDIR.Authid := utilizer;
    rDIR.Quant_Rest := 0;
    rDIR.Quant_Rsrv := 0;
    rDIR.Quant_Fill := 0;
    rDIR.Quant_Full := 0;
    -- заказы подразделений
    for rrsv in (select PSP.RN,
                        PSP.PRODPLANSP,
                        PSP.PRN_NODE
                   from UDO_PRODPLAN_DEFF_TMP_PSP PSP
                  where PSP.IDENT = nIDENT
                    and exists (select null
                           from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD
                          where SVD.IDENT = nIDENT
                            and SVD.PRN = PSP.RN
                            and SVD.QUANT_DEFF > SVD.QUANT_REST)) loop
      -- заказ на производство
      for rprd in (select DO.RN
                     from FCPRODPLANSP  PPS,
                          PRODUCTORDS   PS,
                          DOCLINKS      LP,
                          DOCLINKS      LE,
                          FCPREXPACT    PE,
                          DOCLINKS      LO,
                          DEPARTMENTORD DO
                    where PPS.RN = rrsv.prn_node
                      and LP.OUT_DOCUMENT = PPS.RN
                      and LP.OUT_UNITCODE = 'CostProductPlansSpecs'
                      and LP.IN_DOCUMENT = PS.RN
                      and LP.IN_UNITCODE = 'ProductionOrdersSpecs'
                      and LE.IN_UNITCODE = 'ProductionOrders'
                      and LE.IN_DOCUMENT = PS.PRN
                      and LE.OUT_UNITCODE = 'CostProductExpenseActs'
                      and LE.OUT_DOCUMENT = PE.RN
                      and LO.IN_UNITCODE = 'CostProductExpenseActs'
                      and LO.IN_DOCUMENT = PE.RN
                      and LO.OUT_UNITCODE = 'DepartmentsOrders'
                      and LO.OUT_DOCUMENT = DO.RN) loop
        bNEXT := true;
        if rORD.Count > 0 then
          for Idx in rORD.First .. rORD.Last loop
            if rORD(Idx) = rprd.rn then
              bNEXT := false;
            end if;
          end loop;
        end if;
        if bNEXT then
          rORD.Extend;
          rORD(rORD.Last) := rprd.rn;
        end if;
      end loop;
      
    
      -- замены, план закупок
      if rORD.Count > 0 then
        -- замены
        for rdf in (select SVD.RN,
                           SVD.CMPL_PLAN,
                           MR.NOMEN_MODIF
                      from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD,
                           FCMATRESOURCE                  MR
                     where SVD.IDENT = nIDENT
                       and SVD.CMPL_PLAN = MR.RN
                       and SVD.PRN = rrsv.rn
                       and SVD.QUANT_DEFF > SVD.QUANT_REST) loop
          rDIR.Prn := rdf.rn;
          rDIR.Cmpl_Plan := rdf.cmpl_plan;
          --
          for Idx in rORD.First .. rORD.Last loop
            for rdr in(select DDS.MODIF_CHNG,
                              (select MR.RN from FCMATRESOURCE MR where MR.NOMEN_MODIF = DDS.MODIF_CHNG) as MATRES
                         from DEPARTMENTORDS   DS, 
                              UDO_DEPORDDIR_SP DDS
                        where DS.PRN = rORD(Idx)
                          and DS.NOM_MODIF = rdf.nomen_modif
                          and DDS.DEPORDSP = DS.RN
                          and not exists(select null from UDO_DEPORDDIR_CHNG DDC where DDC.PRN = DDS.RN)
                        union
                       select DDC.MODIF_CHNG,
                              (select MR.RN from FCMATRESOURCE MR where MR.NOMEN_MODIF = DDC.MODIF_CHNG) as MATRES
                         from DEPARTMENTORDS     DS, 
                              UDO_DEPORDDIR_SP   DDS,
                              UDO_DEPORDDIR_CHNG DDC
                        where DS.PRN = rORD(Idx)
                          and DS.NOM_MODIF = rdf.nomen_modif
                          and DDS.DEPORDSP = DS.RN
                          and DDC.PRN = DDS.RN
                          ) loop
              rDIR.Cmpl_Dir   := rdr.matres;
              rDIR.Modif_Chng := rdr.modif_chng;
              ins_dir(rROW => rDIR);
            end loop;
          end loop;
        end loop;
      end if;
      
    end loop;
  end deff_dirr;
        
  -- план закупок
  procedure deff_buy is
    type tORD is table of number(17);
    rORD  tORD := tORD();
    bNEXT boolean;
    rBUY  UDO_PRODPLAN_DEFF_TMP_BUY%rowtype;
  begin
    rBUY.Ident  := nIDENT;
    rBUY.Authid := utilizer;
    -- заказы подразделений
    for rrsv in (select PSP.RN,
                        PSP.PRODPLANSP,
                        PSP.PRN_NODE
                   from UDO_PRODPLAN_DEFF_TMP_PSP PSP
                  where PSP.IDENT = nIDENT
                    and exists (select null
                           from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD
                          where SVD.IDENT = nIDENT
                            and SVD.PRN = PSP.RN
                            and SVD.QUANT_DEFF > SVD.QUANT_REST)) loop
      -- заказ на производство
      for rprd in (select DO.RN
                     from FCPRODPLANSP  PPS,
                          PRODUCTORDS   PS,
                          DOCLINKS      LP,
                          DOCLINKS      LE,
                          FCPREXPACT    PE,
                          DOCLINKS      LO,
                          DEPARTMENTORD DO
                    where PPS.RN = rrsv.prn_node
                      and LP.OUT_DOCUMENT = PPS.RN
                      and LP.OUT_UNITCODE = 'CostProductPlansSpecs'
                      and LP.IN_DOCUMENT = PS.RN
                      and LP.IN_UNITCODE = 'ProductionOrdersSpecs'
                      and LE.IN_UNITCODE = 'ProductionOrders'
                      and LE.IN_DOCUMENT = PS.PRN
                      and LE.OUT_UNITCODE = 'CostProductExpenseActs'
                      and LE.OUT_DOCUMENT = PE.RN
                      and LO.IN_UNITCODE = 'CostProductExpenseActs'
                      and LO.IN_DOCUMENT = PE.RN
                      and LO.OUT_UNITCODE = 'DepartmentsOrders'
                      and LO.OUT_DOCUMENT = DO.RN) loop
        bNEXT := true;
        if rORD.Count > 0 then
          for Idx in rORD.First .. rORD.Last loop
            if rORD(Idx) = rprd.rn then
              bNEXT := false;
            end if;
          end loop;
        end if;
        if bNEXT then
          rORD.Extend;
          rORD(rORD.Last) := rprd.rn;
        end if;
      end loop;
      
    
      -- замены, план закупок
      if rORD.Count > 0 then
        -- план закупок
        for rdf in (select SVD.RN,
                           SVD.CMPL_PLAN,
                           MR.NOMEN_MODIF
                      from UDO_PRODPLAN_DEFF_TMP_DSH_SVOD SVD,
                           FCMATRESOURCE                  MR
                     where SVD.IDENT = nIDENT
                       and SVD.CMPL_PLAN = MR.RN
                       and SVD.PRN = rrsv.rn
                       and SVD.QUANT_DEFF > SVD.QUANT_REST) loop
          rBUY.Prn       := rdf.rn;
          rBUY.Cmpl_Plan := rdf.cmpl_plan;
          --
          for Idx in rORD.First .. rORD.Last loop
            for rods in (select DS.MAIN_QUANT,
                                BP.QUANT_PLAN,
                                BP.RN,
                                udo_pkg_umts_04_perf.f_buyplanespref_calc_pl_date(ncompany => DS.COMPANY, nrn => BP.RN) as PL_DATE,
                                (select nvl(sum(BD.DOC_QUANT_PLAN), 0)
                                   from UDO_UZD_03_BUYPLANESP_CNTR_DOC BD 
                                  where BD.RN_REF = BP.RN and BD.DOC_UNITCODE = 'DeliveryOrdersSpec') as QNT_DLVR
                           from DEPARTMENTORDS DS,
                                BUYPLANESPREF  BP
                          where DS.PRN = rORD(Idx)
                            and DS.NOM_MODIF = rdf.nomen_modif
                            and BP.DEPTORDSP = DS.RN
                            and BP.QUANT_PLAN > 0) loop
              rBUY.Bp_Pref_Rn := rods.rn;
              rBUY.Quant_Buy  := rods.quant_plan;
              rBUY.Plan_Date  := rods.pl_date;
              rBUY.Quant_Dlv  := rods.qnt_dlvr;
              ins_buy(rROW => rBUY);
            end loop;
          end loop;
        end loop;
      end if;
    
    end loop;
  end deff_buy;
  
begin
  -- инициализация
  clear_tmp;
  rPSP.Ident  := nIDENT;
  rPSP.Authid := utilizer;
  rART.Ident  := nIDENT;
  rART.Authid := utilizer;
  rDSE.Ident  := nIDENT;
  rDSE.Authid := utilizer;
  rDSH.Ident  := nIDENT;
  rDSH.Authid := utilizer;
  rSVD.Ident  := nIDENT;
  rSVD.Authid := utilizer;
  --
  nTMP := to_number(null);
  for rat in (select PSP.RN,
                     PSP.PRN_NODE,
                     LST.RN as LST_RN,
                     RA.RN as ART_RN,
                     (select count(*)
                        from DOCLINKS LD
                       where LD.IN_DOCUMENT = LST.RN
                         and LD.IN_UNITCODE = 'CostRouteLists'
                         and LD.OUT_UNITCODE = 'CostDeliverySheets') SH_CNT
                from FCPRODPLANSP     PSP,
                     FCROUTLST        LST,
                     DOCLINKS         L,
                     FCROUTLSTSERNUMB LSR,
                     RLARTICLES       RA
               where PSP.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                 and PSP.COMPANY = nCOMPANY
                 and L.IN_DOCUMENT = PSP.RN
                 and L.OUT_DOCUMENT = LST.RN
                 and LSR.PRN = LST.RN
                 and LSR.ARTICLE = RA.RN
                 and (not exists (select null
                        from DOCLINKS           LI,
                             INCOMEFROMDEPSSPEC IFS
                       where LI.IN_DOCUMENT = LST.RN
                         and LI.OUT_DOCUMENT = IFS.PRN
                         and IFS.ARTICLE = LSR.ARTICLE) or LST.STATE = 2)
               order by PSP.RN) loop
    if nTMP is null or
       nTMP != rat.rn then
      rPSP.Prodplansp := rat.rn;
      rPSP.Prn_Node   := rat.prn_node;
      ins_psp(rROW => rPSP);
      rDSE.Prn := rPSP.Rn;
      dse_list(nPSP_RN => rat.prn_node);
      nTMP := rat.rn;
    end if;
    -- головное изделие
    rART.Prn        := rPSP.Rn;
    rART.Prodplansp := rat.rn;
    rART.Prn_Node   := rat.prn_node;
    rART.Lst        := rat.lst_rn;
    rART.Article    := rat.art_rn;
    rART.Cnt_Sh     := rat.sh_cnt;
    ins_art(rROW => rART);
  end loop;
  -- комплектование
  for rls in (select DSE.RN,
                     DSE.LST
                from UDO_PRODPLAN_DEFF_TMP_DSE DSE
               where DSE.IDENT = nIDENT
                 and DSE.SH_CNT > 0) loop
    rDSH.Prn := rls.rn;
    cmpl_create(nLST => rls.lst);
  end loop;
  -- сводный дефицит
  for rasv in (select PSP.RN,
                      PS.PROD_ORDER
                 from UDO_PRODPLAN_DEFF_TMP_PSP PSP,
                      FCPRODPLANSP              PS
                where PSP.IDENT = nIDENT
                  and PSP.PRODPLANSP = PS.RN) loop
    rSVD.Prn := rasv.rn;
    cmpl_svod(nPRN => rasv.rn, nFA => rasv.prod_order);
  end loop;
  --
  deff_set_prm;
  -- замены
  deff_dirr;
  dirr_set_prm;
  dirr_set_svod;
  -- ПЗ
  deff_buy;
end;
/

