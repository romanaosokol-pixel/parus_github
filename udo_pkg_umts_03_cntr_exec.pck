create or replace package udo_pkg_umts_03_cntr_exec is

  -- Author  : I.ANNENKO
  -- Created : 01.11.2022 10:22:19
  -- Purpose : УМТС. 3. Исполнение договора с поставщиком

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  /*Функция возвращает признак исполнения заказа поставщику*/
  function f_deliveryord_calc_sign_exec(nrn in number /*Регистрационный номер записи*/)
    return number;

  /*Процедура выполняет автоматическое закрытие заказа поставщику при отработке накладной*/
  procedure p_ininvoices_process(ncompany in number /*Организация*/,
                                 nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет автоматическую отмену закрытия заказа поставщику при снятии отработки накладной*/
  procedure p_ininvoices_cancel(ncompany in number /*Организация*/,
                                nrn      in number /*Регистрационный номер записи*/);

  /*** процедура пересчета исполнения у родительских документов ***/
  procedure RECALC_PERFORMANCE(nCOMPANY   in number,
                               dWORK_DATE in date,
                               nR_RN      in number, -- RN приходной накладной
                               nR_OSTATUS in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
                               nR_NSTATUS in number -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
                               );

  /*Процедура выполняет исправление модификации счета на оплату*/
  procedure p_payaccinspec_update_modif(ncompany       in number /*Организация*/,
                                        nprn           in number /*Регистрационный номер родителя*/,
                                        nrn            in number /*Регистрационный номер записи*/,
                                        snomen         in varchar2 /*Номенклатура*/,
                                        snommodif      in varchar2 /*Модификация*/,
                                        staxgr         in varchar2 /*Налоговая группа*/,
                                        nquant         in number /*Количество*/,
                                        nprice         in number /*Цена*/,
                                        nsummwithnds   in number /*Сумма с НДС*/,
                                        nsumm          in number /*Сумма без НДС*/,
                                        nsumm_nds      in number /*Сумма НДС*/,
                                        nautocalc_sign in number /*Признак автоматического расчета*/,
                                        soriginal_name in varchar2 /*Оригинальное наименование*/);

end udo_pkg_umts_03_cntr_exec;
/

create or replace package body udo_pkg_umts_03_cntr_exec is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*Функция возвращает признак исполнения заказа поставщику*/
  function f_deliveryord_calc_sign_exec(nrn in number /*Регистрационный номер записи*/)
    return number is
  begin
  
    for sp_cursor in (select s.rn as nrn,
                             s.main_quant as nmain_quant,
                             to_number(null) as nexec_quant
                        from deliveryords s
                       where s.prn = nrn) loop
      begin
        select p.p_factm_quant
          into sp_cursor.nexec_quant
          from DELIVERYORDPS p
         where p.prn = sp_cursor.nrn;
      exception
        when no_data_found then
          p_exception(0,
                      'Не удалось определить исполнение');
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить исполнение');
      end;
    
      if (sp_cursor.nmain_quant > sp_cursor.nexec_quant) then
        return(0);
      end if;
    end loop;
  
    if (F_DELIVERYORDP_GET_NPARAM(1, nrn, 0, 'PERF_FACT_SUM') =
       F_DELIVERYORDP_GET_NPARAM(1, nrn, 0, 'PAY_FACT_SUM')) then
      return(1);
    else
      return(0);
    end if;
  end f_deliveryord_calc_sign_exec;

  /*Процедура выполняет автоматическое закрытие заказа поставщику при отработке накладной*/
  procedure p_ininvoices_process(ncompany in number /*Организация*/,
                                 nrn      in number /*Регистрационный номер записи*/) is
  
    /*Регистрационный номер записи заказа поставщику*/
    nrn_ord pkg_std.tREF;
  
    /*Регистрационный номер записи счета на оплату*/
    nrn_acc pkg_std.tREF;
  
    /*Состояние заказа поставщику*/
    nord_state number;
  
    /*Результат установки состояния*/
    nresult number;
  
  begin
    /*Регистрационный номер записи заказа поставщику*/
    nrn_ord := f_doclinks_link_in_doc(sOUT_UNITCODE => 'IncomingInvoices',
                                      nOUT_DOCUMENT => nrn,
                                      sIN_UNITCODE  => 'DeliveryOrders');
  
    if (nrn_ord is null) then
      /*Регистрационный номер записи счета на оплату*/
      nrn_acc := f_doclinks_link_in_doc(sOUT_UNITCODE => 'IncomingInvoices',
                                        nOUT_DOCUMENT => nrn,
                                        sIN_UNITCODE  => 'PaymentAccountsIn');
    
      /*Регистрационный номер записи заказа поставщику*/
      if (nrn_acc is not null) then
        nrn_ord := f_doclinks_link_in_doc(sOUT_UNITCODE => 'PaymentAccountsIn',
                                          nOUT_DOCUMENT => nrn_acc,
                                          sIN_UNITCODE  => 'DeliveryOrders');
      end if;
    end if;
  
    /*Если накладная не связана с заказом поставщику, то завершаем работу процедуры*/
    if (nrn_ord is null) then
      return;
    end if;
  
    /*Состояние заказа поставщику*/
    begin
      select do.ord_state
        into nord_state
        from deliveryord do
       where do.rn = nrn_ord
         and do.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.record_not_found(ndocument   => nrn_ord,
                                 sunit_table => 'DeliveryOrders');
    end;
  
    /*Если состояние заказа поставщику отлично от Утвержден, то завершаем работу процедуры*/
    if (nord_state <> 1) then
      return;
    end if;
  
    /*Если заказ поставщику не исполнен, то завершаем работу процедуры*/
    if (f_deliveryord_calc_sign_exec(nrn => nrn_ord) = 0) then
      return;
    end if;
  
    /*Выполняем закрытие заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn_ord,
                            nflag_mode  => 0,
                            nnew_state  => 3,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
  
    /*Выполняем проверку закрытия заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При закрытии заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  end p_ininvoices_process;

  /*Процедура выполняет автоматическую отмену закрытия заказа поставщику при снятии отработки накладной*/
  procedure p_ininvoices_cancel(ncompany in number /*Организация*/,
                                nrn      in number /*Регистрационный номер записи*/) is
  
    /*Регистрационный номер записи заказа поставщику*/
    nrn_ord pkg_std.tREF;
  
    /*Регистрационный номер записи счета на оплату*/
    nrn_acc pkg_std.tREF;
  
    /*Состояние заказа поставщику*/
    nord_state number;
  
    /*Результат установки состояния*/
    nresult number;
  
  begin
    /*Регистрационный номер записи заказа поставщику*/
    nrn_ord := f_doclinks_link_in_doc(sOUT_UNITCODE => 'IncomingInvoices',
                                      nOUT_DOCUMENT => nrn,
                                      sIN_UNITCODE  => 'DeliveryOrders');
  
    if (nrn_ord is null) then
      /*Регистрационный номер записи счета на оплату*/
      nrn_acc := f_doclinks_link_in_doc(sOUT_UNITCODE => 'IncomingInvoices',
                                        nOUT_DOCUMENT => nrn,
                                        sIN_UNITCODE  => 'PaymentAccountsIn');
    
      /*Регистрационный номер записи заказа поставщику*/
      if (nrn_acc is not null) then
        nrn_ord := f_doclinks_link_in_doc(sOUT_UNITCODE => 'PaymentAccountsIn',
                                          nOUT_DOCUMENT => nrn_acc,
                                          sIN_UNITCODE  => 'DeliveryOrders');
      end if;
    end if;
  
    /*Если накладная не связана с заказом поставщику, то завершаем работу процедуры*/
    if (nrn_ord is null) then
      return;
    end if;
  
    /*Состояние заказа поставщику*/
    begin
      select do.ord_state
        into nord_state
        from deliveryord do
       where do.rn = nrn_ord
         and do.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.record_not_found(ndocument   => nrn_ord,
                                 sunit_table => 'DeliveryOrders');
    end;
  
    /*Если состояние заказа поставщику отлично от Закрыт, то завершаем работу процедуры*/
    if (nord_state <> 3) then
      return;
    end if;
  
    /*Если заказ поставщику исполнен, то завершаем работу процедуры*/
    if (f_deliveryord_calc_sign_exec(nrn => nrn_ord) = 1) then
      return;
    end if;
  
    /*Выполняем утверждение заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn_ord,
                            nflag_mode  => 0,
                            nnew_state  => 1,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
  
    /*Выполняем проверку утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При утверждении заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  end p_ininvoices_cancel;

  /*** процедура пересчета исполнения у родительских документов ***/
  procedure RECALC_PERFORMANCE(nCOMPANY   in number,
                               dWORK_DATE in date,
                               nR_RN      in number, -- RN приходной накладной
                               nR_OSTATUS in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
                               nR_NSTATUS in number -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
                               ) is
    nR_IDENT   PKG_STD.tNUMBER; -- идентификатор процесса отражения.
    nR_ORDER   PKG_STD.tREF; -- RN периода исполнения заказа поставщику
    nR_PACCIN  PKG_STD.tREF; -- RN входящего счета на оплату
    nPLAN_SIGN PKG_STD.tNUMBER; -- знак суммирования плана (-1,0,1)
    nFACT_SIGN PKG_STD.tNUMBER; -- знак суммирования факта (-1,0,1)
  
    /* отражение в калькуляции при отражении исполнения */
    bCLC_PERF boolean := (nR_OSTATUS = 2) or (nR_NSTATUS = 2);
    /* идентификатор записей соответствия исходных и отражаемых товарных позиций в SELECTLIST */
    nIDENT_SL PKG_STD.tNUMBER;
  begin
    if (bCLC_PERF) then
      nIDENT_SL := GEN_IDENT;
    end if;
  
    /* инициализация пакета расчета исполнения товарных позиций */
    PKG_GOODSDOCS_PERF_CRM.INIT(nCOMPANY, nR_IDENT, nIDENT_SL);
    /* поиск родительского заказа поставщикам (работа идет с конкретным периодом, связь ищем только по указанным цепочкам) */
    nR_ORDER := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT(nR_IDENT,
                                                       'IncomingInvoices',
                                                       nR_RN,
                                                       'DeliveryOrdersPerform',
                                                       null,
                                                       ';IncomingInvoices<DeliveryOrdersPerform;' ||
                                                       'IncomingInvoices<PaymentAccountsIn<DeliveryOrdersPerform;');
    /* поиск родительского входящего счета на оплату (связь ищем только по указанным цепочкам) */
    nR_PACCIN := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT(nR_IDENT,
                                                        'IncomingInvoices',
                                                        nR_RN,
                                                        'PaymentAccountsIn',
                                                        null,
                                                        ';IncomingInvoices<PaymentAccountsIn;');
    /* если нет ни одного родительского документа - выходим */
    if (nR_ORDER is null) and (nR_PACCIN is null) then
      return;
    end if;
  
    /* выставим знаки суммирования плана и факта */
    nPLAN_SIGN := 0;
    nFACT_SIGN := 0;
    if (nR_OSTATUS = 0) then
      -- был не отработан
      if (nR_NSTATUS = 1) then
        -- будет планом
        nPLAN_SIGN := 1;
        nFACT_SIGN := 0;
      elsif (nR_NSTATUS = 2) then
        -- будет фактом
        nPLAN_SIGN := 1;
        nFACT_SIGN := 1;
      else
        return;
      end if; -- на всякий случай
    elsif (nR_OSTATUS = 1) then
      -- был планом
      if (nR_NSTATUS = 0) then
        -- будет не отработан
        nPLAN_SIGN := -1;
        nFACT_SIGN := 0;
      elsif (nR_NSTATUS = 2) then
        -- будет фактом
        nPLAN_SIGN := 0;
        nFACT_SIGN := 1;
      else
        return;
      end if; -- на всякий случай
    elsif (nR_OSTATUS = 2) then
      -- был фактом
      if (nR_NSTATUS = 0) then
        -- будет не отработан
        nPLAN_SIGN := -1;
        nFACT_SIGN := -1;
      elsif (nR_NSTATUS = 1) then
        -- будет планом
        nPLAN_SIGN := 0;
        nFACT_SIGN := -1;
      else
        return;
      end if; -- на всякий случай
    end if;
  
    /* отражение исполнения по спецификациям приходной накладной */
    for INIS in (select I.CURRENCY,
                        I.CURCOURS,
                        I.CURBASECOURS,
                        F.CURRENCY FA_CURRENCY,
                        I.FA_BASECOURS,
                        I.FA_COURS,
                        S.NOMEN,
                        S.MODIF,
                        S.PACK,
                        S.ARTICLE,
                        nvl(S.STORE, I.STORE) STORE,
                        S.SERNUMB,
                        S.COUNTRY,
                        S.GTD,
                        S.QUANT,
                        S.QUANTALT,
                        S.SUMMTAX,
                        S.RN
                   from ININVOICES I, ININVOICESSPECS S, FACEACC F
                  where I.RN = nR_RN
                    and I.RN = S.PRN
                    and I.FACEACC = F.RN) loop
      /* суммирование исполнения */
      PKG_GOODSDOCS_PERF_CRM.SET_PERF(nR_IDENT,
                                      1 /*SIGN_PACK*/,
                                      null /*NOMENCLS*/,
                                      null /*UMEAS_MAIN*/,
                                      INIS.NOMEN,
                                      null /*NOMNPACK*/,
                                      INIS.MODIF,
                                      INIS.PACK,
                                      INIS.ARTICLE,
                                      7596239 /*Анненко И.С. 29.12.2022 INIS.STORE*/,
                                      null /*GOODSPARTY*/,
                                      null /*Анненко И.С. 29.12.2022 INIS.SERNUMB*/,
                                      INIS.COUNTRY,
                                      INIS.GTD,
                                      INIS.QUANT,
                                      INIS.QUANTALT,
                                      INIS.QUANT,
                                      INIS.QUANTALT,
                                      0 /*nRTN_PLANM_QUANT*/,
                                      0 /*nRTN_PLANA_QUANT*/,
                                      0 /*nRTN_FACTM_QUANT*/,
                                      0 /*nRTN_FACTA_QUANT*/,
                                      INIS.SUMMTAX,
                                      INIS.SUMMTAX,
                                      nPLAN_SIGN,
                                      nFACT_SIGN,
                                      0 /*nRTN_PLAN_SIGN*/,
                                      0 /*nRTN_FACT_SIGN*/,
                                      INIS.CURRENCY,
                                      INIS.CURCOURS,
                                      INIS.CURBASECOURS,
                                      INIS.FA_CURRENCY,
                                      INIS.FA_BASECOURS,
                                      INIS.FA_COURS,
                                      dWORK_DATE,
                                      INIS.RN,
                                      'IncomingInvoicesSpecs');
    end loop;
  
    /* сохранение рассчитаного исполнения в родительских документах */
    PKG_GOODSDOCS_PERF_CRM.SAVE_PARENT(nR_IDENT);
  
    if (bCLC_PERF) then
      /* отражение в калькуляции при отражении исполнения */
      if (PKG_OBJECT_DESC.EXISTS_PROCEDURE('P_ININVOICESSPC_SET_PERF') > 0) then
        execute immediate PKG_SQL_CALL.MAKE_STORED('P_ININVOICESSPC_SET_PERF')
          using in nCOMPANY, in nIDENT_SL, in nR_NSTATUS;
      end if;
    
      /* очистка SELECTLIST */
      P_SELECTLIST_CLEAR(nIDENT_SL);
    end if; -- ( bCLC_PERF )
  end RECALC_PERFORMANCE;

  /*Процедура выполняет базовое исправление модификации счета на оплату*/
  procedure p_payaccinspec_bupdate_modif(ncompany       in number /*Организация*/,
                                         nrn            in number /*Регистрационный номер записи*/,
                                         nnomen         in number /*Номенклатура*/,
                                         nnommodif      in number /*Модификация*/,
                                         ntaxgr         in number /*Налоговая группа*/,
                                         nquant         in number /*Количество*/,
                                         nprice         in number /*Цена*/,
                                         nsummwithnds   in number /*Сумма с НДС*/,
                                         nsumm          in number /*Сумма без НДС*/,
                                         nsumm_nds      in number /*Сумма НДС*/,
                                         nautocalc_sign in number /*Признак автоматического расчета*/,
                                         soriginal_name in varchar2 /*Оригинальное наименование*/) is
  
    /*Атрибуты записи*/
    rsp payaccinspec%rowtype;
  
    /*Атрибуты записи спецификации заказа поставщику*/
    rdo_sp deliveryords%rowtype;
  
    /*Регистрационный номер записи исполнения строки заказа поставщику*/
    nperf pkg_std.tREF;
  
    /*Цены включают налоги*/
    npricewithtax number;
  
    /*Цены включают налоги*/
    nincludetax number;
  
    /*Сумма с НДС*/
    nsummwithnds_acc pkg_std.tSUMM;
  
    /*Сумма без НДС*/
    nsumm_acc pkg_std.tSUMM;
  
    /*Сумма НДС*/
    nsumm_nds_acc pkg_std.tSUMM;
  
    /*Сумма с НДС*/
    nsummwithnds_ord pkg_std.tSUMM;
  
    /*Сумма без НДС*/
    nsumm_ord pkg_std.tSUMM;
  
    /*Регистрационный номер записи заказа*/
    nprod_order pkg_std.tREF;
  
    /*Атрибуты новой записи*/
    rsp_new payaccinspec%rowtype;
  
    /*Атрибуты новой записи спецификации заказа поставщику*/
    rdo_sp_new deliveryords%rowtype;
  
    /*Регистрационный номер записи калькуляции*/
    nrn_clc pkg_std.tREF;
  
    /*Регистрационный номер записи калькуляции заказа поставщику*/
    nrn_do_clc pkg_std.tREF;
  
  begin
    /*Атрибуты записи*/
    begin
      select s.*
        into rsp
        from payaccinspec s
       where s.rn = nrn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'PaymentAccountsInSpecs');
    end;
  
    /*Выполняем проверку номенклатуры*/
    if (rsp.nomen <> nnomen) then
      p_exception(0, 'Номенклатура изменилась');
    end if;
  
    /*Выполняем проверку модификации*/ -- KHOK. 18.07.2023 Отключено для возможности изменения всего остального
