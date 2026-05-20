create or replace procedure USR_P_ST_FIN_DETAILS_UPDATE
/*
Договоры (этапы).
Исправить финансовые параметры в этапе и документах
13/09/2024 Степанов М.
*/
(
 nRN        in number
,nFLAGSMART in number
,sFPDARTCL  in varchar
)
is
  rRow      stages%rowtype;
  rFaceAcc  faceacc%rowtype;
  nFpdArtcl pkg_std.tref;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_ST_FIN_DETAILS_UPDATE');

  /* Считывание текущего этапа */
  rRow     := usr_pkg_contracts.stages_get(nrn => nRN);
  rFaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rRow.faceacc);

  /* RN статьи из параметра */
  find_fpdartcl_code(nflag_smart => 0
                    ,ncompany    => rFaceAcc.company
                    ,scode       => sFPDARTCL
                    ,nrn         => nFpdArtcl);

  /* Исправляем лицевой счёт */
  usr_pkg_faceacc.faceacc_fin_details_update(rrow       => rFaceAcc
                                            ,nflagsmart => nFLAGSMART
                                            ,nfpdartcl  => nFpdArtcl);
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_ST_FIN_DETAILS_UPDATE;
/
