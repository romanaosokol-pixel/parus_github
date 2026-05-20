create or replace function usr_f_faoop_rest_quant
/*
Лицевые счета (план расхода)
Функция для колонки #Остаток (количество)
grant execute on usr_f_faoop_rest_quant to public;
17/02/2026 Степанов М.
*/
(
 nRN            in number
)
return number
is
  nRes        pkg_std.tquant;

  nNumber     pkg_std.tnumber; 
begin
  usr_pkg_faceacc.fcacoperoutplans_get_exec(nrn              => NRN
                                           ,nquant_fact      => nNumber
                                           ,nsum_fact        => nNumber
                                           ,nsumwithnds_fact => nNumber
                                           ,nsumnds_fact     => nNumber
                                           ,nquant_rest      => nRes
                                           ,nsum_rest        => nNumber
                                           ,nsumwithnds_rest => nNumber
                                           ,nsumnds_rest     => nNumber);
  return nRes;
end;
/
