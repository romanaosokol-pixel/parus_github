create or replace procedure usr_p_alloc_arts_det_b_ins(ncompany in number
                                                      ,nprn     in number
                                                      ,nfaceacc          in number
                                                      ,sfaceacc_cost_nmb in varchar2
                                                      ,nfinplan_arts     in number
                                                      ,nprojectstage     in number
                                                      ,nfaceacc_cost_rn  in number
                                                      ,snote             in varchar2
                                                      ,nrn               out number) is
  rec usr_t_alloc_arts_det%rowtype; --Куда пишем
begin
  /*Городецкий 08-04-2026 Добавление строки Бюджетное распределение Детализация подстатьи
    grant execute on usr_p_alloc_arts_det_b_ins to public;
  */
  nrn                  := gen_id_fix;
  rec.rn               := nrn;
  rec.prn              := nprn;
  rec.company          := ncompany;
  rec.faceacc          := nfaceacc;
  rec.faceacc_cost_nmb := sfaceacc_cost_nmb;
  rec.finplan_arts     := nfinplan_arts;
  rec.projectstage     := nprojectstage;
  rec.faceacc_cost_rn  := nfaceacc_cost_rn;
  rec.note             := snote;

  insert into usr_t_alloc_arts_det
  values rec;
end;
/
