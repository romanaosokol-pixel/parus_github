create or replace procedure usr_p_payaccinspclc_chk1(nrn payaccin.rn%type) is

  /* Проверка калькуляции на этапе утверждения счета
  по всем его строкам спецификации
  */

  ---declare  := 262385194;

  n_fl  number(1) := 1;
  s_n   dicnomns.nomen_code%type;
  n_q   payaccinspec.factquant%type;
  n_s   payaccinspec.summwithnds%type;
  ps_rn payaccinspec.rn%type;
  is_sm number(1);
  s_cat acatalog.name%type;

begin

  /* 1.Проверка наличия калькуляции при задании статьи затрат в лицевом счете.
  Логику наличия состава затрат в лицевом счете проверяем на этапе создания счета
  */
  begin
    select 0
          ,dn.nomen_code
          ,ps.quant
          ,ps.summwithnds
          ,ps.rn
          ,udo_f_payaccin_is_sm(nrn) /*Признак смета в статье затрат, заданной в лицевом счете*/
          ,ac.name
      into n_fl
          ,s_n
          ,n_q
          ,n_s
          ,ps_rn
          ,is_sm
          ,s_cat
      from payaccin p
      join payaccinspec ps
        on ps.prn = p.rn
      join dicnomns dn
        on dn.rn = ps.nomen
      join acatalog ac
        on ac.rn = p.crn
    
     where p.rn = nrn
       and not exists (select 1
              from payaccinspclc cl
             where cl.prn = ps.rn)
       and rownum = 1;
  exception
    when no_data_found then
      n_fl := 1;
  end;

  if is_sm = 1
  then
    p_exception(n_fl
               ,'В счете задана сметная статья затрат, поэтому обязательно задайте в спецификации счета калькуляцию.' || cr ||
                'Не задана в строке спецификации счета RN = %s, код номенклатуры %s, кол-во %s, Сумма %s'
               ,ps_rn
               ,s_n
               ,n_q
               ,n_s);
  end if;

  if s_cat = 'Служба ГИ'
  then
  
    p_exception(0
               ,'В счетах, заводимых в каталоге "Служба ГИ" задание калькуляции строки спецификации счета обязательно.' || cr ||
                'Не задана в строке спецификации счета RN = %s, код номенклатуры %s, кол-во %s, Сумма %s'
               ,ps_rn
               ,s_n
               ,n_q
               ,n_s);
  
  end if;

  /*2. Проверяем что задана статья бюджета и подстатья (если она нужна)*/

  begin
  
    for cur in (select f.numb
                      ,usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 260664294
                                                          ,sunitcode => 'PaymentAccountsInSpecsCalcs'
                                                          ,ndocument => cl.rn) rn_budj_art
                      ,usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 260630987
                                                          ,sunitcode => 'PaymentAccountsInSpecsCalcs'
                                                          ,ndocument => cl.rn) rn_alloc_art
                      ,dn.nomen_code
                      ,ps.quant
                      ,ps.summwithnds
                       /*Возможно контролировать нужно по совпадению свойства состава затрат "Приход/расход напрвление" */
                      ,szc.code szc_code /*Код статьи затрат калькуляции*/
                      ,dp.code dp_code
                      ,dс.code dc_code
                      ,ac.name cat_name
                      ,szp.code szp_code /* Статья затрат лицевого счета  самого Счета */
                      ,cl.faceaccount cl_faceaccount /* RN лицевого счета затрат (лицевого счета этапа проекта) */
                      ,f.numb cl_face_cost_nmb /* Номер лицевого счета затрат калькуляции */
                      ,cl.rn cl_rn
                      ,ps.rn ps_rn
                      ,p.rn p_rn
                      ,sum(round(cl.cost_fact * cl.quant_fact,2)) over(partition  by ps.rn) s_cl
                      ,sum(cl.quant_fact) over(partition  by ps.rn) q_cl
                     
                
                  from payaccin p
                  join payaccinspec ps
                    on ps.prn = p.rn
                  join dicnomns dn
                    on dn.rn = ps.nomen
                  join payaccinspclc cl
                    on cl.prn = ps.rn
                  left join faceacc f /* Лицевого счета затрат калькуляции может не быть, если счет не связан с проектом*/
                    on f.rn = cl.faceaccount
                  join faceacc fp
                    on fp.rn = p.faceacc
                  join fpdartcl szp /*Статья затрат лицевого счета счета должна быть! */
                    on szp.rn = fp.ieelement
                  left join fpdartcl szc
                    on szc.rn = cl.cost_article
                  left join diciearts dp
                    on dp.rn = szp.iearticle
                  left join diciearts dс
                    on dс.rn = szc.iearticle
                  join acatalog ac
                    on ac.rn = p.crn
                
                 where p.rn = nrn
                
                --- and udo_f_payaccin_faceacc_article(p.rn) is not null /**/
                
                )
    
    loop
    
      /*Сумма по всем строкам калькуляции не равна сумме счета */
    
      if cur.s_cl != cur.summwithnds
      then
        p_exception(0
                   ,'Сумма по всем строкам спецификации счета (Сумма счета) %s не равна сумме по всем строкам калькуляции счета %s. Исправьте калькуляции строк спецификации счета'
                   ,cur.summwithnds
                   ,cur.s_cl);
      end if;
    
      /* Суммарное количество по всем строкам счета не равно суммарному количеству по всем строкам спецификации */
    
      if cur.q_cl != cur.quant
      then
        p_exception(0
                   ,'Суммарное количество по всем строкам спецификации счета  %s не равнo суммарному количеству по всем строкам калькуляции счета %s. Исправьте калькуляции строк спецификации счета'
                   ,cur.quant
                   ,cur.q_cl);
      end if;
    
      /*  Статьи калькуляции в составе затрат Личевого счета счета и составе затрат калькуляции должны совпадать */
      if cmp_vc2(cur.dc_code, cur.dp_code) = 0
      then
      
        p_exception(0
                   ,'Направление статьи калькуляции состава затрат лицевого счета "%s" должно совпадать с направлением ' ||
                    'состава затрат калькуляции "%s". Выберите корректное значение статьи и подстатьи бюджета в калькуляции!'
                   ,cur.dp_code
                   ,cur.dc_code);
      
      end if;
    
      /*Если каталог счета ОХД или Калькуляция, то статья затрат лицевого счета не должна заканчиваеться на _Б*/
    
      if cur.cat_name in ('ОХД', 'Калькуляция')
         and substr(cur.szc_code, -2, 2) != '_Б'
      then
      
        p_exception(0
                   ,'Для счетов, созданных в каталоге %s статья затрта должна заканчиваться на "_Б", а задана статья затрат %s.' ||
                    'Выберите корректное значение статьи и подстатьи бюджета в калькуляции!');
      
      end if;
    
      if cur.rn_budj_art is null --and utilizer != 'KHOK'
      then
        /* Задание статьи бюджета */
        p_exception(0
                   ,'В калькуляции спецификации счета задан бюджет, но не задана статья. Задайте статью бюджета.' || cr ||
                    'Не задано в строке спецификации счета RN = %s, код номенклатуры %s, кол-во %s, Сумма %s'
                   ,cur.ps_rn
                   ,cur.nomen_code
                   ,cur.quant
                   ,cur.summwithnds);
      
      else
        /* Проверяем наличие подстатьи, если статья разбивается на подстатьи */
      
        if ust_f_art_is_allocation(cur.rn_budj_art) = 1
           and cur.rn_alloc_art is null
        then
        
          p_exception(0
                     ,'Статья бюджета, заданная в калькуляции спецификации счете подразумевает разбиение на подстатьи. Задайте подстатью.' || cr ||
                      'Не задано в строке спецификации счета RN = %s, код номенклатуры %s, кол-во %s, Сумма %s'
                     ,cur.ps_rn
                     ,cur.nomen_code
                     ,cur.quant
                     ,cur.summwithnds);
        
        end if;
      
      end if;
      /* Лицевой счёт калькуляции заканчивается на "/77" и статья затрат НЕ "Покупка КИП", "ПриобрПрОборуд" */
      if (nvl(cur.cl_face_cost_nmb, 'null') like '%/77' or nvl(cur.cl_face_cost_nmb, 'null') like '%/77-1' or
         nvl(cur.cl_face_cost_nmb, 'null') like '%/77-2')
         and cur.szc_code not in ('Покупка КИП', 'ПриобрПрОборуд')
      then
        p_exception(0
                   ,'В калькуляции, в поле "Статья затрат", указана статья <%s> (%s), которую запрещено использовать для "Лицевого счёта (заказа)" <%s>.%s%s%s'
                   ,cur.szc_code
                   ,cur.cl_face_cost_nmb
                   ,cr || cr || f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => cur.cl_rn)
                   ,cr || cr || f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => cur.ps_rn)
                   ,cr || cr || f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => cur.p_rn));
      
      end if;
      /* 3 Проверяем, что если Статья затрат оканчивается на _Б, То задание Лицевого счета затрат обязательно 
      Необходимость данной проверки, несмотря на аналогичный контроль при заведении  калькуляции проверяется, 
      но иногда калькуляция заводится не через штаное добавление */
    
      /*Если статья затрат ЛС оканчивается на Б, то задание лицевой счет (затрат) лицевой счет этапа проекта. обязательно */
      if regexp_like(cur.szc_code, '\w_Б$')
      then
      
        if cur.cl_faceaccount is null
        then
          p_exception(0
                     ,'В калькуляции: Статья затрат - %s оканчивается на "_Б", поэтому обязательно задайте в лицевой счет (затрат) лицевой счет этапа проекта.'
                     ,cur.szc_code);
        
        else
          /*Если Лицевой счет затрат задан и статья затарат оканчивается на _Б, то лицевой счет затрат должен состоять из 5 цифр и хотя бы одной не цифры*/
        
          if not regexp_like(cur.cl_face_cost_nmb, '^\d{5}\D+') /*5 цифр и минимум одна не цифра */
             and not (cur.cl_face_cost_nmb like ('1672%') or cur.cl_face_cost_nmb = '10220000' or cur.cl_face_cost_nmb = '20220000') /* Это лицевые счета исключение */
          then
          
            p_exception(0
                       ,'3 Статья затрат (%s) оканчивается на _Б, следовательно номер лицевого счета затрат должен состоять из 5 цифр и хотя бы одного нецифрового символа и быть лицевым счетом этапа проета, а вы задали лицевой счет затрат %s'
                       ,cur.szc_code
                       ,cur.cl_face_cost_nmb);
          
          end if;
        
        end if;
      
      else
        /*Если статья затрат не заканчивается на _Б и лицевой счет задан, то номер лицевого счета не должен состоять из 5 цифр и любого количества не цифровых символов */
        if cur.cl_faceaccount is not null
           and regexp_like(cur.cl_face_cost_nmb, '^[[:digit:]]{5}[[:alpha:]].*')
        then
        
          p_exception(0
                     ,'Статья затрат (%s) НЕ оканчивается на _Б, следовательно номер лицевого счета затрат НЕ должен состоять из 5 цифр и хотя бы одного нецифрового символа и быть лицевым счетом этапа проета, а вы задали лицевой счет затрат %s'
                     ,cur.szc_code
                     ,cur.cl_face_cost_nmb);
        
        end if;
      end if;
    
    end loop;
  
  end;

end;
/
