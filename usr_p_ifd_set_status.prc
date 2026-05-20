create or replace procedure USR_P_IFD_SET_STATUS
/*
Раздел: "Приход из подразделений"
Процедура: Отработать.
30/01/2024 Степанов М.
*/
(
 nRN              in number
,dDATE            in date
,nUSE_DOC_DATE    in number default 1 /* использовать дату документа: 0 - нет, 1 - да*/
,nAUTO_GEN_PARTY  in number default 0 /* автоматически генерировать партию: 0 - нет, 1 - да*/
)
is
  rRow                  incomefromdeps%rowtype;
  dWorkDate             date;
  nOptionsCurrentVal    pkg_std.tnumber; 
  
  nNumber               pkg_std.tnumber;   
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IFD_SET_STATUS');

  /* Проверка параметров */
  if nUSE_DOC_DATE not in (0, 1) then
    p_exception(0, 'Неверное значение <%s> параметра <nUSE_DOC_DATE>', nUSE_DOC_DATE); 
  end if;
  if nAUTO_GEN_PARTY not in (0, 1) then
    p_exception(0, 'Неверное значение <%s> параметра <nAUTO_GEN_PARTY>', nAUTO_GEN_PARTY); 
  end if;
  
  /* Запись */
  rRow := usr_pkg_incomefromdeps.incomefromdeps_get(nrn => nRN);

  /* Дата отработки */
  /* если не задана, то текущая */
  dWorkDate := nvl(dDATE, sysdate);
  /* если использовать дату документа */
  if nvl(nUSE_DOC_DATE, 0) = 1 then
    dWorkDate := rRow.doc_date;
  end if;
  
  /* Исходное значение настройки */
  nOptionsCurrentVal := f_options_number_value( nopt_type      => null
                                               ,nopt_kind      => null
                                               ,sunitcode      => null
                                               ,nshare_kind    => null
                                               ,scode          => 'Realiz_InFDeps_MakeParty'
                                               ,ndefault_value => null );

  /* Параметр "автоматически генерировать партию" не равен исходному значению настройки */
  if nAUTO_GEN_PARTY != nOptionsCurrentVal and nAUTO_GEN_PARTY is not null and nOptionsCurrentVal is not null then
    /* Исправление настройки значением параметра */
    usr_pkg_common.options_set( scode       => 'Realiz_InFDeps_MakeParty'
                               ,sauthid     => utilizer
                               ,ncompany    => rRow.company
                               ,sstr_value  => null
                               ,nnum_value  => nAUTO_GEN_PARTY
                               ,ddate_value => null
                               ,nrn         => nNumber );
  end if;

  /* Отработка */
  p_incomefromdeps_set_status(ncompany  => rRow.company
                             ,nrn       => rRow.rn
                             ,nident    => null
                             ,nstatus   => 2
                             ,dworkdate => dWorkDate
                             ,nwarning  => rRow.rn
                             ,smsg      => rRow.note
                             ,nshow_msg => rRow.rn);

  /* Параметр "автоматически генерировать партию" не равен исходному значению настройки */
  if nAUTO_GEN_PARTY != nOptionsCurrentVal and nAUTO_GEN_PARTY is not null and nOptionsCurrentVal is not null then
    /* Исправление настройки исходным значением */
    usr_pkg_common.options_set( scode       => 'Realiz_InFDeps_MakeParty'
                               ,sauthid     => utilizer
                               ,ncompany    => rRow.company
                               ,sstr_value  => null
                               ,nnum_value  => nOptionsCurrentVal
                               ,ddate_value => null
                               ,nrn         => nNumber );
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end USR_P_IFD_SET_STATUS;
/
