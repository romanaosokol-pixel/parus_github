create or replace package udo_pkg_umts_05_replan is

  --create public synonym udo_pkg_umts_05_replan for udo_pkg_umts_05_replan;

  --grant execute on udo_pkg_umts_05_replan to public;

  -- Author  : I.ANNENKO
  -- Created : 13.09.2022 11:51:59
  -- Purpose : УМТС. 5. Перепланирование

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  /*Функция определяет плановую дату поставки*/
  function f_buyplandirspref_calc_pl_date(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return date;

  /*Процедура выполняет поиск и при необходимости добавление строки распоряжения*/
  procedure p_buyplandir_find_insert_sp(ncompany    in number /*Организация*/,
                                        nprn        in number /*Регистрационный номер записи распоряжения*/,
                                        nrn_plan_sp in number /*Регистрационный номер записи строки плана закупок*/,
                                        nmodif      in number /*Модификация*/,
                                        dperiod_end in date /*Дата окончания периода*/,
                                        nrn_dir_sp  out number /*Регистрационный номер записи строки распоряжения*/);

  /*Процедура выполняет пересчет количества в строках распоряжения об изменении плана закупок*/
  procedure p_buyplandir_recalc_sp(ncompany in number /*Организация*/,
                                   nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет базовое утверждение распоряжения об изменении плана закупок*/
  procedure p_buyplandir_bconfirm(ncompany in number /*Организация*/,
                                  nrn      in number /*Регистрационный номер записи*/,
                                  ddate    in date /*Дата изменений*/);

  /*Процедура выполняет формирование распоряжения об изменении плана закупок*/
  procedure p_buyplandir_crt(ncompany       in number               /*Организация*/,
                             nrn            in number               /*Регистрационный номер записи*/
                            ,ndepartmentord in number default null  /* Заказ подразделения. RN (25/06/2024 Степанов М.) */ );

  /*Процедура выполняет расформирование распоряжения об изменении плана закупок*/
  procedure p_buyplandir_rmv(ncompany in number /*Организация*/,
                             nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет изменение плановой даты поставки*/
  procedure p_buyplandirspref_set_pl_date(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          dplan_date in date /*Плановая дата поставки*/);

  /*Процедура выполняет утверждение распоряжения об изменении плана закупок*/
  procedure p_buyplandir_confirm(ncompany in number /*Организация*/,
                                 nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет снятие утверждения распоряжения об изменении плана закупок*/
  procedure p_buyplandir_cancel(ncompany in number /*Организация*/,
                                nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет расчет истории изменений записи строки заказа подразделений в плане закупок*/
  procedure P_BUYPLANESPREF_calc_hist(NCOMPANY in number /*Регистрационный номер организации*/,
                                      NRN      in number /*Регистрационный номер записи*/,
                                      shist    out varchar2 /*История изменений*/);

  /*Процедура выполняет установку признака дублирования для указанной строки заказа в распоряжении*/
  procedure p_buyplandirspref_set_sign_dup(ncompany in number /*Организация*/,
                                           nrn      in number /*Регистрационный номер записи*/);

  /* временная процедура снятия отработки только для отмеченных строк */
  procedure p_sys24071_replan_cancel(nIDENT in number, nCOMPANY in number);
  
end udo_pkg_umts_05_replan;
/
create or replace package body udo_pkg_umts_05_replan is

/*
25/06/2024 Степанов М.
Добавил входной параметр ndepartmentord для формирования спецификаций распоряжения об изменении только по одному заказу
*/
  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*Функция определяет плановую дату поставки*/
  function f_buyplandirspref_calc_pl_date(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return date is
  begin
    return(prsg_prop.dGET(nCOMPANY  => ncompany,
                          nVERSION  => to_number(null),
                          sUNITCODE => 'BuyingPlanDirectsSpecsReferences',
                          nDOCUMENT => nrn,
                          sPROPCODE => 'УМТС_ПланДатаПост'));
  end f_buyplandirspref_calc_pl_date;
  
  /* Функция определяет количество включенное в заказ поставщику для строки заказа подразделения */
  procedure p_buyplanespref_calc_dlvr_qnt
  (
    nSPEC      in number, -- рег.номер записи спецификации заказа подразделения
    nPLANE     in number, -- рег.нмоер плана закупок
    nQUANT     out number, -- включено в заказ поставщику в ОЕИ
    nQUANT_ALT out number -- включено в заказ поставщику в ДЕИ
  ) is
  
  begin
    select nvl(sum(DOC.DOC_QUANT_PLAN), 0),
           nvl(sum(DOC.DOC_QUANT_PLAN_ALT), 0)
      into nQUANT,
           nQUANT_ALT
      from BUYPLANESP                     BSP,
           BUYPLANESPREF                  BSR,
           UDO_UZD_03_BUYPLANESP_CNTR_DOC DOC
     where BSP.PRN = nPLANE
       and BSR.PRN = BSP.RN
       and BSR.DEPTORDSP = nSPEC
       and DOC.RN_REF = BSR.RN;
  exception
    when no_data_found then
      nQUANT     := 0;
      nQUANT_ALT := 0;
  end p_buyplanespref_calc_dlvr_qnt;

  /*Процедура выполняет поиск и при необходимости добавление строки распоряжения*/
  procedure p_buyplandir_find_insert_sp(ncompany    in number /*Организация*/,
                                        nprn        in number /*Регистрационный номер записи распоряжения*/,
                                        nrn_plan_sp in number /*Регистрационный номер записи строки плана закупок*/,
                                        nmodif      in number /*Модификация*/,
                                        dperiod_end in date /*Дата окончания периода*/,
                                        nrn_dir_sp  out number /*Регистрационный номер записи строки распоряжения*/) is
  
    /*Атрибуты записи строки плана закупок*/
    rbp_sp buyplanesp%rowtype;
  
  begin
  
    /*Новая строка в плане*/
    if (nrn_plan_sp is null) then
    
      /*Выполняем поиск строки в распоряжении*/
      begin
        select s.rn
          into nrn_dir_sp
          from buyplandirsp s
         where s.prn = nprn
           and s.company = ncompany
           and s.modif_aft = nmodif
           and s.shipplan_aft = dperiod_end;
      exception
        when no_data_found then
          nrn_dir_sp := to_number(null);
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить строку распоряжения');
      end;
    
      /*Выполняем добавление строки в распоряжение*/
      if (nrn_dir_sp is null) then
        begin
          select nm.prn, n.umeas_main
            into rbp_sp.nomen, rbp_sp.umeas_main
            from nommodif nm, dicnomns n
           where nm.rn = nmodif
             and n.rn = nm.prn;
        exception
          when no_data_found then
            pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nmodif,
                                     sUNIT_TABLE => 'NomenclatorModification');
        end;
      
        find_agnlist_code(nflag_smart  => 0,
                          nflag_option => 1,
                          ncompany     => ncompany,
                          scode        => prsg_prop.SGET(nCOMPANY  => ncompany,
                                                         nVERSION  => to_number(null),
                                                         sUNITCODE => 'Nomenclator',
                                                         nDOCUMENT => rbp_sp.nomen,
                                                         sPROPCODE => 'УМТС_ЕП'),
                          nrn          => rbp_sp.agent);
      
        p_buyplandirsp_base_insert(ncompany          => ncompany,
                                   nprn              => nprn,
                                   nplansp           => to_number(null),
                                   nkind             => 1,
                                   nnomcls_bef       => to_number(null),
                                   nnomcls_aft       => to_number(null),
                                   nnomen_bef        => to_number(null),
                                   nnomen_aft        => rbp_sp.nomen,
                                   nnompack_bef      => to_number(null),
                                   nnompack_aft      => to_number(null),
                                   nmodif_bef        => to_number(null),
                                   nmodif_aft        => nmodif,
                                   nmodpack_bef      => to_number(null),
                                   nmodpack_aft      => to_number(null),
                                   numain_bef        => to_number(null),
                                   numain_aft        => rbp_sp.umeas_main,
                                   nstore_bef        => to_number(null),
                                   nstore_aft        => to_number(null),
                                   nagent_bef        => to_number(null),
                                   nagent_aft        => rbp_sp.agent,
                                   dshipplan_bef     => to_date(null),
                                   dshipplan_aft     => dperiod_end,
                                   dshipacc_bef      => to_date(null),
                                   dshipacc_aft      => dperiod_end,
                                   ncostplace_bef    => to_number(null),
                                   ncostplace_aft    => to_number(null),
                                   nquantplan_bef    => to_number(null),
                                   nquantplan_aft    => 0,
                                   nquantaltplan_bef => to_number(null),
                                   nquantaltplan_aft => 0,
                                   nquantacc_bef     => to_number(null),
                                   nquantacc_aft     => 0,
                                   nquantaltacc_bef  => to_number(null),
                                   nquantaltacc_aft  => 0,
                                   npriceplan_bef    => to_number(null),
                                   npriceplan_aft    => 0,
                                   npriceacc_bef     => to_number(null),
                                   npriceacc_aft     => 0,
                                   nprmeas_bef       => to_number(null),
                                   nprmeas_aft       => 0,
                                   nsumplan_bef      => to_number(null),
                                   nsumplan_aft      => 0,
                                   nsumacc_bef       => to_number(null),
                                   nsumacc_aft       => 0,
                                   snote_bef         => to_char(null),
                                   snote_aft         => to_char(null),
                                   nbudgexpsp_bef    => to_number(null),
                                   nbudgexpsp_aft    => to_number(null),
                                   nrn               => nrn_dir_sp);
      end if;
    
      /*Строка в плане закупок существует*/
    else
    
      /*Выполняем поиск строки в распоряжении*/
      begin
        select s.rn
          into nrn_dir_sp
          from buyplandirsp s
         where s.prn = nprn
           and s.company = ncompany
           and s.plansp = nrn_plan_sp;
      exception
        when no_data_found then
          nrn_dir_sp := to_number(null);
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить строку распоряжения');
      end;
    
      /*Выполняем добавление строки в распоряжение*/
      if (nrn_dir_sp is null) then
      
        begin
          select s.*
            into rbp_sp
            from buyplanesp s
           where s.rn = nrn_plan_sp
             and s.company = company;
        exception
          when no_data_found then
            pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn_plan_sp,
                                     sUNIT_TABLE => 'BuyPlaneSpecs');
        end;
      
        p_buyplandirsp_base_insert(ncompany          => ncompany,
                                   nprn              => nprn,
                                   nplansp           => rbp_sp.rn,
                                   nkind             => 0,
                                   nnomcls_bef       => to_number(null),
                                   nnomcls_aft       => to_number(null),
                                   nnomen_bef        => rbp_sp.nomen,
                                   nnomen_aft        => rbp_sp.nomen,
                                   nnompack_bef      => to_number(null),
                                   nnompack_aft      => to_number(null),
                                   nmodif_bef        => rbp_sp.nommodif,
                                   nmodif_aft        => rbp_sp.nommodif,
                                   nmodpack_bef      => to_number(null),
                                   nmodpack_aft      => to_number(null),
                                   numain_bef        => rbp_sp.umeas_main,
                                   numain_aft        => rbp_sp.umeas_main,
                                   nstore_bef        => to_number(null),
                                   nstore_aft        => to_number(null),
                                   nagent_bef        => rbp_sp.agent,
                                   nagent_aft        => rbp_sp.agent,
                                   dshipplan_bef     => rbp_sp.shipment_plan,
                                   dshipplan_aft     => rbp_sp.shipment_plan,
                                   dshipacc_bef      => rbp_sp.shipment_acc,
                                   dshipacc_aft      => rbp_sp.shipment_acc,
                                   ncostplace_bef    => to_number(null),
                                   ncostplace_aft    => to_number(null),
                                   nquantplan_bef    => rbp_sp.quant_plan,
                                   nquantplan_aft    => rbp_sp.quant_plan,
                                   nquantaltplan_bef => 0,
                                   nquantaltplan_aft => 0,
                                   nquantacc_bef     => rbp_sp.quant_acc,
                                   nquantacc_aft     => rbp_sp.quant_acc,
                                   nquantaltacc_bef  => 0,
                                   nquantaltacc_aft  => 0,
                                   npriceplan_bef    => 0,
                                   npriceplan_aft    => 0,
                                   npriceacc_bef     => 0,
                                   npriceacc_aft     => 0,
                                   nprmeas_bef       => 0,
                                   nprmeas_aft       => 0,
                                   nsumplan_bef      => 0,
                                   nsumplan_aft      => 0,
                                   nsumacc_bef       => 0,
                                   nsumacc_aft       => 0,
                                   snote_bef         => to_char(null),
                                   snote_aft         => to_char(null),
                                   nbudgexpsp_bef    => to_number(null),
                                   nbudgexpsp_aft    => to_number(null),
                                   nrn               => nrn_dir_sp);
      end if;
    end if;
  end p_buyplandir_find_insert_sp;

  /*Процедура выполняет распределение изменений*/
  procedure p_distr_diff(ncompany   in number /*Организация*/,
                         nrn_bp     in number /*Регистрационный номер записи плана закупок*/,
                         nrn_ord_sp in number /*Регистрационный номер записи строки заказа*/) is
  
    /*Атрибуты записи таблицы изменений*/
    rdir_ord udo_umts_05_replan%rowtype;
  
    /*Разница*/
    ndiff pkg_std.tQUANT;
  
    /*Знак разницы*/
    nsign_diff number;
  
    /*Распределенное количество*/
    nquant_distr pkg_std.tQUANT;
  
    /*Текущее распределенное количество*/
    nquant_distr_cur pkg_std.tQUANT;
  
    /*Атрибуты записи строки заказа подразделений*/
    rdep_ord_sp departmentords%rowtype;
  
    /*Атрибуты записи заказа подразделений*/
    rdep_ord departmentord%rowtype;
  
    /*Исходное количество в плане*/
    nquant_ref_orig pkg_std.tQUANT;
  
  begin
    /*Атрибуты записи таблицы изменений*/
    begin
      select t.*
        into rdir_ord
        from udo_umts_05_replan t
       where t.rn = nrn_ord_sp;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn_ord_sp,
                                 sUNIT_TABLE => 'udo_umts_05_replan');
    end;
  
    /*Исходное количество в плане*/
    nquant_ref_orig := rdir_ord.quant_ref;
  
    /*Разница*/
    ndiff := greatest(0,
                      rdir_ord.quant - rdir_ord.quant_res -
                      rdir_ord.quant_inv) - rdir_ord.quant_ref;
  
    /*Знак разницы*/
    nsign_diff := sign(ndiff);
  
    /*Определяем модуль разницы*/
    ndiff := abs(ndiff);
  
    /*Распределенное количество*/
    nquant_distr := 0;
  
    /*Тип записи*/
    rdir_ord.rec_type := 2;
  
    /*Цикл по строкам заказа в плане закупок*/
    for ref_cursor in (select r.rn as nrn,
                              r.prn as nprn,
                              r.quant_plan as nquant,
                              prsg_prop.dGET(nCOMPANY  => r.company,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'BuyPlaneSpecsReferences',
                                             nDOCUMENT => r.rn,
                                             sPROPCODE => 'УМТС_ПланДатаПост') as dplan_date,
                              bp_sp.prn as nrn_bp /*Анненко И.С. 29.11.2022*/
                         from buyplanesp bp_sp, buyplanespref r
                        where /*Анненко И.С. 29.11.2022 bp_sp.prn = nrn_bp and*/
                        r.prn = bp_sp.rn
                    and r.deptordsp = rdir_ord.rn
                        order by prsg_prop.dGET(nCOMPANY  => r.company,
                                                nVERSION  => to_number(null),
                                                sUNITCODE => 'BuyPlaneSpecsReferences',
                                                nDOCUMENT => r.rn,
                                                sPROPCODE => 'УМТС_ПланДатаПост') desc) loop
    
      /*Плановая дата поставки*/
      rdir_ord.plan_date := ref_cursor.dplan_date;
    
      /*Регистрационный номер записи строки плана*/
      rdir_ord.rn_sp := ref_cursor.nprn;
    
      /*Регистрационный номер записи строки заказа*/
      rdir_ord.rn_ref := ref_cursor.nrn;
    
      /*Текущее распределенное количество*/
      if (nquant_distr >= ndiff) then
        nquant_distr_cur := 0;
      else
        if (nsign_diff = 1) then
          nquant_distr_cur := ndiff;
        else
          nquant_distr_cur := least(ref_cursor.nquant, ndiff - nquant_distr);
        end if;
      end if;
    
      /*Количество*/
      rdir_ord.quant_ref := ref_cursor.nquant +
                            nsign_diff * nquant_distr_cur;
    
      /*Распределенное количество*/
      nquant_distr := nquant_distr + nquant_distr_cur;
    
      /*Выполняем добавление записи*/
      /*Анненко И.С. 29.11.2022*/
      if (ref_cursor.nrn_bp = nrn_bp) and
         not (rdir_ord.quant_ref = 0 and ref_cursor.nquant = 0) /*Анненко И.С. 20.01.2023*/
       then
        insert into udo_umts_05_replan values rdir_ord;
      end if;
    end loop;
  
    /*Выполняем проверку распределения количества*/
    if (cmp_num(ndiff, nquant_distr) = 0) then
    
      /*Атрибуты записи строки заказа подразделений*/
      begin
        select s.*
          into rdep_ord_sp
          from departmentords s
         where s.rn = rdir_ord.rn
           and s.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir_ord.rn,
                                   sUNIT_TABLE => 'DepartmentsOrdersSpecs');
      end;
    
      /*Атрибуты записи заказа подразделений*/
      begin
        select do.*
          into rdep_ord
          from departmentord do
         where do.rn = rdep_ord_sp.prn
           and do.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdep_ord_sp.prn,
                                   sUNIT_TABLE => 'DepartmentsOrders');
      end;
    
      p_exception(0,
                  'Не удалось выполнить распределение изменения количества в плане закупок по заказу ' ||
                  pkg_document.make_number(ndoc_type => rdep_ord.ord_doctype,
                                           sdoc_pref => rdep_ord.ord_pref,
                                           sdoc_numb => rdep_ord.ord_numb,
                                           ddoc_date => rdep_ord.ord_date) ||
                  ', номенклатура ' ||
                  f_dicnomns_get_code(nNOMEN => rdep_ord_sp.nomen) ||
                  chr(13) || chr(10) || 'Заявлено = ' ||
                  to_char(rdir_ord.quant) || chr(13) || chr(10) ||
                  'Зарезервировано с остатков = ' ||
                  to_char(rdir_ord.quant_res) || chr(13) || chr(10) ||
                  'Выдано с остатков = ' || to_char(rdir_ord.quant_inv) ||
                  chr(13) || chr(10) || 'Включено в ПЗ = ' ||
                  to_char(nquant_ref_orig) || chr(13) || chr(10) ||
                  'К распределению = ' || to_char(ndiff) || chr(13) ||
                  chr(10) || 'Распределено = ' || to_char(nquant_distr));
    end if;
  end p_distr_diff;

  /*Процедура выполняет заполнение таблицы изменений*/
  procedure p_fill_dir_tab(rbp            in buyplane%rowtype    /*Атрибуты записи плана*/
                          ,ndepartmentord in number default null /* Заказ подразделения. RN (25/06/2024 Степанов М.) */) is
  
    /*ИГК*/
    sigk govcntrid.code%type;
  
    /*Признак планирования по ИГК*/
    ssign_igk pkg_std.tSTRING;
  
    /*Группа номенклатуры*/
    sgrp pkg_std.tSTRING;
  
    ntmp number;
  
  begin
    /*ИГК*/
    if (rbp.govcntrid is not null) then
      begin
        select igk.code
          into sigk
          from govcntrid igk
         where igk.rn = rbp.govcntrid
           and igk.company = rbp.company;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rbp.govcntrid,
                                   sUNIT_TABLE => 'GovernmentContractsIdentifiers');
      end;
    end if;
  
    /*Признак планирования по ИГК*/
    ssign_igk := prsg_prop.SGET(nCOMPANY  => rbp.company,
                                nVERSION  => to_number(null),
                                sUNITCODE => 'DOCTYPES',
                                nDOCUMENT => rbp.doctype,
                                sPROPCODE => 'УМТС_ПланироватьИГК');
  
    /*Группа номенклатуры*/
    sgrp := prsg_prop.SGET(nCOMPANY  => rbp.company,
                           nVERSION  => to_number(null),
                           sUNITCODE => 'DOCTYPES',
                           nDOCUMENT => rbp.doctype,
                           sPROPCODE => 'УМТС_ГруппаНомен');
  
    /*Выполняем очистку таблицы перепланирования*/
    delete udo_umts_05_replan;
  
    /*Выполнем заполнение таблицы перепланирования новыми заказами,
      которые ни разу не включались в планы закупок*/
    insert into udo_umts_05_replan
      (rec_type,
       rn,
       modif,
       quant,
       quant_res,
       quant_inv,
       plan_date,
       rn_hist,
       rn_sp,
       rn_ref,
       quant_ref)
      select 1,
             s.rn,
             nvl(s.nom_modif, 0),
             s.main_quant,
             0,
             0,
             udo_pkg_umts_01_plan.f_departmentords_clc_plan_date(ncompany => rbp.company,
                                                                 nrn      => s.rn),
             to_number(null),
             to_number(null),
             to_number(null),
             to_number(null)
        from departmentord o, ins_department d, departmentords s
       where (o.ord_state = 1 -- только утвержденные
              --or (utilizer in('CITK_MARKOV') and o.rn in(75928804)) -- Марков МВ. исключения для включения старых заказов
              --or (utilizer in('KHOK') and o.rn in(157821571, 157821615)) -- исключения для закрытых старых заказов
              )
         and d.rn = o.acc_subdiv
         and d.code in ('ОМТС', 'Отдел метрологии', 'IT', 'Кооперация', 'ВЭД') -- перечень закупающих подразделений
         and s.prn = o.rn
         and s.company = rbp.company
         -- 29/02/2024 Марков МВ. Ограничение по дате заказа подразделения (до 01/01/2023 не включаем)
         and ((o.ord_date >= s2d('01.01.2024') /*or (utilizer in ('KHOK') and o.ord_date >= s2d('01.01.2023'))*/ )
              --or (utilizer in('CITK_MARKOV') and s.rn in(92224948,92234085,92243353,92297575))  -- Марков МВ. исключения для включения старых заказов
             )
         -- 01/12/2023 временное ограничение на ЦВМ12Р Марков МВ.
         and o.rn not in(105205934, 105315018, 105204818)
         --
         and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rbp.company,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'DepartmentsOrdersSpecs',
                                               nDOCUMENT => s.rn,
                                               sPROPCODE => 'УМТС_НеЗакупать'))),
                     'да') = 0
         and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rbp.company,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'DepartmentsOrdersSpecs',
                                               nDOCUMENT => s.rn,
                                               sPROPCODE => 'УМТС_Дубль'))),
                     'да') = 0
         and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rbp.company,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'DepartmentsOrders',
                                               nDOCUMENT => o.rn,
                                               sPROPCODE => 'СОСТ_ЗАЯВКИ'))),
                     'выполнено') = 0
         and not exists
       (select /*+ no_unnest*/
               1
                from buyplanespref r
               where r.deptordsp = s.rn)
            /*Фильтр по группе номенклатуры/типу плана закупок*/
         and s.nomen in (
                         --         
                         /* 17/09/2024 Марков МВ. строго по группе номенклатуры!!!
                         select n.rn
                           from dicnomns n
                          where get_doctypes_code_id(nFLAG_SMART => 0,
                                                     nRN         => rbp.doctype) =
                                'ПЗ_Импорт'
                            and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rbp.company,
                                                                  nVERSION  => to_number(null),
                                                                  sUNITCODE => 'Nomenclator',
                                                                  nDOCUMENT => n.rn,
                                                                  sPROPCODE => 'УМТС_Импорт'))),
                                        'да') = 1
                         --
                         union all*/
                         --         
                         select n.rn
                           from dicnomns n
                          where /* 17/09/2024 Марков МВ. строго по группе номенклатуры!!!
                                get_doctypes_code_id(nFLAG_SMART => 0,
                                                     nRN         => rbp.doctype) <>
                                'ПЗ_Импорт'
                            and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rbp.company,
                                                                  nVERSION  => to_number(null),
                                                                  sUNITCODE => 'Nomenclator',
                                                                  nDOCUMENT => n.rn,
                                                                  sPROPCODE => 'УМТС_Импорт'))),
                                        'да') = 0
                            and*/ prsg_prop.SGET(nCOMPANY  => rbp.company,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'Nomenclator',
                                               nDOCUMENT => n.rn,
                                               sPROPCODE => 'УМТС_ГруппаНомен') = sgrp
                         --
                         )
            /*Фильтр по ИГК*/
         and (cmp_vc2(lower(trim(ssign_igk)), 'да') = 1 and
              sigk = udo_f_departmentord_igk(NFACEACC => o.faceacc) or
              cmp_vc2(lower(trim(ssign_igk)), 'да') = 0 and
              rbp.govcntrid is null)
         and (o.rn = ndepartmentord or ndepartmentord is null) /* Заказ подразделения. RN (25/06/2024 Степанов М.) */;
  
    /*Цикл по новым заказам без модификации*/
    for new_cursor in (select o.ord_doctype,
                              o.ord_pref,
                              o.ord_numb,
                              o.ord_date,
                              s.nomen
                         from udo_umts_05_replan t,
                              departmentords     s,
                              departmentord      o
                        where t.rec_type = 1
                          and t.modif = 0
                          and s.rn = t.rn
                          and o.rn = s.prn) loop
      p_exception(0,
                  'Не указана модификация для заказа ' ||
                  pkg_document.make_number(ndoc_type => new_cursor.ord_doctype,
                                           sdoc_pref => new_cursor.ord_pref,
                                           sdoc_numb => new_cursor.ord_numb,
                                           ddoc_date => new_cursor.ord_date) ||
                  ', номенклатура ' ||
                  f_dicnomns_get_code(nNOMEN => new_cursor.nomen));
    end loop;
  
    /*Цикл по новым заказам*/
    for new_cursor in (select *
                         from udo_umts_05_replan t
                        where t.rec_type = 1) loop
    
      /*Выполняем корректировку плановой даты поставки*/
      if (new_cursor.plan_date > rbp.end_period) then
        new_cursor.plan_date := rbp.end_period;
      end if;
    
      if (new_cursor.plan_date < add_months(trunc(sysdate, 'month'), 2) - 1) then
        new_cursor.plan_date := least(add_months(trunc(sysdate, 'month'), 2) - 1,
                                      rbp.end_period);
      end if;
    
      /*Зарезервировано по строке спецификации*/
      udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY        => rbp.company,
                                                        NRN             => new_cursor.rn,
                                                        NQUANT_PERF     => new_cursor.quant_res,
                                                        NQUANT_PERF_ALT => ntmp);
    
      /*Выдано по резерву к строке спецификации (отработана накладная)*/
      --if new_cursor.rn != 83624200 then -- Марков
      udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_EXEC_QNT(NCOMPANY        => rbp.company,
                                                         NRN             => new_cursor.rn,
                                                         NQUANT_PERF     => new_cursor.quant_inv,
                                                         NQUANT_PERF_ALT => ntmp);
      --else
      --  new_cursor.quant_inv := 0;
      --  ntmp := 0;
      --end if;
      /*Регистрационный номер записи истории изменений*/
      select max(h.rn)
        into new_cursor.rn_hist
        from depordsphs h
       where h.prn = new_cursor.rn;
    
      /*Выполняем исправление записи*/
      update udo_umts_05_replan t
         set t.quant_res = new_cursor.quant_res,
             t.quant_inv = new_cursor.quant_inv,
             t.plan_date = new_cursor.plan_date,
             t.rn_hist   = new_cursor.rn_hist
       where t.rn = new_cursor.rn;
    
      /*Выполняем проверку исправления записи*/
      if (sql%notfound) then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => new_cursor.rn,
                                 sUNIT_TABLE => 'udo_umts_05_replan');
      end if;
    end loop;
  
    /*Фильтр по количеству*/
    delete udo_umts_05_replan t
     where t.rec_type = 1
       and t.quant - t.quant_res - t.quant_inv <= 0
       /*and utilizer != 'KHOK'*/;
  
    /*Выполняем заполнение таблицы перепланирования изменениями*/
    insert into udo_umts_05_replan
      (rec_type,
       rn,
       modif,
       quant,
       quant_res,
       quant_inv,
       plan_date,
       rn_hist,
       rn_sp,
       rn_ref,
       quant_ref)
      select 0,
             dos.rn,
             dos.nom_modif,
             (case
               when (do.ord_state = 4 /*Аннулирован*/
                    ) then
                (0)
               when (cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => dos.company,
                                                       nVERSION  => to_number(null),
                                                       sUNITCODE => 'DepartmentsOrdersSpecs',
                                                       nDOCUMENT => dos.rn,
                                                       sPROPCODE => 'УМТС_Дубль'))),
                             'да') = 1) then
                (0)
               -- 17/10/2023 Марков МВ
               when (cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => dos.company,
                                                       nVERSION  => to_number(null),
                                                       sUNITCODE => 'DepartmentsOrdersSpecs',
                                                       nDOCUMENT => dos.rn,
                                                       sPROPCODE => 'УМТС_НеЗакупать'))),
                             'да') = 1) then
                (0)
               else
                (dos.main_quant)
             end),
             0,
             0,
             trunc(sysdate),
             to_number(null),
             to_number(null),
             to_number(null),
             to_number(null)
        from departmentords dos, departmentord do
       where dos.rn in (select r.deptordsp -- строка заказа подразделения включена в указанный план
                          from buyplanesp s, buyplanespref r
                         where s.prn = rbp.rn
                           and s.company = rbp.company
                           and r.prn = s.rn)
         and do.rn = dos.prn
         -- 25/03/2024 Марков МВ. Ограничение до 01/01/2023 Заказы не включаются в распоряжения
         -- Согласовано с Лукашиной
         and ((do.ord_date >= s2d('01.01.2024') /*or (utilizer in ('KHOK') and do.ord_date >= s2d('01.01.2023'))*/ )
         --or (utilizer in('CITK_MARKOV') and dos.rn in(92224948,92234085,92243353,92297575)) -- кроме исключений по просьбе ОМТС
             )
         ;
  
    /*Цикл по изменениям*/
    for old_cursor in (select s.prn as nrn_ord,
                              0 as sign_quant,
                              t.*
                         from udo_umts_05_replan t, departmentords s
                        where t.rec_type = 0
                          --and s.main_quant > 0 -- иначе не попадут удаленные 
                          and s.rn = t.rn) loop
    
      /*Дата включения в план закупок*/
      old_cursor.plan_date := prsg_prop.dGET(nCOMPANY  => rbp.company,
                                             nVERSION  => to_number(null),
                                             sUNITCODE => 'DepartmentsOrdersSpecs',
                                             nDOCUMENT => old_cursor.rn,
                                             sPROPCODE => 'УМТС_ДатаВклПЗ');
    
      /*Выполняем проверку указания даты включения в план закупок*/
      if (old_cursor.plan_date is null) /*and utilizer != 'KHOK'*/ then
        p_exception(0,
                    'Для позиции ' ||
                    udo_get_nommodif_code_id(nFLAG_SMART => 0,
                                             nRN         => old_cursor.modif) ||
                    ' заявки на снабжение ' ||
                    f_docdescrs_describe(nCOMPANY     => rbp.company,
                                         sUNITCODE    => 'DepartmentsOrders',
                                         nRN          => old_cursor.nrn_ord,
                                         nRETURN_NULL => 0) ||
                    ' не указана дата включения в план закупок. Обратитесь к администратору');
      end if;
    
      /*Зарезервировано*/
      -- 19/01/2024 Марков МВ. -- добавим исключение из плана для резервов по позициям, для которых нет заказа поставщику
      /*p_buyplanespref_calc_dlvr_qnt(nSPEC      => old_cursor.rn, -- рег.номер записи спецификации заказа подразделения
                                    nPLANE     => rbp.rn, -- рег.нмоер плана закупок
                                    nQUANT     => old_cursor.quant_res, -- включено в заказ поставщику в ОЕИ
                                    nQUANT_ALT => ntmp);
      if old_cursor.quant_res > 0 then
        -- есть заказы поставщику - смотрим резервы ДО даты включения в план
        udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY         => rbp.company,
                                                          NRN              => old_cursor.rn,
                                                          DPLAN_DATE_BEGIN => old_cursor.plan_date,
                                                          NQUANT_PERF      => old_cursor.quant_res,
                                                          NQUANT_PERF_ALT  => ntmp);
      else
        -- нет заказов поставщику - смотрим ВСЕ резервы
        udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY         => rbp.company,
                                                          NRN              => old_cursor.rn,
                                                          NQUANT_PERF      => old_cursor.quant_res,
                                                          NQUANT_PERF_ALT  => ntmp);
      end if;*/
      -- 22/04/2026 Марков МВ. Зарезервировано - только из свободных остатков
      UDO_PKG_DEPORDS_PRF.P_DEPORDS_CALC_RES_SIGN(NCOMPANY        => rbp.company,
                                                  NRN             => old_cursor.rn,
                                                  NQUANT_PERF     => old_cursor.quant_res,
                                                  NQUANT_PERF_ALT => nTMP,
                                                  nCHECK_TRINV    => 1);
      /*Выдано*/
      -- 24/04/2026 Марков МВ. Для изменений надо ВСЕ выдачи.
      -- Иначе получаем неучтенные выдачи, которых уже нет в резерве.
      udo_pkg_depords_prf.P_DEPARTMENTORDS_CALC_EXEC_QNT(NCOMPANY         => rbp.company,
                                                         NRN              => old_cursor.rn,
                                                         --DPLAN_DATE_BEGIN => old_cursor.plan_date,
                                                         NQUANT_PERF      => old_cursor.quant_inv,
                                                         NQUANT_PERF_ALT  => ntmp);
    
      /*Выполняем проверку количества*/
      if (cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => rbp.company,
                                            nVERSION  => to_number(null),
                                            sUNITCODE => 'DepartmentsOrdersSpecs',
                                            nDOCUMENT => old_cursor.rn,
                                            sPROPCODE => 'УМТС_Дубль'))),
                  'да') = 1) then
      null;
        /*Зарезервировано*/
        /*if (old_cursor.quant_res > 0) then
          p_exception(0,
                      'Для позиции ' ||
                      udo_get_nommodif_code_id(nFLAG_SMART => 0,
                                               nRN         => old_cursor.modif) ||
                      ' заявки на снабжение ' ||
                      f_docdescrs_describe(nCOMPANY     => rbp.company,
                                           sUNITCODE    => 'DepartmentsOrders',
                                           nRN          => old_cursor.nrn_ord,
                                           nRETURN_NULL => 0) ||
                      ' указан признак дублирования и есть активные резервы');
        end if;*/
      
        /*Выдано*/
        /* 15/02/2024 Марков МВ. по старым заявкам может быть выдача и дубль!!!!
        if (old_cursor.quant_inv > 0) then
          p_exception(0,
                      'Для позиции ' ||
                      udo_get_nommodif_code_id(nFLAG_SMART => 0,
                                               nRN         => old_cursor.modif) ||
                      ' заявки на снабжение ' ||
                      f_docdescrs_describe(nCOMPANY     => rbp.company,
                                           sUNITCODE    => 'DepartmentsOrders',
                                           nRN          => old_cursor.nrn_ord,
                                           nRETURN_NULL => 0) ||
                      ' указан признак дублирования и есть выдача');
        end if;*/
      
      end if;
    
      /*Регистрационный номер записи истории изменений*/
      select max(h.rn)
        into old_cursor.rn_hist
        from depordsphs h
       where h.prn = old_cursor.rn;
    
      /*Количество в плане закупок*/
      select sum(r.quant_plan)
        into old_cursor.quant_ref
        from buyplanespref r
       where r.deptordsp = old_cursor.rn;
    
      /*Выполняем исправление записи*/
      update udo_umts_05_replan t
         set t.quant_res = old_cursor.quant_res,
             t.quant_inv = old_cursor.quant_inv,
             t.rn_hist   = old_cursor.rn_hist,
             t.quant_ref = old_cursor.quant_ref,
             t.plan_date = nvl(old_cursor.plan_date, sysdate)
       where t.rn = old_cursor.rn;
    
      /*Выполняем проверку исправления записи*/
      if (sql%notfound) then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => old_cursor.rn,
                                 sUNIT_TABLE => 'udo_umts_05_replan');
      end if;
    end loop;
  
    /*Выполняем удаление записей без изменений*/
    delete from udo_umts_05_replan t
     where t.rec_type = 0
       and not exists
     (select 1
              from buyplanespref r
                   /*Анненко И.С. 18.04.2023*/,
                   buyplanesp s
             where r.deptordsp = t.rn
               and s.rn = r.prn /*Анненко И.С. 18.04.2023*/
               and s.prn = rbp.rn /*Анненко И.С. 18.04.2023*/
               and not ((r.quant_plan = 0) and (t.quant - t.quant_res - t.quant_inv = t.quant_ref)) /*Анненко И.С. 23.05.2023*/
               and cmp_num(r.hist, t.rn_hist) = 0)
       and t.quant - t.quant_res - t.quant_inv = t.quant_ref;
  
    /*Цикл по общим записям изменений*/
    for ref_cursor in (select t.rn as nrn
                         from udo_umts_05_replan t
                        where t.rec_type = 0) loop
      p_distr_diff(ncompany   => rbp.company,
                   nrn_bp     => rbp.rn,
                   nrn_ord_sp => ref_cursor.nrn);
    end loop;
  
    /*Выполняем удаление общих записей по изменениям*/
    delete udo_umts_05_replan t where t.rec_type = 0;
  
    /*Выполняем удаление заказов. включенных в неотработанные распоряжения*/
    delete udo_umts_05_replan t
     where exists (select 1
              from buyplandir d, buyplandirsp s, buyplandirspref r
             where d.work_date is null
               and s.prn = d.rn
               and r.prn = s.rn
               and r.deptordsp = t.rn);

  end p_fill_dir_tab;

  /*Процедура выполняет обработку записи таблицы изменений*/
  procedure p_proc_dir_tab(ncompany    in number /*Организация*/,
                           nprn        in number /*Регистрационный номер родителя*/,
                           nrn         in number /*Регистрационный номер строки заказа подразделений*/,
                           nrn_ref     in number /*Регистрационный номер строки заказа подразделений в плане закупок*/,
                           nplan       in number /*Регистрационный номер записи плана закупок*/,
                           ssign_disrc in varchar2 /*Дискретность*/) is
  
    /*Атрибуты записи таблицы изменений*/
    rdir_ord udo_umts_05_replan%rowtype;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
    /*Атрибуты записи строки заказа в плане закупок*/
    rref buyplanespref%rowtype;
  
    /*Регистрационный номер записи строки распоряжения об изменении плана закупок*/
    nrn_dir_sp pkg_std.tREF;
  
    /*Регистрационный номер записи строки заказа в распоряжении*/
    nrn_dir_ref pkg_std.tREF;

    /*Группа номенклатуры*/
    sgrp     pkg_std.tSTRING;
    sNomCode dicnomns.nomen_code%type;
    nom_rn   dicnomns.rn%type;
  begin
    /*Атрибуты записи таблицы изменений*/
    begin
      select t.*
        into rdir_ord
        from udo_umts_05_replan t
       where t.rn = nrn
         and cmp_num(t.rn_ref, nrn_ref) = 1;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'udo_umts_05_replan');
    end;

    /* KHOK 07.02.2025 Проверка наличия группы номенклатуры */
    begin
      select D.NOMEN_CODE, D.RN,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 19579777 and UNITCODE = 'Nomenclator' and UNIT_RN = D.RN)
        into sNomCode, nom_rn, sgrp
        from DICNOMNS D,
             NOMMODIF M
       where M.RN = rdir_ord.modif
         and D.RN = M.PRN;
    end;

    if (trim(sgrp) is null) then
        p_exception(0, 'Для номенклатуры %s не указана группа. Обратитесь к ответственному.', sNomCode );
    end if;
