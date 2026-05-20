create or replace package udo_pkg_umts_monitor_supply is

  --create public synonym udo_pkg_umts_monitor_supply for udo_pkg_umts_monitor_supply;

  --grant execute on udo_pkg_umts_monitor_supply to public;

  -- Author  : I.ANNENKO
  -- Created : 02.01.2023 11:52:46
  -- Purpose : УМТС. Мониторинг снабжения

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  /*Процедура выполняет переформирование раздела*/
  procedure p_recreate(ncompany  in number /*Организация*/,
                       sunitcode in varchar2 /*Код раздела*/,
                       nident    in number /*Идентификатор помеченных записей*/,
                       stheme    in varchar2 /*Тема*/,
                       nstate0   in number /*Не утвержден*/,
                       nstate1   in number /*Утвержден*/,
                       nstate2   in number /*Согласование*/,
                       nstate3   in number /*Закрыт*/,
                       nstate4   in number /*Аннулирован*/,
                       nsign_ful in number default 0 /*Показать сводную*/);

  /*Процедура выполняет заполнение списка документов по помеченным записям*/
  procedure p_calc_doc_list(nident     in number /*Идентификатор помеченных записей*/,
                            sunitcode  in varchar2 /*Код раздела*/,
                            nident_doc out number /*Идентификатор документов*/);

