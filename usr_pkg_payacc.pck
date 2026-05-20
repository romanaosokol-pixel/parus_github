create or replace package USR_PKG_PAYACC is
  /*
  Package предназначен для работы с разделом "Счета на оплату". Степанов М. 02/04/2024
  PaymentAccounts             PAYACC        PA
  PaymentAccountsSpecs        PAYACCSPECS   PAS
  PaymentAccountsSpecsCalcs   PAYACCSPCLC   PASC
  */
  --#########################################################################################################

  function PAYACC_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return PAYACC%ROWTYPE;
  --#########################################################################################################
  
  /* Проверка корректности спецификации счета */
  
  procedure PAYACC_CHEK_BASE_SPEC
    (
    nRn number
    );

  --#########################################################################################################

  FUNCTION PAYACC_GET_STATE_NAME
  /*
  Наименование статусов
  */
  (
   nSTATUS      IN NUMBER
  ) 
  RETURN VARCHAR2;
  --#########################################################################################################

  function PAYACC_GET_TYPE
  /*
  Заголовок. Получение типа счёта (1 - товар, 2 - услуга, 3 - тара, 9 - смешанный, 0 - нет спецификаций)
  */
  (
   nRN        in number -- RN записи
  ,nCOMPANY   in number
  ) 
  return number;
  --#########################################################################################################

  procedure PAYACC_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BPUTOUT
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Выставлен"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_APUTOUT
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Выставлен"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BCLOSE
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_ACLOSE
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BCANCEL
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_ACANCEL
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BMAKEINV
  /*
  Заголовок. Проверка перед Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_AMAKEINV
  /*
  Заголовок. Проверка после Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка перед Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_AMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка после Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_BMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка перед Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_AMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка после Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACC_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  PROCEDURE PAYACC_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW       in v_payacc%rowtype
  ,nRN          out number
  );
  --#########################################################################################################

  PROCEDURE PAYACC_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   RV_ROW       in v_payacc%rowtype  -- RN сформированного документа
  );
  --#########################################################################################################

  PROCEDURE PAYACC_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in payacc%rowtype  -- RN сформированного документа
  ,nSTATUS_IGNORE   in number default 0  -- Исправлять в утверждёный документ 0-нет, 1-да
  );
  --#########################################################################################################

  function PAYACCSPECS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return PAYACCSPECS%ROWTYPE;
  --#########################################################################################################

  procedure PAYACCSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACCSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACCSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACCSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACCSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure PAYACCSPECS_INSERT
  /*
  Спецификация. Добавление
  */
  (
   rV_ROW       in v_payaccspecs%rowtype  -- RN сформированного документа
  ,nDUP_RN      in number default null
  ,nRN          out number
  );
  --#########################################################################################################

  procedure PAYACCSPECS_UPDATE
  /*
  Спецификация. Исправление
  */
  (
   rV_ROW           in v_payaccspecs%rowtype  
  ,nFLAG_DEL_CALC   in number default 0  
  );
  --#########################################################################################################

  procedure PAYACCSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW       in payaccspecs%rowtype
  );
  --#########################################################################################################  

