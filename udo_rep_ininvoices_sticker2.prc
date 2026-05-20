create or replace procedure UDO_REP_ININVOICES_STICKER2(
       nCOMPANY   in number,   -- Организация
       sUNITCODE  in varchar2, -- Раздел из которого запускается отчет
       nIdent     in number,   -- Отмеченные записи
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
  sShifr      varchar2(256);
  sZayav      varchar2(256);
  sTMP        varchar2(1024);
  nDocument   number := 0;
/*
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
\*  for zak in (select trim(PR.NAME_USL) Usl, trim(PS.NUMB) Numb
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
  end loop;*\
  return(sZakaz);
end;
*/
function STORE_ZONE(nCEL in number) return varchar
  as
  sRes PKG_STD.tSTRING;
  begin
    begin
      select ',     '||trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB)
      into sRes
      from STPLCELLS       CEL
      where CEL.rn = nCEL;
    exception when others then
      return null;
    end;
    return sRes;
  end;
  
function print_numb(nQuant in number) return varchar 
  as
  sRes varchar(20);
  begin
    if nQuant - TRUNC(nQuant,0) > 0  then
      sRes := to_char(nQuant,'999999990.999');
    else
      sRes := to_char(nQuant);
    end if;
    return sRes;
  end;

procedure Print_stiker(
    nParam in number,  -- 0 - приходные ордера, 1- расходные в подразделения
    UNITCODE in varchar, 
    GROUP_PARAM in number
  )
  as
    sTMP        PKG_STD.tSTRING;
    sSTORE_ZONE PKG_STD.tSTRING;
    npp number;
  begin
    npp := 1;
    for prn in (select sum(st.quant)  as  QUANT
                      ,st.check_date  as  check_date
                      ,st.prod_date   as  prod_date
                      ,st.PROD_DOC    as  PROD_DOC
                      ,st.store_zone  as  nSTORE_ZONE
                      ,st.sernumb     as  sernumb
                      ,st.TITLE       as  sTITLE
                      ,fc.numb        as  sFACEACC
                      ,dn.nomen_name  as  sNOMEN_NAME
                      ,NM.MODIF_NAME  as  sMODIF_CODE
                      ,ms.meas_mnemo  as  sMeas_Mnemo
                      ,case GROUP_PARAM when 0 then st.PROD_NUMB else '' end  as  sPROD_NUMB
                  from UDO_TMP_STICKER st                     
                      ,FACEACC         fc
                      ,NOMMODIF        nm
                      ,DICNOMNS        dn
                      ,DICMUNTS        ms
                 where fc.rn (+)= st.faceacc
                   and nm.rn = st.nom_modif
                   and dn.rn = nm.prn    
                   and ms.rn (+) = dn.UMEAS_MAIN 
                   group by  st.check_date
                            ,st.prod_date  
                            ,st.PROD_DOC    
                            ,st.store_zone  
                            ,st.sernumb    
                            ,st.TITLE      
                            ,fc.numb         
                            ,dn.nomen_name 
                            ,NM.MODIF_NAME 
                            ,ms.meas_mnemo
                            ,case GROUP_PARAM when 0 then st.PROD_NUMB else '' end                
                   order by st.TITLE, dn.nomen_name
                )
    loop  
      if nParam = 1 then
        sSTORE_ZONE  := STORE_ZONE(prn.nSTORE_ZONE);
        prn.sFACEACC := null;
      else  
        prn.sFACEACC := /*prn.sFACEACC||CR||*/ prn.PROD_DOC;
      end if;
      if GROUP_PARAM = 0 then
        if prn.sPROD_NUMB is not null then 
          prn.sTITLE := prn.sTITLE || ' (зав.№' || prn.sPROD_NUMB || ')';
        end if;
      end if; 
        
      if instr(prn.sMODIF_CODE, 'ГОСТ') > 0 then 
        sTMP := substr(prn.sMODIF_CODE, instr(prn.sMODIF_CODE, 'ГОСТ'));
      elsif instr(prn.sMODIF_CODE, 'ОСТ') > 0 then 
        sTMP := substr(prn.sMODIF_CODE, instr(prn.sMODIF_CODE, 'ОСТ'));
      elsif instr(prn.sMODIF_CODE, 'ТУ') > 0 then 
        sTMP := substr(prn.sMODIF_CODE, instr(prn.sMODIF_CODE, 'ТУ'));
      else  
        sTMP := null;
      end if;
    
      if 1 = MOD(npp, 2) then
        nSTR1 := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);
        nSTR2 := PRSG_EXCEL.LINE_CONTINUE(LL_NAME);
        nSTR3 := PRSG_EXCEL.LINE_CONTINUE(LL_GOST);
        nSTR4 := PRSG_EXCEL.LINE_CONTINUE(LL_KOL);
        nSTR5 := PRSG_EXCEL.LINE_CONTINUE(LL_SHIFR);
        nSTR6 := PRSG_EXCEL.LINE_CONTINUE(LL_NOMEN);
        nSTR7 := PRSG_EXCEL.LINE_CONTINUE(LL_DATE);
        nSTR8 := PRSG_EXCEL.LINE_CONTINUE(LL_PROV);

        if nParam = 1 then
          PRSG_EXCEL.CELL_VALUE_WRITE(С_STop1,   0, nSTR1, 'Изделие');
          PRSG_EXCEL.CELL_VALUE_WRITE(С_STop2,   0, nSTR1, 'Изделие');
          PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum1,   0, nSTR5, 'Номер заказа');
          PRSG_EXCEL.CELL_VALUE_WRITE(С_SNum2,   0, nSTR5, 'Номер заказа');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria1, 0, nSTR6, 'Серия, мест.хр.');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SSeria2, 0, nSTR6, 'Серия, мест.хр.');
        end if;

        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr1, 0, nSTR1, prn.sTITLE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName1,  0, nSTR2, prn.sNOMEN_NAME);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost1,  0, nSTR3, sTMP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol1,   0, nSTR4, print_numb(prn.quant) || ' '||prn.sMeas_Mnemo);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr1, 0, nSTR5, prn.sFACEACC/*||CR|| prn.PROD_DOC*/);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen1, 0, nSTR6, prn.sernumb||sSTORE_ZONE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate1,  0, nSTR7, prn.PROD_DATE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv1, 0, nSTR8, prn.check_date);
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SContr2, 0, nSTR1, prn.sTITLE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SName2,  0, nSTR2, prn.sNOMEN_NAME);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SGost2,  0, nSTR3, sTMP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SKol2,   0, nSTR4, print_numb(prn.quant) ||' '||prn.sMeas_Mnemo);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SShifr2, 0, nSTR5, prn.sFACEACC/*||CR|| prn.PROD_DOC*/);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SNomen2, 0, nSTR6, prn.sernumb||sSTORE_ZONE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDate2,  0, nSTR7, prn.PROD_DATE );
        PRSG_EXCEL.CELL_VALUE_WRITE(C_SDProv2, 0, nSTR8, prn.check_date);

        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);      
        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP); 
        /* Подгоняем до целого листа */ 
        if 0 = MOD(npp, 10) then    
          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_GAP);  
        end if;
      end if;
      npp := npp +1;
    end loop;

  end Print_stiker;
  
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
  
  nPP := 1;

  /* Подготовим данные */
  if sUNITCODE in ('IncomingOrders', 'IncomingOrdersSpecs') then
    for rec in(
      select spec.NOMMODIF,
             spec.planquant,
             spec.factquant,
             inv.faceacc,
             spec.sernumb,
           --  spec.pricemeas,
             ag.agnname,
             UDO_F_INORDERS_DEPORD_NUMB(inv.RN) as sPROD_DOC,
             to_number(null) as STORE_ZONE,
             udo_f_get_doc_prop_val(NDOC => spec.RN, SPROP => 'Дата производства') as dDate,
             f_docs_props_get_str_value(nproperty => 134301298, sunitcode => 'IncomingOrdersSpecs', ndocument => spec.RN) as sIFDS
             
        from INORDERS inv, INORDERSPECS spec, NOMMODIF MD, DICNOMNS dn, AGNLIST ag
       where (   inv.RN  in (select SL.DOCUMENT from SELECTLIST SL where sUNITCODE = 'IncomingOrders' and SL.IDENT = nIdent)
              or spec.rn in (select SL.DOCUMENT from SELECTLIST SL where sUNITCODE = 'IncomingOrdersSpecs' and SL.IDENT = nIdent))
         and inv.company = nCompany
         and inv.rn = spec.prn
         and UPPER(TRIM(dn.nomen_name)) not like '%ДОСТАВКА%' 
         and UPPER(TRIM(dn.nomen_name)) not like 'ТАРА'
         and spec.NOMMODIF = MD.RN
         and DN.rn = MD.prn
         and ag.rn = inv.CONTRAGENT
      
    ) loop

      INSERT INTO UDO_TMP_STICKER (RN, NOM_MODIF, QUANT, FACEACC, SERNUMB, STORE_ZONE, TITLE, PROD_DOC, PROD_NUMB, PROD_DATE, CHECK_DATE)
      VALUES (nPP, rec.NOMMODIF, rec.factquant, rec.faceacc, rec.sernumb, rec.STORE_ZONE, rec.agnname, rec.sPROD_DOC, null, rec.dDate, rec.sIFDS);

      nPP := nPP + 1;
    end loop;
    
    Print_stiker(0, sUNITCODE, nJoint);  

  elsif sUNITCODE in ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs')  then

    for rec in(
      select nvl(VP.QUANT, ivs.quant)        as nQuant,
             ivs.nommodif   as NOMMODIF,
             GP.SERNUMB     as Sernumb,
             ivs.faceacc    as FACEACC,
             VP.cell        as STORE_ZONE,            
             UDO_F_TRINDEPTSPECS_PROVDATE(ivs.RN)     as sDate,
             UDO_F_TRANSINVDEPT_MAIN_PROD(ivs.PRN)    as sMAIN_PROD,
             UDO_F_TRANSINVDEPT_MAIN_NUMB(ivs.PRN)    as sPROD_NUMB,
             UDO_F_INVDEPT_DEPORD(ivs.PRN)            as sPROD_DOC,
             USR_PKG_GOODSPARTIES.GOODSPARTIES_GET_IIVS_IFDS_PRP(nRN         => GP.RN,
                                                                 nFLAGSMART  => 1,
                                                                 nDOCS_PROPS => 134301298) as sIFDS -- План.поверка. Дата         
        from NOMMODIF MD, DICNOMNS dn, GOODSPARTIES GP
           ,(select spec.RN
                   ,spec.NOMMODIF
                   ,spec.goodsparty
                   ,inv.rn          as PRN
                   ,inv.faceacc
                   ,spec.pricemeas
                   ,spec.quant
               from TRANSINVDEPT inv, TRANSINVDEPTSPECS spec 
              where inv.rn = spec.prn
                and inv.company = nCompany 
                and  inv.RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIdent and sUNITCODE = 'GoodsTransInvoicesToDepts')
               --  or  spec.RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIdent and sUNITCODE = 'GoodsTransInvoicesToDeptsSpecs'))
             union
             select spec.RN
                   ,spec.NOMMODIF
                   ,spec.goodsparty
                   ,inv.rn          as PRN
                   ,inv.faceacc
                   ,spec.pricemeas
                   ,spec.quant
              from TRANSINVDEPT inv, TRANSINVDEPTSPECS spec 
             where inv.rn = spec.prn
               and inv.company = nCompany 
               and spec.RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIdent and sUNITCODE = 'GoodsTransInvoicesToDeptsSpecs')

            )   ivs
          ,(select DLIN.IN_DOCUMENT,
                    VPL.cell,
                    VPL.QUANT 
              from STRPLRESJRNL VPL, DOCLINKS DLIN
             where VPL.res_type = 1
               and DLIN.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
               and DLIN.OUT_UNITCODE = 'StoragePlacesResJournal'
               and DLIN.OUT_DOCUMENT = VPL.RN) VP
         where ivs.NOMMODIF = MD.RN
           and DN.rn = MD.prn
           and Gp.rn = ivs.goodsparty
           and vp.IN_DOCUMENT (+) = ivs.RN
         
    ) loop  
--  p_exception(0,'err= 0');
      INSERT INTO UDO_TMP_STICKER (RN, NOM_MODIF, QUANT, FACEACC, SERNUMB, STORE_ZONE, TITLE, PROD_DOC, PROD_NUMB, PROD_DATE, CHECK_DATE)
      VALUES (nPP, rec.NOMMODIF, rec.nQuant, rec.faceacc, rec.sernumb, rec.STORE_ZONE, rec.sMAIN_PROD, rec.sPROD_DOC, rec.sprod_numb, rec.sDate, rec.sIFDS);

      nPP := nPP + 1;
    end loop;

    Print_stiker(1, sUNITCODE, nJoint);  

  elsif 'IncomingInvoices' = sUNITCODE then
      p_exception(0,'Печать этикеток возможна из соответствующего Приходного ордера или Расходных накладных на отпуск в подразделение!');
  elsif 'IncomingInvoicesSpecs' = sUNITCODE then
      p_exception(0,'Печать этикеток возможна из соответствующего Приходного ордера или Расходных накладных на отпуск в подразделение!');

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

end UDO_REP_ININVOICES_STICKER2;
/