end udo_pkg_umts_monitor_supply;
/
create or replace package body udo_pkg_umts_monitor_supply is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*Процедура определяет каталог*/
  procedure p_calc_crn(ncompany in number /*Организация*/,
                       nrn      in number /*Регистрационный номер записи номенклатуры*/,
                       ncrn     out number /*Каталог*/) is
  
    /*Группа номенклатуры*/
    sgrp pkg_std.tSTRING;
  
  begin
    /*Импорт*/
    /* 17/09/2024 Марков МВ. строго по группе УМТС номенклатуры!!!
    if (lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'Nomenclator',
                                  nDOCUMENT => nrn,
                                  sPROPCODE => 'УМТС_Импорт'))) = 'да') then
    
      ncrn := 2;
    
      return;
    end if;*/
  
    /*Группа номенклатуры*/
    sgrp := prsg_prop.SGET(nCOMPANY  => ncompany,
                           nVERSION  => to_number(null),
                           sUNITCODE => 'Nomenclator',
                           nDOCUMENT => nrn,
                           sPROPCODE => 'УМТС_ГруппаНомен');
  
    /*Каталог*/
    begin
      select c.nrn
        into ncrn
        from udo_v_umts_monitor_supply_cat c
       where substr(c.sname, 5) = sgrp;
    exception
      when no_data_found then
        ncrn := 1;
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить каталог');
    end;
  end p_calc_crn;

  /*Процедура выполняет добавление указанной строки заказа подразделения в спецификацию раздела*/
  procedure p_add_dep_ord_sp(ncompany  in number /*Организация*/,
                             nrn       in number /*Регистрационный номер записи*/,
                             nident    in number /*Идентификатор помеченных записей*/,
                             nsign_ful in number default 0 /*Показать сводную*/
                             ) is
  
    /*Атрибуты записи*/
    rdep_ord_sp departmentords%rowtype;
  
    /*Атрибуты записи*/
    rsp    udo_umts_monitor_supply%rowtype;
    rsp_sp udo_umts_monitor_supply_sp%rowtype;
  
    /*Дата включения в план закупок*/
    dplan_date date;
    
    /* Потребность */
    nFcPrExpAct   pkg_std.tref; 
  
    ntmp number;
  
  begin
    /*Атрибуты записи*/
    begin
      select s.*
        into rdep_ord_sp
        from departmentords s
       where s.rn = nrn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;
    
    /*Дубль*/
    if (cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rdep_ord_sp.company,
                                          nVERSION  => to_number(null),
                                          sUNITCODE => 'DepartmentsOrdersSpecs',
                                          nDOCUMENT => rdep_ord_sp.rn,
                                          sPROPCODE => 'УМТС_Дубль'))),
                'да') = 1) then
      return;
    end if;
  
    if (rdep_ord_sp.main_quant = 0) then
      return;
    end if;
  
    /*Если не указана модификация, то выдаем сообщение об ошибке*/
    if (rdep_ord_sp.nom_modif is null) then
      p_exception(0,
                  'Не указана модификация для заказа ' ||
                  f_docdescrs_describe(nCOMPANY  => ncompany,
                                       sUNITCODE => 'DepartmentsOrders',
                                       nRN       => nrn) ||
                  ', номенклатура ' ||
                  f_dicnomns_get_code(nNOMEN => rdep_ord_sp.nomen));
    end if;
  
    /*Регистрационный номер записи*/
    rsp.rn := nrn;

    /*Каталог*/
    p_calc_crn(ncompany => ncompany,
               nrn      => rdep_ord_sp.nomen,
               ncrn     => rsp.crn);
  
    /*Дата включения в план закупок*/
    dplan_date := prsg_prop.dGET(nCOMPANY  => ncompany,
                                 nVERSION  => to_number(null),
                                 sUNITCODE => 'DepartmentsOrdersSpecs',
                                 nDOCUMENT => nrn,
                                 sPROPCODE => 'УМТС_ДатаВклПЗ');
  
    /* Количество Заявлено (из заказа подразделения) */
    rsp.main_quant := rdep_ord_sp.main_quant;
    
    /* Модификация потребности */
    rsp.modif := rdep_ord_sp.nom_modif;
    
    /*Зарезервировано с остатков*/
    udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY         => ncompany,
                                                      NRN              => nrn,
                                                      DPLAN_DATE_BEGIN => nvl(dplan_date,
                                                                              trunc(sysdate)),
                                                      NQUANT_PERF      => rsp.quant_rest_res,
                                                      NQUANT_PERF_ALT  => ntmp);
  
    /*Выдано с остатков*/
    udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_EXEC_QNT(NCOMPANY         => ncompany,
                                                       NRN              => nrn,
                                                       DPLAN_DATE_BEGIN => nvl(dplan_date,
                                                                               trunc(sysdate)),
                                                       NQUANT_PERF      => rsp.quant_rest_inv,
                                                       NQUANT_PERF_ALT  => ntmp);
  
    /*Количество, включенное в план закупок*/
    rsp.quant_bp := udo_f_departmentords_incl_bp(nrn => nrn);
  
    /*Количество, к включению в план закупок*/
    rsp.quant_to_bp := greatest(0,
                                udo_f_departmentords_to_bp(nrn      => nrn,
                                                           ncompany => ncompany));
  
    /*Минимальная дата поставки*/
    select min(nvl(udo_pkg_umts_04_perf.f_buyplanespref_calc_pl_date_a(ncompany => r.company,
                                                                       nrn      => r.rn),
                   prsg_prop.dGET(nCOMPANY  => r.company,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'BuyPlaneSpecsReferences',
                                  nDOCUMENT => r.rn,
                                  sPROPCODE => 'УМТС_ПланДатаПост')))
      into rsp.plan_date_min
      from buyplanespref r
     where r.deptordsp = nrn
       and r.quant_plan > 0 -- 07/11/2023 Марков МВ. нулевые не нужны, так как есть переносы
       ;
  
    /*Максимальная дата поставки*/
    select max(nvl(udo_pkg_umts_04_perf.f_buyplanespref_calc_pl_date_a(ncompany => r.company,
                                                                       nrn      => r.rn),
                   prsg_prop.dGET(nCOMPANY  => r.company,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'BuyPlaneSpecsReferences',
                                  nDOCUMENT => r.rn,
                                  sPROPCODE => 'УМТС_ПланДатаПост')))
      into rsp.plan_date_max
      from buyplanespref r
     where r.deptordsp = nrn
       and r.quant_plan > 0 -- 29/05/2024 KHOK нулевые не нужны, так как есть переносы
     ;
  
    /*Количество, включенное в заказ поставщику*/
    select nvl(sum(udo_f_buyplanespref_quant_cntr(nrn      => r.rn,
                                                  ncompany => ncompany)),
               0)
      into rsp.quant_do
      from buyplanespref r
     where r.deptordsp = nrn;
  
    /*Номер счета на оплату*/
    for acc_cursor in (select p.ext_numb --,
                       --p.doc_date as ddoc_date,
                       
                       /* case
                         when p.DOC_STATE = 2 then
                          'Аннулирован'
                         else
                          (select ST.sEVENT_STAT
                             from V_CLNEVENTS_STATMOD ST
                            where ST.sLINKED_UNIT = 'PaymentAccountsIn'
                              and ST.nLINKED_RN = p.RN)
                       end as sstatus,
                       case
                         when nvl(p.FACTPAYSUMM, 0) > 0 and
                              nvl(p.FACTPAYSUMM, 0) >= p.SUMMWITHNDS then
                          'Полностью оплачен'
                         when nvl(p.FACTPAYSUMM, 0) > 0 and
                              nvl(p.FACTPAYSUMM, 0) < p.SUMMWITHNDS then
                          'Частично оплачен'
                         else
                          'Не оплачен'
                       end as spay_status*/
                         from payaccin p
                        where p.rn in
                              (
                               --
                               select ps.prn
                                 from buyplanespref                  r,
                                       udo_uzd_03_buyplanesp_cntr_doc c,
                                       deliveryords                   ds,
                                       doclinks                       l,
                                       payaccinspec                   ps
                                where r.deptordsp = nrn
                                  and c.prn = r.prn
                                  and c.rn_ref = r.rn
                                  and ds.rn = c.doc_rn
                                  and c.doc_unitcode = 'DeliveryOrdersSpec'
                                  and l.in_document = ds.prn
                                  and l.out_document = ps.prn
                                  and ps.nommodif = ds.nom_modif
                               --
                               union all
                               --
                               select ps.prn
                                 from buyplanespref                  r,
                                       udo_uzd_03_buyplanesp_cntr_doc c,
                                       deliveryords                   ds,
                                       doclinks                       l1,
                                       doclinks                       l2,
                                       payaccinspec                   ps
                                where r.deptordsp = nrn
                                  and c.prn = r.prn
                                  and c.rn_ref = r.rn
                                  and ds.rn = c.doc_rn
                                  and c.doc_unitcode = 'DeliveryOrdersSpec'
                                  and l1.in_document = ds.prn
                                  and l2.in_document = l1.out_document
                                  and l2.out_document = ps.prn
                                  and ps.nommodif = ds.nom_modif
                               --
                               )) loop
      if (rsp.pay_acc_numb is not null) then
        rsp.pay_acc_numb := rsp.pay_acc_numb || ';';
      end if;
    
      rsp.pay_acc_numb := rsp.pay_acc_numb || acc_cursor.ext_numb
      --|| ' от ' ||                          to_char(acc_cursor.ddoc_date, 'dd.mm.yyyy') ||
      --                    ' Состояние: ' || acc_cursor.sstatus ||
      --                    ' Состояние оплаты: ' || acc_cursor.spay_status
       ;
    end loop;
