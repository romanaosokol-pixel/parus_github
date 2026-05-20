create or replace procedure UDO_REP_ININVOICES_STICKER(
       nCOMPANY   in number,   -- Организация
       sRazd      in varchar2, -- Раздел из которого запускается отчет
       nIdent     in number,   -- Выбранная строка
       nJoint     in number    -- Суммирование количества
) is
-- Печать этикеток для Приходной накладной
----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'TDSheet'; -- Лист

  LL_CONTR   constant PKG_STD.TSTRING := 'L_CONTR';
  С_STop1    constant PKG_STD.TSTRING := 'S_Top1';
  С_STop2    constant PKG_STD.TSTRING := 'S_Top2';
  C_SContr1  constant PKG_STD.TSTRING := 'S_Contr1';
  C_SContr2  constant PKG_STD.TSTRING := 'S_Contr2';
  LL_NAME    constant PKG_STD.TSTRING := 'L_NAME';
  C_SName1   constant PKG_STD.TSTRING := 'S_Name1';
  C_SName2   constant PKG_STD.TSTRING := 'S_Name2';
  LL_GOST    constant PKG_STD.TSTRING := 'L_GOST';
  C_SGost1   constant PKG_STD.TSTRING := 'S_Gost1';
  C_SGost2   constant PKG_STD.TSTRING := 'S_Gost2';
  LL_KOL     constant PKG_STD.TSTRING := 'L_KOL';
  C_SKol1    constant PKG_STD.TSTRING := 'S_Kol1';
  C_SKol2    constant PKG_STD.TSTRING := 'S_Kol2';
  LL_SHIFR   constant PKG_STD.TSTRING := 'L_SHIFR';
  С_SNum1    constant PKG_STD.TSTRING := 'S_Num1';
  С_SNum2    constant PKG_STD.TSTRING := 'S_Num2';
  C_SShifr1  constant PKG_STD.TSTRING := 'S_Shifr1';
  C_SShifr2  constant PKG_STD.TSTRING := 'S_Shifr2';
  LL_NOMEN   constant PKG_STD.TSTRING := 'L_NOMEN';
  C_SSeria1  constant PKG_STD.TSTRING := 'S_Seria1';
  C_SSeria2  constant PKG_STD.TSTRING := 'S_Seria2';
  C_SNomen1  constant PKG_STD.TSTRING := 'S_Nomenkl1';
  C_SNomen2  constant PKG_STD.TSTRING := 'S_Nomenkl2';
  LL_DATE    constant PKG_STD.TSTRING := 'L_DATE';
  C_SDate1   constant PKG_STD.TSTRING := 'S_Date1';
  C_SDate2   constant PKG_STD.TSTRING := 'S_Date2';
  LL_PROV    constant PKG_STD.TSTRING := 'L_PROV';
  C_SDProv1  constant PKG_STD.TSTRING := 'S_DProv1';
  C_SDProv2  constant PKG_STD.TSTRING := 'S_DProv2';

  LL_GAP     constant PKG_STD.TSTRING := 'L_GAP';

  nPP         number := 0;
  nSTR        number;
  nSTR1       number;
  nSTR2       number;
  nSTR3       number;
  nSTR4       number;
  nSTR5       number;
  nSTR6       number;
  nSTR7       number;
  nSTR8       number;
  sZakaz      varchar2(2048);
  --sShifr      varchar2(256);
  sZayav      varchar2(256);
  sTMP        varchar2(1024);
  --nDocument   number := 0;
  --sCode       varchar2(1024);
  --sFaceacc    faceacc.numb%type;

function F_GET_ZAKAZ(rec_nrn in number) return varchar2 is
  --sUsl        varchar2(1024);
begin
  sZakaz := null; --sUsl := '';
