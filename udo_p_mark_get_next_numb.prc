create or replace procedure UDO_P_MARK_GET_NEXT_NUMB
/*
   –асчет очередного номера документа в разделе "ѕоказатели"
  */
(
  NCOMPANY   number --рег. номер организации
 ,SJUR_PERS  varchar2 --юр. лицо
 ,SMARK_TYPE varchar2 --тип показател€
 ,SMARK_PREF varchar2 --префикс
 ,SMARK_NUMB out varchar2 --расчитанный номер
) is
begin
  --выполним расчет
  UDO_PKG_MARK.MARK_GET_NEXT_NUMB(NCOMPANY   => NCOMPANY
                                 ,SJUR_PERS  => SJUR_PERS
                                 ,SMARK_TYPE => SMARK_TYPE
                                 ,SMARK_PREF => SMARK_PREF
                                 ,SMARK_NUMB => SMARK_NUMB);
end;
--grant execute on UDO_P_MARK_GET_NEXT_NUMB to public;
/

