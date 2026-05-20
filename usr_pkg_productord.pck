create or replace package USR_PKG_PRODUCTORD is
  /*
  Package предназначен для работы с разделом "Заказы на производство". 
  ProductionOrders          PRODUCTORD     PO
  ProductionOrdersSpecs     PRODUCTORDS    POS
  */
  --#########################################################################################################

  function PRODUCTORD_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return productord%rowtype;
  /* ######################################################################################################### */
  
  function PRODUCTORD_GET_BY_DPO
  /*
  Заголовок. Поиск по заказу подразделения
  */
  (
   nFLAGSMART       in number default 0
  ,nTOO_MANY_ROWS   in number default 0
  ,nDEPARTMENTORD   in number
  ) 
  return number;
  /*#########################################################################################################*/

  function PRODUCTORD_GET_STATUS_NAME
  /*
  Показать наименование состояния заголовка
  */
  (
   nORD_STATE    in number /* номер статуса */
  ) 
  return varchar2;
  --#########################################################################################################

  procedure PRODUCTORD_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_ACONFIRM
  /*
  Заголовок. Утверждение. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_AWOCONFIRM
  /*
  Заголовок. Снятие Утверждения. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_ACLOSE
  /*
  Заголовок. Закрытие. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_AANNUL
  /*
  Заголовок. Аннулирование. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORD_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in productord%rowtype
  );
  --#########################################################################################################

  function PRODUCTORDS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return productords%rowtype;
  --#########################################################################################################

  procedure PRODUCTORDS_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORDS_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORDS_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORDS_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  --#########################################################################################################

  procedure PRODUCTORDS_AFCPRODCMP_CMP
  /*
  Спецификация. Указать производственный состав. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORDS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure PRODUCTORDS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in productords%rowtype
  ,rPRODUCTORDPS    in productordps%rowtype
  );
  --#########################################################################################################

end USR_PKG_PRODUCTORD;
/
create or replace package body USR_PKG_PRODUCTORD is

  --#########################################################################################################

  function PRODUCTORD_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return productord%rowtype
  is
    rRow productord%rowtype;
  begin
    begin
      select t.* into rRow from productord t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PRODUCTORD');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORD')));
    end;
    return(rRow);
  end PRODUCTORD_GET;
  /* ######################################################################################################### */
  
  function PRODUCTORD_GET_BY_DPO
  /*
  Заголовок. Поиск по заказу подразделения
  */
  (
   nFLAGSMART       in number default 0
  ,nTOO_MANY_ROWS   in number default 0
  ,nDEPARTMENTORD   in number
  ) 
  return number
  is
    nRef    pkg_std.tref; 

    /* Поиск через Потребности и акты расхода */
    function GET_1
    return number
    is
    begin
      begin
        select dl1.in_document
          into nRef
          from doclinks      dl1
              ,doclinks      dl2
         where dl2.out_document = nDEPARTMENTORD
           and dl2.in_unitcode  = 'CostProductExpenseActs'
           and dl2.in_document  = dl1.out_document
           and dl1.in_unitcode  = 'ProductionOrders';
      exception
        when no_data_found then
          p_exception( nFLAGSMART, 'Не найден заказ на производство для заказа подразделения <%s>.', nDEPARTMENTORD );
        when too_many_rows then
          if nFLAGSMART = 0 then
            p_exception( nTOO_MANY_ROWS, 'Найдено больше одного заказа на производство для заказа подразделения <%s>.', nDEPARTMENTORD );
          end if;
        when others then
          p_exception( 0, 'Неопределённая ситуация при поиске заказа на производство для заказа подразделения <%s>.', nDEPARTMENTORD );
      end;
      return nRef;
    end GET_1;

    /* Поиск через прямую связь */
    function GET_2
    return number
    is
    begin
      begin
      select dl.in_document
        into nRef
        from doclinks      dl
            ,productords   po
            ,fcmatresource fmr
       where dl.out_document  = nDEPARTMENTORD
         and dl.in_unitcode   = 'ProductionOrders';
      exception
        when no_data_found then
          p_exception( nFLAGSMART, 'Не найден заказ на производство для заказа подразделения <%s>.', nDEPARTMENTORD );
        when too_many_rows then
          if nFLAGSMART = 0 then
            p_exception( nTOO_MANY_ROWS, 'Найдено больше одного заказа на производство для заказа подразделения <%s>.', nDEPARTMENTORD );
          end if;
        when others then
          p_exception( 0, 'Неопределённая ситуация при поиске заказа на производство для заказа подразделения <%s>.', nDEPARTMENTORD );
      end;
      return nRef;
    end GET_2;

  begin
    /* Поиск 1 и поиск 2 */
    return coalesce(GET_1, GET_2);

  end PRODUCTORD_GET_BY_DPO;
  /*#########################################################################################################*/

  function PRODUCTORD_GET_STATUS_NAME
  /*
  Показать наименование состояния заголовка
  */
  (
   nORD_STATE    in number /* номер статуса */
  ) 
  return varchar2
  is
  begin
    return( case nORD_STATE
              when 0 then 'Не утвержден'
              when 1 then 'Утвержден'
              when 2 then 'Согласование'
              when 3 then 'Закрыт'
              when 4 then 'Аннулирован'
            else 'Не определено'  
            end);
  END PRODUCTORD_GET_STATUS_NAME;
  /*#########################################################################################################*/

  procedure PRODUCTORD_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  productord%rowtype;
  begin
    /* Заголовок */
    /*rRow   := PRODUCTORD_GET(nRN);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    productord_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rproductord := null;*/

  end PRODUCTORD_AINSERT;
  --#########################################################################################################

  procedure PRODUCTORD_BUPDATE
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
    /*usr_pkg_pub_const.rproductord := productord_get(nrn => nRN);*/
  end PRODUCTORD_BUPDATE;
  --#########################################################################################################

  procedure PRODUCTORD_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    productord%rowtype;
  begin
    /* Запись */
    /*rRow := productord_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    productord_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end PRODUCTORD_AUPDATE;
  --#########################################################################################################

  procedure PRODUCTORD_BDELETE
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
    for c in (select * from productords where prn = nRN)
    loop
      productords_bdelete(nrn => c.rn, ncompany => c.company);
    end loop;

  end PRODUCTORD_BDELETE;
  --#########################################################################################################

  procedure PRODUCTORD_ACONFIRM
  /*
  Заголовок. Утверждение. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    productord%rowtype;
    dTMP    date;
  begin
    /* Считывание */
    rRow := productord_get(nRN => nRN);
    
    /* ПРОВЕРКИ */
    /* Базовая */
    productord_check_base(nrn => nRN, ncompany => nCOMPANY);
    
    /* Дата утверждения должна равняться текущей */
    if cmp_dat(trunc(rRow.state_date), trunc(current_date)) != 1 then
      p_exception(0, 'Дата утверждения <%s> не равна текущей дате <%s>. %s'
                 ,decode_date(rRow.state_date)
                 ,decode_date(current_date)
                 ,cr||f_docdescrs_get_description(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORD'), ndocument => rRow.rn)); 
    end if;
    
    /* 26/03/2024 Марков МВ.
       Для Заказа на производство должна быть указана дата поставки ОМТС */
    --if utilizer != 'KHOK' then
    begin
      select DV.DATE_VALUE
        into dTMP
        from DOCS_PROPS_VALS DV
       where DV.UNIT_RN = rRow.Rn
         and DV.DATE_VALUE is not null
         and DV.DOCS_PROP_RN = 113738795; -- Дата поставки ПКИ от ПДО для ОМТС
    exception
      when no_data_found then
        p_exception(0, 'Для заказа на производство %s не указана дата поставки ПКИ для ОМТС.');
    end;
    --end if;
  end PRODUCTORD_ACONFIRM;
  --#########################################################################################################

  procedure PRODUCTORD_AWOCONFIRM
  /*
  Заголовок. Снятие Утверждения. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    productord%rowtype;
    
    dDate   date;
  begin
    /* Считывание */
    rRow := productord_get(nRN => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    /*productord_check_base(nrn => nRN, ncompany => nCOMPANY);*/
    
    /* Есть связи с разделом Потребности производства */
    dDate := f_doclinks_link_out(sin_unitcode  => 'ProductionOrders'
                                ,nin_document  => rRow.rn
                                ,sout_unitcode => 'CostProductExpenseActs');
    if dDate is not null then
      p_exception(0, 'Документ имеет выходные связи с разделом <%s>. %s'
                 ,get_unitlist_name_code(nflag_smart => 1, sunitcode => 'CostProductExpenseActs')
                 ,cr||f_docdescrs_get_description(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORD'), ndocument => rRow.rn)); 
    end if;

  end PRODUCTORD_AWOCONFIRM;
  --#########################################################################################################

  procedure PRODUCTORD_ACLOSE
  /*
  Заголовок. Закрытие. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    /*rRow      productord%rowtype;*/
    nNumber   pkg_std.tnumber; 
  begin
    /* Считывание */
    /*rRow := productord_get( nrn => nRN );*/

    /* Рассылка о закрытии в ОМТС */
    usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany      => nCOMPANY
                                                ,sdescription  => 'Парус. Закрыт заказ на производство.'
                                                ,sto_list      => 'snab@module.ru'
                                                ,stitle        => 'Парус. Закрыт заказ на производство.'
                                                ,ctext         => f_docdescrs_get_description( sunitcode => 'ProductionOrders', ndocument => nRN )
                                                ,nrn           => nNumber );
  end PRODUCTORD_ACLOSE;
  --#########################################################################################################

  procedure PRODUCTORD_AANNUL
  /*
  Заголовок. Аннулирование. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;

  end PRODUCTORD_AANNUL;
  --#########################################################################################################

  procedure PRODUCTORD_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                productord%rowtype;
    nProjectStage_Sht   pkg_std.tref; 
  begin
    /* Заголовок  */
    rRow := productord_get(nRN => nRN);
    /* Связанная ведомость производства */
    nProjectStage_Sht := usr_pkg_doclinks.doclinks_link_in_doc(sout_unitcode => 'ProductionOrders', nout_document => rRow.rn, sin_unitcode => 'UDOProjectsStagesSheet');
    
    /* Дата заказа должна быть меньше или равна дате исполнения */
    if cmp_dat_minmax(trunc(rRow.ord_date), trunc(rRow.release_date)) > 0 then
      p_exception(0, 'Дата заказа <%s> должна быть меньше или равна дате исполнения <%s>. %s'
                 ,decode_date(rRow.ord_date)
                 ,decode_date(rRow.release_date)
                 ,cr||f_docdescrs_get_description(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORD'), ndocument => rRow.rn)); 
    end if;

    /* Если ведомость производства найдена */
    if nProjectStage_Sht is not null then
      /* Сравниваем значения свойства "Фото-видео документирование" */
      if cmp_vc2(usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 160686482, ndocument => nRN)
                ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 160686482, ndocument => nProjectStage_Sht) ) != 1 then
        p_exception(0, 'Значение свойства "Фото-видео документирование" в заказе на производство <%s> не равно ведомости производства <%s>. %s'
                   ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 160686482, ndocument => nRN)
                   ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 160686482, ndocument => nProjectStage_Sht)
                   ,cr||f_docdescrs_get_description(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORD'), ndocument => rRow.rn)); 
      end if;             
    end if;
    
  end PRODUCTORD_CHECK_BASE;
  --#########################################################################################################

  procedure PRODUCTORD_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in productord%rowtype
  ) 
  is
  begin
    p_productord_base_update(ncompany      => rROW.COMPANY
                            ,nrn           => rROW.RN
                            ,sord_pref     => rROW.ORD_PREF
                            ,sord_numb     => rROW.ORD_NUMB
                            ,nagent        => rROW.AGENT
                            ,nfaceacc      => rROW.FACEACC
                            ,ngraphpoint   => rROW.GRAPHPOINT
                            ,nsubdiv       => rROW.SUBDIV
                            ,nord_doctype  => rROW.ORD_DOCTYPE
                            ,dord_date     => rROW.ORD_DATE
                            ,nord_state    => rROW.ORD_STATE
                            ,dstate_date   => rROW.STATE_DATE
                            ,ncurrency     => rROW.CURRENCY
                            ,nstore        => rROW.STORE
                            ,nacc_agent    => rROW.ACC_AGENT
                            ,nacc_subdiv   => rROW.ACC_SUBDIV
                            ,drelease_date => rROW.RELEASE_DATE
                            ,nord_period   => rROW.ORD_PERIOD
                            ,nusecalendar  => rROW.USECALENDAR
                            ,nperiod_corr  => rROW.PERIOD_CORR
                            ,nperiod_quant => rROW.PERIOD_QUANT
                            ,nperiod_type  => rROW.PERIOD_TYPE
                            ,nperiod_len   => rROW.PERIOD_LEN
                            ,natsametime   => rROW.ATSAMETIME
                            ,snote         => rROW.NOTE
                            ,ncost_plan    => rROW.COST_PLAN
                            ,ncost_fact    => rROW.COST_FACT
                            ,ncost_npz     => rROW.COST_NPZ
                            ,ncalcschm     => rROW.CALCSCHM
                            ,ntarif        => rROW.TARIF
                            ,nmat_price    => rROW.MAT_PRICE
                            ,sbarcode      => rROW.BARCODE
                            ,ncoeff_tarif  => rROW.COEFF_TARIF
                            ,nready_prod   => rROW.READY_PROD
                            ,nfcexpact     => rROW.FCEXACT
                            ,dfrm_date     => rROW.FRM_DATE
                            ,nflag_mode    => 0);
  end PRODUCTORD_BASE_UPDATE;
  --#########################################################################################################

  function PRODUCTORDS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return productords%rowtype
  is
    rRow productords%rowtype;
  begin
    begin
      select * into rRow from productords t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PRODUCTORDS');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORDS')));
    end;
    return(rRow);
  end PRODUCTORDS_GET;
  --#########################################################################################################

  procedure PRODUCTORDS_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         productords%rowtype;
  begin
    /* Спецификация */
    /*rRow := productords_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    productords_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PRODUCTORDS_AINSERT;
  --#########################################################################################################

  procedure PRODUCTORDS_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* usr_pkg_pub_const.rproductords := productords_get(nrn => nRN); */
    
  end PRODUCTORDS_BUPDATE;
  --#########################################################################################################

  procedure PRODUCTORDS_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            productords%rowtype;
    rGoodsSupply    goodssupply%rowtype;
  begin
    /* Заголовок */
    /* rRow := productords_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    productords_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rproductords := null;*/

  end PRODUCTORDS_AUPDATE;
  --#########################################################################################################

  procedure PRODUCTORDS_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            productords%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := productords_get(nrn => nRN);*/
    
  end PRODUCTORDS_BDELETE;
  --#########################################################################################################

  procedure PRODUCTORDS_AFCPRODCMP_CMP
  /*
  Спецификация. Указать производственный состав. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            productords%rowtype;
  begin
    /* Заголовок */
    /* rRow := productords_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    productords_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rproductords := null;*/

  end PRODUCTORDS_AFCPRODCMP_CMP;
  --#########################################################################################################

  procedure PRODUCTORDS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            productords%rowtype;
    rFCProdCmp      fcprodcmp%rowtype;
    rFCMatResource  fcmatresource%rowtype;
  begin
    /* Заголовок */
    rRow        := productords_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Если указан производственный состав */
    if rRow.prodcmp is not null then

      /* Считывание производственого состава */
      rFCProdCmp := udo_pkg_get.row_fcprodcmp(nrn => rRow.prodcmp, nsmart => 0);

      /* Считывание мат.ресурса производственого состава */
      begin
        select *
          into rFCMatResource
          from fcmatresource
         where rn = rFCProdCmp.mtr_res;
      exception
        when no_data_found then
          pkg_msg.record_not_found(nflag_smart => 0, ndocument => nrn, sunit_table => 'FCMATRESOURCE');
        when others then
          p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                     ,NRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1
                                                                             ,stable_name => 'FCMATRESOURCE')));
      end;

      /* Модификация производственого состава и спецификации должны равняться */
      if cmp_num(rFCMatResource.nomen_modif, rRow.nom_modif) != 1 then
        p_exception(0, 'Модификация номенклатуры производственного состава <%s> не равна модификации номенклатуры спецификации заказа на производство <%s>. %s'
                   ,usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => rFCMatResource.nomen_modif)
                   ,usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => rRow.nom_modif)
                   ,cr||f_docdescrs_get_description(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PRODUCTORDS'), ndocument => rRow.rn)); 
        
      end if;

    end if;

  end PRODUCTORDS_CHECK_BASE;
  --#########################################################################################################

  procedure PRODUCTORDS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in productords%rowtype
  ,rPRODUCTORDPS    in productordps%rowtype
  ) 
  is
  begin
    P_PRODUCTORDS_BASE_UPDATE(ncompany     => rROW.COMPANY
                             ,nrn          => rROW.RN
                             ,nnomen       => rROW.NOMEN
                             ,nnom_pack    => rROW.NOM_PACK
                             ,nnom_modif   => rROW.NOM_MODIF
                             ,nnommod_pack => rROW.NOMMOD_PACK
                             ,nproduct     => rROW.PRODUCT
                             ,nexp_price   => rROW.EXP_PRICE
                             ,npr_meas     => rROW.PR_MEAS
                             ,nstore       => rROW.STORE
                             ,snote        => rROW.NOTE
                             ,ncost_plan   => rROW.COST_PLAN
                             ,ncost_fact   => rROW.COST_FACT
                             ,ncost_npz    => rROW.COST_NPZ
                             ,nprodcmp     => rROW.PRODCMP
                             ,nperfs_state => rPRODUCTORDPS.PERFS_STATE
                             ,dcs_date     => rPRODUCTORDPS.CS_DATE
                             ,dactpf_date  => rPRODUCTORDPS.ACTPF_DATE
                             ,dcust_date   => rPRODUCTORDPS.CUST_DATE
                             ,dexec_date   => rPRODUCTORDPS.EXEC_DATE
                             ,nactm_quant  => rPRODUCTORDPS.ACTM_QUANT
                             ,nacta_quant  => rPRODUCTORDPS.ACTA_QUANT
                             ,ncustm_quant => rPRODUCTORDPS.CUSTM_QUANT
                             ,ncusta_quant => rPRODUCTORDPS.CUSTA_QUANT
                             ,nexecm_quant => rPRODUCTORDPS.EXECM_QUANT
                             ,nexeca_quant => rPRODUCTORDPS.EXECA_QUANT
                             ,nactsumm     => rPRODUCTORDPS.ACTSUMM
                             ,ncustsumm    => rPRODUCTORDPS.CUSTSUMM
                             ,nexecsumm    => rPRODUCTORDPS.EXECSUMM);
  end PRODUCTORDS_BASE_UPDATE;
  --#########################################################################################################
  
end USR_PKG_PRODUCTORD;
/
