create or replace procedure UDO_P_TRIGGER_CTRL
  (
    sOWNER  in varchar2, -- схема
    STRIGER in varchar2, -- наименование триггер (если заполнено работаем конкретно с ним)
    sTABLE  in varchar2, -- наименование таблицы  (если не указан триггер работаем со всеми триггерами таблицы)
    nSET    in number default null -- 0 - выключить триггер, все остальное - включить
  ) is
    -----------------------------------------------------------------------------------------
  -- ВКЛЮЧЕНИЕ, ОТКЛЮЧЕНИЯ ТРИГГЕРА (триггеров по таблице) В РАМКАХ АВТОНОМНОЙ ТРАНЗАКЦИИМ
  -----------------------------------------------------------------------------------------
    pragma autonomous_transaction;
    SSQL PKG_STD.TSQL;
  begin
    if STRIGER is not null then
      SSQL := 'alter trigger ' || STRIGER || ' ';
      if NSET = 0 then
        SSQL := SSQL || 'disable';
      else
        SSQL := SSQL || 'enable';
      end if;
      execute immediate SSQL;
    elsif sTABLE is not null then
      for cur in (select t.TRIGGER_NAME
                    from all_triggers t
                   where t.OWNER = sOWNER
                     and t.TABLE_NAME = sTABLE)
      loop
        UDO_P_TRIGGER_CTRL(sOWNER, cur.trigger_name, null, nset);
      end loop cur;
    end if;
  exception
    when others then
      P_EXCEPTION(0, 'UDO_PKG_DMSMERGE.TRIGGER_CTRL-' || ERROR_TEXT);
  end UDO_P_TRIGGER_CTRL;
/

