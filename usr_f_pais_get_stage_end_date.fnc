create or replace function USR_F_PAIS_GET_STAGE_END_DATE
/*
Раздел "Входящие счета на оплату (спецификация)".
Функция для колонки "#Дата окончания этапа - LAG"
10/01/2024 Степанов М.
grant execute on USR_F_PAIS_GET_STAGE_END_DATE to public;
*/
(
 nRN in number
)
return date
as
  dDate   date;
begin
  begin
    select min(nvl(st.end_date, pjs.endplan)) - 91
      into dDate
      from payaccinspec       t
          ,payaccinspclc      paisc
          ,payaccinspclc_ex   paisce
          ,departmentord      do
          ,projectstage       pjs
          ,stages             st
     where t.rn             = nRN
       and paisc.prn        = t.rn
       and paisce.prn       = paisc.rn
       and do.rn            = paisce.departmentord
       and pjs.faceacc      = do.faceacc
       and pjs.faceacccust  = st.faceacc(+);
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPEC'))
                   ,sqlerrm
                   );
  end;

  return dDate;
  
end USR_F_PAIS_GET_STAGE_END_DATE;
/
