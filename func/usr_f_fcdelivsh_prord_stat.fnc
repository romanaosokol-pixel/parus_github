create or replace function usr_f_fcdelivsh_prord_stat(nrn number) return varchar2 is

  /* ƒоп. колонка  омплектовочной ведомости - —осто€ние заказа на производств
  состо€ние заказа (0-неутвержден, 1-утвержден, 2-согласование, 3-закрыт, 4-аннулирован) 
  
  grant execute on usr_f_fcdelivsh_prord_stat to public;
  */
begin
  for cur in (
              
              select case zp.ord_state
                        when 0 then
                         'неутвержден'
                        when 1 then
                         'утвержден'
                        when 2 then
                         'согласование'
                        when 3 then
                         'закрыт'
                        when 4 then
                         'аннулирован'
                        else
                         null
                      end sres
                from doclinks dl1
                join doclinks dl2
                  on dl2.out_document = dl1.in_document
                 and dl2.in_unitcode = 'CostProductPlansSpecs'
                 and dl2.out_unitcode = dl1.in_unitcode
                join fcprodplansp pps
                  on pps.rn = dl2.in_document
                join doclinks dl3
                  on dl3.out_document = pps.prn_node
                 and dl3.in_unitcode = 'ProductionOrdersSpecs'
                 and dl3.out_unitcode = dl2.in_unitcode
                join productords zps
                  on zps.rn = dl3.in_document
                join productord zp
                  on zp.rn = zps.prn
               where dl1.out_document = nrn
                 and dl1.in_unitcode = 'CostRouteLists'
                 and dl1.out_unitcode = 'CostDeliverySheets')
  loop
  
    return cur.sres;
  
  end loop;

  return 'нет заказа';

end;
/
