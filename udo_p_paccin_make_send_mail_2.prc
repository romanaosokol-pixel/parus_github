create or replace procedure UDO_P_PACCIN_MAKE_SEND_MAIL_2
(
  nCOMPANY  in number, -- рег. номер организации
  sUNITCODE in varchar2,
  nDOCUMENT in number, -- рег. номер ВСО
  sUNITFUNC in varchar2
) is
  /*
      13/07/2022 Селиванов А.Е.
      Входящие счета на оплату
      Отправка e-mail сообщения ответственным по этапу проекта
  */
  nAGN         PKG_STD.tREF; -- Рег номер контрагента
  SPAYACCIN    PKG_STD.tSTRING; -- Реквизиты ВСО
  sEXT_NUMB    PAYACCIN.EXT_NUMB%type; -- внешний номер счета на оплату
  SAGMAIL      PKG_STD.tSTRING; -- Адрес E-mail
  STO_LIST     PKG_STD.tSTRING; -- Перечень E-mail адресов
  ALL_TO_LIST  PKG_STD.tSTRING; -- Перечень E-mail адресов
  SZAYAVKA     PKG_STD.tSTRING; -- Реквизиты Заказа
  SUNIT_DEPORD PKG_STD.tSTRING := 'DepartmentsOrders'; -- Код раздела заказы подразделений
  SDOCPROPCODE PKG_STD.tSTRING := 'ROWID_1C'; -- Код свойства Идентификатор документа 1С (Версия документа)
  sDOCPROP_NUM constant varchar2(20) := 'НОМ_ЗЯВКИ'; -- Свойство Номер заявки
  /* Сообщение */
  CTEXT_C constant PKG_STD.tSTRING := 'По заявке <номер заявки> от <дата заявки> создан Входящий счет на оплату <номер счета на оплату> от <дата счета на оплату>.'||CR||'Необходимо согласовать спецификацию счета.';
  CTEXT PKG_STD.tSTRING;
  /* Тема */
  STITLE_C constant PKG_STD.tSTRING := 'Входящий счет <номер счета на оплату> на оплату по Заявке <Номер заявки>';
  STITLE PKG_STD.tSTRING;
  --
  nRN constant number(17) := nDOCUMENT;
  sShifr varchar2(64);
  sEtap  varchar2(256); --integer;
  --
  nDELORD PKG_STD.tREF; -- Заказ поставщику
  -- контрольное сообщение
  sTEXT_K  PKG_STD.tSTRING;
  sTITLE_K PKG_STD.tSTRING;

