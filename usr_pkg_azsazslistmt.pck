create or replace package USR_PKG_AZSAZSLISTMT is

  /*
  Степанов М. 10/09/2025
  Package предназначен для работы с разделом "Склады". 
  AZSListView   AZSAZSLISTMT      DS
  */
  /*#########################################################################################################*/

  function AZSAZSLISTMT_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return AZSAZSLISTMT%rowtype;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW       in azsazslistmt%rowtype
  );
  /*#########################################################################################################*/

end USR_PKG_AZSAZSLISTMT;
/
create or replace package body USR_PKG_AZSAZSLISTMT is

  /*#########################################################################################################*/

  function AZSAZSLISTMT_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return azsazslistmt%rowtype
  is
    rRow azsazslistmt%rowtype;
  begin
    begin
      select * into rRow from azsazslistmt where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'AZSAZSLISTMT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'AZSAZSLISTMT')));
    end;
    return(rRow);
  end AZSAZSLISTMT_GET;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            azsazslistmt%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := AZSAZSLISTMT_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    azsazslistmt_check_base(nrn => nRN, ncompany => nCOMPANY);

  end AZSAZSLISTMT_AINSERT;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BUPDATE
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
  end AZSAZSLISTMT_BUPDATE;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     azsazslistmt%rowtype;
    
  begin
    /* Считывание
     rRow := azsazslistmt_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    azsazslistmt_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AZSAZSLISTMT_AUPDATE;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BMOVE_IN
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
  end AZSAZSLISTMT_BMOVE_IN;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AMOVE_IN
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
    azsazslistmt_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end AZSAZSLISTMT_AMOVE_IN;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BMOVE_OUT
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
  end AZSAZSLISTMT_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_AMOVE_OUT
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
  end AZSAZSLISTMT_AMOVE_OUT;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BDELETE
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
  end AZSAZSLISTMT_BDELETE;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      azsazslistmt%rowtype;
  begin
    null;
    /* Заголовок */  
    /*rRow := azsazslistmt_get(nrn => nRN); */

  end AZSAZSLISTMT_CHECK_BASE;
  /*#########################################################################################################*/

  procedure AZSAZSLISTMT_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW       in azsazslistmt%rowtype
  ) 
  is
  begin
    p_dicstore_base_update(ncompany           => rROW.COMPANY
                          ,nrn                => rROW.RN
                          ,njur_pers          => rROW.JUR_PERS
                          ,snumb              => rROW.AZS_NUMBER
                          ,sname              => rROW.AZS_NAME
                          ,nstore_type        => rROW.STORE_TYPE
                          ,ncurrency          => rROW.CURRENCY
                          ,nkeeper            => rROW.AZS_AGENT
                          ,npbe               => rROW.AZS_PBE
                          ,ndepartment        => rROW.DEPARTMENT
                          ,saddress           => rROW.AZS_ADDRESS
                          ,nlock_sign         => rROW.LOCK_SIGN
                          ,ncalc_type         => rROW.CALC_TYPE
                          ,nvol_calc_type     => rROW.VOL_CALC_TYPE
                          ,nwgt_calc_type     => rROW.WGT_CALC_TYPE
                          ,nprocess_sign      => rROW.PROCESS_SIGN
                          ,ndistribution_sign => rROW.DISTRIBUTION_SIGN
                          ,njur_pers_sign     => rROW.JUR_PERS_SIGN
                          ,nagent             => rROW.AGENT
                          ,nstkind            => rROW.STKIND
                          ,nroute_sign        => rROW.ROUTE_SIGN
                          ,nstoper_in         => rROW.STOPER_IN
                          ,nstoper_out        => rROW.STOPER_OUT
                          ,nshiptype          => rROW.SHIPTYPE);
  end AZSAZSLISTMT_BASE_UPDATE;
  /*#########################################################################################################*/
end USR_PKG_AZSAZSLISTMT;
/
