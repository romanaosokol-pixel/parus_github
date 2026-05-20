create or replace procedure UDO_P_LOADEXT_ORD_POS_SET
(
  nIDENT   in number,
  nCOMPANY in number,
  sUNIT    in varchar2
) as
  /*
    16/05/2023 Марков МВ.
    Разделы:
     - Загрузки из внешних источников
     - Производственный состав
     - Комплектовочные ведомости
     
    Инициализация позиционных мест.
  */
  nLOAD number(17);
  nTMP  number(17);
  nUNIT number(17);

  -- инициализация позиционных мест в спецификации загрузки
  procedure set_sp_position(nSPEC in number) is
  begin
    UDO_PKG_LOADEXT_ORD_BASE.P_ORDSP_POS_CONTEXT(nPRN => nSPEC);
  end set_sp_position;

  -- обновление позиционных мест для производственного состава
  procedure set_prodcmp_pos(nID in number) is
    sPOS FCPRODLSTSP.NOTE%type;
  begin
    -- по всем отмеченным записям
    for rcm in (select CSP.RN         as CSP_RN,
                       LSP.RN         as LSP_RN,
                       LSP.PRN        as LSP_PRN,
                       MR.NOMEN_MODIF /*,
                                       f_doclinks_link_in_doc(sOUT_UNITCODE => 'CostProductLists',
                                                              nOUT_DOCUMENT => LSP.PRN,
                                                              sIN_UNITCODE  => 'CostProductListNotifies') as PLN_RN*/
                  from FCPRODCMPSP   CSP,
                       SELECTLIST    SL,
                       FCPRODLSTSP   LSP,
                       FCMATRESOURCE MR
                 where SL.IDENT = nID
                   and SL.DOCUMENT = CSP.RN
                   and CSP.PRODLSTSP = LSP.RN
                   and LSP.COMPLETE = MR.RN) loop
      -- только при наличии Извещения об изменении
      --if rcm.pln_rn is not null then
      for rpl in (select PLN.RN
                    from DOCLINKS  L,
                         FCPLCHNOT PLN
                   where L.OUT_UNITCODE = 'CostProductLists'
                     and L.OUT_DOCUMENT = rcm.lsp_prn
                     and L.IN_UNITCODE = 'CostProductListNotifies'
                     and L.IN_DOCUMENT = PLN.RN
                     and f_doclinks_link_in_doc(sOUT_UNITCODE => 'CostProductListNotifies',
                                                nOUT_DOCUMENT => PLN.RN,
                                                sIN_UNITCODE  => 'UdoLoadextOrd') is not null
                   order by PLN.RN desc) loop
        -- загрузка по извещению (последняя загрузка по RN)
        nLOAD := f_doclinks_link_in_doc(sOUT_UNITCODE => 'CostProductListNotifies',
                                        nOUT_DOCUMENT => rpl.rn,
                                        sIN_UNITCODE  => 'UdoLoadextOrd');
        if nLOAD is not null then
          for rld in (select LDS.RN,
                             udo_pkg_loadext_ord_base.F_ORDSP_POS_GET_CONTEXT(nPRN => LDS.RN) as position
                        from UDO_LOADEXT_ORD_SP LDS
                       where LDS.PRN = nLOAD
                         and LDS.MODIF = rcm.nomen_modif) loop
            sPOS := rld.position;
            exit;
          end loop;
          -- обновим в ПС
          update FCPRODCMPSP CSP set CSP.NOTE = sPOS where CSP.RN = rcm.csp_rn;
          -- обновим в спецификации
          update FCPRODLSTSP LSP set LSP.NOTE = sPOS where LSP.RN = rcm.lsp_rn;
        end if;
        exit; -- достаточно 1 раза
      end loop;
    end loop;
  end set_prodcmp_pos;

  -- проставление позиционных мест из загрузки
  procedure set_load_pos is
  begin
    for rec in (select sp.rn,
                       sp.prn,
                       ord.doc_date,
                       udo_pkg_loadext_ord_base.F_ORDSP_POS_GET_CONTEXT(nPRN => sp.rn) as position,
                       (select lsp.rn
                          from fcplchnot   pn,
                               doclinks    lp,
                               doclinks    ll,
                               fcprodlstsp lsp
                         where lp.in_document = sp.prn
                           and lp.in_unitcode = 'UdoLoadextOrd'
                           and lp.out_document = pn.rn
                           and lp.out_unitcode = 'CostProductListNotifies'
                           and ll.in_document = pn.rn
                           and ll.in_unitcode = 'CostProductListNotifies'
                           and ll.out_document = lsp.prn
                           and ll.out_unitcode = 'CostProductLists'
                           and lsp.complete = mr.rn
                           and lsp.quant > 0) as spec_rn,
                       (select lsp.date_from
                          from fcplchnot   pn,
                               doclinks    lp,
                               doclinks    ll,
                               fcprodlstsp lsp
                         where lp.in_document = sp.prn
                           and lp.in_unitcode = 'UdoLoadextOrd'
                           and lp.out_document = pn.rn
                           and lp.out_unitcode = 'CostProductListNotifies'
                           and ll.in_document = pn.rn
                           and ll.in_unitcode = 'CostProductListNotifies'
                           and ll.out_document = lsp.prn
                           and ll.out_unitcode = 'CostProductLists'
                           and lsp.complete = mr.rn
                           and lsp.quant > 0) as spec_date
                  from udo_loadext_ord_sp sp,
                       fcmatresource      mr,
                       udo_loadext_ord    ord
                 where ((nUNIT = 0 and sp.prn = nLOAD) or
                       (nUNIT = 1 and sp.rn in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)))
                   and mr.nomen_modif = sp.modif
                   and sp.prn = ord.rn) loop
    
      -- при наличии позиций - обновление в спецификации
      if trim(rec.position) is not null and
         rec.spec_rn is not null then
        -- перенос позиционных мест
        delete from udo_fcprodlstsp_pos lps where lps.prn = rec.spec_rn;
        --
        for rps in (select LSP.POS_PREF,
                           LSP.POS_NUMB,
                           LSP.POS_NUMB_N,
                           LSP.STRING_VALUE as POSITION
                      from UDO_LOADEXT_ORD_ATTR_SPEC LSP
                     where LSP.PRN = rec.rn
                       and LSP.ATTRIBUTE_ID = 4100) loop
          udo_pkg_fcprodlst_base.POS_INSERT(nPRN        => rec.spec_rn,
                                            sPOSITION   => rps.position,
                                            dDATE_FROM  => rec.spec_date,
                                            nANNUL      => 0,
                                            nSIGN_HS    => 1,
                                            sPOS_PREF   => rps.pos_pref,
                                            sPOS_NUMB   => rps.pos_numb,
                                            nPOS_NUMB_N => rps.pos_numb_n,
                                            nRN         => nTMP);
        end loop;
        --
        update fcprodlstsp ps set ps.note = rec.position where ps.rn = rec.spec_rn;
        -- найдем производственные составы для этой спецификации
        update FCPRODCMPSP CSP set CSP.NOTE = rec.position where CSP.PRODLSTSP = rec.spec_rn;
      end if;
    end loop;
  end set_load_pos;

  -- проставление позиционных мест для строк КВ
  procedure set_sheetsp_pos is
    nID  number(17);
    nTMP number(17);
  begin
    p_selectlist_genident(nIDENT => nID);
    for rssp in (select CSP.RN
                   from FCDELIVSHSP SSP,
                        SELECTLIST  SL,
                        DOCLINKS    L,
                        FCROUTLST   LST,
                        FCPRODCMPSP CSP
                  where SL.IDENT = nIDENT
                    and SL.DOCUMENT = SSP.RN
                    and L.OUT_DOCUMENT = SSP.PRN
                    and L.OUT_UNITCODE = 'CostDeliverySheets'
                    and L.IN_DOCUMENT = LST.RN
                    and L.IN_UNITCODE = 'CostRouteLists'
                    and LST.PRODCMPSP = CSP.HRN
                    and CSP.MTR_RES = SSP.MATRES
                    and CSP.QUANT = SSP.QUANT_SPEC) loop
      p_selectlist_insert(nIDENT => nID, nDOCUMENT => rssp.rn, sUNITCODE => 'CostDeliverySheetsSpec', nRN => nTMP);
    end loop;
    --
    --p_exception(0, 'nTMP = %s', nTMP);
    if nTMP is not null then
      set_prodcmp_pos(nID => nID);
      p_selectlist_clear(nIDENT => nID);
    end if;
  end set_sheetsp_pos;

