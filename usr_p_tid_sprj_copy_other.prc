create or replace procedure USR_P_TID_SPRJ_COPY_OTHER
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Копировать места хранения для распределения из другого документа.
06/03/2024 Степанов М.
create public synonym USR_P_TID_SPRJ_COPY_OTHER for USR_P_TID_SPRJ_COPY_OTHER;
grant execute on USR_P_TID_SPRJ_COPY_OTHER to public;
*/
(
 nFLAGSMART       in number
,sDETAILS_FROM    in varchar2
,nRES_TYPE_FROM   in number
,nRN              in number
,nRES_TYPE_TO     in number
,dRESERVING_DATE  in date
)
is
  nRN_FROM      pkg_std.tref;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_SPRJ_COPY_OTHER');

  /* Заголовок документа-отправителя */
  nRN_FROM := usr_pkg_document.get_rn_by_str_details( nflagsmart => 0, sunitcode => 'GoodsTransInvoicesToDepts', sdetails => sDETAILS_FROM );

  /* Копирование мест хранения для распределения из документа-отправителя в места хранения для списания в документ-получатель */
  usr_pkg_transinvdept.transinvdept_sprj_copy_other( nflagsmart      => nFLAGSMART
                                                    ,nrn_from        => nRN_FROM
                                                    ,nres_type_from  => nRES_TYPE_FROM
                                                    ,nrn_to          => nRN
                                                    ,nres_type_to    => nRES_TYPE_TO
                                                    ,dreserving_date => nvl( dRESERVING_DATE, sysdate ) );
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_TID_SPRJ_COPY_OTHER;
/
