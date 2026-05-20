create or replace procedure USR_P_TID_UPDATE
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Исправить.
09/10/2024 Степанов М.
*/
(
 nRN                  in number
,nSTATUS_IGNORE       in number
,sMOL                 in varchar2
,sSHEEPVIEW           in varchar2
,sFACEACC             in varchar2
,nFACEACC_CLEAR       in number
,sIN_STORE            in varchar2
,sIN_MOL              in varchar2
,sIN_STOPER           in varchar2
,sCOMMENTS            in varchar2
)
is
  rV_Row          v_transinvdept%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_UPDATE');

  /* Проверка параметров */
  if sMOL||sSHEEPVIEW||sIN_STORE||sIN_MOL||sIN_STOPER||sCOMMENTS||sFACEACC||nFACEACC_CLEAR is null then
    p_exception(0, 'Не заполнены входные параметры. %s'
               ,cr||cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => USR_P_TID_UPDATE.NRN) ); 
  end if;

  /* Считывание текущей записи */
  begin select * into rV_Row from v_transinvdept where nrn = USR_P_TID_UPDATE.NRN; end;

  /* МОЛ склада-отправителя */
  rV_Row.smol := nvl( sMOL, rV_Row.smol );
  /* Вид отгрузки */
  rV_Row.ssheepview := nvl(sSHEEPVIEW, rV_Row.ssheepview);
  /* Лицевой счёт */
  if nFACEACC_CLEAR = 0 then
    rV_Row.sfaceacc := nvl( sFACEACC, rV_Row.sfaceacc );
  else
    rV_Row.sfaceacc := null;
  end if;

  /* Склад-получатель */
  rV_Row.sin_store  := nvl(sIN_STORE, rV_Row.sin_store);
  /* МОЛ склада-получателя */
  rV_Row.sin_mol := nvl(sIN_MOL, rV_Row.sin_mol);
  /* Складская операция прихода */
  rV_Row.sin_stoper := nvl(sIN_STOPER, rV_Row.sin_stoper);
  /* Примечание */
   rV_Row.scomments := nvl( sCOMMENTS, rV_Row.scomments );

  /* Исправление */
  usr_pkg_transinvdept.transinvdept_update(rv_row => rV_Row, nstatus_ignore => nSTATUS_IGNORE );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end;
/
