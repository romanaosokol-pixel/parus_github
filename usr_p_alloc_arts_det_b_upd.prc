create or replace procedure usr_p_alloc_arts_det_b_upd(nrn               in number
                                                      ,nfaceacc          in number
                                                      ,sfaceacc_cost_nmb in varchar2
                                                      ,nfinplan_arts     in number
                                                      ,nprojectstage     in number
                                                      ,nfaceacc_cost_rn  in number
                                                      ,snote             in varchar2) is
  rec usr_t_alloc_arts_det%rowtype; --Куда пишем
begin
  /*
  Городецкий 12-05-2026 Исправление строки Бюджетное распределение Детализация подстатьи
  */

  update usr_t_alloc_arts_det t
     set t.faceacc          = nfaceacc
        ,t.faceacc_cost_nmb = sfaceacc_cost_nmb
        ,t.finplan_arts     = nfinplan_arts
        ,t.projectstage     = nprojectstage
        ,t.note             = snote
        ,t.faceacc_cost_rn  = nfaceacc_cost_rn
   where t.rn = nrn;
end;
/