--udo_f_faceacc_buhcode
--select listagg(UDO_F_FACEACC_PRJCODE(sspc.nfaceaccount), '; ') within group (order by UDO_F_FACEACC_PRJCODE(sspc.nfaceaccount))
  select listagg(t.Zak, '; ') within group (order by t.Zak)
    into sZakaz
    from (select distinct UDO_F_FACEACC_GET_SHEFR(sspc.nfaceaccount) Zak
            from V_INORDERSPECSCLC sspc
           where sspc.nPRN = rec_nrn
             and sspc.nquant_plan > 0) t;     -- .nquant_fact
/*  for zak in (select trim(PR.NAME_USL) Usl, trim(PS.NUMB) Numb
      from INORDERSPECSCLC sspc,
           FACEACC      fc,
           PROJECTSTAGE ps,
           PROJECT      pr
     where sspc.PRN = rec_nrn
       and sspc.quant_fact > 0
       and FC.RN = sspc.faceaccount
       and (PS.FACEACC = FC.rn or PS.FACEACCCUST = FC.rn)
       and PR.RN = PS.PRN
       order by PR.NAME_USL, PS.NUMB) loop
       if sZakaz is null then
         sZakaz := zak.usl ||' Эт.'|| zak.numb;
         sUsl := zak.usl;
       else 
         if sUsl != zak.usl then
              sZakaz := sZakaz || '; ' || zak.usl ||' Эт.'|| zak.numb;
         else sZakaz := sZakaz || ', ' || zak.numb;
         end if;
       end if;
  end loop;*/
  return(sZakaz);
end;
  
