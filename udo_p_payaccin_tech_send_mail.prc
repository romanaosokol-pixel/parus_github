create or replace procedure UDO_P_PAYACCIN_TECH_SEND_MAIL(
  nCOMPANY           in number,         -- рег. номер организации
  nRN                in number          -- рег. номер ВСО
  )
is
/*
    02/03/2023 Хохряков А.В.
    Входящие счета на оплату
    Отправка уведомительного e-mail сообщения Технологам
*/
  nAGN               PKG_STD.tREF;      -- Рег номер контрагента
  SPAYACCIN          PKG_STD.tSTRING;   -- Реквизиты ВСО
  SAGMAIL            PKG_STD.tSTRING;   -- Адрес E-mail
  STO_LIST           PKG_STD.tSTRING := 'a.khokhryakov@module.ru';   -- Перечень E-mail адресов
  SZAYAVKA           PKG_STD.tSTRING;   -- Реквизиты Заказа
  SUNITCODE          PKG_STD.tSTRING := 'DepartmentsOrders';   -- Код раздела заказы подразделений
  SDOCPROPCODE       PKG_STD.tSTRING := 'ROWID_1C';            -- Код свойства Идентификатор документа 1С (Версия документа)
  /* Сообщение */
  CTEXT              PKG_STD.tSTRING := 'По заявке <номер заявки> от <дата заявки> создан Входящий счет на оплату <номер счета на оплату> от <дата счета на оплату>. Необходимо согласовать спецификацию счета';
  /* Тема */
  STITLE             PKG_STD.tSTRING := 'Входящий счет на оплату по Заявке <Номер заявки>';
begin
  for FACC in (select distinct (clc.faceaccount), PSD.ROWID_1C
                 from PAYACCINSPEC            sp,
                      PAYACCINSPCLC           clc,
                      UDO_PAYACCINSPEC_DEPORD PSD
                where sp.prn = nrn --7559427
                  and sp.company = nCOMPANY
                  and clc.prn = sp.rn
                  and psd.prn = sp.rn) loop
    begin
      select TRIM(P.EXT_NUMB) || ' от ' || to_char(p.reg_date,'dd.mm.yyyy')
        into SPAYACCIN
        from PAYACCIN P
       where P.RN = NRN
         and P.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        SPAYACCIN := null;
    end;
    
    /* Найдем e-mail технологов */
    begin
      select agn.mail into SAGMAIL
        from CLNPERSONS clp,
             AGNLIST    agn
       where clp.pers_authid in (select us.authid from USERGRPSP us where PRN = 62526127) -- Группа Технологи
         and clp.PERS_AGENT = agn.RN;     
      /* Соберем e-mail ответственных */
      STO_LIST := SAGMAIL || ';' || STO_LIST;
    exception
      when NO_DATA_FOUND then
        SAGMAIL := null;
    end;
    /* Найдем заказ */
    for zakaz in (select TRIM(dep.ORD_PREF) || '-' || TRIM(dep.ORD_NUMB) DPORD_NUM,
                         dep.ORD_DATE ORD_DATE
                    from DEPARTMENTORD dep, docs_props_vals dv, DOCS_PROPS DP
                   where dv.str_value = FACC.ROWID_1C
                     and DV.DOCS_PROP_RN = DP.RN
                     and DP.CODE = SDOCPROPCODE
                     and dv.unitcode = SUNITCODE
                     and dep.RN = DV.UNIT_RN) loop

      SZAYAVKA := zakaz.dpord_num || ' от ' || to_char(zakaz.ord_date, 'dd.mm.yyyy') || '; ' ||
                  SZAYAVKA;
    end loop;

  end loop;
  --STO_LIST := 'a.khokhryakov@module.ru'; --RTRIM(STO_LIST, ';');
  SZAYAVKA := RTRIM(SZAYAVKA, ';');

  CTEXT := replace(replace(CTEXT, '<номер заявки> от <дата заявки>', SZAYAVKA),
                   '<номер счета на оплату> от <дата счета на оплату>', SPAYACCIN);
                   
   CTEXT := CTEXT||CR||CR||CR||'Данное сообщение сформировано автоматически, не отвечаете на сообщение.';
  /* Тема */
  STITLE := replace(STITLE, '<Номер заявки>', SZAYAVKA);
  /* Отправка E-mail сообщения (по списку получателей) */
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT,
                                --NFILE_BUFFER_IDENT      in number := null, -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
  
end UDO_P_PAYACCIN_TECH_SEND_MAIL;
-- grant execute on UDO_P_PAYACCIN_TECH_SEND_MAIL to public;
/

