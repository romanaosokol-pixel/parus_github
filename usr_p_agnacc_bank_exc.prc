create or replace procedure usr_p_agnacc_bank_exc
(
  nrn        in agnacc.rn%type
 ,ncompany   in companies.rn%type
 ,agg_type   in bankacctypes.code%type
 ,sbank_code in agnlist.agnabbr%type
 ,treas_code in agnlist.agnabbr%type
  
) is
  /*grant execute on usr_p_agnacc_bank_exc to public;*/

  n_rn number(17);

begin

  for cur in (
              
              select dt.code
                     ,b.agnabbr  bank_code
                     ,ta.agnabbr treas_code
                from agnacc ag
                left join agnbanks ab
                  on ab.rn = ag.agnbanks
                left join agnlist b
                  on b.rn = ab.agnrn
                left join agntreas tr
                  on tr.rn = ag.agntreas
                left join agnlist ta
                  on ta.rn = tr.agnrn
                left join bankacctypes dt
                  on dt.rn = ag.bankacc_type
               where ag.rn = nrn)
  loop
  
    -- Проверяем, надо ли менять значения
  
    if agg_type != cur.code then
    
      begin
        select bt.rn
          into n_rn
          from bankacctypes bt
          join compverlist v
            on v.version = bt.version
           and v.company = ncompany
           and v.unitcode = 'BankAccountTypes'
         where bt.code = agg_type;
      exception
        when no_data_found then
          p_exception(0
                     ,'Тип счета с кодом "%s" не существует. Выберите корректный тип через справочник. '
                     ,agg_type);
        
      end;
    
      update agnacc t set t.bankacc_type = n_rn where t.rn = nrn;
    
    end if;
  
    if sbank_code != cur.bank_code
       or (sbank_code is not null and treas_code is null) then
    
      begin
        select ab.rn
          into n_rn
          from agnlist a
          join compverlist v
            on v.version = a.version
           and v.company = ncompany
           and v.unitcode = 'AGNLIST'
          join agnbanks ab
            on ab.agnrn = a.rn
          join compverlist v2
            on v2.version = ab.version
           and v2.company = ncompany
           and v2.unitcode = 'AGNBANKS'
         where a.agnabbr = sbank_code;
      exception
        when no_data_found then
          p_exception(0
                     ,'Банковской организации с кодом "%s" не существует. Выберите корректное значение через справочник.'
                     ,sbank_code);
      end;
    
      update agnacc t
         set t.agnbanks = n_rn
            ,t.agntreas = null
       where t.rn = nrn;
    
    end if;
  
    if treas_code != cur.treas_code
       or (sbank_code is null and treas_code is not null) then
      begin
        select tr.rn
          into n_rn
          from agnlist ta
          join compverlist v
            on v.version = ta.version
           and v.company = ncompany
           and v.unitcode = 'AGNLIST'
          join agntreas tr
            on tr.agnrn = ta.rn
         where ta.agnabbr = treas_code;
      exception
        when no_data_found then
          p_exception(0
                     ,'Казначейство с кодом "%s" не найдено. Выберите корректное значение через словарь.');
      end;
    
      update agnacc t
         set t.agntreas = n_rn
            ,t.agnbanks = null
       where t.rn = nrn;
    
    end if;
  
  end loop;

end;
/
