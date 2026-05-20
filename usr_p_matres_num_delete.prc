create or replace procedure usr_p_matres_num_delete
(
  nrn      in number
 ,ncompany in number 
) is

  v_ncrn usr_tab_matres_numeration.crn%type;
  /*Удаление группы сквозной нумерации заводских номеров материального ресурса */
begin
/* CRN не передается */
  select t.crn into v_ncrn from usr_tab_matres_numeration t where t.rn = nrn;

  /* проверка прав доступа */
  pkg_env.prologue(ncompany
                  ,null
                  ,v_ncrn
                  ,'USR_MATRES_NUMERATION_'
                  ,'MATRES_NUM_DELETE'
                  ,'USR_TAB_MATRES_NUMERATION'
                  ,nrn);

  /* Базовое удаление */

  usr_p_matres_num_base_delete(nrn);

  /* фиксация окончания выполнение действия */
  pkg_env.epilogue(ncompany
                  ,null
                  ,v_ncrn
                  ,'USR_MATRES_NUMERATION_'
                  ,'MATRES_NUM_DELETE'
                  ,'USR_TAB_MATRES_NUMERATION'
                  ,nrn);

end;
/