begin
  --
  if utilizer not in ('CITK_MARKOV', 'MARANICHENKO_AP') then
    p_exception(0,
                'У Вас нет прав на выполнение процедуры. Обратитесь к Администратору!');
  end if;
  --
  if sUNIT = 'UdoLoadextOrd' then
    -- по всей загрузке
    nUNIT := 0;
    begin
      select DOCUMENT into nLOAD from SELECTLIST where IDENT = nIDENT;
    exception
      when no_data_found then
        p_exception(0, 'Не отмечено ни одной записи.');
      when too_many_rows then
        p_exception(0, 'Необходимо отметить только ОДНУ запись.');
    end;
    set_load_pos;
  elsif sUNIT = 'UdoLoadextOrdSp' then
    -- для выделенных строк спецификации загрузки
    nUNIT := 1;
    for rspp in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) loop
      set_sp_position(nSPEC => rspp.document);
    end loop;
    set_load_pos;
  elsif sUNIT = 'CostProductCompositionSpec' then
    -- для выделенных строк производственного состава
    set_prodcmp_pos(nID => nIDENT);
  elsif sUNIT = 'CostDeliverySheetsSpec' then
    -- для отмеченных строк КВ (связь со строкой ПС)
    set_sheetsp_pos;
  else
    null;
  end if;
  --
end;
/
