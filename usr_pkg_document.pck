create or replace package USR_PKG_DOCUMENT is
  /*
  25/07/2023 Степанов М.
  Package предназначен для работы с документами. 
  */
  /*########################################################################################################*/

  function GET_FIELD_NAME
  /*
  Функция получения наименования поля таблицы
  */
  (
   nFLAGSMART       in number
  ,nMODE            in number default 0 /* Если значение не найдено выводить: 0 - null, 1 - 'null' (текст) */
  ,sTABLENAME       in varchar2
  ,sFIELD           in varchar2 /* Обозначения полей: ncrn, ndoctype, sprefix, snumber, ddate, nstatus, dwork_date, nstore
                                                     , nstoreoper, nin_status, din_work_date, nin_store, nin_storeoper */
  )  
  return varchar2;
  /*########################################################################################################*/

  function GET_BASE_VALUES
  /*
  Функция получения базовых полей документа
  */
  (
   nFLAGSMART       in number
  ,nRN              in number
  ,nCOMPANY         in number
  ,sUNITCODE        in varchar2
  ) 
  return usr_pkg_pub_const.tdoc_base_values_rec;
  /*########################################################################################################*/

  function GET_TDOC_VALUES
  /*
  Функция получения полей товарного документа: склад, МОЛ, складская операция, ЛС, склад-получатель, МОЛ-получатель, складская операция-получатель
  */
  (
   nRN              in number
  ,sUNITCODE        in varchar2
  ) 
  return usr_pkg_pub_const.tdoc_base_values_rec;
  /*########################################################################################################*/

  procedure DETAILS_DECODE
  /*
  Процедура определения реквизитов из строки документа
  */
  (
   nFLAGSMART   in number
  ,sDETAILS     in varchar2
  ,sTYPE        out varchar2
  ,sPREF        out varchar2
  ,sNUMB        out varchar2
  ,dDATE        out date  
  );
  /*########################################################################################################*/

  procedure DETAILS_DECODE
  /*
  Процедура определения реквизитов из строки документа
  */
  (
   nFLAGSMART   in number
  ,sDETAILS     in varchar2
  ,sTYPE        out varchar2
  ,sPREF_NUMB   out varchar2
  ,dDATE        out date  
  );
  /*########################################################################################################*/

  function GET_RN_BY_DETAILS
  /*
  Функция получения RN документа по реквизитам Тип, Префикс, Номер, Дата
  */
  (
   nFLAGSMART   in number
  ,sUNITCODE    in varchar2
  ,nTYPE        in number
  ,sPREF        in varchar2
  ,sNUMB        in varchar2
  ,dDATE        in date  
  ) 
  return number;
  /*########################################################################################################*/

  function GET_RN_BY_DETAILS
  /*
  Функция получения RN документа по реквизитам Тип, Префикс-Номер, Дата
  */
  (
   nFLAGSMART   in number
  ,sUNITCODE    in varchar2
  ,nTYPE        in number
  ,sPREF_NUMB   in varchar2
  ,dDATE        in date  
  ) 
  return number;
  /*########################################################################################################*/

  function GET_RN_BY_STR_DETAILS
  /*
  Функция получения RN документа по строке, содержащей реквизиты: Тип, Префикс, Номер, Дата
  */
  (
   nFLAGSMART   in number
  ,sUNITCODE    in varchar2
  ,sDETAILS     in varchar2
  ) 
  return number;
  /*########################################################################################################*/

  function GET_DMSCLATTRS_CAPTION
  /*
  Функция получения наименования колонки по таблице и полю
  */
  (
   nFLAGSMART       in number
  ,sTABLE_NAME      in varchar2
  ,sCOLUMN_NAME     in varchar2
  ,nKIND            in number default 0
  )
  return varchar2 ;
  /*########################################################################################################*/

  function GET_CLNEVENTS
  /*
  Функция получения RN события, связанного с документом по статусной модели
  */
  (
   nFLAGSMART       in number
  ,nRN              in number
  ) 
  return number;
  /*########################################################################################################*/
  
  PrOCEDURE SPEC_GET_MESSAGE
  /*
  Спецификация. Получение текста сообщения по заданным параметрам спецификации
  */
  (
   nCOMPANY           in number
  ,sUNITCODE          in varchar2
  ,nPRN               in number
  ,nNOMEN             in number default null
  ,nNOMMODIF          in number default null
  ,nTAXGR             in number default null
  ,nQUANT             in number default null
  ,nQUANTALT          in number default null
  ,nPRICE             in number default null
  ,nARTICLE           in number default null
  ,nGOODSPARTY        in number   default null
  ,sSERNUMB           in varchar2 default null
  ,nCOUNTRY           in number   default null
  ,sGTD               in varchar2 default null
  ,dBEGINDATE         in date     default null
  ,dENDDATE           in date     default null
  ,sMESSAGE           out varchar2 
  );
  /*########################################################################################################*/
  
  PROCEDURE SPEC_PROPS_COPY_TO_GP
  /*
  Спецификация. Копирование доп.данных из свойств спецификации в свойства приходной партии
  */
  (
   nPRN        in number  /* Заголовок документа. RN */
  );
  /*########################################################################################################*/

  procedure CHECK_PREF_NUMB
  /*
  Проверка префикса и номера
  */
  (
   sPREF      in varchar2
  ,sNUMB      in varchar2
  ,dDATE      in date
  ,sNUMBMAX   in varchar2 default null /* Максимальный номер. Если задан, то проверяется, что он равен текущему */
  );
  /*########################################################################################################*/

  procedure STRPLRESJRNL_DELETE
  /*
  Удаление связанных записей журнала резервирования текущего документа
  */
  (
   nRN        in number
  );
  /*########################################################################################################*/

  procedure STRPLRESJRNL_BASE_DELETE
  /*
  Удаление связанных записей журнала резервирования текущего документа. Базовая
  */
  (
   nRN        in number
  );
  /*########################################################################################################*/

  procedure CLNEVENTS_CHANGE_STATE
  /*
  Документы. Перевод события в следующий статус
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ,sSTATUS    in varchar2
  );
  /*########################################################################################################*/

  procedure INSERT_FL_TO_SELECTLIST
  /*
  Добавить RN присоединённых документов текущего документа в SELECTLIST
  */
  (
   nRN              in number
  ,nIDENT           in number
  ,sFLT_CODE_LIST   in varchar2 default null
  );
  /*########################################################################################################*/

  procedure INSERT_FL_TO_FILE_BUFFER
  /*
  Добавить присоединённе документы текущего документа в FILE_BUFFER
  */
  (
   nRN              in number   /* RN документа, присоединённые документы которого необходимо добавить */
  ,nIDENT           in number
  ,sFLT_CODE_LIST   in varchar2 default null  /* Список типов присоединённых документов, которые необходимо считать через ";" */
  );
  /*########################################################################################################*/
  
