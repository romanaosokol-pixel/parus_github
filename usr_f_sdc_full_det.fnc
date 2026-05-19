create or replace function USR_F_SDC_FULL_DET
/*
Раздел "Распоряжения на отгрузку потребителям".
Функция для колонки "#Документ (Тип, №, дата)"
05/23/2023 Степанов М.
grant execute on USR_F_SDC_FULL_DET to public;
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
end USR_F_SDC_FULL_DET;
/
