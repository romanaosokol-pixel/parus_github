create or replace function USR_F_DSCR_SPGS_RLS_DATE
/*
Раздел Товарные запасы по местам хранения (товарные запасы)
Функция для колонки "#Дата последней ведомости инвентаризации"
03/10/2023 Степанов М.
grant execute on USR_F_DSCR_SPGS_RLS_DATE to public;
*/
(
 nGOODSSUPPLY   in number
,nCELL          in number
)
return date
is
  dRes  date;
begin

  begin
    select max(h.docdate)
      into dRes
      from rlinvsheetspec t
          ,rlinvsheet     h
     where t.goodssupply = nGOODSSUPPLY
       and t.cell        = nCELL
       and t.prn         = h.rn
       and h.status      = 1
       ;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,nCELL ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STPLGSSUPPLYHIST')));
  end;               

  return dRes;
  
end USR_F_DSCR_SPGS_RLS_DATE;
/
