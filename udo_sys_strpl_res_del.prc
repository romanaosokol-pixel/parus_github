create or replace procedure UDO_SYS_STRPL_RES_DEL
(
  nIDENT   in number,
  nCOMPANY in number,
  sUNIT    in varchar2
) as
  /*
    Марков МВ.
    Временная процедура удаления распределения по местам хранения
  */
begin
  if utilizer not in ('CITK_MARKOV', 'KHOK') then
    p_exception(0, 'Errors. Not anougth privilegies.');
  end if;
  if sUNIT = 'GoodsTransInvoicesToDepts' then
    -- по отмеченным расходным накладным
    for doc in (select TDS.RN,
                       TD.DOCTYPE,
                       TD.PREF,
                       TD.NUMB,
                       TDS.NOMMODIF,
                       TDS.ARTICLE
                  from TRANSINVDEPT      TD,
                       TRANSINVDEPTSPECS TDS,
                       SELECTLIST        SL
                 where SL.IDENT = nIDENT
                   and SL.DOCUMENT = TD.RN
                   and TDS.PRN = TD.RN
                   and TD.COMPANY = nCOMPANY) loop
      -- удалим резерв
      for del in (select T.COMPANY,
                         T.RN
                    from STRPLRESJRNL t
                   where T.NOMMODIF = doc.nommodif
                     and cmp_num(T.Article, doc.article) = 1
                        --and T.RES_TYPE = nRES_TYPE
                     and T.DOCTYPE = doc.doctype
                     and T.DOCPREF = doc.pref
                     and T.DOCNUMB = doc.numb
                     and exists (select null
                            from DOCLINKS DL
                           where DL.OUT_DOCUMENT = t.rn
                             and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
                             and DL.IN_DOCUMENT = doc.rn
                             and DL.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')) loop
        P_STRPLRESJRNL_BASE_DELETE(nCOMPANY => del.company, nRN => del.rn);
      end loop;
    end loop;
  end if;
  --
  if sUNIT = 'IncomingOrders' then
    -- по отмеченным приходным ордерам
    for doc in (select IOS.RN,
                       IO.INDOCTYPE as DOCTYPE,
                       IO.INDOCPREF as PREF,
                       IO.INDOCNUMB as NUMB,
                       IOS.NOMMODIF,
                       IOS.ARTICLE
                  from INORDERS     IO,
                       INORDERSPECS IOS,
                       SELECTLIST   SL
                 where SL.IDENT = nIDENT
                   and SL.DOCUMENT = IO.RN
                   and IOS.PRN = IO.RN
                   and IO.COMPANY = nCOMPANY) loop
      -- удалим резерв
      for del in (select T.COMPANY,
                         T.RN
                    from STRPLRESJRNL t
                   where T.NOMMODIF = doc.nommodif
                     and cmp_num(T.Article, doc.article) = 1
                        --and T.RES_TYPE = nRES_TYPE
                     and T.DOCTYPE = doc.doctype
                     and T.DOCPREF = doc.pref
                     and T.DOCNUMB = doc.numb
                     and exists (select null
                            from DOCLINKS DL
                           where DL.OUT_DOCUMENT = t.rn
                             and DL.OUT_UNITCODE = 'StoragePlacesResJournal'
                             and DL.IN_DOCUMENT = doc.rn
                             and DL.IN_UNITCODE = 'IncomingOrdersSpecs')) loop
        P_STRPLRESJRNL_BASE_DELETE(nCOMPANY => del.company, nRN => del.rn);
      end loop;
    end loop;
  end if;

end;
/

