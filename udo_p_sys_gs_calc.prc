create or replace procedure udo_p_sys_gs_calc as
  nCLC number(17);
begin
  for rec in (select tt.restfact,
                     tt.reserv,
                     tt.tds_qnt,
                     tt.gs_rn,
                     tt.clc_rn,
                     gp.rn as gp_rn,
                     ic.code as party,
                     trim(gp.sernumb) as sernumb,
                     (select nvl(sum(ios.factquant), 0) from inorderspecs ios where trim(ios.sernumb) = trim(gp.sernumb)) ios_qnt,
                     (select count(*)
                        from inorderspecs    ios,
                             inorderspecsclc clc
                       where trim(ios.sernumb) = trim(gp.sernumb)
                         and clc.prn = ios.rn) oclc_cnt,
                     (select nvl(sum(ifs.quant_fact), 0)
                        from incomefromdepsspec ifs,
                             goodssupply        gss
                       where trim(ifs.sernumb) = trim(gp.sernumb)
                         and ifs.supply = gss.rn
                         and gss.prn = gp.rn) ifs_qnt,
                     (select count(*)
                        from incomefromdepsspec ifs,
                             incfdepspclc       clc,
                             goodssupply        gss
                       where trim(ifs.sernumb) = trim(gp.sernumb)
                         and ifs.supply = gss.rn
                         and gss.prn = gp.rn
                         and clc.prn = ifs.rn) fclc_cnt
                from goodsparties gp,
                     incomdoc     ic,
                     (select st.azs_number,
                             gs.restfact,
                             gs.reserv,
                             gs.rn as gs_rn,
                             gs.prn,
                             (select gc.rn
                                from goodssupplyclc gc
                               where gc.prn = gs.rn
                                 and gc.faceacc is null
                                 and gc.quant_fact > 0) as clc_rn,
                             (select nvl(sum(tds.quant), 0)
                                from storeoperjourn    soj,
                                     doclinks          l,
                                     transinvdeptspecs tds
                               where soj.goodssupply = gs.rn
                                 and soj.oper_type = 1
                                 and l.out_document = soj.rn
                                 and l.in_document = tds.rn
                                 and tds.crn = 43727700) as tds_qnt
                        from goodssupply  gs,
                             azsazslistmt st
                       where gs.store = st.rn
                         and gs.restfact > 0
                         and st.azs_number in ('ÝÐÈ')
                         and not exists (select null
                                from goodssupplyclc gc
                               where gc.prn = gs.rn
                                 and gc.faceacc is not null
                                 --and gc.quant_fact > 0
                                 )
                         and exists (select null
                                from storeoperjourn    soj,
                                     doclinks          l,
                                     transinvdeptspecs tds,
                                     transinvdept td
                               where soj.goodssupply = gs.rn
                                 and soj.oper_type = 1
                                 and l.out_document = soj.rn
                                 and l.in_document = tds.rn
                                 and tds.crn = 43727700
                                 and tds.prn = td.rn 
                                 and td.docdate = s2d('29.10.2022'))) tt
               where tt.prn = gp.rn and gp.indoc = ic.rn) loop
    if rec.fclc_cnt = 1 then
      --
      for rclc in (select clc.*
                     from incomefromdepsspec ifs,
                          incfdepspclc       clc,
                          goodssupply        gss
                    where trim(ifs.sernumb) = rec.sernumb
                      and ifs.supply = gss.rn
                      and gss.prn = rec.gp_rn
                      and clc.prn = ifs.rn) loop
        if rec.clc_rn is not null then
          update goodssupplyclc gc
             set gc.faceacc = rclc.faceaccount
           where gc.rn = rec.clc_rn;
        else
        begin
        p_goodssupplyclc_base_insert(nCOMPANY      => rclc.company,
                                     nPRN          => rec.gs_rn,
                                     sNUMB         => 1,
                                     nCOST_ARTICLE => rclc.cost_article,
                                     nCOST_PLACE   => rclc.cost_place,
                                     nCOST_PLAN    => rclc.cost_plan,
                                     nCOST_FACT    => rclc.cost_fact,
                                     nPRIORITY     => rclc.priority,
                                     nFACEACC      => rclc.faceaccount,
                                     nGRAPHPOINT   => rclc.graphpoint,
                                     nFINOPER_TYPE => rclc.finoper_type,
                                     nQUANT_PLAN   => rec.tds_qnt,
                                     nQUANT_FACT   => rec.tds_qnt,
                                     nSUBDIV       => rclc.subdiv,
                                     nRN           => nCLC);
        exception
          when others then
            p_exception (0, 'sernumb = %s; party = %s', rec.sernumb, rec.party);
        end;
        end if;
      end loop;
    end if;
  end loop;
end;
/

