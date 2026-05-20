create or replace package USR_PKG_INS_DEPARTMENT is
  /*
  Степанов М. 13/09/2023
  Package предназначен для работы с разделом "Штатные подразделения". 
  INS_DEPARTMENT           DIV
  */
  --#########################################################################################################

  function INS_DEPARTMENT_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return ins_department%rowtype;
  --#########################################################################################################

  procedure INS_DEPARTMENT_ASDIV_INSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure INS_DEPARTMENT_BSDIV_UPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure INS_DEPARTMENT_ASDIV_UPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure INS_DEPARTMENT_BSDIV_MOVE
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure INS_DEPARTMENT_ASDIV_MOVE
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure INS_DEPARTMENT_BSDIV_DELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure INS_DEPARTMENT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function INS_DEPARTMENT_GET_CODE_BY_RN
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number 
  ) 
  return varchar2;
  --#########################################################################################################

end USR_PKG_INS_DEPARTMENT;
/
create or replace package body USR_PKG_INS_DEPARTMENT is

  --#########################################################################################################

  function INS_DEPARTMENT_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return ins_department%rowtype
  is
    rRow ins_department%rowtype;
  begin
    begin
      select T.*
        into rRow
        from ins_department t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'INS_DEPARTMENT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INS_DEPARTMENT')));
    end;
    return(rRow);
  end INS_DEPARTMENT_GET;
  --#########################################################################################################

  procedure INS_DEPARTMENT_ASDIV_INSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            ins_department%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := INS_DEPARTMENT_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    ins_department_check_base(nrn => nRN, ncompany => nCOMPANY);

  end INS_DEPARTMENT_ASDIV_INSERT;
  --#########################################################################################################

  procedure INS_DEPARTMENT_BSDIV_UPDATE
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
  end INS_DEPARTMENT_BSDIV_UPDATE;
  --#########################################################################################################

  procedure INS_DEPARTMENT_ASDIV_UPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     ins_department%rowtype;
    
  begin
    /* Считывание
     rRow := ins_department_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    ins_department_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end INS_DEPARTMENT_ASDIV_UPDATE;
  --#########################################################################################################

  procedure INS_DEPARTMENT_BSDIV_MOVE
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        ins_department%rowtype;
    sCatalog    acatalog.name%type;
    nNumber     pkg_std.tnumber;  
  begin
    null;
  end INS_DEPARTMENT_BSDIV_MOVE;
  --#########################################################################################################

  procedure INS_DEPARTMENT_ASDIV_MOVE
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        ins_department%rowtype;
  begin
    null;
  end INS_DEPARTMENT_ASDIV_MOVE;
  --#########################################################################################################

  procedure INS_DEPARTMENT_BSDIV_DELETE
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
  end INS_DEPARTMENT_BSDIV_DELETE;
  --#########################################################################################################

  procedure INS_DEPARTMENT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     ins_department%rowtype;
  begin
    null;
    /* Заголовок */  
    /* rRow := ins_department_get(nrn => nRN); */
    
  end INS_DEPARTMENT_CHECK_BASE;
  --#########################################################################################################

  function INS_DEPARTMENT_GET_CODE_BY_RN
  /*
  Заголовок. Поиск мнемокода по RN
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
      select t.code
        into sResult
        from ins_department t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'INS_DEPARTMENT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INS_DEPARTMENT')));
    end;
    return(sResult);
  end INS_DEPARTMENT_GET_CODE_BY_RN;
--#########################################################################################################

end USR_PKG_INS_DEPARTMENT;
/
