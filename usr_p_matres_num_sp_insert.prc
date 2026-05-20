create or replace procedure usr_p_matres_num_sp_insert
(
  nprn     in number
 ,ncompany in number
 ,ncrn     in number
 ,smatres  in varchar2
 ,smodif   in varchar2
 ,snote    in varchar2
 ,nrn      in out number
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
                  ,'MATRES_NUM_SP_INSERT'
                  ,'USR_TAB_MATRES_NUMERATION_SP');

  if (nrn != -1)
  then
    p_exception(0
               ,'–азмножение не реализовано');

  else

    usr_p_matres_num_sp_bs_insert(nprn     => nprn
                                 ,ncompany => ncompany
                                 ,ncrn     => ncrn
                                 ,nmatres  => nmatres
                                 ,nmodif   => nmodif
                                 ,snote    => snote
                                 ,nrn      => nrn);

  end if;

  pkg_env.epilogue(ncompany
                  ,null
                  ,ncrn
                  ,'USR_MATRES_NUMERATION_SP'
                  ,'MATRES_NUM_SP_INSERT'
                  ,'USR_TAB_MATRES_NUMERATION_SP'
                  ,nrn);

end;
/
