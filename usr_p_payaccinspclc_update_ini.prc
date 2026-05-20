create or replace procedure usr_p_payaccinspclc_update_ini(nrn                in payaccinspclc.rn%type
                                                          ,ncompany           in companies.rn%type
                                                          ,nprn               in payaccinspclc.prn%type
                                                          ,sdepord            out ins_department.code%type
                                                          ,speriod            out varchar2
                                                          ,sfp_type           out varchar2
                                                          ,sbudj_code         out varchar2
                                                          ,scost_article      out varchar2
                                                          ,sbudj_art_nmb      out varchar2
                                                          ,sfaceaccount       out varchar2
                                                          ,salloc_art_nmb     in out varchar2
                                                          ,salloc_name        out varchar2
                                                          ,nquant_plan        in out number
                                                          ,nsum_plan          in out number
                                                          ,finplan_rn         out number
                                                          ,finplan_arts_rn    out number
                                                          ,allocation_sp_rn   in out number
                                                          ,sbudj_code_enb     out number /*Доступность изменения поля Бюджет*/
                                                          ,sbudj_art_nmb_enb  out number /*Доступность статьи бюджета */
                                                          ,scost_article_enb  out number /* Доступность статьи затрат */
                                                          ,salloc_art_nmb_enb out number /* Доступность уточненной статьи */
                                                          ,limit_year         out number
                                                          ,salloc_art_nmb_clr out varchar2 /*Цвет поля подстатья */
                                                          ,is_allc_art_nmb    out number /* Обязательность поля подстатья */
                                                          ,cost_year          out number
                                                          ,balance_year       out number
                                                          ,is_ok              out number
                                                          ,err_txt            out varchar2 /*Сообщение об ошибке*/) is

  payin_nrn payaccin.rn%type;
  --- ps_price      payaccinspec.price%type;
  payin_faceacc payaccin.faceacc%type;
  ndelta_s      number(17, 2);
  ndelta_q      number(17, 3);

begin

  /*if user = 'GOR' then P_exception(0,nsum_plan); end; */

  /*Найдем RN счета */
  select ps.prn
    into payin_nrn
    from payaccinspec ps
   where ps.rn = nprn;

  begin
    /* select bj.fp_code
         ,dt.doccode
         ,sz.code
         ,bjs.art_numb
         ,ep.code
         ,bj.rn
         ,bjs.rn
     into sbudj_code
         ,sfp_type
         ,scost_article
         ,sbudj_art_nmb
         ,speriod
         ,finplan_rn
         ,finplan_arts_rn
     from udo_t_finplan_arts bjs
     join udo_t_finplan bj
       on bj.rn = bjs.prn
     join doctypes dt
       on dt.rn = bj.fp_type
     left join fpdartcl sz
       on sz.rn = bjs.fpdartcl
     join enperiod ep
       on ep.rn = bj.fp_period
       
    
    where bjs.rn = usr_pkg_docs_props_vals.get_val_num(sprop_code => 'RN_СТР_БЮДЖЕТ'
                                                      ,sunitcode  => 'PaymentAccountsInSpecsCalcs'
                                                      ,ndocument  => nrn);*/
  
    select bj.fp_code
          ,dt.doccode
          ,sz.code
          ,bjs.art_numb
          ,ep.code
          ,bj.rn
          ,bjs.rn
          ,dep.code
          ,cld.alloc_arts
      into sbudj_code
          ,sfp_type
          ,scost_article
          ,sbudj_art_nmb
          ,speriod
          ,finplan_rn
          ,finplan_arts_rn
          ,sdepord
          ,allocation_sp_rn
      from usr_tab_calc_detail cld /*Привязка калькуляции к строке бюджетного распределения */
      join usr_t_alloc_arts brs
        on brs.rn = cld.alloc_arts
      join udo_t_finplan_arts bjs
        on bjs.rn = brs.finplan_arts
      join udo_t_finplan bj
        on bj.rn = bjs.prn
      join doctypes dt
        on dt.rn = bj.fp_type
      left join fpdartcl sz
        on sz.rn = bjs.fpdartcl
      join enperiod ep
        on ep.rn = bj.fp_period
      join ins_department dep
        on dep.rn = bj.depord
    
     where cld.prn = nrn;
  
  exception
    when no_data_found then
      /* Это старая калькуляция, в которой бюджет еще не привязан*/
      sfp_type := 'БДДСП_подр';
      
      sbudj_art_nmb:= usr_pkg_docs_props_vals.get_val_str(sPROP_CODE => 'Подстатья', sunitcode => 'PaymentAccountsInSpecsCalcs', nDOCUMENT => nrn);
    
      /*Определим бюджет исходя из состава затрат (если состав затрат однозначно определяет бюджет)*/
    
     /* usr_p_payaccinspclc_finpl_def(nrn             => payin_nrn
                                   ,ncompany        => ncompany
                                   ,speriod         => speriod
                                   ,sbudj_code      => sbudj_code
                                   ,finplan_rn      => finplan_rn
                                   ,sdepord         => sdepord
                                   ,sbudj_art_nmb   => sbudj_art_nmb
                                   ,finplan_arts_rn => finplan_arts_rn
                                   ,payin_faceacc   => payin_faceacc);*/
    
  end;


  
  
  
