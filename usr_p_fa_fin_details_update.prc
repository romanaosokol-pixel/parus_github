create or replace procedure USR_P_FA_FIN_DETAILS_UPDATE
/*
Лицевые счета. 
Исправить финансовые параметры в лицевом счёте и документах
13/09/2024 Степанов М.
*/
(
 nRN         in number
,nFLAGSMART  in number
,sFPDARTCL   in varchar
)
is
  rRow        faceacc%rowtype;
  nFPDArtcl   pkg_std.tref; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_FA_FIN_DETAILS_UPDATE');

  /* Считывание текущего лицевого счёта */
  rRow := usr_pkg_faceacc.faceacc_get(nrn => nRN);

  /* RN статьи из параметра */
  find_fpdartcl_code(nflag_smart => 0, ncompany => rRow.company, scode => sFPDARTCL, nrn => nFPDArtcl);

  /* Исправление */
  usr_pkg_faceacc.faceacc_fin_details_update(rrow => rRow, nflagsmart => nFLAGSMART, nfpdartcl => nFPDArtcl);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_FA_FIN_DETAILS_UPDATE;
/
