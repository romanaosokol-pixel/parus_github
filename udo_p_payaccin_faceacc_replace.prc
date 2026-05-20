create or replace procedure UDO_P_PAYACCIN_FACEACC_REPLACE(
  nCOMPANY        in number,  -- организация.
  sRazdel         in varchar2,-- Раздел Парус
  nOldRN          in number,  -- RN обрабатываемого Входящего счета
  sDogPref        in varchar2,-- Префикс договора
  sDogNum         in varchar2,-- Номер договора
  sNewCntr        in varchar2,-- Код строки нового Контрагента
  sNewFAcc        in varchar2,-- Код строки нового Лицевого счета
  sNewSchet       in varchar2,-- Код строки нового Расчетного счета
  sPayPref        in varchar2,-- Префикс счета
  sPayNum         in varchar2,-- Номер счета
  sPasword        in varchar2, -- пароль!!!
  bAll            in number   -- Всю цепочку документов
) is
-- Замена Контрагента и Лицевого Счета по цепочке от Входящего счета и далее
  nNewCntr    AGNLIST.RN%TYPE := 0;
  nNewFAcc    FACEACC.RN%TYPE := 0;
  nFACC       FACEACC%rowtype;
  nNewSchet   AGNACC.RN%TYPE  := 0;
  --nOUT_DOCUMENT PKG_STD.tREF;   

procedure UPDATE_CHILD(rec_out_unitcode in varchar2,
                      rec_out_document  in numeric, -- RN Счета!!!
                      nNewCntrRN in numeric,
                      nNewSchet  in numeric, 
                      nNewFAccRN in numeric,
                      sValid_Doctype in varchar2,
                      sValid_Docnumb in varchar2,
                      sValid_Docdate in varchar2)
as
begin
    if 'PayNotes' = rec_out_unitcode then -- Журнал платежей
      begin
        EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE DISABLE';
        update PAYNOTES p 
           set p.payer        = nvl(nNewCntrRN, p.payer),
               p.payer_agnacc = nvl(nNewSchet,  p.payer_agnacc),
               p.faceacc      = nvl(nNewFAccRN, p.faceacc),
               p.vdoc_type    = nvl(sValid_Doctype, p.vdoc_type),
               p.vdoc_numb    = nvl(sValid_Docnumb, p.vdoc_numb), 
               p.vdoc_date    = nvl(sValid_Docdate, p.vdoc_date),
               p.tdoc_type    = nvl(sValid_Doctype, p.tdoc_type),
               p.tdoc_numb    = nvl(sValid_Docnumb, p.tdoc_numb), 
               p.tdoc_date    = nvl(sValid_Docdate, p.tdoc_date)
         where p.rn = rec_out_document;
         EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE ENABLE';
      end;
    elsif 1 = bAll and 'IncomingInvoices' = rec_out_unitcode then -- Приходные накладные
--p_exception(0, rec_out_unitcode  || '. out_document: ' || rec_out_document);
      begin
        update ININVOICES inv 
           set inv.AGENT   = nvl(nNewCntrRN, inv.AGENT),
               inv.FACEACC = nvl(nNewFAccRN, inv.FACEACC),
               inv.valid_doctype = nvl(sValid_Doctype, inv.valid_doctype),
               inv.valid_docnumb = nvl(sValid_Docnumb, inv.valid_docnumb),
               inv.valid_docdate = nvl(sValid_Docdate, inv.valid_docdate)
         where inv.rn = rec_out_document;
      end;

      for sec in(
        select L.OUT_DOCUMENT, L.OUT_UNITCODE
          from DOCLINKS L
          where L.IN_DOCUMENT = rec_out_document
            and L.IN_UNITCODE = 'IncomingInvoices'
      ) loop
--p_exception(0,'1) ' || sec.out_document || ' - ' || sec.out_unitcode);

        if 1 = bAll and 'AccountFactInput' = sec.out_unitcode then -- Входящие Счета-Фактуры
