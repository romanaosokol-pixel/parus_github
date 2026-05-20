create or replace procedure USR_P_SET_EXCEPTION_LIST
/*
Сохранить список исключений
02/20/2023 Степанов М.
*/
(
 sEXCEPTIONLIST   in varchar2
)
is
  bExistsAllRights  boolean := false;
begin
  /* Проверка наличия роли Все права */
  for c in (select null from userroles where authid = utilizer and roleid = 90519)
  loop
    bExistsAllRights := true;
    exit;
  end loop;
  /* Если нет роли Все права */
  if not bExistsAllRights then
    p_exception(0, 'У Вас нет прав на выполнение процедуры.');
  end if;

  /* Сохранение списка исключений */
  usr_pkg_pub_const.sexceptionlist := sEXCEPTIONLIST;

end USR_P_SET_EXCEPTION_LIST;
/
