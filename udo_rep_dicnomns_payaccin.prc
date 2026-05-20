create or replace procedure UDO_REP_DICNOMNS_PAYACCIN (
       nCOMPANY   in number,   -- Организация
       sRAZDEL    in varchar2, -- Раздел из которого запускается отчет
       nIDENT     in number,   -- Выбранная строка
       nIzd       in number,   -- Сколько изделий
       nAll       in number,   -- Вся иерархия ПС
       sType      in varchar2, -- Тип ПС
       nNum       in number,   -- Номер ПС
       nModif     in number    -- Модификация
) is
  C_SLIST1    constant PKG_STD.TSTRING := 'Лист1'; -- Лист
-- Шапка
  C_sIzdelie  constant PKG_STD.TSTRING := 'sIzd';
  C_nIzd      constant PKG_STD.TSTRING := 'nIzd';

  LL_GAP      constant PKG_STD.TSTRING := 'L_GAP';
  LL_LINE     constant PKG_STD.TSTRING := 'L_Line';
  C_nPP       constant PKG_STD.TSTRING := 'nPP';
  C_sName     constant PKG_STD.TSTRING := 'sName';
  C_nKol      constant PKG_STD.TSTRING := 'nKol';
  C_nPrice    constant PKG_STD.TSTRING := 'nPrice';
  C_nCost     constant PKG_STD.TSTRING := 'nCost';
  C_nCost_NDS constant PKG_STD.TSTRING := 'nCost_NDS';
  C_sPay      constant PKG_STD.TSTRING := 'sPay';
  C_dPay      constant PKG_STD.TSTRING := 'dPay';
  C_sPost     constant PKG_STD.TSTRING := 'sPost';
  C_nSrokLast constant PKG_STD.TSTRING := 'nSrokLast';
  C_nSrokMin  constant PKG_STD.TSTRING := 'nSrokMin';
  C_nSrokMax  constant PKG_STD.TSTRING := 'nSrokMax';

  nSTR        number;
  nRows       number := 0;
  --nDIC_RN     number;
  nProdRN     number;
  
  sIzdelie    DICNOMNS.NOMEN_NAME%type;
  sPurp       FCPRODCMP.Purpose%type;
  sPS         varchar2(32);
  nKol        number(17,4);
  nPrice      number(17,2);
  nCost       number(17,2);
  nCostNDS    number(17,2);
  sPay        varchar2(1024);
  dPay        varchar2(1024); --date;
  sPost       varchar2(1024);
  nSrokLast   number := 0;
  nSrokMin    number := 0;
  nSrokMax    number := 0;
  nTypePS     number := 9015570; -- ПС

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;
  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST1); -- Главная страница  -- Составные части
  -- Описываем имена ячеек в шапке
  PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie);
  PRSG_EXCEL.CELL_DESCRIBE(C_nIzd);
  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_GAP);
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sName);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nKol);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPrice);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nCost);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nCost_NDS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPay);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPay);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPost);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSrokLast);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSrokMin);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSrokMax);

  if 'Nomenclator' = sRAZDEL then
    if sType is not null then
      FIND_DOCTYPES_CODE(nCOMPANY  => nCOMPANY,
                       sDOCCODE  => sType,
                       sUNITCODE => null,
                       nSTYPE    => null,
                       nRN       => nTypePS);
    else nTypePS := 9015570;
    end if;                    
    if nTypePS is null then nTypePS := 9015570; end if;
