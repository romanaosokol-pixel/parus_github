create or replace procedure usr_p_docs_update_gp_det_ini
/*
Документы. Спецификация. Исправить доп.данные приходной партии.
Инициализация параметров для формы
11/08/2025 Степанов М.
grant execute on usr_p_docs_update_gp_det_ini to public;
*/
(
 nIDENT           in number 
,sUNITCODE        in varchar
,nSEQ_NUMB        out number    /* Номер по порядку */
,dPROD_DATE       out date      /* Дата производства */
,sPROD_DATE       out varchar   /* Дата производства (текст) */
,sSUPPLIER_PARTY  out varchar   /* Партия поставщика */
,sACCEPT_TYPE     out varchar   /* Вид приёмки*/
,sPLAN_CHECK_DATE out varchar   /* Дата плановой поверки */
,nRN              out number   
)
is
begin
  /* Проверка превышения отмеченных записей */
  begin
    select document into nRN from selectlist where ident = nIDENT;
  exception
    when no_data_found then
      p_exception(0, 'Не найдены отмеченные записи в разделе %s.', f_unitlist_getname( sunitcode => sUNITCODE ));
    when too_many_rows then
      p_exception(0, 'Отмечено больше одной записи в разделе %s.', f_unitlist_getname( sunitcode => sUNITCODE ));
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске количества отмеченных записей в разделе %s.%s', f_unitlist_getname( sunitcode => sUNITCODE ), cr||sqlerrm );
  end;
  /* Проверка раздела вызова */
  if sUNITCODE not in ( 'IncomingInvoicesSpecs', 'IncomingOrdersSpecs', 'IncomFromDepsSpecs', 'WriteOffActsSpecs', 'RealizationInventorySheetSpec' ) then
    p_exception(0, 'Неверный раздел вызова "%s"', sUNITCODE);
  end if;
  /* Присвоение результатов */
  nSEQ_NUMB        := usr_pkg_docs_props_vals.get_val_num ( ndoc_prop => 13884319 , ndocument => nRN );   /* Номер по порядку */
  sPROD_DATE       := usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 12114824 , ndocument => nRN );   /* Дата производства (текст) */
  dPROD_DATE       := usr_pkg_docs_props_vals.get_val_date( ndoc_prop => 211014548, ndocument => nRN );   /* Дата произв. (дата) */
  sSUPPLIER_PARTY  := usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 69192082 , ndocument => nRN );   /* Партия поставщика */
  sACCEPT_TYPE     := usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 8027724  , ndocument => nRN );   /* Вид приёмки*/
  sPLAN_CHECK_DATE := usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 134301298, ndocument => nRN );   /* Дата плановой поверки */

end;
/
