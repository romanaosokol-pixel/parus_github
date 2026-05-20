create or replace procedure udo_p_umts_report_del_ord(ncompany        in number /*Организация*/,
                                                      nident          in number /*Идентификатор отмеченных записей*/,
                                                      nprocess        in number /*Идентификатор процесса*/,
                                                      nsign_pay_acc   in number /*Признак запроса счета-договора*/,
                                                      nsign_vp        in number /*Признак военной приемки*/,
                                                      sprod_chief_fio in varchar2 /*Начальник производства*/,
                                                      svp_post        in varchar2 /*ВП. Должность*/,
                                                      svp_fio         in varchar2 /*ВП. ФИО*/,
                                                      svp_del_post    in varchar2 /*ВП поставщика. Должность*/,
                                                      svp_del_fio     in varchar2 /*ВП поставщика. ФИО*/) is

  /*Анненко И.С.*/

  /*08.09.022*/

  --create public synonym udo_p_umts_report_del_ord for udo_p_umts_report_del_ord;

  --grant execute on udo_p_umts_report_del_ord to public;

  /*Процедура выполняет формирование печатной формы заказа поставщику*/

  BREP BLOB;
  CREP CLOB;

  /*Атрибуты заказа поставщику*/
  rdel_ord deliveryord%rowtype;

  /*Номер строки*/
  nrow_num number;

  /*Идентификатор строки*/
  nrow number;

  /*ОБС*/
  sobs pkg_std.tSTRING;

  /*Банк*/
  sbank pkg_std.tSTRING;

  /*КоррСчет*/
  scs pkg_std.tSTRING;

  /*БИК*/
  sbik pkg_std.tSTRING;
  
  /* ИГК */
  sIGK  GOVCNTRID.CODE%type;
  sDate varchar2(32); --GOVCNTRID.DATESTART%type;

begin
  /*Получаем шаблон отчета*/
  begin
    select T.TEMPLATE_DATA
      into BREP
      from USERREPORTS T
     where T.COMPANY = Pkg_Session.GET_COMPANY()
       and T.RN = PKG_USERREPORTS.GET_REPORT();
  exception
    when no_data_found then
      p_exception(0, 'Шаблон отчета не найден.');
  end;

  /*Регистрационный номер записи заказа поставщику*/
  begin
    select sl.document
      into rdel_ord.rn
      from selectlist sl
     where sl.ident = nident
       and sl.company = ncompany;
  exception
    when no_data_found then
      p_exception(0,
                  'Необходимо выбрать заказ поставщику');
    when too_many_rows then
      p_exception(0,
                  'Необходимо выбрать единственный заказ поставщику');
  end;

  /*Атрибуты заказа поставщику*/
  begin
    select do.*
      into rdel_ord
      from deliveryord do
     where do.rn = rdel_ord.rn
       and do.company = ncompany;
  exception
    when no_data_found then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rdel_ord.rn,
                               sUNIT_TABLE => 'DeliveryOrders');
  end;

  /*Инициализация*/
  UDO_PKG_WINWORD.PREPARE(PAGEBREAK_IN_FIRST_PARAGRAPH => false,
                          DELETE_FIELDS                => true);

  /*Загрузка шиблона отчета*/
  UDO_PKG_WINWORD.LOAD(DATA => BREP, SNLS_CHARSET_ID => 'UTF8');

  /*Поставщик. Наименование*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ПоставщикНаименование',
                                  SVALUE   => get_agnlist_agnname_id(nFLAG_SMART => 0,
                                                                     nRN         => rdel_ord.agent));

  /*Поставщик. Директор. Должность*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ПоставщикДиректорДолжность',
                                  SVALUE   => 'ПоставщикДиректорДолжность');

  /*Поставщик. Директор. ФИО*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ПоставщикДиректорФИО',
                                  SVALUE   => 'ПоставщикДиректорФИО');

  /*Поставщик. Телефон*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ПоставщикТелефон',
                                  SVALUE   => 'ПоставщикТелефон');

  /*Поставщик. Адрес*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ПоставщикАдрес',
                                  SVALUE   => 'ПоставщикАдрес');

  /*Военная приемка*/
  if (nsign_vp = 1) then
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВППостДолжность',
                                    SVALUE   => svp_del_post);
  
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВППостФИО',
                                    SVALUE   => svp_del_fio);
  else
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВППостДолжность',
                                    SVALUE   => to_char(null));
  
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВППостФИО',
                                    SVALUE   => to_char(null));
  end if;

  /*Приемка*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'Приемка',
                                  SVALUE   => prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                                                             nVERSION  => to_number(null),
                                                             sUNITCODE => 'DeliveryOrders',
                                                             nDOCUMENT => rdel_ord.rn,
                                                             sPROPCODE => 'ПРИЕМКА'));
  /*Номер строки*/
  nrow_num := 0;

  /*Цикл по строкам заказа*/
  for sp_cursor in 
    (select n.nomen_name as snomen_name,
           (case
             when (instr(nm.modif_name, '_') = 0) then
              (nm.modif_name)
             else
              (substr(nm.modif_name,
                      instr(nm.modif_name, '_') + 1))
           end) as smodif_name,
           s.main_quant as nmain_quant
      from deliveryords s, dicnomns n, nommodif nm
     where s.prn = rdel_ord.rn
       and s.company = ncompany
       and n.rn = s.nomen
       and nm.rn = s.nom_modif
     order by n.nomen_name
     ) loop
    /*Номер строки*/
    nrow_num := nrow_num + 1;
  
    /*Выполняем добавление строки*/
    nrow := UDO_PKG_WINWORD.APPEND_TABLEROW(ntablenum => 1,
                                            nbeginrow => 2,
                                            nendrow   => 2);
    /*Номер*/
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ТаблицаНомер',
                                    SVALUE   => to_char(nrow_num),
                                    TABLEROW => nrow);
	  /*Наименование*/
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ТаблицаНаименование',
                                    SVALUE   => sp_cursor.snomen_name,
                                    TABLEROW => nrow);
    /*ТУ*/
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ТаблицаТУ',
                                    SVALUE   => sp_cursor.smodif_name,
                                    TABLEROW => nrow);
    /*Количество*/
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ТаблицаКоличество',
                                    SVALUE   => sp_cursor.nmain_quant,
                                    TABLEROW => nrow);
  end loop;

  /*Удаляем шаблон строки*/
  UDO_PKG_WINWORD.DELETE_TABLEROW(ntablenum => 1,
                                  nbeginrow => 2,
                                  nendrow   => 2);
  /*ИГК*/
  sIGK := prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                         nVERSION  => to_number(null),
                         sUNITCODE => 'DeliveryOrders',
                         nDOCUMENT => rdel_ord.rn,
                         sPROPCODE => 'ИГК');
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ИГК', SVALUE => sIGK);
  /*Дата ИГК*/
  begin
    select to_char(gov.datestart, 'DD.MM.YYYY')  
      into sDate
      from GOVCNTRID gov 
     where gov.code = trim(sIGK);
  exception
    when no_data_found then
      sDate := '01.01.1900';
  end;
