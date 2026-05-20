create or replace procedure USR_P_FACEACC_ALLOC_ARTS_SET(nrn in number, nstep in number, sPeriod in varchar2, sunit in varchar2) is
begin

  /*
  
  Процедура задает подстатью бюджета для лицевого счета этапа договора
  
  1. На первом шаге сохраняем в переменную лицевой счет этапа
  
  Затем открываем раздел "Бюджетное распределение Детализация подстатьи"
  
  2. Записываем/редактируем  заданный бюджет в таблицу . Лицевой счет берем в валидаторе из сохранения
  
  */
case nstep when 1 then   
  
USR_PKG_PUB_CONST.nNumber := nrn;
USR_PKG_PUB_CONST.sVarchar:=sPeriod;
USR_PKG_PUB_CONST.sUnitCode:= sunit;

else 

USR_PKG_PUB_CONST.nNumber := null;
USR_PKG_PUB_CONST.sVarchar:=null;
USR_PKG_PUB_CONST.sUnitCode:= null;

end case;


end;
/
