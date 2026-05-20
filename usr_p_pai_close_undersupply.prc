create or replace procedure USR_P_PAI_CLOSE_UNDERSUPPLY
/*
Входящий счёт на оплату. Заголовок. 
Закрыть недопоставленный счёт
В недопоставленных спецификациях изменяет количество и сумму по документу на количество и сумму фактически. Переводит документ в статус "Закрыт"
25/02/2025 Степанов М.
*/
(
 nRN            in number /* Заголовок */
)
is
  rRow                  payaccin%rowtype;
  rV_Spec               v_payaccinspec%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_CLOSE_UNDERSUPPLY');

  /* Заголовок */
  rRow := usr_pkg_payaccin.payaccin_get( nrn => nRN );

  /* По спецификациям */
  for c in (select * from v_payaccinspec where nprn = rRow.rn )
  loop
    rV_Spec := c;

    /* Если количество по документу больше количества фактически */
    if rV_Spec.nquant > nvl(rV_Spec.nfactquant, 0) then

      /* Исправляем спецификацию, в количество и сумму по документу записываем количество и сумму фактически */
      rV_Spec.nquant       := rV_Spec.nfactquant;
      rV_Spec.nsummwithnds := rV_Spec.nfactsumm;
      usr_pkg_payaccin.payaccinspec_update( rv_row => rV_Spec, nflag_del_calc => 0, nmode => 1 );

    /* Если количество по документу меньше количества фактически */
    elsif rV_Spec.nquant < nvl( rV_Spec.nfactquant, 0 ) then
      p_exception(0, 'Количество по документу <%s> меньше, чем количество фактически <%s>. %s%s'
                 ,rV_Spec.nquant
                 ,rV_Spec.nfactquant
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsInSpecs', ndocument => rV_Spec.nrn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Spec.nprn));
    end if;

  end loop;

  /* Повторное считывание заголовка после исправления спецификаций */
  rRow := usr_pkg_payaccin.payaccin_get(nrn => rRow.rn);

  /* Проверка что сумма оплаты не больше суммы оприходовано */
  if nvl(rRow.factpaysumm, 0) > nvl(rRow.inordsumm, 0) then
    p_exception(0, 'Сумма "Фактических платежей" по документу <%s> больше, чем сумма "Оприходовано фактически" <%s>. %s'
               ,rRow.factpaysumm
               ,rRow.inordsumm
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'PaymentAccountsIn', ndocument => rV_Spec.nprn));
  end if;

  /* Переводим счёт в состояние Закрыт */
  p_payaccin_set_status(ncompany   => rRow.company
                       ,nrn        => rRow.rn
                       ,nstatus    => 3
                       ,dwork_date => rRow.state_date);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
