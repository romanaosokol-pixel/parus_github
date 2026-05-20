create or replace procedure UDO_P_TRANSINVDEPT_INS_CELL
(
  nCOMPANY in number,
  nRN      in number, -- рег.номер записи накладной
  sACTION  in varchar2,
  sMODE    in varchar2
) as

  /*
     ЦИТК Парус.
     22/01/2023
     Расходная накладная на отпуск в подразделение
     Возвратная накладная
     Автоматический неименованный блок
     После отработки
     Проставление журнала резервирования по МХ, и журнала операций по МХ
  */
  nRN_SP    number(17);
  nQUANT    number(17, 3);
  nQUANTALT number(17, 3);
  nrn_cell  number(17);
  nrn_jrn   number(17);
  nID       number(17);
begin

  if sACTION in ('TRANSINVDEPT_PROCESSWITH', 'TRANSINVDEPT_PROCESS') then
    -- возвратная накладная обязательно связана по входу с расходной накладной
    for l_cur in (select p.rn nRN_OUT,
                         t.rn nRN_IN,
                         ST.PROCESS_SIGN,
                         ST.DISTRIBUTION_SIGN,
                         p.*
                    from transinvdept p,
                         doclinks     l,
                         transinvdept t,
                         azsazslistmt st
                   where p.rn = nRN
                     and l.out_document = P.RN
                     and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                     and l.in_document = t.rn
                     and L.IN_UNITCODE = 'GoodsTransInvoicesToDepts'
                     and P.STORE = ST.RN) loop
      -- по спецификации исходной накладной
      for l_sp in (select ps.*,
                          NM.NOMEN_CODE,
                          NM.NOMEN_NAME,
                          MD.MODIF_CODE
                     from transinvdeptspecs ps,
                          NOMMODIF          MD,
                          DICNOMNS          NM
                    where ps.prn = l_cur.nRN_IN
                      and PS.NOMMODIF = MD.RN
                      and MD.PRN = NM.RN
                      and exists (select null
                             from TRANSINVDEPTSPECS TDS
                            where TDS.PRN = l_cur.nrn_out
                              and TDS.NOMMODIF = PS.NOMMODIF
                              and ((TDS.GOODSPARTY is not null and PS.GOODSPARTY is not null and TDS.GOODSPARTY = PS.GOODSPARTY) or
                                   (TDS.ARTICLE is not null and PS.ARTICLE is not null and TDS.ARTICLE = PS.ARTICLE))
                              )
                      and exists (select null
                             from V_STRPLRESJRNL_DOCS j
                            where NRES_TYPE = 1
                              and exists (select null
                                     from V_DOCLINKS_INOUT_IN_EXT DLIN
                                    where (DLIN.NIN_DOCUMENT = ps.rn)
                                      and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                      and (DLIN.NDOCUMENT = j.NRN)))) loop

        begin
          select tts.rn,
                 tts.quant,
                 tts.quantalt
            into nRN_SP,
                 nQUANT,
                 nQUANTALT
            from transinvdeptspecs tts
           where tts.prn = l_cur.nrn_out
             and tts.nommodif = l_sp.nommodif
             and ( cmp_num(tts.goodsparty, l_sp.goodsparty) = 1
                /* 05.12.2024 KHOK. Возвр.РН 2024-26889: article is null */
                or (tts.article is not null and cmp_num(tts.article, l_sp.article) = 1) 
                );
        exception
          when no_data_found then
            nRN_SP := to_number(null);
        end;
      
        -- места хранения исходной накладной
        if nRN_SP is not null and (l_cur.process_sign = 1 or l_cur.distribution_sign = 1) then
          for L_mx in (select distinct j.sstore,
                              j.srack_pref,
                              j.srack_numb,
                              j.scell_pref,
                              j.scell_numb,
                              j.snomen,
                              j.snommodif,
                              j.snomnmodifpack,
                              j.nnommodif,
                              j.nnomnmodifpack,
                              j.ncell,
                              j.ngoodssupply
                             ,j.narticle
                             ,j.sarticle
                         from V_STRPLRESJRNL_DOCS j
                        where NRES_TYPE = 1
                          and exists (select null
                                 from V_DOCLINKS_INOUT_IN_EXT DLIN
                                where (DLIN.NIN_DOCUMENT = l_sp.rn) -- 145844275
                                  and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                  and (DLIN.NDOCUMENT = j.NRN))
                          and not exists (select null
                                            from UDO_TRINVDEPT_STRPLACE_RETURN STRR
                                           where STRR.PRN = nRN_SP)
                       union all
                       -- 23/05/2024 Марков МВ. Возвратная накладная зарегистрируем МХ для возврата
                       select (select ST.AZS_NUMBER
                                 from TRANSINVDEPTSPECS TDS, TRANSINVDEPT TD, AZSAZSLISTMT ST
                                where TDS.RN = STR.PRN and TDS.PRN = TD.RN
                                  and TD.STORE = ST.RN) as sstore,
                              RACK.PREF as srack_pref,
                              RACK.NUMB as srack_numb,
                              CEL.PREF as scell_pref,
                              CEL.NUMB as scell_numb,
                              l_sp.nomen_code as snomen,
                              l_sp.modif_code as snommodif,
                              null as snomnmodifpack,
                              l_sp.nommodif as nnommodif,
                              null as nnomnmodifpack,
                              STR.CELL as ncell,
                              (select SOJ.GOODSSUPPLY
                                 from TRANSINVDEPTSPECS TDS,
                                      DOCLINKS          LTD,
                                      STOREOPERJOURN    SOJ
                                where TDS.RN = l_sp.rn
                                  and LTD.IN_DOCUMENT = TDS.RN
                                  and LTD.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                                  and LTD.OUT_DOCUMENT = SOJ.RN
                                  and LTD.OUT_UNITCODE = 'StoreOpersJournal'
                                  and SOJ.OPER_TYPE = 0
                                ) as ngoodssupply
                             ,( select tds.article
                                  from transinvdeptspecs tds
                                 where tds.rn = str.prn )     as narticle
                             ,( select rla.code
                                  from transinvdeptspecs tds
                                      ,rlarticles        rla
                                 where tds.rn = str.prn
                                   and rla.rn = tds.article ) as sarticle
                         from UDO_TRINVDEPT_STRPLACE_RETURN STR,
                              STPLCELLS                     CEL,
                              STPLRACKS                     RACK
                        where STR.PRN = nRN_SP
                          and STR.CELL = CEL.RN
                          and CEL.PRN  = RACK.RN
                       ) loop
            
            if sMODE = 'BEFORE' then
              -- ДО ОТРАБОТКИ
              -- резервирование по местам хранения
              p_strplresjrnl_insert(ncompany        => l_cur.company,
                                    smasterunitcode => 'GoodsTransInvoicesToDepts',
                                    sslaveunitcode  => 'GoodsTransInvoicesToDeptsSpecs',
                                    nmasterrn       => l_cur.nrn_out,
                                    nslavern        => nRN_SP,
                                    sstore          => L_mx.Sstore,
                                    srack_pref      => L_mx.Srack_Pref,
                                    srack_numb      => L_mx.Srack_Numb,
                                    scell_pref      => L_mx.Scell_Pref,
                                    scell_numb      => L_mx.Scell_Numb,
                                    ngoodssupply    => null,
                                    nres_type       => 0,
                                    snomen          => L_mx.Snomen,
                                    snommodif       => L_mx.Snommodif,
                                    snomnmodifpack  => L_mx.Snomnmodifpack,
                                    nnommodif       => L_mx.Nnommodif,
                                    nnomnmodifpack  => L_mx.Nnomnmodifpack,
                                    sarticle        => L_mx.sarticle,
                                    narticle        => L_mx.narticle,
                                    sgoodsunit      => null,
                                    sdoctype        => null,
                                    ddocdate        => null,
                                    sdocnumb        => null,
                                    sdocpref        => null,
                                    dreserving_date => l_cur.docdate,
                                    dfree_date      => null,
                                    nquant          => nQUANT,
                                    nquantalt       => nQUANTALT,
                                    nquantpack      => 0,
                                    nrn             => nrn_cell);
              end if;
            
            if sMODE = 'AFTER' then
              -- ПОСЛЕ ОТРАБОТКИ
              -- oper_kind = 0  oper_type = 0   signplan = 1
              -- складсик операции по местам хранения
              p_strploprjrnl_base_insert(ncompany     => l_cur.company,
                                         nprn         => null,
                                         ncell        => L_mx.Ncell,
                                         ngoodssupply => L_mx.Ngoodssupply,
                                         ngoodsunit   => null, ---  Грузовая еденица
                                         narticle     => L_mx.narticle,
                                         nquant       => nQUANT,
                                         nquantalt    => nQUANTALT,
                                         nquantpack   => 0,
                                         noper_type   => 0,
                                         noper_kind   => 0,
                                         doper_date   => l_cur.docdate,
                                         nsignplan    => 0,
                                         ndoctype     => l_cur.doctype,
                                         ddocdate     => l_cur.docdate,
                                         sdocnumb     => l_cur.numb,
                                         sdocpref     => l_cur.pref,
                                         nrn          => nrn_jrn);
              pkg_doclinks.link(nflag_smart       => 0,
                                ncompany          => l_cur.company,
                                sin_unitcode      => 'GoodsTransInvoicesToDepts',
                                nin_document      => l_cur.nrn_out,
                                nin_prn_document  => null,
                                din_date          => sysdate,
                                nin_status        => 0,
                                sout_unitcode     => 'StoreOpersJournal',
                                nout_document     => nrn_jrn,
                                nout_prn_document => null,
                                dout_date         => sysdate,
                                nout_status       => 0,
                                nbreakup_kind     => 0,
                                nlink_type        => 0,
                                nident            => nID);
            end if;
          end loop; -- l_mx
        end if;
      
      end loop; -- l_sp
    
    end loop; -- l_cur
  end if;
  
  --
  if sACTION in ('TRANSINVDEPT_CANCEL') then
  if sMODE = 'BEFORE' then
    -- по журналу операций по местам хранения
    for l_cur in (select j.*
                    from strploprjrnl j,
                         doclinks     l,
                         transinvdept tt
                   where j.rn = l.out_document
                     and l.in_document = tt.rn
                     and tt.rn = nRN
                        --and tt.status  = 1
                     and exists (select null
                            from transinvdept d,
                                 doclinks     dd
                           where dd.out_document = tt.rn
                             and dd.in_document = d.rn)) loop
      -- удалим операции по местам хранения
      --p_strploprjrnl_delete(nCOMPANY => l_cur.company, nRN => l_cur.rn);
      /* проверка связи с документами */
      P_LINKSALL_CHECK(nRN               => l_cur.rn, 
                       nCOMPANY          => l_cur.company, 
                       sUNITCODE         => 'StoragePlacesOperJournal', 
                       nBREAKUP_KIND     => 0, 
                       nCHECK_SMART_LINK => 1);

      /* базовое удаление */
      P_STRPLOPRJRNL_BASE_DELETE(nCOMPANY => l_cur.company, nRN => l_cur.rn );
    end loop;
  
    -- журнал резервирования по местам хранения
    for l_cur in (select j.*
                    from strplresjrnl j,
                         doclinks     l,
                         transinvdept tt
                   where j.rn = l.out_document
                     and l.in_document = tt.rn
                     and tt.rn = nRN
                        --and tt.status  = 1
                     and exists (select null
                            from transinvdept d,
                                 doclinks     dd
                           where dd.out_document = tt.rn
                             and dd.in_document = d.rn)) loop
      -- удалим МХ
      p_strplresjrnl_delete(nCOMPANY => l_cur.company, nRN => l_cur.rn);
    end loop;
  end if;
  --
  if sMODE = 'AFTER' then
    -- подсчитска связей ?
    for l_cur in (select l.*
                    from TRANSINVDEPT t,
                         doclinks     l
                   where t.RN = nRN
                     and t.rn = l.in_document
                     and l.out_unitcode = 'StoreOpersJournal'
                     and not exists (select null from storeoperjourn j where j.rn = l.out_document)
                        -- and t.status   = 1
                     and exists (select null
                            from transinvdept d,
                                 doclinks     dd
                           where dd.out_document = t.rn
                             and dd.in_document = d.rn)) loop
    
      delete from doclinks del where del.rn = l_cur.rn;
    
    end loop;
  end if;
  end if;
  --p_exception(0, 'Конец');
end;
/