end USR_PKG_DOCUMENT;
/
create or replace package body USR_PKG_DOCUMENT is

  /*########################################################################################################*/
  function GET_FIELD_NAME
  /*
  Функция получения наименования поля таблицы
  */
  (
   nFLAGSMART       in number
  ,nMODE            in number default 0 /* Если значение не найдено выводить: 0 - null, 1 - 'null' (текст) */
  ,sTABLENAME       in varchar2
  ,sFIELD           in varchar2 /* Обозначения полей: ncrn, ndoctype, sprefix, snumber, ddate, nstatus, dwork_date, nstore
                                                     , nstoreoper, nin_status, din_work_date, nin_store, nin_storeoper */
  )
  return varchar2
  is
    sResult     pkg_std.tstring;
  begin
    begin
      case upper(sFIELD)
        when 'NCOMPANY' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    = 'COMPANY'
             ;
        when 'NJUR_PERS' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind        = 0
             and t.prn         = ul.rn
             and ul.table_name = sTABLENAME
             and t.column_name in ('JURPERS', 'JURPERSON', 'JURPERSONS', 'JUR_PERS')
             ;
        when 'NCRN' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind        = 0
             and t.prn         = ul.rn
             and ul.table_name = sTABLENAME
             and t.column_name in ('CRN', 'CATALOG')
             ;
        when 'NDOCTYPE' then
          select a.column_name
            into sResult
            from (
                  select t.column_name
                    from dmsclattrs t, unitlist ul
                   where t.kind           = 0
                     and t.prn            = ul.rn
                     and ul.table_name    = sTABLENAME
                     and upper(t.caption) like '%ТИПЫ ДОКУМЕНТОВ%'
                  order by t.position 
                ) a 
           where rownum = 1
             ;
        when 'SPREFIX' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.domain         = dmn.rn
             and dmn.data_length  = 80
             and t.column_name    like '%PREF%'
             ;
        when 'SNUMBER' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.domain         = dmn.rn
             and dmn.data_length  = 80
             and t.column_name    like '%NUMB%'
             ;
        when 'SEXT_NUMB' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.domain         = dmn.rn
             and t.column_name    like 'EXT_NUMB%'
             ;
        when 'DDATE' then
          select a.column_name
            into sResult
            from (
                  select t.column_name
                    from dmsclattrs t, unitlist ul, dmsdomains dmn
                   where t.kind           = 0
                     and t.prn            = ul.rn
                     and ul.table_name    = sTABLENAME
                     and t.domain         = dmn.rn
                     and dmn.name         = 'Дата'
                  order by t.position 
                ) a 
           where rownum = 1
             ;
        when 'NSTATUS' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.domain         = dmn.rn
             and upper(dmn.name)  like upper('%состояни%') 
             ;
        when 'DWORK_DATE' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.domain       = dmn.rn
             and dmn.data_type  = 2
             and (t.column_name like '%STAT%' or t.column_name like 'WORK%')
             ;
        when 'NSTORE' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.column_name  in ('STORE', 'NSTORE', 'DICSTORE')
             ;
        when 'NMOL' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and (
                 ( ul.table_name in ('INTEGRACT', 'RINVTOSUP', 'TRANSINVCUST', 'TRANSINVDEPT', 'RLINVSHEET') 
                  and t.column_name = 'MOL' )
              or ( ul.table_name in ('WROFFACTS', 'INCOMEFROMDEPS', 'INORDERS', 'ININVOICES')  
                  and t.column_name = 'AGENT' ) 
                 )
             ;
        when 'NSTOREOPER' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and (t.column_name like '%ST%OPER%' and t.column_name not like '%IN%')
             ;
        when 'NIN_STATUS' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.column_name  = 'IN_STATUS'
             ;
        when 'DIN_WORK_DATE' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.domain       = dmn.rn
             and dmn.data_type  = 2
             and t.column_name like 'IN_WORK%'
             ;
        when 'NIN_STORE' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and (t.column_name like '%STORE%' and t.column_name like '%IN%')
             ;
        when 'NIN_MOL' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.column_name  = 'IN_MOL' 
             ;
        when 'NIN_STOREOPER' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and (t.column_name like '%ST%OPER%' and t.column_name like '%IN%')
             ;
        when 'NFACEACC' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    in ('FACEACC', 'OUT_FACEACC')
             ;
        when 'NAGENT' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    in ('AGENT', 'SUPPLIER')
             ;
        when 'NAGNACC' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    in ('AGNACC', 'SUPPLACC')
             ;
        when 'NJUR_PERS_ACC' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    in ('SELF_AGNACC', 'PAYERACC')
             ;
        when 'NAGNFIFO' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    = 'AGNFIFO'
             ;
        when 'NSHIPPER' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    = 'SHIPPER'
             ;
        when 'NCURRENCY' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    = 'CURRENCY'
             ;
        when 'NACC_AGENT' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.column_name    = 'ACC_AGENT'
             ;
        when 'SNOTE' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul, dmsdomains dmn
           where t.kind           = 0
             and t.prn            = ul.rn
             and ul.table_name    = sTABLENAME
             and t.domain         = dmn.rn
             and t.column_name    in ('NOTE', 'COMMENTS')
             ;
        when 'NSUMM' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.column_name  in ('DOC_SUM', 'SUMM', 'BASESUMM')
             ;
        when 'NSUMMTAX' then
          select t.column_name
            into sResult
            from dmsclattrs t, unitlist ul
           where t.kind         = 0
             and t.prn          = ul.rn
             and ul.table_name  = sTABLENAME
             and t.column_name  in ('DOC_SUMTAX', 'SUMMTAX', 'PLANSUMTAX', 'PAY_SUM', 'SUMMWITHNDS', 'SUMMTAX')
             ;
      else
        p_exception(nFLAGSMART, 'Неверное значение <%s> параметра <sFIELD>.', sFIELD);
      end case;
    exception
      when no_data_found then
        sResult := case nMODE
                     when 1 then 'null'
                   else 
                     null
                   end;
      when too_many_rows then
        sResult := case nMODE
                     when 1 then 'null'
                   else 
                     null
                   end;
        p_exception(nFLAGSMART, 'Найдено больше одного наименования колонки по описанию <%s>.', sFIELD);
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске наименования колонки по описанию <%s>.', sFIELD);
    end;

    return(sResult);

  end GET_FIELD_NAME;
  /*########################################################################################################*/

  function GET_BASE_VALUES
  /*
  Функция получения базовых полей документа
  */
  (
   nFLAGSMART       in number
  ,nRN              in number
  ,nCOMPANY         in number
  ,sUNITCODE        in varchar2
  ) 
  return usr_pkg_pub_const.tdoc_base_values_rec
  is
    sTableName          pkg_std.tstring; 
    rTdoc_Base_Values   usr_pkg_pub_const.tdoc_base_values_rec;
    nNumber             pkg_std.tnumber; 
  begin
    /* Проверка параметров */
    /* Если не заданы */
    if nRN is null or sUNITCODE is null then
      /* сообщение об ошибке */
      p_exception(nFLAGSMART, 'Не заданы значения входных параметров <nRN> и <sUNITCODE>');
      /* сохраняем RN и организацию */
      rTdoc_Base_Values.nrn      := nRN;
      rTdoc_Base_Values.ncompany := NCOMPANY;
      /* выходим */
      return rTdoc_Base_Values;
   end if;

    /* Проверка наличия описания полей раздела в DMSCLATTRS */
    find_dmsclattrs_col_name(nflag_smart  => nFLAGSMART
                            ,nflag_option => 0
                            ,nmaster_rn   => null
                            ,smaster_code => sUNITCODE
                            ,scode        => 'RN'
                            ,nrn          => nNumber);
    /* Если описания отсутствуют */
    if nNumber is null then
      /* сохраняем RN и организацию */
      rTdoc_Base_Values.nrn      := nRN;
      rTdoc_Base_Values.ncompany := NCOMPANY;
      /* выходим */
      return rTdoc_Base_Values;
    end if;

    /* Определение таблицы по коду раздела */
    find_unitlist_table(nflag_smart => nFLAGSMART, sunitcode => sUNITCODE, stablename => sTableName);

    /* Формирование списка полей таблицы */
    pkg_proc_broker.set_param_num('NCOMPANY', NCOMPANY);
    pkg_proc_broker.set_param_num('NRN', NRN);
    pkg_proc_broker.standard_get(sunitcode => sUNITCODE);

    /* Наполнение выходной переменной значениями из списка полей таблицы */
    rTdoc_Base_Values.nrn       := nRN;
    rTdoc_Base_Values.ncompany  := NCOMPANY;
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'njur_pers')
                                ,nattr_value => rTdoc_Base_Values.njur_pers);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'ncrn')
                                ,nattr_value => rTdoc_Base_Values.ncrn);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'ndoctype')
                                ,nattr_value => rTdoc_Base_Values.ndoctype);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'ncrn')
                                ,nattr_value => rTdoc_Base_Values.ncrn);
    pkg_proc_broker.get_attr_str(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'sprefix')
                                ,sattr_value => rTdoc_Base_Values.sprefix);
    pkg_proc_broker.get_attr_str(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'snumber')
                                ,sattr_value => rTdoc_Base_Values.snumber);
    pkg_proc_broker.get_attr_str(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'sext_numb')
                                ,sattr_value => rTdoc_Base_Values.sext_numb);
    pkg_proc_broker.get_attr_dat(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'ddate')
                                ,dattr_value => rTdoc_Base_Values.ddate);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nstatus')
                                ,nattr_value => rTdoc_Base_Values.nstatus);
    pkg_proc_broker.get_attr_dat(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'dwork_date')
                                ,dattr_value => rTdoc_Base_Values.dwork_date);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nstore')
                                ,nattr_value => rTdoc_Base_Values.nstore);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nmol')
                                ,nattr_value => rTdoc_Base_Values.nmol);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nstoreoper')
                                ,nattr_value => rTdoc_Base_Values.nstoreoper);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nin_status')
                                ,nattr_value => rTdoc_Base_Values.nin_status);
    pkg_proc_broker.get_attr_dat(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'din_work_date')
                                ,dattr_value => rTdoc_Base_Values.din_work_date);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nin_store')
                                ,nattr_value => rTdoc_Base_Values.nin_store);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nin_mol')
                                ,nattr_value => rTdoc_Base_Values.nin_mol);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nin_storeoper')
                                ,nattr_value => rTdoc_Base_Values.nin_storeoper);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nfaceacc')
                                ,nattr_value => rTdoc_Base_Values.nfaceacc);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nagent')
                                ,nattr_value => rTdoc_Base_Values.nagent);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nagnacc')
                                ,nattr_value => rTdoc_Base_Values.nagnacc);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'njur_pers_acc')
                                ,nattr_value => rTdoc_Base_Values.njur_pers_acc);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nagnfifo')
                                ,nattr_value => rTdoc_Base_Values.nagnfifo);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nshipper')
                                ,nattr_value => rTdoc_Base_Values.nshipper);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'ncurrency')
                                ,nattr_value => rTdoc_Base_Values.ncurrency);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nacc_agent')
                                ,nattr_value => rTdoc_Base_Values.nacc_agent);
    pkg_proc_broker.get_attr_str(nflag_smart => 1
                                ,sattr_name => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'snote')
                                ,sattr_value => rTdoc_Base_Values.snote);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nsumm')
                                ,nattr_value => rTdoc_Base_Values.nsumm);
    pkg_proc_broker.get_attr_num(nflag_smart => 1
                                ,sattr_name  => get_field_name(nflagsmart => 1, stablename => sTableName, sfield => 'nsummtax')
                                ,nattr_value => rTdoc_Base_Values.nsummtax);
    /* Результат */
    return rTdoc_Base_Values;

  end GET_BASE_VALUES;  
  /*########################################################################################################*/

  function GET_TDOC_VALUES
  /*
  Функция получения полей товарного документа: склад, МОЛ, складская операция, ЛС, склад-получатель, МОЛ-получатель, складская операция-получатель
  */
  (
   nRN              in number
  ,sUNITCODE        in varchar2
  ) 
  return usr_pkg_pub_const.tdoc_base_values_rec
  is
    rTdoc_Base_Values   usr_pkg_pub_const.tdoc_base_values_rec;
  begin
    case sUNITCODE
      when 'IncomingOrders' then
        select store
              ,agent
              ,stopertype
              ,faceacc
          into rTdoc_Base_Values.nstore
              ,rTdoc_Base_Values.nmol
              ,rTdoc_Base_Values.nstoreoper
              ,rTdoc_Base_Values.nfaceacc
          from inorders
         where rn = nRN;
      when 'IncomFromDeps' then
        select store
              ,agent
              ,store_oper
              ,out_faceacc
          into rTdoc_Base_Values.nstore
              ,rTdoc_Base_Values.nmol
              ,rTdoc_Base_Values.nstoreoper
              ,rTdoc_Base_Values.nfaceacc
          from incomefromdeps
         where rn = nRN;
      when 'GoodsTransInvoicesToDepts' then
        select store
              ,mol
              ,stoper
              ,faceacc
              ,in_store
              ,in_mol
              ,in_stoper
          into rTdoc_Base_Values.nstore
              ,rTdoc_Base_Values.nmol
              ,rTdoc_Base_Values.nstoreoper
              ,rTdoc_Base_Values.nfaceacc
              ,rTdoc_Base_Values.nin_store
              ,rTdoc_Base_Values.nin_mol
              ,rTdoc_Base_Values.nin_storeoper
          from transinvdept
         where rn = nRN;
      when 'GoodsTransInvoicesToConsumers' then
        select store
              ,mol
              ,stoper
              ,faceacc
          into rTdoc_Base_Values.nstore
              ,rTdoc_Base_Values.nmol
              ,rTdoc_Base_Values.nstoreoper
              ,rTdoc_Base_Values.nfaceacc
          from transinvcust
         where rn = nRN;
      when 'WriteOffActs' then
        select decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 0, store)
              ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 0, agent)
              ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 0, stoper)
              ,faceacc
              ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 1, store)
              ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 1, agent)
              ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 1, stoper)
          into rTdoc_Base_Values.nstore
              ,rTdoc_Base_Values.nmol
              ,rTdoc_Base_Values.nstoreoper
              ,rTdoc_Base_Values.nfaceacc
              ,rTdoc_Base_Values.nin_store
              ,rTdoc_Base_Values.nin_mol
              ,rTdoc_Base_Values.nin_storeoper
          from wroffacts
         where rn = nRN;
      when 'ReturnInvoicesToSuppliers' then
        select store
              ,mol
              ,storeoper
              ,faceacc
          into rTdoc_Base_Values.nstore
              ,rTdoc_Base_Values.nmol
              ,rTdoc_Base_Values.nstoreoper
              ,rTdoc_Base_Values.nfaceacc
          from rinvtosup
         where rn = nRN;
    else
      null;
    end case;

    /* Результат */
    return rTdoc_Base_Values;

  end GET_TDOC_VALUES;  
  /*########################################################################################################*/

  function GET_TAX_SUM
  /*
  Функция 
  */
  (
   nRN              in number
  ,sUNITCODE        in varchar2
  ) 
  return number
  is
  begin
    null;
  end GET_TAX_SUM;  
  /*########################################################################################################*/

  procedure DETAILS_DECODE
  /*
  Процедура определения реквизитов из строки документа
  */
  (
   nFLAGSMART   in number
  ,sDETAILS     in varchar2
  ,sTYPE        out varchar2
  ,sPREF        out varchar2
  ,sNUMB        out varchar2
  ,dDATE        out date  
  ) 
  is
  begin
    /* Если входной папраметр содержит не 2 запятые */
    if regexp_count(sDETAILS, ',') != 2 then
      if nFLAGSMART = 0 then
        p_exception(0, 'Входное значение должно иметь формат: Тип, префикс-номер, дата. %s', sDETAILS); 
      else
        return;
      end if;
    end if;

    /* Вычисление */
    sTYPE := substr(sDETAILS, 0, instr(sDETAILS, ',', 1, 1) -1);  
    sPREF := substr(sDETAILS, instr(sDETAILS, ',', -1, 2) +2, instr(sDETAILS, '-', -1, 1) - instr(sDETAILS, ',', -1, 2) -2);
    sNUMB := substr(
                    sDETAILS
                   ,instr(sDETAILS, '-', -1, 1) +1
                   ,instr(sDETAILS, ',', -1, 1) - instr(sDETAILS, '-', -1, 1) -1
                   );  
    dDATE := to_date(
                     substr(
                            sDETAILS
                           ,instr(sDETAILS, ',', 1, 2) +2
                           )
                    , 'dd.mm.yyyy'
                   );
  end DETAILS_DECODE;
  /*########################################################################################################*/

  procedure DETAILS_DECODE
  /*
  Процедура определения реквизитов из строки документа
  */
  (
   nFLAGSMART   in number
  ,sDETAILS     in varchar2
  ,sTYPE        out varchar2
  ,sPREF_NUMB   out varchar2
  ,dDATE        out date  
  ) 
  is
  begin
    /* Если входной папраметр содержит не 2 запятые */
    if regexp_count(sDETAILS, ',') != 2 then
      if nFLAGSMART = 0 then
        p_exception(0, 'Входное значение должно иметь формат: Тип, префикс-номер, дата. %s', sDETAILS); 
      else
        return;
      end if;
    end if;

    /* Вычисление */
    sTYPE       := substr(sDETAILS, 0, instr(sDETAILS, ',', 1, 1)-1);  
    sPREF_NUMB  := substr(sDETAILS, instr(sDETAILS, ',', 1, 1) +2, instr(sDETAILS, ',', 1, 2) - instr(sDETAILS, ',', 1, 1) -2);
    dDATE       := to_date(substr(sDETAILS, instr(sDETAILS, ',', 1, 2) +2), 'dd.mm.yyyy');

  end DETAILS_DECODE;
  /*########################################################################################################*/

  function GET_RN_BY_DETAILS
  /*
  Функция получения RN документа по реквизитам Тип, Префикс, Номер, Дата
  */
  (
   nFLAGSMART   in number
  ,sUNITCODE    in varchar2
  ,nTYPE        in number
  ,sPREF        in varchar2
  ,sNUMB        in varchar2
  ,dDATE        in date  
  ) 
  return number
  is
    sTableName     pkg_std.tstring; 
    sTypeName      pkg_std.tstring; 
    sPrefName      pkg_std.tstring; 
    sNumbName      pkg_std.tstring; 
    sDateName      pkg_std.tstring; 
    
    nREF            pkg_std.tref; 
  begin
    /* Определение таблицы по коду раздела */
    find_unitlist_table(nflag_smart => 0, sunitcode => sUNITCODE, stablename => sTableName);
    
    /* Определение наименований полей в таблице */
    sTypeName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'ndoctype');
    sPrefName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'sprefix');
    sNumbName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'snumber');
    sDateName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'ddate');

    /* Запрос */
    begin
      execute immediate
      'select t.rn
         from '||sTableName||' t
        where t.'||sTypeName||'       = :nTYPE
          and trim(t.'||sPrefName||') = :sPREF
          and trim(t.'||sNumbName||') = :sNUMB
          and t.'||sDateName||'       = :dDATE' 
         into nREF
        using nTYPE
             ,sPREF
             ,sNUMB
             ,dDATE;
    exception
      when others then
        p_exception(nFLAGSMART, 'Ошибка при поиске RN документа с параметрами: %s из таблицы %s. %s'
                   ,get_doctypes_code_id(nflag_smart => 1, nrn => nTYPE)||', '||sPREF||'-'||sNUMB||', '||decode_date(dDATE)
                   ,sTableName
                   ,cr||sqlerrm);
    end;

    return(nREF);

  end GET_RN_BY_DETAILS;
  /*########################################################################################################*/

  function GET_RN_BY_DETAILS
  /*
  Функция получения RN документа по реквизитам Тип, Префикс-Номер, Дата
  */
  (
   nFLAGSMART   in number
  ,sUNITCODE    in varchar2
  ,nTYPE        in number
  ,sPREF_NUMB   in varchar2
  ,dDATE        in date  
  ) 
  return number
  is
    sTableName     pkg_std.tstring; 
    sTypeName      pkg_std.tstring; 
    sPrefName      pkg_std.tstring; 
    sNumbName      pkg_std.tstring; 
    sDateName      pkg_std.tstring; 
    
    nREF            pkg_std.tref; 
  begin
    /* Определение таблицы по коду раздела */
    find_unitlist_table(nflag_smart => 0, sunitcode => sUNITCODE, stablename => sTableName);

    /* Определение наименований полей в таблице */
    sTypeName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'ndoctype');
    sPrefName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'sprefix');
    sNumbName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'snumber');
    sDateName := get_field_name(nflagsmart => 0, nmode => 1, stablename => sTableName, sfield => 'ddate');

    begin
      execute immediate
      'select t.rn
         from '||sTableName||' t
        where t.'||sTypeName||'       = :nTYPE
          and trim(t.'||sPrefName||')||''-''||trim(t.'||sNumbName||') = :sPREF_NUMB
          and t.'||sDateName||'       = :dDATE' 
         into nREF
        using nTYPE
             ,sPREF_NUMB
             ,dDATE;
    exception
      when others then
        p_exception(nFLAGSMART, 'Ошибка при поиске RN документа с параметрами: %s из таблицы %s. %s'
                   ,get_doctypes_code_id(nflag_smart => 1, nrn => nTYPE)||', '||sPREF_NUMB||', '||decode_date(dDATE)
                   ,sTableName
                   ,cr||sqlerrm);
    end;

    return(nREF);

  end GET_RN_BY_DETAILS;
  /*########################################################################################################*/

  function GET_RN_BY_STR_DETAILS
  /*
  Функция получения RN документа по строке, содержащей реквизиты: Тип, Префикс, Номер, Дата
  */
  (
   nFLAGSMART   in number
  ,sUNITCODE    in varchar2
  ,sDETAILS     in varchar2
  ) 
  return number
  is
    sTYPE       pkg_std.tstring; 
    nTYPE       pkg_std.tref; 
    sPREF_NUMB  pkg_std.tstring; 
    dDATE       date; 
    
    nREF        pkg_std.tref; 
  begin
    /* Определение реквизитов из строки */
    details_decode(nflagsmart => nFLAGSMART
                  ,sdetails   => sDETAILS
                  ,stype      => sTYPE
                  ,spref_numb => sPREF_NUMB
                  ,ddate      => dDATE);
    /* RN типа документа */
    find_doctypes_code(ncompany  => 90521
                      ,sdoccode  => sTYPE
                      ,sunitcode => null
                      ,nstype    => null
                      ,nrn       => nTYPE);
    /* Получение Rn по реквизитам */
    nREF := get_rn_by_details(nflagsmart => nFLAGSMART
                             ,sunitcode  => sUNITCODE
                             ,ntype      => nTYPE
                             ,spref_numb => sPREF_NUMB
                             ,ddate      => dDATE);
    return(nREF);
    
  end GET_RN_BY_STR_DETAILS;
  /*########################################################################################################*/

  function GET_DMSCLATTRS_CAPTION
  /*
  Функция получения наименования колонки по таблице и полю
  */
  (
   nFLAGSMART       in number
  ,sTABLE_NAME      in varchar2
  ,sCOLUMN_NAME     in varchar2
  ,nKIND            in number default 0
  ) 
  return varchar2
  is
    sVarchar      pkg_std.tstring; 
  begin
    begin
      select t.caption
        into sVarchar
        from dmsclattrs t, unitlist ul, dmsdomains dmn
       where t.prn         = ul.rn
         and ul.table_name = sTABLE_NAME
         and t.domain      = dmn.rn
         and t.column_name = sCOLUMN_NAME 
         and t.kind        = nKIND ;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найдено наименование класса для поля "%s" таблицы "%s".', sCOLUMN_NAME,  sTABLE_NAME ) ;
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного наименования класса для поля "%s" таблицы "%s".', sCOLUMN_NAME,  sTABLE_NAME ) ;
      when others then
        p_exception( 0, 'Неопределённая ситуация при поиске наименования класса для поля "%s" таблицы "%s".', sCOLUMN_NAME,  sTABLE_NAME ) ;
    end;
    
    return sVarchar;
    
  end GET_DMSCLATTRS_CAPTION;
  /*########################################################################################################*/

  function GET_CLNEVENTS
  /*
  Функция получения RN события, связанного с документом по статусной модели
  */
  (
   nFLAGSMART       in number
  ,nRN              in number
  ) 
  return number
  is
    nRef      pkg_std.tref; 
  begin
    begin
      select rn into nRef from clnevents where linked_rn = nRN;
    exception
      when no_data_found then
        if nFLAGSMART = 0 then
          p_exception(0, 'Не найдено событие статусной модели для документа с RN <%s>', nRN);
        end if;
      when too_many_rows then
        if nFLAGSMART = 0 then
          p_exception(0, 'Найдено больше одного события статусной модели для документа с RN <%s>', nRN);
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске события статусной модели для документа с RN <%s>', nRN);
    end;
    
    return nRef;
    
  end GET_CLNEVENTS;
  /*########################################################################################################*/
  
  PROCEDURE SPEC_GET_MESSAGE
  /*
  Спецификация. Получение текста сообщения по заданным параметрам спецификации
  */
  (
   nCOMPANY           in number
  ,SUNITCODE          in varchar2
  ,nPRN               in number
  ,nNOMEN             in number default null
  ,nNOMMODIF          in number default null
  ,nTAXGR             in number default null
  ,nQUANT             in number default null
  ,nQUANTALT          in number default null
  ,nPRICE             in number default null
  ,nARTICLE           in number default null
  ,nGOODSPARTY        in number   default null
  ,sSERNUMB           in varchar2 default null
  ,nCOUNTRY           in number   default null
  ,sGTD               in varchar2 default null
  ,dBEGINDATE         in date     default null
  ,dENdDATE           in date     default null
  ,sMESSAGE           out varchar2 
  ) 
  IS
    rV_GoodsParties   v_goodsparties%rowtype;

    sVarchar          pkg_std.tstring; 
  BEGIN
    sMESSAGE := ' ';
    sMESSAGE := strcombine(sMESSAGE, get_dicnomns_code_id(nflag_smart => 1, nrn => nNOMEN), CR||'Номенклатура: ');
    sMESSAGE := strcombine(sMESSAGE, usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => nNOMMODIF), CR||'Модификация: ');
    find_dictaxgr_rn(nflag_smart  => 1
                    ,nflag_option => 1
                    ,ncompany     => nCOMPANY
                    ,nrn          => nTAXGR
                    ,scode        => sVarchar);
    sMESSAGE := strcombine(sMESSAGE, sVarchar, CR||'Налоговая группа: ');
    sMESSAGE := strcombine(sMESSAGE, nQUANT, CR||'Количество: ');
    sMESSAGE := strcombine(sMESSAGE, nPRICE, CR||'Цена: ');
    sMESSAGE := strcombine(sMESSAGE, replace(
                                             f_rlarticles_get_code(narticle => nARTICLE)
                                            ,case when nARTICLE is null then 'RN: <null>' else 'RN: '||nARTICLE end
                                            )
                          , cr||'Изделие: ');
    if nGOODSPARTY is not null then
      begin
        select * into rV_GoodsParties from v_goodsparties where nrn = nGOODSPARTY;
      exception
        when no_data_found then
          null;
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске приходной партии товара с RN <%s> для документа в разделе <%s>'
                     ,nGOODSPARTY, f_unitlist_getname(sunitcode => SUNITCODE));
      end;                   
      sMESSAGE := strcombine(sMESSAGE, rV_GoodsParties.scode, CR||'Партия: ');
      sMESSAGE := strcombine(sMESSAGE, rV_GoodsParties.ssernumb, CR||'Серия: ');
      sMESSAGE := strcombine(sMESSAGE, sSERNUMB, CR||'Серия: ');
      sMESSAGE := strcombine(sMESSAGE, nCOUNTRY, CR||'Страна: ');
      sMESSAGE := strcombine(sMESSAGE, sGTD, CR||'ГТД: ');
      sMESSAGE := strcombine(sMESSAGE, decode_date(ddate => dBEGINDATE), CR||'Дата начала: ');
      sMESSAGE := strcombine(sMESSAGE, decode_date(ddate => dENdDATE), CR||'Дата окончания: ');
      sMESSAGE := strcombine(sMESSAGE, f_docdescrs_get_description(sunitcode => SUNITCODE, ndocument => NPRN), CR||'В документе: ');
    end if;

  END SPEC_GET_MESSAGE;
  /*########################################################################################################*/
  
  PROCEDURE SPEC_PROPS_COPY_TO_GP
  /*
  Спецификация. Копирование доп.данных из свойств спецификации в свойства приходной партии
  */
  (
   nPRN        in number  /* Заголовок документа. RN */
  ) 
  is
    rGoodsParties   goodsparties%rowtype;
    nNumber         pkg_std.tnumber; 
  begin
    /* По связанным журналам складских операций документа с типом Приход */
    for c in ( select dl2.in_document as rn               /* Заголовок. RN */
                     ,dl.in_document  as prn              /* Спецификация. RN */
                     ,dl.in_unitcode  as dl_in_unitcode   /* Заголовок. Раздел */
                     ,dl2.in_unitcode as dl2_in_unitcode  /* Спецификация. Раздел */
                     ,gs.prn          as gs_prn           /* Приходная партия. RN */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 134301298, ndocument => dl2.in_document  ) as sPlan_Check_Date  /* Спецификация. Дата перепроверки */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 12114824 , ndocument => dl2.in_document  ) as sProd_Date        /* Спецификация. Дата производства */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 8027724  , ndocument => dl2.in_document  ) as sAccept_Type      /* Спецификация. ПРИЕМКА */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 69192082 , ndocument => dl2.in_document  ) as sSupplier_Party   /* Спецификация. Партия поставщика */
                     ,usr_pkg_docs_props_vals.get_val_date( ndoc_prop => 211014548, ndocument => dl2.in_document  ) as dProd_Date        /* Спецификация. Дата произв. (дата) */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 134301298, ndocument => gs.prn ) as sGP_Plan_Check_Date  /* Приходная партия. Дата перепроверки */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 12114824 , ndocument => gs.prn ) as sGP_Prod_Date        /* Приходная партия. Дата производства */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 8027724  , ndocument => gs.prn ) as sGP_Accept_Type      /* Приходная партия. ПРИЕМКА */
                     ,usr_pkg_docs_props_vals.get_val_str ( ndoc_prop => 69192082 , ndocument => gs.prn ) as sGP_Supplier_Party   /* Приходная партия. Партия поставщика */
                 from doclinks       dl
                     ,storeoperjourn soj
                     ,doclinks       dl2
                     ,goodssupply    gs
                where dl.in_document   = nPRN
                  and dl2.out_document = dl.out_document
                  and dl2.in_document != nPRN
                  and soj.rn           = dl2.out_document
                  and soj.oper_type    = 1
                  and gs.rn            =  soj.goodssupply )
    loop
      /* Если заполнено хотя бы одно из свойств доп.данных в спецификации */
      if c.sProd_Date || c.sAccept_Type || c.sSupplier_Party is not null then
        /* Если при этом заполнено хотя бы одно из свойств доп.данных в приходной партии */
        if c.sGP_Prod_Date || c.sGP_Accept_Type || c.sGP_supplier_Party is not null 
        and nvl( usr_pkg_process.process_get, 'null' ) not in ( 'USR_P_DOCS_REPLACE_FACEACC' ) then
          p_exception(0, 'Приходная партия "%s" уже содержит дополнительные данные, исправление невозможно. Удалите дополнительные данные из спецификации. %s%s'
                     ,usr_pkg_goodsparties.goodsparties_get_code( nrn => c.gs_prn, nflagsmart => 1 )
                     ,cr||cr||f_docdescrs_get_description( sunitcode => c.dl2_in_unitcode, ndocument => c.rn  ) 
                     ,cr||cr||f_docdescrs_get_description( sunitcode => c.dl_in_unitcode , ndocument => c.prn ) ); 
        else
          /* Копирование доп.данных из свойств спецификации в приходную партию */
          pkg_docs_props_vals.modify(nproperty   => 12114824
                                    ,sunitcode   => 'GoodsParties'
                                    ,ndocument   => c.gs_prn
                                    ,sstr_value  => c.sProd_Date
                                    ,nnum_value  => null
                                    ,ddate_value => null
                                    ,nrn         => nNumber);
          pkg_docs_props_vals.modify(nproperty   => 8027724
                                    ,sunitcode   => 'GoodsParties'
                                    ,ndocument   => c.gs_prn
                                    ,sstr_value  => c.sAccept_Type
                                    ,nnum_value  => null
                                    ,ddate_value => null
                                    ,nrn         => nNumber);
          pkg_docs_props_vals.modify(nproperty   => 69192082
                                    ,sunitcode   => 'GoodsParties'
                                    ,ndocument   => c.gs_prn
                                    ,sstr_value  => c.sSupplier_Party
                                    ,nnum_value  => null
                                    ,ddate_value => null
                                    ,nrn         => nNumber);
          /* Если в спецификации документа заполнено свойство Дата произв. (дата) */
          if c.dProd_Date is not null then
            /* считывание записи Товарного запаса */
            rGoodsParties := usr_pkg_goodsparties.goodsparties_get(nrn => c.gs_prn);
            /* заполнение параметров */
            rGoodsParties.prod_date := c.dProd_Date;
            /* исправление Товарного запаса */
            usr_pkg_goodsparties.goodsparties_base_update( rrow => rGoodsParties, nmode => 1 );
          end if;
        end if;
      end if;

      /* Дату перепроверки меняем безусловно */
      pkg_docs_props_vals.modify(nproperty   => 134301298
                                ,sunitcode   => 'GoodsParties'
                                ,ndocument   => c.gs_prn
                                ,sstr_value  => c.sPlan_Check_Date
                                ,nnum_value  => null
                                ,ddate_value => null
                                ,nrn         => nNumber);
    end loop;

  END SPEC_PROPS_COPY_TO_GP;
  /*########################################################################################################*/

  procedure CHECK_PREF_NUMB
  /*
  Проверка префикса и номера
  */
  (
   sPREF      in varchar2
  ,sNUMB      in varchar2
  ,dDATE      in date
  ,sNUMBMAX   in varchar2 default null /* Максимальный номер. Если задан, то проверяется, что он равен текущему */
  ) 
  is
    sPref2    pkg_std.tstring := usr_f_trim( sval => sPREF );
    sNumb2    pkg_std.tstring := usr_f_trim( sval => sNUMB );
    sNumbMax2 pkg_std.tstring := usr_f_trim( sval => sNUMBMAX );
  begin
    /* Проверка префикса */
    if cmp_vc2( sPref2, d_year( dDATE ) ) != 1 then
      p_exception(0, 'Префикс <%s> должен равняться четырём цифрам года из поля "Дата".', sPref2 );
    end if;
    
    /* Проверка номера */
    /* Если есть символы или первый ноль */
    if ltrim( sNumb2, '1234567890') is not null 
    or substr( sNumb2, 0, 1) = 0 then
      p_exception(0, 'Номер <%s> должен содержать только цифры, и первым не должен быть ноль.', sNumb2 );
    end if;

    /* Проверка максимального номера */
    /* Если максимальный номер задан в параметре */
    if sNumbMax2 is not null then
      /* Если есть символы или первый ноль */
      if ltrim( sNumbMax2, '1234567890') is not null 
      or substr( sNumbMax2, 0, 1 ) = 0 then
        p_exception(0, 'Максимальный номер <%s> должен содержать только цифры, и первым не должен быть ноль.', sNumbMax2 );
      end if;
      /* Проверка на равенство номера максимальному */
      if cmp_vc2( sNumb2, sNumbMax2 ) != 1 then
        p_exception(0, 'Номер <%s> должен быть равен следующему по порядку номеру <%s>.', sNumb2, sNumbMax2 );
      end if;
    end if;
    
  end CHECK_PREF_NUMB;  
  /*########################################################################################################*/

  procedure STRPLRESJRNL_DELETE
  /*
  Удаление связанных записей журнала резервирования текущего документа
  */
  (
   nRN        in number
  )
  as
  begin
    /* По связанным записям журнала резервирования по местам хранения */
    for c in (
              select dl.out_company, dl.out_document
                from doclinks dl
               where dl.in_document  = nRN
                 and dl.out_unitcode = 'StoragePlacesResJournal'
             )
    loop
      /* удаление */
      P_STRPLRESJRNL_DELETE(nCOMPANY => c.out_company, nRN => c.out_document);
    end loop;
  end STRPLRESJRNL_DELETE;
  /*########################################################################################################*/

  procedure STRPLRESJRNL_BASE_DELETE
  /*
  Удаление связанных записей журнала резервирования текущего документа. Базовая
  */
  (
   nRN        in number
  )
  as
  begin
    /* По связанным записям журнала резервирования по местам хранения */
    for c in ( select out_company, out_document
                 from doclinks
                where in_document  = nRN
                  and out_unitcode = 'StoragePlacesResJournal' )
    loop
      /* удаление */
      p_strplresjrnl_base_delete( ncompany => c.out_company, nrn => c.out_document );
    end loop;
  end STRPLRESJRNL_BASE_DELETE;
  /*########################################################################################################*/

  procedure CLNEVENTS_CHANGE_STATE
  /*
  Документы. Перевод события в следующий статус
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ,sSTATUS    in varchar2
  )
  as
    nClnEvents      pkg_std.tref;
    nClnEventsCRN   pkg_std.tref;
    rV_ClnEvents    v_clnevents%rowtype;
    
    nNumber         pkg_std.tnumber; 
    bBoolean        boolean := false;
  begin
    /* RN события документа по статусной модели */
    nClnEvents := usr_pkg_document.get_clnevents(nflagsmart => 1, nrn => nRN);
    
    /* Если событие найдено */
    if nClnEvents is not null then
      /* Каталог события */
      p_clnevents_exists(ncompany => nCOMPANY, nrn => nClnEvents, ncrn => nClnEventsCRN);

      /* Проверка прав на Каталог события */
      nNumber := usr_pkg_rights.userpriv_check_crn(ncrn => nClnEventsCRN, sauthid => utilizer);

      /* Если нет прав на Каталог события */
      if cmp_num(nNumber, 1) != 1 then
        /* Назначение роли "Техническая. Для считывания данных из представлений" */
        usr_pkg_rights.userroles_link(nroleid => 158177008 /*166068802*/, sauthid => utilizer, nmode => 1);
        /* признак, что назначали роль */
        bBoolean := true;
      end if;

      /* Считывание записи события */
      select * into rV_ClnEvents from v_clnevents where nrn = nClnEvents;
      
      /* Если назначали роль */
      if bBoolean then 
        /* Удаляем */
        usr_pkg_rights.userroles_unlink(nroleid => 158177008 /*166068802*/, sauthid => utilizer, nmode => 1);
      end if;

    /* Если событие НЕ найдено */
    else
      p_exception(0, 'Не найдено событие по статусной модели для документа с RN: %s', nRN);     
    end if;

    /* Установка нового статуса */
    rV_ClnEvents.sevent_stat := sSTATUS;

    /* Перевод события */
    p_clnevents_change_state(ncompany         => rV_ClnEvents.ncompany
                            ,nrn              => rV_ClnEvents.nrn
                            ,sevent_stat      => rV_ClnEvents.sevent_stat
                            ,ssend_client     => rV_ClnEvents.ssend_client
                            ,ssend_division   => rV_ClnEvents.ssend_division
                            ,ssend_post       => rV_ClnEvents.ssend_post
                            ,ssend_perform    => rV_ClnEvents.ssend_perform
                            ,ssend_person     => rV_ClnEvents.ssend_person
                            ,ssend_staffgrp   => rV_ClnEvents.ssend_staffgrp
                            ,ssend_user_group => rV_ClnEvents.ssend_user_group
                            ,ssend_user_name  => rV_ClnEvents.ssend_user_name);
  end CLNEVENTS_CHANGE_STATE;
  /*########################################################################################################*/

  procedure INSERT_FL_TO_SELECTLIST
  /*
  Добавить RN присоединённых документов текущего документа в SELECTLIST
  */
  (
   nRN              in number   /* RN документа, присоединённые документы которого необходимо добавить */
  ,nIDENT           in number
  ,sFLT_CODE_LIST   in varchar2 default null  /* Список типов присоединённых документов, которые необходимо считать через ";" */
  ) 
  is
    nNumber   pkg_std.tnumber; 
  begin
    for c in ( select fl.rn, flu.unitcode
                 from filelinks       fl
                     ,flinktypes      flt
                     ,filelinksunits  flu
                where fl.file_type      = flt.rn
                  and ( strin(ssubstr => flt.code, ssource => sFLT_CODE_LIST, sdelim => ';') = 1 
                      or sFLT_CODE_LIST is null )
                  and flu.filelinks_prn = fl.rn
                  and flu.table_prn     = nRN )
    loop
      p_selectlist_insert(nident    => nIDENT
                         ,ndocument => c.rn
                         ,sunitcode => null
                         ,nrn       => nNumber);
    end loop;             
  end INSERT_FL_TO_SELECTLIST;
  /*########################################################################################################*/

  procedure INSERT_FL_TO_FILE_BUFFER
  /*
  Добавить присоединённе документы текущего документа в FILE_BUFFER
  */
  (
   nRN              in number   /* RN документа, присоединённые документы которого необходимо добавить */
  ,nIDENT           in number
  ,sFLT_CODE_LIST   in varchar2 default null  /* Список типов присоединённых документов, которые необходимо считать через ";" */
  ) 
  is
    nNumber   pkg_std.tnumber; 
  begin
    for c in ( select fl.file_path, fl.bdata, fl.cdata
                 from filelinks       fl
                     ,flinktypes      flt
                     ,filelinksunits  flu
                where fl.file_type      = flt.rn
                  and ( strin(ssubstr => flt.code, ssource => sFLT_CODE_LIST, sdelim => ';') = 1 
                      or sFLT_CODE_LIST is null )
                  and flu.filelinks_prn = fl.rn
                  and flu.table_prn     = nRN )
    loop
      p_file_buffer_insert( nident    => nIDENT
                           ,cfilename => c.file_path
                           ,cdata     => c.cdata
                           ,blobdata  => c.bdata );
    end loop;             
  end INSERT_FL_TO_FILE_BUFFER;
  /*########################################################################################################*/

end USR_PKG_DOCUMENT;
/