--p_exception(0,'1.1) ' || sec.out_document || ' - ' || sec.out_unitcode);
          begin
            update DICACCFI inv 
               set inv.PR_CODE    = nvl(nNewCntrRN, inv.PR_CODE),
                   inv.PR_FACEACC = nvl(nNewFAccRN, inv.PR_FACEACC),
                   inv.base_type  = nvl(sValid_Doctype, inv.base_type),
                   inv.base_numb  = nvl(sValid_Docnumb, inv.base_numb),
                   inv.base_date  = nvl(sValid_Docdate, inv.base_date)
             where inv.rn = sec.out_document;
          end;
        elsif 1 = bAll and 'LiabilitiesNotes' = sec.out_unitcode then -- Журнале отгрузок
--p_exception(0,'1.2) ' || sec.out_document || ' - ' || sec.out_unitcode);
          begin
            update LIABILITYNOTES lia 
               set lia.AGENT   = nvl(nNewCntrRN, lia.AGENT),
                   lia.FACEACC = nvl(nNewFAccRN, lia.FACEACC),
                   lia.vdoc_type = nvl(sValid_Doctype, lia.vdoc_type),
                   lia.vdoc_numb = nvl(sValid_Docnumb, lia.vdoc_numb),
                   lia.vdoc_date = nvl(sValid_Docdate, lia.vdoc_date)
             where lia.rn = sec.out_document;
          end;

        elsif 1 = bAll and 'IncomingOrders' = sec.out_unitcode then -- Приходные ордера
--p_exception(0,'1.3) ' || sec.out_document || ' - ' || sec.out_unitcode);
          begin
            update INORDERS inv 
               set inv.CONTRAGENT  = nvl(nNewCntrRN, inv.CONTRAGENT),
                   inv.FACEACC     = nvl(nNewFAccRN, inv.FACEACC),
                   inv.confdoctype = nvl(sValid_Doctype, inv.confdoctype),
                   inv.confdocnumb = nvl(sValid_Docnumb, inv.confdocnumb),
                   inv.confdocdate = nvl(sValid_Docdate, inv.confdocdate)
             where inv.rn = sec.out_document;
          end;

          for thi in(
            select L.OUT_DOCUMENT, L.OUT_UNITCODE
              from DOCLINKS L
              where L.IN_DOCUMENT = sec.out_document
                and L.IN_UNITCODE = 'IncomingOrders'
          ) loop
--p_exception(0,'2) ' || thi.out_document || ' - ' || thi.out_unitcode);

            if 1 = bAll and 'StoreOpersJournal' = thi.out_unitcode then -- Журнал складских операций

              begin
                update STOREOPERJOURN inv 
                   set inv.FACEACC = nvl(nNewFAccRN, inv.FACEACC)
                 where inv.rn = thi.out_document;
              end;

              -- Партии: INCOMDOC.AGENT (INCOMDOC.CODE <- V_STOREOPERJOURN.SPARTY)
              for par in(
                select G.INDOC
                  from STOREOPERJOURN  SOJ, -- Журнал складских операций
                       GOODSSUPPLY     S,   -- Товарные запасы
                       GOODSPARTIES    G    -- Приходные партии товара
                where SOJ.RN = thi.out_document 
                  and SOJ.GOODSSUPPLY = S.RN
                  and S.PRN           = G.RN
              ) loop
  --p_exception(0,'2.1) ' || par.indoc || ' - ' || nNewCntrRN);
                begin
                  update INCOMDOC inc -- Поставщик партии
                     set inc.agent = nvl(nNewCntrRN, inc.agent)  -- 7147583 -> 43501287
                   where inc.rn = par.indoc;
                end;
              end loop;

            end if;

          end loop;

        end if;

      end loop;
    end if;

end; -- UPDATE_CHILD

