create or replace function usr_f_udo_deporddir_approve(
nrn udo_deporddir.rn%type,  
nSTATE udo_deporddir.State%type
/*sauthid userlist.authid%type default utilizer*/) return number as

  /*
  
  Возвращает 0, если пользователь может утвердить Ведомость замен и 
             1, если может   
  (Имеет право и ведомость замен еще не согласована)            
  
  */
sauthid varchar2(40):=utilizer;
begin
if nstate in ( 6,5, 2)
       then return 0;  
else
  ---Если пользователь имеет роль   WEB_Конструктор, то анализируем видимость Ведомостей замен, а если нет, то видят все ведомости.
  for cur in (select 1
                from userroles ur
               where ur.authid = sauthid
                 and ur.roleid = 164230031 ---WEB_Конструктор
                 and rownum = 1)
  loop
  
    --- Только для владельцев роли "WEB_Конструктор"
  
            
    case usr_f_udo_deporddir_acces(nrn => nrn, sauthid => sauthid)
      when 0 then
        return 0;
      else
        return 1;
    end case;
    
  end loop;
end if;
  return 1;

end;
/
