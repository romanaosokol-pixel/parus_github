create or replace package USR_PKG_INCOMEFROMDEPS is
  /*
  Package предназначен для работы с разделом "Приход из подразделений".
  IncomFromDeps       IFD
  IncomFromDepsSpecs  IFDS
  */

  /*#########################################################################################################*/

  function INCOMEFROMDEPS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   NRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return INCOMEFROMDEPS%ROWTYPE;
  /*#########################################################################################################*/

  function INCOMEFROMDEPS_GET_PO_RN
  /*
  Заголовок. Поиск RN Заказа на производство
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return number;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASFACT
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) ;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AASFACT
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASE_INSERT
  /*
  Заголовок. Добавить. Базовая
  */
  (
   rROW   in incomefromdeps%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASE_UPDATE
  /*
  Заголовок. Исправить. Базовая
  */
  (
   rROW   in incomefromdeps%rowtype
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_INSERT
  /*
  Заголовок. Добавить. Клиентская
  */
  (
   rV_ROW   in v_incomefromdeps%rowtype
  ,nDUP_RN  in number
  ,nRN      out number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_UPDATE
  /*
  Заголовок. Исправить. Клиентская
  */
  (
   rV_ROW   in v_incomefromdeps%rowtype
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASE_SET_STAT
  /*
  Заголовок. Отработка документа. Внутри использует базовую процедуру, без прологов/эпилогов
  При снятии - делает копию с исходного документа, чтобы штатная процедура снятия отработки не очищала партию. После удаляет копию
  При отработке - отключает парамтер автоматической генерации партии, после отработки восстанавливает парамтр
  */
  (
   nRN      in number 
  ,nIDENT   in number 
  ,nSTATUS  in number 
  );
  /*#########################################################################################################*/

  function INCOMEFROMDEPSSPEC_GET
  /*
  Спецификация. Считывание
  */
  (
   NRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return INCOMEFROMDEPSSPEC%ROWTYPE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_CHECK_SPRJ
  /*
  Спецификация. Проверка резервирования по местам хранения
  */
  (
   rROW       in incomefromdepsspec%rowtype
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BASE_INSERT
  /*
  Спецификация. Добавить. Базовая
  */
  (
   rROW   in incomefromdepsspec%rowtype
  ,nRN    out number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BASE_UPDATE
  /*
  Спецификация. Исправить. Базовая
  */
  (
   rROW   in incomefromdepsspec%rowtype
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_INSERT
  /*
  Спецификация. Добавить. Клиентская
  */
  (
   rV_ROW   in v_incomefromdepsspec%rowtype
  ,nRN      out number
  );
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_UPDATE
  /*
  Спецификация. Исправить. Клиентская
  */
  (
   rV_ROW         in v_incomefromdepsspec%rowtype
  ,nFLAG_DEL_CALC in number default 0
  );
  /*#########################################################################################################*/

end USR_PKG_INCOMEFROMDEPS;
/
create or replace package body USR_PKG_INCOMEFROMDEPS is

  /*#########################################################################################################*/

  function INCOMEFROMDEPS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   NRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return incomefromdeps%rowtype
  is
    rRow incomefromdeps%rowtype;
  begin
    begin
      select * into rRow from incomefromdeps where rn = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN,  sunit_table => 'INCOMEFROMDEPS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(NRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INCOMEFROMDEPS'))||'>.');
    end;
    return(rRow);
  end INCOMEFROMDEPS_GET;
  /*#########################################################################################################*/

  function INCOMEFROMDEPS_GET_PO_RN
  /*
  Заголовок. Поиск RN Заказа на производство
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return number
  is
    rFCProdPlanSp   fcprodplansp%rowtype;
    nProductOrd     pkg_std.tref; 
  begin
    /* Поиск спецификации Планов и отчётов производства */ 
    rFCProdPlanSp.rn := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                      ,sout_unitcode => 'IncomFromDeps'
                                                      ,nout_document => nRN
                                                      ,sin_unitcode  => 'CostProductPlansSpecs' );
    /* Если найдена спецификация Планов и отчётов производства */ 
    if rFCProdPlanSp.rn is not null then                                                          
      /* Считывание спецификация Планов и отчётов производства */ 
      rFCProdPlanSp := udo_pkg_get.row_fcprodplansp( nrn => rFCProdPlanSp.rn );
      /* Поиск заказа на производство хитрой процедурой */ 
      nProductOrd   := udo_pkg_fcprodplan_utl.sp_get_prodord( nflagsmart  => nFLAGSMART, nprodplansp => rFCProdPlanSp.prn_node );
    end if;

    return( nProductOrd );
    
  end INCOMEFROMDEPS_GET_PO_RN;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            incomefromdeps%rowtype;
    sAcatalog       pkg_std.tstring; 
    nTransInvDept   pkg_std.tref; 
  begin
    /* Заголовок */
    rRow      := incomefromdeps_get(nrn => nRN);
    sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая */
    incomefromdeps_check_base(nrn => rRow.RN, ncompany => rRow.company);

    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      /* Процесс НЕ Исправление РН в подразделение */
      if cmp_vc2(usr_pkg_process.get_parus_process(sunitcode => 'GoodsTransInvoicesToDepts', nmode => 1), 'TRANSINVDEPT_INSERT') != 1 then
        /* запрет действия из текущего раздела */
        p_exception(0, 'Документ в каталоге "%s" добавляется автоматически при добавлении связанного документа в разделе "%s". %s'
                   ,sAcatalog
                   ,f_unitlist_getname(sunitcode => 'GoodsTransInvoicesToDepts')
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)); 
      end if;
    end if;

    /* По спецификациям */
    for c in (select * from incomefromdepsspec where prn = rRow.rn) 
    loop
      /* проверка спецификации */
      incomefromdepsspec_ainsert(nrn => c.rn, ncompany => c.company);
    end loop;
    
  end INCOMEFROMDEPS_AINSERT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Считывание  */
    usr_pkg_pub_const.rincomefromdeps := incomefromdeps_get(nrn => NRN); 
    
    /* ПРОВЕРКИ */

  end INCOMEFROMDEPS_BUPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
    rRow            incomefromdeps%rowtype;
    sAcatalog       acatalog.name%type;
    nTransInvDept   pkg_std.tref; 
  begin
    /* Считывание */
    rRow      := incomefromdeps_get(nrn => NRN);
    sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    incomefromdeps_check_base(nrn => rRow.rn, ncompany => rRow.company);
    
    /* Документ отработан */
    if rRow.doc_state != 0 then
      /* Изменились поля */
      if cmp_num(rRow.doc_type        ,usr_pkg_pub_const.rincomefromdeps.doc_type        ) = 0
      or cmp_num(rRow.jur_pers        ,usr_pkg_pub_const.rincomefromdeps.jur_pers        ) = 0
      or cmp_vc2(rRow.doc_pref        ,usr_pkg_pub_const.rincomefromdeps.doc_pref        ) = 0
      or cmp_vc2(rRow.doc_numb        ,usr_pkg_pub_const.rincomefromdeps.doc_numb        ) = 0
      or cmp_dat(rRow.doc_date        ,usr_pkg_pub_const.rincomefromdeps.doc_date        ) = 0
      or cmp_num(rRow.store           ,usr_pkg_pub_const.rincomefromdeps.store           ) = 0
      /*or cmp_num(rRow.agent           ,usr_pkg_pub_const.rincomefromdeps.agent           ) = 0*/
      or cmp_num(rRow.currency        ,usr_pkg_pub_const.rincomefromdeps.currency        ) = 0
      or cmp_num(rRow.store_oper      ,usr_pkg_pub_const.rincomefromdeps.store_oper      ) = 0
      or cmp_num(rRow.valid_doctype   ,usr_pkg_pub_const.rincomefromdeps.valid_doctype   ) = 0
      or cmp_vc2(rRow.valid_docnumb   ,usr_pkg_pub_const.rincomefromdeps.valid_docnumb   ) = 0
      or cmp_dat(rRow.valid_docdate   ,usr_pkg_pub_const.rincomefromdeps.valid_docdate   ) = 0
      or cmp_num(rRow.out_department  ,usr_pkg_pub_const.rincomefromdeps.out_department  ) = 0
      or cmp_num(rRow.out_faceacc     ,usr_pkg_pub_const.rincomefromdeps.out_faceacc     ) = 0
      or cmp_num(rRow.out_graphpoint  ,usr_pkg_pub_const.rincomefromdeps.out_graphpoint  ) = 0
      or cmp_num(rRow.out_store       ,usr_pkg_pub_const.rincomefromdeps.out_store       ) = 0
      or cmp_num(rRow.party_agent     ,usr_pkg_pub_const.rincomefromdeps.party_agent     ) = 0
      or cmp_num(rRow.party_rn        ,usr_pkg_pub_const.rincomefromdeps.party_rn        ) = 0
      or cmp_vc2(rRow.party           ,usr_pkg_pub_const.rincomefromdeps.party           ) = 0
      or cmp_num(rRow.curcours        ,usr_pkg_pub_const.rincomefromdeps.curcours        ) = 0
      or cmp_num(rRow.curbasecours    ,usr_pkg_pub_const.rincomefromdeps.curbasecours    ) = 0
      or cmp_num(rRow.curcours_doc    ,usr_pkg_pub_const.rincomefromdeps.curcours_doc    ) = 0
      or cmp_num(rRow.curbasecours_doc,usr_pkg_pub_const.rincomefromdeps.curbasecours_doc) = 0
      or cmp_vc2(rRow.barcode         ,usr_pkg_pub_const.rincomefromdeps.barcode         ) = 0 then
        p_exception(0, 'Запрещено изменение отработанного документа. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)); 
      end if;
    end if;

    -- Каталоги 'Сборка, разборка'
    if sAcatalog in ('Сборка, разборка') then
      -- считывание связанного по входу документа
      nTransInvDept := F_DOCLINKS_LINK_IN_DOC('IncomFromDeps', rRow.rn, 'GoodsTransInvoicesToDepts');
      -- связанный документ есть 
      if nTransInvDept is not null then
        -- процесс НЕ Исправление РН в подразделение
        if CMP_VC2(USR_PKG_PROCESS.GET_PARUS_PROCESS(SUNITCODE => 'GoodsTransInvoicesToDepts', NMODE => 1), 'TRANSINVDEPT_UPDATE') != 1 then
          -- запрет действия из текущего раздела
          P_EXCEPTION(0, 'Документ в каталоге "%s" исправляется автоматически при исправлении связанного документа в разделе "%s". %s'
                     ,sAcatalog
                     ,F_UNITLIST_GETNAME('GoodsTransInvoicesToDepts')
                     ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
        end if;
      -- связаннонго документа нет 
      else
        P_EXCEPTION(0, 'Документ в каталоге "%s" не имеет связанного документа в разделе "%s". %s'
                   ,sAcatalog
                   ,F_UNITLIST_GETNAME('GoodsTransInvoicesToDepts')
                   ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
      end if;
    end if;
    
  end INCOMEFROMDEPS_AUPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              incomefromdeps%rowtype;
    sAcatalog         acatalog.name%type;
    nTransInvDept     pkg_std.tref; 
    nNumber           pkg_std.tnumber; 
  begin
    -- Заголовок  
    rRow := INCOMEFROMDEPS_GET(NRN);
    sAcatalog := GET_ACATALOG_NAME_ID(0, rRow.crn);

    -- ИСПРАВЛЕНИЯ
    -- Каталоги 'Сборка, разборка'
    if sAcatalog in ('Сборка, разборка') then
      -- Удаление журнала резервирования по местам хранения
      USR_PKG_DOCUMENT.STRPLRESJRNL_DELETE(NRN => rRow.rn);
    end if;
    
    /* ПРОВЕРКИ */
    -- Каталоги 'Сборка, разборка'
    if sAcatalog in ('Сборка, разборка') then
      -- считывание связанного по входу документа
      nTransInvDept := F_DOCLINKS_LINK_IN_DOC('IncomFromDeps', rRow.rn, 'GoodsTransInvoicesToDepts');
      -- связанный документ есть 
      if nTransInvDept is not null then
        -- процесс НЕ Удаление РН в подразделение
        if CMP_VC2(USR_PKG_PROCESS.GET_PARUS_PROCESS(SUNITCODE => 'GoodsTransInvoicesToDepts', NMODE => 1), 'TRANSINVDEPT_DELETE') != 1 then
          -- запрет действия из текущего раздела
          P_EXCEPTION(0, 'Документ в каталоге "%s" удаляется автоматически при удалении связанного документа в разделе "%s". %s'
                     ,sAcatalog
                     ,F_UNITLIST_GETNAME('GoodsTransInvoicesToDepts')
                     ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
        end if;
      -- связаннонго документа нет 
      else
        P_EXCEPTION(0, 'Документ в каталоге "%s" не имеет связанного документа в разделе "%s". %s'
                   ,sAcatalog
                   ,F_UNITLIST_GETNAME('GoodsTransInvoicesToDepts')
                   ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
      end if;
    end if;

    -- По спецификациям
    for c in (select * from incomefromdepsspec where prn = rRow.rn)
    loop
      -- проверка перед удалением спецификаций
      incomefromdepsspec_bdelete(NRN => c.rn, NCOMPANY => c.company);
    end loop;

  end INCOMEFROMDEPS_BDELETE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end INCOMEFROMDEPS_BMOVE_IN;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
    rRow   incomefromdeps%rowtype;
    sAcatalog         acatalog.name%type;
  begin
    -- Считывание
    rRow := INCOMEFROMDEPS_GET(NRN); 
    sAcatalog     := GET_ACATALOG_NAME_ID(0, rRow.crn);

    -- ИСПРАВЛЕНИЯ
    
    /* ПРОВЕРКИ */
    -- Каталоги 'Сборка, разборка'
    if sAcatalog in ('Сборка, разборка') then
      P_EXCEPTION(0, 'Запрещено переносить документ из каталога "%s". %s'
                 ,sAcatalog
                 ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)
                 ); 
    end if;

  end INCOMEFROMDEPS_BMOVE_OUT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AASPLAN
  /*
  Заголовок. Проверка после отработки как план
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    nCrn     pkg_std.tref := 96011992;  -- 'Учет инструмента'
    rRow     incomefromdeps%rowtype;
  begin
    -- Заголовок  
    rRow := incomefromdeps_get(NRN);

    -- ИСПРАВЛЕНИЯ

    /* ПРОВЕРКИ */
    /* Запрет отработки как план */
    if rRow.doc_state = 1 then
      p_exception(0, 'Запрещено отрабатывать документ как план. %s'
                  ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
    end if;

  end INCOMEFROMDEPS_AASPLAN;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASFACT
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              incomefromdeps%rowtype;
    sAcatalog         acatalog.name%type;
    nTransInvDept     pkg_std.tref; 
    nCount            pkg_std.tnumber := 0; 
    nNumber           pkg_std.tnumber; 
    rSpec             incomefromdepsspec%rowtype;
  begin
    /* Заголовок */
    usr_pkg_pub_const.rIncomefromdeps := incomefromdeps_get(nrn => NRN);
    rRow      := usr_pkg_pub_const.rIncomefromdeps;
    sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* ИСПРАВЛЕНИЯ */
    /* По спецификациям */
    for c in (select * from incomefromdepsspec where prn = rRow.rn)
    loop
      /* Если заполнен товарный запас */
      if c.supply is not null then
        rSpec := c;
        /* очищаем */
        rSpec.supply := null;
        incomefromdepsspec_base_update(rrow => rSpec);
      end if;
      /* Каталоги 'Сборка, разборка' */
      if sAcatalog in ('Сборка, разборка') then
        /* Добавление калькуляций, если нет ни одной */
        select count(*) into nCount from incfdepspclc where prn = c.rn;
        if nCount = 0 then
          p_incfdepspclc_insert(ncompany      => c.company
                               ,nprn          => c.rn
                               ,snumb         => null
                               ,scost_article => null
                               ,scost_place   => null
                               ,ncost_plan    => null
                               ,ncost_fact    => null
                               ,npriority     => null
                               ,sfaceaccount  => get_faceacc_numb_id(nflag_smart => 0, nrn => rRow.out_faceacc)
                               ,sgraphpoint   => null
                               ,sfinoper_type => null
                               ,nquant_plan   => c.quant_plan
                               ,nquant_fact   => c.quant_fact
                               ,ssubdiv       => null
                               ,nrn           => nNumber);
        end if;
      end if;
    end loop;

  end INCOMEFROMDEPS_BASFACT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_AASFACT
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow            incomefromdeps%rowtype;
    sAcatalog       acatalog.name%type;
    nTransInvDept   pkg_std.tref; 
    
    nDocType      FCROUTLST.DOCTYPE%type;
    nPerMatres    FCROUTLST.PER_MATRES%type;
    nState        FCROUTLST.STATE%type;
    dDateClose    FCROUTLSTSP.Rlfact_Date%type;
    rOut_FaceAcc  faceacc%rowtype;
    sHead         pkg_std.tstring; 
    sSpec         pkg_std.tlstring; 
    nProductOrd   pkg_std.tref; 
    
    nNumber       pkg_std.tnumber; 
 begin
    /* Заголовок */
    rRow      := incomefromdeps_get(nrn => NRN);
    sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);
    /* Лицевой счёт */
    if rRow.out_faceacc is not null then
      rOut_FaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rRow.out_faceacc);
    end if;

    /* ИСПРАВЛЕНИЯ */
    /* Копирование доп.данных из свойств спецификации в приходную партию */
    usr_pkg_document.spec_props_copy_to_gp( nprn => rRow.rn );

    /* ПРОВЕРКИ */
    /* Базовая */
    incomefromdeps_check_base(nrn => rRow.rn, ncompany => rRow.company);

    /* Дата отработки НЕ РАВНА дате документа */
    if cmp_dat(rRow.work_date, rRow.doc_date) != 1 then
      p_exception(0, 'Дата отработки %s не равна дате документа %s.%s'
                 ,d2s(rRow.work_date)
                 ,d2s(rRow.doc_date)
                 ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)); 
    end if;

    /* Каталоги 'Сборка, разборка' */
    if sAcatalog in ('Сборка, разборка') then
      /* считывание связанного по входу документа */
      nTransInvDept := f_doclinks_link_in_doc('IncomFromDeps', rRow.rn, 'GoodsTransInvoicesToDepts');
      /* связанный документ есть */
      if nTransInvDept is not null then
        /* процесс НЕ Отработать РН в подразделение */
        if cmp_vc2(usr_pkg_process.get_parus_process(sunitcode => 'GoodsTransInvoicesToDepts', nmode => 1), 'TRANSINVDEPT_PROCESS') != 1 then
          /* запрет действия из текущего раздела */
          p_exception(0, 'Документ в каталоге "%s" отрабатывается автоматически при отработке связанного документа в разделе "%s". %s'
                     ,sAcatalog
                     ,f_unitlist_getname(sunitcode => 'GoodsTransInvoicesToDepts')
                     ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)); 
        end if;
      /* связанного документа нет */
      else
        p_exception(0, 'Документ в каталоге "%s" не имеет связанного документа в разделе "%s". %s'
                   ,sAcatalog
                   ,f_unitlist_getname(sunitcode => 'GoodsTransInvoicesToDepts')
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)); 
      end if;

      /* Дата отработки равна дате документа */
      if cmp_dat(rRow.work_date, rRow.doc_date) != 1 then
        P_EXCEPTION(0, 'Дата отработки %s не равна дате документа %s. %s'
                   ,d2s(rRow.work_date)
                   ,d2s(rRow.doc_date)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)
                   ); 
      end if;
    elsif sAcatalog in ('СГП') then /* KHOK 11/09/2024 Контроль выполнения операция МЛ */
      begin
        select ril.doctype, ril.per_matres, ril.rlfact_date, ril.state 
          into nDocType, nPerMatres, dDateClose, nState
          from (select row_number() over (order by sp.SIGN_CONTRL desc, sp.oper_numb desc) as seqnum,
                       lst.doctype, lst.per_matres, sp.state, sp.rlfact_date
                  from FCROUTLSTSP sp,
                       FCROUTLST   lst,
                       DOCLINKS    dl
                 where sp.company = NCOMPANY
                   and dl.out_document = rRow.Rn
                   and dl.in_document = lst.rn
                   and lst.rn = sp.prn
                   and (sp.oper_uk in ('Сборка','Контроль','Проверка','Лакирование','Оценка качества','Производ. контроль'/*, 'Упаковывание'*/) 
                     or sp.oper_tps in (20722606, 20722594, 20722619, 20722618, 20722593, 20722602/*, 20722621*/) )
          ) ril
          where seqnum = 1;
      exception
        when NO_DATA_FOUND then
          nState := 0; nPerMatres := null; dDateClose := null;
      end;
      
      if nDocType = 12140413 and nPerMatres is null and nState = 0 and dDateClose is null then -- МЛ на Головное изделие без выполнения контрольной операции
        p_exception(0, 'Приходование изделия на СГП невозможно. Не выполнена последняя контрольная операция Маршрутного листа.');
      end if;
    end if;
    
    /* Если лицевой счёт задан */    
    if rOut_FaceAcc.rn is not null then
      /* Тип не Внутренний */    
      if cmp_num( rOut_FaceAcc.ACC_CLASS, 3 ) != 1 then
        p_exception(0, 'Лицевой счёт <%s> должен иметь тип "Внутренний".%s'
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.rn)); 
      end if;
    end if;

    /* По спецификациям */
    for c in (select * from incomefromdepsspec where prn = rRow.rn)
    loop
      /* проверка резервирования по МХ */
      incomefromdepsspec_check_sprj(rrow => c);
      
      /* Если склад СГП */ 
      if rRow.store = 12047522 then
        /* Собираем описание спецификаций для рассылки */ 
        sSpec := substr( strcombine( sleft      => sSpec
                                    ,sright     => f_docdescrs_get_description( sunitcode => 'IncomFromDepsSpecs', ndocument => c.rn )
                                    ,sdelimeter => cr )
                       , 0
                       , 32760 );
      end if;

    end loop;

    /* Рассылка об отработке */
    /* Если склад СГП */ 
    if rRow.store = 12047522 then
      /* Описание заголовка */ 
      sHead := f_docdescrs_get_description( sunitcode => 'IncomFromDeps', ndocument => rRow.rn );

      /* Поиск входного заказа на производство */ 
      nProductOrd := incomefromdeps_get_po_rn( nrn => rRow.rn );

      /* Рассылка */ 
      usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany      => rRow.company
                                                  ,sdescription  => 'Парус. Отработан приход из подразделений на склад СГП: '||sHead
                                                  ,sto_list      => 'v.pogonin@module.ru;o.anufrienko@module.ru'
                                                  ,stitle        => 'Парус. Отработан приход из подразделений на склад СГП: '||sHead
                                                  ,ctext         => sHead ||', Заказ на производство: '|| f_docdescrs_get_description( sunitcode => 'ProductionOrders', ndocument => nProductOrd )
                                                                    ||cr||cr|| sSpec
                                                  ,nrn           => nNumber );
    end if;
    
  end INCOMEFROMDEPS_AASFACT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              incomefromdeps%rowtype;
    nNumber           pkg_std.tnumber; 
  begin
    null;
    /* Заголовок  */
    /*usr_pkg_pub_const.rIncomefromdeps := incomefromdeps_get(nrn => NRN);
    rRow := usr_pkg_pub_const.rIncomefromdeps;*/

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */

  end INCOMEFROMDEPS_BCANCEL;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              incomefromdeps%rowtype;
    sAcatalog         acatalog.name%type;
    nTransInvDept     pkg_std.tref; 
    nCount            pkg_std.tnumber := 0; 

    nNumber           pkg_std.tnumber := 0; 
  begin
    -- Заголовок  
    rRow := INCOMEFROMDEPS_GET(NRN);
    sAcatalog := GET_ACATALOG_NAME_ID(0, rRow.crn);

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    -- Каталоги 'Сборка, разборка'
    if sAcatalog in ('Сборка, разборка') then
      -- считывание связанного по входу документа
      nTransInvDept := F_DOCLINKS_LINK_IN_DOC('IncomFromDeps', rRow.rn, 'GoodsTransInvoicesToDepts');
      -- связанный документ есть 
      if nTransInvDept is not null then
        -- процесс НЕ Отменить отработку РН в подразделение
        if CMP_VC2(USR_PKG_PROCESS.GET_PARUS_PROCESS(SUNITCODE => 'GoodsTransInvoicesToDepts', NMODE => 1), 'TRANSINVDEPT_CANCEL') != 1 then
          -- запрет действия из текущего раздела
          P_EXCEPTION(0, 'Документ в каталоге "%s" отменяется автоматически при отмене отработки связанного документа в разделе "%s". %s'
                     ,sAcatalog
                     ,F_UNITLIST_GETNAME('GoodsTransInvoicesToDepts')
                     ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
        end if;
      -- связаннонго документа нет 
      else
        P_EXCEPTION(0, 'Документ в каталоге "%s" не имеет связанного документа в разделе "%s". %s'
                   ,sAcatalog
                   ,F_UNITLIST_GETNAME('GoodsTransInvoicesToDepts')
                   ,CR||F_DOCDESCRS_GET_DESCRIPTION('IncomFromDeps', rRow.rn)); 
      end if;
    end if;

    /* По спецификациям */
    for c in (select * from incomefromdepsspec where prn = rRow.rn)
    loop
      null;
    end loop;

  end INCOMEFROMDEPS_ACANCEL;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow            incomefromdeps%rowtype;
    sAcatalog       acatalog.name%type;
    nTransInvDept   pkg_std.tref; 
  begin
    null;
    -- Считывание
    /*rRow      := INCOMEFROMDEPS_GET(NRN);
    sAcatalog := GET_ACATALOG_NAME_ID(0, rRow.crn);*/

    /* ПРОВЕРКИ */

  end INCOMEFROMDEPS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASE_INSERT
  /*
  Заголовок. Добавить. Базовая
  */
  (
   rROW   in incomefromdeps%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_incomefromdeps_base_insert(ncompany          => rRow.company
                                ,ncrn              => rRow.crn
                                ,njur_pers         => rRow.jur_pers
                                ,ndoc_type         => rRow.doc_type
                                ,sdoc_pref         => rRow.doc_pref
                                ,sdoc_numb         => rRow.doc_numb
                                ,ddoc_date         => rRow.doc_date
                                ,nvalid_doctype    => rRow.valid_doctype
                                ,svalid_docnumb    => rRow.valid_docnumb
                                ,dvalid_docdate    => rRow.valid_docdate
                                ,nout_department   => rRow.out_department
                                ,nout_faceacc      => rRow.out_faceacc
                                ,nout_graphpoint   => rRow.out_graphpoint
                                ,nout_store        => rRow.out_store
                                ,nparty_agent      => rRow.party_agent
                                ,nstore            => rRow.store
                                ,nagent            => rRow.agent
                                ,ncurrency         => rRow.currency
                                ,nstore_oper       => rRow.store_oper
                                ,sparty            => rRow.party
                                ,snote             => rRow.note
                                ,ncurcours         => rRow.curcours
                                ,ncurbasecours     => rRow.curbasecours
                                ,ncurcours_doc     => rRow.curcours_doc
                                ,ncurbasecours_doc => rRow.curbasecours_doc
                                ,sbarcode          => rRow.barcode
                                ,nrn               => nRN);

  end INCOMEFROMDEPS_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASE_UPDATE
  /*
  Заголовок. Исправить. Базовая
  */
  (
   rROW   in incomefromdeps%rowtype
  ) 
  is
  begin
    p_incomefromdeps_base_update(nrn               => rRow.rn
                                ,ncompany          => rRow.company
                                ,njur_pers         => rRow.jur_pers
                                ,ndoc_type         => rRow.doc_type
                                ,sdoc_pref         => rRow.doc_pref
                                ,sdoc_numb         => rRow.doc_numb
                                ,ddoc_date         => rRow.doc_date
                                ,nvalid_doctype    => rRow.valid_doctype
                                ,svalid_docnumb    => rRow.valid_docnumb
                                ,dvalid_docdate    => rRow.valid_docdate
                                ,nout_department   => rRow.out_department
                                ,nout_faceacc      => rRow.out_faceacc
                                ,nout_graphpoint   => rRow.out_graphpoint
                                ,nout_store        => rRow.out_store
                                ,nparty_agent      => rRow.party_agent
                                ,nstore            => rRow.store
                                ,nagent            => rRow.agent
                                ,ncurrency         => rRow.currency
                                ,nstore_oper       => rRow.store_oper
                                ,sparty            => rRow.party
                                ,nparty_rn         => rRow.party_rn
                                ,snote             => rRow.note
                                ,ncurcours         => rRow.curcours
                                ,ncurbasecours     => rRow.curbasecours
                                ,ncurcours_doc     => rRow.curcours_doc
                                ,ncurbasecours_doc => rRow.curbasecours_doc
                                ,sbarcode          => rRow.barcode);

  end INCOMEFROMDEPS_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_INSERT
  /*
  Заголовок. Добавить. Клиентская
  */
  (
   rV_ROW   in v_incomefromdeps%rowtype
  ,nDUP_RN  in number
  ,nRN      out number
  ) 
  is
  begin
    p_incomefromdeps_insert(ncompany          => rV_ROW.NCOMPANY
                           ,ncrn              => rV_ROW.NCRN
                           ,sjur_pers         => rV_ROW.SJUR_PERS
                           ,sdoc_type         => rV_ROW.SDOC_TYPE
                           ,sdoc_pref         => rV_ROW.SDOC_PREF
                           ,sdoc_numb         => rV_ROW.SDOC_NUMB
                           ,ddoc_date         => rV_ROW.DDOC_DATE
                           ,svalid_doctype    => rV_ROW.SVALID_DOCTYPE
                           ,svalid_docnumb    => rV_ROW.SVALID_DOCNUMB
                           ,dvalid_docdate    => rV_ROW.DVALID_DOCDATE
                           ,sout_department   => rV_ROW.SOUT_DEPARTMENT
                           ,sout_faceacc      => rV_ROW.SOUT_FACEACC
                           ,sout_graphpoint   => rV_ROW.SOUT_GRAPHPOINT
                           ,sout_store        => rV_ROW.SOUT_STORE
                           ,sparty_agent      => rV_ROW.SPARTY_AGENT
                           ,sstore            => rV_ROW.SSTORE
                           ,sagent            => rV_ROW.SAGENT
                           ,scurrency         => rV_ROW.SCURRENCY
                           ,sstore_oper       => rV_ROW.SSTORE_OPER
                           ,sparty            => rV_ROW.SPARTY
                           ,snote             => rV_ROW.SNOTE
                           ,ncurcours         => rV_ROW.NCURCOURS
                           ,ncurbasecours     => rV_ROW.NCURBASECOURS
                           ,ncurcours_doc     => rV_ROW.NCURCOURS_DOC
                           ,ncurbasecours_doc => rV_ROW.NCURBASECOURS_DOC
                           ,sbarcode          => rV_ROW.SBARCODE
                           ,ndup_rn           => nDUP_RN
                           ,nrn               => nRN);
  end INCOMEFROMDEPS_INSERT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_UPDATE
  /*
  Заголовок. Исправить. Клиентская
  */
  (
   rV_ROW   in v_incomefromdeps%rowtype
  ) 
  is
  begin
    p_incomefromdeps_update(nrn               => rV_ROW.nrn
                           ,ncompany          => rV_ROW.ncompany
                           ,sjur_pers         => rV_ROW.sjur_pers
                           ,sdoc_type         => rV_ROW.sdoc_type
                           ,sdoc_pref         => rV_ROW.sdoc_pref
                           ,sdoc_numb         => rV_ROW.sdoc_numb
                           ,ddoc_date         => rV_ROW.ddoc_date
                           ,svalid_doctype    => rV_ROW.svalid_doctype
                           ,svalid_docnumb    => rV_ROW.svalid_docnumb
                           ,dvalid_docdate    => rV_ROW.dvalid_docdate
                           ,sout_department   => rV_ROW.sout_department
                           ,sout_faceacc      => rV_ROW.sout_faceacc
                           ,sout_graphpoint   => rV_ROW.sout_graphpoint
                           ,sout_store        => rV_ROW.sout_store
                           ,sparty_agent      => rV_ROW.sparty_agent
                           ,sstore            => rV_ROW.sstore
                           ,sagent            => rV_ROW.sagent
                           ,scurrency         => rV_ROW.scurrency
                           ,sstore_oper       => rV_ROW.sstore_oper
                           ,sparty            => rV_ROW.sparty
                           ,snote             => rV_ROW.snote
                           ,ncurcours         => rV_ROW.ncurcours
                           ,ncurbasecours     => rV_ROW.ncurbasecours
                           ,ncurcours_doc     => rV_ROW.ncurcours_doc
                           ,ncurbasecours_doc => rV_ROW.ncurbasecours_doc
                           ,sbarcode          => rV_ROW.sbarcode);
  end INCOMEFROMDEPS_UPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPS_BASE_SET_STAT
  /*
  Заголовок. Отработка документа. Внутри использует базовую процедуру, без прологов/эпилогов
  При снятии - делает копию с исходного документа, чтобы штатная процедура снятия отработки не очищала партию. После удаляет копию
  При отработке - отключает парамтер автоматической генерации партии, после отработки восстанавливает парамтр
  */
  (
   nRN      in number 
  ,nIDENT   in number 
  ,nSTATUS  in number 
  ) 
  is
    rIFD            incomefromdeps%rowtype;
    rIFDS           incomefromdepsspec%rowtype;
    rIFD_Copy       incomefromdeps%rowtype;
    rIFDS_Copy      incomefromdepsspec%rowtype;
    nIFD_Copy       pkg_std.tref; 
    nIFDS_Copy      pkg_std.tref; 
    nOptions        pkg_std.tnumber; 
    
    nNumber   pkg_std.tnumber; 
    sVarchar  pkg_std.tstring; 
  begin
    /* Считывание */
    rIFD := incomefromdeps_get(nrn => NRN);

    /* Если выполняется снятие отработки */
    if nSTATUS = 0 then

      /* Добавление копии заголовка с фиктивным префиксом, чтобы процедура снятия отработки не удалила партию из заголовка текущего документа */
      rIFD_Copy          := rIFD;
      rIFD_Copy.doc_pref := rIFD_Copy.rn;
      incomefromdeps_base_insert(rrow => rIFD_Copy, nrn => nIFD_Copy);

      /* По спецификациям исходного документа */
      for c in (select * from incomefromdepsspec where prn = rIFD.rn)
      loop
        /* Добавление спецификаций в копию */
        rIFDS_Copy     := c;
        rIFDS_Copy.prn := nIFD_Copy;
        incomefromdepsspec_base_insert(rrow => rIFDS_Copy, nrn => nIFDS_Copy);
        /* подстановка товарного запаса в скопированную спецификацию */
        rIFDS_Copy         := incomefromdepsspec_get(nrn => nIFDS_Copy);
        rIFDS_Copy.supply  := c.supply; 
        incomefromdepsspec_base_update(rrow => rIFDS_Copy);
      end loop;

      /* Процедура отработки исходного документа */
      p_incomefromdeps_bset_status(ncompany   => rIFD.company
                                  ,nrn        => rIFD.rn
                                  ,nident     => nIDENT
                                  ,nstatus    => nSTATUS
                                  ,dwork_date => rIFD.doc_date
                                  ,nwarning   => nNumber
                                  ,smsg       => sVarchar);
      /* Удаление копии */
      p_incomefromdeps_base_delete(ncompany => rIFD.company, nrn => nIFD_Copy);

    /* Если выполняется отработка */
    elsif nSTATUS = 2 then

      /* Считывание текущего значения параметра "Автоматическая генерация номера партии по лицевому счёту при отработке прихода из подразделений(Закупки Склад Реализация)" */
      nOptions := get_options_num(scode => 'Realiz_InFDeps_MakeParty', ncomp_vers => rIFD.company);

      /* По спецификациям исходного документа */
      for c in (select * from incomefromdepsspec where prn = rIFD.rn)
      loop
        /* очистка supply */
        rIFDS := c;
        rIFDS.supply := null;
        incomefromdepsspec_base_update(rrow => rIFDS);
      end loop;

      /* Исправление параметра на НЕТ, чтобы при отработке попал в ту же приходную партию */
      if cmp_num(nOptions, 0) != 1 then
        usr_pkg_common.options_set(scode       => 'Realiz_InFDeps_MakeParty'
                                  ,sauthid     => utilizer
                                  ,ncompany    => rIFD.company
                                  ,sstr_value  => null
                                  ,nnum_value  => 0
                                  ,ddate_value => null
                                  ,nrn         => nNumber);
      end if;

      /* Процедура отработки */
      p_incomefromdeps_bset_status(ncompany   => rIFD.company
                                  ,nrn        => rIFD.rn
                                  ,nident     => nIDENT
                                  ,nstatus    => nSTATUS
                                  ,dwork_date => rIFD.doc_date
                                  ,nwarning   => nNumber
                                  ,smsg       => sVarchar);

      /* Восстановление параметра "Автоматическая генерация номера партии по лицевому счёту при отработке прихода из подразделений(Закупки Склад Реализация)" */
      if nOptions = 1 then
        usr_pkg_common.options_set(scode       => 'Realiz_InFDeps_MakeParty'
                                  ,sauthid     => utilizer
                                  ,ncompany    => rIFD.company
                                  ,sstr_value  => null
                                  ,nnum_value  => 1
                                  ,ddate_value => null
                                  ,nrn         => nNumber);
      end if;                            
    else
      p_exception(0, 'Неверное значение параметра отработки документа'); 
    end if;                            

  end INCOMEFROMDEPS_BASE_SET_STAT;
  /*#########################################################################################################*/

  function INCOMEFROMDEPSSPEC_GET
  /*
  Спецификация. Считывание записи
  */
  (
   NRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return incomefromdepsspec%rowtype
  is
    rRow incomefromdepsspec%rowtype;
  begin
    begin
      select * into rRow from incomefromdepsspec where rn = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN,  sunit_table => 'INCOMEFROMDEPSSPEC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(NRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INCOMEFROMDEPSSPEC'))||'>.');
    end;
    return(rRow);
  end INCOMEFROMDEPSSPEC_GET;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    incomefromdepsspec_check_base(nrn => NRN, ncompany => NCOMPANY);

  end INCOMEFROMDEPSSPEC_AINSERT;
  
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end INCOMEFROMDEPSSPEC_BUPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              incomefromdepsspec%rowtype;
    sAcatalog         acatalog.name%type;
    nNumber           pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow      := incomefromdepsspec_get(nrn => NRN);
    sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rRow.crn);

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    incomefromdepsspec_check_base(nrn => NRN, ncompany => NCOMPANY);
    
  end INCOMEFROMDEPSSPEC_AUPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow              incomefromdepsspec%rowtype;
    sAcatalog         acatalog.name%type;
    nNumber           pkg_std.tnumber; 
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rIncomefromdepsspec := INCOMEFROMDEPSSPEC_GET(NRN);
    rRow      := usr_pkg_pub_const.rIncomefromdepsspec;
    sAcatalog := GET_ACATALOG_NAME_ID(0, rRow.crn);*/

    /* ИСПРАВЛЕНИЯ */

  end INCOMEFROMDEPSSPEC_BDELETE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              incomefromdepsspec%rowtype;
    rIncomeFromDeps   incomefromdeps%rowtype;
    rRlArticles       rlarticles%rowtype;
    nArticleSsupply   pkg_std.tref; 
    rGoodsSupply      goodssupply%rowtype;
    nDicNomns         pkg_std.tnumber; 
    rDicNomns         dicnomns%rowtype;
    nFcRoutLst        pkg_std.tref; 

    sVarchar          pkg_std.tstring;
    nNumber           pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow            := incomefromdepsspec_get(nrn => nRN);
    rIncomeFromDeps := incomefromdeps_get(nrn => rRow.prn);
    nDicNomns       := usr_pkg_dicnomns.nommodif_get_prn_by_rn(nflagsmart => 0, nrn => rRow.nommodif);
    rDicNomns       := usr_pkg_dicnomns.dicnomns_get(nrn => nDicNomns);
    nFcRoutLst      := usr_pkg_doclinks.doclinks_link_in_doc( ntoo_many_rows => 0
                                                             ,sout_unitcode  => 'IncomFromDeps'
                                                             ,nout_document  => rRow.prn
                                                             ,sin_unitcode   => 'CostRouteLists' );
    /* Изделие */
    if rRow.article is not null then
      /* Считывание записи изделия */
      rRlArticles := usr_pkg_rlarticles.rlarticles_get(nrn => rRow.article);
      /* Изделие на складе */
      find_articlessupply_by_article(nflag_smart  => 1
                                    ,nflag_option => 1
                                    ,ncompany     => rRow.company
                                    ,narticle     => rRlArticles.rn
                                    ,sarticle     => null
                                    ,nrn          => nArticleSsupply
                                    ,nship_plan   => nNumber);
      /* Товарный запас по изделию на складе */
      if nArticleSsupply is not null then
        usr_pkg_goodsparties.goodssupply_get_by_gssa(nflagsmart => 0
                                                    ,ngssa      => nArticleSsupply
                                                    ,ncompany   => rRow.company
                                                    ,nrn        => rGoodsSupply.rn);
      end if;                                                  
      /* Данные товарного запаса */
      if rGoodsSupply.rn is not null then
        find_goodssupply_full_by_rn(ncompany     => rRow.company
                                   ,nflag_smart  => 0
                                   ,nrn          => rGoodsSupply.rn
                                   ,ddate        => rIncomeFromDeps.doc_date
                                   ,nrestplan    => nNumber
                                   ,nrestplanalt => nNumber
                                   ,nrestfact    => rGoodsSupply.restfact
                                   ,nrestfactalt => nNumber
                                   ,nreserv      => nNumber
                                   ,nreservalt   => nNumber);
      end if;                                 
    end if;    

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКА */
    /* Количество не нулевое */
    if rRow.quant_plan = 0 then 
       p_exception(0, 'Количество "По документу" равно нулю. %s%s'
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rRow.rn)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.prn)); 
    end if;
    if rRow.quant_fact = 0 then 
       p_exception(0, 'Количество "Фактически принято" равно нулю. %s%s'
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rRow.rn)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.prn)); 
    end if;
    /* Количество по документу НЕ равно фактическому */
    if rRow.quant_plan != rRow.quant_fact then 
       p_exception(0, 'Количество "По документу" <%s> не равно "Фактически принято" <%s>. %s%s'
                  ,rRow.quant_plan
                  ,rRow.quant_fact
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rRow.rn)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.prn)); 
    end if;
    /* Изделие числится в учёте */
    if nvl(rGoodsSupply.restfact, 0) != 0 then 
       p_exception(0, 'Изделие <%s> числится в учёте на дату документа <%s>. Повторный приход запрещён. %s%s'
                  ,rRlArticles.code
                  ,decode_date(rIncomeFromDeps.doc_date)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rRow.rn)
                  ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.prn)); 
    end if;
    /* Номенклатура по серийным номерам и не указано изделие */
    if rDicNomns.sign_serial = 1 and rRow.article is null then
      p_exception(0, 'Не заполнено изделие при том, что номеклатура учитывается по серийным номерам. %s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.prn)); 
    end if; 
    /* Есть маршрутный лист */
    if nFcRoutLst is not null and rDicNomns.sign_serial = 1 then /*Если нет учета по серийным номерам, то и не проверяем*/
      /* Поиск в нём такого же изделия, что в спецификации */
      begin
        select null
          into sVarchar
          from fcroutlstsernumb t
         where t.prn     = nFcRoutLst
           and t.article = nvl(rRow.article, 0);
      exception
        when no_data_found then
          p_exception(0, 'В маршрутном листе <%s> не найден заводской номер %s, указанный в спецификации. %s%s'                    
                     ,f_docdescrs_get_description(sunitcode => 'CostRouteLists', ndocument => nFcRoutLst)
                     ,nvl(rRow.article, 0) 
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rRow.rn)
                     ,cr||cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rRow.prn)); 
        when others then
          p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.%s'
                     ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')) 
                     ,cr||cr||sqlerrm );
      end;
    end if;

  end INCOMEFROMDEPSSPEC_CHECK_BASE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_CHECK_SPRJ
  /*
  Спецификация. Проверка резервирования по местам хранения
  */
  (
   rROW       in incomefromdepsspec%rowtype
  ) 
  is
  begin
    /* По связанным записям резервирования по МХ */
    for c in (
              select sprj.nommodif, sprj.article
                from doclinks t
                    ,strplresjrnl       sprj
               where t.in_document  = rROW.RN
                 and t.out_document = sprj.rn
             )
    loop
      /* номенклатура */
      if cmp_num(c.nommodif, rRow.nommodif) != 1 then
        p_exception(0, 'Номенклатура в журнале резервирования по местам хранения <%s> отличается от спецификации. '|| 
                       'Повторно выполните размещение по местам хранения. %s%s'
                   ,usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => c.nommodif)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rROW.RN)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rROW.PRN)); 
      end if;
      /* изделие */
      if cmp_num(c.article, rRow.article) != 1 then
        p_exception(0, 'Изделие в журнале резервирования по местам хранения <%s> отличается от спецификации. '|| 
                       'Повторно выполните размещение по местам хранения. %s%s'
                   ,f_rlarticles_get_code(narticle =>  c.article)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDepsSpecs', ndocument => rROW.RN)
                   ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => rROW.PRN)); 
      end if;
    end loop;
    
  end INCOMEFROMDEPSSPEC_CHECK_SPRJ;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BASE_INSERT
  /*
  Спецификация. Добавить. Базовая
  */
  (
   rROW   in incomefromdepsspec%rowtype
  ,nRN    out number
  ) 
  is
  begin
    p_incomefromdpspec_base_insert(ncompany        => rROW.COMPANY
                                  ,nprn            => rROW.PRN
                                  ,nnommodif       => rROW.NOMMODIF
                                  ,npack           => rROW.PACK
                                  ,narticle        => rROW.ARTICLE
                                  ,ncell           => rROW.CELL
                                  ,nparty_agent    => rROW.PARTY_AGENT
                                  ,nsupply         => rROW.SUPPLY
                                  ,nquant_plan     => rROW.QUANT_PLAN
                                  ,nquant_fact     => rROW.QUANT_FACT
                                  ,nquant_plan_alt => rROW.QUANT_PLAN_ALT
                                  ,nquant_fact_alt => rROW.QUANT_FACT_ALT
                                  ,dsrok           => rROW.SROK
                                  ,ssertificate    => rROW.SERTIFICATE
                                  ,nprice          => rROW.PRICE
                                  ,npricemeas      => rROW.PRICEMEAS
                                  ,nsumm_plan      => rROW.SUMM_PLAN
                                  ,nsumm_fact      => rROW.SUMM_FACT
                                  ,snote           => rROW.NOTE
                                  ,ssernumb        => rROW.SERNUMB
                                  ,sbarcode        => rROW.BARCODE
                                  ,ncountry        => rROW.COUNTRY
                                  ,sgtd            => rROW.GTD
                                  ,nproducer       => rROW.PRODUCER
                                  ,nstorage_time   => rROW.STORAGE_TIME
                                  ,numeas_storage  => rROW.UMEAS_STORAGE
                                  ,dprod_date      => rROW.PROD_DATE
                                  ,scardnumb       => rROW.CARDNUMB
                                  ,nrn             => nRN);
  end INCOMEFROMDEPSSPEC_BASE_INSERT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_BASE_UPDATE
  /*
  Спецификация. Исправить. Базовая
  */
  (
   rROW   in incomefromdepsspec%rowtype
  ) 
  is
  begin
    p_incomefromdpspec_base_update(nrn             => rROW.RN
                                  ,ncompany        => rROW.COMPANY
                                  ,nprn            => rROW.PRN
                                  ,nnommodif       => rROW.NOMMODIF
                                  ,npack           => rROW.PACK
                                  ,narticle        => rROW.ARTICLE
                                  ,ncell           => rROW.CELL
                                  ,nparty_agent    => rROW.PARTY_AGENT
                                  ,nsupply         => rROW.SUPPLY
                                  ,nquant_plan     => rROW.QUANT_PLAN
                                  ,nquant_fact     => rROW.QUANT_FACT
                                  ,nquant_plan_alt => rROW.QUANT_PLAN_ALT
                                  ,nquant_fact_alt => rROW.QUANT_FACT_ALT
                                  ,dsrok           => rROW.SROK
                                  ,ssertificate    => rROW.SERTIFICATE
                                  ,nprice          => rROW.PRICE
                                  ,npricemeas      => rROW.PRICEMEAS
                                  ,nsumm_plan      => rROW.SUMM_PLAN
                                  ,nsumm_fact      => rROW.SUMM_FACT
                                  ,snote           => rROW.NOTE
                                  ,ssernumb        => rROW.SERNUMB
                                  ,sbarcode        => rROW.BARCODE
                                  ,ncountry        => rROW.COUNTRY
                                  ,sgtd            => rROW.GTD
                                  ,nproducer       => rROW.PRODUCER
                                  ,nstorage_time   => rROW.STORAGE_TIME
                                  ,numeas_storage  => rROW.UMEAS_STORAGE
                                  ,dprod_date      => rROW.PROD_DATE
                                  ,scardnumb       => rROW.CARDNUMB);
  end INCOMEFROMDEPSSPEC_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_INSERT
  /*
  Спецификация. Добавить. Клиентская
  */
  (
   rV_ROW   in v_incomefromdepsspec%rowtype
  ,nRN      out number
  ) 
  is
  begin
    p_incomefromdepsspec_insert(ncompany        => rV_ROW.NCOMPANY
                               ,nprn            => rV_ROW.NPRN
                               ,snomen          => rV_ROW.SNOMEN
                               ,snommodif       => rV_ROW.SNOMMODIF
                               ,snomnpack       => rV_ROW.SPACK
                               ,sarticle        => rV_ROW.SARTICLE
                               ,scell           => rV_ROW.SCELL
                               ,sparty_agent    => rV_ROW.SPARTY_AGENT
                               ,ssupply         => rV_ROW.SSUPPLY
                               ,sstore          => null
                               ,nquant_plan     => rV_ROW.NQUANT_PLAN
                               ,nquant_fact     => rV_ROW.NQUANT_FACT
                               ,nquant_plan_alt => rV_ROW.NQUANT_PLAN_ALT
                               ,nquant_fact_alt => rV_ROW.NQUANT_FACT_ALT
                               ,dsrok           => rV_ROW.DSROK
                               ,ssertificate    => rV_ROW.SSERTIFICATE
                               ,nprice          => rV_ROW.NPRICE
                               ,npricemeas      => rV_ROW.NPRICEMEAS
                               ,nsumm_plan      => rV_ROW.NSUMM_PLAN
                               ,nsumm_fact      => rV_ROW.NSUMM_FACT
                               ,snote           => rV_ROW.SNOTE
                               ,ssernumb        => rV_ROW.SSERNUMB
                               ,sbarcode        => rV_ROW.SBARCODE
                               ,scountry        => rV_ROW.SCOUNTRY
                               ,sgtd            => rV_ROW.SGTD
                               ,sproducer       => rV_ROW.SPRODUCER
                               ,nstorage_time   => rV_ROW.NSTORAGE_TIME
                               ,sumeas_storage  => rV_ROW.SUMEAS_STORAGE
                               ,dprod_date      => rV_ROW.DPROD_DATE
                               ,scardnumb       => rV_ROW.SCARDNUMB
                               ,nrn             => NRN);
  end INCOMEFROMDEPSSPEC_INSERT;
  /*#########################################################################################################*/

  procedure INCOMEFROMDEPSSPEC_UPDATE
  /*
  Спецификация. Исправить. Клиентская
  */
  (
   rV_ROW         in v_incomefromdepsspec%rowtype
  ,nFLAG_DEL_CALC in number default 0
  ) 
  is
  begin
    p_incomefromdepsspec_update(ncompany        => rV_ROW.NCOMPANY
                               ,nrn             => rV_ROW.NRN
                               ,nprn            => rV_ROW.NPRN
                               ,snomen          => rV_ROW.SNOMEN
                               ,snommodif       => rV_ROW.SNOMMODIF
                               ,snomnpack       => rV_ROW.SPACK
                               ,sarticle        => rV_ROW.SARTICLE
                               ,scell           => rV_ROW.SCELL
                               ,sparty_agent    => rV_ROW.SPARTY_AGENT
                               ,ssupply         => rV_ROW.SSUPPLY
                               ,sstore          => null
                               ,nquant_plan     => rV_ROW.NQUANT_PLAN
                               ,nquant_fact     => rV_ROW.NQUANT_FACT
                               ,nquant_plan_alt => rV_ROW.NQUANT_PLAN_ALT
                               ,nquant_fact_alt => rV_ROW.NQUANT_FACT_ALT
                               ,dsrok           => rV_ROW.DSROK
                               ,ssertificate    => rV_ROW.SSERTIFICATE
                               ,nprice          => rV_ROW.NPRICE
                               ,npricemeas      => rV_ROW.NPRICEMEAS
                               ,nsumm_plan      => rV_ROW.NSUMM_PLAN
                               ,nsumm_fact      => rV_ROW.NSUMM_FACT
                               ,snote           => rV_ROW.SNOTE
                               ,ssernumb        => rV_ROW.SSERNUMB
                               ,sbarcode        => rV_ROW.SBARCODE
                               ,scountry        => rV_ROW.SCOUNTRY
                               ,sgtd            => rV_ROW.SGTD
                               ,sproducer       => rV_ROW.SPRODUCER
                               ,nstorage_time   => rV_ROW.NSTORAGE_TIME
                               ,sumeas_storage  => rV_ROW.SUMEAS_STORAGE
                               ,dprod_date      => rV_ROW.DPROD_DATE
                               ,scardnumb       => rV_ROW.SCARDNUMB
                               ,nflag_del_calc  => nFLAG_DEL_CALC);
  end INCOMEFROMDEPSSPEC_UPDATE;
  /*#########################################################################################################*/

end USR_PKG_INCOMEFROMDEPS;
/
