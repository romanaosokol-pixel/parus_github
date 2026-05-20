create or replace procedure UDO_P_SESSIONS_DROP as
  /*
    Марков МВ. Пользовательская процедура для пользовательского задания
    Чистка сессий, висящих без активности более 30 минут
  */
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  -- ограничение работы процедуры - только в рабочее время с 8-29 по 17-01
  if sysdate not between to_date(to_char(sysdate, 'ddmmyyyy') || '0829', 'ddmmyyyyhh24mi') and
     to_date(to_char(sysdate, 'ddmmyyyy') || '1701', 'ddmmyyyyhh24mi') then
    return;
  end if;
  --
  for session_drop in (
    select t.rn,
          t.authid,
          t.last_time,
          t.application,
          l.nmax_number,
          l.nacnt_number,
          l.nmax_number - l.nacnt_number rest_lic -- количество свободных лицензий
     from LICENSE_SESSIONS t,
          dba_users        u,
          v_LICCTRLSPEC    l
    where u.username = t.authid
          and case when t.authid in ('ADAMOV_AA', 'SAVINKOV_II', 'VINOKUROV_VV', 'NADEEVA_IA', 'KUZNETSOVA_SA',
                                     'TYUMENTSEVA_YY', 'VOROBEVA_DV', 'SUROV_RS', 'TAYMASOV_SV', 
                                     'EVGEN', 'CITK_MARKOV', 'KHOK', 'PAY', 'PARUS') then 0 -- кроме отдельных пользователей
                   /*when t.authid in ('SAVINKOV_II') and (sysdate - t.last_time) * 1440 > 540 then 1*/  -- выделим отдельных пользователей более 9 часов простоя
                   when (sysdate - t.last_time) * 1440 > 165 then 1 -- простой более 2 часов 45минут
                   else 0
              end = 1 -- только для простаивающих сессий
      --and u.PROFILE <> 'DEFAULT'
      and l.sapplication = t.application
      order by l.sapplication, t.last_time
      -- можно поставить ограничение на Приложения and t.application not in ('Account', 'Salary', 'TimeBoard', 'Persons')
  ) loop
    -- если для модуля ПУДП есть свободные лицензии, то пропускаем
    if session_drop.application != 'Other' ---and session_drop.rest_lic <= 3 -- Пока не будем смотреть на количество свободных лицензий !
      /*'MechanicalRecords' and session_drop.rest_lic >= 1*/ then
      --continue;
    -- отключить сессию
    PKG_PROC_BROKER.PROLOGUE;
    PKG_PROC_BROKER.SET_PARAM_NUM_EX('NRN', 'IN', session_drop.rn);
    PKG_PROC_BROKER.EXECUTE('P_SESSION_ABORT', 1);
    PKG_PROC_BROKER.EPILOGUE;
    -- сохраним
    insert into udo_t_sessions_drop
      (date_drop, authid, application, last_time, acnt_number)
    values
      (sysdate, session_drop.authid, session_drop.application, session_drop.last_time, session_drop.nacnt_number);
    --
    end if;
  end loop;
  -- убить спящие сессии Оракл
  for sniped_drop in (SELECT v$session.username,
                             module,
                             logon_time,
                             SID,
                             v$session.serial# SER,
                             'alter system kill session ' || '''' || SID || ', ' || v$session.serial# || '''' ||
                             ' immediate' kill_sql
                        FROM v$session,
                             sys.v_$process
                       WHERE v$session.paddr = sys.v_$process.addr
                         AND status = 'SNIPED'
                         and sysdate - logon_time > 1 / 24
                         /*and MODULE not in ('PARUS$LicenseControl',
                                            'PARUS$Account',
                                            'PARUS$Salary',
                                            'PARUS$TimeBoard',
                                            'PARUS$Persons')*/
                                            ) loop

    -- убить сессию Оракл
    execute immediate sniped_drop.kill_sql;
    -- сохраним
    insert into udo_t_sessions_drop
      (date_drop,
       authid,
       application,
       last_time)
    values
      (sysdate,
       sniped_drop.username,
       replace(sniped_drop.module, 'PARUS', 'SNIPED'),
       sniped_drop.logon_time);
    --
  end loop;
  --
  commit;

exception
  when others then
    PKG_PROC_BROKER.EPILOGUE;
    raise;

end;
/