if rdir_ord.rn = 242364905 and utilizer in ('CITK_MARKOV') then
  p_exception(0, 'rdir_ord.rn_sp = %s; rdir_ord.quant = %s; rdir_ord.quant_res = %s; rdir_ord.quant_inv = %s', 
                 rdir_ord.rn_sp, rdir_ord.quant, rdir_ord.quant_res, rdir_ord.quant_inv);
end if;
    if (rdir_ord.rn_sp is null) then
      /*Период*/
      udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => rdir_ord.plan_date,
                                              speriod       => ssign_disrc,
                                              dperiod_begin => dperiod_begin,
                                              dperiod_end   => dperiod_end);
    
      /*Выполняем поиск строки плана закупок*/
      begin
        select s.rn
          into rdir_ord.rn_sp
          from buyplanesp s
         where s.prn = nplan
           and s.nommodif = rdir_ord.modif
           and s.shipment_plan = dperiod_end;
      exception
        when no_data_found then
          rdir_ord.rn_sp := to_number(null);
        when too_many_rows then
          p_exception(0, 'Не удалось однозначно определить строку плана закупок');
      end;
    end if;
  
    /*Выполняем поиск и при необходимости добавление строки распоряжения*/
    p_buyplandir_find_insert_sp(ncompany    => ncompany,
                                nprn        => nprn,
                                nrn_plan_sp => rdir_ord.rn_sp,
                                nmodif      => rdir_ord.modif,
                                dperiod_end => dperiod_end,
                                nrn_dir_sp  => nrn_dir_sp);
  
    if (rdir_ord.rn_ref is null) then
    
      /*Выполняем добавление строки заказа в распоряжение*/
      p_buyplandirspref_base_insert(ncompany          => ncompany,
                                    nprn              => nrn_dir_sp,
                                    ndeptordsp        => rdir_ord.rn,
                                    nconsordsp        => to_number(null),
                                    nquantplan_bef    => to_number(null),
                                    nquantplan_aft    => rdir_ord.quant -
                                                         rdir_ord.quant_res -
                                                         rdir_ord.quant_inv,
                                    nquantaltplan_bef => to_number(null),
                                    nquantaltplan_aft => 0,
                                    nsign_excl        => 0,
                                    nhist             => rdir_ord.rn_hist,
                                    nrn               => nrn_dir_ref,
                                    nsign_recalc      => 0);
    
    else
    
      /*Атрибуты записи строки заказа*/
      begin
        select r.*
          into rref
          from buyplanespref r
         where r.rn = rdir_ord.rn_ref
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir_ord.rn_ref,
                                   sUNIT_TABLE => 'BuyPlaneSpecsReferences');
      end;
    
      /*Выполняем добавление строки заказа в распоряжение*/
      p_buyplandirspref_base_insert(ncompany          => ncompany,
                                    nprn              => nrn_dir_sp,
                                    ndeptordsp        => rref.deptordsp,
                                    nconsordsp        => to_number(null),
                                    nquantplan_bef    => nvl(rref.quant_plan, 0),
                                    nquantplan_aft    => nvl(rdir_ord.quant_ref, 0),
                                    nquantaltplan_bef => 0,
                                    nquantaltplan_aft => 0,
                                    nsign_excl        => 0,
                                    nhist             => rdir_ord.rn_hist,
                                    nrn               => nrn_dir_ref,
                                    nsign_recalc      => 0);
    end if;
  
    /*Плановая дата поставки*/
    prsg_prop.VSET(sUNITCODE  => 'BuyingPlanDirectsSpecsReferences',
                   nDOCUMENT  => nrn_dir_ref,
                   sPROPCODE  => 'УМТС_ПланДатаПост',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => rdir_ord.plan_date);
  end p_proc_dir_tab;

  /*Процедура выполняет пересчет количества в строках распоряжения об изменении плана закупок*/
  procedure p_buyplandir_recalc_sp(ncompany in number /*Организация*/,
                                   nrn      in number /*Регистрационный номер записи*/) is
    /*Группа номенклатуры*/
    sgrp     pkg_std.tSTRING;
    sNomCode dicnomns.nomen_code%type;
  begin
    /*Цикл по строкам распоряжения*/
    for sp_cursor in (
      select s.rn as nrn, s.quantplan_bef as nquant, s.nomen_bef, s.nomen_aft
        from buyplandirsp s
       where s.prn = nrn
         and s.company = ncompany
    ) loop
      /* KHOK 07.02.2025 Проверка наличия группы номенклатуры */
      if sp_cursor.nomen_bef is not null then
        begin
          select D.Nomen_Code,
            (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 19579777 and UNITCODE = 'Nomenclator' and UNIT_RN = sp_cursor.nomen_bef)
            into sNomCode, sgrp
            from DICNOMNS D
           where D.RN = sp_cursor.nomen_bef;
        end;
        if trim(sgrp) is null then
          p_exception(0, 'Для номенклатуры %s не указана группа. Обратитесь к ответственному.', sNomCode );
        end if;
      end if;    

      /*Выполняем расчет количества*/
      select nvl(sp_cursor.nquant, 0) +
             nvl(sum(r.quantplan_aft - nvl(r.quantplan_bef, 0)), 0)
        into sp_cursor.nquant
        from buyplandirspref r
       where r.prn = sp_cursor.nrn
         and r.company = ncompany;
    
      /*Выполняем исправление количества*/
      update buyplandirsp s
         set s.quantplan_aft = sp_cursor.nquant,
             s.quantacc_aft  = sp_cursor.nquant
       where s.rn = sp_cursor.nrn
         and s.company = ncompany;
    
      /*Выполняем проверку исправления записи*/
      if (sql%notfound) then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => sp_cursor.nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecs');
      end if;
    end loop;
  end p_buyplandir_recalc_sp;

  /*Процедура выполняет базовое формирование распоряжения об изменении плана закупок*/
  procedure p_buyplandir_bcrt(ncompany        in number               /*Организация*/,
                              nrn             in number               /*Регистрационный номер записи*/
                             ,ndepartmentord  in number default null  /* Заказ подразделения. RN (25/06/2024 Степанов М.) */ ) is
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Атрибуты записи распоряжения*/
    rdir buyplandir%rowtype;
  
    /*Количество записей в спецификации*/
    ncount number;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
  begin
    /*Атрибуты записи распоряжения*/
    begin
      select dir.*
        into rdir
        from buyplandir dir
       where dir.rn = nrn
         and dir.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirects');
    end;
  
    /*Если распоряжение отработано, то выдаем сообщение об ошибке*/
    if (rdir.work_date is not null) then
      p_exception(0, 'Распоряжение отработано');
    end if;
  
    /*Атрибуты записи плана*/
    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rdir.plan
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir.plan,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;
  
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (rbp.state <> 2) then
      P_EXCEPTION(0, 'План закупок не утвержден');
    end if;
  
    /*Количество записей в спецификации*/
    select count(1)
      into ncount
      from buyplandirsp s
     where s.prn = nrn
       and s.company = ncompany;
  
    /*Если распоряжение уже сформировано, то выдаем сообщение об ошибке*/
    if (ncount > 0) then
      p_exception(0, 'Распоряжение уже сформировано');
    end if;
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Выполняем заполнение таблицы изменений*/
    p_fill_dir_tab(rbp => rbp
                  ,ndepartmentord => ndepartmentord /* Заказ подразделения. RN (25/06/2024 Степанов М.) */ );

    /*Цикл по строкам таблицы перепланирования*/
    for ord_cursor in (select t.rn as nrn, t.rn_ref as nrn_ref
                         from udo_umts_05_replan t
                        where t.rec_type in (1, 2)) loop
      p_proc_dir_tab(ncompany    => ncompany,
                     nprn        => rdir.rn,
                     nplan       => rbp.rn,
                     nrn         => ord_cursor.nrn,
                     nrn_ref     => ord_cursor.nrn_ref,
                     ssign_disrc => ssign_disrc);
    end loop;
  
    /*Выполняем пересчет количества в строках распоряжения об изменении плана закупок*/
    p_buyplandir_recalc_sp(ncompany => ncompany, nrn => nrn);
  end p_buyplandir_bcrt;

  /*Процедура выполняет базовое расформирование распоряжения об изменении плана закупок*/
  procedure p_buyplandir_brmv(ncompany in number /*Организация*/,
                              nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Атрибуты записи распоряжения*/
    rdir buyplandir%rowtype;
  
  begin
    /*Атрибуты записи распоряжения*/
    begin
      select dir.*
        into rdir
        from buyplandir dir
       where dir.rn = nrn
         and dir.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirects');
    end;
  
    /*Если распоряжение отработано, то выдаем сообщение об ошибке*/
    if (rdir.work_date is not null) then
      p_exception(0, 'Распоряжение отработано');
    end if;
  
    /*Атрибуты записи плана*/
    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rdir.plan
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir.plan,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;
  
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (rbp.state <> 2) then
      P_EXCEPTION(0, 'План закупок не утвержден');
    end if;
  
    /*Цикл по строкам плана*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.prn = nrn
                         and s.company = ncompany) loop
      p_buyplandirsp_base_delete(nrn      => sp_cursor.nrn,
                                 ncompany => ncompany);
    end loop;
  end p_buyplandir_brmv;

  /*Процедура выполняет изменение плановой даты поставки*/
  procedure p_buyplandirspref_bset_pl_date(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           dplan_date in date /*Плановая дата поставки*/) is
  
    /*Атрибуты записи распоряжения*/
    rdir buyplandir%rowtype;
  
    /*Атрибуты записи строки распоряжения*/
    rdir_sp buyplandirsp%rowtype;
  
    /*Атрибуты записи заказа строки распоряжения*/
    rdir_sp_ref buyplandirspref%rowtype;
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;
  
    /*Дата начала периода планирования*/
    dperiod_begin date;
  
    /*Дата окончания периода планирования*/
    dperiod_end date;
  
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
  
    /*Регистрационный номер записи новой строки распоряжения*/
    nrn_dir_sp pkg_std.tREF;
  
    /*Регистрационный номер записи заказа строки распоряжения*/
    nrn_dir_ref pkg_std.tREF;
  
    /*Количество заказов*/
    ncount number;
  
  begin
    /*Если плановая дата поставки не изменилась, то выдаем сообщение об ошибке*/
    if (prsg_prop.dGET(nCOMPANY  => ncompany,
                       nVERSION  => to_number(null),
                       sUNITCODE => 'BuyingPlanDirectsSpecsReferences',
                       nDOCUMENT => nrn,
                       sPROPCODE => 'УМТС_ПланДатаПост') = dplan_date) then
      p_exception(0,
                  'Плановая дата поставки не изменилась');
    end if;
  
    /*Атрибуты записи заказа строки распоряжения*/
    begin
      select r.*
        into rdir_sp_ref
        from buyplandirspref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecsReferences');
    end;
  
    /*Если запись является изменением, то выдаем сообщение об ошибке*/
    if (rdir_sp_ref.quantplan_bef is not null) then
      p_exception(0,
                  'Действие недоступно для записи изменения');
    end if;
  
    /*Атрибуты записи строки распоряжения*/
    begin
      select s.*
        into rdir_sp
        from buyplandirsp s
       where s.rn = rdir_sp_ref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir_sp_ref.prn,
                                 sUNIT_TABLE => 'BuyingPlanDirects');
    end;
  
    /*Атрибуты записи распоряжения*/
    begin
      select dir.*
        into rdir
        from buyplandir dir
       where dir.rn = rdir_sp.prn
         and dir.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir_sp.prn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecs');
    end;
  
    /*Если распоряжение отработано, то выдаем сообщение об ошибке*/
    if (rdir.work_date is not null) then
      p_exception(0, 'Распоряжение отработано');
    end if;
  
    /*Атрибуты записи плана*/
    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rdir.plan
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir.plan,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;
  
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (rbp.state <> 2) then
      P_EXCEPTION(0, 'План закупок не утвержден');
    end if;
  
    /*Если плановая дата поставки не принадлежит периоду планирования, то выдаем сообщение об ошибке*/
    if not (dplan_date between rbp.begin_period and rbp.end_period) then
      p_exception(0,
                  'Плановая дата поставки должна принадлежать периоду планирования');
    end if;
  
    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');
  
    /*Период*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => dplan_date,
                                            speriod       => ssign_disrc,
                                            dperiod_begin => dperiod_begin,
                                            dperiod_end   => dperiod_end);
  
    /*Принадлежность к периоду не изменилась*/
    if (dperiod_end = rdir_sp.shipplan_aft) then
      /*Плановая дата поставки*/
      prsg_prop.VSET(sUNITCODE  => 'BuyingPlanDirectsSpecsReferences',
                     nDOCUMENT  => nrn,
                     sPROPCODE  => 'УМТС_ПланДатаПост',
                     sSTRVALUE  => to_char(null),
                     nNUMVALUE  => to_number(null),
                     dDATEVALUE => dplan_date);
    
      return;
    end if;
  
    /*Выполняем поиск строки плана закупок*/
    begin
      select s.rn
        into nrn_bp_sp
        from buyplanesp s
       where s.prn = rdir.plan
         and s.nommodif = rdir_sp.modif_aft
         and s.shipment_plan = dperiod_end;
    exception
      when no_data_found then
        nrn_bp_sp := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить строку плана закупок');
    end;
  
    /*Выполняем удаление строки заказа из распоряжения*/
    p_buyplandirspref_base_delete(nRN => nrn, nCOMPANY => ncompany);
  
    /*Количество заказов*/
    select count(1)
      into ncount
      from buyplandirspref r
     where r.prn = rdir_sp.rn
       and r.company = ncompany;
  
    /*Выполняем удаление строки распоряжения*/
    if (ncount = 0) then
      p_buyplandirsp_base_delete(nrn => rdir_sp.rn, ncompany => ncompany);
    end if;
  
    /*Выполняем поиск и при необходимости добавление строки распоряжения*/
    p_buyplandir_find_insert_sp(ncompany    => ncompany,
                                nprn        => rdir.rn,
                                nrn_plan_sp => nrn_bp_sp,
                                nmodif      => rdir_sp.modif_aft,
                                dperiod_end => dperiod_end,
                                nrn_dir_sp  => nrn_dir_sp);
  
    /*Выполняем добавление строки заказа в распоряжение*/
    p_buyplandirspref_base_insert(ncompany          => ncompany,
                                  nprn              => nrn_dir_sp,
                                  ndeptordsp        => rdir_sp_ref.deptordsp,
                                  nconsordsp        => to_number(null),
                                  nquantplan_bef    => to_number(null),
                                  nquantplan_aft    => rdir_sp_ref.quantplan_aft,
                                  nquantaltplan_bef => to_number(null),
                                  nquantaltplan_aft => 0,
                                  nsign_excl        => 0,
                                  nhist             => rdir_sp_ref.hist,
                                  nrn               => nrn_dir_ref,
                                  nsign_recalc      => 1);
  
    /*Плановая дата поставки*/
    prsg_prop.VSET(sUNITCODE  => 'BuyingPlanDirectsSpecsReferences',
                   nDOCUMENT  => nrn_dir_ref,
                   sPROPCODE  => 'УМТС_ПланДатаПост',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => dplan_date);
  end p_buyplandirspref_bset_pl_date;

  /*Процедура выполняет утверждение изменений заказа*/
  procedure p_buyplandirspref_confirm(ncompany  in number /*Организация*/,
                                      nrn       in number /*Регистрационный номер записи*/,
                                      sunitcode in varchar2 /*Код раздела*/,
                                      ndocument in number /*Регистрационный номер документа*/,
                                      ddate_to  in date /*Дата истории*/,
                                      sbase     in varchar2 /*Основание изменений*/) is
  
    /*Атрибуты записи заказа распоряжения*/
    rref buyplandirspref%rowtype;
  
    /*Регистрационный номер записи строки заказа в плане закупок*/
    nrn_bp_sp_ref pkg_std.tREF;
  
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
  
    /*Регистрационный номер записи истории изменений*/
    nrn_hist pkg_std.tREF;
    
    /* распоряжение об изменении*/
    nplan_dir pkg_std.tREF;
  
  begin
    /*Атрибуты записи заказа распоряжения*/
    begin
      select r.*
        into rref
        from buyplandirspref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecsReferences');
    end;
  
    /*Выполняем включение заказа в план закупок*/
    if (rref.quantplan_bef is null) then
      begin
        select sp.prn
          into nplan_dir
          from buyplandirsp sp
         where sp.rn = rref.prn;
      exception
        when no_data_found then
          p_exception(0, 'Не удалось определить распоряжение об изменении плана закупок.');
      end;
      udo_pkg_umts_01_plan.p_departmentords_bincl_bp(ncompany   => ncompany,
                                                     nrn        => rref.deptordsp,
                                                     dplan_date => prsg_prop.dGET(nCOMPANY  => ncompany,
                                                                                  nVERSION  => to_number(null),
                                                                                  sUNITCODE => 'BuyingPlanDirectsSpecsReferences',
                                                                                  nDOCUMENT => nrn,
                                                                                  sPROPCODE => 'УМТС_ПланДатаПост'),
                                                     nquant     => rref.quantplan_aft,
                                                     nsign_dir  => 1,
                                                     nplan_dir  => nplan_dir);
    
      /*Регистрационный номер записи строки заказа в плане закупок*/
      begin
        select r.rn, r.prn
          into nrn_bp_sp_ref, nrn_bp_sp
          from buyplanespref r
         where r.deptordsp = rref.deptordsp
           ; --and r.quant_plan > 0; /* 17/07/2025 KHOK */
      exception
        when no_data_found then
          p_exception(0,
                      'Не удалось определить строку заказа в плане закупок');
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить строку заказа в плане закупок ' || rref.deptordsp);
      end;
    
      /*Устанавливаем связь*/
      P_LINKSALL_LINK_DIRECT(nCOMPANY,
                             'BuyingPlanDirectsSpecsReferences',
                             rREF.RN,
                             rref.prn,
                             sysdate,
                             0,
                             'BuyPlaneSpecsReferences',
                             nrn_bp_sp_ref,
                             nrn_bp_sp,
                             sysdate,
                             0);
    
      return;
    end if;
  
    /*Регистрационный номер записи строки заказа в плане закупок*/
    begin
      select r.rn
        into nrn_bp_sp_ref
        from buyplandirsp s, buyplanespref r
       where s.rn = rref.prn
         and r.prn = s.plansp
         and r.deptordsp = rref.deptordsp;
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить строку заказа в плане закупок');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить строку заказа в плане закупок');
    end;
    /*Выполняем формирование истории*/
    p_buyplanesprefhs_make(ncompany  => ncompany,
                           nprn      => nrn_bp_sp_ref,
                           sunitcode => sunitcode,
                           ndocument => ndocument,
                           ddate_to  => ddate_to,
                           sbase     => sbase,
                           nrn       => nrn_hist);
  
    /*Плановая дата поставки*/
    prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferencesHistory',
                   nDOCUMENT  => nrn_hist,
                   sPROPCODE  => 'УМТС_ПланДатаПост',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => prsg_prop.dGET(nCOMPANY  => ncompany,
                                                nVERSION  => to_number(null),
                                                sUNITCODE => 'BuyingPlanDirectsSpecsReferences',
                                                nDOCUMENT => rref.rn,
                                                sPROPCODE => 'УМТС_ПланДатаПост'));
  
    /*Устанавливаем связь с историей*/
    P_LINKSALL_LINK_DIRECT(nCOMPANY,
                           'BuyingPlanDirectsSpecsReferences',
                           rref.RN,
                           rref.pRN,
                           sysdate,
                           0,
                           'BuyPlaneSpecsReferencesHistory',
                           nrn_hist,
                           nrn_bp_sp_ref,
                           sysdate,
                           0);
  
    /*Выполняем исправление строки заказа в плане закупок*/
    p_buyplanespref_base_update(nrn            => nrn_bp_sp_ref,
                                ncompany       => ncompany,
                                nquant_plan    => rref.quantplan_aft,
                                nquantalt_plan => rref.quantaltplan_aft,
                                nsign_excl     => rref.sign_excl,
                                nhist          => rref.hist,
                                nsign_client   => 0);
  end p_buyplandirspref_confirm;

  /*Процедура выполняет утверждение изменений строки плана*/
  procedure p_buyplandirsp_confirm(ncompany in number /*Организация*/,
                                   nrn      in number /*Регистрационный номер записи*/,
                                   nplan    in number /*Регистрационный номер записи плана закупок*/) is
  
    /*Атрибуты записи строки распоряжения*/
    rsp buyplandirsp%rowtype;
  
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
  
    /*Количество в заказах*/
    nquant_ord pkg_std.tQUANT;
    
    /* текст ошибки */
    sMSG varchar2(2000);
    
    sTMP varchar2(4000);
  
  begin
    /*Атрибуты записи строки распоряжения*/
    begin
      select sp.*
        into rsp
        from buyplandirsp sp
       where sp.rn = nrn
         and sp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecs');
    end;

    /*Выполняем включение нмоенклатуры заказа в план закупок*/
    if (rsp.kind = 1) then
      -- 23/10/2023 Марков МВ. ДОБАВИТЬ
      /*Регистрационный номер записи строки плана закупок*/
      begin
        select s.rn
          into nrn_bp_sp
          from buyplanesp s
         where s.prn = nplan
           and s.nommodif = rsp.modif_aft
           and s.shipment_plan = rsp.shipplan_aft;
      exception
        when no_data_found then
          -- 23/10/2023 Марков МВ. нет еще этой номенклатуры - надо добавить
          /*sMSG := 'Номенклатура (после): ';
          sMSG := sMSG || get_dicnomns_code_id(nFLAG_SMART => 0, nRN => rsp.nomen_aft);
          sMSG := sMSG || chr(10) || 'Количество: ';
          sMSG := sMSG || to_char(rsp.quantplan_aft);
          p_exception(0,
                      'Не удалось определить строку плана закупок' || chr(10) ||
                      sMSG);*/
          p_buyplanesp_base_insert(nCOMPANY       => ncompany,
                                   nPRN           => nplan,
                                   nNOMENCLS      => rsp.nomcls_aft,
                                   nNOMEN         => rsp.nomen_aft,
                                   nNOMNPACK      => rsp.nompack_aft,
                                   nNOMMODIF      => rsp.modif_aft,
                                   nNOMNMODIFPACK => rsp.modpack_aft,
                                   nUMEAS_MAIN    => rsp.umain_aft,
                                   nSTORE         => rsp.store_aft,
                                   nAGENT         => rsp.agent_aft,
                                   nSIGN_ONE_ROW  => null,
                                   dSHIPMENT_PLAN => rsp.shipplan_aft,
                                   dSHIPMENT_ACC  => rsp.shipacc_aft,
                                   nCOST_PLACE    => rsp.costplace_aft,
                                   nQUANT_PLAN    => 0,
                                   nQUANTALT_PLAN => 0,
                                   nQUANT_ACC     => 0,
                                   nQUANTALT_ACC  => 0,
                                   nPRICE_PLAN    => rsp.priceplan_aft,
                                   nPRICE_ACC     => rsp.priceacc_aft,
                                   nPR_MEAS       => rsp.prmeas_aft,
                                   nSUMM_PLAN     => 0,
                                   nSUMM_ACC      => 0,
                                   sNOTE          => null,
                                   dINCL_DATE     => trunc(sysdate),
                                   nBUDGEXPEND_SP => rsp.budgexpsp_aft,
                                   nRN            => nrn_bp_sp);
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить строку плана закупок');
      end;
    
      /*Устанавливаем связь*/
      P_LINKSALL_LINK_DIRECT(nCOMPANY,
                             'BuyingPlanDirectsSpecs',
                             rsp.RN,
                             rsp.pRN,
                             sysdate,
                             0,
                             'BuyPlaneSpecs',
                             nrn_bp_sp,
                             nPLAN,
                             sysdate,
                             0);
    
      return;
    end if;
  
    /*Количество в заказах*/
    select nvl(sum(r.quant_plan), 0)
      into nquant_ord
      from buyplanespref r
     where r.prn = rsp.plansp
       and r.company = ncompany;
  
    /*Выполняем проверку количества*/
    if (nquant_ord <> rsp.quantplan_aft) --and utilizer not in ('CITK_MARKOV', 'KHOK') 
      then
      begin
        select nm.nomen_name
          into sTMP
          from buyplandirsp sp,
               dicnomns     nm
         where sp.rn = rsp.rn
           and sp.nomen_aft = nm.rn;
      exception
        when no_data_found then
          p_exception(0, 'Не найдена запись спецификации распоряжения.'||chr(10)||
                         'RN: %s', rsp.rn);
      end;
      p_exception(0,
                  'Количество в строке плана отличается от количества позаказно для номенклатуры.' ||chr(10)||
                  'RN: %s' ||chr(10)||
                  'Мнемокод: %s'||chr(10)||
                  'Наименование: %s'||chr(10)||
                  'Количество в заказах: %s'||chr(10)||
                  'Количество в плане: %s'||chr(10)||
                  'План Закупок: %s ',
                  rsp.plansp, f_dicnomns_get_code(nNOMEN => rsp.nomen_aft), sTMP,
                  nquant_ord, rsp.quantplan_aft, nPLAN);
    end if;
  
    -- Исправление записи в таблице
    update BUYPLANESP s
       set s.QUANT_PLAN = rsp.quantplan_aft, s.QUANT_ACC = rsp.quantacc_aft
     where s.RN = rsp.plansp
       and s.company = ncompany;
  
    /*Выполняем проверку исправления записи*/
    if (SQL%NOTFOUND) then
      PKG_MSG.RECORD_NOT_FOUND(rsp.plansp, 'BuyPlaneSpecs');
    end if;
  end p_buyplandirsp_confirm;

  /*Процедура выполняет базовое утверждение распоряжения об изменении плана закупок*/
  procedure p_buyplandir_bconfirm(ncompany in number /*Организация*/,
                                  nrn      in number /*Регистрационный номер записи*/,
                                  ddate    in date /*Дата изменений*/) is
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Атрибуты записи распоряжения*/
    rdir buyplandir%rowtype;
  
    /*Количество записей в спецификации*/
    ncount number;
  
    /*Основание изменений*/
    sbase pkg_std.tSTRING;
  
    /*Регистрационный номер записи истории изменений*/
    nrn_hist pkg_std.tREF;
    
    V_doc_code doctypes.doccode%type;
  
  begin
    /*Атрибуты записи распоряжения*/
    begin
      select dir.*
        into rdir
        from buyplandir dir
       where dir.rn = nrn
         and dir.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirects');
    end;
  
    /*Если распоряжение отработано, то выдаем сообщение об ошибке*/
    if (rdir.work_date is not null) then
      p_exception(0, 'Распоряжение об изменении Плана закупок уже отработано');
    end if;
  
    /*Атрибуты записи плана*/
    begin
      select bp.*
        into rbp
        from buyplane bp

        
       where bp.rn = rdir.plan
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir.plan,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;
  
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (rbp.state <> 2) /*and utilizer != 'KHOK'*/ then
      
    select dt.doccode
      into V_doc_code
      from doctypes DT
     where DT.rn = rbp.doctype;
    
      P_EXCEPTION(0, 'План закупок %s не утвержден. ( RN = %s)', V_doc_code||' '||trim(rbp.pref)||'-'||trim(rbp.numb), rbp.rn);
    end if;
