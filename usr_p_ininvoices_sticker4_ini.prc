create or replace procedure usr_p_ininvoices_sticker4_ini
(
  nrn           in number
 ,sunitcode     in varchar2
 ,nstore_vis    out number
 ,sstore        out varchar2
 ,ntypecell_vis out number
) is

begin

  case sunitcode
    when 'GoodsParties' then
      nstore_vis    := 1;
      ntypecell_vis := 0;
    when 'GoodsTransInvoicesToDepts' then
      ntypecell_vis := 1;
      nstore_vis    := 0;
    when 'GoodsTransInvoicesToDeptsSpecs' then
      ntypecell_vis := 1;
      nstore_vis    := 0;
    else
      nstore_vis    := 0;
      ntypecell_vis := 0;
  end case;

end;
/
