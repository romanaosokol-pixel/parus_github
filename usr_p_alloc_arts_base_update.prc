create or replace procedure usr_p_alloc_arts_base_update(nrn              in number /*RN Распределения/Статьи. */
                                                        ,sname            in varchar2 /* Наименование расширенной статьи */
                                                        ,snote            in varchar2 /* Примечание расширенной статьи */
                                                        ,nfaceacc_cost    in number /*Лицевой счет затрат*/
                                                        ,nart_numb        in number /*Номер уточняющей статьи*/
                                                        ,out_nspz         in number /* Лицеврой счет этапа проекта*/
                                                        ,stype_production in varchar2
                                                        ,sdivision_using  in varchar2
                                                        ,spurpose_product in varchar2
                                                        ,nquant           in number
                                                        ,noei             in number
                                                        ,saccept_period   in varchar2
                                                        ,srequest         in varchar2
                                                        ,sanalog          in varchar2
                                                         
                                                         ) is
begin

  /*Городецкий 20-11-2025 Исправление строки бюджетного распределения */

  update usr_t_alloc_arts t
     set t.name          = sname
        ,t.note          = snote
        ,t.faceacc_cost  = nfaceacc_cost
        ,t.art_numb      = nart_numb
        ,t.prjst_faceacc = out_nspz
        ,T.TYPE_PRODUCTION = stype_production
        ,T.DIVISION_USING = sdivision_using
        ,T.PURPOSE_PRODUCT = spurpose_product
        ,T.QUANT = nquant
        ,T.OEI = noei
        ,T.ACCEPT_PERIOD = saccept_period
        ,T.REQUEST = srequest
        ,T.ANALOG = sanalog
         
   where t.rn = nrn;

end;
/
