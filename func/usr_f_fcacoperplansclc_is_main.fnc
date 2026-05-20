create or replace function usr_f_fcacoperplansclc_is_main(nrn number)
  return number is
  nres contrprclc.sign_main%type;
begin
  begin
  
    select sps.sign_main
      into nres
      from fcacoperplansclc fcs
      join fcacoperplans fc
        on fc.rn = fcs.prn
      join stages st
        on st.faceacc = fc.prn
      join contrprstruct sp
        on sp.prn = st.rn
      join contrprclc sps
        on sps.prn = sp.rn
       and sps.cost_article = fcs.cost_article
     where fcs.rn = nrn
      
       and sp.calc_indir = 1
       and sp.sign_act = 1       ; --(По калькуляции и действующая)
  exception
    when no_data_found then
      nres := null;
  end;

  return nres;

end;

  --select t.*, t.rowid from CONTRPRCLC t where t.RN = 157607336
/