begin
--p_exception(0,'Раздел: ' || sRazd || '. Строка: ' || nIdent);
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;
  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  PRSG_EXCEL.LINE_DESCRIBE(LL_CONTR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, С_STop1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, С_STop2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_SContr1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_SContr2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_NAME, C_SName1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_NAME, C_SName2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_GOST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_GOST, C_SGost1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_GOST, C_SGost2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_KOL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_KOL, C_SKol1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_KOL, C_SKol2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_SHIFR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_SHIFR, С_SNum1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_SHIFR, С_SNum2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_SHIFR, C_SShifr1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_SHIFR, C_SShifr2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_NOMEN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_NOMEN, C_SSeria1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_NOMEN, C_SSeria2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_NOMEN, C_SNomen1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_NOMEN, C_SNomen2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_DATE, C_SDate1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_DATE, C_SDate2);
  PRSG_EXCEL.LINE_DESCRIBE(LL_PROV);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_PROV, C_SDProv1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_PROV, C_SDProv2);

  PRSG_EXCEL.LINE_DESCRIBE(LL_GAP);

  if 'IncomingOrders' = UDO_REP_ININVOICES_STICKER.sRazd then
    for rec in(
      select UDO_F_INORDERS_DEPORD_NUMB(inv.NRN) sZayav, upper(MD.MODIF_NAME) as MODIF_CODE,
             inv.nrn inv_nrn, inv.sseller, inv.sseller_name, --to_char(spec.dprod_date, 'DD.MM.YYYY') sDate,
             /*trim(inv.sindocpref) ||'-'||*/ trim(inv.sindocnumb) sNomen, 
             UDO_F_FACEACC_PRJCODE(inv.nfaceacc) sCode,
             --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = spec.NRN) sDate,
             udo_f_get_doc_prop_val(NDOC => spec.NRN, SPROP => 'Дата производства') as sDate,
             f_docs_props_get_str_value(nproperty => 134301298, sunitcode => 'IncomingOrdersSpecs', ndocument => spec.NRN) as sIFDS,
             spec.nrn spec_nrn, 
             spec.nfactquant, 
             spec.spricemeas, 
             spec.nfactquant || ' ' || spec.spricemeas as s_Quant,
             spec.snomenname, 
             spec.ssernumb--, spec.snomen
        from SELECTLIST SL, 
             V_INORDERS inv, V_INORDERSPECS spec, NOMMODIF MD
       where SL.IDENT = nIdent
         and inv.NRN = SL.DOCUMENT
         and inv.ncompany = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.nrn = spec.nprn
         and spec.snomenname not like '%Доставка%' and UPPER(TRIM(spec.snomenname)) not like 'ТАРА'
         and spec.NNOMMODIF = MD.RN
       order by inv.sagent, spec.snomenname
    ) loop

      nPP := nPP + 1;
      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sseller_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.s_Quant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, F_GET_ZAKAZ(rec.spec_nrn) || ' / ' || rec.szayav);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.sNomen || '   ' || rec.ssernumb);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv1, 0, nSTR8, rec.sIFDS);
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sseller_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.s_Quant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, F_GET_ZAKAZ(rec.spec_nrn) || ' / ' || rec.szayav);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.sNomen || '   ' || rec.ssernumb);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv2, 0, nSTR8, rec.sIFDS);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);

    end loop;

  elsif 'IncomingOrdersSpecs' = UDO_REP_ININVOICES_STICKER.sRazd then

    for rec in(
      select UDO_F_INORDERS_DEPORD_NUMB(spec.NPRN) sZayav, upper(MD.MODIF_NAME) as MODIF_CODE,
             inv.nrn inv_nrn, inv.sseller, inv.sseller_name, --to_char(spec.dprod_date, 'DD.MM.YYYY') sDate,
             /*trim(inv.sindocpref) ||'-'|| */trim(inv.sindocnumb) sNomen, 
             UDO_F_FACEACC_PRJCODE(inv.nfaceacc) sCode,
             --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = spec.NRN) sDate,
             udo_f_get_doc_prop_val(NDOC => spec.NRN, SPROP => 'Дата производства') as sDate,
             f_docs_props_get_str_value(nproperty => 134301298, sunitcode => 'IncomingOrdersSpecs', ndocument => spec.NRN) as sIFDS,
             spec.nrn spec_nrn, 
             spec.nfactquant, 
             spec.spricemeas, 
             spec.nfactquant || ' ' || spec.spricemeas as s_Quant,
             spec.snomenname, 
             spec.ssernumb--, spec.snomen
        from SELECTLIST SL, 
             V_INORDERSPECS spec, V_INORDERS inv, NOMMODIF MD
       where SL.IDENT = nIdent
         and spec.NRN = SL.DOCUMENT
         and spec.ncompany = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.nrn = spec.nprn
         and spec.snomenname not like '%Доставка%' and spec.snomenname not like 'Тара'
         and spec.NNOMMODIF = MD.RN
       order by inv.sagent, spec.snomenname
    ) loop

      nPP := nPP + 1;
      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sseller_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.s_Quant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, F_GET_ZAKAZ(rec.spec_nrn) || ' / ' || rec.szayav);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.sNomen || '   ' || rec.ssernumb);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv1, 0, nSTR8, rec.sIFDS);
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sseller_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.s_Quant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, F_GET_ZAKAZ(rec.spec_nrn) || ' / ' || rec.szayav);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.sNomen || '   ' || rec.ssernumb);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv2, 0, nSTR8, rec.sIFDS);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);

    end loop;

  elsif 'GoodsTransInvoicesToDepts' = UDO_REP_ININVOICES_STICKER.sRazd then
