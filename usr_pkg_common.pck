create or replace package USR_PKG_COMMON is
  /*
  Package 
  */
  /*#########################################################################################################*/

  function GET_CAT_HIGHER_RN_LIST
  /*
  Функция. Возвращает коллекцию RN каталогов верхнего уровня, начиная от заданного RN
  */
  (
   NRN        in number             -- RN записи
  ,NSIGNS     in number default 0   -- Начиная с уровня: 0 - корневого, 1 - первого уровня, 2 - второго, и т.д.
  ,NMODE      in number default 0   -- 0 - весь список, 1 - одну запись
  ) 
  return UDO_TP_NUMTABLE;
  /*#########################################################################################################*/

  function GET_CAT_HIGHER_LIST
  /*
  Функция. Возвращает коллекцию наименований каталогов верхнего уровня, начиная от заданного RN
  */
  (
   NRN        in number             -- RN записи
  ,NSIGNS     in number default 0   -- Начиная с уровня: 0 - корневого, 1 - первого уровня, 2 - второго, и т.д.
  ,NMODE      in number default 0   -- 0 - весь список, 1 - одну запись
  ) 
  return UDO_TP_STRTABLE;
  /*#########################################################################################################*/

  function GET_CAT_HIGHER_STR
  /*
  Функция. Возвращает наименование текущего и каталогов верхнего уровня, разделённых символом "\"
  */
  (
   NRN        in number             -- RN записи
  ,NSIGNS     in number default 0   -- Начиная с уровня: 0 - корневого, 1 - первого уровня, 2 - второго, и т.д.
  ,NMODE      in number default 0   -- 0 - весь список, 1 - одну запись
  ) 
  return PKG_STD.tSTRING;
  /*#########################################################################################################*/

  function GET_AMAKE_DOCUMENT_RN_LIST
  /*
  Функция возвращает список RN документов, сформированных из текущего документа
  Сработает только при вызове после формирования документов
  */
  return UDO_TP_NUMTABLE;
  /*#########################################################################################################*/

  FUNCTION GET_UNIT_NAME_SHORT
  /*
  Сокращённое наименование раздела
  */
  (
   sUNITCODE        in varchar2
  ) 
  return unitlist.unitname%type;
  /*#########################################################################################################*/

  function GET_RN_LIST_BY_CODE

  /*
  Функция. Возвращает список RN записей заданного раздела по мнемокодам с разделительными символами
  */
  (
   SCODE        in varchar2 -- значения для отбора
  ,STABLE_NAME  in varchar2 -- имя таблицы
  ,SCOLUMN_NAME in varchar2 -- имя колонки
  ) 
  return UDO_TP_NUMTABLE;
  --########################################################################################################

  function GET_LIST_DISTINCT
  /*
  Функция возвращает список с дистинктом значений, заданнных в параметре
  19/01/2024 Степанов М.
  */
  (
   sLIST            in varchar2             /* список с разделителем ";" (обязательно)*/
  ,sDELIM           in varchar2 default ';' /* символ - разделитель для выходного списка */
  )
  return varchar2;
  --########################################################################################################

  function GET_STR_NORMALIZED
  /*
  Функция возвращает нормализованное значение входной строки
  19/1/2024 Степанов М.
  */
  (
   sSTR            in varchar2  
  )
  return varchar2;
  /*#########################################################################################################*/

  function GET_DATE_FROM_TEMPLATE
  /*
  Функция преобразования строки в дату по одному из 4х шаблонов
  */
  (
   nFLAGSMART       in number default 0 
  ,nMODE            in number /* формат шаблона: 0 - MM.YYYY, 1 - YYWW, 2 - DD.MM.YYYY, 3 - YY */
  ,sVALUE           in varchar    
  )
  return date;
  /*#########################################################################################################*/

  function IS_CRN_IN_HIERCRN
  /*
  Функция. Определяет входит ли заданный каталог в иерархию заданного каталога
  */
  (
   nCRN             in number
  ,sHIER_CRN_LIST   in varchar2 /* Список RN через ";" */
  ) 
  return boolean;
  /*#########################################################################################################*/

  function IS_CRN_IN_HIERCRN
  /*
  Функция. Определяет входит ли заданный каталог в иерархию заданного каталога
  */
  (
   nCRN             in number
  ,sHIER_CRN_LIST2  in varchar2 /* Список RN через ";" */
  ) 
  return number;
  /*#########################################################################################################*/

  function IS_LISTS_INTERSECT
  /*
  Функция. Определяет входит ли одно из значений списка1 в список2
  */
  (
   sLIST1        in varchar2 /* Список через ";" */
  ,sLIST2        in varchar2 /* Список через ";" */
  ) 
  return boolean;
  --########################################################################################################
  
  procedure OPTIONS_SET_STR
  /*
  Исправление строкового значения заданного параметра
  */
  (
   nCOMPANY        in number
  ,sCODE           in varchar2
  ,sSTR_VAL        in varchar2
  ,sAUTHID         in varchar2 default utilizer
  ,nCHECK          in number   default 0 /* 0 - сначала проверить текущее значение, если равно заданному, то не исправлять, 1 - исправлять без проверки */
  );
  --########################################################################################################
  
  procedure OPTIONS_SET
  /*
  Штатная процедура с отменой проверки прав
  */
  (
   sCODE           in varchar2
  ,sAUTHID         in varchar2
  ,nCOMPANY        in number
  ,sSTR_VALUE      in varchar2
  ,nNUM_VALUE      in number
  ,dDATE_VALUE     in date
  ,nRN             out number
  ,nMODE           in number default 1  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --########################################################################################################
  
  procedure OPTIONS_SAVE_UNIT_PARAMS
  /*
  Процедура сохранения значений параметров заданного раздела для заданного пользователя
  */
  (
   sUNITCODE       in varchar2
  ,sAUTHID         in varchar2 default utilizer
  );
  --########################################################################################################
  
  procedure OPTIONS_RESTORE_UNIT_PARAMS
  /*
  Процедура восстановления значений параметров заданного раздела для заданного пользователя
  */
  ;
  --########################################################################################################

  function MAKE_PERIOD_FROM_LIST
  /*
  Функция возвращает список с периодами из значений, указанных в параметре
  14/05/2024 Степанов М.
  grant execute on usr_f_fcroutlst_sernumb to public;
  */
  (
   sLIST            in varchar2  /* список через ";" */
  ,sPERIOD_DELIM    in varchar2 default '-' /* разделитель последовательности */
  ,sLIST_DELIM      in varchar2 default ',' /* разделитель перечисления */
  )
  return varchar2;
  /*#########################################################################################################*/

  function DICSHPVW_GET_CODE
  /*
  Вид отгрузки. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2;
  --########################################################################################################
  
  FUNCTION FRAC_PART_NUMBER(PIN_NUMBER IN NUMBER, PIN_TR_1 IN NUMBER, PIN_TR_2 IN NUMBER) RETURN varchar2;
  
  /* 
    -- Выводит не менее PIN_TR_1 после запятой и не более PIN_TR_2
    -- Недостающие позиции дополняет нулями '0'
    -- PIN_NUMBER математически округляется до PIN_TR_2 знаков после запятой
    -- PIN_TR_1 >= 0
  */
  
  
  --########################################################################################################
  

end USR_PKG_COMMON;
/
create or replace package body USR_PKG_COMMON is

  /*#########################################################################################################*/

  function GET_CAT_HIGHER_RN_LIST
  /*
  Функция. Возвращает коллекцию RN каталогов верхнего уровня, начиная от заданного RN
  */
  (
   NRN        in number             -- RN записи
  ,NSIGNS     in number default 0   -- Начиная с уровня: 0 - корневого, 1 - первого уровня, 2 - второго, и т.д.
  ,NMODE      in number default 0   -- 0 - весь список, 1 - одну запись
  ) 
  return  UDO_TP_NUMTABLE
  is
    aList UDO_TP_NUMTABLE;
  begin
   
    begin
      select a.rn bulk collect
        into aList
        from (
              select t.rn, t.signs
                from acatalog t
               where (
                      t.signs >= NSIGNS and NMODE = 0
                     or 
                      t.signs  = NSIGNS and NMODE = 1
                     )
              connect by prior t.crn = t.rn 
              start with t.rn = nrn
              ) a
      order by a.signs;
    end;

    return(aList);
    
  end GET_CAT_HIGHER_RN_LIST;
  /*#########################################################################################################*/

  function GET_CAT_HIGHER_LIST
  /*
  Функция. Возвращает коллекцию наименований каталогов верхнего уровня, начиная от заданного RN
  */
  (
   NRN        in number             -- RN записи
  ,NSIGNS     in number default 0   -- Начиная с уровня: 0 - корневого, 1 - первого уровня, 2 - второго, и т.д.
  ,NMODE      in number default 0   -- 0 - весь список, 1 - одну запись
  ) 
  return UDO_TP_STRTABLE
  is
    aRNList     UDO_TP_NUMTABLE;
    aStrTable   UDO_TP_STRTABLE;
  begin
    aRNList := GET_CAT_HIGHER_RN_LIST(NRN, NSIGNS, NMODE);
    
    begin
      select t.name bulk collect
        into aStrTable
        from acatalog t
       where t.rn in (select column_value from table(cast(aRNList as udo_tp_numtable)));
    end;

    return(aStrTable);
    
  end GET_CAT_HIGHER_LIST;
  /*#########################################################################################################*/

  function GET_CAT_HIGHER_STR
  /*
  Функция. Возвращает наименование текущего и каталогов верхнего уровня, разделённых символом "\"
  */
  (
   NRN        in number             -- RN записи
  ,NSIGNS     in number default 0   -- Начиная с уровня: 0 - корневого, 1 - первого уровня, 2 - второго, и т.д.
  ,NMODE      in number default 0   -- 0 - весь список, 1 - одну запись
  ) 
  return pkg_std.tstring 
  is
    aRNList     udo_tp_numtable;
    sRes        pkg_std.tstring;
  begin
    aRNList := GET_CAT_HIGHER_RN_LIST(NRN, NSIGNS, NMODE);
    
    for c in (
              select ac.name
                from table(cast(aRNList as udo_tp_numtable)) t, acatalog ac
               where ac.rn = t.column_value
             ) 
    loop
      sRes := STRCOMBINE(sRes, c.name, '\') ;
    END LOOP;
    
    return(sRes);
    
  end GET_CAT_HIGHER_STR;
  /*#########################################################################################################*/

  function GET_AMAKE_DOCUMENT_RN_LIST
  /*
  Функция возвращает список RN документов, сформированных из текущего документа
  Сработает только при вызове после формирования документов
  */
  return udo_tp_numtable
  is
    aRNList     udo_tp_numtable := udo_tp_numtable();
  begin
    -- Список
    begin
      select t.out_document0 bulk collect
        into aRNList
        from inhierbuff_common t;
    end;
    -- Результат
    return(aRNList);
  end GET_AMAKE_DOCUMENT_RN_LIST;
  /*#########################################################################################################*/

  FUNCTION GET_UNIT_NAME_SHORT
  /*
  Сокращённое наименование раздела
  */
  (
   sUNITCODE        in varchar2
  ) 
  return unitlist.unitname%type
  is
  begin
    return(case sUNITCODE
             when 'IncomingOrders'                then 'Прих.орд.'
             when 'IncomFromDeps'                 then 'Прих.подр.'
             when 'GoodsTransInvoicesToDepts'     then 'РН в подр.'
             when 'GoodsTransInvoicesToConsumers' then 'РН потреб.'
             when 'WriteOffActs'                  then 'Акты спис.'
             when 'ReturnInvoicesToSuppliers'     then 'РН возвр.пост.'
             when 'IntegrationActs'               then 'Акты компл.'
           else F_UNITLIST_GETNAME(sUNITCODE)
           end
          );
  end GET_UNIT_NAME_SHORT;
  /*#########################################################################################################*/

  function GET_RN_LIST_BY_CODE
  /*
  Функция. Возвращает список RN записей заданного раздела по мнемокодам с разделительными символами
  */
  (
   sCODE        in varchar2 -- значения для отбора
  ,sTABLE_NAME  in varchar2 -- имя таблицы
  ,sCOLUMN_NAME in varchar2 -- имя колонки
  ) 
  return udo_tp_numtable 
  is
    aRNList   udo_tp_numtable := udo_tp_numtable();
  begin

    begin
      execute immediate
        'select t.rn 
           from '||sTABLE_NAME||' t
                ,(select column_value from table(cast(udo_f_get_str_table(0, '''||sCODE||''') as UDO_TP_STRTABLE))) a 
          where upper(t.'||sCOLUMN_NAME||') like upper(a.column_value)'
        bulk collect into aRNList;
    exception
      when others then
        P_EXCEPTION(0, 'Ошибка при считывании RN записей из таблицы %s с мнемокодами %s . %s', sTABLE_NAME, sCODE, sqlerrm);
    end;

    return(aRNList);
    
  end GET_RN_LIST_BY_CODE;
  --########################################################################################################

  function GET_LIST_DISTINCT
  /*
  Функция возвращает список с дистинктом значений, заданнных в параметре
  19/01/2024 Степанов М.
  */
  (
   sLIST            in varchar2             /* список с разделителем ";" (обязательно)*/
  ,sDELIM           in varchar2 default ';' /* символ - разделитель для выходного списка */
  )
  return varchar2
  is
    sRes    pkg_std.tstring;
  begin

    if sLIST is not null then
      select substr( listagg(column_value, sDELIM) within group (order by column_value), 0, 3999 )
        into sRes
        from (select distinct column_value from table(cast(udo_f_get_str_table(0, sLIST ) as udo_tp_strtable)));
    end if;

    return(sRes);

  end GET_LIST_DISTINCT;
  --########################################################################################################

  function GET_STR_NORMALIZED
  /*
  Функция возвращает нормализованное значение входной строки
  20/02/2025 Степанов М.
  */
  (
   sSTR            in varchar2  
  )
  return varchar2
  is
    sRes    pkg_std.tstring;
  begin
    sRes := translate(upper(usr_f_trim(sval => sSTR, nspaces => 0)), 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ');
    return(sRes);
  end GET_STR_NORMALIZED;

  /*#########################################################################################################*/

  function GET_DATE_FROM_TEMPLATE
  /*
  Функция преобразования строки в дату по одному из 4х шаблонов
  */
  (
   nFLAGSMART       in number default 0 
  ,nMODE            in number /* формат шаблона: 0 - MM.YYYY, 1 - YYWW, 2 - DD.MM.YYYY, 3 - YY */
  ,sVALUE           in varchar    
  )
  return date
  is
    dDate           date;
    sMODE           pkg_std.tstring := case nMODE when 0 then 'MM.YYYY' when 1 then 'YYWW' when 2 then 'DD.MM.YYYY' when 3 then 'YY' end; 
    sYear           varchar2(10);
    sWeek           varchar2(10);
  begin
    /* Вычисление даты производства по текстовым шаблонам */
    case nMODE
      /* MM.YYYY */
      when 0 then
        begin
          dDate  := to_date( '01.'||sVALUE, 'dd.mm.yyyy' );
        exception when others then
          p_exception( nFLAGSMART, 'Неверное значение "%s" для шаблона "%s"', sVALUE, sMODE ); 
        end;
      /* YYWW */        
      when 1 then
        if ltrim( sVALUE, '1234567890' ) is not null 
        or length( sVALUE ) != 4 then
          p_exception( nFLAGSMART, 'Неверное значение "%s" для шаблона "%s"', sVALUE, sMODE ); 
        end if;
        begin
          sYear  := substr( sVALUE, 0, 2 );
          sWeek  := substr( sVALUE, 3 );
          dDate  := to_date( to_char( trunc( to_date( sYear, 'yy'), 'yy') + 7 * ( to_number( sWeek ) - 1 ), 'dd.mm.yyyy' ), 'dd.mm.yyyy' );
        exception when others then
          p_exception( nFLAGSMART, 'Неверное значение "%s" для шаблона "%s"', sVALUE, sMODE ); 
        end;
      /* DD.MM.YYYY */        
      when 2 then
        begin
          dDate := to_date( sVALUE, 'dd.mm.yyyy' );
        exception when others then
          p_exception( nFLAGSMART, 'Неверное значение "%s" для шаблона "%s"', sVALUE, sMODE ); 
        end;
      /* YY */
      when 3 then
        if ltrim( sVALUE, '1234567890' ) is not null 
        or length( sVALUE ) != 2 then
          p_exception( nFLAGSMART, 'Неверное значение "%s" для шаблона "%s"', sVALUE, sMODE ); 
        end if;
        begin
          dDate := to_date( '01.01'||sVALUE, 'dd.mm.yy' );
        exception when others then
          p_exception( nFLAGSMART, 'Неверное значение "%s" для шаблона "%s"', sVALUE, sMODE ); 
        end;
    else
      p_exception( nFLAGSMART, 'Неверный режим выполнения %s', nMODE ); 
    end case;
    
    return ( dDate );

  end GET_DATE_FROM_TEMPLATE;
  /*#########################################################################################################*/

  function IS_CRN_IN_HIERCRN
  /*
  Функция. Определяет входит ли заданный каталог в иерархию заданного каталога
  */
  (
   nCRN             in number
  ,sHIER_CRN_LIST   in varchar2 /* Список RN через ";" */
  ) 
  return boolean
  is
    bRes  boolean := false;
  begin
    for c in (select column_value from table(cast(usr_pkg_common.get_cat_higher_rn_list(nrn => nCRN ) as udo_tp_numtable))
              intersect 
              select to_number(column_value) from table(cast(udo_f_get_str_table(nflag_smart => 1, sparam_list => sHIER_CRN_LIST) as udo_tp_strtable))) 
    loop
      bRes := true;
      exit;
    end loop;
    return(bRes);
  END IS_CRN_IN_HIERCRN;
  /*#########################################################################################################*/

  function IS_CRN_IN_HIERCRN
  /*
  Функция. Определяет входит ли заданный каталог в иерархию заданного каталога
  */
  (
   nCRN             in number
  ,sHIER_CRN_LIST2  in varchar2 /* Список RN через ";" */
  ) 
  return number
  is
  begin
    return(sys.diutil.bool_to_int(usr_pkg_common.is_crn_in_hiercrn(ncrn => nCRN, shier_crn_list => sHIER_CRN_LIST2)));
  END IS_CRN_IN_HIERCRN;
  /*#########################################################################################################*/

  function IS_LISTS_INTERSECT
  /*
  Функция. Определяет входит ли одно из значений списка1 в список2
  */
  (
   sLIST1        in varchar2 /* Список через ";" */
  ,sLIST2        in varchar2 /* Список через ";" */
  ) 
  return boolean
  is
    bRes  boolean := false;
  begin
    for c in (
              select translate(regexp_substr(t.val, '[^;]+', 1, level), '*?', '%_')
                from (select sLIST1 as val from dual) t
              connect by regexp_substr(t.val, '[^;]+', 1, level) is not null
              intersect             
              select translate(regexp_substr(t.val, '[^;]+', 1, level), '*?', '%_')
                from (select sLIST2 as val from dual) t
              connect by regexp_substr(t.val, '[^;]+', 1, level) is not null
             )
    loop
      bRes := true;
      exit;
    end loop;
    return(bRes);
  END IS_LISTS_INTERSECT;
  --########################################################################################################
  
  procedure OPTIONS_SET_STR
  /*
  Исправление строкового значения заданного параметра
  */
  (
   nCOMPANY        in number
  ,sCODE           in varchar2
  ,sSTR_VAL        in varchar2
  ,sAUTHID         in varchar2 default utilizer
  ,nCHECK          in number   default 0 /* 0 - сначала проверить текущее значение, если равно заданному, то не исправлять, 1 - исправлять без проверки */
  )
  as
    sVarchar    pkg_std.tstring; 
    nNumber     pkg_std.tnumber; 
  begin
    if nCHECK = 0 then
      sVarchar := f_options_string_value(nopt_type      => null
                                        ,nopt_kind      => null
                                        ,sunitcode      => null
                                        ,nshare_kind    => null
                                        ,scode          => 'Realiz_RInvToSup_DocType'
                                        ,sdefault_value => null);
    end if;
    if cmp_vc2(sSTR_VAL, sVarchar) != 1 then
      options_set(scode       => sCODE
                 ,sauthid     => sAUTHID
                 ,ncompany    => nCOMPANY
                 ,sstr_value  => sSTR_VAL
                 ,nnum_value  => null
                 ,ddate_value => null
                 ,nrn         => nNumber);
    end if;               
  end OPTIONS_SET_STR;
  --########################################################################################################
  
  procedure OPTIONS_SET
  /*
  Штатная процедура с отменой проверки прав и очисткой кэша, чтобы следущие процедуры считали актуальное значение
  Также отключается регистрация событий
  */
  (
   sCODE           in varchar2
  ,sAUTHID         in varchar2
  ,nCOMPANY        in number
  ,sSTR_VALUE      in varchar2
  ,nNUM_VALUE      in number
  ,dDATE_VALUE     in date
  ,nRN             out number
  ,nMODE           in number default 1  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  as
    rPARAM          OPTIONS%rowtype;
    sACTION         UNITFUNC.CODE%type;
    sREAL_AUTHID    OPTIONS.AUTHID%type := sAUTHID;
    nINSERT_SIGN1   number( 1 );
    /* перенесено из входных параметров */
    nVERSION        pkg_std.tref; 
    nINSERT_SIGN    pkg_std.tnumber := null; 
    nIMP_SIGN       pkg_std.tnumber := 0; 
    sCOMPANY        pkg_std.tstring := '';
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_options_set(scode        => sCODE
                   ,sauthid      => sAUTHID
                   ,ncompany     => nCOMPANY
                   ,nversion     => nVERSION
                   ,sstr_value   => sSTR_VALUE
                   ,nnum_value   => nNUM_VALUE
                   ,ddate_value  => dDATE_VALUE
                   ,ninsert_sign => nINSERT_SIGN
                   ,nrn          => nRN
                   ,nimp_sign    => nIMP_SIGN
                   ,scompany     => sCOMPANY);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* считывание загрузочного параметра */
      P_OPTIONS_GET_DEF( 0,sCODE,rPARAM );

      /* установка действия */
      /* глобальная, системная */
      if ( rPARAM.OPT_KIND = 1 and rPARAM.OPT_TYPE = 1 ) then
        sACTION := 'OPTIONS_UPDATE_GS';

      /* глобальная, пользовательская */
      elsif ( rPARAM.OPT_KIND = 1 and rPARAM.OPT_TYPE = 0 ) then

        if sREAL_AUTHID is null then
          sREAL_AUTHID := UTILIZER;
        end if;

        if ( cmp_vc2(sREAL_AUTHID,UTILIZER) = 0 ) then
          sACTION := 'OPTIONS_UPDATE_GU';
        else
          sACTION := null;
        end if;

      /* локальная, системная */
      elsif ( rPARAM.OPT_KIND = 0 and rPARAM.OPT_TYPE = 1 ) then
        sACTION := 'OPTIONS_UPDATE_LS';

      /* локальная, пользовательская */
      elsif ( rPARAM.OPT_KIND = 0 and rPARAM.OPT_TYPE = 0 ) then

        if sREAL_AUTHID is null then
          sREAL_AUTHID := UTILIZER;
        end if;

        if ( cmp_vc2(sREAL_AUTHID,UTILIZER) = 0 ) then
          sACTION := 'OPTIONS_UPDATE_LU';
        else
          sACTION := null;
        end if;

      else
        sACTION := null;
      end if;

      /* проверка прав доступа */
      /*if ( sACTION is not null ) then
        PKG_ENV.ACCESS( null,null,null,'Options',sACTION );
      end if;*/
  
      if nINSERT_SIGN is null then
         nINSERT_SIGN1 := 1;
         else
           nINSERT_SIGN1 := nINSERT_SIGN;
      end if;

      /* отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

      /* вызов базовой процедуры */
      P_OPTIONS_BASE_SET( sCODE,sREAL_AUTHID,nCOMPANY,nVERSION,sSTR_VALUE,nNUM_VALUE,dDATE_VALUE,nINSERT_SIGN1,nRN,nIMP_SIGN,sCOMPANY);

      /* включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
      
      /* очистка кэша */
      pkg_contvarglb.purge('PKG_OPTIONS');

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end OPTIONS_SET;
  --########################################################################################################
  
  procedure OPTIONS_SAVE_UNIT_PARAMS
  /*
  Процедура сохранения значений параметров заданного раздела для заданного пользователя
  */
  (
   sUNITCODE       in varchar2
  ,sAUTHID         in varchar2 default utilizer
  )
  as
  begin

    select * bulk collect
      into usr_pkg_pub_const.aOptions
      from options
     where unitcode = sUNITCODE
       and authid   = sAUTHID;

  end OPTIONS_SAVE_UNIT_PARAMS;
  --########################################################################################################
  
  procedure OPTIONS_RESTORE_UNIT_PARAMS
  /*
  Процедура восстановления значений параметров заданного раздела для заданного пользователя
  */
  as
    nNumber   pkg_std.tnumber; 
  begin
    /* Если в массиве есть записи */
    if usr_pkg_pub_const.aOptions.count != 0 then
      /* Цикл */
      for i in usr_pkg_pub_const.aOptions.first .. usr_pkg_pub_const.aOptions.last 
      loop
        /* Исправление */
        options_set(scode       => usr_pkg_pub_const.aOptions(i).code
                   ,sauthid     => usr_pkg_pub_const.aOptions(i).authid
                   ,ncompany    => usr_pkg_pub_const.aOptions(i).company
                   ,sstr_value  => usr_pkg_pub_const.aOptions(i).str_value
                   ,nnum_value  => usr_pkg_pub_const.aOptions(i).num_value
                   ,ddate_value => usr_pkg_pub_const.aOptions(i).date_value
                   ,nrn         => nNumber);
      end loop;
      /* Очистка массива */
      usr_pkg_pub_const.aOptions.delete;
    /*else
      p_exception(0, 'Пустой массив со значениями параметров раздела.');       */
    end if;

  end OPTIONS_RESTORE_UNIT_PARAMS;
  --########################################################################################################

  function MAKE_PERIOD_FROM_LIST
  /*
  Функция возвращает список с периодами из значений, указанных в параметре
  14/05/2024 Степанов М.
  */
  (
   sLIST            in varchar2  /* список через ";" */
  ,sPERIOD_DELIM    in varchar2 default '-' /* разделитель последовательности */
  ,sLIST_DELIM      in varchar2 default ',' /* разделитель перечисления */
  )
  return varchar2
  is
    sRes    pkg_std.tstring;
  begin
    for c in ( select sval                              as sval
                     ,nval                              as nval
                     ,lag (nval, 1) over(order by nval) as nlag
                     ,lead(nval, 1) over(order by nval) as nlead
                from (
                      select a.column_value                                  as sval
                            ,to_number(regexp_replace(a.column_value, '\D')) as nval
                        from table(cast(udo_f_get_str_table(nflag_smart => 1, sparam_list => sLIST) as udo_tp_strtable)) a
                      order by nval) )
    loop
      /* внутри последовательности */
      if    cmp_num(c.nval - 1, c.nlag)  = 1 and cmp_num(c.nval + 1, c.nlead)  = 1 then
        null;
      /* конец последовательности */
      elsif cmp_num(c.nval - 1, c.nlag)  = 1 and cmp_num(c.nval + 1, c.nlead) != 1 then
        sRes := strcombine(sRes, c.sval, sPERIOD_DELIM);
      /* начало последовательности */
      elsif cmp_num(c.nval - 1, c.nlag) != 1 and cmp_num(c.nval + 1, c.nlead)  = 1 then
        sRes := strcombine(sRes, c.sval, sLIST_DELIM);
      /* нет последовательности */
      elsif cmp_num(c.nval - 1, c.nlag) != 1 and cmp_num(c.nval + 1, c.nlead) != 1 then
        sRes := strcombine(sRes, c.sval, sLIST_DELIM);
      end if;
    end loop;

    return(sRes);

  end MAKE_PERIOD_FROM_LIST;
  /*#########################################################################################################*/

  function DICSHPVW_GET_CODE
  /*
  Вид отгрузки. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2
  is
    sRes  pkg_std.tstring; 
  begin
    begin
      select code into sRes from dicshpvw where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'DICSHPVW' );
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске мнемокода записи с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'DICSHPVW' ) ) );
    end;
    return(sRes);
  end DICSHPVW_GET_CODE;
  --########################################################################################################
  
  function frac_part_number
  (
    pin_number in number
   ,pin_tr_1   in number
   ,pin_tr_2   in number
  ) return varchar2 is
  
    -- Выводит не менее PIN_TR_1 после запятой и не более PIN_TR_2
    -- Недостающие позиции дополняет нулями '0'
    -- PIN_NUMBER математически округляется до PIN_TR_2 знаков после запятой
    -- PIN_TR_1 >= 0
  
    v_frac varchar2(20) := substr(to_char(mod(round(abs(pin_number), pin_tr_2), 1)), 2);
  
  begin
  
    return to_char(trunc(pin_number)) || 
    case when v_frac is null 
         then 
             case pin_tr_1 
                 when 0 
                 then '' 
                 else '.' ||rpad('0',pin_tr_1,'0') 
             end 
           else '.' || rpad(v_frac,greatest(pin_tr_1,length(v_frac) ,'0'),'0') 
             end;
    end;
  
  
  --########################################################################################################

end USR_PKG_COMMON;
/
