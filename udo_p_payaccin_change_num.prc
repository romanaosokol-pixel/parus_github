create or replace procedure UDO_P_PAYACCIN_CHANGE_NUM(
  nCOMPANY        in number,   -- Организация.
  sRazdel         in varchar2, -- Раздел Парус
  nIDENT          in number,   -- Идентификатор помеченных записей
  sPayPref        in varchar2, -- Новый Префикс счета
  sPayNum         in varchar2, -- Новый Номер счета
  sPasword        in varchar2, -- Пароль!!!
  bAll            in number    -- Всю цепочку документов
) is

  nOldRN        number;  -- RN обрабатываемого Входящего счета
  nPAYACC       PAYACCIN%rowtype;

procedure UPDATE_ROWS(nDirection in numeric,
                      nPayRN  in numeric, -- RN Счета!!!
                      nFAccRN in numeric,
                      sValid_Doctype in varchar2,
                      sValid_Docnumb in varchar2,
                      sValid_Docdate in varchar2)
as
begin
--p_exception(0, nOldPayRN  || '-' || nNewCntrRN || '-' || nNewSchet || '-' || nNewFAccRN);
/*  if 0 = nDirection then -- Меняем во Входящих счетах
    begin
    update PAYACCIN p 
       set \*p.supplier  = nvl(nNewCntrRN, p.supplier), 
           p.supplacc  = nvl(nNewSchet, p.supplacc),
           p.faceacc   = nvl(nNewFAccRN, p.faceacc),*\
           p.vdoc_type = nvl(sValid_Doctype, p.vdoc_type),
           p.vdoc_num  = nvl(sValid_Docnumb, p.vdoc_num),
           p.vdoc_date = nvl(sValid_Docdate, p.vdoc_date)
     where p.rn = nPayRN;
    end;
  else -- Меняем в Счетах на оплату
    begin
    update PAYACC p 
       set \*p.AGENT   = nvl(nNewCntrRN, p.AGENT),
           p.AGNACC  = nvl(nNewSchet, p.AGNACC),
           p.faceacc   = nvl(nNewFAccRN, p.faceacc),*\
           p.vdoc_type = nvl(sValid_Doctype, p.vdoc_type),
           p.vdoc_numb = nvl(sValid_Docnumb, p.vdoc_numb),
           p.vdoc_date = nvl(sValid_Docdate, p.vdoc_date)
     where p.rn = nPayRN;

    EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE DISABLE';
    update PAYNOTES p 
       set \*p.payer        = nvl(nNewCntrRN, p.payer),
           p.payer_agnacc = nvl(nNewSchet,  p.payer_agnacc),
           p.faceacc      = nvl(nNewFAccRN, p.faceacc),*\
           p.vdoc_type    = nvl(sValid_Doctype, p.vdoc_type),
           p.vdoc_numb    = nvl(sValid_Docnumb, p.vdoc_numb),
           p.vdoc_date    = nvl(sValid_Docdate, p.vdoc_date),
           p.tdoc_type    = nvl(sValid_Doctype, p.tdoc_type),
           p.tdoc_numb    = nvl(sValid_Docnumb, p.tdoc_numb), 
           p.tdoc_date    = nvl(sValid_Docdate, p.tdoc_date)
     where p.faceacc = nFAccRN;
    EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE ENABLE';
    end;
  end if;*/

  for rec in( -- Сюда войдем только если Входящие счета на оплату
      select L.OUT_DOCUMENT, L.OUT_UNITCODE
        from DOCLINKS L
        where L.IN_DOCUMENT = nPayRN
          and L.IN_UNITCODE = 'PaymentAccountsIn'
  ) loop  

    if 'PayNotes' = rec.out_unitcode then -- Журнал платежей
      begin
        EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE DISABLE';
        update PAYNOTES p 
           set /*p.payer        = nvl(nNewCntrRN, p.payer),
               p.payer_agnacc = nvl(nNewSchet,  p.payer_agnacc),
               p.faceacc      = nvl(nNewFAccRN, p.faceacc),*/
               p.vdoc_type    = nvl(sValid_Doctype, p.vdoc_type),
               p.vdoc_numb    = nvl(sValid_Docnumb, p.vdoc_numb), 
               p.vdoc_date    = nvl(sValid_Docdate, p.vdoc_date),
               p.tdoc_type    = nvl(sValid_Doctype, p.tdoc_type),
               p.tdoc_numb    = nvl(sValid_Docnumb, p.tdoc_numb), 
               p.tdoc_date    = nvl(sValid_Docdate, p.tdoc_date)
         where p.rn = rec.out_document;
         EXECUTE IMMEDIATE 'ALTER TRIGGER T_PAYNOTES_BUPDATE ENABLE';
      end;
    elsif 1 = bAll and 'IncomingInvoices' = rec.out_unitcode then -- Приходные накладные
      begin
        update ININVOICES inv 
           set /*inv.AGENT   = nvl(nNewCntrRN, inv.AGENT),
               inv.FACEACC = nvl(nNewFAccRN, inv.FACEACC),*/
               inv.valid_doctype = nvl(sValid_Doctype, inv.valid_doctype),
               inv.valid_docnumb = nvl(sValid_Docnumb, inv.valid_docnumb),
               inv.valid_docdate = nvl(sValid_Docdate, inv.valid_docdate)
         where inv.rn = rec.out_document;
      end;

      for sec in(
        select L.OUT_DOCUMENT, L.OUT_UNITCODE
          from DOCLINKS L
          where L.IN_DOCUMENT = rec.out_document
            and L.IN_UNITCODE = 'IncomingInvoices'
      ) loop