--if utilizer = 'KHOK' then p_exception(0,nrn); end if;   
    /*Количество записей в спецификации*/
    select count(1)
      into ncount
      from buyplandirsp s
     where s.prn = nrn
       and s.company = ncompany;
  
    /*Если распоряжение не сформировано, то выдаем сообщение об ошибке*/
    if (ncount = 0) then
      --if utilizer != 'KHOK' then --потом надо найти и расформировать созданное пустое распоряжение и сделать его ручками
      p_exception(0, 'Распоряжение об изменении Плана закупок не сформировано.');
      --end if;
    end if;
  
    select count(1)
      into ncount
      from dual
     where exists (select null
              from BUYPLANESP S, BUYPLANESPHS H
             where S.RN = H.PRN
               and S.PRN = rbp.RN
               -- 16/04/2024 марков МВ. Контроль только по позициям для изменения
               and S.NOMMODIF in(select DSP.MODIF_AFT from BUYPLANDIRSP DSP where DSP.PRN = nRN)
               --
               and H.DATE_TO > trunc(ddate, 'mi'));
    --
    if (ncount = 1) then
      P_EXCEPTION(0,
                  'В плане закупок обнаружены изменения с большей датой и временем. Отработка распоряжения невозможна.');
    end if;
  
    /*Удаляем строки распоряжения без заказов*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.prn = nrn
                         and s.company = ncompany
                         and not exists (select 1
                                from buyplandirspref r
                               where r.prn = s.rn)) loop
      p_buyplandirsp_base_delete(nrn      => sp_cursor.nrn,
                                 ncompany => ncompany);
    end loop;
  
    /*Выполняем пересчет количества в строках распоряжения об изменении плана закупок*/
    p_buyplandir_recalc_sp(ncompany => ncompany, nrn => nrn);
  
    /* заголовок распоряжения связывается с заголовком плана закупок */
    P_LINKSALL_LINK_DIRECT(nCOMPANY,
                           'BuyingPlanDirects',
                           rDIR.RN,
                           null,
                           sysdate,
                           0,
                           'BuyPlanes',
                           rDIR.PLAN,
                           null,
                           sysdate,
                           0);
  
    /* в дату отработки записывается параметр "Действует с" */
    update BUYPLANDIR
       set WORK_DATE = trunc(sysdate)
     where RN = rDIR.RN
       and COMPANY = nCOMPANY;
    --
    if (SQL%NOTFOUND) then
      PKG_MSG.RECORD_NOT_FOUND(rDIR.RN, 'BuyingPlanDirects');
    end if;
  
    /*Основание*/
    sbase := PKG_DOCUMENT.MAKE_NUMBER(rDIR.DOC_TYPE,
                                      rDIR.DOC_PREF,
                                      rDIR.DOC_NUMB,
                                      rDIR.DOC_DATE);
  
    /*Цикл по строкам изменений*/
    for sp_cursor in (select s.*
                        from buyplandirsp s
                       where s.prn = nrn
                         and s.company = ncompany
                         and s.kind = 0) loop
      /*Выполняем формирование истории*/
      P_BUYPLANESPHS_MAKE(ncompany  => ncompany,
                          nprn      => sp_cursor.plansp,
                          sunitcode => 'BuyingPlanDirects',
                          ndocument => nrn,
                          ddate_to  => ddate,
                          sbase     => sbase,
                          nrn       => nrn_hist);
    
      /*Устанавливаем связь с историей*/
      P_LINKSALL_LINK_DIRECT(nCOMPANY,
                             'BuyingPlanDirectsSpecs',
                             sp_cursor.RN,
                             sp_cursor.pRN,
                             sysdate,
                             0,
                             'BuyPlaneSpecsHistory',
                             nrn_hist,
                             sp_cursor.plansp,
                             sysdate,
                             0);
    end loop;
  
    /*Цикл по заказам*/
    for ref_cursor in (select r.rn as nrn,
                              r.quantplan_aft,
                              (select s.nomen from departmentords s where s.rn = r.deptordsp) as nomen
                         from buyplandirsp s, buyplandirspref r
                        where s.prn = nrn
                          and s.company = ncompany
                          and r.prn = s.rn) loop
      p_buyplandirspref_confirm(ncompany  => ncompany,
                                nrn       => ref_cursor.nrn,
                                sunitcode => 'BuyingPlanDirects',
                                ndocument => nrn,
                                ddate_to  => ddate,
                                sbase     => sbase);
    end loop;
  
    /*Цикл по строкам распоряжения*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.prn = nrn
                         and s.company = ncompany) loop
      p_buyplandirsp_confirm(ncompany => ncompany,
                             nrn      => sp_cursor.nrn,
                             nplan    => rbp.rn);
    end loop;
  end p_buyplandir_bconfirm;

  /*Процедура выполняет отмену утверждения изменений заказа*/
  procedure p_buyplandirspref_cancel(ncompany in number /*Организация*/,
                                     nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи заказа распоряжения*/
    rref buyplandirspref%rowtype;
  
    /*Регистрационный номер записи строки заказа в плане закупок*/
    nrn_bp_sp_ref pkg_std.tREF;
  
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
  
    /*Атрибуты записи истории изменений*/
    rhist buyplanesprefhs%rowtype;
  
    /*Количество записей*/
    ncount number;
  
    /*Регистрационный номер записи номенклатуры*/
    nnomen pkg_std.tREF;
  
  begin
    /*Атрибуты записи заказа распоряжения*/
    begin
      select r.*
        into rref
        from buyplandirspref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecsReferences');
    end;
  
    /*Выполняем исключение заказа из плана закупок*/
    if (rref.quantplan_bef is null) then
      /*Регистрационный номер записи строки заказа в плане закупок*/
      begin
        select r.rn, r.prn, s.nomen
          into nrn_bp_sp_ref, nrn_bp_sp, nnomen
          from buyplanespref r, departmentords s
         where r.deptordsp = rref.deptordsp
           and s.rn = r.deptordsp;
      exception
        when no_data_found then
          p_exception(0,
                      'Не удалось определить строку заказа в плане закупок');
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить строку заказа в плане закупок');
      end;
    
      select count(1)
        into ncount
        from buyplanesprefhs h
       where h.prn = nrn_bp_sp_ref
         and h.company = ncompany;
    
      if (ncount > 0) then
        p_exception(0,
                    'Для добавленной строки заказа плана закупок с номенклатурой ' ||
                    get_dicnomns_code_id(nFLAG_SMART => 0, nRN => nnomen) ||
                    ' уже были выполнены изменения');
      end if;
    
      /*Разрываем связь*/
      P_LINKSALL_REMOVE(nCOMPANY,
                        'BuyingPlanDirectsSpecsReferences',
                        rref.RN,
                        'BuyPlaneSpecsReferences',
                        nrn_bp_sp_ref);
    
      udo_pkg_umts_01_plan.p_departmentords_bexcl_bp(ncompany  => ncompany,
                                                     nrn       => rref.deptordsp,
                                                     nsign_dir => 1);
    
      return;
    end if;
  
    /*Регистрационный номер записи строки заказа в плане закупок*/
    begin
      select r.rn
        into nrn_bp_sp_ref
        from buyplandirsp s, buyplanespref r
       where s.rn = rref.prn
         and r.prn = s.plansp
         and r.deptordsp = rref.deptordsp;
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить строку заказа в плане закупок');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить строку заказа в плане закупок');
    end;
  
    /* записи «Истории включения/исключения ссылок на заказы» */
    rhist.rn := F_DOCLINKS_LINK_OUT_DOC('BuyingPlanDirectsSpecsReferences',
                                        rref.RN,
                                        'BuyPlaneSpecsReferencesHistory');
  
    /*Выполняем проверку наличия записи истории изменений заказа в плане закупок*/
    if (rhist.rn is null) then
      p_exception(0,
                  'Не удалось определить записи истории изменений заказа в плане закупок');
    end if;
  
    /*Атрибуты записи истории*/
    begin
      select h.*
        into rhist
        from buyplanesprefhs h
       where h.rn = rhist.rn
         and h.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rhist.rn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferencesHistory');
    end;
  
    /*Количество записей в истории*/
    select count(1)
      into ncount
      from buyplanesprefhs h
     where h.prn = rhist.prn
       and h.chng_numb > rhist.chng_numb;
  
    /*Если обнаружены более поздние изменения, то выдаем сообщение об ошибке*/
    if (ncount > 0) then
      p_exception(0,
                  'Обнаружены более поздние изменения');
    end if;
  
    /*Выполняем проверку количества*/
    if (rhist.quant_plan <> rref.quantplan_bef) then
      p_exception(0, 'Неверное количество');
    end if;
  
    /*Разрываем связь с историей*/
    P_LINKSALL_REMOVE(nCOMPANY,
                      'BuyingPlanDirectsSpecsReferences',
                      rref.RN,
                      'BuyPlaneSpecsReferencesHistory',
                      rhist.rn);
  
    /*Выполняем удаление записи истории*/
    p_buyplanesprefhs_base_delete(nrn => rhist.rn, ncompany => ncompany);
  
    /*Выполняем исправление строки заказа в плане закупок*/
    p_buyplanespref_base_update(nrn            => nrn_bp_sp_ref,
                                ncompany       => ncompany,
                                nquant_plan    => rref.quantplan_bef,
                                nquantalt_plan => rref.quantaltplan_bef,
                                nsign_excl     => rref.sign_excl,
                                nhist          => rref.hist,
                                nsign_client   => 0);
  end p_buyplandirspref_cancel;

  /*Процедура выполняет снятия утверждения изменений строки плана*/
  procedure p_buyplandirsp_cancel(ncompany in number /*Организация*/,
                                  nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи строки распоряжения*/
    rsp buyplandirsp%rowtype;
  
    /*Регистрационный номер записи строки плана*/
    nrn_bp_sp pkg_std.tREF;
  
    /*Количество записей в спецификации*/
    ncount number;
  
    /*Атрибуты записи истории изменений*/
    rhist buyplanesphs%rowtype;
    
    sTMP varchar2(4000);
  
  begin
    
    /*Атрибуты записи строки распоряжения*/
    begin
      select sp.*
        into rsp
        from buyplandirsp sp
       where sp.rn = nrn
         and sp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecs');
    end;
  
    if (rsp.kind = 1) then
    
      /*Регистрационный номер записи строки плана*/
      nrn_bp_sp := F_DOCLINKS_LINK_OUT_DOC('BuyingPlanDirectsSpecs',
                                           nrn,
                                           'BuyPlaneSpecs');
    
      if (nrn_bp_sp is null) then
        p_exception(0,
                    'Не удалось определить регистрационный номер записи строки плана закупок');
      end if;
    
      /*Разрываем связи*/
      P_LINKSALL_REMOVE(nCOMPANY,
                        'BuyingPlanDirectsSpecs',
                        nrn,
                        'BuyPlaneSpecs',
                        nrn_bp_sp);
    
      select count(1)
        into ncount
        from buyplanesphs h
       where h.prn = nrn_bp_sp
         and h.company = ncompany;
    
      if (ncount > 0)
        then
        p_exception(0,
                    'Для добавленной строки плана закупок уже были выполнены изменения'||chr(10)||
                    'nrn_bp_sp = %s', nrn_bp_sp);
      end if;
    
      return;
    end if;
  
    /* находится связанная с ней запись «Истории изменения строк плана» */
    rhist.rn := F_DOCLINKS_LINK_OUT_DOC('BuyingPlanDirectsSpecs',
                                        nrn,
                                        'BuyPlaneSpecsHistory');
  
    /*Выполняем проверку наличия записи истории изменений строки плана закупок*/
    if (rhist.rn is null) then
      p_exception(0,
                  'Не удалось определить запись истории изменений строки плана закупок');
    end if;
  
    /*Атрибуты записи истории*/
    begin
      select h.*
        into rhist
        from buyplanesphs h
       where h.rn = rhist.rn
         and h.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rhist.rn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsHistory');
    end;
  
    /*Количество записей в истории с более поздней датой от распоряжений*/
    select count(1)
      into ncount
      from buyplanesphs h
     where h.prn = rhist.prn
       and h.chng_numb > rhist.chng_numb
       and exists(select null from doclinks l where l.in_unitcode = 'BuyingPlanDirectsSpecs'
                         and l.out_unitcode = 'BuyPlaneSpecsHistory' and l.out_document = h.rn);
  
    /*Если обнаружены более поздние изменения, то выдаем сообщение об ошибке*/
    if (ncount > 0) then
      begin
        select nm.nomen_code||', '||nm.nomen_name
          into sTMP
          from buyplanesp sp,
               dicnomns   nm
         where sp.rn = rhist.prn
           and sp.nomen = nm.rn;
      exception
        when no_data_found then
          p_exception(0, 'Не найдена запись спецификации плана закупок.'||chr(10)||
                         'RN: %s', rhist.prn);
      end;
      p_exception(0,
                  'Обнаружены более поздние изменения по Распоряжениям об изменении'||chr(10)||
                  'Строка распоряжения RN: %s'||chr(10)||
                  'Номер изменения: %s'||chr(10)||
                  'Позиция: %s', nrn, rhist.chng_numb, sTMP);
    end if;
  
    /*Количество записей в истории с более поздней датой без распоряжений*/
    -- изменение даты поставки - переносы в другие планы закупок
    select count(1)
      into ncount
      from buyplanesphs h
     where h.prn = rhist.prn
       and h.chng_numb > rhist.chng_numb
       and not exists(select null from doclinks l where l.in_unitcode = 'BuyingPlanDirectsSpecs'
                         and l.out_unitcode = 'BuyPlaneSpecsHistory' and l.out_document = h.rn);
  
    /*Если обнаружены более поздние изменения, то другая обработка*/
    if (ncount > 0) then
      -- есть более поздние изменения, но без распоряжений
    /*Если обнаружены более поздние изменения, то выдаем сообщение об ошибке*/
    if (ncount > 0) then
      begin
        select nm.nomen_code||', '||nm.nomen_name
          into sTMP
          from buyplanesp sp,
               dicnomns   nm
         where sp.rn = rhist.prn
           and sp.nomen = nm.rn;
      exception
        when no_data_found then
          p_exception(0, 'Не найдена запись спецификации плана закупок.'||chr(10)||
                         'RN: %s', rhist.prn);
      end;
      p_exception(0,
                  'Обнаружены более поздние изменения по Распоряжениям об изменении'||chr(10)||
                  'Строка распоряжения RN: %s'||chr(10)||
                  'Номер изменения: %s'||chr(10)||
                  'Позиция: %s', nrn, rhist.chng_numb, sTMP);
    end if;
  
      /*Разрываем связь с историей*/
      P_LINKSALL_REMOVE(nCOMPANY,
                        'BuyingPlanDirectsSpecs',
                        rsp.RN,
                        'BuyPlaneSpecsHistory',
                        rhist.rn);
    
      /*Выполняем удаление записи истории*/
      p_buyplanesphs_base_delete(nrn => rhist.rn, ncompany => ncompany);
      
      /*Выполняем исправление строки плана закупок*/
      update BUYPLANESP s
         set s.QUANT_PLAN = s.QUANT_PLAN - (rsp.quantplan_aft - rsp.quantplan_bef),
             s.QUANT_ACC = s.QUANT_ACC - (rsp.quantacc_aft - rsp.quantacc_bef)
       where s.RN = rsp.plansp
         and s.company = ncompany;
    
      /*Выполняем проверку исправления записи*/
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(rsp.plansp, 'BuyPlaneSpecs');
      end if;
    
    else
      -- нет более поздних изменений
      /*Выполняем проверку количества*/
      if (rhist.quant_plan <> rsp.quantplan_bef) then
        p_exception(0, 'Неверное количество');
      end if;
    
      /*Разрываем связь с историей*/
      P_LINKSALL_REMOVE(nCOMPANY,
                        'BuyingPlanDirectsSpecs',
                        rsp.RN,
                        'BuyPlaneSpecsHistory',
                        rhist.rn);
    
      /*Выполняем удаление записи истории*/
      p_buyplanesphs_base_delete(nrn => rhist.rn, ncompany => ncompany);
    
      /*Выполняем исправление строки плана закупок*/
      update BUYPLANESP s
         set s.QUANT_PLAN = rsp.quantplan_bef, s.QUANT_ACC = rsp.quantacc_bef
       where s.RN = rsp.plansp
         and s.company = ncompany;
    
      /*Выполняем проверку исправления записи*/
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(rsp.plansp, 'BuyPlaneSpecs');
      end if;
    
    end if;
    
  end p_buyplandirsp_cancel;

  /*Процедура выполняет базовое снятие утверждения распоряжения об изменении плана закупок*/
  procedure p_buyplandir_bcancel(ncompany in number /*Организация*/,
                                 nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи плана*/
    rbp buyplane%rowtype;
  
    /*Атрибуты записи распоряжения*/
    rdir buyplandir%rowtype;
  
    /*Количество записей в спецификации*/
    ncount number;
  
  begin
    /*Атрибуты записи распоряжения*/
    begin
      select dir.*
        into rdir
        from buyplandir dir
       where dir.rn = nrn
         and dir.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirects');
    end;
  
    /*Если распоряжение не отработано, то выдаем сообщение об ошибке*/
    if (rdir.work_date is null) then
      p_exception(0, 'Распоряжение не отработано');
    end if;
  
    /*Атрибуты записи плана*/
    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rdir.plan
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdir.plan,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;
  
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (rbp.state <> 2) then
      P_EXCEPTION(0, 'План закупок не утвержден');
    end if;
  
    /*Количество записей в спецификации*/
    select count(1)
      into ncount
      from buyplandir d
     where d.plan = rdir.plan
       and d.company = ncompany
       and d.work_date is null;
  
    /*Если есть неотработанные распоряжения по плану закупок, то выдаем сообщение об ошибке*/
    if (ncount > 0) /*and utilizer != 'KHOK'*/ then
      p_exception(0, 'Обнаружены неотработанные распоряжения по плану закупок');
    end if;
  
    select count(1)
      into ncount
      from dual
     where exists (select null
              from BUYPLANESP S, BUYPLANESPHS H
             where S.RN = H.PRN
               and S.PRN = rbp.RN
               -- 16/04/2024 марков МВ. Контроль только по позициям для изменения
               and S.NOMMODIF in(select DSP.MODIF_AFT from BUYPLANDIRSP DSP where DSP.PRN = nRN)
               --
               and H.DATE_TO > rDIR.WORK_DATE);
    --
    if /*utilizer != 'KHOK' and*/ ncount = 1 then
      P_EXCEPTION(0, 'В плане закупок обнаружены изменения с большей датой и временем. Снятие отработки распоряжения "%s" невозможно.');
    end if;
  
    /* заголовок распоряжения отвязывается от заголовка плана закупок */
    P_LINKSALL_REMOVE(nCOMPANY,
                      'BuyingPlanDirects',
                      rDIR.RN,
                      'BuyPlanes',
                      rDIR.PLAN);
  
    /* дата отработки очищается */
    update BUYPLANDIR
       set WORK_DATE = null
     where RN = rDIR.RN
       and COMPANY = nCOMPANY;
    --
    if (SQL%NOTFOUND) then
      PKG_MSG.RECORD_NOT_FOUND(rDIR.RN, 'BuyingPlanDirects');
    end if;
  
    /*Цикл по новым строкам*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.prn = nrn
                         and s.company = ncompany
                         and s.kind = 1) loop
      p_buyplandirsp_cancel(ncompany => ncompany, nrn => sp_cursor.nrn);
    end loop;
  
    /*Цикл по заказам*/
    for ref_cursor in (select r.rn as nrn
                         from buyplandirsp s, buyplandirspref r
                        where s.prn = nrn
                          and s.company = ncompany
                          and r.prn = s.rn) loop
      p_buyplandirspref_cancel(ncompany => ncompany, nrn => ref_cursor.nrn);
    end loop;
  
    /*Цикл по изменениям*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.prn = nrn
                         and s.company = ncompany
                         and s.kind <> 1) loop
      p_buyplandirsp_cancel(ncompany => ncompany, nrn => sp_cursor.nrn);
    end loop;
  end p_buyplandir_bcancel;

  /*Процедура выполняет формирование распоряжения об изменении плана закупок*/
  procedure p_buyplandir_crt(ncompany       in number               /*Организация*/,
                             nrn            in number               /*Регистрационный номер записи*/
                            ,ndepartmentord in number default null  /* Заказ подразделения. RN (25/06/2024 Степанов М.) */ ) is
  
    /*Каталог*/
    ncatalog pkg_std.tREF;
  
    /*Юридическое лицо*/
    njur_pers pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования распоряжения*/
    p_buyplandir_exists(nrn       => nrn,
                        ncompany  => ncompany,
                        ncrn      => ncatalog,
                        njur_pers => njur_pers);
  
    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsCrt',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  
    /*Выполняем базовое формирование распоряжения об изменении плана*/
    p_buyplandir_bcrt(ncompany       => ncompany
                     ,nrn            => nrn
                     ,ndepartmentord => ndepartmentord /* Заказ подразделения. RN (25/06/2024 Степанов М.) */ );
  
    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsCrt',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  end p_buyplandir_crt;

  /*Процедура выполняет расформирование распоряжения об изменении плана закупок*/
  procedure p_buyplandir_rmv(ncompany in number /*Организация*/,
                             nrn      in number /*Регистрационный номер записи*/) is
  
    /*Каталог*/
    ncatalog pkg_std.tREF;
  
    /*Юридическое лицо*/
    njur_pers pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования распоряжения*/
    p_buyplandir_exists(nrn       => nrn,
                        ncompany  => ncompany,
                        ncrn      => ncatalog,
                        njur_pers => njur_pers);
  
    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsRmv',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  
    /*Выполняем базовое расформирование распоряжения об изменении плана*/
    p_buyplandir_brmv(ncompany => ncompany, nrn => nrn);
  
    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsRmv',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  end p_buyplandir_rmv;

  /*Процедура выполняет изменение плановой даты поставки*/
  procedure p_buyplandirspref_set_pl_date(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          dplan_date in date /*Плановая дата поставки*/) is
    /*Каталог*/
    ncatalog pkg_std.tREF;
  
    /*Юридическое лицо*/
    njur_pers pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования распоряжения*/
    p_buyplandirspref_exists(nrn       => nrn,
                             ncompany  => ncompany,
                             ncrn      => ncatalog,
                             njur_pers => njur_pers);
  
    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirectsSpecsReferences',
                     saction    => 'BuyingPlanDirectsSpecsReferencesSetPDate',
                     stable     => 'BUYPLANDIRSPREF',
                     ndocument  => nrn);
  
    /*Процедура выполняет базовое изменение плановой даты поставки*/
    p_buyplandirspref_bset_pl_date(ncompany   => ncompany,
                                   nrn        => nrn,
                                   dplan_date => dplan_date);
  
    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirectsSpecsReferences',
                     saction    => 'BuyingPlanDirectsSpecsReferencesSetPDate',
                     stable     => 'BUYPLANDIRSPREF',
                     ndocument  => nrn);
  end p_buyplandirspref_set_pl_date;

  /*Процедура выполняет утверждение распоряжения об изменении плана закупок*/
  procedure p_buyplandir_confirm(ncompany in number /*Организация*/,
                                 nrn      in number /*Регистрационный номер записи*/) is
  
    /*Каталог*/
    ncatalog pkg_std.tREF;
  
    /*Юридическое лицо*/
    njur_pers pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования распоряжения*/
    p_buyplandir_exists(nrn       => nrn,
                        ncompany  => ncompany,
                        ncrn      => ncatalog,
                        njur_pers => njur_pers);
  
    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsConfirm',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  
    /*Выполняем базовое утверждение распоряжения об изменении плана*/
    p_buyplandir_bconfirm(ncompany => ncompany,
                          nrn      => nrn,
                          ddate    => trunc(sysdate));
  
    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsConfirm',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  end p_buyplandir_confirm;

  /*Процедура выполняет снятие утверждения распоряжения об изменении плана закупок*/
  procedure p_buyplandir_cancel(ncompany in number /*Организация*/,
                                nrn      in number /*Регистрационный номер записи*/) is
  
    /*Каталог*/
    ncatalog pkg_std.tREF;
  
    /*Юридическое лицо*/
    njur_pers pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования распоряжения*/
    p_buyplandir_exists(nrn       => nrn,
                        ncompany  => ncompany,
                        ncrn      => ncatalog,
                        njur_pers => njur_pers);
  
    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsCancel',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  
    /*Выполняем базовое снятие утверждения распоряжения об изменении плана*/
    p_buyplandir_bcancel(ncompany => ncompany, nrn => nrn);
  
    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany   => ncompany,
                     nversion   => to_number(null),
                     ncatalog   => ncatalog,
                     njur_pers  => njur_pers,
                     nhierarchy => to_number(null),
                     sunit      => 'BuyingPlanDirects',
                     saction    => 'BuyingPlanDirectsCancel',
                     stable     => 'BUYPLANDIR',
                     ndocument  => nrn);
  end p_buyplandir_cancel;

  /*Процедура выполняет расчет истории изменений записи строки заказа подразделений в плане закупок*/
  procedure P_BUYPLANESPREF_calc_hist(NCOMPANY in number /*Регистрационный номер организации*/,
                                      NRN      in number /*Регистрационный номер записи*/,
                                      shist    out varchar2 /*История изменений*/) is
  begin
    for hist_cursor in (select *
                          from buyplanesprefhs h
                         where h.prn = nrn
                           and h.company = ncompany
                         order by h.chng_numb desc) loop
      if (shist is not null) then
        shist := shist || chr(13) || chr(10);
      end if;
    
      shist := shist || trim(hist_cursor.chng_numb);
      shist := shist || ' Дата изменения: ' ||
               to_char(hist_cursor.chng_date, 'dd.mm.yyyy');
      shist := shist || ' Действует до: ' ||
               to_char(hist_cursor.date_to, 'dd.mm.yyyy');
      shist := shist || ' Количество: ' || to_char(hist_cursor.quant_plan);
      shist := shist || ' Плановая дата поставки: ' ||
               to_char(prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                      nVERSION  => to_number(null),
                                      sUNITCODE => 'BuyPlaneSpecsReferencesHistory',
                                      nDOCUMENT => hist_cursor.rn,
                                      sPROPCODE => 'УМТС_ПланДатаПост'),
                       'dd.mm.yyyy');
    end loop;
  end P_BUYPLANESPREF_calc_hist;

  /*Процедура выполняет установку признака дублирования для указанной строки заказа в распоряжении*/
  procedure p_buyplandirspref_set_sign_dup(ncompany in number /*Организация*/,
                                           nrn      in number /*Регистрационный номер записи*/) is
  
    /*Регистрационный номер записи строки заказа подразделений*/
    nrn_dep_ord_sp pkg_std.tREF;
  
  begin
    /*Регистрационный номер записи строки заказа подразделений*/
    begin
      select r.deptordsp
        into nrn_dep_ord_sp
        from buyplandirspref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyingPlanDirectsSpecsReferences');
    end;
  
    /*Если признак изменения не равен Добавить, то выдаем сообщение об ошибке*/
    if (cmp_num(udo_f_buyplandirspref_kind(nrn => nrn), 1) = 0) then
      p_exception(0,
                  'Признак изменения не равен Добавить');
    end if;
  
    /*Выполняем установку признака дублирования*/
    prsg_prop.VSET(sUNITCODE  => 'DepartmentsOrdersSpecs',
                   nDOCUMENT  => nrn_dep_ord_sp,
                   sPROPCODE  => 'УМТС_Дубль',
                   sSTRVALUE  => 'Да',
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => to_date(null));
  
    /*Выполняем базовое удаление записи*/
    p_buyplandirspref_base_delete(nrn => nrn, ncompany => ncompany);
  end p_buyplandirspref_set_sign_dup;

  /* временная процедура снятия отработки только для отмеченных строк */
  procedure p_sys24071_replan_cancel(nIDENT in number, nCOMPANY in number) is
  begin
    if utilizer not in ('CITK_MARKOV') then
      p_exception(0, 'У Вас нет прав на выполнение процедуры!!!');
    end if;
    /*Цикл по новым строкам*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.rn in (select sl.document from selectlist sl where sl.ident = nIDENT)
                         and s.company = ncompany
                         and s.kind = 1) loop
      p_buyplandirsp_cancel(ncompany => ncompany, nrn => sp_cursor.nrn);

    end loop;

    /*Цикл по заказам*/
    for ref_cursor in (select r.rn as nrn
                         from buyplandirsp s, buyplandirspref r
                        where s.rn in (select sl.document from selectlist sl where sl.ident = nIDENT)
                          and s.company = ncompany
                          and r.prn = s.rn) loop
      p_buyplandirspref_cancel(ncompany => ncompany, nrn => ref_cursor.nrn);
    end loop;

    /*Цикл по изменениям*/
    for sp_cursor in (select s.rn as nrn
                        from buyplandirsp s
                       where s.rn in (select sl.document from selectlist sl where sl.ident = nIDENT)
                         and s.company = ncompany
                         and s.kind <> 1) loop
      p_buyplandirsp_cancel(ncompany => ncompany, nrn => sp_cursor.nrn);
    end loop;
    -- удалить строки
    pkg_flag.SET_FLAG;
    delete from buyplandirsp dsp where dsp.rn in(select sl.document from selectlist sl where sl.ident = nIDENT);
    pkg_flag.RESET_FLAG;
    
  end p_sys24071_replan_cancel;
  
begin
  -- Initialization
  null;
end udo_pkg_umts_05_replan;
/
