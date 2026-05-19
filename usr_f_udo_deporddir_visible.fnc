create or replace function usr_f_udo_deporddir_visible(nrn udo_deporddir.rn%type,  sauthid userlist.authid%type default utilizer) return number as

  /*
  Оболочка для доп. usr_f_udo_deporddir_acces  
  Возвращает 0, если прав НЕТ , 1 - Если права есть
  
  Городецкий О.И.
  29-04-2025
  
  */
nfl number(1):=0;

begin
 /* Если пользователь задан как ответственный, то пусть видит */
begin
  select 1
  into nfl
 from udo_deporddir VZ
 join clnpersons CP on CP.PERS_AGENT = VZ.RESP_AGENT
where VZ.rn = nrn and CP.PERS_AUTHID = sauthid;
exception when no_data_found then nfl := 1;

end;

if nfl = 1 then return 1; end if;

  /* --- Только для владельцев роли "WEB_Конструктор"
  for cur in (select 1
                from userroles ur
               where ur.authid = sauthid
                 and ur.roleid = 164230031 ---WEB_Конструктор
                 and rownum = 1)
  loop
    */
  
      
    case usr_f_udo_deporddir_acces(nrn => nrn, sauthid => sauthid)
      when 0 then
        return 0;
      else
        return 1;
    end case;
---  end loop;

  return 1;

end;
/
