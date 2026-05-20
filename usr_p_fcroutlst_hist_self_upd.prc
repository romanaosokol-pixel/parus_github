create or replace procedure usr_p_fcroutlst_hist_self_upd
(
  nrn            in udo_fcroutlst_hist.rn%type
 ,pin_clnpersons in clnpersons.rn%type
) is

  v_authid agnlist.pers_authid%type;
  n_fl     number(1);
begin

  begin
    select 1 into n_fl from udo_fcroutlst_hist t where t.rn = nrn;
  exception
    when no_data_found then
      n_fl := 0;
  end;

  p_exception(n_fl
             ,'Исправлять можно только записи начала/ окончания работ. Записи Формирования/печати править нельзя!');
begin
  select ag.pers_authid into v_authid from clnpersons cp join agnlist ag on ag.rn = cp.pers_agent where cp.rn = pin_clnpersons;
  exception
    when no_data_found then
      v_authid := UTILIZER;

end;
---P_EXCEPTION(0, pin_clnpersons);
  update udo_fcroutlst_hist t
     set t.clnperson   = pin_clnpersons
        ,t.authid      = nvl(v_authid, UTILIZER)
        ,t.author      = utilizer
        ,t.record_time = sysdate
        ,t.state_date  = sysdate
   where t.rn = nrn;

end;
/
