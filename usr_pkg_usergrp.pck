create or replace package USR_PKG_USERGRP is
  /*
  Package предназначен для работы с разделом "Группы пользователей".
  UserGroups                        USERGRP         UGP
  UserGroupsSpecs                   USERGRPSP       UGPS
  */
  /*#########################################################################################################*/

  function USERGRP_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return USERGRP%ROWTYPE;
  /*#########################################################################################################*/

  function USERGRP_GET_MAIL_LIST
  /*
  Заголовок. Получение e-mail участников группы
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return varchar2;
  /*#########################################################################################################*/

  procedure USERGRP_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRP_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRP_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRP_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRP_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRP_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRP_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  function USERGRPSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return USERGRPSP%ROWTYPE;
  /*#########################################################################################################*/

  procedure USERGRPSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRPSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRPSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRPSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure USERGRPSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

end USR_PKG_USERGRP;
/
create or replace package body USR_PKG_USERGRP is

  /*#########################################################################################################*/

  function USERGRP_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return usergrp%rowtype
  is
    rRow usergrp%rowtype;
  begin
    begin
      select * into rRow from usergrp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'USERGRP' );
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERGRP'))||'>.');
    end;
    return(rRow);
  end USERGRP_GET;
  /*#########################################################################################################*/

  function USERGRP_GET_MAIL_LIST
  /*
  Заголовок. Получение e-mail участников группы
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return varchar2
  is
    sRes   pkg_std.tstring; 
  begin
    begin
      select listagg(trim(al.mail),';') within group (order by al.mail)
        into sRes
        from usergrpsp  t
        join userlist   ul on ul.authid      = t.authid
        join clnpersons cp on cp.pers_authid = ul.authid
        join agnlist    al on al.rn          = cp.pers_agent
       where t.prn = nRN;
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании e-mail сотрудников из Группы пользователей с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERGRP'))||'>.');
    end;

    return( sRes );

  end USERGRP_GET_MAIL_LIST;
  /*#########################################################################################################*/

  procedure USERGRP_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            usergrp%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow      := usergrp_get(nRN);*/
  end USERGRP_AINSERT;
  /*#########################################################################################################*/

  procedure USERGRP_BUPDATE
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
    /* Считывание  */
    
    /* ПРОВЕРКИ */

  end USERGRP_BUPDATE;
  /*#########################################################################################################*/

  procedure USERGRP_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow            usergrp%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := usergrp_get(nRN);*/

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    /*usergrp_check_base(nrn => rRow.rn, ncompany => rRow.company);*/
    
  end USERGRP_AUPDATE;
  /*#########################################################################################################*/

  procedure USERGRP_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              usergrp%rowtype;
  begin
    /* Заголовок */
    rRow := usergrp_get(nrn => nRN);

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */

  end USERGRP_BDELETE;
  /*#########################################################################################################*/

  procedure USERGRP_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERGRP_BMOVE_IN;
  /*#########################################################################################################*/

  procedure USERGRP_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end USERGRP_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure USERGRP_CHECK_BASE
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
  end USERGRP_CHECK_BASE;
  /*#########################################################################################################*/

  function USERGRPSP_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return usergrpsp%rowtype
  is
    rRow usergrpsp%rowtype;
  begin
    begin
      select * into rRow from usergrpsp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'USERGRPSP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERGRPSP'))||'>.');
    end;
    return(rRow);
  end USERGRPSP_GET;
  /*#########################################################################################################*/

  procedure USERGRPSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*usergrpsp_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end USERGRPSP_AINSERT;
  /*#########################################################################################################*/

  procedure USERGRPSP_BUPDATE
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
  end USERGRPSP_BUPDATE;
  /*#########################################################################################################*/

  procedure USERGRPSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*usergrpsp_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end USERGRPSP_AUPDATE;
  /*#########################################################################################################*/

  procedure USERGRPSP_BDELETE
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
  end USERGRPSP_BDELETE;
  /*#########################################################################################################*/

  procedure USERGRPSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              usergrpsp%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow            := usergrpsp_get(nrn => nRN);
    rIncomeFromDeps := usergrp_get(nrn => rRow.prn);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКА */

  end USERGRPSP_CHECK_BASE;
  /*#########################################################################################################*/

end USR_PKG_USERGRP;
/
