create or replace function usr_f_tid_get_valid_doc_str
/*
Функция для колонки "#Документ-основание (тип, №, дата)".
Раздел: Расходные накладные на отпуск в подразделения
14/03/2025 Степанов М.
grant execute on usr_f_tid_get_valid_doc_str to public;
*/
(
 sVALID_DOCTYPE   in varchar2
,sVALID_DOCNUMB   in varchar2
,dVALID_DOCDATE   in date
)
return varchar2
is
  sRes  pkg_std.tstring; 
begin
  if sVALID_DOCTYPE||trim(sVALID_DOCNUMB)||dVALID_DOCDATE is not null then
    sRes := sVALID_DOCTYPE||', '||trim(sVALID_DOCNUMB)||', '||to_char(dVALID_DOCDATE, 'dd.mm.yyyy');
  end if;
    
  return sRes;
end;
/
