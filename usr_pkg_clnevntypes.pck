create or replace package USR_PKG_CLNEVNTYPES is
  /*
  Package предназначен для работы с разделом "Типы событий".
  ClientEventTypes        CET   -- Типовые события
  ClientEventStatuses     CES   -- Типовые статусы событий
  ClientEventTypesStates  CETS  -- Типовые события. Статусы
  ClientEventTypesNotes   CETN  -- Типовые события. Заголовки примечаний
  */
  --#########################################################################################################

  function CLNEVNTYPES_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN       in number
  ) 
  return CLNEVNTYPES%ROWTYPE;
  --#########################################################################################################

  procedure CLNEVNTYPES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function CLNEVNTYPES_GET_NAME
  /*
  Заголовок. Считывание наименования
  */
  (
   nRN      in number
  ) 
  return varchar2;
  --#########################################################################################################

  procedure CLNEVNTYPES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPES_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPES_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPES_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function CLNEVNTYPSTS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN       in number
  ) 
  return CLNEVNTYPSTS%ROWTYPE;
  --#########################################################################################################

  function CLNEVNTYPSTS_GET_CES_NAME
  /*
  Спецификация. Определение наименования типового статуса по RN статуса типового события
  */
  (
   nRN      in number
  ) 
  return varchar2;
  --#########################################################################################################

  procedure CLNEVNTYPSTS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPSTS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPSTS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPSTS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPSTS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function CLNEVNTYPENOTES_GET
  /*
  Примечания. Считывание
  */
  (
   nRN       in number
  ) 
  return CLNEVNTYPENOTES%ROWTYPE;
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_AINSERT
  /*
  Примечания. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_BUPDATE
  /*
  Примечания. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_AUPDATE
  /*
  Примечания. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_BDELETE
  /*
  Примечания. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_CHECK_BASE
  /*
  Примечания. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_CLNEVNTYPES;
/
create or replace package body USR_PKG_CLNEVNTYPES is

  --#########################################################################################################

  function CLNEVNTYPES_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number
  ) 
  return clnevntypes%rowtype
  is
    rRow clnevntypes%rowtype;
  begin
    begin
      select * into rRow from clnevntypes where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNTYPES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNTYPES')));
    end;
    return(rRow);
  end CLNEVNTYPES_GET;
  --#########################################################################################################

  function CLNEVNTYPES_GET_NAME
  /*
  Заголовок. Считывание наименования
  */
  (
   nRN      in number
  ) 
  return varchar2
  is
    sRes  clnevntypes.evntype_name%type; 
  begin
    begin
      select evntype_name into sRes from clnevntypes where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNTYPES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNTYPES')));
    end;
    return(sRes);
  end CLNEVNTYPES_GET_NAME;
  --#########################################################################################################

  procedure CLNEVNTYPES_AINSERT
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
    clnevntypes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNTYPES_AINSERT;
  --#########################################################################################################

  procedure CLNEVNTYPES_BUPDATE
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
  end CLNEVNTYPES_BUPDATE;
  --#########################################################################################################

  procedure CLNEVNTYPES_AUPDATE
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
    clnevntypes_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end CLNEVNTYPES_AUPDATE;
  --#########################################################################################################

  procedure CLNEVNTYPES_BDELETE
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
  end CLNEVNTYPES_BDELETE;
  --#########################################################################################################

  procedure CLNEVNTYPES_BMOVE_IN
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
  end CLNEVNTYPES_BMOVE_IN;
  --#########################################################################################################

  procedure CLNEVNTYPES_BMOVE_OUT
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
  end CLNEVNTYPES_BMOVE_OUT;
  --#########################################################################################################

  procedure CLNEVNTYPES_CHECK_BASE
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
  end CLNEVNTYPES_CHECK_BASE;
  --#########################################################################################################

  function CLNEVNTYPSTS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN      in number
  ) 
  return clnevntypsts%rowtype
  is
    rRow clnevntypsts%rowtype;
  begin
    begin
      select * into rRow from clnevntypsts where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNTYPSTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNTYPSTS')));
    end;
    return(rRow);
  end CLNEVNTYPSTS_GET;
  --#########################################################################################################

  function CLNEVNTYPSTS_GET_CES_NAME
  /*
  Спецификация. Определение наименования типового статуса по RN статуса типового события
  */
  (
   nRN      in number
  ) 
  return varchar2
  is
    sRes  clnevnstats.evnstat_name%type; 
  begin
    begin
      select ces.evnstat_name
        into sRes
        from clnevntypsts cets
            ,clnevnstats  ces
       where cets.rn = nRN
         and ces.rn  = cets.event_status;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNTYPSTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNTYPSTS')));
    end;
    return(sRes);
  end CLNEVNTYPSTS_GET_CES_NAME;
  --#########################################################################################################

  procedure CLNEVNTYPSTS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */    
    /* Проверка базовая */
    clnevntypsts_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNTYPSTS_AINSERT;
  --#########################################################################################################

  procedure CLNEVNTYPSTS_BUPDATE
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
  end CLNEVNTYPSTS_BUPDATE;
  --#########################################################################################################

  procedure CLNEVNTYPSTS_AUPDATE
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
    clnevntypsts_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNTYPSTS_AUPDATE;
  --#########################################################################################################

  procedure CLNEVNTYPSTS_BDELETE
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
  end CLNEVNTYPSTS_BDELETE;
  --#########################################################################################################

  procedure CLNEVNTYPSTS_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNTYPSTS_CHECK_BASE;
  --#########################################################################################################

  function CLNEVNTYPENOTES_GET
  /*
  Примечания. Считывание записи
  */
  (
   nRN      in number
  ) 
  return clnevntypenotes%rowtype
  is
    rRow clnevntypenotes%rowtype;
  begin
    begin
      select * into rRow from clnevntypenotes where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNTYPENOTES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNTYPENOTES')));
    end;
    return(rRow);
  end CLNEVNTYPENOTES_GET;
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_AINSERT
  /*
  Примечания. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    clnevntypenotes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNTYPENOTES_AINSERT;
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_BUPDATE
  /*
  Примечания. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNTYPENOTES_BUPDATE;
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_AUPDATE
  /*
  Примечания. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    clnevntypenotes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNTYPENOTES_AUPDATE;
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_BDELETE
  /*
  Примечания. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNTYPENOTES_BDELETE;
  --#########################################################################################################

  procedure CLNEVNTYPENOTES_CHECK_BASE
  /*
  Примечания. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNTYPENOTES_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_CLNEVNTYPES;
/
