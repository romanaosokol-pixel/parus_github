create or replace procedure USR_P_TID_SET_STATUS
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Отработать.
06/03/2024 Степанов М.
*/
(
 nRN              in number
,dDATE            in date
,nUSE_DOC_DATE    in number default 1 /* использовать дату документа: 0 - нет, 1 - да*/
)
is
  rRow          transinvdept%rowtype;
  dWorkDate     date;
  nIn_Status    pkg_std.tnumber := 0; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_SET_STATUS');

  /* Запись */
  rRow := usr_pkg_transinvdept.transinvdept_get(nrn => nRN);

  /* Дата отработки */
  /* если не задана, то текущая */
  dWorkDate := nvl(dDATE, current_date);

  /* Если использовать дату документа */
  if cmp_num(nUSE_DOC_DATE, 1) = 1 then
    dWorkDate := rRow.docdate;
  end if;

  /* Если заполнен склад-получатель, то отработка с приходом */
  if rRow.in_store is not null then
    nIn_Status := 1; 
  end if;

  /* Отработка */
  p_transinvdept_set_status(ncompany      => rRow.company
                           ,nrn           => rRow.rn
                           ,nstatus       => 2
                           ,nin_status    => nIn_Status
                           ,din_work_date => dWorkDate
                           ,dwork_date    => dWorkDate
                           ,smsg          => rRow.comments
                           ,sconfirm      => rRow.comments
                           ,nident_msg    => rRow.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_TID_SET_STATUS;
/