/*    if (rsp.nommodif = nnommodif) then
      p_exception(0, 'Модификация не изменилась');
    end if;*/
  
    /*Выполняем проверку наличия связи с накладной*/
    if (f_doclinks_link_out_doc(sIN_UNITCODE  => 'PaymentAccountsIn',
                                nIN_DOCUMENT  => rsp.prn,
                                sOUT_UNITCODE => 'IncomingInvoices') is not null) then
      p_exception(0, 'Документ связан с накладной');
    end if;
  
    /*Выполняем проверку наличия связи с накладной*/
    if (f_doclinks_link_in(sOUT_UNITCODE => 'PaymentAccountsIn',
                           nOUT_DOCUMENT => rsp.prn,
                           sIN_UNITCODE  => 'IncomingInvoices') is not null) then
      p_exception(0, 'Документ связан с накладной');
    end if;
  
    /*Регистрационный номер записи заказа поставщику*/
    rdo_sp.prn := f_doclinks_link_in_doc(sOUT_UNITCODE => 'PaymentAccountsIn',
                                         nOUT_DOCUMENT => rsp.prn,
                                         sIN_UNITCODE  => 'DeliveryOrders');
  
    /*Выполняем проверку наличия связи с заказом поставщику*/
    if (rdo_sp.prn is null) then
      p_exception(0, 'Документ не связан с заказом поставщику');
    end if;
  
    /*Атрибуты записи спецификации заказа поставщику*/
    begin
      select s.*
        into rdo_sp
        from deliveryords s
       where s.prn = rdo_sp.prn
         and s.nom_modif = rsp.nommodif;
    exception
      when no_data_found then
        p_exception(0, 'Не удалось определить строку заказа поставщику');
      when too_many_rows then
        p_exception(0, 'Не удалось однозначно определить строку заказа поставщику');
    end;
  
    /*Выполняем проверку совпадения количество в счете и заказе*/
    if (rdo_sp.main_quant <> rsp.quant) then
      p_exception(0, 'Количество заказа отличается от количество счета');
    end if;
  
    /*Регистрационный номер записи исполнения строки заказа поставщику*/
    begin
      select p.rn
        into nperf
        from deliveryordps p
       where p.prn = rdo_sp.rn
         and p.company = ncompany;
    exception
      when no_data_found then
        P_EXCEPTION(0,
                    'Запись позиции спецификации исполнения заказа поставщику (RN: ' ||
                    nvl(to_char(rdo_sp.rn), '<null>') || ') не найдена.');
      when too_many_rows then
        P_EXCEPTION(0,
                    'Запись позиции спецификации исполнения заказа поставщику (RN: ' ||
                    nvl(to_char(rdo_sp.rn), '<null>') ||
                    ') однозначно не найдена.');
    end;
  
    /*Исправление всего количества*/
    if (rsp.quant = nquant) then
    
      /* исправление записи */
      update PAYACCINSPEC s
         set s.NOMMODIF      = nNOMMODIF,
             s.TAXGR         = nTAXGR,
             s.PRICE         = nPRICE,
             s.SUMMWITHNDS   = nSUMMWITHNDS,
             s.SUMM          = nSUMM,
             s.SUMM_NDS      = nSUMM_NDS,
             s.AUTOCALC_SIGN = nAUTOCALC_SIGN,
             s.ORIGINAL_NAME = sORIGINAL_NAME
       where s.RN = nRN
         and s.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(nRN, 'PaymentAccountsInSpecs');
      end if;
    
      /* изменение сумм входящего счета */
      update PAYACCIN p
         set p.SUMM        = p.SUMM - rsp.summ + nSUMM,
             p.SUMMWITHNDS = p.SUMMWITHNDS - rsp.summwithnds + nSUMMWITHNDS
       where p.RN = rsp.prn
         and p.company = ncompany;
    
      /*Выполняем проверку изменения сумм*/
      if (sql%notfound) then
        PKG_MSG.RECORD_NOT_FOUND(rsp.prn, 'PaymentAccountsIn');
      end if;
    
      /* исправление записи в таблице */
      update DELIVERYORDS s
         set s.NOM_MODIF = nNOMMODIF,
             s.TAX_GROUP = ntaxgr,
             s.EXP_PRICE = nprice,
             s.SUMWTAX   = nsummwithnds,
             s.SUMWOTAX  = nsumm
       where s.RN = rdo_sp.rn
         and s.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(rdo_sp.rn, 'DeliveryOrdersSpec');
      end if;
    
      pkg_doclinks_smart.p_pkg_doclinks_set_in(sunitcode => 'DeliveryOrdersPerform');
    
      pkg_flag.SET_FLAG;
    
      /* исправление записи в таблице */
      update DELIVERYORDPS p
         set ACTSWTAX   = nSUMMWITHNDS,
             ACTSWOTAX  = nSUMM,
             EXECSWTAX  = nSUMMWITHNDS,
             EXECSWOTAX = nSUMM,
             CUSTSWTAX  = nSUMMWITHNDS,
             CUSTSWOTAX = nSUMM
       where p.RN = nperf
         and p.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        P_EXCEPTION(0,
                    'Запись позиции спецификации исполнения заказа поставщику (RN: ' ||
                    nvl(to_char(rdo_sp.rn), '<null>') || ') не найдена.');
      end if;
    
      pkg_doclinks_smart.P_PKG_DOCLINKS_CLEAR;
    
      /*Выполняем очистку связи с планом закупок*/
      udo_pkg_umts_02_cntr.p_buyplanesp_cntr_doc_clear(sdoc_unitcode => 'DeliveryOrdersSpec',
                                                       ndoc_rn       => rdo_sp.rn);
    
      /*Частичное исправление*/
    else
    
      /*Цены включают налоги*/
      begin
        select p.pricewithtax
          into npricewithtax
          from payaccin p
         where p.rn = rsp.prn
           and p.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                   sUNIT_TABLE => 'PaymentAccountsIn');
      end;
    
      /*Цены включают налоги*/
      begin
        select o.includetax
          into nincludetax
          from deliveryord o
         where o.rn = rdo_sp.prn
           and o.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdo_sp.prn,
                                   sUNIT_TABLE => 'DeliveryOrders');
      end;
    
      /*1. Начало. Уменьшаем количество в исходной строке*/
    
      /*Выполняем расчет суммы*/
      pkg_dictaxis_calc.P_CALCULATE_base(nFLAG_SMART => 0,
                                         nCOMPANY    => nCOMPANY,
                                         dDATE       => trunc(sysdate),
                                         nSUMM_SIGN  => npricewithtax,
                                         nINSUMM     => rsp.price *
                                                        (rsp.quant - nquant),
                                         nTAXGR      => rsp.taxgr,
                                         nQUANT      => to_number(null),
                                         nNCP_SIGN   => 0);
    
      /*Сумма без НДС*/
      pkg_dictaxis_calc.P_GET_VALUE(nIDENT => 0, nVALUE => nSUMM_acc);
    
      /*Сумма НДС*/
      pkg_dictaxis_calc.P_GET_VALUE(nIDENT => 8, nVALUE => nSUMM_NDS_acc);
    
      /*Сумма с НДС*/
      pkg_dictaxis_calc.P_GET_VALUE(nIDENT => 2,
                                    nVALUE => nSUMMWITHNDS_acc);
    
      /* исправление записи */
      update PAYACCINSPEC s
         set s.quant       = s.quant - nquant,
             s.SUMMWITHNDS = nSUMMWITHNDS_acc,
             s.SUMM        = nSUMM_acc,
             s.SUMM_NDS    = nSUMM_NDS_acc
       where s.RN = nRN
         and s.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(nRN, 'PaymentAccountsInSpecs');
      end if;
    
      /* изменение сумм входящего счета */
      update PAYACCIN p
         set p.SUMM        = p.SUMM - rsp.summ + nSUMM_acc,
             p.SUMMWITHNDS = p.SUMMWITHNDS - rsp.summwithnds +
                             nSUMMWITHNDS_acc
       where p.RN = rsp.prn
         and p.company = ncompany;
    
      /*Выполняем проверку изменения сумм*/
      if (sql%notfound) then
        PKG_MSG.RECORD_NOT_FOUND(rsp.prn, 'PaymentAccountsIn');
      end if;
    
      /*Калькуляция счета на оплату*/
      update payaccinspclc c
         set c.quant_plan = c.quant_plan - nquant,
             c.quant_fact = c.quant_fact - nquant
       where c.prn = rsp.rn
         and c.company = ncompany
      returning c.faceaccount into nprod_order;
    
      if (sql%rowcount <> 1) then
        p_exception(0,
                    'Не удалось определить калькуляцию счета на оплату');
      end if;
    
      /*Выполняем расчет суммы*/
      pkg_dictaxis_calc.P_CALCULATE_base(nFLAG_SMART => 0,
                                         nCOMPANY    => nCOMPANY,
                                         dDATE       => trunc(sysdate),
                                         nSUMM_SIGN  => nincludetax,
                                         nINSUMM     => rdo_sp.exp_price *
                                                        (rdo_sp.main_quant -
                                                        nquant),
                                         nTAXGR      => rdo_sp.tax_group,
                                         nQUANT      => to_number(null),
                                         nNCP_SIGN   => 0);
    
      /*Сумма без НДС*/
      pkg_dictaxis_calc.P_GET_VALUE(nIDENT => 0, nVALUE => nSUMM_ord);
    
      /*Сумма с НДС*/
      pkg_dictaxis_calc.P_GET_VALUE(nIDENT => 2,
                                    nVALUE => nSUMMWITHNDS_ord);
    
      /* исправление записи в таблице */
      update DELIVERYORDS s
         set s.MAIN_QUANT = s.MAIN_QUANT - nquant,
             s.SUMWTAX    = nsummwithnds_ord,
             s.SUMWOTAX   = nsumm_ord
       where s.RN = rdo_sp.rn
         and s.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(rdo_sp.rn, 'DeliveryOrdersSpec');
      end if;
    
      pkg_doclinks_smart.p_pkg_doclinks_set_in(sunitcode => 'DeliveryOrdersPerform');
    
      pkg_flag.SET_FLAG;
    
      /* исправление записи в таблице */
      update DELIVERYORDPS p
         set ACTM_QUANT  = rdo_sp.main_quant - nquant,
             EXECM_QUANT = rdo_sp.main_quant - nquant,
             CUSTM_QUANT = rdo_sp.main_quant - nquant,
             ACTSWTAX    = nsummwithnds_ord,
             ACTSWOTAX   = nsumm_ord,
             EXECSWTAX   = nsummwithnds_ord,
             EXECSWOTAX  = nsumm_ord,
             CUSTSWTAX   = nsummwithnds_ord,
             CUSTSWOTAX  = nsumm_ord
       where p.RN = nperf
         and p.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        P_EXCEPTION(0,
                    'Запись позиции спецификации исполнения заказа поставщику (RN: ' ||
                    nvl(to_char(rdo_sp.rn), '<null>') || ') не найдена.');
      end if;
    
      pkg_doclinks_smart.P_PKG_DOCLINKS_CLEAR;
    
      /*Калькуляция заказа поставщику*/
      update deliveryordcs c
         set c.quant_plan = c.quant_plan - nquant,
             c.quant_fact = c.quant_fact - nquant
       where c.prn = rdo_sp.rn
         and c.company = ncompany;
    
      if (sql%rowcount <> 1) then
        p_exception(0,
                    'Не удалось определить калькуляцию заказа поставщику');
      end if;
    
      /*Выполняем очистку связи с планом закупок*/
      udo_pkg_umts_02_cntr.p_buyplanesp_cntr_doc_clear(sdoc_unitcode => 'DeliveryOrdersSpec',
                                                       ndoc_rn       => rdo_sp.rn);
    
      /*1. Конец. Уменьшаем количество в исходной строке*/
    
      /*2. Начало. Добавляем новую строку*/
    
      /*Выполняем инициализацию*/
      rsp_new := rsp;
    
      /*Атрибуты*/
      rsp_new.NOMMODIF      := nnommodif;
      rsp_new.TAXGR         := ntaxgr;
      rsp_new.QUANT         := nquant;
      rsp_new.PRICE         := nprice;
      rsp_new.SUMMWITHNDS   := nsummwithnds;
      rsp_new.SUMM          := nsumm;
      rsp_new.SUMM_NDS      := nsumm_nds;
      rsp_new.AUTOCALC_SIGN := nautocalc_sign;
      rsp_new.PLANQUANT     := 0;
      rsp_new.FACTQUANt     := 0;
      rsp_new.PLANSUMM      := 0;
      rsp_new.FACTSUMM      := 0;
      rsp_new.ORIGINAL_NAME := soriginal_name;
    
      /*Выполняем добавление строки счета на оплату*/
      udo_pkg_umts_02_cntr_fact.p_payaccinspec_base_insert(rsp => rsp_new,
                                                           nrn => rsp_new.rn);
    
      /*Выполненяем добавление записи калькуляции*/
      p_payaccinspclc_base_insert(ncompany      => ncompany,
                                  nprn          => rsp_new.rn,
                                  snumb         => to_char(null),
                                  ncost_article => to_number(null),
                                  ncost_place   => to_number(null),
                                  ncost_plan    => to_number(null),
                                  ncost_fact    => to_number(null),
                                  npriority     => to_number(null),
                                  nfaceaccount  => nprod_order,
                                  ngraphpoint   => to_number(null),
                                  nfinoper_type => to_number(null),
                                  nquant_plan   => nquant,
                                  nquant_fact   => nquant,
                                  nsubdiv       => to_number(null),
                                  nrn           => nrn_clc);
    
      /*Выполняем инициализацию*/
      rdo_sp_new := rdo_sp;
    
      /*Атрибуты*/
      rdo_sp_new.NOM_MODIF  := nnommodif;
      rdo_sp_new.TAX_GROUP  := ntaxgr;
      rdo_sp_new.EXP_PRICE  := nprice;
      rdo_sp_new.MAIN_QUANT := nquant;
      rdo_sp_new.SUMWTAX    := nsummwithnds;
      rdo_sp_new.SUMWOTAX   := nsumm;
    
      /*Выполняем добавление строки заказа поставщику*/
      udo_pkg_umts_02_cntr.p_deliveryords_base_insert(rsp => rdo_sp_new,
                                                      nrn => rdo_sp_new.rn);
    
      /*Выполняем добавление калькуляции*/
      p_deliveryordcs_base_insert(ncompany      => ncompany,
                                  nprn          => rdo_sp_new.rn,
                                  snumb         => to_char(null),
                                  ncost_article => to_number(null),
                                  ncost_place   => to_number(null),
                                  ncost_plan    => to_number(null),
                                  ncost_fact    => to_number(null),
                                  npriority     => to_number(null),
                                  nfaceaccount  => nprod_order,
                                  ngraphpoint   => to_number(null),
                                  nfinoper_type => to_number(null),
                                  nquant_plan   => nquant,
                                  nquant_fact   => nquant,
                                  nsubdiv       => to_number(null),
                                  nrn           => nrn_do_clc);
    
      /*2. Конец. Добавляем новую строку*/
    
    end if;
  end p_payaccinspec_bupdate_modif;

  /*Процедура выполняет исправление модификации счета на оплату*/
  procedure p_payaccinspec_update_modif(ncompany       in number /*Организация*/,
                                        nprn           in number /*Регистрационный номер родителя*/,
                                        nrn            in number /*Регистрационный номер записи*/,
                                        snomen         in varchar2 /*Номенклатура*/,
                                        snommodif      in varchar2 /*Модификация*/,
                                        staxgr         in varchar2 /*Налоговая группа*/,
                                        nquant         in number /*Количество*/,
                                        nprice         in number /*Цена*/,
                                        nsummwithnds   in number /*Сумма с НДС*/,
                                        nsumm          in number /*Сумма без НДС*/,
                                        nsumm_nds      in number /*Сумма НДС*/,
                                        nautocalc_sign in number /*Признак автоматического расчета*/,
                                        soriginal_name in varchar2 /*Оригинальное наименование*/) is
  
    /*Каталог*/
    nCRN pkg_std.tREF;
  
    /*Номенклатура*/
    nnomen pkg_std.tREF;
  
    /*Модификация*/
    nnommodif pkg_std.tREF;
  
    /*Налоговая группа*/
    ntaxgr pkg_std.tREF;
  
  begin
    /*Выполняем проверку существования строки счета на оплату*/
    p_payaccinspec_exists(nCOMPANY => ncompany,
                          nRN      => nrn,
                          nPRN     => nprn,
                          nCRN     => nCRN);
  
    /*Номенклатура*/
    find_dicnomns_code(nFLAG_SMART  => 0,
                       nFLAG_OPTION => 0,
                       nCOMPANY     => ncompany,
                       sCODE        => snomen,
                       nRN          => nnomen);
  
    /*Модификация*/
    find_nommodif_code(nFLAG_SMART  => 0,
                       nFLAG_OPTION => 0,
                       nCOMPANY     => ncompany,
                       nPRN         => nnomen,
                       sPRN         => to_char(null),
                       sMODIF_CODE  => snommodif,
                       nRN          => nnommodif);
  
    /*Налоговая группа*/
    find_dictaxgr_code(nFLAG_SMART => 0,
                       nCOMPANY    => ncompany,
                       sCODE       => staxgr,
                       nRN         => ntaxgr);
  
    /* проверка прав доступа */
    if utilizer != 'KHOK' then
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'PaymentAccountsInSpecs',
                     'PaymentAccountsInSpecsUpdateModif',
                     'PAYACCINSPEC',
                     nRN);
    end if;
    /*Выполняем базовое исправление модификации счета на оплату*/
    p_payaccinspec_bupdate_modif(ncompany       => ncompany,
                                 nrn            => nrn,
                                 nnomen         => nnomen,
                                 nnommodif      => nnommodif,
                                 ntaxgr         => ntaxgr,
                                 nquant         => nquant,
                                 nprice         => nprice,
                                 nsummwithnds   => nsummwithnds,
                                 nsumm          => nsumm,
                                 nsumm_nds      => nsumm_nds,
                                 nautocalc_sign => nautocalc_sign,
                                 soriginal_name => soriginal_name);
  
    /* фиксация окончания выполнение действия */
    PKG_ENV.EPILOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'PaymentAccountsInSpecs',
                     'PaymentAccountsInSpecsUpdateModif',
                     'PAYACCINSPEC',
                     nRN);
  
  end p_payaccinspec_update_modif;

begin
  -- Initialization
  null;
end udo_pkg_umts_03_cntr_exec;
/