--if USER = 'KHOK' then p_exception(0, sIGK || ' - ' ||sDate); end if;

  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ДатаИГК',
                                  SVALUE   => sDate);

  /*Запрос счета-договора*/
  if (nsign_pay_acc = 1) then
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ЗапросСчетДог',
                                    SVALUE   => 'Прошу оформить счет-договор с указанием ГК, ИГК, сроком поставки, внести банковские реквизиты');
  else
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ЗапросСчетДог',
                                    SVALUE   => to_char(null));
  end if;

  if (prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                     nVERSION  => to_number(null),
                     sUNITCODE => 'DeliveryOrders',
                     nDOCUMENT => rdel_ord.rn,
                     sPROPCODE => 'ИнстрОпл') is not null) then
    begin
      select /*ОБС*/
       acc.agnacc
       /*Банк*/,
       agn.agnname
       /*КоррСчет*/,
       b.bankacc
       /*БИК*/,
       b.bankfcodeacc
        into /*ОБС*/ sobs
             /*Банк*/,
             sbank
             /*КоррСчет*/,
             scs
             /*БИК*/,
             sbik
        from finpaytool t, agnacc acc, agnbanks b, agnlist agn
       where t.code = prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                                     nVERSION  => to_number(null),
                                     sUNITCODE => 'DeliveryOrders',
                                     nDOCUMENT => rdel_ord.rn,
                                     sPROPCODE => 'ИнстрОпл')
         and acc.rn = t.payer_acc
         and b.rn = acc.agnbanks
         and agn.rn = b.agnrn;
    exception
      when no_data_found then
        p_exception(0, 'Не удалось определить платежные реквизиты');
      when too_many_rows then
        p_exception(0, 'Не удалось однозначно определить платежные реквизиты');
    end;
  end if;

  /*ОБС*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ОБС', SVALUE => sobs);

  /*Банк*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'Банк', SVALUE => sbank);

  /*КоррСчет*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'КоррСчет', SVALUE   => scs);

  /*БИК*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'БИК', SVALUE => sbik);

  /*Начальник производства. Должность*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'НачПроизвФИО',
                                  SVALUE   => sprod_chief_fio);

  /*Военная приемка*/
  if (nsign_vp = 1) then
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВПДолжность',
                                    SVALUE   => svp_post);
  
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВПФИО',
                                    SVALUE   => svp_fio);
  else
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВПДолжность',
                                    SVALUE   => to_char(null));
  
    UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'ВПФИО',
                                    SVALUE   => to_char(null));
  end if;

  /*Ответственный*/
  UDO_PKG_WINWORD.SET_DOCPROPERTY(SDOCPROP => 'Ответственный',
                                  SVALUE   => get_agnlist_agnabbr_id(nFLAG_SMART => 0,
                                                                     nRN         => rdel_ord.acc_agent));

  /*Сохранение отчета*/
  UDO_PKG_WINWORD.SAVE(DATA => CREP);

  /*Запись в буфер для отображения*/
  p_file_buffer_insert(nIDENT    => NPROCESS,
                       cFILENAME => '.DOC',
                       cDATA     => CREP,
                       bLOBDATA  => null);
end udo_p_umts_report_del_ord;
/

