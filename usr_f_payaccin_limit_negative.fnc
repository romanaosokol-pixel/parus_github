create or replace function usr_f_payaccin_limit_negative(nrn in payaccin.rn%type) return number is

  nres number(1);
  pin_nrn number(17):= nrn;


begin

  /*Если хоть по одной подстатье калькуляции из спецификации входящего счета Лимит по бюджетному распределению больше чем выписано утвержденных счетов, по данной подстатье,
  то выводится 1, инаяе 0
  
  Значения рассчитываются в момент утверждения или согласования счета или запуска процедуры вручную
  */
  begin
  
    select 1 
      into nres 
      from usr_v_payaccin_cl_val clv
     where clv.nprn =  pin_nrn
       and clv.nlimit - clv.ncost < 0  
       and clv.sdep_code !='Основное'  -- По основному отделению Лимитов бюджетов нет
       and rownum = 1;
  
  exception
    when no_data_found then
      return 0;
    
  end;

  return 1;

end;
/
