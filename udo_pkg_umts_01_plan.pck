create or replace package udo_pkg_umts_01_plan is

  --create public synonym udo_pkg_umts_01_plan for udo_pkg_umts_01_plan;

  --grant execute on udo_pkg_umts_01_plan to public;

  -- Author  : I.ANNENKO
  -- Created : 03.09.2022 8:01:37
  -- Purpose : УМТС. 01. Планирование

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  /*Функция возвращает плановую дату поставки для указанной строки заказа подразделений*/
  function f_departmentords_clc_plan_date(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return date;

  /*Процедура выполняет поиск типа плана закупок*/
  procedure p_dicnomns_calc_bp_type(nFLAG_SMART in number /*Признак генерации исключения*/,
                                    ncompany    in number /*Организация*/,
                                    nrn         in number /*Регистрационный номер записи*/,
                                    nbp_type    out number /*Тип плана закупок*/);

  /*Процедура определяет период планирования*/
  procedure p_calc_plan_period(dplan_date    in date /*Плановая дата поставки*/,
                               speriod       in varchar2 /*Размер периода*/,
                               dperiod_begin out date /*Дата начала периода*/,
                               dperiod_end   out date /*Дата окончания периода*/);

  /*Процедура выполняет базовое включение указанной строки заказа подразделений в план закупок*/
  procedure p_departmentords_bincl_bp(ncompany   in number /*Организация*/,
                                      nrn        in number /*Регистрационный номер записи*/,
                                      dplan_date in date /*Плановая дата поставки*/,
                                      nquant     in number /*Количество*/,
                                      nsign_dir  in number /*Признак включения через распоряжение*/,
                                      nplan_dir  in number default null /*рег.номер распоряжения*/);

  /*Процедура выполняет базовое исключение указанной строки заказа подразделений из плана закупок*/
  procedure p_departmentords_bexcl_bp(ncompany  in number /*Организация*/,
                                      nrn       in number /*Регистрационный номер записи*/,
                                      nsign_dir in number /*Признак исключения через распоряжение*/);

  /*Процедура выполняет включение указанной строки заказа подразделений в план закупок*/
  procedure p_departmentords_incl_bp(ncompany   in number /*Организация*/,
                                     nrn        in number /*Регистрационный номер записи*/,
                                     dplan_date in date /*Плановая дата поставки*/,
                                     nquant     in number /*Количество*/);

  /*Процедура выполняет исключение указанной строки заказа подразделений из плана закупок*/
  procedure p_departmentords_excl_bp(ncompany in number /*Организация*/,
                                     nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет включение указанной строки заказа подразделений в план закупок*/
  procedure p_departmentords_incl_bp_list(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          dplan_date in date /*Плановая дата поставки*/);

  /*Процедура выполняет исключение указанной строки заказа подразделений из плана закупок*/
  procedure p_buyplanespref_excl_bp(ncompany in number /*Организация*/,
                                    nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет включение указанного заказа подразделений в план закупок*/
  procedure p_departmentord_incl_bp(ncompany   in number /*Организация*/,
                                    nrn        in number /*Регистрационный номер записи*/,
                                    dplan_date in date /*Плановая дата поставки*/);

  /*Процедура выполняет исключение указанного заказа подразделений из плана закупок*/
  procedure p_departmentord_excl_bp(ncompany in number /*Организация*/,
                                    nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет формирование интерфейса очистки потребностей от остатков*/
  procedure p_rest_clr_recrt(ncompany  in number /*Организация*/,
                             sgrp      in varchar2 /*Группа номенклатуры*/,
                             nsign_imp in number /*Признак импорта*/);

  /*Процедура выполняет выбор партии*/
  procedure p_rest_clr_party_select(nrn in number /*Регистрационный номер записи*/);

  /*Функция возвращает доступное для резервирования количество для указанной строки заказа подразделения*/
  function f_rest_clr_dep_ord_clc_res_qnt(nrn in number /*Регистрационный номер записи*/)
    return number;

  /*Процедура выполняет резервирование*/
  procedure p_rest_clr_dep_ord_res_crt(nrn    in number /*Регистрационный номер записи*/,
                                       nquant in number /*Количество*/);

  /*Процедура выполняет резервирование по списку*/
  procedure p_rest_clr_dep_ord_res_crtl(nrn in number /*Регистрационный номер записи*/);

  /*Процедура выполняет снятие резервирования*/
  procedure p_rest_clr_res_delete(nrn in number /*Регистрационный номер записи*/);

  /*Процедура выполняет включение в план закупок*/
  procedure p_rest_clr_dep_ord_incl_bp(ncompany   in number /*Организация*/,
                                       nrn        in number /*Регистрационный номер записи*/,
                                       dplan_date in date /*Плановая дата поставки*/,
                                       nquant     in number /*Количество*/);

  /*Процедура выполняет включение в план закупок*/
  procedure p_rest_clr_dep_ord_incl_bp_lst(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           dplan_date in date /*Плановая дата поставки*/);

  /*Процедура выполняет корректировку типа плана закупок*/
  procedure P_BUYPLANESPREF_correct_bptype(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           DHIST_DATE in date /*Дата записи истории изменений*/,
                                           SBASE      in varchar2 /*Основание*/);

end udo_pkg_umts_01_plan;
/
create or replace package body udo_pkg_umts_01_plan is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  /*Регистрационный номер записи выбранной партии*/
  nrn_pkg_party pkg_std.tref;

  -- Function and procedure implementations
  /*Функция возвращает плановую дату поставки для указанной строки заказа подразделений*/
  function f_departmentords_clc_plan_date(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return date is
  begin
    return(f_departmentordps_get_dparam(nflag_smart => 1,
                                        nprn        => nrn,
                                        nflag_mode  => 0,
                                        sparname    => 'PERF_DATE'));
  end f_departmentords_clc_plan_date;

  /*Процедура выполняет поиск типа плана закупок*/
  procedure p_dicnomns_calc_bp_type(nFLAG_SMART in number /*Признак генерации исключения*/,
                                    ncompany    in number /*Организация*/,
                                    nrn         in number /*Регистрационный номер записи*/,
                                    nbp_type    out number /*Тип плана закупок*/) is

    /*Группа номенклатуры*/
    sgrp pkg_std.tSTRING;
    sNomCode dicnomns.nomen_code%type;
<<<<<<< HEAD
  
=======

>>>>>>> c6e73845 (РљС‚Рѕ-С‚Рѕ РІРЅС‘СЃ)
  begin
    /* 17/09/2024 Марков МВ. строго по группе номенклатуры!!!
    if (lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'Nomenclator',
                                  nDOCUMENT => nrn,
                                  sPROPCODE => 'УМТС_Импорт'))) = 'да') then
      find_doctypes_code(nCOMPANY  => ncompany,
                         sDOCCODE  => 'ПЗ_Импорт',
                         sUNITCODE => to_char(null),
                         nSTYPE    => 0,
                         nRN       => nbp_type);

      return;
    end if;*/

    /*Группа номенклатуры*/
    sgrp := prsg_prop.SGET(nCOMPANY  => ncompany,
                           nVERSION  => to_number(null),
                           sUNITCODE => 'Nomenclator',
                           nDOCUMENT => nrn,
                           sPROPCODE => 'УМТС_ГруппаНомен');

    if (sgrp is null) then
      if (nFLAG_SMART = 0) then
<<<<<<< HEAD
        
      begin
        select D.Nomen_Code
          into sNomCode 
          from dicnomns D
         where D.RN = nrn;
      
      
      end;
      
=======

      begin
        select D.Nomen_Code
          into sNomCode
          from dicnomns D
         where D.RN = nrn;


      end;

>>>>>>> c6e73845 (РљС‚Рѕ-С‚Рѕ РІРЅС‘СЃ)
        p_exception(0,
                    'Для номенклатуры %s не указана группа. Обратитесь к администратору', sNomCode );
      else
        return;
      end if;
    end if;

    begin
      select v.unit_rn
        into nbp_type
        from docs_props_vals v, docs_props p
       where v.str_value = sgrp
         and v.unitcode = 'DOCTYPES'
         and p.rn = v.docs_prop_rn
         and p.code = 'УМТС_ГруппаНомен';
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить тип плана закупок для группы номенклатуры ' || sgrp ||
                    '. Обратитесь к администратору');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить тип плана закупок для группы номенклатуры ' || sgrp ||
                    '. Обратитесь к администратору');
    end;
  end p_dicnomns_calc_bp_type;

  /*Процедура определяет период планирования*/
  procedure p_calc_plan_period(dplan_date    in date /*Плановая дата поставки*/,
                               speriod       in varchar2 /*Размер периода*/,
                               dperiod_begin out date /*Дата начала периода*/,
                               dperiod_end   out date /*Дата окончания периода*/) is
    nperiod_size number;
  begin
    if (speriod = 'Год') then
      dperiod_begin := trunc(dplan_date, 'year');
      nperiod_size  := 12;
    elsif (speriod = 'Квартал') then
      dperiod_begin := trunc(dplan_date, 'q');
      nperiod_size  := 3;
    elsif (speriod = 'Месяц') then
      dperiod_begin := trunc(dplan_date, 'month');
      nperiod_size  := 1;
    else
      p_exception(0,
                  'Не удалось определить размер периода ' || speriod);
    end if;

    dperiod_end := add_months(dperiod_begin, nperiod_size) - 1;
  end p_calc_plan_period;

  /*Процедура выполняет базовое включение указанной строки заказа подразделений в план закупок*/
  procedure p_departmentords_bincl_bp(ncompany   in number /*Организация*/,
                                      nrn        in number /*Регистрационный номер записи*/,
                                      dplan_date in date /*Плановая дата поставки*/,
                                      nquant     in number /*Количество*/,
                                      nsign_dir  in number /*Признак включения через распоряжение*/,
                                      nplan_dir  in number default null /*рег.номер распоряжения*/
                                      ) is

    /*Атрибуты записи строки заказа подразделений*/
    rdep_ord_sp departmentords%rowtype;

    /*Атрибуты записи заказа подразделений*/
    rdep_ord departmentord%rowtype;

    /*Атрибуты записи заголовка плана закупок*/
    rbp buyplane%rowtype;

    /*Атрибуты записи строки плана закупок*/
    rbp_sp buyplanesp%rowtype;

    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;

    /*Признак планирования по ИГК*/
    ssign_igk pkg_std.tSTRING;

    /*Периодичность*/
    ssign_period pkg_std.tSTRING;

    /*Дискретность*/
    ssign_disrc pkg_std.tSTRING;

    /*Дата начала периода поставки*/
    dshipment_plan_begin date;

    nTMP number(17, 3);
    sTMP varchar2(2000);

  begin
    /*Атрибуты записи строки заказа подразделений*/
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

    /*Выполняем проверку состояния*/
    if (rdep_ord.ord_state <> 1) and utilizer not in('CITK_MARKOV', 'KHOK' )
      then
      p_exception(0,
                  'Действие запрещено для заказа подразделения в состоянии, отличном от Утвержден' ||
                  chr(10) || 'Заказ подразделения: %s',
                  trim(rdep_ord.ord_pref) || '-' || trim(rdep_ord.ord_numb));
    end if;

    /*Если для строки заказа подразделения указан признак не закупать, то выдаем сообщение об ошибке*/
    if (lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DepartmentsOrdersSpecs',
                                  nDOCUMENT => nrn,
                                  sPROPCODE => 'УМТС_НеЗакупать'))) = 'да') then
      p_exception(0, 'Для строки заказа подразделений указан признак Не закупать');
    end if;

    /*Выполняем проверку включения в план закупок*/
    if (f_doclinks_link_out_doc(sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                                nIN_DOCUMENT  => nrn,
                                sOUT_UNITCODE => 'BuyPlanes') is not null) then
      begin
        select NOMEN_CODE
          into sTMP
          from DICNOMNS
         where RN = rdep_ord_sp.nomen;
      exception
        when no_data_found then
          sTMP := '';
      end;
      p_exception(0,
                  'Спецификация заказа подразделения уже включена в план закупок'||chr(10)||
                  'DEPARTMENTORDS.RN: %s'||chr(10)||
                  'Номенклатура: %s',
                  nrn, sTMP);
    end if;

    /*Выполняем проверку количества*/
    if (nquant <> udo_f_departmentords_to_bp(nrn => nrn)) then -- and nrn != 83624200 then -- Марковthen
      nTMP := udo_f_departmentords_to_bp(nrn => nrn);
      sTMP := get_dicnomns_code_id(nFLAG_SMART => 1,
                                   nRN         => rdep_ord_sp.nomen);
      p_exception(0,
                  'Количество указано неверно.' || chr(10) ||
                  'Количество по распоряжению = %s' || chr(10) ||
                  'Количество "К включению" = %s' || chr(10) ||
                  'Заказ подразделения: %s' || chr(10) ||
                  'Номенклатура: %s',
                  nquant,
                  nTMP,
                  trim(rdep_ord.ord_pref) || '-' || trim(rdep_ord.ord_numb),
                  sTMP);
    end if;

    /*Выполняем проверку количества*/
    if (nquant <= 0) then
      p_exception(0,
                  'Количество к закупке должно быть положительным');
    end if;

    /*Выполняем поиск типа плана закупок*/
    p_dicnomns_calc_bp_type(nFLAG_SMART => 0,
                            ncompany    => ncompany,
                            nrn         => rdep_ord_sp.nomen,
                            nbp_type    => rbp.doctype);

    /*Признак планирования по ИГК*/
    ssign_igk := prsg_prop.SGET(nCOMPANY  => ncompany,
                                nVERSION  => to_number(null),
                                sUNITCODE => 'DOCTYPES',
                                nDOCUMENT => rbp.doctype,
                                sPROPCODE => 'УМТС_ПланироватьИГК');

    /*Периодичность*/
    ssign_period := prsg_prop.SGET(nCOMPANY  => ncompany,
                                   nVERSION  => to_number(null),
                                   sUNITCODE => 'DOCTYPES',
                                   nDOCUMENT => rbp.doctype,
                                   sPROPCODE => 'УМТС_Периодичность');

    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => rbp.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');

    /*Период*/
    p_calc_plan_period(dplan_date    => dplan_date,
                       speriod       => ssign_period,
                       dperiod_begin => rbp.begin_period,
                       dperiod_end   => rbp.end_period);

    /*Выполняем поиск плана закупок*/
    if nsign_dir = 1 then
      -- 28/10/2023 Марков МВ. план закупок из распоряжения!!!!
      begin
        select dir.plan
          into rbp.rn
          from buyplandir dir
         where dir.rn = nplan_dir;
      exception
        when no_data_found then
          p_exception(0, 'Не удалось найти распоряжение.'||chr(10)||
                         'RN: %s', nplan_dir);
      end;
    else
      -- ищем план закупок
    begin
      select bp.rn
        into rbp.rn
        from buyplane bp, govcntrid igk
       where bp.doctype = rbp.doctype
         and bp.company = ncompany
         and bp.begin_period = rbp.begin_period
         and igk.rn(+) = bp.govcntrid
         and (cmp_vc2(lower(trim(ssign_igk)), 'да') = 1 and
             igk.code =
             udo_f_departmentord_igk(nfaceacc => rdep_ord.faceacc) or
             cmp_vc2(lower(trim(ssign_igk)), 'да') = 0 and
             bp.govcntrid is null);
    exception
      when no_data_found then
        rbp.rn := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить план закупок');
    end;
    end if;

    if (nsign_dir = 1 and rbp.rn is null) then
      p_exception(0,
                  'Не удалось определить план закупок');
    end if;

    if (rbp.rn is not null) then
      /*Атрибуты записи плана закупок*/
      begin
        select bp.*
          into rbp
          from buyplane bp
         where bp.rn = rbp.rn
           and bp.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rbp.rn,
                                   sUNIT_TABLE => 'BuyPlanes');
      end;

      /*Выполняем проверку состояния*/
      if (rbp.state <> 0) then
        if (nsign_dir = 0) then
          p_exception(0,
                      'План закупок находится в состоянии, отличном от "Новый"');
        end if;
      end if;

    else
      /*Организация*/
      rbp.company := ncompany;

      /*Каталог*/
      find_acatalog_name(nFLAG_SMART => 0,
                         nCOMPANY    => ncompany,
                         nVERSION    => to_number(null),
                         sUNITCODE   => 'BuyPlanes',
                         sNAME       => (case
                                          when (lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                                                          nVERSION  => to_number(null),
                                                                          sUNITCODE => 'Nomenclator',
                                                                          nDOCUMENT => rdep_ord_sp.nomen,
                                                                          sPROPCODE => 'УМТС_Импорт'))) = 'да') then
                                           ('Импорт')
                                          else
                                           (prsg_prop.SGET(nCOMPANY  => ncompany,
                                                           nVERSION  => to_number(null),
                                                           sUNITCODE => 'Nomenclator',
                                                           nDOCUMENT => rdep_ord_sp.nomen,
                                                           sPROPCODE => 'УМТС_ГруппаНомен'))
                                        end),
                         nRN         => rbp.crn);

      /*Юридическое лио*/
      rbp.jur_pers := rdep_ord.jur_pers;

      /*Префикс*/
      rbp.pref := to_char(rbp.begin_period, 'yyyy');

      /*Номер*/
      p_buyplane_getnextnumb(nCOMPANY => ncompany,
                             sDOCTYPE => get_doctypes_code_id(nFLAG_SMART => 0,
                                                              nRN         => rbp.doctype),
                             sPREF    => rbp.pref,
                             sNUMB    => rbp.numb);

      /*Дата*/
      rbp.docdate := trunc(sysdate);

      /*Валюта*/
      rbp.currency := f_curbase_get_rn(nFLAG_SMART => 0,
                                       nCOMPANY    => ncompany);

      /*ИГК*/
      if (cmp_vc2(lower(trim(ssign_igk)), 'да') = 1) then
        find_govcntrid_code(nFLAG_SMART  => 0,
                            nFLAG_OPTION => 1,
                            nCOMPANY     => ncompany,
                            sCODE        => udo_f_departmentord_igk(nfaceacc => rdep_ord.faceacc),
                            nRN          => rbp.govcntrid);
      end if;

      /*Выполняем добавление заголовка плана закупок*/
      p_buyplane_base_insert(ncompany      => rbp.company,
                             ncrn          => rbp.crn,
                             njur_pers     => rbp.jur_pers,
                             nenperiod     => rbp.enperiod,
                             dbegin_period => rbp.begin_period,
                             dend_period   => rbp.end_period,
                             nsubdiv       => rbp.subdiv,
                             nstore        => rbp.store,
                             ndoctype      => rbp.doctype,
                             spref         => rbp.pref,
                             snumb         => rbp.numb,
                             ddocdate      => rbp.docdate,
                             ncurrency     => rbp.currency,
                             snote         => rbp.note,
                             ngovcntrid    => rbp.govcntrid,
                             nrn           => rbp.rn);
    end if;

    /*Плановая дата поставки*/
    p_calc_plan_period(dplan_date    => dplan_date,
                       speriod       => ssign_disrc,
                       dperiod_begin => dshipment_plan_begin,
                       dperiod_end   => rbp_sp.shipment_plan);

    /*Выполняем поиск строки плана закупок*/
    begin
      select s.rn
        into rbp_sp.rn
        from buyplanesp s
       where s.prn = rbp.rn
         and s.nomen = rdep_ord_sp.nomen
         and s.nommodif = rdep_ord_sp.nom_modif /*Анненко И.С. 01.11.2022*/
         and s.shipment_plan = rbp_sp.shipment_plan;
    exception
      when no_data_found then
        rbp_sp.rn := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить строку плана закупок');
    end;

    if (rbp_sp.rn is not null) then
      /*Выполняем исправление количества*/
      update buyplanesp s
         set s.quant_plan = s.quant_plan + nquant,
             s.quant_acc  = s.quant_acc + nquant
       where s.rn = rbp_sp.rn
         and s.company = ncompany;

      /*Выполняем проверку исправления количества*/
      if (sql%notfound) then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rbp_sp.rn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');

      end if;
    else
      /*Организация*/
      rbp_sp.company := ncompany;

      /*Регистрационный номер родителя*/
      rbp_sp.prn := rbp.rn;

      /*Номенклатура*/
      rbp_sp.nomen := rdep_ord_sp.nomen;

      /*Модификация*/
      rbp_sp.nommodif := rdep_ord_sp.nom_modif;

      /*Основная ЕИ*/
      begin
        select n.umeas_main
          into rbp_sp.umeas_main
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
                        nRN          => rbp_sp.agent);

      /*Согласованная дата поставки*/
      rbp_sp.shipment_acc := rbp_sp.shipment_plan;

      /*Количество*/
      rbp_sp.quant_plan := nquant;
      rbp_sp.quant_acc  := nquant;

      /*Количество ДЕИ*/
      rbp_sp.quantalt_plan := 0;
      rbp_sp.quantalt_acc  := 0;

      /*Цена*/
      rbp_sp.price_plan := 0;
      rbp_sp.price_acc  := 0;

      /*ЕИ цены*/
      rbp_sp.pr_meas := 0;

      /*Сумма*/
      rbp_sp.summ_plan := 0;
      rbp_sp.summ_acc  := 0;

      /*Дата включения*/
      rbp_sp.incl_date := trunc(sysdate);

      /*Выполняем добавление строки плана закупок*/
      p_buyplanesp_base_insert(ncompany       => rbp_sp.company,
                               nprn           => rbp_sp.prn,
                               nnomencls      => rbp_sp.nomencls,
                               nnomen         => rbp_sp.nomen,
                               nnomnpack      => rbp_sp.nomnpack,
                               nnommodif      => rbp_sp.nommodif,
                               nnomnmodifpack => rbp_sp.nomnmodifpack,
                               numeas_main    => rbp_sp.umeas_main,
                               nstore         => rbp_sp.store,
                               nagent         => rbp_sp.agent,
                               nsign_one_row  => rbp_sp.sign_one_row,
                               dshipment_plan => rbp_sp.shipment_plan,
                               dshipment_acc  => rbp_sp.shipment_acc,
                               ncost_place    => rbp_sp.cost_place,
                               nquant_plan    => rbp_sp.quant_plan,
                               nquantalt_plan => rbp_sp.quantalt_plan,
                               nquant_acc     => rbp_sp.quant_acc,
                               nquantalt_acc  => rbp_sp.quantalt_acc,
                               nprice_plan    => rbp_sp.price_plan,
                               nprice_acc     => rbp_sp.price_acc,
                               npr_meas       => rbp_sp.pr_meas,
                               nsumm_plan     => rbp_sp.summ_plan,
                               nsumm_acc      => rbp_sp.summ_acc,
                               snote          => rbp_sp.note,
                               dincl_date     => rbp_sp.incl_date,
                               nbudgexpend_sp => rbp_sp.budgexpend_sp,
                               nrn            => rbp_sp.rn);
    end if;

    /*Организация*/
    rref.company := ncompany;

    /*Регистрационный номер родителя*/
    rref.prn := rbp_sp.rn;

    /*Регистрационный номер строки заказа*/
    rref.deptordsp := nrn;

    /*Количество*/
    rref.quant_plan := nquant;

    /*Количество ДЕИ*/
    rref.quantalt_plan := 0;

    /*Признак исключения*/
    rref.sign_excl := 0;

    /*Регистрационный номер записи истории*/
    select max(h.rn)
      into rref.hist
      from depordsphs h
     where h.prn = rdep_ord_sp.rn
       and h.company = ncompany;

    /*Выполняем добавление ссылки на заказ*/
    p_buyplanespref_base_insert(ncompany       => rref.company,
                                nprn           => rref.prn,
                                ndeptordsp     => rref.deptordsp,
                                nconsordsp     => rref.consordsp,
                                nquant_plan    => rref.quant_plan,
                                nquantalt_plan => rref.quantalt_plan,
                                nsign_excl     => rref.sign_excl,
                                nhist          => rref.hist,
                                nrn            => rref.rn,
                                nsign_ord      => 0,
                                nsign_client   => 0);

    /*Плановая дата поставки*/
    prsg_prop.VSET(sUNITCODE  => 'BuyPlaneSpecsReferences',
                   nDOCUMENT  => rref.rn,
                   sPROPCODE  => 'УМТС_ПланДатаПост',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => dplan_date);

    /*Устанавливаем связь строки заказа с заголовком плана*/
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => ncompany,
                      sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                      nIN_DOCUMENT  => rdep_ord_sp.rn,
                      sOUT_UNITCODE => 'BuyPlanes',
                      nOUT_DOCUMENT => rbp.rn);

    /*Устанавливаем связь строки заказа со строкой плана*/
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => ncompany,
                      sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                      nIN_DOCUMENT  => rdep_ord_sp.rn,
                      sOUT_UNITCODE => 'BuyPlaneSpecs',
                      nOUT_DOCUMENT => rbp_sp.rn);

    /*Устанавливаем связь заголовка заказа с заголовком плана*/
    if (pkg_doclinks.FIND(nFLAG_SMART       => 1,
                          sIN_UNITCODE      => 'DepartmentsOrders',
                          nIN_DOCUMENT      => rdep_ord.rn,
                          nIN_PRN_DOCUMENT  => to_number(null),
                          sOUT_UNITCODE     => 'BuyPlanes',
                          nOUT_DOCUMENT     => rbp.rn,
                          nOUT_PRN_DOCUMENT => to_number(null)) = 0) then
      pkg_doclinks.LINK(nFLAG_SMART   => 0,
                        nCOMPANY      => ncompany,
                        sIN_UNITCODE  => 'DepartmentsOrders',
                        nIN_DOCUMENT  => rdep_ord.rn,
                        sOUT_UNITCODE => 'BuyPlanes',
                        nOUT_DOCUMENT => rbp.rn);
    end if;

    /*Устанавливаем связь заголовка заказа со строкой плана*/
    if (pkg_doclinks.FIND(nFLAG_SMART       => 1,
                          sIN_UNITCODE      => 'DepartmentsOrders',
                          nIN_DOCUMENT      => rdep_ord.rn,
                          nIN_PRN_DOCUMENT  => to_number(null),
                          sOUT_UNITCODE     => 'BuyPlaneSpecs',
                          nOUT_DOCUMENT     => rbp_sp.rn,
                          nOUT_PRN_DOCUMENT => to_number(null)) = 0) then
      pkg_doclinks.LINK(nFLAG_SMART   => 0,
                        nCOMPANY      => ncompany,
                        sIN_UNITCODE  => 'DepartmentsOrders',
                        nIN_DOCUMENT  => rdep_ord.rn,
                        sOUT_UNITCODE => 'BuyPlaneSpecs',
                        nOUT_DOCUMENT => rbp_sp.rn);
    end if;

    /*Дата включения в план закупок*/
    prsg_prop.VSET(sUNITCODE  => 'DepartmentsOrdersSpecs',
                   nDOCUMENT  => nrn,
                   sPROPCODE  => 'УМТС_ДатаВклПЗ',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => trunc(sysdate));
  end p_departmentords_bincl_bp;

  /*Процедура выполняет базовое исключение указанной строки заказа подразделений из плана закупок*/
  procedure p_departmentords_bexcl_bp(ncompany  in number /*Организация*/,
                                      nrn       in number /*Регистрационный номер записи*/,
                                      nsign_dir in number /*Признак исключения через распоряжение*/) is

    /*Атрибуты записи строки заказа подразделений*/
    rdep_ord_sp departmentords%rowtype;

    /*Атрибуты записи заказа подразделений*/
    rdep_ord departmentord%rowtype;

    /*Атрибуты записи заголовка плана закупок*/
    rbp buyplane%rowtype;

    /*Атрибуты записи строки плана закупок*/
    rbp_sp buyplanesp%rowtype;

    /*Атрибуты записи ссылки на заказ*/
    rref buyplanespref%rowtype;

    /*Количество записей*/
    ncount number;

  begin
    /*Атрибуты записи строки заказа подразделений*/
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

    /*Выполняем проверку состояния*/
    if (rdep_ord.ord_state <> 1) --and utilizer not in ('CITK_MARKOV', 'KHOK')
      then
      p_exception(0, 'Действие запрещено в состоянии, отличном от Утвержден');
    end if;

    /*Если для строки заказа подразделения указан признак не закупать, то выдаем сообщение об ошибке*/
    if (lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DepartmentsOrdersSpecs',
                                  nDOCUMENT => nrn,
                                  sPROPCODE => 'УМТС_НеЗакупать'))) = 'да')
       /*and utilizer not in ('CITK_MARKOV', 'KHOK') */then
      p_exception(0, 'Для строка заказа подразделений указан признак Не закупать');
    end if;

    /*Выполняем проверку включения в план закупок*/
    if (f_doclinks_link_out_doc(sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                                nIN_DOCUMENT  => nrn,
                                sOUT_UNITCODE => 'BuyPlanes') is null) then
      p_exception(0, 'Документ не включен в план закупок');
    end if;

    /*Атрибуты записи раздела Ссылки на заказы*/
