create or replace procedure usr_p_import_user_form_f
(
  pin_doc  in number /* RN формы */
 ,pin_file in clob
) is
  nident number(17) := gen_ident;
begin

  /*Записываем файл в Буфер */
  p_file_buffer_insert(nident => nident, cfilename => 'filename', cdata => pin_file, blobdata => null);

  /* Обновляем форму */
  update userforms uf
     set uf.form_data =
         (select fb.data from file_buffer fb where fb.ident = nident)
   where uf.rn = pin_doc;

  /* Очищаем буфер */
  p_file_buffer_clear(nIDENT => nIdent);
end;
/
