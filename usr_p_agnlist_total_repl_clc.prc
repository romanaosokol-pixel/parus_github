create or replace procedure usr_p_agnlist_total_repl_clc
(
  ncompany    in number
 ,noldrn      in number
 , -- RN заменяемого контрагента
  snewcode    in varchar2
 , --- Код строки нового контрагента
  s_old_agent out varchar2
 ,s_new_agent out varchar2
 ,is_ok       out number
) is

begin

  begin
  
    is_ok := 1;
    select a.agnidnumb || '/' || a.reason_code || ' ' || a.agnname || ' (' || a.agnabbr || ')'
      into s_old_agent
      from agnlist a
     where a.rn = noldrn;
  exception
    when no_data_found then
      is_ok       := 0;
      s_old_agent := 'Процедура запускается только из раздела контрагенты.';
  end;

  begin
  
    select a.agnidnumb || '/' || a.reason_code || ' ' || a.agnname || ' (' || a.agnabbr || ')'
      into s_new_agent
      from agnlist a
      join compverlist v
        on v.version = a.version
       and v.unitcode = 'AGNLIST'
       and v.company = ncompany
     where a.agnabbr = snewcode;
  exception
    when no_data_found then
      is_ok       := 0;
      s_new_agent := 'Контрагент с мнемокодом "' || s_new_agent || '" не существует. Выберите корректное значение.';
  end;

end;
/
