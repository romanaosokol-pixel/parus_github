create or replace procedure usr_p_contract_set_unfail(nrn in number) is

  v_nrn docs_props_vals.rn%type;

begin
  /* Отменяем признак "Отказ" на договоре */

  if usr_f_contract_base_status(nrn => nrn) = 10
  then

    pkg_docs_props_vals.modify(sproperty => 'status', sunitcode => 'Contracts', ndocument => nrn, sstr_value => null, nnum_value => null, ddate_value => null, nrn => v_nrn);
  end if;

end;
/
