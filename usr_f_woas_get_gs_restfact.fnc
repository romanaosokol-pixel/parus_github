create or replace function USR_F_WOAS_GET_GS_RESTFACT
/*
Раздел Акты списания недостач/оприходования излишков (спецификация)
Функция для колонки "#Фактический остаток"
07/11/2024 Степанов М.
grant execute on USR_F_WOAS_GET_GS_RESTFACT to public;
*/
(
 nCOMPANY       in number
,nGOODSSUPPLY   in number
)
return pkg_std.tquant
is
  nRes      pkg_std.tquant;

  nNumber   pkg_std.tnumber;
begin

  begin
    select 1
      into nNumber
      from goodssupply
     where rn = nGOODSSUPPLY
       and exists ( select null from goodssupplyhist where prn = nGOODSSUPPLY );
  exception
    when no_data_found then
      nNumber := 0;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,nGOODSSUPPLY
                 ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSSUPPLY')));
  end;

  if nNumber = 1 then
    find_goodssupply_full_by_rn(ncompany     => nCOMPANY
                               ,nflag_smart  => 1
                               ,nrn          => nGOODSSUPPLY
                               ,ddate        => sysdate
                               ,nrestplan    => nNumber
                               ,nrestplanalt => nNumber
                               ,nrestfact    => nRes
                               ,nrestfactalt => nNumber
                               ,nreserv      => nNumber
                               ,nreservalt   => nNumber);
    return nRes;
  end if;

  return null;

end;
/
