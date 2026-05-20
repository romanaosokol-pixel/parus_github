create or replace procedure UDO_P_SYS_CMPL_ADD
(
  nCOMPANY in number,
  nIDENT   in number,
  nSPEC    in number
) as
  /*
    Марков МВ.
    Процедура учета выдачи ПКИ по накладным из 1С.
  */
  --nCOMPANY  number(17) := 90521;
  nCRN      number(17) := 22312636;
  nJUR_PERS number(17) := 92147;
  nACT      number(1) := 0;
  dACT_DATE date := s2d('22.09.2022');

  nPRN  number(17);
  nTMP  number(17);
  nCMPL number(17);
  --nSPEC number(17) := 42419150;

begin
  if utilizer not in ('CITK_MARKOV') then
    p_exception(0, 'У Вас нет прав на выполнение процедуры.');
  end if;
  begin
    select SP.RN
      into nPRN
      from SELECTLIST  SL,
           FCDELIVSHSP SP
     where SL.IDENT = nIDENT
       and SL.DOCUMENT = SP.RN;
  exception
    when no_data_found then
      return;
    when too_many_rows then
      p_exception(0, 'Errors.');
  end;
  --
  if nSPEC is not null then
    for rec in (select TDS.GOODSPARTY,
                       TDS.QUANT,
                       TDS.RN,
                       MR.RN as matres,
                       TD.STORE,
                       TD.SUBDIV,
                       (select dv.str_value
                          from docs_props_vals dv
                         where dv.unit_rn = tds.rn
                           and dv.docs_prop_rn = 13459633) as ser_1c
                  from TRANSINVDEPTSPECS TDS,
                       FCMATRESOURCE     MR,
                       TRANSINVDEPT      TD
                 where TDS.RN = nSPEC
                   and TDS.NOMMODIF = MR.NOMEN_MODIF
                   and TDS.PRN = TD.RN) loop
      -- комплектование
      nCMPL := gen_id;
      insert into FCDELIVSHSPCMPL
        (RN,
         COMPANY,
         CRN,
         PRN,
         JUR_PERS,
         ACT,
         ACT_DATE,
         DELIVSHSP,
         CMPL,
         MATRES,
         QUANT,
         COEFF,
         ROUTLST,
         PARTY,
         ARTICLE,
         VALID_DOCTYPE,
         VALID_DOCNUMB,
         VALID_DOCDATE,
         NOTE,
         RESERV_DATE,
         RESERV_QUANT)
      values
        (nCMPL,
         nCOMPANY,
         nCRN,
         nPRN,
         nJUR_PERS,
         nACT,
         dACT_DATE,
         null,
         null,
         rec.matres,
         rec.quant,
         1,
         null,
         rec.goodsparty,
         null,
         null,
         null,
         null,
         null,
         null,
         null);
      -- серия 1С
      if rtrim(rec.ser_1c) is not null then
      pkg_docs_props_vals.MODIFY(nPROPERTY   => 13459633,
                                 sUNITCODE   => 'CostDeliverySheetsSpecCompletion', -- код раздела
                                 nDOCUMENT   => nCMPL, -- документ
                                 sSTR_VALUE  => rec.ser_1c, -- значение (строка)
                                 nNUM_VALUE  => null, -- значение (число)
                                 dDATE_VALUE => null, -- значение (дата)
                                 nRN         => nTMP);
      end if;
      -- линк
      /*PKG_DOCLINKS.LINK(nFLAG_SMART   => 0,
                        nCOMPANY      => nCOMPANY,
                        sIN_UNITCODE  => 'CostDeliverySheets',
                        nIN_DOCUMENT  => 22354140,
                        sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                        nOUT_DOCUMENT => rec.rn);*/
      /*PKG_DOCLINKS.LINK(nFLAG_SMART   => 0,
      nCOMPANY      => nCOMPANY,
      sIN_UNITCODE  => 'CostDeliverySheetsSpec',
      nIN_DOCUMENT  => nPRN,
      sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
      nOUT_DOCUMENT => rec.rn);*/
      -- выдача в цех
      insert into FCDELIVSHSPTRN
        (RN,
         COMPANY,
         CRN,
         PRN,
         JUR_PERS,
         ACT,
         ACT_DATE,
         MATRES,
         QUANT,
         COEFF,
         TRNSDPTSP,
         ROUTLST,
         PARTY,
         ARTICLE,
         SUBDIV,
         STORE)
      values
        (gen_id,
         nCOMPANY,
         nCRN,
         nPRN,
         nJUR_PERS,
         nACT,
         dACT_DATE,
         rec.matres,
         rec.quant,
         1,
         rec.rn,
         null,
         rec.goodsparty,
         null,
         rec.subdiv,
         rec.store);
      -- обновление строки
      update FCDELIVSHSP SP
         set SP.QUANT_CMPL = SP.QUANT_CMPL + rec.quant,
             SP.QUANT_DLVR = SP.QUANT_DLVR + rec.quant
       where SP.RN = nPRN;
    end loop;
  
  /*********************************************/
  else
    -- по всем связанным строкам накладным из 1С
    for rsp in (select TS.GOODSPARTY,
                       TS.QUANT,
                       TS.RN,
                       MR.RN as matres,
                       TR.STORE,
                       TR.SUBDIV,
                       (select dv.str_value
                          from docs_props_vals dv
                         where dv.unit_rn = ts.rn
                           and dv.docs_prop_rn = 13459633) as ser_1c
                  from DOCLINKS          dl,
                       TRANSINVDEPTSPECS ts,
                       FCMATRESOURCE     MR,
                       TRANSINVDEPT      tr
                 where dl.in_document = nPRN
                   and dl.in_unitcode = 'CostDeliverySheetsSpec'
                   and dl.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                   and dl.out_document = ts.rn
                   and ts.prn = tr.rn
                   and TS.NOMMODIF = MR.NOMEN_MODIF
                   and tr.crn in (42531014, 17663998, 42356515, 51482197, 49280187, 50682490)) loop
      if rsp.ser_1c is not null then
        rsp.goodsparty := to_number(null);
      end if;
      -- комплектование
      nCMPL := gen_id;
      insert into FCDELIVSHSPCMPL
        (RN,
         COMPANY,
         CRN,
         PRN,
         JUR_PERS,
         ACT,
         ACT_DATE,
         DELIVSHSP,
         CMPL,
         MATRES,
         QUANT,
         COEFF,
         ROUTLST,
         PARTY,
         ARTICLE,
         VALID_DOCTYPE,
         VALID_DOCNUMB,
         VALID_DOCDATE,
         NOTE,
         RESERV_DATE,
         RESERV_QUANT)
      values
        (nCMPL,
         nCOMPANY,
         nCRN,
         nPRN,
         nJUR_PERS,
         nACT,
         dACT_DATE,
         null,
         null,
         rsp.matres,
         rsp.quant,
         1,
         null,
         rsp.goodsparty,
         null,
         null,
         null,
         null,
         null,
         null,
         null);
      -- серия 1С
      pkg_docs_props_vals.MODIFY(nPROPERTY   => 13459633,
                                 sUNITCODE   => 'CostDeliverySheetsSpecCompletion', -- код раздела
                                 nDOCUMENT   => nCMPL, -- документ
                                 sSTR_VALUE  => rsp.ser_1c, -- значение (строка)
                                 nNUM_VALUE  => null, -- значение (число)
                                 dDATE_VALUE => null, -- значение (дата)
                                 nRN         => nTMP);
      -- линк
      /*PKG_DOCLINKS.LINK(nFLAG_SMART   => 0,
                        nCOMPANY      => nCOMPANY,
                        sIN_UNITCODE  => 'CostDeliverySheets',
                        nIN_DOCUMENT  => 22354140,
                        sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                        nOUT_DOCUMENT => rsp.rn);*/
      /*PKG_DOCLINKS.LINK(nFLAG_SMART   => 0,
      nCOMPANY      => nCOMPANY,
      sIN_UNITCODE  => 'CostDeliverySheetsSpec',
      nIN_DOCUMENT  => nPRN,
      sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
      nOUT_DOCUMENT => rsp.rn);*/
      -- выдача в цех
      insert into FCDELIVSHSPTRN
        (RN,
         COMPANY,
         CRN,
         PRN,
         JUR_PERS,
         ACT,
         ACT_DATE,
         MATRES,
         QUANT,
         COEFF,
         TRNSDPTSP,
         ROUTLST,
         PARTY,
         ARTICLE,
         SUBDIV,
         STORE)
      values
        (gen_id,
         nCOMPANY,
         nCRN,
         nPRN,
         nJUR_PERS,
         nACT,
         dACT_DATE,
         rsp.matres,
         rsp.quant,
         1,
         rsp.rn,
         null,
         rsp.goodsparty,
         null,
         rsp.subdiv,
         rsp.store);
      -- обновление строки
      update FCDELIVSHSP SP
         set SP.QUANT_CMPL = SP.QUANT_CMPL + rsp.quant,
             SP.QUANT_DLVR = SP.QUANT_DLVR + rsp.quant
       where SP.RN = nPRN;
    end loop;
  end if;
end;
/

