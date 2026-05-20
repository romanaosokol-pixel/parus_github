create or replace procedure usr_p_user_roles_ini
(
  pin_doc    in userlist.rn%type
 ,suser_name out userlist.name%type
) is

begin

  select max(ul.authid) into suser_name from userlist ul where ul.rn = pin_doc;

end;
/
