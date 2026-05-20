create or replace procedure usr_p_agnlist_total_repl_ini
(
  noldrn      in number
 ,s_old_agent out varchar2
 ,s_new_agent out varchar2
) is

begin

  begin
  
    select a.agnidnumb || '/' || a.reason_code || ' ' || a.agnname || ' (' || a.agnabbr || ')'
      into s_old_agent
      from agnlist a
     where a.rn = noldrn;
  exception
    when no_data_found then
      s_old_agent := 'ѕроцедура запускаетс€ только из раздела контрагенты.';
  end;
  s_new_agent := '¬ыберте мнемокод контрагента на которого замен€ем.';

end;
/
