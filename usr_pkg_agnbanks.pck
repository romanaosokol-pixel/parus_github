create or replace package USR_PKG_AGNBANKS is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Банковские учреждения". 
  AGNBANKS              AGNBANKS        AGB
  */
  --#########################################################################################################

  function AGNBANKS_GET
  /*
  Банковские учреждения. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnbanks%rowtype;
  --#########################################################################################################

  procedure AGNBANKS_AINSERT
  /*
  Банковские учреждения. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure AGNBANKS_BUPDATE
  /*
  Банковские учреждения. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure AGNBANKS_AUPDATE
  /*
  Банковские учреждения. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure AGNBANKS_BDELETE
  /*
  Банковские учреждения. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure AGNBANKS_CHECK_BASE
  /*
  Банковские учреждения. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_AGNBANKS;
/
create or replace package body USR_PKG_AGNBANKS is

  --#########################################################################################################

  function AGNBANKS_GET
  /*
  Банковские учреждения. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return agnbanks%rowtype
  is
    rRow agnbanks%rowtype;
  begin
    begin
      select * into rRow from agnbanks where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'AGNBANKS');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'AGNBANKS'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end AGNBANKS_GET;
  --#########################################################################################################

  procedure AGNBANKS_AINSERT
  /*
  Банковские учреждения. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    agnbanks_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNBANKS_AINSERT;
  --#########################################################################################################

  procedure AGNBANKS_BUPDATE
  /*
  Банковские учреждения. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end AGNBANKS_BUPDATE;
  --#########################################################################################################

  procedure AGNBANKS_AUPDATE
  /*
  Банковские учреждения. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    agnbanks_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AGNBANKS_AUPDATE;
  --#########################################################################################################

  procedure AGNBANKS_BDELETE
  /*
  Банковские учреждения. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end AGNBANKS_BDELETE;
  --#########################################################################################################

  procedure AGNBANKS_CHECK_BASE
  /*
  Банковские учреждения. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     agnbanks%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := agnbanks_get(nrn => nRN); */

    /* ПРОВЕРКИ */

  end AGNBANKS_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_AGNBANKS;
/
