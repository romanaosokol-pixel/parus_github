CREATE OR REPLACE PROCEDURE USR_P_STAGES_UPD_SUM_TYPE
/*
Исправление признака "Расчёт суммы" на этапе договора. Степанов М. 09/04/2021

-- Форма JScript

для параметра SSUM_TYPE запрос: 
select 'Вручную' AS SSUM_TYPE from DUAL 
UNION 
select 'По спецификации' AS SSUM_TYPE from DUAL 
UNION 
select 'По платежам' AS SSUM_TYPE from DUAL
И ПОСТАВИТЬ ГАЛОЧКУ АВТОМАТИЧЕСКИ ОТКРЫВАТЬ, ЧТОБЫ ЗАПРОС СРАБАТЫВАЛ!!!
*/
(
 nRN            in number
,sSUM_TYPE      in varchar2
,sDICTAXGR      in varchar2
,nSUM           in number
)
IS
  rRow          stages%rowtype;
  nDicTaxGr     pkg_std.tref; 
BEGIN
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_STAGES_UPD_SUM_TYPE');

  /* Запись договора */
  rRow := usr_pkg_contracts.stages_get(nrn => nRN);

  /* Проверки параметров */
  case sSUM_TYPE 
    when 'Вручную' then
      if sDICTAXGR is null or nSUM is null then
        p_exception(0, 'Для расчёта суммы <%s> должны быть заполнены параметры "Налоговая группа" и "Сумма". %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => rRow.rn)); 
      end if;
    when 'По спецификации' then
      if sDICTAXGR is not null or nSUM is not null then
        p_exception(0, 'Для расчёта суммы <%s> НЕ должны быть заполнены параметры "Налоговая группа" и "Сумма". %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => rRow.rn)); 
      end if;
  else
    p_exception(0, 'Недопустимое значение <%s> параметра <sSUM_TYPE>. %s'
               ,cr||sSUM_TYPE 
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => rRow.rn)); 
  end case;    

  /* Пролог */
  pkg_env.prologue(ncompany   => rRow.company
                  ,nversion   => null
                  ,ncatalog   => rRow.crn
                  ,njur_pers  => rRow.jur_pers
                  ,nhierarchY => null
                  ,sunit      => 'ContractsStages'
                  ,saction    => 'STAGES_UPDATE'
                  ,stable     => 'STAGES'
                  ,ndocument  => rRow.rn);
  /* Налоговая группа */
  if sDICTAXGR is not null then
    find_dictaxgr_code(nflag_smart => 0
                      ,ncompany    => rRow.company
                      ,scode       => sDICTAXGR
                      ,nrn         => nDicTaxGr);
  end if;            
  /* Исправление */
  usr_pkg_contracts.stages_update_sum_type(nflagsmart => 0
                                          ,nrn        => rRow.rn
                                          ,nsum_type  => case sSUM_TYPE 
                                                           when 'Вручную'          then 0 
                                                           when 'По спецификации'  then 1 
                                                           when 'По платежам'      then 2 
                                                         end
                                          ,ntaxgr     => nDicTaxGr
                                          ,nsum       => nSUM);
  /* Эпилог */
  pkg_env.epilogue(ncompany   => rRow.company
                  ,nversion   => null
                  ,ncatalog   => rRow.crn
                  ,njur_pers  => rRow.jur_pers
                  ,nhierarchy => null
                  ,sunit      => 'ContractsStages'
                  ,saction    => 'STAGES_UPDATE'
                  ,stable     => 'STAGES'
                  ,ndocument  => rRow.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
END USR_P_STAGES_UPD_SUM_TYPE;
/