end USR_PKG_PAYACC;
/
create or replace package body USR_PKG_PAYACC is

  --#########################################################################################################

  function PAYACC_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return payacc%rowtype
  is
    rRow payacc%rowtype;
  begin
    begin
      select * into rRow from payacc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'PAYACC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACC'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end PAYACC_GET;
  --#########################################################################################################
  
  procedure PAYACC_CHEK_BASE_SPEC
    (
    nrn number
    ) is
  
    nq0 number(17);
    nq1 number(17);
  
  begin
  
    select count((case
                   when ts.quant = 0 then
                    1
                 end)) q0, /* Количество строк с 0 количеством*/
           count(ts.quant) q1 /* Общее количество строк */
      into nq0
          ,nq1
      from payaccspecs ts
     where ts.prn = nrn;
  
    p_exception(nq1
               ,'В спецификации счета обязательно должна быть хоть одна строка с ненулевым количеством!');
    p_exception(nq1 - nq0
               ,'В спецификации счета не должно содержаться строк с нулевым количеством!');
  
  end;
  --#########################################################################################################
  function PAYACC_GET_STATE_NAME
  /*
  Наименование статусов
  */
  (
   nSTATUS      in number
  ) 
  return varchar2
  is
    sResult pkg_std.tstring; 
  begin
    sResult := case nSTATUS
                 when 0 then 'Выставлен'
                 when 1 then 'Анулирован'
                 when 2 then 'Закрыт'
               else 'Не определён'
               end;
    return(sResult);

  end PAYACC_GET_STATE_NAME;
  --#########################################################################################################

  function PAYACC_GET_TYPE
  /*
  Заголовок. Получение типа счёта (1 - товар, 2 - услуга, 3 - тара, 9 - смешанный, 0 - нет спецификаций)
  */
  (
   nRN        in number -- RN записи
  ,nCOMPANY   in number
  ) 
  return number
  is
    nResult   pkg_std.tnumber;   
    
    nNumber   pkg_std.tnumber; 
  begin
    /* Проверка наличия документа */
    p_payacc_exists(ncompany => nCOMPANY, nrn => nrn, ncrn => nNumber);
    
    /* Определение типа */
    begin
      select decode(listagg(nomen_type) within group (order by nomen_type) 
                   ,1 ,1
                   ,2 ,2
                   ,3 ,3
                   ,null, 0 /* нет спецификаций */
                   ,9)
       into nResult
       from (select distinct dnm.nomen_type
               from payaccspecs t, dicnomns dnm, nommodif nm
              where t.prn      = nRN
                and t.nommodif = nm.rn
                and nm.prn     = dnm.rn);
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>. %s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'PAYACC')), sqlerrm);
    end;

    return(nResult);

  end PAYACC_GET_TYPE;
  --#########################################################################################################

  procedure PAYACC_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payacc%rowtype;
    sNumbMax        pkg_std.tstring; 
    sNumb2          pkg_std.tstring;

    sVarchar        pkg_std.tstring; 
  begin
    -- Заголовок  
    rRow := payacc_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКА */
    /* Базовая */
    payacc_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Префикс-номер */
