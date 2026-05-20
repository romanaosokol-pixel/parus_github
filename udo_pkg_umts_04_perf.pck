create or replace package udo_pkg_umts_04_perf is

  --create public synonym udo_pkg_umts_04_perf for udo_pkg_umts_04_perf;

  --grant execute on udo_pkg_umts_04_perf to public;

  -- Author  : I.ANNENKO
  -- Created : 20.09.2022 19:20:45
  -- Purpose : УМТС. 4. Контроль исполнения и закрытие плана закупок

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations

  /* Функция определяет принадлежность к общепроизводственным - 12/1 */
  -- 25/01/2024 Марков МВ.
  function f_buyplanespref_check_12_1
  (
    nCOMPANY in number, -- Организация
    nRN      in number -- Регистрационный номер записи
  ) return number;

  /*Функция определяет плановую дату поставки*/
  function f_buyplanespref_calc_pl_date(ncompany in number /*Организация*/,
                                        nrn      in number /*Регистрационный номер записи*/)
    return date;

  /*Процедура выполняет расчет количество поставлено для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_inv(ncompany     in number /*Организация*/,
                                           nrn          in number /*Регистрационный номер записи*/,
                                           nsign_period in number /*Признак контроля периода поставки*/,
                                           nquant       out number /*Количество ОЕИ*/,
                                           nquant_alt   out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество поставлено для указанной строки заказа*/
  procedure p_departmentords_clc_quant_inv(ncompany     in number /*Организация*/,
                                           nrn          in number /*Регистрационный номер записи*/,
                                           nsign_period in number /*Признак контроля периода поставки*/,
                                           nquant       out number /*Количество ОЕИ*/,
                                           nquant_alt   out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество зарезервировано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_res(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           nquant     out number /*Количество ОЕИ*/,
                                           nquant_alt out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество скомплектовано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_cmp(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           nquant     out number /*Количество ОЕИ*/,
                                           nquant_alt out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество выдано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_ex(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          nquant     out number /*Количество ОЕИ*/,
                                          nquant_alt out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество скомплектовано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_cmp(ncompany    in number /*Организация*/,
                                           nrn         in number /*Регистрационный номер записи*/,
                                           nprod_order in number /*Регистрационный номер записи заказа на производство*/,
                                           nquant      out number /*Количество ОЕИ*/,
                                           nquant_alt  out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество выдано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_ex(ncompany    in number /*Организация*/,
                                          nrn         in number /*Регистрационный номер записи*/,
                                          nprod_order in number /*Регистрационный номер записи заказа на производство*/,
                                          nquant      out number /*Количество ОЕИ*/,
                                          nquant_alt  out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество скомплектовано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_clc_quant_cmpl(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           nquant     out number /*Количество ОЕИ*/,
                                           nquant_alt out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество выдано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_clc_quant_exl(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          nquant     out number /*Количество ОЕИ*/,
                                          nquant_alt out number /*Количество ДЕИ*/);

  /*Процедура выполняет расчет количество возвращено для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_clc_quant_exr(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          nquant     out number /*Количество ОЕИ*/,
                                          nquant_alt out number /*Количество ДЕИ*/);

  /*Функция определяет плановую дату поставки по счету на оплату
    Сначала ищем раннюю дату в графике поставки спецификации вх.счета
    Если не найдена, ищем дату оплаты вх.счёта
    Если какая-то из дат найдена, добавляем к ней количество дней из свойства спецификации и возвращаем*/
  function f_buyplanespref_calc_pl_date_a(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return date;

  /*Изменение планируемой даты поставки*/
  procedure P_BUYPLANESPREF_UPD_PLAN_DATE(NCOMPANY   in number /*Регистрационный номер организации*/,
                                          NRN        in number /*Регистрационный номер записи*/,
                                          DPLAN_DATE in date /*Плановая дата поставки*/,
                                          NQUANT     in number /*Количество ОЕИ*/,
                                          NQUANT_ALT in number /*Количество ДЕИ*/,
                                          DHIST_DATE in date /*Дата записи истории изменений*/,
                                          SBASE      in varchar2 /*Основание*/);

  /*Изменение планируемой даты поставки*/
  procedure P_BUYPLANESPREF_UPD_PL_DATE_L(NCOMPANY   in number /*Регистрационный номер организации*/,
                                          NRN        in number /*Регистрационный номер записи*/,
                                          DPLAN_DATE in date /*Плановая дата поставки*/
                                          --,NQUANT     in number /*Количество ОЕИ*/
                                          --,NQUANT_ALT in number /*Количество ДЕИ*/
                                         ,
                                          DHIST_DATE in date /*Дата записи истории изменений*/,
                                          SBASE      in varchar2 /*Основание*/);

  /*Изменение планируемой даты поставки автоматически*/
  procedure P_BUYPLANESPREF_UPD_PL_DATE_La(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           DHIST_DATE in date /*Дата записи истории изменений*/,
                                           SBASE      in varchar2 /*Основание*/);

  /*Процедура выполняет корректировку связей заказа с планом закупок при исключении*/
  procedure P_BUYPLANESPREF_LNK_CORR_EXCL(NCOMPANY  in number /*Регистрационный номер организации*/,
                                          NRN_DO_SP in number /*Регистрационный номер записи строки заказа*/,
                                          NRN_DO    in number /*Регистрационный номер записи заказа*/,
                                          NRN_BP_SP in number /*Регистрационный номер записи строки плана*/,
                                          NRN_BP    in number /*Регистрационный номер записи плана*/);

  /*Процедура выполняет корректировку связей заказа с планом закупок при включении*/
  procedure P_BUYPLANESPREF_LNK_CORR_INCL(NCOMPANY  in number /*Регистрационный номер организации*/,
                                          NRN_DO_SP in number /*Регистрационный номер записи строки заказа*/,
                                          NRN_DO    in number /*Регистрационный номер записи заказа*/,
                                          NRN_BP_SP in number /*Регистрационный номер записи строки плана*/,
                                          NRN_BP    in number /*Регистрационный номер записи плана*/);

end udo_pkg_umts_04_perf;
/
create or replace package body udo_pkg_umts_04_perf is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  
  /* Процедура получения атрибута */
  procedure GET_PREF(
    NRN in number, 
    nCOMPANY in number,
    /*Атрибуты записи ссылки на заказ*/
    tREF out buyplanespref%rowtype
    ) as
    begin
      /*Атрибуты записи ссылки на заказ*/
      begin
        select r.*
          into tREF
          from buyplanespref r
         where r.rn = NRN
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => NRN,
                                   sUNIT_TABLE => 'BuyPlaneSpecsReferences');
      end;
   end;
   
  /* Процедура получения атрибута строки плана */
  procedure GET_SPEC(
    NRN in number, 
    nCOMPANY in number,
    tREF out buyplanesp%rowtype
    ) as
    begin
      /*Атрибуты записи ссылки на заказ*/
      begin
        select r.*
          into tREF
          from buyplanesp r
         where r.rn = NRN
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => NRN,
                                   sUNIT_TABLE => 'BuyPlaneSpecs');
      end;
   end;

  /* Процедура получения атрибута заголовка плана */
  procedure GET_PLAN(
    NRN in number, 
    nCOMPANY in number,
    tREF out buyplane%rowtype
    ) as
    begin
      /*Атрибуты записи ссылки на заказ*/
      begin
        select r.*
          into tREF
          from buyplane r
         where r.rn = NRN
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => NRN,
                                   sUNIT_TABLE => 'BuyPlanes');
      end;
   end;

  /* Функция определяет принадлежность к общепроизводственным - 12/1 */
  -- 25/01/2024 Марков МВ.
  function f_buyplanespref_check_12_1
  (
    nCOMPANY in number, -- Организация
    nRN      in number -- Регистрационный номер записи
  ) return number is
  begin
    for r12 in (select FA.RN
                  from BUYPLANESPREF  RF,
                       DEPARTMENTORDS ORDS,
                       DEPARTMENTORD  ORD,
                       FACEACC        FA
                 where RF.RN = nRN
                   and RF.COMPANY = nCOMPANY
                   and RF.DEPTORDSP = ORDS.RN
                   and ORDS.PRN = ORD.RN
                   and ORD.FACEACC = FA.RN
                   and FA.NUMB in ('12/1', '10/1')) loop
      return 1;
    end loop;
    return 0;
  end f_buyplanespref_check_12_1;
  
  /*Функция определяет плановую дату поставки*/
  function f_buyplanespref_calc_pl_date(ncompany in number /*Организация*/,
                                        nrn      in number /*Регистрационный номер записи*/)
    return date is
  begin
    return(prsg_prop.dGET(nCOMPANY  => ncompany,
                          nVERSION  => to_number(null),
                          sUNITCODE => 'BuyPlaneSpecsReferences',
                          nDOCUMENT => nrn,
                          sPROPCODE => 'УМТС_ПланДатаПост'));
  end f_buyplanespref_calc_pl_date;

  /*Процедура выполняет расчет количество поставлено по указанному документу контрактации*/
  procedure p_buyplanespref_calc_qnt_inv_с(ncompany    in number /*Организация*/,
                                           nrn         in number /*Регистрационный номер записи*/,
                                           ddate_begin in date /*Дата начала периода*/,
                                           ddate_end   in date /*Дата окончания периода*/,
                                           nquant      out number /*Количество ОЕИ*/,
                                           nquant_alt  out number /*Количество ДЕИ*/) is
  begin
    select nvl(sum(t.nquant), 0), nvl(sum(t.nquantalt), 0)
      into nquant, nquant_alt
      from (with tLINK as
               (select l1.in_document
                      ,l2.out_document
                 from doclinks        l1,
                      doclinks        l2
                 where l1.in_unitcode = 'DeliveryOrders'
                   and l1.out_unitcode = 'PaymentAccountsIn'
                   and l2.in_document = l1.out_document
                   and l2.in_unitcode = 'PaymentAccountsIn'
                   and l2.out_unitcode = 'IncomingInvoices' 
                 
                union all
                
                select l3.in_document
                      ,l3.out_document 
               from doclinks          l3
               where l3.in_unitcode = 'DeliveryOrders'
                 and l3.out_unitcode = 'IncomingInvoices'
                )
            --
            select iis.quant as nquant, iis.quantalt as nquantalt
              from udo_uzd_03_buyplanesp_cntr_doc c,
                    deliveryords                   s,
                    tLINK                          lnk,
               /*     doclinks                       l1,
                    doclinks                       l2,*/
                    ininvoices                     i,
                    ininvoicesspecs                iis
             where c.rn = nrn
               and c.company = ncompany
               and s.rn = c.doc_rn
               and c.doc_unitcode = 'DeliveryOrdersSpec'
               and lnk.in_document = s.prn
               and lnk.out_document = i.rn
            /*   and l1.in_document = s.prn
               and l1.in_unitcode = 'DeliveryOrders'
               and l1.out_unitcode = 'PaymentAccountsIn'
               and l2.in_document = l1.out_document
               and l2.in_unitcode = 'PaymentAccountsIn'
               and l2.out_unitcode = 'IncomingInvoices'
               and i.rn = l2.out_document*/
               and i.status = 2
                  --and i.work_date between ddate_begin and ddate_end
               and i.work_date between nvl(ddate_begin, i.work_date) and
                   nvl(ddate_end, i.work_date)
               and iis.prn = i.rn
               and iis.modif = s.nom_modif
         /*   --
            union all
            --
            \*Анненко И.С. 26.12.2022*\
            select iis.quant as nquant, iis.quantalt as nquantalt
              from udo_uzd_03_buyplanesp_cntr_doc c,
                    deliveryords                   s,
                    doclinks                       l1,
                    ininvoices                     i,
                    ininvoicesspecs                iis
             where c.rn = nrn
               and c.company = ncompany
               and s.rn = c.doc_rn
               and c.doc_unitcode = 'DeliveryOrdersSpec'
               and l1.in_document = s.prn
               and l1.in_unitcode = 'DeliveryOrders'
               and l1.out_unitcode = 'IncomingInvoices'
               and i.rn = l1.out_document
               and i.status = 2
                  --and i.work_date between ddate_begin and ddate_end
               and i.work_date between nvl(ddate_begin, i.work_date) and
                   nvl(ddate_end, i.work_date)
               and iis.prn = i.rn
               and iis.modif = s.nom_modif*/
            --
            ) t;
  end p_buyplanespref_calc_qnt_inv_с;

  /*Процедура выполняет расчет количество поставлено для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_inv(ncompany     in number /*Организация*/,
                                           nrn          in number /*Регистрационный номер записи*/,
                                           nsign_period in number /*Признак контроля периода поставки*/,
                                           nquant       out number /*Количество ОЕИ*/,
                                           nquant_alt   out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    if (nsign_period = 1) then
      /*Атрибуты записи ссылки на заказ*/
        GET_PREF(NRN => nrn, nCOMPANY => ncompany, tREF => rref );
          
/*          begin
        select r.*
          into rref
          from buyplanespref r
         where r.rn = nrn
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                   sUNIT_TABLE => 'BuyPlaneSpecsReferences');
      end;*/
    
      /*Атрибуты записи строки плана закупок*/
        GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
          
/*      begin
        select s.*
          into rsp
          from buyplanesp s
         where s.rn = rref.prn
           and s.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                   sUNIT_TABLE => 'BuyPlaneSpecs');
      end;*/
    
      /*Атрибуты записи плана*/
        GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*      begin
        select bp.*
          into rbp
          from buyplane bp
         where bp.rn = rsp.prn
           and bp.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                   sUNIT_TABLE => 'BuyPlanes');
      end;*/
    
      /*Дискретность*/
      ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                    nVERSION  => to_number(null),
                                    sUNITCODE => 'DOCTYPES',
                                    nDOCUMENT => rbp.doctype,
                                    sPROPCODE => 'УМТС_Дискретность');
    
      /*Период*/
      udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                              speriod       => ssign_disrc,
                                              dperiod_begin => dperiod_begin,
                                              dperiod_end   => dperiod_end);
    
      /*Дата начала периода планирования*/
      dperiod_begin := greatest(dperiod_begin,
                                prsg_prop.dGET(nCOMPANY  => ncompany,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'DepartmentsOrdersSpecs',
                                               nDOCUMENT => rref.deptordsp,
                                               sPROPCODE => 'УМТС_ДатаВклПЗ'));
    end if;
  
    /*Количество ОЕИ*/
    nquant := 0;
  
    /*Количество ДЕИ*/
    nquant_alt := 0;
  
    /*Цикл по документам контрактации*/
    for cntr_cursor in (select c.rn as nrn,
                               c.quant_plan as nquant_plan,
                               c.quant_plan_alt as nquant_plan_alt,
                               to_number(null) as nquant_plan_inv,
                               to_number(null) as nquant_plan_alt_inv
                          from udo_uzd_03_buyplanesp_cntr_doc c
                         where c.rn_ref = nrn
                           and c.company = ncompany) loop
      p_buyplanespref_calc_qnt_inv_с(ncompany    => ncompany,
                                     nrn         => cntr_cursor.nrn,
                                     ddate_begin => dperiod_begin,
                                     ddate_end   => dperiod_end,
                                     nquant      => cntr_cursor.nquant_plan_inv,
                                     nquant_alt  => cntr_cursor.nquant_plan_alt_inv);
    
      /*Количество ОЕИ*/
      nquant := nquant +
                nvl(cntr_cursor.nquant_plan_inv,0);
--                least(cntr_cursor.nquant_plan, cntr_cursor.nquant_plan_inv);
    
      /*Количество ДЕИ*/
      nquant_alt := nquant_alt +
                    nvl(cntr_cursor.nquant_plan_alt_inv,0);
/*                    least(cntr_cursor.nquant_plan_alt,
                          cntr_cursor.nquant_plan_alt_inv);*/
    
    end loop;
  end p_buyplanespref_calc_quant_inv;

  /*Процедура выполняет расчет количество поставлено для указанной строки заказа*/
  procedure p_departmentords_clc_quant_inv(ncompany     in number /*Организация*/,
                                           nrn          in number /*Регистрационный номер записи*/,
                                           nsign_period in number /*Признак контроля периода поставки*/,
                                           nquant       out number /*Количество ОЕИ*/,
                                           nquant_alt   out number /*Количество ДЕИ*/) is
  
  begin
    /*Количество ОЕИ*/
    nquant := 0;
  
    /*Количество ДЕИ*/
    nquant_alt := 0;
  
    /*Цикл по строкам плана закупок*/
    for sp_cursor in (select r.rn as nrn,
                             to_number(null) as nquant_plan_inv,
                             to_number(null) as nquant_plan_alt_inv
                        from buyplanespref r
                       where r.deptordsp = nrn
                         and r.company = ncompany) loop
      p_buyplanespref_calc_quant_inv(ncompany     => ncompany,
                                     nrn          => sp_cursor.nrn,
                                     nsign_period => nsign_period,
                                     nquant       => sp_cursor.nquant_plan_inv,
                                     nquant_alt   => sp_cursor.nquant_plan_alt_inv);
    
      /*Количество ОЕИ*/
      nquant := nquant + sp_cursor.nquant_plan_inv;
    
      /*Количество ДЕИ*/
      nquant_alt := nquant_alt + sp_cursor.nquant_plan_alt_inv;
    
    end loop;
  end p_departmentords_clc_quant_inv;

  /*Процедура выполняет расчет количество зарезервировано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_res(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           nquant     out number /*Количество ОЕИ*/,
                                           nquant_alt out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
      GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
  /*  begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => trunc(sysdate), -- 13/06/2024 Марков МВ. берем текущую дату как поставку rsp.shipment_plan,
                                            speriod       => 'Год', -- 13/06/2024 Марков МВ. для расчета резервов всегда поствим ГОД ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    /* 11/06/2024 Марков МВ. надо дату начала для резервов от даты включения в ПЗ
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));*/
    dperiod_begin := nvl(prsg_prop.dGET(nCOMPANY  => ncompany,
                                        nVERSION  => to_number(null),
                                        sUNITCODE => 'DepartmentsOrdersSpecs',
                                        nDOCUMENT => rref.deptordsp,
                                        sPROPCODE => 'УМТС_ДатаВклПЗ'), dperiod_begin);
    
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_calc_res_qnt(ncompany         => ncompany,
                                                      nrn              => rref.deptordsp,
                                                      dplan_date_begin => dperiod_begin,
                                                      dplan_date_end   => dperiod_end,
                                                      nquant_perf      => nquant,
                                                      nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_calc_quant_res;

  /*Процедура выполняет расчет количество скомплектовано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_cmp(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           nquant     out number /*Количество ОЕИ*/,
                                           nquant_alt out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
  /*  begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_calc_cmpl_qnt(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_calc_quant_cmp;

  /*Процедура выполняет расчет количество выдано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_ex(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          nquant     out number /*Количество ОЕИ*/,
                                          nquant_alt out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
/*    begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_calc_exec_qnt(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_calc_quant_ex;

  /*Процедура выполняет расчет количество скомплектовано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_cmp(ncompany    in number /*Организация*/,
                                           nrn         in number /*Регистрационный номер записи*/,
                                           nprod_order in number /*Регистрационный номер записи заказа на производство*/,
                                           nquant      out number /*Количество ОЕИ*/,
                                           nquant_alt  out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
/*    begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_calc_cmpl_qnt(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       nprod_order      => nprod_order,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_calc_quant_cmp;

  /*Процедура выполняет расчет количество скомплектовано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_clc_quant_cmpl(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           nquant     out number /*Количество ОЕИ*/,
                                           nquant_alt out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
/*    begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_clc_cmpl_qntl(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_clc_quant_cmpl;

  /*Процедура выполняет расчет количество выдано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_calc_quant_ex(ncompany    in number /*Организация*/,
                                          nrn         in number /*Регистрационный номер записи*/,
                                          nprod_order in number /*Регистрационный номер записи заказа на производство*/,
                                          nquant      out number /*Количество ОЕИ*/,
                                          nquant_alt  out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
 /*   begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
/*    begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_calc_exec_qnt(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       nprod_order      => nprod_order,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_calc_quant_ex;

  /*Процедура выполняет расчет количество выдано для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_clc_quant_exl(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          nquant     out number /*Количество ОЕИ*/,
                                          nquant_alt out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
 /*   begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_clc_exec_qntl(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_clc_quant_exl;

  /*Процедура выполняет расчет количество возвращено для указанной строки заказа в плане закупок*/
  procedure p_buyplanespref_clc_quant_exr(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          nquant     out number /*Количество ОЕИ*/,
                                          nquant_alt out number /*Количество ДЕИ*/) is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана*/
    rsp buyplanesp%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
  begin
    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(
          NRN      => nrn, 
          nCOMPANY => ncompany,
          tREF     => rref );
/*    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    /*Атрибуты записи строки плана закупок*/
    GET_SPEC(NRN => rref.prn, nCOMPANY => ncompany, tREF => rsp );
/*    begin
      select s.*
        into rsp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;*/
  
    /*Атрибуты записи плана*/
      GET_PLAN(NRN => rsp.prn, nCOMPANY => ncompany, tREF => rbp );
/*    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rsp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rsp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;*/
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rsp.shipment_plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Дата начала периода планирования*/
    dperiod_begin := greatest(dperiod_begin,
                              prsg_prop.dGET(nCOMPANY  => ncompany,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => rref.deptordsp,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ'));
  
    /*Выполняем расчет*/
    udo_pkg_depords_prf.p_departmentords_clc_exec_qntr(ncompany         => ncompany,
                                                       nrn              => rref.deptordsp,
                                                       dplan_date_begin => dperiod_begin,
                                                       dplan_date_end   => dperiod_end,
                                                       nquant_perf      => nquant,
                                                       nquant_perf_alt  => nquant_alt);
  end p_buyplanespref_clc_quant_exr;

  /*Функция определяет плановую дату поставки по счету на оплату
    Сначала ищем раннюю дату в графике поставки спецификации вх.счета
    Если не найдена, ищем дату оплаты вх.счёта
    Если какая-то из дат найдена, добавляем к ней количество дней из свойства спецификации и возвращаем*/
  function f_buyplanespref_calc_pl_date_a(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return date is
  
    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;
    /*Регистрационный номер записи строки заказа подразделений*/
    nrn_dep_ord_sp pkg_std.tREF;
  
    /*Регистрационный номер записи строки счета на оплату*/
    nrn_acc_sp pkg_std.tREF;
  
    /*Дата счета*/
    dacc_date date;
  
    /*Дата оплаты*/
    dpay_date date;
  
    /*Дней поставки*/
    ndel_days number;
  
    /*Анненко И.С. 18.04.2023*/
    ncount_inc number;
    
    dDate     date;
    dOutDate  date;
  begin

    /*Атрибуты записи ссылки на заказ*/
        GET_PREF(NRN => nrn, nCOMPANY => ncompany, tREF => rref );
    /*Регистрационный номер записи строки заказа подразделений*/
    nrn_dep_ord_sp := rref.deptordsp; 
/*    begin
      select r.deptordsp
        into nrn_dep_ord_sp
        from buyplanespref r
       where r.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
  
    if (nrn_dep_ord_sp is null) then
      return(to_date(null));
    end if;
  
    /*Регистрационный номер записи строки счета на оплату*/
    udo_pkg_umts_02_cntr.p_departmentords_calc_acc_sp(ncompany => ncompany,
                                                      nrn      => nrn_dep_ord_sp,
                                                      nrn_acc  => nrn_acc_sp);
    if (nrn_acc_sp is null) then
      return(to_date(null));
    end if;

    /* Дата начала из графика */
    udo_p_payaccinsp_shedule(nrn => nrn_acc_sp, dbeg => dOutDate, dend => dDate);
  
    /* Если не найдена дата начала из графика */
    if dOutDate is null then 
   
      /*Дата оплаты*/
      select min(p.pay_date)
        into dOutDate
        from payaccinspec s, doclinks l, paynotes p
       where s.rn = nrn_acc_sp
         and s.company = ncompany
         and l.in_document = s.prn
         and l.in_unitcode = 'PaymentAccountsIn'
         and l.out_unitcode = 'PayNotes'
         and p.rn = l.out_document
         and p.signplan = 0;

      /* Если не найдена Дата оплаты, выходим */
      if (dOutDate is null) then
        return(to_date(null));
      end if;

    end if;

    /*Дней поставки*/
    /* 19/06/2024 Степанов М. для скорости
    ndel_days := prsg_prop.NGET(nCOMPANY  => ncompany,
                                nVERSION  => to_number(null),
                                sUNITCODE => 'PaymentAccountsInSpecs',
                                nDOCUMENT => nrn_acc_sp,
                                sPROPCODE => 'Дней поставки');*/ 
    begin
      select num_value
        into ndel_days
        from docs_props_vals
       where docs_prop_rn = 7551156 /* Дней поставки */
         and unit_rn      = nrn_acc_sp;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nrn_acc_sp, f_unitlist_getname(sunitcode => 'PaymentAccountsInSpecs'));
    end;

    /*Возвращаем результат*/
    return(dOutDate + nvl(ndel_days, 0));

  end f_buyplanespref_calc_pl_date_a;

  /*Процедура выполняет корректировку связей заказа с планом закупок при исключении*/
  procedure P_BUYPLANESPREF_LNK_CORR_EXCL(NCOMPANY  in number /*Регистрационный номер организации*/,
                                          NRN_DO_SP in number /*Регистрационный номер записи строки заказа*/,
                                          NRN_DO    in number /*Регистрационный номер записи заказа*/,
                                          NRN_BP_SP in number /*Регистрационный номер записи строки плана*/,
                                          NRN_BP    in number /*Регистрационный номер записи плана*/) is
    NCOUNT number;
  begin
    select count(1)
      into NCOUNT
      from BUYPLANESPREF R
     where R.DEPTORDSP = NRN_DO_SP
       and R.PRN = NRN_BP_SP;
    /*Разрываем связь строки заказа со строкой плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                          NIN_DOCUMENT  => NRN_DO_SP,
                          SOUT_UNITCODE => 'BuyPlaneSpecs',
                          NOUT_DOCUMENT => NRN_BP_SP);
    end if;
    select count(1)
      into NCOUNT
      from BUYPLANESPREF R, BUYPLANESP S
     where R.DEPTORDSP = NRN_DO_SP
       and S.RN = R.PRN
       and S.PRN = NRN_BP;
    /*Разрываем связь строки заказа с заголовком плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                          NIN_DOCUMENT  => NRN_DO_SP,
                          SOUT_UNITCODE => 'BuyPlanes',
                          NOUT_DOCUMENT => NRN_BP);
    end if;
    select count(1)
      into NCOUNT
      from DEPARTMENTORDS DOS, BUYPLANESPREF R
     where DOS.PRN = NRN_DO
       and R.DEPTORDSP = DOS.RN
       and R.PRN = NRN_BP_SP;
    /*Разрываем связь заголовка заказа со строкой плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'DepartmentsOrders',
                          NIN_DOCUMENT  => NRN_DO,
                          SOUT_UNITCODE => 'BuyPlaneSpecs',
                          NOUT_DOCUMENT => NRN_BP_SP);
    end if;
    select count(1)
      into NCOUNT
      from DEPARTMENTORDS DOS, BUYPLANESPREF R, BUYPLANESP S
     where DOS.PRN = NRN_DO
       and R.DEPTORDSP = DOS.RN
       and S.RN = R.PRN
       and S.PRN = NRN_BP;
    /*Разрываем связь заголовка заказа с заголовком плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'DepartmentsOrders',
                          NIN_DOCUMENT  => NRN_DO,
                          SOUT_UNITCODE => 'BuyPlanes',
                          NOUT_DOCUMENT => NRN_BP);
    end if;
  end P_BUYPLANESPREF_LNK_CORR_EXCL;

  /*Процедура выполняет корректировку связей заказа с планом закупок при включении*/
  procedure P_BUYPLANESPREF_LNK_CORR_INCL(NCOMPANY  in number /*Регистрационный номер организации*/,
                                          NRN_DO_SP in number /*Регистрационный номер записи строки заказа*/,
                                          NRN_DO    in number /*Регистрационный номер записи заказа*/,
                                          NRN_BP_SP in number /*Регистрационный номер записи строки плана*/,
                                          NRN_BP    in number /*Регистрационный номер записи плана*/) is
    NCOUNT number;
  begin
    select count(1)
      into NCOUNT
      from DOCLINKS L
     where L.IN_DOCUMENT = NRN_DO_SP
       and L.IN_UNITCODE = 'DepartmentsOrdersSpecs'
       and L.OUT_DOCUMENT = NRN_BP_SP
       and L.OUT_UNITCODE = 'BuyPlaneSpecs';
    /*Создаем связь строки заказа со строкой плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                        NCOMPANY      => NCOMPANY,
                        SIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                        NIN_DOCUMENT  => NRN_DO_SP,
                        SOUT_UNITCODE => 'BuyPlaneSpecs',
                        NOUT_DOCUMENT => NRN_BP_SP);
    end if;
    select count(1)
      into NCOUNT
      from DOCLINKS L
     where L.IN_DOCUMENT = NRN_DO_SP
       and L.IN_UNITCODE = 'DepartmentsOrdersSpecs'
       and L.OUT_DOCUMENT = NRN_BP
       and L.OUT_UNITCODE = 'BuyPlanes';
    /*Создаем связь строки заказа с заголовком плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                        NCOMPANY      => NCOMPANY,
                        SIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                        NIN_DOCUMENT  => NRN_DO_SP,
                        SOUT_UNITCODE => 'BuyPlanes',
                        NOUT_DOCUMENT => NRN_BP);
    end if;
    select count(1)
      into NCOUNT
      from DOCLINKS L
     where L.IN_DOCUMENT = NRN_DO
       and L.IN_UNITCODE = 'DepartmentsOrders'
       and L.OUT_DOCUMENT = NRN_BP_SP
       and L.OUT_UNITCODE = 'BuyPlaneSpecs';
    /*Создаем связь заголовка заказа со строкой плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                        NCOMPANY      => NCOMPANY,
                        SIN_UNITCODE  => 'DepartmentsOrders',
                        NIN_DOCUMENT  => NRN_DO,
                        SOUT_UNITCODE => 'BuyPlaneSpecs',
                        NOUT_DOCUMENT => NRN_BP_SP);
    end if;
    select count(1)
      into NCOUNT
      from DOCLINKS L
     where L.IN_DOCUMENT = NRN_DO
       and L.IN_UNITCODE = 'DepartmentsOrders'
       and L.OUT_DOCUMENT = NRN_BP
       and L.OUT_UNITCODE = 'BuyPlanes';
    /*Создаем связь заголовка заказа с заголовком плана*/
    if (NCOUNT = 0) then
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                        NCOMPANY      => NCOMPANY,
                        SIN_UNITCODE  => 'DepartmentsOrders',
                        NIN_DOCUMENT  => NRN_DO,
                        SOUT_UNITCODE => 'BuyPlanes',
                        NOUT_DOCUMENT => NRN_BP);
    end if;
  end P_BUYPLANESPREF_LNK_CORR_INCL;

  /*Процедура выполняет базовое изменение планируемой даты поставки*/
  procedure P_BUYPLANESPREF_BUPD_PLAN_DATE(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           DPLAN_DATE in date /*Плановая дата поставки*/,
                                           NQUANT     in number /*Количество ОЕИ*/,
                                           NQUANT_ALT in number /*Количество ДЕИ*/,
                                           DHIST_DATE in date /*Дата записи истории изменений*/,
                                           SBASE      in varchar2 /*Основание*/) is
    /*Атрибуты записи заказа, подчиненного строке исходного плана закупок*/
    RREF_SRC BUYPLANESPREF%rowtype;
    /*Атрибуты записи строки заказа подразделения*/
    RDEP_ORD_SP DEPARTMENTORDS%rowtype;
    /*Атрибуты записи заголовка заказа подразделения*/
    RDEP_ORD DEPARTMENTORD%rowtype;
    /*Атрибуты записи строки исходного плана закупок*/
    RSP_SRC BUYPLANESP%rowtype;
    /*Атрибуты записи исходного плана закупок*/
    RBP_SRC BUYPLANE%rowtype;
    /*Резерв*/
    NQUANT_RES     PKG_STD.TQUANT;
    NQUANT_RES_ALT PKG_STD.TQUANT;
    /*Исполнено*/
    NQUANT_PERF     PKG_STD.TQUANT;
    NQUANT_PERF_ALT PKG_STD.TQUANT;
    /*Дата начала периода планирования строки исходного плана закупок*/
    DDATE_BEGIN_SRC date;
    /*Дата окончания периода планирования строки исходного плана закупок*/
    DDATE_END_SRC date;
    /*Дата начала периода планирования строки плана закупок назначения*/
    DDATE_BEGIN_dst date;
    /*Дата окончания периода планирования строки плана закупок назначения*/
    DDATE_END_dst date;
    /*Количество записей в строке исходного плана закупок*/
    NCOUNT_REF_SRC number;
    /*Атрибуты записи заголовка плана закупок назначения*/
    RBP_DST BUYPLANE%rowtype;
    /*Атрибуты записи строки плана закупок назначения*/
    RBP_SP_DST BUYPLANESP%rowtype;
    /*Атрибуты записи заказа, подчиненного строке плана закупок назначения*/
    RREF_DST BUYPLANESPREF%rowtype;
    /*Регистрационный номер записи истории*/
    NHIST PKG_STD.TREF;
    /*Законтрактовано в ОЕИ*/
    NQUANT_CNTR PKG_STD.TQUANT;
    /*Законтрактовано в ДЕИ*/
    NQUANT_CNTR_ALT PKG_STD.TQUANT;
    /*Законтрактовано в ОЕИ по заказу*/
    NQUANT_CNTR_DO PKG_STD.TQUANT;
    /*Законтрактовано в ДЕИ по заказу*/
    NQUANT_CNTR_ALT_DO PKG_STD.TQUANT;
    /*Количество переброски контрактации по заказу в ОЕИ*/
    NQUANT_CNTR_DO_MOVE PKG_STD.TQUANT;
    /*Количество переброски контрактации по заказу в ДЕИ*/
    NQUANT_CNTR_ALT_DO_MOVE PKG_STD.TQUANT;
    /*Количество переброски контрактации в ОЕИ*/
    NQUANT_CNTR_MOVE PKG_STD.TQUANT;
    /*Количество переброски контрактации в ДЕИ*/
    NQUANT_CNTR_ALT_MOVE PKG_STD.TQUANT;
    /*Регистрационный номер записи истории изменений*/
    nrn_hist pkg_std.tREF;
    /*Периодичность*/
    ssign_period pkg_std.tSTRING;
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
    /*Старое значение плановой даты поставки*/
    DPLAN_DATE_old date;
  begin
    --P_EXCEPTION(0,
    --            'Действие неработоспособно. Обратитесь к администратору в службу ИТ');
    /*1. Раздел 1. Красный. Инициализация, проверки. Начало*/
    /*Атрибуты записи заказа, подчиненного строке исходного плана закупок*/
    begin
      select R.*
        into RREF_SRC
        from BUYPLANESPREF R
       where R.RN = NRN
         and R.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
    /*Атрибуты записи строки заказа подразделения*/
    begin
      select S.*
        into RDEP_ORD_SP
        from DEPARTMENTORDS S
       where S.RN = RREF_SRC.DEPTORDSP
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RREF_SRC.DEPTORDSP,
                                 SUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;
    /*Атрибуты записи заголовка заказа подразделения*/
    begin
      select DO.*
        into RDEP_ORD
        from DEPARTMENTORD DO
       where DO.RN = RDEP_ORD_SP.PRN
         and DO.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RDEP_ORD_SP.PRN,
                                 SUNIT_TABLE => 'DepartmentsOrders');
    end;
    /*Атрибуты записи строки исходного плана закупок*/
    begin
      select S.*
        into RSP_SRC
        from BUYPLANESP S
       where S.RN = RREF_SRC.PRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RREF_SRC.PRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
    /*Атрибуты записи исходного плана закупок*/
    begin
      select BP.*
        into RBP_SRC
        from BUYPLANE BP
       where BP.RN = RSP_SRC.PRN
         and BP.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP_SRC.PRN,
                                 SUNIT_TABLE => 'BuyPlanes');
    end;
    /*Выполняем проверку состояния исходного плана закупок*/
    if (RBP_SRC.STATE not in (0, 2)) then
      P_EXCEPTION(0,
                  'План закупок должен находиться в состоянии "Не утвержден" либо "Утвержден"');
    end if;
    /*Старое значение плановой даты поставки*/
    DPLAN_DATE_old := prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                     nVERSION  => to_number(null),
                                     sUNITCODE => 'BuyPlaneSpecsReferences',
                                     nDOCUMENT => NRN,
                                     sPROPCODE => 'УМТС_ПланДатаПост');
    /*Дата поставки*/
    if (CMP_DAT(DPLAN_DATE, DPLAN_DATE_old) = 1) then
      P_EXCEPTION(0,
                  'Плановая дата поставки не изменилась');
    end if;
    /*Резерв*/
    udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY         => NCOMPANY,
                                                      NRN              => RREF_SRC.DEPTORDSP,
                                                      DPLAN_DATE_BEGIN => prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                                                                         nVERSION  => to_number(null),
                                                                                         sUNITCODE => 'DepartmentsOrdersSpecs',
                                                                                         nDOCUMENT => RREF_SRC.DEPTORDSP,
                                                                                         sPROPCODE => 'УМТС_ДатаВклПЗ'),
                                                      NQUANT_PERF      => NQUANT_RES,
                                                      NQUANT_PERF_ALT  => NQUANT_RES_ALT);
    /*Исполнено*/
    udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_EXEC_QNT(NCOMPANY         => NCOMPANY,
                                                       NRN              => RREF_SRC.DEPTORDSP,
                                                       DPLAN_DATE_BEGIN => prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                                                                          nVERSION  => to_number(null),
                                                                                          sUNITCODE => 'DepartmentsOrdersSpecs',
                                                                                          nDOCUMENT => RREF_SRC.DEPTORDSP,
                                                                                          sPROPCODE => 'УМТС_ДатаВклПЗ'),
                                                       NQUANT_PERF      => NQUANT_PERF,
                                                       NQUANT_PERF_ALT  => NQUANT_PERF_ALT);
    /*Выполняем проверку количество ОЕИ*/
    if (NQUANT < 0) then
      P_EXCEPTION(0,
                  'Указано отрицательное количество в ОЕИ');
    end if;
    if (NQUANT > /*Анненко И.С. 12.07.2022 RREF_SRC.QUANT_PLAN*/
       RDEP_ORD_SP.MAIN_QUANT - NQUANT_RES - NQUANT_PERF) then
      /*Ошибку выдаем только в случае переноса плановой даты поставки вперед*/
      if (DPLAN_DATE > DPLAN_DATE_old) then
        P_EXCEPTION(0,
                    'Превышено максимально допустимое количество в ОЕИ');
      end if;
    end if;
    /*Выполняем проверку количество ДЕИ*/
    if (NQUANT_ALT < 0) then
      P_EXCEPTION(0,
                  'Указано отрицательное количество в ДЕИ');
    end if;
    if (NQUANT_ALT >
       RDEP_ORD_SP.Alt_Quant - NQUANT_RES_ALT - NQUANT_PERF_ALT) then
      /*Ошибку выдаем только в случае переноса плановой даты поставки вперед*/
      if (DPLAN_DATE > DPLAN_DATE_old) then
        P_EXCEPTION(0,
                    'Превышено максимально допустимое количество в ДЕИ');
      end if;
    end if;
    /*Выполняем очистку записей временной таблицы*/
    delete UDO_UZD_03_BPSP_CNTR_DOC_TMP;
    /*Выполняем заполнение временной таблицы*/
    insert into UDO_UZD_03_BPSP_CNTR_DOC_TMP
      select *
        from UDO_UZD_03_BUYPLANESP_CNTR_DOC C
       where C.PRN = RSP_SRC.RN
         and udo_pkg_umts_02_cntr.F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY => C.COMPANY,
                                                                 NRN      => C.RN) = 0;
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => RBP_SRC.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период планирования строки исходного плана закупок*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => RSP_SRC.Shipment_Plan,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => DDATE_BEGIN_SRC,
                                            dperiod_end   => DDATE_END_SRC);
  
    /*1. Раздел 1. Красный. Инициализация, проверки. Конец*/
    /*2. Раздел 2. Фиолетовый. Период планирования не изменился. Начало*/
    /*Период планирования не изменился*/
    if (DPLAN_DATE between DDATE_BEGIN_SRC and DDATE_END_SRC)
    -- and
    -- (RREF_SRC.QUANT_PLAN = NQUANT) and
    -- (RREF_SRC.QUANTALT_PLAN = NQUANT_ALT)
     then
      /*Выполняем формирование истории изменений записи заказа в плане закупок*/
      if (RBP_SRC.STATE = 2) then
        p_buyplanesprefhs_make(ncompany  => ncompany,
                               nprn      => NRN,
                               sunitcode => TO_CHAR(null),
                               ndocument => TO_NUMBER(null),
                               ddate_to  => DHIST_DATE,
                               sbase     => sbase,
                               nrn       => nrn_hist);
      
        /*Плановая дата поставки*/
        prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferencesHistory',
                       nDOCUMENT  => nrn_hist,
                       sPROPCODE  => 'УМТС_ПланДатаПост',
                       sSTRVALUE  => to_char(null),
                       nNUMVALUE  => to_number(null),
                       dDATEVALUE => dplan_date_old);
      end if;
    
      /*Выполняем изменение плановой даты поставки*/
      prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferences',
                     nDOCUMENT  => NRN,
                     sPROPCODE  => 'УМТС_ПланДатаПост',
                     sSTRVALUE  => to_char(null),
                     nNUMVALUE  => to_number(null),
                     dDATEVALUE => dplan_date);
    
      /*Завершаем работу алгоритма*/
      return;
    end if;
    /*2. Раздел 2. Фиолетовый. Период планирования не изменился. Конец*/
    /*3. Раздел 3. Желтый. Уменьшение строки плана источника. Начало*/
    /*Если план не утвержден и выполняется исправление даты поставки для всего количества, то выполняем удаление записи*/
    if ((RBP_SRC.STATE = 0) and (RREF_SRC.QUANT_PLAN = NQUANT) and
       (RREF_SRC.QUANTALT_PLAN = NQUANT_ALT)) then
      P_BUYPLANESPREF_BASE_DELETE(NRN       => NRN,
                                  NCOMPANY  => NCOMPANY,
                                  NSIGN_ORD => 0);
      /*Исправление записи*/
    else
      /*Выполняем формирование истории изменений записи заказа в плане закупок*/
      if (RBP_SRC.STATE = 2) then
        p_buyplanesprefhs_make(ncompany  => ncompany,
                               nprn      => NRN,
                               sunitcode => TO_CHAR(null),
                               ndocument => TO_NUMBER(null),
                               ddate_to  => DHIST_DATE,
                               sbase     => sbase,
                               nrn       => nrn_hist);
      
        /*Плановая дата поставки*/
        prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferencesHistory',
                       nDOCUMENT  => nrn_hist,
                       sPROPCODE  => 'УМТС_ПланДатаПост',
                       sSTRVALUE  => to_char(null),
                       nNUMVALUE  => to_number(null),
                       dDATEVALUE => dplan_date_old);
      end if;
    
      /* исправление записи в таблице */
      update BUYPLANESPREF R
         set R.QUANT_PLAN    = R.QUANT_PLAN - NQUANT,
             R.QUANTALT_PLAN = R.QUANTALT_PLAN - NQUANT_ALT
       where R.RN = NRN
         and R.COMPANY = NCOMPANY;
      --
      if (sql%notfound) then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsReferences');
      end if;
    end if;
    /*Количество записей в строке исходного плана закупок*/
    select count(1)
      into NCOUNT_REF_SRC
      from BUYPLANESPREF R
     where R.PRN = RSP_SRC.RN
       and R.COMPANY = NCOMPANY;
    /*Если план не утвержден и для строки нет подчиненных записей, то выполняем удаление записи*/
    if ((RBP_SRC.STATE = 0) and (NCOUNT_REF_SRC = 0)) then
      P_BUYPLANESP_BASE_DELETE(NCOMPANY => NCOMPANY, NRN => RSP_SRC.RN);
    else
      /*Выполняем формирование истории изменений строки плана закупок*/
      if (RBP_SRC.STATE = 2) then
        P_BUYPLANESPHS_MAKE(ncompany  => ncompany,
                            nprn      => RSP_SRC.RN,
                            sunitcode => TO_CHAR(null),
                            ndocument => TO_NUMBER(null),
                            ddate_to  => DHIST_DATE,
                            sbase     => sbase,
                            nrn       => nrn_hist);
      end if;
    
      /*Выполняем пересчет количества в строке плана закупок*/
      update BUYPLANESP s
         set s.QUANT_PLAN    = s.quant_plan - NQUANT,
             s.quant_acc     = s.quant_acc - NQUANT,
             s.quantalt_plan = s.quantalt_plan - NQUANT_ALT,
             s.quantalt_acc  = s.quantalt_acc - NQUANT_ALT
       where s.RN = RSP_SRC.RN
         and s.company = ncompany;
    
      /*Выполняем проверку исправления записи*/
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(RSP_SRC.RN, 'BuyPlaneSpecs');
      end if;
    end if;
  
    /*Выполняем корректировку связей заказа с планом закупок при исключении*/
    P_BUYPLANESPREF_LNK_CORR_EXCL(NCOMPANY  => NCOMPANY,
                                  NRN_DO_SP => RDEP_ORD_SP.RN,
                                  NRN_DO    => RDEP_ORD_SP.PRN,
                                  NRN_BP_SP => RSP_SRC.RN,
                                  NRN_BP    => RSP_SRC.PRN);
  
    /*3. Раздел 3. Желтый. Уменьшение строки плана источника. Конец*/
  
    /*4. Раздел 4. Зеленый. Увеличение строки плана назначения. Начало*/
  
    /*Периодичность*/
    ssign_period := prsg_prop.SGET(nCOMPANY  => ncompany,
                                   nVERSION  => to_number(null),
                                   sUNITCODE => 'DOCTYPES',
                                   nDOCUMENT => rbp_src.doctype,
                                   sPROPCODE => 'УМТС_Периодичность');
  
    /*Период плана закупок*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => DPLAN_DATE,
                                            speriod       => ssign_period,
                                            dperiod_begin => RBP_DST.BEGIN_PERIOD,
                                            dperiod_end   => RBP_DST.End_Period);
  
    /*Выполняем поиск плана закупок*/
    begin
      select bp.rn
        into RBP_DST.RN
        from buyplane bp
       where bp.doctype = rbp_src.doctype
         and bp.company = ncompany
         and bp.begin_period = RBP_DST.begin_period
         and cmp_num(bp.govcntrid, rbp_src.govcntrid) = 1;
    exception
      when no_data_found then
        RBP_DST.RN := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить план закупок');
    end;
  
    if (RBP_DST.rn is not null) then
      /*Атрибуты записи плана закупок назначения*/
      begin
        select BP.*
          into RBP_DST
          from BUYPLANE BP
         where BP.RN = RBP_DST.RN
           and BP.COMPANY = NCOMPANY;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RBP_DST.RN,
                                   SUNIT_TABLE => 'BuyPlanes');
      end;
    
    else
      /*Организация*/
      RBP_DST.company := ncompany;
    
      /*Каталог*/
      RBP_DST.crn := RBP_SRC.crn;
    
      /*Юридическое лио*/
      RBP_DST.jur_pers := RBP_SRC.jur_pers;
    
      /*Тип*/
      RBP_DST.doctype := RBP_SRC.Doctype;
    
      /*Префикс*/
      RBP_DST.pref := to_char(RBP_DST.begin_period, 'yyyy');
    
      /*Номер*/
      p_buyplane_getnextnumb(nCOMPANY => ncompany,
                             sDOCTYPE => get_doctypes_code_id(nFLAG_SMART => 0,
                                                              nRN         => RBP_DST.doctype),
                             sPREF    => RBP_DST.pref,
                             sNUMB    => RBP_DST.numb);
    
      /*Дата*/
      RBP_DST.docdate := trunc(sysdate);
    
      /*Валюта*/
      RBP_DST.currency := f_curbase_get_rn(nFLAG_SMART => 0,
                                           nCOMPANY    => ncompany);
    
      /*ИГК*/
      RBP_DST.govcntrid := rbp_src.govcntrid;
    
      /*Выполняем добавление заголовка плана закупок*/
      p_buyplane_base_insert(ncompany      => RBP_DST.company,
                             ncrn          => RBP_DST.crn,
                             njur_pers     => RBP_DST.jur_pers,
                             nenperiod     => RBP_DST.enperiod,
                             dbegin_period => RBP_DST.begin_period,
                             dend_period   => RBP_DST.end_period,
                             nsubdiv       => RBP_DST.subdiv,
                             nstore        => RBP_DST.store,
                             ndoctype      => RBP_DST.doctype,
                             spref         => RBP_DST.pref,
                             snumb         => RBP_DST.numb,
                             ddocdate      => RBP_DST.docdate,
                             ncurrency     => RBP_DST.currency,
                             snote         => RBP_DST.note,
                             ngovcntrid    => RBP_DST.govcntrid,
                             nrn           => RBP_DST.rn);
    end if;
  
    /*Период планирования строки плана закупок назначения*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => DPLAN_DATE,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => DDATE_BEGIN_dst,
                                            dperiod_end   => DDATE_END_dst);
  
    /*Выполняем поиск строки плана закупок назначения*/
    begin
      select S.RN
        into RBP_SP_DST.RN
        from BUYPLANESP S
       where S.PRN = RBP_DST.RN
         and S.COMPANY = NCOMPANY
         and S.NOMMODIF = RDEP_ORD_SP.NOM_MODIF
         and S.SHIPMENT_PLAN = DDATE_END_dst;
    exception
      when NO_DATA_FOUND then
        RBP_SP_DST.RN := TO_NUMBER(null);
      when TOO_MANY_ROWS then
        P_EXCEPTION(0,
                    'Не удалось однозначно определить строку плана закупок');
    end;
  
    /*Выполняем добавление записи строки плана закупок*/
    if (RBP_SP_DST.RN is null) then
    
      /*Организация*/
      RBP_SP_DST.company := ncompany;
    
      /*Регистрационный номер родителя*/
      RBP_SP_DST.prn := rbp_dst.rn;
    
      /*Номенклатура*/
      RBP_SP_DST.nomen := rdep_ord_sp.nomen;
    
      /*Модификация*/
      RBP_SP_DST.nommodif := rdep_ord_sp.nom_modif;
    
      /*Основная ЕИ*/
      begin
        select n.umeas_main
          into RBP_SP_DST.umeas_main
          from dicnomns n
         where n.rn = rdep_ord_sp.nomen;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdep_ord_sp.nomen,
                                   sUNIT_TABLE => 'Nomenclator');
      end;
    
      /*ЕП*/
      find_agnlist_code(nFLAG_SMART  => 0,
                        nFLAG_OPTION => 1,
                        nCOMPANY     => ncompany,
                        sCODE        => prsg_prop.SGET(nCOMPANY  => ncompany,
                                                       nVERSION  => to_number(null),
                                                       sUNITCODE => 'Nomenclator',
                                                       nDOCUMENT => rdep_ord_sp.nomen,
                                                       sPROPCODE => 'УМТС_ЕП'),
                        nRN          => RBP_SP_DST.agent);
    
      /*Дата поставки*/
      RBP_SP_DST.shipment_plan := DDATE_END_dst;
      RBP_SP_DST.shipment_acc  := DDATE_END_dst;
    
      /*Количество*/
      RBP_SP_DST.quant_plan := nquant;
      RBP_SP_DST.quant_acc  := nquant;
    
      /*Количество ДЕИ*/
      RBP_SP_DST.quantalt_plan := nquant_alt;
      RBP_SP_DST.quantalt_acc  := nquant_alt;
    
      /*Цена*/
      RBP_SP_DST.price_plan := 0;
      RBP_SP_DST.price_acc  := 0;
    
      /*ЕИ цены*/
      RBP_SP_DST.pr_meas := 0;
    
      /*Сумма*/
      RBP_SP_DST.summ_plan := 0;
      RBP_SP_DST.summ_acc  := 0;
    
      /*Дата включения*/
      RBP_SP_DST.incl_date := trunc(sysdate);
    
      /*Выполняем добавление строки плана закупок*/
      p_buyplanesp_base_insert(ncompany       => RBP_SP_DST.company,
                               nprn           => RBP_SP_DST.prn,
                               nnomencls      => RBP_SP_DST.nomencls,
                               nnomen         => RBP_SP_DST.nomen,
                               nnomnpack      => RBP_SP_DST.nomnpack,
                               nnommodif      => RBP_SP_DST.nommodif,
                               nnomnmodifpack => RBP_SP_DST.nomnmodifpack,
                               numeas_main    => RBP_SP_DST.umeas_main,
                               nstore         => RBP_SP_DST.store,
                               nagent         => RBP_SP_DST.agent,
                               nsign_one_row  => RBP_SP_DST.sign_one_row,
                               dshipment_plan => RBP_SP_DST.shipment_plan,
                               dshipment_acc  => RBP_SP_DST.shipment_acc,
                               ncost_place    => RBP_SP_DST.cost_place,
                               nquant_plan    => RBP_SP_DST.quant_plan,
                               nquantalt_plan => RBP_SP_DST.quantalt_plan,
                               nquant_acc     => RBP_SP_DST.quant_acc,
                               nquantalt_acc  => RBP_SP_DST.quantalt_acc,
                               nprice_plan    => RBP_SP_DST.price_plan,
                               nprice_acc     => RBP_SP_DST.price_acc,
                               npr_meas       => RBP_SP_DST.pr_meas,
                               nsumm_plan     => RBP_SP_DST.summ_plan,
                               nsumm_acc      => RBP_SP_DST.summ_acc,
                               snote          => RBP_SP_DST.note,
                               dincl_date     => RBP_SP_DST.incl_date,
                               nbudgexpend_sp => RBP_SP_DST.budgexpend_sp,
                               nrn            => RBP_SP_DST.rn);
    else
      /*Выполняем формирование истории изменений строки плана закупок*/
      if (RBP_DST.STATE = 2) then
        P_BUYPLANESPHS_MAKE(ncompany  => ncompany,
                            nprn      => RBP_SP_DST.RN,
                            sunitcode => TO_CHAR(null),
                            ndocument => TO_NUMBER(null),
                            ddate_to  => DHIST_DATE,
                            sbase     => sbase,
                            nrn       => nrn_hist);
      end if;
    
      /*Выполняем пересчет количества в строке плана закупок*/
      update BUYPLANESP s
         set s.QUANT_PLAN    = s.quant_plan + NQUANT,
             s.quant_acc     = s.quant_acc + NQUANT,
             s.quantalt_plan = s.quantalt_plan + NQUANT_ALT,
             s.quantalt_acc  = s.quantalt_acc + NQUANT_ALT
       where s.RN = RBP_SP_DST.RN
         and s.company = ncompany;
    
      /*Выполняем проверку исправления записи*/
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(RBP_SP_DST.RN, 'BuyPlaneSpecs');
      end if;
    end if;
  
    /*Атрибуты записи заказа, подчиненного строке плана закупок назначения*/
    begin
      select R.RN
        into RREF_DST.RN
        from BUYPLANESPREF R
       where R.PRN = RBP_SP_DST.RN
         and R.DEPTORDSP = RDEP_ORD_SP.RN;
    exception
      when NO_DATA_FOUND then
        RREF_DST.RN := TO_NUMBER(null);
      when TOO_MANY_ROWS then
        P_EXCEPTION(0,
                    'Не удалось однозначно определить запись заказа, включенного в план закупок');
    end;
  
    /*Выполняем добавление записи в таблицу*/
    if (RREF_DST.RN is null) then
      select max(H.RN)
        into NHIST
        from DEPORDSPHS H
       where H.PRN = RDEP_ORD_SP.RN;
      --добавляем связь в свою таблцу связей
      P_BUYPLANESPREF_BASE_INSERT(NCOMPANY       => NCOMPANY,
                                  NPRN           => RBP_SP_DST.RN,
                                  NDEPTORDSP     => RDEP_ORD_SP.RN,
                                  NCONSORDSP     => TO_NUMBER(null),
                                  NQUANT_PLAN    => NQUANT,
                                  NQUANTALT_PLAN => NQUANT_ALT,
                                  NSIGN_EXCL     => 0,
                                  NHIST          => NHIST,
                                  NRN            => RREF_DST.RN,
                                  NSIGN_ORD      => 0 /*Анненко И.С. 15.06.2021*/);
    else
      /*Выполняем формирование истории изменений записи заказа в плане закупок*/
      if (RBP_DST.STATE = 2) then
        p_buyplanesprefhs_make(ncompany  => ncompany,
                               nprn      => RREF_DST.RN,
                               sunitcode => TO_CHAR(null),
                               ndocument => TO_NUMBER(null),
                               ddate_to  => DHIST_DATE,
                               sbase     => sbase,
                               nrn       => nrn_hist);
      
        /*Плановая дата поставки*/
        prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferencesHistory',
                       nDOCUMENT  => nrn_hist,
                       sPROPCODE  => 'УМТС_ПланДатаПост',
                       sSTRVALUE  => to_char(null),
                       nNUMVALUE  => to_number(null),
                       dDATEVALUE => dplan_date_old);
      end if;
    
      /* исправление записи в таблице */
      update BUYPLANESPREF R
         set R.QUANT_PLAN    = R.QUANT_PLAN + NQUANT,
             R.QUANTALT_PLAN = R.QUANTALT_PLAN + NQUANT_ALT
       where R.RN = RREF_DST.RN
         and R.COMPANY = NCOMPANY;
      --
      if (sql%notfound) then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RREF_DST.RN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsReferences');
      end if;
    end if;
  
    /*Плановая дата поставки*/
    prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferences',
                   nDOCUMENT  => RREF_DST.rn,
                   sPROPCODE  => 'УМТС_ПланДатаПост',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => dplan_date);
  
    /*Выполняем корректировку связей заказа с планом закупок при включении*/
    P_BUYPLANESPREF_LNK_CORR_INCL(NCOMPANY  => NCOMPANY,
                                  NRN_DO_SP => RDEP_ORD_SP.RN,
                                  NRN_DO    => RDEP_ORD_SP.PRN,
                                  NRN_BP_SP => RBP_SP_DST.RN,
                                  NRN_BP    => RBP_DST.RN);
  
    /*4. Раздел 4. Зеленый. Увеличение строки плана назначения. Конец*/
  
    /*5. Раздел 5. Синий. Корректировка контрактации. Начало*/
    /*Законтрактовано*/
    select NVL(sum(T.QUANT_PLAN), 0), NVL(sum(T.QUANT_PLAN_ALT), 0)
      into NQUANT_CNTR, NQUANT_CNTR_ALT
      from UDO_UZD_03_BPSP_CNTR_DOC_TMP T;
    /*Законтрактовано по заказу*/
    select NVL(sum(T.QUANT_PLAN), 0), NVL(sum(T.QUANT_PLAN_ALT), 0)
      into NQUANT_CNTR_DO, NQUANT_CNTR_ALT_DO
      from UDO_UZD_03_BPSP_CNTR_DOC_TMP T
     where T.RN_REF = NRN;
    /*Анненко И.С. 21.07.2022 Реализовал перенос в сторону уменьшения*/
    if (DPLAN_DATE < DPLAN_DATE_old) then
      /*Количество переброски контрактации по заказу в ОЕИ*/
      NQUANT_CNTR_DO_MOVE := LEAST(NQUANT_CNTR_DO, NQUANT);
      /*Количество переброски контрактации по заказу в ДЕИ*/
      NQUANT_CNTR_ALT_DO_MOVE := LEAST(NQUANT_CNTR_ALT_DO, NQUANT_ALT);
    else
      /*Количество переброски контрактации по заказу в ОЕИ*/
      NQUANT_CNTR_DO_MOVE := GREATEST(0,
                                      NQUANT_CNTR_DO -
                                      (RREF_SRC.QUANT_PLAN - NQUANT));
      /*Количество переброски контрактации по заказу в ДЕИ*/
      NQUANT_CNTR_ALT_DO_MOVE := GREATEST(0,
                                          NQUANT_CNTR_ALT_DO - (RREF_SRC.QUANTALT_PLAN -
                                          NQUANT_ALT));
    end if;
    if ((NQUANT_CNTR_DO_MOVE > 0) or (NQUANT_CNTR_ALT_DO_MOVE > 0)) then
      udo_pkg_umts_02_cntr.P_BUYPLANESPREF_MOVE_CNTR(NCOMPANY        => NCOMPANY,
                                                     NRN_SRC         => NRN,
                                                     NRN_DST         => RREF_DST.RN,
                                                     NPRN_DST        => RBP_SP_DST.RN,
                                                     NCRN_DST        => RBP_DST.CRN,
                                                     NBP_DST         => RBP_DST.RN,
                                                     NQUANT_MOVE     => NQUANT_CNTR_DO_MOVE,
                                                     NQUANT_ALT_MOVE => NQUANT_CNTR_ALT_DO_MOVE);
    end if;
    if (1 = 0) then
      /*Анненко И.С. 21.07.2022 Реализовал перенос в сторону уменьшения*/
      if (DPLAN_DATE < DPLAN_DATE_old) then
        /*Количество переброски контрактации в ОЕИ*/
        NQUANT_CNTR_MOVE := LEAST(NQUANT_CNTR - NQUANT_CNTR_DO, NQUANT);
        /*Количество переброски контрактации в ДЕИ*/
        NQUANT_CNTR_ALT_MOVE := LEAST(NQUANT_CNTR_ALT - NQUANT_CNTR_ALT_DO,
                                      NQUANT_ALT);
      else
        /*Количество переброски контрактации в ОЕИ*/
        NQUANT_CNTR_MOVE := GREATEST(0,
                                     (NQUANT_CNTR - NQUANT_CNTR_DO) -
                                     (RSP_SRC.QUANT_PLAN - NQUANT));
        /*Количество переброски контрактации в ДЕИ*/
        NQUANT_CNTR_ALT_MOVE := GREATEST(0,
                                         (NQUANT_CNTR_ALT -
                                         NQUANT_CNTR_ALT_DO) -
                                         (RSP_SRC.QUANTALT_PLAN - NQUANT_ALT));
      end if;
      if ((NQUANT_CNTR_MOVE > 0) or (NQUANT_CNTR_ALT_MOVE > 0)) then
        udo_pkg_umts_02_cntr.P_BUYPLANESPREF_MOVE_CNTR(NCOMPANY        => NCOMPANY,
                                                       NRN_SRC         => TO_NUMBER(null),
                                                       NRN_DST         => TO_NUMBER(null),
                                                       NPRN_DST        => RBP_SP_DST.RN,
                                                       NCRN_DST        => RBP_DST.CRN,
                                                       NBP_DST         => RBP_DST.RN,
                                                       NQUANT_MOVE     => NQUANT_CNTR_MOVE,
                                                       NQUANT_ALT_MOVE => NQUANT_CNTR_ALT_MOVE);
      end if;
    end if;
    /*5. Раздел 5. Синий. Корректировка контрактации. Конец*/
  end P_BUYPLANESPREF_BUPD_PLAN_DATE;

  /*Изменение планируемой даты поставки*/
  procedure P_BUYPLANESPREF_UPD_PLAN_DATE(NCOMPANY   in number /*Регистрационный номер организации*/,
                                          NRN        in number /*Регистрационный номер записи*/,
                                          DPLAN_DATE in date /*Плановая дата поставки*/,
                                          NQUANT     in number /*Количество ОЕИ*/,
                                          NQUANT_ALT in number /*Количество ДЕИ*/,
                                          DHIST_DATE in date /*Дата записи истории изменений*/,
                                          SBASE      in varchar2 /*Основание*/) is
    /*Каталог*/
    NCRN PKG_STD.TREF;
  begin
    /* Считывание записи */
    P_BUYPLANESPREF_EXISTS(NRN, NCOMPANY, NCRN);
    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     NCRN,
                     null,
                     null,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesUpdPlanDate',
                     'BUYPLANESPREF',
                     NRN);
    /*Выполняем базовое изменение планируемой даты поставки*/
    P_BUYPLANESPREF_BUPD_PLAN_DATE(NCOMPANY   => NCOMPANY,
                                   NRN        => NRN,
                                   DPLAN_DATE => DPLAN_DATE,
                                   NQUANT     => NQUANT,
                                   NQUANT_ALT => NQUANT_ALT,
                                   DHIST_DATE => DHIST_DATE,
                                   SBASE      => SBASE);
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     NCRN,
                     null,
                     null,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesUpdPlanDate',
                     'BUYPLANESPREF',
                     NRN);
  end P_BUYPLANESPREF_UPD_PLAN_DATE;

  /*Процедура выполняет базовое изменение планируемой даты поставки*/
  procedure P_BUYPLANESPREF_BUPD_PL_DATE_L(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           DPLAN_DATE in date /*Плановая дата поставки*/
                                           --,NQUANT     in number /*Количество ОЕИ*/
                                           --,NQUANT_ALT in number /*Количество ДЕИ*/
                                          ,
                                           DHIST_DATE in date /*Дата записи истории изменений*/,
                                           SBASE      in varchar2 /*Основание*/) is
    /*Атрибуты записи заказа, подчиненного строке исходного плана закупок*/
    RREF_SRC BUYPLANESPREF%rowtype;
    /*Атрибуты записи строки заказа подразделения*/
    RDEP_ORD_SP DEPARTMENTORDS%rowtype;
    /*Резерв*/
    NQUANT_RES     PKG_STD.TQUANT;
    NQUANT_RES_ALT PKG_STD.TQUANT;
    /*Исполнено*/
    NQUANT_PERF     PKG_STD.TQUANT;
    NQUANT_PERF_ALT PKG_STD.TQUANT;
    /*Анненко И.С. 12.07.2022*/
    NCOUNT_REF number;
  begin
    /*Если дата поставки изменяется в сторону уменьшения, то выдаем сообщение об ошибке*/
    if (DPLAN_DATE <
       prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                       nVERSION  => to_number(null),
                       sUNITCODE => 'BuyPlaneSpecsReferences',
                       nDOCUMENT => NRN,
                       sPROPCODE => 'УМТС_ПланДатаПост')) then
      P_EXCEPTION(0,
                  'Массовое изменение плановой даты поставки в сторону уменьшения запрещено');
    end if;
    /*Атрибуты записи заказа, подчиненного строке исходного плана закупок*/
    GET_PREF(NRN => NRN, nCOMPANY => NCOMPANY, tREF => RREF_SRC );
