create or replace procedure usr_p_fcroutlst_hist_upd_ini
(
  nrn            in udo_fcroutlst_hist.rn%type
 ,out_clnpersons out clnpersons.rn%type
 ,out_fullname   out agnlist.agnname%type
  
) is

begin

  begin
    select t.clnperson
          ,ag.agnname
      into out_clnpersons
          ,out_fullname
      from udo_fcroutlst_hist t
      join clnpersons cp
        on cp.rn = t.clnperson
      join agnlist ag
        on ag.rn = cp.pers_agent
     where t.rn = nrn;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Исправлять можно только записи начала/ окончания работ. Записи Формирования/печати править нельзя!');
  end;

end;
/