begin

  -- параметры ВСО
  begin
    select TRIM(P.EXT_NUMB),
           TRIM(P.EXT_NUMB) || ' от ' || to_char(p.reg_date, 'dd.mm.yyyy'),
           P.RN
    /*(select L.IN_DOCUMENT
     from DOCLINKS L
    where L.OUT_DOCUMENT = P.RN
      and L.OUT_UNITCODE = 'PaymentAccountsIn'
      and L.IN_UNITCODE = 'DeliveryOrders'
      and rownum < 2)*/
      into sEXT_NUMB,
           SPAYACCIN,
           nDELORD
      from PAYACCIN P
     where P.RN = NRN
       and P.COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      return;
  end;

  /* Необходимо разделить ВСЩ из 1С и ВСО созданные в Парусе */
  -- if nDELORD is not null and 0=1 then
  /* 13092022 Селиванов переделал на новую таблицу PAYACCINSPCLC_EX */
  --if nDELORD is not null then
  -- созданные в Парусе
  /* Найдем заказ */
  for zakaz in (
                select TRIM(Z.ORD_PREF) || '-' || TRIM(Z.ORD_NUMB) DPORD_NUM,
                       Z.ORD_DATE ORD_DATE, Z.AGENT, Z.FACEACC, UDO_F_PAYACCIN_AUTHOR(PS.PRN) acc_agent, --Z.ACC_AGENT,
                       udo_f_get_doc_prop_val(Z.RN, sDOCPROP_NUM) NUM_Z,
                       UDO_F_PAYACCINSPEC_DOGNUMB(PS.RN) sNumb
                  from DEPARTMENTORD    Z,
                       PAYACCINSPCLC_EX CEX,
                       PAYACCINSPCLC    CLC,
                       PAYACCINSPEC     PS
                --DOCLINKS        LZ,
                --DELIVERYORD     D,
                --DOCLINKS        LD
                 where PS.PRN = NRN
                   and CLC.PRN = PS.RN
                   and CEX.PRN = CLC.RN
                   and CEX.DEPARTMENTORD = Z.RN
                 group by TRIM(Z.ORD_PREF) || '-' || TRIM(Z.ORD_NUMB),
                          Z.ORD_DATE, Z.AGENT, Z.FACEACC, UDO_F_PAYACCIN_AUTHOR(PS.PRN), --Z.ACC_AGENT,
                          udo_f_get_doc_prop_val(Z.RN, sDOCPROP_NUM),
                          UDO_F_PAYACCINSPEC_DOGNUMB(PS.RN)
                /*LD.OUT_DOCUMENT = NRN
                and LD.OUT_UNITCODE = 'PaymentAccountsIn'
                and LD.IN_DOCUMENT = D.RN
                and LD.IN_UNITCODE = 'DeliveryOrders'
                and LZ.OUT_DOCUMENT = D.RN
                and LZ.OUT_UNITCODE = 'DeliveryOrders'
                and LZ.IN_DOCUMENT = Z.RN
                and LZ.IN_UNITCODE = 'DepartmentsOrders'*/


/*                 select *
                   from (select trim(z.ord_pref) || '-' || trim(z.ord_numb) dpord_num
                               ,z.ord_date ord_date
                               ,z.agent
                               ,z.faceacc
                               ,udo_f_payaccin_author(ps.prn) acc_agent
                               ,udo_f_get_doc_prop_val(z.rn, sdocprop_num) num_z
                               ,udo_f_payaccinspec_dognumb(ps.rn) snumb
                               ,(select fc.rn
                                   from productords   dp
                                       ,fcmatresource fc
                                       ,doclinks      dl1
                                       ,doclinks      dl2
                                  where dl2.out_document = z.rn
                                    and dl2.out_unitcode = 'DepartmentsOrders'
                                    and dl2.in_unitcode = 'CostProductExpenseActs'
                                    and dl2.in_document = dl1.out_document
                                    and dl1.out_unitcode = 'CostProductExpenseActs'
                                    and dl1.in_unitcode = 'ProductionOrders'
                                    and dl1.in_document = dp.prn
                                    and fc.nomenclature = dp.nomen
                                    and fc.nomen_modif = dp.nom_modif
                                    and rownum = 1) as npos
                           from departmentord    z
                               ,payaccinspclc_ex cex
                               ,payaccinspclc    clc
                               ,payaccinspec     ps
                          where ps.prn            = nrn
                            and clc.prn           = ps.rn
                            and cex.prn           = clc.rn
                            and cex.departmentord = z.rn) a
                  group by a.dpord_num
                          ,a.ord_date
                          ,a.agent
                          ,a.faceacc
                          ,a.acc_agent
                          ,a.num_z
                          ,a.snumb
                          ,a.npos
*/

  ) loop
    -- заявка
    SZAYAVKA := zakaz.dpord_num || ' от ' || to_char(zakaz.ord_date, 'dd.mm.yyyy') || ' (' || zakaz.num_z ||
                ')'' (л/с ' || zakaz.sNumb || ')';

    /* Определим Ответственного контрагента */
    nAGN := UDO_F_FACEACC_GET_AGENT(nRN => zakaz.faceacc/*, nmatresource => zakaz.nPOS*/);

    sShifr := substr(zakaz.sNumb, 0, INSTR(zakaz.sNumb, '/') - 1);
    sEtap  := substr(zakaz.sNumb, INSTR(zakaz.sNumb, '/') + 1);

    -- 05/02/2024 KHOK. По Общепроизводственным и Вспомогательным материалам смотрим Ответственного заказчика
    if zakaz.agent is not null and
       (zakaz.faceacc in (56844386, 6991753) ) then -- 10/1 и 12/1 Эт.1
      begin
        select ag.mail into SAGMAIL from agnlist ag where ag.rn = zakaz.agent;
      exception
        when NO_DATA_FOUND then
          SAGMAIL := null;
      end;
    end if;
    /* к Технологам добавляем Ястребову */
    if STRIN(SAGMAIL, 'tikhanov') != 0 or STRIN(SAGMAIL, 'zaharovag') != 0 or STRIN(SAGMAIL, 'sevastenkova') != 0 then
      SAGMAIL := SAGMAIL || ';i.yastrebova@module.ru';
    end if;
    /* к Харину добавляем Миронова */
    if STRIN(SAGMAIL, 'vharin') != 0 then
      SAGMAIL := SAGMAIL || ';mironov@module.ru';
    end if;

    -- Заголовок
    STITLE := replace(replace(STITLE_C, '<Номер заявки>', SZAYAVKA), '<номер счета на оплату>', sEXT_NUMB);
    -- Сообщение
    CTEXT := replace(replace(CTEXT_C, '<номер заявки> от <дата заявки>', SZAYAVKA),
                     '<номер счета на оплату> от <дата счета на оплату>', SPAYACCIN);
    CTEXT := CTEXT || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';

    -- 25/07/2022 Марков МВ. По всем ответственным по проекту
    for rex in (select CP.PERS_AGENT,
                       PS.RESPONSIBLE -- !!! Когда будет порядок с ответственным по этапу проекта, можно использовать только его почту
                  from PROJECTSTAGE     PS,
                       UDO_PRJEXEC_LIST EL,
                       CLNPERSONS       CP
                 where PS.FACEACC = zakaz.faceacc
                   and PS.PRN = EL.PRN
                   and EL.PERSON = CP.RN
    ) loop
      /* Соберем e-mail ответственных */
      if zakaz.faceacc not in (56844386, 6991753) or SAGMAIL is null then -- для 10/1 и 12/1 ответственного уже определили раньше.
        begin
          if sShifr in ('28817', '29900', '80028') and rex.RESPONSIBLE is not null
             --and rex.RESPONSIBLE in (select M.RN from AGNLIST M where M.CRN in ('1083644'))
            then
               select ag.mail into SAGMAIL from agnlist ag where ag.rn = rex.RESPONSIBLE;
          else select ag.mail into SAGMAIL from agnlist ag where ag.rn = rex.PERS_AGENT;
          end if;
        exception
          when NO_DATA_FOUND then
            SAGMAIL := null;
        end;
      end if;

      /* KHOK. Без костылей пока никак. В этапах не всегда стоят Ответственные разработчики */
      if 6000395 != rex.pers_agent or -- Фильтр для Петровичева по проекту "Изготовление изделий для собственных нужд" 80028
         (6000395 = rex.pers_agent and ('80028' != sShifr or zakaz.sNumb in ('80028/7', '80028/16', '80028/18', '80028/21') )) then
        if 1083287 != rex.pers_agent or -- Фильтр для Павлова по проекту "Изготовление изделий для собственных нужд" 80028
           (1083287 = rex.pers_agent and ('80028' != sShifr or zakaz.sNumb in ('80028/17', '80028/19', '80028/20') )) then
        if 1083287 != rex.pers_agent or -- Фильтр для Павлова по проекту "Изготовление МОДУЛЕЙ" 29020
           (1083287 = rex.pers_agent and ('29020' != sShifr or sEtap in ('48','49','52','53','54','55','56','62','68','69','70','72','73','74','75'))) then
        if 8039872 != rex.pers_agent or -- Фильтр для Словика по проекту "Изготовление МОДУЛЕЙ" 29020
           (8039872 = rex.pers_agent and ('29020' != sShifr or sEtap in ('57','58','59','60','61','63','64','65','66','67') )) then
        if 6000731 != rex.pers_agent or -- Фильтр для Миронова по проекту "Изготовление МОДУЛЕЙ" 29020
           (6000731 = rex.pers_agent and ('29020' != sShifr or sEtap in ('5','71'))) then
        if 6003000 != rex.pers_agent or -- Фильтр для Розова по проекту "Изготовление МОДУЛЕЙ" 29020
           (6003000 = rex.pers_agent and ('29020' != sShifr or sEtap not in ('5','71','48','49','52','53','54','55','56','68','69','70','72','73','74','75'))) then
