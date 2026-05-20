create or replace procedure usr_p_tid_set_check_prop
/*
Раздел: Расходные накладные на отпуск в подразделения (спецификации)
Установить свойство "Проверено" по штрих-коду приходной партии
*/
(
 nRN        in number
,sUNITCODE  in varchar2
,sBARCODE   in varchar2 /* Штрих-код ( GOODSPARTIES.RN  ) */
,nCLEAR     in number   /* Очистить значения во всех спецификациях: 0- нет, 1 - да */
)
as
  nBarCode    pkg_std.tref; 
  nTICS       pkg_std.tref; 
  nNumber     pkg_std.tnumber;
  dDate       date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open( sname => 'usr_p_tid_set_check_prop' );

  /* Очистить значения во всех спецификациях - да */
  if nCLEAR = 0 then

    /* Перевод штрих-кода в число */
    begin
      nBARCODE := to_number( sBARCODE ); 
    exception when others then
      p_exception(0, 'Недопустимое значение <%s> штрих-кода.%s'
                 ,sBARCODE
                 ,cr||cr||f_docdescrs_get_description( sunitcode => sUNITCODE, ndocument => nRN ) );
    end;

    /* Поиск спецификации в текущем документе с такой партией */
    begin
      select rn
        into nTICS
        from transinvdeptspecs 
       where prn = nRN
         and ( ( goodsparty is not null 
                and article is null 
                and goodsparty = nBarCode )
             or 
               ( goodsparty is null 
                and article is not null 
                and article in ( select article from articlessupply where prn = nBarCode ) ) );
    exception
      when no_data_found then
        p_exception(0, 'Не найдена спецификация с партией <%s>.%s'
                   ,sBARCODE
                   ,cr||cr||f_docdescrs_get_description( sunitcode => sUNITCODE, ndocument => nRN ) );
        p_exception(0, 'Неайдено больше одной спецификации с партией <%s>.%s'
                   ,sBARCODE
                   ,cr||cr||f_docdescrs_get_description( sunitcode => sUNITCODE, ndocument => nRN ) );
      when others then
        p_exception(0, 'Нопределённая ситуация при поиске спецификации с партией <%s>.%s'
                   ,sBARCODE
                   ,cr||cr||f_docdescrs_get_description( sunitcode => sUNITCODE, ndocument => nRN ) );
    end;

    /* Установка значения свойства "Проверено" */
    pkg_docs_props_vals.modify(nproperty   => 167924481
                              ,sunitcode   => 'GoodsTransInvoicesToDeptsSpecs'
                              ,ndocument   => nTICS
                              ,sstr_value  => 'Да'
                              ,nnum_value  => nNumber
                              ,ddate_value => dDate
                              ,nrn         => nNumber);

  /* Очистить значения во всех спецификациях - нет */
  else

    /* По спецификациям */
    for c in (select rn from transinvdeptspecs where prn = nRN)
    loop
      /* Очистка значения свойства "Проверено" */
      pkg_docs_props_vals.modify(nproperty   => 167924481
                                ,sunitcode   => 'GoodsTransInvoicesToDeptsSpecs'
                                ,ndocument   => c.rn
                                ,sstr_value  => null
                                ,nnum_value  => nNumber
                                ,ddate_value => dDate
                                ,nrn         => nNumber);
    end loop;

  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