/* необходима печать этикеток с пустым местом хранения - как вариант при списании с рук от Шикуца в производство */
    if nJoint = 1 then
    -- KHOK 24.07.2023 Объединяем и суммируем, без учета заводских номеров
    for rec in(
      select upper(MD.MODIF_NAME) as MODIF_CODE, 
             --0 as inv_nrn, 
             inv.faceacc, --inv.sfaceacc, 
             inv.in_mol,
             cll.sDate,
             cll.sProd,
             cll.sNomen, cll.snomenname, cll.ssernumb, /*cll.sgoodsparty,*/ sum(cll.nQuant) nQuant, cll.sQuant,
             cll.sIFDS
        from SELECTLIST SL, 
             TRANSINVDEPT inv, NOMMODIF MD,
             (select trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) as sNomen 
                    ,spec.nprn
                    ,sum(spec.nquant) nQuant, spec.spricemeas as sQuant
                    ,spec.snomenname, spec.ssernumb, spec.sgoodsparty, spec.nnommodif
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn)  as sProd
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)   as sDate
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298) as sIFDS -- План.поверка. Дата   
                from V_TRANSINVDEPTSPECS spec, 
                     V_STRPLRESJRNL_DOCS VPL,
                     STPLCELLS           CEL                    
               where VPL.nres_type = 1
                 and VPL.ncell = CEL.RN and vpl.nquant > 0
                 and exists (select null 
                               from DOCLINKS DL
                              where DL.in_document = spec.NRN
                                and DL.in_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                                and DL.out_document = VPL.NRN)
                group by trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB), 
                     spec.nprn, spec.spricemeas, spec.snomenname, spec.ssernumb, spec.sgoodsparty, spec.nnommodif
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn)
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298)
              union
                select null as sNomen 
                    ,spec.nprn
                    ,sum(spec.nquant) nQuant, spec.spricemeas as sQuant
                    ,spec.snomenname, spec.ssernumb, spec.sgoodsparty, spec.nnommodif
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn)  as sProd
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)   as sDate
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298) as sIFDS -- План.поверка. Дата      
                  from V_TRANSINVDEPTSPECS spec
                 where not exists (select null 
                               from DOCLINKS DL, V_STRPLRESJRNL_DOCS VPL
                              where DL.in_document = spec.NRN
                                and DL.in_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                                and DL.out_document = VPL.NRN
                                and VPL.nres_type = 1)
                 group by spec.nprn, spec.spricemeas, spec.snomenname, spec.ssernumb, spec.sgoodsparty, spec.nnommodif
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn)
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298)
             ) CLL
       where SL.IDENT = nIdent
         and inv.RN = SL.DOCUMENT
         and inv.company = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.rn = cll.nprn
         and cll.snomenname not like '%Доставка%' and UPPER(TRIM(cll.snomenname)) not like 'ТАРА'
         and cll.nnommodif = MD.RN
       -- KHOK 06.07.2023 Объединяем и суммируем, если вдруг выбраны несколько накладных с полностью одинаковыми позициями внутри
       group by MD.MODIF_NAME, inv.faceacc, /*inv.sfaceacc,*/ inv.in_mol, 
             /*UDO_F_FACEACC_PRJCODE(inv.nfaceacc),*/ cll.sNomen, cll.snomenname, cll.sProd, cll.sDate, cll.sQuant, cll.ssernumb --, cll.sgoodsparty,
       order by cll.snomenname, cll.ssernumb--, cll.sgoodsparty 
    ) loop

      nPP := nPP + 1;
      --sZakaz := rec.szakaz; -- null
      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(С_STop1,   0, nSTR1, 'Изделие');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_STop2,   0, nSTR1, 'Изделие');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum1,   0, nSTR5, 'Номер заказа');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum2,   0, nSTR5, 'Номер заказа');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria1, 0, nSTR6, 'Серия, мест.хр.');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria2, 0, nSTR6, 'Серия, мест.хр.');

        --PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sProd || ' - ' || rec.sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sProd);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.nQuant || ' ' || rec.sQuant);
        if rec.faceacc is not null then 
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, GET_FACEACC_NUMB_ID(0, rec.faceacc) /*rec.sfaceacc*/); --sShifr); --
        end if;
        if /*79777323 = rec.inv_nrn or*/ rec.sNomen is null then
             PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.ssernumb);
        else PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.ssernumb || ',   ' || rec.sNomen);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv1, 0, nSTR8, rec.sIFDS);
      else
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sProd || ' - ' || rec.sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sProd);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.nQuant || ' ' || rec.sQuant);
        if rec.faceacc is not null then 
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, GET_FACEACC_NUMB_ID(0, rec.faceacc) /*rec.sfaceacc*/); --sShifr); --
        end if;
        if /*79777323 = rec.inv_nrn or*/ rec.sNomen is null then
             PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.ssernumb);
        else PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.ssernumb || ',   ' || rec.sNomen);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv2, 0, nSTR8, rec.sIFDS);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);

    end loop;

    else
