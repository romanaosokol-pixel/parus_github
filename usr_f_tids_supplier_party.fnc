create or replace function usr_f_tids_supplier_party
/*
Раздел "Расходные накладные на отпуск в подразделения (спецификации)"
Функция получения партии поставщика
03/04/2024 Степанов М.
grant execute on usr_f_tids_supplier_party to public;
*/
(
 nRN in number
)
return varchar2
is
  sRES      pkg_std.tstring;
  rRow      transinvdeptspecs%rowtype;
begin
  /* Считывание */
  rRow := usr_pkg_transinvdept.transinvdeptspecs_get(nrn => NRN);
  /* Поиск */
  usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => rRow.goodsparty
                                                     ,nflagsmart  => 1
                                                     ,ndocs_props => 69192082
                                                     ,sresult     => SRES
                                                     ,nothers     => rRow.company);
  return(SRES);
end USR_F_TIDS_SUPPLIER_PARTY;
/
