create or replace procedure usr_p_project_props_modif(nrn          in number
                                                     ,protype_old  in varchar2
                                                     ,zam_gd_old   in varchar2
                                                     ,sotr_peo_old in varchar2
                                                     ,tkpa_old     in varchar2
                                                     ,protype      in varchar2
                                                     ,zam_gd       in varchar2
                                                     ,sotr_peo     in varchar2
                                                     ,tkpa         in varchar2) is
  nfl   integer;
  newrn number(17);

  procedure contracts_chg(sv_code in varchar2
                         ,sv_sval in varchar) is
    /* Изменение свойства в связнном договоре */
  begin
  
    for d in (select dl.out_document drn
                from doclinks dl
                join contracts dog
                  on dog.rn = dl.out_document
                 and dl.out_unitcode = 'Contracts'
               where dl.in_document = nrn)
    loop
    
      pkg_docs_props_vals.modify(sproperty   => sv_code
                                ,sunitcode   => 'Contracts'
                                ,ndocument   => d.drn
                                ,sstr_value  => sv_sval
                                ,nnum_value  => null
                                ,ddate_value => null
                                ,nrn         => newrn);
    
    end loop;
  
  end;

begin
  /*Пользователь имеет роль ВСЕ права или Управлене Финансами*/

  begin
    select 1
      into nfl
      from userroles ur
      join roles r
        on r.rn = ur.roleid
     where ur.authid = utilizer
       and r.rolename in ('Все права', 'Управление Финансами');
  
  end;

  p_exception(nfl
             ,'Менять свойство может только пользователь с ролью "Управление Финансами"');

  if cmp_vc2(protype_old, protype) = 0
  then
    pkg_docs_props_vals.modify(sproperty   => 'PrProductType'
                              ,sunitcode   => 'Projects'
                              ,ndocument   => nrn
                              ,sstr_value  => protype
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => newrn);
  
    contracts_chg('PrProductType', protype);
  
  end if;

  if cmp_vc2(zam_gd_old, zam_gd) = 0
  then
    pkg_docs_props_vals.modify(sproperty   => 'Заместитель ГД'
                              ,sunitcode   => 'Projects'
                              ,ndocument   => nrn
                              ,sstr_value  => zam_gd
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => newrn);
    contracts_chg('Заместитель ГД', zam_gd);
  
  end if;

  if cmp_vc2(sotr_peo_old, sotr_peo) = 0
  then
  
    pkg_docs_props_vals.modify(sproperty   => 'Сотрудник'
                              ,sunitcode   => 'Projects'
                              ,ndocument   => nrn
                              ,sstr_value  => sotr_peo
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => newrn);
  
    contracts_chg('Сотрудник', sotr_peo);
  
  end if;

  if cmp_vc2(tkpa_old, tkpa) = 0
  then
    pkg_docs_props_vals.modify(sproperty   => 'ТКПА'
                              ,sunitcode   => 'Projects'
                              ,ndocument   => nrn
                              ,sstr_value  => tkpa
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => newrn);
  
    contracts_chg('ТКПА', tkpa);
  
  end if;

end;
/
