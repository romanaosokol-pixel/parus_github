create or replace procedure USR_P_PAIS_DELETE
/*
Входящий счёт на оплату. Спецификация. Удаление
08/04/2022 Степанов М.
*/
(
 NRN          in number
,NDLOS        in number  -- удалять аналогичную спецификацию в заказе поставщикам
)
is
  nrn2              pkg_std.tref := NRN;
  bExistsAllRights  boolean := false;
  rV_Spec           v_payaccinspec%rowtype;
  rHead             payaccin%rowtype;
  nDeliveryOrd      pkg_std.tref;
  rDeliveryOrds     deliveryords%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAIS_DELETE');

  -- Считывание текущей записи и заголовка
  select * into rV_Spec from v_payaccinspec t where t.nrn = nrn2;
  rHead := usr_pkg_payaccin.payaccin_get(rV_Spec.nprn);

  /* Наличие у пользователя роли 'Все права' */
  for c in (select null from userroles where authid = utilizer and roleid = 90519)
  loop
    bExistsAllRights := true;
    exit;
  end loop;


  -- Проверка наличия выходных связей
  if ( f_doclinks_link_out('PaymentAccountsIn', rV_Spec.nprn, 'IncomingOrders') is not null
     or f_doclinks_link_out('PaymentAccountsIn', rV_Spec.nprn, 'IncomingInvoices') is not null ) 
  and not bExistsAllRights then
    p_exception(0, 'Документ имеет связи по выходу с разделами "%s" или "%s". %s'
               ,f_unitlist_getname('IncomingOrders')
               ,f_unitlist_getname('IncomingInvoices')
               ,cr||f_docdescrs_get_description('PaymentAccountsIn', rV_Spec.nprn));
  end if;

  -- Удаление текущей записи
  -- подмена статуса на Не утверждён
  update payaccin 
     set doc_state = 0 
   where rn = rHead.rn;
  -- удаление текущей спецификации
  p_payaccinspec_delete(ncompany => rV_Spec.ncompany, nRN => rV_Spec.nrn, nPRN => rV_Spec.nprn);
  -- восстановлени исходного статуса
  update payaccin 
     set doc_state = rHead.doc_state 
   where rn = rHead.rn;

  -- Заголовок заказа
  nDeliveryOrd := f_doclinks_link_in_doc('PaymentAccountsIn', rV_Spec.nprn, 'DeliveryOrders');

  -- Если документ связан с заказом по входу
  if nDeliveryOrd is not null then
    -- если исправлять заказ
    if nvl(NDLOS, 0) = 1 then
      -- считываем аналогичную спецификацию заказа
      usr_pkg_deliveryord.deliveryords_get_by_params
      (
       nprn         => nDeliveryOrd
      ,nnom_modif   => rV_Spec.nnommodif
      ,nnommod_pack => rV_Spec.nnompack
      ,rrow         => rDeliveryOrds
      );
      -- удаление
      usr_pkg_deliveryord.deliveryords_delete(rDeliveryOrds);
    else
      p_exception(0, 'Документ имеет связь по входу с заказом поставщикам, при этом не установлен признак "Исправлять заказ поставщикам". %s'
                  ,cr||f_docdescrs_get_description('PaymentAccountsIn', rV_Spec.nprn));
    end if;
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_PAIS_DELETE;
/