/*Проверить нужно ли нам это свойство, когда наладим восстановление данных после перезагрузки распределения! */
  allocation_sp_rn := COALESCE (allocation_sp_rn,  usr_pkg_docs_props_vals.get_val_num(sprop_code => 'RN_СТР_РАСПРЕД'
                                                         ,sunitcode  => 'PaymentAccountsInSpecsCalcs'
                                                         ,ndocument  => nrn));
  ----if user = 'PARUS' then P_exception(0,'allocation_sp_rn --> '||allocation_sp_rn); end if;

  if allocation_sp_rn is not null
  then
    begin
      select f.numb
            ,brs.art_numb
            ,brs.name
        into sfaceaccount
            ,salloc_art_nmb
            ,salloc_name
        from usr_t_alloc_arts brs
        left join faceacc f
          on f.rn = brs.prjst_faceacc
       where brs.rn = allocation_sp_rn;
    exception
      when no_data_found then
        salloc_art_nmb := null;
    end;
  
  end if;

  select nvl(sdepord, dep.code)
        ,pc.quant_plan
        ,nvl(pc.cost_plan * pc.quant_plan, 0)
        ,nvl(sfaceaccount, f.numb) /* Если лицевого счет нет в бюджетном распределении, то берем его из калькуляции */
        ,nvl(sz.code, scost_article)
    into sdepord
        ,nquant_plan
        ,nsum_plan
        ,sfaceaccount
        ,scost_article
    from payaccinspclc pc
    left join ins_department dep
      on dep.rn = pc.subdiv
    left join faceacc f
      on f.rn = pc.faceaccount
    left join fpdartcl sz
      on sz.rn = pc.cost_article
   where pc.rn = nrn;

  ---if user = 'GOR' then P_exception(0, nquant_plan); end if;

  /* Если период не задан в калькуляции, заведено по старому алгоритму, то берем из счета */
  if speriod is null
  then
  
    begin
      select per.code
        into speriod
        from payaccinspec ps
        join payaccin p
          on p.rn = ps.prn
        join enperiod per
          on p.doc_date between per.startdate and per.enddate
       where ps.rn = nprn
         and per.pertype = 3
         and per.enddate - per.startdate > 360
         and per.code != 'Произвольный период'
         and rownum = 1;
    
    exception
      when no_data_found then
        speriod := null;
    end;
  
  end if;

  if sbudj_code is null
  then
    /*Поробуем найти бюджет по парметрам */
    begin
      select t.fp_code
            ,t.rn
        into sbudj_code
            ,finplan_rn
        from udo_t_finplan t
        join enperiod en
          on en.rn = t.fp_period
        join ins_department dep
          on dep.rn = t.depord
       where en.code = speriod
         and dep.code = sdepord
         and t.fp_type = 6336511 /*БДДСП_подр*/
         and t.groupbudg = 6419333 /*ПЛАН*/
         and rownum = 1;
    exception
      when no_data_found then
        sbudj_code := null;
    end;
  end if;

  /* 
  Если подстатья не задана, а статья распределения задана, то проверим, что возможно только одна подстатья и 
  если это так, то подставим ее */

  if allocation_sp_rn is null
     and finplan_arts_rn is not null
  then
  
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
  
  end if;

  /* if user = 'GOR'
     and nrn = 261686174
  then
    p_exception(0, '223 ' || salloc_art_nmb||' '||allocation_sp_rn);
  end if;*/

  /* Доступность полей */
  if speriod is null
     or sdepord is null
  then
    sbudj_code_enb := 0;
  else
    sbudj_code_enb := 1;
  end if;

  /* Если не задан бюджет, то статью задать нельзя */
  if sbudj_code is null
  
  /**/
  
  then
    sbudj_art_nmb_enb := 0;
  else
    sbudj_art_nmb_enb := 1;
  end if;

  /* Если не задана статья бюджета, то статью затрат нужно задать вручную */
  if sbudj_art_nmb is null
  then
    scost_article_enb := 1;
  else
    scost_article_enb := 0;
  end if;

  /*Уточненную статью можно выбрать только если они есть у статьи бюджета*/
  begin
  
    select 1
      into salloc_art_nmb_enb
      from usr_t_alloc_arts t
     where t.finplan_arts = finplan_arts_rn
       and rownum = 1;
  exception
    when no_data_found then
      salloc_art_nmb_enb := 0;
    
  end;

  /*Рассчитаем Димиты, исполнение, остаток */
  /* if salloc_art_nmb is null
  then
  
    limit_year   := usr_f_finplan_art_limit(finplan_arts_rn, 0);
   
    balance_year := limit_year - cost_year;
  
  else*/

  limit_year   := usr_f_alloc_art_limit(allocation_sp_rn, 0);
  cost_year    := usr_f_payaccin_cost_sum(allocation_sp_rn);
  balance_year := limit_year - cost_year;

  /* Рассчитаем сумму и количество по калькуляции */

  with sq as
   (select t.quant       q
          ,t.summwithnds s
      from payaccinspec t
     where t.rn = nprn
    
    union all
    /*Определяем через plan, т.к. факта может не быть*/
    select -cl.quant_plan q
          ,-cl.cost_plan * cl.quant_plan s
      from payaccinspclc cl
     where cl.prn = nprn)
  
  select sum(sq.s)
        ,sum(sq.q)
    into ndelta_s
        ,ndelta_q
    from sq;

  nsum_plan   := nsum_plan + ndelta_s;
  nquant_plan := nquant_plan + ndelta_q;

  /* Обязательность заполнения подстатьи */

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

  if salloc_art_nmb is not null
  then
    salloc_art_nmb_clr := '16777215'; /* белый цвет */
    is_allc_art_nmb    := 0;
  end if;

  if sbudj_art_nmb is null
  then
    salloc_art_nmb_enb := 0;
    is_allc_art_nmb    := 0;
    salloc_art_nmb_clr := '-2147483645'; /*Серый цвет*/
  
  end if;

  is_ok   := 1;
  err_txt := null;

  /* Если лицевого (Заказ) счета нет, попробуем его определить
  Если введен лицевой счет не из этапа проекта, обнулим его
  
   */
  --- usr_p_payaccinspclc_prfc_get(nrn => nrn, ncompany => ncompany, sfaceacc_shpz => sfaceaccount);

end;
/
