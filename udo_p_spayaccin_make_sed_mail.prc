create or replace procedure UDO_P_SPAYACCIN_MAKE_SED_MAIL
(
  nCOMPANY           in number,         -- рег. номер организации
  nRN                in number          -- рег. номер ВСО
)
is
/*
    13/07/2022 Селиванов А.Е.
    Входящие счета на оплату
    Отправка e-mail сообщения ответственным по этапу проекта
*/
  nAGN               PKG_STD.tREF;      -- Рег номер контрагента
  SPAYACCIN          PKG_STD.tSTRING;   -- Реквизиты ВСО
  SAGMAIL            PKG_STD.tSTRING;   -- Адрес E-mail
  STO_LIST           PKG_STD.tSTRING;   -- Перечень E-mail адресов
  SZAYAVKA           PKG_STD.tSTRING;   -- Реквизиты Заказа
  SUNITCODE          PKG_STD.tSTRING := 'DepartmentsOrders';   -- Код раздела заказы подразделений
  SDOCPROPCODE       PKG_STD.tSTRING := 'ROWID_1C';            -- Код свойства Идентификатор документа 1С (Версия документа)
  sDOCPROP_NUM constant varchar2(20) := 'НОМ_ЗЯВКИ'; -- Свойство Номер заявки
  /* Сообщение */
  CTEXT              PKG_STD.tSTRING := 'По заявке <номер заявки> от <дата заявки> создан Входящий счет на оплату <номер счета на оплату> от <дата счета на оплату>. Необходимо повторно согласовать спецификацию счета';
  /* Тема */
  STITLE             PKG_STD.tSTRING := 'Входящий счет на оплату по Заявке <Номер заявки>';
begin
  for FACC in (select distinct (clc.faceaccount)--, PSD.ROWID_1C
                 from PAYACCINSPEC            sp,
                      PAYACCINSPCLC           clc/*,
                      UDO_PAYACCINSPEC_DEPORD PSD*/
                where sp.prn = nrn --7559427
                  and sp.company = nCOMPANY
                  and clc.prn = sp.rn
                  /*and psd.prn = sp.rn*/) loop
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
    /* Определим Ответственного контрагента */
    nAGN := UDO_F_FACEACC_GET_AGENT(nRN => FACC.FACEACCOUNT);
--if utilizer = 'KHOK' then p_exception(0,nAGN); end if; 
    /* Найдем e-mail ответственнго */
    begin
      select ag.mail into SAGMAIL from agnlist ag where ag.rn = nAGN;
      /* Соберем e-mail ответственных */
      STO_LIST := SAGMAIL || ';' || STO_LIST;
    exception
      when NO_DATA_FOUND then
        STO_LIST := 'a.khokhryakov@module.ru';
    end;
--if utilizer = 'KHOK' then p_exception(0,nAGN); end if;    
    /* Найдем заказ */
    for zakaz in (select TRIM(Z.ORD_PREF) || '-' || TRIM(Z.ORD_NUMB) DPORD_NUM,
                       Z.ORD_DATE ORD_DATE,
                       Z.FACEACC,
                       udo_f_get_doc_prop_val(Z.RN, sDOCPROP_NUM) NUM_Z,
                       UDO_F_PAYACCINSPEC_DOGNUMB(PS.RN) sNumb
                  from DEPARTMENTORD    Z,
                       PAYACCINSPCLC_EX CEX,
                       PAYACCINSPCLC    CLC,
                       PAYACCINSPEC     PS
                 where PS.PRN = NRN
                   and CLC.PRN = PS.RN
                   and CEX.PRN = CLC.RN
                   and CEX.DEPARTMENTORD = Z.RN
                 group by TRIM(Z.ORD_PREF) || '-' || TRIM(Z.ORD_NUMB),
                          Z.ORD_DATE,
                          Z.FACEACC,
                          udo_f_get_doc_prop_val(Z.RN, sDOCPROP_NUM),
                          UDO_F_PAYACCINSPEC_DOGNUMB(PS.RN)
                  /*select TRIM(Z.ORD_PREF) || '-' || TRIM(Z.ORD_NUMB) DPORD_NUM,
                         Z.ORD_DATE ORD_DATE
                    from DEPARTMENTORD Z, docs_props_vals dv, DOCS_PROPS DP
                   where dv.str_value = FACC.ROWID_1C
                     and DV.DOCS_PROP_RN = DP.RN
                     and DP.CODE = SDOCPROPCODE
                     and dv.unitcode = SUNITCODE
                     and Z.RN = DV.UNIT_RN*/) loop

      SZAYAVKA := zakaz.dpord_num || ' от ' || to_char(zakaz.ord_date, 'dd.mm.yyyy') || '; ' ||
                  SZAYAVKA;

    end loop;

  end loop;
  STO_LIST := RTRIM(STO_LIST, ';')||'; a.khokhryakov@module.ru';
  SZAYAVKA := RTRIM(SZAYAVKA, ';');

  CTEXT := replace(replace(CTEXT,
                           '<номер заявки> от <дата заявки>',
                           SZAYAVKA),
                   '<номер счета на оплату> от <дата счета на оплату>',
                   SPAYACCIN);
                   
   CTEXT := CTEXT||CR||CR||CR||'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';
  /* Тема */
  STITLE := replace(STITLE, '<Номер заявки>', SZAYAVKA);
  --STO_LIST := 'a.selivanov@module.ru;m.markov@module.ru;e.stolyarskiy@module.ru';
  /* Отправка E-mail сообщения (по списку получателей) */
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT,
                                --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
end UDO_P_SPAYACCIN_MAKE_SED_MAIL;
-- grant execute on UDO_P_SPAYACCIN_MAKE_SED_MAIL to public;
/
