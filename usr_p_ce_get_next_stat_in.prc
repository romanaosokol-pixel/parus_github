create or replace procedure usr_p_ce_get_next_stat_in
/*
Для пользоваетельской формы процедуры "Переход события в следующий статус"
grant execute on USR_P_CE_GET_NEXT_STAT_IN to public;
*/
(
 nRN              in number
,sUNITCODE        in varchar2
,nCOMPANY         in number
,sATRIB           in varchar2
,sEVENT_STAT      out varchar2
,sEVENT_STAT_LIST in out varchar2
)
is
  rV_ClnEvents v_clnevents%rowtype;

  sREZ            pkg_std.tlstring;
  n               pkg_std.tnumber := 0;
begin
    p_unitstmod_get_event(sunitcode       => sUNITCODE
                         ,ndocument       => nRN
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

    for st in (select t.snext_point
                     ,t.snext_point_name
                 from v_evrtptpass t
                where ncompany      = nCOMPANY
                  and sevent_type   = rV_ClnEvents.sevent_type
                  and sevent_status = rV_ClnEvents.sevent_stat
                  and nforce_only   = 0
                order by snext_point)
    loop
      n := n + 1;
      if n = 1 then
        srez := 'select' || '''' || st.snext_point || ''' from dual';
      else
        srez := srez || ' union ' || 'select' || '''' || st.snext_point || ''' from dual';
      end if;
    end loop;

    sEVENT_STAT_LIST := sREZ;
    sEVENT_STAT      := '';

end;
/
