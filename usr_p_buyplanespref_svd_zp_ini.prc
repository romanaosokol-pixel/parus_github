create or replace procedure usr_p_buyplanespref_svd_zp_ini
(
  nident            in number
 ,ncompany          in number
 
 ,out_ncrn          out number 
 ,out_date          out date
 ,out_saccept       out varchar2
 ,out_drelease_date out date
 ,out_sdoc_type     out varchar2
 ,out_stax_group    out varchar2
 ,out_sobs          out varchar2
) is
begin

  out_date          := trunc(sysdate);
  out_saccept       := null;
  out_drelease_date := null;
  out_sdoc_type     := 'ЗаказПоств';
  out_stax_group    := 'НДС 20';

---P_exception(0, ncrn);

  begin
    select distinct t.obs, T.Crn
      into out_sobs, out_ncrn
      from selectlist sl
      join usr_tab_buyplanespref_svod t
        on t.rn = sl.document
     where sl.ident = nident
       and sl.authid = utilizer
       and sl.company = ncompany;
  exception
    when too_many_rows then
      out_sobs := null;
    when no_data_found then
      out_sobs := 'no_data_found';
  end;

end;
/
