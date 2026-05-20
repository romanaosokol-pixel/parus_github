create or replace package USR_PKG_SHEEPDIRSCUST is
  /*
  Package предназначен для работы с разделом "Распоряжения на отгрузку потребителям".
  SheepDirectToConsumers        SDC
  SheepDirectToConsumersSpecs   SDCS
  SheepDirectToConsumersCalcs   SDCSС
  */
  --#########################################################################################################

  function SHEEPDIRSCUST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   NRN       in number
  ) 
  return SHEEPDIRSCUST%ROWTYPE;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BPROCESS
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) ;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_APROCESS
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_ACLOSE
  /*
  Заголовок. Проверка после закрытия
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_AMAKEINV
  /*
  Заголовок. Проверка после формирования РН потребителям
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_CHECK_TIC
  /*
  Заголовок. Проверка соответствия полей с накладной потребителям
  */
  (
   nRN       in number
  ,nTIC      in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW           in sheepdirscust%rowtype
  ,nRESERV_SIGN   in number
  ,nRN            out number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW           in sheepdirscust%rowtype
  );
  --#########################################################################################################

  function SHEEPDIRSCUSTSPECS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   NRN      in number -- RN записи
  ) 
  return sheepdirscustspecs%rowtype;
  --#########################################################################################################
  
  PROCEDURE SHEEPDIRSCUSTSPECS_GET_BY_PRM
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,NGOODSPARTY        IN NUMBER   DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT SHEEPDIRSCUSTSPECS%ROWTYPE 
  );
  --#########################################################################################################
  
  procedure SHEEPDIRCS_GET_OUT_DOC_EXEC
  /*
  Спецификация. Получить остаток и исполнение по выходным документам
  */
  (
   RROW         in sheepdirscustspecs%rowtype
  ,NQUANT_EXEC  out number /* результат: количество на которое сформированы документы */
  ,NQUANT_REST  out number /* результат: количество на которое НЕ сформированы документы */
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW           in sheepdirscustspecs%rowtype
  ,nRN            out number
  );
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW           in sheepdirscustspecs%rowtype
  ); 
  --#########################################################################################################

  procedure SHEEPDIRCS_SEPAR_BY_ARTICLE
  /*
  Спецификация. Разделить спецификацию на несколько по заданному периоду заводских номеров
  */
  (
   nRN              in number
  ,sARTICLE_FROM    in varchar2
  ,sARTICLE_TO      in varchar2
  );
  --#########################################################################################################

  function SHPDIRCUSTCLC_GET
  /*
  Калькуляция. Считывание записи
  */
  (
   NRN      in number -- RN записи
  ) 
  return shpdircustclc%rowtype;
  --#########################################################################################################

  procedure SHPDIRCUSTCLC_BASE_INSERT
  /*
  Калькуляция. Добавление базовое
  */
  (
   rROW           in shpdircustclc%rowtype
  ,nRN            out number
  );
  --#########################################################################################################

  procedure SHPDIRCUSTCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление базовое
  */
  (
   rROW           in shpdircustclc%rowtype
  );
  --#########################################################################################################

