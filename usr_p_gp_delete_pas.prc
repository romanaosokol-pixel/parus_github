create or replace procedure USR_P_GP_DELETE_PAS
/*
Приходные партии товара
Удалить из счёта на оплату
03/04/2024 Степанов М.
*/
(
 nRN        in number
,nPAYACC    in number
)
is
  nNumber   pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GP_DELETE_PAS');

  /* По спецификациям счёта на оплату с текущей приходной партией товара */
  for c in (select * from payaccspecs where prn = nPAYACC and goodsparty = nRN)
  loop
    /* Удаление */
    p_payaccspecs_delete(ncompany                => c.company
                        ,nrn                     => c.rn
                        ,nprn                    => c.prn
                        ,nsumm_base_delta        => nNumber
                        ,nsummwithnds_base_delta => nNumber
                        ,nsumm_payacc            => nNumber
                        ,nsummwithnds_payacc     => nNumber);
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GP_DELETE_PAS;
/