procedure UPDATE_ROWS(nDirection in numeric,
                      nOldPayRN  in numeric, -- RN Счета!!!
                      nNewCntrRN in numeric,
                      nNewSchet  in numeric, 
                      nNewFAccRN in numeric,
                      sValid_Doctype in varchar2,
                      sValid_Docnumb in varchar2,
                      sValid_Docdate in varchar2)
as
begin
--p_exception(0, nOldPayRN  || '-' || nNewCntrRN || '-' || nNewSchet || '-' || nNewFAccRN);
  if 0 = nDirection then -- Меняем во Входящих счетах
    if 'PaymentAccountsIn' = sRazdel then
      begin
      update PAYACCIN p 
         set p.supplier  = nvl(nNewCntrRN, p.supplier), 
             p.supplacc  = nvl(nNewSchet, p.supplacc),
             p.faceacc   = nvl(nNewFAccRN, p.faceacc),
             p.vdoc_type = nvl(sValid_Doctype, p.vdoc_type),
             p.vdoc_num  = nvl(sValid_Docnumb, p.vdoc_num),
             p.vdoc_date = nvl(sValid_Docdate, p.vdoc_date)
       where p.rn = nOldPayRN;
      end;
    elsif 'DeliveryOrders' = sRazdel then 
--21125221-6001814-52059724-21129800
      begin
      update DELIVERYORD p 
         set p.faceacc = nvl(nNewFAccRN, p.faceacc),
             p.agent   = nvl(nNewCntrRN, p.agent)
       where p.rn = nOldPayRN;
      end;
    end if;
  else -- Меняем в Счетах на оплату
    begin
    update PAYACC p 
       set p.AGENT   = nvl(nNewCntrRN, p.AGENT),
           p.AGNACC  = nvl(nNewSchet, p.AGNACC),
           p.faceacc   = nvl(nNewFAccRN, p.faceacc),
           p.vdoc_type = nvl(sValid_Doctype, p.vdoc_type),
           p.vdoc_numb = nvl(sValid_Docnumb, p.vdoc_numb),
           p.vdoc_date = nvl(sValid_Docdate, p.vdoc_date)
     where p.rn = nOldPayRN;

    EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE DISABLE';
    update PAYNOTES p 
       set p.payer        = nvl(nNewCntrRN, p.payer),
           p.payer_agnacc = nvl(nNewSchet,  p.payer_agnacc),
           p.faceacc      = nvl(nNewFAccRN, p.faceacc),
           p.vdoc_type    = nvl(sValid_Doctype, p.vdoc_type),
           p.vdoc_numb    = nvl(sValid_Docnumb, p.vdoc_numb),
           p.vdoc_date    = nvl(sValid_Docdate, p.vdoc_date),
           p.tdoc_type    = nvl(sValid_Doctype, p.tdoc_type),
           p.tdoc_numb    = nvl(sValid_Docnumb, p.tdoc_numb), 
           p.tdoc_date    = nvl(sValid_Docdate, p.tdoc_date)
     where p.faceacc = nNewFAccRN;
    EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE ENABLE';
    end;
  end if;

  if 'PaymentAccountsIn' = sRazdel or 'Contracts' = sRazdel then
  for rec in( -- Сюда войдем только если были Входящие счета на оплату
      select L.OUT_DOCUMENT, L.OUT_UNITCODE
        from DOCLINKS L
        where L.IN_DOCUMENT = nOldPayRN
          and L.IN_UNITCODE = 'PaymentAccountsIn'
  ) loop  
    UPDATE_CHILD(rec.out_unitcode, rec.out_document, nNewCntrRN, nNewSchet, nNewFAccRN, 
                 sValid_Doctype, sValid_Docnumb, sValid_Docdate);
  end loop;
  else -- 'DeliveryOrders'
  for rec in(
      select L.OUT_DOCUMENT, L.OUT_UNITCODE
        from DOCLINKS L
        where L.IN_DOCUMENT = nOldPayRN/*
          and L.IN_UNITCODE = 'PaymentAccountsIn'*/
  ) loop
    UPDATE_CHILD(rec.out_unitcode, rec.out_document, nNewCntrRN, nNewSchet, nNewFAccRN, 
                 sValid_Doctype, sValid_Docnumb, sValid_Docdate);
  end loop;
  end if;

