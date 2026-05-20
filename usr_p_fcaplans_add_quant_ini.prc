create or replace procedure usr_p_fcaplans_add_quant_ini
(
  nrn        in fcacoperplans.rn%type
 ,dstar_date out date
 ,out_NQUANT out number
 ,out_txt    out varchar2
) is
begin
  select fp.begin_date into dstar_date from fcacoperplans fp where fp.rn = nrn;
  
  out_NQUANT:=null;

  out_txt := 'Дата начала нового графика должна быть в диапазоне дат разбиваемого графика!';

end;
/
