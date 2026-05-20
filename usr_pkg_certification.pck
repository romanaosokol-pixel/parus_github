create or replace package USR_PKG_CERTIFICATION is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Номенклатор". 
  Certificates        CERTIFICATION     CRT
  CertificatesSpecs   CERTIFICATIONSP   CRTS
  */
  --#########################################################################################################

  function CERTIFICATION_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ) 
  return CERTIFICATION%rowtype;
  --#########################################################################################################

  function CERTIFICATION_GET_SP
  /*
  Поиск единственной спецификации для сертификата
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  )
  return number;
  --#########################################################################################################

  procedure CERTIFICATION_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATION_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATION_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATION_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATION_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATION_BASE_INSERT
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certification%rowtype
  ,nRN          out number
  );
  --#########################################################################################################

  procedure CERTIFICATION_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certification%rowtype
  );
  --#########################################################################################################

  function CERTIFICATIONSP_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ) 
  return CERTIFICATIONSP %ROWTYPE;
  --#########################################################################################################

  procedure CERTIFICATIONSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATIONSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATIONSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATIONSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATIONSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CERTIFICATIONSP_BASE_INSERT
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certificationsp%rowtype
  ,nRN          out number
  );
  --#########################################################################################################

  procedure CERTIFICATIONSP_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certificationsp%rowtype
  );
  --#########################################################################################################

end USR_PKG_CERTIFICATION;
/
create or replace package body USR_PKG_CERTIFICATION is

  --#########################################################################################################

  function CERTIFICATION_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ) 
  return certification%rowtype
  is
    rRow certification%rowtype;
  begin
    begin
      select T.*
        into rRow
        from certification t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART,ndocument => nRN, sunit_table => 'CERTIFICATION');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CERTIFICATION')));
    end;
    return(rRow);
  end CERTIFICATION_GET;

  --#########################################################################################################

  function CERTIFICATION_GET_SP
  /*
  Поиск единственной спецификации для сертификата
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  )
  return number
  is
    nRef    pkg_std.tref; 
  begin
    begin
      select rn into nRef from certificationsp where prn = nRN;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найдено записей в разделе "Сертифицируемые товары и услуги" для сертификата <%s>. %s'
                   ,nRN
                   ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => nRN));
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одной записи в разделе "Сертифицируемые товары и услуги" для сертификата <%s>. %s'
                   ,nRN
                   ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => nRN));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске в разделе "Сертифицируемые товары и услуги" для сертификата <%s>. %s'
                   ,nRN
                   ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => nRN));
    end;

    return(nRef);

  end CERTIFICATION_GET_SP;
  --#########################################################################################################

  procedure CERTIFICATION_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow            certification%rowtype;*/
  begin
    /* Считывание */
     /*rRow := certification_get(nrn => nRN); */
     
    /* ПРОВЕРКИ */
    /* Базовая */
    certification_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end CERTIFICATION_AINSERT;
  --#########################################################################################################

  procedure CERTIFICATION_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rcertification := certification_get(nrn => nRN); */
    
  end CERTIFICATION_BUPDATE;
  --#########################################################################################################

  procedure CERTIFICATION_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow                certification%rowtype;*/
    nCertificationSp    pkg_std.tref; 
    rCertificationSp    pkg_std.tref; 
  begin
    /* Считывание */
    /*rRow := certification_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    certification_check_base(nrn => nRN, ncompany => nCOMPANY);
/*
    \* Если исправлялась запись со свойством 'Фактическая поверка. Дата' *\
    if cmp_vc2(f_docs_props_get_str_value(nproperty => 97644642, sunitcode => 'Certificates', ndocument => rRow.rn)
              ,'Фактическая поверка. Дата') = 1 then

      \* Поиск единственной спецификации сертификата *\
      nCertificationSp := certification_get_sp(nrn => , nflagsmart => 1);

      \* Если спецификация найдена *\
      if nCertificationSp is not null then
        \* считываем её запись *\
        rCertificationSp := CertificationSp_get(nrn => nCertificationSp); 
      end if;

      \* Находим запись 'Плановая поверка. Дата' *\
      usr_pkg_goodsparties_add.get(ngoodsparties => :ngoodsparties, stype => :stype);

      if cmp_dat(rRow.date_to, usr_pkg_pub_const.rcertification.date_to) != 1 then
        rRow.date_to := 
      end if;
    end if;              
    */
  end CERTIFICATION_AUPDATE;
  --#########################################################################################################

  procedure CERTIFICATION_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          certification%rowtype;
    sGP_AddType   pkg_std.tstring; 
  begin
    /* Считывание */
     rRow := certification_get(nrn => nRN); 
    /* Свойство "Доп.данные прих.парт" */
    sGP_AddType := f_docs_props_get_str_value(nproperty => 97644642, sunitcode => 'Certificates', ndocument => rROW.RN);

    /* Если каталог Метрология, то добавление только процедурой */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => usr_pkg_pub_const.ncrt_cat_gp_add) then
      p_exception(0, 'В каталоге <%s> операции разрешено делать только с использованием пользовательской процедуры. %s'
                 ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                 ,cr||f_docdescrs_get_description('Certificates', rRow.rn)); 
    end if;

  end CERTIFICATION_BDELETE;
  --#########################################################################################################

  procedure CERTIFICATION_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          certification%rowtype;
    sGP_AddType   pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := certification_get(nRN); 
    /* Свойство "Доп.данные прих.парт" */
    sGP_AddType := f_docs_props_get_str_value(nproperty => 97644642, sunitcode => 'Certificates', ndocument => rROW.RN);

    /* Если каталог Дополнительные данные приходных партий, и тип доп.данных НЕ Характеристики и Руководство то добавление только процедурой */
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => usr_pkg_pub_const.ncrt_cat_gp_add) then
      p_exception(0, 'В каталоге <%s> операции разрешено делать только с использованием пользовательской процедуры. %s'
                 ,get_acatalog_name_id(nflag_smart => 1, nrn => rRow.crn)
                 ,cr||f_docdescrs_get_description('Certificates', rRow.rn)); 
    end if;
    
  end CERTIFICATION_CHECK_BASE;
  --#########################################################################################################

  procedure CERTIFICATION_BASE_INSERT
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certification%rowtype
  ,nRN          out number
  ) 
  is 
    nCompany    pkg_std.tref;  
  begin
    find_company_by_version(nversion => rROW.version, sunitcode => 'Certificates', ncompany => nCompany);
    p_certification_base_insert(ncompany               => nCompany
                               ,ncrn                   => rRow.crn
                               ,snumb_cert             => rRow.numb_cert
                               ,ncompany_cert          => rRow.company_cert
                               ,ncompany_cert_director => rRow.company_cert_director
                               ,ncompany_cert_expert   => rRow.company_cert_expert
                               ,ddate_from             => rRow.date_from
                               ,ddate_to               => rRow.date_to
                               ,snote                  => rRow.note
                               ,nrn                    => nRN);
  end CERTIFICATION_BASE_INSERT;
  --#########################################################################################################

  procedure CERTIFICATION_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certification%rowtype
  ) 
  is 
    nCompany    pkg_std.tref;  
  begin
    find_company_by_version(nversion => rROW.version, sunitcode => 'Certificates', ncompany => nCompany);
    p_certification_base_update(ncompany               => nCompany
                               ,nrn                    => rRow.rn
                               ,snumb_cert             => rRow.numb_cert
                               ,ncompany_cert          => rRow.company_cert
                               ,ncompany_cert_director => rRow.company_cert_director
                               ,ncompany_cert_expert   => rRow.company_cert_expert
                               ,ddate_from             => rRow.date_from
                               ,ddate_to               => rRow.date_to
                               ,snote                  => rRow.note);
  end CERTIFICATION_BASE_UPDATE;

  --#########################################################################################################

  function CERTIFICATIONSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ) 
  return certificationsp%rowtype
  is
    rRow certificationsp%rowtype;
  begin
    begin
      select T.*
        into rRow
        from certificationsp t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART,ndocument => nRN, sunit_table => 'CERTIFICATIONSP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CERTIFICATIONSP')));
    end;
    return(rRow);
  end CERTIFICATIONSP_GET;
  --#########################################################################################################

  procedure CERTIFICATIONSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    certificationsp_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end CERTIFICATIONSP_AINSERT;
  
  --#########################################################################################################

  procedure CERTIFICATIONSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CERTIFICATIONSP_BUPDATE;
  --#########################################################################################################

  procedure CERTIFICATIONSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    certificationsp_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end CERTIFICATIONSP_AUPDATE;
  --#########################################################################################################

  procedure CERTIFICATIONSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CERTIFICATIONSP_BDELETE;
  --#########################################################################################################

  procedure CERTIFICATIONSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     certificationsp%rowtype;
  begin
    null;
    /* Считывание */
    /*  rRow := certificationsp_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    
  end CERTIFICATIONSP_CHECK_BASE;
  --#########################################################################################################

  procedure CERTIFICATIONSP_BASE_INSERT
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certificationsp%rowtype
  ,nRN          out number
  ) 
  is 
    nCompany    pkg_std.tref;  
  begin
    find_company_by_version(nversion => rROW.version, sunitcode => 'CertificatesSpecs', ncompany => nCompany);
    p_certificationsp_base_insert(ncompany    => nCompany
                                 ,nprn        => rRow.prn
                                 ,nnommodif   => rRow.nommodif
                                 ,ngoodsparty => rRow.goodsparty
                                 ,ssernumb    => rRow.sernumb
                                 ,nparty      => rRow.party
                                 ,nrn         => nRN);
  end CERTIFICATIONSP_BASE_INSERT;
  --#########################################################################################################

  procedure CERTIFICATIONSP_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in certificationsp%rowtype
  ) 
  is 
    nCompany    pkg_std.tref;  
  begin
    find_company_by_version(nversion => rROW.version, sunitcode => 'CertificatesSpecs', ncompany => nCompany);
    p_certificationsp_base_update(ncompany    => nCompany
                                 ,nrn         => rRow.rn
                                 ,nnommodif   => rRow.nommodif
                                 ,ngoodsparty => rRow.goodsparty
                                 ,ssernumb    => rRow.sernumb
                                 ,nparty      => rRow.party);
  end CERTIFICATIONSP_BASE_UPDATE;
--#########################################################################################################

end USR_PKG_CERTIFICATION;
/
