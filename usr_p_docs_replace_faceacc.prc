create or replace procedure usr_p_docs_replace_faceacc
/*
25/08/2025 Степанов М.
Документы
Исправить лицевой счёт в текущем и связанных документах
*/
(
 nRN        in number
,nCOMPANY   in number
,sUNITCODE  in varchar2   /* Раздел вызова. Допускается только: Заказы поставщикам, Входящие счета на оплату */
,sFACEACC   in varchar2
)
as
  nDocument         pkg_std.tref := nRN; 
  rV_FaceAcc        v_faceacc%rowtype;
  rStages           stages%rowtype;
  rContracts        contracts%rowtype;
  rAgnAcc           agnacc%rowtype;
  rGovCntrId        govcntrid%rowtype;
  rFinPayTool       finpaytool%rowtype;
  rV_DeliveryOrd    v_deliveryord%rowtype;
  rV_RInvToSup      v_rinvtosup%rowtype;
  rV_InOrders       v_inorders%rowtype;
  rV_InInvoices     v_ininvoices%rowtype;
  rV_PayNotes       v_paynotes%rowtype;
  rV_PayAccIn       v_payaccin%rowtype;

  sVarchar          pkg_std.tstring;
  nNumber           pkg_std.tnumber;
begin
  /* Открытие процесса */
  usr_pkg_process.process_open( sname => 'USR_P_DOCS_REPLACE_FACEACC' );

  /* Считывание нового лицевого счёта */
  find_faceacc_by_numb( ncompany => nCOMPANY, snumber => sFACEACC, nrn => rV_FaceAcc.nrn );
  select * into rV_FaceAcc from v_faceacc where nrn = rV_FaceAcc.nrn;

  /* Поиск этапа договора по ЛС */
  find_contracts_faceacc(nflag_smart  => 1
                        ,ncompany     => rV_FaceAcc.ncompany
                        ,nfaceacc     => rV_FaceAcc.nrn
                        ,sfaceacc     => null
                        ,ncontract    => null
                        ,ncontractout => nNumber
                        ,sdoc_type    => sVarchar
                        ,sdoc_pref    => sVarchar
                        ,sdoc_numb    => sVarchar
                        ,ddoc_date    => sVarchar
                        ,nstage       => rStages.rn
                        ,sstagenumb   => sVarchar
                        ,sfaceaccout  => sVarchar);
  /* Если найден этап договора */
  if rStages.rn is not null then
    /* Считывание этапа договора */
    rStages := usr_pkg_contracts.stages_get( nrn => rStages.rn );
    /* Если в этапе указаны наши реквизиты */
    if rStages.jur_acc is not null then
      /* Сохраняем RN наших реквизитов */
      rAgnAcc.rn := rStages.jur_acc;
    /* Если в этапе НЕ указаны наши реквизиты */
    else
      /* Считываем договор этапа */
      rContracts := usr_pkg_contracts.contracts_get( nrn => rStages.prn );
      /* Если в договоре указаны наши реквизиты */
      if rContracts.jur_acc is not null then
        /* Сохраняем RN наших реквизитов */
        rAgnAcc.rn := rContracts.jur_acc;
      end if;
    end if;
  end if;

  /* Если найдены наши реквизиты */
  if rAgnAcc.rn is not null then
    /* Считываем запись наших реквизитов */
    rAgnAcc := usr_pkg_agnlist.agnacc_get( nrn => rAgnAcc.rn );
    /* Поис ИГК для наших реквизитов */
    find_govcntrid_agnacc( nflag_option => 1
                          ,ncompany     => nCOMPANY
                          ,sagent       => sVarchar
                          ,nagent       => nNumber
                          ,sagnacc      => sVarchar
                          ,nagnacc      => rAgnAcc.rn
                          ,sgovcntrid   => rGovCntrId.code
                          ,ngovcntrid   => rGovCntrId.rn );

    /* Поиск инструмента оплаты для наших реквизитов */
    rFinPayTool.rn := usr_pkg_finpaytool.finpaytool_get_by_agnacc( nagnacc => rAgnAcc.rn, nflagsmart => 1 );
    /* Если инструменты оплаты найден, считываем */
    if rFinPayTool.rn is not null then
      rFinPayTool := usr_pkg_finpaytool.finpaytool_get( nrn => rFinPayTool.rn );
    end if;
  end if;

  /* РАСХОДНЫЕ НАКЛАДНЫЕ НА ВОЗВРАТ ПОСТАВЩИКАМ */
  /* Получение списка выходных документов в разделе */
  nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                            ,sin_unitcode  => sUNITCODE
                                            ,nin_document  => nDocument
                                            ,sout_unitcode => 'ReturnInvoicesToSuppliers'
                                            ,nident        => nDocument );
  /* По документам из списка */
  for c in ( select t.*
               from selectlist  sl
                   ,v_rinvtosup t
              where sl.ident = nDocument
                and t.nrn    = sl.document )
  loop
    /* Сохранение в переменную */
    rV_RInvToSup := c;
    /* Подмена */
    rV_RInvToSup.sfaceacc  := rV_FaceAcc.snumber;
    rV_RInvToSup.sdoctype  := rV_FaceAcc.svalid_doctype;
    rV_RInvToSup.snumb     := rV_FaceAcc.svalid_docnumb;
    rV_RInvToSup.ddocdate  := rV_FaceAcc.dvalid_docdate;
    /* Исправление */
    usr_pkg_rinvtosup.rinvtosup_update( rv_row => rV_RInvToSup, nmode => 1 );
  end loop;
  /* Очистка */
  p_selectlist_clear( nident => nDocument );

  /* ПРИХОДНЫЕ ОРДЕРА */
  /* Получение списка выходных документов в разделе */
  nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                            ,sin_unitcode  => sUNITCODE
                                            ,nin_document  => nDocument
                                            ,sout_unitcode => 'IncomingOrders'
                                            ,nident        => nDocument );
  /* По документам из списка */
  for c in ( select t.*
               from selectlist  sl
                   ,v_inorders  t
              where sl.ident = nDocument
                and t.nrn    = sl.document )
  loop
    /* Сохранение в переменную */
    rV_InOrders := c;
    /* Подмена */
    rV_InOrders.sfaceacc     := rV_FaceAcc.snumber;
    rV_InOrders.sconfdoctype := rV_FaceAcc.svalid_doctype;
    rV_InOrders.sconfdocnumb := rV_FaceAcc.svalid_docnumb;
    rV_InOrders.dconfdocdate := rV_FaceAcc.dvalid_docdate;
    /* Исправление */
    usr_pkg_inorders.inorders_update( rv_row => rV_InOrders, nmode => 1 );
  end loop;
  /* Очистка */
  p_selectlist_clear( nident => nDocument );

  /* ПРИХОДНЫЕ НАКЛАДНЫЕ */
  /* Получение списка выходных документов в разделе */
  nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                            ,sin_unitcode  => sUNITCODE
                                            ,nin_document  => nDocument
                                            ,sout_unitcode => 'IncomingInvoices'
                                            ,nident        => nDocument );
  /* По документам из списка */
  for c in ( select t.*
               from selectlist    sl
                   ,v_ininvoices  t
              where sl.ident  = nDocument
                and t.nrn     = sl.document )
  loop
    /* Сохранение в переменную */
    rV_InInvoices := c;
    /* Подмена */
    rV_InInvoices.sfaceacc        := rV_FaceAcc.snumber;
    rV_InInvoices.svalid_doctype  := rV_FaceAcc.svalid_doctype;
    rV_InInvoices.svalid_docnumb  := rV_FaceAcc.svalid_docnumb;
    rV_InInvoices.dvalid_docdate  := rV_FaceAcc.dvalid_docdate;
    /* Исправление */
    usr_pkg_ininvoices.ininvoices_update( rv_row => rV_InInvoices, nmode => 1 );
  end loop;
  /* Очистка */
  p_selectlist_clear( nident => nDocument );

  /* ЖУРНАЛ ПЛАТЕЖЕЙ */
  /* Получение списка выходных документов в разделе */
  nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                            ,sin_unitcode  => sUNITCODE
                                            ,nin_document  => nDocument
                                            ,sout_unitcode => 'PayNotes'
                                            ,nident        => nDocument );
  /* По документам из списка */
  for c in ( select t.*
               from selectlist  sl
                   ,v_paynotes  t
              where sl.ident  = nDocument
                and t.nrn     = sl.document )
  loop
    /* Сохранение в переменную */
    rV_PayNotes := c;
    /* Подмена */
    rV_PayNotes.snumb      := rV_FaceAcc.snumber;
    rV_PayNotes.svdoc_type := rV_FaceAcc.svalid_doctype;
    rV_PayNotes.svdoc_numb := rV_FaceAcc.svalid_docnumb;
    rV_PayNotes.dvdoc_date := rV_FaceAcc.dvalid_docdate;
    /* Исправление */
    usr_pkg_paynotes.paynotes_update( rv_row => rV_PayNotes, nmode => 1 );
  end loop;
  /* Очистка */
  p_selectlist_clear( nident => nDocument );

  /* ВХОДЯЩИЕ СЧЕТА НА ОПЛАТУ */
  /* Получение списка выходных документов в разделе */
  /* Раздел вызова */
  case sUNITCODE
    /* Заказы поставщикам */
    when 'DeliveryOrders' then
      /* связанные по выходу входящие счета */
      nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                                ,sin_unitcode  => sUNITCODE
                                                ,nin_document  => nDocument
                                                ,sout_unitcode => 'PaymentAccountsIn'
                                                ,nident        => nDocument );
    /* Входящие счета на оплату */
    when 'PaymentAccountsIn' then
      /* связанные по выходу входящие счета (доплата) */
      nNumber := f_doclinks_link_out_recurs_doc( nflag_mode    => 0
                                                ,sin_unitcode  => sUNITCODE
                                                ,nin_document  => nDocument
                                                ,sout_unitcode => 'PaymentAccountsIn'
                                                ,nident        => nDocument );
      /* и текущий входящий счет */
      p_selectlist_insert( nident => nDocument, ndocument => nDocument, sunitcode => sUNITCODE, nrn => nNumber );
  else 
    p_exception(0, 'Неверный раздел вызова "%s".', sUNITCODE ); 
  end case;

  /* По документам из списка */
  for c in ( select t.*
               from selectlist  sl
                   ,v_payaccin  t
              where sl.ident = nDocument
                and t.nrn    = sl.document )
  loop
    /* Сохранение в переменную */
    rV_PayAccIn := c;
    /* Подмена */
    rV_PayAccIn.sfaceacc   := rV_FaceAcc.snumber;
    rV_PayAccIn.svdoc_type := rV_FaceAcc.svalid_doctype;
    rV_PayAccIn.svdoc_num  := rV_FaceAcc.svalid_docnumb;
    rV_PayAccIn.dvdoc_date := rV_FaceAcc.dvalid_docdate;
    /* Исправление */
    usr_pkg_payaccin.payaccin_update( rv_row => rV_PayAccIn, nmode => 1 );
  end loop;
  /* Очистка */
  p_selectlist_clear( nident => nDocument );

  /* ЗАКЗАЗ ПОСТАВЩИКУ */
  /* Получение списка выходных документов в разделе */
  /* Раздел вызова */
  case sUNITCODE
    /* Заказы поставщикам */
    when 'DeliveryOrders' then
      /* текущий заказ поставщику*/
      p_selectlist_insert( nident => nDocument, ndocument => nDocument, sunitcode => sUNITCODE, nrn => nNumber );
    /* Входящие счета на оплату */
    when 'PaymentAccountsIn' then
      /* связанные по входу заказы поставщикам */
      nNumber := f_doclinks_link_in_recurs_doc( nflag_mode     => 0
                                               ,sout_unitcode => sUNITCODE
                                               ,nout_document => nDocument
                                               ,sin_unitcode  => 'DeliveryOrders'
                                               ,srule_chains  => ';PaymentAccountsIn<DeliveryOrders;'
                                               ,nident        => nDocument );
  else 
    p_exception(0, 'Неверный раздел вызова "%s".', sUNITCODE ); 
  end case;

  /* По документам из списка */
  for c in ( select t.*
               from selectlist    sl
                   ,v_deliveryord t
              where sl.ident = nDocument
                and t.nrn    = sl.document )
  loop
    /* Сохранение в переменную */
    rV_DeliveryOrd := c;
    /* Подмена */
    rV_DeliveryOrd.sfaceacc := rV_FaceAcc.snumber;
    /* Исправление */
    usr_pkg_deliveryord.deliveryord_update( rv_row => rV_DeliveryOrd, nmode => 1 );
    /* Свойство ИГК */
    pkg_docs_props_vals.modify(nproperty   => 21128575
                              ,sunitcode   => 'DeliveryOrders'
                              ,ndocument   => rV_DeliveryOrd.nrn
                              ,sstr_value  => rGovCntrId.code
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => nNumber);
    /* Свойство Инструмент оплаты */
    pkg_docs_props_vals.modify(nproperty   => 21128577
                              ,sunitcode   => 'DeliveryOrders'
                              ,ndocument   => rV_DeliveryOrd.nrn
                              ,sstr_value  => rFinPayTool.code
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => nNumber);
  end loop;
  /* Очистка */
  p_selectlist_clear( nident => nDocument );

  /* Закрытие процесса */
  usr_pkg_process.process_close;

/* Обработка исключений */
exception when others then
  /* Закрытие процесса */
  usr_pkg_process.process_close;
  /* Сообщение об ошибке */
  raise;
end;
/
