create or replace package USR_PKG_FINSTATE is
  /*
  Степанов М. 18/09/2024
  Package предназначен для работы с разделом " Состояния финансовых показателей". 
  FinancialStates   FINSTATE      FS
  */
  --#########################################################################################################

  function FINSTATE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return FINSTATE%rowtype;
  --#########################################################################################################

  function FINSTATE_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2;
  --#########################################################################################################

  procedure FINSTATE_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINSTATE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FINSTATE;
/
create or replace package body USR_PKG_FINSTATE is

  --#########################################################################################################

  function FINSTATE_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return finstate%rowtype
  is
    rRow finstate%rowtype;
  begin
    begin
      select * into rRow from finstate where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FINSTATE');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FINSTATE')));
    end;
    return(rRow);
  end FINSTATE_GET;
  --#########################################################################################################

  function FINSTATE_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2
  is
    sRes  finstate.code%type;
  begin
    begin
      select code into sRes from finstate where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FINSTATE');
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске мнемокода записи с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FINSTATE')));
    end;
    return(sRes);
  end FINSTATE_GET_CODE;
  --#########################################################################################################

  procedure FINSTATE_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            finstate%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := FINSTATE_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    finstate_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FINSTATE_AINSERT;
  --#########################################################################################################

  procedure FINSTATE_BUPDATE
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
  end FINSTATE_BUPDATE;
  --#########################################################################################################

  procedure FINSTATE_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     finstate%rowtype;
    
  begin
    /* Считывание
     rRow := finstate_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    finstate_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FINSTATE_AUPDATE;
  --#########################################################################################################

  procedure FINSTATE_BMOVE_IN
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
  end FINSTATE_BMOVE_IN;
  --#########################################################################################################

  procedure FINSTATE_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    finstate_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FINSTATE_AMOVE_IN;
  --#########################################################################################################

  procedure FINSTATE_BMOVE_OUT
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
  end FINSTATE_BMOVE_OUT;
  --#########################################################################################################

  procedure FINSTATE_AMOVE_OUT
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
  end FINSTATE_AMOVE_OUT;
  --#########################################################################################################

  procedure FINSTATE_BDELETE
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
  end FINSTATE_BDELETE;
  --#########################################################################################################

  procedure FINSTATE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      finstate%rowtype;
  begin
    null;
    /* Заголовок */  
    /*rRow := finstate_get(nrn => nRN); */
    
  end FINSTATE_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_FINSTATE;
/
