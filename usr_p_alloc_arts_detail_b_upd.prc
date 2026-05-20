create or replace procedure usr_p_alloc_arts_detail_b_upd(nrn in number
                                                          /* ,nfaceacc      in number*/
                                                         ,speriod_code  in varchar2
                                                         ,alloc_art_nmb in varchar2
                                                         ,sshpz         in varchar2
                                                         ,snote         in varchar2) is

begin

  /*Городецкий 20-11-2025 Исправление строки Бюджетное распределение Детализация подстатьи */

  update usr_t_alloc_arts_detail t
     set t.period_code   = speriod_code
        ,t.alloc_art_nmb = alloc_art_nmb
        ,t.shpz          = sshpz
        ,t.note          = snote
   where t.rn = nrn;

end;
/
