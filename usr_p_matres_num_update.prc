create or replace procedure usr_p_matres_num_update
(
  nrn      in number
 ,ncrn     in number
 ,ncompany in number
 ,snote    in varchar2
) is

  /*”даление группы сквозной нумерации заводских номеров материального ресурса */
begin

  /* проверка прав доступа */

  pkg_env.prologue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_'
                  ,'MATRES_NUM_UPDATE'
                  ,'USR_TAB_MATRES_NUMERATION'
                  ,nrn);

  /* Ѕазовое исправление (≈сли внесли изменени€)*/

  for cur in (select 1
                from usr_tab_matres_numeration t
               where t.rn = nrn
                 and (nvl(t.note
                         ,' ') != snote)
                  or t.crn != ncrn)
  loop
  
    usr_p_matres_num_base_update(nrn   => nrn
                                ,ncrn  => ncrn
                                ,snote => snote);
  
  end loop;

  /* фиксаци€ окончани€ выполнение действи€ */
  pkg_env.epilogue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_'
                  ,'MATRES_NUM_UPDATE'
                  ,'USR_TAB_MATRES_NUMERATION'
                  ,nrn);

end;
/
