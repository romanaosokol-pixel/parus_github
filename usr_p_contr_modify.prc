create or replace procedure usr_p_contr_modify
/*
  Процедура изменения реквизитов договора (Для всех случаев)
  Контроль доступа к полям в валидаторе
  
  Городецкий 21-04-2026
  
  */
(ncompany       in number
,nrn            in contracts.rn%type
,sdoctype_code  in doctypes.doccode%type
,ddoc_pref      in contracts.doc_pref%type
,ddoc_nmb       in contracts.doc_numb%type
,ddoc_date      in contracts.reg_date%type -- Дата договора это дата РЕГИСТРАЦИИ !!!
,ddoc_conf      in contracts.confirm_date%type
,ddoc_close     in contracts.close_date%type
,sdoc_extnumb   in contracts.ext_number%type
,ddoc_beg       in contracts.begin_date%type
,ddoc_end       in contracts.end_date%type
,sdoc_subject   in varchar2
,sdoc_agn       in varchar2 -- Это МЫ 
,sdoc_agncode   in varchar2 -- Это наши реквизиты
,nsumm          in number -- Сумма
,scurr          in varchar2 -- Валюта
,sacc           in varchar2 -- Контрагент 
,sacc_code      in varchar2 ---Р/С контрагента договора
,sigk           in varchar2 -- ИГК Договора
,pin_otv_ek     in varchar2 --- Ответственный экономист
,spbu_code      in varchar2 -- КОД  (свойство связи с проектом)
,svid_dog       in varchar2 -- Вид договора Свойство  
,nsum_type      in number --- Признак расчетные суммы
,nautocalc_sign in number --Признак автоматического расчета сумм
,all_rights_enb in number /* Предоставить все права */) as

  rrow contracts%rowtype; /*Текущее состояние Договора*/

  v_ndoc_type contracts.doc_type%type;
  v_otv_ek    varchar2(80);
  v_spbu_code varchar2(80);
  v_svid_dog  varchar2(80);
  ncheck      integer := 0;

  v_nrn           number(17);
  v_ncurr         curnames.rn%type;
  v_my_rn         agnlist.rn%type;
  v_my_acc_rn     contracts.jur_acc%type;
  v_nagent_rn     contracts.agent%type;
  v_nacc_agent_rn contracts.agnacc%type;
  v_nigk          contracts.govcntrid%type;

  /* Для формирования динамического запроса */
  v_sql_1 varchar2(28) := 'update contracts t set ';
  v_sql_2 varchar2(2000) := null;
  v_sql_3 varchar2(2000) := ' where t.rn = :nRN';

  /*Признак изменения документа основания по цепочке */
  nface_cnt integer := 0;

  procedure dog_uq_nmb(in_doc_type in number
                      ,in_doc_pref in varchar2
                      ,in_doc_numb in varchar2) is
  
    nfl integer;
  begin
  
    begin
      select 1
        into nfl
        from contracts dog
       where dog.rn != rrow.rn
         and dog.company = rrow.company
         and dog.jur_pers = rrow.jur_pers
         and dog.doc_year = rrow.doc_year
         and dog.doc_type = in_doc_type
         and dog.doc_pref = in_doc_pref
         and dog.doc_numb = in_doc_numb;
    exception
      when no_data_found then
        return;
    end;
    p_exception(0, 'Договор с таким префиксом и номером уже существует, измените префикс и номер.');
  end;

