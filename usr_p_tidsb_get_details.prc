create or replace procedure USR_P_TIDSB_GET_DETAILS
/*
Раздел: Расходные накладные на отпуск в подразделения (спецификации): буфер формирования
Процедура для получения значений полей для использования в окне просмотра
create public synonym USR_P_TIDSB_GET_DETAILS for USR_P_TIDSB_GET_DETAILS;
grant execute on USR_P_TIDSB_GET_DETAILS to public;
*/
(
 nRN          in number
,sOUT         out varchar2
)
as
  rV_Row   v_transinvdeptspbuf%rowtype;
begin
  begin
    select * into rV_Row from v_transinvdeptspbuf where nrn = NRN;
  exception
    when no_data_found then
      return;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,NRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPTSPBUF')));
  end;

  sOUT := 'Сертификат: '||rV_Row.scertificate;

end USR_P_TIDSB_GET_DETAILS;
/
