create or replace procedure USR_P_PAIS_UPDATE
/*
Входящий счёт на оплату. Спецификация. Исправление
Если значение какого-либо параметра не задано, то используется текущее значение
08/04/2022 Степанов М.

Добавлено изменение позиции в Приходной накладной, Приходном ордере, во Входном контроле и в Товарных запасах.
16.08.2024
*/
(
 nRN              in number
,nDLOS_UPDATE     in number  /* исправлять аналогичную спецификацию в заказе поставщикам */
,nOUT_DOC_UPDATE  in number  /* исправлять аналогичную спецификацию в приходных накладных */
,sNOMEN           in varchar2
,sMODIF           in varchar2
,sTAXGR           in varchar2
,sSERNUMB         in varchar2
,sCOMMENTS        in varchar2
,nQUANT           in number
,nSUMMWITHNDS     in number
,nRECALC_SUM_TAX  in number         /* Пересчитывать сумму по налоговой группе */
,sORIGINAL_NAME   in varchar2
,nUSE_NOMEN_NAME  in number default 0
)
is
  rV_Row                v_payaccinspec%rowtype;
  rV_Row2               v_payaccinspec%rowtype;
  nInDocQuant           pkg_std.tquant;
  nInDocQuantAlt        pkg_std.tquant;
  bExistsAllRights      boolean := false;
  bExistsAllRightsLim   boolean := false;
  nClnEvents            pkg_std.tref;
  rInInvoicesSpecs      ininvoicesspecs%rowtype;

  rPayAccIn             payaccin%rowtype;
  nDeliveryOrd          pkg_std.tref;
  rDeliveryOrdS         deliveryords%rowtype;
  rDeliveryOrdPs        deliveryordps%rowtype;
  rClnEvents            clnevents%rowtype;
  nCount                pkg_std.tnumber := 0; 
  nFlag_Del_Calc        pkg_std.tnumber := 0; 
  
  nSumm                 pkg_std.tlcoeff; 
  nSumm_Old             pkg_std.tlcoeff; 
  nSummNDS_Old          pkg_std.tlcoeff; 
  nSummNDS_New          pkg_std.tlcoeff; 
  nNumber               pkg_std.tnumber; 
  sVarchar              pkg_std.tstring; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAIS_UPDATE');

  /* ПРОВЕРКИ */
  /* Считывание текущей записи и заголовка */
  select * into rV_Row from v_payaccinspec where nrn = usr_p_pais_update.nRN;
  nClnEvents  := usr_pkg_document.get_clnevents(nflagsmart => 1, nrn => rV_Row.nprn);
  if nClnEvents is not null then
    rClnEvents  := usr_pkg_ClnEvents.clnevents_get(nrn => nClnEvents);
  end if;

  /* Наличие у пользователя роли 'Все права' */
  for c in ( select null from userroles where authid = utilizer and roleid = 90519 )
  loop
    bExistsAllRights := true;
    exit;
  end loop;

  /* Наличие у пользователя роли 'Все права. Ограничено' */
  for c in ( select null from userroles where authid = utilizer and roleid = 111526249 )
  loop
    bExistsAllRightsLim := true;
    exit;
  end loop;

  /* Изменяется сумма или количество, и они не равны значениям в документе, и Статус события НЕ "РегистрацияВхСч" */
  /*if (
      ( nSUMMWITHNDS is not null and cmp_num( nSUMMWITHNDS, rV_Row.nsummwithnds ) != 1 )
     or
      ( nQUANT is not null and cmp_num( nQUANT, rV_Row.nquant ) != 1)
     )
  and nClnEvents is not null 
  and rClnEvents.event_stat != 7195921 
  and ( not bExistsAllRights and not bExistsAllRightsLim ) then
    p_exception(0, 'Исправление допускается только на статусе события <%s>. %s%s'
               ,usr_pkg_clnevntypes.clnevntypsts_get_ces_name(nrn => 7195921)
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rV_Row.nrn)
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Row.nprn));
  end if;*/

  /* Изменяется номенклатура или модификация */
  if ( sNOMEN is not null or sMODIF is not null ) then

    /* Меняем признак Исправлять калькуляции */
    /*nFlag_Del_Calc := 1; */
  
    /* Нет роли Все права */
    if not bExistsAllRights  then
      p_exception(0, 'Номенклатура и модификация исправляются пока только сотрудниками ИТ отдела. %s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rV_Row.nrn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Row.nprn));
    end if;
  end if;

  /* Изменяется количество */
  if nQUANT is not null then

    /* Меняем признак Исправлять калькуляции */
    /*nFlag_Del_Calc := 1;*/ 

    /* Количество по приходным документам для спецификации */
    usr_pkg_payaccin.payaccinspec_get_indoc_quant(nrn       => rV_Row.nrn
                                                 ,nquant    => nInDocQuant
                                                 ,nquantalt => nInDocQuantAlt);
    /* Проверка количества */
    /*if nQUANT < nInDocQuant and utilizer not in  ( 'KHOK')  then
      p_exception(0, 'Новое количество <%s> меньше, чем количество по приходным документам <%s>. %s%s'
                 ,nQUANT
                 ,nInDocQuant
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rV_Row.nrn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Row.nprn));
    end if;*/
  end if;

  /* ПРОЦЕДУРА */
  /* Считывание заголовка */
  rV_Row2  := rV_Row;
  rPayAccIn := usr_pkg_payaccin.payaccin_get(nrn => rV_Row2.nprn);

  rV_Row2.snomen          := nvl(sNOMEN, rV_Row2.snomen);
  rV_Row2.snommodif       := nvl(sMODIF, rV_Row2.snommodif);
  rV_Row2.staxgr          := nvl(sTAXGR, rV_Row2.staxgr);
  rV_Row2.sseria          := nvl(sSERNUMB, rV_Row2.sseria);
  rV_Row2.scomments       := nvl(sCOMMENTS, rV_Row2.scomments);
  rV_Row2.nquant          := nvl(nQUANT, rV_Row2.nquant);
  rV_Row2.nsummwithnds    := nvl(nSUMMWITHNDS, rV_Row2.nsummwithnds);
  rV_Row2.soriginal_name  := nvl( sORIGINAL_NAME, case nUSE_NOMEN_NAME when 1 then rV_Row2.snomname else rV_Row2.soriginal_name end );

  /* Если заданы параметры, которые могут инициировать пересчёт сумм */
  if nSUMMWITHNDS is not null or sTAXGR is not null or nQUANT is not null or nRECALC_SUM_TAX = 1 then
    /* Спецификация частично исполнена */
    /*if cmp_num( rV_Row2.nfactsumm, 0 ) != 1 then
      p_exception(0, 'Спецификация частично исполнена на сумму <%s>. Для исправления обратитесь в отдел ИТ.%s%s'
                 ,rV_Row2.nfactsumm
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rV_Row.nrn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Row.nprn));
    end if;*/
    /* Если пересчитывать сумму по налоговой группе */
    if nRECALC_SUM_TAX = 1 then
      /* НДС с суммы недопоставки по исходной ставке */
      usr_pkg_dictaxgr.dictaxis_calc( ncompany      => rPayAccIn.company
                                     ,ddate         => rPayAccIn.doc_date
                                     ,staxgr        => rV_Row.staxgr
                                     ,ninsumm       => rV_Row2.nsummwithnds - rV_Row2.nfactsumm
                                     ,nquant        => rV_Row2.nquant
                                     ,nsumm         => nSumm_Old
                                     ,nsummwithnds  => nNumber
                                     ,nsumm_nds     => nSummNDS_Old
                                     ,nprice        => nNumber );
      /* НДС с суммы недопоставки по новой ставке */
      usr_pkg_dictaxgr.dictaxis_calc( ncompany      => rPayAccIn.company
                                     ,ddate         => rPayAccIn.doc_date
                                     ,staxgr        => rV_Row2.staxgr
                                     ,ninsumm       => nSumm_Old
                                     ,nsumm_sign    => 0
                                     ,nquant        => rV_Row2.nquant
                                     ,nsumm         => nNumber       
                                     ,nsummwithnds  => nNumber
                                     ,nsumm_nds     => nSummNDS_New
                                     ,nprice        => nNumber );
      /* НДС с суммы недопоставки по новой ставке */
      rV_Row2.nsummwithnds := rV_Row2.nsummwithnds - nvl( nSummNDS_Old, 0 ) + nvl( nSummNDS_New, 0 );
    end if;

    /* Пересчёт сумм */
    usr_pkg_dictaxgr.dictaxis_calc( ncompany      => rPayAccIn.company
                                   ,ddate         => rPayAccIn.doc_date
                                   ,staxgr        => rV_Row2.staxgr
                                   ,ninsumm       => rV_Row2.nsummwithnds
                                   ,nquant        => rV_Row2.nquant
                                   ,nsumm         => rV_Row2.nsumm       
                                   ,nsummwithnds  => rV_Row2.nsummwithnds
                                   ,nsumm_nds     => rV_Row2.nsumm_nds  
                                   ,nprice        => rV_Row2.nprice );
  end if;

  /* Исправление текущей записи */
  usr_pkg_payaccin.payaccinspec_update( rv_row => rV_Row2, nflag_del_calc => nFlag_Del_Calc, nmode => 1 );

  /* Перечитываем представление спецификации вх.счёта */
  select * into rV_Row2 from v_payaccinspec where nrn = rV_Row2.nrn;

  /* Заголовок заказа */
  nDeliveryOrd := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 1
                                                       ,sout_unitcode  => 'PaymentAccountsIn'
                                                       ,nout_document  => rV_Row2.nprn
                                                       ,sin_unitcode   => 'DeliveryOrders');
  /* Если документ связан с заказом по входу */
  if nDeliveryOrd is not null then

    /* если исправлять заказ */
    if nvl( nDLOS_UPDATE, 0 ) = 1 then

      /* считываем аналогичную спецификацию заказа */
      usr_pkg_deliveryord.deliveryords_get_by_params
      (
       nprn         => nDeliveryOrd
      ,nnom_modif   => rV_Row.nnommodif
      ,nnommod_pack => rV_Row.nnompack
      ,rrow         => rDeliveryOrds
      );
      /* и её исполнение */
      rDeliveryOrdPs := usr_pkg_deliveryord.deliveryordps_get_by_prn(nrn => rDeliveryOrds.rn);

      /* подмена */
      rDeliveryOrdS.nomen         := rV_Row2.nnomen;
      rDeliveryOrdS.nom_modif     := rV_Row2.nnommodif;
      rDeliveryOrdS.tax_group     := rV_Row2.ntaxgr;
      rDeliveryOrdS.note          := rV_Row2.scomments;
      rDeliveryOrdS.main_quant    := rV_Row2.nquant;
      rDeliveryOrdS.exp_price     := rV_Row2.nprice;
      rDeliveryOrdS.sumwtax       := rV_Row2.nsummwithnds;
      rDeliveryOrdS.sumwotax      := rV_Row2.nsumm;
      rDeliveryOrdPs.actm_quant   := rV_Row2.nquant;
      rDeliveryOrdPs.actswtax     := rV_Row2.nsummwithnds;
      rDeliveryOrdPs.actswotax    := rV_Row2.nsumm;
      rDeliveryOrdPs.custm_quant  := rV_Row2.nquant;
      rDeliveryOrdPs.custswtax    := rV_Row2.nsummwithnds;
      rDeliveryOrdPs.custswotax   := rV_Row2.nsumm;
      rDeliveryOrdPs.execm_quant  := rV_Row2.nquant; 

      /* исправление спецификации */
      usr_pkg_deliveryord.deliveryords_base_update( rRow => rDeliveryOrdS, rdeliveryordps => rDeliveryOrdPs, nflag_del_calc => 0, nmode => 1 );
    /*else
      p_exception(0, 'Документ имеет связь по входу с заказом поставщикам, при этом не установлен признак "Исправлять заказ поставщикам". %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rPayAccIn.rn));*/
    end if;
  end if;

  /* Исправлять выходные документы */
  if nOUT_DOC_UPDATE = 1 then
    /* Спецификации Приходных накладных */
    for c in (
               select t.*
                 from ininvoicesspecs t
                     ,doclinks        dl
                where dl.in_document  = rV_ROW.NPRN
                  and dl.out_unitcode = 'IncomingInvoices'
                  and dl.out_document = t.prn
                  and t.modif         = rV_ROW.NNOMMODIF
              ) 
    loop
      /* Проверка, что исправляется только одна спецификация */
      nCount := nCount + 1;
      if nCount != 1 then
        p_exception(0, 'Спецификация Входящего счёта связана с несколькими спецификациями Приходных накладных. %s%s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rV_Row.nrn)
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Row.nprn));
      end if;

      /* Сохранение строки в переменную */
      rInInvoicesSpecs := c;
      /* Подмена значений в переменной */
      rInInvoicesSpecs.nomen          := rV_Row2.nnomen;
      rInInvoicesSpecs.modif          := rV_Row2.nnommodif;
      rInInvoicesSpecs.taxgr          := rV_Row2.ntaxgr;
      rInInvoicesSpecs.note           := rV_Row2.scomments;
      rInInvoicesSpecs.quant          := rV_Row2.nquant;
      rInInvoicesSpecs.price          := rV_Row2.nprice;
      rInInvoicesSpecs.summtax        := rV_Row2.nsummwithnds;
      rInInvoicesSpecs.summ           := rV_Row2.nsumm;
      rInInvoicesSpecs.summ_nds       := rV_Row2.nsumm_nds;
      rInInvoicesSpecs.original_name  := rV_Row2.soriginal_name;
      /* Исправление */
      usr_pkg_ininvoices.ininvoicesspecs_base_update(rrow                => rInInvoicesSpecs
                                                    ,nsumm_ininvoices    => nNumber
                                                    ,nsummtax_ininvoices => nNumber
                                                    ,nout_doc_update     => nOUT_DOC_UPDATE
                                                    ,nmode               => 1 );
    end loop;

    /* Пересчёт исполнения на входящем счёте (почему-то иначе задваивается исполнение) */
    usr_pkg_payaccin.payaccin_recalc_performance( nrn => rV_Row.nprn );

  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end USR_P_PAIS_UPDATE;
/
