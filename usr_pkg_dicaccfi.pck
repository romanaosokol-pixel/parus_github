create or replace package USR_PKG_DICACCFI IS
  /*
  Package предназначен для работы с разделом "Входящие счета-фактуры". Степанов М. 25/03/2026
  AccountFactInput       DICACCFI   ACFI
  AccountFactInputSlave  DICLACFI   LACFI
  */
  /* ######################################################################################################### */

  function DICACCFI_GET
  /*
  Заголовок. Считывание
  */
  (
   NRN       in number
  ) 
  return DICACCFI%ROWTYPE;
  /* ######################################################################################################### */

  procedure DICACCFI_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICACCFI_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICACCFI_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICACCFI_AMAKEININVOICE
  /*
  Заголовок. Формирование приходной накладной. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICACCFI_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICACCFI_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICACCFI_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rV_ROW         in v_dicaccfi%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure DICACCFI_MAKEININVOICE
  /*
  Заголовок. Формирование приходной накладной
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,dDATE            in date    /* дата накладной */
  ,nFLAG_NULLREC    in number  /* признак формирования накладных без спецификаций (null или 0 - нет, 1 - да) */
  ,nFLAG_QUANTREC   in number  /* признак формирования спецификаций (null или 0 - все, 1 - с кол-вом) */
  ,nTRUE_REC        out number /* признак cформирования хотя бы одной записи (null - ошибка, 0 - нет, >=1 - да) */
  );
  /* ######################################################################################################### */

  procedure DICACCFI_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW           in dicaccfi%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

  function DICLACFI_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   NRN       in number
  ) 
  return DICLACFI %ROWTYPE;
  /* ######################################################################################################### */

  procedure DICLACFI_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICLACFI_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICLACFI_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICLACFI_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICLACFI_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure DICLACFI_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW     in diclacfi%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN      out number
  );
  /* ######################################################################################################### */

  procedure DICLACFI_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW         in diclacfi%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

