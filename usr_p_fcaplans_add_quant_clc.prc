create or replace procedure usr_p_fcaplans_add_quant_clc
(
  nrn            in fcacoperplans.rn%type
 ,pin_dstar_date in date
 ,out_txt        out varchar2
 ,io_q           in out number
 ,vis_ok         out number
) is

  v_d1 fcacoperplans.begin_date%type;
  v_d2 fcacoperplans.end_date%type;
  v_q  fcacoperplans.quant%type;

begin
  out_txt := cr;
  vis_ok  := 1;

  select fp.begin_date
        ,fp.end_date
        ,fp.quant
    into v_d1
        ,v_d2
        ,v_q
    from fcacoperplans fp
   where fp.rn = nrn;

  if not (pin_dstar_date between v_d1 and v_d2)
  then
    out_txt := out_txt || cr || 'Дата начала нового графика должна быть в диапазоне дат разбиваемого графика!';
  end if;

  if v_q <= io_q
  then
    out_txt := out_txt || cr || 'Количество в новом графике должно быть меньше чем а разбиваемом графике.!';
  end if;

  out_txt := substr(out_txt
                   ,3);

end;
/
