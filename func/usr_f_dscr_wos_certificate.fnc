create or replace function USR_F_DSCR_WOS_CERTIFICATE
/*
Раздел Акты списания недостач/оприходования излишков
Функция для колонки "#Сертификат" в
03/10/2023 Степанов М.
grant execute on USR_F_DSCR_WOS_CERTIFICATE to public;
*/
(
 sCERTIFICATE  in varchar2
)
return varchar2
is
begin
  return sCERTIFICATE;
end USR_F_DSCR_WOS_CERTIFICATE;
/
