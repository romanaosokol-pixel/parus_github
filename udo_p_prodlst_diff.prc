create or replace procedure UDO_P_PRODLST_DIFF
(
  nCOMPANY in number,
  nIDENT   in number,
  nMATRES  in number
) as
  /*
    13/03/2023 Марков МВ.
    Список загруженных извещений по матресурсу
    UDO_PRODLST_DIFF_TMP
  */
  
  procedure ins_tmp(rROW in out UDO_PRODLST_DIFF_TMP%rowtype) is
  begin
    rROW.Rn := gen_ident;
    insert into UDO_PRODLST_DIFF_TMP values rROW;
  end ins_tmp;

  /* список загрузок по спецификации */
  procedure load_list(nPRODLST in number) is
    rTMP UDO_PRODLST_DIFF_TMP%rowtype;
  begin
    rTMP.Ident := nIDENT;
    rTMP.Authid := utilizer;
    rTMP.Article := nMATRES;
    -- загрузки к спецификации
    for rld in (select lo.rn as load_rn,
                       lo.load_date,
                       mr.rn as matres_rn,
                       (select ATTR.STRING_VALUE
                          from UDO_LOADEXT_ORD_ATTR ATTR,
                               UDO_LOADEXT_ORD_SP   SP
                         where SP.PRN = lo.RN
                           and SP.SIGN_HEAD = 1
                           and ATTR.PRN = SP.RN
                           and ATTR.ATTRIBUTE_ID = 17918
                           and rownum < 2) as diff
                  from FCPRODLST       prl,
                       doclinks        l,
                       udo_loadext_ord lo,
                       fcmatresource   mr
                 where l.out_document = prl.rn
                   and l.out_unitcode = 'CostProductLists'
                   and l.in_document = lo.rn
                   and l.in_unitcode = 'UdoLoadextOrd'
                   and prl.mtr_res = mr.rn
                   and prl.rn = nPRODLST
                union
                select lo.rn as load_rn,
                       lo.load_date,
                       mr.rn as matres_rn,
                       (select ATTR.STRING_VALUE
                          from UDO_LOADEXT_ORD_ATTR ATTR,
                               UDO_LOADEXT_ORD_SP   SP
                         where SP.PRN = lo.RN
                           and SP.SIGN_HEAD = 1
                           and ATTR.PRN = SP.RN
                           and ATTR.ATTRIBUTE_ID = 17918
                           and rownum < 2) as diff
                  from FCPRODLST       prl,
                       doclinks        lp,
                       fcplchnot       ph,
                       doclinks        l,
                       udo_loadext_ord lo,
                       fcmatresource   mr
                 where lp.out_document = prl.rn
                   and lp.out_unitcode = 'CostProductLists'
                   and lp.in_document = ph.rn
                   and lp.in_unitcode = 'CostProductListNotifies'
                   and l.out_document = ph.rn
                   and l.out_unitcode = 'CostProductListNotifies'
                   and l.in_document = lo.rn
                   and l.in_unitcode = 'UdoLoadextOrd'
                   and prl.mtr_res = mr.rn
                   and prl.rn = nPRODLST) loop
      rTMP.Matres := rld.matres_rn;
      rTMP.Load_Ord := rld.load_rn;
      rTMP.Diff := rld.diff;
      ins_tmp(rROW => rTMP);
    end loop;
    -- по строкам спецификации
    for rpls in(select PP.RN from FCPRODLSTSP PPS, FCPRODLST PP where PPS.PRN = nPRODLST and PP.MTR_RES = PPS.COMPLETE) loop
      load_list(nPRODLST => rpls.rn);
    end loop;
  end load_list;

begin
  for rec in (select PLS.RN from FCPRODLST PLS where PLS.MTR_RES = nMATRES) loop
    -- загрузки по спецификации
    load_list(nPRODLST => rec.rn);
  end loop;
end;
/

