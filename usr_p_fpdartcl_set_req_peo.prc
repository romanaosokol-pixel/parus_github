create or replace procedure usr_p_fpdartcl_set_req_peo
(
  nrn   fpdartcl.rn%type
 ,ncomp companies.rn%type
) is
  v_fl  number(1);
  v_nrn number(17);
begin
  /* Переключение значения свойства "Обязательность задания экономиста ПЭО в документах" в формате Да/Нет*/

  /*Проверим, что свойство с кодом IS_PEO существует */
  begin
    select null
      into v_fl
      from docs_props sv
      join compverlist v
        on v.version = sv.version
       and v.unitcode = 'DocsProperties'
       and v.company = ncomp
     where sv.code = 'IS_PEO';
  exception
    when no_data_found then
      p_exception(0
                 ,'Свойство с кодом "%s" не найдено. Обратитесь в техническую поддержку.'
                 ,'IS_PEO');
  end;

  v_fl := 1 - nvl(usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 218817422
                                                     ,sunitcode => 'FinPlanArticles'
                                                     ,ndocument => nrn)
                 ,0);

  pkg_docs_props_vals.modify(sproperty   => 'IS_PEO'
                            ,sunitcode   => 'FinPlanArticles'
                            ,ndocument   => nrn
                            ,sstr_value  => null
                            ,nnum_value  => v_fl
                            ,ddate_value => null
                            ,nrn         => v_nrn);


end;
/
