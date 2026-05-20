create or replace procedure usr_p_export_user_form(nident in number /*Идентификатор ведомости */) is
  v_blob clob;
begin
/* Выгрузка фвизуальной формы в текстовый файл. Файловый экспорт */

  begin
    select uf.form_data
      into v_blob
      from selectlist sl
      join userforms uf
        on uf.rn = sl.document
     where sl.ident = nident
       and sl.authid = utilizer;
  exception
    when others then
      null;
  end;
  if v_blob is not null
  then
    p_file_buffer_insert(nident, 'FORM_' || to_char(sysdate, 'YYYYMMDD_HH24Mi'), v_blob, null);
  end if;
end;
/
