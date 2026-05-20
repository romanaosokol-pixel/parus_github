create or replace procedure UDO_P_REP_PRODUCTION_SCHEDULE(
       nIDENT in number --идентификатор помеченных записей -- Договор
)
--Процедура для отчета "График изготовления и поставки"
as

begin
  
UDO_PKG_PRODUCTION_SCHEDULE.REP_PRODUCTION_SCHEDULE(
            nIDENT => nIDENT
);


end UDO_P_REP_PRODUCTION_SCHEDULE;
/

