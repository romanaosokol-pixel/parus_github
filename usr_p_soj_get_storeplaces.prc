create or replace procedure USR_P_SOJ_GET_STOREPLACES
/*
Раздел Журнал складских операций
Показать места хранения
03/10/2023 Степанов М.
grant execute on USR_P_SOJ_GET_STOREPLACES to public;
*/
(
 nRN      in number
,sOUT     out varchar
)
is
begin
  begin
    select listagg(trim(trim(cl.pref)||'.'||lpad(to_char(cl.tier), 2, 0)||'.'||trim(cl.numb)),'; ') within group (order by cl.rn)
      into sOUT
      from storeoperjourn soj
          ,doclinks       dl_1
          ,(
            select s.rn, s.unotcode
              from (select rn, 'IncomFromDepsSpecs' as unotcode from incomefromdepsspec) s
             where s.unotcode = 'IncomFromDepsSpecs'
            union
            select s.rn, s.unotcode
              from (select rn, 'IncomingOrdersSpecs' as unotcode from inorderspecs) s
             where s.unotcode = 'IncomingOrdersSpecs'
            union
            select s.rn, s.unotcode
              from (select rn, 'ReturnInvoicesToSuppliersSpecs' as unotcode from rinvtosupspecs) s
             where s.unotcode = 'ReturnInvoicesToSuppliersSpecs'
            union
            select s.rn, s.unotcode
              from (select rn, 'GoodsTransInvoicesToConsumersSpecs' as unotcode from transinvcustspecs) s
             where s.unotcode = 'GoodsTransInvoicesToConsumersSpecs'
            union
            select s.rn, s.unotcode
              from (select rn, 'GoodsTransInvoicesToDeptsSpecs' as unotcode from transinvdeptspecs) s
             where s.unotcode = 'GoodsTransInvoicesToDeptsSpecs'
            union
            select s.rn, s.unotcode
              from (select rn, 'WriteOffActsSpecs' as unotcode from wroffactspecs) s
             where s.unotcode = 'WriteOffActsSpecs'
           ) t
          ,doclinks       dl_2
          ,strplresjrnl   sprj
          ,stplcells      cl
     where soj.rn            = nRN
       and dl_1.out_document = soj.rn
       and dl_1.in_document  = t.rn
       and dl_1.in_unitcode  = t.unotcode
       and dl_2.in_document  = t.rn
       and dl_2.out_document = sprj.rn
       and sprj.res_type     = decode(soj.oper_type, 0, 1, 0)
       and sprj.cell         = cl.rn
       ;
  exception
    when no_data_found then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,nRN ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'STOREOPERJOURN')));
  end;

end USR_P_SOJ_GET_STOREPLACES;
/
