create or replace procedure UDO_PR_STAGES_ORDERS
(
  NCOMPANY           in number,   -- Организация
  sRazd              in varchar2, -- Раздел
  nIDENT             in number,    -- Отмеченные записи Договора/Этапа договора
  dStartDate         in date,
  dEndDate           in date
)
is
 ----Переменные отчета "Закупка по тематике". KHOK
 /* 15/11/2023 Столярский Е.З. Ускорил работу отчета.*/
  C_SLIST    constant PKG_STD.TSTRING := 'Sheet0'; -- Лист
  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
  C_nPP                constant PKG_STD.TSTRING := 'nPP';
  C_sNomen_NAME        constant PKG_STD.TSTRING := 'sNomen_NAME';
  C_nQUANT             constant PKG_STD.TSTRING := 'nQUANT';
  C_nQUANT_Spec        constant PKG_STD.TSTRING := 'nQUANT_Spec';
  C_nPrice             constant PKG_STD.TSTRING := 'nPrice';
  C_nSUMNDS            constant PKG_STD.TSTRING := 'nSUMNDS';
  C_nSUMWITHNDS        constant PKG_STD.TSTRING := 'nSUMWITHNDS';
  C_nSUM_Spec          constant PKG_STD.TSTRING := 'nSUM_Spec';
  C_sAGENT             constant PKG_STD.TSTRING := 'sAGENT';
  C_sPAY_NUMB          constant PKG_STD.TSTRING := 'sPAY_NUMB';
  C_dPAY_DATE          constant PKG_STD.TSTRING := 'dPAY_DATE';
  C_sWork_n            constant PKG_STD.TSTRING := 'sWork_n';
  C_sZayav             constant PKG_STD.TSTRING := 'sZayav';

  C_dPay_Sum           constant PKG_STD.TSTRING := 'dPAY_SUM';
  C_dReal_Pay          constant PKG_STD.TSTRING := 'dREAL_PAY';
  C_nDelivery          constant PKG_STD.TSTRING := 'nDelivery';  
  C_dGet_Day           constant PKG_STD.TSTRING := 'dGET_DAY';
  C_sPlace             constant PKG_STD.TSTRING := 'sPlace';

  C_sWORK_NUMB         constant PKG_STD.TSTRING := 'sWORK_NUMB';
  C_sDate              constant PKG_STD.TSTRING := 'S_Date';
  C_sInDocs            constant PKG_STD.TSTRING := 'sInDocs';
  
  nSTR        number;
  nPP         number := 0;
  nConRN      number := 0;
  nFaceaccust number;
  sUslName    varchar2(256) := '';
  sBuhNum     varchar2(256) := '';
  sBuhNumPrj  varchar2(256) := '';
  sInDocs     pkg_std.tstring; 

procedure PRINT_ROWS(usl_name in varchar2, 
                    st_buhnum in varchar2, 
                  prst_buhnum in varchar2
/*                      ,faceacc in varchar2,
                  prj_faceacc in varchar2,
                       sShifr in varchar2,*/
                       )
as
  dRealDate   date;
  --sRealDate   pkg_std.tstring; 
  dRealPay    date;
  nPaySum     number(17,2) := 0;
  sSerNumb    ININVOICESSPECS.SERNUMB%type;
  nModif      ININVOICESSPECS.MODIF%type;
  sPlace varchar2(4000);