--p_exception(0,'1) ' || sec.out_document || ' - ' || sec.out_unitcode);

        if 1 = bAll and 'AccountFactInput' = sec.out_unitcode then -- Входящие Счета-Фактуры
--p_exception(0,'1.1) ' || sec.out_document || ' - ' || sec.out_unitcode);
          begin
            update DICACCFI inv 
               set /*inv.PR_CODE    = nvl(nNewCntrRN, inv.PR_CODE),
                   inv.PR_FACEACC = nvl(nNewFAccRN, inv.PR_FACEACC),*/
                   inv.base_type  = nvl(sValid_Doctype, inv.base_type),
                   inv.base_numb  = nvl(sValid_Docnumb, inv.base_numb),
                   inv.base_date  = nvl(sValid_Docdate, inv.base_date)
             where inv.rn = sec.out_document;
          end;
        elsif 1 = bAll and 'LiabilitiesNotes' = sec.out_unitcode then -- Журнале отгрузок
--p_exception(0,'1.2) ' || sec.out_document || ' - ' || sec.out_unitcode);
          begin
            update LIABILITYNOTES lia 
               set /*lia.AGENT   = nvl(nNewCntrRN, lia.AGENT),
                   lia.FACEACC = nvl(nNewFAccRN, lia.FACEACC),*/
                   lia.vdoc_type = nvl(sValid_Doctype, lia.vdoc_type),
                   lia.vdoc_numb = nvl(sValid_Docnumb, lia.vdoc_numb),
                   lia.vdoc_date = nvl(sValid_Docdate, lia.vdoc_date)
             where lia.rn = sec.out_document;
          end;

        elsif 1 = bAll and 'IncomingOrders' = sec.out_unitcode then -- Приходные ордера
--p_exception(0,'1.3) ' || sec.out_document || ' - ' || sec.out_unitcode);
          begin
            update INORDERS inv 
               set /*inv.CONTRAGENT  = nvl(nNewCntrRN, inv.CONTRAGENT),
                   inv.FACEACC     = nvl(nNewFAccRN, inv.FACEACC),*/
                   inv.confdoctype = nvl(sValid_Doctype, inv.confdoctype),
                   inv.confdocnumb = nvl(sValid_Docnumb, inv.confdocnumb),
                   inv.confdocdate = nvl(sValid_Docdate, inv.confdocdate)
             where inv.rn = sec.out_document;
          end;

/*          for thi in(
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
          end loop;*/

        end if;

      end loop;
    end if;

  end loop;

end;

------------------------- Начало
begin

  if 'PaymentAccountsIn' = sRazdel then
    if sPasword = '100209' then
--p_exception(0, trim(sPayPref)) || '-' ||length(trim(sPayNum)));
      if sPayPref is null or sPayNum is null then --trim(sPayPref) = 0 or length(trim(sPayNum)) = 0 then
--P_EXCEPTION(0, 'Счет: "' || nOldRN || '. Номер: ' || trim(sPayPref)||'-'||trim(sPayNum));
        for rec in (
          select pa.* 
            from PAYACCIN pa, 
                 selectlist sl 
           where sl.ident = nIDENT 
             and pa.company = nCOMPANY
             and pa.RN = sl.document
          ) loop
--P_EXCEPTION(0, 'Счет: "' || rec.RN || ' Faceacc: "' || rec.faceacc || '. Номер: ' || trim(rec.doc_pref)||'-'||trim(rec.doc_numb));
          UPDATE_ROWS(0, rec.RN, rec.faceacc, rec.doc_type, trim(rec.doc_pref)||'-'||trim(rec.doc_numb), rec.doc_date);
        end loop;
      else 

        begin
        select pa.* 
          into nPAYACC
          from PAYACCIN pa, selectlist sl 
         where sl.ident = nIDENT 
           and pa.company = nCOMPANY
           and pa.RN = sl.document;

        update PAYACCIN p 
           set p.doc_pref = strright(strtrim(sPayPref), 80), 
               p.doc_numb = strright(strtrim(sPayNum), 80)
         where p.rn = nPAYACC.rn;
        end;
--P_EXCEPTION(0, 'Счет: "' || nPAYACC.RN || ' Faceacc: "' || nPAYACC.faceacc || '. Номер: ' || trim(sPayPref)||'-'||trim(sPayNum));

        UPDATE_ROWS(0, nPAYACC.rn, nPAYACC.faceacc, nPAYACC.doc_type, trim(sPayPref)||'-'||trim(sPayNum), nPAYACC.Doc_Date);
      end if;
    else P_EXCEPTION(0, 'Неправильный пароль');
    end if;
  end if;
      
end UDO_P_PAYACCIN_CHANGE_NUM;
/

