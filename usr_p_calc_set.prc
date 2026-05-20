create or replace procedure usr_p_calc_set(nrn              in number
                                          ,sunitcode        in varchar2
                                          ,salloc_art_nmb   in varchar2
                                          ,speriod          in varchar2
                                          ,allocation_sp_rn in number
                                          ,finplan_arts_rn  in number) is

  v_nrn_sv docs_props_vals.rn%type;

begin

  /* Функция записывает свойства калькуляции в свойства (потом переделаем на КОР раздел) */

  /* Номер лицевого счета ---  подстатья бюджетного распределения*/
  pkg_docs_props_vals.modify(sproperty   => 'Подстатья'
                            ,sunitcode   => sunitcode
                            ,ndocument   => nrn
                            ,nnum_value  => null
                            ,sstr_value  => salloc_art_nmb
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /*Периода расчетного */

  pkg_docs_props_vals.modify(sproperty   => 'Рпериод'
                            ,sunitcode   => sunitcode
                            ,ndocument   => nrn
                            ,nnum_value  => null
                            ,sstr_value  => speriod
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /*RN  RN_СТР_РАСПРЕД */

  pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_РАСПРЕД'
                            ,sunitcode   => sunitcode
                            ,ndocument   => nrn
                            ,nnum_value  => allocation_sp_rn
                            ,sstr_value  => null
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

  /*RN  RN_СТР_БЮДЖЕТ */

  pkg_docs_props_vals.modify(sproperty   => 'RN_СТР_БЮДЖЕТ'
                            ,sunitcode   => sunitcode
                            ,ndocument   => nrn
                            ,nnum_value  => finplan_arts_rn
                            ,sstr_value  => null
                            ,ddate_value => null
                            ,nrn         => v_nrn_sv);

end;
/
