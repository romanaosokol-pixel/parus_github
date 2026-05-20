create or replace procedure UDO_P_MARK_COPY
/*
   Клиентское копирование в разделе "Показатели"
  */
(
  NCOMPANY        number --рег. номер организации
 ,NIDENT          number --идентификатор отмеченных записей
 ,SCRN            varchar2 --наименование каталога размещения копий
 ,SMARK_VERS      varchar2 --целевая версия
 ,SMARK_TYPE      varchar2 --целевой тип показателя (null - не менять)
 ,SMARK_FINSTATE  varchar2 --целевой вид фин. состояния (null - не менять)
 ,DDO_ACT_FROM    date --действует с (null - не менять)
 ,NMARK_DATE_YEAR number --год для даты показателя (null - не менять)
 ,NDATE_YEAR      number --год для дат начала и окончания периода показателя (null - не менять)
 ,NVAL_RESET      number --признак сброса значений в целевых показателях (1-сбросить, 0-не сбрасывать)
 ,NREWRITE        number --признак перезаписи существующих показателей
) as
begin
  --проверка прав каталоги, в которых расположены отмеченные документы:
  for CUR in (select distinct T.CRN
                             ,T.JUR_PERS
                from UDO_T_MARK T
               inner join SELECTLIST S
                  on S.DOCUMENT = T.RN
               where S.IDENT = NIDENT
                 and S.UNITCODE = 'Marks')
  loop
    PKG_ENV.ACCESS(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NJUR_PERS => CUR.JUR_PERS
                  ,NCATALOG  => CUR.CRN
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_COPY');
  end loop;
  --выполним копирование
  UDO_PKG_MARK.MARK_COPY(NCOMPANY        => NCOMPANY
                        ,NIDENT          => NIDENT
                        ,SCRN            => SCRN
                        ,SMARK_VERS      => SMARK_VERS
                        ,SMARK_TYPE      => SMARK_TYPE
                        ,SMARK_FINSTATE  => SMARK_FINSTATE
                        ,DDO_ACT_FROM    => DDO_ACT_FROM
                        ,NMARK_DATE_YEAR => NMARK_DATE_YEAR
                        ,NDATE_YEAR      => NDATE_YEAR
                        ,NVAL_RESET      => NVAL_RESET
                        ,NREWRITE        => NREWRITE);
end;
--grant execute on UDO_P_MARK_COPY to public;
/

