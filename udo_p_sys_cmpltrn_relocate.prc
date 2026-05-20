create or replace procedure UDO_P_SYS_CMPLTRN_RELOCATE
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    29/06/2023 Марков МВ.
    Перенос расходников между двумя КВ.
    Перенос - комплектования, связей, расходников, резервов и т.д.
  
    ВЫПОЛНЯТЬ!!!!
    В очень исключительных случаях!!!!!
    Перенос накладных со всеми связями.
    По отмеченным записям расходников
  
    nDELIV_SRC - КВ откуда будем переносить все данные
    nDELIV_TRG - КВ куда переносить все данные
  
  */
  --
  type tSP_TRG is table of number(17);
  rSP_TRG tSP_TRG := tSP_TRG();
  rSP_SRC tSP_TRG := tSP_TRG();
  --
  nDELIV_SRC number(17); -- откуда
  nDELIV_TRG constant number(17) := 42257469; -- куда 923
  --
  nCRN      number(17);
  nJUR_PERS number(17);
  nFA_TRG   number(17);
  nSP_TRG   number(17);
  nCMPL_TRG number(17);
  nTMP      number(17);
  nTMP2     number(17);

begin
  --
  if utilizer not in ('CITK_MARKOV') then
    p_exception(0, 'Not anouth privileges!!! Please ignor.');
  end if;
  -- все накладные должны быть связаны с ОДНОЙ КВ!!!!
  for r_trn in (select L.IN_DOCUMENT
                  from DOCLINKS   L,
                       SELECTLIST SL
                 where SL.IDENT = nIDENT
                   and L.OUT_DOCUMENT = SL.DOCUMENT
                   and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                   and L.IN_UNITCODE = 'CostDeliverySheets') loop
    if nDELIV_SRC is null then
      nDELIV_SRC := r_trn.in_document;
    else
      if nDELIV_SRC != r_trn.in_document then
        p_exception(0,
                    'Отмеченные Расходные накладные должны принадлежать только ОДНОЙ КВ!!');
      end if;
    end if;
  end loop;

  p_fcdelivsh_exists(nRN => nDELIV_TRG, nCOMPANY => nCOMPANY, nCRN => nCRN, nJUR_PERS => nJUR_PERS);
  -- ШПЗ - куда
  begin
    select FA.RN
      into nFA_TRG
      from FACEACC   FA,
           FCDELIVSH SH
     where SH.RN = nDELIV_TRG
       and SH.PROD_ORDER = FA.RN;
  exception
    when no_data_found then
      p_exception(0, 'ШПЗ для КВ куда - не определен.');
  end;
  -- проверка идентичности спецификации КВ
  for rch in (select SP.MATRES,
                     MR.NAME
                from FCDELIVSHSP   SP,
                     FCMATRESOURCE MR
               where SP.PRN = nDELIV_SRC
                 and SP.MATRES = MR.RN) loop
    begin
      select SPP.RN
        into nCRN
        from FCDELIVSHSP SPP
       where SPP.PRN = nDELIV_TRG
         and SPP.MATRES = rch.matres;
    exception
      when no_data_found then
        p_exception(0, 'Для КВ (куда) отсутствет строка для МР = %s', rch.name);
    end;
  end loop;

  rSP_TRG := tSP_TRG();
  rSP_SRC := tSP_TRG();
  -- перенос связей по заголовку - по входу (только заголовки)
  for rli in (select L.*
                from DOCLINKS   L,
                     SELECTLIST SL
               where L.OUT_DOCUMENT = SL.DOCUMENT
                 and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                 and L.IN_UNITCODE = 'CostDeliverySheets'
                 and SL.IDENT = nIDENT) loop
    pkg_doclinks.REMOVE(sIN_UNITCODE  => rli.in_unitcode,
                        nIN_DOCUMENT  => rli.in_document,
                        sOUT_UNITCODE => rli.out_unitcode,
                        nOUT_DOCUMENT => rli.out_document);
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => nCOMPANY,
                      sIN_UNITCODE  => rli.in_unitcode,
                      nIN_DOCUMENT  => nDELIV_TRG,
                      sOUT_UNITCODE => rli.out_unitcode,
                      nOUT_DOCUMENT => rli.out_document);
  
    -- перенос связей спецификации и передачи в цех
    for rlsp in (select TDS.RN,
                        GP.SERNUMB,
                        trim(TD.PREF) || '-' || trim(TD.NUMB) DOC_NUMB
                   from TRANSINVDEPTSPECS TDS,
                        TRANSINVDEPT      TD,
                        GOODSPARTIES      GP
                  where TDS.PRN = rli.out_document
                    and TDS.PRN = TD.RN
                    and TDS.GOODSPARTY = GP.RN) loop
    
      -- связи
      for spl in ( select L.* from DOCLINKS L 
        where L.OUT_DOCUMENT = rlsp.rn) loop
      
        if spl.in_unitcode = 'CostDeliverySheetsSpec' then
          -- связь со спецификацией
          for rspl in (select SP.MATRES,
                              MR.NAME
                         from FCDELIVSHSP   SP,
                              FCMATRESOURCE MR
                        where SP.RN = spl.in_document
                          and SP.MATRES = MR.RN) loop
            begin
              select SPP.RN
                into nSP_TRG
                from FCDELIVSHSP SPP
               where SPP.PRN = nDELIV_TRG
                 and SPP.MATRES = rspl.matres;
            exception
              when no_data_found then
                p_exception(0, 'Для КВ (куда) отсутствет строка для МР = %s', rspl.name);
            end;
          end loop;
          -- запомним для обновения
          rSP_TRG.Extend;
          rSP_TRG(rSP_TRG.Last) := nSP_TRG;
          rSP_SRC.Extend;
          rSP_SRC(rSP_SRC.Last) := spl.in_document;
          -- связь строки накладной
          pkg_doclinks.REMOVE(sIN_UNITCODE  => spl.in_unitcode,
                              nIN_DOCUMENT  => spl.in_document,
                              sOUT_UNITCODE => spl.out_unitcode,
                              nOUT_DOCUMENT => spl.out_document);
          pkg_doclinks.LINK(nFLAG_SMART   => 0,
                            nCOMPANY      => nCOMPANY,
                            sIN_UNITCODE  => spl.in_unitcode,
                            nIN_DOCUMENT  => nSP_TRG,
                            sOUT_UNITCODE => spl.out_unitcode,
                            nOUT_DOCUMENT => spl.out_document);
          -- связь заголовка
          pkg_doclinks.LINK(nFLAG_SMART   => 1,
                            nCOMPANY      => nCOMPANY,
                            sIN_UNITCODE  => spl.in_unitcode,
                            nIN_DOCUMENT  => nSP_TRG,
                            sOUT_UNITCODE => rli.out_unitcode,
                            nOUT_DOCUMENT => rli.out_document);
        
        elsif spl.in_unitcode = 'CostDeliverySheets' then
          -- связь с заголовком
          pkg_doclinks.REMOVE(sIN_UNITCODE  => spl.in_unitcode,
                              nIN_DOCUMENT  => spl.in_document,
                              sOUT_UNITCODE => spl.out_unitcode,
                              nOUT_DOCUMENT => spl.out_document);
          pkg_doclinks.LINK(nFLAG_SMART   => 0,
                            nCOMPANY      => nCOMPANY,
                            sIN_UNITCODE  => spl.in_unitcode,
                            nIN_DOCUMENT  => nDELIV_TRG,
                            sOUT_UNITCODE => spl.out_unitcode,
                            nOUT_DOCUMENT => spl.out_document);
        
        elsif spl.in_unitcode = 'ReservationJournal' then
          -- перенос связи резерва к заголовку КВ
          for rsrl in (select L.*
                         from DOCLINKS L
                        where L.IN_DOCUMENT = spl.in_document
                          and L.IN_UNITCODE = spl.in_unitcode
                          and L.OUT_UNITCODE = 'CostDeliverySheets') loop
            -- связь с заголовком
            pkg_doclinks.REMOVE(sIN_UNITCODE  => rsrl.in_unitcode,
                                nIN_DOCUMENT  => rsrl.in_document,
                                sOUT_UNITCODE => rsrl.out_unitcode,
                                nOUT_DOCUMENT => rsrl.out_document);
            pkg_doclinks.LINK(nFLAG_SMART   => 0,
                              nCOMPANY      => nCOMPANY,
                              sIN_UNITCODE  => rsrl.in_unitcode,
                              nIN_DOCUMENT  => rsrl.in_document,
                              sOUT_UNITCODE => spl.out_unitcode,
                              nOUT_DOCUMENT => nDELIV_TRG);
          end loop;
          -- резерв (плюс комплектование)
          begin
            select PRF.CMPL into nCMPL_TRG from UDO_DEPORDS_PRF PRF where PRF.RSRV = spl.in_document;
          exception
            when no_data_found then
              nCMPL_TRG := null;
          end;
          --
          if nCMPL_TRG is not null then
            -- переносим комплектование
            PKG_FLAG.SET_FLAG;
            update FCDELIVSHSPCMPL CMPL set CMPL.PRN = nSP_TRG where CMPL.RN = nCMPL_TRG;
            PKG_FLAG.RESET_FLAG;
          else
            begin
            select CMPL.PARTY, count(*)
              into nTMP2, nTMP
              from FCDELIVSHSPCMPL CMPL
             where CMPL.PRN = (select L.IN_DOCUMENT from DOCLINKS L 
             where L.OUT_DOCUMENT = rlsp.rn 
               and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
               and L.IN_UNITCODE = 'CostDeliverySheetsSpec')
             group by CMPL.PARTY;
            exception
              when no_data_found then
                nTMP := 0;
              when too_many_rows then
                nTMP := 2;
            end;
            -- напрямую комплектование не нашли
            if spl.in_document not in(62788729, 62788698, 66016835, 67066772, 67416128 -- 923
              ,74687031, 74687033, 74687108, 74687281, 65058042, 65060096, 65054141, 65056695, 65612152 -- 926
              ) then
              if nTMP != 1 then
                p_exception(0, 'Не нашли строку комплектования.'||chr(10)||
                               'Накладная: %s'||chr(10)||
                               'Серия: %s'||chr(10)||
                               'RSRV: %s',
                               rlsp.doc_numb, rlsp.sernumb, spl.in_document);
              else
                for rr1 in(select CMPL.RN
                    from FCDELIVSHSPCMPL CMPL
                    where CMPL.PRN = (select L.IN_DOCUMENT from DOCLINKS L 
                          where L.OUT_DOCUMENT = rlsp.rn 
                          and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                          and L.IN_UNITCODE = 'CostDeliverySheetsSpec')) loop
                  -- переносим комплектование
                  PKG_FLAG.SET_FLAG;
                  update FCDELIVSHSPCMPL CMPL set CMPL.PRN = nSP_TRG where CMPL.RN = rr1.rn;
                  PKG_FLAG.RESET_FLAG;
                end loop;
              end if;
            end if;
          end if;
        
        else
          p_exception(0,
                      'Не отработанный раздел по линкам (вход). sUNIT = %s',
                      spl.in_unitcode);
        end if;
      end loop;
    
    end loop;
  
  end loop;

  -- обновим комплектование
  -- новой КВ
  if rSP_TRG.Count > 0 then
    for Idx in rSP_TRG.First .. rSP_TRG.Last loop
      update FCDELIVSHSP SPP
         set SPP.QUANT_CMPL =
             (select nvl(sum(CMPL.QUANT), 0) from FCDELIVSHSPCMPL CMPL where CMPL.PRN = SPP.RN),
             SPP.QUANT_DLVR =
             (select nvl(sum(CMPL.QUANT), 0) from FCDELIVSHSPCMPL CMPL where CMPL.PRN = SPP.RN)
       where SPP.RN = rSP_TRG(Idx);
    end loop;
  end if;
  -- старой КВ
  if rSP_SRC.Count > 0 then
    for Idx in rSP_SRC.First .. rSP_SRC.Last loop
      update FCDELIVSHSP SPP
         set SPP.QUANT_CMPL =
             (select nvl(sum(CMPL.QUANT), 0) from FCDELIVSHSPCMPL CMPL where CMPL.PRN = SPP.RN),
             SPP.QUANT_DLVR =
             (select nvl(sum(CMPL.QUANT), 0) from FCDELIVSHSPCMPL CMPL where CMPL.PRN = SPP.RN)
       where SPP.RN = rSP_SRC(Idx);
    end loop;
  end if;

  ---------------------------------------------

  -- перенос связей по заголовку - по входу только резервы
  /*for rlo in (select *
                from DOCLINKS L
               where L.OUT_DOCUMENT = nDELIV_SRC
                 and L.IN_UNITCODE = 'ReservationJournal') loop
    pkg_doclinks.REMOVE(sIN_UNITCODE  => rlo.in_unitcode,
                        nIN_DOCUMENT  => rlo.in_document,
                        sOUT_UNITCODE => rlo.out_unitcode,
                        nOUT_DOCUMENT => rlo.out_document);
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => nCOMPANY,
                      sIN_UNITCODE  => rlo.in_unitcode,
                      nIN_DOCUMENT  => rlo.in_document,
                      sOUT_UNITCODE => rlo.out_unitcode,
                      nOUT_DOCUMENT => nDELIV_TRG);
  end loop;*/
  -- теперь по строкам
  /*for rsp in (select SP.RN,
                     SP.QUANT_CMPL,
                     SP.QUANT_DLVR,
                     (select SPP.RN
                        from FCDELIVSHSP SPP
                       where SPP.PRN = nDELIV_TRG
                         and SPP.MATRES = SP.MATRES) as SP_TRG
                from FCDELIVSHSP SP
               where SP.PRN = nDELIV_SRC) loop
    -- перенос связей спецификации
    for rsl in (select * from DOCLINKS L where L.IN_DOCUMENT = rsp.rn) loop
      pkg_doclinks.REMOVE(sIN_UNITCODE  => rsl.in_unitcode,
                          nIN_DOCUMENT  => rsl.in_document,
                          sOUT_UNITCODE => rsl.out_unitcode,
                          nOUT_DOCUMENT => rsl.out_document);
      pkg_doclinks.LINK(nFLAG_SMART   => 0,
                        nCOMPANY      => nCOMPANY,
                        sIN_UNITCODE  => rsl.in_unitcode,
                        nIN_DOCUMENT  => rsp.sp_trg,
                        sOUT_UNITCODE => rsl.out_unitcode,
                        nOUT_DOCUMENT => rsl.out_document);
    end loop;
    -- перенос строк комплектования
    update FCDELIVSHSPCMPL CMPL set CMPL.PRN = rsp.sp_trg where CMPL.PRN = rsp.rn;
    -- перенос передачи в цех
    update FCDELIVSHSPTRN TRN set TRN.PRN = rsp.sp_trg where TRN.PRN = rsp.rn;
    -- перенос замен
    update UDO_FCDELIVSHSUB SUB set SUB.PRN = rsp.sp_trg where SUB.PRN = rsp.rn;
    -- обновим комплектование
    update FCDELIVSHSP SP
       set SP.QUANT_CMPL = 0,
           SP.QUANT_DLVR = 0
     where SP.RN = rsp.rn;
    update FCDELIVSHSP SPP
       set SPP.QUANT_CMPL = rsp.quant_cmpl,
           SPP.QUANT_DLVR = rsp.quant_dlvr
     where SPP.RN = rsp.sp_trg;
  
  end loop;*/

  -- подменим ШПЗ
  for rtn in (select TD.RN,
                     L.OUT_UNITCODE
                from TRANSINVDEPT TD,
                     DOCLINKS     L
               where L.IN_DOCUMENT = nDELIV_TRG
                 and L.IN_UNITCODE = 'CostDeliverySheets'
                 and L.OUT_DOCUMENT = TD.RN
                 and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                 and TD.FACEACC != nFA_TRG) loop
    update TRANSINVDEPT T set T.FACEACC = nFA_TRG where T.RN = rtn.rn;
    -- теперь в Журнале складских операций
    for rjn in (select SOJ.RN
                  from STOREOPERJOURN SOJ,
                       DOCLINKS       L
                 where L.IN_DOCUMENT = rtn.rn
                   and L.IN_UNITCODE = rtn.out_unitcode
                   and L.OUT_DOCUMENT = SOJ.RN
                   and L.OUT_UNITCODE = 'StoreOpersJournal') loop
      update STOREOPERJOURN J set J.FACEACC = nFA_TRG where J.RN = rjn.rn;
    end loop;
  end loop;

end;
/

