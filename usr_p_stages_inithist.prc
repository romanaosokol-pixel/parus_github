create or replace procedure usr_p_stages_inithist
/*
Раздел: Договоры (этапы)
Процедур: Корректировка истории исполнения лицевого счёта этапа
07/07/2025 Степанов М.
create public synonym usr_p_stages_inithist for usr_p_stages_inithist;
*/
(
 nCOMPANY   in number
,nIDENT     in number
)
is
  nNumber   pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_STAGES_INITHIST');

  /* По отмеченным этапам */
  for c in ( select t.faceacc
               from selectlist  sl
                   ,stages      t
              where sl.ident  = nIDENT
                and t.rn      = sl.document )
  loop
    /* Добавляем в selectlist лицевые счета отмеченных этапов с другим IDENT */
    p_selectlist_insert( nident    => nCOMPANY
                        ,ndocument => c.faceacc
                        ,sunitcode => 'FaceAccounts'
                        ,nrn       => nNumber );
  end loop;

  /* Корректировка лицевых счетов с IDENT отмеченных лицевых счетов */
  usr_pkg_faceacc.faceacc_inithist( ncompany => nCOMPANY, nident => nCOMPANY );

  /* Очистка selectlist отмеченных лицевых счетов */
  p_selectlist_clear( nident => nCOMPANY );

  /* Закрываем процесс */
  usr_pkg_process.process_close;
exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
