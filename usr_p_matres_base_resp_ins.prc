create or replace procedure usr_p_matres_resp_ins(ncompany        in number
                                                 ,scatalog        in varchar2 /* Наименование каталога */
                                                 ,smodif_code     in nommodif.modif_code%type /* Код модификации */
                                                 ,sresponsib_type in extra_dicts_values.str_value%type /*Код Типа ответсвенного */
                                                 ,sresponsib_agn  in agnlist.agnabbr%type /* Мнемокод контрагента ответсвенного */
                                                 ,ddate_beg       in date
                                                 ,ddate_end       in date
                                                 ,snote           in varchar2
                                                 ,nrn             out number) is

  rec usr_tab_matres_response%rowtype; --Куда пишем

begin

  usr_p_matres_resp_join(ncompany        => ncompany
                        ,smodif_code     => smodif_code
                        ,scatalog        => scatalog
                        ,sresponsib_type => sresponsib_type
                        ,sresponsib_agn  => sresponsib_agn
                         /*----*/
                        ,nmr_rn          => rec.prn
                        ,ncrn            => rec.crn
                        ,nresponsib_type => rec.response_type
                        ,nresponsib_agn  => rec.response_agn);

  usr_p_matres_base_resp_ins(ncompany       => rec.company
                            ,nprn           => rec.prn
                            ,ncrn           => rec.crn
                            ,nresponse_type => rec.response_type
                            ,nresponse_agn  => rec.response_agn
                            ,ddate_beg      => ddate_beg
                            ,ddate_end      => ddate_end
                            ,snote          => snote
                            ,nrn            => nrn);

end;
/
