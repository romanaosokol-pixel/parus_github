create or replace procedure USR_P_DOC_UPDATE_CE_INIT
/*
Документы. Исправить инициатора события
24/06/2024 Степанов М.
*/
(
 nRN            in number
,nCOMPANY       in number
,sAGNLIST       in varchar2
)
is
  nAgnList      pkg_std.tref; 
  nClnPersons   pkg_std.tref; 
  rClnPersons   clnpersons%rowtype;
  nClnEvents    pkg_std.tref; 
  rClnEvents    clnevents%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DOC_UPDATE_CE_INIT');

  /* Контрагент. RN */
  find_agnlist_code(nflag_smart  => 0
                   ,nflag_option => 0
                   ,ncompany     => nCOMPANY
                   ,scode        => sAGNLIST
                   ,nrn          => nAgnList);
  /* Сотрудник */
  find_clnpersons_by_agent(nflag_smart => 0
                          ,ncompany    => nCOMPANY
                          ,nagent      => nAgnList
                          ,ddate       => sysdate
                          ,nclnpersons => nClnPersons);
  rClnPersons := udo_pkg_get.row_clnpersons(nrn => nClnPersons, nsmart => 0);
  /* Проверка логина сотрудника */
  if rClnPersons.Pers_Authid is null then
    p_exception(0, 'У сотрудника <%s> не задано имя пользователя.%s'
               ,rClnPersons.code
               ,cr||f_docdescrs_get_description(sunitcode => 'ClientPersons', ndocument => rClnPersons.Rn) ); 
  end if;

  /* Событие */
  nClnEvents := usr_pkg_document.get_clnevents(nflagsmart => 0, nrn => nRN);
  rClnEvents := usr_pkg_clnevents.clnevents_get(nrn => nClnEvents);

  /* Подмена инициатора */
  rClnEvents.Action_Code := 'CLNEVENTS_UPDATE';
  rClnEvents.Init_Person := rClnPersons.Rn;
  rClnEvents.Init_Authid := rClnPersons.Pers_Authid;

  /* Исправление события */
  usr_pkg_clnevents.clnevents_base_update(rRow => rClnEvents, slinked_action => 'CLNEVENTS_UPDATE', nmode => 1);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
