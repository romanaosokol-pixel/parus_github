create or replace procedure usr_p_alloc_arts_base_insert(nprn             in number
                                                        ,finplan_arts     in number /*Ссылка на статью бюджета которую уточняем */
                                                        ,art_numb         in number /* Номер подстатьи */
                                                        ,sname            in varchar2 /* Наименование расширенной статьи */
                                                        ,snote            in varchar2 /* Примечание расширенной статьи */
                                                        ,nfaceacc_cost    in number /* RN  Лицевого счета затрат */
                                                        ,stype_production in varchar2 /* Вид производства (просто текст)*/
                                                        ,sdivision_using  in varchar2 /* Пользователь, кто будет использовать*/
                                                        ,spurpose_product in varchar2 /* Назначение*/
                                                        ,nquant           in number /* Планируемое количество*/
                                                        ,noei             in number
                                                        ,saccept_period   in varchar2 /*Срок ввода*/
                                                        ,srequest         in varchar2 /* Заявка */
                                                        ,sanalog          in varchar2 /* Аналог */
                                                        ,out_nspz         in number /* ШПЗ Лицевой счет этапа проекта*/
                                                        ,nrn              out number) is

  rec usr_t_alloc_arts%rowtype; --Куда пишем

begin

  /*Городецкий 20-11-2025 Добавление строки бюджетногораспределения */

  nrn                 := gen_id;
  rec.rn              := nrn;
  rec.prn             := nprn;
  rec.finplan_arts    := finplan_arts;
  rec.art_numb        := art_numb;
  rec.name            := sname;
  rec.note            := snote;
  rec.faceacc_cost    := nfaceacc_cost;
  rec.type_production := stype_production;
  rec.division_using  := sdivision_using;
  rec.purpose_product := spurpose_product;
  rec.quant           := nquant;
  rec.oei             := noei;
  rec.accept_period   := saccept_period;
  rec.request         := srequest;
  rec.analog          := sanalog;
  rec.prjst_faceacc   :=out_nspz;
  
   insert into usr_t_alloc_arts values rec;

  /*Всегда создадём 12 пустых строк значений статьи */

  usr_p_budgall_sp_v_base_insert(nprn => nrn);

end;
/