--if utilizer = 'KHOK' and rsp.pay_acc_numb is not null then p_exception(0,nvl(rsp.pay_acc_numb, 'null')); end if;

    /*Дата счета на оплату*/
    select min(udo_f_buyplanespref_acc_date(nrn      => r.rn,
                                            ncompany => ncompany))
      into rsp.pay_acc_date
      from buyplanespref r
     where r.deptordsp = nrn;
  
    /*Дней поставки*/
    select min(udo_f_buyplanespref_del_days(nrn      => r.rn,
                                            ncompany => ncompany))
      into rsp.sup_days
      from buyplanespref r
     where r.deptordsp = nrn;
  
    /*Количество поставлено*/
    select nvl(min(udo_f_buyplanespref_quant_inv(nrn      => r.rn,
                                                 ncompany => ncompany)),
               0)
      into rsp.quant_inc
      from buyplanespref r
     where r.deptordsp = nrn;
  
    /*Количество зарезервировано с закупки*/
    rsp.quant_res := 0;
  
    /*Количество выдано с закупки*/
    rsp.quant_inv := 0;
  
    /*Цикл по строкам плана закупок*/
    for ref_cursor in (select r.rn as nrn,
                               to_number(null) as nquant_res,
                               to_number(null) as nquant_exec,
                               to_number(null) as nquant_alt_res,
                               to_number(null) as nquant_alt_exec
                         from buyplanespref r
                        where r.deptordsp = nrn
                       ) loop
      /*Зарезервировано*/
      udo_pkg_umts_04_perf.p_buyplanespref_calc_quant_res(ncompany   => ncompany,
                                                          nrn        => ref_cursor.nrn,
                                                          nquant     => ref_cursor.nquant_res,
                                                          nquant_alt => ref_cursor.nquant_alt_res);
    
      /*Выдано*/
      udo_pkg_umts_04_perf.p_buyplanespref_calc_quant_ex(ncompany   => ncompany,
                                                         nrn        => ref_cursor.nrn,
                                                         nquant     => ref_cursor.nquant_exec,
                                                         nquant_alt => ref_cursor.nquant_alt_exec);
    
      /*Количество зарезервировано в периоде планирования*/
      rsp.quant_res := rsp.quant_res + ref_cursor.nquant_res;
    
      /*Количество выдано в периоде планирования*/
      rsp.quant_inv := rsp.quant_inv + ref_cursor.nquant_exec;
    end loop;
  
    /*Модификация исходной потребности (в случае замен)*/
    begin
      select s.modif
        into rsp.rn_modif_orig
        from UDO_DEPORDDIR d, UDO_DEPORDDIR_SP s, UDO_DEPORDDIR_CHNG c
       where d.depord = rdep_ord_sp.prn
         and d.state = 1
         and s.prn = d.rn
         and c.prn = s.rn
         and c.modif_chng = rdep_ord_sp.nom_modif
         and rownum = 1 -------!!!!!Столярский Е.З Ошибка по кол-ву записей
       group by s.modif;
    exception
      when no_data_found then
        rsp.rn_modif_orig := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить исходную потребность для позиции ' ||
                    udo_get_nommodif_code_id(nFLAG_SMART => 0,
                                             nRN         => rdep_ord_sp.nom_modif) ||
                    ' заявки на снабжение ' ||
                    f_docdescrs_describe(nCOMPANY     => ncompany,
                                         sUNITCODE    => 'DepartmentsOrders',
                                         nRN          => rdep_ord_sp.prn,
                                         nRETURN_NULL => 0) || ' rn = ' ||
                    to_char(nrn));
    end;
  
    /*Анненко И.С. 07.02.2023 Старый вариант ведения ведомости замен*/
    if (rsp.rn_modif_orig is null) then
    
      begin
        select s.modif
          into rsp.rn_modif_orig
          from UDO_DEPORDDIR d, UDO_DEPORDDIR_SP s
         where d.depord = rdep_ord_sp.prn
           and d.state = 1
           and s.prn = d.rn
           and s.modif_chng = rdep_ord_sp.nom_modif
           and not exists
         (select 1 from UDO_DEPORDDIR_CHNG c where c.prn = s.rn)
           and rownum = 1
         group by s.modif;
      exception
        when no_data_found then
          rsp.rn_modif_orig := to_number(null);
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить исходную потребность для позиции ' ||
                      udo_get_nommodif_code_id(nFLAG_SMART => 0,
                                               nRN         => rdep_ord_sp.nom_modif) ||
                      ' заявки на снабжение ' ||
                      f_docdescrs_describe(nCOMPANY     => ncompany,
                                           sUNITCODE    => 'DepartmentsOrders',
                                           nRN          => rdep_ord_sp.prn,
                                           nRETURN_NULL => 0) || ' rn = ' ||
                      to_char(nrn));
      end;
    
    end if;
  
    /*Номер договора*/ -- KHOK
    for cntr_cursor in (select distinct c.ext_number
                          from contracts c
                         where c.rn in
                               (
                                --
                                select stg.prn
                                  from buyplanespref                  r,
                                        udo_uzd_03_buyplanesp_cntr_doc c,
                                        deliveryords                   ds,
                                        deliveryord                    o,
                                        stages                         stg
                                 where r.deptordsp = nrn
                                   and c.prn = r.prn
                                   and c.rn_ref = r.rn
                                   and ds.rn = c.doc_rn
                                   and c.doc_unitcode = 'DeliveryOrdersSpec'
                                   and o.rn = ds.prn
                                   and stg.faceacc = o.faceacc
                                --
                                )
                         order by c.ext_number
      ) loop
      if (cntr_cursor.ext_number is not null) then
        if (rsp.contract is not null) then
          rsp.contract := rsp.contract || ';';
        end if;
      
        rsp.contract := rsp.contract || cntr_cursor.ext_number;
      end if;
    end loop;
  
    /*Внешний номер заказа поставщику*/
    for del_ord_cursor in (select do.delivdocnumb
                             from deliveryord do
                            where do.rn in (
                                            --
                                            select ds.prn
                                              from buyplanespref                  r,
                                                    udo_uzd_03_buyplanesp_cntr_doc c,
                                                    deliveryords                   ds
                                             where r.deptordsp = nrn
                                               and c.prn = r.prn
                                               and c.rn_ref = r.rn
                                               and ds.rn = c.doc_rn
                                               and c.doc_unitcode =
                                                   'DeliveryOrdersSpec'
                                            --
                                            )) loop
      if (del_ord_cursor.delivdocnumb is not null) then
        if (rsp.do_ext_numb is not null) then
          rsp.do_ext_numb := rsp.do_ext_numb || ';';
        end if;
      
        rsp.do_ext_numb := rsp.do_ext_numb || del_ord_cursor.delivdocnumb;
      end if;
    end loop;
  
    /*Сумма*/
    select nvl(sum(case
                     when (ds.main_quant = 0) then
                      (0)
                     else
                      (least(c.quant_plan, ds.main_quant) *--/ ds.main_quant *
                       case
                         when (select count(*) from doclinks l, payaccinspec pis
                                where l.in_document = ds.prn and l.in_unitcode = 'DeliveryOrders'
                                  and l.out_document = pis.prn
                                  and l.out_unitcode = 'PaymentAccountsIn'
                                  and pis.nommodif = ds.nom_modif) > 0 then
                           (select nvl(sum(pis.summwithnds)/sum(pis.quant), 0) from doclinks l, payaccinspec pis
                                where l.in_document = ds.prn and l.in_unitcode = 'DeliveryOrders'
                                  and l.out_document = pis.prn
                                  and l.out_unitcode = 'PaymentAccountsIn'
                                  and pis.nommodif = ds.nom_modif)
                         else
                           ds.sumwtax
                       end
                      )
                   end),
               0)
      into rsp.sum_total
      from buyplanespref                  r,
           udo_uzd_03_buyplanesp_cntr_doc c,
           deliveryords                   ds
     where r.deptordsp = nrn
       and c.prn = r.prn
       and c.rn_ref = r.rn
       and ds.rn = c.doc_rn
       and c.doc_unitcode = 'DeliveryOrdersSpec';
  
    /*Фактическая дата оплаты*/
    select min(pn.pay_date)
      into rsp.fact_pay_date
      from payaccin p, doclinks l, paynotes pn
     where p.rn in (
                    --
                    select ps.prn
                      from buyplanespref                  r,
                            udo_uzd_03_buyplanesp_cntr_doc c,
                            deliveryords                   ds,
                            doclinks                       l,
                            payaccinspec                   ps
                     where r.deptordsp = nrn
                       and c.prn = r.prn
                       and c.rn_ref = r.rn
                       and ds.rn = c.doc_rn
                       and c.doc_unitcode = 'DeliveryOrdersSpec'
                       and l.in_document = ds.prn
                       and l.out_document = ps.prn
                       and ps.nommodif = ds.nom_modif
                    --
                    union all
                    --
                    select ps.prn
                      from buyplanespref                  r,
                            udo_uzd_03_buyplanesp_cntr_doc c,
                            deliveryords                   ds,
                            doclinks                       l1,
                            doclinks                       l2,
                            payaccinspec                   ps
                     where r.deptordsp = nrn
                       and c.prn = r.prn
                       and c.rn_ref = r.rn
                       and ds.rn = c.doc_rn
                       and c.doc_unitcode = 'DeliveryOrdersSpec'
                       and l1.in_document = ds.prn
                       and l2.in_document = l1.out_document
                       and l2.out_document = ps.prn
                       and ps.nommodif = ds.nom_modif
                    --
                    )
       and l.in_document = p.rn
       and pn.rn = l.out_document
       and pn.signplan = 0;
  
    /*Примечание*/
    for note_cursor in (
                        --
                        select distinct prsg_prop.SGET(nCOMPANY  => r.company,
                                                        nVERSION  => to_number(null),
                                                        sUNITCODE => 'BuyPlaneSpecsReferences',
                                                        nDOCUMENT => r.rn,
                                                        sPROPCODE => 'УМТС_Примечание') as snote
                          from buyplanespref r
                         where r.deptordsp = nrn
                        --
                        ) loop
      if (note_cursor.snote is not null) then
        if (rsp.note is not null) then
          rsp.note := rsp.note || ';';
        end if;
      
        rsp.note := rsp.note || note_cursor.snote;
      end if;
    end loop;
  
    /*Поставщик*/
    for agn_cursor in (select a.agnabbr as scode
                         from agnlist a
                        where a.rn in
                              (
                               --
                               select do.agent
                                 from buyplanespref                  r,
                                       udo_uzd_03_buyplanesp_cntr_doc c,
                                       deliveryords                   ds,
                                       deliveryord                    do
                                where r.deptordsp = nrn
                                  and c.prn = r.prn
                                  and c.rn_ref = r.rn
                                  and ds.rn = c.doc_rn
                                  and c.doc_unitcode = 'DeliveryOrdersSpec'
                                  and do.rn = ds.prn
                               --
                               )) loop
      if (agn_cursor.scode is not null) then
        if (rsp.ord_agent is not null) then
          rsp.ord_agent := rsp.ord_agent || ';';
        end if;
      
        rsp.ord_agent := rsp.ord_agent || agn_cursor.scode;
      end if;
    end loop;

    /* Тип записи "Без потребности" */
    rsp.type := 2;
  
    /* По спецификации связанной потребности с такой же номенклатурой */
    for c in (select null
                from doclinks       dl
                    ,fcprexpactmr   t
                    ,fcmatresource  fmr
               where dl.out_document  = rdep_ord_sp.prn
                 and dl.in_document   = t.prn
                 and t.matres         = fmr.rn
                 and fmr.nomen_modif  = rdep_ord_sp.nom_modif)
    loop
      /* если найдена, то тип записи "Без замен" */
      rsp.type := 0;
      exit;
    end loop;                 

    /* Если тип записи всё ещё "Без потребности" и была замена */
    if rsp.type = 2 and rsp.rn_modif_orig is not null then
      /* по спецификации связанной потребности с номенклатурой замены */
      for c in (select null
                  from doclinks       dl
                      ,fcprexpactmr   t
                      ,fcmatresource  fmr
                 where dl.out_document  = rdep_ord_sp.prn
                   and dl.in_document   = t.prn
                   and t.matres         = fmr.rn
                   and fmr.nomen_modif  = rsp.rn_modif_orig)
      loop
        /* если найдена, то тип записи "Замена" */
        rsp.type := 1;
        exit;
      end loop;                 
      
    end if;

    /*Выполняем добавление записи*/
    if nvl(nsign_ful,  0) = 0 then
      -- детализация
      insert into udo_umts_monitor_supply values rsp;
    else
      -- сводная
      rsp_sp.rn             := rsp.rn;
      rsp_sp.ident          := nident;
      rsp_sp.crn            := rsp.crn;
      rsp_sp.type           := rsp.type;
      rsp_sp.quant_rest_res := rsp.quant_rest_res;
      rsp_sp.quant_rest_inv := rsp.quant_rest_inv;
      rsp_sp.quant_bp       := rsp.quant_bp;
      rsp_sp.quant_to_bp    := rsp.quant_to_bp;
      rsp_sp.plan_date_min  := rsp.plan_date_min;
      rsp_sp.plan_date_max  := rsp.plan_date_max;
      rsp_sp.quant_do       := rsp.quant_do;
      rsp_sp.pay_acc_numb   := rsp.pay_acc_numb;
      rsp_sp.pay_acc_date   := rsp.pay_acc_date;
      rsp_sp.sup_days       := rsp.sup_days;
      rsp_sp.quant_inc      := rsp.quant_inc;
      rsp_sp.quant_res      := rsp.quant_res;
      rsp_sp.quant_inv      := rsp.quant_inv;
      rsp_sp.rn_modif_orig  := rsp.rn_modif_orig;
      rsp_sp.contract       := rsp.contract;
      rsp_sp.do_ext_numb    := rsp.do_ext_numb;
      rsp_sp.sum_total      := rsp.sum_total;
      rsp_sp.fact_pay_date  := rsp.fact_pay_date;
      rsp_sp.note           := rsp.note;
      rsp_sp.ord_agent      := rsp.ord_agent;
      rsp_sp.quant_dlvr_def := rsp.quant_dlvr_def;
      rsp_sp.quant_rest_vk  := rsp.quant_rest_vk;
      rsp_sp.po_numb        := rsp.po_numb;
      rsp_sp.ips_name       := rsp.ips_name;
      rsp_sp.nomen_agn      := rsp.nomen_agn;
      rsp_sp.nomen_imp      := rsp.nomen_imp;
      rsp_sp.nomen_grp      := rsp.nomen_grp;
      rsp_sp.main_quant     := rsp.main_quant;
      rsp_sp.modif          := rsp.modif;
      rsp_sp.authid         := utilizer;
