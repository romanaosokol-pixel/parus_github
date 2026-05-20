create or replace procedure usr_p_tid_strplresjrnl_mins
/*
Расходные накладные на отпуск в подразделения
Действие "Массовое резервирование по местам хранения"
17/02/2025 Степанов М.
grant execute on usr_p_tid_strplresjrnl_mins to public;
*/
(
 nCOMPANY       in number                 /* Рег номер организации */
,sUNITCODE      in varchar2 default null  /* Код раздела (не используется) */
,nCRN           in number   default null  /* каталог */
,nRN            in number                 /* Рег номер */
,sSTORE         in varchar2 default null  /* склад */
,sCELL          in varchar2 default null  /* место хранения (резервуар) */
,nRES_TYPE      in number   default 1     /* тип резервирования (0 - приход, 1 - расход) */
,nREPLACE       in number   default 0     /* Распределение с заменой найденных записей (0 - нет, 1 - да) */
,nRETURN        in number   default 0     /* признак возвратной накладной (0 - нет, 1 - да) */
,dRESERVINGDATE in date     default null  /* дата и время резервирования. */
,nOUTNOTE       out number
) 
as
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_STRPLRESJRNL_MINS');

  /* Процедура резервирования */
  usr_pkg_transinvdept.transinvdept_sprj_mins(ncompany       => nCOMPANY
                                             ,sunitcode      => sUNITCODE
                                             ,ncrn           => nCRN
                                             ,nrn            => nRN
                                             ,nident         => nRN
                                             ,sstore         => sSTORE
                                             ,scell          => sCELL
                                             ,nres_type      => nRES_TYPE
                                             ,nreplace       => nREPLACE
                                             ,nreturn        => nRETURN
                                             ,dreservingdate => dRESERVINGDATE
                                             ,noutnote       => nOUTNOTE);
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end;
/
