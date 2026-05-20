create or replace procedure usr_p_alloc_arts_detail_upd(ncompany          in number
                                                       ,sfaceacc          in faceacc.numb%type /*В таблице ссылка */
                                                       ,sfaceacc_cost_nmb in varchar2 /* Подстатья */
                                                       ,sbudg_rn          in number /* RN бюджета (Вычислим на форме) */
                                                       ,sbudg_art_code    in varchar2 /* Код Статья бюджета */
                                                       ,sproject_stage_fc in varchar2 /* Лицевой счет этапа проекта*/
                                                       ,snote             in varchar2 /* Примечание */
                                                       ,nrn               out number) as
  nfaceacc         faceacc.rn%type;
  nfaceacc_cost_rn faceacc.rn%type;
  nfinplan_arts    udo_t_finplan_arts.rn%type;
  nprojectstage    projectstage.rn%type;
begin
  /*
  Городецкий 12-05-2026  Исправление в разделе (Бюджетное распределение Детализация подстатьи)*/

  if sfaceacc is null
     and sproject_stage_fc is null
  then
    p_exception(0
               ,'Лицевой счет или лицевой счет Этапа проекта должны быть заданы, иначе непонятно что привязываем!');
  end if;
  /* Разрешение ссылок */
  usr_p_alloc_arts_det_join(ncompany          => ncompany
                           ,sfaceacc          => sfaceacc
                           ,sfaceacc_cost_nmb => sfaceacc_cost_nmb
                           ,sbudg_rn          => sbudg_rn
                           ,sbudg_art_code    => sbudg_art_code
                           ,sproject_stage_fc => sproject_stage_fc
                           ,nfinplan_arts     => nfinplan_arts
                           ,nfaceacc_cost_rn  => nfaceacc_cost_rn
                           ,nfaceacc          => nfaceacc
                           ,nprojectstage     => nprojectstage);
  /* Базовая процедура Исправления */
  usr_p_alloc_arts_det_b_upd(nrn              => nrn
                            ,nfaceacc          => nfaceacc
                            ,sfaceacc_cost_nmb => sfaceacc_cost_nmb
                            ,nfinplan_arts     => nfinplan_arts
                            ,nprojectstage     => nprojectstage
                            ,nfaceacc_cost_rn  => nfaceacc_cost_rn
                            ,snote             => snote);
end;
/
