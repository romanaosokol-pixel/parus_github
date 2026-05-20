create or replace procedure usr_p_dlo_update
/*
Раздел: "Заказы поставщикам"
Процедура: Исправить.
28/02/2025 Степанов М.
*/
(
 nRN          in number
,sFACEACC     in varchar2
)
is
  nRN2            pkg_std.tref := nRN;
  rV_Row          v_deliveryord%rowtype;
  nFaceAcc        pkg_std.tref; 
  rV_FaceAcc      v_faceacc%rowtype;

  sVarchar        pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DLO_UPDATE');

  /* Проверка параметров */
  /* Наличие выходных связей с входящими счетами */
  if f_doclinks_link_out(sin_unitcode => 'DeliveryOrders', nin_document => nRN, sout_unitcode => 'PaymentAccountsIn') is null then
    p_exception(0, 'Документ имеет связь по выходу с разделом "Входящие счета на оплату". %s'
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'DeliveryOrders', ndocument => nRN) );
  end if;

  /* Считывание */
  /* Текущая запись */
  begin select * into rV_Row from v_deliveryord where nrn = nRN2; end;
  /* Лицевой счёт. RN */
  find_faceacc_numb(nflag_smart  => 0
                   ,nflag_option => 0
                   ,ncompany     => rV_Row.ncompany
                   ,snumb        => sFACEACC
                   ,nrn          => nFaceAcc);
  /* Лицевой счёт. Запись представления */
  begin select * into rV_FaceAcc from v_faceacc where nrn = nFaceAcc; end;

  /* Подмена значений */
  rV_Row.sfaceacc := nvl(rV_FaceAcc.snumber, rV_Row.sfaceacc);
  rV_Row.sagent   := nvl(rV_FaceAcc.sagent, rV_Row.sagent);
  
  /* Исправление */
  usr_pkg_deliveryord.deliveryord_update(rv_row => rV_Row, nmode => 1);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
