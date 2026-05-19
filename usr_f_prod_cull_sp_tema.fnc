create or replace function usr_f_prod_cull_sp_tema(nrn number) return varchar2 is
  v_res varchar2(255);

begin
  begin
    /*Поиск в накладной в подразделение*/
    select udo_f_departmentord_shefr(td.faceacc)
      into v_res
      from udo_prod_cull_sp t
      join doclinks dl
        on dl.out_document = t.prn
       and dl.in_unitcode = 'GoodsTransInvoicesToDepts'
       and dl.out_unitcode = 'UdoProdCull'
      join transinvdept td
        on td.rn = dl.in_document
     where t.rn = nrn;
  
  exception
    when no_data_found then
      /* Поиск в приходном ордере usr_f_inorders_tema*/
      begin
        select udo_f_departmentord_shefr(dl.in_document)
          into v_res
          from udo_prod_cull_sp t
          join doclinks dl
            on dl.out_document = t.prn
           and dl.in_unitcode = 'IncomingOrders'
           and dl.out_unitcode = 'UdoProdCull'
         where t.rn = nrn;
      exception
        when no_data_found then
          return null;
      end;
    
  end;

  return v_res;
end; ---161773408
/
