create or replace procedure USR_P_USERS_OPTIONS_COPY
/*
Пользователи. Копирование всех настроек от пользователя текущему
20/12/2023 Степанов М.
*/
(
 nRN           in number
,sNAME_FROM    in varchar2
)
is
 sName_To    pkg_std.tstring; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_USERS_OPTIONS_COPY');

  /* Имя текущего пользователя */
  sName_To := get_userlist_name_id(nflag_smart => 0, sauthid => get_userlist_authid_id(nflag_smart => 0, nrn => nRN));

  /* Копирование */
  p_userprofiles_copy(ssource_user    => sNAME_FROM
                     ,ssource_company => 'МОДУЛЬ'
                     ,susers          => sName_To
                     ,scompanies      => 'МОДУЛЬ'
                     ,sapps           => null
                     ,sunits          => null
                     ,nuse_privs      => 1
                     ,stypes          => null
                     ,skinds          => null);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_USERS_OPTIONS_COPY;
/
