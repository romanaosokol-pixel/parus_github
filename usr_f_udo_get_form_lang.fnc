create or replace function USR_F_UDO_GET_FORM_LANG
/*
Пользовательские объекты
Возвращает языки программирования пользовательских форм у объекта
16/05/2024 Степанов М.
grant execute on USR_F_UDO_GET_FORM_LANG to public;
*/
(
 nRN  in number
)
return varchar2
is
  sRes    pkg_std.tstring := 'Нет';
begin
  begin
  select listagg(decode(events_language, null, 'Не используется', 0, 'VBScript', 1, 'JScript', 2, 'DelphiScript', 3, 'PerlScript', 4, 'PythonScript'), ', ') within group (order by events_language)
    into sRes
    from userforms where form_id = nRN;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s>.', nRN);
  end;

/*  for c in (select * from USERFORMS where form_id = nRN)
  loop
    sRes  := 'Да';
    exit;
  end loop;
*/
  return sRes;

end USR_F_UDO_GET_FORM_LANG;
/
