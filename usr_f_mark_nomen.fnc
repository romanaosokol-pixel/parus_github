create or replace function usr_f_mark_nomen(nrn in number) return varchar2 is

  v_res  varchar2(2000) := ';';
  pin_rn number(17) := nrn;

begin

  for cur in (
              
              select distinct t.snomen_name from udo_v_mark_nomen t join payaccin p on p.rn = t.nsrn where t.nprn = pin_rn)
  
  loop
    if length(v_res) < 300
    then
      v_res := v_res || ';' || cur.snomen_name;
    end if;
  
  end loop;

  return substr(v_res, 3);

end;
/
