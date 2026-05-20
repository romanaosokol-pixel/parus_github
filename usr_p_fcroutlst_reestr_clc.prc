create or replace procedure usr_p_fcroutlst_reestr_clc
(
  pin_route_rn  in number
 ,out_route_txt out varchar2
) is

begin
  begin
    select dt.doccode || ' ' || trim(rl.docpref) || '-' || trim(rl.docnumb) || ' от  ' || to_char(rl.docdate, 'DD.MM.YYYY')
      into out_route_txt
      from fcroutlst rl
      join doctypes dt
        on dt.rn = rl.doctype
     where rl.rn = pin_route_rn;
  
  exception
    when no_data_found then
      out_route_txt := 'Маршрутный лист';
  end;

end;
/
