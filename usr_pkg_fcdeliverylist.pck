create or replace package USR_PKG_FCDELIVERYLIST is
  /*
  Package предназначен для работы с разделом "Комплектации".
  CostDeliveryLists        FCDELIVERYLIST     DL
  CostDeliveryListsSpec    FCDELIVERYLISTSP   DLS
  */
  --#########################################################################################################

  function FCDELIVERYLIST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN       in number
  ) 
  return FCDELIVERYLIST%ROWTYPE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_BWROFF_CREATE
  /*
  Заголовок. Формирование актов списания. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_AWROFF_CREATE
  /*
  Заголовок. Формирование актов списания. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_BTRDPT_MAKE
  /*
  Заголовок. Формирование расходных накладных на отпуск в подразделения. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_ATRDPT_MAKE
  /*
  Заголовок. Формирование расходных накладных на отпуск в подразделения. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLIST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function FCDELIVERYLISTSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN       in number
  ) 
  return FCDELIVERYLISTSP%ROWTYPE;
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FCDELIVERYLIST;
/
create or replace package body USR_PKG_FCDELIVERYLIST is

  --#########################################################################################################

  function FCDELIVERYLIST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcdeliverylist%rowtype
  is
    rRow fcdeliverylist%rowtype;
  begin
    begin
      select * into rRow from fcdeliverylist where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCDELIVERYLIST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCDELIVERYLIST')));
    end;
    return(rRow);
  end FCDELIVERYLIST_GET;
  --#########################################################################################################

  procedure FCDELIVERYLIST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow       fcdeliverylist%rowtype;
    
    nNumber    pkg_std.tnumber; 
    sVrachar   pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := fcdeliverylist_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    fcdeliverylist_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Тип документа "Компл" */
    if rRow.doc_types != 16161963 then
      p_exception(0, 'Тип документа Комплектации <%s> должен быть <%s>.%s'
                 ,get_doctypes_code_id(nflag_smart => 1, nrn => rRow.doc_types)
                 ,get_doctypes_code_id(nflag_smart => 1, nrn => 16161963)
                 ,cr||f_docdescrs_get_description(sunitcode => 'CostDeliveryLists', ndocument => rRow.rn)); 
    end if;

  end FCDELIVERYLIST_AINSERT;
  --#########################################################################################################

  procedure FCDELIVERYLIST_BUPDATE
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
  end FCDELIVERYLIST_BUPDATE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_AUPDATE
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
    fcdeliverylist_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FCDELIVERYLIST_AUPDATE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_BDELETE
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
  end FCDELIVERYLIST_BDELETE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_BMOVE_IN
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
  end FCDELIVERYLIST_BMOVE_IN;
  --#########################################################################################################

  procedure FCDELIVERYLIST_BMOVE_OUT
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
  end FCDELIVERYLIST_BMOVE_OUT;
  --#########################################################################################################

  procedure FCDELIVERYLIST_BWROFF_CREATE
  /*
  Заголовок. Формирование актов списания. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCDELIVERYLIST_BWROFF_CREATE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_AWROFF_CREATE
  /*
  Заголовок. Формирование актов списания. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCDELIVERYLIST_AWROFF_CREATE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_BTRDPT_MAKE
  /*
  Заголовок. Формирование расходных накладных на отпуск в подразделения. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCDELIVERYLIST_BTRDPT_MAKE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_ATRDPT_MAKE
  /*
  Заголовок. Формирование расходных накладных на отпуск в подразделения. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCDELIVERYLIST_ATRDPT_MAKE;
  --#########################################################################################################

  procedure FCDELIVERYLIST_CHECK_BASE
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
  end FCDELIVERYLIST_CHECK_BASE;
  --#########################################################################################################

  function FCDELIVERYLISTSP_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcdeliverylistsp%rowtype
  is
    rRow fcdeliverylistsp%rowtype;
  begin
    begin
      select * into rRow from fcdeliverylistsp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCDELIVERYLISTSP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCDELIVERYLISTSP')));
    end;
    return(rRow);
  end FCDELIVERYLISTSP_GET;
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    fcdeliverylistsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCDELIVERYLISTSP_AINSERT;
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_BUPDATE
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
  end FCDELIVERYLISTSP_BUPDATE;
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_AUPDATE
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
    fcdeliverylistsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCDELIVERYLISTSP_AUPDATE;
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_BDELETE
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
  end FCDELIVERYLISTSP_BDELETE;
  --#########################################################################################################

  procedure FCDELIVERYLISTSP_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow    fcdeliverylistsp%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := fcdeliverylistsp_get(nrn => nRN);*/
    
  end FCDELIVERYLISTSP_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_FCDELIVERYLIST;
/
