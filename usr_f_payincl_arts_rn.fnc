create or replace function usr_f_payincl_arts_rn
(nrn in payaccinspclc.rn%type) return number deterministic as

begin
/*ñâîéñòâî RN_ÑÒĞ_ÁŞÄÆÅÒ*/
  return usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 260664294, sunitcode => 'PaymentAccountsInSpecsCalcs', ndocument => nrn);
end;
/