--if utilizer = 'KHOK' then p_exception(0, 'stop'); end if;
    for rec in(
      select upper(MD.MODIF_NAME) as MODIF_CODE, 
             --inv.nrn inv_nrn, 
             inv.faceacc, inv.in_mol, --to_char(spec.dprod_date, 'DD.MM.YYYY') sDate,
             --UDO_F_FACEACC_PRJCODE(inv.nfaceacc) sCode,
           --  spec.nrn, spec.nquant || ' ' || spec.spricemeas sQuant, spec.snomenname, spec.ssernumb,-- spec.snomen
          /*   (select trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) CELL--, VPL.nQUANT
                from V_STRPLRESJRNL_DOCS VPL,
                     STPLCELLS           CEL
               where VPL.nres_type = 1
                 and VPL.ncell = CEL.RN
                 and exists (select * from V_DOCLINKS_INOUT_IN_EXT DLIN
                              where (DLIN.NIN_DOCUMENT = spec.NRN)
                                and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                and (DLIN.NDOCUMENT = VPL.NRN))) sNomen,*/
             cll.sZakaz,
             cll.sProd,
             cll.sDate,
             cll.snomenname, cll.ssernumb, /*cll.sgoodsparty,*/ cll.sNomen, sum(cll.nQuant) nQuant, cll.sQuant,
             cll.sIFDS --, CLL.*
        from SELECTLIST SL, 
             TRANSINVDEPT inv, NOMMODIF MD,
             (select trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) as sNomen 
                    --,spec.NRN  
                    ,spec.nprn
                    ,sum(spec.nquant) nQuant, spec.spricemeas as sQuant
                    ,spec.snomenname, spec.ssernumb, spec.sgoodsparty, spec.nnommodif
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn) as sProd
                    ,UDO_F_TRANSINVDEPT_MAIN_NUMB(spec.nprn) as sZakaz
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)  as sDate
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298) as sIFDS -- План.поверка. Дата
                    --    ,vpl.nquant
                from V_TRANSINVDEPTSPECS spec, 
                     V_STRPLRESJRNL_DOCS VPL,
                     STPLCELLS           CEL                    
               where VPL.nres_type = 1
                 and VPL.ncell = CEL.RN and vpl.nquant > 0
                 and exists (select null 
                               from V_DOCLINKS_INOUT_IN_EXT DLIN
                              where DLIN.NIN_DOCUMENT = spec.NRN
                                and DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                                and DLIN.NDOCUMENT = VPL.NRN)
                group by trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB), 
                     /*spec.NRN,*/ spec.nprn, spec.spricemeas, spec.snomenname, spec.ssernumb, spec.sgoodsparty
                    ,spec.NNOMMODIF
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn)
                    ,UDO_F_TRANSINVDEPT_MAIN_NUMB(spec.nprn)
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298)
              union
                select null as sNomen 
                    --,spec.NRN  
                    ,spec.nprn
                    ,sum(spec.nquant) nQuant, spec.spricemeas as sQuant
                    ,spec.snomenname, spec.ssernumb, spec.sgoodsparty, spec.nnommodif
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn) as sProd
                    ,UDO_F_TRANSINVDEPT_MAIN_NUMB(spec.nprn) as sZakaz
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)  as sDate
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298) as sIFDS -- План.поверка. Дата
                  from V_TRANSINVDEPTSPECS spec
                 where not exists (select null 
                               from V_DOCLINKS_INOUT_IN_EXT DLIN, V_STRPLRESJRNL_DOCS VPL
                              where DLIN.NIN_DOCUMENT = spec.NRN
                                and DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                                and DLIN.NDOCUMENT = VPL.NRN
                                and VPL.nres_type = 1)
                 group by /*spec.NRN,*/ spec.nprn, spec.spricemeas, spec.snomenname, spec.ssernumb, spec.sgoodsparty
                    ,spec.NNOMMODIF
                    ,UDO_F_TRANSINVDEPT_MAIN_PROD(spec.nprn)
                    ,UDO_F_TRANSINVDEPT_MAIN_NUMB(spec.nprn)
                    ,UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN)
                    ,USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298)
            ) CLL
       where SL.IDENT = nIdent
         and inv.RN = SL.DOCUMENT
         and inv.company = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.rn = cll.nprn
         and cll.snomenname not like '%Доставка%' and UPPER(TRIM(cll.snomenname)) not like 'ТАРА'
         and cll.nnommodif = MD.RN
       -- KHOK 06.07.2023 Объединяем и суммируем, если вдруг выбраны несколько накладных с полностью одинаковыми позициями внутри
       group by MD.MODIF_NAME, /*inv.nrn,*/ inv.faceacc, inv.in_mol, 
             /*CLL.NRN,*/ cll.snomenname, cll.sQuant, cll.ssernumb, /*cll.sgoodsparty,*/ cll.sNomen,
             cll.sZakaz, cll.sProd, cll.sDate, cll.sIFDS
       order by cll.snomenname, cll.ssernumb--, cll.sgoodsparty
    ) loop

      nPP := nPP + 1;
      if rec.sZakaz is not null then
        if INSTR(rec.sProd, '(000') > 0 then
             sZakaz := SUBSTR(rec.sProd, 0, INSTR(rec.sProd, '(000')) || 'зав.№' || rec.sZakaz || ')';
        else sZakaz := rec.sProd || ' (зав.№' || rec.sZakaz || ')';
        end if;
      else sZakaz := rec.sProd;
      end if;

      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(С_STop1,   0, nSTR1, 'Изделие');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_STop2,   0, nSTR1, 'Изделие');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum1,   0, nSTR5, 'Номер заказа');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum2,   0, nSTR5, 'Номер заказа');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria1, 0, nSTR6, 'Серия, мест.хр.');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria2, 0, nSTR6, 'Серия, мест.хр.');

        --PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sProd || ' - ' || rec.sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.nQuant || ' ' || rec.sQuant);
        if rec.faceacc is not null then 
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, GET_FACEACC_NUMB_ID(0, rec.faceacc)); --sShifr);
        end if;
        if /*79777323 = rec.inv_nrn or */rec.sNomen is null then
             PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.ssernumb);
        else PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.ssernumb || ',   ' || rec.sNomen);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv1, 0, nSTR8, rec.sIFDS);
      else
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sProd || ' - ' || rec.sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.nQuant || ' ' || rec.sQuant);
        if rec.faceacc is not null then
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, GET_FACEACC_NUMB_ID(0, rec.faceacc)); --sShifr);
        end if;
        if /*79777323 = rec.inv_nrn or*/ rec.sNomen is null then
             PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.ssernumb);
        else PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.ssernumb || ',   ' || rec.sNomen);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv2, 0, nSTR8, rec.sIFDS);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);

    end loop;
    end if;

  elsif 'GoodsTransInvoicesToDeptsSpecs' = UDO_REP_ININVOICES_STICKER.sRazd then
    for rec in(
      select upper(MD.MODIF_NAME) as MODIF_CODE, 
             inv.nrn inv_nrn, inv.sfaceacc, inv.nin_mol, --to_char(spec.dprod_date, 'DD.MM.YYYY') sDate,
             UDO_F_FACEACC_PRJCODE(inv.nfaceacc) sCode,
             spec.nrn, spec.nquant || ' ' || spec.spricemeas sQuant, spec.snomenname, spec.ssernumb,-- spec.snomen
/*             (select trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) CELL--, VPL.nQUANT
                from V_STRPLRESJRNL_DOCS VPL,
                     STPLCELLS           CEL
               where VPL.nres_type = 1
                 and VPL.ncell = CEL.RN
                 and exists (select * from V_DOCLINKS_INOUT_IN_EXT DLIN
                              where (DLIN.NIN_DOCUMENT = spec.NRN)
                                and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                and (DLIN.NDOCUMENT = VPL.NRN))) sNomen,*/
             UDO_F_TRINDEPTSPECS_PROVDATE(spec.NRN) as sDate,
             UDO_F_TRANSINVDEPT_MAIN_NUMB(inv.nrn) sZakaz,
             UDO_F_TRANSINVDEPT_MAIN_PROD(inv.nrn) sProd,
             USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN => spec.nparty,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298) as sIFDS
        from SELECTLIST SL, 
             V_TRANSINVDEPT inv, V_TRANSINVDEPTSPECS spec, NOMMODIF MD
       where SL.IDENT = nIdent
         and spec.NRN = SL.DOCUMENT
         and spec.ncompany = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.nrn = spec.nprn
         and spec.snomenname not like '%Доставка%' and UPPER(TRIM(spec.snomenname)) not like 'ТАРА'
         and spec.NNOMMODIF = MD.RN
       order by inv.sagent, spec.snomenname
    ) loop

      nPP := nPP + 1;
      if rec.sZakaz is not null then
        if INSTR(rec.sProd, '(000') > 0 then
             sZakaz := SUBSTR(rec.sProd, 0, INSTR(rec.sProd, '(000')) || rec.sZakaz || ')';
        else sZakaz := rec.sProd || ' (' || rec.sZakaz || ')';
        end if;
      else sZakaz := rec.sProd;
      end if;

      for place in (
        select --trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) as sNomen
             UDO_F_STPLCELLS_SFULLCELL(UDO_REP_ININVOICES_STICKER.nCompany, cel.rn) sNomen
          from V_STRPLRESJRNL_DOCS VPL,
               STPLCELLS           CEL
         where VPL.nres_type = 1
           and VPL.ncell = CEL.RN
           and exists (select * from V_DOCLINKS_INOUT_IN_EXT DLIN
                        where (DLIN.NIN_DOCUMENT = rec.NRN)
                          and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                          and (DLIN.NDOCUMENT = VPL.NRN))
      ) loop

      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(С_STop1,   0, nSTR1, 'Изделие');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_STop2,   0, nSTR1, 'Изделие');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum1,   0, nSTR5, 'Номер заказа');
        PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum2,   0, nSTR5, 'Номер заказа');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria1, 0, nSTR6, 'Серия, мест.хр.');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria2, 0, nSTR6, 'Серия, мест.хр.');

        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.sQuant); --nquant || ' ' || rec.spricemeas);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, rec.sfaceacc);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.ssernumb || ',   ' || place.sNomen);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv1, 0, nSTR8, rec.sIFDS);
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        if instr(rec.modif_code, 'ГОСТ') > 0 then 
          sTMP := substr(rec.modif_code, instr(rec.modif_code, 'ГОСТ'));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, sTMP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.sQuant); --nquant || ' ' || rec.spricemeas);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, rec.sfaceacc);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.ssernumb || ',   ' || place.sNomen);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv2, 0, nSTR8, rec.sIFDS);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);

      end loop;

    end loop;

  elsif 'IncomingInvoices' = UDO_REP_ININVOICES_STICKER.sRazd then
