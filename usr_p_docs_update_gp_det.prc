create or replace procedure usr_p_docs_update_gp_det
/*
Документы. Спецификация. Исправить доп.данные приходной партии.
Основная процедура
11/08/2025 Степанов М.
grant execute on usr_p_docs_update_gp_det to public;
*/
(
 nRN              in number
,nCOMPANY         in number
,sUNITCODE        in varchar
,nSEQ_NUMB        in number   /* Номер по порядку */
,dPROD_DATE       in date     /* Дата производства */
,sPROD_DATE       in varchar  /* Дата производства (текст) */
,sSUPPLIER_PARTY  in varchar  /* Партия поставщика */
,sACCEPT_TYPE     in varchar  /* Вид приёмки */
,sPLAN_CHECK_DATE in varchar  /* Дата плановой поверки */
,sMM_YYYY         in varchar  /* Дата производства. Шаблон */
,sYYWW            in varchar  /* Дата производства. Шаблон */
,sDD_MM_YYYY      in varchar  /* Дата производства. Шаблон */
,sYY              in varchar  /* Дата производства. Шаблон */
)
is
  nNumber       pkg_std.tnumber; 
begin
  /* Открытие процесса */
  usr_pkg_process.process_open( sname => 'USR_P_DOCS_UPDATE_GP_DET' );

  /* Проверки */
  /* Раздел вызова */
  if f_doclinks_link_out(sin_unitcode => sUNITCODE, nin_document => nRN) is not null then
    p_exception(0, 'Запрещено исправление, т.к. документ имеет связи по выходу. RN: %s, раздел: %s.', nRN, f_unitlist_getname( sunitcode => sUNITCODE ) ); 
  end if;
  /* даты производства на превышение текущей даты */
  if dPROD_DATE is not null and cmp_dat_minmax( dPROD_DATE, sysdate ) > 0 then
    p_exception(0, 'Указанная дата производства "%s" больше текущей даты "%s".', decode_date( dPROD_DATE ), decode_date( sysdate ) ); 
  end if;

  /* Исправление */
  /* Номер по порядку */
  pkg_docs_props_vals.modify(nproperty   => 13884319
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => null
                            ,nnum_value  => nSEQ_NUMB
                            ,ddate_value => null
                            ,nrn         => nNumber);
  /* Дата производства (текст) */
  pkg_docs_props_vals.modify(nproperty   => 12114824
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => sPROD_DATE
                            ,nnum_value  => null
                            ,ddate_value => null
                            ,nrn         => nNumber);
  /* Дата произв. (дата) */
  pkg_docs_props_vals.modify(nproperty   => 211014548
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => null
                            ,nnum_value  => null
                            ,ddate_value => dPROD_DATE
                            ,nrn         => nNumber);
  /* Партия поставщика */
  pkg_docs_props_vals.modify(nproperty   => 69192082 
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => sSUPPLIER_PARTY
                            ,nnum_value  => null
                            ,ddate_value => null
                            ,nrn         => nNumber);
  /* Вид приёмки*/
  pkg_docs_props_vals.modify(nproperty   => 8027724  
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => sACCEPT_TYPE
                            ,nnum_value  => null
                            ,ddate_value => null
                            ,nrn         => nNumber);
  /* Дата плановой поверки */
  pkg_docs_props_vals.modify(nproperty   => 134301298  
                            ,sunitcode   => sUNITCODE
                            ,ndocument   => nRN
                            ,sstr_value  => sPLAN_CHECK_DATE
                            ,nnum_value  => null
                            ,ddate_value => null
                            ,nrn         => nNumber);
  /* Закрытие процесса */
  usr_pkg_process.process_close;

exception when others then
  /* Закрытие процесса */
  usr_pkg_process.process_close;
  raise;

end;
/
