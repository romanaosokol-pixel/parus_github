create or replace procedure usr_p_agnacc_bank_ini
(
  nrn        in agnacc.rn%type
 ,agn_code   out agnacc.strcode%type
 ,agn_name   out agnacc.agnnameacc%type
 ,agg_type   out bankacctypes.code%type
 ,sbank_code out agnlist.agnabbr%type
 ,sbank_name out agnlist.agnname%type
 ,sbank_inn  out agnlist.agnidnumb%type
 ,treas_code out agnlist.agnabbr%type
 ,treas_name out agnlist.agnname%type
 ,treas_inn  out agnlist.agnidnumb%type
) is
  /*grant execute on usr_p_agnacc_bank_ini to public;*/
begin

  if usr_f_agnacc_bank_priv = 0 then
    p_exception(0
               ,'Только пользователь с правами "Управление Финансами" может менять реквизиты расчетного счета данной процедурой.');
  end if;

  begin
  
    select dt.code
          ,ag.strcode
          ,ag.agnnameacc
          ,b.agnabbr bank_code
          ,coalesce(b.agnname, ag.banknameacc) bank_name
          ,b.agnidnumb bank_inn
          ,ta.agnabbr treas_code
          ,ta.agnname treas_name
          ,ta.agnidnumb treas_inn
      into agg_type
          ,agn_code
          ,agn_name
          ,sbank_code
          ,sbank_name
          ,sbank_inn
          ,treas_code
          ,treas_name
          ,treas_inn
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
     where ag.rn = nrn;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедуру можно вызвать только на расчетном счете контрагента!');
  end;

end;
/
