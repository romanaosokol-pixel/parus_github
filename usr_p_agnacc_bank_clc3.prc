create or replace procedure usr_p_agnacc_bank_clc3
(
  ncompany       in companies.rn%type
 ,out_sbank_code out agnlist.agnabbr%type
 ,treas_code     in agnlist.agnabbr%type
 ,sbank_name     out agnlist.agnname%type
 ,sbank_inn      out agnlist.agnidnumb%type
 ,treas_name     out agnlist.agnname%type
 ,treas_inn      out agnlist.agnidnumb%type
  
) is
  /*grant execute on usr_p_agnacc_bank_clc3 to public;*/

begin

  if treas_code is not null then
    out_sbank_code := null;
    sbank_name     := null;
    sbank_inn      := null;
  
    begin
      select ta.agnname
            ,ta.agnidnumb
        into treas_name
            ,treas_inn
        from agnlist ta
        join compverlist v
          on v.version = ta.version
         and v.company = ncompany
         and v.unitcode = 'AGNLIST'
       where ta.agnabbr = treas_code;
    exception
      when no_data_found then
        p_exception(0
                   ,'Казначейство с кодом "%s" не найдено. Выберите корректное значение через словарь.');
    end;
  
  end if;

end;
/
