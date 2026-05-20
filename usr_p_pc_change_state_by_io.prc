create or replace procedure USR_P_PC_CHANGE_STATE_BY_IO
/*
Сертификация/Входной контроль.
Изменить состояние документа по RN приходного ордера
Для использования сканера штрих-кодов
*/
(
 sINORDERS        in varchar2   /* Приходный ордер. RN*/
,sSTATE_VK        in varchar2   /* Новый статус */
,sSTATE_VK_NOTE   in varchar2   /* Примечание */
)
as
  nState          pkg_std.tnumber;  
  nProd_Cull      pkg_std.tref; 
  rProd_Cull      udo_prod_cull%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PC_CHANGE_STATE_BY_IO');
  
  /* Сертификация/входной контроль. RN */
  nProd_Cull := usr_pkg_doclinks.doclinks_link_out_doc(sin_unitcode  => 'IncomingOrders'
                                                      ,nin_document  => to_number(sINORDERS)
                                                      ,sout_unitcode => 'UdoProdCull');
  /* Сертификация/входной контроль. Запись */
  rProd_Cull := usr_pkg_prod_cull.prod_cull_get(nrn => nProd_Cull);
  
  /* Новый статус по наименованию */
  nState := usr_pkg_prod_cull.prod_cull_get_status_by_name(sstatus => sSTATE_VK);

  /* Если новый статус "Принято на ВК", а текущий не равен "Новый документ" */
  if  nState = 1 
  and cmp_num(rProd_Cull.State_Vk, 0) != 1 then
    p_exception(0, 'Текущий статус документа <%s> не равен статусу <%s>. %s'
               ,usr_pkg_prod_cull.prod_cull_get_status_name(nstatus => rProd_Cull.State_Vk)    
               ,usr_pkg_prod_cull.prod_cull_get_status_name(nstatus => 0)    
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'UdoProdCull', ndocument => rProd_Cull.rn) ); 
  end if; 

  /* Пролог */
  pkg_env.prologue(ncompany  => rProd_Cull.company
                  ,nversion  => null
                  ,ncatalog  => rProd_Cull.crn
                  ,njur_pers => rProd_Cull.Jurpers
                  ,sunit     => 'UdoProdCull'
                  ,saction   => 'UDO_PROD_CULL_STATE_VK'
                  ,stable    => 'UDO_PROD_CULL'
                  ,ndocument => rProd_Cull.rn);

  /* базовое изменение */
  udo_pkg_prod_cull.cull_state_vk(nrn => rProd_Cull.rn, nstate => nState, snote => sSTATE_VK_NOTE);

  /* Эпилог */
  pkg_env.epilogue(ncompany  => rProd_Cull.company
                  ,nversion  => null
                  ,ncatalog  => rProd_Cull.crn
                  ,njur_pers => rProd_Cull.Jurpers
                  ,sunit     => 'UdoProdCull'
                  ,saction   => 'UDO_PROD_CULL_STATE_VK'
                  ,stable    => 'UDO_PROD_CULL'
                  ,ndocument => rProd_Cull.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