/*        if 1083287 != rex.pers_agent or -- Фильтр для Павлова по проекту "Нейроплатформа" 28817
           (1083287 = rex.pers_agent and ('28817' != sShifr or sEtap not in ('13ТЗ', '7ТЗ/99'))) then
        if 6003000 != rex.pers_agent or -- Фильтр для Розова по проекту "Нейроплатформа" 28817
           (6003000 = rex.pers_agent and ('28817' != sShifr or sEtap in ('13ТЗ', '7ТЗ/99'))) then*/

          -- Отправим сообщение
          if rtrim(SAGMAIL) is not null then
            -- получатель
            STO_LIST := SAGMAIL;
            if ALL_TO_LIST is null then
                 ALL_TO_LIST := SAGMAIL;
            else ALL_TO_LIST := ALL_TO_LIST ||'; '||SAGMAIL;
            end if;
            
            /* Отправка E-mail сообщения (по списку получателей) */
            PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => USR_PKG_COMMON.GET_LIST_DISTINCT(sLIST => STO_LIST), -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                          STITLE   => STITLE, -- Тема
                                          CTEXT    => CTEXT,
                                          --NFILE_BUFFER_IDENT in number := null, -- Прикладываемые документы (идентификатор файлового буфера)
                                          NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
          end if;
