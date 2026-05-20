create or replace package USR_PKG_FPDARTCL is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Элементы дохода и расхода, статьи затрат". 
  FinPlanArticles   FPDARTCL      FPD
  */
  --#########################################################################################################

  function FPDARTCL_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return FPDARTCL%rowtype;
  --#########################################################################################################

  function FPDARTCL_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2;
  --#########################################################################################################

  procedure FPDARTCL_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FPDARTCL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FPDARTCL;
/
create or replace package body USR_PKG_FPDARTCL is

  --#########################################################################################################

  function FPDARTCL_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return fpdartcl%rowtype
  is
    rRow fpdartcl%rowtype;
  begin
    begin
      select * into rRow from fpdartcl where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FPDARTCL');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FPDARTCL')));
    end;
    return(rRow);
  end FPDARTCL_GET;
  --#########################################################################################################

  function FPDARTCL_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2
  is
    sRes  fpdartcl.code%type;
  begin
    begin
      select code into sRes from fpdartcl where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FPDARTCL');
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске мнемокода записи с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FPDARTCL')));
    end;
    return(sRes);
  end FPDARTCL_GET_CODE;
  --#########################################################################################################

  procedure FPDARTCL_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fpdartcl%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := FPDARTCL_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    fpdartcl_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FPDARTCL_AINSERT;
  --#########################################################################################################

  procedure FPDARTCL_BUPDATE
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
  end FPDARTCL_BUPDATE;
  --#########################################################################################################

  procedure FPDARTCL_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     fpdartcl%rowtype;
    
  begin
    /* Считывание
     rRow := fpdartcl_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    fpdartcl_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FPDARTCL_AUPDATE;
  --#########################################################################################################

  procedure FPDARTCL_BMOVE_IN
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
  end FPDARTCL_BMOVE_IN;
  --#########################################################################################################

  procedure FPDARTCL_AMOVE_IN
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
    fpdartcl_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FPDARTCL_AMOVE_IN;
  --#########################################################################################################

  procedure FPDARTCL_BMOVE_OUT
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
  end FPDARTCL_BMOVE_OUT;
  --#########################################################################################################

  procedure FPDARTCL_AMOVE_OUT
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
  end FPDARTCL_AMOVE_OUT;
  --#########################################################################################################

  procedure FPDARTCL_BDELETE
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
  end FPDARTCL_BDELETE;
  --#########################################################################################################

  procedure FPDARTCL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      fpdartcl%rowtype;
  begin
    null;
    /* Заголовок */  
    /*rRow := fpdartcl_get(nrn => nRN); */
    
  end FPDARTCL_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_FPDARTCL;
/
