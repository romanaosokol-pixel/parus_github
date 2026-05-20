create or replace procedure usr_p_tic_update
/*
Раздел: "Расходные накладные на отпуск потребителям"
Процедура: Исправить.
11/10/2024 Степанов М.
23/10/2025 Городецекий О. Добавил исправление даты накладной
*/
(
 nRN            in number
,sDOCTYPE       in varchar2
,dDOCDATE       in date
,dWORK_DATE     in date
,nUSE_DOC_DATE  in number   /* Использовать дату документа: 0 - нет, 1 - да */
) 
is
  rV_Row    v_transinvcust%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TIC_UPDATE');

  /* Считывание текущей записи */
  select * into rV_Row from v_transinvcust where nrn = usr_p_tic_update.nrn;

  /* Подстановка значений в переменную */
  rV_Row.sdoctype   := nvl( sDOCTYPE, rV_Row.sdoctype );
  rV_Row.ddocdate   := nvl( dDOCDATE, rV_Row.ddocdate );
  if nUSE_DOC_DATE = 1 then 
    rV_Row.dwork_date := rV_Row.ddocdate; 
  else    
    rV_Row.dwork_date := nvl( dWORK_DATE, rV_Row.dwork_date );
  end if;
    
  /* Исправление */
  usr_pkg_transinvcust.transinvcust_update( rV_Row => rV_Row, nmode => 1 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
    usr_pkg_process.process_close;
    raise;
end;
/
