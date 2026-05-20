create or replace procedure UDO_P_MOVE2ARC as
  /* 
    15/07/2022 Марков МВ.
    Джоб перевода журнала изменений в архив.
    журнал регистрации бизнес-процессов тоже архивируем
    отработка ТОЛЬКО под админом!!!!!
  */
  type tRN is table of UPDATELIST.RN%type index by binary_integer;
  rRN tRN;

  dBEG constant date := sysdate - 1;
  dEND constant date := sysdate;

  -- перенос в архив
  procedure move2arc is
  begin
    for Idx in rRN.First .. rRN.Last loop
      execute immediate 'begin
         p_updatelist_move_2arc(:nRN);
       end;'
        using rRN(Idx);
      commit;
    end loop;
  end move2arc;

  -- перенос в архив бизнес-процессов 
  procedure move2arc2 is
  begin
    for Idx in rRN.First .. rRN.Last loop
      execute immediate 'begin
         P_BPHIST_MOVE_TO_ARC(:nRN);
       end;'
        using rRN(Idx);
      commit;
    end loop;
  end move2arc2;

begin

  -- отработка ТОЛЬКО под админом
  if utilizer != 'PARUS' then
    p_exception(0,
                'Функция архивации журнала доступна только Администратору системы.');
  end if;

  /* архивируем текущий день */
  begin
    select UL.RN bulk collect into rRN from UPDATELIST UL where UL.MODIFDATE between dBEG and dEND;
  exception
    when no_data_found then
      null;
  end;
  -- перенос
  if rRN.Count > 0 then
    move2arc;
  end if;

  /* архивируем текущий день  бизнес-процессы*/
  begin
    select UL.RN bulk collect into rRN from BPHIST UL where UL.End_Date between dBEG and dEND;
  exception
    when no_data_found then
      null;
  end;
  -- перенос
  if rRN.Count > 0 then
    move2arc2;
  end if;

  /* архивируем предыдущие дни - по 32000 записей за раз (10 циклов) */
  for cnt in 1 .. 10 loop
    rRN.Delete;
    begin
      select UL.RN bulk collect
        into rRN
        from UPDATELIST UL
       where rownum < 32001
         and UL.MODIFDATE < dBEG
       order by UL.MODIFDATE;
    exception
      when no_data_found then
        null;
    end;
    -- перенос
    if rRN.Count > 0 then
      move2arc;
    end if;
  end loop;

  /* архивируем предыдущие дни бизнес-процессы - по 32000 записей за раз (10 циклов)*/
  for cnt in 1 .. 10 loop
    rRN.Delete;
    begin
      select UL.RN bulk collect
        into rRN
        from BPHIST UL
       where rownum < 32001
         and (UL.End_Date < dBEG or (ul.reg_date < = s2d('01/05/2020') and ul.end_date is null)) -- очистка незаконченных процессов
       order by UL.End_Date;
    exception
      when no_data_found then
        null;
    end;
    -- перенос
    if rRN.Count > 0 then
      move2arc2;
    end if;
  end loop;
end;
/

