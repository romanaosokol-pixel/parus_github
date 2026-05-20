create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_B_DEL
/*
   Базовое удаление в разделе "Планы и отчеты по статьям (спецификация)"
  */
(NRN number --рег. номер удаляемой записи
 ) as
  REC    UDO_T_PRJSTG_ARTCL_PLAN_SP%rowtype; --удаляемая запись
  SSQL   varchar2(4000); --динамический SQL для обновления таблицы помесячных планов
  SERR   varchar2(4000); --ошибка исполнения динамического SQL
  SMONTH varchar2(2); --номер месяца
  NCNT   number; --счетчик планов статьи
begin
  --считаем удаляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN_SP T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN_SP');
  end;
  --удалим данные из таблицы
  delete from UDO_T_PRJSTG_ARTCL_PLAN_SP T
   where T.RN = NRN;
  --исправим помесячные планы
  begin
    --посмотрим - сколько планов по данной статье в данном состоянии ещё осталось
    select count(T.RN)
      into NCNT
      from UDO_T_PRJSTG_ARTCL_PLAN_SP T
     where T.PRN = REC.PRN
       and T.PRJSTG_ARTCL = REC.PRJSTG_ARTCL
       and T.STATE = REC.STATE;
    --удалим данные в таблице помесячных планов, если больше нет таких статей в таком состоянии в данном плане
    if (NCNT = 0)
    then
      delete from UDO_T_PRJSTG_ARTCL_PLAN_MN T
       where T.PRN = REC.PRN
         and T.PRJSTG_ARTCL = REC.PRJSTG_ARTCL
         and T.STATE = REC.STATE;
    else
      --исправим планы, если такая статья ещё есть
      --определим месяц
      select TO_NUMBER(TO_CHAR(P.STARTDATE
                              ,'mm'))
        into SMONTH
        from ENPERIOD P
       where P.RN = REC.PERIOD;
      --сформируем и исполним запрос для исправления таблицы помесячных планов
      SSQL := 'update UDO_T_PRJSTG_ARTCL_PLAN_MN t set t.SUMM_' || SMONTH ||
              '=0 where T.PRN = :1 and T.PRJSTG_ARTCL = :2 and T.STATE = :3';
      execute immediate SSQL
        using REC.PRN, REC.PRJSTG_ARTCL, REC.STATE;
    end if;
  exception
    when others then
      SERR := sqlerrm;
      P_EXCEPTION(0
                 ,'Ошибка удаления помесячных планов: ' || SERR);
  end;
end UDO_P_PRJSTG_ARTCL_PL_SP_B_DEL;
/

