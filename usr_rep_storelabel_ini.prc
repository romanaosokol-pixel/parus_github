create or replace procedure usr_rep_storelabel_ini
(
  nrn              in number
 ,sunitcode        in varchar2
 ,in_sstore        in varchar2
 ,out_GPRN         out varchar2 
 ,out_sstore       out varchar2  
 ,out_vis_sstore   out number
 ,out_vis_celltype out number
 ,out_vis_sstellaj out number
 ,out_VIS_GPRN   out number
  
) is

begin
  case sunitcode
    when 'GoodsSupply' then
      out_vis_sstore   := 0;
      out_vis_celltype := 0;
      out_vis_sstellaj := 1;
    begin  
      select GY.Prn, skl.azs_number
       into  out_GPRN, out_sstore
       from goodssupplyhist GYH
       join goodssupply GY on gy.rn = GYH.prn
       join azsazslistmt skl on skl.rn = gy.store
      where GYH.RN = nrn;
     exception when no_data_found then  out_GPRN:=null;
      
    end;  
      
    when 'GoodsParties' then
      out_vis_sstore   := 1;
      out_vis_celltype := 0;
      out_vis_sstellaj := 1;
      out_GPRN := nrn;
    when 'StoragePlacesGoodsSupply' then
      out_vis_sstore   := 0;
      out_vis_celltype := 0;
      out_vis_sstellaj := 0;
    when 'GoodsTransInvoicesToDepts' then
      out_vis_sstore   := 0;
      out_vis_celltype := 1;
      out_vis_sstellaj := 0;
    when 'GoodsTransInvoicesToDeptsSpecs' then
      out_vis_sstore   := 0;
      out_vis_celltype := 1;
      out_vis_sstellaj := 0;
    when 'IncomingOrders' then  
      out_vis_sstore   := 0;
      out_vis_celltype := 0;
      out_vis_sstellaj := 0;
    when 'IncomingOrdersSpecs' then    
      out_vis_sstore   := 0;
      out_vis_celltype := 0;
      out_vis_sstellaj := 0;
    when 'RealizationInventorySheet' then    
      out_vis_sstore   := 0;
      out_vis_celltype := 0;
      out_vis_sstellaj := 0;
    when 'RealizationInventorySheetSpec' then    
      out_vis_sstore   := 0;
      out_vis_celltype := 0;    
      out_vis_sstellaj := 0;
      
      
    else
      out_vis_sstore   := 1;
      out_vis_celltype := 1;
  end case;
    

out_sstore:= nvl(out_sstore, in_sstore);  
out_VIS_GPRN:=0;  -- Никому не надо видеть это поле

end;
/