/*    \* считывание максимального номера *\
    begin
      select trim(max(t.numb))
        into sNumbMax
        from payacc t
       where t.doctype = rRow.doctype
         and cmp_vc2(t.pref, rRow.pref) = 1
         and t.rn      != rRow.rn;
    exception
      when others then
        p_exception(0, 'Неопределённая ситуация при определении максимального номера входящего счёта. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccounts', ndocument => rRow.rn)); 
    end;
    \* прибавляем единицу к максимальному номеру *\
    sNumbMax := nvl(s2n(sNumbMax), 0) + 1;
    \* проверка реквизитов *\
    usr_pkg_document.check_pref_numb(spref    => rRow.pref
                                    ,snumb    => rRow.numb
                                    ,ddate    => rRow.accdate
                                    ,snumbmax => sNumbMax);
*/

    /* Проверка префикса ущербная */
    if cmp_vc2(trim(rRow.pref), d_year(rRow.accdate)) != 1 then
      p_exception(0, 'Префикс <%s> должен равняться четырём цифрам года из поля "Дата".', nvl(trim(rRow.pref), 'Не задан'));
    end if;
    
    /* если есть символы или первый ноль*/
    rRow.numb := trim(rRow.numb);
    if ltrim(rRow.numb, '1234567890') is not null 
    or substr(rRow.numb, 0, 1) = 0 then
      p_exception(0, 'Номер <%s> должен содержать только цифры, и первым не должен быть ноль.', rRow.numb);
    end if;

    /* По спецификациям */
    for c in (select * from payaccspecs where prn = rRow.rn) 
    loop
      /* проверка спецификации */
      payaccspecs_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;
    
  end PAYACC_AINSERT;
  --#########################################################################################################

  procedure PAYACC_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание */
    usr_pkg_pub_const.rpayacc := payacc_get(nrn => nRN); 

  end PAYACC_BUPDATE;
  --#########################################################################################################

  procedure PAYACC_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payacc%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Заголовок */
    rRow := payacc_get(nrn => nRN);
  
    /* ИСПРАВЛЕНИЯ */


    /* ПРОВЕРКИ */
    /* Базовая */
    payacc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PAYACC_AUPDATE;
  --#########################################################################################################

  procedure PAYACC_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      PAYACC%rowtype;
    
  procedure payacc_unlink_fop(nrn in payacc.rn%type) is
    /*Процедура удаляет связб между спецификацией счета на оплату и графиком отгрузки, если нет фактических платежей
    и товарных документов созданных из счета */
    v_fl number(1) := 1; /* Признак отсутсивия ощибок */
  
  begin
  
    /*Проверим отсутствие товарных докуметов, сформированных из счета */
    select nvl(max(0)
              ,1)
      into v_fl
      from doclinks dlt
     where dlt.in_document = nrn
       and dlt.in_unitcode = 'PaymentAccounts'
       and dlt.out_unitcode = 'GoodsTransInvoicesToConsumers'
       and rownum = 1;
  
    p_exception(v_fl
               ,'Удаление счета невозможно, т.к. из него уже созданы накладные.');
  
    /*Проверим отсутствие фактических платежей, сформированных из счета */
  
    select nvl(max(0)
              ,1)
      into v_fl
      from doclinks dlp
      join paynotes pn
        on pn.rn = dlp.out_document
       and pn.signplan = 0 /*Только факт */
     where dlp.in_document = nrn
       and dlp.in_unitcode = 'PaymentAccounts'
       and dlp.out_unitcode = 'PayNotes'
       and rownum = 1;
  
    /* Если все проверки прошли, то очищаем перед удалением */
    p_exception(v_fl
               ,'Удаление счета невозможно, т.к. из него уже созданы фактические платежи.');
  
    /* Удаляем плановые платежи */
  
    for cur in (select dlp.out_document nrn
                      ,dlp.out_company  ncom
                  from doclinks dlp
                 where dlp.in_document = nrn
                   and dlp.in_unitcode = 'PaymentAccounts'
                   and dlp.out_unitcode = 'PayNotes')
    loop
      p_paynotes_base_delete(nrn      => cur.nrn
                            ,ncompany => cur.ncom);
    end loop;
  
    /* Пересчитываем график отгрузки ЛС счета иУдаляем связь спецификации счета с графиком отгрузки ЛС   */
  
    for spe in (select t.quant         q
                      ,t.summwithnds   s
                      ,dl.in_unitcode
                      ,dl.out_unitcode
                      ,dl.in_document
                      ,dl.out_document
                  from payaccspecs t
                  join doclinks dl
                    on dl.in_document = t.rn
                   and dl.out_unitcode = 'FaceAccountsOperOutPlans'
                   and dl.in_unitcode = 'PaymentAccountsSpecs'
                 where t.prn = nrn)
    loop
    
      update fcacoperplans fop
         set fop.acc_quant = greatest(fop.acc_quant - spe.q
                                     ,0)
            ,fop.acc_sum   = greatest(fop.acc_sum - spe.s
                                     ,0)
            ,fop.acc_count = greatest(fop.acc_count - 1
                                     ,0)
       where fop.rn = spe.out_document;
    
      pkg_doclinks.remove(sin_unitcode  => spe.in_unitcode
                         ,nin_document  => spe.in_document
                         ,sout_unitcode => spe.out_unitcode
                         ,nout_document => spe.out_document);
    end loop;
  
  end payacc_unlink_fop;
    
    
  begin
    /* Заголовок */
    rRow := payacc_get(nrn => nRN);
    
    /* Снятие утверждения */
    if rRow.status != 0 then
      p_payacc_base_changestatus(ncompany   => rRow.company
                                ,nrn        => rRow.rn
                                ,nstatus    => 0
                                ,dwork_date => current_date);
    end if;
    /*Удалим связь спецификации с графиком отгрузки*/
    payacc_unlink_fop(nrn);
    

  end PAYACC_BDELETE;
  --#########################################################################################################

  procedure PAYACC_BPUTOUT
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Выставлен"
  */
  (
   nRN       in number
  ,nCOMPANY  in NUMBER
  )
  is
    sVarchar    pkg_std.tstring; 
  begin
    /* Заголовок */
    usr_pkg_pub_const.rpayacc := payacc_get(nrn => nRN);

    /* ПРОВЕРКИ */
  
  end PAYACC_BPUTOUT;
  --#########################################################################################################

  procedure PAYACC_APUTOUT
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Выставлен"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
    rRow            payacc%rowtype;
  begin
    /* Заголовок */
    rRow := payacc_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая*/
    payacc_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* По спецификациям */
    /*for c in (select * from payaccspecs where prn = rRow.rn) 
    loop
      \* проверка превышения исполнения родительской спецификации заказа поставщикам *\
      \*payaccspecs_check_indoc(rrow => c);*\
      \* проверка калькуляций *\
      \*payaccspecs_check_pasc(rrow => c);*\
    end loop;*/

  end PAYACC_APUTOUT;
  --#########################################################################################################

  procedure PAYACC_BCLOSE
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in NUMBER
  )
  is
  begin
    /* Заголовок */
    usr_pkg_pub_const.rpayacc := payacc_get(nrn => nRN);
    
  end PAYACC_BCLOSE;
  --#########################################################################################################

  procedure PAYACC_ACLOSE
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Закрыт"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACC_ACLOSE;
  --#########################################################################################################

  procedure PAYACC_BCANCEL
  /*
  Заголовок. Проверка перед Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACC_BCANCEL;
  --#########################################################################################################

  procedure PAYACC_ACANCEL
  /*
  Заголовок. Проверка после Перевод входящего счета на оплату в состояние "Аннулирован"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACC_ACANCEL;
  --#########################################################################################################

  procedure PAYACC_BMAKEINV
  /*
  Заголовок. Проверка перед Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  END PAYACC_BMAKEINV; 
  --#########################################################################################################

  procedure PAYACC_AMAKEINV
  /*
  Заголовок. Проверка после Формирование приходных накладных
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select column_value from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable))) 
    loop
      /* проверка заголовка */
      usr_pkg_transinvcust.transinvcust_ainsert(nrn => c.column_value, ncompany => nCOMPANY);
    end loop;

  end PAYACC_AMAKEINV;
  --#########################################################################################################

  procedure PAYACC_BMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка перед Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    payacc_chek_base_spec(nRN);
  end PAYACC_BMAKEPLANPAYNOTE;
  --#########################################################################################################

  procedure PAYACC_AMAKEPLANPAYNOTE
  /*
  Заголовок. Проверка после Формирование плановых платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACC_AMAKEPLANPAYNOTE;
  --#########################################################################################################

  procedure PAYACC_BMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка перед Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    /* Запрет формирования фактических платежей */
    p_exception(0, 'Запрещено добавление фактического платежа не из раздела "Банковские документы". %s'
               ,cr||f_docdescrs_get_description(sunitcode => 'PaymentAccounts', ndocument => nRN)); 

  end PAYACC_BMAKEFACTPAYNOTE;
  --#########################################################################################################

  procedure PAYACC_AMAKEFACTPAYNOTE
  /*
  Заголовок. Проверка после Формирование фактических платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  )
  is
  begin
    null;
  end PAYACC_AMAKEFACTPAYNOTE;
  --#########################################################################################################

  procedure PAYACC_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            payacc%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := payacc_get(nrn => nRN);*/

  end PAYACC_CHECK_BASE;
  --#########################################################################################################

  PROCEDURE PAYACC_INSERT
  /*
  Заголовок. Добавление
  */
  (
   rV_ROW       in v_payacc%rowtype
  ,nRN          out number
  ) 
  is
    sVarchar    pkg_std.tstring; 
  begin
    p_payacc_insert(ncompany      => rV_ROW.NCOMPANY
                   ,ncrn          => rV_ROW.NCRN
                   ,sjur_pers     => rV_ROW.SJUR_PERS
                   ,sself_agnacc  => rV_ROW.SSELF_AGNACC
                   ,sagent        => rV_ROW.SAGENT
                   ,sagnacc       => rV_ROW.SAGNACC
                   ,sfaceacc      => rV_ROW.SFACEACC
                   ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                   ,scurrency     => rV_ROW.SCURRENCY
                   ,ssheepview    => rV_ROW.SSHEEPVIEW
                   ,spaytype      => rV_ROW.SPAYTYPE
                   ,starif        => rV_ROW.STARIF
                   ,sfifo         => rV_ROW.SFIFO
                   ,sstore        => rV_ROW.SSTORE
                   ,sdoctype      => rV_ROW.SDOCTYPE
                   ,spref         => rV_ROW.SPREF
                   ,snumb         => rV_ROW.SNUMB
                   ,daccdate      => rV_ROW.DACCDATE
                   ,dsaledate     => rV_ROW.DSALEDATE
                   ,dwork_date    => rV_ROW.DWORK_DATE
                   ,ncurcours     => rV_ROW.NCURCOURS
                   ,ncurbase      => rV_ROW.NCURBASE
                   ,nfa_cours     => rV_ROW.NFA_COURS
                   ,nfa_basecours => rV_ROW.NFA_BASECOURS
                   ,ndiscount     => rV_ROW.NDISCOUNT
                   ,svdoc_type    => rV_ROW.SVDOC_TYPE
                   ,svdoc_numb    => rV_ROW.SVDOC_NUMB
                   ,dvdoc_date    => rV_ROW.DVDOC_DATE
                   ,scomments     => rV_ROW.SCOMMENTS
                   ,sacc_agent    => rV_ROW.SACC_AGENT
                   ,ssubdiv       => rV_ROW.SSUBDIV
                   ,sbarcode      => rV_ROW.SBARCODE
                   ,nrn           => nRN
                   ,smsg          => sVarchar);
  END PAYACC_INSERT;
  --#########################################################################################################

  PROCEDURE PAYACC_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_payacc%rowtype  -- RN сформированного документа
  ) 
  is
  begin
    p_payacc_update(nrn           => rV_ROW.NRN
                   ,ncompany      => rV_ROW.NCOMPANY
                   ,sjur_pers     => rV_ROW.SJUR_PERS
                   ,sself_agnacc  => rV_ROW.SSELF_AGNACC
                   ,sagent        => rV_ROW.SAGENT
                   ,sagnacc       => rV_ROW.SAGNACC
                   ,sfaceacc      => rV_ROW.SFACEACC
                   ,sgraphpoint   => rV_ROW.SGRAPHPOINT
                   ,scurrency     => rV_ROW.SCURRENCY
                   ,ssheepview    => rV_ROW.SSHEEPVIEW
                   ,spaytype      => rV_ROW.SPAYTYPE
                   ,starif        => rV_ROW.STARIF
                   ,sfifo         => rV_ROW.SFIFO
                   ,sstore        => rV_ROW.SSTORE
                   ,sdoctype      => rV_ROW.SDOCTYPE
                   ,spref         => rV_ROW.SPREF
                   ,snumb         => rV_ROW.SNUMB
                   ,daccdate      => rV_ROW.DACCDATE
                   ,dsaledate     => rV_ROW.DSALEDATE
                   ,ncurcours     => rV_ROW.NCURCOURS
                   ,ncurbase      => rV_ROW.NCURBASE
                   ,nfa_cours     => rV_ROW.NFA_COURS
                   ,nfa_basecours => rV_ROW.NFA_BASECOURS
                   ,ndiscount     => rV_ROW.NDISCOUNT
                   ,svdoc_type    => rV_ROW.SVDOC_TYPE
                   ,svdoc_numb    => rV_ROW.SVDOC_NUMB
                   ,dvdoc_date    => rV_ROW.DVDOC_DATE
                   ,scomments     => rV_ROW.SCOMMENTS
                   ,sacc_agent    => rV_ROW.SACC_AGENT
                   ,ssubdiv       => rV_ROW.SSUBDIV
                   ,sbarcode      => rV_ROW.SBARCODE);

  END PAYACC_UPDATE;
  --#########################################################################################################

  PROCEDURE PAYACC_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in payacc%rowtype  -- RN сформированного документа
  ,nSTATUS_IGNORE   in number default 0  -- Исправлять в утверждёный документ 0-нет, 1-да
  ) 
  is
  begin
    /* Если договор утверждён, то снимаем утверждение */
    if nSTATUS_IGNORE = 1 and rROW.STATUS != 0 then
      update payacc set status = 0 where rn = rROW.RN;
    end if;
    p_payacc_base_update(nrn           => rROW.RN
                        ,ncompany      => rROW.COMPANY
                        ,njur_pers     => rROW.JUR_PERS
                        ,nself_agnacc  => rROW.SELF_AGNACC
                        ,nagnacc       => rROW.AGNACC
                        ,nagent        => rROW.AGENT
                        ,nfaceacc      => rROW.FACEACC
                        ,ngraphpoint   => rROW.GRAPHPOINT
                        ,ncurrency     => rROW.CURRENCY
                        ,nsheepview    => rROW.SHEEPVIEW
                        ,npaytype      => rROW.PAYTYPE
                        ,ntarif        => rROW.TARIF
                        ,nfifo         => rROW.FIFO
                        ,nstore        => rROW.STORE
                        ,ndoctype      => rROW.DOCTYPE
                        ,spref         => rROW.PREF
                        ,snumb         => rROW.NUMB
                        ,daccdate      => rROW.ACCDATE
                        ,dsaledate     => rROW.SALEDATE
                        ,ncurcours     => rROW.CURCOURS
                        ,ncurbase      => rROW.CURBASE
                        ,nfa_cours     => rROW.FA_COURS
                        ,nfa_basecours => rROW.FA_BASECOURS
                        ,ndiscount     => rROW.DISCOUNT
                        ,nvdoc_type    => rROW.VDOC_TYPE
                        ,svdoc_numb    => rROW.VDOC_NUMB
                        ,dvdoc_date    => rROW.VDOC_DATE
                        ,scomments     => rROW.COMMENTS
                        ,nacc_agent    => rROW.ACC_AGENT
                        ,nsubdiv       => rROW.SUBDIV
                        ,sbarcode      => rROW.BARCODE);
    /* Если договор утверждён, то восстанавливаем утверждение */
    if nSTATUS_IGNORE = 1 and rROW.STATUS in (1, 2) then
      update payacc set status = rROW.STATUS where rn = rROW.RN;
    end if;
  END PAYACC_BASE_UPDATE;
  --#########################################################################################################

  function PAYACCSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return PAYACCSPECS%ROWTYPE
  is
    rRow PAYACCSPECS%ROWTYPE;
  begin
    begin
      select * into rRow from payaccspecs where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument =>  nRN, sunit_table => 'PAYACCSPECS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCSPECS'))
                   ,cr||sqlerrm);
    end;
    return(rRow);
  end PAYACCSPECS_GET;
  --#########################################################################################################

  procedure PAYACCSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow         payaccspecs%rowtype;
   rDicNomns    dicnomns%rowtype;
  begin
    /* Считывание */
    rRow := payaccspecs_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */
