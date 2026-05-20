create or replace procedure usr_p_alloc_arts_detail_b_ins(ncompany      in number
                                                         ,nfaceacc      in number
                                                         ,speriod_code  in varchar2
                                                         ,alloc_art_nmb in varchar2
                                                         ,sshpz         in varchar2
                                                         ,SBUDJ_CODE    in varchar2
                                                         ,snote         in varchar2
                                                         ,nrn           out number) is

  rec usr_t_alloc_arts_detail%rowtype; --Куда пишем

begin

  /*Городецкий 20-11-2025 Добавление строки Бюджетное распределение Детализация подстатьи */

  nrn               := gen_id;
  rec.rn            := nrn;
  rec.company       := ncompany;
  rec.faceacc       := nfaceacc;
  rec.period_code   := speriod_code;
  rec.alloc_art_nmb := alloc_art_nmb;
  rec.shpz          := sshpz;
  rec.note          := snote;
  rec.finplan_code  := SBUDJ_CODE;

  insert into usr_t_alloc_arts_detail values rec;

end;
/
