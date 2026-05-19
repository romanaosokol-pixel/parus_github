create or replace function usr_f_t_mark_dep_zak(nrn in number) return varchar2 is
  v_res varchar2(2000);

begin
/*«аказывающее подразделение в показател€х */
  begin
    with 
    sdep1 as
     (select distinct sp.prn
                     ,dep.code
        from payaccinspec sp
        join payaccinspclc spc
          on spc.prn = sp.rn
        join payaccinspclc_ex cle
          on cle.prn = spc.rn
        join departmentord zp
          on zp.rn = cle.departmentord
        join ins_department dep
          on dep.rn = zp.subdiv),
    sdep2 as
     (select distinct sdep1.code
        from udo_t_mark t
        join paynotes pn
          on pn.rn = t.document
        join doclinks dl
          on dl.out_document = pn.rn
         and dl.in_unitcode = 'PaymentAccountsIn'
         and dl.out_unitcode = t.unitcode
        join payaccin p
          on p.rn = dl.in_document
        join sdep1
          on sdep1.prn = p.rn
       where t.unitcode = 'PayNotes'
         and t.rn = nrn)
    
    select substr(listagg(sdep2.code, ';') within group(order by sdep2.code), 1, 255) into v_res from sdep2;
  exception
    when no_data_found then
      return null;
    
  end;

  return v_res;

end;
/