end; --UPDATE_ROWS

------------------------- Начало
begin
--p_exception(0, sRazdel || ': ' || nOldRN  || '. sNewFAcc: ' || sNewFAcc);

  begin -- Проверка входных данных и получение RN
    if sNewCntr is null then -- Контрагента не меняем
      if 'PaymentAccountsIn' = sRazdel then
           select t.SUPPLIER into nNewCntr from PAYACCIN  t where t.rn = nOldRN;
      elsif 'DeliveryOrders' = sRazdel then
           select t.AGENT    into nNewCntr from DELIVERYORD t where t.rn = nOldRN;
      else select t.AGENT    into nNewCntr from CONTRACTS t where t.rn = nOldRN;
      end if;
    else
      FIND_AGNLIST_CODE(nFLAG_SMART  => 0,
                        nFLAG_OPTION => 0,
                        nCOMPANY     => nCOMPANY,
                        sCODE        => sNewCntr,
                        nRN          => nNewCntr);
    end if;

    if nNewCntr is null or 0 = nNewCntr then
      P_EXCEPTION(0, 'Ошибка получения RN Контрагента!');
    end if;

    if 'PaymentAccountsIn' = sRazdel or sNewFAcc is not null then

      FIND_FACEACC_NUMB(nFLAG_SMART  => 0,
                        nFLAG_OPTION => 0,
                        nCOMPANY     => nCOMPANY,
                        sNUMB        => sNewFAcc,
                        nRN          => nNewFAcc);

      if nNewFAcc is null or 0 = nNewFAcc then
        P_EXCEPTION(0, 'Ошибка получения номера Лицевого счета!');
      end if;

      begin -- Проверка, что лицевой счет у нужного контрагента 
        select * into nFACC 
          from FACEACC 
         where RN = nNewFAcc and AGENT = nNewCntr
           and FACT_CLOSE_DATE is null /* and SIGN_CONTRACT = 0 and ORDER_SIGN = 0 */ ;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION(0, 'Ошибка!!! Лицевой счет "' || sNewFAcc || '" для выбранного контрагента ненайден или уже закрыт!');
      end;
      /* Если не смогли получить новые RN - выходим */
      if ( nOldRN is null or nNewCntr is null or nNewFAcc is null) then
        P_EXCEPTION(0, 'Ошибка!!! RN старого или нового Лицевого счета не задан.');
      end if;

    end if;

    if sNewSchet is not null then -- Проверка, что расчетный счет у нужного контрагента 
      begin
        select ag.RN into nNewSchet from AGNACC ag where ag.strcode = sNewSchet and ag.agnrn = nNewCntr;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION(0, 'Ошибка!!! Расчетный счет "' || sNewSchet || '" для выбранного контрагента ненайден!');
      end;
/*    else 
      select t.agnacc into nNewSchet from CONTRACTS t where t.rn = nOldRN;*/
    end if;

--P_EXCEPTION(0, 'Старый RN: '||nOldRN||'. Код нового: '||sNewCntr||'. RN нового: '||nNewCntrRN||'. Код л/с: '||sNewFAcc||'. RN л/с: '||nNewFAccRN);
  end;


  if 'PaymentAccountsIn' = sRazdel then -- Входящие счета на оплату
    if length(trim(sPayPref)) > 0 and length(trim(sPayNum)) > 0 then
      if sPasword = '100209' then
