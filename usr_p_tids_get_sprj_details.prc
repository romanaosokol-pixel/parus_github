create or replace procedure USR_P_TIDS_GET_SPRJ_DETAILS
/*
Расходные накладные на отпуск в подразделения (спецификация)
Показать неотработанные документы с резервами по местам хранения
04/10/2023 Степанов М.
*/
(
 nRN          in number    /* Приходная партия товара */
,sRESULT      out varchar2
)
is
  rRow              transinvdeptspecs%rowtype;
  rTransInvDept     transinvdept%rowtype;
  nGoodsSupply      pkg_std.tref; 
begin
  /* Текущая запись и заголовок */
  rRow          := usr_pkg_TransInvDept.transinvdeptspecs_get(nrn => nRN);
  rTransInvDept := usr_pkg_TransInvDept.transinvdept_get(nrn => rRow.prn);
  /* Товарный запас */
  find_goodssupply_by_store(ncompany    => rRow.company
                           ,nflag_smart => 0
                           ,nprn        => rRow.goodsparty
                           ,sstore      => f_dicstore_get_numb(nstore => rTransInvDept.store)
                           ,nrn         => nGoodsSupply);

  /* По неотработанным документам с резервом по месту хранения товарного запаса */
  for c in (
            select f_docdescrs_get_description(sunitcode => t.unotcode, ndocument => t.rn) as doc
              from (
                    select s.rn, s.status, s.unotcode 
                      from (select rn, decode(doc_state, 2, 1, 0) as status, 'IncomFromDeps' as unotcode from incomefromdeps) s
                     where s.unotcode = 'IncomFromDeps'
                    union
                    select s.rn, s.status, s.unotcode 
                      from (select rn, decode(docstatus, 2, 1, 0) as status, 'IncomingOrders' as unotcode from inorders) s
                     where s.unotcode = 'IncomingOrders'
                    union
                    select s.rn, s.status, s.unotcode 
                      from (select rn, status as status,  'ReturnInvoicesToSuppliers' as unotcode from rinvtosup) s
                     where s.unotcode = 'ReturnInvoicesToSuppliers'
                    union
                    select s.rn, s.status, s.unotcode 
                      from (select rn, status as status, 'GoodsTransInvoicesToConsumers' as unotcode from transinvcust) s
                     where s.unotcode = 'GoodsTransInvoicesToConsumers'
                    union
                    select s.rn, s.status, s.unotcode 
                      from (select rn, status as status, 'GoodsTransInvoicesToDepts' as unotcode from transinvdept) s
                     where s.unotcode = 'GoodsTransInvoicesToDepts'
                    union
                    select s.rn, s.status , s.unotcode
                      from (select rn, status as status, 'WriteOffActs' as unotcode from wroffacts) s
                     where s.unotcode = 'WriteOffActs'
                   ) t
                  ,doclinks       dl_2
                  ,strplresjrnl   sprj
             where dl_2.in_document  = t.rn
               and dl_2.out_document = sprj.rn
               and sprj.res_type     = 1
               and t.status         != 1
               and sprj.goodssupply  = nGoodsSupply
               and t.rn             != rTransInvDept.rn
           )
    loop
      sRESULT := strcombine(sleft => sRESULT, sright => c.doc, sdelimeter => cr||cr);
    end loop;

end USR_P_TIDS_GET_SPRJ_DETAILS;
/