/*    begin
      select R.*
        into RREF_SRC
        from BUYPLANESPREF R
       where R.RN = NRN
         and R.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;*/
    /*Анненко И.С. 12.07.2022*/
    select count(1)
      into NCOUNT_REF
      from BUYPLANESPREF R
     where R.DEPTORDSP = RREF_SRC.DEPTORDSP
       and R.COMPANY = NCOMPANY
          /*Анненко И.С. 18.03.2023*/
       and r.quant_plan <> 0;
    /*Атрибуты записи строки заказа подразделения*/
    begin
      select S.*
        into RDEP_ORD_SP
        from DEPARTMENTORDS S
       where S.RN = RREF_SRC.DEPTORDSP
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RREF_SRC.DEPTORDSP,
                                 SUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;
    /*Резерв*/
    udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY         => NCOMPANY,
                                                      NRN              => RREF_SRC.DEPTORDSP,
                                                      DPLAN_DATE_BEGIN => prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                                                                         nVERSION  => to_number(null),
                                                                                         sUNITCODE => 'DepartmentsOrdersSpecs',
                                                                                         nDOCUMENT => RREF_SRC.DEPTORDSP,
                                                                                         sPROPCODE => 'УМТС_ДатаВклПЗ'),
                                                      NQUANT_PERF      => NQUANT_RES,
                                                      NQUANT_PERF_ALT  => NQUANT_RES_ALT);
    /*Исполнено*/
    udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_EXEC_QNT(NCOMPANY         => NCOMPANY,
                                                       NRN              => RREF_SRC.DEPTORDSP,
                                                       DPLAN_DATE_BEGIN => prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                                                                          nVERSION  => to_number(null),
                                                                                          sUNITCODE => 'DepartmentsOrdersSpecs',
                                                                                          nDOCUMENT => RREF_SRC.DEPTORDSP,
                                                                                          sPROPCODE => 'УМТС_ДатаВклПЗ'),
                                                       NQUANT_PERF      => NQUANT_PERF,
                                                       NQUANT_PERF_ALT  => NQUANT_PERF_ALT);
    /*В том случае, если остатка для переброски нет, то завершаем работу процедуры*/
    if not ((RDEP_ORD_SP.MAIN_QUANT - NQUANT_RES - NQUANT_PERF > 0) or
        (RDEP_ORD_SP.ALT_QUANT - NQUANT_RES_ALT - NQUANT_PERF_ALT > 0)) then
      return;
    end if;
    /*Анненко И.С. 12.07.2022*/
    /*Если количество записей строки заказа в плане закупок больше одной и по заказу есть резерв либо выдача, то завершаем работу процедуры*/
    if (NCOUNT_REF > 1) then
      if (NQUANT_RES > 0 or NQUANT_PERF > 0) then
        return;
      end if;
    end if;
    /*Базовое исправление плановой даты поставки*/
    P_BUYPLANESPREF_BUPD_PLAN_DATE(NCOMPANY   => NCOMPANY,
                                   NRN        => NRN,
                                   DPLAN_DATE => DPLAN_DATE,
                                   NQUANT     => LEAST(RREF_SRC.QUANT_PLAN,
                                                       RDEP_ORD_SP.MAIN_QUANT -
                                                       NQUANT_RES -
                                                       NQUANT_PERF),
                                   NQUANT_ALT => LEAST(RREF_SRC.QUANTALT_PLAN,
                                                       RDEP_ORD_SP.ALT_QUANT -
                                                       NQUANT_RES_ALT -
                                                       NQUANT_PERF_ALT),
                                   DHIST_DATE => DHIST_DATE,
                                   SBASE      => SBASE);
  end P_BUYPLANESPREF_BUPD_PL_DATE_L;

  /*Изменение планируемой даты поставки*/
  procedure P_BUYPLANESPREF_UPD_PL_DATE_L(NCOMPANY   in number /*Регистрационный номер организации*/,
                                          NRN        in number /*Регистрационный номер записи*/,
                                          DPLAN_DATE in date /*Плановая дата поставки*/
                                          --,NQUANT     in number /*Количество ОЕИ*/
                                          --,NQUANT_ALT in number /*Количество ДЕИ*/
                                         ,
                                          DHIST_DATE in date /*Дата записи истории изменений*/,
                                          SBASE      in varchar2 /*Основание*/) is
    /*Каталог*/
    NCRN PKG_STD.TREF;
  begin
    /* Считывание записи */
    P_BUYPLANESPREF_EXISTS(NRN, NCOMPANY, NCRN);
    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     NCRN,
                     null,
                     null,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesUpdPlanDateList',
                     'BUYPLANESPREF',
                     NRN);
    /*Выполняем базовое изменение планируемой даты поставки*/
    P_BUYPLANESPREF_BUPD_PL_DATE_L(NCOMPANY   => NCOMPANY,
                                   NRN        => NRN,
                                   DPLAN_DATE => DPLAN_DATE,
                                   --NQUANT     => NQUANT,
                                   --NQUANT_ALT => NQUANT_ALT,
                                   DHIST_DATE => DHIST_DATE,
                                   SBASE      => SBASE);
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     NCRN,
                     null,
                     null,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesUpdPlanDateList',
                     'BUYPLANESPREF',
                     NRN);
  end P_BUYPLANESPREF_UPD_PL_DATE_L;

  /*Изменение планируемой даты поставки автоматически*/
  procedure P_BUYPLANESPREF_UPD_PL_DATE_La(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           DHIST_DATE in date /*Дата записи истории изменений*/,
                                           SBASE      in varchar2 /*Основание*/) is
  
    /*Каталог*/
    NCRN PKG_STD.TREF;
  
  begin
    /* Считывание записи */
    P_BUYPLANESPREF_EXISTS(NRN, NCOMPANY, NCRN);
  
    /*Выполняем проверку расчета плановой даты поставки*/
    if (f_buyplanespref_calc_pl_date_a(ncompany => ncompany, nrn => nrn) is null) then
      p_exception(0,
                  'Не удалось автоматически рассчитать плановую дату поставки');
    end if;
  
    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     NCRN,
                     null,
                     null,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesUpdPlanDateListA',
                     'BUYPLANESPREF',
                     NRN);
    /*Выполняем базовое изменение планируемой даты поставки*/
    P_BUYPLANESPREF_BUPD_PL_DATE_L(NCOMPANY   => NCOMPANY,
                                   NRN        => NRN,
                                   DPLAN_DATE => f_buyplanespref_calc_pl_date_a(ncompany => ncompany,
                                                                                nrn      => nrn),
                                   DHIST_DATE => DHIST_DATE,
                                   SBASE      => SBASE);
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     NCRN,
                     null,
                     null,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesUpdPlanDateListA',
                     'BUYPLANESPREF',
                     NRN);
  end P_BUYPLANESPREF_UPD_PL_DATE_La;

begin
  -- Initialization
  null;
end udo_pkg_umts_04_perf;
/
