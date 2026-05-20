create or replace package USR_PKG_PROD_CULL is
  /*
  Package предназначен для работы с разделом "Сертификация / Входной контроль". 
  UdoProdCull               PROD_CULL        BP
  UdoProdCullSp             PROD_CULL_SP     BPS    Передано на сертификацию / ВК
  UdoProdCullSpOut          PROD_CULL_OUT    BPSR   Результаты сертификации / ВК
  */
  /*#########################################################################################################*/

  function PROD_CULL_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return udo_prod_cull%rowtype;
  /*#########################################################################################################*/

  function PROD_CULL_GET_STATUS_NAME
  /*
  Заголовок. Наименование состояния по номеру
  */
  (
   nSTATUS      in number
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function PROD_CULL_GET_STATUS_BY_NAME
  /*
  Заголовок. Номер состояния по наименованию
  */
  (
   sSTATUS      in varchar2
  ) 
  return number;
  /*#########################################################################################################*/

  procedure PROD_CULL_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  function PROD_CULL_SP_GET
  /*
  Передано на сертификацию / ВК. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_prod_cull_sp%rowtype;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_AINSERT
  /*
  Передано на сертификацию / ВК. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BUPDATE
  /*
  Передано на сертификацию / ВК. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_AUPDATE
  /*
  Передано на сертификацию / ВК. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BDELETE
  /*
  Передано на сертификацию / ВК. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BSET_STATE
  /*
  Передано на сертификацию / ВК. Отработать. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_ASET_STATE
  /*
  Передано на сертификацию / ВК. Отработать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_CHECK_BASE
  /*
  Передано на сертификацию / ВК. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_UPDATE
  (
   rV_ROW   in udo_v_prod_cull_sp%rowtype
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BASE_UPDATE
  (
   rROW   in udo_prod_cull_sp%rowtype
  );
  /*#########################################################################################################*/

  function PROD_CULL_OUT_GET
  /*
  Результаты сертификации / ВК. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_prod_cull_out%rowtype;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_AINSERT
  /*
  Результаты сертификации / ВК. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_BUPDATE
  /*
  Результаты сертификации / ВК. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_AUPDATE
  /*
  Результаты сертификации / ВК. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_BDELETE
  /*
  Результаты сертификации / ВК. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_CHECK_BASE
  /*
  Результаты сертификации / ВК. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_BASE_UPDATE
  (
   rROW   in udo_prod_cull_out%rowtype
  );
  /*#########################################################################################################*/

end USR_PKG_PROD_CULL;
/
create or replace package body USR_PKG_PROD_CULL is

  /*#########################################################################################################*/

  function PROD_CULL_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return udo_prod_cull%rowtype
  is
    rRow udo_prod_cull%rowtype;
  begin
    begin
      select t.* into rRow from udo_prod_cull t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'UDO_PROD_CULL');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_PROD_CULL')));
    end;
    return(rRow);
  end PROD_CULL_GET;
  /*#########################################################################################################*/

  function PROD_CULL_GET_STATUS_NAME
  /*
  Заголовок. Наименование состояния по номеру
  */
  (
   nSTATUS      in number
  ) 
  return varchar2
  is
    sVarchar    pkg_std.tstring; 
  begin
    begin
      select t.name
        into sVarchar
        from dmsenumvalues t
       where t.prn        = 112522971
         and t.value_num  = nSTATUS 
         and nSTATUS      is not null;
    exception
      when no_data_found then
        p_exception(0, 'Не найдено наименование статуса для номера <%s> в разделе <%s>.'
                   ,nSTATUS
                   ,f_unitlist_getname(sunitcode => 'UdoProdCull'));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске номера статуса для наименования <%s> в разделе <%s>.'
                   ,nSTATUS
                   ,f_unitlist_getname(sunitcode => 'UdoProdCull'));
    end;
 
    return(sVarchar);

  end PROD_CULL_GET_STATUS_NAME;
  /*#########################################################################################################*/

  function PROD_CULL_GET_STATUS_BY_NAME
  /*
  Заголовок. Номер состояния по наименованию
  */
  (
   sSTATUS      in varchar2
  ) 
  return number 
  is
    nNumber   pkg_std.tnumber; 
  begin
    begin
      select t.value_num
        into nNumber
        from dmsenumvalues t
       where t.prn   = 112522971
         and t.name  = sSTATUS 
         and sSTATUS is not null;
    exception
      when no_data_found then
        p_exception(0, 'Не найден номер статуса для наименования <%s> в разделе <%s>.'
                   ,sSTATUS
                   ,f_unitlist_getname(sunitcode => 'UdoProdCull'));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске номера статуса для наименования <%s> в разделе <%s>.'
                   ,sSTATUS
                   ,f_unitlist_getname(sunitcode => 'UdoProdCull'));
    end;
 
    return(nNumber);

  end PROD_CULL_GET_STATUS_BY_NAME;
  /*#########################################################################################################*/

  procedure PROD_CULL_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  udo_prod_cull%rowtype;
  begin
    /* Заголовок */
    /*rRow   := PROD_CULL_GET(nRN);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    prod_cull_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rprod_cull := null;*/

  end PROD_CULL_AINSERT;
  /*#########################################################################################################*/

  procedure PROD_CULL_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rprod_cull := prod_cull_get(nrn => nRN);*/
  end PROD_CULL_BUPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    udo_prod_cull%rowtype;
  begin
    /* Запись */
    /*rRow := prod_cull_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    prod_cull_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end PROD_CULL_AUPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* Проверка спецификаций */
    for c in (select * from udo_prod_cull_sp where prn = nRN)
    loop
      prod_cull_sp_bdelete(nrn => c.rn, ncompany => c.company);
    end loop;

  end PROD_CULL_BDELETE;
  /*#########################################################################################################*/

  procedure PROD_CULL_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              udo_prod_cull%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow := prod_cull_get(nRN => nRN);*/
  
  end PROD_CULL_CHECK_BASE;
  /*#########################################################################################################*/

  function PROD_CULL_SP_GET
  /*
  Передано на сертификацию / ВК. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_prod_cull_sp%rowtype
  is
    rRow udo_prod_cull_sp%rowtype;
  begin
    begin
      select * into rRow from udo_prod_cull_sp t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'UDO_PROD_CULL_SP');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_PROD_CULL_SP')));
    end;
    return(rRow);
  end PROD_CULL_SP_GET;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_AINSERT
  /*
  Передано на сертификацию / ВК.  Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_prod_cull_sp%rowtype;
  begin
    /* Спецификация */
    /*rRow := prod_cull_sp_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    prod_cull_sp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PROD_CULL_SP_AINSERT;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BUPDATE
  /*
  Передано на сертификацию / ВК.  Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* usr_pkg_pub_const.rprod_cull_sp := prod_cull_sp_get(nrn => nRN); */
    
  end PROD_CULL_SP_BUPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_AUPDATE
  /*
  Передано на сертификацию / ВК.  Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prod_cull_sp%rowtype;
  begin
    /* Заголовок */
    /* rRow := prod_cull_sp_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */
     

    /* ПРОВЕРКИ */
    /* Базовая */
    prod_cull_sp_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rprod_cull_sp := null;*/

  end PROD_CULL_SP_AUPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BDELETE
  /*
  Передано на сертификацию / ВК.  Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            udo_prod_cull_sp%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := prod_cull_sp_get(nrn => nRN);*/
    
  end PROD_CULL_SP_BDELETE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BSET_STATE
  /*
  Передано на сертификацию / ВК.  Отработать. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* Сохранение RN в константу - инициализация записи в usr_t_inhierbuff */
    usr_pkg_pub_const.nIdentBefore := nRN; 
    
  end PROD_CULL_SP_BSET_STATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_ASET_STATE
  /*
  Передано на сертификацию / ВК.  Отработать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prod_cull_sp%rowtype;
    sConnect_Ext    pkg_std.tstring := pkg_session.get_connect_ext; 
  begin
    /* Заголовок */
    /* rRow := prod_cull_sp_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */
    /* По сформированным накладным в подразделения */
    for c in (select t.*
                from usr_t_inhierbuff tp, transinvdept t
               where tp.identbefore = usr_pkg_pub_const.nIdentBefore
                 and tp.connect_ext = sConnect_Ext
                 and t.rn           = tp.out_document0) 
    loop

      /* Если склад-получатель Микроэлектроника, и каталог НЕ Микроэлектроника */
      if c.in_store = 32814621 and c.crn != 95911302 then
        /* перенос документа в каталог Микроэлектроника */
        pkg_document.base_move(imove_type => 1
                              ,sunitcode  => 'GoodsTransInvoicesToDepts'
                              ,ndocument  => c.rn
                              ,ntarget    => 95911302);
      end if;

    end loop;     

    /* ПРОВЕРКИ */
    /* Базовая */
    prod_cull_sp_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    delete from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nIdentBefore and connect_ext = sConnect_Ext;
    usr_pkg_pub_const.nIdentBefore := null;

  end PROD_CULL_SP_ASET_STATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_CHECK_BASE
  /*
  Передано на сертификацию / ВК.  Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prod_cull_sp%rowtype;
  begin
    /* Заголовок */
    rRow := prod_cull_sp_get(nrn => nRN);

    /* ПРОВЕРКИ */

  end PROD_CULL_SP_CHECK_BASE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_UPDATE
  (
   rV_ROW   in udo_v_prod_cull_sp%rowtype
  )
  as
   rRow   udo_prod_cull_sp%rowtype;
  begin
    rRow.rn            := rV_ROW.nRN;
    rRow.prn           := rV_ROW.nPRN;
    rRow.goodsparty    := rV_ROW.nGOODSPARTY;
    rRow.quant         := rV_ROW.nQUANT;
    rRow.sign_sert     := rV_ROW.nSIGN_SERT;
    rRow.note          := rV_ROW.sNOTE;
    rRow.state         := rV_ROW.nSTATE;
    rRow.quant_conf    := rV_ROW.nQUANT_CONF;
    rRow.state_vk      := rV_ROW.nSTATE_VK;
    rRow.state_vk_note := rV_ROW.sSTATE_VK_NOTE;

    udo_pkg_prod_cull.cull_sp_join( ncompany => rV_ROW.NCOMPANY
                                   ,snomen   => rV_ROW.SNOMEN_CODE
                                   ,smodif   => rV_ROW.SMODIF_CODE
                                   ,spack    => rV_ROW.SPACK_CODE
                                   ,sarticle => rV_ROW.SARTICLE_CODE
                                   ,nnomen   => rRow.nomen
                                   ,nmodif   => rRow.modif
                                   ,npack    => rRow.pack
                                   ,narticle => rRow.article );

    usr_pkg_prod_cull.prod_cull_sp_base_update( rrow => rRow );
  
  end PROD_CULL_SP_UPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_SP_BASE_UPDATE
  (
   rROW   in udo_prod_cull_sp%rowtype
  )
  as
  begin
    update udo_prod_cull_sp
       set goodsparty    = rROW.GOODSPARTY
          ,nomen         = rROW.NOMEN
          ,modif         = rROW.MODIF
          ,pack          = rROW.PACK
          ,article       = rROW.ARTICLE
          ,quant         = rROW.QUANT
          ,sign_sert     = rROW.SIGN_SERT
          ,note          = rROW.NOTE
          ,state         = rROW.STATE
          ,quant_conf    = rROW.QUANT_CONF   
          ,state_vk      = rROW.STATE_VK
          ,state_vk_note = rROW.STATE_VK_NOTE 
     where rn = rROW.RN ;
    if ( sql%notfound ) then
      p_exception( 0, 'Запись спецификации в разделе Сертификация/Входной контроль (RN: '||nvl(to_char(rROW.RN),'<null>')||') не найдена.' );
    end if;

  end PROD_CULL_SP_BASE_UPDATE;
  /*#########################################################################################################*/

  function PROD_CULL_OUT_GET
  /*
  Результаты сертификации / ВК. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_prod_cull_out%rowtype
  is
    rRow udo_prod_cull_out%rowtype;
  begin
    begin
      select * into rRow from udo_prod_cull_out t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'UDO_PROD_CULL_OUT');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_PROD_CULL_OUT')));
    end;
    return(rRow);
  end PROD_CULL_OUT_GET;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_AINSERT
  /*
  Результаты сертификации / ВК. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_prod_cull_out%rowtype;
  begin
    /* Результаты сертификации / ВК */
    /*rRow := prod_cull_out_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    prod_cull_out_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PROD_CULL_OUT_AINSERT;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_BUPDATE
  /*
  Результаты сертификации / ВК. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* usr_pkg_pub_const.rprod_cull_out := prod_cull_out_get(nrn => nRN); */
    
  end PROD_CULL_OUT_BUPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_AUPDATE
  /*
  Результаты сертификации / ВК. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prod_cull_out%rowtype;
  begin
    /* Заголовок */
    /* rRow := prod_cull_out_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    prod_cull_out_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rprod_cull_out := null;*/

  end PROD_CULL_OUT_AUPDATE;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_BDELETE
  /*
  Результаты сертификации / ВК. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            udo_prod_cull_out%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := prod_cull_out_get(nrn => nRN);*/
    
  end PROD_CULL_OUT_BDELETE;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_CHECK_BASE
  /*
  Результаты сертификации / ВК. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prod_cull_out%rowtype;
  begin
    /* Заголовок */
    rRow := prod_cull_out_get(nrn => nRN);

    /* ПРОВЕРКИ */

  end PROD_CULL_OUT_CHECK_BASE;
  /*#########################################################################################################*/

  procedure PROD_CULL_OUT_BASE_UPDATE
  (
   rROW   in udo_prod_cull_out%rowtype
  )
