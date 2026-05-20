create or replace procedure usr_p_ios_gld_modif_from_tics
/*
Приходные ордера (спецификация). Добавить данные драг.металлов из накладной потребителям
02/04/2026 Степанов М.
create public synonym usr_p_ios_gld_modif_from_tics for usr_p_ios_gld_modif_from_tics;
grant execute on usr_p_ios_gld_modif_from_tics to public;
*/
(
 nRN          in number
,nFLAGSMART   in number
)
is
  rRow                    inorderspecs%rowtype;
  rTransInvCustSpecs      transinvcustspecs%rowtype;
  rGoodsParties           goodsparties%rowtype;
  nInOrderSpecs           pkg_std.tref; 
  rInOrderSpec_Golds      udo_inorderspec_golds%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IOS_SEPARATION');

  /* Считывание текущей записи */
  rRow := usr_pkg_inorders.inorderspecs_get(nrn => nRN );

  /* RN спецификации Расходной накладной потребителям */
  rTransInvCustSpecs.rn := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                         ,sout_unitcode => 'IncomingOrdersSpecs'
                                                         ,nout_document => rRow.rn
                                                         ,sin_unitcode  => 'GoodsTransInvoicesToConsumersSpecs' );

  /* Считывание спецификации Расходной накладной потребителям */
  rTransInvCustSpecs := usr_pkg_TransInvCust.transinvcustspecs_get( nrn => rTransInvCustSpecs.rn );
  /* Считывание Партии товара */
  rGoodsParties      := usr_pkg_goodsparties.goodsparties_get( nrn => rTransInvCustSpecs.goodsparty );
  /* Поиск спецификации Приходного ордера, по которому приходила серия */
  nInOrderSpecs      := usr_pkg_goodsparties.goodsparties_get_indocs_data( ssernumb       => rGoodsParties.sernumb
                                                                          ,nflagsmart     => nFLAGSMART
                                                                          ,ntoo_many_rows => 0
                                                                          ,sparam         => 'nIOS' );
  /* По драг.металлам спецификации Приходного ордера, по которому приходила серия */
  for c in ( select * from udo_inorderspec_golds where prn = nInOrderSpecs )
  loop  
    /* Копирование в переменную */
    rInOrderSpec_Golds := c;
    /* Подмена в переменной спецификацию Приходного ордера на текущую */
    rInOrderSpec_Golds.prn := rRow.rn;
    /* Добавление драг.металлов для текущей спецификации */
    udo_pkg_inorderspec_golds.p_golds_base_insert( rrow => rInOrderSpec_Golds );
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
