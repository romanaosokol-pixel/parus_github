create or replace procedure UDO_P_THEME_EXCLUDE_TMP
(
  nCOMPANY in number,
  sTHEME   in varchar2
) as
  /*
    10/07/2023 Марков МВ.
    Процедура формирования данных о расходе ТМЦ, закупленных под определенную тему
  
    UDO_THEME_EXCLUDE_TMP - таблица с данными
  */

  rTMP UDO_THEME_EXCLUDE_TMP%rowtype;

  --
  procedure ins_tmp(rROW in out UDO_THEME_EXCLUDE_TMP%rowtype) is
  begin
    insert into UDO_THEME_EXCLUDE_TMP values rROW;
  end ins_tmp;

begin
  --
  if rtrim(sTHEME) is null then
    p_exception(0, 'Не указана тема.');
  else
    rTMP.Ident  := gen_ident;
    rTMP.Authid := utilizer;
    rTMP.Theme  := sTHEME;
    delete from UDO_THEME_EXCLUDE_TMP where AUTHID = rTMP.Authid;
  end if;
  -- партии ТМЦ, где указана тема
  for rec in (select distinct gp.rn       as party,
                              gp.nommodif,
                              md.prn      as nomen,
                              gp.sernumb
                from goodssupplyclc gsc,
                     faceacc        fa,
                     goodssupply    gs,
                     goodsparties   gp,
                     incomdoc       ic,
                     nommodif       md
               where (gsc.quant_plan > 0 or gsc.quant_fact > 0)
                 and gsc.faceacc = fa.rn
                 and fa.numb like sTHEME || '%'
                 and gsc.prn = gs.rn
                 and gs.prn = gp.rn
                 and gp.indoc = ic.rn
                 and gs.restfact > 0
                 and gp.nommodif = md.rn) loop
    -- паратмеры партии
    rTMP.Nomen := rec.nomen;
    rTMP.Modif := rec.nommodif;
    rTMP.Party := rec.party;
    -- приходный документ
    if rtrim(rec.sernumb) is not null then
      begin
        select IO.RN,
               IOS.RN
          into rTMP.Indoc_Rn,
               rTMP.Inspec_Rn
          from INORDERS     IO,
               INORDERSPECS IOS
         where IOS.PRN = IO.RN
           and IOS.SERNUMB = rec.sernumb
           and IOS.NOMMODIF = rec.nommodif;
      exception
        when no_data_found then
          rTMP.Indoc_Rn := null;
        when too_many_rows then
          rTMP.Indoc_Rn := null;
      end;
    end if;
  
    --
    rTMP.In_Doc_Zakaz := '';
    if rTMP.Inspec_Rn is not null then
      for r_zak in (select distinct substr(FA.NUMB, 1, 5) as NUMB
                      from INORDERSPECSCLC IOC,
                           FACEACC         FA
                     where IOC.PRN = rTMP.Inspec_Rn
                       and IOC.FACEACCOUNT = FA.RN) loop
        if rtrim(rTMP.In_Doc_Zakaz) is null then
          rTMP.In_Doc_Zakaz := r_zak.numb;
        else
          if length(rTMP.In_Doc_Zakaz||';'||r_zak.numb) <= 2000 then
            rTMP.In_Doc_Zakaz := rTMP.In_Doc_Zakaz||';'||r_zak.numb;
          end if;
        end if;
      end loop;
    end if;
  
    -- расход партии в производство (связано с КВ)
    for r_ex in (select SOJ.UNITCODE,
                        SOJ.QUANT,
                        SOJ.GOODSSUPPLY,
                        TD.RN           as DOC_RN,
                        FA.NUMB         as ZAKAZ
                   from STOREOPERJOURN SOJ,
                        GOODSSUPPLY    GS,
                        DOCLINKS       L,
                        TRANSINVDEPT   TD,
                        FACEACC        FA
                  where GS.PRN = rec.party
                    and SOJ.GOODSSUPPLY = GS.RN
                    and SOJ.OPER_TYPE = 0
                    and L.OUT_DOCUMENT = SOJ.RN
                    and L.OUT_UNITCODE = 'StoreOpersJournal'
                    and L.IN_UNITCODE = 'GoodsTransInvoicesToDepts'
                    and L.IN_DOCUMENT = TD.RN
                    and TD.FACEACC = FA.RN
                    and exists (select null
                           from DOCLINKS LL
                          where LL.OUT_DOCUMENT = TD.RN
                            and LL.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                            and LL.IN_UNITCODE = 'CostDeliverySheets')) loop
      rTMP.Supply   := r_ex.goodssupply;
      rTMP.Unitcode := r_ex.unitcode;
      rTMP.Doc_Rn   := r_ex.doc_rn;
      rTMP.Quant    := r_ex.quant;
      rTMP.Zakaz    := r_ex.zakaz;
      --
      ins_tmp(rROW => rTMP);
    end loop;
  
  end loop;
end;
/