--if utilizer = 'KHOK' then p_exception(0,'Раздел: ' || sRAZDEL || '; sType: ' || sType || '; nTypePS '|| nTypePS); end if;

    if nNum is null then
      begin
        select /*part.nomenclature,*/ part.name, part.rn, part.purpose, part.numb
          into /*nDIC_RN,*/ sIzdelie, nProdRN, sPurp, sPS
          from(select row_number() over(ORDER BY prod.frm_date desc) as nums,
                      mat.nomenclature, mat.name, prod.rn, prod.purpose, 'ПС '||trim(prod.numb) as numb
                 from SELECTLIST sl, 
                      FCMATRESOURCE mat, 
                      FCPRODCMP prod
         where sl.ident = nIDENT and sl.unitcode = sRAZDEL --and sl.authid = USER
           and mat.nomenclature = sl.document
           and prod.mtr_res = mat.rn
           and prod.category = 0 -- ПС
           and prod.status = 1   -- Производство
           and prod.doctype = nTypePS
           ) part where nums = 1;
      exception when NO_DATA_FOUND then
        p_exception(0, 'Производственный состав не найден.');
      end;
    else -- конкретный ПС
--if utilizer = 'KHOK' then p_exception(0, nNum||' - '||nTypePS); end if;
      begin
        select /*mat.nomenclature,*/ mat.name, prod.rn, prod.purpose, 'ПС '||trim(prod.numb) as numb
          into /*nDIC_RN,*/ sIzdelie, nProdRN, sPurp, sPS
          from SELECTLIST sl, 
               FCMATRESOURCE mat, 
               FCPRODCMP prod
         where sl.ident = nIDENT and sl.unitcode = sRAZDEL --and sl.authid = USER
           and mat.nomenclature = sl.document
           and prod.mtr_res    = mat.rn
           and (mat.nomen_modif = nModif or nModif is null)
           and prod.category   = 0 -- ПС
           and prod.status     = 1 -- Производство
           and trim(prod.numb) = to_char(nNum)
           and prod.doctype    = nTypePS;
      exception 
        when NO_DATA_FOUND then
          p_exception(0, 'Производственный состав '|| nNum || ' не найден для данного изделия.');
        when TOO_MANY_ROWS then
          p_exception(0, 'Несколько производственных составов для данной номенклатуры. Выберите нужную Модификацию.');
      end;
    end if;

--if utilizer = 'KHOK' then p_exception(0,'Раздел: ' || sRAZDEL || '; nProdRN: ' || nProdRN); end if;
    if instr(sIzdelie, '(000') > 0 then
         sIzdelie := SUBSTR(sIzdelie, 0, INSTR(sIzdelie, '(000')) || sPS || ': ' || sPurp || ')';
    else sIzdelie := trim(sIzdelie) || ' (' || sPS || ': ' || sPurp || ')';
    end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie, sIzdelie);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nIzd, nIzd);

  for sel in (
    select distinct mat.name, mat.nomen_modif, sum(sp.PROD_QUANT) nQuant
      from FCPRODCMPSP sp,
           FCMATRESOURCE mat
     where sp.COMPANY = UDO_REP_DICNOMNS_PAYACCIN.nCOMPANY 
       and sp.PRN = nProdRN  
       and mat.rn = sp.mtr_res
       and sp.sign_res = 1 -- Покупное
       and sp.quant > 0
       and (sp.hier_level = 2 or 1 = nAll)
     group by mat.name, mat.nomen_modif
     order by mat.name
  ) loop

    nRows := nRows + 1;
    if instr(sel.name, '(000') > 0 then
         sIzdelie := SUBSTR(sel.name, 0, INSTR(sel.name, '(000')-1);
    else sIzdelie := sel.name;
    end if;

--if nKol > 1 then p_exception(0,nProdRN); end if;
      nKol      := sel.nQuant * nIzd; --acc.nfactquant;
      nPrice    := 0;
      nCost     := 0;
      nCostNDS  := 0;
      sPay      := '';
      dPay      := '';
      sPost     := '';
      nSrokLast := 0;
      nSrokMin  := 0;
      nSrokMax  := 0;      

