create or replace procedure usr_p_alloc_arts_detail_upd_i(nrn           in number
                                                         ,sfaceacc      out varchar2
                                                         ,speriod_code  out varchar2
                                                         ,alloc_art_nmb out varchar2
                                                         ,sshpz         out varchar2
                                                         ,snote         out varchar2
                                                         ,sfinplan_code out varchar2) is

begin

  /*Городецкий 20-11-2025 Исправление строки Бюджетное распределение Детализация подстатьи */

  select f.numb
        ,t.period_code
        ,t.alloc_art_nmb
        ,t.shpz
        ,t.note
        ,t.finplan_code
    into sfaceacc
        ,speriod_code
        ,alloc_art_nmb
        ,sshpz
        ,snote
        ,sfinplan_code
    from usr_t_alloc_arts_detail t
    join faceacc f
      on f.rn = t.faceacc
   where t.rn = nrn;



end;
/
