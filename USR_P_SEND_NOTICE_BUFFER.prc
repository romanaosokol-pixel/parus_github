create or replace procedure USR_P_SEND_NOTICE_BUFFER(nCOMPANY in number default null)
is
/* Процедура ежедневного уведомления о формировании заказа подразделения на дельту */
  
  cursor c_emails is
    select distinct EMAIL_LIST as email
      from USR_T_NOTICE_DEPTORD_BUFFER
     where SENT_AT is null
       and (nCOMPANY is null or COMPANY = nCOMPANY)
       and EMAIL_LIST is not null;

  v_email varchar2(4000);
  v_body  clob;
  v_subject varchar2(1000);

begin
  /*dbms_output.enable(1000000);*/

  for e in c_emails loop
    v_email := trim(e.email);
    if v_email is null then continue; end if;

    v_body := 'По состоянию на ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi') ||
              ' сформированы следующие заказы подразделений:' || cr || cr;

    --
    for r in (
      select NOTICE_RAW,
             DEPTORD_FULL,
             PROD_NAME
        from USR_T_NOTICE_DEPTORD_BUFFER
       where SENT_AT is null
         and (nCOMPANY is null or COMPANY = nCOMPANY)
         and trim(EMAIL_LIST) = v_email
       order by CREATED_AT
    ) loop
      v_body := v_body ||
                '• По извещению ' || r.NOTICE_RAW ||
                ' сформирован заказ подразделения ' || r.DEPTORD_FULL ||
                ' для изделия: ' || r.PROD_NAME || cr||cr;
    end loop;

    v_body := v_body || cr || cr ||
              'Данное сообщение сформировано автоматически.'
              ||cr||cr||'Сообщение отправлено: '||v_email;

    v_subject := 'Сформированы заказы подразделений на дельту по извещениям';

    -- Вывод для отладки
/*    dbms_output.put_line('=== ПИСЬМО ===');
    dbms_output.put_line('Тема: ' || v_subject);
    dbms_output.put_line('Получатель: ' || v_email);
    dbms_output.put_line('--- ТЕКСТ ---');
    dbms_output.put_line(v_body);
    dbms_output.put_line('===============');
    dbms_output.put_line('');*/

    -- Отправка
    PKG_EXS_EXT_MAIL.SEND_BY_LIST(
      STO_LIST           => 'v.fanov@module.ru; r.fedoreev@module.ru;'||v_email,
      STITLE             => v_subject,
      CTEXT              => v_body,
      NFILE_BUFFER_IDENT => null,
      NFORMAT            => PKG_EXS_EXT_MAIL.NFORMAT_TEXT
    );

    -- Пометка как отправленные
    update USR_T_NOTICE_DEPTORD_BUFFER
       set SENT_AT     = sysdate,
           SENT_STATUS = 1
     where SENT_AT is null
       and (nCOMPANY is null or COMPANY = nCOMPANY)
       and trim(EMAIL_LIST) = v_email;

  end loop;

  commit;
  delete from USR_T_NOTICE_DEPTORD_BUFFER where SENT_STATUS = 1;
  commit;

exception
  when others then
    rollback;
    raise;
end USR_P_SEND_NOTICE_BUFFER;
/*grant execute on USR_P_SEND_NOTICE_BUFFER to public;*/
/
