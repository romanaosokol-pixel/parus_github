create or replace function USR_F_TID_FULL_DET
/*
30/06/2022 Степанов М.
Раздел "Расходные накладные на отпуск в подразделения".
Функция для колонки "#Документ (Тип, №, дата)"
grant execute on USR_F_TID_FULL_DET to public;
*/
(
 sDOCTYPE     in varchar2
,sPREF_LTRIM  in varchar2
,sNUMB_LTRIM  in varchar2
,dDOCDATE     in date
)
return varchar2
as
begin
  return sDOCTYPE||', '||sPREF_LTRIM||'-'||sNUMB_LTRIM||', '||to_char(dDOCDATE, 'dd.mm.yyyy');
end USR_F_TID_FULL_DET;
/
