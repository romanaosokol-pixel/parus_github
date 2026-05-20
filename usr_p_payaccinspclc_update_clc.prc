create or replace procedure usr_p_payaccinspclc_update_clc(nrn                in payaccinspclc.rn%type
                                                          ,sprm               in varchar2
                                                          ,ncompany           in number
                                                          ,sdepord            in out ins_department.code%type
                                                          ,speriod            in out varchar2
                                                          ,sfp_type           in out varchar2
                                                          ,sbudj_code         in out varchar2
                                                          ,scost_article      in out varchar2
                                                          ,sbudj_art_nmb      in out varchar2
                                                          ,sfaceaccount       in out varchar2
                                                          ,salloc_art_nmb     in out varchar2
                                                          ,salloc_name        in out varchar2
                                                          ,nquant_plan        in out number
                                                          ,nsum_plan          in out number
                                                          ,finplan_rn         in out number
                                                          ,finplan_arts_rn    in out number
                                                          ,allocation_sp_rn   in out number
                                                          ,is_allc_art_nmb    out number /*Обязательность поля подстатья*/
                                                          ,sbudj_code_enb     out number /*Доступность изменения поля Бюджет*/
                                                          ,sbudj_art_nmb_enb  out number /*Доступность статьи бюджета */
                                                          ,scost_article_enb  out number /* Доступность статьи затрат */
                                                          ,salloc_art_nmb_enb out number /* Доступность уточненной статьи */
                                                          ,salloc_art_nmb_clr out varchar2 /* Цвет поля уточненной статьи */
                                                          ,limit_year         in out number /* Лимит за год (по статье бюджета или статье распределения */
                                                          ,cost_year          out number
                                                          ,balance_year       out number
                                                          ,is_ok              out number
                                                          ,err_txt            out varchar2) is

begin

  --p_exception(0, sprm);
  if sprm in ('SDEPORD', 'SPERIOD')
  then
    /* Если изменили отдел, то все сбрасывем, кроме периода */
  
    sbudj_code    := null;
    scost_article := null;
    sbudj_art_nmb := null;
    ---sfaceaccount     := null;
    salloc_art_nmb   := null;
    salloc_name      := null;
    finplan_rn       := null;
    finplan_arts_rn  := null;
    allocation_sp_rn := null;
  
  elsif sprm = 'SBUDJ_CODE'
  then
  
    /* Если изменили бюджет, то все сбрасываем, кроме отдела и периода, при необходимости обновляем RN бюджета */
    begin
      select bj.rn
        into finplan_rn
        from udo_t_finplan bj
        join doctypes dt
          on dt.rn = bj.fp_type
       where bj.fp_code = sbudj_code
         and dt.doccode = sfp_type;
    
    exception
      when others then
        sbudj_code := null;
      
    end;
  
    scost_article := null;
    sbudj_art_nmb := null;
    --sfaceaccount     := null;
    salloc_art_nmb   := null;
    salloc_name      := null;
    finplan_arts_rn  := null;
    allocation_sp_rn := null;
  
  elsif sprm = 'SBUDJ_ART_NMB'
  then
  
    salloc_art_nmb := null;
    salloc_name    := null;
    scost_article  := null;
    ---    finplan_arts_rn  := null;
    allocation_sp_rn := null;
  
    /* Если подстатья SALLOC_ART_NMB у статьи единственная, то сразу ее выбираем */
  
    begin
    
      select brs.art_numb
            ,brs.name
            ,brs.rn
            ,sz.code
        into salloc_art_nmb
            ,salloc_name
            ,allocation_sp_rn
            ,scost_article
        from usr_t_alloc_arts brs
        join udo_t_finplan_arts bjs
          on bjs.rn = brs.finplan_arts
        left join fpdartcl sz
          on sz.rn = bjs.fpdartcl
       where brs.finplan_arts = finplan_arts_rn;
    
    exception
      when others then
        salloc_art_nmb   := null;
        salloc_name      := null;
        allocation_sp_rn := null;
        scost_article    := null;
      
    end;
  
    if finplan_arts_rn is not null /*Статья задана */
    then
      begin
        select bjs.name
              ,sz.code
          into salloc_name
              ,scost_article
          from udo_t_finplan_arts bjs
          left join fpdartcl sz
            on sz.rn = bjs.fpdartcl
         where bjs.rn = finplan_arts_rn;
      
      exception
        when no_data_found then
          salloc_name   := null;
          scost_article := null;
      end;
    end if;
  
  end if;

 

  /* Доступность полей */

  if speriod is null
     or sdepord is null
  then
    sbudj_code_enb := 0;
  else
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
        sbudj_code := 'Выберите бюджет';
      when too_many_rows then
        sbudj_code := 'Выберите бюджет';
    end;
    sbudj_code_enb := 1;
  end if;

  /* Если не задан бюджет, то статью задать нельзя */
  if nvl(sbudj_code, 'Выберите бюджет') = 'Выберите бюджет'
  then
    sbudj_art_nmb_enb := 0;
  else
    sbudj_art_nmb_enb := 1;
  end if;

  scost_article_enb := 0;

  begin
  
    select 1
          , /*to_char(pkg_options.get_options_num(scode => 'RequeredColor', ncomp_vers => ncompany)) ---*/'65535'
      into salloc_art_nmb_enb
          ,salloc_art_nmb_clr
      from usr_t_alloc_arts t
     where t.finplan_arts = finplan_arts_rn
       and rownum = 1;
  exception
    when no_data_found then
      salloc_art_nmb_enb := 0;
      salloc_art_nmb_clr := '-2147483645'; /*Серый цвет*/
  
  end;

  if salloc_art_nmb is not null
  then
    salloc_art_nmb_clr := '16777215'; /* белый цвет */
  end if;

  if sbudj_art_nmb is null
  then
    salloc_art_nmb_enb := 0;
    salloc_art_nmb_clr := '-2147483645'; /*Серый цвет*/
  
  end if;

  /* Если в подстатье задано ШПЗ, то надо проверить, что Лицевой счет заказ соответствует ШПЗ  */

  begin
    for cur in (select spz.numb spz_nmb
                  from payaccinspclc cl
                  left join faceacc f
                    on f.rn = cl.faceaccount
                  left join usr_t_alloc_arts bsp
                    on bsp.rn = allocation_sp_rn
                  left join faceacc spz
                    on spz.rn = bsp.prjst_faceacc
                
                 where cl.rn = nrn)
    loop
    
      if (sfaceaccount is not null and cur.spz_nmb is not null)
         and cmp_vc2(sfaceaccount, cur.spz_nmb) = 0
      then
      
        is_ok   := 0;
        err_txt := 'У Подстатьи ' || salloc_art_nmb || ' в бюджетном распределении задано ШПЗ ' || cur.spz_nmb ||
                   ', ему должен соответствовать лицевой счет затрат, заданный в калькуляции (' || sfaceaccount ||
                   '). Измените лицевой счет (заказ) или подстатью. ';
      
      else
      
        is_ok   := 1;
        err_txt := null;
      
      end if;
    
    end loop;
  
  end;
  
   if allocation_sp_rn is null
  then
    is_allc_art_nmb := 0;  
  else
    is_allc_art_nmb := 1;  
  end if;
  
  limit_year   := usr_f_alloc_art_limit(allocation_sp_rn, 0);
  cost_year    := usr_f_payaccin_cost_sum(allocation_sp_rn);
  balance_year := limit_year - cost_year;
  

end;
/
