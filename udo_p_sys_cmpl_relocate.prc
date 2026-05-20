create or replace procedure UDO_P_SYS_CMPL_RELOCATE(nCOMPANY in number) as
  /*
    28/04/2023 Марков МВ.
    Перенос всех записей между двумя КВ.
    Перенос - комплектования, связей, расходников, резервов и т.д.
    
    ВЫПОЛНЯТЬ!!!!
    В очень исключительных случаях!!!!!
    Перенос только комплектования и накладных со всеми связями.
    
    nDELIV_SRC - КВ откуда будем переносить все данные
    nDELIV_TRG - КВ куда переносить все данные
    
    Убрать контроль:
    T_FCDELIVSHSPCMPL_BUPDATE
    
  */
  nDELIV_SRC constant number(17) := 24740773; -- откуда 32
  nDELIV_TRG constant number(17) := 50301125; -- куда 1645
  --
  nCRN      number(17);
  nJUR_PERS number(17);
  nFA_TRG   number(17);

begin
  --
  --if utilizer not in ('CITK_MARKOV') then
    p_exception(0, 'Not anouth privileges!!! Please ignor.');
  --end if;
  --
  p_fcdelivsh_exists(nRN => nDELIV_SRC, nCOMPANY => nCOMPANY, nCRN => nCRN, nJUR_PERS => nJUR_PERS);
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
  for rch in ( select SP.MATRES from FCDELIVSHSP SP where SP.PRN = nDELIV_SRC
    and exists(select null from FCDELIVSHSPCMPL CMPL where CMPL.PRN = SP.RN)) loop
    begin
      select SPP.RN
        into nCRN
        from FCDELIVSHSP SPP
       where SPP.PRN = nDELIV_TRG
         and SPP.MATRES = rch.matres;
    exception
      when no_data_found then
        p_exception(0, 'Для КВ (куда) отсутствет строка для МР = %s', rch.matres);
    end;
  end loop;
  -- перенос связей по заголовку - по выходу
  for rli in (select * from DOCLINKS L where L.IN_DOCUMENT = nDELIV_SRC) loop
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
  end loop;
  -- перенос связей по заголовку - по входу только резервы
  for rlo in (select *
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
  end loop;
  -- теперь по строкам
  for rsp in (select SP.RN,
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
    PKG_FLAG.SET_FLAG;
    -- перенос строк комплектования
    update FCDELIVSHSPCMPL CMPL set CMPL.PRN = rsp.sp_trg where CMPL.PRN = rsp.rn;
    -- перенос передачи в цех
    update FCDELIVSHSPTRN TRN set TRN.PRN = rsp.sp_trg where TRN.PRN = rsp.rn;
    -- перенос замен
    update UDO_FCDELIVSHSUB SUB set SUB.PRN = rsp.sp_trg where SUB.PRN = rsp.rn;
    PKG_FLAG.RESET_FLAG;
    -- обновим комплектование
    update FCDELIVSHSP SP
       set SP.QUANT_CMPL = 0,
           SP.QUANT_DLVR = 0
     where SP.RN = rsp.rn;
    update FCDELIVSHSP SPP
       set SPP.QUANT_CMPL = rsp.quant_cmpl,
           SPP.QUANT_DLVR = rsp.quant_dlvr
     where SPP.RN = rsp.sp_trg;
  
  end loop;

  -- подменим ШПЗ
  for rtn in (select TD.RN,
                     L.OUT_UNITCODE
                from TRANSINVDEPT TD,
                     DOCLINKS     L
               where L.IN_DOCUMENT = nDELIV_TRG
                 and L.IN_UNITCODE = 'CostDeliverySheets'
                 and L.OUT_DOCUMENT = TD.RN
                 and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts') loop
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

