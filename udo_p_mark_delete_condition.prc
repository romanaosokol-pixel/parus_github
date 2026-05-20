create or replace procedure UDO_P_MARK_DELETE_CONDITION
/*
   Клиентское удаление по условию в разделе "Показатели"
  */
(
  NCOMPANY       in number -- рег. номер организации
 ,NCRN           in number -- рег. номер каталога
 ,SJUR_PERS      in varchar2 -- юр. лицо
 ,SMARK_TYPE     in varchar2 -- тип показателя
 ,SMARK_VERS     in varchar2 -- версия показателя
 ,SMARK_FINSTATE in varchar2 -- фин. состояние показателя
 ,DDO_ACT_FROM   in date -- действует с
) is
  NJUR_PERS number; -- рег. номер юр. лица
begin
  --рег. номер юр. лица
  FIND_JURPERSONS_CODE(NFLAG_SMART  => 0
                      ,NFLAG_OPTION => 0
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => SJUR_PERS
                      ,NRN          => NJUR_PERS);
  --проверка прав доступа
  PKG_ENV.ACCESS(NCOMPANY  => NCOMPANY
                ,NVERSION  => null
                ,NCATALOG  => NCRN
                ,NJUR_PERS => NJUR_PERS
                ,SUNIT     => 'Marks');
  --выполним удаление             
  UDO_PKG_MARK.MARK_DELETE_CONDITION(NCOMPANY       => NCOMPANY
                                    ,SJUR_PERS      => SJUR_PERS
                                    ,SMARK_TYPE     => SMARK_TYPE
                                    ,SMARK_VERS     => SMARK_VERS
                                    ,SMARK_FINSTATE => SMARK_FINSTATE
                                    ,DDO_ACT_FROM   => DDO_ACT_FROM);
end;
--grant execute on UDO_P_MARK_DELETE_CONDITION to public;
/

