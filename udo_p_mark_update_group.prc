create or replace procedure UDO_P_MARK_UPDATE_GROUP
/*
   Клиентское массовое исправление записей в разделе "Показатели"
  */
(
  NIDENT            number --идетификатор отмеченных записей
 ,NCH_MARK_VERS     number --признак необходимости изменения "версии" показателя (см. константы NCH*)
 ,SMARK_VERS        varchar2 --версия показателя
 ,NCH_MARK_DATE     number --признак необходимости изменения "даты" показателя (см. константы NCH*)
 ,DMARK_DATE        date --дата показателя
 ,NCH_STATE_DATE    number --признак необходимости изменения дата показателя "по состоянию на" (см. константы NCH*)
 ,DSTATE_DATE       date --дата показателя "по состоянию на"
 ,NCH_DO_ACT_FROM   number --признак необходимости изменения "действует с" показателя (см. константы NCH*)
 ,DDO_ACT_FROM      date --действует с
 ,NCH_DO_ACT_TO     number --признак необходимости изменения "действует по" показателя (см. константы NCH*)
 ,DDO_ACT_TO        date --действует по
 ,NCH_DATE_FROM     number --признак необходимости изменения "периода с" показателя (см. константы NCH*)
 ,DDATE_FROM        date --период с
 ,NCH_DATE_TO       number --признак необходимости изменения "периода по" показателя (см. константы NCH*)
 ,DDATE_TO          date --период по
 ,NCH_FINSTATE      number --признак необходимости изменения "состояния" показателя (см. константы NCH*)
 ,SFINSTATE         varchar2 --состояние
 ,NCH_FPDARTCL      number --признак необходимости изменения "статьи" показателя (см. константы NCH*)
 ,SFPDARTCL         varchar2 --статья
 ,NCH_COST_FPDARTCL number --признак необходимости изменения "статьи затрат" показателя (см. константы NCH*)
 ,SCOST_FPDARTCL    varchar2 --статья затрат
 ,NCH_COST_GR       number --признак необходимости изменения "группы затрат" показателя (см. константы NCH*)
 ,SCOST_GR          varchar2 --группа затрат
 ,NCH_VAL           number --признак необходимости изменения "значение" показателя (см. константы NCH*)
 ,NVAL              number --значение
 ,NCH_VAL_MOD       number --признак необходимости изменения "значение (измененное)" показателя (см. константы NCH*)
 ,NVAL_MOD          number --значение (измененное)
) is
begin
  --исправим запись
  UDO_PKG_MARK.MARK_UPDATE_GROUP(NIDENT            => NIDENT
                                ,NCH_MARK_VERS     => NCH_MARK_VERS
                                ,SMARK_VERS        => SMARK_VERS
                                ,NCH_MARK_DATE     => NCH_MARK_DATE
                                ,DMARK_DATE        => DMARK_DATE
                                ,NCH_STATE_DATE    => NCH_STATE_DATE
                                ,DSTATE_DATE       => DSTATE_DATE
                                ,NCH_DO_ACT_FROM   => NCH_DO_ACT_FROM
                                ,DDO_ACT_FROM      => DDO_ACT_FROM
                                ,NCH_DO_ACT_TO     => NCH_DO_ACT_TO
                                ,DDO_ACT_TO        => DDO_ACT_TO
                                ,NCH_DATE_FROM     => NCH_DATE_FROM
                                ,DDATE_FROM        => DDATE_FROM
                                ,NCH_DATE_TO       => NCH_DATE_TO
                                ,DDATE_TO          => DDATE_TO
                                ,NCH_FINSTATE      => NCH_FINSTATE
                                ,SFINSTATE         => SFINSTATE
                                ,NCH_FPDARTCL      => NCH_FPDARTCL
                                ,SFPDARTCL         => SFPDARTCL
                                ,NCH_COST_FPDARTCL => NCH_COST_FPDARTCL
                                ,SCOST_FPDARTCL    => SCOST_FPDARTCL
                                ,NCH_COST_GR       => NCH_COST_GR
                                ,SCOST_GR          => SCOST_GR
                                ,NCH_VAL           => NCH_VAL
                                ,NVAL              => NVAL
                                ,NCH_VAL_MOD       => NCH_VAL_MOD
                                ,NVAL_MOD          => NVAL_MOD);
end;
--grant execute on UDO_P_MARK_UPDATE_GROUP to public;
/