as
  begin
    update udo_prod_cull_out
       set rn             = rROW.RN            
          ,prn            = rROW.PRN           
          ,company        = rROW.COMPANY       
          ,jurpers        = rROW.JURPERS       
          ,crn            = rROW.CRN           
          ,sign_out       = rROW.SIGN_OUT      
          ,supply         = rROW.SUPPLY        
          ,sernumb_new    = rROW.SERNUMB_NEW   
          ,cert_numb      = rROW.CERT_NUMB     
          ,cert_from      = rROW.CERT_FROM     
          ,cert_to        = rROW.CERT_TO       
          ,quant          = rROW.QUANT         
          ,price          = rROW.PRICE         
          ,summ           = rROW.SUMM          
          ,currency       = rROW.CURRENCY      
          ,note           = rROW.NOTE          
          ,prod_date_d    = rROW.PROD_DATE_D   
          ,supplier_party = rROW.SUPPLIER_PARTY
          ,accept         = rROW.ACCEPT        
          ,prod_date_s    = rROW.PROD_DATE_S   
          ,recheck_date   = rROW.RECHECK_DATE  
     where rn = rROW.RN ; 
    if ( sql%notfound ) then
      p_exception( 0, 'Запись спецификации в разделе Сертификация/Входной контроль (Результат сертификации) (RN: '||nvl(to_char(rROW.RN),'<null>')||') не найдена.' );
    end if;

  end PROD_CULL_OUT_BASE_UPDATE;
  /*#########################################################################################################*/


end USR_PKG_PROD_CULL;
/