/*    \* Если документ в каталоге IT, Метрология *\
    if usr_pkg_common.is_crn_in_hiercrn(nCRN => rRow.crn, shier_crn_list => '12043905' \* IT, Метрология *\) then
      \* не заполнено Оригинальное наименование *\
      if rRow.original_name is null then
        \* считывание наименования номенклатуры в переменную спецификации *\
        rDicNomns          := usr_pkg_dicnomns.dicnomns_get(nrn => rRow.nomen);
        rRow.original_name := rDicNomns.nomen_name;
        \* исправление спецификации *\
        payaccspecs_base_update(rrow => rRow);
      end if;
    end if;    */

    /* ПРОВЕРКИ */
    /* Базовая */
    payaccspecs_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end PAYACCSPECS_AINSERT;
  --#########################################################################################################

  procedure PAYACCSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Считывание в константу */
    /*usr_pkg_pub_const.rpayaccspec := payaccspecs_get(nrn => nRN); */
  end PAYACCSPECS_BUPDATE;
  --#########################################################################################################

  procedure PAYACCSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow         payaccspecs%rowtype;
  begin
    /* Считывание */
    /*rRow := payaccspecs_get(nrn => nRN);*/
   
    /* ПРОВЕРКИ */
    /* Базовая */
    payaccspecs_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PAYACCSPECS_AUPDATE;
  --#########################################################################################################

  procedure PAYACCSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end PAYACCSPECS_BDELETE;
  --#########################################################################################################

  procedure PAYACCSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          payaccspecs%rowtype;
    rHead         payacc%rowtype;
    
    sVarchar      pkg_std.tstring; 
  begin
    null;
    /* Считывание */
    /*rRow  := payaccspecs_get(nrn => nRN);
    rHead := payacc_get(nrn => rRow.prn);*/

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */

  end PAYACCSPECS_CHECK_BASE;
  --#########################################################################################################

  procedure PAYACCSPECS_INSERT
  /*
  Спецификация. Добавление
  */
  (
   rV_ROW       in v_payaccspecs%rowtype  -- RN сформированного документа
  ,nDUP_RN      in number default null
  ,nRN          out number
  ) 
  is
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    p_payaccspecs_insert(ncompany                => rV_ROW.NCOMPANY
                        ,nprn                    => rV_ROW.NPRN
                        ,staxgr                  => rV_ROW.STAXGR
                        ,snomen                  => rV_ROW.SNOMEN
                        ,snommodif               => rV_ROW.SNOMMODIF
                        ,snomnmodifpack          => rV_ROW.SNOMNMODIFPACK
                        ,ssernumb                => rV_ROW.SSERNUMB
                        ,scountry                => rV_ROW.SCOUNTRY
                        ,sgtd                    => rV_ROW.SGTD
                        ,sarticle                => rV_ROW.SARTICLE
                        ,sgoodsparty             => rV_ROW.SGOODSPARTY
                        ,sstore                  => rV_ROW.SSTORE
                        ,nprice                  => rV_ROW.NPRICE
                        ,ndiscount               => rV_ROW.NDISCOUNT
                        ,nquant                  => rV_ROW.NQUANT
                        ,nquantalt               => rV_ROW.NQUANTALT
                        ,ncoeff                  => rV_ROW.NCOEFF
                        ,ncoeff_val_sign         => rV_ROW.NCOEFF_VAL_SIGN
                        ,ncoeff_calc_sign        => rV_ROW.NCOEFF_CALC_SIGN
                        ,npricemeas              => rV_ROW.NPRICEMEAS
                        ,nsumm                   => rV_ROW.NSUMM
                        ,nsummwithnds            => rV_ROW.NSUMMWITHNDS
                        ,nsumm_nds               => rV_ROW.NSUMM_NDS
                        ,nautocalc_sign          => rV_ROW.NAUTOCALC_SIGN
                        ,dbegindate              => rV_ROW.DBEGINDATE
                        ,denddate                => rV_ROW.DENDDATE
                        ,snote                   => rV_ROW.SNOTE
                        ,ndup_rn                 => nDUP_RN
                        ,nrn                     => nRN
                        ,smsg                    => sVarchar
                        ,nsumm_base_delta        => nNumber
                        ,nsummwithnds_base_delta => nNumber
                        ,nsumm_payacc            => nNumber
                        ,nsummwithnds_payacc     => nNumber);
  end PAYACCSPECS_INSERT;
  --#########################################################################################################

  procedure PAYACCSPECS_UPDATE
  /*
  Спецификация. Исправление
  */
  (
   rV_ROW           in v_payaccspecs%rowtype  
  ,nFLAG_DEL_CALC   in number default 0  
  ) 
  is
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    p_payaccspecs_update(nrn                     => rV_ROW.NRN
                        ,ncompany                => rV_ROW.NCOMPANY
                        ,nprn                    => rV_ROW.NPRN
                        ,staxgr                  => rV_ROW.STAXGR
                        ,snomen                  => rV_ROW.SNOMEN
                        ,snommodif               => rV_ROW.SNOMMODIF
                        ,snomnmodifpack          => rV_ROW.SNOMNMODIFPACK
                        ,ssernumb                => rV_ROW.SSERNUMB
                        ,scountry                => rV_ROW.SCOUNTRY
                        ,sgtd                    => rV_ROW.SGTD
                        ,sarticle                => rV_ROW.SARTICLE
                        ,sgoodsparty             => rV_ROW.SGOODSPARTY
                        ,sstore                  => rV_ROW.SSTORE
                        ,nprice                  => rV_ROW.NPRICE
                        ,ndiscount               => rV_ROW.NDISCOUNT
                        ,nquant                  => rV_ROW.NQUANT
                        ,nquantalt               => rV_ROW.NQUANTALT
                        ,ncoeff                  => rV_ROW.NCOEFF
                        ,ncoeff_val_sign         => rV_ROW.NCOEFF_VAL_SIGN
                        ,ncoeff_calc_sign        => rV_ROW.NCOEFF_CALC_SIGN
                        ,npricemeas              => rV_ROW.NPRICEMEAS
                        ,nsumm                   => rV_ROW.NSUMM
                        ,nsummwithnds            => rV_ROW.NSUMMWITHNDS
                        ,nsumm_nds               => rV_ROW.NSUMM_NDS
                        ,nautocalc_sign          => rV_ROW.NAUTOCALC_SIGN
                        ,dbegindate              => rV_ROW.DBEGINDATE
                        ,denddate                => rV_ROW.DENDDATE
                        ,snote                   => rV_ROW.SNOTE
                        ,smsg                    => sVarchar
                        ,nsumm_base_delta        => nNumber
                        ,nsummwithnds_base_delta => nNumber
                        ,nsumm_payacc            => nNumber
                        ,nsummwithnds_payacc     => nNumber
                        ,nflag_del_calc          => nFLAG_DEL_CALC);

  end PAYACCSPECS_UPDATE;
  --#########################################################################################################

  procedure PAYACCSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in payaccspecs%rowtype
  ) 
  is
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    p_payaccspecs_base_update(ncompany                => rROW.COMPANY
                             ,nrn                     => rROW.RN
                             ,ntaxgr                  => rROW.TAXGR
                             ,nnommodif               => rROW.NOMMODIF
                             ,nnomnmodifpack          => rROW.NOMNMODIFPACK
                             ,narticle                => rROW.ARTICLE
                             ,ngoodsparty             => rROW.GOODSPARTY
                             ,nstore                  => rROW.STORE
                             ,nprice                  => rROW.PRICE
                             ,ndiscount               => rROW.DISCOUNT
                             ,nquant                  => rROW.QUANT
                             ,nquantalt               => rROW.QUANTALT
                             ,ncoeff                  => rROW.COEFF
                             ,ncoeff_val_sign         => rROW.COEFF_VAL_SIGN
                             ,ncoeff_calc_sign        => rROW.COEFF_CALC_SIGN
                             ,npricemeas              => rROW.PRICEMEAS
                             ,nsumm                   => rROW.SUMM
                             ,nsummwithnds            => rROW.SUMMWITHNDS
                             ,nsumm_nds               => rROW.SUMM_NDS
                             ,nautocalc_sign          => rROW.AUTOCALC_SIGN
                             ,dbegindate              => rROW.BEGINDATE
                             ,denddate                => rROW.ENDDATE
                             ,snote                   => rROW.NOTE
                             ,nsign_warn              => sVarchar
                             ,nsumm_base_delta        => nNumber
                             ,nsummwithnds_base_delta => nNumber
                             ,nsumm_payacc            => nNumber
                             ,nsummwithnds_payacc     => nNumber);

  end PAYACCSPECS_BASE_UPDATE;
  --#########################################################################################################  


end USR_PKG_PAYACC;
/
