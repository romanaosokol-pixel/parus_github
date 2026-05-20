create or replace procedure usr_p_payaccinspclc_insert_ini(nrn                in number
                                                          ,nprn               in number
                                                          ,ncompany           in number
                                                          ,speriod            out varchar2
                                                          ,sdepord            out varchar2
                                                          ,sbudj_code         out varchar2
                                                          ,finplan_rn         out number
                                                          ,finplan_arts_rn    out number
                                                          ,sfaceaccount       out varchar2
                                                          ,nquant_fact        out number
                                                          ,ncost_fact_sum     out number
                                                          ,sbudj_art_nmb      out varchar2
                                                          ,salloc_art_nmb     out varchar2
                                                          ,allocation_sp_rn   out number
                                                          ,sbudj_code_enb     out number /*Доступность изменения поля Бюджет*/
                                                          ,sbudj_art_nmb_enb  out number /*Доступность статьи бюджета */
                                                          ,scost_article_enb  out number /* Доступность статьи затрат */
                                                          ,salloc_art_nmb_enb out number /* Доступность уточненной статьи */
                                                          ,limit_year         out number
                                                          ,cost_year          out number
                                                          ,balance_year       out number
                                                          ,salloc_art_nmb_clr out varchar2
                                                          ,is_allc_art_nmb    out number
                                                          ,is_ok              out number /* Доступность кнопки "ОК" */
                                                          ,err_txt            out varchar2 /*Сообщение об ошибке , если кнопка ОК недоступна */
                                                           
                                                           ) is
  payin_nrn     payaccin.rn%type;
  payin_faceacc payaccin.faceacc%type;

begin

  select p.rn
    into payin_nrn
    from payaccinspec ps
    join payaccin p
      on p.rn = ps.prn
   where ps.rn = nprn;

  usr_p_payaccinspclc_finpl_def(nrn             => payin_nrn
                               ,ncompany        => ncompany
                               ,speriod         => speriod
                               ,sbudj_code      => sbudj_code
                               ,finplan_rn      => finplan_rn
                               ,sdepord         => sdepord
                               ,sbudj_art_nmb   => sbudj_art_nmb
                               ,finplan_arts_rn => finplan_arts_rn
                               ,payin_faceacc   => payin_faceacc);
  ---  P_EXCEPTION(0, sdepord ||' '||sbudj_code);

  if sdepord is null
  then
    /*Попробуем взять подразделение из параметра */
    sdepord := pkg_options.get_options_str(scode => 'Realiz_PaymentAccountsIn_Department', ncomp_vers => ncompany);
  end if;
 
  if speriod is null
     or sdepord is null
  then
    sbudj_code_enb := 0;
  else
    sbudj_code_enb := 1;
  end if;
  /* Если не задан бюджет, то статью задать нельзя */
  if sbudj_code is null
  then
  
    /* Если не задан бюджет, то статью задать нельзя */
    sbudj_code        := 'Выберите бюджет';
    sbudj_art_nmb_enb := 1;
  else
    sbudj_art_nmb_enb := 1;
  end if;

  /* Если не задана статья бюджета, то статью затрат нужно задать вручную */

  scost_article_enb := 0;
  
  /* Рассчитаем сумму и количество по калькуляции */

  with sq as
   (select t.quant       q
          ,t.summwithnds s
      from payaccinspec t
     where t.rn = nprn
    
    union all
    /*Определяем через plan, т.к. факта может не быть*/
    select -cl.quant_plan
          ,-cl.cost_plan * cl.quant_plan
      from payaccinspclc cl
     where cl.prn = nprn)
  
  select sum(sq.q) q
        ,sum(sq.s)
    into nquant_fact
        ,ncost_fact_sum
    from sq;

  /* Если подстатья SALLOC_ART_NMB у статьи единственная, то срвзу ее выбираем */

  begin
  
    select brs.art_numb
          ,brs.rn
      into salloc_art_nmb
          ,allocation_sp_rn
      from usr_t_alloc_arts brs
     where brs.finplan_arts = finplan_arts_rn;
  
  exception
    when others then
      salloc_art_nmb   := null;
      allocation_sp_rn := null;
    
  end;

/* Найдем ШПЗ */

  usr_p_shpz_get_get(ncompany          => ncompany
                    ,nrn               => nrn
                    ,sunitcode         => 'PaymentAccountsIn'
                    ,speriod           => speriod
                    ,nfaceacc          => payin_faceacc
                    ,salloc_art_rn     => allocation_sp_rn
                    ,out_sfaceacc_shpz => sfaceaccount);

  if sbudj_art_nmb is null
  then
    /* Обязательность заполнения подстатьи */
    /* Уточненную статью можно выбрать только если они есть у статьи бюджета*/
    begin
    
      select 1
            , /*to_char(pkg_options.get_options_num(scode => 'RequeredColor', ncomp_vers => ncompany)) ---*/'65535'
            ,1
        into salloc_art_nmb_enb
            ,salloc_art_nmb_clr
            ,is_allc_art_nmb
        from usr_t_alloc_arts t
       where t.finplan_arts = finplan_arts_rn
         and rownum = 1;
    exception
      when no_data_found then
        salloc_art_nmb_enb := 0;
        salloc_art_nmb_clr := '-2147483645'; /*Серый цвет*/
        is_allc_art_nmb    := 0;
      
    end;
  
    salloc_art_nmb_enb := 0;
    is_allc_art_nmb    := 0;
    salloc_art_nmb_clr := '-2147483645'; /*Серый цвет*/
  
  else
  
    salloc_art_nmb_enb := 1;
    salloc_art_nmb_clr := '16777215'; /* белый цвет */
  
  end if;

  
    limit_year   := usr_f_alloc_art_limit(allocation_sp_rn, 0);
    cost_year    := usr_f_payaccin_cost_sum(allocation_sp_rn);
    balance_year := limit_year - cost_year;
  


  /* Заготовка для контролей */
  is_ok   := 1;
  err_txt := null;

end;
/
