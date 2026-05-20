create or replace procedure usr_p_alloc_arts_update(nrn           in number /*RN Распределения/Статьи. */
                                                   ,ncompany      in number
                                                   ,sname         in varchar2 /* Наименование расширенной статьи */
                                                   ,snote         in varchar2 /* Примечание расширенной статьи */
                                                   ,pin_spz       in varchar2 /*ШПЗ Лицевой счет этапа проекта */
                                                   ,sfaceacc_cost in varchar2 /* Лицевой счет затрат */
                                                   ,nart_numb     in number /*Номер уточняющей статьи */
                                                   ,stype_production  in varchar2
                                                   ,sdivision_using  in varchar2
                                                   ,spurpose_product in varchar2
                                                   ,nquant           in number
                                                   ,soei_code        in varchar2
                                                   ,saccept_period   in varchar2
                                                   ,srequest         in varchar2
                                                   ,sanalog          in varchar2
                                                   ) is
  nfinplan_arts udo_t_finplan_arts.rn%type;
  nfaceacc_cost usr_t_alloc_arts.faceacc_cost%type;
  noei          dicmunts.rn%type;
  out_nspz      projectstage.faceacc%type;
begin
  /*Городецкий 20-11-2025 Исправление строки бюджетного распределения */

  usr_p_alloc_arts_join(nfinplan      => null
                       ,ncompany      => ncompany
                       ,sfinplan_arts => null
                       ,sfaceacc      => sfaceacc_cost
                       ,soei_code     => soei_code
                       ,pin_spz       => pin_spz
                       ,nfinplan_arts => nfinplan_arts
                       ,nfaceacc      => nfaceacc_cost
                       ,noei          => noei
                       ,out_nspz      => out_nspz);

  usr_p_alloc_arts_base_update(nrn           => nrn
                              ,sname         => sname
                              ,snote         => snote
                              ,nfaceacc_cost => nfaceacc_cost
                              ,nart_numb     => nart_numb
                              ,out_nspz      => out_nspz
                              ,stype_production   => stype_production 
                              ,sdivision_using    => sdivision_using  
                              ,spurpose_product   => spurpose_product 
                              ,nquant             => nquant           
                              ,noei               => noei             
                              ,saccept_period     => saccept_period   
                              ,srequest           => srequest         
                              ,sanalog            => sanalog  
                              );
end;
/
