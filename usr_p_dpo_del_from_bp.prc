create or replace procedure USR_P_DPO_DEL_FROM_BP
/*
Заказы подразделений. Исключить из плана закупок
10/10/2024 Степанов М.
*/
(
 nRN            in number
,nCOMPANY       in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DPO_DEL_FROM_BP');

  /* По связанным заказам поставщикам */
  for c in ( select distinct dlos.prn
               from departmentords                 dpos
                   ,buyplanespref                  bpsp
                   ,udo_uzd_03_buyplanesp_cntr_doc t
                   ,deliveryords                   dlos
              where dpos.prn        = nRN
                and bpsp.deptordsp  = dpos.rn
                and t.rn_ref        = bpsp.rn
                and dlos.rn         = t.doc_rn )
  loop
    /* По входящим счетам на оплату */
    for c1 in ( select dl.out_document
                  from doclinks dl
                 where dl.in_document  = c.prn
                   and dl.out_unitcode = 'PaymentAccountsIn' )
    loop
      /* удаление входящего счета */
      p_payaccin_delete( ncompany => nCOMPANY, nrn => c1.out_document );
    end loop;

    /* удаление заказа поставщику */
     p_deliveryord_delete( ncompany => nCOMPANY, nrn => c.prn );
  end loop;

  /* По связанным распоряжениям об изменении плана закупок */
  for c in ( select distinct bpds.prn
               from departmentords    dpos
                   ,buyplandirspref   bpdsp
                   ,buyplandirsp      bpds
              where dpos.prn        = nRN
                and bpdsp.deptordsp = dpos.rn
                and bpds.rn         = bpdsp.prn )
  loop
    /* Снятие отработки распоряжения плана закупок */
    udo_pkg_umts_05_replan.p_buyplandir_cancel( ncompany => nCOMPANY, nrn => c.prn );
    /* Удаление распоряжения плана закупок */
    p_buyplandir_delete( ncompany => nCOMPANY, nrn => c.prn );
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end;
/
