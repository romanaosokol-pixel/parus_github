create or replace procedure USR_P_USERFORMS_COPY_DATA
/*
Пользовательские формы.
Копировать значение form_data и form_events (потом можно расширить) из другой пользовательской формы.
04/09/2023 Степанов М.
*/
(
 nRN          in number
,nRN_FROM     in number  -- RN пользовательской формы, с которой скопировать значения
)
is
  rUserForms  userforms%rowtype;
begin
  /* Считывание записи FROM */
  begin
    select t.*
      into rUserForms
      from userforms t
     where t.rn = nRN_FROM;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nrn, get_unitlist_code_table(1, 'USERFORMS'));
      when others then
        p_exception(0
                   ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN
                   ,f_unitlist_getname(get_unitlist_code_table(1, 'USERFORMS')));
  end;

  /* Исправление текущей записи */
  update userforms t
     set t.form_data   = rUserForms.form_data
        ,t.form_events = rUserForms.form_events
   where t.rn = nRN;

end USR_P_USERFORMS_COPY_DATA;
/
