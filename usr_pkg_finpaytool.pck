create or replace package USR_PKG_FINPAYTOOL is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Инструменты оплаты". 
  FinancialPayTools   FINPAYTOOL      FPT
  */
  --#########################################################################################################

  function FINPAYTOOL_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return FINPAYTOOL%rowtype;
  --#########################################################################################################

  function FINPAYTOOL_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2;
  --#########################################################################################################

  function FINPAYTOOL_GET_BY_AGNACC
  /*
  Заголовок. Поиск RN по RN реквизитов контрагента
  */
  (
   nAGNACC      in number
  ,nFLAGSMART   in number default 0
  ) 
  return number;
  --#########################################################################################################

  procedure FINPAYTOOL_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FINPAYTOOL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FINPAYTOOL;
/
create or replace package body USR_PKG_FINPAYTOOL is

  --#########################################################################################################

  function FINPAYTOOL_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return finpaytool%rowtype
  is
    rRow finpaytool%rowtype;
  begin
    begin
      select * into rRow from finpaytool where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FINPAYTOOL');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FINPAYTOOL')));
    end;
    return(rRow);
  end FINPAYTOOL_GET;
  --#########################################################################################################

  function FINPAYTOOL_GET_CODE
  /*
  Заголовок. Поиск мнемокода по RN
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return varchar2
  is
    sRes  finpaytool.code%type;
  begin
    begin
      select code into sRes from finpaytool where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FINPAYTOOL');
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске мнемокода записи с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FINPAYTOOL')));
    end;
    return(sRes);
  end FINPAYTOOL_GET_CODE;
  --#########################################################################################################

  function FINPAYTOOL_GET_BY_AGNACC
  /*
  Заголовок. Поиск RN по RN реквизитов контрагента
  */
  (
   nAGNACC      in number
  ,nFLAGSMART   in number default 0
  ) 
  return number
  is
    nRes  pkg_std.tref; 
  begin
    begin
      select rn into nRes from finpaytool where payer_acc = nAGNACC;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найден инструмент оплаты по реквизиту контрагента с RN <%s>.', nAGNACC );
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного инструмента оплаты по реквизиту контрагента с RN <%s>.', nAGNACC );
      when others then
        p_exception( 0, 'Неопределённая ситуация при поиске инструмента оплаты по реквизиту контрагента с RN <%s>.', nAGNACC );
    end;
    return(nRes);
  end FINPAYTOOL_GET_BY_AGNACC;
  --#########################################################################################################

  procedure FINPAYTOOL_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            finpaytool%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := FINPAYTOOL_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    finpaytool_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FINPAYTOOL_AINSERT;
  --#########################################################################################################

  procedure FINPAYTOOL_BUPDATE
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
  end FINPAYTOOL_BUPDATE;
  --#########################################################################################################

  procedure FINPAYTOOL_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     finpaytool%rowtype;
    
  begin
    /* Считывание
     rRow := finpaytool_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    finpaytool_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FINPAYTOOL_AUPDATE;
  --#########################################################################################################

  procedure FINPAYTOOL_BMOVE_IN
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
  end FINPAYTOOL_BMOVE_IN;
  --#########################################################################################################

  procedure FINPAYTOOL_AMOVE_IN
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
    finpaytool_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FINPAYTOOL_AMOVE_IN;
  --#########################################################################################################

  procedure FINPAYTOOL_BMOVE_OUT
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
  end FINPAYTOOL_BMOVE_OUT;
  --#########################################################################################################

  procedure FINPAYTOOL_AMOVE_OUT
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
  end FINPAYTOOL_AMOVE_OUT;
  --#########################################################################################################

  procedure FINPAYTOOL_BDELETE
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
  end FINPAYTOOL_BDELETE;
  --#########################################################################################################

  procedure FINPAYTOOL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      finpaytool%rowtype;
  begin
    /* Заголовок */  
    rRow := finpaytool_get(nrn => nRN); 

    for c in ( select t.code, t.payer_acc
                 from finpaytool t
                where t.rn       != rRow.rn
                  and t.payer_acc = rRow.payer_acc )
    loop
      p_exception(0, 'Уже существует инструмент оплаты "%s" с банковским реквизитом "%s".'
                  ,c.code, usr_pkg_agnlist.agnacc_get_code_id( nflag_smart => 1, nrn => rRow.payer_acc ) );
    end loop;                  

  end FINPAYTOOL_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_FINPAYTOOL;
/
