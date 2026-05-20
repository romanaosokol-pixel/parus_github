create or replace package USR_PKG_PAYNOTES is
  /*
  Степанов М. 15/11/2023
  Package предназначен для работы с разделом "Журнал платежей". 
  PayNotes              PAYNOTES    PN
  */
  --#########################################################################################################

  function PAYNOTES_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return PAYNOTES%rowtype;
  --#########################################################################################################

  procedure PAYNOTES_GET_FIN_EXTENSIONS
  /*
  Заголовок. Считывание фин.расширений 
  */
  (
   nRN              in number
  ,nFLAGSMART       in number default 0
  ,rFINPAYNOTES     out finpaynotes%rowtype
  ,rFINPAYCALENDAR  out finpaycalendar%rowtype
  );
  --#########################################################################################################

  procedure PAYNOTES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYNOTES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYNOTES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYNOTES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYNOTES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYNOTES_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW         in v_paynotes%rowtype
  ,nDUP_RN        in number
  ,nDIV_RN        in number
  ,nRN            out number
  );
  --#########################################################################################################

  procedure PAYNOTES_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW         in v_paynotes%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure PAYNOTES_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW           in paynotes%rowtype
  ,nRN            out number
  );
  --#########################################################################################################

  procedure PAYNOTES_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in paynotes%rowtype
  );
  --#########################################################################################################

  function PAYNOTESCLC_GET
  /*
  Калькуляция. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  )  
  return paynotesclc%rowtype;
  --#########################################################################################################

  procedure PAYNOTESCLC_UPDATE
  /*
  Фин.расширение. Исправление
  */
  (
   rV_ROW         in v_paynotesclc%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure PAYNOTESCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление
  */
  (
   rROW           in paynotesclc%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure FINPAYNOTES_UPDATE
  /*
  Фин.расширение. Исправление
  */
  (
   rV_ROW         in v_finpaynotes_base%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure FINPAYNOTES_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */  
  (
   rROW                 in finpaynotes%rowtype
  ,rPAYNOTES            in paynotes%rowtype
  ,rFINPAYCALENDAR      in finpaycalendar%rowtype
  ,nMODE                in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################
  
  procedure PAYNOTES_TYP_DIRECT_CNTR
  /*
  Проверка совпадения направления финансовой операции журнала платежей  с напралением статьи затрат лицевого счета
  */  
  (
   nrn                 in paynotes.rn%type
  );
  --#########################################################################################################
  

end USR_PKG_PAYNOTES;
/
create or replace package body USR_PKG_PAYNOTES is

  --#########################################################################################################

  function PAYNOTES_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return paynotes%rowtype
  is
    rRow paynotes%rowtype;
  begin
    begin
      select * into rRow from paynotes where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'PAYNOTES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYNOTES')));
    end;
    return(rRow);
  end PAYNOTES_GET;
  --#########################################################################################################

  procedure PAYNOTES_GET_FIN_EXTENSIONS
  /*
  Заголовок. Считывание фин.расширений 
  */
  (
   nRN              in number
  ,nFLAGSMART       in number default 0
  ,rFINPAYNOTES     out finpaynotes%rowtype
  ,rFINPAYCALENDAR  out finpaycalendar%rowtype
  ) 
  is
  begin
    /* Фин.расширение */    
    begin
      select * into rFINPAYNOTES from finpaynotes where payrn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FINPAYNOTES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FINPAYNOTES')));
    end;
    /* Платёжный календарь */    
    begin
      select * into rFINPAYCALENDAR from finpaycalendar where prn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FINPAYCALENDAR');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FINPAYCALENDAR')));
    end;
  end PAYNOTES_GET_FIN_EXTENSIONS;
  --#########################################################################################################

  procedure PAYNOTES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            paynotes%rowtype;
    rDictOper       dictoper%rowtype;
    rFaceAcc        faceacc%rowtype;
    nBankDocs       pkg_std.tref; 
    rBankDocs       bankdocs%rowtype;
    rBD_DictOper    dictoper%rowtype;
    rAgnAcc         agnacc%rowtype;
    nPAIExists      pkg_std.tnumber; 
    nPAIxists       pkg_std.tnumber; 
    rBankAccTypes   bankacctypes%rowtype;
  begin
    /* Считывание */
    rRow := paynotes_get(nrn => nRN); 
    /* Фин.операция */
    begin select * into rDictOper from dictoper where rn = rRow.finoper; end; 
    /* Реквизиты юр.лица */
    rAgnAcc := usr_pkg_agnlist.agnacc_get(rRow.agnacc);
    /* Тип банковского счёта юр.лица */
    if rAgnAcc.bankacc_type is not null then
      rBankAccTypes := usr_pkg_agnlist.bankacctypes_get(nrn => rAgnAcc.bankacc_type);
    end if;
    /* Входной банковский документ */
    nBankDocs := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode => 'PayNotes', nout_document => rRow.rn, sin_unitcode => 'BankDocuments');


    /* ПРОВЕРКИ */

    /* Если платёж фактический */
    if rRow.signplan = 0 then
      
      /*Если направление финансовой операции журнала платежей не совпадвет с напралением статьи затрат лицевого счета Выдаем предупреждение*/  
      paynotes_typ_direct_cntr(nrn); /*Городецкий О.И. 12-08-2025*/
      
      /* Если лицевой счет привязан к подстатье, то зададим калькуляцию */
      usr_p_paynotesclc_calc(nrn); /*Городецкий О.И. 07-05-2026*/

      /* Если НЕТ связи с банковским документом */
      if nBankDocs is null then

        /* Кроме ЛС "МОДУЛЬ\1" */
        if cmp_num(rRow.faceacc, 6715338) != 1 then
          p_exception(0, 'Запрещено добавление фактического платежа не из раздела "Банковские документы". %s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rRow.rn)); 
        end if;                   

      /* Если ЕСТЬ связь с банковским документом */
      else
        /* считывание банковского документа */
        rBankDocs := usr_pkg_bankdocs.bankdocs_get(nrn => nBankDocs);

        /* считывание Фин.операция банковского документа */
        begin select * into rBD_DictOper from dictoper where rn = rBankDocs.type_oper; end; 

        /* сравнение направления фин.операции платежа и банковского документа */
        if rDictOper.typoper_direct != rBD_DictOper.typoper_direct then
          p_exception(0, 'Направление финансовой операции <%s> в платеже не равно направлению финансовой операции <%s> в связанном банковском документе. %s'
                     ,case rDictOper.typoper_direct    when 0 then 'Приход' else 'Расход' end
                     ,case rBD_DictOper.typoper_direct when 0 then 'Приход' else 'Расход' end
                     ,cr||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rRow.rn)); 
        end if;               
      end if;
      
      
                  

      /*  Если платёж формируется НЕ из планового */
      if rRow.pay_plan is null then

        /* направление фин.операции */
        case rDictOper.typoper_direct 

          /* Расход */
          when 1 then

          /* наличие входящих счетов по лицевому счёту */
          select count(*) into nPAIExists from payaccin where faceacc = rRow.faceacc;

          /* если есть входящие счета */
          if nPAIExists != 0 then
            p_exception(0, 'Запрещено добавление расходного фактического платежа НЕ из планового, т.к. по лицевому счёту <%s> имеются входящие счета. %s'
                       ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                       ,cr||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rRow.rn)); 
          end if;               

          /* Приход */
          when 0 then

            /* наличие счетов на оплату по лицевому счёту */
            select count(*) into nPAIxists from payacc where faceacc = rRow.faceacc;

            /* если есть счета на оплату */
            if nPAIxists != 0 then
              p_exception(0, 'Запрещено добавление приходного фактического платежа НЕ из планового, т.к. по лицевому счёту <%s> имеются счета на оплату. %s'
                         ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                         ,cr||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rRow.rn)); 
            end if;               

        end case;
      end if;               

      /* Если тип банковского счёта "Специальный", а фин.операция не "Расход с ИГК, Приход на ИГК, Возврат на ИГК, Возврат с ИГК" */
      if (
          (cmp_num(rBankAccTypes.rn, 1080004) = 1 and rDictOper.rn not in (7036719, 7036720, 92122674, 92127070 )) 
         /* или тип банковского счёта НЕ "Специальный", а фин.операция "Расход с ИГК, Приход на ИГК, Возврат на ИГК, Возврат с ИГК" */
         or 
          (cmp_num(rBankAccTypes.rn, 1080004) != 1 and rDictOper.rn in (7036719, 7036720, 92122674, 92127070 )) 
         ) 
      then
        p_exception(0, 'Финансовая операция <%s> не сооветствует типу банковского счёта <%s>. %s'
                   ,rDictOper.typoper_mnemo
                   ,rBankAccTypes.code
                   ,cr||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rRow.rn)); 
      end if;               
    end if;               

    /* Базовая */
    paynotes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PAYNOTES_AINSERT;
  --#########################################################################################################

  procedure PAYNOTES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end PAYNOTES_BUPDATE;
  --#########################################################################################################

  procedure PAYNOTES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     paynotes%rowtype;
    
  begin
    /* Считывание
     rRow := paynotes_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    paynotes_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end PAYNOTES_AUPDATE;
  --#########################################################################################################

  procedure PAYNOTES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end PAYNOTES_BDELETE;
  --#########################################################################################################

  procedure PAYNOTES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     paynotes%rowtype;
  begin
    /* Заголовок */  
    rRow := paynotes_get(nrn => nRN); 
    
    /* Скорректируем каталог платежа по правилам Городецкий 05-05-2026 */
    usr_p_paynotes_crn_def(nrn => rRow.Rn, ncrn => rRow.Crn);
    
    
    /* ПРОВЕРКИ */  
    /* Лицевой счёт */  
    if /*utilizer != 'KHOK' and*/ rRow.faceacc is null then
      p_exception(0, 'Не задан лицевой счёт. %s%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'PayNotes', ndocument => rROW.RN)); 
    end if;
    
  end PAYNOTES_CHECK_BASE;
  --#########################################################################################################

  procedure PAYNOTES_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW         in v_paynotes%rowtype
  ,nDUP_RN        in number
  ,nDIV_RN        in number
  ,nRN            out number
  ) 
  is 
  begin
    p_paynotes_insert(ncompany            => rV_ROW.NCOMPANY
                     ,ncrn                => rV_ROW.NCRN
                     ,sjur_pers           => rV_ROW.SJUR_PERS
                     ,spay_prefix         => rV_ROW.SPAY_PREFIX
                     ,spay_number         => rV_ROW.SPAY_NUMBER
                     ,spayer              => rV_ROW.SPAYER
                     ,dpay_date           => rV_ROW.DPAY_DATE
                     ,nserv_pay           => rV_ROW.NSERV_PAY
                     ,sfaceacc            => rV_ROW.sNUMB
                     ,sgraphpoint         => rV_ROW.SGRAPHPOINT
                     ,sfinoper            => rV_ROW.SFINOPER_MNEMO
                     ,spaytool            => rV_ROW.SPAYTOOL
                     ,svdoc_type          => rV_ROW.SVDOC_TYPE
                     ,svdoc_numb          => rV_ROW.SVDOC_NUMB
                     ,dvdoc_date          => rV_ROW.DVDOC_DATE
                     ,sfdoc_type          => rV_ROW.SFDOC_TYPE
                     ,sfdoc_numb          => rV_ROW.SFDOC_NUMB
                     ,dfdoc_date          => rV_ROW.DFDOC_DATE
                     ,sescort_doctype     => rV_ROW.SESCORT_DOCTYPE
                     ,sescort_docnumb     => rV_ROW.SESCORT_DOCNUMB
                     ,descort_docdate     => rV_ROW.DESCORT_DOCDATE
                     ,scurrency           => rV_ROW.SCURRENCY
                     ,ncurr_rate          => rV_ROW.NCURR_RATE
                     ,ncurr_rate_base     => rV_ROW.NCURR_RATE_BASE
                     ,ncurr_rate_acc      => rV_ROW.NCURR_RATE_ACC
                     ,ncurr_rate_pay_acc  => rV_ROW.NCURR_RATE_PAY_ACC
                     ,ncurr_rate_trd      => rV_ROW.NCURR_RATE_TRD
                     ,ncurr_rate_base_trd => rV_ROW.NCURR_RATE_BASE_TRD
                     ,nupd_course         => rV_ROW.NUPD_COURSE
                     ,npay_sum            => rV_ROW.NPAY_SUM
                     ,npay_sum_acc        => rV_ROW.NPAY_SUM_ACC
                     ,npay_sum_trd        => rV_ROW.NPAY_SUM_TRD
                     ,nfinspec            => rV_ROW.NFINSPEC
                     ,nintrdebt           => rV_ROW.NINTRDEBT
                     ,nsignplan           => rV_ROW.NSIGNPLAN
                     ,staxgroup           => rV_ROW.STAXGROUP
                     ,npay_plan           => rV_ROW.NPAY_PLAN
                     ,nsignactive         => rV_ROW.NSIGNACTIVE
                     ,spay_type           => rV_ROW.SPAY_TYPE
                     ,stdoc_type          => rV_ROW.STDOC_TYPE
                     ,stdoc_numb          => rV_ROW.STDOC_NUMB
                     ,dtdoc_date          => rV_ROW.DTDOC_DATE
                     ,ntax_sum            => rV_ROW.NTAX_SUM
                     ,ntax_percent        => rV_ROW.NTAX_PERCENT
                     ,scomments           => rV_ROW.SCOMMENTS
                     ,nsignacnt           => rV_ROW.NSIGNACNT
                     ,spay_purp           => rV_ROW.SPAY_PURP
                     ,sgovcntrid          => rV_ROW.SGOVCNTRID
                     ,ssepaccop           => rV_ROW.SSEPACCOP
                     ,sagnacc             => rV_ROW.SAGNACC
                     ,spayer_agnacc       => rV_ROW.SPAYER_AGNACC
                     ,ndup_rn             => nDUP_RN
                     ,ndiv_rn             => nDIV_RN
                     ,nrn                 => nRN);
  end PAYNOTES_INSERT;
  --#########################################################################################################

  procedure PAYNOTES_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW         in v_paynotes%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is 
    rV_PayNotesPrev   v_paynotes%rowtype;
    nFinOperPrev      pkg_std.tref; 
    nFinOper          pkg_std.tref; 
    nCurrencyPrev     pkg_std.tref; 
    nCurrency         pkg_std.tref; 
    aRN_Unit_List     usr_pkg_pub_const.tRN_Unit_List;
    aRNList           udo_tp_numtable := udo_tp_numtable();  -- список RN
    aRNList2          udo_tp_numtable := udo_tp_numtable();  -- список RN

    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_paynotes_update(nrn                 => rV_ROW.NRN
                       ,ncompany            => rV_ROW.NCOMPANY
                       ,sjur_pers           => rV_ROW.SJUR_PERS
                       ,spay_prefix         => rV_ROW.SPAY_PREFIX
                       ,spay_number         => rV_ROW.SPAY_NUMBER
                       ,spayer              => rV_ROW.SPAYER
                       ,dpay_date           => rV_ROW.DPAY_DATE
                       ,nserv_pay           => rV_ROW.NSERV_PAY
                       ,sfaceacc            => rV_ROW.SNUMB
                       ,sgraphpoint         => rV_ROW.SGRAPHPOINT
                       ,sfinoper            => rV_ROW.SFINOPER_MNEMO
                       ,spaytool            => rV_ROW.SPAYTOOL
                       ,svdoc_type          => rV_ROW.SVDOC_TYPE
                       ,svdoc_numb          => rV_ROW.SVDOC_NUMB
                       ,dvdoc_date          => rV_ROW.DVDOC_DATE
                       ,sfdoc_type          => rV_ROW.SFDOC_TYPE
                       ,sfdoc_numb          => rV_ROW.SFDOC_NUMB
                       ,dfdoc_date          => rV_ROW.DFDOC_DATE
                       ,sescort_doctype     => rV_ROW.SESCORT_DOCTYPE
                       ,sescort_docnumb     => rV_ROW.SESCORT_DOCNUMB
                       ,descort_docdate     => rV_ROW.DESCORT_DOCDATE
                       ,scurrency           => rV_ROW.SCURRENCY
                       ,ncurr_rate          => rV_ROW.NCURR_RATE
                       ,ncurr_rate_base     => rV_ROW.NCURR_RATE_BASE
                       ,ncurr_rate_acc      => rV_ROW.NCURR_RATE_ACC
                       ,ncurr_rate_pay_acc  => rV_ROW.NCURR_RATE_PAY_ACC
                       ,ncurr_rate_trd      => rV_ROW.NCURR_RATE_TRD
                       ,ncurr_rate_base_trd => rV_ROW.NCURR_RATE_BASE_TRD
                       ,nupd_course         => rV_ROW.NUPD_COURSE
                       ,npay_sum            => rV_ROW.NPAY_SUM
                       ,npay_sum_acc        => rV_ROW.NPAY_SUM_ACC
                       ,npay_sum_trd        => rV_ROW.NPAY_SUM_TRD
                       ,staxgroup           => rV_ROW.STAXGROUP
                       ,npay_plan           => rV_ROW.NPAY_PLAN
                       ,nsignactive         => rV_ROW.NSIGNACTIVE
                       ,spay_type           => rV_ROW.SPAY_TYPE
                       ,nsignacnt           => rV_ROW.NSIGNACNT
                       ,nsignopacc          => rV_ROW.NSIGNOPACC
                       ,stdoc_type          => rV_ROW.STDOC_TYPE
                       ,stdoc_numb          => rV_ROW.STDOC_NUMB
                       ,dtdoc_date          => rV_ROW.DTDOC_DATE
                       ,ntax_sum            => rV_ROW.NTAX_SUM
                       ,ntax_percent        => rV_ROW.NTAX_PERCENT
                       ,scomments           => rV_ROW.SCOMMENTS
                       ,spay_purp           => rV_ROW.SPAY_PURP
                       ,sgovcntrid          => rV_ROW.SGOVCNTRID
                       ,ssepaccop           => rV_ROW.SSEPACCOP
                       ,sagnacc             => rV_ROW.SAGNACC
                       ,spayer_agnacc       => rV_ROW.SPAYER_AGNACC);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Считывание значений платежа до исправления */
      select * into rV_PayNotesPrev from v_paynotes where nrn = rV_ROW.NRN;

      /* Фин.операция RN */
      p_find_dictoper_by_mnemo(ncompany => rV_ROW.NCOMPANY         , nmnemo => rV_ROW.SFINOPER_MNEMO         , nrn => nFinOper);
      p_find_dictoper_by_mnemo(ncompany => rV_PayNotesPrev.ncompany, nmnemo => rV_PayNotesPrev.sfinoper_mnemo, nrn => nFinOperPrev);
      /* Валюта RN */
      find_currency_by_code(company => rV_ROW.NCOMPANY         , code => rV_ROW.SCURRENCY         , rn => nCurrency);
      find_currency_by_code(company => rV_PayNotesPrev.ncompany, code => rV_PayNotesPrev.scurrency, rn => nCurrencyPrev);

      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
      /* Удаление входных связей */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 1
                                         ,nrn           => rV_ROW.NRN
                                         ,ncompany      => rV_ROW.NCOMPANY
                                         ,arn_unit_list => aRN_Unit_List
                                         ,nmode         => 0 );
      /* Удаление связей */
      /*usr_pkg_doclinks.doclinks_reset_in(nflagsmart    => 0
                                        ,ncompany      => rV_ROW.NCOMPANY
                                        ,sout_unitcode => 'PayNotes'
                                        ,nout_document => rV_ROW.NRN
                                        ,sin_unitcode  => 'PaymentAccountsIn'
                                        ,ain_document  => aRNList
                                        ,nmode         => 0);
      usr_pkg_doclinks.doclinks_reset_in(nflagsmart    => 0
                                        ,ncompany      => rV_ROW.NCOMPANY
                                        ,sout_unitcode => 'PayNotes'
                                        ,nout_document => rV_ROW.NRN
                                        ,sin_unitcode  => 'BankDocuments'
                                        ,ain_document  => aRNList2
                                        ,nmode         => 0);*/
      /* ФРАГМЕНТ ИЗ ТРИГГЕРА T_PAYNOTES_BUPDATE */
      /* энергетика */
      pkg_paynotes.set_prev_state(aprev_sum     => rV_PayNotesPrev.npay_sum_acc
                                 ,aprev_finoper => nFinOperPrev
                                 ,aprev_paytype => rV_PayNotesPrev.npay_type
                                 ,aserv_pay     => rV_PayNotesPrev.nserv_pay);
      pkg_paynotes.set_prev_sum_tax(rV_PayNotesPrev.ntax_sum);
      pkg_paynotes.set_prev_date(rV_PayNotesPrev.dpay_date);
      /* управление финансами */
      pkg_paynotes.set_new_state_fp(nfaceacc  => rV_ROW.NFACEACC
                                   ,noper     => nFinOper
                                   ,nsum      => rV_ROW.NPAY_SUM
                                   ,nacc_sum  => rV_ROW.NPAY_SUM_ACC
                                   ,ncurrency => nCurrency
                                   ,ddate     => rV_ROW.DPAY_DATE);
      pkg_paynotes.set_new_pay_plan(npay_plan => rV_ROW.NPAY_PLAN);
      /* реализация */
      pkg_paynotes.set_prev_signactive(nsignactive => rV_PayNotesPrev.nsignactive);
      pkg_paynotes.set_prev_graphpoint(ngraphpoint => rV_PayNotesPrev.ngraphpoint);
      /* товарные документы */
      pkg_paynotes_gdoc.set_pay_sum_trd(rV_ROW.npay_sum_trd);
      /* Отражение платежа на исходном лицевом счёте */
      p_paynotes_ex_tofaceacc(ncompany => rV_ROW.NCOMPANY, nrn => rV_ROW.NRN, soperation => 'D');
      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Исправление платежа с установкой флага для обхода запрета в триггере */
      pkg_flag.set_flag;
      paynotes_update(rv_row => rV_ROW, nmode => 0);
      pkg_flag.reset_flag;

      /* Отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
      /* Отражение платежа на новом лицевом счёте */
      p_paynotes_ex_tofaceacc(ncompany => rV_ROW.NCOMPANY, nrn => rV_ROW.NRN, soperation => 'I');
      /* Восстановление входных связей */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 1
                                         ,nrn           => rV_ROW.NRN
                                         ,ncompany      => rV_ROW.NCOMPANY
                                         ,arn_unit_list => aRN_Unit_List
                                         ,nmode         => 1 );
      /* Восстановление связей */
      /*usr_pkg_doclinks.doclinks_reset_in(nflagsmart    => 0
                                        ,ncompany      => rV_ROW.ncompany
                                        ,sout_unitcode => 'PayNotes'
                                        ,nout_document => rV_ROW.nrn
                                        ,sin_unitcode  => 'PaymentAccountsIn'
                                        ,ain_document  => aRNList
                                        ,nmode         => 1);
      usr_pkg_doclinks.doclinks_reset_in(nflagsmart    => 0
                                        ,ncompany      => rV_ROW.ncompany
                                        ,sout_unitcode => 'PayNotes'
                                        ,nout_document => rV_ROW.nrn
                                        ,sin_unitcode  => 'BankDocuments'
                                        ,ain_document  => aRNList2
                                        ,nmode         => 1);*/
      /* Включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end PAYNOTES_UPDATE;
  --#########################################################################################################

  procedure PAYNOTES_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in paynotes%rowtype
  ) 
  is 
  begin
    p_paynotes_base_update(nrn                 => rROW.rn
                          ,ncompany            => rROW.company
                          ,njur_pers           => rROW.jur_pers
                          ,spay_prefix         => rROW.pay_prefix
                          ,spay_number         => rROW.pay_number
                          ,npayer              => rROW.payer
                          ,dpay_date           => rROW.pay_date
                          ,npay_type           => rROW.pay_type
                          ,nserv_pay           => rROW.serv_pay
                          ,nfaceacc            => rROW.faceacc
                          ,ngraphpoint         => rROW.graphpoint
                          ,nfinoper            => rROW.finoper
                          ,npaytool            => rROW.paytool
                          ,nvdoc_type          => rROW.vdoc_type
                          ,svdoc_numb          => rROW.vdoc_numb
                          ,dvdoc_date          => rROW.vdoc_date
                          ,nfdoc_type          => rROW.fdoc_type
                          ,sfdoc_numb          => rROW.fdoc_numb
                          ,dfdoc_date          => rROW.fdoc_date
                          ,nescort_doctype     => rROW.escort_doctype
                          ,sescort_docnumb     => rROW.escort_docnumb
                          ,descort_docdate     => rROW.escort_docdate
                          ,ncurrency           => rROW.currency
                          ,ncurr_rate          => rROW.curr_rate
                          ,ncurr_rate_base     => rROW.curr_rate_base
                          ,ncurr_rate_acc      => rROW.curr_rate_acc
                          ,ncurr_rate_pay_acc  => rROW.curr_rate_pay_acc
                          ,ncurr_rate_trd      => rROW.curr_rate_trd
                          ,ncurr_rate_base_trd => rROW.curr_rate_base_trd
                          ,nUPD_COURSE         => rROW.UPD_COURSE          ---Обновление 2024/03/28
                          ,npay_sum            => rROW.pay_sum
                          ,npay_sum_acc        => rROW.pay_sum_acc
                          ,npay_sum_trd        => rROW.pay_sum_trd
                          ,nfinspec            => rROW.finspec
                          ,nintrdebt           => rROW.intrdebt
                          ,neditable           => rROW.editable
                          ,nsignplan           => rROW.signplan
                          ,npay_plan           => rROW.pay_plan
                          ,nsignacnt           => rROW.signacnt
                          ,nsignspent          => rROW.signspent
                          ,nsignactive         => rROW.signactive
                          ,ntaxgroup           => rROW.taxgroup
                          ,nsignopacc          => rROW.signopacc
                          ,ntdoc_type          => rROW.tdoc_type
                          ,stdoc_numb          => rROW.tdoc_numb
                          ,dtdoc_date          => rROW.tdoc_date
                          ,ntax_sum            => rROW.tax_sum
                          ,ntax_percent        => rROW.tax_percent
                          ,scomments           => rROW.comments
                          ,saltsign1           => rROW.altsign1
                          ,saltsign2           => rROW.altsign2
                          ,saltsign3           => rROW.altsign3
                          ,saltsign4           => rROW.altsign4
                          ,saltsign5           => rROW.altsign5
                          ,saltsign6           => rROW.altsign6
                          ,saltsign7           => rROW.altsign7
                          ,saltsign8           => rROW.altsign8
                          ,saltsign9           => rROW.altsign9
                          ,saltsign10          => rROW.altsign10
                          ,spay_purp           => rROW.pay_purp
                          ,ngovcntrid          => rROW.govcntrid
                          ,nsepaccop           => rROW.sepaccop
                          ,nagnacc             => rROW.agnacc
                          ,npayer_agnacc       => rROW.payer_agnacc);
  end PAYNOTES_BASE_UPDATE;
  --#########################################################################################################

  procedure PAYNOTES_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW           in paynotes%rowtype
  ,nRN            out number
  ) 
  is 
  begin
    p_paynotes_base_insert(ncompany            => rROW.company
                          ,ncrn                => rROW.crn
                          ,njur_pers           => rROW.jur_pers
                          ,spay_prefix         => rROW.pay_prefix
                          ,spay_number         => rROW.pay_number
                          ,npayer              => rROW.payer
                          ,dpay_date           => rROW.pay_date
                          ,npay_type           => rROW.pay_type
                          ,nserv_pay           => rROW.serv_pay
                          ,nfaceacc            => rROW.faceacc
                          ,ngraphpoint         => rROW.graphpoint
                          ,nfinoper            => rROW.finoper
                          ,npaytool            => rROW.paytool
                          ,nvdoc_type          => rROW.vdoc_type
                          ,svdoc_numb          => rROW.vdoc_numb
                          ,dvdoc_date          => rROW.vdoc_date
                          ,nfdoc_type          => rROW.fdoc_type
                          ,sfdoc_numb          => rROW.fdoc_numb
                          ,dfdoc_date          => rROW.fdoc_date
                          ,nescort_doctype     => rROW.escort_doctype
                          ,sescort_docnumb     => rROW.escort_docnumb
                          ,descort_docdate     => rROW.escort_docdate
                          ,ncurrency           => rROW.currency
                          ,ncurr_rate          => rROW.curr_rate
                          ,ncurr_rate_base     => rROW.curr_rate_base
                          ,ncurr_rate_acc      => rROW.curr_rate_acc
                          ,ncurr_rate_pay_acc  => rROW.curr_rate_pay_acc
                          ,ncurr_rate_trd      => rROW.curr_rate_trd
                          ,ncurr_rate_base_trd => rROW.curr_rate_base_trd
                          ,nUPD_COURSE         => rROW.UPD_COURSE          --- Обновление 2024/03/28
                          ,npay_sum            => rROW.pay_sum
                          ,npay_sum_acc        => rROW.pay_sum_acc
                          ,npay_sum_trd        => rROW.pay_sum_trd
                          ,nfinspec            => rROW.finspec
                          ,nintrdebt           => rROW.intrdebt
                          ,neditable           => rROW.editable
                          ,nsignplan           => rROW.signplan
                          ,npay_plan           => rROW.pay_plan
                          ,nsignacnt           => rROW.signacnt
                          ,nsignspent          => rROW.signspent
                          ,nsignactive         => rROW.signactive
                          ,ntaxgroup           => rROW.taxgroup
                          ,nsignopacc          => rROW.signopacc
                          ,ntdoc_type          => rROW.tdoc_type
                          ,stdoc_numb          => rROW.tdoc_numb
                          ,dtdoc_date          => rROW.tdoc_date
                          ,ntax_sum            => rROW.tax_sum
                          ,ntax_percent        => rROW.tax_percent
                          ,scomments           => rROW.comments
                          ,saltsign1           => rROW.altsign1
                          ,saltsign2           => rROW.altsign2
                          ,saltsign3           => rROW.altsign3
                          ,saltsign4           => rROW.altsign4
                          ,saltsign5           => rROW.altsign5
                          ,saltsign6           => rROW.altsign6
                          ,saltsign7           => rROW.altsign7
                          ,saltsign8           => rROW.altsign8
                          ,saltsign9           => rROW.altsign9
                          ,saltsign10          => rROW.altsign10
                          ,spay_purp           => rROW.pay_purp
                          ,ngovcntrid          => rROW.govcntrid
                          ,nsepaccop           => rROW.sepaccop
                          ,nagnacc             => rROW.agnacc
                          ,npayer_agnacc       => rROW.payer_agnacc
                          ,nrn                 => nRN
                          ,nbill               => null);

  end PAYNOTES_BASE_INSERT;
  --#########################################################################################################

  function PAYNOTESCLC_GET
  /*
  Калькуляция. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return paynotesclc%rowtype
  is
    rRow paynotesclc%rowtype;
  begin
    begin
      select t.* into rRow from paynotesclc t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'PAYNOTESCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYNOTESCLC')));
    end;

    return(rRow);

  end PAYNOTESCLC_GET;
  --#########################################################################################################

  procedure PAYNOTESCLC_UPDATE
  /*
  Фин.расширение. Исправление
  */
  (
   rV_ROW         in v_paynotesclc%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_paynotesclc_update(nrn           => rV_ROW.NRN
                          ,ncompany      => rV_ROW.NCOMPANY
                          ,snumb         => rV_ROW.SNUMB
                          ,scost_article => rV_ROW.SCOST_ARTICLE
                          ,scost_place   => rV_ROW.SCOST_PLACE
                          ,nsum_plan     => rV_ROW.NSUM_PLAN
                          ,nsum_fact     => rV_ROW.NSUM_FACT
                          ,npriority     => rV_ROW.NPRIORITY
                          ,sfaceaccount  => rV_ROW.SFACEACCOUNT
                          ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                          ,sfinoper_type => rV_ROW.SFINOPER_TYPE
                          ,ssubdiv       => rV_ROW.SSUBDIV);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end PAYNOTESCLC_UPDATE;
  --#########################################################################################################

  procedure PAYNOTESCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление
  */
  (
   rROW           in paynotesclc%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_paynotesclc_base_update(nrn           => rROW.RN
                               ,ncompany      => rROW.COMPANY
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,nsum_plan     => rROW.SUM_PLAN
                               ,nsum_fact     => rROW.SUM_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nsubdiv       => rROW.SUBDIV);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end PAYNOTESCLC_BASE_UPDATE;
  --#########################################################################################################

  procedure FINPAYNOTES_UPDATE
  /*
  Фин.расширение. Исправление
  */
  (
   rV_ROW         in v_finpaynotes_base%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_finpaynotes_update(nrn               => rV_ROW.NRN
                          ,ncompany          => rV_ROW.NCOMPANY
                          ,sjur_pers         => rV_ROW.SJUR_PERS
                          ,spay_prefix       => rV_ROW.SPAY_PREFIX
                          ,spay_number       => rV_ROW.SPAY_NUMBER
                          ,spayer            => rV_ROW.SPAYER
                          ,dpay_date         => rV_ROW.DPAY_DATE
                          ,sfaceacc          => rV_ROW.SFACEACC
                          ,sgraphpoint       => rV_ROW.SGRAPHPOINT
                          ,sfinoper          => rV_ROW.SFINOPER
                          ,svdoc_type        => rV_ROW.SVDOC_TYPE
                          ,svdoc_numb        => rV_ROW.SVDOC_NUMB
                          ,dvdoc_date        => rV_ROW.DVDOC_DATE
                          ,sfdoc_type        => rV_ROW.SFDOC_TYPE
                          ,sfdoc_numb        => rV_ROW.SFDOC_NUMB
                          ,dfdoc_date        => rV_ROW.DFDOC_DATE
                          ,scurrency         => rV_ROW.SCURRENCY
                          ,ncurr_rate        => rV_ROW.NCURR_RATE
                          ,ncurr_rate_base   => rV_ROW.NCURR_RATE_BASE
                          ,nupd_course       => rV_ROW.NUPD_COURSE
                          ,npay_sum          => rV_ROW.NPAY_SUM
                          ,npay_plan         => rV_ROW.NPAY_PLAN
                          ,scomments         => rV_ROW.SCOMMENTS
                          ,nsignopacc        => rV_ROW.NSIGNOPACC
                          ,spay_type         => rV_ROW.SPAY_TYPE
                          ,staxgroup         => rV_ROW.STAXGROUP
                          ,ntax_sum          => rV_ROW.NTAX_SUM
                          ,ntax_percent      => rV_ROW.NTAX_PERCENT
                          ,sgovcntrid        => rV_ROW.SGOVCNTRID
                          ,ssepaccop         => rV_ROW.SSEPACCOP
                          ,sagnacc           => rV_ROW.SAGNACC
                          ,spayer_agnacc     => rV_ROW.SPAYER_AGNACC
                          ,sstate            => rV_ROW.SSTATE
                          ,nduty_per         => rV_ROW.NDUTY_PER
                          ,nduty_sum         => rV_ROW.NDUTY_SUM
                          ,nbase_duty_sum    => rV_ROW.NBASE_DUTY_SUM
                          ,ssubdiv           => rV_ROW.SSUBDIV
                          ,srespmanager      => rV_ROW.SRESPMANAGER
                          ,sieelement        => rV_ROW.SIEELEMENT
                          ,ssource           => rV_ROW.SSOURCE
                          ,spaytool          => rV_ROW.SPAYTOOL
                          ,spayrule          => rV_ROW.SPAYRULE
                          ,nfactrest         => rV_ROW.NFACTREST
                          ,nplanrest         => rV_ROW.NPLANREST
                          ,sload_rise_prefix => rV_ROW.SLOAD_RISE_PREFIX
                          ,sload_rise_numb   => rV_ROW.SLOAD_RISE_NUMB
                          ,spayprior         => rV_ROW.SPAYPRIOR
                          ,sdefl             => rV_ROW.SDEFL
                          ,sagr_pay          => null
                          ,sspmark           => rV_ROW.SSPMARK
                          ,nopertype         => rV_ROW.nFINOPER_DIRECT
                          ,npaytype          => rV_ROW.nOPERFEATURE
                          ,ndebtype          => rV_ROW.NDEBTYPE
                          ,ndebflowtype      => rV_ROW.NDEBFLOWTYPE
                          ,scal_payer        => rV_ROW.SCAL_PAYER
                          ,scal_payer_acc    => rV_ROW.SCAL_PAYER_ACC
                          ,nrequest          => rV_ROW.NREQUEST
                          ,sindossament      => rV_ROW.SINDOSSAMENT
                          ,spay_purp         => rV_ROW.SPAY_PURP
                          ,dpayplan_date     => rV_ROW.DPAYPLAN_DATE
                          ,ncurrent_sum      => rV_ROW.NCURRENT_SUM
                          ,scurrent_cur      => rV_ROW.SCURRENT_CUR
                          ,scurrent_tool     => rV_ROW.SCURRENT_TOOL
                          ,spayment_type     => rV_ROW.SPAYMENT_TYPE
                          ,spay_kind         => rV_ROW.SPAY_KIND
                          ,spayment_que      => rV_ROW.SPAYMENT_QUE
                          ,nfacevalue_sum    => rV_ROW.NFACEVALUE_SUM
                          ,npay_quant        => rV_ROW.NPAY_QUANT);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end FINPAYNOTES_UPDATE;
  --#########################################################################################################

  procedure FINPAYNOTES_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW                 in finpaynotes%rowtype
  ,rPAYNOTES            in paynotes%rowtype
  ,rFINPAYCALENDAR      in finpaycalendar%rowtype
  ,nMODE                in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is 
    rFaceAcc            faceacc%rowtype;
    dFact_Close_Date    date;
    aRN_Unit_List_In    usr_pkg_pub_const.trn_unit_list;
    aRN_Unit_List_Out   usr_pkg_pub_const.trn_unit_list;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_finpaynotes_base_update(nrn             => rPAYNOTES.RN
                               ,ncompany        => rPAYNOTES.COMPANY
                               ,njur_pers       => rPAYNOTES.JUR_PERS
                               ,spay_prefix     => rPAYNOTES.PAY_PREFIX
                               ,spay_number     => rPAYNOTES.PAY_NUMBER
                               ,npayer          => rPAYNOTES.PAYER
                               ,dpay_date       => rPAYNOTES.PAY_DATE
                               ,nfaceacc        => rPAYNOTES.FACEACC
                               ,ngraphpoint     => rPAYNOTES.GRAPHPOINT
                               ,nfinoper        => rPAYNOTES.FINOPER
                               ,nvdoc_type      => rPAYNOTES.VDOC_TYPE
                               ,svdoc_numb      => rPAYNOTES.VDOC_NUMB
                               ,dvdoc_date      => rPAYNOTES.VDOC_DATE
                               ,nfdoc_type      => rPAYNOTES.FDOC_TYPE
                               ,sfdoc_numb      => rPAYNOTES.FDOC_NUMB
                               ,dfdoc_date      => rPAYNOTES.FDOC_DATE
                               ,ncurrency       => rPAYNOTES.CURRENCY
                               ,ncurr_rate      => rPAYNOTES.CURR_RATE
                               ,ncurr_rate_base => rPAYNOTES.CURR_RATE_BASE
                               ,nupd_course     => rPAYNOTES.UPD_COURSE
                               ,npay_sum        => rPAYNOTES.PAY_SUM
                               ,nstate_sign     => rPAYNOTES.EDITABLE
                               ,npay_plan       => rPAYNOTES.PAY_PLAN
                               ,scomments       => rPAYNOTES.COMMENTS
                               ,nsignopacc      => rPAYNOTES.SIGNOPACC
                               ,npay_type       => rPAYNOTES.PAY_TYPE
                               ,ntaxgroup       => rPAYNOTES.TAXGROUP
                               ,ntax_sum        => rPAYNOTES.TAX_SUM
                               ,ntax_percent    => rPAYNOTES.TAX_PERCENT
                               ,ngovcntrid      => rPAYNOTES.GOVCNTRID
                               ,nsepaccop       => rPAYNOTES.SEPACCOP
                               ,nagnacc         => rPAYNOTES.AGNACC
                               ,npayer_agnacc   => rPAYNOTES.PAYER_AGNACC
                               ,nstate          => rROW.STATE
                               ,nduty_per       => rROW.DUTY_PER
                               ,nduty_sum       => rROW.DUTY_SUM
                               ,nbase_duty_sum  => rROW.BASE_DUTY_SUM
                               ,nsubdiv         => rROW.SUBDIV
                               ,nrespmanager    => rROW.RESPMANAGER
                               ,nieelement      => rROW.IEELEMENT
                               ,nsource         => rROW.SOURCE
                               ,npaytool        => rROW.PAYTOOL
                               ,npayrule        => rROW.PAYRULE
                               ,nfactrest       => rROW.FACTREST
                               ,nplanrest       => rROW.PLANREST
                               ,nload_rise      => rROW.LOAD_RISE
                               ,npayprior       => rROW.PAYPRIOR
                               ,ndefl           => rROW.DEFL
                               ,nagr_pay        => rROW.AGR_PAY
                               ,nspmark         => rROW.SPMARK
                               ,nopertype       => rROW.OPERTYPE
                               ,npaytype        => rROW.PAYTYPE
                               ,ndebtype        => rROW.DEBTYPE
                               ,ndebflowtype    => rROW.DEBFLOWTYPE
                               ,ncal_payer      => rFINPAYCALENDAR.CAL_PAYER
                               ,ncal_payer_acc  => rFINPAYCALENDAR.CAL_PAYER_ACC
                               ,spay_purp       => rPAYNOTES.PAY_PURP
                               ,dpayplan_date   => rFINPAYCALENDAR.PAYPLAN_DATE
                               ,ncurrent_sum    => rFINPAYCALENDAR.CURRENT_SUM
                               ,ncurrent_cur    => rFINPAYCALENDAR.CURRENT_CUR
                               ,ncurrent_tool   => rFINPAYCALENDAR.CURRENT_TOOL
                               ,spayment_type   => rFINPAYCALENDAR.PAYMENT_TYPE
                               ,spay_kind       => rFINPAYCALENDAR.PAY_KIND
                               ,spayment_que    => rFINPAYCALENDAR.PAYMENT_QUE
                               ,nrequest        => rFINPAYCALENDAR.REQUEST
                               ,nfacevalue_sum  => rFINPAYCALENDAR.FACEVALUE_SUM
                               ,npay_quant      => rFINPAYCALENDAR.PAY_QUANT
                               ,nindossament    => rFINPAYCALENDAR.INDOSSAMENT);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Удаление связей */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 1
                                         ,nrn           => rPAYNOTES.RN
                                         ,ncompany      => rPAYNOTES.COMPANY
                                         ,arn_unit_list => aRN_Unit_List_In
                                         ,nmode         => 0 );
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                         ,nrn           => rPAYNOTES.RN
                                         ,ncompany      => rPAYNOTES.COMPANY
                                         ,arn_unit_list => aRN_Unit_List_Out
                                         ,nmode         => 0 );

      /* Если в платеже указал личевой счёт */
      if rPAYNOTES.FACEACC is not null then
        /* Считывание личевого счёта */
        rFaceAcc := usr_pkg_FaceAcc.faceacc_get(nrn => rPAYNOTES.FACEACC);
        /* Если ЛС закрыт (дата закрытия не пустая) */
        if rFaceAcc.fact_close_date is not null then
          /* сохраняем дату для восстановления после исправления */
          dFact_Close_Date := rFaceAcc.fact_close_date;
          /* открываем лицевой счёт */
          usr_pkg_faceacc.faceacc_open(rrow => rFaceAcc, dopen_date => rFaceAcc.fact_open_date, nmode => 1);
        end if;
      end if;

      /* Исправляем фин. расширение в штатном режиме */
      finpaynotes_base_update(rrow              => rrow
                             ,rpaynotes         => rpaynotes
                             ,rfinpaycalendar   => rfinpaycalendar
                             ,nmode             => 0);

      /* Восстановление связей */
      usr_pkg_doclinks.doclinks_reset_in( nflagsmart    => 1
                                         ,nrn           => rPAYNOTES.RN
                                         ,ncompany      => rPAYNOTES.COMPANY
                                         ,arn_unit_list => aRN_Unit_List_In
                                         ,nmode         => 1 );
      usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => 1
                                         ,nrn           => rPAYNOTES.RN
                                         ,ncompany      => rPAYNOTES.COMPANY
                                         ,arn_unit_list => aRN_Unit_List_Out
                                         ,nmode         => 1 );

      /* Если лицевой счёт открывался (дата закрытия была сохранена) */
      if dFact_Close_Date is not null then
        /* закрываем лицевой счёт */
        usr_pkg_FaceAcc.faceacc_close(rrow => rFaceAcc, dclose_date => dFact_Close_Date, nmode => 1);
      end if;        

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end FINPAYNOTES_BASE_UPDATE;
  --#########################################################################################################
  
 procedure PAYNOTES_TYP_DIRECT_CNTR
 /*
   Проверка совпадения направления финансовой операции журнала платежей  с напралением статьи затрат лицевого счета
   */
 (nrn in paynotes.rn%type) is
 
 begin
   for cur in (select case pnf.factret_sign /* признак возврата */
                        when 0 then
                         pnf.typoper_direct
                        when 1 then
                         1 - pnf.typoper_direct
                        else
                         pnf.typoper_direct
                      end pn_dir
                     ,case szn.code
                        when 'Доход' then
                         0
                        when 'Расход' then
                         1
                        else
                         pnf.typoper_direct
                      end f_dir
                     ,pn.rn
                     ,pn.pay_date
                     ,f.numb
                     ,pnf.typoper_mnemo
                     ,sz.code sz_code
                 from paynotes pn
                 join faceacc f
                   on f.rn = pn.faceacc
                 join dictoper pnf
                   on pnf.rn = pn.finoper
                 join fpdartcl sz
                   on sz.rn = f.ieelement
                 join diciearts szn
                   on szn.rn = sz.iearticle
                where pn.rn = nrn
                  and pn.signplan != 1
                  and case pnf.factret_sign
                        when 0 then
                         pnf.typoper_direct
                        when 1 then
                         1 - pnf.typoper_direct
                        else
                         pnf.typoper_direct
                      end != case szn.code
                        when 'Доход' then
                         0
                        when 'Расход' then
                         1
                        else
                         case pnf.typoper_direct
                           when 0 then
                            pnf.typoper_direct
                           when 1 then
                            1 - pnf.typoper_direct
                           else
                            pnf.typoper_direct
                         end
                      end)
   loop
     p_exception(0,
                'Вид банковской операции (Финасовая операция Журнала платежей "%s" тип ("%s")) не соответствует виду движению статьи (статье затрат лицевого счета %s тип ("%s")). Это возврат? Если да, необходимо изменить вид оплаты на возврат. Если нет, необходимо выбрать фиктивный лицевой счёт с другой бюджетной статьей.'
                ,cur.typoper_mnemo
                ,case cur.pn_dir when 1 then 'Расход' else 'Приход' end
                ,cur.sz_code
                ,case cur.f_dir when 1 then 'Расход' else 'Приход' end
               );
   end loop;
 
 end;
 --#########################################################################################################
 
end USR_PKG_PAYNOTES;
/
