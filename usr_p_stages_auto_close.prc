create or replace procedure usr_p_stages_auto_close is

  n_flag integer;
   v_err usr_tab_msg_log.msg%type;
begin
  /* Процедура закрывает исполненные этапы договоров 
  Если сумма этапа не нудевая , а сумма получено/отгружено и сумма платежей равна сумме этапа
  */

  for cur in (
              
              select dog.rn dogrn
                     ,dog.company
                     ,st.rn strn
                     ,trim(st.numb) numb
                    /* ---  поля для тестирования
                    ,trim(dog.doc_pref) doc_pref
                     ,trim(dog.doc_numb) doc_numb
                     ,dog.doc_date
                     
                     ,st.numb
                     ,st.stage_sumtax
                     , --- Сумма этапа
                      f.fact_posted out_pay_fact
                     , -- Отправлено платежей
                      f.fact_payed in_pay_payed
                     , -- Получено платежей
                      f.fact_income in_fakt_tvus
                     , -- Получено товаров и услуг
                      f.fact_serv out_fact_usl --- Оказано услуг фактически
                     ,f.plan_serv out_plan_usl -- Оказано услуг по плану (запланировано)
                     ,f.fact_ship out_fact_tov -- Отгружено товаров
                     ,f.plan_ship out_plan_tov -- Отгружено товаров по плану (запланировано)*/
                from contracts dog
                join stages st
                  on st.prn = dog.rn
                join faceacc f
                  on f.rn = st.faceacc
              
               where dog.status != 2 -- не закрыт
                 and st.status not in (0, 2)
                 and dog.crn != 58774176   /*Каталог "!Исполнено"*/
                 and f.fact_close_date is null
                 and st.stage_sumtax != 0  --- рамочные договора без суммы
                    
                 and st.stage_sumtax = abs(f.fact_posted - f.fact_payed) --- Закрыто платежами
                 and st.stage_sumtax = abs (fact_income - f.fact_serv - f.fact_ship ) --- Закрыто товарам и услугами
              
              ---  and st.prn = 43022006
              
              )
  loop
    n_flag := 0;
  
    begin
      savepoint before_setstatus;
      p_stages_setstatus(ncompany    => cur.company
                        ,nrn         => cur.strn
                        ,nstatus     => 0
                        ,dworkdate   => sysdate
                        ,nssfod_sign => 0);
    exception
      when others then
        n_flag := 1;
        v_err := 'RN договора '||
        cur.dogrn||' Номер этапа '||cur.numb||' '||
        substr(sqlerrm,11,case instr(sqlerrm, 'ORA-',12) when 0 then 500 else instr(sqlerrm, 'ORA-',12) end);
        
        ---substr(sqlerrm, 1, 2000);
        
        /* тут надо записать сообщение в лог ошибок */
        rollback to savepoint before_setstatus; --- Если неудача, то
        
         insert into usr_tab_msg_log
          (rn
          ,company
          ,sauthid
          ,event_code
          ,msg
          ,operdate)
        values
          (gen_id()
          ,90521
          ,user
          ,'STAGE_CLOSE'
          ,v_err
          ,trunc(sysdate));
        
        
        
    end;
  
    if n_flag = 0 then
      update stages t
         set t.comments = substr('Закрыто автоматически ' || t.comments, 1, 2000)
       where t.rn = cur.strn;
    end if;
  
  end loop;

end;

  ---and ST.rn = 138320780
/