/*      for acc in ( -- если смотреть по фактическим поступлениям
        select vin.nprice_wo_nds, vin.nprice, vin.sPayaccNumb, vin.sagnname,
               vin.ndays_fact, vin.nDAYS_PLAN
          from UDO_V_INORDERSPECS_ACC vin 
         where vin.nMODIF = sel.nomen_modif
           and vin.nprice_wo_nds > 0
           and vin.sPayaccNumb is not null
          order by vin.dDOCDATE --desc
      ) loop

        nPrice    := acc.nprice_wo_nds; --nprice;
        nCost     := nKol*acc.nprice_wo_nds; --acc.nfactsum;
        nCostNDS  := nCost*acc.nprice/nullif(acc.nprice_wo_nds, 0); --nfactsumtax/nullif(acc.nfactsum, 0);
        sPay      := substr(acc.sPayaccNumb, 0, instr(acc.sPayaccNumb, 'от')-2); --sdocnumb;
        dPay      := substr(acc.sPayaccNumb, instr(acc.sPayaccNumb, 'от')+3);    --ddocdate;
        sPost     := acc.sagnname; --sagnabbr; --.
        nSrokLast := nvl(acc.ndays_fact, acc.ndays_plan);
        if nSrokMin = 0 or nSrokMin > nSrokLast then nSrokMin := nSrokLast; end if;
        if nSrokMax < nSrokLast then nSrokMax := nSrokLast; end if;

      end loop;*/

      for acc in ( /* просмотр от счетов, даже если еще нет поступления */
        select pay.doc_date, trim(pay.ext_numb) ext_numb, 
               spec.quant, spec.price, spec.summ, spec.summwithnds, ag.agnname,
               UDO_F_PAYACCINSP_INDATE(spec.rn) - pay.doc_date as nDAYS_PLAN,
              (select min(IO.INDOCDATE) -- старые счета с прямым переходом в ПО
                 from DOCLINKS     L,
                      INORDERSPECS IOS,
                      INORDERS     IO
                where L.IN_DOCUMENT = pay.RN
                  and L.IN_UNITCODE = 'PaymentAccountsIn'
                  and L.OUT_DOCUMENT = IO.RN
                  and IOS.NOMMODIF = spec.nommodif
                  and IOS.PRN = IO.RN)  as nDAYS_FACT1,
              (select min(IO.INDOCDATE) -- счета с переходом в ПО через ПН
                 from DOCLINKS     L1,
                      ININVOICESSPECS INVS,
                      DOCLINKS     L2,
                      INORDERSPECS IOS,
                      INORDERS     IO
                where L1.IN_DOCUMENT = pay.RN
                  and L1.IN_UNITCODE = 'PaymentAccountsIn'
                  and L1.OUT_DOCUMENT = INVS.PRN
                  and INVS.MODIF = spec.nommodif
                  and L2.IN_DOCUMENT = INVS.PRN
                  and L2.OUT_DOCUMENT = IO.RN
                  and IOS.NOMMODIF = spec.nommodif
                  and IOS.PRN = IO.RN)  as nDAYS_FACT2,
              (select min(PN.PAY_DATE) -- фактический платеж
                 from DOCLINKS     LP,
                      PAYNOTES     PN
                where LP.IN_DOCUMENT = pay.RN
                  and LP.IN_UNITCODE = 'PaymentAccountsIn'
                  and LP.OUT_DOCUMENT = PN.RN
                  and LP.OUT_UNITCODE = 'PayNotes'
                  and PN.SIGNPLAN = 0) as nDAYS_PAY
             --, UDO_F_INORDERSPECS_DAYS_FACT(nRN => T.RN) as nDAYS_FACT
          from PAYACCINSPEC spec,
               PAYACCIN pay,
               AGNLIST ag
         where spec.nommodif = sel.nomen_modif
           and pay.rn = spec.prn
           and ag.rn = pay.supplier
         order by pay.doc_date --desc
      ) loop

        if acc.quant <> 0  then
          nPrice  := acc.summ/acc.quant; --acc.price -- эта цена с НДС !!!;
        else
          nPrice  := 0;
        end if;
        nCost     := nPrice*nKol; -- nKol*acc.price; --acc.summ;
        nCostNDS  := nCost*acc.summwithnds/nullif(acc.summ, 0); --acc.summwithnds;
        sPay      := acc.ext_numb;
        dPay      := to_char(acc.doc_date, 'DD.MM.YYYY');
        sPost     := acc.agnname;
       /* if nvl(acc.ndays_fact1, acc.ndays_fact2) is null then
          nSrokLast := 0;
        els*/if nvl(acc.ndays_fact1, acc.ndays_fact2) > acc.ndays_pay then -- предоплата 
          nSrokLast := nvl(acc.ndays_fact1, acc.ndays_fact2) - acc.ndays_pay;
        elsif nvl(acc.ndays_fact1, acc.ndays_fact2) < acc.ndays_pay then -- постоплата
          nSrokLast := nvl(acc.ndays_fact1, acc.ndays_fact2) - acc.doc_date;
        end if;  
        if nSrokMin = 0 or nSrokMin > nSrokLast then nSrokMin := nSrokLast; end if;
        if nSrokMax < nSrokLast then nSrokMax := nSrokLast; end if;

      end loop;
      
      /* если не нашли проверим старые запасы Столярский Е. 22/04/2024 */
      if nPrice = 0 then
        for old in( 
          select isp.factquant  
                ,isp.factsumtax
                ,isp.factsum
                ,trim(ino.indocpref) as sDOC_PREF
                ,trim(ino.indocnumb) as sDOC_NUMB
                ,ino.indocdate       as dDOC_DATE
                ,trim(ino.invdocnumb) as sDOC_VNUMB
                ,ino.invdocdate       as dDOC_VDATE
          from INORDERS      ino
              ,INORDERSPECS  isp
          where ino.rn = isp.prn
            and isp.nommodif = sel.nomen_modif
            and not exists (select null from DOCLINKS dl, PAYACCIN pay 
                            where dl.in_unitcode in ('PaymentAccountsIn', 'IncomingInvoices') 
                              and dl.out_document = ino.rn ) 
           order by ino.indocdate  desc
        ) loop
          nPrice    := old.factsum/old.factquant; --acc.price -- эта цена с НДС !!!;
          nCost     := nPrice*nKol; -- nKol*acc.price; --acc.summ;
          nCostNDS  := nCost*old.factsumtax/nullif(old.factsum, 0); --acc.summwithnds;
          if old.sdoc_vnumb is not null then
            sPay    := old.sdoc_vnumb||' от '||to_char(old.dDOC_VDATE,'dd.mm.yyyy');
          else
            sPay    := 'ПО '||old.sDOC_PREF||'-'||old.sDOC_NUMB||' от '||to_char(old.dDOC_DATE,'dd.mm.yyyy');
          end if;
          dPay      := null;
          sPost     := 'Закупка до 08.2022';
          
          nSrokLast := null;
          nSrokMin  := null;
          nSrokMax  := null;
          exit;
       
        end loop;
      end if;

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,       0, nSTR, nRows);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sName,     0, nSTR, sIzdelie);
      if nKol > 0 then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nKol,      0, nSTR, nKol);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice,    0, nSTR, nPrice);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nCost,     0, nSTR, nCost);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nCost_NDS, 0, nSTR, nCostNDS);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPay,      0, nSTR, sPay);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_dPay,      0, nSTR, dPay);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPost,     0, nSTR, sPost);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nSrokLast, 0, nSTR, nSrokLast);
        if nSrokMin != 0 and nSrokMin < nSrokMax then
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSrokMin,  0, nSTR, nSrokMin);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nSrokMax,  0, nSTR, nSrokMax);
      end if;

  end loop;
  end if;
  --удаляем технические строки
  if nRows > 0 then  PRSG_EXCEL.LINE_DELETE(LL_LINE); end if;
  PRSG_EXCEL.LINE_DELETE(LL_GAP);
  
end UDO_REP_DICNOMNS_PAYACCIN;
/
