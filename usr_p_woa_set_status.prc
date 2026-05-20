create or replace procedure USR_P_WOA_SET_STATUS
/*
Раздел: "Акты списания недостач/оприходования излишков"
Процедура: Отработать.
30/01/2024 Степанов М.
*/
(
 nRN              in number
,dDATE            in date
,nUSE_DOC_DATE    in number default 1 /* использовать дату документа: 0 - нет, 1 - да*/
)
is
  rRow          wroffacts%rowtype;
  dWorkDate     date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_WOA_SET_STATUS');

  /* Запись */
  rRow := usr_pkg_wroffacts.wroffacts_get(nrn => nRN);

  /* Дата отработки */
  /* если не задана, то текущая */
  dWorkDate := nvl(dDATE, current_date);

  /* Если использовать дату документа */
  if cmp_num(nUSE_DOC_DATE, 1) = 1 then
    dWorkDate := rRow.docdate;
  end if;

  /* Отработка */
  p_wroffacts_setstatus(ncompany   => rRow.company
                       ,nrn        => rRow.rn
                       ,nstatus    => 1
                       ,dwork_date => dWorkDate
                       ,smsg       => rRow.comments
                       ,nident_msg => rRow.rn);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_WOA_SET_STATUS;
/
