create or replace procedure UDO_P_SYS_REMOVE_CMPL(nIDENT in number, nCOMPANY in number) as
nNEW number(17) := 42257808;
begin
return;    -- перенос связей по заголовку - по входу (только заголовки)
  for rli in (select L.*
                from DOCLINKS   L,
                     SELECTLIST SL
               where L.OUT_DOCUMENT = SL.DOCUMENT and SL.IDENT = nIDENT
                 and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                 and L.IN_UNITCODE = 'CostDeliverySheets') loop
    pkg_doclinks.REMOVE(sIN_UNITCODE  => rli.in_unitcode,
                        nIN_DOCUMENT  => rli.in_document,
                        sOUT_UNITCODE => rli.out_unitcode,
                        nOUT_DOCUMENT => rli.out_document);
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => nCOMPANY,
                      sIN_UNITCODE  => rli.in_unitcode,
                      nIN_DOCUMENT  => nNEW,
                      sOUT_UNITCODE => rli.out_unitcode,
                      nOUT_DOCUMENT => rli.out_document);
  end loop;

end;
/

