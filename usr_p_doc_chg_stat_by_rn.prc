create or replace procedure usr_p_doc_chg_stat_by_rn
/*
Все документы.
Переход события в следующий статус по RN документа
*/
(
 sRN              in varchar2
,nCOMPANY         in number
,sUNITCODE        in varchar2
,sEVENT_STAT      in varchar2
,sEVENT_STAT_NAME in varchar2
,sSEND_PERSON     in varchar2
)
is
  rV_ClnEvents    v_clnevents%rowtype;
begin
  /* Реквизиты события */
  p_unitstmod_get_event(sunitcode       => sUNITCODE
                       ,ndocument       => to_number(sRN)
                       ,nevent          => rV_ClnEvents.nrn
                       ,nevent_type     => rV_ClnEvents.nevent_type
                       ,sevent          => rV_ClnEvents.sevent_numb
                       ,sevent_type     => rV_ClnEvents.sevent_type
                       ,nevent_stat     => rV_ClnEvents.nevent_stat
                       ,sevent_stat     => rV_ClnEvents.sevent_stat
                       ,sinit_person    => rV_ClnEvents.sinit_person
                       ,sinit_authname  => rV_ClnEvents.sinit_authname
                       ,sclient_client  => rV_ClnEvents.sclient_client
                       ,sclient_person  => rV_ClnEvents.sclient_person
                       ,ssend_person    => rV_ClnEvents.ssend_person
                       ,ssend_user_name => rV_ClnEvents.ssend_user_name
                       ,npoint          => rV_ClnEvents.npoint
                       ,nclosed         => rV_ClnEvents.nclosed);
  /* Переход в следующий статус */
  p_clnevents_change_state(ncompany         => nCOMPANY
                          ,nrn              => rV_ClnEvents.nrn
                          ,sevent_stat      => sEVENT_STAT
                          ,ssend_client     => rV_ClnEvents.ssend_client    
                          ,ssend_division   => rV_ClnEvents.ssend_division  
                          ,ssend_post       => rV_ClnEvents.ssend_post      
                          ,ssend_perform    => rV_ClnEvents.ssend_perform   
                          ,ssend_person     => nvl(sSEND_PERSON, rV_ClnEvents.ssend_person)
                          ,ssend_staffgrp   => rV_ClnEvents.ssend_staffgrp  
                          ,ssend_user_group => rV_ClnEvents.ssend_user_group
                          ,ssend_user_name  => rV_ClnEvents.ssend_user_name );
end;
/