end USR_PKG_SHEEPDIRSCUST;
/
create or replace package body USR_PKG_SHEEPDIRSCUST is

  --#########################################################################################################

  function SHEEPDIRSCUST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return sheepdirscust%rowtype
  is
    rRow sheepdirscust%rowtype;
  begin
    begin
      select * into rRow from sheepdirscust where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'SHEEPDIRSCUST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'SHEEPDIRSCUST')));
    end;
    return(rRow);
  end SHEEPDIRSCUST_GET;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    sheepdirscust_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* По спецификациям */
    for c in (select * from sheepdirscustspecs where prn = nRN) 
    loop
      /* проверка спецификации */
      sheepdirscustspecs_ainsert(nrn => nRN, ncompany => nCOMPANY);
    end loop;

  end SHEEPDIRSCUST_AINSERT;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_BUPDATE;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    sheepdirscust_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end SHEEPDIRSCUST_AUPDATE;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_BDELETE;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_BMOVE_IN;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
  begin
    null;
  end SHEEPDIRSCUST_BMOVE_OUT;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BPROCESS
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_BPROCESS;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_APROCESS
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    nDicNomns             pkg_std.tref; 
    rDicNomns             dicnomns%rowtype;
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    sheepdirscust_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* По спецификациям */
    for c in (select * from sheepdirscustspecs where prn = nRN)
    loop
      /* Номенклатура */
      nDicNomns := usr_pkg_dicnomns.nommodif_get_prn_by_rn(nflagsmart => 0, nrn => c.nommodif);
      rDicNomns := usr_pkg_dicnomns.dicnomns_get(nrn => nDicNomns);
      
      /* базовая проверка */
      sheepdirscustspecs_check_base(nrn => c.rn, ncompany => c.company);

      /* Если учёт по серийным номерам и не задано изделие */
      if rDicNomns.sign_serial = 1 and c.article is null then
        p_exception(0, 'В спецификации не указано изделие. %s%s.'
                   ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumersSpecs', ndocument => c.rn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => c.prn)); 
      end if;
    end loop;
    
  end SHEEPDIRSCUST_APROCESS;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_ACANCEL;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_ACLOSE
  /*
  Заголовок. Проверка после закрытия
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_ACLOSE;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_AMAKEINV
  /*
  Заголовок. Проверка после формирования РН потребителям
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    nTIC          pkg_std.tref; 
    nQuant_Rest   pkg_std.tquant; 
    
    nNumber       pkg_std.tnumber; 
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

  end SHEEPDIRSCUST_AMAKEINV;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUST_CHECK_BASE;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_CHECK_TIC
  /*
  Заголовок. Проверка соответствия полей с накладной потребителям
  */
  (
   nRN       in number
  ,nTIC      in number
  ) 
  is
    rRow         sheepdirscust%rowtype;
    rTIC         transinvcust%rowtype; 
    nQuant_Rest  pkg_std.tquant; 
    
    nNumber      pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := sheepdirscust_get(nrn => nRN);
    rTIC := usr_pkg_transinvcust.transinvcust_get(nrn => nTIC); 

    /* Ответственный */
    if cmp_num(rRow.acc_agent, rTIC.acc_agent) != 1 then
      p_exception(0, 'Разные Ответственые в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.acc_agent)
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rTIC.acc_agent)
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Подразделение */
    if cmp_num(rRow.subdiv, rTIC.subdiv) != 1 then
      p_exception(0, 'Разные Подразделения в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rRow.subdiv)
                 ,usr_pkg_ins_department.ins_department_get_code_by_rn(nflagsmart => 1, nrn => rTIC.subdiv)
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Контрагент */
    if cmp_num(rRow.agent, rTIC.agent) != 1 then
      p_exception(0, 'Разные Контрагенты в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.agent)
                 ,get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rTIC.agent)
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Лицевой счёт */
    if cmp_num(rRow.faceacc, rTIC.faceacc) != 1 then
      p_exception(0, 'Разные Лицевые счета в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                 ,get_faceacc_numb_id(nflag_smart => 1, nrn => rTIC.faceacc)
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Склад */
    if cmp_num(rRow.store, rTIC.store) != 1 then
      p_exception(0, 'Разные Склады в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,f_dicstore_get_numb(nstore => rRow.store)
                 ,f_dicstore_get_numb(nstore => rTIC.store)
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Валюта */
    if cmp_num(rRow.currency, rTIC.currency) != 1 then
      p_exception(0, 'Разные Валюты в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,f_dicstore_get_numb(nstore => rRow.store)
                 ,f_dicstore_get_numb(nstore => rTIC.store)
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Складская операция */
    if cmp_num(rRow.stoper, rTIC.stoper) != 1 then
      p_exception(0, 'Разные Складские операции в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,rRow.stoper
                 ,rTIC.stoper
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Сумма с налогами */
    if cmp_num(rRow.summwithnds, rTIC.summwithnds) != 1 then
      p_exception(0, 'Разные Суммы с налогами в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,rRow.summwithnds
                 ,rTIC.summwithnds
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    /* Сумма с налогами */
    if cmp_num(rRow.summ, rTIC.summ) != 1 then
      p_exception(0, 'Разные Суммы без налогов в Распоряжении на отгрузку <%s> и Расходной накладной потребителям <%s>. %s.'
                 ,rRow.summ
                 ,rTIC.summ
                 ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rRow.rn)); 
    end if;
    
    /* По спецификациям  */
    for c in (select * from sheepdirscustspecs where prn = rRow.rn) 
    loop
      /* определение количества, по которому НЕ сформированы документы */
      sheepdircs_get_out_doc_exec(rrow => c, nquant_exec => nNumber, nquant_rest => nQuant_Rest);

      /* если это количество не равно нулю */
      if nQuant_Rest != 0 then
        p_exception(0, 'Спецификация Распоряжения не полностью исполнена по сформированным Расходным накладным потребителям. %s%s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumersSpecs', ndocument => c.rn)
                   ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => c.prn));
      end if; 
    end loop;

  end SHEEPDIRSCUST_CHECK_TIC;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW           in sheepdirscust%rowtype
  ,nRESERV_SIGN   in number
  ,nRN            out number
  ) 
  is
  begin
    p_sheepdirscust_base_insert(ncompany       => rROW.COMPANY
                               ,ncrn           => rROW.CRN
                               ,njur_pers      => rROW.JUR_PERS
                               ,ndoctype       => rROW.DOCTYPE
                               ,spref          => rROW.PREF
                               ,snumb          => rROW.NUMB
                               ,ddocdate       => rROW.DOCDATE
                               ,nauto_curcours => rROW.AUTO_CURCOURS
                               ,dsaledate      => rROW.SALEDATE
                               ,nstore         => rROW.STORE
                               ,ndirector      => rROW.DIRECTOR
                               ,nfaceacc       => rROW.FACEACC
                               ,ngraphpoint    => rROW.GRAPHPOINT
                               ,nagent         => rROW.AGENT
                               ,nstoper        => rROW.STOPER
                               ,nsheepview     => rROW.SHEEPVIEW
                               ,npaytype       => rROW.PAYTYPE
                               ,ntarif         => rROW.TARIF
                               ,ncurrency      => rROW.CURRENCY
                               ,ncurcours      => rROW.CURCOURS
                               ,ncurbase       => rROW.CURBASE
                               ,nfa_cours      => rROW.FA_COURS
                               ,nfa_basecours  => rROW.FA_BASECOURS
                               ,ndiscount      => rROW.DISCOUNT
                               ,nsumm          => rROW.SUMM
                               ,nsummwithnds   => rROW.SUMMWITHNDS
                               ,nsheepsumm     => rROW.SHEEPSUMM
                               ,scomments      => rROW.COMMENTS
                               ,nreserv_sign   => nRESERV_SIGN
                               ,nacc_agent     => rROW.ACC_AGENT
                               ,nsubdiv        => rROW.SUBDIV
                               ,sbarcode       => rROW.BARCODE
                               ,nrn            => nRN);
  end SHEEPDIRSCUST_BASE_INSERT;
  --#########################################################################################################

  procedure SHEEPDIRSCUST_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW           in sheepdirscust%rowtype
  ) 
  is
  begin
    p_sheepdirscust_base_update(nrn            => rROW.RN
                               ,ncompany       => rROW.COMPANY
                               ,njur_pers      => rROW.JUR_PERS
                               ,ndoctype       => rROW.DOCTYPE
                               ,spref          => rROW.PREF
                               ,snumb          => rROW.NUMB
                               ,ddocdate       => rROW.DOCDATE
                               ,nauto_curcours => rROW.AUTO_CURCOURS
                               ,dsaledate      => rROW.SALEDATE
                               ,nstore         => rROW.STORE
                               ,ndirector      => rROW.DIRECTOR
                               ,nfaceacc       => rROW.FACEACC
                               ,ngraphpoint    => rROW.GRAPHPOINT
                               ,nagent         => rROW.AGENT
                               ,nstoper        => rROW.STOPER
                               ,nsheepview     => rROW.SHEEPVIEW
                               ,npaytype       => rROW.PAYTYPE
                               ,ntarif         => rROW.TARIF
                               ,ncurrency      => rROW.CURRENCY
                               ,ncurcours      => rROW.CURCOURS
                               ,ncurbase       => rROW.CURBASE
                               ,nfa_cours      => rROW.FA_COURS
                               ,nfa_basecours  => rROW.FA_BASECOURS
                               ,ndiscount      => rROW.DISCOUNT
                               ,nsumm          => rROW.SUMM
                               ,nsummwithnds   => rROW.SUMMWITHNDS
                               ,nsheepsumm     => rROW.SHEEPSUMM
                               ,scomments      => rROW.COMMENTS
                               ,nacc_agent     => rROW.ACC_AGENT
                               ,nsubdiv        => rROW.SUBDIV
                               ,sbarcode       => rROW.BARCODE);
  end SHEEPDIRSCUST_BASE_UPDATE;
  --#########################################################################################################

  function SHEEPDIRSCUSTSPECS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   NRN      in number -- RN записи
  ) 
  return sheepdirscustspecs%rowtype
  is
    rRow sheepdirscustspecs%rowtype;
  begin
    begin
      select * into rRow from sheepdirscustspecs where rn = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'SHEEPDIRSCUSTSPECS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'SHEEPDIRSCUSTSPECS')));
    end;
    return(rRow);
  end SHEEPDIRSCUSTSPECS_GET;
  --#########################################################################################################
  
  PROCEDURE SHEEPDIRSCUSTSPECS_GET_BY_PRM
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,NGOODSPARTY        IN NUMBER   DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT SHEEPDIRSCUSTSPECS%ROWTYPE 
  ) 
  is
    sMessage          pkg_std.tstring; 
    rV_GoodsParties   v_goodsparties%rowtype;

    sVarchar          pkg_std.tstring; 
  BEGIN
    BEGIN
      SELECT *
        INTO rRow
        FROM SHEEPDIRSCUSTSPECS T
       WHERE T.PRN                    = NPRN
         AND (NVL(T.NOMMODIF, 0)      = NVL(NNOMMODIF, 0) OR (NNOMMODIF IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMNMODIFPACK, 0) = NVL(NNOMMODIFPACK, 0) OR (NNOMMODIFPACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.TAXGR, 0)         = NVL(NTAXGR, 0) OR (NTAXGR IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANT, 0)         = NVL(NQUANT, 0) OR (NQUANT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANTALT, 0)      = NVL(NQUANTALT, 0) OR (NQUANTALT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.PRICE, 0)         = NVL(NPRICE, 0) OR (NPRICE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.ARTICLE, 0)       = NVL(NARTICLE, 0) OR (NARTICLE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.GOODSPARTY, 0)    = NVL(NGOODSPARTY, 0) OR (NGOODSPARTY IS NULL AND NFLAG_OPTION = 1))
         AND ((T.BEGINDATE = DBEGINDATE OR (T.BEGINDATE IS NULL AND DBEGINDATE IS NULL)) OR (DBEGINDATE IS NULL AND NFLAG_OPTION = 1))
         AND ((T.ENDDATE   = DENDDATE   OR (T.ENDDATE   IS NULL AND DENDDATE   IS NULL)) OR (DENDDATE   IS NULL AND NFLAG_OPTION = 1))
         ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF NFLAGSMART = 0 then
          sMessage := cr||'RN заголовка: '||NPRN;
          sMessage := strcombine(sMessage, usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => NNOMMODIF), CR||'Модификация: ');
          find_dictaxgr_rn(nflag_smart  => 1
                          ,nflag_option => 1
                          ,ncompany     => 90521
                          ,nrn          => NTAXGR
                          ,scode        => sVarchar);
          sMessage := strcombine(sMessage, sVarchar, CR||'Налоговая группа: ');
          sMessage := strcombine(sMessage, NQUANT, CR||'Количество: ');
          sMessage := strcombine(sMessage, NPRICE, CR||'Цена: ');
          sMessage := strcombine(sMessage, f_rlarticles_get_code(narticle => NARTICLE), cr||'Изделие: ');
          select * into rV_GoodsParties from v_goodsparties where nrn = NGOODSPARTY;
          sMessage := strcombine(sMessage, rV_GoodsParties.scode||', '||rV_GoodsParties.ssernumb , CR||'Партия, серия: ');
          sMessage := strcombine(sMessage, decode_date(ddate => DBEGINDATE), CR||'Дата начала: ');
          sMessage := strcombine(sMessage, decode_date(ddate => DENDDATE), CR||'Дата окончания: ');
          P_EXCEPTION(0 ,'Не найдено спецификации с параметрами: %s в разделе %s'
                     ,sMessage, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'SHEEPDIRSCUSTSPECS')));
        END IF;
      WHEN TOO_MANY_ROWS THEN
        IF NTOO_MANY_ROWS = 0 AND NFLAGSMART = 0 THEN
          P_EXCEPTION(0, 'Найдено больше одной спецификации для заголовка с RN <%s> записи в разделе <%s>'
                     ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'SHEEPDIRSCUSTSPECS')));
        END IF;
      WHEN OTHERS THEN
        P_EXCEPTION(0, 'Неопределённая ситуация при поиске спецификации для заголовка с RN <%s> записи в разделе <%s>'
                   ,NPRN, F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'SHEEPDIRSCUSTSPECS')));
    END;
  END SHEEPDIRSCUSTSPECS_GET_BY_PRM;
  --#########################################################################################################
  
  procedure SHEEPDIRCS_GET_OUT_DOC_EXEC
  /*
  Спецификация. Получить остаток и исполнение по выходным документам (пока считаем только количество)
  */
  (
   RROW         in sheepdirscustspecs%rowtype
  ,NQUANT_EXEC  out number /* результат: количество на которое сформированы документы */
  ,NQUANT_REST  out number /* результат: количество на которое НЕ сформированы документы */
  ) 
  is
    NCALC_WAY     pkg_std.tnumber := 0; /* возвращать: 0 - количество, 1 - сумму */
    NSUM_EXEC     pkg_std.tnumber;      /* результат: сумма на которую сформированы документы */
    NSUM_REST     pkg_std.tnumber;      /* результат: сумма на которую НЕ сформированы документы */

    nIdent        pkg_std.tref := RROW.RN;
    nDicNomns     pkg_std.tref; 
    rDicNomns     dicnomns%rowtype;
    rHead         sheepdirscust%rowtype;
    nQuant        pkg_std.tquant;
    nSumTax       pkg_std.tsumm;  /*сумма с налогами */

    nNumber       pkg_std.tnumber;
  begin
    /* Считывание */
    rHead     := sheepdirscust_get(nrn => RROW.PRN);
    /* Номенклатура RN */
    nDicNomns := usr_pkg_dicnomns.nommodif_get_prn_by_rn(nflagsmart => 0, nrn => RROW.NOMMODIF);
    /* Номенклатура запись */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get(nrn => nDicNomns); 
  
    /* использование пакета PKG_GOODSDOCS_SPEC */
    pkg_goodsdocs_spec_crm.init(ncompany => RROW.COMPANY, nident => nIdent);
    /* добавление в массив текущей спецификации */
    pkg_goodsdocs_spec_crm.add_spec(nident         => nIdent
                                   ,ndocument      => rHead.rn
                                   ,sunitcode      => 'SheepDirectToConsumers'
                                   ,ndocument1     => RROW.RN
                                   ,sunitcode1     => 'SheepDirectToConsumersSpecs'
                                   ,nnomencls      => null 
                                   ,numeas_main    => null 
                                   ,nnomen         => rDicNomns.rn
                                   ,nnomnpack      => null 
                                   ,nnommodif      => RROW.NOMMODIF
                                   ,nnomnmodifpack => RROW.NOMNMODIFPACK
                                   ,narticle       => RROW.ARTICLE
                                   ,nstore         => case rDicNomns.nomen_type when 2 then null else rHead.store end /* если услуга, то склад не подставляем */
                                   ,ngoodsparty    => RROW.GOODSPARTY
                                   ,ssernumb       => null 
                                   ,ncountry       => null 
                                   ,sgtd           => null 
                                   ,nquant         => RROW.QUANT
                                   ,nsumm          => null 
                                   ,ncurrency      => null 
                                   ,ncurcours      => null 
                                   ,ncurbase       => null);
    /* вычитание из исходной спецификации спецификаций всех порожденных документов */
    pkg_goodsdocs_spec_crm.sub_cons_out_spec(nident    => nIdent
                                            ,ndocument => rHead.rn
                                            ,sunitcode => 'SheepDirectToConsumers'
                                            ,ncalc_way => 0); /* здесь пока рассчет только по кол-ву */
    /* вычисление количества */
    pkg_goodsdocs_spec_crm.get_spec(nident    => nIdent
                                   ,nquant    => nQuant
                                   ,nsumm     => nSumTax 
                                   ,nmod_sign => nNumber);
    /* Результат */
    case NCALC_WAY
      /* количество */
      when 0 then
        NQUANT_REST := nQuant;
        NQUANT_EXEC := rRow.quant - nQUANT;
      /* сумма */
      /*when 1 then
        NSUM_REST := nSumTax;
        NSUM_EXEC := rRow.summwithnds - nSumTax;*/
      else
        p_exception(0, 'Неверное <%s> значение параметра <nCALC_WAY>. %s%s'
                   ,nCALC_WAY
                   ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumersSpecs', ndocument => rROW.RN)
                   ,cr||f_docdescrs_get_description(sunitcode => 'SheepDirectToConsumers', ndocument => rROW.PRN));
    end case;
  
  end SHEEPDIRCS_GET_OUT_DOC_EXEC;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    sheepdirscustspecs_check_base(nrn => NRN, ncompany => NCOMPANY);

  end SHEEPDIRSCUSTSPECS_AINSERT;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUSTSPECS_BUPDATE;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    sheepdirscustspecs_check_base(nrn => NRN, ncompany => NCOMPANY);

  end SHEEPDIRSCUSTSPECS_AUPDATE;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end SHEEPDIRSCUSTSPECS_BDELETE;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
   rRow             sheepdirscustspecs%rowtype;
   rHead            sheepdirscust%rowtype;
   rFcAcOperPlans   fcacoperplans%rowtype;
   nContracts       pkg_std.tref; 
   rContracts       contracts%rowtype;
   
   sVarchar         pkg_std.tstring; 
   nNumber          pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow  := sheepdirscustspecs_get(nrn => nRN);
    rHead := sheepdirscust_get(nrn => rRow.prn);
    find_contracts_faceacc(nflag_smart  => 0
                          ,ncompany     => rHead.company
                          ,nfaceacc     => rHead.faceacc
                          ,sfaceacc     => null
                          ,ncontract    => null
                          ,ncontractout => nContracts
                          ,sdoc_type    => sVarchar
                          ,sdoc_pref    => sVarchar
                          ,sdoc_numb    => sVarchar
                          ,ddoc_date    => sVarchar
                          ,nstage       => nNumber
                          ,sstagenumb   => sVarchar
                          ,sfaceaccout  => sVarchar);
    rContracts := usr_pkg_contracts.contracts_get(nrn => nContracts);

    /* Если договор не Условный */
    if rContracts.false_doc = 0 then
      /* Поиск аналогичной записи в графике отпуска ЛС */
      usr_pkg_faceacc.fcacoperplans_get_by_params(ntoo_many_rows => 1
                                                 ,nprn           => rHead.faceacc
                                                 ,ninexp_sign    => 1
                                                 ,nnommodif      => rRow.nommodif
                                                 ,ntaxgr         => rRow.taxgr
                                                 ,rrow           => rFcAcOperPlans);
    end if;    
  end SHEEPDIRSCUSTSPECS_CHECK_BASE;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW           in sheepdirscustspecs%rowtype
  ,nRN            out number
  ) 
  is
  begin
    p_sheepdirscustsp_base_insert(ncompany         => rROW.COMPANY
                                 ,nprn             => rROW.PRN
                                 ,ntaxgr           => rROW.TAXGR
                                 ,ngoodsparty      => rROW.GOODSPARTY
                                 ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                 ,nnommodif        => rROW.NOMMODIF
                                 ,narticle         => rROW.ARTICLE
                                 ,ncell            => rROW.CELL
                                 ,nprice           => rROW.PRICE
                                 ,ndiscount        => rROW.DISCOUNT
                                 ,nquant           => rROW.QUANT
                                 ,nquantalt        => rROW.QUANTALT
                                 ,ncoeff           => rROW.COEFF
                                 ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                 ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                 ,npricemeas       => rROW.PRICEMEAS
                                 ,nsumm            => rROW.SUMM
                                 ,nsummwithnds     => rROW.SUMMWITHNDS
                                 ,nsumm_nds        => rROW.SUMM_NDS
                                 ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                 ,dbegindate       => rROW.BEGINDATE
                                 ,denddate         => rROW.ENDDATE
                                 ,snote            => rROW.NOTE
                                 ,nrn              => nRN);
  end SHEEPDIRSCUSTSPECS_BASE_INSERT;
  --#########################################################################################################

  procedure SHEEPDIRSCUSTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW           in sheepdirscustspecs%rowtype
  ) 
  is
  begin
    p_sheepdirscustsp_base_update(nrn              => rROW.RN
                                 ,ncompany         => rROW.COMPANY
                                 ,ntaxgr           => rROW.TAXGR
                                 ,ngoodsparty      => rROW.GOODSPARTY
                                 ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                 ,nnommodif        => rROW.NOMMODIF
                                 ,narticle         => rROW.ARTICLE
                                 ,ncell            => rROW.CELL
                                 ,nprice           => rROW.PRICE
                                 ,ndiscount        => rROW.DISCOUNT
                                 ,nquant           => rROW.QUANT
                                 ,nquantalt        => rROW.QUANTALT
                                 ,ncoeff           => rROW.COEFF
                                 ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                 ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                 ,npricemeas       => rROW.PRICEMEAS
                                 ,nsumm            => rROW.SUMM
                                 ,nsummwithnds     => rROW.SUMMWITHNDS
                                 ,nsumm_nds        => rROW.SUMM_NDS
                                 ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                 ,dbegindate       => rROW.BEGINDATE
                                 ,denddate         => rROW.ENDDATE
                                 ,snote            => rROW.NOTE);
  end SHEEPDIRSCUSTSPECS_BASE_UPDATE;
  --#########################################################################################################

  procedure SHEEPDIRCS_SEPAR_BY_ARTICLE
  /*
  Спецификация. Разделить спецификацию на несколько по заданному периоду заводских номеров
  */
  (
   nRN              in number
  ,sARTICLE_FROM    in varchar2
  ,sARTICLE_TO      in varchar2
  )
  is
    nArticle_From     pkg_std.tquant;
    nArticle_To       pkg_std.tquant;
    rRow              sheepdirscustspecs%rowtype;
    rHead             sheepdirscust%rowtype;
    rRow_New          sheepdirscustspecs%rowtype;
    rNomModif         nommodif%rowtype;
    sDicNomns         dicnomns.nomen_code%type;
    nArticle          pkg_std.tref; 
    nArticlesSupply   pkg_std.tref; 
    nGoodsSupply      pkg_std.tref; 
    rGoodsSupply      GoodsSupply%rowtype;

    nNumber   pkg_std.tnumber;   
  begin
    /* Считывание */
    rRow  := sheepdirscustspecs_get(nrn => nRN);
    rHead := sheepdirscust_get(nrn => rRow.prn);
    /* Мнемокод номенклатуры */
    rNomModif := usr_pkg_dicnomns.nommodif_get(nrn => rRow.nommodif);
    sDicNomns := get_dicnomns_code_id(nflag_smart => 0, nrn => rNomModif.prn);

    /* Проверки параметров */
    /* типы */
    begin
      nArticle_From := to_number(sARTICLE_FROM);
    exception
      when others then
        p_exception(0, 'Неверное значение <%s> параметра <%s>. %s%s'
                   ,sARTICLE_FROM
                   ,'sARTICLE_FROM'
                   ,cr||f_docdescrs_get_description('SheepDirectToConsumersSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('SheepDirectToConsumers', rRow.prn));
    end;
    begin
      nArticle_To := to_number(sARTICLE_TO);
    exception
      when others then
        p_exception(0, 'Неверное значение <%s> параметра <%s>. %s%s'
                   ,sARTICLE_TO
                   ,'sARTICLE_TO'
                   ,cr||f_docdescrs_get_description('SheepDirectToConsumersSpecs', rRow.rn)
                   ,cr||f_docdescrs_get_description('SheepDirectToConsumers', rRow.prn));
    end;
    /* на отрицательный диапазон */
    if nArticle_To - nArticle_From < 0  then
      p_exception(0, 'Отрицательный диапазон в параметрах с <%s> по <%s>. %s%s'
                 ,nArticle_From
                 ,nArticle_To
                 ,cr||f_docdescrs_get_description('SheepDirectToConsumersSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('SheepDirectToConsumers', rRow.prn));
    end if;
    /* количество в диапазоне больше количества в спецификации */
    if nArticle_To - nArticle_From > rrow.quant  then
      p_exception(0, 'Количество в диапазоне заводских номеров <%s> больше количества в спецификации <%s>. %s%s'
                 ,nArticle_To - nArticle_From
                 ,rrow.quant
                 ,cr||f_docdescrs_get_description('SheepDirectToConsumersSpecs', rRow.rn)
                 ,cr||f_docdescrs_get_description('SheepDirectToConsumers', rRow.prn));
    end if;
      
    /* Копирование строки спецификации в переменную для новых строк */
    rRow_New := rRow;

    /* По диапазону номеров */
    for a in nArticle_From .. nArticle_To
    loop
      /* поиск изделия */
      usr_pkg_rlarticles.rlarticles_get_by_nommodif(nflagsmart => 0
                                                   ,scode      => sDicNomns||'_'||lpad(a, 3, 0)
                                                   ,nnommodif  => rNomModif.rn
                                                   ,nrn        => nArticle);
      /* поиск товарного запаса изделия */
      find_articlessupply_by_article(nflag_smart  => 1
                                    ,nflag_option => 0
                                    ,ncompany     => rRow.company
                                    ,narticle     => nArticle
                                    ,sarticle     => null
                                    ,nrn          => nArticlesSupply
                                    ,nship_plan   => nNumber);
      /* поиск товарного запаса */
      usr_pkg_goodsparties.goodssupply_get_by_gssa(nflagsmart => 1
                                                  ,ngssa      => nArticlesSupply
                                                  ,ncompany   => rRow.company
                                                  ,nrn        => nGoodsSupply);
      /* если товарный запас найден */
      if nGoodsSupply is not null then
        /* считывание записи товарного запаса */
        rGoodsSupply := usr_pkg_goodsparties.goodssupply_get(nrn => nGoodsSupply);

        /* если склад товарного запаса равен складу заголовка */
        if cmp_num(rGoodsSupply.store, rHead.store) = 1 then
          /* подмена параметров, добавление */
          rRow_New.article     := nArticle;
          rRow_New.quant       := 1;
          rRow_New.summ        := rRow.summ / rRow.quant;
          rRow_New.summwithnds := rRow.summwithnds / rRow.quant;
          rRow_New.summ_nds    := rRow.summ_nds / rRow.quant;
          sheepdirscustspecs_base_insert(rrow => rRow_New, nrn => nNumber);
          /* вычитание из текущей спецификации */
          rRow.quant       := rRow.quant       - rRow_New.quant;
          rRow.summ        := rRow.summ        - rRow_New.summ;
          rRow.summwithnds := rRow.summwithnds - rRow_New.summwithnds;
          rRow.summ_nds    := rRow.summ_nds    - rRow_New.summ_nds;
        end if;

      end if;
    end loop;

    /* Если осталось ещё количество в текущей спецификации */
    if rRow.quant != 0 then 
      /* исправляем */
      sheepdirscustspecs_base_update(rrow => rRow);
    else 
      /* удаляем */
      p_sheepdirscustsp_base_delete(ncompany => rRow.company, nrn => rRow.rn);
    end if;

  end SHEEPDIRCS_SEPAR_BY_ARTICLE;
  --#########################################################################################################

  function SHPDIRCUSTCLC_GET
  /*
  Калькуляция. Считывание записи
  */
  (
   NRN      in number -- RN записи
  ) 
  return shpdircustclc%rowtype
  is
    rRow shpdircustclc%rowtype;
  begin
    begin
      select * into rRow from shpdircustclc where rn = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'SHPDIRCUSTCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'SHPDIRCUSTCLC')));
    end;
    return(rRow);
  end SHPDIRCUSTCLC_GET;
  --#########################################################################################################

  procedure SHPDIRCUSTCLC_BASE_INSERT
  /*
  Калькуляция. Добавление базовое
  */
  (
   rROW           in shpdircustclc%rowtype
  ,nRN            out number
  ) 
  is
  begin
    p_shpdircustclc_base_insert(ncompany      => rROW.COMPANY
                               ,nprn          => rROW.PRN
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,ncost_plan    => rROW.COST_PLAN
                               ,ncost_fact    => rROW.COST_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nquant_plan   => rROW.QUANT_PLAN
                               ,nquant_fact   => rROW.QUANT_FACT
                               ,nsubdiv       => rROW.SUBDIV
                               ,nrn           => nRN);
  end SHPDIRCUSTCLC_BASE_INSERT;
  --#########################################################################################################

  procedure SHPDIRCUSTCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление базовое
  */
  (
   rROW           in shpdircustclc%rowtype
  ) 
  is
  begin
    p_shpdircustclc_base_update(nrn           => rROW.RN
                               ,ncompany      => rROW.COMPANY
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,ncost_plan    => rROW.COST_PLAN
                               ,ncost_fact    => rROW.COST_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nquant_plan   => rROW.QUANT_PLAN
                               ,nquant_fact   => rROW.QUANT_FACT
                               ,nsubdiv       => rROW.SUBDIV);

  end SHPDIRCUSTCLC_BASE_UPDATE;
  --#########################################################################################################

end USR_PKG_SHEEPDIRSCUST;
/