--P_EXCEPTION(0, 'Счет: "' || nOldRN || '. Номер: ' || trim(sPayPref)||'-'||trim(sPayNum));
        begin
          update PAYACCIN p 
             set p.doc_pref = strright(strtrim(sPayPref), 80), 
                 p.doc_numb = strright(strtrim(sPayNum), 80)
           where p.rn = nOldRN;
        end;
        -- ??? P_FACEACC_BASE_CORRECT_ACCOUNT ??? 
        UPDATE_ROWS(0, nOldRN, nNewCntr, nNewSchet, nNewFAcc, 
                nFACC.Valid_Doctype, trim(sPayPref)||'-'||trim(sPayNum), nFACC.Valid_Docdate);
      else
        P_EXCEPTION(0, 'Неправильный пароль');
      end if;
    else UPDATE_ROWS(0, nOldRN, nNewCntr, nNewSchet, nNewFAcc, 
                nFACC.Valid_Doctype, nFACC.Valid_Docnumb, nFACC.Valid_Docdate);
    end if;

  elsif 'DeliveryOrders' = sRazdel then -- Заказы поставщикам
      if sPasword = '100209' then
--P_EXCEPTION(0, 'Заказ: "' || nOldRN || '. Номер: ' || nFACC.Valid_Docnumb||' - '||nFACC.Valid_Docdate);
        UPDATE_ROWS(0, nOldRN, nNewCntr, nNewSchet, nNewFAcc, 
                nFACC.Valid_Doctype, nFACC.Valid_Docnumb, nFACC.Valid_Docdate);
      else
        P_EXCEPTION(0, 'Неправильный пароль');
      end if;

  elsif 'Contracts' = sRazdel then -- Договоры
    begin -- Получение и проверка данных
    if sDogPref is not null and sDogNum is not null then -- Меняем номер Договора
/*      begin
        select t.supplier into nNewCntrRN from CONTRACTS t where t.rn = nOldRN;
      end;*/
      begin
--p_exception(0, sDogPref || '-' || sDogNum || '. NewCntrRN: ' || nNewCntr || '. NewSchet: ' || nNewSchet );

        update CONTRACTS con -- Меняем договор
           set con.doc_pref = strright(strtrim(sDogPref), 80),
               con.doc_numb = strright(strtrim(sDogNum), 80),
               con.AGENT    = nNewCntr, 
               con.AGNACC   = nNewSchet
         where con.rn = nOldRN;

         for rec in ( -- Меняем лицевые счета этапов договора
           select st.faceacc, trim(sDogPref)||'-'||trim(sDogNum)|| ' Эт.' || trim(numb) sValidNum
                  --st.faceacc, st.numb 
             from STAGES st where st.prn = nOldRN
         ) loop
--p_exception(0, 'faceacc: ' || rec.faceacc || '; ' || rec.sValidNum);

           update FACEACC fc
              set fc.valid_docnumb = rec.sValidNum
            where fc.rn = rec.faceacc;
            
           select * into nFACC from FACEACC where RN = rec.faceacc;

           for sch in ( -- Меняем все Входящие счета по Лицевому счету
             select pa.rn from PAYACCIN pa where pa.faceacc = rec.faceacc
           ) loop
--p_exception(0, 'PAYACCIN: ' || sch.rn );
           
           UPDATE_ROWS(0, sch.rn, nNewCntr, nNewSchet, rec.faceacc, 
                       nFACC.Valid_Doctype, nFACC.Valid_Docnumb, nFACC.Valid_Docdate);
           end loop;

           for sch in ( -- Меняем все Cчета на оплату по Лицевому счету
             select pa.rn from PAYACC pa where pa.faceacc = rec.faceacc
           ) loop
--p_exception(0, 'PAYACC: ' || sch.rn );
           
           UPDATE_ROWS(1, sch.rn, nNewCntr, nNewSchet, rec.faceacc, 
                       nFACC.Valid_Doctype, nFACC.Valid_Docnumb, nFACC.Valid_Docdate);
           end loop;

         end loop;

      end;

    end if;
    end;

  end if;



end UDO_P_PAYACCIN_FACEACC_REPLACE;
/