/*if utilizer = 'KHOK' then ---p_exception(0,nrn); end if;
    begin
      select r.*
        into rref
        from buyplanespref r
       where r.deptordsp = nrn
         and r.company = ncompany
         and r.quant_plan > 0
         and (r.rn = 140876002 \*or user = 'STEPANOV_MV'*\) --113401927 -- !!!
         ;
    exception
      when no_data_found then
        rref.rn := 146566389; --140876002;
        rref.prn := 146566388; --140876001;
        --p_exception(0, 'Не удалось определить строку заказа в плане закупок ' || nrn);
      when too_many_rows then
        p_exception(0, 'Не удалось однозначно определить строку заказа в плане закупок ' || nrn);
    end;
else*/
    begin
      select r.*
        into rref
        from buyplanespref r
       where r.deptordsp = nrn
         and r.company = ncompany
         and r.quant_plan > 0 -- 25/01/2024 Марков МВ. - при переносе из одного плана в другой остаются нулевые строки
         ;
    exception
      when no_data_found then
        p_exception(0, 'Не удалось определить строку заказа в плане закупок ' || nrn);
      when too_many_rows then
        p_exception(0, 'Не удалось однозначно определить строку заказа в плане закупок ' || nrn);
    end;
--end if;
    /*Атрибуты записи строки плана закупок*/
    begin
      select s.*
        into rbp_sp
        from buyplanesp s
       where s.rn = rref.prn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rref.prn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');
    end;

    /*Атрибуты записи плана закупок*/
    begin
      select bp.*
        into rbp
        from buyplane bp
       where bp.rn = rbp_sp.prn
         and bp.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rbp_sp.prn,
                                 sUNIT_TABLE => 'BuyPlanes');
    end;

    /*Выполняем проверку состояния плана закупок*/
    if /*utilizer != 'KHOK' and */  (rbp.state <> 0) then
      if (nsign_dir = 0) then
        -- 27/06/2024 Марков МВ. Если по заказу подразделения не сформирован заказ поставщику - можно исключить!!!
        begin
          select count(*)
            into ncount
            from UDO_UZD_03_BUYPLANESP_CNTR_DOC DOC
           where DOC.RN_REF = rref.rn
             and DOC.DOC_QUANT_PLAN > 0 -- только при наличии количества, включенного в заказ
             ;
        exception
          when no_data_found then
            ncount := 0;
        end;
        if ncount > 0 then
          p_exception(0, 'Заказ подразделения включен в заказ поставщику. Исключение невозможно!');
        end if;
      end if;
    end if;

    /* 27/06/2024 Марков МВ. Выполняем удаление включения в заказы поставщиков с нулевым количеством */
    delete from UDO_UZD_03_BUYPLANESP_CNTR_DOC DOC
     where DOC.RN_REF = rref.rn
       and DOC.DOC_QUANT_PLAN > 0;

    /*Выполняем удаление ссылки на заказы*/
    p_buyplanespref_base_delete(nrn          => rref.rn,
                                ncompany     => ncompany,
                                nsign_ord    => 0,
                                nsign_client => 0);

    /*Разрываем связь строки заказа с заголовком плана*/
    pkg_doclinks.remove(sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                        nIN_DOCUMENT  => rdep_ord_sp.rn,
                        sOUT_UNITCODE => 'BuyPlanes',
                        nOUT_DOCUMENT => rbp.rn);

    /*Разрываем связь строки заказа со строкой плана*/
    pkg_doclinks.remove(sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                        nIN_DOCUMENT  => rdep_ord_sp.rn,
                        sOUT_UNITCODE => 'BuyPlaneSpecs',
                        nOUT_DOCUMENT => rbp_sp.rn);

    /*Разрываем связь заголовка заказа с заголовком плана*/
    select count(1)
      into ncount
      from departmentords dos, buyplanespref r, buyplanesp s
     where dos.prn = rdep_ord.rn
       and r.deptordsp = dos.rn
       and s.rn = r.prn
       and s.prn = rbp.rn;

    if (ncount = 0) then
      pkg_doclinks.remove(sIN_UNITCODE  => 'DepartmentsOrders',
                          nIN_DOCUMENT  => rdep_ord.rn,
                          sOUT_UNITCODE => 'BuyPlanes',
                          nOUT_DOCUMENT => rbp.rn);
    end if;

    /*Разрываем связь заголовка заказа со строкой плана*/
    select count(1)
      into ncount
      from departmentords dos, buyplanespref r
     where dos.prn = rdep_ord.rn
       and r.deptordsp = dos.rn
       and r.prn = rbp_sp.rn;

    if (ncount = 0) then
      pkg_doclinks.remove(sIN_UNITCODE  => 'DepartmentsOrders',
                          nIN_DOCUMENT  => rdep_ord.rn,
                          sOUT_UNITCODE => 'BuyPlaneSpecs',
                          nOUT_DOCUMENT => rbp_sp.rn);
    end if;

    /*Количество ссылок на заказы*/
    select count(1)
      into ncount
      from buyplanespref r
     where r.prn = rref.prn
       and r.company = ncompany;

    if (ncount = 0) then

      /* 28/10/2023 Марков МВ. перед удалением - проверить линки */
      for rhs in(select hs.rn from buyplanesphs hs where hs.prn = rref.prn) loop
        return;
        pkg_doclinks.REMOVE(sIN_UNITCODE => null,
                            nIN_DOCUMENT => null, sOUT_UNITCODE => 'BuyPlaneSpecsHistory', nOUT_DOCUMENT => rhs.rn);
      end loop;
      pkg_doclinks.REMOVE(sIN_UNITCODE => null,
                          nIN_DOCUMENT => null, sOUT_UNITCODE => 'BuyPlaneSpecs', nOUT_DOCUMENT => rref.prn);
      /*Выполняем удаление строки плана закупок*/
      p_buyplanesp_base_delete(ncompany => ncompany, nrn => rref.prn);

    else

      /*Выполняем исправление количества*/
      update buyplanesp s
         set s.quant_plan = s.quant_plan - rref.quant_plan,
             s.quant_acc  = s.quant_acc - rref.quant_plan
       where s.rn = rbp_sp.rn
         and s.company = ncompany;

      /*Выполняем проверку исправления количества*/
      if (sql%notfound) then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rbp_sp.rn,
                                 sUNIT_TABLE => 'BuyPlaneSpecs');

      end if;

    end if;

    /*Дата включения в план закупок*/
    prsg_prop.VSET(sUNITCODE  => 'DepartmentsOrdersSpecs',
                   nDOCUMENT  => nrn,
                   sPROPCODE  => 'УМТС_ДатаВклПЗ',
                   sSTRVALUE  => to_char(null),
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => to_date(null));
  end p_departmentords_bexcl_bp;

  /*Процедура выполняет базовое включение указанного заказа подразделений в план закупок*/
  procedure p_departmentord_bincl_bp(ncompany   in number /*Организация*/,
                                     nrn        in number /*Регистрационный номер записи*/,
                                     dplan_date in date /*Плановая дата поставки*/) is
  begin
    /*Цикл по строкам заказа подразделений*/
    for sp_cursor in (select s.rn as nrn, s.main_quant
                        from departmentords s
                       where s.prn = nrn
                         and s.company = ncompany
                         and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                                               nVERSION  => to_number(null),
                                                               sUNITCODE => 'DepartmentsOrdersSpecs',
                                                               nDOCUMENT => nrn,
                                                               sPROPCODE => 'УМТС_НеЗакупать'))),
                                     'да') = 0
                         and f_doclinks_link_out_doc(sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                                                     nIN_DOCUMENT  => s.rn,
                                                     sOUT_UNITCODE => 'BuyPlanes') is null
                         and udo_f_departmentords_to_bp(nrn => s.rn) > 0) loop

      p_departmentords_bincl_bp(ncompany   => ncompany,
                                nrn        => sp_cursor.nrn,
                                dplan_date => dplan_date,
                                nquant     => udo_f_departmentords_to_bp(nrn => sp_cursor.nrn),
                                nsign_dir  => 0);

    end loop;
  end p_departmentord_bincl_bp;

  /*Процедура выполняет базовое исключение указанного заказа подразделений из плана закупок*/
  procedure p_departmentord_bexcl_bp(ncompany in number /*Организация*/,
                                     nrn      in number /*Регистрационный номер записи*/) is
  begin
    /*Цикл по строкам заказа подразделений*/
    for sp_cursor in (select s.rn as nrn
                        from departmentords s
                       where s.prn = nrn
                         and s.company = ncompany
                         and f_doclinks_link_out_doc(sIN_UNITCODE  => 'DepartmentsOrdersSpecs',
                                                     nIN_DOCUMENT  => s.rn,
                                                     sOUT_UNITCODE => 'BuyPlanes') is not null) loop

      p_departmentords_bexcl_bp(ncompany  => ncompany,
                                nrn       => sp_cursor.nrn,
                                nsign_dir => 0);

    end loop;
  end p_departmentord_bexcl_bp;

  /*Процедура выполняет включение указанной строки заказа подразделений в план закупок*/
  procedure p_departmentords_incl_bp(ncompany   in number /*Организация*/,
                                     nrn        in number /*Регистрационный номер записи*/,
                                     dplan_date in date /*Плановая дата поставки*/,
                                     nquant     in number /*Количество*/) is

    /*Каталог*/
    ncrn pkg_std.tREF;

  begin

    /*Выполняем проверку ссуществования строки заказа подразделений*/
    p_departmentords_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrdersSpecs',
                     saction   => 'DepartmentsOrdersSpecsBP_Incl',
                     stable    => 'DEPARTMENTORDS',
                     ndocument => nrn);

    /*Выполняем базовое включение указанной строки заказа подразделений в план закупок*/
    p_departmentords_bincl_bp(ncompany   => ncompany,
                              nrn        => nrn,
                              dplan_date => dplan_date,
                              nquant     => nquant,
                              nsign_dir  => 0);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrdersSpecs',
                     saction   => 'DepartmentsOrdersSpecsBP_Incl',
                     stable    => 'DEPARTMENTORDS',
                     ndocument => nrn);
  end p_departmentords_incl_bp;

  /*Процедура выполняет исключение указанной строки заказа подразделений из плана закупок*/
  procedure p_departmentords_excl_bp(ncompany in number /*Организация*/,
                                     nrn      in number /*Регистрационный номер записи*/) is

    /*Каталог*/
    ncrn pkg_std.tREF;

  begin

    /*Выполняем проверку ссуществования строки заказа подразделений*/
    p_departmentords_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrdersSpecs',
                     saction   => 'DepartmentsOrdersSpecsBP_Excl',
                     stable    => 'DEPARTMENTORDS',
                     ndocument => nrn);

    /*Выполняем базовое исключение указанной строки заказа подразделений из плана закупок*/
    p_departmentords_bexcl_bp(ncompany  => ncompany,
                              nrn       => nrn,
                              nsign_dir => 0);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrdersSpecs',
                     saction   => 'DepartmentsOrdersSpecsBP_Excl',
                     stable    => 'DEPARTMENTORDS',
                     ndocument => nrn);
  end p_departmentords_excl_bp;

  /*Процедура выполняет включение указанной строки заказа подразделений в план закупок*/
  procedure p_departmentords_incl_bp_list(ncompany   in number /*Организация*/,
                                          nrn        in number /*Регистрационный номер записи*/,
                                          dplan_date in date /*Плановая дата поставки*/) is

    /*Атрибуты записи строки заказа подразделений*/
    rdep_ord_sp departmentords%rowtype;

  begin

    /*Атрибуты записи строки заказа подразделений*/
    begin
      select s.* into rdep_ord_sp from departmentords s where s.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => rdep_ord_sp.crn,
                     sunit     => 'DepartmentsOrdersSpecs',
                     saction   => 'DepartmentsOrdersSpecsBP_InclList',
                     stable    => 'DEPARTMENTORDS',
                     ndocument => nrn);

    /*Выполняем базовое включение указанной строки заказа подразделений в план закупок*/
    p_departmentords_bincl_bp(ncompany   => ncompany,
                              nrn        => nrn,
                              dplan_date => dplan_date,
                              nquant     => udo_f_departmentords_to_bp(nrn => nrn),
                              nsign_dir  => 0);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => rdep_ord_sp.crn,
                     sunit     => 'DepartmentsOrdersSpecs',
                     saction   => 'DepartmentsOrdersSpecsBP_InclList',
                     stable    => 'DEPARTMENTORDS',
                     ndocument => nrn);
  end p_departmentords_incl_bp_list;

  /*Процедура выполняет исключение указанной строки заказа подразделений из плана закупок*/
  procedure p_buyplanespref_excl_bp(ncompany in number /*Организация*/,
                                    nrn      in number /*Регистрационный номер записи*/) is

    /*Каталог*/
    ncrn pkg_std.tREF;

    /*Регистрационный номер записи строки заказа подразделений*/
    nrn_sp pkg_std.tREF;

  begin

    /*Выполняем проверку ссуществования строки заказа подразделений*/
    p_buyplanespref_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);

    begin
      select r.deptordsp
        into nrn_sp
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'BuyPlaneSpecsReferences',
                     saction   => 'BuyPlaneSpecsReferencesBP_Excl',
                     stable    => 'BUYPLANESPREF',
                     ndocument => nrn);

    /*Выполняем базовое исключение указанной строки заказа подразделений из плана закупок*/
    p_departmentords_bexcl_bp(ncompany  => ncompany,
                              nrn       => nrn_sp,
                              nsign_dir => 0);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'BuyPlaneSpecsReferences',
                     saction   => 'BuyPlaneSpecsReferencesBP_Excl',
                     stable    => 'BUYPLANESPREF',
                     ndocument => nrn);
  end p_buyplanespref_excl_bp;

  /*Процедура выполняет включение указанного заказа подразделений в план закупок*/
  procedure p_departmentord_incl_bp(ncompany   in number /*Организация*/,
                                    nrn        in number /*Регистрационный номер записи*/,
                                    dplan_date in date /*Плановая дата поставки*/) is

    /*Каталог*/
    ncrn pkg_std.tREF;

  begin

    /*Выполняем проверку ссуществования заказа подразделений*/
    p_departmentord_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrders',
                     saction   => 'DepartmentsOrdersBP_Incl',
                     stable    => 'DEPARTMENTORD',
                     ndocument => nrn);

    /*Выполняем базовое включение указанного заказа подразделений в план закупок*/
    p_departmentord_bincl_bp(ncompany   => ncompany,
                             nrn        => nrn,
                             dplan_date => dplan_date);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrders',
                     saction   => 'DepartmentsOrdersBP_Incl',
                     stable    => 'DEPARTMENTORD',
                     ndocument => nrn);
  end p_departmentord_incl_bp;

  /*Процедура выполняет исключение указанного заказа подразделений из плана закупок*/
  procedure p_departmentord_excl_bp(ncompany in number /*Организация*/,
                                    nrn      in number /*Регистрационный номер записи*/) is

    /*Каталог*/
    ncrn pkg_std.tREF;

  begin

    /*Выполняем проверку ссуществования заказа подразделений*/
    p_departmentord_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrders',
                     saction   => 'DepartmentsOrdersBP_Excl',
                     stable    => 'DEPARTMENTORD',
                     ndocument => nrn);

    /*Выполняем базовое исключение указанного заказа подразделений из плана закупок*/
    p_departmentord_bexcl_bp(ncompany => ncompany, nrn => nrn);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => ncompany,
                     nversion  => to_number(null),
                     ncatalog  => ncrn,
                     sunit     => 'DepartmentsOrders',
                     saction   => 'DepartmentsOrdersBP_Excl',
                     stable    => 'DEPARTMENTORD',
                     ndocument => nrn);
  end p_departmentord_excl_bp;

  /*Процедура выполняет пересчет записи интерфейса очистки потребностей от остатков*/
  procedure p_rest_clr_recalc(nrn in number /*Регистрационный номер записи*/) is

    /*Атрибуты записи*/
    rtmp udo_umts_01_rest_clr%rowtype;

  begin
    /*Выполняем расчет*/
    select nvl(sum(do.nmain_quant), 0),
           nvl(sum(do.nquant_res), 0),
           nvl(sum(do.nquant_inv), 0)
      into rtmp.quant, rtmp.quant_res, rtmp.quant_inv
      from udo_v_umts_01_rest_clr_dep_ord do
     where do.nprn = p_rest_clr_recalc.nrn;

    /*Выполняем исправление записи*/
    update udo_umts_01_rest_clr t
       set t.quant     = rtmp.quant,
           t.quant_res = rtmp.quant_res,
           t.quant_inv = rtmp.quant_inv
     where t.rn = nrn;

    /*Выполняем проверку исправления записи*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'udo_umts_01_rest_clr');
    end if;
  end p_rest_clr_recalc;

  /*Процедура выполняет базовое формирование интерфейса очистки потребностей от остатков*/
  procedure p_rest_clr_brecrt(ncompany  in number /*Организация*/,
                              sgrp      in varchar2 /*Группа номенклатуры*/,
                              nsign_imp in number /*Признак импорта*/) is
  begin
    /*Выполняем очистку временной таблицы*/
    delete udo_umts_01_rest_clr;

    /*Выполняем заполнение временной таблицы*/
    /* 17/09/2024 Марков МВ. строго по группе УМТС номенклатуры!!!
    insert into udo_umts_01_rest_clr
      select nm.rn, 0, 0, 0
        from nommodif nm
       where nsign_imp = 1
         and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany, --get_session_company,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'Nomenclator',
                                               nDOCUMENT => nm.prn,
                                               sPROPCODE => 'УМТС_Импорт'))),
                     'да') = 1;*/

    insert into udo_umts_01_rest_clr
      select nm.rn, 0, 0, 0
        from nommodif nm
       where /* 17/09/2024 Марков МВ. строго по группе УМТС номенклатуры!!!
             nsign_imp = 0
         and cmp_vc2(lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany, --get_session_company,
                                               nVERSION  => to_number(null),
                                               sUNITCODE => 'Nomenclator',
                                               nDOCUMENT => nm.prn,
                                               sPROPCODE => 'УМТС_Импорт'))),
                     'да') = 0
         and */prsg_prop.SGET(nCOMPANY  => ncompany, --get_session_company,
                            nVERSION  => to_number(null),
                            sUNITCODE => 'Nomenclator',
                            nDOCUMENT => nm.prn,
                            sPROPCODE => 'УМТС_ГруппаНомен') = sgrp;

    /*Выполняем пересчет*/
    for tmp_cusor in (select t.rn as nrn from udo_umts_01_rest_clr t) loop
      p_rest_clr_recalc(nrn => tmp_cusor.nrn);
    end loop;
  end p_rest_clr_brecrt;

  /*Процедура выполняет формирование интерфейса очистки потребностей от остатков*/
  procedure p_rest_clr_bparty_select(nrn in number /*Регистрационный номер записи*/) is
  begin
    nrn_pkg_party := nrn;
  end p_rest_clr_bparty_select;

  /*Процедура выполняет базовое резервирование*/
  procedure p_rest_clr_dep_ord_bres_crt(nrn    in number /*Регистрационный номер записи*/,
                                        nquant in number /*Количество*/) is

    /*Регистрационный номер записи резерва*/
    nrsrv pkg_std.tREF;

    /*Регистрационный номер записи модификации*/
    nmodif pkg_std.tREF;

  begin
    begin
      select s.nom_modif
        into nmodif
        from departmentords s
       where s.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;

    udo_pkg_resjournal_ctrl.make_by_dords_ex(nsupply  => nrn_pkg_party,
                                             nquant   => nquant,
                                             ndepords => nrn,
                                             nrsrv    => nrsrv);

    p_rest_clr_recalc(nrn => nmodif);
  end p_rest_clr_dep_ord_bres_crt;

  /*Процедура выполняет базовое снятие резервирования*/
  procedure p_rest_clr_res_bdelete(nrn in number /*Регистрационный номер записи*/) is

    /*Регистрационный номер записи строки заказа*/
    nrn_do_sp pkg_std.tREF;

    /*Регистрационный номер записи модификации*/
    nmodif pkg_std.tREF;

  begin
    begin
      select s.rn, s.nom_modif
        into nrn_do_sp, nmodif
        from udo_depords_prf p, departmentords s
       where p.rsrv = nrn
         and s.rn = p.dordsp;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'ReservationJournal');
    end;

    udo_pkg_resjournal_ctrl.take_by_dords(ndocument        => nrn,
                                          ndocument_parent => nrn_do_sp);

    p_rest_clr_recalc(nrn => nmodif);
  end p_rest_clr_res_bdelete;

  /*Процедура выполняет базовое включение в план закупок*/
  procedure p_rest_clr_dep_ord_bincl_bp(ncompany   in number /*Организация*/,
                                        nrn        in number /*Регистрационный номер записи*/,
                                        dplan_date in date /*Плановая дата поставки*/,
                                        nquant     in number /*Количество*/) is

    /*Атрибуты записи строки заказа подразделений*/
    rdep_ord_sp departmentords%rowtype;

    /*Атрибуты записи заказа подразделений*/
    rdep_ord departmentord%rowtype;

    /*Атрибуты записи заголовка плана закупок*/
    rbp buyplane%rowtype;

    /*Признак планирования по ИГК*/
    ssign_igk pkg_std.tSTRING;

    /*Периодичность*/
    ssign_period pkg_std.tSTRING;

  begin

    /*Атрибуты записи строки заказа подразделений*/
    begin
      select s.* into rdep_ord_sp from departmentords s where s.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;

    /*Атрибуты записи заказа подразделений*/
    begin
      select s.*
        into rdep_ord
        from departmentord s
       where s.rn = rdep_ord_sp.prn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdep_ord_sp.prn,
                                 sUNIT_TABLE => 'DepartmentsOrders');
    end;

    /*Выполняем поиск типа плана закупок*/
    p_dicnomns_calc_bp_type(nFLAG_SMART => 0,
                            ncompany    => ncompany,
                            nrn         => rdep_ord_sp.nomen,
                            nbp_type    => rbp.doctype);

    /*Признак планирования по ИГК*/
    ssign_igk := prsg_prop.SGET(nCOMPANY  => ncompany,
                                nVERSION  => to_number(null),
                                sUNITCODE => 'DOCTYPES',
                                nDOCUMENT => rbp.doctype,
                                sPROPCODE => 'УМТС_ПланироватьИГК');

    /*Периодичность*/
    ssign_period := prsg_prop.SGET(nCOMPANY  => ncompany,
                                   nVERSION  => to_number(null),
                                   sUNITCODE => 'DOCTYPES',
                                   nDOCUMENT => rbp.doctype,
                                   sPROPCODE => 'УМТС_Периодичность');

    /*Период*/
    p_calc_plan_period(dplan_date    => dplan_date,
                       speriod       => ssign_period,
                       dperiod_begin => rbp.begin_period,
                       dperiod_end   => rbp.end_period);

    /*Выполняем поиск плана закупок*/
    begin
      select bp.rn
        into rbp.rn
        from buyplane bp, govcntrid igk
       where bp.doctype = rbp.doctype
         and bp.company = ncompany
         and bp.begin_period = rbp.begin_period
         and igk.rn(+) = bp.govcntrid
         and (cmp_vc2(lower(trim(ssign_igk)), 'да') = 1 and
             igk.code =
             udo_f_departmentord_igk(nfaceacc => rdep_ord.faceacc) or
             cmp_vc2(lower(trim(ssign_igk)), 'да') = 0 and
             bp.govcntrid is null);
    exception
      when no_data_found then
        rbp.rn := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить план закупок');
    end;

    if (rbp.rn is not null) then
      /*Атрибуты записи плана закупок*/
      begin
        select bp.*
          into rbp
          from buyplane bp
         where bp.rn = rbp.rn
           and bp.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rbp.rn,
                                   sUNIT_TABLE => 'BuyPlanes');
      end;

    else
      rbp.state := 0;
    end if;

    if (rbp.state = 0) then
      p_departmentords_bincl_bp(ncompany   => ncompany,
                                nrn        => nrn,
                                dplan_date => dplan_date,
                                nquant     => nquant,
                                nsign_dir  => 0);
    else
      /*Дата включения в план закупок*/
      prsg_prop.VSET(sUNITCODE  => 'DepartmentsOrdersSpecs',
                     nDOCUMENT  => nrn,
                     sPROPCODE  => 'УМТС_ПризнакОчОст',
                     sSTRVALUE  => 'Да',
                     nNUMVALUE  => to_number(null),
                     dDATEVALUE => to_date(null));
    end if;

    p_rest_clr_recalc(nrn => rdep_ord_sp.nom_modif);
  end p_rest_clr_dep_ord_bincl_bp;

  /*Процедура выполняет формирование интерфейса очистки потребностей от остатков*/
  procedure p_rest_clr_recrt(ncompany  in number /*Организация*/,
                             sgrp      in varchar2 /*Группа номенклатуры*/,
                             nsign_imp in number /*Признак импорта*/) is
  begin

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClr',
                     saction   => 'UdoUmtsRestClrRecreate',
                     stable    => 'UDO_V_UMTS_01_REST_CLR',
                     ndocument => 0);

    /*Выполняем базовое формирование интерфейса очистки потребностей от остатков*/
    p_rest_clr_brecrt(ncompany  => ncompany,
                      sgrp      => sgrp,
                      nsign_imp => nsign_imp);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClr',
                     saction   => 'UdoUmtsRestClrRecreate',
                     stable    => 'UDO_V_UMTS_01_REST_CLR',
                     ndocument => 0);
  end p_rest_clr_recrt;

  /*Процедура выполняет выбор партии*/
  procedure p_rest_clr_party_select(nrn in number /*Регистрационный номер записи*/) is
  begin

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrParty',
                     saction   => 'UdoUmtsRestClrPartySelect',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_GP',
                     ndocument => nrn);

    /*Выполняем базовый выбор партии*/
    p_rest_clr_bparty_select(nrn => nrn);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrParty',
                     saction   => 'UdoUmtsRestClrPartySelect',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_GP',
                     ndocument => nrn);
  end p_rest_clr_party_select;

  /*Функция возвращает доступное для резервирования количество для указанной строки заказа подразделения*/
  function f_rest_clr_dep_ord_clc_res_qnt(nrn in number /*Регистрационный номер записи*/)
    return number is

    /*Свободный остаток*/
    NQUANT_SALE pkg_std.tQUANT;

  begin
    /*Свободный остаток*/
    begin
      select LEAST(T.RESTPLAN, T.RESTFACT) - T.RESERV
        into NQUANT_SALE
        from GOODSSUPPLY T
       where T.RN = nrn_pkg_party;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, nrn_pkg_party, 'GOODSSUPPLY');
    end;
    return(least(NQUANT_SALE,
                 udo_pkg_resjournal_ctrl.get_quanterst_by_order(ndepords => nrn)));
  end f_rest_clr_dep_ord_clc_res_qnt;

  /*Процедура выполняет резервирование*/
  procedure p_rest_clr_dep_ord_res_crt(nrn    in number /*Регистрационный номер записи*/,
                                       nquant in number /*Количество*/) is

  begin

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdResCrt',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);

    /*Выполняем базовое резервирование*/
    p_rest_clr_dep_ord_bres_crt(nrn => nrn, nquant => nquant);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdResCrt',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);
  end p_rest_clr_dep_ord_res_crt;

  /*Процедура выполняет резервирование по списку*/
  procedure p_rest_clr_dep_ord_res_crtl(nrn in number /*Регистрационный номер записи*/) is
  begin

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdResCrtL',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);

    /*Выполняем базовое резервирование*/
    p_rest_clr_dep_ord_bres_crt(nrn    => nrn,
                                nquant => f_rest_clr_dep_ord_clc_res_qnt(nrn => nrn));

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdResCrtL',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);
  end p_rest_clr_dep_ord_res_crtl;

  /*Процедура выполняет снятие резервирования*/
  procedure p_rest_clr_res_delete(nrn in number /*Регистрационный номер записи*/) is

  begin

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrRes',
                     saction   => 'UdoUmtsRestClrResDelete',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_RES',
                     ndocument => nrn);

    /*Выполняем базовое снятие резервирования*/
    p_rest_clr_res_bdelete(nrn => nrn);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrRes',
                     saction   => 'UdoUmtsRestClrResDelete',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_RES',
                     ndocument => nrn);
  end p_rest_clr_res_delete;

  /*Процедура выполняет включение в план закупок*/
  procedure p_rest_clr_dep_ord_incl_bp(ncompany   in number /*Организация*/,
                                       nrn        in number /*Регистрационный номер записи*/,
                                       dplan_date in date /*Плановая дата поставки*/,
                                       nquant     in number /*Количество*/) is

  begin

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdBP_Incl',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);

    /*Выполняем базовое включение указанной строки заказа подразделений в план закупок*/
    p_rest_clr_dep_ord_bincl_bp(ncompany   => ncompany,
                                nrn        => nrn,
                                dplan_date => dplan_date,
                                nquant     => nquant);

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdBP_Incl',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);
  end p_rest_clr_dep_ord_incl_bp;

  /*Процедура выполняет включение в план закупок*/
  procedure p_rest_clr_dep_ord_incl_bp_lst(ncompany   in number /*Организация*/,
                                           nrn        in number /*Регистрационный номер записи*/,
                                           dplan_date in date /*Плановая дата поставки*/) is

    /*Атрибуты записи строки заказа подразделений*/
    rdep_ord_sp departmentords%rowtype;

  begin

    /*Атрибуты записи строки заказа подразделений*/
    begin
      select s.* into rdep_ord_sp from departmentords s where s.rn = nrn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DepartmentsOrdersSpecs');
    end;

    /* фиксация начала выполнения действия */
    pkg_env.prologue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdBP_InclList',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);

    /*Выполняем базовое включение указанной строки заказа подразделений в план закупок*/
    p_rest_clr_dep_ord_bincl_bp(ncompany   => ncompany,
                                nrn        => nrn,
                                dplan_date => dplan_date,
                                nquant     => udo_f_departmentords_to_bp(nrn => nrn));

    /* фиксация окончания выполнения действия */
    pkg_env.epilogue(ncompany  => to_number(null),
                     nversion  => to_number(null),
                     ncatalog  => to_number(null),
                     sunit     => 'UdoUmtsRestClrDepOrd',
                     saction   => 'UdoUmtsRestClrDepOrdBP_InclList',
                     stable    => 'UDO_V_UMTS_01_REST_CLR_DEP_ORD',
                     ndocument => nrn);
  end p_rest_clr_dep_ord_incl_bp_lst;

  /*Процедура выполняет корректировку типа плана закупок*/
  procedure P_BUYPLANESPREF_correct_bptype(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN        in number /*Регистрационный номер записи*/,
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
    /*Дата начала периода планирования строки плана закупок назначения*/
    DDATE_BEGIN_dst date;
    /*Дата окончания периода планирования строки плана закупок назначения*/
    DDATE_END_dst date;
    /*Атрибуты записи заголовка плана закупок назначения*/
    RBP_DST BUYPLANE%rowtype;
    /*Атрибуты записи строки плана закупок назначения*/
    RBP_SP_DST BUYPLANESP%rowtype;
    /*Атрибуты записи заказа, подчиненного строке плана закупок назначения*/
    RREF_DST BUYPLANESPREF%rowtype;
    /*Регистрационный номер записи истории*/
    NHIST PKG_STD.TREF;
    /*Законтрактовано в ОЕИ по заказу*/
    NQUANT_CNTR_DO PKG_STD.TQUANT;
    /*Законтрактовано в ДЕИ по заказу*/
    NQUANT_CNTR_ALT_DO PKG_STD.TQUANT;
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
    /*Выполняем проверку количества*/
    if (rref_src.quant_plan <= 0) then
      p_exception(0,
                  'Данная позиция плана закупок не имеет положительное количество');
    end if;
    /*Выполняем проверку состояния исходного плана закупок*/
    if (RBP_SRC.STATE not in (2)) then
      P_EXCEPTION(0,
                  'План закупок должен находиться в состоянии "Утвержден"');
    end if;
    /*Старое значение плановой даты поставки*/
    DPLAN_DATE_old := prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                                     nVERSION  => to_number(null),
                                     sUNITCODE => 'BuyPlaneSpecsReferences',
                                     nDOCUMENT => NRN,
                                     sPROPCODE => 'УМТС_ПланДатаПост');
    /*Если тип плана закупок корректный, то выдаем сообщение об ошибке*/
    if (udo_f_buyplanespref_incorr_bpt(nrn => nrn) = 0) then
      p_exception(0,
                  'Тип плана закопок корректный');
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

    /*1. Раздел 1. Красный. Инициализация, проверки. Конец*/
    /*3. Раздел 3. Желтый. Уменьшение строки плана источника. Начало*/
    /*Выполняем формирование истории изменений записи заказа в плане закупок*/
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

    /* исправление записи в таблице */
    update BUYPLANESPREF R
       set R.QUANT_PLAN = 0, R.QUANTALT_PLAN = 0
     where R.RN = NRN
       and R.COMPANY = NCOMPANY;
    --
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                               SUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end if;
    /*Выполняем формирование истории изменений строки плана закупок*/
    P_BUYPLANESPHS_MAKE(ncompany  => ncompany,
                        nprn      => RSP_SRC.RN,
                        sunitcode => TO_CHAR(null),
                        ndocument => TO_NUMBER(null),
                        ddate_to  => DHIST_DATE,
                        sbase     => sbase,
                        nrn       => nrn_hist);

    /*Выполняем пересчет количества в строке плана закупок*/
    update BUYPLANESP s
       set s.QUANT_PLAN    = s.quant_plan - RREF_SRC.Quant_Plan,
           s.quant_acc     = s.quant_acc - RREF_SRC.Quant_Plan,
           s.quantalt_plan = s.quantalt_plan - RREF_SRC.Quantalt_Plan,
           s.quantalt_acc  = s.quantalt_acc - RREF_SRC.Quantalt_Plan
     where s.RN = RSP_SRC.RN
       and s.company = ncompany;

    /*Выполняем проверку исправления записи*/
    if (SQL%NOTFOUND) then
      PKG_MSG.RECORD_NOT_FOUND(RSP_SRC.RN, 'BuyPlaneSpecs');
    end if;

    /*Выполняем корректировку связей заказа с планом закупок при исключении*/
    udo_pkg_umts_04_perf.P_BUYPLANESPREF_LNK_CORR_EXCL(NCOMPANY  => NCOMPANY,
                                                       NRN_DO_SP => RDEP_ORD_SP.RN,
                                                       NRN_DO    => RDEP_ORD_SP.PRN,
                                                       NRN_BP_SP => RSP_SRC.RN,
                                                       NRN_BP    => RSP_SRC.PRN);

    /*3. Раздел 3. Желтый. Уменьшение строки плана источника. Конец*/

    /*4. Раздел 4. Зеленый. Увеличение строки плана назначения. Начало*/

    /*Тип плана назначения*/
    p_dicnomns_calc_bp_type(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => RSP_SRC.Nomen,
                            nbp_type    => rbp_dst.doctype);

    /*Периодичность*/
    ssign_period := prsg_prop.SGET(nCOMPANY  => ncompany,
                                   nVERSION  => to_number(null),
                                   sUNITCODE => 'DOCTYPES',
                                   nDOCUMENT => rbp_dst.doctype,
                                   sPROPCODE => 'УМТС_Периодичность');

    /*Период плана закупок*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => DPLAN_DATE_old,
                                            speriod       => ssign_period,
                                            dperiod_begin => RBP_DST.BEGIN_PERIOD,
                                            dperiod_end   => RBP_DST.End_Period);

    /*Выполняем поиск плана закупок*/
    begin
      select bp.rn
        into RBP_DST.RN
        from buyplane bp
       where bp.doctype = rbp_dst.doctype
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
      find_acatalog_name(nFLAG_SMART => 0,
                         nCOMPANY    => ncompany,
                         nVERSION    => to_number(null),
                         sUNITCODE   => 'BuyPlanes',
                         sNAME       => /* 17/09/2024 Марков МВ. строго по группе УМТС номенклатуры!!!
                                         (case
                                          when (lower(trim(prsg_prop.SGET(nCOMPANY  => ncompany,
                                                                          nVERSION  => to_number(null),
                                                                          sUNITCODE => 'Nomenclator',
                                                                          nDOCUMENT => rdep_ord_sp.nomen,
                                                                          sPROPCODE => 'УМТС_Импорт'))) = 'да') then
                                           ('Импорт')
                                          else
                                           (prsg_prop.SGET(nCOMPANY  => ncompany,
                                                           nVERSION  => to_number(null),
                                                           sUNITCODE => 'Nomenclator',
                                                           nDOCUMENT => rdep_ord_sp.nomen,
                                                           sPROPCODE => 'УМТС_ГруппаНомен'))
                                        end),*/
                                        prsg_prop.SGET(nCOMPANY  => ncompany,
                                                           nVERSION  => to_number(null),
                                                           sUNITCODE => 'Nomenclator',
                                                           nDOCUMENT => rdep_ord_sp.nomen,
                                                           sPROPCODE => 'УМТС_ГруппаНомен'),
                         nRN         => RBP_DST.crn);

      /*Юридическое лио*/
      RBP_DST.jur_pers := RBP_SRC.jur_pers;

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

    /*Дискретность*/
    ssign_disrc := prsg_prop.SGET(nCOMPANY  => ncompany,
                                  nVERSION  => to_number(null),
                                  sUNITCODE => 'DOCTYPES',
                                  nDOCUMENT => RBP_DST.doctype,
                                  sPROPCODE => 'УМТС_Дискретность');

    /*Период планирования строки плана закупок назначения*/
    udo_pkg_umts_01_plan.p_calc_plan_period(dplan_date    => DPLAN_DATE_old,
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
      RBP_SP_DST.quant_plan := RREF_SRC.Quant_Plan;
      RBP_SP_DST.quant_acc  := RREF_SRC.Quant_Plan;

      /*Количество ДЕИ*/
      RBP_SP_DST.quantalt_plan := RREF_SRC.Quantalt_Plan;
      RBP_SP_DST.quantalt_acc  := RREF_SRC.Quantalt_Plan;

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
      if (rbp_dst.state in (2)) then
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
         set s.QUANT_PLAN    = s.quant_plan + RREF_SRC.Quant_Plan,
             s.quant_acc     = s.quant_acc + RREF_SRC.Quant_Plan,
             s.quantalt_plan = s.quantalt_plan + RREF_SRC.Quantalt_Plan,
             s.quantalt_acc  = s.quantalt_acc + RREF_SRC.Quantalt_Plan
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
                                  NQUANT_PLAN    => RREF_SRC.Quant_Plan,
                                  NQUANTALT_PLAN => RREF_SRC.QUANTALT_PLAN,
                                  NSIGN_EXCL     => 0,
                                  NHIST          => NHIST,
                                  NRN            => RREF_DST.RN,
                                  NSIGN_ORD      => 0 /*Анненко И.С. 15.06.2021*/);
    else
      /*Выполняем формирование истории изменений записи заказа в плане закупок*/
      if (rbp_dst.state in (2)) then
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
         set R.QUANT_PLAN    = R.QUANT_PLAN + rref_src.quant_plan,
             R.QUANTALT_PLAN = R.QUANTALT_PLAN + rref_src.quantalt_plan
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
                   dDATEVALUE => dplan_date_old);

    /*Выполняем корректировку связей заказа с планом закупок при включении*/
    udo_pkg_umts_04_perf.P_BUYPLANESPREF_LNK_CORR_INCL(NCOMPANY  => NCOMPANY,
                                                       NRN_DO_SP => RDEP_ORD_SP.RN,
                                                       NRN_DO    => RDEP_ORD_SP.PRN,
                                                       NRN_BP_SP => RBP_SP_DST.RN,
                                                       NRN_BP    => RBP_DST.RN);

    /*4. Раздел 4. Зеленый. Увеличение строки плана назначения. Конец*/

    /*5. Раздел 5. Синий. Корректировка контрактации. Начало*/
    select NVL(sum(T.QUANT_PLAN), 0), NVL(sum(T.QUANT_PLAN_ALT), 0)
      into NQUANT_CNTR_DO, NQUANT_CNTR_ALT_DO
      from UDO_UZD_03_BPSP_CNTR_DOC_TMP T
     where T.RN_REF = NRN;
    if ((NQUANT_CNTR_DO > 0) or (NQUANT_CNTR_ALT_DO > 0)) then
      udo_pkg_umts_02_cntr.P_BUYPLANESPREF_MOVE_CNTR(NCOMPANY        => NCOMPANY,
                                                     NRN_SRC         => NRN,
                                                     NRN_DST         => RREF_DST.RN,
                                                     NPRN_DST        => RBP_SP_DST.RN,
                                                     NCRN_DST        => RBP_DST.CRN,
                                                     NBP_DST         => RBP_DST.RN,
                                                     NQUANT_MOVE     => NQUANT_CNTR_DO,
                                                     NQUANT_ALT_MOVE => NQUANT_CNTR_ALT_DO);
    end if;
    /*5. Раздел 5. Синий. Корректировка контрактации. Конец*/
  end P_BUYPLANESPREF_correct_bptype;

begin
  -- Initialization
  null;
end udo_pkg_umts_01_plan;
/