p_exception(0,'Печать этикеток возможна из соответствующего Приходного ордера или Расходных накладных на отпуск в подразделение!');

    for rec in(
      select inv.sagent, inv.sagent_name, --to_char(inv.ddoc_date, 'DD.MM.YYYY') sDate,
             spec.nrn, spec.nquant, spec.snomenname, spec.snomen, -- sspc.sfaceaccount,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingInvoicesSpecs' and UNIT_RN = spec.NRN) sDate
        from SELECTLIST SL, V_ININVOICES inv, V_ININVOICESSPECS spec--, V_ININVOICESSPC sspc
       where SL.IDENT = nIdent
         and inv.NRN = SL.DOCUMENT
         and inv.ncompany = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.nrn = spec.nprn
         and spec.snomenname not like '%Доставка%' and spec.snomenname not like 'Тара'
         --and sspc.nprn (+)= spec.nrn
       order by inv.sagent, spec.snomenname
    ) loop
      nPP := nPP + 1;
      
      begin
        select listagg(UDO_F_FACEACC_PRJCODE(sspc.nfaceaccount), '; ') within group (order by UDO_F_FACEACC_PRJCODE(sspc.nfaceaccount))
          into sZakaz
          from V_ININVOICESSPC sspc 
         where sspc.nPRN = rec.nrn
           and sspc.nquant_fact > 0;
      exception
        when NO_DATA_FOUND then
          sZakaz := '---';
      end;

      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sagent_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.nquant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.snomen);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate); --to_char(rec.sDate, 'DD.MM.YYYY'));
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sagent_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.nquant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.snomen);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);
    end loop;

  elsif 'IncomingInvoicesSpecs' = UDO_REP_ININVOICES_STICKER.sRazd then
