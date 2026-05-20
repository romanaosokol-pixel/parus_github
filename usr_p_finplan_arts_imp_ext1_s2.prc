create or replace procedure usr_p_finplan_arts_imp_ext1_s2(brn in udo_t_finplan.rn%type
                                                          ,out_err_txt out varchar2
                                                           
                                                           ) is

begin
  /* Шаг записи бюджета */

  out_err_txt := ';';
  /* Проверим, что все статьи из файла есть в бюджете в который загружаем */
  for err in (with imp as
                 (select substr(t.art_numb
                              ,1
                              ,case instr(t.art_numb, '_')
                                 when 0 then
                                  100
                                 else
                                  instr(t.art_numb, '_') - 1
                               end) art_numb
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
                 having sum(t.mes_01 + t.mes_02 + t.mes_03 + t.mes_04 + t.mes_05 + t.mes_06 + t.mes_07 + t.mes_08 + t.mes_09 + t.mes_10 + t.mes_11 + t.mes_12) != 0),
                
                art as
                 (select t.rn
                       ,t.art_numb
                   from udo_t_finplan_arts t
                  where t.prn = brn)
                
                select imp.art_numb
                      ,art.rn
                  from imp
                  left join art
                    on art.art_numb = imp.art_numb
                
                 where art.rn is null)
  loop
  
    out_err_txt := out_err_txt || ';' || err.art_numb;
  
  end loop;

  if out_err_txt != ';'
  then
  
    out_err_txt := 'В бюджете, в которой загружаем данные, нет статeй с кодом ' || substr(out_err_txt, 3) ||
                   ', но они есть в файле загрузки!.';
    return; /* Выходим с сообщением обошибке */
  
  end if;

  out_err_txt := null;

  for v in (with imp as
               (select substr(t.art_numb
                            ,1
                            ,case instr(t.art_numb, '_')
                               when 0 then
                                100
                               else
                                instr(t.art_numb, '_') - 1
                             end) art_numb
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
               
               /*having sum(t.mes_01 + t.mes_02 + t.mes_03 + t.mes_04 + t.mes_05 + t.mes_06 + t.mes_07 + t.mes_08 + t.mes_09 + t.mes_10 + t.mes_11 + t.mes_12) != 0*/
               ),
              
              art as
               (select t.rn
                     ,t.art_numb
                 from udo_t_finplan_arts t
                where t.prn = brn)
              
              select imp.art_numb
                    ,art.rn
                    ,sum(imp.mes_01) mes_01
                    ,sum(imp.mes_02) mes_02
                    ,sum(imp.mes_03) mes_03
                    ,sum(imp.mes_04) mes_04
                    ,sum(imp.mes_05) mes_05
                    ,sum(imp.mes_06) mes_06
                    ,sum(imp.mes_07) mes_07
                    ,sum(imp.mes_08) mes_08
                    ,sum(imp.mes_09) mes_09
                    ,sum(imp.mes_10) mes_10
                    ,sum(imp.mes_11) mes_11
                    ,sum(imp.mes_12) mes_12
                from imp
                join art
                  on art.art_numb = imp.art_numb
               group by imp.art_numb
                       ,art.rn)
  loop
  
    /*Обновим строки помесячных значений бюджетов */
  
    if v.mes_01 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_01
       where vt.prn = v.rn
         and vt.numb = 1;
    end if;
  
    if v.mes_02 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_02
       where vt.prn = v.rn
         and vt.numb = 2;
    end if;
  
    if v.mes_03 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_03
       where vt.prn = v.rn
         and vt.numb = 3;
    end if;
  
    if v.mes_04 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_04
       where vt.prn = v.rn
         and vt.numb = 4;
    end if;
  
    if v.mes_05 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_05
       where vt.prn = v.rn
         and vt.numb = 5;
    end if;
  
    if v.mes_06 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_06
       where vt.prn = v.rn
         and vt.numb = 6;
    end if;
  
    if v.mes_07 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_07
       where vt.prn = v.rn
         and vt.numb = 7;
    end if;
  
    if v.mes_08 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_08
       where vt.prn = v.rn
         and vt.numb = 8;
    end if;
  
    if v.mes_09 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_09
       where vt.prn = v.rn
         and vt.numb = 9;
    end if;
  
    if v.mes_10 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_10
       where vt.prn = v.rn
         and vt.numb = 10;
    end if;
  
    if v.mes_11 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_11
       where vt.prn = v.rn
         and vt.numb = 11;
    end if;
  
    if v.mes_12 != 0
    then
      update udo_t_finplan_arts_v vt
         set vt.val = v.mes_12
       where vt.prn = v.rn
         and vt.numb = 12;
    end if;
  
  end loop;

  /*Пересчитаем зависимые статьи */
  udo_p_finplan_recalc(nrn => brn);

end;
/
