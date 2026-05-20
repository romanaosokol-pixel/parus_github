create or replace procedure UDO_P_SYS_PRODSP_RECALC
(
  nCOMPANY in number,
  nIDENT   in number,
  sUNIT    in varchar2
) as
  /*
    Марков МВ.
    Формирование позиционных мест по загрузкам.
  */
  sPOS_PREF   UDO_FCPLCHNOTSP_POS.POS_PREF%type; -- префикс
  sPOS_NUMB   UDO_FCPLCHNOTSP_POS.POS_NUMB%type; -- номер
  nPOS_NUMB_N UDO_FCPLCHNOTSP_POS.POS_NUMB_N%type; -- цифровое обозначение
  sLSTSP_NOTE FCPLCHNOTSP.NOTICE%type;
  nID         number(17);
  nTMP        number(17);
begin
  -- извещения об изменении спецификации
  if sUNIT = 'CostProductListNotifies' then
    /*PKG_FLAG.SET_FLAG;
    -- формирование позиционных обозначений для извещения
    for rec in (select CSP.RN,
                       (select OSP.RN
                          from UDO_LOADEXT_ORD_SP OSP,
                               DOCLINKS           L
                         where L.OUT_DOCUMENT = CSP.PRN
                           and L.OUT_UNITCODE = 'CostProductListNotifies'
                           and L.IN_DOCUMENT = OSP.PRN
                           and OSP.MODIF = MR.NOMEN_MODIF) OSP_RN
                  from FCPLCHNOTSP   CSP,
                       FCMATRESOURCE MR
                 where CSP.PRN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                   and CSP.MTR_RES = MR.RN) loop
      nTMP := 0;
      for rsp in (select RN,
                         POSITION
                    from UDO_FCPLCHNOTSP_POS
                   where PRN = rec.rn) loop
        nTMP := 1;
        -- преобразование позиционного обозначения
        UDO_PKG_LOADEXT_ORD_BASE.P_POSITION_GET_PREFNUMB(sPOS  => rsp.position,
                                                         sPREF => sPOS_PREF,
                                                         sNUMB => sPOS_NUMB,
                                                         nNUMB => nPOS_NUMB_N);
        update UDO_FCPLCHNOTSP_POS P
           set P.POS_PREF   = sPOS_PREF,
               P.POS_NUMB   = sPOS_NUMB,
               P.POS_NUMB_N = nPOS_NUMB_N
         where P.RN = rsp.rn;
      end loop;
      --
      if nTMP <= 0 and
         rec.osp_rn is not null then
        for rosp in (select OAS.STRING_VALUE,
                            OAS.POS_PREF,
                            OAS.POS_NUMB,
                            OAS.POS_NUMB_N
                       from UDO_LOADEXT_ORD_ATTR_SPEC OAS
                      where OAS.PRN = rec.osp_rn
                        and OAS.ATTRIBUTE_ID = 4100) loop
          UDO_PKG_FCPLCHNOT_BASE.POS_INSERT(nPRN         => rec.rn,
                                            sPOSITION    => rosp.string_value,
                                            nANNUL       => 0,
                                            nCHANGE_KIND => 0,
                                            nLSTSPPOS_RN => null,
                                            sPOS_PREF    => rosp.pos_pref,
                                            sPOS_NUMB    => rosp.pos_numb,
                                            nPOS_NUMB_N  => rosp.pos_numb_n,
                                            nRN          => nTMP);
        end loop;
      end if;
      --
      if nTMP > 0 then
        sLSTSP_NOTE := UDO_PKG_FCPLCHNOT_BASE.F_POS_GET_CONTEXT(nPRN => rec.rn);
        update FCPLCHNOTSP SP set SP.NOTICE = sLSTSP_NOTE where SP.RN = rec.rn;
      end if;
    
    end loop;
    PKG_FLAG.RESET_FLAG;*/
  
    --
    --return;
    --
  
    -- перенос примечания в спецификации и ПС
    for rec in (select NS.RN,
                       NS.NOTICE,
                       (select N.INTRO_DATE from FCPLCHNOT N where N.RN = NS.PRN) DATE_FR
                  from FCPLCHNOTSP NS
                 where NS.PRN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
                   and NS.NOTICE is not null) loop
      p_selectlist_genident(nIDENT => nID);
      for rsp in (select SP.RN
                    from FCPRODLSTSP SP,
                         DOCLINKS    L
                   where L.IN_DOCUMENT = rec.rn
                     and L.IN_UNITCODE = 'CostProductListNotifiesSpecs'
                     and L.OUT_DOCUMENT = SP.RN
                     and L.OUT_UNITCODE = 'CostProductListsSpecs'
                     and SP.QUANT > 0) loop
        p_selectlist_insert(nIDENT => nID, nDOCUMENT => rsp.rn, sUNITCODE => 'CostProductListsSpecs', nRN => nTMP);
        --
        for rpl in (select * from UDO_FCPLCHNOTSP_POS where PRN = rec.rn) loop
          UDO_PKG_FCPRODLST_BASE.POS_INSERT(nPRN        => rsp.rn,
                                            sPOSITION   => rpl.position,
                                            dDATE_FROM  => rec.date_fr,
                                            nANNUL      => 0,
                                            sPOS_PREF   => rpl.pos_pref,
                                            sPOS_NUMB   => rpl.pos_numb,
                                            nPOS_NUMB_N => rpl.pos_numb_n,
                                            nRN         => nTMP);
        end loop;
      end loop;
      UDO_P_PRODLSTSP_SETPOS(nIDENT => nID, nCOMPANY => nCOMPANY);
      p_selectlist_clear(nIDENT => nID);
    end loop;
  end if;

  -- спецификация
  if sUNIT = 'CostProductLists' then
    -- перенос в ПС
    for rec in (select SP.RN,
                       SP.NOTE
                  from FCPRODLSTSP SP
                 where SP.PRN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)) loop
      for cmp in (select CSP.RN from FCPRODCMPSP CSP where CSP.PRODLSTSP = rec.rn) loop
        update FCPRODCMPSP S set S.NOTE = rec.note where S.RN = cmp.rn;
      end loop;
    end loop;
  end if;

  -- инициализация позиционных мест в ПС
  if 0 = 1 then
    for rec in (select cmp.rn,
                       cmp.note,
                       (select lsp.note from fcprodlstsp lsp where lsp.rn = cmp.prodlstsp) sp_note
                  from fcprodcmpsp cmp
                 where cmp.prn = 57245517) loop
      if (rec.note is null and rec.sp_note is not null) or
         (rec.sp_note is not null and rec.note != rec.sp_note) then
        update fcprodcmpsp cm set cm.note = rec.sp_note where cm.rn = rec.rn;
      end if;
    end loop;
  end if;

end;
/

