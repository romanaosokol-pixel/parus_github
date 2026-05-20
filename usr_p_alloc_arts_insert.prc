create or replace procedure usr_p_alloc_arts_insert(nprn             in number /*RN Распределения */
                                                   ,ncompany         in number
                                                   ,nfinrn           in number /*RN Бюджета*/
                                                   ,sfinplan_arts    in varchar2 /*Номер статьи бюджета которую уточняем */
                                                   ,art_numb         in number /* Номер подстатьи */
                                                   ,sname            in varchar2 /* Наименование расширенной статьи */
                                                   ,snote            in varchar2 /* Примечание расширенной статьи */
                                                   ,sfaceacc_cost    in varchar2 /* Номер Лицевого счета затрат */
                                                   ,stype_production in varchar2 /* Вид производства (просто текст)*/
                                                   ,sdivision_using  in varchar2 /* Пользователь, кто будет использовать*/
                                                   ,spurpose_product in varchar2 /* Назначение*/
                                                   ,nquant           in number /* Планируемое количество*/
                                                   ,soei_code        in varchar2 /* Ед.Изм.*/
                                                   ,saccept_period   in varchar2 /*Срок ввода*/
                                                   ,srequest         in varchar2 /* Заявка */
                                                   ,sanalog          in varchar2 /* Аналог */
                                                   ,pin_SPZ          in varchar2 /* ШПЗ лицевой счет этапа проекта */                                                   
                                                   ,nrn              out number) is

  nfinplan_arts udo_t_finplan_arts.rn%type;
  nfaceacc_cost usr_t_alloc_arts.faceacc_cost%type;
  noei          dicmunts.rn%type;
  out_nspz      projectstage.faceacc%type;

begin

  /*Городецкий 20-11-2025 Добавление строки бюджетного распределения */

  usr_p_alloc_arts_join(nfinplan      => nfinrn
                       ,ncompany      => ncompany
                       ,sfinplan_arts => sfinplan_arts
                       ,sfaceacc      => sfaceacc_cost
                       ,soei_code     => nvl(soei_code, 'шт')
                       ,pin_spz => pin_SPZ
                       ,nfinplan_arts => nfinplan_arts
                       ,nfaceacc      => nfaceacc_cost
                       ,noei          => noei
                       ,out_nspz => out_nspz);

  usr_p_alloc_arts_base_insert(nprn             => nprn
                              ,finplan_arts     => nfinplan_arts
                              ,art_numb         => art_numb
                              ,sname            => sname
                              ,snote            => snote
                              ,nfaceacc_cost    => nfaceacc_cost
                              ,stype_production => stype_production
                              ,sdivision_using  => sdivision_using
                              ,spurpose_product => spurpose_product
                              ,nquant           => nquant
                              ,noei             => noei
                              ,saccept_period   => saccept_period
                              ,srequest         => srequest
                              ,sanalog          => sanalog
                              ,out_nspz => out_nspz
                              ,nrn              => nrn);
end;
/
