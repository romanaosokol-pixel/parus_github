create or replace function usr_f_productord_sernumb(nrn number) return varchar2 is
/* 
17/03/2026 Степанов М. доработки по скорости 
*/
  sres varchar2(2000) := ';';
begin
  for cur in (select distinct udo_f_productords_sernumb(nrn => t.rn) nz
                from productords t
               where t.prn = nrn
               order by 1)
  loop
  
    if length(sres) < 1500 then
      sres := sres ||';'  || cur.nz;
    /* 17/03/2026 Степанов М. доработки по скорости */
    else
      exit;
    end if;
  
  end loop;
  return substr(sres, 3);

end;
---grant execute on usr_f_productord_sernumb to public
/
