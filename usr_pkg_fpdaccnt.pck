create or replace package USR_PKG_FPDACCNT is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Центры учета, места возникновения затрат". 
  FinPlanAccountCenters   FPDACCNT      FPA
  */
  --#########################################################################################################

  function FPDACCNT_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return FPDACCNT%rowtype;
  --#########################################################################################################

  function FPDACCNT_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2;
  --#########################################################################################################

  procedure FPDACCNT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDACCNT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FPDACCNT;
/
create or replace package body USR_PKG_FPDACCNT is

  --#########################################################################################################

  function FPDACCNT_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return fpdaccnt%rowtype
  is
    rRow fpdaccnt%rowtype;
  begin
    begin
      select * into rRow from fpdaccnt where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FPDACCNT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FPDACCNT')));
    end;
    return(rRow);
  end FPDACCNT_GET;
  --#########################################################################################################

  function FPDACCNT_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2
  is
    sRes  fpdaccnt.code%type;
  begin

    begin
      select code into sRes from fpdaccnt where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FPDACCNT');
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске мнемокода записи с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FPDACCNT')));
    end;

    return(sRes);

  end FPDACCNT_GET_CODE;
  --#########################################################################################################

  procedure FPDACCNT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fpdaccnt%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := FPDACCNT_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    fpdaccnt_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FPDACCNT_AINSERT;
  --#########################################################################################################

  procedure FPDACCNT_BUPDATE
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
  end FPDACCNT_BUPDATE;
  --#########################################################################################################

  procedure FPDACCNT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     fpdaccnt%rowtype;
    
  begin
    /* Считывание
     rRow := fpdaccnt_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    fpdaccnt_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FPDACCNT_AUPDATE;
  --#########################################################################################################

  procedure FPDACCNT_BMOVE_IN
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
  end FPDACCNT_BMOVE_IN;
  --#########################################################################################################

  procedure FPDACCNT_AMOVE_IN
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
    fpdaccnt_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FPDACCNT_AMOVE_IN;
  --#########################################################################################################

  procedure FPDACCNT_BMOVE_OUT
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
  end FPDACCNT_BMOVE_OUT;
  --#########################################################################################################

  procedure FPDACCNT_AMOVE_OUT
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
  end FPDACCNT_AMOVE_OUT;
  --#########################################################################################################

  procedure FPDACCNT_BDELETE
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
  end FPDACCNT_BDELETE;
  --#########################################################################################################

  procedure FPDACCNT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      fpdaccnt%rowtype;
  begin
    null;
    /* Заголовок */  
    /*rRow := fpdaccnt_get(nrn => nRN); */
    
  end FPDACCNT_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_FPDACCNT;
/