--if utilizer = 'KHOK' and length(rsp_sp.contract) > 50 then p_exception(0,rsp_sp.contract); end if; 
      begin
        insert into udo_umts_monitor_supply_sp values rsp_sp;
/*      exception
        when others then
          null;*/
          --p_exception(0, 'Ошибка уникальности с RN = ' || rsp_sp.rn);
      end;
    end if;
  end p_add_dep_ord_sp;

  /* Процедура выполняет формирование сводной таблицы */
  procedure p_recreate_full(nident in number) is
    /*Атрибуты записи*/
    rsp udo_umts_monitor_supply%rowtype;

    spay_acc_numb varchar2(2000);
    sord_agent    varchar2(2000);
    sdo_ext_numb  varchar2(2000);
    scontract     varchar2(2000);
    snote         varchar2(2000);
    --fact_pay_date rsp.fact_pay_date%type;
    --pay_acc_date  rsp.pay_acc_date%type;
    --sup_days      rsp.sup_days%type;
  begin
    for rec_sp in (select sp.type,
                          sp.modif,
                          sp.rn_modif_orig,
                          min(sp.crn) as crn,
                          min(sp.plan_date_min) as plan_date_min,
                          max(sp.plan_date_max) as plan_date_max,
                          min(sp.pay_acc_date)  as pay_acc_date, 
                          min(sp.fact_pay_date) as fact_pay_date, 
                          min(sp.sup_days)      as sup_days,
                          nvl(sum(sp.quant_rest_res), 0) as quant_rest_res,
                          nvl(sum(sp.quant_rest_inv), 0) as quant_rest_inv,
                          nvl(sum(sp.quant_bp), 0)    as quant_bp,
                          nvl(sum(sp.quant_to_bp), 0) as quant_to_bp,
                          nvl(sum(sp.quant_do), 0)  as quant_do,
                          nvl(max(sp.quant_inc), 0) as quant_inc,
                          nvl(sum(sp.quant_res), 0) as quant_res,
                          nvl(sum(sp.quant_inv), 0) as quant_inv,
                          nvl(sum(sp.sum_total), 0) as sum_total,
                          nvl(sum(sp.quant_dlvr_def), 0) as quant_dlvr_def,
                          nvl(sum(sp.quant_rest_vk), 0)  as quant_rest_vk,
                          nvl(sum(sp.main_quant), 0)     as main_quant
                     from udo_umts_monitor_supply_sp sp
                    where sp.ident = nident
                      and sp.authid = utilizer
                    group by sp.type,
                             sp.modif,
                             sp.rn_modif_orig --, sp.pay_acc_numb
    ) loop

      begin
        select max(s.rn)
          into rsp.rn
          from udo_umts_monitor_supply_sp s
         where s.ident = nident
           and s.authid = utilizer
           and s.modif = rec_sp.modif
           /*and ((rec_sp.rn_modif_orig is null and s.rn_modif_orig is null) or 
                (s.rn_modif_orig = rec_sp.rn_modif_orig))*/;
      exception
        when no_data_found then
          p_exception(0, 'Ошибка определения строки заказа подразделения.');
      end;

      /* 29/02/2024. KHOK. Консолидация данных по счетам на оплату. Start */
      sord_agent := null; spay_acc_numb := null; sdo_ext_numb := null; scontract := null; snote := null;

      for rec_acc in (
        select distinct su.ord_agent
          from udo_umts_monitor_supply_sp su
         where su.ident  = nident
           and su.authid = utilizer
           and su.modif  = rec_sp.modif
           and ((rec_sp.rn_modif_orig is null and su.rn_modif_orig is null) or 
                (su.rn_modif_orig = rec_sp.rn_modif_orig))
           and su.ord_agent is not null
         --order by su.pay_acc_numb -- !!!
      ) loop
        if sord_agent is null then
          sord_agent := rec_acc.ord_agent;
        elsif length(sord_agent || rec_acc.ord_agent) < 1990 then
          sord_agent := sord_agent || '; ' || rec_acc.ord_agent;
        end if;
      end loop;
  
      for rec_acc in (
        select distinct su.pay_acc_numb/*||', '||to_char(su.pay_acc_date, 'dd.mm.yyyy') ||
                        ' ('||su.sup_days||')' as pay_acc_numb*/
          from udo_umts_monitor_supply_sp su
         where su.ident  = nident
           and su.authid = utilizer
           and su.modif  = rec_sp.modif
           and ((rec_sp.rn_modif_orig is null and su.rn_modif_orig is null) or 
                (su.rn_modif_orig = rec_sp.rn_modif_orig))
           and su.pay_acc_numb is not null
         --order by su.pay_acc_numb
      ) loop
        if spay_acc_numb is null then
          spay_acc_numb := rec_acc.pay_acc_numb;
        elsif length(spay_acc_numb || rec_acc.pay_acc_numb) < 1990 then
          spay_acc_numb := spay_acc_numb || '; ' || rec_acc.pay_acc_numb;
        end if;
      end loop;

      for rec_acc in (
        select distinct trim(su.do_ext_numb) as do_ext_numb
          from udo_umts_monitor_supply_sp su
         where su.ident = nident
           and su.authid = utilizer
           and su.modif = rec_sp.modif
           and ((rec_sp.rn_modif_orig is null and su.rn_modif_orig is null) or 
                (su.rn_modif_orig = rec_sp.rn_modif_orig))
           and su.do_ext_numb is not null
      ) loop
        if sdo_ext_numb is null then
          sdo_ext_numb := rec_acc.do_ext_numb;
        elsif length(sdo_ext_numb || rec_acc.do_ext_numb) < 1990 then
          sdo_ext_numb := sdo_ext_numb || '; ' || rec_acc.do_ext_numb;
        end if;
      end loop;


      for rec_acc in ( 
        select distinct su.contract as contract -- собирается по заявке !!!
          from udo_umts_monitor_supply_sp su
         where su.ident = nident
           and su.authid = utilizer
           and su.modif = rec_sp.modif
           and ((rec_sp.rn_modif_orig is null and su.rn_modif_orig is null) or 
                (su.rn_modif_orig = rec_sp.rn_modif_orig))
           and su.contract is not null
         --order by contract
      ) loop
        if STRIN(rec_acc.contract, scontract) != 1 then
          if scontract is null then
            scontract := rec_acc.contract;
          elsif length(scontract || rec_acc.contract) < 1990 then
            scontract := scontract || '; ' || rec_acc.contract;
          end if;
        end if;
      end loop;

      for rec_acc in (
        select distinct trim(su.note) as note
          from udo_umts_monitor_supply_sp su
         where su.ident = nident
           and su.authid = utilizer
           and su.modif = rec_sp.modif
           and ((rec_sp.rn_modif_orig is null and su.rn_modif_orig is null) or 
                (su.rn_modif_orig = rec_sp.rn_modif_orig))
           and su.note is not null
      ) loop
        if snote is null then
          snote := rec_acc.note;
        elsif length(snote || rec_acc.note) < 1990 then
          snote := snote || '; ' || rec_acc.note;
        end if;
      end loop;
      /* Консолидация данных по счетам на оплату. End. */

      rsp.crn            := rec_sp.crn;
      rsp.type           := rec_sp.type;
      rsp.rn_modif_orig  := rec_sp.rn_modif_orig;
      rsp.modif          := rec_sp.modif;
      rsp.quant_rest_res := rec_sp.quant_rest_res;
      rsp.quant_rest_inv := rec_sp.quant_rest_inv;      
      rsp.quant_bp       := rec_sp.quant_bp;
      rsp.quant_to_bp    := rec_sp.quant_to_bp;
      rsp.plan_date_min  := rec_sp.plan_date_min;
      rsp.plan_date_max  := rec_sp.plan_date_max;
      rsp.quant_do       := rec_sp.quant_do;
      rsp.quant_inc      := rec_sp.quant_inc;
      rsp.quant_res      := rec_sp.quant_res;
      rsp.quant_inv      := rec_sp.quant_inv;
      rsp.sum_total      := rec_sp.sum_total;
      rsp.quant_dlvr_def := rec_sp.quant_dlvr_def;
      rsp.quant_rest_vk  := rec_sp.quant_rest_vk;
      rsp.main_quant     := rec_sp.main_quant;
      rsp.pay_acc_date   := rec_sp.pay_acc_date; 
      rsp.fact_pay_date  := rec_sp.fact_pay_date; 
      rsp.sup_days       := rec_sp.sup_days;

      rsp.contract       := scontract; --substr(rec_sp.contract, 0, 1990); -- 
      rsp.pay_acc_numb   := spay_acc_numb;
      rsp.ord_agent      := sord_agent;
      rsp.do_ext_numb    := sdo_ext_numb;
      rsp.note           := snote;
      --
      insert into udo_umts_monitor_supply values rsp;
    end loop;
  end p_recreate_full;
  
  /*Процедура выполняет переформирование раздела*/
  procedure p_recreate(ncompany  in number /*Организация*/,
                       sunitcode in varchar2 /*Код раздела*/,
                       nident    in number /*Идентификатор помеченных записей*/,
                       stheme    in varchar2 /*Тема*/,
                       nstate0   in number /*Не утвержден*/,
                       nstate1   in number /*Утвержден*/,
                       nstate2   in number /*Согласование*/,
                       nstate3   in number /*Закрыт*/,
                       nstate4   in number /*Аннулирован*/,
                       nsign_ful in number default 0 /*Показать сводную*/
                       ) is
    -- 07/11/2023 Марков МВ.
    -- показать сводную - это мониторинг по нмоенклатурам без деления по заказам
  begin
    /*Выполняем очистку таблицы раздела*/
    delete udo_umts_monitor_supply;
    delete from udo_umts_monitor_supply_sp;
  
    /*Цикл по строкам заказов подразделений*/
    for sp_cursor in ( -- KHOK Debug
                      --
                      select /*+ ordered index(o I_DEPARTMENTORD_FACEACC_FK)*/
                       s.rn as nrn
                        from departmentord o, departmentords s
                       where o.faceacc in
                             (select fa.rn
                                from udo_v_sheme_list l, faceacc fa
                               where strinlike(l.scode, stheme) = 1
                                 and fa.numb like l.scode || '/%') -- '%') 27/02/2024 Марков МВ.
                         and o.company = ncompany
                         and (o.ord_state = 0 and nstate0 = 1 or
                             o.ord_state = 1 and nstate1 = 1 or
                             o.ord_state = 2 and nstate2 = 1 or
                             o.ord_state = 3 and nstate3 = 1 or
                             o.ord_state = 4 and nstate4 = 1)
                         and s.prn = o.rn
                         and cmp_vc2(sunitcode, 'ProductionOrders') = 0
                         /*and s.main_quant > 0*/
                      --
                      union all
                      --
                      select s.rn as nrn
                        from departmentord o, departmentords s
                       where o.rn in
                             (select l2.out_document
                                from selectlist sl, doclinks l1, doclinks l2
                               where sl.ident = nident
                                 and l1.in_document = sl.document
                                 and l1.in_unitcode = sunitcode
                                 and l2.in_document = l1.out_document)
                         and o.company = ncompany
                         and (o.ord_state = 0 and nstate0 = 1 or
                             o.ord_state = 1 and nstate1 = 1 or
                             o.ord_state = 2 and nstate2 = 1 or
                             o.ord_state = 3 and nstate3 = 1 or
                             o.ord_state = 4 and nstate4 = 1)
                         and s.prn = o.rn
                         and cmp_vc2(sunitcode, 'ProductionOrders') = 1
                         /*and s.main_quant > 0*/
                      --
                      ) loop
      /*Выполняем добавление указанной строки заказа подразделения в спецификацию раздела*/
      p_add_dep_ord_sp(ncompany => ncompany, nrn => sp_cursor.nrn, nident => nvl(nident, 154), nsign_ful => nsign_ful);
    end loop;

    -- 07/11/2023 Марков МВ. Формирование сводной таблицы
    if nvl(nsign_ful, 0) > 0 then
