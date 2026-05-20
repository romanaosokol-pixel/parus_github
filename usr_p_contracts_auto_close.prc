create or replace procedure usr_p_contracts_auto_close is

  v_exeс agnlist.agnabbr%type := null; -- Контрагент которому шлем уведомление о закрытии
  v_msg   clob;
  v_mail  agnlist.mail%type; --- Куда шлем сообщение

  v_err usr_tab_msg_log.msg%type;
  v_nrn number(17);

  v_mail_def varchar2(140) := 'o.gorodetskiy@module.ru;k.bykova@module.ru';
  v_mail_err varchar2(80) := 'o.gorodetskiy@module.ru;k.bykova@module.ru;';

  v_event_code usr_tab_msg_log.event_code%type := 'CONTRACTS_CLOSE';
  v_txt_err    varchar2(2000) := chr(10);

begin

  /* Очистим таблицу сообщений об ошибках */
  delete usr_tab_msg_log;
  --- Закроем этапы договоров, где поставка/отгрухка больше либо равна сумме этапа
  ---    и сумма оплат строго равна сумме этапа

  usr_p_stages_auto_close;

  --- Закроем договора, где нет открытых этапов (Закрытый этап это если - Лицевой счет закрыт и дата его закрытия задана (не равна null))

  for cur in (select distinct dog.rn dog_rn
                             ,dog.company
                             ,trim(dog.doc_pref) || '-' || trim(dog.doc_numb) || ' от ' || to_char(dog.doc_date, 'DD.MM.YYYY') dog
                             ,nvl((select sum(s.stage_sumtax) from stages s where s.prn = dog.rn), 0) dog_sum
                             ,nvl(usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, ndocument => dog.rn), ae.agnabbr) executive
                             ,dog.doc_date
                             ,sysdate close_date
                from contracts dog
                left join (select st.prn prn
                                ,f.fact_close_date
                            from stages st
                            join faceacc f
                              on f.rn = st.faceacc
                           where st.status != 0
                              or f.fact_close_date is null) stg
                  on stg.prn = dog.rn
              
                left join agnlist ae
                  on ae.rn = dog.executive
              
               where dog.status != 2 -- не закрыт
                 and dog.crn != 58774176   /*Каталог "!Исполнено"*/
                 and stg.prn is null
                 and nvl((select sum(s.stage_sumtax) from stages s where s.prn = dog.rn), 0) > 0
              
              )
  loop
  
    if v_exeс is null
       or v_exeс != cur.executive
    then
      --- смена менеджера, отправляем сообщение
    
      if v_exeс is not null
      then
        usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany     => cur.company
                                                   ,sdescription => 'Автоматическое закрытие договоров'
                                                   ,sto_list     => v_mail || ';' || v_mail_def
                                                   ,stitle       => 'Автоматическое закрытие договоров'
                                                   ,ctext        => v_msg
                                                   ,nrn          => v_nrn);
      
      end if;
    
      v_exeс := cur.executive;
      v_msg   := null;
      --- найдем E-mail
      begin
        select a.mail into v_mail from agnlist a where a.agnabbr = v_exeс;
      
      exception
        when no_data_found then
          v_msg := to_clob('Контрагент ' || v_exeс || ' не найден.' || cr);
        
      end;
    
      if v_mail is null
      then
        v_mail := v_mail_def; --- Мейл по умолчанию
        v_msg  := v_msg || to_clob('У Контрагента ' || v_exeс || ' не задан E-MAIL.' || cr);
      end if;
    
      v_msg := v_msg || to_clob('Для менеджера ' || v_exeс || ' Были закрыты договора, т.к. все входящие в них этапы закрыты:' || cr);
    
    end if;
  
    v_msg := v_msg || to_clob(cur.dog || cr);
  
    begin
      savepoint before_setstatus;
      p_contracts_setstatus(ncompany => 90521, nrn => cur.dog_rn, nstatus => 2, dworkdate => cur.close_date);
    exception
      when others then
      
        v_err :=  'RN договора '||
        cur.dog_rn||' '||
        substr(sqlerrm,11,case instr(sqlerrm, 'ORA-',12) when 0 then 500 else instr(sqlerrm, 'ORA-',12) end);
        --substr(sqlerrm, 1, 2000);
      
        /* тут надо записать сообщение в лог ошибок */
        rollback to savepoint before_setstatus; --- Если неудача, то откатываем изменения
      
        insert into usr_tab_msg_log
          (rn
          ,company
          ,sauthid
          ,event_code
          ,msg
          ,operdate
          ,dog_rn)
        values
          (gen_id()
          ,90521
          ,user
          ,v_event_code
          ,v_err
          ,cur.close_date
          ,cur.dog_rn);
      
    end;
  
  end loop;
  --- Отправим сообщение последнему в списке.
  if v_msg is not null
  then
    usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany     => 90521
                                               ,sdescription => 'Автоматическое закрытие договоров'
                                               ,sto_list     => v_mail || ';' || v_mail_def
                                               ,stitle       => 'Автоматическое закрытие договоров'
                                               ,ctext        => v_msg
                                               ,nrn          => v_nrn);
  end if;

  --- Проверим наличие ошибок
  for err in (select t.msg from usr_tab_msg_log t)
  loop
  
    /*Сформируем текст про ошибки */
  
    if length(v_txt_err) < 1500
    then
    
      v_txt_err := v_txt_err || err.msg;
    
    end if;
  
  end loop;

  if length(v_txt_err) > 5
  then
  
    usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany     => 90521
                                               ,sdescription => 'ERR Автоматическое закрытие договоров'
                                               ,sto_list     => v_mail_err
                                               ,stitle       => 'ERR Автоматическое закрытие договоров'
                                               ,ctext        => 'При работе процедуры "Автоматическое закрытие договоров" ' ||
                                                                'произошли ошибки. Подробности в таблице "usr_tab_msg_log".' ||
                                                                substr(v_txt_err, 2)
                                               ,nrn          => v_nrn);
  end if;

end;
/