begin
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sWORK_NUMB, 'Тема: ' || usl_name);
  /* 15/11/2023 изменил последовательность запуска */
  for cost in(
    select distinct l.*, fc.numb as sCOST_FC from IDLIST L, FACEACC fc where fc.rn = L.id order by fc.numb
  ) loop
    for prn in (select pa.ext_numb
                      ,pa.rn        pa_rn
                      ,pa.reg_date
                      ,dn.nomen_name
                      ,nm.modif_name
                      --,nm.rn modif_rn
                      ,(select pc.quant_fact from PAYACCINSPCLC pc where pc.prn = ps.rn and pc.faceaccount = cost.id) as  Quant_fact
                      ,ag.agnname
                      ,ps.summ
                      ,ps.summwithnds
                      ,ps.summ_nds
                      ,ps.quant
                      ,ps.nommodif
                      --,UDO_F_PAYACCINSPEC_DOGNUMB(ps.rn) S7577545
                      ,F_DOCS_PROPS_GET_NUM_VALUE(
                          nPROPERTY    =>  7551156,                 -- регистрационный номер записи свойства
                          sUNITCODE    => 'PaymentAccountsInSpecs', -- код раздела документа
                          nDOCUMENT    =>  ps.rn                    -- регистрационный номер записи документа   
                          ) nDays
                      ,dn.nomen_type    
                      ,UDO_F_PAYACCINSP_EXT_DEPORD(ps.rn) as sZayav
                from PAYACCIN      pa
                    ,PAYACCINSPEC  ps
                   -- ,PAYACCINSPCLC pc
                    ,DICNOMNS      dn
                    ,NOMMODIF      nm
                    ,AGNLIST       ag
                where pa.rn = ps.prn
               --   and ps.rn = pc.prn
                  and exists (select 1 from PAYACCINSPCLC pc where pc.faceaccount = cost.id and pc.prn = ps.rn)/*L.HID = nConRN*/
                  --and (UDO_F_PAYACCINSPEC_DOGNUMB(ps.rn) = sShifr or upper(UDO_F_PAYACCIN_TEMA(pa.rn)) = upper(usl_name))
                  --and upper(UDO_F_FACEACC_GET_SHEFR(pa.rn)) = sShifr ???
                  and dn.rn = ps.nomen
                  and nm.rn (+)= ps.nommodif 
                  --and nm.prn (+)= dn.rn
                  and ag.rn = pa.supplier
                  and pa.doc_state != 2 -- не Аннулирован
                order by pa.ext_numb,  pa.doc_date, ag.agnname, dn.nomen_name, nm.modif_name--.reg_date
     ) loop
      nPaySum := 0;
      nPP := nPP + 1;    
      if prn.nomen_type = 2 then
        if  prn.quant_fact  >  prn.quant then prn.quant_fact := prn.quant; end if;
      end if; 

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,         0, nSTR, nPP);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomen_NAME, 0, nSTR, prn.nomen_name);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nQUANT,      0, nSTR, prn.quant_fact);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice,      0, nSTR, case prn.quant when 0 then 0 else prn.summ / prn.quant end );
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMNDS,     0, nSTR, case prn.quant when 0 then 0 else prn.summ_nds * prn.quant_fact / prn.quant end );
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMWITHNDS, 0, nSTR, case prn.quant when 0 then 0 else prn.summwithnds * prn.quant_fact / prn.quant end );
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nQUANT_Spec, 0, nSTR, prn.quant);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_Spec,   0, nSTR, prn.summwithnds);
      if length(cost.sCOST_FC) > 0 then
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, cost.sCOST_FC);
      elsif length(prst_buhnum) > 0 then 
           PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, prst_buhnum);
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, st_buhnum);
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sZayav,      0, nSTR, prn.sZayav);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,      0, nSTR, trim(prn.agnname));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_NUMB,   0, nSTR, trim(prn.ext_numb));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE,   0, nSTR, prn.reg_date);