--if utilizer in('CITK_MARKOV') then return; end if;
      p_recreate_full(nident => nvl(nident, 154));
    end if;

  end p_recreate;

  /*Процедура выполняет заполнение списка документов по помеченным записям*/
  procedure p_calc_doc_list(nident     in number /*Идентификатор помеченных записей*/,
                            sunitcode  in varchar2 /*Код раздела*/,
                            nident_doc out number /*Идентификатор документов*/) is
  
    /*Регистрационный номер записи*/
    nrn_sl pkg_std.tREF;
  
  begin
    /*Идентификатор помеченных записей документов*/
    p_selectlist_genident(nIDENT => nident_doc);
  
    /*Цикл по документам*/
    for doc_cursor in (
                       --
                       /*Заказы подразделений*/
                       select distinct ds.prn as nrn
                         from selectlist sl, departmentords ds
                        where sunitcode = 'DepartmentsOrders'
                          and sl.ident = nident
                          and ds.rn = sl.document
                       --
                       union all
                       --
                       /*Планы закупок*/
                       select distinct sp.prn as nrn
                         from selectlist sl, buyplanespref r, buyplanesp sp
                        where sunitcode = 'BuyPlanes'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and sp.rn = r.prn
                       --
                       union all
                       --
                       /*Заказы поставщикам*/
                       select distinct ds.prn as nrn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds
                        where sunitcode = 'DeliveryOrders'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.rn_ref = r.rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and ds.rn = c.doc_rn
                       --
                       union all
                       --
                       /*Договор*/
                       select distinct stg.prn as nrn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               deliveryord                    o,
                               stages                         stg
                        where sunitcode = 'Contracts'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.rn_ref = r.rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and ds.rn = c.doc_rn
                          and o.rn = ds.prn
                          and stg.faceacc = o.faceacc
                       --
                       union all
                       --
                       /*Счет на оплату. Аванс*/
                       select distinct ps.prn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               doclinks                       l,
                               payaccinspec                   ps
                        where sunitcode = 'PaymentAccountsIn'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.prn = r.prn
                          and c.rn_ref = r.rn
                          and ds.rn = c.doc_rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and l.in_document = ds.prn
                          and l.out_document = ps.prn
                          and ps.nommodif = ds.nom_modif
                       --
                       union all
                       --
                       /*Счет на оплату. Оплата по факту*/
                       select distinct ps.prn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               doclinks                       l1,
                               doclinks                       l2,
                               payaccinspec                   ps
                        where sunitcode = 'PaymentAccountsIn'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.prn = r.prn
                          and c.rn_ref = r.rn
                          and ds.rn = c.doc_rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and l1.in_document = ds.prn
                          and l2.in_document = l1.out_document
                          and l2.out_document = ps.prn
                          and ps.nommodif = ds.nom_modif
                       --
                       union all
                       --
                       /*Приходные накладные. Постоплата*/
                       select distinct iis.prn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               doclinks                       l,
                               ininvoicesspecs                iis
                        where sunitcode = 'IncomingInvoices'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.prn = r.prn
                          and c.rn_ref = r.rn
                          and ds.rn = c.doc_rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and l.in_document = ds.prn
                          and l.out_document = iis.prn
                          and iis.modif = ds.nom_modif
                       --
                       union all
                       --
                       /*Приходные накладные. Предоплата 100%*/
                       select distinct iis.prn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               doclinks                       l1,
                               doclinks                       l2,
                               ininvoicesspecs                iis
                        where sunitcode = 'IncomingInvoices'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.prn = r.prn
                          and c.rn_ref = r.rn
                          and ds.rn = c.doc_rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and l1.in_document = ds.prn
                          and l2.in_document = l1.out_document
                          and l2.out_document = iis.prn
                          and iis.modif = ds.nom_modif
                       --
                       union all
                       --
                       /*Приходные ордера. Постоплата*/
                       select distinct ios.prn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               doclinks                       l,
                               doclinks                       li,
                               inorderspecs                   ios
                        where sunitcode = 'IncomingOrders'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.prn = r.prn
                          and c.rn_ref = r.rn
                          and ds.rn = c.doc_rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and l.in_document = ds.prn
                          and li.in_document = l.out_document
                          and li.out_document = ios.prn
                          and ios.nommodif = ds.nom_modif
                       --
                       union all
                       --
                       /*Приходные ордера. Предоплата 100%*/
                       select distinct ios.prn
                         from selectlist                     sl,
                               buyplanespref                  r,
                               udo_uzd_03_buyplanesp_cntr_doc c,
                               deliveryords                   ds,
                               doclinks                       l1,
                               doclinks                       l2,
                               doclinks                       li,
                               inorderspecs                   ios
                        where sunitcode = 'IncomingOrders'
                          and sl.ident = nident
                          and r.deptordsp = sl.document
                          and c.prn = r.prn
                          and c.rn_ref = r.rn
                          and ds.rn = c.doc_rn
                          and c.doc_unitcode = 'DeliveryOrdersSpec'
                          and l1.in_document = ds.prn
                          and l2.in_document = l1.out_document
                          and li.in_document = l2.out_document
                          and li.out_document = ios.prn
                          and ios.nommodif = ds.nom_modif
                       --
                       union all
                       --
                       /*Требования. Старые*/
                       select distinct n.rn
                         from selectlist        sl,
                               departmentords    s,
                               doclinks          l,
                               transinvdeptspecs ns,
                               transinvdept      n,
                               azsazslistmt      in_store
                        where sunitcode = 'GoodsTransInvoicesToDepts'
                          and sl.ident = nident
                          and s.rn = sl.document
                          and l.in_document = s.prn
                          and l.in_unitcode = 'DepartmentsOrders'
                          and l.out_document = ns.prn
                          and l.out_unitcode = 'GoodsTransInvoicesToDepts'
                          and prsg_prop.SGET(nCOMPANY  => n.company,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'GoodsTransInvoicesToDepts',
                                             nDOCUMENT => ns.prn,
                                             sPROPCODE => 'ROWID_1C') is not null
                          and ns.nommodif = s.nom_modif
                          and n.rn = ns.prn
                          and in_store.rn(+) = n.in_store
                          and cmp_vc2(in_store.azs_number,
                                      'ВходнойКонтроль') = 0
                          and not exists
                        (select 1
                                 from udo_depords_prf p
                                where p.invdptsp = ns.rn)
                       --
                       union all
                       --
                       /*Требования. Новые*/
                       select distinct n.rn
                         from selectlist        sl,
                               udo_depords_prf   R,
                               TRANSINVDEPTSPECS S,
                               TRANSINVDEPT      N
                        where sunitcode = 'GoodsTransInvoicesToDepts'
                          and sl.ident = nident
                          and R.Dordsp = sl.document
                          and S.RN = R.INVDPTSP
                          and N.RN = S.PRN
                          and N.STATUS = 1
                       --
                       ) loop
      p_selectlist_insert(nident    => nident_doc,
                          ndocument => doc_cursor.nrn,
                          sunitcode => sunitcode,
                          nrn       => nrn_sl);
    end loop;
  end p_calc_doc_list;

begin
  -- Initialization
  null;
end udo_pkg_umts_monitor_supply;
/
