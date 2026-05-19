create or replace function USR_F_PAIS_GET_PO_RELEASE_DATE
/*
Раздел "Входящие счета на оплату (спецификация)".
Функция для колонки "#Заказ на производство. Дата исполнения - LAG"
10/01/2024 Степанов М.
grant execute on USR_F_PAIS_GET_PO_RELEASE_DATE to public;
*/
(
 nRN in number
)
return varchar2
as
  sRes    pkg_std.tstring;
begin
  for c in (
            select po.release_date - 91 as dDate
              from payaccinspec       t
                  ,payaccinspclc      paisc
                  ,payaccinspclc_ex   paisce
                  ,departmentord      do
                  ,doclinks           dl_1
                  ,doclinks           dl_2
                  ,productord         po
             where t.rn               = nRN
               and paisc.prn          = t.rn
               and paisce.prn         = paisc.rn
               and do.rn              = paisce.departmentord
               and dl_1.out_document  = do.rn
               and dl_1.in_unitcode   = 'CostProductExpenseActs'
               and dl_1.in_document   = dl_2.out_document
               and dl_2.in_unitcode   = 'ProductionOrders'
               and dl_2.in_document   = po.rn
           )
  loop
    sRes := strcombine(sRes, decode_date(c.dDate), ';');
  end loop;

  return sRes;

end USR_F_PAIS_GET_PO_RELEASE_DATE;
/
