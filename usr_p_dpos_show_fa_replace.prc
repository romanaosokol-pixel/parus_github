create or replace procedure usr_p_dpos_show_fa_replace
/*
Раздел: Заказы подразделений (спецификация)
Процедура: Показать переносы между темами
26/12/2023 Степанов М.
create public synonym usr_p_dpos_show_fa_replace for usr_p_dpos_show_fa_replace;
grant execute on usr_p_dpos_show_fa_replace to public;
*/
(
 nRN            in number
,sRESULT        out varchar2
)
is
begin
  for c in (select listagg(trim(sdoc), cr) within group (order by sdoc) as sdoc
              from (select distinct f_docdescrs_get_description(sunitcode => 'UdoFaceAccountReplace', ndocument => t.rn) as sdoc
                      from departmentords dpos
                          ,departmentord  dpo
                          ,(
                            select far.rn, gp.nommodif 
                              from udo_faceacc_replace      far
                                  ,udo_faceacc_replace_sp   fars
                                  ,goodsparties             gp
                             where far.rn       = fars.prn
                               and far.state    in (0, 1) /* Состояние (0 - новый, 1 - согласован, 2 - отработан в учете, 3 - Не согласовано) */
                               and fars.gparty  = gp.rn
                           ) t
                     where dpos.rn        = nRN
                       and dpo.rn         = dpos.prn
                       and dpos.nom_modif = t.nommodif ))
  loop
    sRESULT := c.sdoc;
  end loop;

/*  for c in (select listagg(trim(sdoc), cr) within group (order by sdoc) as sdoc
              from (select distinct f_docdescrs_get_description(sunitcode => 'UdoFaceAccountReplace', ndocument => t.rn) as sdoc
                      from departmentords dpos
                          ,departmentord  dpo
                          ,(
                            select far.rn, pjs.prn as pjs_prn, gp.nommodif 
                              from udo_faceacc_replace      far
                                  ,udo_faceacc_replace_sp   fars
                                  ,goodsparties             gp
                                  ,projectstage             pjs
                             where far.rn           = fars.prn
                               and far.state        in (0, 1) \* Состояние (0 - новый, 1 - согласован, 2 - отработан в учете, 3 - Не согласовано) *\
                               and fars.gparty      = gp.rn
                               and far.faceacc_from = pjs.faceacc
                            union
                            select far.rn, pjs.prn as pjs_prn, gp.nommodif 
                              from udo_faceacc_replace      far
                                  ,udo_faceacc_replace_sp   fars
                                  ,goodsparties             gp
                                  ,projectstage             pjs
                             where far.rn         = fars.prn
                               and far.state      in (0, 1) \* Состояние (0 - новый, 1 - согласован, 2 - отработан в учете, 3 - Не согласовано) *\
                               and fars.gparty    = gp.rn
                               and far.faceacc_to = pjs.faceacc
                           ) t
                     where dpos.rn        = nRN
                       and dpo.rn         = dpos.prn
                       and dpos.nom_modif = t.nommodif 
                       and t.pjs_prn      = usr_pkg_project.project_get_rn_by_faceacc(nflagsmart => 1, nfaceacc => dpo.faceacc)
                       ))
  loop
    sRESULT := c.sdoc;
  end loop;
*/

end;
/
