create or replace function usr_f_storeoper_mol_rn(pin_doc storeoperjourn.rn%type) return number is
  v_res agnlist.rn%type;
begin
  for cur in (select st.unitcode
                    ,case op.factret_sign --- Признак складской операции "возврат" меняет направление складской операции - Запрос А. Хохрякова
                       when 1 then
                        st.oper_type
                       else
                        1 - st.oper_type
                     end as oper_type
                from storeoperjourn st
                join azsgsmwaystypes op
                  on op.rn = st.stoper
               where st.rn = pin_doc)
  loop
    case cur.unitcode
      when 'GoodsTransInvoicesToConsumers' then
        begin
          select t.mol
            into v_res
            from doclinks dl
            join transinvcust t
              on t.rn = dl.in_document
           where dl.out_document = pin_doc
             and dl.out_company = t.company
             and dl.in_unitcode = cur.unitcode
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_company = dl.out_company;
        exception
          when no_data_found then
            return null;
        end;
      
      when 'IncomingOrders' then
      
        begin
          select t.agent
            into v_res
            from doclinks dl
            join inorders t
              on t.rn = dl.in_document
           where dl.out_document = pin_doc
             and dl.out_company = t.company
             and dl.in_unitcode = cur.unitcode
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_company = dl.out_company;
        exception
          when no_data_found then
            return null;
        end;
      
      when 'GoodsTransInvoicesToDepts' then
      
        begin
          select case
                   when cur.oper_type = 1 then
                    t.in_mol
                   else
                    t.mol
                 end
            into v_res
            from doclinks dl
            join transinvdept t
              on t.rn = dl.in_document
           where dl.out_document = pin_doc
             and dl.out_company = t.company
             and dl.in_unitcode = cur.unitcode
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_company = dl.out_company;
        exception
          when no_data_found then
            return null;
        end;
      
      when 'IncomFromDeps' then
      
        begin
          select t.agent
            into v_res
            from doclinks dl
            join incomefromdeps t
              on t.rn = dl.in_document
           where dl.out_document = pin_doc
             and dl.out_company = t.company
             and dl.in_unitcode = cur.unitcode
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_company = dl.out_company;
        exception
          when no_data_found then
            return null;
        end;
      
      when 'GoodsTransInvoicesToDepts' then
      
        begin
          select case
                   when cur.oper_type = 1 then
                    t.in_mol
                   else
                    t.mol
                 end
            into v_res
            from doclinks dl
            join transinvdept t
              on t.rn = dl.in_document
           where dl.out_document = pin_doc
             and dl.out_company = t.company
             and dl.in_unitcode = cur.unitcode
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_company = dl.out_company;
        exception
          when no_data_found then
            return null;
        end;
      
      when 'ReturnInvoicesToSuppliers' then
        begin
        
          select t.mol
            into v_res
            from doclinks dl
            join rinvtosup t
              on t.rn = dl.in_document
           where dl.out_document = pin_doc
             and dl.out_company = t.company
             and dl.in_unitcode = cur.unitcode
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_company = dl.out_company;
        exception
          when no_data_found then
            return null;
          
        end;
      
      else
        return 6714216; ---null; -- Если не нашли, то Хохряков
    end case;
  end loop;
  return v_res;
end;
---grant execute on USR_F_STOREOPER_MOL_RN to public;
/
