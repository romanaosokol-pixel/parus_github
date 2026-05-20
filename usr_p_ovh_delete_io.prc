create or replace procedure usr_p_ovh_delete_io
/*
Накладные расходы (OVERHEADS) или Товарные запасы (GOODSSUPPLY)\Накладные расходы (OVERHEADS)
Процедура формирования удаления распределения накладного расхода на товарный запас и его приходного ордера
04/10/2023 Степанов М.
*/
(
 nRN        in number
,nCOMPANY   in number
)
is
  nInOrders     pkg_std.tref;
  nNumber       pkg_std.tnumber;
  sVarchar      pkg_std.tstring;
begin
  /* Удаление распределения */
  p_overheads_spread_delete(ncompany => nCOMPANY, nrn => nRN);

  /* Связанный приходный ордер */
  nInOrders := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode => 'RealizationOverheads', nout_document => nRN, sin_unitcode => 'IncomingOrders');

  /* Снятие отработки ПО */
  p_inorders_bset_status(ncompany    => ncompany
                        ,nrn         => nInOrders
                        ,nstatus     => 0
                        ,dwork_date  => current_date
                        ,nflag_reset => 0
                        ,nwarning    => nNumber
                        ,smsg        => sVarchar);
  /* Удаление ПО */
  p_inorders_base_delete(ncompany => nCOMPANY, nrn => nInOrders);
end USR_P_OVH_DELETE_IO;
/