begin

  /*if user != 'GOR'
  then
    p_exception(0, 'Процедура на реконструкции. Заработает с 22-04-2026');
  end if;*/

  ---if rrow.reg_date is null then 

  /* Процедура запускается по одному договору */
  select count(sl.rn)
    into ncheck
    from selectlist sl
   where sl.unitcode = 'Contracts'
     and sl.authid = user;

  if ncheck > 1
  then
    p_exception(0, 'Выбрано ' || ncheck || ' строк!');
  end if;

  /*Считываем текущие значения догвора */
  rrow := usr_pkg_contracts.contracts_get(nrn => nrn);

  /* Текущие значения свойств */

  v_otv_ek    := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, sunitcode => 'Contracts', ndocument => rrow.rn); /* Экономист ПЭО */
  v_spbu_code := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1076177, sunitcode => 'Contracts', ndocument => rrow.rn); /* Шифр_поБУ */
  v_svid_dog  := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 45150801, sunitcode => 'Contracts', ndocument => rrow.rn); /*УМТС_ВидДоговора*/

  /*  Разрешаем ссылки */

  find_doctypes_code_ex(0, 0, rrow.company, sdoctype_code, v_ndoc_type);

  if scurr is not null
  then
    -- Ищем RN Валюты
    find_currency_by_code(company => ncompany, code => scurr, rn => v_ncurr);
  end if;

  /*Ищем контрагента Себя (Это МОДУЛЬ)*/
  if sdoc_agn is not null
  then
    begin
      find_agnlist_code(nflag_smart => 0, nflag_option => 0, ncompany => ncompany, scode => sdoc_agn, nrn => v_my_rn);
    exception
      when others then
        p_exception(0, 'Контрагент юридического лица с мнемокодом %s не найден', sdoc_agn);
    end;
  
  end if;

  if sdoc_agncode is not null
  then
    -- Ищем RN НАШEГО реквизита
    find_agnacc_code(nflag_smart => 0, company => ncompany, mnemo => sdoc_agn, code => trim(sdoc_agncode), rn => v_my_acc_rn);
  end if;

  /*Ищем RN контрагента*/
  if trim(sacc) is not null
  then
    begin
      find_agnlist_code(nflag_smart => 0, nflag_option => 0, ncompany => ncompany, scode => sacc, nrn => v_nagent_rn);
    exception
      when others then
        p_exception(0, 'Контрагент с мнемокодом %s не найден', sacc);
    end;
  end if;

  /*Ищем RN Реквизита контрагента */
  if trim(sacc_code) is not null
  then
    begin
      find_agnacc_code(nflag_smart => 0, company => ncompany, mnemo => sacc, code => sacc_code, rn => v_nacc_agent_rn);
    exception
      when others then
        p_exception(0, 'У контрагента %s нет реквизита %s', sacc, sacc_code);
    end;
  end if;

  if sigk is not null
  then
    begin
      select igk.rn
        into v_nigk
        from govcntrid igk
       where igk.code = sigk
         and igk.company = ncompany;
    exception
      when no_data_found then
        p_exception(0, 'ИГК с кодом "%s" не найден!. Выберите корректное значение через словарь', sigk);
    end;
  end if;

  /*Формируем запрос на изменение */

  if v_ndoc_type != rrow.doc_type
  then
    nface_cnt := 1;
    /* Проверим уникальность нового номера */
    dog_uq_nmb(v_ndoc_type, rrow.doc_pref, rrow.doc_numb);
  
    rrow.doc_type := v_ndoc_type;
    v_sql_2       := strcombine(sleft => v_sql_2, sright => 't.doc_type = ' || v_ndoc_type, sdelimeter => ',');
  
  end if;

  if cmp_num(v_nigk, rrow.govcntrid) = 0
  then
  
    v_sql_2 := strcombine(sleft      => v_sql_2
                         ,sright     => 't.Govcntrid = ' || case
                                          when v_nigk is null then
                                           'Null'
                                          else
                                           to_char(v_nigk)
                                        end
                         ,sdelimeter => ',');
  end if;

  if ddoc_pref != trim(rrow.doc_pref)
  then
    nface_cnt := 1;
    /* Проверим уникальность нового номера */
    dog_uq_nmb(rrow.doc_type, lpad(str1 => ddoc_pref, len => 80, pad => ' '), rrow.doc_numb);
  
    rrow.doc_pref := ddoc_pref;
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.doc_pref = ''' || lpad(str1 => ddoc_pref, len => 80, pad => ' ') || '''', sdelimeter => ',');
  
  end if;

  /* признак автоматического пересчета сумм: 0 - нет, 1 - да */

  if cmp_num(nautocalc_sign, rrow.autocalc_sign) = 0
  then
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.AUTOCALC_SIGN = ' || nautocalc_sign, sdelimeter => ',');
  end if;

  if cmp_num(nsum_type, rrow.sum_type) = 0
  then
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.sum_type = ' || nsum_type, sdelimeter => ',');
  end if;

  if ddoc_nmb != trim(rrow.doc_numb)
  then
    nface_cnt := 1;
    /* Проверим уникальность нового номера */
    dog_uq_nmb(rrow.doc_type, rrow.doc_pref, lpad(str1 => ddoc_nmb, len => 80, pad => ' '));
  
    rrow.doc_numb := ddoc_nmb;
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.doc_numb = ''' || lpad(str1 => ddoc_nmb, len => 80, pad => ' ') || '''', sdelimeter => ',');
  
  end if;

  /* Дата догоовра */
  if cmp_dat(ddoc_date, rrow.reg_date) = 0
  then
  
    rrow.reg_date := ddoc_date;
    nface_cnt     := 1;
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.reg_date = to_date(''' || to_char(ddoc_date, 'DD.MM.YYYY') || ''',''DD.MM.YYYY''' || ') ', sdelimeter => ',');
  end if;

  if cmp_dat(ddoc_beg, rrow.begin_date) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.begin_date = to_date(''' || to_char(ddoc_beg, 'DD.MM.YYYY') || ''',''DD.MM.YYYY''' || ') ', sdelimeter => ',');
  end if;

  if cmp_dat(ddoc_end, rrow.end_date) = 0
  then
  
    v_sql_2 := strcombine(sleft      => v_sql_2
                         ,sright     => 't.end_date = to_date(''' || case
                                          when ddoc_end is null then
                                           'Null'
                                          else
                                           to_char(ddoc_end, 'DD.MM.YYYY') || ''',''DD.MM.YYYY'''
                                        end || ') '
                         ,sdelimeter => ',');
  end if;

  if cmp_dat(ddoc_conf, rrow.confirm_date) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.confirm_date = to_date(''' || to_char(ddoc_conf, 'DD.MM.YYYY') || ''',''DD.MM.YYYY''' || ') ', sdelimeter => ',');
  end if;

  if cmp_dat(ddoc_close, rrow.close_date) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.close_date = to_date(''' || to_char(ddoc_close, 'DD.MM.YYYY') || ''',''DD.MM.YYYY''' || ') ', sdelimeter => ',');
  end if;

  if cmp_vc2(sdoc_subject, rrow.subject) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.subject = ''' || nvl(sdoc_subject, '') || '''', sdelimeter => ',');
  
  end if;

  /*Реквизиты Контрагента МЫ*/
  if cmp_num(v_my_acc_rn, rrow.jur_acc) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.Jur_Acc = ' || v_my_acc_rn, sdelimeter => ',');
  
  end if;

  if cmp_num(nsumm, rrow.doc_sumtax) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.DOC_SUMTAX = ' || nsumm, sdelimeter => ',');
  
  end if;

  /*Контрагент */
  if cmp_num(v_nagent_rn, rrow.agent) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.agent = ' || v_nagent_rn, sdelimeter => ',');
  
  end if;

  /* Контрагент. Реквизиты */
  if cmp_num(v_nacc_agent_rn, rrow.agnacc) = 0
  then
  
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.agnacc = ' || v_nacc_agent_rn, sdelimeter => ',');
  
  end if;

  /* Внешний номер */

  if cmp_vc2(sdoc_extnumb, rrow.ext_number) = 0
  then
    v_sql_2 := strcombine(sleft => v_sql_2, sright => 't.ext_number = ''' || nvl(sdoc_extnumb, '') || '''', sdelimeter => ',');
  end if;

  /* Обновляем свойства Если значения изменились */
  if cmp_vc2(pin_otv_ek, v_otv_ek) = 0
  then
    pkg_docs_props_vals.modify(sproperty   => 'Сотрудник'
                              ,sunitcode   => 'Contracts'
                              ,ndocument   => nrn
                              ,sstr_value  => pin_otv_ek
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => v_nrn);
  end if;

  /* Обновляем свойство ШИФР ПБУ */
  if cmp_vc2(spbu_code, v_spbu_code) = 0
  then
    pkg_docs_props_vals.modify(sproperty   => 'Шифр_поБУ'
                              ,sunitcode   => 'Contracts'
                              ,ndocument   => nrn
                              ,sstr_value  => spbu_code
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => v_nrn);
  end if;

  /* Обновляем свойство УМТС_ВидДоговора */
  if cmp_vc2(svid_dog, v_svid_dog) = 0
  then
    pkg_docs_props_vals.modify(sproperty   => 'УМТС_ВидДоговора'
                              ,sunitcode   => 'Contracts'
                              ,ndocument   => nrn
                              ,sstr_value  => svid_dog
                              ,nnum_value  => null
                              ,ddate_value => null
                              ,nrn         => v_nrn);
  end if;

  /*Если было что менять, запишем */
  if length(v_sql_2) > 3
  then
  
    ---if user = 'GOR' then  P_EXCEPTION(0,  v_sql_1 || v_sql_2 || v_sql_3); end if;
    execute immediate v_sql_1 || v_sql_2 || v_sql_3 ---СубКонтрак
      using nrn;
  end if;

  /* Если изменился тип документа или год, то обновим документ основания у лицевых счетов */
  if nface_cnt = 1
  then
  
    /* Меняем документ основания : Лицевые счета (Если изменилось хоть одно из  Тип, Префикс, Номер, Дата) */
  
    for rec in (select st.faceacc
                      ,trim(cn.doc_pref) as sprev_doc_pref
                      ,trim(cn.doc_numb) as sprev_doc_numb
                      ,trim(st.numb) as sprev_stage_numb
                      ,cn.doc_type
                      ,cn.reg_date ddoc_date
                  from stages    st
                      ,contracts cn
                 where cn.rn = nrn
                   and st.prn = cn.rn
                   and cn.company = ncompany)
    loop
    
      update faceacc t
         set t.valid_doctype = rec.doc_type
            ,t.valid_docnumb = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
            ,t.valid_docdate = rec.ddoc_date
       where t.rn = rec.faceacc;
    
      /* Меняем все Входящие счета по Лицевому счету */
    
      update payaccin p
         set p.vdoc_type = rec.doc_type
            ,p.vdoc_num  = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
            ,p.vdoc_date = rec.ddoc_date
       where p.faceacc = rec.faceacc;
    
      /* Меняем в Счетах на оплату */
    
      update payacc p
         set p.vdoc_type = rec.doc_type
            ,p.vdoc_numb = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
            ,p.vdoc_date = rec.ddoc_date
       where p.faceacc = rec.faceacc;
    
      /* Меняем в расходных накладных потребителям */
    
      update transinvcust tr
         set tr.accdoc  = rec.doc_type
            ,tr.accnumb = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
            ,tr.accdate = rec.ddoc_date
       where tr.faceacc = rec.faceacc;
    
      /*Меняем в приходных накладных */
    
      update ininvoices tr
         set tr.valid_doctype = rec.doc_type
            ,tr.valid_docnumb = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
            ,tr.valid_docdate = rec.ddoc_date
       where tr.faceacc = rec.faceacc;
       
      /* Меняем в Приходном ордере */ 
      
      update INORDERS tr
         set tr.CONFDOCTYPE = rec.doc_type
            ,tr.CONFDOCNUMB = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
            ,tr.CONFDOCDATE = rec.ddoc_date
       where tr.faceacc = rec.faceacc;
    
      /* Меняем в журнале платежей */
    
      begin
        execute immediate 'ALTER TRIGGER T_PAYNOTES_BUPDATE DISABLE';
        update paynotes p
           set p.vdoc_type = rec.doc_type
              ,p.vdoc_numb = rec.sprev_doc_pref || '-' || rec.sprev_doc_numb || ' Эт.' || rec.sprev_stage_numb
              ,p.vdoc_date = rec.ddoc_date
        
         where p.faceacc = rec.faceacc;
        execute immediate 'ALTER TRIGGER T_PAYNOTES_BUPDATE ENABLE';
      
      exception
        when others then
          execute immediate 'ALTER TRIGGER T_PAYNOTES_BUPDATE ENABLE';
      end;
    
    end loop;
  
  end if;
end;
/
