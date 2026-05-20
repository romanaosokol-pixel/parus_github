create or replace procedure usr_p_t_finplan_svod_cre(ncompany   in number
                                                    ,ssfp_type  in varchar2 /* Тип бюджета */
                                                    ,sfp_period in varchar2 /* Период */
                                                    ,sgroupbudg in varchar2 /* Группа бюджета */) is
  nrnz     pkg_std.tlnumber;
  nidenter number(17);
  nfirst   number(1);
begin

  -- сохраним контейнер
  nfirst := pkg_contvaraut.getn(scontainer => 'FINPLAN_SVOD_CRE', sname => 'NFIRST');

  if nvl(nfirst, 1) = 1
  then
  
    pkg_contvaraut.putn(scontainer => 'FINPLAN_SVOD_CRE', sname => 'NFIRST', nvalue => 2);
  
    nidenter := gen_ident;
  
    pkg_contvaraut.putn(scontainer => 'FINPLAN_SVOD_CRE', sname => 'NIDENTER', nvalue => nidenter);
  
    for cur in (select bj.rn
                  from udo_t_finplan bj
                  join enperiod per
                    on per.rn = bj.fp_period
                   and per.company = bj.company
                  join dicsmrks gb
                    on gb.rn = bj.groupbudg
                  join compverlist v
                    on v.company = bj.company
                   and v.version = gb.version
                   and v.unitcode = 'SpecialMarks'
                  join doctypes dt
                    on dt.rn = bj.fp_type
                 where bj.company = ncompany
                   and per.code = sfp_period
                   and gb.smark_mnemo = sgroupbudg
                   and dt.doccode = ssfp_type
                
                )
    
    loop
      /* Запишем отобранные документы в селектлист */
      p_selectlist_base_insert(nident       => nidenter
                              ,ncompany     => ncompany
                              ,ndocument    => cur.rn
                              ,sunitcode    => 'FinPlan'
                              ,sactioncode  => null
                              ,ncrn         => null
                              ,ndocument1   => null
                              ,sunitcode1   => null
                              ,sactioncode1 => null
                              ,nrn          => nrnz);
    
    end loop;
  
  else
    /* Очищаем Selectlist  на втором шаге */
    p_selectlist_clear(nident => nidenter);
  end if;

end;
/
