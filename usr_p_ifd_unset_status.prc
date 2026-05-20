create or replace procedure USR_P_IFD_UNSET_STATUS
/*
Раздел: "Приход из подразделений"
Процедура: Снять отработку.
30/01/2024 Степанов М.
*/
(
 nRN              in number
,nCOMPANY         in number
)
is
  nNumber     pkg_std.tnumber;
  sVarchar    pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IFD_UNSET_STATUS');

  /* Удаление дополнительных данных приходной партии из раздела Сертификаты в приходных партиях спецификаций */
  for c in (select distinct crts.prn
              from incomefromdepsspec t
                  ,goodssupply        gs
                  ,certificationsp    crts
             where t.prn      = nRN
               and gs.rn      = t.supply
               and crts.party = gs.prn)
  loop
    p_certification_base_delete(ncompany => nCOMPANY, nrn => c.prn);
  end loop;

  /* Снятие отработки */
  p_incomefromdeps_set_status(ncompany  => nCOMPANY
                             ,nrn       => nRN
                             ,nident    => null
                             ,nstatus   => 0
                             ,dworkdate => current_date
                             ,nwarning  => nNumber
                             ,smsg      => sVarchar
                             ,nshow_msg => nNumber);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IFD_UNSET_STATUS;
/
