create or replace package USR_PKG_BANKDOCS is
  /*
  Степанов М. 01/11/2023
  Для работы с разделом "Банковские документы". 
  BankDocuments   BD
  */
  --#########################################################################################################

  function BANKDOCS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return BANKDOCS%rowtype;
  --#########################################################################################################

  procedure BANKDOCS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_BMAKE_PAY
  /*
  Заголовок. Проверка до формирования платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_AMAKE_PAY
  /*
  Заголовок. Проверка после формирования платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure BANKDOCS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
end USR_PKG_BANKDOCS;
/
create or replace package body USR_PKG_BANKDOCS is

  --#########################################################################################################

  function BANKDOCS_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return bankdocs%rowtype
  is
    rRow bankdocs%rowtype;
  begin
    begin
      select T.*
        into rRow
        from bankdocs t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'BANKDOCS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BANKDOCS')));
    end;
    return(rRow);
  end BANKDOCS_GET;
  --#########################################################################################################

  procedure BANKDOCS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            bankdocs%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := BANKDOCS_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    bankdocs_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BANKDOCS_AINSERT;
  --#########################################################################################################

  procedure BANKDOCS_BUPDATE
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
  end BANKDOCS_BUPDATE;
  --#########################################################################################################

  procedure BANKDOCS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     bankdocs%rowtype;
  begin
    /* Считывание
     rRow := bankdocs_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    bankdocs_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end BANKDOCS_AUPDATE;
  --#########################################################################################################

  procedure BANKDOCS_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end BANKDOCS_BMOVE_IN;
  --#########################################################################################################

  procedure BANKDOCS_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end BANKDOCS_AMOVE_IN;
  --#########################################################################################################

  procedure BANKDOCS_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end BANKDOCS_BMOVE_OUT;
  --#########################################################################################################

  procedure BANKDOCS_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end BANKDOCS_AMOVE_OUT;
  --#########################################################################################################

  procedure BANKDOCS_BDELETE
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
  end BANKDOCS_BDELETE;
  --#########################################################################################################

  procedure BANKDOCS_BMAKE_PAY
  /*
  Заголовок. Проверка до формирования платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     bankdocs%rowtype;
  begin
    null;
  end BANKDOCS_BMAKE_PAY;
  --#########################################################################################################

  procedure BANKDOCS_AMAKE_PAY
  /*
  Заголовок. Проверка после формирования платежей
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        bankdocs%rowtype;
    sVarchar    pkg_std.tstring; 
    nNumber     pkg_std.tnumber; 
  begin
    /* По сформированным документам */
    for c in (select * from inhierbuff_rec where authid = utilizer) 
    loop
      /* проверка заголовка */
      usr_pkg_paynotes.paynotes_ainsert(nrn => c.out_document0, ncompany => nCOMPANY);
    end loop;
    
  end BANKDOCS_AMAKE_PAY;
  --#########################################################################################################

  procedure BANKDOCS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      bankdocs%rowtype;
  begin
    null;
    
  end BANKDOCS_CHECK_BASE;
  --#########################################################################################################
end USR_PKG_BANKDOCS;
/