p_exception(0,'Печать этикеток возможна из соответствующего Приходного ордера или Расходных накладных на отпуск в подразделение!');

    for rec in(
      select inv.sagent, inv.sagent_name, --to_char(inv.ddoc_date, 'DD.MM.YYYY') sDate,
             spec.nrn, spec.nquant, spec.snomenname, spec.snomen,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingInvoicesSpecs' and UNIT_RN = spec.NRN) sDate
        from SELECTLIST SL, V_ININVOICESSPECS spec, V_ININVOICES inv
       where SL.IDENT = nIdent
         and spec.NRN = SL.DOCUMENT
         and spec.ncompany = UDO_REP_ININVOICES_STICKER.nCompany
         and inv.nrn = spec.nprn
         and spec.snomenname not like '%Доставка%' and spec.snomenname not like 'Тара'
       order by spec.snomenname
    ) loop
      nPP := nPP + 1;
      
      begin
        select listagg(UDO_F_FACEACC_PRJCODE(sspc.nfaceaccount), '; ') within group (order by UDO_F_FACEACC_PRJCODE(sspc.nfaceaccount))
          into sZakaz
          from V_ININVOICESSPC sspc 
         where sspc.nPRN = rec.nrn
           and sspc.nquant_fact > 0;
      exception
        when NO_DATA_FOUND then
          sZakaz := '---';
      end;
            
      if 1 = MOD(nPP, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, rec.sagent_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, rec.snomenname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, rec.nquant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, rec.snomen);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, rec.sDate);
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, rec.sagent_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, rec.snomenname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, '');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, rec.nquant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, sZakaz);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, rec.snomen);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, rec.sDate);
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);
    end loop;

  end if;
  --удаляем технические строки
  PRSG_EXCEL.LINE_DELETE(LL_CONTR);
  PRSG_EXCEL.LINE_DELETE(LL_NAME);
  PRSG_EXCEL.LINE_DELETE(LL_GOST);
  PRSG_EXCEL.LINE_DELETE(LL_KOL);
  PRSG_EXCEL.LINE_DELETE(LL_SHIFR);
  PRSG_EXCEL.LINE_DELETE(LL_NOMEN);
  PRSG_EXCEL.LINE_DELETE(LL_DATE);
  PRSG_EXCEL.LINE_DELETE(LL_PROV);

  PRSG_EXCEL.LINE_DELETE(LL_GAP);

end UDO_REP_ININVOICES_STICKER;
/
