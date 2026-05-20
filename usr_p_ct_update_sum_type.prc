create or replace procedure USR_P_CT_UPDATE_SUM_TYPE
/*
30/08/2023 Степанов М.
Исправление признака "Расчёт суммы" в договоре на значение "Да". 
*/
(
 nRN            in number
)
IS
  nSUM_TYPE      pkg_std.tnumber := 1; 
  sDICTAXGR      pkg_std.tstring := null; 
  nSUM           pkg_std.tnumber := null; 

  rRow          contracts%rowtype;
  nDicTaxGr     pkg_std.tref;
BEGIN
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_CT_UPDATE_SUM_TYPE');

  /* Запись договора */
  rRow := usr_pkg_contracts.contracts_get(nrn => nRN);
  /* Пролог */
  pkg_env.prologue(ncompany   => rRow.company
                  ,nversion   => null
                  ,ncatalog   => rRow.crn
                  ,njur_pers  => rRow.jur_pers
                  ,nhierarchy => null
                  ,sunit      => 'Contracts'
                  ,saction    => 'CONTRACTS_UPDATE'
                  ,stable     => 'CONTRACTS'
                  ,ndocument  => rRow.rn);
  /* Налоговая группа */
  if sDICTAXGR is not null then
    find_dictaxgr_code(nflag_smart => 0
                      ,ncompany    => rRow.company
                      ,scode       => sDICTAXGR
                      ,nrn         => nDicTaxGr);
  end if;
  /* Исправление */
  usr_pkg_contracts.contracts_update_sum_type(nflagsmart => 0
                                             ,nrn        => rRow.rn
                                             ,nsum_type  => nSUM_TYPE
                                             ,ntaxgr     => nDicTaxGr
                                             ,nsum       => nSUM);
  /* Эпилог */
  pkg_env.epilogue(ncompany   => rRow.company
                  ,nversion   => null
                  ,ncatalog   => rRow.crn
                  ,njur_pers  => rRow.jur_pers
                  ,nhierarchy => null
                  ,sunit      => 'Contracts'
                  ,saction    => 'CONTRACTS_UPDATE'
                  ,stable     => 'CONTRACTS'
                  ,ndocument  => rRow.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_CT_UPDATE_SUM_TYPE;
/
