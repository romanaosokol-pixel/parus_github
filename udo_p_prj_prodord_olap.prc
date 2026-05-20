create or replace procedure UDO_P_PRJ_PRODORD_OLAP(nCOMPANY in number, nIDENT in number) as
/*
  17/10/2022 Марков МВ.
  Многомерный отчет Проекты (производство)
  Процедура формирования
*/
begin
  insert into IDLIST(ID, HID) select IDENT, DOCUMENT from SELECTLIST where IDENT = nIDENT;
end;
/

