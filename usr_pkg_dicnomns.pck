create or replace package USR_PKG_DICNOMNS is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Номенклатор". 
  Nomenclator              DNM
  NomenclatorModification  NMD
  */
  /*#########################################################################################################*/

  function DICNOMNS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return DICNOMNS%rowtype;
  /*#########################################################################################################*/

  function GET_MU_SIZE_BY_VAL
  /*
  Функция. Определяет код единицы измерениня размера по номеру
  */
  ( 
   nVALUE in number
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function GET_MU_WEIGHT_BY_VAL
  /*
  Функция. Определяет код единицы измерениня веса по номеру
  */
  (
   nVALUE in number
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function GET_MU_SIZE_BY_CODE
  /*
  Функция. Определяет номер единицы измерениня размера по коду
  */
  (
   sCODE    in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  function GET_MU_WEIGHT_BY_CODE
  /*
  Функция. Определяет номер единицы измерениня веса по коду
  */
  (
   sCODE    in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  procedure DICNOMNS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_BNOMEN_MOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_ANOMEN_MOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_BNOMEN_MOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_ANOMEN_MOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_CHECK_NAME
  /*
  Заголовок. Проверка мнемокора наименования
  */
  (
   nFLAGSMART in number default 0
  ,nRN        in number
  ,nCOMPANY   in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_INSERT
  /*
  Заголовок. Клиентское добавление
  */
  (
   rV_ROW         in v_dicnomns%rowtype
  ,nCOMPANY       in number
  ,nRN_DUP        in number default null
  ,nAUTOADDMODIF  in number default 0
  ,nRN            out number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_UPDATE
  /*
  Заголовок. Клиентское исправление
  */
  (
   rV_ROW         in v_dicnomns%rowtype
  ,nCOMPANY       in number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW           in dicnomns%rowtype
  ,nCOMPANY       in number
  ,nRN_DUP        in number default null
  ,nAUTOADDMODIF  in number
  ,nRN            out number
  );
  /*#########################################################################################################*/

  procedure DICNOMNS_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in dicnomns%rowtype
  ,nCOMPANY     in number
  );
  /*#########################################################################################################*/

  function NOMMODIF_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return NOMMODIF %ROWTYPE;
  /*#########################################################################################################*/

  function NOMMODIF_GET_CODE_BY_RN
  /*
  Спецификация. Поиск мнемокода по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function NOMMODIF_GET_PRN_BY_RN
  /*
  Спецификация. Поиск RN номенклатуры по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ) 
  return number;
  /*#########################################################################################################*/

  procedure NOMMODIF_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_CHECK_NAME
  /*
  Спецификация. Проверка мнемокора наименования
  */
  (
   nFLAGSMART in number default 0
  ,nRN        in number
  ,nCOMPANY   in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_BASE_INSERT
  /*
  Спецификация. Базовое добавление
  */
  (
   rROW       in nommodif%rowtype
  ,nCOMPANY   in number
  ,nPRN_DUP   in number
  ,nRN_DUP    in number
  ,nRN        out number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_BASE_UPDATE
  /*
  Спецификация. Базовое исправление
  */
  (
   rROW         in NOMMODIF%rowtype
  ,nCOMPANY     in number
  );
  /*#########################################################################################################*/

  procedure NOMMODIF_MATRES_INSERT
  /*
  Спецификация. Добавление материального ресурса
  */
  (
   nFLAGSMART in number
  ,nRN        in number
  ,nCOMPANY   in number
  ,nMATRES    out number
  );
  /*#########################################################################################################*/

end USR_PKG_DICNOMNS;
/
create or replace package body USR_PKG_DICNOMNS is

  /*#########################################################################################################*/

  function DICNOMNS_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return dicnomns%rowtype
  is
    rRow dicnomns%rowtype;
  begin
    begin
      select * into rRow from dicnomns t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART,ndocument => nRN, sunit_table => 'DICNOMNS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DICNOMNS')));
    end;
    return(rRow);
  end DICNOMNS_GET;
  /*#########################################################################################################*/

  function GET_MU_SIZE_BY_VAL
  /*
  Функция. Определяет код единицы измерениня размера по номеру
  */
  ( 
   nVALUE in number
  ) 
  return varchar2
  is
  begin
    return(case nVALUE
             when 0 then 'ММ'
             when 1 then 'СМ'
             when 2 then 'М' 
           else null
           end);
  END GET_MU_SIZE_BY_VAL;
  /*#########################################################################################################*/

  function GET_MU_WEIGHT_BY_VAL
  /*
  Функция. Определяет код единицы измерениня веса по номеру
  */
  (
   nVALUE in number
  ) 
  return varchar2
  is
  begin
    return(case nVALUE
             when 0 then 'Г'   
             when 1 then 'КГ'  
             when 2 then 'ТОНН'
           else null
           end);
  END GET_MU_WEIGHT_BY_VAL;
  /*#########################################################################################################*/

  function GET_MU_SIZE_BY_CODE
  /*
  Функция. Определяет номер единицы измерениня размера по коду
  */
  (
   sCODE    in varchar2
  ) 
  return number
  is
  begin
    return(case sCODE
             when 'ММ' then 0
             when 'СМ' then 1
             when 'М'  then 2
           else null
           end);
  END GET_MU_SIZE_BY_CODE;
  /*#########################################################################################################*/

  function GET_MU_WEIGHT_BY_CODE
  /*
  Функция. Определяет номер единицы измерениня веса по коду
  */
  (
   sCODE    in varchar2
  ) 
  return number
  is
  begin
    return(case sCODE
             when 'Г'     then 0
             when 'КГ'    then 1
             when 'ТОНН'  then 2
           else null
           end);
  END GET_MU_WEIGHT_BY_CODE;
  /*#########################################################################################################*/

  procedure DICNOMNS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            dicnomns%rowtype;
    rNomModif       nommodif%rowtype;

    sImportPropVal  docs_props_vals.str_value%type;
    sOMTSGroupVal   docs_props_vals.str_value%type;
  begin
    /* Считывание */
    rRow := dicnomns_get(nrn => nRN); 

    /* ИСПРАВЛЕНИЕ */
    /* Заполнение переменных для добавления модификации */
    rNomModif.prn            := rROW.RN;
    rNomModif.modif_code     := rROW.NOMEN_CODE;
    rNomModif.modif_name     := rROW.NOMEN_NAME;
    rNomModif.width          := rROW.WIDTH;
    rNomModif.height         := rROW.HEIGHT;
    rNomModif.length         := rROW.LENGTH;
    rNomModif.weight         := rROW.WEIGHT;
    rNomModif.mu_size        := rROW.MU_SIZE;
    rNomModif.mu_weight      := rROW.MU_WEIGHT;
    rNomModif.temp_from      := rROW.TEMP_FROM;
    rNomModif.temp_to        := rROW.TEMP_TO;
    rNomModif.humid_from     := rROW.HUMID_FROM;
    rNomModif.humid_to       := rROW.HUMID_TO;
    rNomModif.common_pr_sign := rROW.COMMON_PR_SIGN;
    rNomModif.storage_time   := rROW.STORAGE_TIME;
    rNomModif.umeas_storage  := rROW.UMEAS_STORAGE;

    /* Добавление модификации */
    nommodif_base_insert(rrow     => rNomModif
                        ,ncompany => nCOMPANY
                        ,nprn_dup => null
                        ,nrn_dup  => null
                        ,nrn      => rNomModif.rn);

    /* Проверка после добавления модификации */
    nommodif_ainsert(nrn => rNomModif.rn, ncompany => nCOMPANY);

    /* ПРОВЕРКИ */
    /* Базовая */
    dicnomns_check_base(nrn => nRN, ncompany => nCOMPANY);
    
    /* Считывание свойств "УМТС. Группа номенклатуры" и "УМТС. Импорт" */
    sImportPropVal := f_docs_props_get_str_value(nproperty => 19579336, sunitcode => 'Nomenclator', ndocument => rRow.rn);
    sOMTSGroupVal  := f_docs_props_get_str_value(nproperty => 19579777, sunitcode => 'Nomenclator', ndocument => rRow.rn);

    /* Проверка свойств */
    if  cmp_vc2(sOMTSGroupVal        , 'Импорт')  = 1 
    and cmp_vc2(upper(sImportPropVal), 'ДА'    ) != 1 then
      p_exception(0, 'В свойстве "УМТС. Группа номенклатуры" указано значение <%s>, необходимо в свойстве "УМТС. Импорт" указать значение  "Да". %s'
                 ,sOMTSGroupVal
                 ,cr||f_docdescrs_get_description(sunitcode => 'Nomenclator', ndocument => rRow.rn)); 
    end if;

  end DICNOMNS_AINSERT;
  /*#########################################################################################################*/

  procedure DICNOMNS_BUPDATE
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
    usr_pkg_pub_const.rdicnomns := dicnomns_get(nrn => nRN); 
    usr_pkg_docs_props_vals.get_vals_document_type(ndocument => nRN, apropvals => usr_pkg_pub_const.aprops);

  end DICNOMNS_BUPDATE;
  /*#########################################################################################################*/

  procedure DICNOMNS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      dicnomns%rowtype;
    aProps    usr_pkg_pub_const.tdocs_props_vals;
  begin
    /* Считывание */
    rRow := dicnomns_get(nrn => nRN); 
    usr_pkg_docs_props_vals.get_vals_document_type(ndocument => rRow.rn, apropvals => aProps);

    /* ИСПРАВЛЕНИЯ */
    /* Если свойство "УМТС_ГруппаНомен" имеет значения 'Импорт', 'Импорт1' */
    if nvl(usr_pkg_docs_props_vals.get_val_from_type_str(nproperty => 19579777, apropvals => aProps), 'null') in ('Импорт', 'Импорт1') then
      /* исправляем в массиве свойство "УМТС_Импорт" на 'Да' */
      usr_pkg_docs_props_vals.modify_val_from_type(nproperty => 19579336, sstr_value => 'Да', apropvals => aProps);
    /* Иначе */
    else      
      /* исправляем в массиве свойство "УМТС_Импорт" на null */
      usr_pkg_docs_props_vals.modify_val_from_type(nproperty => 19579336, sstr_value => null, apropvals => aProps);
    end if;

    /* Исправляем свойства значениями из массива */
    usr_pkg_docs_props_vals.modify_vals_document_type(ndocument => rRow.rn, sunitcode => 'Nomenclator', apropvals => aProps);


    /* ПРОВЕРКИ */
    /* Базовая */
    dicnomns_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */    
    usr_pkg_pub_const.rdicnomns := null;
    usr_pkg_pub_const.aprops.delete;
    
  end DICNOMNS_AUPDATE;
  /*#########################################################################################################*/

  procedure DICNOMNS_BNOMEN_MOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        dicnomns%rowtype;
    sCatalog    acatalog.name%type;
    nNumber     pkg_std.tnumber;  
  begin
    null;
  end DICNOMNS_BNOMEN_MOVE_IN;
  /*#########################################################################################################*/

  procedure DICNOMNS_ANOMEN_MOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        dicnomns%rowtype;
    sCatalog    acatalog.name%type;
    nNumber     pkg_std.tnumber;  
  begin
    /* Считывание */
    rRow     := dicnomns_get(nrn => nRN);
    /* Каталог */
    sCatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);
    
    /* ИСПРАВЛЕНИЯ */
    /* Если перемещение выполнено в каталог "НЕ ИСПОЛЬЗОВАТЬ" */
    if sCatalog = 'Я_НЕ ИСПОЛЬЗОВАТЬ (дубли)' then
      /* если у номенклатуры были признаки использовать в учёте и документах */
      if rRow.sign_acnt = 1 or rRow.sign_docs = 1 then
        /* подменяем признаки */
        rRow.sign_acnt := 0;
        rRow.sign_docs := 0;
        /* исправляем номенкатуру */
        dicnomns_base_update(rrow => rRow, ncompany => nCOMPANY);
      end if;
    else
      null;      
    end if;

  end DICNOMNS_ANOMEN_MOVE_IN;
  /*#########################################################################################################*/

  procedure DICNOMNS_BNOMEN_MOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        dicnomns%rowtype;
    sCatalog    acatalog.name%type;
    nNumber     pkg_std.tnumber;  
  begin
    /* Считывание */
    usr_pkg_pub_const.rdicnomns := dicnomns_get(nrn => nRN);
    rRow     := usr_pkg_pub_const.rdicnomns;

    /* Каталог */
    sCatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* Если перемещение выполняется из каталога "НЕ ИСПОЛЬЗОВАТЬ" */
    if sCatalog = 'Я_НЕ ИСПОЛЬЗОВАТЬ (дубли)' then
      /* если у номенклатуры нет признаков использовать в учёте и документах */
      if rRow.sign_acnt = 0 or rRow.sign_docs = 0 then
        /* подменяем признаки */
        rRow.sign_acnt := 1;
        rRow.sign_docs := 1;
        /* исправляем номенкатуру */
        dicnomns_base_update(rrow => rRow, ncompany => nCOMPANY);
      end if;
    end if;

  end DICNOMNS_BNOMEN_MOVE_OUT;
  /*#########################################################################################################*/

  procedure DICNOMNS_ANOMEN_MOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        dicnomns%rowtype;
    sCatalog    acatalog.name%type;
    nNumber     pkg_std.tnumber;  
  begin
    null;
  end DICNOMNS_ANOMEN_MOVE_OUT;
  /*#########################################################################################################*/

  procedure DICNOMNS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* По модификациям */
    for c in (
              select t.rn
                from nommodif t
               where t.prn = nRN
             )
    loop
      /* Проверка перед удалением */
      nommodif_bdelete(nrn => c.rn, ncompany => nCOMPANY);
    end loop;             

  end DICNOMNS_BDELETE;
  /*#########################################################################################################*/

  procedure DICNOMNS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow            dicnomns%rowtype;*/
  begin
    /* Заголовок */  
     /*rRow := dicnomns_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Проверка мнемокода и наименования */
    dicnomns_check_name( nrn => nRN, ncompany => nCOMPANY );

  end DICNOMNS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure DICNOMNS_CHECK_NAME
  /*
  Заголовок. Проверка мнемокора наименования
  */
  (
   nFLAGSMART in number default 0
  ,nRN        in number
  ,nCOMPANY   in number
  ) 
  is
    rRow            dicnomns%rowtype;
  begin
    /* Заголовок */  
     rRow := dicnomns_get(nrn => nRN, nflagsmart => nFLAGSMART);
     
     if  rRow.SIGN_SERIAL = 1 /*учет по серийным номерам */
         and rRow.UMEAS_ALT is null /* не задана доп. единица измерения */
     then P_Exception(0, 'Если задан признак "учет по серийным номерам", то обязательно задайте дополнительную единицу измерения!');    
     end if;    
    /* ПРОВЕРКИ */
    /* Мнемокод задан на входе */
    if rRow.nomen_code is null then
      p_exception(nFLAGSMART, 'Не задан мнемокод номенклатуры.'); 
      return;
    end if;
    /* Наименование задано на входе */
    if rRow.nomen_name is null then
      p_exception(nFLAGSMART, 'Не задано наименование номенклатуры.'); 
      return;
    end if;

    /* Проверка мнемокода без пробелов */
    for c in (
              select t.nomen_code 
                from dicnomns t 
               where t.rn != rRow.rn
                 and usr_pkg_common.get_str_normalized(sstr => t.nomen_code) = usr_pkg_common.get_str_normalized(sstr => rRow.nomen_code)
             )
    loop
      p_exception(nFLAGSMART, 'Существует номенклатура с аналогичным мнемокодом.'
                  ||cr||'Добавляемый мнемокод: <%s>'
                  ||cr||'Существующий мнемокод: <%s>'
                 ,rRow.nomen_code
                 ,c.nomen_code); 
    end loop;

    /* Проверка наименования без пробелов */
    for c in (
              select t.nomen_name
                from dicnomns t 
               where t.rn != rRow.rn
                 and usr_pkg_common.get_str_normalized(sstr => t.nomen_name) = usr_pkg_common.get_str_normalized(sstr => rRow.nomen_name)
             )
    loop
      p_exception(nFLAGSMART, 'Существует номенклатура с аналогичным наименованием.'
                  ||cr||'Добавляемое наименование: <%s>'
                  ||cr||'Существующее наименование: <%s>'
                 ,rRow.nomen_name
                 ,c.nomen_name); 
    end loop;

  end DICNOMNS_CHECK_NAME;
  /*#########################################################################################################*/

  procedure DICNOMNS_INSERT
  /*
  Заголовок. Клиентское добавление
  */
  (
   rV_ROW         in v_dicnomns%rowtype
  ,nCOMPANY       in number
  ,nRN_DUP        in number default null
  ,nAUTOADDMODIF  in number default 0
  ,nRN            out number
  ) 
  is 
  begin
    p_dicnomns_insert(ncompany         => nCOMPANY
                     ,ncrn             => rV_ROW.CRN
                     ,snomen_code      => rV_ROW.NOMEN_CODE
                     ,snomen_name      => rV_ROW.NOMEN_NAME
                     ,smn_name         => rV_ROW.SMN_NAME
                     ,soriginal_name   => rV_ROW.SORIGINAL_NAME
                     ,sumeas_main      => rV_ROW.UMEAS_MAIN
                     ,sumeas_alt       => rV_ROW.UMEAS_ALT
                     ,nequal           => rV_ROW.EQUAL
                     ,nsign_acnt       => rV_ROW.SIGN_ACNT
                     ,nsign_docs       => rV_ROW.SIGN_DOCS
                     ,sgroup_code      => rV_ROW.SGROUP_CODE
                     ,stax_group       => rV_ROW.STAX_GROUP
                     ,snaltax_group    => rV_ROW.SNALTAX_GROUP
                     ,nsign_umeas      => rV_ROW.SIGN_UMEAS
                     ,nnomen_type      => rV_ROW.NOMEN_TYPE
                     ,nsign_serial     => rV_ROW.SIGN_SERIAL
                     ,nsign_modif      => rV_ROW.SIGN_MODIF
                     ,nsign_party      => rV_ROW.SIGN_PARTY
                     ,nsign_ser_ranges => rV_ROW.NSIGN_SER_RANGES
                     ,nsign_liquid     => rV_ROW.NSIGN_LIQUID
                     ,ncntrndm         => rV_ROW.NCNTRNDM
                     ,nmtdrndm         => rV_ROW.NMTDRNDM
                     ,ncntrnds         => rV_ROW.NCNTRNDS
                     ,nmtdrnds         => rV_ROW.NMTDRNDS
                     ,sokpd            => rV_ROW.SOKPD
                     ,sokdp            => rV_ROW.SOKDP
                     ,sokof            => rV_ROW.SOKOF
                     ,nsign_set        => rV_ROW.NSIGN_SET
                     ,nsign_set_divide => rV_ROW.NSIGN_SET_DIVIDE
                     ,nrn_dup          => nRN_DUP
                     ,nwidth           => rV_ROW.NWIDTH
                     ,nheight          => rV_ROW.NHEIGHT
                     ,nlength          => rV_ROW.NLENGTH
                     ,nweight          => rV_ROW.NWEIGHT
                     ,nmu_size         => rV_ROW.NMU_SIZE
                     ,nmu_weight       => rV_ROW.NMU_WEIGHT
                     ,ntemp_from       => rV_ROW.NTEMP_FROM
                     ,ntemp_to         => rV_ROW.NTEMP_TO
                     ,nhumid_from      => rV_ROW.NHUMID_FROM
                     ,nhumid_to        => rV_ROW.NHUMID_TO
                     ,ncommon_pr_sign  => rV_ROW.NCOMMON_PR_SIGN
                     ,nstorage_time    => rV_ROW.NSTORAGE_TIME
                     ,sumeas_storage   => rV_ROW.SUMEAS_STORAGE
                     ,nautoaddmodif    => nAUTOADDMODIF
                     ,sokp             => rV_ROW.SOKP
                     ,samort_group     => rV_ROW.SAMORT_GROUP
                     ,sfnsnomclass     => rV_ROW.SFNSNOMCLASS
                     ,sokved           => rV_ROW.SOKVED
                     ,nrn              => nRN);
  end DICNOMNS_INSERT;
  /*#########################################################################################################*/

  procedure DICNOMNS_UPDATE
  /*
  Заголовок. Клиентское исправление
  */
  (
   rV_ROW         in v_dicnomns%rowtype
  ,nCOMPANY       in number
  ) 
  is 
  begin
    p_dicnomns_update(nrn              => rV_ROW.rn
                     ,ncompany         => nCOMPANY
                     ,snomen_code      => rV_ROW.nomen_code
                     ,snomen_name      => rV_ROW.nomen_name
                     ,smn_name         => rV_ROW.smn_name
                     ,soriginal_name   => rV_ROW.soriginal_name
                     ,sumeas_main      => rV_ROW.umeas_main
                     ,sumeas_alt       => rV_ROW.umeas_alt
                     ,nequal           => rV_ROW.equal
                     ,nsign_acnt       => rV_ROW.sign_acnt
                     ,nsign_docs       => rV_ROW.sign_docs
                     ,sgroup_code      => rV_ROW.sgroup_code
                     ,stax_group       => rV_ROW.stax_group
                     ,snaltax_group    => rV_ROW.snaltax_group
                     ,nsign_umeas      => rV_ROW.sign_umeas
                     ,nnomen_type      => rV_ROW.nomen_type
                     ,nsign_serial     => rV_ROW.sign_serial
                     ,nsign_modif      => rV_ROW.sign_modif
                     ,nsign_party      => rV_ROW.sign_party
                     ,nsign_ser_ranges => rV_ROW.nsign_ser_ranges
                     ,nsign_liquid     => rV_ROW.nsign_liquid
                     ,ncntrndm         => rV_ROW.ncntrndm
                     ,nmtdrndm         => rV_ROW.nmtdrndm
                     ,ncntrnds         => rV_ROW.ncntrnds
                     ,nmtdrnds         => rV_ROW.nmtdrnds
                     ,sokpd            => rV_ROW.sokpd
                     ,sokdp            => rV_ROW.sokdp
                     ,sokof            => rV_ROW.sokof
                     ,nsign_set        => rV_ROW.nsign_set
                     ,nsign_set_divide => rV_ROW.nsign_set_divide
                     ,nwidth           => rV_ROW.nwidth
                     ,nheight          => rV_ROW.nheight
                     ,nlength          => rV_ROW.nlength
                     ,nweight          => rV_ROW.nweight
                     ,nmu_size         => rV_ROW.nmu_size
                     ,nmu_weight       => rV_ROW.nmu_weight
                     ,ntemp_from       => rV_ROW.ntemp_from
                     ,ntemp_to         => rV_ROW.ntemp_to
                     ,nhumid_from      => rV_ROW.nhumid_from
                     ,nhumid_to        => rV_ROW.nhumid_to
                     ,ncommon_pr_sign  => rV_ROW.ncommon_pr_sign
                     ,nstorage_time    => rV_ROW.nstorage_time
                     ,sumeas_storage   => rV_ROW.sumeas_storage
                     ,sokp             => rV_ROW.sokp
                     ,samort_group     => rV_ROW.samort_group
                     ,sfnsnomclass     => rV_ROW.sfnsnomclass
                     ,sokved           => rV_ROW.sokved);
  end DICNOMNS_UPDATE;
  /*#########################################################################################################*/

  procedure DICNOMNS_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW           in dicnomns%rowtype
  ,nCOMPANY       in number
  ,nRN_DUP        in number default null
  ,nAUTOADDMODIF  in number
  ,nRN            out number
  ) 
  is 
  begin
    p_dicnomns_base_insert(ncompany         => nCOMPANY
                          ,ncrn             => rROW.CRN
                          ,snomen_code      => rROW.NOMEN_CODE
                          ,snomen_name      => rROW.NOMEN_NAME
                          ,smn_name         => rROW.MN_NAME
                          ,soriginal_name   => rROW.ORIGINAL_NAME
                          ,nmeas_main       => rROW.UMEAS_MAIN
                          ,nmeas_alt        => rROW.UMEAS_ALT
                          ,nequal           => rROW.EQUAL
                          ,nsign_acnt       => rROW.SIGN_ACNT
                          ,nsign_docs       => rROW.SIGN_DOCS
                          ,ngroup_code      => rROW.GROUP_CODE
                          ,ntax_group       => rROW.TAX_GROUP
                          ,nnaltax_group    => rROW.NALTAX_GROUP
                          ,nsign_umeas      => rROW.SIGN_UMEAS
                          ,nnomen_type      => rROW.NOMEN_TYPE
                          ,nsign_serial     => rROW.SIGN_SERIAL
                          ,nsign_modif      => rROW.SIGN_MODIF
                          ,nsign_party      => rROW.SIGN_PARTY
                          ,nsign_ser_ranges => rROW.SIGN_SER_RANGES
                          ,nsign_liquid     => rROW.SIGN_LIQUID
                          ,ncntrndm         => rROW.CNTRNDM
                          ,nmtdrndm         => rROW.MTDRNDM
                          ,ncntrnds         => rROW.CNTRNDS
                          ,nmtdrnds         => rROW.MTDRNDS
                          ,nokpd            => rROW.OKPD
                          ,nokdp_rn         => rROW.OKDP_RN
                          ,nokof            => rROW.OKOF
                          ,nsign_set        => rROW.SIGN_SET
                          ,nsign_set_divide => rROW.SIGN_SET_DIVIDE
                          ,nrn_dup          => nRN_DUP
                          ,nwidth           => rROW.WIDTH
                          ,nheight          => rROW.HEIGHT
                          ,nlength          => rROW.LENGTH
                          ,nweight          => rROW.WEIGHT
                          ,nmu_size         => rROW.MU_SIZE
                          ,nmu_weight       => rROW.MU_WEIGHT
                          ,ntemp_from       => rROW.TEMP_FROM
                          ,ntemp_to         => rROW.TEMP_TO
                          ,nhumid_from      => rROW.HUMID_FROM
                          ,nhumid_to        => rROW.HUMID_TO
                          ,ncommon_pr_sign  => rROW.COMMON_PR_SIGN
                          ,nstorage_time    => rROW.STORAGE_TIME
                          ,numeas_storage   => rROW.UMEAS_STORAGE
                          ,nautoaddmodif    => nAUTOADDMODIF
                          ,nokp             => rROW.OKP
                          ,namort_group     => rROW.AMORT_GROUP
                          ,nfnsnomclass     => rROW.FNSNOMCLASS
                          ,nokved           => rROW.OKVED
                          ,nrn              => nRN);
  end DICNOMNS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure DICNOMNS_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW         in dicnomns%rowtype
  ,nCOMPANY     in number
  ) 
  is 
  begin
    p_dicnomns_base_update(ncompany         => nCOMPANY
                          ,nrn              => rROW.RN
                          ,snomen_code      => rROW.NOMEN_CODE
                          ,snomen_name      => rROW.NOMEN_NAME
                          ,smn_name         => rROW.MN_NAME
                          ,soriginal_name   => rROW.ORIGINAL_NAME
                          ,nmeas_main       => rROW.UMEAS_MAIN
                          ,nmeas_alt        => rROW.UMEAS_ALT
                          ,nequal           => rROW.EQUAL
                          ,nsign_acnt       => rROW.SIGN_ACNT
                          ,nsign_docs       => rROW.SIGN_DOCS
                          ,ngroup_code      => rROW.GROUP_CODE
                          ,ntax_group       => rROW.TAX_GROUP
                          ,nnaltax_group    => rROW.NALTAX_GROUP
                          ,nsign_umeas      => rROW.SIGN_UMEAS
                          ,nnomen_type      => rROW.NOMEN_TYPE
                          ,nsign_serial     => rROW.SIGN_SERIAL
                          ,nsign_modif      => rROW.SIGN_MODIF
                          ,nsign_party      => rROW.SIGN_PARTY
                          ,nsign_ser_ranges => rROW.SIGN_SER_RANGES
                          ,nsign_liquid     => rROW.SIGN_LIQUID
                          ,ncntrndm         => rROW.CNTRNDM
                          ,nmtdrndm         => rROW.MTDRNDM
                          ,ncntrnds         => rROW.CNTRNDS
                          ,nmtdrnds         => rROW.MTDRNDS
                          ,nokpd            => rROW.OKPD
                          ,nokdp_rn         => rROW.OKDP_RN
                          ,nokof            => rROW.OKOF
                          ,nsign_set        => rROW.SIGN_SET
                          ,nsign_set_divide => rROW.SIGN_SET_DIVIDE
                          ,nwidth           => rROW.WIDTH
                          ,nheight          => rROW.HEIGHT
                          ,nlength          => rROW.LENGTH
                          ,nweight          => rROW.WEIGHT
                          ,nmu_size         => rROW.MU_SIZE
                          ,nmu_weight       => rROW.MU_WEIGHT
                          ,ntemp_from       => rROW.TEMP_FROM
                          ,ntemp_to         => rROW.TEMP_TO
                          ,nhumid_from      => rROW.HUMID_FROM
                          ,nhumid_to        => rROW.HUMID_TO
                          ,ncommon_pr_sign  => rROW.COMMON_PR_SIGN
                          ,nstorage_time    => rROW.STORAGE_TIME
                          ,numeas_storage   => rROW.UMEAS_STORAGE
                          ,nokp             => rROW.OKP
                          ,namort_group     => rROW.AMORT_GROUP
                          ,nfnsnomclass     => rROW.FNSNOMCLASS
                          ,nokved           => rROW.OKVED);
  end DICNOMNS_BASE_UPDATE;
  /*#########################################################################################################*/

  function NOMMODIF_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return nommodif%rowtype
  is
    rRow nommodif%rowtype;
  begin
    begin
      select * into rRow from nommodif where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART,ndocument => nRN, sunit_table => 'NOMMODIF');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'NOMMODIF')));
    end;
    return(rRow);
  end NOMMODIF_GET;
  /*#########################################################################################################*/

  function NOMMODIF_GET_CODE_BY_RN
  /*
  Спецификация. Поиск мнемокода по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ) 
  return varchar2
  is
    sResult           pkg_std.tstring;
  begin
    begin
      select t.modif_code
        into sResult
        from nommodif t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'NOMMODIF');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'NOMMODIF')));
    end;
    return(sResult);
  end NOMMODIF_GET_CODE_BY_RN;
  /*#########################################################################################################*/

  function NOMMODIF_GET_PRN_BY_RN
  /*
  Спецификация. Поиск RN номенклатуры по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ) 
  return number
  is
    nResult           pkg_std.tref; 
  begin
    begin
      select t.prn
        into nResult
        from nommodif t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'NOMMODIF');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'NOMMODIF')));
    end;
    return(nResult);
  end NOMMODIF_GET_PRN_BY_RN;
  /*#########################################################################################################*/

  procedure NOMMODIF_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        nommodif%rowtype;
    rDicNomns   dicnomns%rowtype;
    nMatRes   pkg_std.tref; 
  begin
    /* Считывание */
    rRow      := nommodif_get(nrn => nRN); 
    rDicNomns := dicnomns_get(nrn => rRow.prn); 

    /* ИСПРАВЛЕНИЯ */
    /* Если тип номенклатуры - товар */
    if rDicNomns.nomen_type = 1 then
      /* Добавление мат.ресурса */
      nommodif_matres_insert(nflagsmart => 0
                            ,nrn        => nRN
                            ,ncompany   => nCOMPANY
                            ,nmatres    => nMatRes);
    end if;
      
    /* ПРОВЕРКИ */
    /* Проверка базовая */
    nommodif_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end NOMMODIF_AINSERT;
  /*#########################################################################################################*/

  procedure NOMMODIF_BUPDATE
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
  end NOMMODIF_BUPDATE;
  /*#########################################################################################################*/

  procedure NOMMODIF_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    nommodif_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end NOMMODIF_AUPDATE;
  /*#########################################################################################################*/

  procedure NOMMODIF_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* По материальным ресурсам */
    for c in (
              select t.rn
                from fcmatresource t
               where t.nomen_modif = nRN
             )
    loop
      /* Если выполняются НЕ процедуры замены номенклатуры */
      if nvl(usr_pkg_process.process_get, 'null') not in ('UDO_P_DICNOMNS_TABLE_ALL', 'UDO_P_NOMMODIF_TABLE_ALL_NOMEN')  then 
        /* Удаление мат.ресурса */
        p_fcmatresource_base_delete(nrn => c.rn);
      end if;
    end loop;             

  end NOMMODIF_BDELETE;
  /*#########################################################################################################*/

  procedure NOMMODIF_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        nommodif%rowtype;
    rDicNomns   dicnomns%rowtype;
  begin
    /* Считывание */
    rRow      := nommodif_get(nrn => nRN); 
    rDicNomns := dicnomns_get(nrn => rRow.prn); 

    /* ПРОВЕРКИ */
    /* Мнемокод */
    if case 
         when upper(substr(rRow.modif_code, 0, 1)) = 'Д' 
         then substr(rRow.modif_code, 2) 
       else rRow.modif_code
       end  not like rDicNomns.nomen_code||'%' 
    and not usr_pkg_common.is_crn_in_hiercrn(ncrn => rRow.crn, shier_crn_list => 7152820 /* "Служба IT" */ )  then 
      p_exception(0, 'Первые символы мнемокода модификации <%s> должны равняться мнемокоду номенклатуры <%s>'
                  ,rRow.modif_code
                  ,rDicNomns.nomen_code);   
    end if;

    /* Проверка мнемокода и наименования */
    nommodif_check_name(nrn => rRow.rn, ncompany => nCOMPANY);

  end NOMMODIF_CHECK_BASE;
  /*#########################################################################################################*/

  procedure NOMMODIF_CHECK_NAME
  /*
  Спецификация. Проверка мнемокода и наименования без пробелов по всем модификациям без учёта номенклатуры
  */
  (
   nFLAGSMART in number default 0
  ,nRN        in number
  ,nCOMPANY   in number
  ) 
  is
    rRow            nommodif%rowtype;
  begin
    /* Заголовок */  
     rRow := nommodif_get(nrn => nRN, nflagsmart => nFLAGSMART); 

    /* ПРОВЕРКИ */
    /* Мнемокод задан на входе */
    if rRow.modif_code is null then
      p_exception(nFLAGSMART, 'Не задан мнемокод модификации.'); 
      return;
    end if;
    /* Наименование задано на входе */
    if rRow.modif_name is null then
      p_exception(nFLAGSMART, 'Не задано наименование модификации.'); 
      return;
    end if;

    /* Проверка мнемокода без пробелов */
    for c in (
              select t.modif_code 
                from nommodif t 
               where t.rn != rRow.rn
                 and usr_pkg_common.get_str_normalized(sstr => t.modif_code) = usr_pkg_common.get_str_normalized(sstr => rRow.modif_code)
             )
    loop
      p_exception(nFLAGSMART, 'Существует модификация с аналогичным мнемокодом.'
                  ||cr||'Добавляемый мнемокод: <%s>'
                  ||cr||'Существующий мнемокод: <%s>'
                 ,rRow.modif_code
                 ,c.modif_code); 
    end loop;

    /* Проверка наименования без пробелов */
    for c in (
              select t.modif_name
                from nommodif t 
               where t.rn != rRow.rn
                 and usr_pkg_common.get_str_normalized(sstr => t.modif_name) = usr_pkg_common.get_str_normalized(sstr => rRow.modif_name)
             )
    loop
      p_exception(nFLAGSMART, 'Существует модификация с аналогичным наименованием.'
                  ||cr||'Добавляемое наименование: <%s>'
                  ||cr||'Существующее наименование: <%s>'
                 ,rRow.modif_name
                 ,c.modif_name); 
    end loop;

  end NOMMODIF_CHECK_NAME;
  /*#########################################################################################################*/

  procedure NOMMODIF_BASE_INSERT
  /*
  Спецификация. Базовое добавление
  */
  (
   rROW       in nommodif%rowtype
  ,nCOMPANY   in number
  ,nPRN_DUP   in number
  ,nRN_DUP    in number
  ,nRN        out number
  ) 
  is 
  begin
    p_nommodif_base_insert(ncompany        => nCOMPANY
                          ,nprn            => rROW.PRN
                          ,smodif_code     => rROW.MODIF_CODE
                          ,smodif_name     => rROW.MODIF_NAME
                          ,sbar_code       => rROW.BAR_CODE
                          ,scomments       => rROW.COMMENTS
                          ,nprn_dup        => nPRN_DUP
                          ,nrn_dup         => nRN_DUP
                          ,nwidth          => rROW.WIDTH
                          ,nheight         => rROW.HEIGHT
                          ,nlength         => rROW.LENGTH
                          ,nweight         => rROW.WEIGHT
                          ,nmu_size        => rROW.MU_SIZE
                          ,nmu_weight      => rROW.MU_WEIGHT
                          ,ntemp_from      => rROW.TEMP_FROM
                          ,ntemp_to        => rROW.TEMP_TO
                          ,nhumid_from     => rROW.HUMID_FROM
                          ,nhumid_to       => rROW.HUMID_TO
                          ,ncommon_pr_sign => rROW.COMMON_PR_SIGN
                          ,nproducer       => rROW.PRODUCER
                          ,nstorage_time   => rROW.STORAGE_TIME
                          ,numeas_storage  => rROW.UMEAS_STORAGE
                          ,ngoodnomenft    => rROW.GOODNOMENFT
                          ,nrn             => nRN);

  end NOMMODIF_BASE_INSERT;
  /*#########################################################################################################*/

  procedure NOMMODIF_BASE_UPDATE
  /*
  Спецификация. Базовое исправление
  */
  (
   rROW         in NOMMODIF%rowtype
  ,nCOMPANY     in number
  ) 
  is 
  begin
    p_nommodif_base_update(ncompany        => nCOMPANY
                          ,nrn             => rROW.RN
                          ,smodif_code     => rROW.MODIF_CODE
                          ,smodif_name     => rROW.MODIF_NAME
                          ,sbar_code       => rROW.BAR_CODE
                          ,scomments       => rROW.COMMENTS
                          ,nwidth          => rROW.WIDTH
                          ,nheight         => rROW.HEIGHT
                          ,nlength         => rROW.LENGTH
                          ,nweight         => rROW.WEIGHT
                          ,nmu_size        => rROW.MU_SIZE
                          ,nmu_weight      => rROW.MU_WEIGHT
                          ,ntemp_from      => rROW.TEMP_FROM
                          ,ntemp_to        => rROW.TEMP_TO
                          ,nhumid_from     => rROW.HUMID_FROM
                          ,nhumid_to       => rROW.HUMID_TO
                          ,ncommon_pr_sign => rROW.COMMON_PR_SIGN
                          ,nproducer       => rROW.PRODUCER
                          ,nstorage_time   => rROW.STORAGE_TIME
                          ,numeas_storage  => rROW.UMEAS_STORAGE
                          ,ngoodnomenft    => rROW.GOODNOMENFT);
  end NOMMODIF_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure NOMMODIF_MATRES_INSERT
  /*
  Спецификация. Добавление материального ресурса
  */
  (
   nFLAGSMART in number
  ,nRN        in number
  ,nCOMPANY   in number
  ,nMATRES    out number
  ) 
  is
    rRow            nommodif%rowtype;
    rDicNomns       dicnomns%rowtype;
    rDicMUnts       dicmunts%rowtype;
    rFCMatResource  fcmatresource%rowtype;
  begin
    /* По мат.ресурсам с такой же модификацией */
    for c in (select rn from fcmatresource where nomen_modif = nRN)
    loop
      /* Сообщение об ошибке */
      case nFLAGSMART 
        /* выдавать */
        when 0 then
          p_exception(0, 'Для модификации <%s> уже существует материальный ресурс. %s'
                     ,nommodif_get_code_by_rn(nflagsmart => 1, nrn => nRN)
                     ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'NOMMODIF')));
        /* НЕ выдавать */
        when 1 then
          return;
      else
        p_exception(0, 'Неверное значение <%s> параметра <nFLAGSMART>. %s'
                   ,nFLAGSMART
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'NOMMODIF')));
      end case;
    end loop;

    /* Считывание */
    rRow      := nommodif_get(nrn => nRN); 
    rDicNomns := dicnomns_get(nrn => rRow.prn); 
    begin
      select * into rDicMUnts from dicmunts where rn = rDicNomns.umeas_main;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => rDicNomns.umeas_main, sunit_table => 'DICMUNTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,NRN
                   ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DICMUNTS')));
    end;

    /* Заполнение значений в переменные */
    rFCMatResource.company        := nCOMPANY;
    rFCMatResource.crn            := 20548975; /* корневой */
    rFCMatResource.code           := /*rDicNomns.nomen_code||' / '|| */rRow.modif_code;
    rFCMatResource.name           := /*rDicNomns.nomen_name||' / '|| */rRow.modif_name;
    rFCMatResource.nomenclature   := rDicNomns.rn;
    rFCMatResource.nomen_modif    := rRow.rn;
    rFCMatResource.art_number     := 0;
    rFCMatResource.calc_type      := 0;
    rFCMatResource.res_sign       := 1;
    rFCMatResource.wrk_acc_sign   := 1;
    rFCMatResource.prod_cycle     := 0;
    rFCMatResource.norm_munit     := rDicNomns.umeas_main; 
    rFCMatResource.plan_mode      := 2;
    rFCMatResource.sep_sign       := 0;
    rFCMatResource.virtual_sign   := 0;
    rFCMatResource.wght_munit     := 175632; /* кг */
    rFCMatResource.weight         := rRow.weight;
    rFCMatResource.size_munit     := 175634; /* мм */
    rFCMatResource.length         := rRow.length;
    rFCMatResource.width          := rRow.width;
    rFCMatResource.height         := rRow.height;
    rFCMatResource.half_sign      := 0;
    rFCMatResource.tool_sign      := 0;
    rFCMatResource.round_calc     := 0;
    rFCMatResource.plan_munit     := rDicNomns.umeas_main;
    rFCMatResource.plan_coeff     := 1;

    /* Добавление мат.ресурса */
    p_fcmatresource_base_insert(ncompany       => rFCMatResource.company
                               ,ncrn           => rFCMatResource.crn
                               ,scode          => rFCMatResource.code
                               ,sname          => rFCMatResource.name
                               ,nnomenclature  => rFCMatResource.nomenclature
                               ,nnomen_modif   => rFCMatResource.nomen_modif
                               ,nequiv_munit   => rFCMatResource.equiv_munit
                               ,ndef_artcl     => rFCMatResource.def_artcl
                               ,nbrak_artcl    => rFCMatResource.brak_artcl
                               ,nart_number    => rFCMatResource.art_number
                               ,ncalc_type     => rFCMatResource.calc_type
                               ,scalc_formula  => rFCMatResource.calc_formula
                               ,npr_subdiv     => rFCMatResource.pr_subdiv
                               ,nprod_kind     => rFCMatResource.prod_kind
                               ,nres_sign      => rFCMatResource.res_sign
                               ,nwrk_acc_sign  => rFCMatResource.wrk_acc_sign
                               ,nstor_oper_in  => rFCMatResource.stor_oper_in
                               ,nstor_oper_out => rFCMatResource.stor_oper_out
                               ,nstorage       => rFCMatResource.storage
                               ,nmol           => rFCMatResource.mol
                               ,nmtr_res       => rFCMatResource.mtr_res
                               ,nmin_party     => rFCMatResource.min_party
                               ,nquanin_party  => rFCMatResource.quanin_party
                               ,nprod_cycle    => rFCMatResource.prod_cycle
                               ,nnorm_munit    => rFCMatResource.norm_munit
                               ,nplan_mode     => rFCMatResource.plan_mode
                               ,nmin_rest      => rFCMatResource.min_rest
                               ,ncalcschm      => rFCMatResource.calcschm
                               ,sformat        => rFCMatResource.format
                               ,nsep_sign      => rFCMatResource.sep_sign
                               ,nvirtual_sign  => rFCMatResource.virtual_sign
                               ,nwght_munit    => rFCMatResource.wght_munit
                               ,nweight        => rFCMatResource.weight
                               ,nsize_munit    => rFCMatResource.size_munit
                               ,nlength        => rFCMatResource.length
                               ,nwidth         => rFCMatResource.width
                               ,nheight        => rFCMatResource.height
                               ,nhalf_sign     => rFCMatResource.half_sign
                               ,nmtr_grade     => rFCMatResource.mtr_grade
                               ,nmtr_grade_std => rFCMatResource.mtr_grade_std
                               ,nmtr_asrt      => rFCMatResource.mtr_asrt
                               ,nmtr_asrt_std  => rFCMatResource.mtr_asrt_std
                               ,npr_agent      => rFCMatResource.pr_agent
                               ,snote          => rFCMatResource.note
                               ,ntool_sign     => rFCMatResource.tool_sign
                               ,nlife          => rFCMatResource.life
                               ,nlife_unit     => rFCMatResource.life_unit
                               ,nround_calc    => rFCMatResource.round_calc
                               ,nplan_munit    => rFCMatResource.plan_munit
                               ,nplan_coeff    => rFCMatResource.plan_coeff
                               ,ndup_rn        => null
                               ,nrn            => nMATRES);
  end NOMMODIF_MATRES_INSERT;
/*#########################################################################################################*/

end USR_PKG_DICNOMNS;
/
