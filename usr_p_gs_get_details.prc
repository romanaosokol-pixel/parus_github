create or replace procedure USR_P_GS_GET_DETAILS
/*
Товарные запасы.
Показать дополнительные данные
Степанов М.В. 20/05/2024
*/
(
 nRN                in number    /* Товарный запас. RN */
,sPAYACCIN_LIST     out varchar2 /* Реквизиты входящих счетов */
,sAGNACC_LIST       out varchar2 /* Расчётные счета платежей юр.лица */
,sPAYER_AGNACC_LIST out varchar2 /* Расчётные счета платежей Контрагента */
,sTRANSINV_SERT     out varchar2 /* Расходная накладная на передачу на Сертификацию */
) 
is
  nInorders   pkg_std.tref;
  nInInvoices pkg_std.tref;
  nPayAccIn   pkg_std.tref;
  rPayAccIn   payaccin%rowtype;

  --nNumber  pkg_std.tnumber;
  --sVarchar pkg_std.tstring;
begin
  /* RN приходного ордера */
  begin
    select s.prn
      into nInorders
      from inorderspecs s
     where s.goodssupply = nrn;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      null;
  end;

  if (nInorders is null) then
    begin
      select s.prn
        into nInorders
        from goodssupply  gs
            ,goodsparties gp
            ,inorderspecs s
       where gs.rn = nrn
         and gp.rn = gs.prn
         and trim(s.sernumb) = trim(gp.sernumb);
    exception
      when no_data_found then
        null;
      when too_many_rows then
        null;
    end;
  end if;

  /* Приходная накладная */
  nInInvoices := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                                    ,sout_unitcode  => 'IncomingOrders'
                                                    ,nout_document  => nInorders
                                                    ,sin_unitcode   => 'IncomingInvoices');

  /* Если приходная накладная найдена */
  if nInInvoices is not null then
    /* Входящий счёт */
    nPayAccIn := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                                      ,sout_unitcode  => 'IncomingInvoices'
                                                      ,nout_document  => nInInvoices
                                                      ,sin_unitcode   => 'PaymentAccountsIn');
  /* Если приходная накладная НЕ найдена */
  else
    /* Входящий счёт напрямую из приходного ордера */
    nPayAccIn := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                                      ,sout_unitcode  => 'IncomingOrders'
                                                      ,nout_document  => nInorders
                                                      ,sin_unitcode   => 'PaymentAccountsIn');
  end if;

  /* Если Входящий счёт найден */
  if nPayAccIn is not null then
    /* считывание */
    rPayAccIn := usr_pkg_payaccin.payaccin_get(nrn => nPayAccIn);
  /* Если Входящий счёт НЕ найден */
  else
    /* выходим */
    return;
  end if;

  /* Реквизиты Входящего счёта */
  sPAYACCIN_LIST := pkg_document.make_number(ndoc_type => rPayAccIn.doc_type
                                            ,sdoc_pref => rPayAccIn.doc_pref
                                            ,sdoc_numb => rPayAccIn.doc_numb
                                            ,ddoc_date => rPayAccIn.doc_date);

  /* Расчётные счета Юр.лица */
  select listagg(trim(t.agnacc), ', ') within group(order by t.agnacc)
    into sAGNACC_LIST
    from (select distinct aac.agnacc
            from paynotes pn
                ,agnacc   aac
           where pn.rn in (select distinct out_document
                             from doclinks
                            where out_unitcode = 'PayNotes'
                           connect by prior out_document = in_document
                            start with in_document = nPayAccIn)
             and pn.signplan = 0
             and pn.agnacc = aac.rn) t;

  /* Расчётные счета Контрагента */
  select listagg(trim(t.agnacc), ', ') within group(order by t.agnacc)
    into sPAYER_AGNACC_LIST
    from (select distinct aac.agnacc
            from paynotes pn
                ,agnacc   aac
           where pn.rn in (select distinct out_document
                             from doclinks
                            where out_unitcode = 'PayNotes'
                           connect by prior out_document = in_document
                            start with in_document = nPayAccIn)
             and pn.signplan = 0
             and pn.payer_agnacc = aac.rn) t;

  /* Расходник передачи на Сертификацию 
     15/07/2024 KHOK */
  begin
  select listagg(trim(TR.PREF)||'-'||trim(TR.NUMB)||' от '||to_char(TR.DOCDATE, 'DD.MM.YYYY')||case TR.STATUS when 0 then ' (Не отработан)' else ' (Отработан)' end, ', ')
         WITHIN GROUP (order by TR.PREF, TR.NUMB)
    into sTRANSINV_SERT
    from TRANSINVDEPT      TR,
         TRANSINVDEPTSPECS SPEC,
         GOODSSUPPLY       GS
   where TR.IN_STORE in (select d.nrn from V_DICSTORE D where nCRN in ('12737559') and nCOMPANY = 90521) -- Склады каталога Сертификация
     and SPEC.PRN = TR.RN
     and SPEC.GOODSPARTY = GS.PRN
     and GS.RN = NRN;
  exception
    when no_data_found then
        sTRANSINV_SERT := '-'; --to_char(null);
    when too_many_rows then
        sTRANSINV_SERT := '???';
  end;

end USR_P_GS_GET_DETAILS;
/
