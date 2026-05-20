create or replace procedure usr_p_finplan_arts_imp_ext1_s3(pin_com     in number
                                                          ,brn         in number
                                                          ,out_err_txt out varchar2
                                                           
                                                           ) is

  v_ncrn usr_t_budget_allocation.crn%type; /*2026*/
  v_scat varchar2(240);

  nfl       integer;
  nrn       usr_t_budget_allocation.rn%type;
  v_nbrs_rn usr_t_alloc_arts.rn%type;

begin

  v_scat := pkg_options.get_options_str(scode => 'Budget_AllocatioN_Catalog', ncomp_vers => pin_com);

  if v_scat is null
  then
    out_err_txt := 'Обязательно задайте параметр № 100510  (Каталог бюджетного распределения). Файд--> Сервис --> Параметры --> Бюджетное распределение ';
  end if;

  begin
    select a.rn
      into v_ncrn
      from acatalog a
     where a.name = v_scat
       and a.docname = 'BUDGET_ALLOCATION'
       and a.company = pin_com;
  
  exception
    when no_data_found then
      out_err_txt := 'Каталог ' || v_scat || ', заданный в значении парметра № 100510 (Каталог бюджетного распределения), не найден в разделе "Бюджетное рспределение".';
    
  end;

  /* Если статья не имеет уточняющей, то в распределение ее заносим c индексом  _1*/

  begin
    for cur in (select substr(t.art_numb
                             ,1
                             ,case instr(t.art_numb, '_')
                                when 0 then
                                 100
                                else
                                 instr(t.art_numb, '_') - 1
                              end) art
                  from usr_t_finplan_arts_imp_ext1 t
                 where t.sauthid = utilizer
                 group by substr(t.art_numb
                                ,1
                                ,case instr(t.art_numb, '_')
                                   when 0 then
                                    100
                                   else
                                    instr(t.art_numb, '_') - 1
                                 end)
                having count(t.art_numb) = 1)
    
    loop
    
      update usr_t_finplan_arts_imp_ext1 t
         set t.art_numb = cur.art || '_1'
       where t.art_numb = cur.art
         and t.sauthid = utilizer;
    
    end loop;
  
  end;

  -- Проверим, что есть ненулевые суммы по уточняющим статьям
  begin
    select 1
      into nfl
      from usr_t_finplan_arts_imp_ext1 t
     where t.sauthid = utilizer
       and instr(t.art_numb, '_') > 0
          /*and (t.mes_01 != 0 or t.mes_02 != 0 or t.mes_03 != 0 or t.mes_04 != 0 or t.mes_05 != 0 or t.mes_06 != 0 or t.mes_07 != 0 or
          t.mes_08 != 0 or t.mes_09 != 0 or t.mes_10 != 0 or t.mes_11 != 0 or t.mes_12 != 0)*/
       and rownum = 1;
  exception
    when no_data_found then
      out_err_txt := 'Уточняющих строк нет.';
      return; /*Уточняющих строк нет*/
  
  end;

  /* Проверим, что уточняющие распределение создано, если нет то заведем */

  begin
    select ba.rn
      into nrn
      from usr_t_budget_allocation ba
     where ba.finplan = brn;
  
    ---out_err_txt := '61 '||to_char(brn); return;
  
  exception
    when no_data_found then
    
      begin
      
        for b in (select j.code         jur_code
                        ,t.fp_code
                        ,gb.smark_mnemo groupbudg
                        ,t.fp_vers
                    from udo_t_finplan t
                    join dicsmrks gb
                      on gb.rn = t.groupbudg
                    join jurpersons j
                      on j.rn = t.jur_pers
                   where t.rn = brn)
        loop
        
          usr_p_budget_alloc_insert(ncompany    => pin_com
                                   ,nfinplan_rn => brn
                                   ,sjur_pers   => b.jur_code
                                   ,ncrn        => v_ncrn
                                   ,doc_code    => 'БР'
                                   ,sdedpcode   => null /*В данном случае определяется brn - бюджетом к которому делаем распределение */
                                   ,ddocdate    => sysdate
                                   ,sfp_code    => b.fp_code
                                   ,sgroupbudg  => b.groupbudg
                                   ,nfp_vers    => b.fp_vers
                                   ,nrn         => nrn);
        
        end loop;
      
      end;
    
  end;

  ---  p_exception(0,'Процедура на реконструкции');

  /* Создадим строки в бюджетном распределении ЕСЛИМ ЕЕ не было! */

  for vl in (select t.art_numb
                   ,substr(t.art_numb, 1, instr(t.art_numb, '_') - 1) art
                   ,substr(t.art_numb, instr(t.art_numb, '_') + 1) nmb
                   ,t.name
                   ,t.mes_01
                   ,t.mes_02
                   ,t.mes_03
                   ,t.mes_04
                   ,t.mes_05
                   ,t.mes_06
                   ,t.mes_07
                   ,t.mes_08
                   ,t.mes_09
                   ,t.mes_10
                   ,t.mes_11
                   ,t.mes_12
                   ,t.type_production
                   ,t.division_using
                   ,t.purpose_product
                   ,t.quant
                   ,t.accept_period
                   ,t.request
                   ,t.analog
                   ,t.shpz
               from usr_t_finplan_arts_imp_ext1 t
              where t.sauthid = utilizer
                and instr(t.art_numb, '_') > 0
                and t.name is not null
             
             /*and (t.mes_01 != 0 or t.mes_02 != 0 or t.mes_03 != 0 or t.mes_04 != 0 or t.mes_05 != 0 or t.mes_06 != 0 or t.mes_07 != 0 or
             t.mes_08 != 0 or t.mes_09 != 0 or t.mes_10 != 0 or t.mes_11 != 0 or t.mes_12 != 0)*/
             
             )
  
  loop
  
    /* Найдем строку в бюджетном распределении  */
    nfl := 0; /*Признак заведения новой строки спецификации распредленеия*/
    begin
    
      select bjs.rn
        into v_nbrs_rn
        from usr_t_alloc_arts brs
        join udo_t_finplan_arts bjs
          on bjs.rn = brs.finplan_arts
       where brs.prn = nrn
         and bjs.art_numb = vl.art
         and brs.art_numb = vl.nmb
         and bjs.prn = brn;
    
    exception
      when no_data_found then
        /*Если НЕ нашли, то создадим ее */
      
        nfl := 1;
      
        usr_p_alloc_arts_insert(nprn             => nrn
                               ,ncompany         => pin_com
                               ,nfinrn           => brn
                               ,sfinplan_arts    => vl.art
                               ,art_numb         => vl.nmb
                               ,sname            => vl.name
                               ,snote            => null
                               ,sfaceacc_cost    => vl.art || '/' || vl.nmb
                               ,stype_production => vl.type_production
                               ,sdivision_using  => vl.division_using
                               ,spurpose_product => vl.purpose_product
                               ,nquant           => nvl(vl.quant, 0)
                               ,soei_code        => 'шт'
                               ,pin_spz          => vl.shpz
                               ,saccept_period   => vl.accept_period
                               ,srequest         => vl.request
                               ,sanalog          => vl.analog
                               ,nrn              => v_nbrs_rn);
      
    end;
  
    if nfl = 0
    then
    
      usr_p_alloc_arts_update(nrn => v_nbrs_rn 
                              ,ncompany => pin_com 
                              ,sname => vl.name 
                              ,snote => null 
                              ,pin_spz => vl.shpz 
                              ,sfaceacc_cost => vl.art || '/' || vl.nmb 
                              ,nart_numb => vl.nmb
                               ,stype_production  => vl.type_production
                               ,sdivision_using  => vl.division_using
                               ,spurpose_product => vl.purpose_product
                               ,nquant           => nvl(vl.quant, 0)
                               ,soei_code        => 'шт'
                               ,saccept_period    => vl.accept_period
                               ,srequest         => vl.request
                               ,sanalog          => vl.analog
                              );
    
    end if;
  
    /* Запишем помесячные значения в бюджетном распределении */
  
    if vl.mes_01 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_01
       where t.prn = v_nbrs_rn
         and t.numb = 1;
    end if;
  
    if vl.mes_02 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_02
       where t.prn = v_nbrs_rn
         and t.numb = 2;
    end if;
  
    if vl.mes_03 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_03
       where t.prn = v_nbrs_rn
         and t.numb = 3;
    end if;
  
    if vl.mes_04 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_04
       where t.prn = v_nbrs_rn
         and t.numb = 4;
    end if;
  
    if vl.mes_05 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_05
       where t.prn = v_nbrs_rn
         and t.numb = 5;
    end if;
  
    if vl.mes_06 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_06
       where t.prn = v_nbrs_rn
         and t.numb = 6;
    end if;
  
    if vl.mes_07 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_07
       where t.prn = v_nbrs_rn
         and t.numb = 7;
    end if;
  
    if vl.mes_08 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_08
       where t.prn = v_nbrs_rn
         and t.numb = 8;
    end if;
  
    if vl.mes_09 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_09
       where t.prn = v_nbrs_rn
         and t.numb = 9;
    end if;
  
    if vl.mes_10 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_10
       where t.prn = v_nbrs_rn
         and t.numb = 10;
    end if;
  
    if vl.mes_11 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_11
       where t.prn = v_nbrs_rn
         and t.numb = 11;
    end if;
  
    if vl.mes_12 != 0
    then
      update usr_t_alloc_arts_v t
         set t.val = vl.mes_12
       where t.prn = v_nbrs_rn
         and t.numb = 12;
    end if;
  
  end loop;

  /*Пересчитаем исполнение бюджета, рапределение по которому загрузили */
 usr_p_alloc_arts_v_ispoln_br(pin_doc => nrn);

end;
/
