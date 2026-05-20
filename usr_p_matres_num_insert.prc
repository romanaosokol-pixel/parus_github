create or replace procedure usr_p_matres_num_insert
(
  ncompany in number
 ,ncrn     in number
 ,snote    in varchar2
 ,nrn      in out number
) is

  /*Заведение группы сквозной нумерации заводских номеров материального ресурса */
begin

  /* размножение спецификации */
  if (nrn != -1)
  then
    p_exception(0
               ,'Не имеет смысла размножать Группу сквозной нумерации, т.к. Материальный ресурс может входить СТРОГО в одну группу.');
  end if;

  /* проверка прав доступа */
  pkg_env.prologue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_'
                  ,'MATRES_NUM_INSERT'
                  ,'USR_TAB_MATRES_NUMERATION');

  /* Базовое добавление */

  usr_p_matres_num_base_insert(ncompany => ncompany
                              ,ncrn     => ncrn
                              ,snote    => snote
                              ,nrn      => nrn);

  /* фиксация окончания выполнение действия */
  pkg_env.epilogue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_'
                  ,'MATRES_NUM_INSERT'
                  ,'USR_TAB_MATRES_NUMERATION'
                  ,nrn);

end;
/
