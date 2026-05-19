create or replace function usr_f_stages_prj_code(nfaceacc in stages.faceacc%type) return project.code%type is

  v_res project.code%type;

begin

  /* Код проекта для этапа договора 
  Городецкий 04-05-2026
  */

  for cur in (select distinct z.code
                from (
                      /*Основной договор проекта*/
                      select pr.code
                        from projectstage prs
                        join project pr
                          on pr.rn = prs.prn
                       where prs.faceacccust = nfaceacc
                      
                      union all
                      /*Исполнители этапа проекта */
                      select pr.code
                        from projectstagepf pre
                        join projectstage prs
                          on prs.rn = pre.prn
                        join project pr
                          on pr.rn = prs.prn
                       where pre.faceacc = nfaceacc) z)
  loop
  
    v_res := strcombine(sleft => v_res, sright => cur.code, sdelimeter => ';');
  
  end loop;

  return v_res;

end;
/