/*      begin
      select inv.doc_date, sp.sernumb, sp.modif\*, sp.summtax*\, inv.ext_numb
        into dRealDate, sSerNumb, nModif\*, nPaySum*\, sInDocs
        from ININVOICES inv,
             ININVOICESSPECS sp
       where inv.RN in (select dl.out_document from DOCLINKS dl where dl.in_document = prn.pa_rn and dl.in_unitcode='PaymentAccountsIn' and dl.out_unitcode='IncomingInvoices')
         and sp.prn = inv.rn
         and sp.modif = prn.nommodif
         and rownum = 1
       order by inv.doc_date;
      exception
        when NO_DATA_FOUND then dRealDate := null; sSerNumb := null; nModif := 0; sInDocs := null;
      end;*/

      begin
      select inv.doc_date, sp.sernumb, sp.modif
        into dRealDate, sSerNumb, nModif
        from ININVOICES inv,
             ININVOICESSPECS sp
       where inv.RN in (select dl.out_document from DOCLINKS dl where dl.in_document = prn.pa_rn and dl.in_unitcode='PaymentAccountsIn' and dl.out_unitcode='IncomingInvoices')
         and sp.prn = inv.rn
         and sp.modif = prn.nommodif
         and rownum = 1
       order by inv.doc_date;
      exception
        when NO_DATA_FOUND then dRealDate := null; sSerNumb := null; nModif := 0;
      end;

      if dRealDate is null then -- вариант 1С, когда из счета сразу приходный ордер
        begin
        select inv.indocdate, sp.sernumb, sp.nommodif
          into dRealDate, sSerNumb, nModif
          from INORDERS inv,
               INORDERSPECS  sp
         where inv.RN in (select dl.out_document from DOCLINKS dl where dl.in_document = prn.pa_rn and dl.in_unitcode='PaymentAccountsIn' and dl.out_unitcode='IncomingOrders')
           and sp.prn = inv.rn
           and sp.nommodif = prn.nommodif
           and rownum = 1
         order by inv.indocdate;
        exception
          when NO_DATA_FOUND then dRealDate := null; sSerNumb := null; nModif := 0;
        end;
      end if;

      sInDocs := null;
      for c in (
                 select distinct inv.ext_numb || decode(inv.ext_date, null, null, ' от ') || to_char(inv.ext_date, 'DD.MM.YY') as sDet
                   from ININVOICES inv,
                        ININVOICESSPECS sp
                  where inv.RN in (select dl.out_document from DOCLINKS dl where dl.in_document = prn.pa_rn and dl.in_unitcode='PaymentAccountsIn' and dl.out_unitcode='IncomingInvoices')
                    and sp.prn = inv.rn
                    and sp.modif = prn.nommodif
               ) 
      loop
        sInDocs := strcombine(sInDocs, c.sDet, '; ');
      end loop;               

    /*  if dRealDate is null then*/
        begin
        select min(M.pay_date), sum(M.pay_sum) 
          into dRealPay, nPaySum --M.*--, UDO_F_PAYNOTES_ARTICLE(NRN) S6431513, UDO_F_PAYNOTES_FACT_BY_PLAN(NRN) N6858508 
          from PAYNOTES M 
         where M.COMPANY = NCOMPANY and M.signplan = 0 
           and m.pay_date between nvl(dStartDate, m.pay_date) and nvl(dEndDate, m.pay_date)
           and M.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT = prn.pa_rn and SIN_UNITCODE='PaymentAccountsIn' and SUNITCODE='PayNotes');
        exception
          when NO_DATA_FOUND then dRealPay := null; nPaySum := 0;
        end;
   /*   else -- Есть Приходная накладная*/
        begin
        select LISTAGG(trim(AZ.AZS_NAME || ' ' || UDO_F_STPLGOODSSUPPLY_CELLS(NCOMPANY, SUP.RN)) || ': ' || SUP.RESTFACT || ' (' || to_char(I.ENTRY_DATE, 'DD.MM.YYYY') || ')', '; ') 
               WITHIN GROUP (ORDER BY AZ.AZS_NAME) 
          into sPlace 
          from GOODSPARTIES GP,
               GOODSSUPPLY  SUP,
               INCOMDOC     I,
               AZSAZSLISTMT AZ
          where GP.NOMMODIF = nModif and GP.SERNUMB = sSerNumb
            and SUP.PRN  = GP.RN
            and GP.INDOC = I.RN
            and AZ.RN    = SUP.STORE
            and SUP.RESTFACT > 0;
        exception
          when NO_DATA_FOUND then sPlace := null;
        end;
        /* Есть Расходная накладная в производство */
        if sPlace is null then
          begin
          select sEVENT_STAT
            into sPlace 
            from GOODSPARTIES      GP,
                 TRANSINVDEPTSPECS SP,
                 TRANSINVDEPT      dept,
                 V_CLNEVENTS_STATMOD ev
            where GP.NOMMODIF = nModif and GP.SERNUMB = sSerNumb
              and SP.NOMMODIF = GP.NOMMODIF 
              and SP.GOODSPARTY = GP.RN
              and dept.rn = SP.PRN
              and dept.doctype = 17575789 -- РасхСписан
              --and dept.sheepview in (17575674, 503003) /* ПередПроизводство, ВыпРабИсп */
              and ev.sLINKED_UNIT = 'GoodsTransInvoicesToDepts' and ev.nLINKED_RN = dept.RN
              and rownum < 2;
          exception
            when NO_DATA_FOUND then sPlace := null;
          end;
        end if;
    /*  end if;*/

      PRSG_EXCEL.CELL_VALUE_WRITE(C_dPay_Sum,   0, nSTR, nPaySum); -- Сумма из спецификации Приходной накладной
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dReal_Pay,  0, nSTR, dRealPay);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nDelivery,  0, nSTR, prn.ndays);

      if dRealDate is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dGet_Day, 0, nSTR, dRealDate);
      elsif dRealPay is not null and prn.nomen_type != 2 then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dGet_Day, 0, nSTR, to_char(dRealPay+prn.ndays, 'DD.MM.YYYY')||'(!)');
      elsif prn.nomen_type = 2 then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dGet_Day, 0, nSTR, '-');
      end if;

      if sInDocs is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sInDocs, 0, nSTR, sInDocs);
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlace, 0, nSTR, sPlace);

    end loop;   
  end loop;

