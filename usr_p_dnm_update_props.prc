create or replace procedure USR_P_DNM_UPDATE_PROPS
/*
Процедура для действия "Исправить свойства"
Раздел: Номенклатор
create public synonym USR_P_DNM_UPDATE_PROPS for USR_P_DNM_UPDATE_PROPS;
grant execute on USR_P_DNM_UPDATE_PROPS to public;
*/
(
 nRN          in number
,nCOMPANY     in number
,sUNITCODE    in varchar2
,sSPECS       in varchar2
)
as
  rDicNomns   dicnomns%rowtype;

  nNumber   pkg_std.tnumber;
  dDate     date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DNM_UPDATE_PROPS');

  /* считывание записи */
  rDicNomns := usr_pkg_dicnomns.dicnomns_get(nrn => nRN);

  /* проверка прав доступа */
  pkg_env.prologue(ncompany  => nCOMPANY
                  ,nversion  => rDicNomns.version
                  ,ncatalog  => rDicNomns.crn
                  ,njur_pers => null
                  ,sunit     => 'Nomenclator'
                  ,saction   => 'NOMEN_UPDATE_PROPS'
                  ,stable    => 'DICNOMNS'
                  ,ndocument => rDicNomns.rn);

  /* фиксация окончания выполнение действия */
  pkg_env.epilogue(ncompany  => nCOMPANY
                  ,nversion  => rDicNomns.version
                  ,ncatalog  => rDicNomns.crn
                  ,njur_pers => null
                  ,sunit     => 'Nomenclator'
                  ,saction   => 'NOMEN_UPDATE_PROPS'
                  ,stable    => 'DICNOMNS'
                  ,ndocument => rDicNomns.rn);

  /* исправление */
  pkg_docs_props_vals.modify(nproperty   => 101698142
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => rDicNomns.rn
                            ,sstr_value  => sSPECS
                            ,nnum_value  => nNumber
                            ,ddate_value => dDate
                            ,nrn         => nNumber);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end;
/
