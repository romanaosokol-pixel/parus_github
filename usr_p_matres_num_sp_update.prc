create or replace procedure usr_p_matres_num_sp_update
(
  nprn     in number
 ,ncompany in number
 ,ncrn     in number
 ,smatres  in varchar2
 ,smodif   in varchar2
 ,snote    in varchar2
 ,nrn      in number
) is
  /*«аведение состава группы сквозной нумерации заводских номеров материального ресурса */

  nmatres fcmatresource.rn%type;
  nmodif  nommodif.rn%type;

begin

  usr_p_matres_num_sp_join(ncompany => ncompany
                          ,smatres  => smatres
                          ,smodif   => smodif
                          ,nmatres  => nmatres
                          ,nmodif   => nmodif);

  /* проверка прав доступа */
  pkg_env.prologue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_SP'
                  ,'MATRES_NUM_SP_UPDATE'
                  ,'USR_TAB_MATRES_NUMERATION_SP'
                  ,nrn);

 /* Ѕазовое исправление (≈сли внесли изменени€)*/

  for cur in (select 1
                from USR_TAB_MATRES_NUMERATION_SP t
               where t.rn = nrn
                 and (nvl(t.note
                         ,' ') != snote)
                  or t.matres != nmatres)
  loop

   null;

  end loop;

  pkg_env.epilogue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_SP'
                  ,'MATRES_NUM_SP_UPDATE'
                  ,'USR_TAB_MATRES_NUMERATION_SP'
                  ,nrn);

end;
/
