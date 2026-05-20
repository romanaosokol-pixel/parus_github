create or replace package USR_PKG_DMSDOMAINS is
  /*
  Package предназначен для работы с разделом "Домены метаданных".
  DMSDomains            DMSDOMAINS     DM      Домены метаданных
  DMSDomainsEnumValues  DMSENUMVALUES  DMV     Домены метаданных (перечисляемые значения)

  create public synonym USR_PKG_DMSDOMAINS for USR_PKG_DMSDOMAINS;
  grant execute on USR_PKG_DMSDOMAINS to public;
  */
  /*#########################################################################################################*/

  function DMSDOMAINS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return DMSDOMAINS%ROWTYPE;
  /*#########################################################################################################*/

  function DMSDOMAINS_GET_NAME_BY_CODE
  /*
  Заголовок. Поиск наименования по коду
  */
  (
   nFLAGSMART   in number default 0
  ,sCODE        in varchar2
  ) 
  return varchar2;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/


  procedure DMSDOMAINS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DMSDOMAINS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DMSDOMAINS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DMSDOMAINS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DMSDOMAINS_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_dmsdomains%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure DMSDOMAINS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое 
  */
  (
   rROW      in dmsdomains%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  function DMSENUMVALUES_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return DMSENUMVALUES%ROWTYPE;
  /*#########################################################################################################*/

  function DMSENUMVALUES_GET_SVAL_BY_NVAL
  /*
  Спецификация. Считывание записи
  */
  (
   nFLAGSMART   in number default 0
  ,sCODE        in varchar2 /* STATE_VK, UDO_SIGN_SERTIFRES */
  ,nVALUE       in number
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function DMSENUMVALUES_GET_NVAL_BY_SVAL
  /*
  Спецификация. Поиск числового значения по строковому
  */
  (
   nFLAGSMART   in number default 0
  ,sCODE        in varchar2 /* STATE_VK, UDO_SIGN_SERTIFRES */
  ,sVALUE       in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  procedure DMSENUMVALUES_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure DMSENUMVALUES_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

end USR_PKG_DMSDOMAINS;
/
create or replace package body USR_PKG_DMSDOMAINS is

  /*#########################################################################################################*/

  function DMSDOMAINS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return dmsdomains%rowtype
  is
    rRow dmsdomains%rowtype;
  begin
    begin
      select * into rRow from dmsdomains where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'DMSDOMAINS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DMSDOMAINS')));
    end;
    return(rRow);
  end DMSDOMAINS_GET;
  /*#########################################################################################################*/

  function DMSDOMAINS_GET_NAME_BY_CODE
  /*
  Заголовок. Поиск наименования по коду
  */
  (
   nFLAGSMART   in number default 0
  ,sCODE        in varchar2
  ) 
  return varchar2
  is
    nRef        pkg_std.tref; 
    sVarchar    pkg_std.tstring; 
  begin
    /* RN по коду */
    find_dmsdomains_code( nflag_smart  => nFLAGSMART
                         ,nflag_option => nFLAGSMART
                         ,scode        => sCODE
                         ,nrn          => nRef );
    /* Наименование по RN */
    sVarchar := get_dmsdomains_name_id( nflag_smart => nFLAGSMART, nrn => nRef );
    /* Результат*/
    return( sVarchar );

  end DMSDOMAINS_GET_NAME_BY_CODE;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow       dmsdomains%rowtype;
  begin
    /* Считывание */
    rRow := dmsdomains_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    dmsdomains_check_base(nrn => nRN, ncompany => nCOMPANY);

  end DMSDOMAINS_AINSERT;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_BUPDATE
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
  end DMSDOMAINS_BUPDATE;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_AUPDATE
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
    dmsdomains_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end DMSDOMAINS_AUPDATE;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN      in number
  ,nCOMPANY in number
  ) 
  is
  begin
    null;
  end DMSDOMAINS_BDELETE;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DMSDOMAINS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_dmsdomains%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    null;
  end DMSDOMAINS_UPDATE;
  /*#########################################################################################################*/

  procedure DMSDOMAINS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое 
  */
  (
   rROW      in dmsdomains%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    null;
  end DMSDOMAINS_BASE_UPDATE;
  /*#########################################################################################################*/

  function DMSENUMVALUES_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return dmsenumvalues%rowtype
  is
    rRow dmsenumvalues%rowtype;
  begin
    begin
      select * into rRow from dmsenumvalues where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'DMSDomainsEnumValues');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => 'DMSDomainsEnumValues'));
    end;
    return(rRow);
  end DMSENUMVALUES_GET;
  /*#########################################################################################################*/

  function DMSENUMVALUES_GET_SVAL_BY_NVAL
  /*
  Спецификация. Поиск строкового значения по числовому
  */
  (
   nFLAGSMART   in number default 0
  ,sCODE        in varchar2 /* STATE_VK, UDO_SIGN_SERTIFRES */
  ,nVALUE       in number
  ) 
  return varchar2
  is
    sVarchar              pkg_std.tstring; 
  begin
    /* Проверка */
    if sCODE is null then
      p_exception( nFLAGSMART, 'Не задано значение параметра "sCODE" при поиске в разделе "%s".'
                 ,f_unitlist_getname( sunitcode => 'DMSDomainsEnumValues' ) );
    end if;
    if nVALUE is null then
      p_exception( nFLAGSMART, 'Не задано значение параметра "nVALUE" при поиске в разделе "%s".'
                 ,f_unitlist_getname( sunitcode => 'DMSDomainsEnumValues' ) );
    end if;
    /* Поиск */
    begin
      select svalue_text
        into sVarchar
        from v_dmsdomains_ex 
       where scode      = DMSENUMVALUES_GET_SVAL_BY_NVAL.sCODE 
         and nvalue_num = nVALUE;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найдено значение словаря "%s" где "nvalue_num" равно "%s" в разделе <%s>.'
                   ,dmsdomains_get_name_by_code( nflagsmart => 1, scode => sCODE ), nVALUE
                   ,f_unitlist_getname( sunitcode => 'DMSDomainsEnumValues' ) );
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного значения словаря "%s" где "nvalue_num" равно "%s" в разделе <%s>.'
                   ,dmsdomains_get_name_by_code( nflagsmart => 1, scode => sCODE ), nVALUE
                   ,f_unitlist_getname( sunitcode => 'DMSDomainsEnumValues' ) );
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске значения словаря "%s" где "nvalue_num" равно "%s" в разделе <%s>.'
                   ,dmsdomains_get_name_by_code( nflagsmart => 1, scode => sCODE ), nVALUE
                   ,f_unitlist_getname( sunitcode => 'DMSDomainsEnumValues' ) );
    end;
    /* Результат */
    return( sVarchar );

  end DMSENUMVALUES_GET_SVAL_BY_NVAL;
  /*#########################################################################################################*/

  function DMSENUMVALUES_GET_NVAL_BY_SVAL
  /*
  Спецификация. Поиск числового значения по строковому
  */
  (
   nFLAGSMART   in number default 0
  ,sCODE        in varchar2 /* STATE_VK, UDO_SIGN_SERTIFRES */
  ,sVALUE       in varchar2
  ) 
  return number
  is
    nNumber              pkg_std.tnumber; 
  begin
    /* Проверка */
    if sCODE is null then
      p_exception( nFLAGSMART, 'Не задано значение параметра "sCODE" при поиске в разделе "%s".', f_unitlist_getname( sunitcode => 'DMSENUMVALUES' ) );
    end if;
    if sVALUE is null then
      p_exception( nFLAGSMART, 'Не задано значение параметра "sVALUE" при поиске в разделе "%s".', f_unitlist_getname( sunitcode => 'DMSENUMVALUES' ) );
    end if;
    /* Поиск */
    begin
      select nvalue_num
        into nNumber
        from v_dmsdomains_ex 
       where scode       = DMSENUMVALUES_GET_NVAL_BY_SVAL.sCODE 
         and svalue_text = sVALUE;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найдено значение словаря "%s" где "svalue_text" равно "%s" в разделе <%s>.'
                   ,dmsdomains_get_name_by_code( nflagsmart => 1, scode => sCODE ), sVALUE
                   ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'DMSENUMVALUES' ) ) );
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного значения словаря "%s" где "svalue_text" равно "%s" в разделе <%s>.'
                   ,dmsdomains_get_name_by_code( nflagsmart => 1, scode => sCODE ), sVALUE
                   ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'DMSENUMVALUES' ) ) );
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске значения словаря "%s" где "svalue_text" равно "%s" в разделе <%s>.'
                   ,dmsdomains_get_name_by_code( nflagsmart => 1, scode => sCODE ), sVALUE
                   ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'DMSENUMVALUES' ) ) );
    end;
    /* Результат */
    return( nNumber );

  end DMSENUMVALUES_GET_NVAL_BY_SVAL;
  /*#########################################################################################################*/

  procedure DMSENUMVALUES_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          dmsenumvalues%rowtype;
  begin
    null;    
  end DMSENUMVALUES_AINSERT;
  /*#########################################################################################################*/

  procedure DMSENUMVALUES_BDELETE
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
  end DMSENUMVALUES_BDELETE;
  /*#########################################################################################################*/

end USR_PKG_DMSDOMAINS;
/