/*        end if;
        end if;*/
        end if;
        end if;
        end if;
        end if;
        end if;
      end if;
      nAGN := to_number(null); -- есть ответственные по проекту

      if zakaz.faceacc in (56844386, 6991753) or '28817' = sShifr then  -- достаточно 1 раз отправить Ответственному Заказчику
        exit;
      end if;
    end loop;

    /* Найдем e-mail ответственного */
    if nAGN is not null then
      /* Соберем e-mail ответственных */
      begin
        select ag.mail into SAGMAIL from agnlist ag where ag.rn = nAGN;
      exception
        when NO_DATA_FOUND then
          SAGMAIL := null;
      end;
      -- Отправим сообщение
      if rtrim(SAGMAIL) is not null then
        -- получатель
        STO_LIST := SAGMAIL; -- отдельным письмом||';m.markov@module.ru';
        -- Заголовок
        STITLE := replace(replace(STITLE_C, '<Номер заявки>', SZAYAVKA), '<номер счета на оплату>', sEXT_NUMB);
        -- Сообщение
        CTEXT := replace(replace(CTEXT_C, '<номер заявки> от <дата заявки>', SZAYAVKA),
                         '<номер счета на оплату> от <дата счета на оплату>', SPAYACCIN);
        CTEXT := CTEXT || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';
        /* Отправка E-mail сообщения (по списку получателей) */
        PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => USR_PKG_COMMON.GET_LIST_DISTINCT(sLIST => STO_LIST), -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                      STITLE   => STITLE, -- Тема
                                      CTEXT    => CTEXT,
                                      --NFILE_BUFFER_IDENT      in number := null, -- Прикладываемые документы (идентификатор файлового буфера)
                                      NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
      end if;

    end if; --else

    /* контрольное сообщение */
    -- Заголовок
    STITLE := replace(replace(STITLE_C, '<Номер заявки>', SZAYAVKA), '<номер счета на оплату>', sEXT_NUMB);
    -- Сообщение
    CTEXT := 'Входящий счет на оплату ' || SPAYACCIN || ', созданный по заявке ' || SZAYAVKA || ', отправлен на согласование.' ;
    CTEXT := CTEXT || CR || CR || 'Получатели:' || CR || nvl(ALL_TO_LIST, 'Отсутствуют.');

    -- получатели, включая инициатора счета (кроме Лукашиной)
    if zakaz.acc_agent not in ('Лукашина М.А.') then
      begin
        select ag.mail into SAGMAIL from agnlist ag where trim(ag.agnabbr) = trim(zakaz.acc_agent);
      exception
        when NO_DATA_FOUND then
          SAGMAIL := null;
        when TOO_MANY_ROWS then
          SAGMAIL := null;
      end;
    else
      SAGMAIL := null;
    end if;
    STO_LIST := 'm.markov@module.ru;a.khokhryakov@module.ru;' || SAGMAIL;
    /* Отправка E-mail сообщения (по списку получателей) */
    PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => USR_PKG_COMMON.GET_LIST_DISTINCT(sLIST => STO_LIST), -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                  STITLE   => STITLE, -- Тема
                                  CTEXT    => CTEXT,
                                  --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                  NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
    --end if;

    -- достаточно 1 раза
    exit;
  end loop;

  /* 28/06/2023 Марков МВ. по требованию Михайлова В.А. */
  /* по проектам контролируем срок поставки и цену */
  for ctrl in (select PS.PRICE,
                      /*(select DV.NUM_VALUE
                         from DOCS_PROPS_VALS DV
                        where DV.UNIT_RN = PS.RN
                          and DV.DOCS_PROP_RN = 7551156) DAYS_IN,*/
                      /* UDO_F_PAYACCINSP_INDATE(nRN => ps.RN) DAYS_IN */
                      udo_f_get_doc_prop_val(NDOC => ps.RN, SPROP => 'Дней поставки') DAYS_IN,
                      udo_f_get_doc_prop_val(NDOC => ps.RN, SPROP => 'Дата поставки') DATE_IN
                 from PAYACCINSPEC PS
                where PS.PRN = NRN
                  and exists(select null
                               from PAYACCINSPCLC_EX CEX,
                                    PAYACCINSPCLC    CLC
                              where CLC.PRN = PS.RN
                                and CEX.PRN = CLC.RN)
  ) loop

    if nvl(ctrl.price, 0) <= 0 or
      (nvl(ctrl.days_in, 0) <= 0 and ctrl.date_in is null) then
      -- отправим сообщение, в том числе и инициатору счета
      sTEXT_K := 'По заявке ' || SZAYAVKA || ' создан Входящий счет на оплату ' || SPAYACCIN;
      -- || '. Необходимо согласовать спецификацию счета' || CR || 'Отсутствует срок поставки или цена.';
      if nvl(ctrl.price, 0) <= 0 then
        sTEXT_K := sTEXT_K || CR || 'Отсутствует цена.';
      end if;
      if nvl(ctrl.days_in, 0) <= 0 then
        sTEXT_K := sTEXT_K || CR || 'Отсутствует срок поставки.';
      end if;
      PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => 'm.markov@module.ru; a.khokhryakov@module.ru;' || SAGMAIL, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                    STITLE   => 'Счет на оплату. Отсутствует срок поставки или цена', -- Тема
                                    CTEXT    => sTEXT_K,
                                    NFORMAT  => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
    end if;
    exit; -- достаточно 1 раза
  end loop;

  /* 28/06/2023 Марков МВ. закомментировал за ненадобностью
  else
    -- из 1С
  -- определим заказы
  for FACC in (select distinct PSD.ROWID_1C
                 from PAYACCINSPEC            sp,
                      UDO_PAYACCINSPEC_DEPORD PSD
                where sp.prn = nrn --7559427
                  and sp.company = nCOMPANY
                  and psd.prn = sp.rn) loop

    \* Найдем заказ *\
    for zakaz in (select TRIM(Z.ORD_PREF) || '-' || TRIM(Z.ORD_NUMB) DPORD_NUM,
                         Z.ORD_DATE ORD_DATE,
                         Z.FACEACC,
                         (select V.STR_VALUE
                            from DOCS_PROPS_VALS V,
                                 DOCS_PROPS      P
                           where V.UNIT_RN = Z.RN
                             and V.DOCS_PROP_RN = P.RN
                             and P.CODE = sDOCPROP_NUM) as NUM_Z
                    from DEPARTMENTORD   Z,
                         docs_props_vals dv,
                         DOCS_PROPS      DP
                   where dv.str_value = FACC.ROWID_1C
                     and DV.DOCS_PROP_RN = DP.RN
                     and DP.CODE = SDOCPROPCODE
                     and dv.unitcode = SUNIT_DEPORD
                     and Z.RN = DV.UNIT_RN) loop

      -- заявка
      SZAYAVKA := zakaz.dpord_num || ' от ' || to_char(zakaz.ord_date, 'dd.mm.yyyy') || ' ('|| zakaz.num_z || ')';

      \* Определим Ответственного контрагента *\
      nAGN := UDO_F_FACEACC_GET_AGENT(nRN => zakaz.faceacc);
      -- 25/07/2022 Марков МВ. По всем ответственным по проекту
      for rex in(select CP.PERS_AGENT
                   from PROJECTSTAGE     PS,
                        UDO_PRJEXEC_LIST EL,
                        CLNPERSONS       CP
                  where PS.FACEACC = zakaz.faceacc
                    and PS.PRN = EL.PRN
                    and EL.PERSON = CP.RN
                ) loop
        \* Соберем e-mail ответственных *\
        begin
          select ag.mail into SAGMAIL from agnlist ag where ag.rn = rex.pers_agent;
        exception
          when NO_DATA_FOUND then
            SAGMAIL := null;
        end;
        -- Отправим сообщение
        if rtrim(SAGMAIL) is not null then
          -- получатель
          STO_LIST := SAGMAIL;
          -- Заголовок
          STITLE := replace(replace(STITLE_C, '<Номер заявки>', SZAYAVKA),
                            '<номер счета на оплату>',
                            sEXT_NUMB);
          -- Сообщение
          CTEXT := replace(replace(CTEXT_C, '<номер заявки> от <дата заявки>', SZAYAVKA),
                           '<номер счета на оплату> от <дата счета на оплату>',
                           SPAYACCIN);
          CTEXT := CTEXT || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';
          \* Отправка E-mail сообщения (по списку получателей) *\
          PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                        STITLE   => STITLE, -- Тема
                                        CTEXT    => CTEXT,
                                        --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                        NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
        end if;

        nAGN := to_number(null); -- есть ответственные по проекту
      end loop;


      \* Найдем e-mail ответственного *\
      if nAGN is not null then
        \* Соберем e-mail ответственных *\
        begin
          select ag.mail into SAGMAIL from agnlist ag where ag.rn = nAGN;
        exception
          when NO_DATA_FOUND then
            SAGMAIL := null;
        end;
        -- Отправим сообщение
        if rtrim(SAGMAIL) is not null then
          -- получатель
          STO_LIST := SAGMAIL; -- отдельно со списком получателей||';m.markov@module.ru';
          -- Заголовок
          STITLE := replace(replace(STITLE_C, '<Номер заявки>', SZAYAVKA),
                            '<номер счета на оплату>',
                            sEXT_NUMB);
          -- Сообщение
          CTEXT := replace(replace(CTEXT_C, '<номер заявки> от <дата заявки>', SZAYAVKA),
                           '<номер счета на оплату> от <дата счета на оплату>',
                           SPAYACCIN);
          CTEXT := CTEXT || CR || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';
          \* Отправка E-mail сообщения (по списку получателей) *\
          PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                        STITLE   => STITLE, -- Тема
                                        CTEXT    => CTEXT,
                                        --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                        NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
        end if;

      end if; --else
          \* отправка сообщения для контроля *\
          -- Заголовок
          STITLE := replace(replace(STITLE_C, '<Номер заявки>', SZAYAVKA),
                            '<номер счета на оплату>',
                            sEXT_NUMB);
          -- Сообщение
          CTEXT := replace(replace(CTEXT_C, '<номер заявки> от <дата заявки>', SZAYAVKA),
                           '<номер счета на оплату> от <дата счета на оплату>',
                           SPAYACCIN);
          CTEXT := CTEXT || CR || CR || 'Получатели:'||CR||nvl(STO_LIST, 'Отсутствуют.');
          -- получатель
          STO_LIST := 'm.markov@module.ru';
          \* Отправка E-mail сообщения (по списку получателей) *\
          PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                        STITLE   => STITLE, -- Тема
                                        CTEXT    => CTEXT,
                                        --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                        NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
      --end if;

    end loop;

  end loop;

  end if;*/

  /*STO_LIST := RTRIM(STO_LIST, ';');
  SZAYAVKA := RTRIM(SZAYAVKA, ';');

  CTEXT := replace(replace(CTEXT, '<номер заявки> от <дата заявки>', SZAYAVKA),
                   '<номер счета на оплату> от <дата счета на оплату>',
                   SPAYACCIN);

  CTEXT := CTEXT || CR || CR || CR || 'Данное сообщение сформировано автоматически, не отвечаете на сообщение.';
  \* Тема *\
  STITLE := replace(STITLE, '<Номер заявки>', SZAYAVKA);
  --STO_LIST := 'a.selivanov@module.ru;m.markov@module.ru;e.stolyarskiy@module.ru';
  \* Отправка E-mail сообщения (по списку получателей) *\
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT,
                                --NFILE_BUFFER_IDENT      in number := null,        -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);*/

end UDO_P_PACCIN_MAKE_SEND_MAIL_2;
/
