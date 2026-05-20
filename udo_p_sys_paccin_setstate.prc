create or replace procedure UDO_P_SYS_PACCIN_SETSTATE as
  /*
    15/07/2022 Марков МВ.
    Входящие счета на оплату
    Автоматическая установка Статуса для ВСО Отработан.
    Условия:
    ВСО внтри каталогов 1С, кроме "Оплач.Частично"
    Исполнять ТОЛЬКО от админа.
  */
  rTMP UDO_SYS_PACCIN_SETSTATE%rowtype; -- сохраним в таблице все изменения.
begin
  if utilizer not in ('PARUS') then p_exception(0, 'Fatal error 404. Come to Admin!!!'); end if;
  for rec in (select t.rn,
                     (select EV.RN
                        from CLNEVENTS EV
                       where EV.LINKED_UNIT = 'PaymentAccountsIn'
                         and EV.LINKED_RN = T.RN) event_rn,
                     (select ST.sEVENT_STAT
                        from V_CLNEVENTS_STATMOD ST
                       where ST.sLINKED_UNIT = 'PaymentAccountsIn'
                         and ST.nLINKED_RN = T.RN) event_state
                from payaccin t
               where t.doc_date < s2d('01.01.2022') and t.doc_state < 2
                 and t.crn != 7578029 -- кроме каталога Оплач.Частично
                 and t.crn in(select rn from acatalog ac connect by prior ac.rn = ac.crn start with ac.rn = 6868349)
                 and exists (select null
                        from V_CLNEVENTS_STATMOD ST
                       where ST.sLINKED_UNIT = 'PaymentAccountsIn'
                         and ST.nLINKED_RN = T.RN)
                 and (select ST.sEVENT_STAT
                        from V_CLNEVENTS_STATMOD ST
                       where ST.sLINKED_UNIT = 'PaymentAccountsIn'
                         and ST.nLINKED_RN = T.RN) != 'Отработан'
               order by t.rn) loop
    -- установим Отработан
    update CLNEVENTS EV set EV.EVENT_STAT = 7195939 where EV.RN = rec.event_rn;
    -- сохраним
    rTMP.Acc_Rn := rec.rn;
    rTMP.Old_State := rec.event_rn;
    rTMP.New_State := 7195939;
    rTMP.Change_Date := sysdate;
    rTMP.Change_Auth := utilizer;
    insert into UDO_SYS_PACCIN_SETSTATE values rTMP;
    --p_exception(0, 'payaccin = %s', rec.rn);
  end loop;
end;
/

