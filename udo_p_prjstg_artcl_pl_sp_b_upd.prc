create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_B_UPD
/*
   Базовое исправление в разделе "Планы и отчеты по статьям (спецификация)"
  */
(
  NRN           number --рег. номер исправляемой записи
 ,NPRJSTG_ARTCL number --рег. номер статьи этапа заказа
 ,NPERIOD       number --рег. номер расчетного периода
 ,NSTATE        number --рег. номер состояния
 ,NSUMM         number --сумма
 ,DACT_FROM     date --дата начала действия показателей
) as
  REC        UDO_T_PRJSTG_ARTCL_PLAN_SP%rowtype; --исправляемая запись
  SSQL       varchar2(4000); --динамический SQL для обновления таблицы помесячных планов
  SERR       varchar2(4000); --ошибка исполнения динамического SQL
  SMONTH_OLD varchar2(2); --номер месяца (старый)
  SMONTH_NEW varchar2(2); --номер месяца (новый)
begin
  --считаем исправляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN_SP T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, NRN, 'UDO_T_PRJSTG_ARTCL_PLAN_SP');
  end;
  --проверим неизменность полей
  if (REC.PRJSTG_ARTCL <> NPRJSTG_ARTCL)
  then
    P_EXCEPTION(0, 'Привязку записи к статье изменять нельзя!');
  end if;
  if (REC.STATE <> NSTATE)
  then
    P_EXCEPTION(0, 'Состояние записи изменять нельзя!');
  end if;
  --исправим данные в таблице
  update UDO_T_PRJSTG_ARTCL_PLAN_SP T
     set /*T.PRJSTG_ARTCL = NPRJSTG_ARTCL
        ,*/T.PERIOD       = NPERIOD
        /*,T.STATE        = NSTATE*/
        ,T.SUMM         = NSUMM
        ,T.ACT_FROM     = DACT_FROM
   where T.RN = NRN;
  --исправим данные в таблице помесячных планов
  begin
    --определим месяц (старый)
    select TO_NUMBER(TO_CHAR(P.STARTDATE, 'mm'))
      into SMONTH_OLD
      from ENPERIOD P
     where P.RN = REC.PERIOD;
    --определим месяц (новый)
    select TO_NUMBER(TO_CHAR(P.STARTDATE, 'mm'))
      into SMONTH_NEW
      from ENPERIOD P
     where P.RN = NPERIOD;
    --затрем старые помесячные планы (вдруг изменилась статья или состояние)
    SSQL := 'update UDO_T_PRJSTG_ARTCL_PLAN_MN t set t.SUMM_' || SMONTH_OLD ||
            '=0 where T.PRN = :1 and T.PRJSTG_ARTCL = :2 and T.STATE = :3';
    execute immediate SSQL
      using REC.PRN, REC.PRJSTG_ARTCL, REC.STATE;
    --сформируем и исполним запрос для исправления таблицы помесячных планов
    SSQL := 'update UDO_T_PRJSTG_ARTCL_PLAN_MN t set t.SUMM_' || SMONTH_NEW ||
            '=:1 where T.PRN = :2 and T.PRJSTG_ARTCL = :3 and T.STATE = :4';
    execute immediate SSQL
      using NSUMM, REC.PRN, NPRJSTG_ARTCL, NSTATE;
  exception
    when others then
      SERR := sqlerrm;
      P_EXCEPTION(0, 'Ошибка исправления помесячных планов: ' || SERR);
  end;
end;
/

