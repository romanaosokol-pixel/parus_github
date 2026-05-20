create or replace procedure usr_p_alloc_arts_det_join(ncompany          in companies.rn%type
                                                     ,sfaceacc          in faceacc.numb%type
                                                     ,sfaceacc_cost_nmb in faceacc.numb%type
                                                     ,sbudg_rn          in udo_t_finplan.rn%type
                                                     ,sbudg_art_code    in udo_t_finplan_arts.code%type
                                                     ,sproject_stage_fc in faceacc.numb%type /*Лицевой счет этапа проекта */
                                                     ,nfinplan_arts     out udo_t_finplan_arts.rn%type
                                                     ,nfaceacc          out faceacc.rn%type
                                                     ,nfaceacc_cost_rn  out faceacc.rn%type
                                                     ,nprojectstage     out projectstage.rn%type

                                                      ) is

  /*

  Городецкий 08-04-2026
  Процедура разрешений ссылок для действий в разделе "(Бюджетное распределение Детализация подстатьи)"

  */

begin

  if sfaceacc is not null
  then
    begin

      /*Найдем лицевой счет */
      select f.rn
        into nfaceacc
        from faceacc f
       where f.numb = sfaceacc
         and f.company = ncompany;
    exception
      when no_data_found then
        p_exception(0
                   ,'Лицевой счет с номером %s не найден. Выберите корректное значение через словарь.'
                   ,sfaceacc);
    end;

  end if;

  begin

    /*Найдем лицевой счет */
    select f.rn
      into nfaceacc_cost_rn
      from faceacc f
     where f.numb = sfaceacc_cost_nmb
       and f.company = ncompany;
  exception
    when no_data_found then
      p_exception(0
                 ,'Лицевой счет с номером %s не найден. Выберите корректное значение через словарь.'
                 ,sfaceacc);
  end;

  /* Найдем RN строки статьи бюджета */

  begin
    select bjs.rn bjs_rn
      into nfinplan_arts
      from udo_t_finplan_arts bjs
     where bjs.code = sbudg_art_code
       and bjs.prn = sbudg_rn;
  exception
    when no_data_found then
      p_exception(0
                 ,'Cтрока бюджета с кодом %s не найдена. Выберте корректное значение через словарь.'
                 ,sbudg_art_code);
  end;

  /*Если задан ШПЗ */

  if sproject_stage_fc is not null
  then
    begin
      select ps.rn
        into nprojectstage
        from faceacc f
        join projectstage ps
          on ps.faceacc = f.rn
       where f.numb = sproject_stage_fc
         and f.company = ncompany;

    exception
      when no_data_found then
        p_exception(0
                   ,'Этап проекта с дицевым счетом %s не найден. Выберте корректное значение через словарь.'
                   ,sproject_stage_fc);
    end;

  end if;

end;
/
