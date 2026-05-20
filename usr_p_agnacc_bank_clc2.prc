create or replace procedure usr_p_agnacc_bank_clc2
(
  ncompany       in companies.rn%type
 ,sbank_code     in agnlist.agnabbr%type
 ,out_treas_code out agnlist.agnabbr%type
  
 ,sbank_name out agnlist.agnname%type
 ,sbank_inn  out agnlist.agnidnumb%type
  
 ,treas_name out agnlist.agnname%type
 ,treas_inn  out agnlist.agnidnumb%type
  
) is
  /*grant execute on usr_p_agnacc_bank_clc2 to public;*/

begin

  if sbank_code is not null then
    out_treas_code := null;
    treas_name     := null;
    treas_inn      := null;
  
    begin
      select b.agnname
            ,b.agnidnumb
        into sbank_name
            ,sbank_inn
        from agnbanks ab
        join compverlist v1
          on v1.version = ab.version
         and v1.company = ncompany
         and v1.unitcode = 'AGNBANKS'
        left join agnlist b
          on b.rn = ab.agnrn
        left join compverlist v2
          on v2.version = b.version
         and v2.company = v1.company
         and v2.unitcode = 'AGNLIST'
      
       where b.agnabbr = sbank_code;
    
    exception
      when no_data_found then
        p_exception(0
                   ,'Банк с кодом "%s" не найден. Выберите корректное значение через справочник.');
      
    end;
  
  end if;

end;
/
