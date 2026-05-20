create or replace procedure USR_P_ROLES_COPY_UNITPRIV
/*
Раздел: "Роли"
Процедура: Копирование всех прав от одной роли другой.
29/01/2024 Степанов М.
*/
(
 nRN            in number     /* Роль-приёмник. RN*/
,nCOMPANY       in number     
,sROLE_FROM     in varchar2   /* Роль-источник. Наименование */
,nPURGE_TO      in number     /* Удалить права у роли-приёмника (0 - нет, 1 - да) */
)
is
  nRoleFrom     pkg_std.tref;
  sCompany      pkg_std.tstring;
begin
  /* Организация. Наименование */
  sCompany := get_company_fullname(nflag_smart => 0, ncompany => nCOMPANY);

  /* Роль-источник. RN */
  find_roles_by_name(nflag_smart => 0, srolename => sROLE_FROM, nrn => nRoleFrom);

  /* По разделам, назначенным роли-источнику */
  for c in (
            select *
              from v_roleunits_assign
             where nrole    = nRoleFrom
               and ncompany = nCOMPANY
               and nassign  is not null
           )
  loop
    /* Копирование прав на раздел */
    p_roles_copy_unitpriv(nrn           => nRN
                         ,nident        => null
                         ,srole_from    => sROLE_FROM
                         ,sunitname     => c.sunitname
                         ,scompany_from => sCompany
                         ,scompany_to   => sCompany
                         ,npurge_to     => nPURGE_TO);
  end loop;

end USR_P_ROLES_COPY_UNITPRIV;
/
