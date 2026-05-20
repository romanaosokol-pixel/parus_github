create or replace procedure usr_p_payaccin_make_copy_ini(nrn    in number
                                                        ,is_ok  out number
                                                        ,is_err out varchar2
                                                        ,scolor in out varchar2) is
begin

  /*≈сли счет создан из счета (счет на доплату), то создавать к нему новый счет на доплату нельз€ */

  begin
    select 0
          ,'ƒанный счет сам €вл€етс€ счетом на доплату к' || cr || 'счету є' || trim(p.doc_pref) || '-' || trim(p.doc_numb) || ' от ' ||
           to_char(p.doc_date, 'DD.MM.YYYY') || cr || '—оздавать к нему счет на доплату нельз€.' || cr ||
           '—оздайте счет на доплату из основного счета.'
          ,'-2147483635'
      into is_ok
          ,is_err
          ,scolor
      from doclinks dl
      join payaccin p
        on p.rn = dl.in_document
     where dl.out_document = nrn
       and dl.out_unitcode = 'PaymentAccountsIn'
       and dl.in_unitcode = dl.out_unitcode;
  
  exception
    when no_data_found then
      is_ok := 1;
    
  end;

end;
/