end USR_PKG_DICACCFI;
/
create or replace package body USR_PKG_DICACCFI is

  /* ######################################################################################################### */

  function DICACCFI_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number 
  ) 
  return dicaccfi%rowtype
  is
    rRow dicaccfi%rowtype;
  begin
    begin
      select * into rRow from dicaccfi where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(1, 'DICACCFI'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>', nRN, f_unitlist_getname(get_unitlist_code_table(1, 'DICACCFI')));
    end;
    return(rRow);
  end DICACCFI_GET;
  /* ######################################################################################################### */

  procedure DICACCFI_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow     dicaccfi%rowtype;*/
  begin
    /* Заголовок */
    /*rRow := dicaccfi_get(nRN);*/

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    dicaccfi_check_base(nrn => nRN, ncompany => nCOMPANY);

  end DICACCFI_AINSERT;
  /* ######################################################################################################### */

  procedure DICACCFI_BUPDATE
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
    /* Считывание */
    /*usr_pkg_pub_const.rdicaccfi := dicaccfi_get(nrn => nRN); */
  end DICACCFI_BUPDATE;
  /* ######################################################################################################### */

  procedure DICACCFI_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    dicaccfi_check_base(nrn => nRN, ncompany => nCOMPANY);

  end DICACCFI_AUPDATE;
  /* ######################################################################################################### */

  procedure DICACCFI_AMAKEININVOICE
  /*
  Заголовок. Формирование приходной накладной. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end DICACCFI_AMAKEININVOICE;
  /* ######################################################################################################### */

  procedure DICACCFI_BDELETE
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
  end DICACCFI_BDELETE;
  /* ######################################################################################################### */

  procedure DICACCFI_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      dicaccfi%rowtype;
  begin
    /* Заголовок */
    null;
    /*rRow := dicaccfi_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */

  end DICACCFI_CHECK_BASE;
  /* ######################################################################################################### */

  procedure DICACCFI_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rV_ROW         in v_dicaccfi%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    null;

  end DICACCFI_UPDATE;
  /* ######################################################################################################### */

  procedure DICACCFI_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW           in dicaccfi%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    null;
  end DICACCFI_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure DICACCFI_MAKEININVOICE
  /*
  Заголовок. Формирование приходной накладной
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ,dDATE            in date    /* дата накладной */
  ,nFLAG_NULLREC    in number  /* признак формирования накладных без спецификаций (null или 0 - нет, 1 - да) */
  ,nFLAG_QUANTREC   in number  /* признак формирования спецификаций (null или 0 - все, 1 - с кол-вом) */
  ,nTRUE_REC        out number /* признак cформирования хотя бы одной записи (null - ошибка, 0 - нет, >=1 - да) */
  )
  is
    rRow              dicaccfi%rowtype;

    nNumber       pkg_std.tnumber;
  begin
    p_selectlist_insert_ext( nident     => nRN
                            ,ndocument  => nRN
                            ,sunitcode  => 'AccountFactInput'
                            ,ndocument1 => null
                            ,sunitcode1 => null
                            ,ncrn       => null
                            ,nrn        => nNumber );
    p_dicaccfi_create_ininvoices( ncompany       => nCOMPANY
                                 ,nident         => nRN
                                 ,ddate          => dDATE
                                 ,nflag_nullrec  => nFLAG_NULLREC
                                 ,nflag_quantrec => nFLAG_QUANTREC
                                 ,ntrue_rec      => nTRUE_REC );
    p_ininvoicesbuff_makedoc( ncompany => nCOMPANY, nident => nRN );
    p_selectlist_clear( nident => nRN );
    p_ininvoicesbuff_clean(nident => nRN, ncompany => nCOMPANY );

  end DICACCFI_MAKEININVOICE;
  /* ######################################################################################################### */

  function DICLACFI_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return diclacfi%rowtype
  is
    rRow diclacfi%rowtype;
  begin
    begin
      select * into rRow from diclacfi where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(1, 'DICLACFI'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>', nRN, f_unitlist_getname(get_unitlist_code_table(1, 'DICLACFI')));
    end;
    return(rRow);
  end DICLACFI_GET;
  /* ######################################################################################################### */

  procedure DICLACFI_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              diclacfi%rowtype;
  begin
    /* Считывание */
    rRow  := diclacfi_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    diclacfi_check_base(nRN, nCOMPANY);

  end DICLACFI_AINSERT;
  /* ######################################################################################################### */

  procedure DICLACFI_BUPDATE
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
  end DICLACFI_BUPDATE;
  /* ######################################################################################################### */

  procedure DICLACFI_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              diclacfi%rowtype;
  begin
    /* Считывание */
    rRow  := diclacfi_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    diclacfi_check_base(nRN, nCOMPANY);

  end DICLACFI_AUPDATE;
  /* ######################################################################################################### */

  procedure DICLACFI_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              diclacfi%rowtype;
  begin
    /* Считывание */
    rRow  := diclacfi_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    diclacfi_check_base(nRN, nCOMPANY);

  end DICLACFI_BDELETE;
  /* ######################################################################################################### */

  procedure DICLACFI_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow              diclacfi%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow      := diclacfi_get(nrn => nRN);*/

    /* ИСПРАВЛЕНИЯ */
    
  end DICLACFI_CHECK_BASE;
  /* ######################################################################################################### */

  procedure DICLACFI_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW     in diclacfi%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN      out number
  ) 
  is
  begin
    null;

  end DICLACFI_BASE_INSERT;
  /* ######################################################################################################### */

  procedure DICLACFI_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW         in diclacfi%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_diclacfi_base_update(ncompany         => rROW.COMPANY
                            ,nrn              => rROW.RN
                            ,dpay_date        => rROW.PAY_DATE
                            ,nfood_code       => rROW.FOOD_CODE
                            ,nfoodmodif_code  => rROW.FOODMODIF_CODE
                            ,nfoodpack_code   => rROW.FOODPACK_CODE
                            ,sfood_name       => rROW.FOOD_NAME
                            ,namount          => rROW.AMOUNT
                            ,nmes_units       => rROW.MES_UNITS
                            ,ntax_group       => rROW.TAX_GROUP
                            ,none_price       => rROW.ONE_PRICE
                            ,nsum_price       => rROW.SUM_PRICE
                            ,none_excise      => rROW.ONE_EXCISE
                            ,none_excise_sum  => rROW.ONE_EXCISE_SUM
                            ,nexcise          => rROW.EXCISE
                            ,none_gsm_tax     => rROW.ONE_GSM_TAX
                            ,none_gsm_tax_sum => rROW.ONE_GSM_TAX_SUM
                            ,ngsm_tax         => rROW.GSM_TAX
                            ,none_wout_sum    => rROW.ONE_WOUT_SUM
                            ,nsum_wout        => rROW.SUM_WOUT
                            ,nrate_nds        => rROW.RATE_NDS
                            ,nrate_nds_out    => rROW.RATE_NDS_OUT
                            ,nnds_pr          => rROW.NDS_PR
                            ,none_sum_nds     => rROW.ONE_SUM_NDS
                            ,nsum_nds         => rROW.SUM_NDS
                            ,none_sum_total   => rROW.ONE_SUM_TOTAL
                            ,none_nsp         => rROW.ONE_NSP
                            ,nnsp             => rROW.NSP
                            ,none_nsp_sum     => rROW.ONE_NSP_SUM
                            ,nsum_total       => rROW.SUM_TOTAL
                            ,nauto_calc_sign  => rROW.AUTO_CALC_SIGN
                            ,dinclude_date    => rROW.INCLUDE_DATE
                            ,ncountry         => rROW.COUNTRY
                            ,sgtd             => rROW.GTD
                            ,nbalunit         => rROW.BALUNIT
                            ,npbook_way       => rROW.PBOOK_WAY
                            ,nsign_nds        => rROW.SIGN_NDS
                            ,nndsoprcod       => rROW.NDSOPRCOD);
    /* Режим выполнения: 1 - пользовательский */
    /*elsif nMODE = 1 then */

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
  end DICLACFI_BASE_UPDATE;
  /* ######################################################################################################### */


end USR_PKG_DICACCFI;
/
