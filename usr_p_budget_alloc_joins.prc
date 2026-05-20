create or replace procedure usr_p_budget_alloc_joins(ncompany   in number
                                                    ,nbr        in number --- RN бюджета,  если он известен
                                                    ,sdoctypes  in varchar2
                                                    ,sjur_pers  in varchar2
                                                    ,sfp_code   in varchar2
                                                    ,sdedpcode  in varchar2
                                                    ,sgroupbudg in varchar2
                                                    ,nfp_vers   in number
                                                    ,ndoctypes  out number
                                                    ,nfinplan   out number) is

  ndep_rn ins_department.rn%type;

begin

  /* Тип документа */
  begin
    select dt.rn
      into ndoctypes
      from doctypes dt
      join compverlist v
        on v.version = dt.version
       and v.company = ncompany
       and v.unitcode = 'DOCTYPES'
     where dt.doccode = sdoctypes;
  exception
    when no_data_found then
      p_exception(0, 'Не найден тип документа с кодом %s', sdoctypes);
  end;

  /*RN Отдела */

  if sdedpcode is not null
  then
  
    begin
      select dep.rn
        into ndep_rn
        from ins_department dep
       where dep.code = sdedpcode
         and dep.company = ncompany;
    
    exception
      when no_data_found then
        p_exception(0
                   ,'Организация с кодом %s не найдена. Выберите корректное значение серез словарь.');
    end;
  
  end if;

  /* RN бюджета для которго делаем распределение */

  if nbr is not null
  then
    nfinplan := nbr;
  
  else
  
    begin
    
      select t.rn
        into nfinplan
        from udo_t_finplan t
        join jurpersons jp
          on jp.rn = t.jur_pers
        join dicsmrks gb
          on gb.rn = t.groupbudg
        join compverlist v
          on v.version = gb.version
         and v.company = t.company
         and v.unitcode = 'SpecialMarks'
       where t.fp_code = sfp_code
         and t.company = ncompany
         and (t.depord = ndep_rn or ndep_rn is null)
         and t.fp_vers = nfp_vers
         and jp.code = sjur_pers
         and jp.company = t.company
         and gb.smark_mnemo = sgroupbudg;
    
    exception
      when no_data_found then
        p_exception(0
                   ,'Бюджет с кодом %s, версией %s, юридическим лицом %s, группой бюджет %s, не найден.'
                   ,sfp_code
                   ,nfp_vers
                   ,sjur_pers
                   ,sgroupbudg);
      
      when too_many_rows then
        p_exception(0
                   ,'Найдено несколько Бюджетов с кодом %s, версией %s, юридическим лицом %s, группой бюджет %s, не найден.'
                   ,sfp_code
                   ,nfp_vers
                   ,sjur_pers
                   ,sgroupbudg);
      
    end;
  end if;

end;
/
