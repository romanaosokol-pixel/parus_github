create or replace function USR_F_DSCR_TIDS_REST_QUANT
/*
Раздел Расходные накладные на отпуск в подразделения (спецификации)
Функция для колонки "#Остаток на складе" 
10/11/2023 Степанов М.
grant execute on USR_F_DSCR_TIDS_REST_QUANT to public;
*/
(
 nRN  in number
)
return number
is
  nNommodif     pkg_std.tref; 
  nGoodsParty   pkg_std.tref; 
  nStore        pkg_std.tref; 
  nRestFact     pkg_std.tnumber; 
  nNumber       pkg_std.tnumber; 
begin
  begin
    select s.nommodif, s.goodsparty, h.store
      into nNommodif,  nGoodsParty,  nStore             
      from transinvdeptspecs s, transinvdept h
     where s.rn = NRN
       and h.rn = s.prn;
  exception
    when no_data_found then
      return 0;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,NRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'TRANSINVDEPTSPECS')));
  end;

  usr_p_get_rest_quant(ngoodsparties => nGoodsParty
                      ,ndicnomns     => null
                      ,nnommodif     => nNommodif
                      ,nstore        => nStore
                      ,ddate         => current_date
                      ,nrestfact     => nRestFact
                      ,nreserv       => nNumber
                      ,nsale         => nNumber);
  return nRestFact;
end USR_F_DSCR_TIDS_REST_QUANT;
/
