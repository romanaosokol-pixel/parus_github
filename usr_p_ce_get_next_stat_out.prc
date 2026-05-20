create or replace procedure usr_p_ce_get_next_stat_out
/*
Для пользоваетельской формы процедуры "Переход события в следующий статус"
grant execute on usr_p_ce_get_next_stat_out to public;
*/
(
 nCOMPANY         in number
,sATRIB           in varchar2
,sEVENT_STAT      in varchar2
,sEVENT_STAT_NAME in out varchar2
) 
is
begin
  /* Изменение нового статуса */
  if satrib = 'SEVENT_STAT' then
    begin
      select t.evnstat_name
        into sEVENT_STAT_NAME
        from clnevnstats t
       where t.evnstat_code = sEVENT_STAT
         and t.company      = nCOMPANY;
    exception
      when others then
        sEVENT_STAT_NAME := null;
    end;
  end if;
end;
/
