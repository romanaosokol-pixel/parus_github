create or replace procedure usr_p_ininvsp_vidprm_set(nrn in number) is

  v_nrn number(17);

  sv_rn docs_props.rn%type := 8027724;

begin
  for cur in (
              
              select count(*) over() nn
                     ,z.vid_priem
                from (select distinct nvl(usr_pkg_docs_props_vals.get_val_str(ndoc_prop => sv_rn
                                                                              ,sunitcode => 'DepartmentsOrders'
                                                                              ,ndocument => zpe.departmentord)
                                          ,'_') vid_priem
                         from ininvoices pn
                         join doclinks dl
                           on dl.out_document = pn.rn
                          and dl.in_unitcode = 'PaymentAccountsIn'
                          and dl.out_unitcode = 'IncomingInvoices'
                         join payaccinspec ssp
                           on ssp.prn = dl.in_document
                         join payaccinspclc scl
                           on scl.prn = ssp.rn
                         join payaccinspclc_ex zpe
                           on zpe.prn = scl.rn
                        where pn.rn = nrn
                       
                       ) z
              
               group by z.vid_priem)
  loop
  
    if cur.nn > 1
    then
      --- Если видов приемки несколько, ито свойство не переносим
      exit;
    else
      /* Вид приемки один, поэтому перносим свойство из Заказа подразделений в свойства строки  накладной */
      if cur.vid_priem is not null
      then
        for doc in (select sp.rn from ininvoicesspecs sp where sp.prn = nrn)
        loop
        
          pkg_docs_props_vals.modify(nproperty   => sv_rn
                                    ,sunitcode   => 'IncomingInvoicesSpecs'
                                    ,ndocument   => doc.rn
                                    ,sstr_value  => cur.vid_priem
                                    ,nnum_value  => null
                                    ,ddate_value => null
                                    ,nrn         => v_nrn);
        
        end loop;
      end if;
      exit;
    end if;
  
  end loop;

end;
/
