create or replace function USR_F_FA_GET_STATUS_BY_RN
/*
Функция возвращает статус лицевого счёта
26/04/2024 Степанов М.
grant execute on USR_F_FA_GET_STATUS_BY_RN to public;
*/
(
 nFACEACCOUNT  in number
)
return varchar2
is
  sRes    pkg_std.tstring; 
begin
  for c in (select usr_pkg_faceacc.faceacc_get_status_name(dfact_open_date => fact_open_date, dfact_close_date => fact_close_date) as sStatus
              from faceacc
             where rn = nFACEACCOUNT)
  loop
    sRes := c.sStatus;
  end loop;

  return sRes;
  
end USR_F_FA_GET_STATUS_BY_RN;
/
