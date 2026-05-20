create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_B_INS
/*
   Базовое добавление в раздел "Планы и отчеты по статьям (спецификация)"
  */
(
  NPRN          number --рег. номер родительской записи
 ,NPRJSTG_ARTCL number --рег. номер статьи этапа заказа
 ,NPERIOD       number --рег. номер расчетного периода
 ,NSTATE        number --рег. номер состояния
 ,NSUMM         number --сумма
 ,DACT_FROM     date --дата начала действия показателей
 ,NRN           out number --рег. номер добавленной записи
) as
  SSQL   varchar2(4000); --динамический SQL для обновления таблицы помесячных планов
  SERR   varchar2(4000); --ошибка исполнения динамического SQL
  SMONTH varchar2(2); --номер месяца
begin
  --сформируем рег. номер
  NRN := GEN_ID;
  --добавим запись в раздел
  insert into UDO_T_PRJSTG_ARTCL_PLAN_SP
    (RN, PRN, PRJSTG_ARTCL, PERIOD, STATE, SUMM, ACT_FROM)
  values
    (NRN, NPRN, NPRJSTG_ARTCL, NPERIOD, NSTATE, NSUMM, DACT_FROM);
  --проверим наличие записей в таблице помесячных планов, и если их нет - добавим
  declare
    NTMP number; --временая перепенная
  begin
    select T.RN
      into NTMP
      from UDO_T_PRJSTG_ARTCL_PLAN_MN T
     where T.PRN = NPRN
       and T.PRJSTG_ARTCL = NPRJSTG_ARTCL
       and T.STATE = NSTATE;
  exception
    when NO_DATA_FOUND then
      insert into UDO_T_PRJSTG_ARTCL_PLAN_MN
        (RN, PRN, PRJSTG_ARTCL, STATE)
      values
        (GEN_ID, NPRN, NPRJSTG_ARTCL, NSTATE);
  end;
  --выставим сумму в нужной графе помесячного плана
  begin
    --определим месяц
    select TO_NUMBER(TO_CHAR(P.STARTDATE, 'mm'))
      into SMONTH
      from ENPERIOD P
     where P.RN = NPERIOD;
    --сформируем и исполним запрос для исправления таблицы помесячных планов
    SSQL := 'update UDO_T_PRJSTG_ARTCL_PLAN_MN t set t.SUMM_' || SMONTH ||
            '=:1 where T.PRN = :2 and T.PRJSTG_ARTCL = :3 and T.STATE = :4';
    execute immediate SSQL
      using NSUMM, NPRN, NPRJSTG_ARTCL, NSTATE;
  exception
    when others then
      SERR := sqlerrm;
      P_EXCEPTION(0,'Ошибка исправления помесячных планов: ' || SERR);
  end;
end UDO_P_PRJSTG_ARTCL_PL_SP_B_INS;
/

