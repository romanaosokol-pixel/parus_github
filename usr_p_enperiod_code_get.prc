create or replace procedure usr_p_enperiod_code_get(ncompany  in number
                                                   ,sper_year in varchar2
                                                   ,npertype  in  enperiod.pertype%type default 3
                                                   ,sper_code out enperiod.code%type) is

begin
  /*
  Процедура возвразщает код периода (по умолчанию тип периода "Год" (3)
  за исключением периода "Произвольный период" у которых год даты начала периода равен заданному в парметре sPer_Year (4 буквы - цифры года)
   */
  begin
    select per.code
      into sper_code
      from enperiod per
     where per.company = ncompany
       and extract(year from startdate) = sper_year
       and per.pertype = npertype
       and per.rn != 176495; /*Исключили "Произвольный период"*/
  exception
    when others then
      sper_code := null;
    
  end;

end;
/
