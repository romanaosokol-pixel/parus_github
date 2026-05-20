create or replace procedure USR_P_USER_ROLES_COPY
/*
Раздел: "Пользователи"
Процедура: Копирование назначенных ролей от другого пользователя.
08/04/2024 Степанов М.
*/
(
 nCOMPANY       in number    
,nRN            in number     /* Пользователь-приёмник. RN*/
,sUSER_FROM     in varchar2   /* Пользователь-источник. Наименование */
,nPURGE_TO      in number     /* Удалить роли у пользователя-приёмника (0 - нет, 1 - да) */
)
is
  sUserToAuthID     pkg_std.tstring;
  cRoles            clob;
  nPers_Agent       pkg_std.tref; 
  rAgnList          agnlist%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_USER_ROLES_COPY');

  /* Пользователь-приёмник. AuthID */
  sUserToAuthID := get_userlist_authid_id(nflag_smart => 0, nrn => nRN);

  /* Добавление пользователей в текст письма */
  cRoles := cr||'Пользователь от кого: '||sUSER_FROM;
  cRoles := strcombine(cRoles, sUserToAuthID, cr||'Пользователь кому: ');

  /* Если удалить роли у рользователя-приёмника */
  if cmp_num(nPURGE_TO, 1) = 1 then
    /* по назначенным ролям */
    for c in (
              select nrole
                from v_userroles_assign
               where sauthid = sUserToAuthID
                 and nassign is not null
             )
    loop
      /* удаление */
      p_userroles_unlink(nroleid => c.nrole, sauthid => sUserToAuthID);
    end loop;
  end if;

  /* По разделам ролям пользователя источника */
  for c in (
            select nrole, srolename
              from v_userroles_assign
             where sauthid = sUSER_FROM
               and nassign is not null
           )
  loop
    /* Назначение приёмнику */
    p_userroles_link(nroleid => c.nrole, sauthid => sUserToAuthID);
    /* Сохранение имени роли */
    cRoles := strcombine(cRoles, c.srolename, cr);
  end loop;

  /* Контрагент текущего пользователя */
  find_clnpersons_authid_ex(ncompany     => nCOMPANY
                           ,ddate        => current_date
                           ,spers_authid => utilizer
                           ,npers_agent  => nPers_Agent);

  /* Считывание контрагента текущего пользователя */
  rAgnList := usr_pkg_agnlist.agnlist_get(nrn => nPers_Agent);

  /* Если адрес указан */
  if rAgnList.mail is not null then
    /* отправка письма */
    pkg_exs_ext_mail.send_by_list(sto_list => rAgnList.mail
                                 ,stitle   => 'Список назначенных ролей в результате выполнения процедуры USR_P_USER_ROLES_COPY'
                                 ,ctext    => cRoles
                                 ,nformat => pkg_exs_ext_mail.nformat_text);
  /* Если адрес НЕ указан */
  else
    p_exception(0, 'Не найден эл.адрес текущего пользователя. Пользователь: %s, Контрагент: %s'
               ,utilizer
               ,nvl(rAgnList.agnabbr, 'Не задан')); 
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_USER_ROLES_COPY;
/