end;

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;
  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);
  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sWORK_NUMB);
  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNomen_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nQUANT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPrice);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUMNDS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nQUANT_Spec);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUMWITHNDS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUM_Spec);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPAY_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPAY_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sWork_n); -- Тема
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sZayav); -- Заявка

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPay_Sum);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dReal_Pay);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nDelivery);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dGet_Day);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPlace);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sInDocs);
  
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));
  delete from IDLIST ls /*where ls.hid = nConRN*/;

if 'Contracts' = sRazd then -- Из договора
   for sel in(
    select con.rn  as nConRN, 
           UDO_F_GET_USL_NAME(con.rn) as sUslName, 
           udo_f_get_doc_prop_val(NDOC => con.rn, SPROP => 'Шифр_поБУ') as sBuhNum,
--(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Contracts' and UNIT_RN = con.rn)
           pst.faceacc as fa_rn
   --   into nConRN, sUslName, sBuhNum, 
      from CONTRACTS con
          ,STAGES    st
          ,PROJECTSTAGE pst
     where con.rn in (select sl.document from SELECTLIST sl where sl.ident = nIDENT and sl.unitcode = sRazd and sl.company = NCOMPANY)
       and con.rn = st.prn
       and st.faceacc = pst.faceacccust
   
/*
    delete from IDLIST ls where ls.hid = nConRN;

    for sel in(
      select fa.rn fa_rn--, st.faceacc, 
       from STAGES st 
         , faceacc fa
       where st.prn = nConRN
       and fa.numb in (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12047550 and UNITCODE = 'ContractsStages' and UNIT_RN = st.RN) --nConRN
      union all
      select distinct st1.faceacc fa_rn 
        from (
          select st.prn
            from PROJECTSTAGE st, FACEACC fa
           where st.faceacc = fa.rn
             and st.faceacccust in (select st.faceacc from STAGES st where st.prn = nConRN)
          ) ds,
          PROJECTSTAGE st1
        where ds.prn = st1.prn*/
    ) loop
    
      insert into IDLIST ( ID, HID ) values ( sel.fa_rn /*faceacc*/, sel.nConRN );
      nConRN   := sel.nConRN;
      sUslName := sel.sUslName;
      sBuhNum  := sel.sBuhNum; 

    end loop;

    PRINT_ROWS(sUslName, sBuhNum, '' /*, null, null, null*/);

elsif 'ContractsStages' = sRazd then -- Из этапов
    for sel in(
      select st.prn, 
             prs.faceacc as  fa_rn, 
             UDO_F_GET_USL_NAME(st.prn) usl_name,
             udo_f_stages_buhnum(st.rn) st_buhnum,
             udo_f_projectstage_buhnum(prs.rn) prst_buhnum
             --,(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12047550 and UNITCODE = 'ContractsStages' and UNIT_RN = st.RN) sShifr
      from STAGES st,
           PROJECTSTAGE prs        
     where st.rn in (select sl.document from SELECTLIST sl where sl.ident = nIDENT and sl.company = NCOMPANY and sl.unitcode = sRazd) 
       and prs.faceacccust (+) = st.faceacc      
       
     --  and fa.numb in (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12047550 and UNITCODE = 'ContractsStages' and UNIT_RN = st.RN) --nConRN
/*      union all
      select ds.prn, st1.faceacc fa_rn,
             pr.NAME_USL usl_name,
             ds.st_buhnum,
             udo_f_get_doc_prop_val(NDOC => pr.RN, SPROP => 'Шифр_поБУ') prst_buhnum
--select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Projects' and UNIT_RN = pr.RN) prst_buhnum
        from (
          select st.prn, udo_f_stages_buhnum(st.rn) st_buhnum
            from PROJECTSTAGE st, FACEACC fa
           where st.faceacc = fa.rn
             and st.faceacccust in (
                 select st.faceacc 
                   from SELECTLIST sl, STAGES st 
                  where sl.ident = nIDENT
                    and sl.document = st.rn)
          ) ds,
          PROJECTSTAGE st1,
          PROJECT pr
        where ds.prn = st1.prn
          and pr.rn = st1.prn
--     order by st.prn, st.faceacc*/
    ) loop
      nConRN     := sel.prn; 
      sUslName   := sel.usl_name; 
      sBuhNum    := sel.st_buhnum;
      sBuhNumPrj := sel.prst_buhnum;
      if sel.fa_rn is null then
        P_exception(0,' У этапа договора не определен этап проекта, нет ШПЗ.');
      end if;

      insert into IDLIST ( ID, HID ) values ( sel.fa_rn /*faceacc*/, nConRN );

    end loop;

    PRINT_ROWS(sUslName, SUBSTR(sBuhNum, 0, INSTR(sBuhNum, '-')-1), sBuhNumPrj /*, ss.st_faceacc, ss.prs_faceacc, sel.sShifr*/);

elsif 'Projects' = sRazd then -- Из проектов
   for sel in(
    select con.rn        as nConRN, 
           pr.NAME_USL   as sUslName, 
           udo_f_get_doc_prop_val(NDOC => pr.rn, SPROP => 'Шифр_поБУ') as sBuhNum,
--(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Contracts' and UNIT_RN = con.rn)
           pst.faceacc as fa_rn
   --   into nConRN, sUslName, sBuhNum, 
      from CONTRACTS con
          ,STAGES    st
          ,PROJECTSTAGE pst
          ,PROJECT      pr
     where pr.rn in (select sl.document from SELECTLIST sl where sl.ident = nIDENT and sl.unitcode = sRazd and sl.company = NCOMPANY)
       and pr.rn = pst.prn
       and con.rn (+) = st.prn
       and st.faceacc (+) = pst.faceacccust
    ) loop
    
      insert into IDLIST ( ID, HID ) values ( sel.fa_rn /*faceacc*/, nvl(sel.nConRN,0) );
      nConRN   := sel.nConRN;
      sUslName := sel.sUslName;
      sBuhNum  := sel.sBuhNum; 

    end loop;

    PRINT_ROWS(sUslName, sBuhNum, '' /*, null, null, null*/);
    
elsif 'ProjectsStages' = sRazd then -- Из этапов проектов
   for sel in(
    select con.rn        as nConRN, 
           pr.NAME_USL   as sUslName, 
           udo_f_get_doc_prop_val(NDOC => pr.rn, SPROP => 'Шифр_поБУ') as sBuhNum,
--(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Contracts' and UNIT_RN = con.rn)
           pst.faceacc as fa_rn
   --   into nConRN, sUslName, sBuhNum, 
      from CONTRACTS con
          ,STAGES    st
          ,PROJECTSTAGE pst
          ,PROJECT      pr
     where pst.rn in (select sl.document from SELECTLIST sl where sl.ident = nIDENT and sl.unitcode = sRazd and sl.company = NCOMPANY)
       and pr.rn = pst.prn
       and con.rn (+) = st.prn
       and st.faceacc (+) = pst.faceacccust
    ) loop
    
      insert into IDLIST ( ID, HID ) values ( sel.fa_rn /*faceacc*/, nvl(sel.nConRN,0) );
      nConRN   := sel.nConRN;
      sUslName := sel.sUslName;
      sBuhNum  := sel.sBuhNum; 

    end loop;

    PRINT_ROWS(sUslName, sBuhNum, '' /*, null, null, null*/);
      
else -- Из Заказа Поздразделений (DepartmentsOrders)
    begin
    select distinct dep.rn, UDO_F_DEPARTMENTORD_SHEFR(DEP.FACEACC), FA.NUMB, PS.FACEACCCUST
      into nConRN, sUslName, sBuhNum, nFaceaccust
      from SELECTLIST sl,
           DEPARTMENTORD DEP
         , FACEACC       FA
         , PROJECTSTAGE  PS
     where sl.ident = nIDENT
       and sl.document = DEP.rn
       and DEP.company = NCOMPANY
       and FA.rn = DEP.faceacc
       and PS.Faceacc = FA.rn;
    exception
      when NO_DATA_FOUND then p_exception(0, 'Не найден этап проекта с таким ШПЗ.');
    end;

    delete from IDLIST ls where ls.hid = nConRN;
--p_exception(0,nConRN || '-' || sUslName || '-' || sBuhNum);


    for rec in (-- Все этапы договора по выбранной теме
      select t.faceacc 
        from STAGES t 
       where t.rn in(
             select distinct st1.rn 
               from (select st.rn, st.prn from STAGES st where st.faceacc = nFaceaccust) ds,
              STAGES st1
            where ds.prn = st1.prn)
    ) loop

        insert into IDLIST ( ID, HID ) values ( rec.faceacc, nConRN );

    end loop;

    for sel in( -- и лицевые счета по Проектам, если в этапах договора ШПЗ не указан
/*      select distinct st.faceacc\*cust*\ fa_rn
        from FACEACC fa, PROJECTSTAGE st
       where st.faceacc = fa.rn
         and fa.numb like substr(sBuhNum, 0, instr(sBuhNum, '/')-1)||'%'*/
      select distinct st1.faceacc fa_rn 
        from (
          select st.prn
            from PROJECTSTAGE st, FACEACC fa
           where st.faceacc = fa.rn
             and fa.numb = sBuhNum
          ) ds,
          PROJECTSTAGE st1
        where ds.prn = st1.prn
    ) loop
    
      insert into IDLIST ( ID, HID ) values ( sel.fa_rn, nConRN );

    end loop;

    PRINT_ROWS(sUslName, SUBSTR(sBuhNum, 0, INSTR(sBuhNum, '/')-1), '' /*, null, null, null*/);

end if;
  delete from IDLIST ls where ls.hid = nConRN;

  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_LINE);

end UDO_PR_STAGES_ORDERS;
/
