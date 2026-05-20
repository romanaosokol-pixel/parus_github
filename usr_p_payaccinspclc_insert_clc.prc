create or replace procedure usr_p_payaccinspclc_insert_clc(nrn                in number
                                                          ,nprn               in number
                                                          ,ncompany           in number
                                                          ,sprm               in varchar2
                                                          ,speriod            in out varchar2
                                                          ,sdepord            in out varchar2
                                                          ,sbudj_code         in out varchar2
                                                          ,finplan_arts_rn    in out number
                                                          ,allocation_sp_rn   in out number
                                                          ,sbudj_art_nmb      in varchar2
                                                          ,salloc_faceacc     in varchar2
                                                          ,sfaceaccount       in out varchar2
                                                          ,finplan_rn         in out number
                                                          ,scost_article      in out varchar2
                                                          ,salloc_art_nmb     in out varchar2
                                                          ,is_allc_art_nmb    out number
                                                          ,sbudj_code_enb     out number /*Доступность изменения поля Бюджет*/
                                                          ,sbudj_art_nmb_enb  out number /*Доступность статьи бюджета */
                                                          ,scost_article_enb  out number /* Доступность статьи затрат */
                                                          ,salloc_art_nmb_enb out number /* Доступность уточненной статьи */
                                                          ,salloc_art_nmb_clr out varchar2 /* Цвет поля уточненной статьи */
                                                          ,limit_year         out number /* Лимит за год (по статье бюджета или статье распределения */
                                                          ,cost_year          out number
                                                          ,balance_year       out number
                                                          ,is_ok              out number /* Доступность кнопки "ОК" */
                                                          ,err_txt            out varchar2 /*Сообщение об ошибке , если кнопка ОК недоступна */
                                                           
                                                           /*,sfaceaccount out varchar2
                                                                                                                                                                                                                                                                                                      ,NQUANT_FACT  out number
                                                                                                                                                                                                                                                                                                      ,NCOST_FACT_SUM out number*/) is

begin

  if sprm in ('SPERIOD', 'SDEPORD')
  then
    /* Сменили период или Отдел -- обнулили бюджет (найдем его ниже)*/
    sbudj_code := null;
  elsif sprm = 'SBUDJ_CODE'
  then
    begin
      select t.rn
        into finplan_rn
        from udo_t_finplan t
       where t.fp_code = sbudj_code
         and t.company = ncompany
         and rownum = 1;
    exception
      when no_data_found then
        finplan_rn     := null;
        sbudj_code     := null;
        salloc_art_nmb := null;
      
    end;
  
  elsif sprm = 'SBUDJ_ART_NMB'
  then
  
    /* При смене статьи обнуляем подстатью */
    salloc_art_nmb   := null;
    allocation_sp_rn := null;
  
    begin
      select sz.code 
        into scost_article 
        from udo_t_finplan_arts fa
        left join fpdartcl sz
          on sz.rn = fa.fpdartcl
      
       where fa.rn = finplan_arts_rn;
    
    exception
      when no_data_found then
        scost_article := null;
      
    end;
  
  end if;

  if finplan_arts_rn is null
  then
    is_allc_art_nmb := 0;
  else
  
    /*Проверим, */
    is_allc_art_nmb := 1;
  
  end if;

  /* Доступность полей */
  ---if user = 'GOR'  then P_exception(0,sbudj_code); end if;
  if speriod is null
     or sdepord is null
  then
    sbudj_code_enb := 0;
  else
    sbudj_code_enb := 1;
    /*Поробуем найти бюджет по парметрам */
  
    if sbudj_code is null
    then
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
        ;
      exception
        when no_data_found then
          sbudj_code := 'Выберите бюджет';
        when too_many_rows then
          sbudj_code := 'Выберите бюджет';
      end;
    end if;
  
  end if;

  /* Если не задан бюджет, то статью задать нельзя */
  if nvl(sbudj_code, 'Выберите бюджет') = 'Выберите бюджет'
  then
    sbudj_art_nmb_enb := 0;
  else
    sbudj_art_nmb_enb := 1;
  end if;

  scost_article_enb := 0;
  /*Уточненную статью можно выбрать только кесли они есть у статьи бюджета*/
  begin
  
    select 1
          , /*to_char(pkg_options.get_options_num(scode => 'RequeredColor', ncomp_vers => ncompany)) ---*/'65535' --желтый
      into salloc_art_nmb_enb
          ,salloc_art_nmb_clr
      from usr_t_alloc_arts t
     where t.finplan_arts = finplan_arts_rn
       and rownum = 1;
  exception
    when no_data_found then
      salloc_art_nmb_enb := 0;
      salloc_art_nmb_clr := '-2147483645';
    
  end;
  /*После заполнения поля возвращаем ему белый цвет */
  if salloc_art_nmb is not null
  then
    salloc_art_nmb_clr := '16777215'; /* белый цвет */
  end if;

  
    limit_year   := usr_f_alloc_art_limit(allocation_sp_rn, 0);
    cost_year    := usr_f_payaccin_cost_sum(allocation_sp_rn);
    balance_year := limit_year - cost_year;  
 

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
                   ', ему должен соответствовать лицевой счет (заказ), заданный в калькуляции (' || sfaceaccount ||
                   '). Измените лицевой счет затрат или подстатью. ';
      
      else
      
        is_ok   := 1;
        err_txt := null;
      
      end if;
      
     --- if user = 'GOR' then P_exception(0, sfaceaccount); end if;
      
    
    end loop;
  
  end;
is_ok   := 1;
end;
/
