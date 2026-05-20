create or replace procedure USR_P_DOCS_UPDATE_NOTE_PROP
/*
Раздел: Все документы
Исправить свойство "Примечание"
*/
(
 nRN       in number
,nCOMPANY  in number
,sUNITCODE in varchar2
,sNOTE     in varchar2
) 
as
  nNumber pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DOCS_UPDATE_NOTE_PROP');

  /* Если раздел, в котором запрещается исправлять документ со связями */
  if sUNITCODE in ('CostProductExpenseActs') then
    /* Перенос связей на фиктивный документ */
    usr_pkg_doclinks.doclinks_reset(nflagsmart => 0
                                   ,ncompany   => nCOMPANY
                                   ,nrn        => nRN
                                   ,sunitcode  => sUNITCODE
                                   ,nmode      => 0);
  end if;

  /* Исправление */
  pkg_docs_props_vals.modify(nproperty   => 121124504
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => sNOTE
                            ,nnum_value  => null
                            ,ddate_value => null
                            ,nrn         => nNumber);

  /* Если раздел, в котором запрещается исправлять документ со связями */
  if sUNITCODE in ('CostProductExpenseActs') then
    /* Возврат связей с фиктивного документа */
    usr_pkg_doclinks.doclinks_reset(nflagsmart => 0
                                   ,ncompany   => nCOMPANY
                                   ,nrn        => nRN
                                   ,sunitcode  => sUNITCODE
                                   ,nmode      => 1);
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_DOCS_UPDATE_NOTE_PROP;
/
