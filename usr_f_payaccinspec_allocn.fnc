create or replace function usr_f_payaccinspec_allocn(nrn in payaccinspec.rn%type) return varchar2 is

  alloc_art_nmb varchar2(2000);

begin
  /* Возвращаем название подстатей калькуляции строки спецификации взодящего счета  */

  begin
  
    for cur in (with brsp as
                   (select distinct usr_pkg_docs_props_vals.get_val_num(sprop_code => 'RN_СТР_РАСПРЕД'
                                                                      ,sunitcode  => 'PaymentAccountsInSpecsCalcs'
                                                                      ,ndocument  => psc.rn) brs_rn
                     from payaccinspec ps
                     join payaccinspclc psc
                       on psc.prn = ps.rn
                    where ps.rn = nrn)
                  select brs.name
                    into alloc_art_nmb
                    from brsp
                    join usr_t_alloc_arts brs
                      on brs.rn = brsp.brs_rn
                   order by brs.name
                )
    loop
      alloc_art_nmb := strcombine(alloc_art_nmb, cur.name, ';');
    end loop;
  
  end;

  return alloc_art_nmb;

end;
/
