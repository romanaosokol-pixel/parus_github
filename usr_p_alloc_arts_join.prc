create or replace procedure usr_p_alloc_arts_join(nfinplan      in number /* RN Бюджета */
                                                 ,ncompany      in number
                                                 ,sfinplan_arts in varchar2 /* Номер уточняемой строки бюджета*/
                                                 ,sfaceacc      in faceacc.numb%type
                                                 ,soei_code     in dicmunts.meas_mnemo%type
                                                 ,pin_spz       in faceacc.numb%type
                                                 ,nfinplan_arts out udo_t_finplan_arts.rn%type /*RN статьи бюджет, которую уточняем*/
                                                 ,nfaceacc      out faceacc.rn%type
                                                 ,noei          out dicmunts.rn%type
                                                 ,out_nspz      out faceacc.rn%type
                                                  
                                                  ) is

  s_depcode   ins_department.code%type;
  v_fcrn      faceacc.crn%type;
  v_njur_pers udo_t_finplan.jur_pers%type;

begin
  /*Разрешение ссылок строки бюджетного распределения*/
  /*Статья уточняемого бюджета */
  if sfinplan_arts is not null
  then
    begin
      select sp.rn
            ,dep.code
            ,bj.jur_pers
        into nfinplan_arts
            ,s_depcode
            ,v_njur_pers
        from udo_t_finplan_arts sp
        join udo_t_finplan bj
          on bj.rn = sp.prn
        left join ins_department dep
          on dep.rn = bj.depord
      
       where sp.prn = nfinplan
         and sp.art_numb = sfinplan_arts;
    exception
      when no_data_found then
        p_exception(0
                   ,'Статья с кодом %s не найдена в уточняемой версии бюджета'
                   ,sfinplan_arts);
    end;
  end if;
  /*Найдем ОЕИ*/
  if soei_code is not null
  then
    begin
      select ei.rn
        into noei
        from dicmunts ei
        join compverlist v
          on v.version = ei.version
         and v.company = ncompany
         and v.unitcode = 'MeasureUnits'
       where ei.meas_mnemo = soei_code;
    
    exception
      when no_data_found then
        p_exception(0
                   ,'Единица измерения с кодом %s не найдена, выберите корректное значение.');
    end;
  end if;

  /* Лицевой счет затрат */
  begin
    select f.rn
      into nfaceacc
      from faceacc f
     where f.numb = sfaceacc
       and f.company = ncompany;
  exception
    when no_data_found then
      /* Заведем лицевой счет */
    
      /* Проверим, что каталог лицевых счетов, с наименованием, равным наименованию Кода отдела есть, если нет, то заведем его*/
    
      usr_p_faceacc_crn_create(ncompany => ncompany, cat_name => nvl(s_depcode, 'ШПЗ'), cat_parent_name => 'ШПЗ', nrn => v_fcrn);
    
      p_faceacc_base_insert(ncompany         => ncompany
                           ,ncrn             => v_fcrn
                           ,njur_pers        => v_njur_pers
                           ,nprn             => null
                           ,nagent           => null
                           ,nfinerule        => null
                           ,snumber          => sfaceacc
                           ,nacc_kind        => 0 /*Потребление/Закупка*/
                           ,nacc_class       => 3 /* Внутренний */
                           ,noper_flag       => 0 /**/
                           ,nsign_contract   => 0
                           ,nsign_stage      => 0
                           ,norder_sign      => 0
                           ,nvalid_doctype   => null
                           ,svalid_docnumb   => null
                           ,dvalid_docdate   => null
                           ,dplan_open_date  => trunc(sysdate)
                           ,dfact_open_date  => trunc(sysdate)
                           ,dplan_close_date => null
                           ,dfact_close_date => null
                           ,nexecutive       => null
                           ,ncurrency        => 91318 /* Рубль */
                           ,ncredit_sum      => 0
                           ,nbegin_sum       => 0
                           ,ncurrent_sum     => 0
                           ,nplan_sum        => 0
                           ,nfcacgr          => null
                           ,nagnacc          => null
                           ,nagnfi           => null
                           ,nagnfo           => null
                           ,nagn_trans       => null
                           ,nsubdiv          => null /* Подумать, а не задавать ли подразделение */
                           ,ntarif           => null
                           ,ndiscount        => 0
                           ,npay_type        => null
                           ,nship_type       => null
                           ,nprice_type      => 1
                           ,dprice_date      => null
                           ,nsigntax         => 1
                           ,nsame_nomn       => 0
                           ,ndoc_serv        => 0
                           ,nplan_serv       => 0
                           ,nfact_serv       => 0
                           ,ndoc_ship        => 0
                           ,nplan_ship       => 0
                           ,nfact_ship       => 0
                           ,ndoc_income      => 0
                           ,nplan_income     => 0
                           ,nfact_income     => 0
                           ,nfact_deficit    => 0
                           ,ndoc_posted      => 0
                           ,nplan_posted     => 0
                           ,nfact_posted     => 0
                           ,ndoc_payed       => 0
                           ,nplan_payed      => 0
                           ,nfact_payed      => 0
                           ,nfinaccnt        => null
                           ,nrespmanager     => null
                           ,nieelement       => null
                           ,nfinsource       => null
                           ,npaytool         => null
                           ,npayprior        => null
                           ,npayrule         => null
                           ,ncheck_bal_sign  => 1
                           ,nspec_mark       => null
                           ,nbudgexpend_sp   => null
                           ,nserv_sum        => 0
                           ,nserv_percent    => 0
                           ,nfinplanrest     => 0
                           ,snote            => null
                           ,nexpstruct       => null
                           ,nincomeclass     => null
                           ,neconclass       => null
                           ,ndicbunts        => null
                           ,naccfndsrc       => null
                           ,ngovcntrid       => null
                           ,naddr_agent      => null
                           , -- Адресат платежа
                            naddr_agnacc     => null
                           , -- Реквизиты адресата платежа
                            nrn              => nfaceacc);
    
  end;

  begin
    if pin_spz is not null
    then
      begin
        select f.rn
          into out_nspz
          from faceacc f
          join projectstage ps
            on ps.faceacc = f.rn
         where f.numb = pin_spz
           and f.company = ncompany;
      
      exception
        when no_data_found then
          p_exception(0
                     ,'Лицевой счет %s нельзя использовать в качества ШПЗ т.к. он не задействован ни в одном этапе проекта.'
                     ,pin_spz);
      end;
    end if;
  
  end;

end;
/
